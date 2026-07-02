import fs from 'fs';
import path from 'path';
import { Request, Response, NextFunction } from 'express';
import supabase from '../config/db';
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
  const { data, error } = await supabase.from('app_settings').select('key, value');
  if (error) throw error;

  const map: Record<string, string> = {};
  ((data ?? []) as Array<{ key: string; value: string }>).forEach((row) => {
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
    const { q, category, subcategory, location, min, max, sort } = req.query as Record<
      string,
      string | undefined
    >;
    const page = Math.max(1, Number(req.query.page) || 1);
    const limit = Math.max(1, Number(req.query.limit) || DEFAULT_LIMIT);
    const offset = (page - 1) * limit;

    // Resolve category/subcategory slugs to IDs (avoids join filter complexity)
    let categoryId: number | null = null;
    let subcategoryId: number | null = null;

    if (category) {
      const { data: cat } = await supabase
        .from('categories')
        .select('id')
        .eq('slug', category)
        .maybeSingle();
      categoryId = (cat as { id: number } | null)?.id ?? null;
    }
    if (subcategory) {
      const { data: subcat } = await supabase
        .from('subcategories')
        .select('id')
        .eq('slug', subcategory)
        .maybeSingle();
      subcategoryId = (subcat as { id: number } | null)?.id ?? null;
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let dbQuery: any = supabase
      .from('listings')
      .select('*', { count: 'exact' })
      .eq('status', 'active')
      .or(`expires_at.is.null,expires_at.gt.${new Date().toISOString()}`);

    if (q) dbQuery = dbQuery.or(`title.ilike.%${q}%,description.ilike.%${q}%`);
    if (categoryId !== null) dbQuery = dbQuery.eq('category_id', categoryId);
    if (subcategoryId !== null) dbQuery = dbQuery.eq('subcategory_id', subcategoryId);
    if (location) dbQuery = dbQuery.ilike('location', `%${location}%`);
    if (min) dbQuery = dbQuery.gte('price', Number(min));
    if (max) dbQuery = dbQuery.lte('price', Number(max));

    if (sort === 'price_asc') dbQuery = dbQuery.order('price', { ascending: true });
    else if (sort === 'price_desc') dbQuery = dbQuery.order('price', { ascending: false });
    else dbQuery = dbQuery.order('created_at', { ascending: false });

    dbQuery = dbQuery.range(offset, offset + limit - 1);

    const { data, error, count } = await dbQuery;
    if (error) throw error;

    res.status(200).json({
      data: data ?? [],
      total: count ?? 0,
      page,
      totalPages: Math.max(1, Math.ceil((count ?? 0) / limit)),
    });
  } catch (err) {
    next(err);
  }
}

export async function getListing(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;

    const { data: listingData, error } = await supabase
      .from('listings')
      .select('*')
      .eq('id', id)
      .maybeSingle();
    if (error) throw error;
    if (!listingData) throw new AppError(404, "E'lon topilmadi");

    const listing = listingData as Listing;

    // Atomic view increment via DB function
    await supabase.rpc('increment_listing_views', { p_id: Number(id) });

    const { data: imagesData } = await supabase
      .from('listing_images')
      .select('*')
      .eq('listing_id', id)
      .order('sort_order')
      .order('id');

    const { data: sellerData } = await supabase
      .from('users')
      .select('name, phone')
      .eq('id', listing.user_id)
      .maybeSingle();

    const seller = sellerData as { name: string; phone: string } | null;

    res.status(200).json({
      listing: { ...listing, views: listing.views + 1 },
      images: (imagesData ?? []) as ListingImage[],
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

    // Check for an active subscription with remaining ad slots
    const { data: subData } = await supabase
      .from('subscriptions')
      .select('*, plans!plan_id(max_active_ads)')
      .eq('user_id', userId)
      .eq('status', 'active')
      .gt('expires_at', new Date().toISOString())
      .order('expires_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const activeSub = subData as any;

    let hasSubscriptionSlot = false;
    if (activeSub) {
      const { count } = await supabase
        .from('listings')
        .select('*', { count: 'exact', head: true })
        .eq('subscription_id', activeSub.id)
        .eq('status', 'active');
      const activeAdsCount = count ?? 0;
      hasSubscriptionSlot = activeAdsCount < (activeSub.plans?.max_active_ads ?? 0);
    }

    if (hasSubscriptionSlot && activeSub) {
      const { data: listingData, error } = await supabase
        .from('listings')
        .insert({
          user_id: userId,
          category_id,
          subcategory_id: subcategory_id ?? null,
          title,
          description,
          price,
          currency: currency ?? 'USD',
          location,
          contact_phone,
          status: 'active',
          source: 'subscription',
          subscription_id: activeSub.id,
          published_at: new Date().toISOString(),
          expires_at: activeSub.expires_at,
        })
        .select()
        .single();
      if (error) throw error;
      return res.status(201).json({ listing: listingData as Listing });
    }

    // No subscription slot → requires posting fee payment
    const { data: listingData, error: listingError } = await supabase
      .from('listings')
      .insert({
        user_id: userId,
        category_id,
        subcategory_id: subcategory_id ?? null,
        title,
        description,
        price,
        currency: currency ?? 'USD',
        location,
        contact_phone,
        status: 'pending_payment',
        source: 'posting_fee',
      })
      .select()
      .single();
    if (listingError) throw listingError;

    const listingId = (listingData as Listing).id;

    const { data: orderData, error: orderError } = await supabase
      .from('ad_orders')
      .insert({
        user_id: userId,
        type: 'posting_fee',
        listing_id: listingId,
        amount: settings.posting_fee_amount,
        currency: settings.posting_fee_currency,
        status: 'created',
      })
      .select('id')
      .single();
    if (orderError) throw orderError;

    res.status(201).json({
      listing: listingData as Listing,
      order_id: (orderData as { id: number }).id,
    });
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

    const { data: existing, error: fetchError } = await supabase
      .from('listings')
      .select('*')
      .eq('id', id)
      .maybeSingle();
    if (fetchError) throw fetchError;
    if (!existing) throw new AppError(404, "E'lon topilmadi");

    const listing = existing as Listing;
    if (listing.user_id !== req.user!.id) {
      throw new AppError(403, "Faqat egasi e'lonni tahrirlashi mumkin");
    }
    if (price != null && Number(price) <= 0) {
      throw new AppError(400, "Narx 0 dan katta bo'lishi kerak");
    }

    const { data, error } = await supabase
      .from('listings')
      .update({
        title: title ?? listing.title,
        description: description ?? listing.description,
        price: price ?? listing.price,
        location: location ?? listing.location,
      })
      .eq('id', id)
      .select()
      .single();
    if (error) throw error;

    res.status(200).json({ listing: data as Listing });
  } catch (err) {
    next(err);
  }
}

export async function deleteListing(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;

    const { data: existing, error: fetchError } = await supabase
      .from('listings')
      .select('*')
      .eq('id', id)
      .maybeSingle();
    if (fetchError) throw fetchError;
    if (!existing) throw new AppError(404, "E'lon topilmadi");

    const listing = existing as Listing;
    if (listing.user_id !== req.user!.id && req.user!.role !== 'admin') {
      throw new AppError(403, "Faqat egasi yoki admin e'lonni o'chirishi mumkin");
    }

    // Clean up related ad_orders and payment_transactions (no ON DELETE CASCADE there)
    const { data: orders } = await supabase
      .from('ad_orders')
      .select('id')
      .eq('listing_id', id);

    const orderIds = ((orders ?? []) as Array<{ id: number }>).map((o) => o.id);
    if (orderIds.length > 0) {
      await supabase.from('payment_transactions').delete().in('ad_order_id', orderIds);
      await supabase.from('ad_orders').delete().eq('listing_id', id);
    }

    const { error } = await supabase.from('listings').delete().eq('id', id);
    if (error) throw error;

    res.status(200).json({ message: "E'lon o'chirildi" });
  } catch (err: unknown) {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    if ((err as any)?.code === '23503') {
      return next(new AppError(409, "Bu e'lon buyurtmaga bog'langan, avval buyurtmani tozalang"));
    }
    next(err);
  }
}

export async function getMyListings(req: Request, res: Response, next: NextFunction) {
  try {
    const userId = req.user!.id;

    const { data: listings, error } = await supabase
      .from('listings')
      .select('*, ad_orders(id, status, created_at)')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });
    if (error) throw error;

    const data = ((listings ?? []) as Array<Record<string, unknown>>).map((listing) => {
      const orders = (listing.ad_orders as Array<{
        id: number;
        status: string;
        created_at: string;
      }>) ?? [];
      const latestOrder = orders.sort(
        (a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
      )[0];
      const { ad_orders: _omit, ...rest } = listing;
      return {
        ...rest,
        order_status: latestOrder?.status ?? null,
        order_id: latestOrder?.id ?? null,
      };
    });

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

    const { data: listingData, error: fetchError } = await supabase
      .from('listings')
      .select('*')
      .eq('id', id)
      .maybeSingle();
    if (fetchError) throw fetchError;
    if (!listingData) throw new AppError(404, "E'lon topilmadi");

    const listing = listingData as Listing;

    const { error } = await supabase.from('contact_events').insert({
      listing_id: Number(id),
      viewer_id: req.user?.id ?? null,
      type: eventType,
    });
    if (error) throw error;

    res.status(200).json({ phone: listing.contact_phone });
  } catch (err) {
    next(err);
  }
}

export async function uploadImages(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const files = (req.files as Express.Multer.File[] | undefined) ?? [];

    const { data: listingData, error: fetchError } = await supabase
      .from('listings')
      .select('*')
      .eq('id', id)
      .maybeSingle();
    if (fetchError) throw fetchError;
    if (!listingData) throw new AppError(404, "E'lon topilmadi");

    const listing = listingData as Listing;
    if (listing.user_id !== req.user!.id) {
      throw new AppError(403, "Faqat egasi rasm qo'shishi mumkin");
    }
    if (files.length === 0) {
      throw new AppError(400, 'Kamida bitta rasm yuklang');
    }

    const urls: string[] = [];
    for (const file of files) {
      const url = `/uploads/${file.filename}`;
      const { error } = await supabase
        .from('listing_images')
        .insert({ listing_id: Number(id), url });
      if (error) throw error;
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

    const { data: listingData, error: fetchError } = await supabase
      .from('listings')
      .select('*')
      .eq('id', id)
      .maybeSingle();
    if (fetchError) throw fetchError;
    if (!listingData) throw new AppError(404, "E'lon topilmadi");

    const listing = listingData as Listing;
    if (listing.user_id !== req.user!.id) {
      throw new AppError(403, "Faqat egasi rasmni o'chirishi mumkin");
    }

    const { data: imageData, error: imgFetchError } = await supabase
      .from('listing_images')
      .select('*')
      .eq('id', imageId)
      .eq('listing_id', id)
      .maybeSingle();
    if (imgFetchError) throw imgFetchError;
    if (!imageData) throw new AppError(404, 'Rasm topilmadi');

    const image = imageData as ListingImage;

    const filePath = path.join(UPLOAD_DIR, path.basename(image.url));
    fs.unlink(filePath, () => {
      // best-effort disk cleanup; ignore errors
    });

    const { error } = await supabase.from('listing_images').delete().eq('id', imageId);
    if (error) throw error;

    res.status(200).json({ message: "Rasm o'chirildi" });
  } catch (err) {
    next(err);
  }
}
