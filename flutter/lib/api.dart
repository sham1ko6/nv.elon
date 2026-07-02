import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'models.dart';

const _base = 'https://elon-backend-jh1a.onrender.com/api';

Future<Map<String, dynamic>> apiRequest(
  String path, {
  String method = 'GET',
  Map<String, dynamic>? body,
  String? token,
}) async {
  final uri = Uri.parse('$_base$path');
  final headers = <String, String>{
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  final http.Response res;
  switch (method) {
    case 'POST':
      res = await http.post(uri, headers: headers,
          body: body != null ? jsonEncode(body) : null);
      break;
    case 'PUT':
      res = await http.put(uri, headers: headers,
          body: body != null ? jsonEncode(body) : null);
      break;
    case 'DELETE':
      res = await http.delete(uri, headers: headers);
      break;
    default:
      res = await http.get(uri, headers: headers);
  }

  Map<String, dynamic> data;
  try {
    data = res.body.isEmpty ? {} : jsonDecode(res.body) as Map<String, dynamic>;
  } catch (_) {
    data = {};
  }
  if (res.statusCode >= 400) {
    throw Exception(data['error'] ?? 'Xatolik (${res.statusCode})');
  }
  return data;
}

// ── Categories ────────────────────────────────────────────────

Future<List<Category>> getCategories() async {
  final res = await apiRequest('/categories');
  final list = res['data'] as List? ?? [];
  return list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
}

// ── Listings ──────────────────────────────────────────────────

Future<List<Listing>> getListings({
  String? category,
  String? q,
  String? token,
}) async {
  var path = '/listings';
  final params = <String, String>{};
  if (category != null && category != 'all') params['category'] = category;
  if (q != null && q.isNotEmpty) params['q'] = q;
  if (params.isNotEmpty) {
    path += '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
  }
  final res = await apiRequest(path, token: token);
  final list = res['data'] as List? ?? [];
  return list.map((e) => Listing.fromJson(e as Map<String, dynamic>)).toList();
}

Future<Listing> getListing(String id, {String? token}) async {
  final res = await apiRequest('/listings/$id', token: token);
  final listingJson = (res['listing'] ?? {}) as Map<String, dynamic>;
  final images = (res['images'] as List?) ?? [];
  final seller = res['seller'] as Map<String, dynamic>?;
  return Listing.fromJson({
    ...listingJson,
    if (images.isNotEmpty) 'image_url': (images.first as Map)['url'],
    if (seller != null) 'seller_name': seller['name'],
    if (seller != null) 'phone': seller['phone'],
  });
}

/// Creates a listing. Body must contain: title, description, price,
/// currency, category_id (int), location, contact_phone.
/// Response is `{listing, order_id?}` — `order_id` is present when the
/// user has no active subscription slot, meaning the listing is created
/// with status `pending_payment` and won't appear in the public feed
/// until that order is paid.
Future<Map<String, dynamic>> postListing(
    Map<String, dynamic> body, String token) async {
  return apiRequest('/listings', method: 'POST', body: body, token: token);
}

Future<List<Listing>> getMyListings(String token) async {
  final res = await apiRequest('/me/listings', token: token);
  final list = res['data'] as List? ?? [];
  return list.map((e) => Listing.fromJson(e as Map<String, dynamic>)).toList();
}

/// Uploads picked images for a listing. Field name must be `images`
/// (matches `upload.array('images', 10)` on the backend).
Future<List<String>> uploadListingImages(
    String listingId, List<XFile> images, String token) async {
  if (images.isEmpty) return [];
  final uri = Uri.parse('$_base/listings/$listingId/images');
  final request = http.MultipartRequest('POST', uri)
    ..headers['Authorization'] = 'Bearer $token';
  for (final img in images) {
    final bytes = await img.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes('images', bytes, filename: img.name));
  }
  final streamed = await request.send();
  final res = await http.Response.fromStream(streamed);
  final data = res.body.isEmpty ? <String, dynamic>{} : jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode >= 400) {
    throw Exception(data['error'] ?? 'Rasm yuklashda xatolik (${res.statusCode})');
  }
  return ((data['images'] as List?) ?? []).map((e) => e.toString()).toList();
}

// ── Favorites ─────────────────────────────────────────────────

Future<List<Listing>> getMyFavorites(String token) async {
  final res = await apiRequest('/me/favorites', token: token);
  final list = res['data'] as List? ?? [];
  return list.map((e) => Listing.fromJson(e as Map<String, dynamic>)).toList();
}

Future<void> addFavorite(String listingId, String token) async {
  await apiRequest('/listings/$listingId/favorite', method: 'POST', token: token);
}

Future<void> removeFavorite(String listingId, String token) async {
  await apiRequest('/listings/$listingId/favorite', method: 'DELETE', token: token);
}

// ── Auth ──────────────────────────────────────────────────────

Future<void> sendOtp(String phone) async {
  await apiRequest('/auth/otp/request', method: 'POST', body: {'phone': phone});
}

/// Response is `{user, accessToken, refreshToken}`.
Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
  return apiRequest('/auth/otp/verify',
      method: 'POST', body: {'phone': phone, 'code': code});
}
