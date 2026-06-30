import React, { useState, useEffect } from 'react';
import { c, serif, sans } from '../theme';
import { Plus, Star, Chevron, Card, Truck, Home as HomeIcon, LogOut } from '../icons';
import { useNav, StatusBar, BottomNav } from '../shell';
import { api, setAuthToken } from '../api';

interface UserData {
  id: number;
  name: string;
  phone: string;
  role: string;
  is_verified: boolean;
}

interface SubData {
  plan_name: string;
  expires_at: string | null;
  status: string;
}

function initials(name: string) {
  return name.split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase();
}

function roleLabel(role: string) {
  if (role === 'admin') return 'Administrator';
  if (role === 'seller') return 'Sotuvchi';
  return 'Xaridor';
}

function fmtViews(n: number) {
  if (n >= 1000) return `${(n / 1000).toFixed(1)}k`;
  return String(n);
}

export const ProfileScreen = () => {
  const { navigate, reset } = useNav();

  const [user, setUser]       = useState<UserData | null>(null);
  const [sub, setSub]         = useState<SubData | null>(null);
  const [activeAds, setActiveAds]   = useState(0);
  const [soldAds, setSoldAds]       = useState(0);
  const [totalViews, setTotalViews] = useState(0);
  const [loading, setLoading] = useState(true);
  const [notLoggedIn, setNotLoggedIn] = useState(false);

  useEffect(() => {
    Promise.all([
      api.me(),
      api.getMyListings(),
      api.getMySubscription(),
    ])
      .then(([meRes, listingsRes, subRes]: any[]) => {
        setUser(meRes.user);

        const data: any[] = listingsRes.data ?? [];
        setActiveAds(data.filter(l => l.status === 'active').length);
        setSoldAds(data.filter(l => l.status === 'sold').length);
        setTotalViews(data.reduce((sum: number, l: any) => sum + (l.views ?? 0), 0));

        setSub(subRes.subscription ?? null);
      })
      .catch((e: any) => {
        if (e.message?.includes('401') || e.message?.toLowerCase().includes('unauthorized')) {
          setNotLoggedIn(true);
        }
      })
      .finally(() => setLoading(false));
  }, []);

  const handleLogout = () => {
    setAuthToken(null);
    reset('onboarding');
  };

  // ── not logged in ────────────────────────────────────────────────────────
  if (!loading && notLoggedIn) {
    return (
      <>
        <StatusBar />
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center', padding: 32,
          textAlign: 'center' }}>
          <div style={{ width: 64, height: 64, borderRadius: 20, background: c.accentSoft,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            marginBottom: 16 }}>
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none"
              stroke={c.accent} strokeWidth="1.8" strokeLinecap="round"
              strokeLinejoin="round">
              <circle cx="12" cy="8" r="4" />
              <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" />
            </svg>
          </div>
          <div style={{ fontFamily: serif, fontSize: 19, fontWeight: 700, color: c.ink }}>
            Profilga kirish
          </div>
          <div style={{ fontSize: 12, color: c.muted, marginTop: 6, lineHeight: 1.55,
            maxWidth: 220 }}>
            Mening e'lonlarim, saqlangan va to'lovlar tarixini ko'rish uchun kiring.
          </div>
          <button onClick={() => navigate('login')} style={{ marginTop: 20, height: 50,
            padding: '0 32px', border: 'none', borderRadius: 14, background: c.accent,
            color: '#fff', fontSize: 14, fontWeight: 700, cursor: 'pointer',
            boxShadow: '0 8px 16px rgba(194,97,59,.32)' }}>
            Kirish
          </button>
        </div>
        <BottomNav />
      </>
    );
  }

  // ── loading ──────────────────────────────────────────────────────────────
  if (loading) {
    return (
      <>
        <StatusBar color="#fff" />
        <div style={{ flex: 1, display: 'flex', alignItems: 'center',
          justifyContent: 'center', fontSize: 12, color: c.muted, fontWeight: 600 }}>
          Yuklanmoqda…
        </div>
        <BottomNav />
      </>
    );
  }

  const name = user?.name ?? 'Foydalanuvchi';
  const phone = user?.phone ?? '';

  return (
    <>
      <StatusBar color="#fff" />
      <div style={{ flex: 1, overflowY: 'auto', display: 'flex', flexDirection: 'column',
        marginTop: -30 }}>

        {/* header banner */}
        <div style={{ background: c.accent, padding: '46px 18px 56px', position: 'relative' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 13 }}>
            <div style={{ width: 60, height: 60, borderRadius: 18, background: '#fff',
              color: c.accent, display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontFamily: serif, fontWeight: 800, fontSize: 22, flexShrink: 0 }}>
              {initials(name)}
            </div>
            <div>
              <div style={{ fontFamily: serif, fontSize: 20, fontWeight: 700,
                color: '#fff', lineHeight: 1.1 }}>
                {name}
              </div>
              <div style={{ fontSize: 11.5, color: 'rgba(255,255,255,.82)', marginTop: 3 }}>
                {roleLabel(user?.role ?? 'buyer')} · {phone}
              </div>
              {user?.is_verified && (
                <div style={{ display: 'inline-flex', alignItems: 'center', gap: 4,
                  marginTop: 6, background: 'rgba(255,255,255,.18)', borderRadius: 20,
                  padding: '3px 9px' }}>
                  <Star size={11} fill="#fff" color="#fff" />
                  <span style={{ fontSize: 10.5, fontWeight: 700, color: '#fff' }}>
                    Tasdiqlangan
                  </span>
                </div>
              )}
            </div>
          </div>
        </div>

        <div style={{ padding: '0 16px', marginTop: -38 }}>

          {/* subscription card (replaces fake wallet) */}
          <div style={{ background: c.card, border: `1px solid ${c.line}`, borderRadius: 18,
            padding: '15px 16px', boxShadow: '0 10px 24px rgba(60,36,14,.1)',
            display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div>
              <div style={{ fontSize: 10.5, fontWeight: 700, letterSpacing: '.05em',
                textTransform: 'uppercase', color: c.muted }}>
                Obuna
              </div>
              {sub ? (
                <>
                  <div style={{ fontFamily: serif, fontSize: 18, fontWeight: 800,
                    color: c.ink, marginTop: 3 }}>
                    {sub.plan_name}
                  </div>
                  {sub.expires_at && (
                    <div style={{ fontSize: 10.5, color: c.muted, marginTop: 1 }}>
                      {formatExpiry(sub.expires_at)} gacha
                    </div>
                  )}
                </>
              ) : (
                <div style={{ fontFamily: serif, fontSize: 15, fontWeight: 700,
                  color: c.muted, marginTop: 3 }}>
                  Obuna yo'q
                </div>
              )}
            </div>
            <button onClick={() => navigate('business')} style={{ border: 'none',
              borderRadius: 12, background: c.accent, color: '#fff', fontSize: 12,
              fontWeight: 700, padding: '10px 15px', cursor: 'pointer',
              display: 'flex', alignItems: 'center', gap: 5 }}>
              <Plus size={14} />
              {sub ? 'Yangilash' : "Pro'ga o'tish"}
            </button>
          </div>

          {/* stats */}
          <div style={{ display: 'flex', marginTop: 14, background: c.card,
            border: `1px solid ${c.line}`, borderRadius: 16, padding: '13px 0' }}>
            <Stat n={String(activeAds)} l="E'lonlar" border />
            <Stat n={String(soldAds)} l="Sotilgan" border />
            <Stat n={fmtViews(totalViews)} l="Ko'rishlar" />
          </div>

          {/* menu */}
          <div style={{ marginTop: 14, display: 'flex', flexDirection: 'column' }}>
            <Row icon={<HomeIcon size={17} />} label="Mening e'lonlarim"
              onClick={() => navigate('myAds')} />
            <Row icon={<Star size={17} />} label="Saqlangan e'lonlar"
              onClick={() => navigate('saved')} />
            <Row icon={<Card size={17} />} label="To'lovlar tarixi"
              onClick={() => navigate('payment')} />
            <Row icon={<Truck size={17} />} label="Yetkazib berish"
              onClick={() => navigate('tracking')} />
            <Row icon={<LogOut size={17} />} label="Chiqish"
              onClick={handleLogout} labelColor="#c0392b" />
          </div>

          {/* business upgrade banner */}
          {!sub && (
            <button onClick={() => navigate('business')} style={{ width: '100%',
              display: 'flex', alignItems: 'center', gap: 12, padding: 12,
              marginTop: 12, marginBottom: 18, borderRadius: 14,
              background: 'linear-gradient(135deg,#3a2a1c,#5a3a22)',
              border: 'none', cursor: 'pointer', textAlign: 'left' }}>
              <div style={{ width: 34, height: 34, borderRadius: 10,
                background: 'rgba(224,163,62,.2)', color: c.gold,
                display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Star size={17} fill={c.gold} color={c.gold} />
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 12.5, fontWeight: 700, color: '#fff' }}>
                  Biznes profilga o'tish
                </div>
                <div style={{ fontSize: 9.5, color: 'rgba(255,255,255,.6)' }}>
                  Do'kon, statistika, reklama
                </div>
              </div>
              <Chevron size={16} color={c.gold} />
            </button>
          )}

          {sub && <div style={{ height: 18 }} />}
        </div>
      </div>
      <BottomNav />
    </>
  );
};

function formatExpiry(iso: string) {
  const d = new Date(iso);
  return `${d.getDate()}.${String(d.getMonth() + 1).padStart(2, '0')}.${d.getFullYear()}`;
}

const Stat = ({ n, l, border }: { n: string; l: string; border?: boolean }) => (
  <div style={{ flex: 1, textAlign: 'center',
    borderRight: border ? `1px solid ${c.line}` : 'none' }}>
    <div style={{ fontFamily: serif, fontSize: 18, fontWeight: 800, color: c.accent }}>{n}</div>
    <div style={{ fontSize: 9.5, color: c.muted, marginTop: 1 }}>{l}</div>
  </div>
);

const Row = ({ icon, label, onClick, labelColor }: {
  icon: React.ReactNode; label: string; onClick: () => void; labelColor?: string;
}) => (
  <button onClick={onClick} style={{ display: 'flex', alignItems: 'center', gap: 12,
    padding: '12px 2px', borderBottom: `1px solid ${c.line}`, background: 'none',
    border: 'none', borderTop: 'none', borderLeft: 'none', borderRight: 'none',
    cursor: 'pointer', width: '100%', fontFamily: sans }}>
    <div style={{ width: 34, height: 34, borderRadius: 10, background: c.accentSoft,
      color: labelColor ?? c.accent, display: 'flex', alignItems: 'center',
      justifyContent: 'center', flexShrink: 0 }}>
      {icon}
    </div>
    <span style={{ flex: 1, textAlign: 'left', fontSize: 13, fontWeight: 600,
      color: labelColor ?? c.ink }}>
      {label}
    </span>
    <Chevron size={16} color={c.muted} />
  </button>
);
