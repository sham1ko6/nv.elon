import { useState, useEffect } from 'react';
import { c, serif, sans } from '../theme';
import { stories } from '../data';
import { Bell, Search, Filter, Plus, ChevronDown, Pin } from '../icons';
import { useNav, StatusBar, BottomNav } from '../shell';
import { ListingCard } from './ListingCard';
import { api } from '../api';
import { mapBackendListing } from '../mapper';
import type { Listing } from '../types';

const CHIPS = ['Hammasi', 'Uy-joy', 'Elektronika', 'Texnika', 'Chorva'];

// chip label → backend category slug mapping
const CHIP_SLUG: Record<string, string | undefined> = {
  'Uy-joy':      'uy-joy',
  'Elektronika': 'elektronika',
  'Texnika':     'qishloq-texnika',
  'Chorva':      'chorvachilik',
};

export const HomeScreen = () => {
  const { navigate } = useNav();
  const [chip, setChip] = useState('Hammasi');
  const [items, setItems] = useState<Listing[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const slug = CHIP_SLUG[chip];
    const params = slug ? { category: slug } : undefined;
    setLoading(true);
    setError(null);
    api.getListings(params)
      .then((res: any) => setItems(res.data.map(mapBackendListing)))
      .catch((e: any) => setError(e.message))
      .finally(() => setLoading(false));
  }, [chip]);

  return (
    <>
      <StatusBar />
      <div style={{ flex: 1, overflowY: 'auto', display: 'flex', flexDirection: 'column' }}>
        {/* header */}
        <div style={{ padding: '8px 16px 10px', display: 'flex', alignItems: 'flex-start',
          justifyContent: 'space-between' }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
              <svg width="20" height="24" viewBox="0 0 100 120" fill="none">
                <path d="M22 112 L22 54 C22 32 34 17 50 9 C66 17 78 32 78 54 L78 112 Z" fill={c.accent} />
                <path d="M38 112 L38 60 C38 45 43 36 50 31 C57 36 62 45 62 60 L62 112 Z" fill={c.bg} />
                <circle cx="50" cy="22" r="7" fill={c.gold} />
              </svg>
              <div style={{ fontFamily: serif, fontSize: 22, fontWeight: 800,
                letterSpacing: '-.01em', color: c.ink, lineHeight: 1 }}>
                Ravoq<span style={{ color: c.accent }}>.</span>
              </div>
            </div>
            <button onClick={() => navigate('lang')} style={{ background: 'none', border: 'none',
              padding: 0, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 3,
              marginTop: 5, color: c.muted, fontSize: 11, fontWeight: 600, fontFamily: sans }}>
              <Pin size={11} /> Toshkent sh. <ChevronDown size={11} />
            </button>
          </div>
          <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
            <button onClick={() => navigate('notifications')} style={{ width: 38, height: 38,
              borderRadius: 12, background: c.card, border: `1px solid ${c.line}`,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              color: c.ink, position: 'relative', cursor: 'pointer' }}>
              <Bell size={17} />
              <span style={{ position: 'absolute', top: -3, right: -3, width: 8, height: 8,
                borderRadius: '50%', background: c.accent, border: `2px solid ${c.bg}` }} />
            </button>
            <button onClick={() => navigate('profile')} style={{ width: 38, height: 38,
              borderRadius: 12, background: c.accent, color: '#fff', border: 'none',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontFamily: serif, fontWeight: 700, fontSize: 14, cursor: 'pointer' }}>
              B
            </button>
          </div>
        </div>

        {/* search */}
        <div style={{ padding: '0 16px 12px', display: 'flex', gap: 9 }}>
          <button onClick={() => navigate('search')} style={{ flex: 1, display: 'flex',
            alignItems: 'center', gap: 9, height: 44, borderRadius: 14, background: c.card,
            border: `1px solid ${c.line}`, padding: '0 13px', cursor: 'pointer' }}>
            <Search size={16} color="#a8957d" />
            <span style={{ fontSize: 12.5, color: '#a8957d' }}>Qidiruv: traktor, iPhone…</span>
          </button>
          <button onClick={() => navigate('search', { openFilter: true })} style={{ width: 44,
            height: 44, border: 'none', borderRadius: 14, background: c.accent, color: '#fff',
            display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer',
            boxShadow: '0 6px 14px rgba(194,97,59,.28)' }}>
            <Filter size={18} />
          </button>
        </div>

        {/* stories */}
        <div style={{ display: 'flex', gap: 13, padding: '0 16px 14px', overflowX: 'auto' }}>
          <button onClick={() => navigate('post')} style={{ background: 'none', border: 'none',
            cursor: 'pointer', display: 'flex', flexDirection: 'column', alignItems: 'center',
            gap: 5, flexShrink: 0 }}>
            <div style={{ width: 58, height: 58, borderRadius: '50%',
              border: '2px dashed #cdb89a', display: 'flex', alignItems: 'center',
              justifyContent: 'center', color: c.accent }}>
              <Plus size={20} />
            </div>
            <span style={{ fontSize: 9.5, fontWeight: 600, color: c.muted }}>Siz</span>
          </button>
          {stories.map((s) => (
            <button key={s.id} onClick={() => navigate('story', { src: s.src, label: s.label })}
              style={{ background: 'none', border: 'none', cursor: 'pointer', display: 'flex',
                flexDirection: 'column', alignItems: 'center', gap: 5, flexShrink: 0 }}>
              <div style={{ width: 60, height: 60, borderRadius: '50%', padding: 2.5,
                background: `linear-gradient(135deg,${c.gold},${c.accent})` }}>
                <div style={{ width: '100%', height: '100%', borderRadius: '50%',
                  border: `2px solid ${c.bg}`, overflow: 'hidden' }}>
                  <img src={s.src} alt={s.label}
                    style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block' }} />
                </div>
              </div>
              <span style={{ fontSize: 9.5, fontWeight: 600, color: c.ink }}>{s.label}</span>
            </button>
          ))}
        </div>

        {/* chips */}
        <div style={{ display: 'flex', gap: 7, padding: '0 16px 13px', overflowX: 'auto' }}>
          {CHIPS.map((ch) => {
            const on = ch === chip;
            return (
              <button key={ch} onClick={() => setChip(ch)} style={{ whiteSpace: 'nowrap',
                fontSize: 11.5, fontWeight: on ? 700 : 600, padding: '7px 13px',
                borderRadius: 20, background: on ? c.accent : c.card,
                border: on ? 'none' : `1px solid ${c.line}`,
                color: on ? '#fff' : c.ink, cursor: 'pointer' }}>
                {ch}
              </button>
            );
          })}
        </div>

        {/* hero banner */}
        <div style={{ margin: '0 16px 15px', borderRadius: 20, background: c.accent,
          color: '#fff', padding: '17px 19px', position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', right: -26, top: -26, width: 120, height: 120,
            borderRadius: '50%', background: 'rgba(255,255,255,.1)' }} />
          <div style={{ fontFamily: serif, fontSize: 20, fontWeight: 700, lineHeight: 1.15,
            position: 'relative' }}>
            Yerdan bozorga,<br />bir qadamda.
          </div>
          <div style={{ fontSize: 11, opacity: .86, marginTop: 7, maxWidth: 185,
            lineHeight: 1.45, position: 'relative' }}>
            Texnika, chorva va uy-joy e'lonlari — ishonchli sotuvchilardan.
          </div>
          <button onClick={() => navigate('post')} style={{ marginTop: 13, background: '#fff',
            color: c.accent, fontSize: 11.5, fontWeight: 800, border: 'none', borderRadius: 10,
            padding: '8px 15px', cursor: 'pointer', position: 'relative' }}>
            E'lon berish
          </button>
        </div>

        {/* listing grid */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline',
          padding: '0 16px 11px' }}>
          <div style={{ fontFamily: serif, fontSize: 16.5, fontWeight: 700, color: c.ink }}>
            Tavsiya etiladi
          </div>
          <button onClick={() => navigate('search')} style={{ background: 'none', border: 'none',
            fontSize: 11.5, fontWeight: 700, color: c.accent, cursor: 'pointer' }}>
            Barchasi →
          </button>
        </div>

        <div style={{ padding: '0 16px 18px' }}>
          {loading ? (
            <div style={{ textAlign: 'center', padding: '32px 0', fontSize: 12,
              color: c.muted, fontWeight: 600 }}>
              Yuklanmoqda…
            </div>
          ) : error ? (
            <div style={{ textAlign: 'center', padding: '32px 16px' }}>
              <div style={{ fontSize: 12, color: '#c0392b', fontWeight: 600, lineHeight: 1.5 }}>
                {error}
              </div>
              <button onClick={() => setChip(chip)} style={{ marginTop: 12, fontSize: 12,
                fontWeight: 700, color: c.accent, background: 'none', border: 'none',
                cursor: 'pointer' }}>
                Qayta urinish
              </button>
            </div>
          ) : items.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '32px 0', fontSize: 12,
              color: c.muted, fontWeight: 600 }}>
              E'lonlar topilmadi
            </div>
          ) : (
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
              {items.map((it) => <ListingCard key={it.id} item={it} />)}
            </div>
          )}
        </div>
      </div>
      <BottomNav />
    </>
  );
};
