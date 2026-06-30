import React, { useState, useCallback } from 'react';
import type { ScreenName, NavEntry } from './types';
import { NavCtx, Phone } from './shell';
import { listings, autos } from './data';
import { api } from './api';

import { OnboardingScreen } from './screens/Onboarding';
import { LoginScreen } from './screens/Login';
import { LangScreen, MapScreen, StoryScreen, EmptyScreen, TrackingScreen } from './screens/Standalone';
import { HomeScreen } from './screens/Home';
import { SearchScreen } from './screens/Search';
import { CategoriesScreen } from './screens/Categories';
import { DetailScreen } from './screens/Detail';
import { PostAdScreen } from './screens/Post';
import { ProfileScreen } from './screens/Profile';
import { ChatScreen } from './screens/Chat';
import { PriceAIScreen, SafeDealScreen, PaymentScreen, SellerStoreScreen, AutoScreen, CompareScreen, OfferScreen } from './screens/Listing2';
import { MyAdsScreen, SavedScreen, NotificationsScreen, BusinessScreen, VerifyScreen, ReviewScreen, ReferralScreen } from './screens/Account';

const screens: Record<ScreenName, React.ComponentType> = {
  onboarding: OnboardingScreen,
  lang: LangScreen,
  login: LoginScreen,
  home: HomeScreen,
  search: SearchScreen,
  categories: CategoriesScreen,
  auto: AutoScreen,
  detail: DetailScreen,
  priceAI: PriceAIScreen,
  safeDeal: SafeDealScreen,
  payment: PaymentScreen,
  offer: OfferScreen,
  sellerStore: SellerStoreScreen,
  chat: ChatScreen,
  map: MapScreen,
  story: StoryScreen,
  profile: ProfileScreen,
  myAds: MyAdsScreen,
  notifications: NotificationsScreen,
  business: BusinessScreen,
  verify: VerifyScreen,
  referral: ReferralScreen,
  review: ReviewScreen,
  compare: CompareScreen,
  empty: EmptyScreen,
  tracking: TrackingScreen,
  post: PostAdScreen,
  saved: SavedScreen,
};

// screens that render their own dark background edge-to-edge
const darkShell: ScreenName[] = ['onboarding', 'business', 'referral', 'story'];

export default function App() {
  const [stack, setStack] = useState<NavEntry[]>([{ screen: 'onboarding' }]);
  const [fav, setFav] = useState<Record<string, boolean>>(() => {
    const seed: Record<string, boolean> = {};
    [...listings, ...autos].forEach((l) => { seed[l.id] = l.fav; });
    return seed;
  });

  const current = stack[stack.length - 1];

  const navigate = useCallback((screen: ScreenName, params: Record<string, any> = {}) => {
    setStack((s) => [...s, { screen, params }]);
  }, []);

  const back = useCallback(() => {
    setStack((s) => (s.length > 1 ? s.slice(0, -1) : s));
  }, []);

  const reset = useCallback((screen: ScreenName) => {
    setStack([{ screen }]);
  }, []);

  const toggleFav = useCallback((id: string) => {
    setFav((f) => {
      const next = !f[id];
      if (next) api.addFavorite(id).catch(() => {});
      else      api.removeFavorite(id).catch(() => {});
      return { ...f, [id]: next };
    });
  }, []);

  const Screen = screens[current.screen];

  return (
    <NavCtx.Provider value={{ navigate, back, reset, params: current.params || {}, current: current.screen, fav, toggleFav }}>
      <Phone dark={darkShell.includes(current.screen)}>
        <Screen />
      </Phone>
    </NavCtx.Provider>
  );
}
