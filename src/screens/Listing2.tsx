import { useState, useEffect } from 'react';
import { c, serif, price } from '../theme';
import { listings, autos } from '../data';
import { Star, Shield, Truck, Pin, Lock, Card, Verified } from '../icons';
import { useNav, StatusBar, TopBar } from '../shell';
import { api } from '../api';

/* ---------- AI price analysis ---------- */
export const PriceAIScreen = () => {
  const bars = [{ h: 34, l: '65k', muted: true }, { h: 54, l: '72k' }, { h: 42, l: '78k', me: true }, { h: 78, l: '88k' }, { h: 90, l: '95k', muted: true }];
  return (
    <>
      <StatusBar />
      <TopBar title="Narx tahlili" />
      <div style={{ flex: 1, overflowY: 'auto', padding: '16px 16px', display: 'flex', flexDirection: 'column', gap: 14 }}>
        <div style={{ background: `linear-gradient(135deg,#1f7a44,${c.green})`, borderRadius: 18, padding: '17px 18px', color: '#fff', position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', right: -20, top: -20, width: 100, height: 100, borderRadius: '50%', background: 'rgba(255,255,255,.1)' }} />
          <div style={{ display: 'flex', alignItems: 'center', gap: 7, position: 'relative' }}><Star size={17} fill="#fff" color="#fff" /><span style={{ fontSize: 11, fontWeight: 800, letterSpacing: '.08em', textTransform: 'uppercase' }}>Yaxshi narx</span></div>
          <div style={{ fontFamily: serif, fontSize: 30, fontWeight: 800, marginTop: 9, position: 'relative' }}>12% arzon</div>
          <div style={{ fontSize: 11.5, opacity: .9, marginTop: 4, lineHeight: 1.45, position: 'relative' }}>Bozordagi o'xshash traktorlarga nisbatan. AI 86 ta e'lonni tahlil qildi.</div>
        </div>
        <div style={{ background: c.card, border: `1px solid ${c.line}`, borderRadius: 16, padding: '15px 16px' }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: c.ink, marginBottom: 13 }}>Bozor narx oralig'i</div>
          <div style={{ display: 'flex', alignItems: 'flex-end', gap: 6, height: 96 }}>
            {bars.map((b, i) => (
              <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 5, position: 'relative' }}>
                {b.me && <div style={{ position: 'absolute', top: -16, fontSize: 8.5, fontWeight: 800, color: c.accent, whiteSpace: 'nowrap' }}>Bu e'lon</div>}
                <div style={{ width: '100%', height: b.h, borderRadius: 5, background: b.me ? c.accent : b.muted ? '#e7dcc9' : '#e0d2ba' }} />
                <span style={{ fontSize: 8, fontWeight: b.me ? 700 : 400, color: b.me ? c.accent : c.muted }}>{b.l}</span>
              </div>
            ))}
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 12, paddingTop: 11, borderTop: `1px solid ${c.line}` }}>
            <div><div style={{ fontSize: 9.5, color: c.muted }}>O'rtacha narx</div><div style={{ fontFamily: serif, fontSize: 15, fontWeight: 700, color: c.ink, marginTop: 1 }}>$88 600</div></div>
            <div style={{ textAlign: 'right' }}><div style={{ fontSize: 9.5, color: c.muted }}>Siz tejaysiz</div><div style={{ fontFamily: serif, fontSize: 15, fontWeight: 700, color: c.green, marginTop: 1 }}>~$10 600</div></div>
          </div>
        </div>
        <div style={{ display: 'flex', gap: 10 }}>
          <Mini t="Sotilish vaqti" v="~9 kun" />
          <Mini t="Talab darajasi" v="Yuqori" color={c.green} />
        </div>
      </div>
    </>
  );
};
const Mini = ({ t, v, color }: { t: string; v: string; color?: string }) => (
  <div style={{ flex: 1, background: c.card, border: `1px solid ${c.line}`, borderRadius: 14, padding: 12 }}>
    <div style={{ fontSize: 9.5, color: c.muted }}>{t}</div>
    <div style={{ fontFamily: serif, fontSize: 16, fontWeight: 700, color: color || c.ink, marginTop: 3 }}>{v}</div>
  </div>
);

/* ---------- Safe deal ---------- */
export const SafeDealScreen = () => {
  const { navigate } = useNav();
  const item = listings[4];
  const [opt, setOpt] = useState('delivery');
  return (
    <>
      <StatusBar />
      <TopBar title="Xavfsiz savdo" />
      <div style={{ flex: 1, overflowY: 'auto', padding: '14px 16px', display: 'flex', flexDirection: 'column', gap: 13 }}>
        <div style={{ display: 'flex', gap: 11, background: c.card, border: `1px solid ${c.line}`, borderRadius: 14, padding: 10 }}>
          <div style={{ width: 58, height: 58, borderRadius: 10, overflow: 'hidden', flexShrink: 0 }}><img src={item.src} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} /></div>
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center' }}><div style={{ fontSize: 12.5, fontWeight: 600, color: c.ink }}>{item.title}</div><div style={{ fontFamily: serif, fontSize: 15, fontWeight: 700, color: c.accent, marginTop: 3 }}>{price(item.priceVal)}</div></div>
        </div>
        <div style={{ background: c.greenSoft, border: `1px solid ${c.greenLine}`, borderRadius: 14, padding: '12px 13px', display: 'flex', gap: 10, alignItems: 'flex-start' }}>
          <div style={{ width: 34, height: 34, borderRadius: 10, background: c.green, color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Shield size={18} /></div>
          <div><div style={{ fontSize: 12.5, fontWeight: 700, color: '#1f7a44' }}>Pul kafolatlangan</div><div style={{ fontSize: 10.5, color: '#3d7a55', lineHeight: 1.45, marginTop: 2 }}>To'lov mahsulotni qabul qilguningizgacha Ravoq hisobida turadi.</div></div>
        </div>
        <div>
          <div style={{ fontSize: 11, fontWeight: 700, color: c.ink, marginBottom: 8 }}>Yetkazib berish</div>
          <button onClick={() => setOpt('delivery')} style={{ width: '100%', display: 'flex', alignItems: 'center', gap: 11, background: c.card, border: `${opt === 'delivery' ? 2 : 1}px solid ${opt === 'delivery' ? c.accent : c.line}`, borderRadius: 13, padding: '11px 12px', marginBottom: 9, cursor: 'pointer' }}>
            <Truck size={20} color={c.accent} /><div style={{ flex: 1, textAlign: 'left' }}><div style={{ fontSize: 12.5, fontWeight: 700, color: c.ink }}>Ravoq Yetkazib berish</div><div style={{ fontSize: 10, color: c.muted }}>2–3 kun · butun O'zbekiston</div></div><span style={{ fontFamily: serif, fontSize: 13, fontWeight: 700, color: c.accent }}>25 000</span>
          </button>
          <button onClick={() => setOpt('pickup')} style={{ width: '100%', display: 'flex', alignItems: 'center', gap: 11, background: c.card, border: `${opt === 'pickup' ? 2 : 1}px solid ${opt === 'pickup' ? c.accent : c.line}`, borderRadius: 13, padding: '11px 12px', cursor: 'pointer' }}>
            <Pin size={20} color={c.muted} /><div style={{ flex: 1, textAlign: 'left' }}><div style={{ fontSize: 12.5, fontWeight: 700, color: c.ink }}>O'zim olib ketaman</div><div style={{ fontSize: 10, color: c.muted }}>Kelishilgan joyda</div></div><span style={{ fontSize: 12, fontWeight: 700, color: c.green }}>Bepul</span>
          </button>
        </div>
      </div>
      <div style={{ flexShrink: 0, padding: '12px 16px 16px', background: c.card, borderTop: `1px solid ${c.line}` }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 10 }}><span style={{ fontSize: 12, fontWeight: 600, color: c.muted }}>Jami</span><span style={{ fontFamily: serif, fontSize: 22, fontWeight: 800, color: c.ink }}>$2 705</span></div>
        <button onClick={() => navigate('payment')} style={{ width: '100%', height: 50, border: 'none', borderRadius: 14, background: c.accent, color: '#fff', fontSize: 13.5, fontWeight: 700, cursor: 'pointer', boxShadow: '0 8px 16px rgba(194,97,59,.32)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7 }}><Card size={17} />Xavfsiz to'lash</button>
      </div>
    </>
  );
};

/* ---------- Payment ---------- */
const PAY_METHODS = [
  { k: 'click', label: 'Click',  bg: '#00AEEF', fg: '#fff' },
  { k: 'payme', label: 'Payme', bg: '#33D6C9', fg: '#0a3d3a' },
];

const ORDER_STATUS: Record<string, { label: string; color: string }> = {
  created:   { label: 'Kutilmoqda',      color: '#c28a0e' },
  completed: { label: "To'langan",       color: '#1f7a44' },
  cancelled: { label: 'Bekor qilindi',   color: '#a8957d' },
  failed:    { label: 'Muvaffaqiyatsiz', color: '#c0392b' },
};

const ORDER_TYPE: Record<string, string> = {
  subscription: "Obuna to'lovi",
  posting_fee:  "E'lon joylash",
};

function fmtAmt(amount: number, currency: string): string {
  if (currency === 'USD') return `$${amount.toLocaleString()}`;
  return `${amount.toLocaleString('ru-RU').replace(/,/g, ' ')} so'm`;
}

export const PaymentScreen = () => {
  const { navigate, params } = useNav();
  const planId: number | null  = params.plan_id  ?? null;
  const orderId: number | null = params.order_id ?? null;
  const isPayMode = !!(planId || orderId);

  const [provider, setProvider] = useState<'click' | 'payme'>('click');
  const [paying, setPaying]     = useState(false);
  const [done, setDone]         = useState(false);
  const [payError, setPayError] = useState<string | null>(null);

  // history mode
  const [orders, setOrders]         = useState<any[]>([]);
  const [histLoading, setHistLoading] = useState(!isPayMode);
  const [histError, setHistError]   = useState<string | null>(null);

  useEffect(() => {
    if (!isPayMode) {
      api.getMyOrders()
        .then((res: any) => setOrders(res.data ?? []))
        .catch((e: any) => setHistError(e.message))
        .finally(() => setHistLoading(false));
    }
  }, []);

  const handlePay = async () => {
    setPaying(true);
    setPayError(null);
    try {
      let url: string;
      if (planId) {
        const res = await api.createSubscription(planId, provider);
        url = res.checkout_url;
      } else {
        const res = await api.initPayment(orderId!, provider);
        url = res.checkout_url;
      }
      window.open(url, '_blank');
      setDone(true);
      setTimeout(() => navigate('myAds'), 2000);
    } catch (e: any) {
      setPayError(e.message);
    } finally {
      setPaying(false);
    }
  };

  // ── history mode ──────────────────────────────────────────────────────────
  if (!isPayMode) {
    return (
      <>
        <StatusBar />
        <TopBar title="To'lovlar tarixi" />
        <div style={{ flex: 1, overflowY: 'auto', padding: '8px 0' }}>
          {histLoading ? (
            <div style={{ textAlign: 'center', paddingTop: 60, fontSize: 12,
              color: c.muted, fontWeight: 600 }}>Yuklanmoqda…</div>
          ) : histError ? (
            <div style={{ textAlign: 'center', paddingTop: 60, fontSize: 12,
              color: '#c0392b', fontWeight: 600 }}>{histError}</div>
          ) : orders.length === 0 ? (
            <div style={{ textAlign: 'center', paddingTop: 80, fontSize: 12,
              color: c.muted, fontWeight: 600 }}>
              <Card size={40} color="#d3c1a8" />
              <div style={{ marginTop: 14 }}>Hali to'lovlar yo'q</div>
            </div>
          ) : orders.map((o: any) => {
            const st = ORDER_STATUS[o.status] ?? { label: o.status, color: c.muted };
            const typ = ORDER_TYPE[o.type] ?? "To'lov";
            const d = new Date(o.created_at);
            const date = `${d.getDate()}.${String(d.getMonth() + 1).padStart(2, '0')}.${d.getFullYear()}`;
            return (
              <div key={o.id} style={{ display: 'flex', alignItems: 'center',
                gap: 13, padding: '13px 16px', borderBottom: `1px solid ${c.line}` }}>
                <div style={{ width: 40, height: 40, borderRadius: 12, background: c.accentSoft,
                  color: c.accent, display: 'flex', alignItems: 'center',
                  justifyContent: 'center', flexShrink: 0 }}>
                  <Card size={18} />
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 12.5, fontWeight: 700, color: c.ink }}>{typ}</div>
                  <div style={{ fontSize: 10, color: c.muted, marginTop: 1 }}>{date}</div>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <div style={{ fontFamily: serif, fontSize: 13, fontWeight: 700, color: c.ink }}>
                    {fmtAmt(o.amount, o.currency)}
                  </div>
                  <div style={{ fontSize: 10, fontWeight: 700, color: st.color, marginTop: 1 }}>
                    {st.label}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </>
    );
  }

  // ── payment mode ──────────────────────────────────────────────────────────
  const amountDisplay = planId && params.amount
    ? fmtAmt(params.amount, params.currency ?? 'UZS')
    : orderId ? `#${orderId} buyurtma` : '—';

  const subtitle = planId
    ? `${params.plan_name ?? 'Obuna'} · ${params.duration ?? ''}`
    : "E'lon joylash to'lovi";

  if (done) {
    return (
      <>
        <StatusBar />
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center', padding: 32, textAlign: 'center' }}>
          <div style={{ width: 64, height: 64, borderRadius: 20, background: '#e6f5ec',
            display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 16 }}>
            <svg width="32" height="32" viewBox="0 0 24 24" fill="none"
              stroke="#1f7a44" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="12" cy="12" r="10" />
              <path d="M9 12l2 2 4-4" />
            </svg>
          </div>
          <div style={{ fontFamily: serif, fontSize: 19, fontWeight: 700, color: c.ink }}>
            To'lov sahifasi ochildi
          </div>
          <div style={{ fontSize: 12, color: c.muted, marginTop: 6, lineHeight: 1.5 }}>
            To'lovni to'ldirgandan so'ng avtomatik yangilanadi.
          </div>
        </div>
      </>
    );
  }

  return (
    <>
      <StatusBar />
      <TopBar title={planId ? "Obuna to'lovi" : "E'lon to'lovi"} />
      <div style={{ flex: 1, overflowY: 'auto', padding: '16px 16px' }}>

        {/* amount card */}
        <div style={{ textAlign: 'center', background: c.card,
          border: `1px solid ${c.line}`, borderRadius: 16, padding: 16 }}>
          <div style={{ fontSize: 11, color: c.muted }}>To'lov summasi</div>
          <div style={{ fontFamily: serif, fontSize: 28, fontWeight: 800,
            color: c.ink, marginTop: 3 }}>
            {amountDisplay}
          </div>
          <div style={{ fontSize: 10.5, color: c.muted, marginTop: 3 }}>{subtitle}</div>
        </div>

        <div style={{ fontSize: 11, fontWeight: 700, color: c.muted,
          textTransform: 'uppercase', letterSpacing: '.05em', margin: '18px 0 10px' }}>
          To'lov tizimini tanlang
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {PAY_METHODS.map((m) => {
            const on = m.k === provider;
            return (
              <button key={m.k} onClick={() => setProvider(m.k as any)}
                style={{ display: 'flex', alignItems: 'center', gap: 13,
                  background: c.card,
                  border: `${on ? 2 : 1}px solid ${on ? c.accent : c.line}`,
                  borderRadius: 14, padding: 13, cursor: 'pointer' }}>
                <div style={{ width: 46, height: 32, borderRadius: 7, background: m.bg,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  color: m.fg, fontFamily: serif, fontWeight: 800, fontSize: 11,
                  flexShrink: 0 }}>
                  {m.label}
                </div>
                <span style={{ flex: 1, textAlign: 'left', fontSize: 13,
                  fontWeight: 700, color: c.ink }}>
                  {m.label}
                </span>
                {on && <Verified size={20} />}
              </button>
            );
          })}
        </div>

        {payError && (
          <div style={{ marginTop: 12, fontSize: 12, color: '#c0392b',
            fontWeight: 600, textAlign: 'center', lineHeight: 1.45 }}>
            {payError}
          </div>
        )}
      </div>

      <div style={{ flexShrink: 0, padding: '12px 16px 16px', background: c.card,
        borderTop: `1px solid ${c.line}` }}>
        <button onClick={handlePay} disabled={paying}
          style={{ width: '100%', height: 50, border: 'none', borderRadius: 14,
            background: paying ? '#d4a88a' : c.accent, color: '#fff',
            fontSize: 13.5, fontWeight: 700, cursor: paying ? 'default' : 'pointer',
            boxShadow: paying ? 'none' : '0 8px 16px rgba(194,97,59,.32)',
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7 }}>
          <Lock size={16} />
          {paying ? 'Yuklanmoqda…' : amountDisplay + " to'lash"}
        </button>
      </div>
    </>
  );
};

/* ---------- Seller store ---------- */
export const SellerStoreScreen = () => {
  const { back, navigate } = useNav();
  const items = [autos[0], autos[1]];
  return (
    <>
      <div style={{ flex: 1, overflowY: 'auto' }}>
        <div style={{ position: 'relative', height: 148 }}>
          <img src={listings[2].src} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
          <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg,rgba(20,12,6,.4),rgba(20,12,6,.1))' }} />
          <div style={{ position: 'absolute', top: 0, left: 0, right: 0 }}><StatusBar color="#fff" /></div>
          <button onClick={back} style={{ position: 'absolute', top: 36, left: 14, width: 34, height: 34, border: 'none', borderRadius: '50%', background: 'rgba(255,253,249,.92)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: c.ink, cursor: 'pointer' }}>
            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M15 18l-6-6 6-6" /></svg>
          </button>
        </div>
        <div style={{ padding: '0 16px', marginTop: -32, position: 'relative' }}>
          <div style={{ display: 'flex', alignItems: 'flex-end', gap: 12 }}>
            <div style={{ width: 64, height: 64, borderRadius: 18, background: c.accent, color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: serif, fontWeight: 800, fontSize: 22, border: `3px solid ${c.bg}`, flexShrink: 0 }}>AT</div>
            <div style={{ paddingBottom: 4 }}><div style={{ display: 'flex', alignItems: 'center', gap: 5 }}><span style={{ fontFamily: serif, fontSize: 17, fontWeight: 700, color: c.ink }}>AgroTexnika UZ</span><Verified size={14} /></div><div style={{ fontSize: 10.5, color: c.muted, marginTop: 2 }}>Rasmiy diler · Toshkent</div></div>
          </div>
          <div style={{ display: 'flex', marginTop: 14, background: c.card, border: `1px solid ${c.line}`, borderRadius: 14, padding: '11px 0' }}>
            <St n="★ 4.9" l="218 sharh" b /><St n="64" l="E'lon" b /><St n="3 yil" l="Ravoqda" />
          </div>
          <div style={{ display: 'flex', gap: 9, marginTop: 12 }}>
            <button style={{ flex: 1, height: 42, border: 'none', borderRadius: 12, background: c.accent, color: '#fff', fontSize: 12.5, fontWeight: 700, cursor: 'pointer' }}>Obuna</button>
            <button onClick={() => navigate('chat')} style={{ flex: 1, height: 42, border: `1.5px solid ${c.accent}`, borderRadius: 12, background: 'transparent', color: c.accent, fontSize: 12.5, fontWeight: 700, cursor: 'pointer' }}>Xabar</button>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, margin: '16px 0' }}>
            {items.map((it) => (
              <button key={it.id} onClick={() => navigate('detail', { id: it.id })} style={{ background: c.card, border: `1px solid ${c.line}`, borderRadius: 14, overflow: 'hidden', cursor: 'pointer', textAlign: 'left', padding: 0 }}>
                <div style={{ aspectRatio: '1.3/1', overflow: 'hidden' }}><img src={it.src} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} /></div>
                <div style={{ padding: '8px 9px' }}><div style={{ fontSize: 11, fontWeight: 600, color: c.ink, lineHeight: 1.25, height: 28, overflow: 'hidden' }}>{it.title}</div><div style={{ fontFamily: serif, fontSize: 13.5, fontWeight: 700, color: c.accent, marginTop: 3 }}>{price(it.priceVal)}</div></div>
              </button>
            ))}
          </div>
        </div>
      </div>
    </>
  );
};
const St = ({ n, l, b }: { n: string; l: string; b?: boolean }) => (
  <div style={{ flex: 1, textAlign: 'center', borderRight: b ? `1px solid ${c.line}` : 'none' }}>
    <div style={{ fontFamily: serif, fontSize: 16, fontWeight: 800, color: c.ink }}>{n}</div>
    <div style={{ fontSize: 9, color: c.muted }}>{l}</div>
  </div>
);

/* ---------- Auto category ---------- */
export const AutoScreen = () => {
  const { back, navigate, params } = useNav();
  return (
    <>
      <StatusBar />
      <div style={{ flexShrink: 0, padding: '4px 14px 11px', background: c.card, borderBottom: `1px solid ${c.line}`, display: 'flex', alignItems: 'center', gap: 11 }}>
        <button onClick={back} style={{ width: 32, height: 32, border: 'none', borderRadius: '50%', background: c.bg, display: 'flex', alignItems: 'center', justifyContent: 'center', color: c.ink, cursor: 'pointer' }}>
          <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M15 18l-6-6 6-6" /></svg>
        </button>
        <span style={{ flex: 1, fontFamily: serif, fontSize: 16, fontWeight: 700, color: c.ink }}>{params.cat || 'Avtomobillar'}</span>
      </div>
      <div style={{ flexShrink: 0, display: 'flex', gap: 8, padding: '11px 14px', overflowX: 'auto' }}>
        {['Marka', 'Yil', 'Probeg', 'Motor'].map((f, i) => (
          <span key={f} style={{ whiteSpace: 'nowrap', fontSize: 11, fontWeight: 700, padding: '8px 12px', borderRadius: 11, background: i === 2 ? c.accent : c.card, border: i === 2 ? 'none' : `1px solid ${c.line}`, color: i === 2 ? '#fff' : c.ink, display: 'flex', alignItems: 'center', gap: 5 }}>{f} <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke={i === 2 ? '#fff' : c.muted} strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M6 9l6 6 6-6" /></svg></span>
        ))}
      </div>
      <div style={{ flex: 1, overflowY: 'auto', padding: '0 14px 14px', display: 'flex', flexDirection: 'column', gap: 12 }}>
        {autos.map((a, idx) => (
          <button key={a.id} onClick={() => navigate('detail', { id: a.id })} style={{ background: c.card, border: `1px solid ${c.line}`, borderRadius: 16, overflow: 'hidden', cursor: 'pointer', textAlign: 'left', padding: 0 }}>
            <div style={{ position: 'relative', height: 148, overflow: 'hidden' }}>
              <img src={a.src} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
              {a.badge && <span style={{ position: 'absolute', top: 9, left: 9, background: c.accent, color: '#fff', fontSize: 8.5, fontWeight: 800, letterSpacing: '.08em', padding: '3px 8px', borderRadius: 6 }}>{a.badge}</span>}
            </div>
            <div style={{ padding: '11px 13px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}><span style={{ fontSize: 13.5, fontWeight: 700, color: c.ink }}>{a.title}</span><span style={{ fontFamily: serif, fontSize: 16, fontWeight: 700, color: c.accent }}>{price(a.priceVal)}</span></div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginTop: 9 }}>
                {(a.specs || []).map((s) => <span key={s} style={{ fontSize: 10, fontWeight: 600, color: c.ink, background: c.bg, border: `1px solid ${c.line}`, padding: '4px 9px', borderRadius: 8 }}>{s}</span>)}
              </div>
              <div style={{ fontSize: 10, color: c.muted, marginTop: 9 }}>{a.loc} · {idx === 0 ? 'Bugun' : 'Kecha'}</div>
            </div>
          </button>
        ))}
        <button onClick={() => navigate('compare')} style={{ height: 44, border: `1.5px solid ${c.line}`, borderRadius: 12, background: c.card, color: c.ink, fontSize: 12.5, fontWeight: 700, cursor: 'pointer' }}>Tanlanganlarni solishtirish</button>
      </div>
    </>
  );
};

/* ---------- Compare ---------- */
export const CompareScreen = () => {
  const [a, b] = autos;
  const rows = [
    { l: 'Yil', a: '2021', b: '2019', aw: true },
    { l: 'Probeg', a: '42k', b: '87k', aw: true },
    { l: 'Motor', a: '2.0 L', b: '1.5 L' },
    { l: 'Uzatma', a: 'Avtomat', b: 'Mexanika', aw: true },
    { l: 'AI narx', a: 'Yaxshi', b: "O'rtacha", aw: true, bc: c.accent },
  ];
  return (
    <>
      <StatusBar />
      <TopBar title="Solishtirish" />
      <div style={{ flex: 1, overflowY: 'auto', padding: 14 }}>
        <div style={{ display: 'flex', gap: 11 }}>
          {[a, b].map((it) => (
            <div key={it.id} style={{ flex: 1, background: c.card, border: `1px solid ${c.line}`, borderRadius: 14, overflow: 'hidden' }}>
              <div style={{ height: 84, overflow: 'hidden' }}><img src={it.src} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} /></div>
              <div style={{ padding: '9px 10px' }}><div style={{ fontSize: 11.5, fontWeight: 700, color: c.ink, lineHeight: 1.25 }}>{it.title}</div><div style={{ fontFamily: serif, fontSize: 14, fontWeight: 700, color: c.accent, marginTop: 3 }}>{price(it.priceVal)}</div></div>
            </div>
          ))}
        </div>
        <div style={{ marginTop: 14, background: c.card, border: `1px solid ${c.line}`, borderRadius: 14, overflow: 'hidden' }}>
          {rows.map((r, i) => (
            <div key={r.l} style={{ display: 'flex', padding: '11px 12px', borderBottom: i < rows.length - 1 ? `1px solid ${c.line}` : 'none', background: i % 2 ? c.bg : 'transparent' }}>
              <span style={{ flex: 1, fontSize: 10, fontWeight: 700, letterSpacing: '.04em', textTransform: 'uppercase', color: c.muted }}>{r.l}</span>
              <span style={{ flex: 1, textAlign: 'center', fontSize: 12, fontWeight: r.aw ? 700 : 600, color: r.aw ? c.green : c.ink }}>{r.a}</span>
              <span style={{ flex: 1, textAlign: 'center', fontSize: 12, fontWeight: 600, color: r.bc || c.ink }}>{r.b}</span>
            </div>
          ))}
        </div>
      </div>
    </>
  );
};

/* ---------- Offer (price negotiation) ---------- */
export const OfferScreen = () => {
  const { back } = useNav();
  const [val, setVal] = useState(72000);
  return (
    <>
      <StatusBar />
      <div style={{ flex: 1, background: 'rgba(21,17,13,.3)' }} onClick={back} />
      <div style={{ flexShrink: 0, background: c.bg, borderRadius: '24px 24px 0 0', boxShadow: '0 -12px 30px rgba(40,24,10,.18)', padding: '10px 18px 18px' }}>
        <div style={{ width: 38, height: 4, borderRadius: 3, background: '#d8cab3', margin: '2px auto 14px' }} />
        <div style={{ fontFamily: serif, fontSize: 19, fontWeight: 700, color: c.ink }}>Narx taklif qiling</div>
        <div style={{ fontSize: 11.5, color: c.muted, marginTop: 4 }}>Sotuvchi bilan kelishing — bozordagidek.</div>
        <div style={{ textAlign: 'center', marginTop: 18 }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: c.muted, textTransform: 'uppercase', letterSpacing: '.05em' }}>Sizning taklifingiz</div>
          <div style={{ fontFamily: serif, fontSize: 38, fontWeight: 800, color: c.accent, marginTop: 6 }}>{price(val)}</div>
          <div style={{ fontSize: 11, color: c.green, fontWeight: 600, marginTop: 2 }}>{price(78000 - val).replace('$', '$')} ({Math.round((1 - val / 78000) * 100)}%) past</div>
        </div>
        <div style={{ display: 'flex', gap: 9, marginTop: 16 }}>
          {[70000, 72000, 75000].map((p) => {
            const on = p === val;
            return <button key={p} onClick={() => setVal(p)} style={{ flex: 1, textAlign: 'center', fontSize: 12, fontWeight: 700, color: on ? '#fff' : c.ink, background: on ? c.accent : c.card, border: on ? 'none' : `1px solid ${c.line}`, borderRadius: 11, padding: '10px 0', cursor: 'pointer' }}>{price(p)}</button>;
          })}
        </div>
        <div style={{ background: c.accentSoft, border: '1px solid #eccdb6', borderRadius: 12, padding: '10px 12px', marginTop: 14, fontSize: 10.5, color: '#8a5333', lineHeight: 1.45 }}>Bu modeldagi sotuvchilar odatda <b>5–9%</b> chegirma beradi.</div>
        <button onClick={back} style={{ width: '100%', height: 50, border: 'none', borderRadius: 14, background: c.accent, color: '#fff', fontSize: 13.5, fontWeight: 700, cursor: 'pointer', marginTop: 16, boxShadow: '0 8px 16px rgba(194,97,59,.32)' }}>Taklifni yuborish</button>
      </div>
    </>
  );
};
