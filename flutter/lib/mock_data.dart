// ============================================================
// mock_data.dart  –  Seeded / offline-fallback data for nv.elon
// ============================================================
import 'package:flutter/material.dart';
import 'models.dart';

final kCategories = const [
  AppCategory(
    id: 'real-estate',
    name: 'Real Estate',
    uzName: 'Uy-joy',
    icon: '🏠',
    subcategories: [
      AppSubcategory(id: 'apartments', name: 'Apartments',    uzName: 'Kvartiralar'),
      AppSubcategory(id: 'houses',     name: 'Houses & Villas', uzName: 'Hovli va Dacha'),
      AppSubcategory(id: 'land',       name: 'Land Plots',    uzName: 'Er uchastkalari'),
    ],
  ),
  AppCategory(
    id: 'transport',
    name: 'Transport',
    uzName: 'Transport',
    icon: '🚗',
    subcategories: [
      AppSubcategory(id: 'sedan', name: 'Sedans',        uzName: 'Sedanlar'),
      AppSubcategory(id: 'suv',   name: 'SUV / Minivan', uzName: 'SUV / Miniven'),
      AppSubcategory(id: 'truck', name: 'Trucks',        uzName: 'Yuk mashinalari'),
    ],
  ),
  AppCategory(
    id: 'electronics',
    name: 'Electronics & Tech',
    uzName: 'Elektronika',
    icon: '📱',
    subcategories: [
      AppSubcategory(id: 'phones',      name: 'Smartphones', uzName: 'Telefonlar'),
      AppSubcategory(id: 'laptops',     name: 'Laptops',     uzName: 'Noutbuklar'),
      AppSubcategory(id: 'tv',          name: 'TV & Audio',  uzName: 'Televizor'),
      AppSubcategory(id: 'accessories', name: 'Accessories', uzName: 'Aksessuarlar'),
    ],
  ),
  AppCategory(
    id: 'commercial-farming',
    name: 'Commercial Farming',
    uzName: 'Qishloq texnika',
    icon: '🚜',
    subcategories: [
      AppSubcategory(id: 'machinery',  name: 'Heavy Machinery', uzName: "Og'ir Texnika"),
      AppSubcategory(id: 'irrigation', name: 'Irrigation',      uzName: "Sug'orish"),
      AppSubcategory(id: 'wholesale',  name: 'Wholesale',       uzName: 'Ulgurji'),
    ],
  ),
  AppCategory(
    id: 'local-farming',
    name: 'Local Farming',
    uzName: 'Don / Chorva',
    icon: '🌾',
    subcategories: [
      AppSubcategory(id: 'grains',    name: 'Grains & Crops', uzName: 'Don mahsulotlari'),
      AppSubcategory(id: 'livestock', name: 'Livestock',      uzName: "Mol, qo'y, quyon"),
      AppSubcategory(id: 'poultry',   name: 'Poultry & Eggs', uzName: 'Tovuq, tuxum'),
    ],
  ),
  AppCategory(
    id: 'clothing',
    name: 'Clothing & Fashion',
    uzName: 'Kiyim',
    icon: '👕',
    subcategories: [
      AppSubcategory(id: 'women', name: 'Women',    uzName: 'Ayollar'),
      AppSubcategory(id: 'men',   name: 'Men',      uzName: 'Erkaklar'),
      AppSubcategory(id: 'kids',  name: 'Kids',     uzName: 'Bolalar'),
    ],
  ),
  AppCategory(
    id: 'furniture',
    name: 'Furniture & Home',
    uzName: 'Jihozlar',
    icon: '🛋',
    subcategories: [
      AppSubcategory(id: 'sofas',    name: 'Sofas',   uzName: 'Divan'),
      AppSubcategory(id: 'tables',   name: 'Tables',  uzName: 'Stol'),
      AppSubcategory(id: 'bedroom',  name: 'Bedroom', uzName: 'Yotoqxona'),
    ],
  ),
];

// 10 offline-fallback listings shown whenever the backend is unreachable.
final List<Listing> kMockListings = [
  // ── Uy-joy ────────────────────────────────────────────────
  Listing(
    id: 'm1',
    title: "Toshkent shahri, Yunusobod – 3 xonali kvartira",
    description:
        "10-qavat binoning 5-qavati. Umumiy maydoni 82 kv.m. To'liq ta'mirlangan, yangi mebel, konditsioner, plastik derazalar. Metro bekatiga 5 daqiqa.",
    price: 95000,
    currency: 'USD',
    categoryId: 'real-estate',
    subcategoryId: 'apartments',
    location: 'Yunusobod, Toshkent',
    phone: '+998901234567',
    date: 'Bugun, 10:30',
    colorTag: 'real-estate',
    views: 214,
    sellerName: 'Sardor Rahimov',
    imageUrl:
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=600&auto=format&fit=crop&q=80',
  ),
  Listing(
    id: 'm2',
    title: "Mirzo Ulug'bek – 2 xonali kvartira (yangi bino)",
    description:
        "Yangi qurilgan 14-qavatli binodan 2 xonali kvartira. Maydoni 58 kv.m. Hozircha bo'sh, egasi tomonidan sotiladi.",
    price: 58000,
    currency: 'USD',
    categoryId: 'real-estate',
    subcategoryId: 'apartments',
    location: "Mirzo Ulug'bek, Toshkent",
    phone: '+998912345678',
    date: 'Bugun, 09:15',
    colorTag: 'real-estate',
    views: 98,
    sellerName: 'Dilnoza Yusupova',
    imageUrl:
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&auto=format&fit=crop&q=80',
  ),
  Listing(
    id: 'm3',
    title: "Chilonzor – 4 xonali hovli uyi (200 kv.m)",
    description:
        "Chilonzor tumanida 5 sotil yer uchastkasida qurilgan 200 kv.m hovli uyi. 4 xona, 2 hammom, garaj. Yer egasidan.",
    price: 145000,
    currency: 'USD',
    categoryId: 'real-estate',
    subcategoryId: 'houses',
    location: 'Chilonzor, Toshkent',
    phone: '+998935556677',
    date: 'Kecha, 16:45',
    colorTag: 'real-estate',
    views: 187,
    sellerName: 'Nodir Xolmatov',
    imageUrl:
        'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=600&auto=format&fit=crop&q=80',
  ),

  // ── Transport ─────────────────────────────────────────────
  Listing(
    id: 'm4',
    title: "Chevrolet Cobalt 2022 – 23 000 km",
    description:
        "Cobalt LT komplektatsiyasi, 1.5L benzin, avtomat. Aksidentsiz, bitta egasi. Hamma texnik ko'rikdan o'tgan. Rang: Oq.",
    price: 13500,
    currency: 'USD',
    categoryId: 'transport',
    subcategoryId: 'sedan',
    location: 'Sergeli, Toshkent',
    phone: '+998907778899',
    date: 'Bugun, 11:00',
    colorTag: 'transport',
    views: 432,
    sellerName: 'Jasur Toshmatov',
    imageUrl:
        'https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=600&auto=format&fit=crop&q=80',
  ),
  Listing(
    id: 'm5',
    title: "Daewoo Nexia 3 – 2020 yil, 41 000 km",
    description:
        "Nexia 3 MT, 1.5L. Birinchi egasi, aksidentsiz. Ko'k rang, ichi yaxshi saqlangan.",
    price: 9200,
    currency: 'USD',
    categoryId: 'transport',
    subcategoryId: 'sedan',
    location: 'Bektemir, Toshkent',
    phone: '+998917776655',
    date: 'Kecha, 13:20',
    colorTag: 'transport',
    views: 318,
    sellerName: 'Otabek Sobirov',
    imageUrl:
        'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=600&auto=format&fit=crop&q=80',
  ),

  // ── Qishloq texnika ───────────────────────────────────────
  Listing(
    id: 'm6',
    title: "John Deere 6140M traktori – 2021 yil",
    description:
        "140 ot kuchi, GPS avtomatik boshqaruv tizimi bilan. 2800 ish soati. Rasmiy dilerda texnik ko'rik o'tkazilgan.",
    price: 82000,
    currency: 'USD',
    categoryId: 'commercial-farming',
    subcategoryId: 'machinery',
    location: 'Jizzax viloyati',
    phone: '+998934567890',
    date: 'Kecha, 08:00',
    colorTag: 'commercial-farming',
    views: 521,
    sellerName: 'Jizzax Agro Cluster',
    isCompany: true,
    imageUrl:
        'https://images.unsplash.com/photo-1530268578403-bf6e898031e4?w=600&auto=format&fit=crop&q=80',
  ),
  Listing(
    id: 'm7',
    title: "Belarus MTZ-82.1 traktori – 2019 yil",
    description:
        "Ishonchli Belarus traktori, 80 ot kuchi. Yerni haydash, ekin va yig'im-terim ishlari uchun mos.",
    price: 18500,
    currency: 'USD',
    categoryId: 'commercial-farming',
    subcategoryId: 'machinery',
    location: "Farg'ona viloyati",
    phone: '+998916543210',
    date: '25-Iyu',
    colorTag: 'commercial-farming',
    views: 274,
    sellerName: "Farg'ona Texnika",
    isCompany: true,
    imageUrl:
        'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=600&auto=format&fit=crop&q=80',
  ),

  // ── Elektronika ───────────────────────────────────────────
  Listing(
    id: 'm8',
    title: "Apple iPhone 15 Pro – 256 GB, Titan Natural",
    description:
        "Yangi, qutida. Chiqarilgan sana: 2023-yil oktyabr. Garantiya mavjud. Airbag qopqoq va zaryadlagich bilan.",
    price: 1150,
    currency: 'USD',
    categoryId: 'electronics',
    subcategoryId: 'phones',
    location: "Mirzo Ulug'bek, Toshkent",
    phone: '+998907775544',
    date: 'Bugun, 14:10',
    colorTag: 'electronics',
    views: 608,
    sellerName: 'iShop Tashkent',
    isCompany: true,
    imageUrl:
        'https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=600&auto=format&fit=crop&q=80',
  ),
  Listing(
    id: 'm9',
    title: "Samsung QLED 55\" 4K Smart TV – 2023",
    description:
        "Samsung QE55Q70C, 55 dyuym, 4K QLED. HDR10+, Tizen OS, WiFi, Bluetooth. Hech ishlatilmagan, qutida.",
    price: 780,
    currency: 'USD',
    categoryId: 'electronics',
    subcategoryId: 'tv',
    location: 'Shayxontohur, Toshkent',
    phone: '+998997778866',
    date: 'Kecha, 17:30',
    colorTag: 'electronics',
    views: 193,
    sellerName: 'Abdulloh Mirzayev',
    imageUrl:
        'https://images.unsplash.com/photo-1593305841991-05c297ba4575?w=600&auto=format&fit=crop&q=80',
  ),

  // ── Don mahsulotlari ──────────────────────────────────────
  Listing(
    id: 'm10',
    title: "Bug'doy – Yangi hosil, 20 tonna (ulgurji)",
    description:
        "Xorazm viloyatidan yangi yig'ib olingan yumshoq bug'doy. Namligi 13%, proteini 12.5%. Yuk mashinasida yetkazib beriladi.",
    price: 1800,
    currency: 'USD',
    categoryId: 'local-farming',
    subcategoryId: 'grains',
    location: 'Gurlan, Xorazm',
    phone: '+998998887766',
    date: '20-Iyu',
    colorTag: 'local-farming',
    views: 156,
    sellerName: 'Xorazm Don Agro',
    isCompany: true,
    imageUrl:
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&auto=format&fit=crop&q=80',
  ),
];

// 3 listings shown in the guest "Kabinet" tab as sample "My Listings".
final List<Listing> kGuestMyListings = [
  kMockListings[0].copyWith(), // 3-xonali kvartira
  kMockListings[3].copyWith(), // Cobalt 2022
  kMockListings[7].copyWith(), // iPhone 15
];

// Mock notification data
final kMockNotifications = [
  _MockNotif(
    title: "E'loningizga qo'ng'iroq bo'ldi",
    body: '"Yunusobod – 3 xonali kvartira" e\'loniga qiziqish bor',
    time: '5 daq oldin',
    isRead: false,
    icon: Icons.phone_rounded,
  ),
  _MockNotif(
    title: "E'loningiz faollashtirildi",
    body: '"Cobalt 2022" e\'loni muvaffaqiyatli joylashtirildi',
    time: '1 soat oldin',
    isRead: false,
    icon: Icons.check_circle_rounded,
  ),
  _MockNotif(
    title: 'Yangi xabar keldi',
    body: 'Sardor: "Narx haqida gaplasha olamizmi?"',
    time: 'Kecha, 18:30',
    isRead: true,
    icon: Icons.chat_bubble_rounded,
  ),
  _MockNotif(
    title: "E'lon muddati tugamoqda",
    body: '"iPhone 15 Pro" e\'loni 2 kundan keyin arxivga o\'tadi',
    time: 'Kecha, 09:00',
    isRead: true,
    icon: Icons.timer_rounded,
  ),
  _MockNotif(
    title: 'Maxsus taklif',
    body: 'TOP e\'longa 30% chegirma — faqat bugun!',
    time: '2 kun oldin',
    isRead: true,
    icon: Icons.star_rounded,
  ),
];

class _MockNotif {
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final IconData icon;
  const _MockNotif({
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.icon,
  });
}

// Mock conversations for messages screen
final kMockConversations = [
  _MockConv(
    name: 'Sardor Rahimov',
    avatar: 'S',
    lastMessage: 'Narx haqida gaplasha olamizmi?',
    time: '18:30',
    unread: 2,
    listingTitle: '3 xonali kvartira – Yunusobod',
  ),
  _MockConv(
    name: 'Dilnoza Yusupova',
    avatar: 'D',
    lastMessage: "Ko'rish uchun qachon bo'ladi?",
    time: 'Kecha',
    unread: 0,
    listingTitle: '2 xonali kvartira',
  ),
  _MockConv(
    name: 'Jasur Toshmatov',
    avatar: 'J',
    lastMessage: "Xayrli kech! Cobalt hali sotilmadimi?",
    time: 'Dush',
    unread: 1,
    listingTitle: 'Chevrolet Cobalt 2022',
  ),
  _MockConv(
    name: 'iShop Tashkent',
    avatar: 'i',
    lastMessage: "Ha, kafolat bor. Qachon kela olasiz?",
    time: 'Shan',
    unread: 0,
    listingTitle: 'iPhone 15 Pro 256 GB',
  ),
];

class _MockConv {
  final String name;
  final String avatar;
  final String lastMessage;
  final String time;
  final int unread;
  final String listingTitle;
  const _MockConv({
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.listingTitle,
  });
}

// Export types for use in screens
typedef MockNotif = _MockNotif;
typedef MockConv = _MockConv;
