import React, { createContext, useContext } from 'react';
import type { ScreenName } from './types';
import { c, sans } from './theme';
import { Home, Grid, Heart, User, Plus } from './icons';

/* ---------- Navigation context ---------- */
interface Nav {
  navigate: (s: ScreenName, params?: Record<string, any>) => void;
  back: () => void;
  reset: (s: ScreenName) => void;
  params: Record<string, any>;
  current: ScreenName;
  fav: Record<string, boolean>;
  toggleFav: (id: string) => void;
}
export const NavCtx = createContext<Nav>(null as any);
export const useNav = () => useContext(NavCtx);

/* ---------- Status bar ---------- */
export const StatusBar = ({ color = c.ink }: { color?: string }) => (
  <div style={{ height: 30, flexShrink: 0, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 22px 0 24px', fontSize: 12, fontWeight: 700, color, fontFamily: sans }}>
    <span>9:41</span>
    <span style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
      <svg width="17" height="11" viewBox="0 0 18 12" fill={color}><rect x="0" y="7" width="3" height="5" rx="1" /><rect x="5" y="4" width="3" height="8" rx="1" /><rect x="10" y="1.5" width="3" height="10.5" rx="1" /><rect x="15" y="0" width="3" height="12" rx="1" opacity=".35" /></svg>
      <svg width="15" height="11" viewBox="0 0 16 12" fill={color}><path d="M8 11.5l7.5-7.7a10.6 10.6 0 0 0-15 0z" /></svg>
      <svg width="23" height="11" viewBox="0 0 24 12" fill="none"><rect x="1" y="1" width="19" height="10" rx="3" stroke={color} strokeWidth="1.2" opacity=".5" /><rect x="3" y="3" width="13" height="6" rx="1.5" fill={color} /><rect x="21.4" y="4" width="1.6" height="4" rx="1" fill={color} opacity=".5" /></svg>
    </span>
  </div>
);

/* ---------- Phone shell ---------- */
export const Phone = ({ children, dark = false }: { children: React.ReactNode; dark?: boolean }) => (
  <div style={{ minHeight: '100dvh', width: '100%', display: 'flex', justifyContent: 'center', background: dark ? c.dark : '#e9e0d0', fontFamily: sans }}>
    <div style={{ width: '100%', maxWidth: 440, minHeight: '100dvh', background: c.bg, position: 'relative', display: 'flex', flexDirection: 'column', overflow: 'hidden', boxShadow: '0 0 60px rgba(60,36,14,.12)' }}>
      {children}
    </div>
  </div>
);

/* ---------- Bottom tab bar ---------- */
const tabs: { key: ScreenName; label: string; Icon: any }[] = [
  { key: 'home', label: 'Asosiy', Icon: Home },
  { key: 'categories', label: 'Rukn', Icon: Grid },
  { key: 'saved', label: 'Saqlangan', Icon: Heart },
  { key: 'profile', label: 'Profil', Icon: User },
];

export const BottomNav = () => {
  const { current, reset, navigate } = useNav();
  return (
    <div style={{ flexShrink: 0, height: 64, background: c.card, borderTop: `1px solid ${c.line}`, display: 'flex', alignItems: 'center', justifyContent: 'space-around', padding: '0 8px 8px' }}>
      <Tab t={tabs[0]} active={current === 'home'} onClick={() => reset('home')} />
      <Tab t={tabs[1]} active={current === 'categories'} onClick={() => reset('categories')} />
      <button onClick={() => navigate('post')} aria-label="E'lon berish" style={{ width: 50, height: 50, border: 'none', borderRadius: 17, background: c.accent, color: '#fff', marginTop: -22, boxShadow: '0 10px 18px rgba(194,97,59,.38)', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
        <Plus size={24} />
      </button>
      <Tab t={tabs[2]} active={current === 'saved'} onClick={() => reset('saved')} />
      <Tab t={tabs[3]} active={current === 'profile'} onClick={() => reset('profile')} />
    </div>
  );
};

const Tab = ({ t, active, onClick }: { t: { label: string; Icon: any }; active: boolean; onClick: () => void }) => (
  <button onClick={onClick} style={{ background: 'none', border: 'none', cursor: 'pointer', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3, color: active ? c.accent : c.muted, fontFamily: sans }}>
    <t.Icon size={21} />
    <span style={{ fontSize: 9, fontWeight: 700 }}>{t.label}</span>
  </button>
);

/* ---------- Small reusable header ---------- */
export const TopBar = ({ title, onBack, right }: { title: string; onBack?: () => void; right?: React.ReactNode }) => {
  const { back } = useNav();
  return (
    <div style={{ flexShrink: 0, padding: '4px 16px 12px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderBottom: `1px solid ${c.line}`, background: c.card }}>
      <button onClick={onBack || back} aria-label="Orqaga" style={{ width: 32, height: 32, border: 'none', borderRadius: '50%', background: c.bg, display: 'flex', alignItems: 'center', justifyContent: 'center', color: c.ink, cursor: 'pointer' }}>
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M15 18l-6-6 6-6" /></svg>
      </button>
      <span style={{ fontFamily: "'Spectral', serif", fontSize: 16, fontWeight: 700, color: c.ink }}>{title}</span>
      <div style={{ width: 32, display: 'flex', justifyContent: 'flex-end' }}>{right}</div>
    </div>
  );
};
