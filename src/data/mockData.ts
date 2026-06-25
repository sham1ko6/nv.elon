export interface Category {
  id: string;
  icon: string;
  name: string;
  count: string;
}

export interface Seller {
  id: string;
  name: string;
  initials: string;
  verified: boolean;
  rating: number;
  reviewCount: number;
}

export interface Conversation {
  id: string;
  name: string;
  avatar: string;
  lastMsg: string;
  time: string;
  unread: number;
}

export interface ChatMessage {
  id: number;
  from: 'me' | 'them';
  text: string;
  time: string;
}

export interface Listing {
  id: string;
  title: string;
  price: number;
  currency: string;
  location: string;
  categoryLabel: string;
  subcategoryLabel: string;
  condition: 'Yangi' | 'Ishlatilgan';
  sellerType: 'Shaxsiy' | 'Kompaniya';
  imageCount: number;
  date: string;
  views: number;
  isTop?: boolean;
  description: string;
  propertyChips: string[];
  seller: Seller;
}

export const CATEGORIES: Category[] = [
  { id: 'uy-joy', icon: '🏠', name: "Uy-joy", count: '1 240' },
  { id: 'qishloq-texnika', icon: '🚜', name: "Qishloq texnika", count: '640' },
  { id: 'don-mahsulotlari', icon: '🌾', name: "Don mahsulotlari", count: '430' },
  { id: 'transport', icon: '🚗', name: "Transport", count: '1 120' },
  { id: 'elektronika', icon: '📱', name: "Elektronika", count: '890' },
  { id: 'uy-jihozlari', icon: '🛋', name: "Uy jihozlari", count: '310' },
];

export const CATEGORY_CHIPS = ["Hammasi", "Uy-joy", "Elektronika", "Texnika", "Qishloq xo'jaligi"];

const sellers: Seller[] = [
  { id: 's1', name: 'AkFarm Group', initials: 'AF', verified: true, rating: 4.9, reviewCount: 132 },
  { id: 's2', name: 'Botir Tractors', initials: 'BT', verified: true, rating: 4.7, reviewCount: 58 },
  { id: 's3', name: 'Dilnoza R.', initials: 'DR', verified: false, rating: 4.5, reviewCount: 21 },
  { id: 's4', name: 'TechBazar', initials: 'TB', verified: true, rating: 4.8, reviewCount: 204 },
];

export const LISTINGS: Listing[] = [
  {
    id: '1',
    title: 'Tashkent City — zamonaviy 3 xonali kvartira',
    price: 125000,
    currency: '$',
    location: 'Toshkent sh., Yashnobod',
    categoryLabel: 'Uy-joy',
    subcategoryLabel: 'Kvartira',
    condition: 'Yangi',
    sellerType: 'Kompaniya',
    imageCount: 6,
    date: '3 kun oldin',
    views: 142,
    isTop: true,
    description:
      "Tashkent City majmuasida joylashgan zamonaviy 3 xonali kvartira. Yevro remont, mebel va texnika bilan jihozlangan. Yashash uchun barcha qulayliklar mavjud.",
    propertyChips: ['88 m²', '4 xona', '4/9 qavat', 'Yangi remont'],
    seller: sellers[0],
  },
  {
    id: '2',
    title: 'John Deere traktori, 2019 yil',
    price: 28500,
    currency: '$',
    location: "Samarqand viloyati",
    categoryLabel: 'Qishloq texnika',
    subcategoryLabel: 'Traktor',
    condition: 'Ishlatilgan',
    sellerType: 'Kompaniya',
    imageCount: 8,
    date: '1 kun oldin',
    views: 98,
    isTop: true,
    description: "John Deere 6120M, 2019 yilda ishlab chiqarilgan. Texnik holati a'lo, barcha xizmat ko'rsatish ishlari o'z vaqtida bajarilgan.",
    propertyChips: ['120 ot kuchi', '2019 yil', '3400 soat'],
    seller: sellers[1],
  },
  {
    id: '3',
    title: 'iPhone 14 Pro, 256GB',
    price: 780,
    currency: '$',
    location: 'Toshkent sh., Chilonzor',
    categoryLabel: 'Elektronika',
    subcategoryLabel: 'Telefon',
    condition: 'Ishlatilgan',
    sellerType: 'Shaxsiy',
    imageCount: 5,
    date: '5 soat oldin',
    views: 211,
    description: "iPhone 14 Pro, 256GB xotira, Deep Purple rangi. Holati juda yaxshi, barcha funksiyalari ishlaydi. Quti va zaryadlovchi mavjud.",
    propertyChips: ['256GB', 'Deep Purple', 'Garantiya bor'],
    seller: sellers[2],
  },
  {
    id: '4',
    title: 'Bug\'doy don, 1-nav, 50 tonna',
    price: 310,
    currency: '$',
    location: 'Farg\'ona viloyati',
    categoryLabel: 'Don mahsulotlari',
    subcategoryLabel: "Bug'doy",
    condition: 'Yangi',
    sellerType: 'Kompaniya',
    imageCount: 4,
    date: '2 kun oldin',
    views: 76,
    description: "Yuqori sifatli bug'doy don, 1-nav. Hosil yangi yig'ib olingan, namligi standart darajada. Yetkazib berish mumkin.",
    propertyChips: ['1-nav', '50 tonna', 'Yetkazib berish bor'],
    seller: sellers[1],
  },
  {
    id: '5',
    title: 'Chevrolet Cobalt, 2021 yil',
    price: 11200,
    currency: '$',
    location: 'Toshkent sh., Mirzo Ulug\'bek',
    categoryLabel: 'Transport',
    subcategoryLabel: 'Yengil avtomobil',
    condition: 'Ishlatilgan',
    sellerType: 'Shaxsiy',
    imageCount: 7,
    date: '6 kun oldin',
    views: 305,
    isTop: true,
    description: "Chevrolet Cobalt 2021 yil, 1-egasi, 42 000 km yurgan. Avariyaga uchramagan, doim servisda bo'lgan.",
    propertyChips: ['2021 yil', '42 000 km', '1.5L'],
    seller: sellers[2],
  },
  {
    id: '6',
    title: 'Samsung 55" QLED televizor',
    price: 540,
    currency: '$',
    location: 'Toshkent sh., Yunusobod',
    categoryLabel: 'Elektronika',
    subcategoryLabel: 'Televizor',
    condition: 'Yangi',
    sellerType: 'Kompaniya',
    imageCount: 4,
    date: '4 soat oldin',
    views: 64,
    description: "Samsung 55 dyumli QLED televizor, 4K aniqlik, Smart TV funksiyasi bilan. Qutida, ishlatilmagan.",
    propertyChips: ['55"', '4K QLED', 'Smart TV'],
    seller: sellers[3],
  },
  {
    id: '7',
    title: 'Divan burchakli, yangi',
    price: 420,
    currency: '$',
    location: 'Buxoro sh.',
    categoryLabel: 'Uy jihozlari',
    subcategoryLabel: 'Divan',
    condition: 'Yangi',
    sellerType: 'Kompaniya',
    imageCount: 5,
    date: '1 kun oldin',
    views: 41,
    description: "Zamonaviy burchakli divan, yuqori sifatli mato bilan qoplangan. O'lchamlari xonangizga moslashtirilishi mumkin.",
    propertyChips: ['Burchakli', 'Mato', 'Yotqizish funksiyasi'],
    seller: sellers[3],
  },
  {
    id: '8',
    title: 'Hovli, 6 xona, 12 sotix',
    price: 95000,
    currency: '$',
    location: 'Toshkent viloyati, Qibray',
    categoryLabel: 'Uy-joy',
    subcategoryLabel: 'Hovli',
    condition: 'Ishlatilgan',
    sellerType: 'Shaxsiy',
    imageCount: 9,
    date: '2 kun oldin',
    views: 189,
    description: "12 sotix yer maydonida joylashgan 6 xonali hovli. Gaz, suv, svet mavjud. Bog' va g'arajli.",
    propertyChips: ['12 sotix', '6 xona', "Bog' bor"],
    seller: sellers[0],
  },
];

export const CONVERSATIONS: Conversation[] = [
  { id: '1', name: 'Tashkent Realty', avatar: 'TR', lastMsg: 'Kvartira hali mavjudmi?', time: '14:23', unread: 2 },
  { id: '2', name: 'Jasur Toshmatov', avatar: 'JT', lastMsg: "Narxni pasaytira olasizmi?", time: 'Kecha', unread: 0 },
  { id: '3', name: 'Dilnoza', avatar: 'D', lastMsg: "Yaxshi, ko'rishib gaplashamiz", time: 'Dush', unread: 0 },
];

export const MOCK_MESSAGES: ChatMessage[] = [
  { id: 1, from: 'them', text: 'Salom! Kvartira hali sotuvdami?', time: '14:20' },
  { id: 2, from: 'me', text: 'Ha, hali mavjud', time: '14:21' },
  { id: 3, from: 'them', text: "Narxni ko'rib chiqish mumkinmi? 120 000 dan olsak", time: '14:22' },
  { id: 4, from: 'me', text: "Kechirasiz, narx qat'iy", time: '14:23' },
  { id: 5, from: 'them', text: 'Tushunarli. Ertaga ko\'rishsa bo\'ladimi?', time: '14:23' },
];
