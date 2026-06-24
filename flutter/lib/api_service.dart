// ============================================================
// api_service.dart  –  one place for all backend communication
// ============================================================
// This file is the ONLY part of the app that knows how to talk to the
// backend server. Every screen goes through here. If the server address
// ever changes, you only edit it in one spot (baseUrl below).
// ============================================================
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  // ---------------------------------------------------------
  // The backend address.
  //   • Running the app in Chrome or Linux desktop  -> localhost works.
  //   • Running on an Android EMULATOR              -> use 10.0.2.2
  //   • Running on a real phone                     -> use your PC's
  //     network IP, e.g. http://192.168.1.50:4000
  // For now we test in Chrome, so localhost is correct.
  // ---------------------------------------------------------
  static const String baseUrl = 'http://localhost:4000';

  // After login/register we keep the token here and send it on requests
  // that require being logged in (like posting an ad).
  String? _token;
  void setToken(String? t) => _token = t;

  Map<String, String> _headers({bool auth = false}) {
    final h = {'Content-Type': 'application/json'};
    if (auth && _token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  // A small helper that reads the server's reply. If the server returned
  // an error, it pulls out the human-readable message and throws it so the
  // screen can show it to the user.
  dynamic _decode(http.Response res) {
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final msg = (body is Map && body['error'] != null)
        ? body['error'].toString()
        : 'Server error (${res.statusCode})';
    throw ApiException(msg);
  }

  // ---------------- AUTH ----------------

  // Returns { token, user }
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

  // login = phone OR email. Returns { token, user }
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

  // Returns the raw list of listing maps from the feed.
  Future<List<dynamic>> getListings() async {
    final res = await http.get(Uri.parse('$baseUrl/listings'), headers: _headers());
    final data = _decode(res) as Map<String, dynamic>;
    return data['listings'] as List<dynamic>;
  }

  // Create an ad. Returns the full server reply (includes the order id
  // when paying by posting fee). Requires being logged in.
  Future<Map<String, dynamic>> createListing({
    required String title,
    required String description,
    required double price,
    required String location,
    required String category,
    String? subcategory,
    String currency = 'USD',
    String? contactPhone,
    required String publishMethod, // 'posting_fee' or 'subscription'
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

  // ---------------- PAYMENTS ----------------
  // Ask the backend for a "pay now" link for an order, using the chosen
  // provider ('payme' or 'click'). Returns the URL to open in a browser.
  Future<String> paymentInit(int orderId, String provider) async {
    final res = await http.post(
      Uri.parse('$baseUrl/payments/init'),
      headers: _headers(auth: true),
      body: jsonEncode({'orderId': orderId, 'provider': provider}),
    );
    final data = _decode(res) as Map<String, dynamic>;
    return data['paymentUrl'] as String;
  }

  // ---------------- DEV-ONLY (fake payment) ----------------
  // Mirrors the backend's dev route that pretends an order was paid, so
  // the new ad becomes active. Replaced by real Payme/Click in Phase 3.
  Future<void> devPay(int orderId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/dev/pay/$orderId'),
      headers: _headers(auth: true),
    );
    _decode(res);
  }
}
