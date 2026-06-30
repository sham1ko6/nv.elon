// ============================================================
// models.dart  –  Data models for nv.elon
// ============================================================
import 'package:intl/intl.dart';

class AppCategory {
  final String id;
  final String name;
  final String uzName;
  final String icon;
  final List<AppSubcategory> subcategories;

  const AppCategory({
    required this.id,
    required this.name,
    required this.uzName,
    required this.icon,
    this.subcategories = const [],
  });
}

class AppSubcategory {
  final String id;
  final String name;
  final String uzName;

  const AppSubcategory({
    required this.id,
    required this.name,
    required this.uzName,
  });
}

class Listing {
  final String id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final String categoryId;
  final String subcategoryId;
  final String location;
  final String phone;
  final String date;
  final String colorTag;
  final int views;
  final String sellerName;
  final bool isCompany;
  final bool isTop;
  final String imageUrl;
  final String status; // 'active' | 'pending' | 'expired'
  bool isFavorite;

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.currency = 'USD',
    required this.categoryId,
    this.subcategoryId = '',
    required this.location,
    required this.phone,
    required this.date,
    required this.colorTag,
    this.views = 0,
    required this.sellerName,
    this.isCompany = false,
    this.isTop = false,
    this.imageUrl = '',
    this.status = 'active',
    this.isFavorite = false,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    final price = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '0') ?? 0;

    return Listing(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: price,
      currency: json['currency'] ?? 'USD',
      categoryId: json['category'] ?? '',
      subcategoryId: json['subcategory'] ?? '',
      location: json['location'] ?? '',
      phone: json['contact_phone'] ?? '',
      date: _parseDate(json['created_at']?.toString()),
      colorTag: json['category'] ?? '',
      views: json['views'] is int ? json['views'] : 0,
      sellerName: json['seller_name'] ?? '',
      isCompany: json['is_company'] == true,
      isTop: json['is_top'] == true,
      imageUrl: json['image_url'] ?? '',
      status: json['status'] ?? 'active',
    );
  }

  // Parse ISO timestamp → Uzbek-friendly display string.
  static String _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'Yangi';
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return 'Yangi';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final hm = DateFormat('HH:mm').format(dt);
    if (day == today) return 'Bugun, $hm';
    if (day == today.subtract(const Duration(days: 1))) return 'Kecha, $hm';
    const months = [
      'Yan', 'Fev', 'Mar', 'Apr', 'May', 'Iyu',
      'Iyu', 'Avg', 'Sen', 'Okt', 'Noy', 'Dek',
    ];
    return '${dt.day}-${months[dt.month - 1]}';
  }

  Listing copyWith({bool? isFavorite, String? status}) {
    return Listing(
      id: id,
      title: title,
      description: description,
      price: price,
      currency: currency,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      location: location,
      phone: phone,
      date: date,
      colorTag: colorTag,
      views: views,
      sellerName: sellerName,
      isCompany: isCompany,
      isTop: isTop,
      imageUrl: imageUrl,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Full price string used everywhere in the UI.
  String get formattedPrice => Listing.formatPrice(price, currency);

  static String formatPrice(double amount, String currency) {
    if (currency == 'UZS') {
      // Russian locale gives space-thousands: 125 000
      final fmt = NumberFormat('#,##0', 'ru');
      return "${fmt.format(amount.toInt())} so'm";
    }
    // Default: USD with comma-thousands
    return NumberFormat.currency(
      symbol: '\$',
      locale: 'en_US',
      decimalDigits: 0,
    ).format(amount);
  }
}

class AppUser {
  final String name;
  final String phone;
  final String role;
  final String initials;

  const AppUser({
    required this.name,
    required this.phone,
    required this.role,
    required this.initials,
  });
}
