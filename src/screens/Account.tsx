import React, { useState, useEffect } from 'react';
import { c, serif, price } from '../theme';
import { Star, Eye, Heart, Chat, Truck, Search, Check, Shield, Verified, Chevron } from '../icons';
import { useNav, StatusBar, TopBar, BottomNav } from '../shell';
import { ListingCard } from './ListingCard';
import { api } from '../api';
import { mapBackendListing } from '../mapper';
import type { Listing } from '../types';

/* ---------- My ads ---------- */
type AdTab = 'active' | 'sold' | 'other';

const STATUS_INFO: Record<string, { label: string; color: string }> = {
  active:          { label: 'Faol',                color: '#1f7a44' },
  sold:            { label: 'Sotilgan',             color: '#1f7a44' },
  expired:         { label: "Muddati o'tgan",       color: '#a8957d' },
  rejected:        { label: 'Rad etilgan',           color: '#c0392b' },
  pending_payment: { label: "To'lov kutilmoqda",    color: '#c28a0e' },
  draft:           { label: 'Qoralama',              color: '#a8957d' },
};

export const MyAdsScreen = () => {
  const { navigate } = useNav();
  const [items, setItems] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [tab, setTab] = useState<AdTab>('active');
  const [confirmId, setConfirmId] = useState<number | null>(null);
  const [deleting, setDeleting] = useState(false);

  useEffect(() => {
    api.getMyListings()
      .then((res: any) => setItems(res.data))
      .catch((e: any) => setError(e.message))
      .finally(() => setLoading(false));
  }, []);

  const handleDelete = async (id: number) => {
    setDeleting(true);
    try {
      await api.deleteListing(id);
      setItems(prev => prev.filter(l => l.id !== id));
      setConfirmId(null);
    } catch (e: any) {
      setError(e.message);
    } finally {
      setDeleting(false);
    }
  };

  const filtered = items.filter(l =>
    tab === 'active' ? l.status === 'active' :
    tab === 'sold'   ? l.status === 'sold' :
    !['active', 'sold'].includes(l.status)
  );

  const counts = {
    active: items.filter(l => l.status === 'active').length,
    sold:   items.filter(l => l.status === 'sold').length,
    other:  items.filter(l => !['active', 'sold'].includes(l.status)).length,
  };

  const TABS: { key: AdTab; label: string }[] = [
    { key: 'active', label: counts.active ? `Faol  ${counts.active}` : 'Faol' },
    { key: 'sold',   label: counts.sold   ? `Sotilgan  ${counts.sold}` : 'Sotilgan' },
    { key: 'other',  label: 'Arxiv' },
  ];

  return (
    <>
      <StatusBar />
      <TopBar title="Mening e'lonlarim" />

      {/* tabs */}
      <div style={{ flexShrink: 0, display: 'flex', gap: 16, padding: '10px 16px 0',
        fontSize: 12.5, fontWeight: 700, borderBottom: `1px solid ${c.line}` }}>
        {TABS.map(({ key, label }) => {
          const on = key === tab;
          return (
            <button key={key} onClick={() => setTab(key)} style={{ background: 'none',
              border: 'none', color: on ? c.accent : c.muted,
              borderBottom: on ? `2px solid ${c.accent}` : '2px solid transparent',
              padding: '0 0 9px', cursor: 'pointer', fontSize: 12.5, fontWeight: 700 }}>
              {label}
            </button>
          );
        })}
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '13px 16px',
        display: 'flex', flexDirection: 'column', gap: 12 }}>

        {loading ? (
          <div style={{ textAlign: 'center', paddingTop: 48, fontSize: 12,
            color: c.muted, fontWeight: 600 }}>
            Yuklanmoqda…
          </div>
        ) : error ? (
          <div style={{ textAlign: 'center', paddingTop: 48, fontSize: 12,
            color: '#c0392b', fontWeight: 600 }}>
            {error}
          </div>
        ) : filtered.length === 0 ? (
          <div style={{ textAlign: 'center', paddingTop: 60, fontSize: 12,
            color: c.muted, fontWeight: 600 }}>
            Bu bo'limda e'lonlar yo'q
          </div>
        ) : filtered.map((item) => {
          const st = STATUS_INFO[item.status] ?? { label: item.status, color: c.muted };
          const priceCur = item.currency === 'USD' ? '$' : "so'm";
          const isConfirm = confirmId === item.id;

          return (
            <div key={item.id} style={{ background: c.card, border: `1px solid ${c.line}`,
              borderRadius: 14, padding: 11 }}>
              <div style={{ display: 'flex', gap: 11 }}>
                {/* thumbnail placeholder (list endpoint returns no images) */}
                <div style={{ width: 60, height: 60, borderRadius: 10, flexShrink: 0,
                  background: 'linear-gradient(135deg,#e7d8c0,#d8c8aa)',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontFamily: serif, fontWeight: 800, fontSize: 18, color: '#a8957d' }}>
                  {item.title?.[0]?.toUpperCase() ?? '?'}
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontSize: 12.5, fontWeight: 600, color: c.ink,
                    lineHeight: 1.3, overflow: 'hidden', textOverflow: 'ellipsis',
                    whiteSpace: 'nowrap' }}>
                    {item.title}
                  </div>
                  <div style={{ fontFamily: serif, fontSize: 14, fontWeight: 700,
                    color: c.accent, marginTop: 3 }}>
                    {price(Number(item.price), priceCur as any)}
                  </div>
                  <div style={{ display: 'inline-flex', alignItems: 'center', gap: 4,
                    fontSize: 9.5, fontWeight: 700, marginTop: 4, color: st.color }}>
                    <span style={{ width: 5, height: 5, borderRadius: '50%',
                      background: st.color }} />
                    {st.label}
                  </div>
                </div>
              </div>

              {/* stats + actions */}
              <div style={{ display: 'flex', gap: 12, marginTop: 10, paddingTop: 10,
                borderTop: `1px solid ${c.line}`, fontSize: 10.5, color: c.muted,
                alignItems: 'center' }}>
                <span style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                  <Eye size={12} /> {item.views ?? 0}
                </span>

                {isConfirm ? (
                  <>
                    <span style={{ flex: 1, fontSize: 11, fontWeight: 600, color: c.ink }}>
                      O'chirilsinmi?
                    </span>
                    <button onClick={() => setConfirmId(null)} style={{ background: 'none',
                      border: 'none', fontSize: 10.5, fontWeight: 700, color: c.muted,
                      cursor: 'pointer' }}>
                      Bekor
                    </button>
                    <button onClick={() => handleDelete(item.id)} disabled={deleting}
                      style={{ background: 'none', border: 'none', fontSize: 10.5,
                        fontWeight: 700, color: '#c0392b', cursor: 'pointer' }}>
                      {deleting ? '…' : "O'chirish"}
                    </button>
                  </>
                ) : (
                  <>
                    <button onClick={() => navigate('post', { id: String(item.id) })}
                      style={{ marginLeft: 'auto', background: 'none', border: 'none',
                        color: c.accent, fontWeight: 700, fontSize: 10.5, cursor: 'pointer' }}>
                      Tahrirlash
                    </button>
                    <button onClick={() => setConfirmId(item.id)} style={{ background: 'none',
                      border: 'none', color: c.muted, fontWeight: 700, fontSize: 10.5,
                      cursor: 'pointer' }}>
                      O'chirish
                    </button>
                  </>
                )}
              </div>

              {/* TOP upsell for active listings */}
              {item.status === 'active' && !item.is_top && !isConfirm && (
                <button onClick={() => navigate('business')} style={{ width: '100%',
                  marginTop: 8, height: 34, border: `1.5px solid ${c.accent}`,
                  borderRadius: 10, background: c.accentSoft, color: c.accent,
                  fontSize: 11.5, fontWeight: 700, cursor: 'pointer',
                  display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6 }}>
                  <Star size={13} fill={c.accent} color={c.accent} />TOP'ga ko'tarish
                </button>
              )}
            </div>
          );
        })}
      </div>
    </>
  );
};

/* ---------- Saved ---------- */
export const SavedScreen = () => {
  const { navigate } = useNav();
  const [items, setItems] = useState<Listing[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [removing, setRemoving] = useState<Set<string>>(new Set());

  useEffect(() => {
    api.getFavorites()
      .then((res: any) => {
        setItems(res.data.map((b: any) => ({ ...mapBackendListing(b), fav: true })));
      })
      .catch((e: any) => setError(e.message))
      .finally(() => setLoading(false));
  }, []);

  const handleRemove = async (id: string) => {
    setRemoving(r => new Set(r).add(id));
    try {
      await api.removeFavorite(id);
      setItems(prev => prev.filter(i => i.id !== id));
    } catch {
      // keep item visible if API call fails
    } finally {
      setRemoving(r => { const n = new Set(r); n.delete(id); return n; });
    }
  };

  return (
    <>
      <StatusBar />
      <div style={{ flexShrink: 0, padding: '6px 16px 12px' }}>
        <div style={{ fontFamily: serif, fontSize: 22, fontWeight: 800, color: c.ink }}>
          Saqlangan
        </div>
        <div style={{ fontSize: 11.5, color: c.muted, marginTop: 3 }}>
          {loading ? '…' : `${items.length} ta e'lon`}
        </div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '0 16px 16px' }}>
        {loading ? (
          <div style={{ textAlign: 'center', paddingTop: 60, fontSize: 12,
            color: c.muted, fontWeight: 600 }}>
            Yuklanmoqda…
          </div>
        ) : error ? (
          <div style={{ textAlign: 'center', paddingTop: 60, fontSize: 12,
            color: '#c0392b', fontWeight: 600, lineHeight: 1.5 }}>
            {error}
          </div>
        ) : items.length === 0 ? (
          <div style={{ textAlign: 'center', paddingTop: 80, color: c.muted }}>
            <Heart size={40} color="#d3c1a8" />
            <div style={{ marginTop: 14, fontSize: 13 }}>Hali saqlangan e'lon yo'q</div>
            <button onClick={() => navigate('home')} style={{ marginTop: 12, background: 'none',
              border: 'none', color: c.accent, fontSize: 12, fontWeight: 700,
              cursor: 'pointer' }}>
              E'lonlarni ko'rish →
            </button>
          </div>
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
            {items.map(item => (
              <div key={item.id} style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
                <ListingCard item={item} />
                <button onClick={() => handleRemove(item.id)}
                  disabled={removing.has(item.id)}
                  style={{ height: 28, border: `1px solid ${c.line}`, borderRadius: 8,
                    background: c.card, fontSize: 9.5, fontWeight: 700,
                    color: removing.has(item.id) ? c.muted : '#c0392b',
                    cursor: removing.has(item.id) ? 'default' : 'pointer' }}>
                  {removing.has(item.id) ? '…' : '× Saqlangandan olib tashlash'}
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
      <BottomNav />
    </>
  );
};

/* ---------- Notifications ---------- */
export const NotificationsScreen = () => {
  const list = [
    { today: true, icon: <Truck size={18} />, bg: c.green, text: <><b>Narx tushdi!</b> Saqlangan "MacBook Pro 16" endi <b style={{ color: c.accent }}>$2 450</b> (−$200)</>, time: '12 daqiqa oldin', unread: true },
    { today: true, icon: <Chat size={18} />, text: <><b>Tashkent Realty</b> sizning taklifingizga javob berdi</>, time: '1 soat oldin' },
    { today: true, icon: <Truck size={18} />, text: <>Buyurtmangiz yo'lda — <b>ertaga</b> yetkaziladi</>, time: '3 soat oldin' },
    { today: false, icon: <Search size={18} />, text: <>Saqlangan qidiruv "<b>Traktor Jizzax</b>" bo'yicha <b>3 ta yangi</b> e'lon</>, time: 'Kecha, 18:40' },
    { today: false, icon: <Star size={18} fill={c.gold} color={c.gold} />, text: <>E'loningiz <b>TOP</b>'ga ko'tarildi va 320 marta ko'rildi</>, time: 'Kecha, 09:15' },
  ];
  return (
    <>
      <StatusBar />
      <TopBar title="Bildirishnomalar" right={<span style={{ fontSize: 11, fontWeight: 700, color: c.accent, whiteSpace: 'nowrap', position: 'absolute', right: 16 }}>O'qildi</span>} />
      <div style={{ flex: 1, overflowY: 'auto', padding: '8px 0' }}>
        {list.map((n, i) => {
          const first = i === 0 || list[i - 1].today !== n.today;
          return (
            <React.Fragment key={i}>
              {first && <div style={{ padding: '6px 16px', fontSize: 10, fontWeight: 700, letterSpacing: '.06em', textTransform: 'uppercase', color: c.muted }}>{n.today ? 'Bugun' : 'Kecha'}</div>}
              <div style={{ display: 'flex', gap: 12, padding: '11px 16px', background: n.unread ? c.accentSoft : 'transparent', alignItems: 'flex-start' }}>
                <div style={{ width: 38, height: 38, borderRadius: 11, background: n.bg || c.accentSoft, color: n.bg ? '#fff' : c.accent, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{n.icon}</div>
                <div style={{ flex: 1 }}><div style={{ fontSize: 12.5, color: c.ink, lineHeight: 1.4 }}>{n.text}</div><div style={{ fontSize: 10, color: c.muted, marginTop: 3 }}>{n.time}</div></div>
                {n.unread && <span style={{ width: 8, height: 8, borderRadius: '50%', background: c.accent, flexShrink: 0, marginTop: 5 }} />}
              </div>
            </React.Fragment>
          );
        })}
      </div>
    </>
  );
};

/* ---------- Business plans ---------- */
function bsDuration(days: number): string {
  if (days >= 330) return `${Math.round(days / 365)} yil`;
  return `${Math.round(days / 30)} oy`;
}

function bsFeatures(plan: any): string[] {
  const code = (plan.code ?? '').toLowerCase();
  const ads = plan.max_active_ads > 900 ? "Cheksiz e'lon" : `${plan.max_active_ads} ta e'lon`;
  if (code.includes('pro') || code.includes('biznes') || plan.max_active_ads > 900) {
    return [ads, "Avto TOP ko'tarish", "To'liq analitika", "Reklama bannerlari"];
  }
  return [ads, "Do'kon sahifasi", "Asosiy statistika"];
}

export const BusinessScreen = () => {
  const { navigate } = useNav();
  const [plans, setPlans] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.getPlans()
      .then((res: any) => setPlans(res.data ?? []))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const maxPrice = plans.length ? Math.max(...plans.map((p: any) => p.price)) : 0;

  return (
    <>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: c.ink, overflow: 'hidden' }}>
        <StatusBar color="#fff" />
        <div style={{ flex: 1, overflowY: 'auto', padding: '8px 18px 0', display: 'flex', flexDirection: 'column' }}>
          <div style={{ textAlign: 'center' }}>
            <Star size={34} fill={c.gold} color={c.gold} />
            <div style={{ fontFamily: serif, fontSize: 23, fontWeight: 800, color: '#fff', marginTop: 9 }}>
              Biznes uchun Ravoq
            </div>
            <div style={{ fontSize: 12, color: 'rgba(255,255,255,.65)', marginTop: 5, lineHeight: 1.5 }}>
              Ko'proq soting — do'kon, statistika va reklama bilan.
            </div>
          </div>

          <div style={{ display: 'flex', gap: 11, marginTop: 20 }}>
            {loading ? (
              [0, 1].map(i => (
                <div key={i} style={{ flex: 1, height: 190, borderRadius: 16,
                  background: 'rgba(255,255,255,.06)',
                  border: '1px solid rgba(255,255,255,.14)' }} />
              ))
            ) : plans.length === 0 ? (
              <div style={{ flex: 1, textAlign: 'center', padding: 40,
                color: 'rgba(255,255,255,.4)', fontSize: 12 }}>
                Rejalar mavjud emas
              </div>
            ) : (
              plans.map((plan: any) => {
                const popular = plan.price === maxPrice;
                const features = bsFeatures(plan);
                const dur = bsDuration(plan.duration_days);
                const priceStr = plan.currency === 'USD'
                  ? `$${plan.price}`
                  : plan.price.toLocaleString('ru-RU').replace(/,/g, ' ');

                return (
                  <div key={plan.id} style={{ flex: 1, position: 'relative',
                    background: popular
                      ? 'linear-gradient(155deg,#D27044,#A8472A)'
                      : 'rgba(255,255,255,.06)',
                    border: `1px solid ${popular ? 'transparent' : 'rgba(255,255,255,.14)'}`,
                    borderRadius: 16, padding: '15px 13px',
                    boxShadow: popular ? '0 12px 24px rgba(120,55,25,.4)' : 'none' }}>
                    {popular && (
                      <span style={{ position: 'absolute', top: -9, right: 11,
                        background: c.gold, color: c.ink, fontSize: 8.5, fontWeight: 800,
                        letterSpacing: '.06em', padding: '3px 8px', borderRadius: 6 }}>
                        OMMABOP
                      </span>
                    )}
                    <div style={{ fontSize: 12, fontWeight: 700,
                      color: popular ? '#fff' : 'rgba(255,255,255,.8)' }}>
                      {plan.name_uz}
                    </div>
                    <div style={{ fontFamily: serif, fontSize: 21, fontWeight: 800,
                      color: '#fff', marginTop: 6, lineHeight: 1.1 }}>
                      {priceStr}
                      <span style={{ fontSize: 11, fontWeight: 600,
                        color: popular ? 'rgba(255,255,255,.7)' : 'rgba(255,255,255,.5)' }}>
                        /{dur}
                      </span>
                    </div>
                    <div style={{ height: 1,
                      background: popular ? 'rgba(255,255,255,.22)' : 'rgba(255,255,255,.12)',
                      margin: '12px 0' }} />
                    {features.map(f => <Feat key={f} dark={!popular}>{f}</Feat>)}
                    <button onClick={() => navigate('payment', {
                        plan_id: plan.id,
                        amount: plan.price,
                        currency: plan.currency,
                        plan_name: plan.name_uz,
                        duration: dur,
                      })}
                      style={{ width: '100%', marginTop: 12, height: 34, border: 'none',
                        borderRadius: 9, cursor: 'pointer', fontSize: 11.5, fontWeight: 700,
                        background: popular ? c.gold : 'rgba(255,255,255,.15)',
                        color: popular ? c.ink : '#fff' }}>
                      Tanlash
                    </button>
                  </div>
                );
              })
            )}
          </div>

          <div style={{ flex: 1 }} />
          <div style={{ textAlign: 'center', fontSize: 10.5, color: 'rgba(255,255,255,.5)',
            margin: '16px 0' }}>
            Istalgan vaqtda bekor qilasiz · Click · Payme
          </div>
        </div>
      </div>
    </>
  );
};
const Feat = ({ children, dark }: { children: React.ReactNode; dark?: boolean }) => (
  <div style={{ display: 'flex', alignItems: 'center', gap: 7, fontSize: 10.5,
    color: dark ? 'rgba(255,255,255,.75)' : '#fff', marginBottom: 8 }}>
    <Check size={13} color={dark ? c.gold : '#fff'} stroke={2.6} />{children}
  </div>
);

/* ---------- Verify seller ---------- */
export const VerifyScreen = () => {
  const { back } = useNav();
  return (
    <>
      <StatusBar />
      <TopBar title="Tasdiqlash" />
      <div style={{ flex: 1, overflowY: 'auto', padding: '18px 16px' }}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
          <div style={{ width: 64, height: 64, borderRadius: 20, background: c.accentSoft, color: c.accent, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Shield size={32} /></div>
          <div style={{ fontFamily: serif, fontSize: 19, fontWeight: 700, color: c.ink, marginTop: 13 }}>Ishonchli sotuvchi bo'ling</div>
          <div style={{ fontSize: 12, color: c.muted, marginTop: 5, lineHeight: 1.5, maxWidth: 260 }}>Tasdiqlangan sotuvchilar 3× ko'proq sotadi va xaridorlar ishonadi.</div>
        </div>
        <div style={{ marginTop: 20, display: 'flex', flexDirection: 'column', gap: 11 }}>
          <Step done icon={<Check size={18} color={c.green} stroke={2.4} />} title="Telefon raqami" sub="Tasdiqlangan" subColor={c.green} />
          <Step active title="Pasport / ID karta" sub="Rasmga oling — 1 daqiqa" />
          <Step title="Selfi tekshiruvi" sub="Keyingi qadam" dim />
        </div>
        <div style={{ background: c.greenSoft, border: `1px solid ${c.greenLine}`, borderRadius: 12, padding: '11px 13px', marginTop: 16, display: 'flex', gap: 9, alignItems: 'flex-start' }}>
          <Verified size={15} color="#1f7a44" /><span style={{ fontSize: 10.5, color: '#3d7a55', lineHeight: 1.45 }}>Ma'lumotlaringiz shifrlanadi va faqat tekshirish uchun ishlatiladi.</span>
        </div>
      </div>
      <div style={{ flexShrink: 0, padding: '12px 16px 16px', background: c.card, borderTop: `1px solid ${c.line}` }}>
        <button onClick={back} style={{ width: '100%', height: 50, border: 'none', borderRadius: 14, background: c.accent, color: '#fff', fontSize: 13.5, fontWeight: 700, cursor: 'pointer', boxShadow: '0 8px 16px rgba(194,97,59,.32)' }}>Hujjatni rasmga olish</button>
      </div>
    </>
  );
};
const Step = ({ icon, title, sub, subColor, active, done, dim }: any) => (
  <div style={{ display: 'flex', alignItems: 'center', gap: 12, background: c.card, border: `${active ? 2 : 1}px solid ${active ? c.accent : c.line}`, borderRadius: 14, padding: 13, opacity: dim ? .6 : 1 }}>
    <div style={{ width: 36, height: 36, borderRadius: 11, background: done ? c.greenSoft : c.accentSoft, color: c.accent, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{icon || <Shield size={18} />}</div>
    <div style={{ flex: 1 }}><div style={{ fontSize: 12.5, fontWeight: 700, color: c.ink }}>{title}</div><div style={{ fontSize: 10, color: subColor || c.muted, fontWeight: subColor ? 600 : 400 }}>{sub}</div></div>
    {active && <Chevron size={16} color={c.accent} />}
  </div>
);

/* ---------- Review ---------- */
export const ReviewScreen = () => {
  const { back } = useNav();
  const [stars, setStars] = useState(4);
  const [tags, setTags] = useState<string[]>(['Rost ma\'lumot']);
  const toggle = (t: string) => setTags((p) => p.includes(t) ? p.filter((x) => x !== t) : [...p, t]);
  return (
    <>
      <StatusBar />
      <div style={{ flex: 1, background: 'rgba(21,17,13,.3)' }} onClick={back} />
      <div style={{ flexShrink: 0, background: c.bg, borderRadius: '24px 24px 0 0', boxShadow: '0 -12px 30px rgba(40,24,10,.18)', padding: '10px 20px 20px' }}>
        <div style={{ width: 38, height: 4, borderRadius: 3, background: '#d8cab3', margin: '2px auto 16px' }} />
        <div style={{ textAlign: 'center' }}>
          <div style={{ width: 54, height: 54, borderRadius: 16, background: c.accent, color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: serif, fontWeight: 700, fontSize: 18, margin: '0 auto' }}>TR</div>
          <div style={{ fontFamily: serif, fontSize: 18, fontWeight: 700, color: c.ink, marginTop: 10 }}>Bitim qanday o'tdi?</div>
          <div style={{ fontSize: 11.5, color: c.muted, marginTop: 3 }}>Tashkent Realty bilan savdoyingizni baholang</div>
        </div>
        <div style={{ display: 'flex', gap: 10, justifyContent: 'center', marginTop: 18 }}>
          {[1, 2, 3, 4, 5].map((s) => (
            <button key={s} onClick={() => setStars(s)} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 0 }}>
              <Star size={38} fill={s <= stars ? c.gold : 'none'} color={s <= stars ? c.gold : '#d8cab3'} />
            </button>
          ))}
        </div>
        <div style={{ textAlign: 'center', fontSize: 12, fontWeight: 700, color: c.accent, marginTop: 9 }}>{['', 'Yomon', 'O\'rtacha', 'Yaxshi', 'Yaxshi', 'Ajoyib'][stars]}</div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8, justifyContent: 'center', marginTop: 16 }}>
          {['Tez javob berdi', 'Rost ma\'lumot', 'Xushmuomala'].map((t) => {
            const on = tags.includes(t);
            return <button key={t} onClick={() => toggle(t)} style={{ fontSize: 11, fontWeight: on ? 700 : 600, color: on ? c.accent : c.ink, background: on ? c.accentSoft : c.card, border: `1px solid ${on ? c.accent : c.line}`, borderRadius: 20, padding: '7px 13px', cursor: 'pointer' }}>{t}</button>;
          })}
        </div>
        <div style={{ background: c.card, border: `1px solid ${c.line}`, borderRadius: 13, padding: 12, marginTop: 16, fontSize: 12, color: '#a8957d', minHeight: 60 }}>Izoh qoldiring (ixtiyoriy)…</div>
        <button onClick={back} style={{ width: '100%', height: 50, border: 'none', borderRadius: 14, background: c.accent, color: '#fff', fontSize: 13.5, fontWeight: 700, cursor: 'pointer', marginTop: 14, boxShadow: '0 8px 16px rgba(194,97,59,.32)' }}>Sharhni yuborish</button>
      </div>
    </>
  );
};

/* ---------- Referral ---------- */
export const ReferralScreen = () => {
  const { back } = useNav();
  const [copied, setCopied] = useState(false);
  return (
    <>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', background: 'linear-gradient(165deg,#3a2a1c,#5a3a22)', position: 'relative', overflow: 'hidden' }}>
        <div style={{ position: 'absolute', right: -40, top: 40, width: 160, height: 160, borderRadius: '50%', background: 'rgba(224,163,62,.12)' }} />
        <StatusBar color="#fff" />
        <div style={{ padding: '0 16px' }}>
          <button onClick={back} style={{ width: 32, height: 32, border: 'none', borderRadius: '50%', background: 'rgba(255,255,255,.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', cursor: 'pointer' }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 6L6 18M6 6l12 12" /></svg>
          </button>
        </div>
        <div style={{ flex: 1, overflowY: 'auto', padding: '10px 24px 0', display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', position: 'relative', zIndex: 5 }}>
          <div style={{ width: 72, height: 72, borderRadius: 22, background: 'rgba(224,163,62,.2)', color: c.gold, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><svg width="38" height="38" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><circle cx="9" cy="8" r="3.5" /><path d="M2 20c0-4 3.5-6 7-6s7 2 7 6" /><path d="M18 8v6M21 11h-6" /></svg></div>
          <div style={{ fontFamily: serif, fontSize: 24, fontWeight: 800, color: '#fff', marginTop: 16, lineHeight: 1.2 }}>Do'stingizni<br />taklif qiling</div>
          <div style={{ fontSize: 12.5, color: 'rgba(255,255,255,.7)', marginTop: 10, lineHeight: 1.55 }}>Har bir do'st birinchi e'lonini bersa — ikkalangizga ham <b style={{ color: c.gold }}>1 ta bepul TOP ko'tarish</b>.</div>
          <button onClick={() => { setCopied(true); setTimeout(() => setCopied(false), 1500); }} style={{ width: '100%', background: 'rgba(255,255,255,.08)', border: '1px dashed rgba(255,255,255,.3)', borderRadius: 14, padding: 14, marginTop: 22, display: 'flex', alignItems: 'center', justifyContent: 'space-between', cursor: 'pointer' }}>
            <span style={{ fontFamily: serif, fontSize: 19, fontWeight: 800, color: '#fff', letterSpacing: '.1em' }}>BOBUR50</span>
            <span style={{ fontSize: 11, fontWeight: 700, color: c.gold }}>{copied ? 'Nusxalandi ✓' : 'Nusxa'}</span>
          </button>
          <div style={{ display: 'flex', gap: 14, marginTop: 18, width: '100%', justifyContent: 'center' }}>
            <div style={{ textAlign: 'center' }}><div style={{ fontFamily: serif, fontSize: 22, fontWeight: 800, color: c.gold }}>8</div><div style={{ fontSize: 9.5, color: 'rgba(255,255,255,.6)' }}>Taklif qilingan</div></div>
            <div style={{ width: 1, background: 'rgba(255,255,255,.15)' }} />
            <div style={{ textAlign: 'center' }}><div style={{ fontFamily: serif, fontSize: 22, fontWeight: 800, color: c.gold }}>6</div><div style={{ fontSize: 9.5, color: 'rgba(255,255,255,.6)' }}>Bonus olingan</div></div>
          </div>
        </div>
        <div style={{ flexShrink: 0, padding: '0 24px 26px', position: 'relative', zIndex: 5 }}>
          <button style={{ width: '100%', height: 52, border: 'none', borderRadius: 15, background: c.gold, color: c.ink, fontSize: 14, fontWeight: 800, cursor: 'pointer' }}>Telegramda ulashish</button>
        </div>
      </div>
    </>
  );
};
