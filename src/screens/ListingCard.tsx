import type { Listing } from '../types';
import { c, serif, sans, price } from '../theme';
import { Heart, Pin } from '../icons';
import { useNav } from '../shell';

export const ListingCard = ({ item }: { item: Listing }) => {
  const { navigate, fav, toggleFav } = useNav();
  const isFav = fav[item.id] ?? item.fav;
  return (
    <button
      onClick={() => navigate('detail', { id: item.id })}
      style={{ textAlign: 'left', background: c.card, border: `1px solid ${c.line}`, borderRadius: 16, overflow: 'hidden', display: 'flex', flexDirection: 'column', boxShadow: '0 6px 16px rgba(74,46,22,.06)', cursor: 'pointer', fontFamily: sans, padding: 0 }}
    >
      <div style={{ position: 'relative', aspectRatio: '1/1', background: '#ece1cd' }}>
        <img src={item.src} alt={item.img} loading="lazy" style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', objectFit: 'cover', display: 'block' }} />
        {item.badge && (
          <span style={{ position: 'absolute', top: 8, left: 8, background: c.accent, color: '#fff', fontSize: 8.5, fontWeight: 800, letterSpacing: '.1em', padding: '3px 7px', borderRadius: 6 }}>{item.badge}</span>
        )}
        <span
          role="button"
          onClick={(e) => { e.stopPropagation(); toggleFav(item.id); }}
          style={{ position: 'absolute', top: 7, right: 7, width: 28, height: 28, borderRadius: '50%', background: 'rgba(255,253,249,.92)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 2px 6px rgba(74,46,22,.14)', color: isFav ? c.accent : '#b9a48a' }}
        >
          <Heart size={14} fill={isFav ? c.accent : 'none'} color={isFav ? c.accent : '#b9a48a'} />
        </span>
      </div>
      <div style={{ padding: '9px 10px 11px', display: 'flex', flexDirection: 'column', gap: 3 }}>
        <div style={{ fontSize: 9, fontWeight: 700, letterSpacing: '.1em', textTransform: 'uppercase', color: c.muted }}>{item.cat}</div>
        <div style={{ fontSize: 12.5, fontWeight: 600, lineHeight: 1.3, color: c.ink, height: 32, overflow: 'hidden' }}>{item.title}</div>
        <div style={{ fontFamily: serif, fontSize: 16, fontWeight: 700, color: c.accent, marginTop: 2 }}>{price(item.priceVal, item.currency)}</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 3, fontSize: 10, color: c.muted, marginTop: 1 }}>
          <Pin size={10} /><span style={{ overflow: 'hidden', whiteSpace: 'nowrap', textOverflow: 'ellipsis' }}>{item.loc}</span>
        </div>
      </div>
    </button>
  );
};
