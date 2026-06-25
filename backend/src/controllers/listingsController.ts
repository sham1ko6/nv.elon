import fs from 'fs';
import path from 'path';
import { Request, Response, NextFunction } from 'express';
import { query, execute } from '../config/db';
import { AppError } from '../middleware/errorHandler';
import { Listing, ListingImage, ContactEventType, Subscription } from '../types';

const UPLOAD_DIR = process.env.UPLOAD_DIR || './uploads';

const DEFAULT_LIMIT = 20;

interface AppSettingsMap {
  posting_fee_amount: number;
  posting_fee_currency: string;
  ad_duration_days: number;
}

async function loadAppSettings(): Promise<AppSettingsMap> {
  const rows = await query<{ key: string; value: string }>('SELECT `key`, `value` FROM app_settings');
  const map: Record<string, string> = {};
  rows.forEach((row) => {
    map[row.key] = row.value;
  });
  return {
    posting_fee_amount: Number(map.posting_fee_amount ?? 0),
    posting_fee_currency: map.posting_fee_currency ?? 'UZS',
    ad_duration_days: Number(map.ad_duration_days ?? 30),
  };
}

function maskPhone(phone: string): string {
  if (phone.length <= 7) return phone;
  return `${phone.slice(0, 4)}**${phone.slice(-7)}`;
}

export async function listListings(req: Request, res: Response, next: NextFunction) {
  try {
    const { q, category, subcategory, location, min, max, sort } = req.query as Record<string, string | undefined>;
    const page = Math.max(1, Number(req.query.page) || 1);
    const limit = Math.max(1, Number(req.query.limit) || DEFAULT_LIMIT);
    const offset = (page - 1) * limit;

    const joins: string[] = [
      'JOIN categories c ON c.id = l.category_id',
      'LEFT JOIN subcategories sc ON sc.id = l.subcategory_id',
    ];
    const conditions: string[] = ["l.status = 'active'", 'l.expires_at > NOW()'];
    const params: unknown[] = [];

    if (q) {
      conditions.push('MATCH(l.title, l.description) AGAINST (? IN NATURAL LANGUAGE MODE)');
      params.push(q);
    }
    if (category) {
      conditions.push('c.slug = ?');
      params.push(category);
    }
    if (subcategory) {
      conditions.push('sc.slug = ?');
      params.push(subcategory);
    }
    if (location) {
      conditions.push('l.location LIKE ?');
      params.push(`%${location}%`);
    }
    if (min) {
      conditions.push('l.price >= ?');
      params.push(Number(min));
    }
    if (max) {
      conditions.push('l.price <= ?');
      params.push(Number(max));
    }

    const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const joinClause = joins.join(' ');

    let orderClause = 'ORDER BY l.created_at DESC';
    if (sort === 'price_asc') orderClause = 'ORDER BY l.price ASC';
    else if (sort === 'price_desc') orderClause = 'ORDER BY l.price DESC';

    const countRows = await query<{ total: number }>(
      `SELECT COUNT(*) AS total FROM listings l ${joinClause} ${whereClause}`,
      params
    );
    const total = countRows[0]?.total ?? 0;

    const data = await query<Listing>(
      `SELECT l.* FROM listings l ${joinClause} ${whereClause} ${orderClause} LIMIT ? OFFSET ?`,
      [...params, limit, offset]
    );

    res.status(200).json({
      data,
      total,
      page,
      totalPages: Math.max(1, Math.ceil(total / limit)),
    });
  } catch (err) {
    next(err);
  }
}

export async function getListing(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;

    const [listing] = await query<Listing>('SELECT * FROM listings WHERE id = ?', [id]);
    if (!listing) {
      throw new AppError(404, "E'lon topilmadi");
    }

    await execute('UPDATE listings SET views = views + 1 WHERE id = ?', [id]);

    const images = await query<ListingImage>(
      'SELECT * FROM listing_images WHERE listing_id = ? ORDER BY sort_order ASC, id ASC',
      [id]
    );

    const [seller] = await query<{ name: string; phone: string }>(
      'SELECT name, phone FROM users WHERE id = ?',
      [listing.user_id]
    );

    res.status(200).json({
      listing: { ...listing, views: listing.views + 1 },
      images,
      seller: seller ? { name: seller.name, phone: maskPhone(seller.phone) } : null,
    });
  } catch (err) {
    next(err);
  }
}

export async function createListing(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.user!.id;
    const { title, description, price, currency, category_id, subcategory_id, location, contact_phone } =
      req.body as {
        title?: string;
        description?: string;
        price?: number;
        currency?: string;
        category_id?: number;
        subcategory_id?: number;
        location?: string;
        contact_phone?: string;
      };

    if (!title || !description || price == null || !category_id || !location || !contact_phone) {
      throw new AppError(400, "Barcha majburiy maydonlarni to'ldiring");
    }
    if (Number(price) <= 0) {
      throw new AppError(400, "Narx 0 dan katta bo'lishi kerak");
    }

    const settings = await loadAppSettings();

    const [activeSub] = await query<Subscription & { max_active_ads: number }>(
      `SELECT s.*, p.max_active_ads FROM subscriptions s
       JOIN plans p ON p.id = s.plan_id
       WHERE s.user_id = ? AND s.status = 'active' AND s.expires_at > NOW()
       LIMIT 1`,
      [userId]
    );

    let activeAdsCount = 0;
    if (activeSub) {
      const [{ count }] = await query<{ count: number }>(
        "SELECT COUNT(*) AS count FROM listings WHERE subscription_id = ? AND status = 'active'",
        [activeSub.id]
      );
      activeAdsCount = count;
    }

    const hasSubscriptionSlot = !!activeSub && activeAdsCount < activeSub.max_active_ads;

    if (hasSubscriptionSlot && activeSub) {
      const result = await execute(
        `INSERT INTO listings
          (user_id, category_id, subcategory_id, title, description, price, currency, location,
           contact_phone, status, source, subscription_id, published_at, expires_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'active', 'subscription', ?, NOW(), ?)`,
        [
          userId,
          category_id,
          subcategory_id ?? null,
          title,
          description,
          price,
          currency ?? 'USD',
          location,
          contact_phone,
          activeSub.id,
          activeSub.expires_at,
        ]
      );

      const [listing] = await query<Listing>('SELECT * FROM listings WHERE id = ?', [result.insertId]);
      return res.status(201).json({ listing });
    }

    const result = await execute(
      `INSERT INTO listings
        (user_id, category_id, subcategory_id, title, description, price, currency, location,
         contact_phone, status, source)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending_payment', 'posting_fee')`,
      [userId, category_id, subcategory_id ?? null, title, description, price, currency ?? 'USD', location, contact_phone]
    );

    const listingId = result.insertId;
    const orderResult = await execute(
      `INSERT INTO ad_orders (user_id, type, listing_id, amount, currency, status)
       VALUES (?, 'posting_fee', ?, ?, ?, 'created')`,
      [userId, listingId, settings.posting_fee_amount, settings.posting_fee_currency]
    );

    const [listing] = await query<Listing>('SELECT * FROM listings WHERE id = ?', [listingId]);
    res.status(201).json({ listing, order_id: orderResult.insertId });
  } catch (err) {
    next(err);
  }
}

export async function updateListing(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const { title, description, price, location } = req.body as {
      title?: string;
      description?: string;
      price?: number;
      location?: string;
    };

    const [listing] = await query<Listing>('SELECT * FROM listings WHERE id = ?', [id]);
    if (!listing) {
      throw new AppError(404, "E'lon topilmadi");
    }
    if (listing.user_id !== req.user!.id) {
      throw new AppError(403, "Faqat egasi e'lonni tahrirlashi mumkin");
    }
    if (price != null && Number(price) <= 0) {
      throw new AppError(400, "Narx 0 dan katta bo'lishi kerak");
    }

    await execute(
      'UPDATE listings SET title = ?, description = ?, price = ?, location = ? WHERE id = ?',
      [
        title ?? listing.title,
        description ?? listing.description,
        price ?? listing.price,
        location ?? listing.location,
        id,
      ]
    );

    const [updated] = await query<Listing>('SELECT * FROM listings WHERE id = ?', [id]);
    res.status(200).json({ listing: updated });
  } catch (err) {
    next(err);
  }
}

export async function deleteListing(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;

    const [listing] = await query<Listing>('SELECT * FROM listings WHERE id = ?', [id]);
    if (!listing) {
      throw new AppError(404, "E'lon topilmadi");
    }
    if (listing.user_id !== req.user!.id && req.user!.role !== 'admin') {
      throw new AppError(403, "Faqat egasi yoki admin e'lonni o'chirishi mumkin");
    }

    // ad_orders.listing_id has no ON DELETE CASCADE, so any draft/unpaid order
    // tied to this listing must be cleaned up here or the delete would fail
    // with a foreign key violation.
    const orders = await query<{ id: number }>('SELECT id FROM ad_orders WHERE listing_id = ?', [id]);
    for (const order of orders) {
      await execute('DELETE FROM payment_transactions WHERE ad_order_id = ?', [order.id]);
    }
    if (orders.length) {
      await execute('DELETE FROM ad_orders WHERE listing_id = ?', [id]);
    }

    await execute('DELETE FROM listings WHERE id = ?', [id]);
    res.status(200).json({ message: "E'lon o'chirildi" });
  } catch (err) {
    if (err instanceof Error && 'code' in err && (err as { code?: string }).code === 'ER_ROW_IS_REFERENCED_2') {
      return next(new AppError(409, "Bu e'lon buyurtmaga bog'langan, avval buyurtmani tozalang"));
    }
    next(err);
  }
}

export async function getMyListings(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.user!.id;
    const data = await query<Listing & { order_status: string | null; order_id: number | null }>(
      `SELECT l.*,
        (SELECT ao.status FROM ad_orders ao WHERE ao.listing_id = l.id ORDER BY ao.created_at DESC LIMIT 1) AS order_status,
        (SELECT ao.id FROM ad_orders ao WHERE ao.listing_id = l.id ORDER BY ao.created_at DESC LIMIT 1) AS order_id
       FROM listings l
       WHERE l.user_id = ?
       ORDER BY l.created_at DESC`,
      [userId]
    );
    res.status(200).json({ data });
  } catch (err) {
    next(err);
  }
}

export async function contactListing(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const { type } = req.body as { type?: ContactEventType };
    const eventType: ContactEventType = type === 'call' || type === 'share' ? type : 'view_phone';

    const [listing] = await query<Listing>('SELECT * FROM listings WHERE id = ?', [id]);
    if (!listing) {
      throw new AppError(404, "E'lon topilmadi");
    }

    await execute(
      'INSERT INTO contact_events (listing_id, viewer_id, type) VALUES (?, ?, ?)',
      [id, req.user?.id ?? null, eventType]
    );

    res.status(200).json({ phone: listing.contact_phone });
  } catch (err) {
    next(err);
  }
}

export async function uploadImages(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const files = (req.files as Express.Multer.File[] | undefined) ?? [];

    const [listing] = await query<Listing>('SELECT * FROM listings WHERE id = ?', [id]);
    if (!listing) {
      throw new AppError(404, "E'lon topilmadi");
    }
    if (listing.user_id !== req.user!.id) {
      throw new AppError(403, "Faqat egasi rasm qo'shishi mumkin");
    }
    if (files.length === 0) {
      throw new AppError(400, 'Kamida bitta rasm yuklang');
    }

    const urls: string[] = [];
    for (const file of files) {
      const url = `/uploads/${file.filename}`;
      await execute('INSERT INTO listing_images (listing_id, url) VALUES (?, ?)', [id, url]);
      urls.push(url);
    }

    res.status(201).json({ images: urls });
  } catch (err) {
    next(err);
  }
}

export async function deleteImage(req: Request, res: Response, next: NextFunction) {
  try {
    const { id, imageId } = req.params;

    const [listing] = await query<Listing>('SELECT * FROM listings WHERE id = ?', [id]);
    if (!listing) {
      throw new AppError(404, "E'lon topilmadi");
    }
    if (listing.user_id !== req.user!.id) {
      throw new AppError(403, "Faqat egasi rasmni o'chirishi mumkin");
    }

    const [image] = await query<ListingImage>('SELECT * FROM listing_images WHERE id = ? AND listing_id = ?', [
      imageId,
      id,
    ]);
    if (!image) {
      throw new AppError(404, 'Rasm topilmadi');
    }

    const filePath = path.join(UPLOAD_DIR, path.basename(image.url));
    fs.unlink(filePath, () => {
      // best-effort disk cleanup; ignore errors (e.g. file already gone)
    });

    await execute('DELETE FROM listing_images WHERE id = ?', [imageId]);

    res.status(200).json({ message: "Rasm o'chirildi" });
  } catch (err) {
    next(err);
  }
}
