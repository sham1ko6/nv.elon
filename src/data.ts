import type { Listing } from './types';

const U = (id: string) =>
  `https://images.unsplash.com/photo-${id}?w=600&q=70&auto=format&fit=crop`;

export const listings: Listing[] = [
  { id: 'l1', img: 'Kvartira', cat: 'Uy-joy', title: 'Tashkent City — 3 xonali kvartira', priceVal: 125000, currency: '$', loc: 'Toshkent sh.', fav: true, badge: 'TOP', src: U('1560448204-e02f11c3d0e2'), specs: ['88 m²', '4 xona', '4/9 qavat', 'Yangi remont'] },
  { id: 'l2', img: 'Dron', cat: 'Agro-tex', title: 'DJI Agras T40 purkagich dron', priceVal: 16200, currency: '$', loc: 'Yunusobod', fav: false, badge: null, src: U('1473968512647-3e447244af8f') },
  { id: 'l3', img: 'Traktor', cat: 'Texnika', title: 'John Deere 6140M traktor', priceVal: 78000, currency: '$', loc: 'Jizzax', fav: false, badge: 'TOP', src: U('1530267981375-f0de937f5f13'), specs: ['2022', '320 soat', '140 o.k.', 'Diesel'] },
  { id: 'l4', img: 'Sigir', cat: 'Chorva', title: 'Golshtin zotli sutchi sigir', priceVal: 1800, currency: '$', loc: 'Samarqand', fav: false, badge: null, src: U('1500595046743-cd271d694d30') },
  { id: 'l5', img: 'MacBook', cat: 'Elektronika', title: 'MacBook Pro 16" M3 Max', priceVal: 2650, currency: '$', loc: 'Mirzo Ulug‘bek', fav: true, badge: null, src: U('1517336714731-489689fd1ca8') },
  { id: 'l6', img: 'Guruch', cat: 'Don', title: 'Alanga guruch — ulgurji 1.5 t', priceVal: 1200, currency: '$', loc: 'Xorazm', fav: false, badge: null, src: U('1586201375761-83865001e31c') },
];

export const autos: Listing[] = [
  { id: 'a1', img: 'Malibu', cat: 'Avto', title: 'Chevrolet Malibu 2', priceVal: 23500, currency: '$', loc: 'Toshkent sh.', fav: false, badge: 'TOP', src: U('1503376780353-7e6692767b70'), specs: ['2021', '42 000 km', '2.0 L', 'Avtomat'] },
  { id: 'a2', img: 'Cobalt', cat: 'Avto', title: 'Chevrolet Cobalt', priceVal: 12800, currency: '$', loc: 'Samarqand', fav: false, badge: null, src: U('1552519507-da3b142c6e3d'), specs: ['2019', '87 000 km', '1.5 L', 'Mexanika'] },
];

export const categories = [
  { id: 'uy', label: 'Uy-joy', count: '1 240', icon: 'home' },
  { id: 'el', label: 'Elektronika', count: '3 580', icon: 'tv' },
  { id: 'tex', label: 'Qishloq texnika', count: '640', icon: 'tractor' },
  { id: 'chorva', label: 'Chorvachilik', count: '910', icon: 'pin' },
  { id: 'don', label: 'Don mahsulotlari', count: '430', icon: 'wheat' },
  { id: 'sug', label: "Sug'orish", count: '210', icon: 'drop' },
  { id: 'trans', label: 'Transport', count: '1 120', icon: 'truck' },
  { id: 'ish', label: "Ish o'rinlari", count: '380', icon: 'bag' },
];

export const stories = [
  { id: 's1', label: 'Texnika', src: U('1530267981375-f0de937f5f13') },
  { id: 's2', label: 'Uy-joy', src: U('1560448204-e02f11c3d0e2') },
  { id: 's3', label: 'Chorva', src: U('1500595046743-cd271d694d30') },
  { id: 's4', label: 'Tex.', src: U('1517336714731-489689fd1ca8') },
];
