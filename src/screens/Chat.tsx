import { useState, useRef, useEffect } from 'react';
import { c, serif, sans, price } from '../theme';
import { listings } from '../data';
import { Phone, Plus, Send, Verified } from '../icons';
import { useNav, StatusBar } from '../shell';

interface Msg { id: number; me: boolean; text: string; time: string; }

export const ChatScreen = () => {
  const { back } = useNav();
  const item = listings[0];
  const [msgs, setMsgs] = useState<Msg[]>([
    { id: 1, me: false, text: 'Assalomu alaykum! E\'lon hali aktualmi?', time: '14:02' },
    { id: 2, me: true, text: 'Vaalaykum assalom! Ha, aktual. Ko\'rishga kelishingiz mumkin.', time: '14:05' },
    { id: 3, me: false, text: 'Ajoyib! Ertaga soat 11:00 da bo\'ladimi?', time: '14:06' },
  ]);
  const [text, setText] = useState('');
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = scrollRef.current;
    if (el) el.scrollTop = el.scrollHeight;
  }, [msgs]);

  const send = () => {
    if (!text.trim()) return;
    const now = new Date();
    setMsgs((m) => [...m, { id: Date.now(), me: true, text: text.trim(), time: `${now.getHours()}:${String(now.getMinutes()).padStart(2, '0')}` }]);
    setText('');
  };

  return (
    <>
      <StatusBar />
      <div style={{ flexShrink: 0, padding: '4px 14px 11px', background: c.card, borderBottom: `1px solid ${c.line}`, display: 'flex', alignItems: 'center', gap: 11 }}>
        <button onClick={back} aria-label="Orqaga" style={{ width: 32, height: 32, border: 'none', borderRadius: '50%', background: c.bg, display: 'flex', alignItems: 'center', justifyContent: 'center', color: c.ink, cursor: 'pointer', flexShrink: 0 }}>
          <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M15 18l-6-6 6-6" /></svg>
        </button>
        <div style={{ width: 40, height: 40, borderRadius: 12, background: c.accent, color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: serif, fontWeight: 700, fontSize: 15, flexShrink: 0 }}>TR</div>
        <div style={{ flex: 1 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}><span style={{ fontSize: 13, fontWeight: 700, color: c.ink }}>Tashkent Realty</span><Verified size={12} /></div>
          <div style={{ fontSize: 10, color: c.green, fontWeight: 600, marginTop: 1 }}>● Onlayn</div>
        </div>
        <button style={{ width: 34, height: 34, border: 'none', borderRadius: '50%', background: c.bg, display: 'flex', alignItems: 'center', justifyContent: 'center', color: c.accent, cursor: 'pointer' }}><Phone size={16} color={c.accent} /></button>
      </div>

      <div ref={scrollRef} style={{ flex: 1, overflowY: 'auto', padding: '14px 14px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        <div style={{ textAlign: 'center' }}><span style={{ fontSize: 9.5, fontWeight: 600, color: c.muted, background: '#ece2d2', padding: '3px 10px', borderRadius: 20 }}>Bugun</span></div>
        {/* product card */}
        <div style={{ alignSelf: 'flex-start', maxWidth: '88%', background: c.card, border: `1px solid ${c.line}`, borderRadius: 14, padding: 8 }}>
          <div style={{ display: 'flex', gap: 9 }}>
            <div style={{ width: 52, height: 52, borderRadius: 9, overflow: 'hidden', flexShrink: 0 }}><img src={item.src} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} /></div>
            <div style={{ flex: 1 }}><div style={{ fontSize: 11, fontWeight: 600, color: c.ink, lineHeight: 1.3 }}>{item.title}</div><div style={{ fontFamily: serif, fontSize: 13, fontWeight: 700, color: c.accent, marginTop: 2 }}>{price(item.priceVal, item.currency)}</div></div>
          </div>
        </div>
        {msgs.map((m) => (
          <div key={m.id} style={{ alignSelf: m.me ? 'flex-end' : 'flex-start', maxWidth: '78%', background: m.me ? c.accent : c.card, border: m.me ? 'none' : `1px solid ${c.line}`, borderRadius: m.me ? '14px 4px 14px 14px' : '4px 14px 14px 14px', padding: '9px 12px', boxShadow: m.me ? '0 4px 10px rgba(194,97,59,.22)' : 'none' }}>
            <div style={{ fontSize: 12, color: m.me ? '#fff' : c.ink, lineHeight: 1.45 }}>{m.text}</div>
            <div style={{ fontSize: 9, color: m.me ? 'rgba(255,255,255,.7)' : c.muted, textAlign: 'right', marginTop: 3 }}>{m.time}</div>
          </div>
        ))}
      </div>

      <div style={{ flexShrink: 0, padding: '10px 12px', background: c.card, borderTop: `1px solid ${c.line}`, display: 'flex', alignItems: 'center', gap: 9 }}>
        <button style={{ width: 38, height: 38, border: 'none', borderRadius: '50%', background: c.bg, display: 'flex', alignItems: 'center', justifyContent: 'center', color: c.accent, cursor: 'pointer', flexShrink: 0 }}><Plus size={18} /></button>
        <input value={text} onChange={(e) => setText(e.target.value)} onKeyDown={(e) => e.key === 'Enter' && send()} placeholder="Xabar yozing…" style={{ flex: 1, height: 40, borderRadius: 20, background: c.bg, border: `1px solid ${c.line}`, padding: '0 14px', fontSize: 12.5, color: c.ink, outline: 'none', fontFamily: sans }} />
        <button onClick={send} style={{ width: 40, height: 40, border: 'none', borderRadius: '50%', background: c.accent, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', cursor: 'pointer', flexShrink: 0, boxShadow: '0 6px 14px rgba(194,97,59,.3)' }}><Send size={17} color="#fff" /></button>
      </div>
    </>
  );
};
