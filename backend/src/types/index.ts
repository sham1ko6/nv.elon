export type UserRole = 'buyer' | 'seller' | 'admin';
export type UserStatus = 'active' | 'banned';

export interface User {
  id: number;
  name: string;
  phone: string;
  email: string | null;
  password_hash: string | null;
  role: UserRole;
  is_verified: boolean;
  status: UserStatus;
  created_at: Date;
  updated_at: Date;
}

export type SafeUser = Omit<User, 'password_hash'>;

export interface Category {
  id: number;
  slug: string;
  name_uz: string;
  name_en: string;
  icon: string | null;
  sort_order: number;
}

export interface Subcategory {
  id: number;
  category_id: number;
  slug: string;
  name_uz: string;
  name_en: string;
}

export interface CategoryWithSubcategories extends Category {
  subcategories: Subcategory[];
}

export interface Plan {
  id: number;
  code: string;
  name_uz: string;
  price: number;
  currency: string;
  duration_days: number;
  max_active_ads: number;
  is_active: boolean;
}

export type SubscriptionStatus = 'pending' | 'active' | 'expired' | 'cancelled';

export interface Subscription {
  id: number;
  user_id: number;
  plan_id: number;
  status: SubscriptionStatus;
  started_at: Date | null;
  expires_at: Date | null;
  created_at: Date;
}

export type ListingStatus = 'draft' | 'pending_payment' | 'active' | 'expired' | 'rejected' | 'sold';
export type ListingSource = 'posting_fee' | 'subscription';

export interface Listing {
  id: number;
  user_id: number;
  category_id: number;
  subcategory_id: number | null;
  title: string;
  description: string;
  price: number;
  currency: string;
  location: string;
  contact_phone: string;
  status: ListingStatus;
  source: ListingSource | null;
  subscription_id: number | null;
  views: number;
  published_at: Date | null;
  expires_at: Date | null;
  created_at: Date;
  updated_at: Date;
}

export interface ListingImage {
  id: number;
  listing_id: number;
  url: string;
  sort_order: number;
}

export type AdOrderType = 'posting_fee' | 'subscription';
export type AdOrderStatus = 'created' | 'pending' | 'paid' | 'failed' | 'cancelled';

export interface AdOrder {
  id: number;
  user_id: number;
  type: AdOrderType;
  listing_id: number | null;
  plan_id: number | null;
  amount: number;
  currency: string;
  status: AdOrderStatus;
  created_at: Date;
  paid_at: Date | null;
}

export type PaymentProvider = 'payme' | 'click';

export interface PaymentTransaction {
  id: number;
  ad_order_id: number;
  provider: PaymentProvider;
  provider_txn_id: string | null;
  state: string;
  amount: number;
  raw_payload: unknown;
  created_at: Date;
  updated_at: Date;
}

export interface Favorite {
  user_id: number;
  listing_id: number;
  created_at: Date;
}

export type ContactEventType = 'view_phone' | 'call' | 'share';

export interface ContactEvent {
  id: number;
  listing_id: number;
  viewer_id: number | null;
  type: ContactEventType;
  created_at: Date;
}

export interface AppSetting {
  key: string;
  value: string;
}

export interface AuthTokenPayload {
  id: number;
  phone: string;
  role: UserRole;
}

export interface RefreshTokenPayload {
  id: number;
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthTokenPayload;
    }
  }
}
