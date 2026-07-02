import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart' as api;
import 'l10n/strings.dart';
import 'models.dart';

// ── State ─────────────────────────────────────────────────────

class AppState extends ChangeNotifier {
  String _lang = 'uz';
  ThemeMode _themeMode = ThemeMode.system;
  Map<String, dynamic>? _user;
  String? _token;
  String? _refreshToken;
  final List<Listing> _favorites = [];

  String get lang => _lang;
  ThemeMode get themeMode => _themeMode;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  bool get isLoggedIn => _token != null;
  List<Listing> get favorites => List.unmodifiable(_favorites);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString('lang') ?? 'uz';
    S.setLanguage(_lang);
    final tm = prefs.getString('themeMode') ?? 'system';
    _themeMode = tm == 'light'
        ? ThemeMode.light
        : tm == 'dark'
            ? ThemeMode.dark
            : ThemeMode.system;
    _token = prefs.getString('token');
    _refreshToken = prefs.getString('refreshToken');
    final userJson = prefs.getString('user');
    if (userJson != null) {
      try {
        _user = jsonDecode(userJson) as Map<String, dynamic>;
      } catch (_) {}
    }
    notifyListeners();
    if (_token != null) _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final list = await api.getMyFavorites(_token!);
      _favorites
        ..clear()
        ..addAll(list);
      notifyListeners();
    } catch (_) {
      // offline / token expired — keep whatever local state we have
    }
  }

  void setLang(String lang) async {
    _lang = lang;
    S.setLanguage(lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', lang);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    final s = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await prefs.setString('themeMode', s);
    notifyListeners();
  }

  void setAuth(String token, Map<String, dynamic> user, {String? refreshToken}) async {
    _token = token;
    _refreshToken = refreshToken;
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    if (refreshToken != null) await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('user', jsonEncode(user));
    notifyListeners();
    _loadFavorites();
  }

  void logout() async {
    _token = null;
    _refreshToken = null;
    _user = null;
    _favorites.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refreshToken');
    await prefs.remove('user');
    notifyListeners();
  }

  /// Toggles favorite state optimistically and syncs with the backend
  /// when logged in. Reverts on failure so UI never lies about state.
  void toggleFavorite(Listing listing) async {
    final wasFavorite = _favorites.any((f) => f.id == listing.id);
    if (wasFavorite) {
      _favorites.removeWhere((f) => f.id == listing.id);
    } else {
      _favorites.insert(0, listing);
    }
    notifyListeners();

    if (_token == null) return;
    try {
      if (wasFavorite) {
        await api.removeFavorite(listing.id, _token!);
      } else {
        await api.addFavorite(listing.id, _token!);
      }
    } catch (_) {
      // Revert on failure.
      if (wasFavorite) {
        _favorites.insert(0, listing);
      } else {
        _favorites.removeWhere((f) => f.id == listing.id);
      }
      notifyListeners();
    }
  }

  bool isFavorite(String id) => _favorites.any((f) => f.id == id);
}

// ── InheritedNotifier scope ───────────────────────────────────

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}
