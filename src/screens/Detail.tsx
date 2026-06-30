import { useState, useEffect } from 'react';
import { c, serif, price } from '../theme';
import { Heart, Chat, Phone, Verified, Chevron, Eye, Star } from '../icons';
import { useNav, StatusBar } from '../shell';
import { api, API_ROOT } from '../api';

interface BackendImage { id: number; url: string; sort_order: number; }
interface Seller { name: string; phone: string; }
interface DetailData {
  listing: any;
  images: BackendImage[];
  seller: Seller | null;
}

// Prepend the API host to relative /uploads/ paths
const imgSrc = (url: string) =>
  url.startsWith('/') ? `${API_ROOT}${url}` : url;

// "BD" style initials from a name
const initials = (name: string) =>
  name.split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase();

export const DetailScreen = () => {
  const { params, back, navigate, fav, toggleFav } = useNav();
  const id = params.id;

  const [data, setData] = useState<DetailData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [imgIdx, setImgIdx] = useState(0);
  const [calling, setCalling] = useState(false);

  useEffect(() => {
    setLoading(true);
    setError(null);
    setImgIdx(0);
    api.getListing(id)
      .then((res: any) => setData({
        listing: res.listing,
        images: res.images ?? [],
        seller: res.seller ?? null,
      }))
      .catch((e: any) => setError(e.message))
      .finally(() => setLoading(false));
  }, [id]);

  const handleCall = async () => {
    if (calling) return;
    setCalling(true);
    try {
      const res = await api.contactListing(id);
      window.open(`tel:${res.phone}`, '_self');
    } catch {
      // logging failed — gracefully do nothing; user can still see the masked phone
    } finally {
      setCalling(false);
    }
  };

  // ── loading ────────────────────────────────────────────────────────────────
  if (loading) {
    return (
      <>
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
          <div style={{ position: 'relative', height: 280, background: '#e7d8c0' }}>
            <div style={{ position: 'absolute', top: 0, left: 0, right: 0 }}>
              <StatusBar color="#fff" />
            </div>
            <div style={{ position: 'absolute', top: 36, left: 14 }}>
              <Round onClick={back}>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                  stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"
                  strokeLinejoin="round"><path d="M15 18l-6-6 6-6" /></svg>
              </Round>
            </div>
          </div>
          <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center',
            fontSize: 12, color: c.muted, fontWeight: 600 }}>
            Yuklanmoqda…
          </div>
        </div>
      </>
    );
  }

  // ── error ──────────────────────────────────────────────────────────────────
  if (error || !data) {
    return (
      <>
        <StatusBar />
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center', padding: 24 }}>
          <div style={{ fontSize: 13, color: '#c0392b', fontWeight: 600,
            textAlign: 'center', lineHeight: 1.5, marginBottom: 16 }}>
            {error || "E'lon topilmadi"}
          </div>
          <button onClick={back} style={{ fontSize: 13, fontWeight: 700, color: c.accent,
            background: 'none', border: 'none', cursor: 'pointer' }}>
            ← Orqaga
          </button>
        </div>
      </>
    );
  }

  // ── data ───────────────────────────────────────────────────────────────────
  const { listing, images, seller } = data;
  const isFav = fav[String(listing.id)] ?? false;
  const currency = listing.currency === 'USD' ? '$' : "so'm" as const;

  const heroSrc = images[imgIdx]?.url ? imgSrc(images[imgIdx].url) : '';
  const imgCount = Math.max(images.length, 1);

  const sellerInitials = seller ? initials(seller.name) : '??';
  const sellerPhone = seller?.phone ?? '';

  return (
    <>
      <div style={{ flex: 1, overflowY: 'auto' }}>
        {/* hero image */}
        <div style={{ position: 'relative', height: 280, background: '#e7d8c0' }}>
          {heroSrc && (
            <img src={heroSrc} alt={listing.title}
              style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block' }} />
          )}
          <div style={{ position: 'absolute', top: 0, left: 0, right: 0 }}>
            <StatusBar color="#fff" />
          </div>
          <div style={{ position: 'absolute', top: 36, left: 14, right: 14,
            display: 'flex', justifyContent: 'space-between' }}>
            <Round onClick={back}>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"
                strokeLinejoin="round"><path d="M15 18l-6-6 6-6" /></svg>
            </Round>
            <Round onClick={() => toggleFav(String(listing.id))}
              color={isFav ? c.accent : c.ink}>
              <Heart size={16} fill={isFav ? c.accent : 'none'}
                color={isFav ? c.accent : c.ink} />
            </Round>
          </div>

          {/* image dots — only shown when there's more than one image */}
          {images.length > 1 && (
            <>
              <div style={{ position: 'absolute', bottom: 12, left: 0, right: 0,
                display: 'flex', gap: 5, justifyContent: 'center' }}>
                {images.map((_, i) => (
                  <span key={i} onClick={() => setImgIdx(i)} style={{
                    width: i === imgIdx ? 18 : 6, height: 4, borderRadius: 3,
                    background: i === imgIdx ? c.accent : 'rgba(255,255,255,.7)',
                    cursor: 'pointer',
                  }} />
                ))}
              </div>
              <span style={{ position: 'absolute', bottom: 10, right: 12,
                background: 'rgba(21,17,13,.6)', color: '#fff', fontSize: 10,
                fontWeight: 600, padding: '2px 8px', borderRadius: 20 }}>
                {imgIdx + 1} / {imgCount}
              </span>
            </>
          )}
        </div>

        <div style={{ padding: '14px 16px 0' }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: 9.5, fontWeight: 700, letterSpacing: '.1em',
              textTransform: 'uppercase', color: c.muted }}>
              {listing.category_id}
            </span>
            <span style={{ fontSize: 10, color: c.muted }}>
              {listing.published_at ? formatDate(listing.published_at) : ''}
            </span>
          </div>

          <div style={{ fontFamily: serif, fontSize: 24, fontWeight: 800,
            color: c.accent, marginTop: 7 }}>
            {price(Number(listing.price), currency)}
          </div>

          <button onClick={() => navigate('priceAI', { id })} style={{ display: 'inline-flex',
            alignItems: 'center', gap: 6, background: c.greenSoft,
            border: `1px solid ${c.greenLine}`, borderRadius: 10, padding: '6px 10px',
            marginTop: 8, cursor: 'pointer' }}>
            <Star size={14} fill={c.green} color={c.green} />
            <span style={{ fontSize: 10.5, fontWeight: 700, color: '#1f7a44' }}>
              AI: Narxni tahlil qilish
            </span>
            <Chevron size={13} color="#1f7a44" />
          </button>

          <div style={{ fontFamily: serif, fontSize: 16, fontWeight: 600, color: c.ink,
            lineHeight: 1.3, marginTop: 9 }}>
            {listing.title}
          </div>

          {/* views */}
          <div style={{ display: 'flex', gap: 16, marginTop: 13, paddingTop: 13,
            borderTop: `1px solid ${c.line}`, fontSize: 11, color: c.muted }}>
            <span style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
              <Eye size={13} /> {listing.views ?? 0} ko'rish
            </span>
          </div>

          {/* description */}
          {listing.description && (
            <>
              <div style={{ fontFamily: serif, fontSize: 14, fontWeight: 700,
                color: c.ink, marginTop: 15 }}>
                Tavsif
              </div>
              <div style={{ fontSize: 12, lineHeight: 1.55, color: '#5f5443', marginTop: 5 }}>
                {listing.description}
              </div>
            </>
          )}

          {/* seller card */}
          {seller && (
            <button onClick={() => navigate('sellerStore')} style={{ width: '100%',
              textAlign: 'left', display: 'flex', alignItems: 'center',
              justifyContent: 'space-between', background: c.card,
              border: `1px solid ${c.line}`, borderRadius: 14, padding: '11px 12px',
              marginTop: 14, cursor: 'pointer' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <div style={{ width: 40, height: 40, borderRadius: 12, background: c.accent,
                  color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontFamily: serif, fontWeight: 700, fontSize: 15 }}>
                  {sellerInitials}
                </div>
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
                    <span style={{ fontSize: 12.5, fontWeight: 700, color: c.ink }}>
                      {seller.name}
                    </span>
                    <Verified size={13} />
                  </div>
                  <div style={{ fontSize: 10, color: c.muted, marginTop: 1 }}>
                    {sellerPhone}
                  </div>
                </div>
              </div>
              <Chevron size={18} color={c.muted} />
            </button>
          )}

          <button onClick={() => navigate('safeDeal', { id })} style={{ width: '100%',
            display: 'flex', alignItems: 'center', gap: 10, background: c.greenSoft,
            border: `1px solid ${c.greenLine}`, borderRadius: 14, padding: '11px 12px',
            margin: '11px 0 18px', cursor: 'pointer' }}>
            <div style={{ width: 34, height: 34, borderRadius: 10, background: c.green,
              color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
              flexShrink: 0 }}>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                stroke="currentColor" strokeWidth="2" strokeLinecap="round"
                strokeLinejoin="round">
                <path d="M12 2l8 4v6c0 5-3.5 8-8 10-4.5-2-8-5-8-10V6z" />
                <path d="M9 12l2 2 4-4" />
              </svg>
            </div>
            <div style={{ flex: 1, textAlign: 'left' }}>
              <div style={{ fontSize: 12.5, fontWeight: 700, color: '#1f7a44' }}>
                Xavfsiz savdo + yetkazib berish
              </div>
              <div style={{ fontSize: 10, color: '#3d7a55' }}>Pul kafolatlangan · 2–3 kun</div>
            </div>
            <Chevron size={16} color="#1f7a44" />
          </button>
        </div>
      </div>

      {/* action bar */}
      <div style={{ flexShrink: 0, height: 72, background: c.card,
        borderTop: `1px solid ${c.line}`, display: 'flex', alignItems: 'center',
        gap: 10, padding: '0 16px' }}>
        <button onClick={() => navigate('chat')} style={{ flex: 1, height: 46,
          borderRadius: 13, border: `1.5px solid ${c.accent}`, background: 'transparent',
          color: c.accent, fontSize: 13, fontWeight: 700, display: 'flex',
          alignItems: 'center', justifyContent: 'center', gap: 7, cursor: 'pointer' }}>
          <Chat size={17} /> Xabar
        </button>
        <button onClick={handleCall} disabled={calling} style={{ flex: 1.3, height: 46,
          borderRadius: 13, border: 'none', background: calling ? '#d4a88a' : c.accent,
          color: '#fff', fontSize: 13, fontWeight: 700, display: 'flex',
          alignItems: 'center', justifyContent: 'center', gap: 7, cursor: 'pointer',
          boxShadow: '0 8px 16px rgba(194,97,59,.32)' }}>
          <Phone size={17} color="#fff" />
          {calling ? 'Yuklanmoqda…' : "Qo'ng'iroq"}
        </button>
      </div>
    </>
  );
};

function formatDate(iso: string): string {
  const d = new Date(iso);
  const now = new Date();
  const diff = now.getTime() - d.getTime();
  const days = Math.floor(diff / 86400000);
  if (days === 0) return 'Bugun';
  if (days === 1) return 'Kecha';
  return `${d.getDate()}.${String(d.getMonth() + 1).padStart(2, '0')}.${d.getFullYear()}`;
}

const Round = ({ children, onClick, color = c.ink }: {
  children: React.ReactNode; onClick?: () => void; color?: string;
}) => (
  <button onClick={onClick} style={{ width: 36, height: 36, border: 'none', borderRadius: '50%',
    background: 'rgba(255,253,249,.92)', boxShadow: '0 2px 8px rgba(74,46,22,.18)',
    display: 'flex', alignItems: 'center', justifyContent: 'center', color, cursor: 'pointer' }}>
    {children}
  </button>
);
