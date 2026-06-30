import type { Listing } from './types';

export function mapBackendListing(b: any): Listing {
  return {
    id: String(b.id),
    img: b.images?.[0]?.url || '',
    cat: b.category_slug || String(b.category_id),
    title: b.title,
    priceVal: Number(b.price),
    currency: b.currency === 'USD' ? '$' : "so'm",
    loc: b.location,
    fav: false,
    badge: b.is_top ? 'TOP' : null,
    src: b.images?.[0]?.url || '',
    specs: [],
    description: b.description,
    sellerName: b.seller_name || 'N/A',
    sellerPhone: b.contact_phone,
    createdAt: b.created_at,
  };
}

export function mapBackendCategory(c: any) {
  return {
    id: c.slug,
    name: c.name_uz,
    icon: c.icon,
    count: 0,
  };
}
