export type Currency = '$' | "so'm";

export interface Listing {
  id: string;
  img: string;        // short label / placeholder text
  cat: string;        // category label
  title: string;
  priceVal: number;
  currency: Currency;
  loc: string;
  fav: boolean;
  badge: string | null;
  src: string;        // image URL
  specs?: string[];   // optional chips (auto, real estate)
  description?: string;
  sellerName?: string;
  sellerPhone?: string;
  createdAt?: string;
}

export type ScreenName =
  | 'onboarding' | 'lang' | 'login'
  | 'home' | 'search' | 'categories' | 'auto'
  | 'detail' | 'priceAI' | 'safeDeal' | 'payment' | 'offer'
  | 'sellerStore' | 'chat' | 'map' | 'story'
  | 'profile' | 'myAds' | 'notifications' | 'business'
  | 'verify' | 'referral' | 'review' | 'compare'
  | 'empty' | 'tracking' | 'post' | 'saved';

export interface NavEntry {
  screen: ScreenName;
  params?: Record<string, any>;
}
