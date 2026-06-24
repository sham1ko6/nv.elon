// ============================================================
// app_state.dart  –  app-wide state, now backed by the real API
// ============================================================
// This holds the things the whole app needs to know: who is logged in,
// the list of ads, and the current search/category filter. It used to use
// fake in-memory data; now it calls the backend through ApiService.
// ============================================================
import 'package:flutter/material.dart';
import 'models.dart';
import 'api_service.dart';

class AppState extends ChangeNotifier {
  // The one object that talks to the backend.
  final ApiService _api = ApiService();

  // ---------------- Auth ----------------
  bool _isLoggedIn = false;
  AppUser? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  AppUser? get currentUser => _currentUser;

  // ---------------- Listings ----------------
  // Starts empty; filled from the backend after login (loadListings).
  List<Listing> _listings = [];
  List<Listing> get listings => _listings;
  List<Listing> get favoriteListings =>
      _listings.where((l) => l.isFavorite).toList();

  // ---------------- Filter state (still done on the device) ----------------
  String _searchQuery = '';
  String _selectedCategoryId = '';

  String get searchQuery => _searchQuery;
  String get selectedCategoryId => _selectedCategoryId;

  List<Listing> get filteredListings {
    return _listings.where((l) {
      final matchesSearch = _searchQuery.isEmpty ||
          l.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategoryId.isEmpty || l.categoryId == _selectedCategoryId;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // ---------------- Auth actions ----------------
  // Both throw ApiException (with a readable message) if the server says no;
  // the auth screen catches that and shows it to the user.

  // login = phone OR email.
  Future<void> login(String login, String password) async {
    final data = await _api.login(login: login, password: password);
    _applyAuth(data);
    await loadListings();
  }

  Future<void> register(
      String name, String phone, String email, String password) async {
    final data = await _api.register(
        name: name, phone: phone, email: email, password: password);
    _applyAuth(data);
    await loadListings();
  }

  // Save the token + user info that the server returned on login/register.
  void _applyAuth(Map<String, dynamic> data) {
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
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    _api.setToken(null);
    _listings = [];
    notifyListeners();
  }

  // ---------------- Listing actions ----------------

  // Fetch the live feed from the backend and show it.
  Future<void> loadListings() async {
    final raw = await _api.getListings();
    _listings = raw
        .map((j) => Listing.fromJson(j as Map<String, dynamic>))
        .toList();
    notifyListeners();
  }

  // Step 1 of posting: create the ad (as "pending payment") and return its
  // order, e.g. { id, amount, currency }. The ad is NOT live yet — the user
  // pays on the next screen, which is what publishes it.
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
    return (resp['order'] as Map<String, dynamic>);
  }

  // Step 2 (real): ask the backend for a Payme/Click "pay now" link.
  Future<String> getPaymentUrl(int orderId, String provider) {
    return _api.paymentInit(orderId, provider);
  }

  // Step 2 (test mode): pretend the payment succeeded so the ad goes live,
  // then refresh the feed. Used until real merchant accounts are connected.
  Future<void> simulatePayment(int orderId) async {
    await _api.devPay(orderId);
    await loadListings();
  }

  // ---------------- Filter actions ----------------
  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setCategory(String categoryId) {
    _selectedCategoryId = _selectedCategoryId == categoryId ? '' : categoryId;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final idx = _listings.indexWhere((l) => l.id == id);
    if (idx != -1) {
      _listings[idx] =
          _listings[idx].copyWith(isFavorite: !_listings[idx].isFavorite);
      notifyListeners();
    }
  }
}

// Provider widget so any child can access state via context.
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
