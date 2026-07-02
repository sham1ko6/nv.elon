// ── Backend category (real /api/categories rows) ────────────────
//
// `slug` is what the backend's GET /listings?category= filter and
// POST /listings category_id resolve against — must match exactly.

class Category {
  final int id;
  final String slug;
  final String nameUz;
  final String icon;

  const Category({
    required this.id,
    required this.slug,
    required this.nameUz,
    required this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id: (j['id'] as num).toInt(),
        slug: j['slug'] ?? '',
        nameUz: j['name_uz'] ?? j['slug'] ?? '',
        icon: j['icon'] ?? '📦',
      );
}

/// Fallback categories matching the backend seed exactly (id/slug), used
/// only if GET /categories fails — keeps category_id valid even offline.
const kCategoryFallback = [
  Category(id: 1, slug: 'uy-joy',           nameUz: 'Uy-joy',           icon: '🏠'),
  Category(id: 2, slug: 'transport',        nameUz: 'Transport',        icon: '🚗'),
  Category(id: 3, slug: 'elektronika',      nameUz: 'Elektronika',      icon: '📱'),
  Category(id: 4, slug: 'qishloq-texnika',  nameUz: 'Qishloq texnika',  icon: '🚜'),
  Category(id: 5, slug: 'don-mahsulotlari', nameUz: 'Don mahsulotlari', icon: '🌾'),
  Category(id: 6, slug: 'chorvachilik',     nameUz: 'Chorvachilik',     icon: '🐄'),
  Category(id: 7, slug: 'kiyim',            nameUz: 'Kiyim',            icon: '👕'),
  Category(id: 8, slug: 'uy-jihozlari',     nameUz: 'Uy jihozlari',     icon: '🛋️'),
];

// ── Local UI category (browse chips/grid — slugs match backend) ─

class AppCategory {
  final String id; // == backend slug
  final String name;
  final String emoji;
  final String imageUrl;
  final int count;
  const AppCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.imageUrl,
    this.count = 0,
  });
}

const kCategories = [
  AppCategory(id: 'uy-joy',           name: 'Uy-joy',           emoji: '🏠', imageUrl: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=120', count: 1240),
  AppCategory(id: 'transport',        name: 'Transport',        emoji: '🚗', imageUrl: 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=120', count: 1120),
  AppCategory(id: 'elektronika',      name: 'Elektronika',      emoji: '📱', imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=120', count: 3580),
  AppCategory(id: 'qishloq-texnika',  name: 'Qishloq texnika',  emoji: '🚜', imageUrl: 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?w=120', count: 640),
  AppCategory(id: 'don-mahsulotlari', name: 'Don mahsulotlari', emoji: '🌾', imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=120', count: 430),
  AppCategory(id: 'chorvachilik',     name: 'Chorvachilik',     emoji: '🐄', imageUrl: 'https://images.unsplash.com/photo-1546445317-29f4545e9d53?w=120', count: 910),
  AppCategory(id: 'kiyim',            name: 'Kiyim',            emoji: '👕', imageUrl: 'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=120', count: 520),
  AppCategory(id: 'uy-jihozlari',     name: 'Uy jihozlari',     emoji: '🛋️', imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=120', count: 310),
];

// ── Listing model ─────────────────────────────────────────────

class Listing {
  final String id;
  final String title;
  final double price;
  final String currency;
  final String location;
  final String imageUrl;
  final String category;
  final String description;
  final String sellerName;
  final String phone;
  final int views;
  final String date;
  final bool isTop;
  final String condition;
  final bool isCompany;
  final double sellerRating;

  const Listing({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.location,
    required this.imageUrl,
    required this.category,
    required this.description,
    required this.sellerName,
    required this.phone,
    this.views = 0,
    required this.date,
    this.isTop = false,
    this.condition = 'used',
    this.isCompany = false,
    this.status = 'active',
    this.sellerRating = 4.8,
  });

  // Backend listing status (draft/pending_payment/active/expired/rejected/sold).
  final String status;

  static double _toDouble(dynamic v, double fallback) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  static int _toInt(dynamic v, int fallback) {
    if (v == null) return fallback;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  factory Listing.fromJson(Map<String, dynamic> j) => Listing(
        id: '${j['id']}',
        title: j['title'] ?? '',
        price: _toDouble(j['price'], 0),
        currency: j['currency'] ?? 'USD',
        location: j['location'] ?? '',
        imageUrl: j['image_url'] ?? j['imageUrl'] ?? '',
        category: j['category_name'] ?? j['category'] ?? '',
        description: j['description'] ?? '',
        sellerName: j['seller_name'] ?? j['user_name'] ?? '',
        phone: j['phone'] ?? j['contact_phone'] ?? '',
        views: _toInt(j['views'], 0),
        date: j['created_at'] ?? j['date'] ?? '',
        isTop: j['is_top'] == true || j['is_top'] == 1,
        condition: j['condition'] ?? 'used',
        isCompany: j['is_company'] == true || j['is_company'] == 1,
        sellerRating: _toDouble(j['seller_rating'], 4.8),
        status: j['status'] ?? 'active',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'currency': currency,
        'location': location,
        'image_url': imageUrl,
        'category': category,
        'description': description,
        'seller_name': sellerName,
        'phone': phone,
        'views': views,
        'date': date,
        'is_top': isTop,
        'condition': condition,
        'is_company': isCompany,
        'seller_rating': sellerRating,
      };

  String get formattedPrice {
    final n = price.toInt();
    final s = n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return currency == 'USD' ? '\$$s' : '$s so\'m';
  }
}

// ── Mock listings ─────────────────────────────────────────────

const kMockListings = [
  Listing(
    id: 'm1',
    title: 'John Deere 5075E traktor — 2021 yil, yaxshi holat',
    price: 28500,
    currency: 'USD',
    location: 'Andijon viloyati',
    imageUrl: 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?w=400',
    category: 'Texnika',
    description: "John Deere 5075E traktor, 2021 yil ishlab chiqarilgan. 75 ot kuchi, yaxshi texnik holatda. GPS navigatsiya, konditsioner. Ko'p yillik tajriba bilan sotilmoqda.",
    sellerName: 'Mansur Xolmatov',
    phone: '+998901234567',
    views: 1248,
    date: '2 soat oldin',
    isTop: true,
    condition: 'used',
    isCompany: false,
    sellerRating: 4.9,
  ),
  Listing(
    id: 'm2',
    title: "3 xonali kvartira — Chilonzor tumani, 9/14 qavat",
    price: 68000,
    currency: 'USD',
    location: 'Toshkent shahar',
    imageUrl: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400',
    category: 'Uy-joy',
    description: "Chilonzor tumanida 3 xonali kvartira. 9/14 qavat, lift mavjud. Umumiy maydoni 78 kv.m. Yangi ta'mirlangan, barcha mebel va texnika bilan birga.",
    sellerName: 'Gulnora Toshmatova',
    phone: '+998901234568',
    views: 3456,
    date: '5 soat oldin',
    isTop: false,
    condition: 'used',
    isCompany: false,
    sellerRating: 4.7,
  ),
  Listing(
    id: 'm3',
    title: 'Sigir, 12 bosh — Yaxshi nasldor mollar',
    price: 55000000,
    currency: 'UZS',
    location: 'Namangan viloyati',
    imageUrl: 'https://images.unsplash.com/photo-1546445317-29f4545e9d53?w=400',
    category: 'Chorva',
    description: "12 bosh nasldor sigir sotiladi. Har biri kuniga 18-22 litr sut beradi. Sog'liq guvohnomasi mavjud. Fermada ko'rish mumkin.",
    sellerName: 'Bobur Fermerchilik',
    phone: '+998901234569',
    views: 892,
    date: '1 kun oldin',
    isTop: true,
    condition: 'used',
    isCompany: true,
    sellerRating: 4.6,
  ),
  Listing(
    id: 'm4',
    title: 'Toyota Camry 2.5 — 2022 yil, 42 000 km',
    price: 34000,
    currency: 'USD',
    location: 'Toshkent shahar',
    imageUrl: 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=400',
    category: 'Avto',
    description: "Toyota Camry 2.5L, 2022 yil, 42 000 km yurgan. Oq rang, barcha opsiyalar bor. Texnik ko'rik o'tgan. Bepul sinov haydovi.",
    sellerName: 'Sardor Umarov',
    phone: '+998901234570',
    views: 5123,
    date: '2 kun oldin',
    isTop: false,
    condition: 'used',
    isCompany: false,
    sellerRating: 4.8,
  ),
  Listing(
    id: 'm5',
    title: "Bug'doy — 1 tonna, A sinf, quruq",
    price: 1800000,
    currency: 'UZS',
    location: 'Samarqand viloyati',
    imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400',
    category: 'Don',
    description: "Yillik hosil. A sinf bug'doy, namligi 13%, klekovina 28%. Omborda 120 tonna mavjud. Minimal buyurtma 1 tonna. O'z transportimiz bor.",
    sellerName: 'Agro Samarqand MChJ',
    phone: '+998901234571',
    views: 234,
    date: '3 kun oldin',
    isTop: false,
    condition: 'new',
    isCompany: true,
    sellerRating: 4.5,
  ),
  Listing(
    id: 'm6',
    title: 'iPhone 15 Pro Max 256GB — Natural Titanium',
    price: 1450,
    currency: 'USD',
    location: 'Toshkent shahar',
    imageUrl: 'https://images.unsplash.com/photo-1696426106210-b91d5d2e8f62?w=400',
    category: 'Elektronika',
    description: "iPhone 15 Pro Max 256GB, Natural Titanium. Yangi holda, original quti bilan. AppleCare+ garantiya 1 yil. Barcha acessuarlar mavjud.",
    sellerName: 'TechStore Tashkent',
    phone: '+998901234572',
    views: 7890,
    date: '3 soat oldin',
    isTop: true,
    condition: 'new',
    isCompany: true,
    sellerRating: 4.9,
  ),
  Listing(
    id: 'm7',
    title: 'MacBook Pro 14" M3 Pro — 18GB/512GB',
    price: 2800,
    currency: 'USD',
    location: 'Toshkent shahar',
    imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
    category: 'Elektronika',
    description: "MacBook Pro 14\", M3 Pro chip, 18GB unified memory, 512GB SSD. Space Black. Yangi, original. 1 yil kafolat. Faqat jiddiy xaridorlarga.",
    sellerName: 'Dilshod Nazarov',
    phone: '+998901234573',
    views: 2341,
    date: '6 soat oldin',
    isTop: false,
    condition: 'new',
    isCompany: false,
    sellerRating: 4.7,
  ),
  Listing(
    id: 'm8',
    title: "Hovli uy — 8 sotix, 4 xonali, garaj",
    price: 95000,
    currency: 'USD',
    location: "Farg'ona shahar",
    imageUrl: 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=400',
    category: 'Uy-joy',
    description: "8 sotix hovli, 4 xonali 2 qavatli uy. Garaj, qozon xona, mevali daraxtlar. Gaz, suv, kanalizatsiya. Hujjatlar tayyor, tez bitim.",
    sellerName: 'Zulfiya Mirzayeva',
    phone: '+998901234574',
    views: 1567,
    date: '4 kun oldin',
    isTop: false,
    condition: 'used',
    isCompany: false,
    sellerRating: 4.6,
  ),
  Listing(
    id: 'm9',
    title: 'MTZ-82 Belarus traktor — 2020 yil',
    price: 14500,
    currency: 'USD',
    location: 'Qashqadaryo viloyati',
    imageUrl: 'https://images.unsplash.com/photo-1592878897400-e30cbded994e?w=400',
    category: 'Texnika',
    description: "MTZ-82 Belarus traktor, 2020 yil. 80 ot kuchi, yaxshi holatda. Ko'tarmasi va disklisi bor. Yil davomida faqat 450 soat ishlagan.",
    sellerName: 'Hamid Yusupov',
    phone: '+998901234575',
    views: 678,
    date: '1 hafta oldin',
    isTop: false,
    condition: 'used',
    isCompany: false,
    sellerRating: 4.4,
  ),
  Listing(
    id: 'm10',
    title: 'Chevrolet Nexia 3 — 2023 yil, 12 000 km',
    price: 13500,
    currency: 'USD',
    location: 'Samarqand shahar',
    imageUrl: 'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=400',
    category: 'Avto',
    description: "Chevrolet Nexia 3, 2023 yil. Oq rang, 12 000 km. Klimat kontrol, elektr oynalar. Avtoijarada bo'lmagan, yakka egasi.",
    sellerName: 'Akmal Tursunov',
    phone: '+998901234576',
    views: 3245,
    date: '2 kun oldin',
    isTop: false,
    condition: 'used',
    isCompany: false,
    sellerRating: 4.8,
  ),
];
