import 'dart:convert';
import 'package:http/http.dart' as http;
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
    if (token != null) 'Authorization': 'Bearer $token',
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

  final data = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode >= 400) throw Exception(data['error'] ?? 'Xatolik');
  return data;
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
  try {
    final res = await apiRequest(path, token: token);
    final list = res['data'] as List? ?? [];
    return list.map((e) => Listing.fromJson(e as Map<String, dynamic>)).toList();
  } catch (_) {
    return kMockListings.toList();
  }
}

Future<Listing> getListing(String id, {String? token}) async {
  try {
    final res = await apiRequest('/listings/$id', token: token);
    return Listing.fromJson((res['data'] ?? res) as Map<String, dynamic>);
  } catch (_) {
    return kMockListings.firstWhere((l) => l.id == id, orElse: () => kMockListings.first);
  }
}

Future<Map<String, dynamic>> postListing(
    Map<String, dynamic> body, String token) async {
  return apiRequest('/listings', method: 'POST', body: body, token: token);
}

Future<List<Listing>> getMyListings(String token) async {
  try {
    final res = await apiRequest('/me/listings', token: token);
    final list = res['data'] as List? ?? [];
    return list.map((e) => Listing.fromJson(e as Map<String, dynamic>)).toList();
  } catch (_) {
    return [];
  }
}

// ── Auth ──────────────────────────────────────────────────────

Future<void> sendOtp(String phone) async {
  await apiRequest('/auth/otp/send', method: 'POST', body: {'phone': phone});
}

Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
  return apiRequest('/auth/otp/verify',
      method: 'POST', body: {'phone': phone, 'code': code});
}
