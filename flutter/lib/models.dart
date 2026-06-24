// ============================================================
// models.dart  –  Data models for nv.elon
// ============================================================
class AppCategory {
  final String id;
  final String name;
  final String uzName;
  final String icon; // emoji shorthand
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
  final String colorTag; // hex-ish tag for card gradient
  final int views;
  final String sellerName;
  final bool isCompany;
  final String imageUrl;
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
    this.imageUrl = '',
    this.isFavorite = false,
  });

  // Build a Listing from the JSON the backend sends. The backend uses
  // slightly different field names (e.g. "category" instead of
  // "categoryId"), so we translate them here in one place.
  factory Listing.fromJson(Map<String, dynamic> json) {
    // price arrives as a string like "125000.00"; turn it into a number.
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
      date: 'Yangi', // the feed sends a timestamp; we just label it simply
      colorTag: json['category'] ?? '',
      views: json['views'] is int ? json['views'] : 0,
      sellerName: json['seller_name'] ?? '',
      isCompany: false,
      imageUrl: json['image_url'] ?? '',
    );
  }

  Listing copyWith({bool? isFavorite}) {
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
      imageUrl: imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get formattedPrice {
    if (price >= 1000000) {
      return '\$${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '\$${(price / 1000).toStringAsFixed(0)}K';
    }
    return '\$${price.toStringAsFixed(0)}';
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
