import { Request, Response, NextFunction } from 'express';
import supabase from '../config/db';
import { AppError } from '../middleware/errorHandler';
import { Listing, User, AdOrder, ListingStatus, UserRole, UserStatus } from '../types';

export async function getAllListings(req: Request, res: Response, next: NextFunction) {
  try {
    const { status, category, q } = req.query as Record<string, string | undefined>;
    const page = Math.max(1, Number(req.query.page) || 1);
    const limit = Math.max(1, Number(req.query.limit) || 20);
    const offset = (page - 1) * limit;

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let dbQuery: any = supabase
      .from('listings')
      .select('*', { count: 'exact' })
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1);

    if (status) dbQuery = dbQuery.eq('status', status);
    if (category) dbQuery = dbQuery.eq('category_id', category);
    if (q) dbQuery = dbQuery.or(`title.ilike.%${q}%,description.ilike.%${q}%`);

    const { data, error, count } = await dbQuery;
    if (error) throw error;

    res.status(200).json({
      data: data as Listing[],
      total: count ?? 0,
      page,
      totalPages: Math.max(1, Math.ceil((count ?? 0) / limit)),
    });
  } catch (err) {
    next(err);
  }
}

const ALLOWED_LISTING_STATUSES: ListingStatus[] = [
  'draft',
  'pending_payment',
  'active',
  'expired',
  'rejected',
  'sold',
];

export async function updateListingStatus(req: Request, res: Response, next: NextFunction) {
  try {
    const { id } = req.params;
    const { status, expires_at } = req.body as { status?: ListingStatus; expires_at?: string | null };

    if (!status || !ALLOWED_LISTING_STATUSES.includes(status)) {
      throw new AppError(400, "status noto'g'ri");
    }
    if (expires_at !== undefined && expires_at !== null && Number.isNaN(Date.parse(expires_at))) {
      throw new AppError(400, "expires_at noto'g'ri");
    }

    const { data: existing, error: fetchError } = await supabase
      .from('listings')
      .select('*')
      .eq('id', id)
      .maybeSingle();
    if (fetchError) throw fetchError;
    if (!existing) throw new AppError(404, "E'lon topilmadi");

    const listing = existing as Listing;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const publishedAt =
      status === 'active' && !(listing as any).published_at
        ? new Date().toISOString()
        : (listing as any).published_at;

    const { data, error } = await supabase
      .from('listings')
      .update({
        status,
        published_at: publishedAt,
        expires_at: expires_at !== undefined ? expires_at : (listing as any).expires_at,
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

export async function getAllUsers(req: Request, res: Response, next: NextFunction) {
  try {
    const { role, status, q } = req.query as Record<string, string | undefined>;

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let dbQuery: any = supabase
      .from('users')
      .select('id, name, phone, email, role, is_verified, status, created_at, updated_at')
      .order('created_at', { ascending: false });

    if (role) dbQuery = dbQuery.eq('role', role);
    if (status) dbQuery = dbQuery.eq('status', status);
    if (q) dbQuery = dbQuery.or(`name.ilike.%${q}%,phone.ilike.%${q}%`);

    const { data, error } = await dbQuery;
    if (error) throw error;

    res.status(200).json({ data: data as Omit<User, 'password_hash'>[] });
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

    const { data: existing, error: fetchError } = await supabase
      .from('users')
      .select('*')
      .eq('id', id)
      .maybeSingle();
    if (fetchError) throw fetchError;
    if (!existing) throw new AppError(404, 'Foydalanuvchi topilmadi');

    const user = existing as User;
    if (role && !ALLOWED_ROLES.includes(role)) throw new AppError(400, "role noto'g'ri");
    if (status && !ALLOWED_STATUSES.includes(status)) throw new AppError(400, "status noto'g'ri");

    await supabase
      .from('users')
      .update({ role: role ?? user.role, status: status ?? user.status })
      .eq('id', id);

    const { password_hash: _unused, ...safeUser } = user;
    res.status(200).json({
      user: { ...safeUser, role: role ?? user.role, status: status ?? user.status },
    });
  } catch (err) {
    next(err);
  }
}

export async function getAllOrders(_req: Request, res: Response, next: NextFunction) {
  try {
    const { data: orders, error } = await supabase
      .from('ad_orders')
      .select('*, payment_transactions(state, provider, created_at)')
      .order('created_at', { ascending: false });
    if (error) throw error;

    const data = ((orders ?? []) as Array<Record<string, unknown>>).map((order) => {
      const txns = (order.payment_transactions as Array<{
        state: string;
        provider: string;
        created_at: string;
      }>) ?? [];
      const latest = txns.sort(
        (a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
      )[0];
      const { payment_transactions: _omit, ...rest } = order;
      return {
        ...rest,
        payment_state: latest?.state ?? null,
        provider: latest?.provider ?? null,
      };
    });

    res.status(200).json({ data });
  } catch (err) {
    next(err);
  }
}

export async function getMetrics(_req: Request, res: Response, next: NextFunction) {
  try {
    const todayStart = new Date();
    todayStart.setUTCHours(0, 0, 0, 0);

    const [usersRes, listingsRes, revenueRes, todayRes] = await Promise.all([
      supabase.from('users').select('*', { count: 'exact', head: true }),
      supabase.from('listings').select('*', { count: 'exact', head: true }).eq('status', 'active'),
      supabase.from('ad_orders').select('amount').eq('status', 'paid'),
      supabase
        .from('ad_orders')
        .select('amount')
        .eq('status', 'paid')
        .gte('paid_at', todayStart.toISOString()),
    ]);

    const totalRevenue = ((revenueRes.data ?? []) as Array<{ amount: number }>).reduce(
      (sum, row) => sum + Number(row.amount),
      0
    );
    const todayRevenue = ((todayRes.data ?? []) as Array<{ amount: number }>).reduce(
      (sum, row) => sum + Number(row.amount),
      0
    );

    res.status(200).json({
      totalUsers: usersRes.count ?? 0,
      activeListings: listingsRes.count ?? 0,
      totalRevenue,
      todayRevenue,
    });
  } catch (err) {
    next(err);
  }
}
