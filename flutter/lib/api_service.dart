// ============================================================
// api_service.dart  –  one place for all backend communication
// ============================================================
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'https://nvelon-production.up.railway.app';

  String? _token;
  void setToken(String? t) => _token = t;
  String? get token => _token;

  Map<String, String> _headers({bool auth = false}) {
    final h = {'Content-Type': 'application/json'};
    if (auth && _token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  dynamic _decode(http.Response res) {
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final msg = (body is Map && body['error'] != null)
        ? body['error'].toString()
        : 'Server error (${res.statusCode})';
    throw ApiException(msg);
  }

  // ---------------- AUTH ----------------

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers(),
      body: jsonEncode({'name': name, 'phone': phone, 'email': email, 'password': password}),
    );
    return _decode(res) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({'login': login, 'password': password}),
    );
    return _decode(res) as Map<String, dynamic>;
  }

  // ---------------- LISTINGS ----------------

  Future<List<dynamic>> getListings() async {
    final res = await http.get(Uri.parse('$baseUrl/listings'), headers: _headers());
    final data = _decode(res) as Map<String, dynamic>;
    return data['listings'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> createListing({
    required String title,
    required String description,
    required double price,
    required String location,
    required String category,
    String? subcategory,
    String currency = 'USD',
    String? contactPhone,
    required String publishMethod,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/listings'),
      headers: _headers(auth: true),
      body: jsonEncode({
        'title': title,
        'description': description,
        'price': price,
        'location': location,
        'category': category,
        if (subcategory != null) 'subcategory': subcategory,
        'currency': currency,
        if (contactPhone != null) 'contactPhone': contactPhone,
        'publishMethod': publishMethod,
      }),
    );
    return _decode(res) as Map<String, dynamic>;
  }

  Future<void> uploadListingImage(
      int listingId, Uint8List imageBytes, String filename) async {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/listings/$listingId/images'),
    );
    if (_token != null) req.headers['Authorization'] = 'Bearer $_token';
    req.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: filename));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    _decode(res);
  }

  // ---------------- FAVORITES ----------------

  Future<List<dynamic>> getMyFavorites() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/me/favorites'),
      headers: _headers(auth: true),
    );
    final data = _decode(res) as Map<String, dynamic>;
    return (data['favorites'] ?? data['listings'] ?? []) as List<dynamic>;
  }

  Future<void> addFavorite(String listingId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/listings/$listingId/favorite'),
      headers: _headers(auth: true),
    );
    _decode(res);
  }

  Future<void> removeFavorite(String listingId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/api/listings/$listingId/favorite'),
      headers: _headers(auth: true),
    );
    _decode(res);
  }

  // ---------------- MY LISTINGS ----------------

  Future<List<dynamic>> getMyListings() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/me/listings'),
      headers: _headers(auth: true),
    );
    final data = _decode(res) as Map<String, dynamic>;
    return (data['listings'] ?? []) as List<dynamic>;
  }

  // ---------------- ORDERS ----------------

  Future<List<dynamic>> getMyOrders() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/me/orders'),
      headers: _headers(auth: true),
    );
    final data = _decode(res) as Map<String, dynamic>;
    return (data['orders'] ?? []) as List<dynamic>;
  }

  // ---------------- PROFILE ----------------

  Future<void> updateProfile({String? name, String? phone}) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/me'),
      headers: _headers(auth: true),
      body: jsonEncode({
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
      }),
    );
    _decode(res);
  }

  // ---------------- PAYMENTS ----------------

  Future<String> paymentInit(int orderId, String provider) async {
    final res = await http.post(
      Uri.parse('$baseUrl/payments/init'),
      headers: _headers(auth: true),
      body: jsonEncode({'orderId': orderId, 'provider': provider}),
    );
    final data = _decode(res) as Map<String, dynamic>;
    return data['paymentUrl'] as String;
  }

  // Debug-only route: simulate payment success without a real transaction.
  Future<void> devPay(int orderId) async {
    assert(kDebugMode, 'devPay must only be called in debug mode');
    final res = await http.post(
      Uri.parse('$baseUrl/dev/pay/$orderId'),
      headers: _headers(auth: true),
    );
    _decode(res);
  }
}
