// ============================================================
// app_state.dart  –  app-wide state
// ============================================================
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'api_service.dart';
import 'l10n/strings.dart';
import 'mock_data.dart';

class AppState extends ChangeNotifier {
  final ApiService _api = ApiService();

  // ---------------- Initialisation ----------------

  bool _initialized = false;
  bool get initialized => _initialized;

  // Called once from main() before runApp().
  // Loads saved auth from disk, then kicks off background network fetches.
  Future<void> init() async {
    await _loadLocale();
    await _loadAuth();
    // Guest-visible feed — fire and forget so app starts immediately.
    loadListings();
    if (_isLoggedIn) {
      loadMyListings();
      _syncFavorites();
    }
    _initialized = true;
    notifyListeners();
  }

  // ---------------- Locale ----------------

  static const _kLocale = 'app_locale';
  Locale _locale = const Locale('uz');
  Locale get locale => _locale;

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocale);
    if (code != null) {
      _locale = Locale(code);
      S.setLanguage(code);
    }
  }

  Future<void> setLocale(String langCode) async {
    if (_locale.languageCode == langCode) return;
    _locale = Locale(langCode);
    S.setLanguage(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocale, langCode);
    notifyListeners();
  }

  // ---------------- Auth state ----------------

  bool _isLoggedIn = false;
  AppUser? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  AppUser? get currentUser => _currentUser;

  // ---------------- Listings ----------------

  List<Listing> _listings = [];
  List<Listing> _myListings = [];
  bool _listingsLoading = false;

  List<Listing> get listings => _listings;
  List<Listing> get myListings => _myListings;
  bool get listingsLoading => _listingsLoading;
  List<Listing> get favoriteListings =>
      _listings.where((l) => l.isFavorite).toList();

  // ---------------- Filter state ----------------

  String _searchQuery = '';
  String _selectedCategoryId = '';
  String _selectedSubcategoryId = '';

  String get searchQuery => _searchQuery;
  String get selectedCategoryId => _selectedCategoryId;
  String get selectedSubcategoryId => _selectedSubcategoryId;

  List<Listing> get filteredListings {
    return _listings.where((l) {
      final matchesSearch = _searchQuery.isEmpty ||
          l.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat =
          _selectedCategoryId.isEmpty || l.categoryId == _selectedCategoryId;
      final matchesSub = _selectedSubcategoryId.isEmpty ||
          l.subcategoryId == _selectedSubcategoryId;
      return matchesSearch && matchesCat && matchesSub;
    }).toList();
  }

  // ---------------- Auth actions ----------------

  Future<void> login(String login, String password) async {
    final data = await _api.login(login: login, password: password);
    await _applyAuth(data);
    await loadListings();
    loadMyListings();
    _syncFavorites();
  }

  Future<void> register(
      String name, String phone, String email, String password) async {
    final data = await _api.register(
        name: name, phone: phone, email: email, password: password);
    await _applyAuth(data);
    await loadListings();
  }

  Future<void> _applyAuth(Map<String, dynamic> data) async {
    _api.setToken(data['token'] as String?);
    final u = data['user'] as Map<String, dynamic>;
    final name = (u['name'] ?? '') as String;
    _currentUser = AppUser(
      name: name,
      phone: (u['phone'] ?? '') as String,
      role: (u['role'] ?? 'seller') as String,
      initials: name.isNotEmpty ? name.trim()[0].toUpperCase() : 'U',
    );
    _isLoggedIn = true;
    await _saveAuth();
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUser = null;
    _api.setToken(null);
    _listings = [];
    _myListings = [];
    await _clearAuth();
    notifyListeners();
    loadListings(); // restore guest feed
  }

  Future<void> updateProfile(String name, String phone) async {
    await _api.updateProfile(name: name, phone: phone);
    final n = name.trim();
    _currentUser = AppUser(
      name: n,
      phone: phone.trim(),
      role: _currentUser?.role ?? 'seller',
      initials: n.isNotEmpty ? n[0].toUpperCase() : 'U',
    );
    await _saveAuth();
    notifyListeners();
  }

  // ---------------- Persistence (SharedPreferences) ----------------

  static const _kToken = 'auth_token';
  static const _kUser = 'auth_user';

  Future<void> _saveAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, _api.token ?? '');
    if (_currentUser != null) {
      await prefs.setString(
          _kUser,
          jsonEncode({
            'name': _currentUser!.name,
            'phone': _currentUser!.phone,
            'role': _currentUser!.role,
          }));
    }
  }

  Future<void> _loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kToken);
    final userJson = prefs.getString(_kUser);
    if (token != null && token.isNotEmpty && userJson != null) {
      _api.setToken(token);
      final u = jsonDecode(userJson) as Map<String, dynamic>;
      final name = (u['name'] ?? '') as String;
      _currentUser = AppUser(
        name: name,
        phone: (u['phone'] ?? '') as String,
        role: (u['role'] ?? 'seller') as String,
        initials: name.isNotEmpty ? name.trim()[0].toUpperCase() : 'U',
      );
      _isLoggedIn = true;
    }
  }

  Future<void> _clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUser);
  }

  // ---------------- Listing actions ----------------

  Future<void> loadListings() async {
    _listingsLoading = true;
    notifyListeners();
    try {
      final raw = await _api.getListings();
      // Preserve in-memory favorite state across refreshes.
      final prevFavs = {for (final l in _listings) l.id: l.isFavorite};
      _listings = raw
          .map((j) => Listing.fromJson(j as Map<String, dynamic>))
          .map((l) => l.copyWith(isFavorite: prevFavs[l.id] ?? false))
          .toList();
    } catch (_) {
      // Network unavailable — fall back to bundled mock listings.
      if (_listings.isEmpty) _listings = List.of(kMockListings);
    } finally {
      _listingsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyListings() async {
    if (!_isLoggedIn) return;
    try {
      final raw = await _api.getMyListings();
      _myListings =
          raw.map((j) => Listing.fromJson(j as Map<String, dynamic>)).toList();
      notifyListeners();
    } catch (_) {
      // Graceful degradation — show empty list if endpoint not available yet.
    }
  }

  Future<Map<String, dynamic>> createAd({
    required String title,
    required String description,
    required double price,
    required String location,
    required String category,
    String? subcategory,
    String? contactPhone,
  }) async {
    final resp = await _api.createListing(
      title: title,
      description: description,
      price: price,
      location: location,
      category: category,
      subcategory: subcategory,
      contactPhone: contactPhone,
      publishMethod: 'posting_fee',
    );
    return resp['order'] as Map<String, dynamic>;
  }

  Future<void> uploadImages(
      int listingId, List<({Uint8List bytes, String name})> images) async {
    for (final img in images) {
      await _api.uploadListingImage(listingId, img.bytes, img.name);
    }
  }

  Future<String> getPaymentUrl(int orderId, String provider) =>
      _api.paymentInit(orderId, provider);

  Future<void> simulatePayment(int orderId) async {
    await _api.devPay(orderId);
    await loadListings();
  }

  Future<List<dynamic>> getMyOrders() => _api.getMyOrders();

  // ---------------- Favorites ----------------

  // Load favorites from backend and mark matching listings.
  Future<void> _syncFavorites() async {
    if (!_isLoggedIn) return;
    try {
      final raw = await _api.getMyFavorites();
      final favIds = raw.map((j) => j['id'].toString()).toSet();
      _listings =
          _listings.map((l) => l.copyWith(isFavorite: favIds.contains(l.id))).toList();
      notifyListeners();
    } catch (_) {
      // Backend may not have favorites endpoint yet — fall back to local state.
    }
  }

  void toggleFavorite(String id) async {
    final idx = _listings.indexWhere((l) => l.id == id);
    if (idx == -1) return;
    final nowFav = !_listings[idx].isFavorite;
    // Optimistic update
    _listings[idx] = _listings[idx].copyWith(isFavorite: nowFav);
    notifyListeners();
    if (_isLoggedIn) {
      try {
        if (nowFav) {
          await _api.addFavorite(id);
        } else {
          await _api.removeFavorite(id);
        }
      } catch (_) {
        // Revert on API failure
        _listings[idx] = _listings[idx].copyWith(isFavorite: !nowFav);
        notifyListeners();
      }
    }
  }

  // ---------------- Filter actions ----------------

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  // Toggle category filter; clears subcategory.
  void setCategory(String categoryId) {
    _selectedCategoryId = _selectedCategoryId == categoryId ? '' : categoryId;
    _selectedSubcategoryId = '';
    notifyListeners();
  }

  // Set category + subcategory together (from CategoriesScreen).
  void setSubcategory(String categoryId, String subcategoryId) {
    _selectedCategoryId = categoryId;
    _selectedSubcategoryId =
        _selectedSubcategoryId == subcategoryId ? '' : subcategoryId;
    notifyListeners();
  }
}

// Provider widget so any child can access AppState via context.
class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'No AppStateProvider found in context');
    return provider!.notifier!;
  }
}
