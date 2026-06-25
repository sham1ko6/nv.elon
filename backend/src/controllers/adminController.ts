import { Request, Response, NextFunction } from 'express';
import { query, execute } from '../config/db';
import { AppError } from '../middleware/errorHandler';
import { Listing, User, AdOrder, ListingStatus, UserRole, UserStatus } from '../types';

export async function getAllListings(req: Request, res: Response, next: NextFunction) {
  try {
    const { status, category, q } = req.query as Record<string, string | undefined>;
    const page = Math.max(1, Number(req.query.page) || 1);
    const limit = Math.max(1, Number(req.query.limit) || 20);
    const offset = (page - 1) * limit;

    const conditions: string[] = [];
    const params: unknown[] = [];

    if (status) {
      conditions.push('status = ?');
      params.push(status);
    }
    if (category) {
      conditions.push('category_id = ?');
      params.push(category);
    }
    if (q) {
      conditions.push('(title LIKE ? OR description LIKE ?)');
      params.push(`%${q}%`, `%${q}%`);
    }

    const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

    const countRows = await query<{ total: number }>(`SELECT COUNT(*) AS total FROM listings ${whereClause}`, params);
    const total = countRows[0]?.total ?? 0;

    const data = await query<Listing>(
      `SELECT * FROM listings ${whereClause} ORDER BY created_at DESC LIMIT ? OFFSET ?`,
      [...params, limit, offset]
    );

    res.status(200).json({ data, total, page, totalPages: Math.max(1, Math.ceil(total / limit)) });
  } catch (err) {
    next(err);
  }
}

const ALLOWED_LISTING_STATUSES: ListingStatus[] = ['draft', 'pending_payment', 'active', 'expired', 'rejected', 'sold'];

export async function updateListingStatus(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const { status } = req.body as { status?: ListingStatus };

    if (!status || !ALLOWED_LISTING_STATUSES.includes(status)) {
      throw new AppError(400, "status noto'g'ri");
    }

    const [listing] = await query<Listing>('SELECT * FROM listings WHERE id = ?', [id]);
    if (!listing) {
      throw new AppError(404, "E'lon topilmadi");
    }

    const publishedAt = status === 'active' && !listing.published_at ? new Date() : listing.published_at;

    await execute('UPDATE listings SET status = ?, published_at = ? WHERE id = ?', [status, publishedAt, id]);

    const [updated] = await query<Listing>('SELECT * FROM listings WHERE id = ?', [id]);
    res.status(200).json({ listing: updated });
  } catch (err) {
    next(err);
  }
}

export async function getAllUsers(req: Request, res: Response, next: NextFunction) {
  try {
    const { role, status, q } = req.query as Record<string, string | undefined>;
    const conditions: string[] = [];
    const params: unknown[] = [];

    if (role) {
      conditions.push('role = ?');
      params.push(role);
    }
    if (status) {
      conditions.push('status = ?');
      params.push(status);
    }
    if (q) {
      conditions.push('(name LIKE ? OR phone LIKE ?)');
      params.push(`%${q}%`, `%${q}%`);
    }

    const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

    const data = await query<Omit<User, 'password_hash'>>(
      `SELECT id, name, phone, email, role, is_verified, status, created_at, updated_at
       FROM users ${whereClause} ORDER BY created_at DESC`,
      params
    );

    res.status(200).json({ data });
  } catch (err) {
    next(err);
  }
}

const ALLOWED_ROLES: UserRole[] = ['buyer', 'seller', 'admin'];
const ALLOWED_STATUSES: UserStatus[] = ['active', 'banned'];

export async function updateUser(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const { role, status } = req.body as { role?: UserRole; status?: UserStatus };

    const [user] = await query<User>('SELECT * FROM users WHERE id = ?', [id]);
    if (!user) {
      throw new AppError(404, 'Foydalanuvchi topilmadi');
    }
    if (role && !ALLOWED_ROLES.includes(role)) {
      throw new AppError(400, "role noto'g'ri");
    }
    if (status && !ALLOWED_STATUSES.includes(status)) {
      throw new AppError(400, "status noto'g'ri");
    }

    await execute('UPDATE users SET role = ?, status = ? WHERE id = ?', [role ?? user.role, status ?? user.status, id]);

    const { password_hash: _unused, ...safeUser } = user;
    res.status(200).json({ user: { ...safeUser, role: role ?? user.role, status: status ?? user.status } });
  } catch (err) {
    next(err);
  }
}

export async function getAllOrders(_req: Request, res: Response, next: NextFunction) {
  try {
    const data = await query<AdOrder & { payment_state: string | null; provider: string | null }>(
      `SELECT ao.*,
        (SELECT pt.state FROM payment_transactions pt WHERE pt.ad_order_id = ao.id ORDER BY pt.created_at DESC LIMIT 1) AS payment_state,
        (SELECT pt.provider FROM payment_transactions pt WHERE pt.ad_order_id = ao.id ORDER BY pt.created_at DESC LIMIT 1) AS provider
       FROM ad_orders ao
       ORDER BY ao.created_at DESC`
    );
    res.status(200).json({ data });
  } catch (err) {
    next(err);
  }
}

export async function getMetrics(_req: Request, res: Response, next: NextFunction) {
  try {
    const [usersRows, listingsRows, revenueRows, todayRows] = await Promise.all([
      query<{ total: number }>('SELECT COUNT(*) AS total FROM users'),
      query<{ total: number }>("SELECT COUNT(*) AS total FROM listings WHERE status = 'active'"),
      query<{ total: number }>("SELECT COALESCE(SUM(amount), 0) AS total FROM ad_orders WHERE status = 'paid'"),
      query<{ total: number }>(
        "SELECT COALESCE(SUM(amount), 0) AS total FROM ad_orders WHERE status = 'paid' AND DATE(paid_at) = CURDATE()"
      ),
    ]);

    res.status(200).json({
      totalUsers: usersRows[0]?.total ?? 0,
      activeListings: listingsRows[0]?.total ?? 0,
      totalRevenue: revenueRows[0]?.total ?? 0,
      todayRevenue: todayRows[0]?.total ?? 0,
    });
  } catch (err) {
    next(err);
  }
}
