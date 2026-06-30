import { useState, useEffect } from 'react';
import { c, serif } from '../theme';
import { Search, Home, Tv, Tractor, Pin, Wheat, Drop, Truck, Bag } from '../icons';
import { useNav, StatusBar, BottomNav } from '../shell';
import { api } from '../api';

const iconMap: Record<string, any> = {
  home: Home, tv: Tv, tractor: Tractor, pin: Pin,
  wheat: Wheat, drop: Drop, truck: Truck, bag: Bag,
};

export const CategoriesScreen = () => {
  const { navigate } = useNav();
  const [categories, setCategories] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.getCategories()
      .then((res: any) => setCategories(res.data))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  return (
    <>
      <StatusBar />
      <div style={{ flexShrink: 0, padding: '6px 16px 12px' }}>
        <div style={{ fontFamily: serif, fontSize: 22, fontWeight: 800, color: c.ink }}>
          Kategoriyalar
        </div>
        <button onClick={() => navigate('search')} style={{ width: '100%',
          display: 'flex', alignItems: 'center', gap: 9, height: 42,
          borderRadius: 13, background: c.card, border: `1px solid ${c.line}`,
          padding: '0 13px', marginTop: 11, cursor: 'pointer' }}>
          <Search size={16} color="#a8957d" />
          <span style={{ fontSize: 12.5, color: '#a8957d' }}>Kategoriya qidirish…</span>
        </button>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '0 16px 16px' }}>
        {loading ? (
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 11 }}>
            {[...Array(8)].map((_, i) => (
              <div key={i} style={{ background: c.card, border: `1px solid ${c.line}`,
                borderRadius: 16, padding: 13, height: 96,
                opacity: 0.6 + i * 0.02 }} />
            ))}
          </div>
        ) : categories.length === 0 ? (
          <div style={{ textAlign: 'center', paddingTop: 60, fontSize: 12,
            color: c.muted, fontWeight: 600 }}>
            Kategoriyalar topilmadi
          </div>
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 11 }}>
            {categories.map((cat: any) => {
              const Icon = iconMap[cat.icon ?? ''] ?? Home;
              const subCount = cat.subcategories?.length ?? 0;
              return (
                <button key={cat.id}
                  onClick={() => navigate('search', {
                    category: cat.slug,
                    catName: cat.name_uz,
                  })}
                  style={{ background: c.card, border: `1px solid ${c.line}`,
                    borderRadius: 16, padding: 13, display: 'flex',
                    flexDirection: 'column', gap: 9, cursor: 'pointer',
                    textAlign: 'left' }}>
                  <div style={{ width: 42, height: 42, borderRadius: 12,
                    background: c.accentSoft, color: c.accent,
                    display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <Icon size={22} />
                  </div>
                  <div>
                    <div style={{ fontFamily: serif, fontSize: 13.5, fontWeight: 700,
                      color: c.ink }}>
                      {cat.name_uz}
                    </div>
                    {subCount > 0 && (
                      <div style={{ fontSize: 10, color: c.muted, marginTop: 1 }}>
                        {subCount} ta bo'lim
                      </div>
                    )}
                  </div>
                </button>
              );
            })}
          </div>
        )}
      </div>
      <BottomNav />
    </>
  );
};
