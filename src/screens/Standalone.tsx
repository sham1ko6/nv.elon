import { useState } from 'react';
import { c, serif, price } from '../theme';
import { listings } from '../data';
import { Logo, Search, Pin, Truck, Phone, Bell, Heart, Check } from '../icons';
import { useNav, StatusBar, TopBar } from '../shell';

/* ---------- Language & currency ---------- */
export const LangScreen = () => {
  const { navigate } = useNav();
  const [lang, setLang] = useState('uz');
  const [cur, setCur] = useState("so'm");
  const langs = [{ k: 'uz', code: 'UZ', name: "O'zbekcha", sub: 'Lotin' }, { k: 'cyr', code: 'Ўз', name: 'Ўзбекча', sub: 'Кирилл' }, { k: 'ru', code: 'RU', name: 'Русский', sub: '' }];
  return (
    <>
      <StatusBar />
      <div style={{ flex: 1, overflowY: 'auto', padding: '36px 22px 22px', display: 'flex', flexDirection: 'column' }}>
        <Logo size={48} arch={c.accent} inner={c.bg} dot={c.gold} />
        <div style={{ fontFamily: serif, fontSize: 24, fontWeight: 800, color: c.ink, marginTop: 18 }}>Tilni tanlang</div>
        <div style={{ fontSize: 12.5, color: c.muted, marginTop: 5 }}>Til va valyutani keyin sozlamalardan o'zgartirishingiz mumkin.</div>
        <div style={{ marginTop: 20, display: 'flex', flexDirection: 'column', gap: 10 }}>
          {langs.map((l) => {
            const on = l.k === lang;
            return (
              <button key={l.k} onClick={() => setLang(l.k)} style={{ display: 'flex', alignItems: 'center', gap: 13, background: c.card, border: `${on ? 2 : 1}px solid ${on ? c.accent : c.line}`, borderRadius: 14, padding: 14, cursor: 'pointer' }}>
                <span style={{ fontFamily: serif, fontWeight: 800, fontSize: 16, color: on ? c.accent : c.muted, width: 30 }}>{l.code}</span>
                <div style={{ flex: 1, textAlign: 'left' }}><div style={{ fontSize: 13.5, fontWeight: 700, color: c.ink }}>{l.name}</div>{l.sub && <div style={{ fontSize: 10.5, color: c.muted }}>{l.sub}</div>}</div>
                {on && <Check size={20} color={c.accent} stroke={2.4} />}
              </button>
            );
          })}
        </div>
        <div style={{ fontSize: 11, fontWeight: 700, color: c.muted, textTransform: 'uppercase', letterSpacing: '.05em', margin: '22px 0 9px' }}>Valyuta</div>
        <div style={{ display: 'flex', gap: 9 }}>
          {["so'm", 'USD $'].map((cu) => {
            const on = cu === cur;
            return <button key={cu} onClick={() => setCur(cu)} style={{ flex: 1, textAlign: 'center', fontSize: 13, fontWeight: 700, color: on ? '#fff' : c.ink, background: on ? c.accent : c.card, border: on ? 'none' : `1px solid ${c.line}`, borderRadius: 11, padding: '11px 0', cursor: 'pointer' }}>{cu}</button>;
          })}
        </div>
        <div style={{ flex: 1 }} />
        <button onClick={() => navigate('home')} style={{ width: '100%', height: 52, border: 'none', borderRadius: 15, background: c.accent, color: '#fff', fontSize: 14, fontWeight: 700, cursor: 'pointer', boxShadow: '0 10px 20px rgba(194,97,59,.3)', marginTop: 16 }}>Davom etish</button>
      </div>
    </>
  );
};

/* ---------- Map ---------- */
export const MapScreen = () => {
  const { navigate, back } = useNav();
  const pins = [{ top: '48%', left: '24%', p: '$125k', me: true }, { top: '33%', left: '64%', p: '$78k' }, { top: '60%', left: '78%', p: '$2.6k' }];
  return (
    <>
      <div style={{ flex: 1, position: 'relative', overflow: 'hidden', background: '#E5E2D6' }}>
        <svg width="100%" height="100%" viewBox="0 0 340 720" preserveAspectRatio="xMidYMid slice" style={{ display: 'block', position: 'absolute', inset: 0 }}>
          <rect width="340" height="720" fill="#E7E3D6" />
          <path d="M-20 180 H360 M-20 360 H360 M-20 540 H360 M80 -20 V740 M180 -20 V740 M260 -20 V740" stroke="#d6d0bd" strokeWidth="10" />
          <path d="M-20 270 L360 250 M40 -20 L60 740" stroke="#cfc8b2" strokeWidth="16" />
          <path d="M-20 470 Q170 430 360 480" stroke="#bcd6c0" strokeWidth="26" fill="none" opacity=".7" />
          <rect x="20" y="60" width="44" height="80" rx="4" fill="#dcd6c4" />
          <rect x="210" y="100" width="70" height="50" rx="4" fill="#dcd6c4" />
          <rect x="100" y="400" width="60" height="60" rx="4" fill="#dcd6c4" />
          <rect x="230" y="560" width="80" height="70" rx="4" fill="#dcd6c4" />
        </svg>
        <div style={{ position: 'relative', zIndex: 10 }}><StatusBar /></div>
        <div style={{ position: 'absolute', top: 36, left: 14, right: 14, zIndex: 10, display: 'flex', gap: 9 }}>
          <button onClick={back} style={{ width: 42, height: 42, border: 'none', borderRadius: 13, background: c.card, boxShadow: '0 4px 14px rgba(60,36,14,.14)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: c.ink, cursor: 'pointer' }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M15 18l-6-6 6-6" /></svg>
          </button>
          <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 9, height: 42, borderRadius: 13, background: c.card, boxShadow: '0 4px 14px rgba(60,36,14,.14)', padding: '0 13px' }}>
            <Search size={16} color={c.muted} /><span style={{ fontSize: 12.5, color: c.ink, fontWeight: 600 }}>Toshkent sh.</span>
          </div>
        </div>
        {pins.map((p, i) => (
          <div key={i} style={{ position: 'absolute', top: p.top, left: p.left, zIndex: 9, transform: 'translate(-50%,-50%)' }}>
            <div style={{ background: p.me ? c.accent : c.card, color: p.me ? '#fff' : c.ink, fontFamily: serif, fontSize: 12, fontWeight: 700, padding: '5px 11px', borderRadius: 20, boxShadow: p.me ? '0 5px 12px rgba(194,97,59,.4)' : '0 5px 12px rgba(60,36,14,.22)', whiteSpace: 'nowrap' }}>{p.p}</div>
            <div style={{ width: 9, height: 9, background: p.me ? c.accent : c.card, transform: 'rotate(45deg)', margin: '-4px auto 0' }} />
          </div>
        ))}
        <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 12, background: c.card, borderRadius: '22px 22px 0 0', boxShadow: '0 -10px 26px rgba(40,24,10,.16)', padding: '9px 14px 16px' }}>
          <div style={{ width: 36, height: 4, borderRadius: 3, background: '#d8cab3', margin: '0 auto 11px' }} />
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 11 }}>
            <span style={{ fontFamily: serif, fontSize: 15, fontWeight: 700, color: c.ink }}>Bu hududda 24 e'lon</span>
            <button onClick={() => navigate('search')} style={{ background: 'none', border: 'none', fontSize: 11.5, fontWeight: 700, color: c.accent, cursor: 'pointer' }}>Ro'yxat</button>
          </div>
          <button onClick={() => navigate('detail', { id: 'l1' })} style={{ width: '100%', display: 'flex', gap: 11, background: c.bg, borderRadius: 14, padding: 9, border: 'none', cursor: 'pointer', textAlign: 'left' }}>
            <div style={{ width: 64, height: 64, borderRadius: 10, overflow: 'hidden', flexShrink: 0 }}><img src={listings[0].src} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} /></div>
            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center' }}><div style={{ fontSize: 12, fontWeight: 600, color: c.ink, lineHeight: 1.3 }}>{listings[0].title}</div><div style={{ fontFamily: serif, fontSize: 15, fontWeight: 700, color: c.accent, marginTop: 3 }}>{price(listings[0].priceVal)}</div><div style={{ fontSize: 10, color: c.muted, marginTop: 2 }}>Toshkent sh. · 1.2 km</div></div>
          </button>
        </div>
      </div>
    </>
  );
};

/* ---------- Story viewer ---------- */
export const StoryScreen = () => {
  const { back, navigate, params } = useNav();
  const src = params.src || listings[2].src;
  return (
    <>
      <div style={{ flex: 1, position: 'relative', overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
        <img src={src} alt="" style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', objectFit: 'cover' }} />
        <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg,rgba(20,12,6,.55) 0%,rgba(20,12,6,0) 22%,rgba(20,12,6,0) 55%,rgba(20,12,6,.82) 100%)' }} />
        <div style={{ position: 'relative', zIndex: 10 }}><StatusBar color="#fff" /></div>
        <div style={{ position: 'relative', zIndex: 10, padding: '0 14px' }}>
          <div style={{ display: 'flex', gap: 4 }}>
            <span style={{ flex: 1, height: 3, borderRadius: 3, background: '#fff' }} />
            <span style={{ flex: 1, height: 3, borderRadius: 3, background: 'rgba(255,255,255,.4)' }} />
            <span style={{ flex: 1, height: 3, borderRadius: 3, background: 'rgba(255,255,255,.4)' }} />
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 9, marginTop: 13 }}>
            <div style={{ width: 36, height: 36, borderRadius: '50%', border: '2px solid #fff', overflow: 'hidden', flexShrink: 0 }}><img src={src} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} /></div>
            <div style={{ flex: 1 }}><div style={{ fontSize: 12.5, fontWeight: 700, color: '#fff' }}>AgroTexnika UZ</div><div style={{ fontSize: 10, color: 'rgba(255,255,255,.75)' }}>2 soat oldin</div></div>
            <button onClick={back} style={{ background: 'none', border: 'none', color: '#fff', cursor: 'pointer' }}>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 6L6 18M6 6l12 12" /></svg>
            </button>
          </div>
        </div>
        <div style={{ flex: 1 }} />
        <div style={{ position: 'relative', zIndex: 10, padding: '0 16px 22px' }}>
          <span style={{ fontSize: 9.5, fontWeight: 800, letterSpacing: '.1em', textTransform: 'uppercase', color: c.gold }}>Yangi tushdi</span>
          <div style={{ fontFamily: serif, fontSize: 22, fontWeight: 800, color: '#fff', lineHeight: 1.15, marginTop: 6 }}>John Deere 6140M<br />traktor · 2022</div>
          <div style={{ fontFamily: serif, fontSize: 20, fontWeight: 700, color: c.gold, marginTop: 8 }}>$78 000</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 15 }}>
            <button onClick={() => navigate('detail', { id: 'l3' })} style={{ flex: 1, height: 48, border: 'none', borderRadius: 24, background: '#fff', color: c.ink, fontSize: 13, fontWeight: 700, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7, cursor: 'pointer' }}>E'lonni ko'rish →</button>
            <button style={{ width: 48, height: 48, border: '1.5px solid rgba(255,255,255,.6)', borderRadius: '50%', background: 'rgba(255,255,255,.12)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', cursor: 'pointer', flexShrink: 0 }}><Heart size={20} /></button>
          </div>
        </div>
      </div>
    </>
  );
};

/* ---------- Empty state ---------- */
export const EmptyScreen = () => {
  const { back, navigate } = useNav();
  return (
    <>
      <StatusBar />
      <div style={{ flexShrink: 0, padding: '4px 14px 11px', display: 'flex', alignItems: 'center', gap: 11, borderBottom: `1px solid ${c.line}` }}>
        <button onClick={back} style={{ width: 32, height: 32, border: 'none', borderRadius: '50%', background: c.card, display: 'flex', alignItems: 'center', justifyContent: 'center', color: c.ink, cursor: 'pointer', flexShrink: 0 }}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M15 18l-6-6 6-6" /></svg>
        </button>
        <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 8, height: 38, borderRadius: 11, background: c.card, border: `1px solid ${c.line}`, padding: '0 11px' }}><Search size={14} color={c.muted} /><span style={{ fontSize: 12, color: c.ink, fontWeight: 600 }}>kombayn xorazm</span></div>
      </div>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 36px', textAlign: 'center' }}>
        <div style={{ width: 96, height: 96, borderRadius: '50%', background: c.card, border: `1px solid ${c.line}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#d3c1a8' }}><Search size={44} color="#d3c1a8" /></div>
        <div style={{ fontFamily: serif, fontSize: 19, fontWeight: 700, color: c.ink, marginTop: 20 }}>Hech narsa topilmadi</div>
        <div style={{ fontSize: 12.5, color: c.muted, marginTop: 7, lineHeight: 1.55 }}>"kombayn xorazm" bo'yicha e'lon yo'q. Filtrlarni kengaytiring yoki shu qidiruvga obuna bo'ling — yangi e'lon chiqsa, xabar beramiz.</div>
        <button onClick={() => navigate('notifications')} style={{ marginTop: 20, height: 46, padding: '0 22px', border: 'none', borderRadius: 13, background: c.accent, color: '#fff', fontSize: 13, fontWeight: 700, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7, boxShadow: '0 8px 16px rgba(194,97,59,.3)' }}><Bell size={16} />Qidiruvga obuna</button>
        <button onClick={() => navigate('search')} style={{ marginTop: 11, border: 'none', background: 'none', color: c.muted, fontSize: 12, fontWeight: 700, cursor: 'pointer' }}>Filtrlarni tozalash</button>
      </div>
    </>
  );
};

/* ---------- Delivery tracking ---------- */
export const TrackingScreen = () => {
  const steps = [
    { done: true, title: 'Buyurtma qabul qilindi', time: 'Bugun, 09:12' },
    { done: true, title: 'Sotuvchi jo\'natdi', time: 'Bugun, 13:40' },
    { active: true, title: 'Yo\'lda', time: 'Toshkent sortlash markazi' },
    { title: 'Yetkazildi', time: 'Kutilmoqda' },
  ];
  return (
    <>
      <StatusBar />
      <TopBar title="Buyurtma #RV-2841" />
      <div style={{ flex: 1, overflowY: 'auto', padding: 16, display: 'flex', flexDirection: 'column' }}>
        <div style={{ background: c.accent, borderRadius: 16, padding: '15px 17px', color: '#fff' }}>
          <div style={{ fontSize: 11, opacity: .85 }}>Yetkazish kutilmoqda</div>
          <div style={{ fontFamily: serif, fontSize: 21, fontWeight: 800, marginTop: 3 }}>Ertaga, 14:00–18:00</div>
          <div style={{ fontSize: 11, opacity: .85, marginTop: 4 }}>Kuryer: Sardor · +998 90 *** 12 34</div>
        </div>
        <div style={{ flex: 1, marginTop: 18, position: 'relative', paddingLeft: 8 }}>
          <div style={{ position: 'absolute', left: 15, top: 8, bottom: 30, width: 2, background: c.line }} />
          {steps.map((s, i) => (
            <div key={i} style={{ position: 'relative', display: 'flex', gap: 14, marginBottom: 20 }}>
              <div style={{ width: 26, height: 26, borderRadius: '50%', background: s.done ? c.green : s.active ? c.accent : c.bg, border: s.done || s.active ? 'none' : `2px solid ${c.line}`, color: s.done || s.active ? '#fff' : c.muted, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, zIndex: 2, boxShadow: s.active ? `0 0 0 4px ${c.accentSoft}` : 'none' }}>
                {s.done ? <Check size={14} color="#fff" stroke={3} /> : s.active ? <Truck size={13} color="#fff" /> : <Pin size={13} />}
              </div>
              <div style={{ flex: 1 }}><div style={{ fontSize: 12.5, fontWeight: 700, color: s.active ? c.accent : s.done ? c.ink : c.muted }}>{s.title}</div><div style={{ fontSize: 10, color: c.muted, marginTop: 1 }}>{s.time}</div></div>
            </div>
          ))}
        </div>
        <button style={{ width: '100%', height: 48, border: `1.5px solid ${c.accent}`, borderRadius: 13, background: c.accentSoft, color: c.accent, fontSize: 13, fontWeight: 700, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 7 }}><Phone size={16} color={c.accent} />Kuryerga qo'ng'iroq</button>
      </div>
    </>
  );
};
