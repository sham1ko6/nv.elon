import React, { useState, useEffect, useRef } from 'react';
import { c, serif, sans, price } from '../theme';
import { Search as SearchIcon, Close, ChevronDown } from '../icons';
import { useNav, StatusBar } from '../shell';
import { api } from '../api';
import { mapBackendListing } from '../mapper';
import type { Listing } from '../types';

export const SearchScreen = () => {
  const { back, navigate, params } = useNav();
  const [q, setQ] = useState<string>(params.q || '');
  const [filter, setFilter] = useState<boolean>(!!params.openFilter);
  const [catSlug, setCatSlug] = useState<string>(params.category || '');
  const [catName, setCatName] = useState<string>(params.catName || '');
  const [items, setItems] = useState<Listing[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const clearCat = () => { setCatSlug(''); setCatName(''); };

  // debounced fetch — fires 400 ms after the user stops typing or changes category
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => {
    if (timerRef.current) clearTimeout(timerRef.current);
    timerRef.current = setTimeout(() => {
      const p: Record<string, string> = {};
      if (q.trim()) p.q = q.trim();
      if (catSlug) p.category = catSlug;
      setLoading(true);
      setError(null);
      api.getListings(p)
        .then((res: any) => {
          setItems(res.data.map(mapBackendListing));
          setTotal(res.total);
        })
        .catch((e: any) => setError(e.message))
        .finally(() => setLoading(false));
    }, 400);

    return () => { if (timerRef.current) clearTimeout(timerRef.current); };
  }, [q, catSlug]);

  const countLabel = loading ? '…' : String(total);

  return (
    <>
      <StatusBar />
      <div style={{ flexShrink: 0, padding: '4px 14px 11px', background: c.card,
        borderBottom: `1px solid ${c.line}` }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <button onClick={back} aria-label="Orqaga" style={{ width: 34, height: 34,
            border: 'none', borderRadius: '50%', background: c.bg,
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            color: c.ink, cursor: 'pointer', flexShrink: 0 }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
              strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M15 18l-6-6 6-6" />
            </svg>
          </button>
          <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 8, height: 40,
            borderRadius: 12, background: c.bg, border: `1px solid ${c.line}`,
            padding: '0 11px' }}>
            <SearchIcon size={15} color={c.muted} />
            <input
              autoFocus
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder="Qidiruv…"
              style={{ flex: 1, border: 'none', background: 'transparent', outline: 'none',
                fontSize: 13, fontWeight: 600, color: c.ink, fontFamily: sans }}
            />
            {q && (
              <button onClick={() => setQ('')} style={{ background: 'none', border: 'none',
                cursor: 'pointer', color: c.muted, display: 'flex' }}>
                <Close size={15} />
              </button>
            )}
          </div>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          marginTop: 11 }}>
          <span style={{ fontSize: 11.5, fontWeight: 600, color: c.muted }}>
            <b style={{ color: c.ink }}>{countLabel}</b> ta natija
          </span>
          <button onClick={() => setFilter(true)} style={{ background: 'none', border: 'none',
            cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 5,
            fontSize: 11.5, fontWeight: 700, color: c.ink }}>
            Filtr · Eng yangi <ChevronDown size={12} />
          </button>
        </div>

        {/* active category chip */}
        {catName && (
          <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginTop: 9 }}>
            <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6,
              background: c.accentSoft, border: `1px solid ${c.accent}`,
              borderRadius: 20, padding: '5px 11px' }}>
              <span style={{ fontSize: 11, fontWeight: 700, color: c.accent }}>
                {catName}
              </span>
              <button onClick={clearCat} style={{ background: 'none', border: 'none',
                color: c.accent, cursor: 'pointer', padding: 0, fontSize: 13,
                lineHeight: 1, display: 'flex', alignItems: 'center' }}>
                ×
              </button>
            </div>
          </div>
        )}
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '12px 14px',
        display: 'flex', flexDirection: 'column', gap: 11 }}>
        {error ? (
          <div style={{ textAlign: 'center', paddingTop: 48, fontSize: 12,
            color: '#c0392b', fontWeight: 600, lineHeight: 1.5 }}>
            {error}
          </div>
        ) : items.length === 0 && !loading ? (
          <div style={{ textAlign: 'center', paddingTop: 48, fontSize: 12,
            color: c.muted, fontWeight: 600 }}>
            {q.trim() ? `"${q.trim()}" bo'yicha e'lon topilmadi` : 'Qidiruv boshlash uchun yozing'}
          </div>
        ) : (
          items.map((l) => (
            <button key={l.id} onClick={() => navigate('detail', { id: l.id })}
              style={{ display: 'flex', gap: 11, background: c.card,
                border: `1px solid ${c.line}`, borderRadius: 14, padding: 9,
                cursor: 'pointer', textAlign: 'left' }}>
              <div style={{ width: 70, height: 70, borderRadius: 10, flexShrink: 0,
                overflow: 'hidden', background: '#ece1cd' }}>
                {l.src && (
                  <img src={l.src} alt="" loading="lazy"
                    style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block' }} />
                )}
              </div>
              <div style={{ flex: 1, display: 'flex', flexDirection: 'column',
                justifyContent: 'center' }}>
                <div style={{ fontSize: 12.5, fontWeight: 600, color: c.ink, lineHeight: 1.3 }}>
                  {l.title}
                </div>
                <div style={{ fontFamily: serif, fontSize: 15, fontWeight: 700,
                  color: c.accent, marginTop: 4 }}>
                  {price(l.priceVal, l.currency)}
                </div>
                <div style={{ fontSize: 10, color: c.muted, marginTop: 3 }}>
                  {l.loc}
                  {l.createdAt ? ` · ${formatAge(l.createdAt)}` : ''}
                </div>
              </div>
            </button>
          ))
        )}

        {loading && (
          <div style={{ textAlign: 'center', padding: '24px 0', fontSize: 12,
            color: c.muted, fontWeight: 600 }}>
            Yuklanmoqda…
          </div>
        )}
      </div>

      {filter && <FilterSheet count={total} onClose={() => setFilter(false)} />}
    </>
  );
};

function formatAge(iso: string): string {
  const diff = Date.now() - new Date(iso).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 60) return mins <= 1 ? 'Hozirgina' : `${mins} daqiqa oldin`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs} soat oldin`;
  const days = Math.floor(hrs / 24);
  return days === 1 ? 'Kecha' : `${days} kun oldin`;
}

// ── Filter sheet (UI-only — filter values wired in a later step) ─────────────

const FilterSheet = ({ count, onClose }: { count: number; onClose: () => void }) => {
  const [cond, setCond] = useState('Hammasi');
  const [seller, setSeller] = useState('Kompaniya');
  return (
    <div onClick={onClose} style={{ position: 'absolute', inset: 0,
      background: 'rgba(21,17,13,.32)', zIndex: 25, display: 'flex', alignItems: 'flex-end' }}>
      <div onClick={(e) => e.stopPropagation()} style={{ width: '100%', background: c.bg,
        borderRadius: '24px 24px 0 0', boxShadow: '0 -12px 30px rgba(40,24,10,.18)',
        padding: '10px 18px 18px', maxHeight: '78%', overflowY: 'auto' }}>
        <div style={{ width: 38, height: 4, borderRadius: 3, background: '#d8cab3',
          margin: '2px auto 12px' }} />
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          marginBottom: 14 }}>
          <span style={{ fontFamily: serif, fontSize: 18, fontWeight: 700, color: c.ink }}>
            Filtrlar
          </span>
          <button style={{ background: 'none', border: 'none', fontSize: 11.5,
            fontWeight: 700, color: c.accent, cursor: 'pointer' }}>
            Tozalash
          </button>
        </div>
        <Label>Narx oralig'i, $</Label>
        <div style={{ display: 'flex', alignItems: 'center', gap: 9 }}>
          <Box>10 000</Box>
          <span style={{ width: 10, height: 1.5, background: c.muted }} />
          <Box>90 000</Box>
        </div>
        <Label>Holati</Label>
        <Segmented options={['Hammasi', 'Yangi', 'Ishlatilgan']} value={cond} onChange={setCond} />
        <Label>Sotuvchi turi</Label>
        <div style={{ display: 'flex', gap: 8 }}>
          {['Shaxsiy', 'Kompaniya'].map((s) => {
            const on = s === seller;
            return (
              <button key={s} onClick={() => setSeller(s)} style={{ fontSize: 12,
                fontWeight: on ? 700 : 600, color: on ? c.accent : c.ink,
                background: on ? c.accentSoft : c.card,
                border: `1px solid ${on ? c.accent : c.line}`, borderRadius: 20,
                padding: '7px 15px', cursor: 'pointer' }}>
                {s}
              </button>
            );
          })}
        </div>
        <button onClick={onClose} style={{ marginTop: 18, width: '100%', height: 50,
          border: 'none', borderRadius: 14, background: c.accent, color: '#fff',
          fontSize: 13.5, fontWeight: 700, cursor: 'pointer',
          boxShadow: '0 10px 18px rgba(194,97,59,.32)' }}>
          {count} ta natijani ko'rsatish
        </button>
      </div>
    </div>
  );
};

const Label = ({ children }: { children: React.ReactNode }) => (
  <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: '.04em',
    textTransform: 'uppercase', color: c.muted, margin: '16px 0 8px' }}>
    {children}
  </div>
);
const Box = ({ children }: { children: React.ReactNode }) => (
  <div style={{ flex: 1, height: 40, borderRadius: 11, background: c.card,
    border: `1px solid ${c.line}`, display: 'flex', alignItems: 'center',
    padding: '0 11px', fontSize: 12.5, color: c.ink, fontWeight: 600 }}>
    {children}
  </div>
);
const Segmented = ({ options, value, onChange }: {
  options: string[]; value: string; onChange: (v: string) => void;
}) => (
  <div style={{ display: 'flex', background: c.card, border: `1px solid ${c.line}`,
    borderRadius: 11, padding: 3 }}>
    {options.map((o) => {
      const on = o === value;
      return (
        <button key={o} onClick={() => onChange(o)} style={{ flex: 1, textAlign: 'center',
          fontSize: 12, fontWeight: on ? 700 : 600,
          color: on ? '#fff' : c.muted,
          background: on ? c.accent : 'transparent',
          border: 'none', borderRadius: 8, padding: '7px 0', cursor: 'pointer' }}>
          {o}
        </button>
      );
    })}
  </div>
);
