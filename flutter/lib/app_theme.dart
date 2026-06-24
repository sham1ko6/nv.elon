// ============================================================
// app_theme.dart  –  nv.elon Light Design System
// ============================================================
// This is the single source of truth for COLORS, FONTS and shared
// look-and-feel. Every screen reads its colors from here, so changing a
// value in this file updates the whole app. The look is a clean, premium,
// OLX-style LIGHT theme with the nv.elon purple→pink gradient as the brand
// accent.
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ---- Surfaces / backgrounds ----
  static const bg = Color(0xFFF6F7F9);        // app background (soft gray)
  static const surface = Color(0xFFFFFFFF);   // cards, top bar, sheets (white)
  static const surfaceAlt = Color(0xFFF1F3F6);// input fills, image placeholders

  // ---- Brand (purple → pink gradient) ----
  static const primary = Color(0xFF8B5CF6);     // brand purple
  static const primaryDeep = Color(0xFF7C3AED); // deeper purple for emphasis
  static const pink = Color(0xFFEC4899);        // brand pink
  static const primaryGradient = [Color(0xFF8B5CF6), Color(0xFFEC4899)];

  // ---- Text ----
  static const textPrimary = Color(0xFF0F172A);   // titles, prices (near-black)
  static const textSecondary = Color(0xFF64748B); // locations, meta (gray)
  static const textHint = Color(0xFF94A3B8);      // placeholders (light gray)
  static const onPrimary = Color(0xFFFFFFFF);     // text/icons ON the gradient

  // ---- Lines & status ----
  static const border = Color(0xFFECEEF1); // hairline borders / dividers
  static const success = Color(0xFF16A34A);// "active" / verified (green)
  static const danger = Color(0xFFEF4444); // favorite heart / errors (red)
  static const star = Color(0xFFF59E0B);   // ratings / highlights (amber)

  // ---- Category accent colors (solid) ----
  static const catRealEstate = Color(0xFFF59E0B);
  static const catElectronics = Color(0xFF8B5CF6);
  static const catCommercial = Color(0xFF3B82F6);
  static const catLocal = Color(0xFF16A34A);

  // ---- Category gradients (for the round category icons) ----
  static const realEstateGradient = [Color(0xFFFBBF24), Color(0xFFF59E0B)];
  static const electronicsGradient = [Color(0xFF8B5CF6), Color(0xFFEC4899)];
  static const commercialGradient = [Color(0xFF60A5FA), Color(0xFF3B82F6)];
  static const localGradient = [Color(0xFF34D399), Color(0xFF16A34A)];
  static const secondaryGradient = [Color(0xFF3B82F6), Color(0xFF06B6D4)];
}

// A single soft shadow reused across cards so everything feels consistent.
const kCardShadow = [
  BoxShadow(color: Color(0x12101828), blurRadius: 16, offset: Offset(0, 6)),
];

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.pink,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 14),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }

  // ---- Category helpers (used by feed, cards, category screens) ----
  static List<Color> categoryGradient(String categoryId) {
    switch (categoryId) {
      case 'real-estate': return AppColors.realEstateGradient;
      case 'electronics': return AppColors.electronicsGradient;
      case 'commercial-farming': return AppColors.commercialGradient;
      case 'local-farming': return AppColors.localGradient;
      default: return AppColors.primaryGradient;
    }
  }

  static Color categoryColor(String categoryId) {
    switch (categoryId) {
      case 'real-estate': return AppColors.catRealEstate;
      case 'electronics': return AppColors.catElectronics;
      case 'commercial-farming': return AppColors.catCommercial;
      case 'local-farming': return AppColors.catLocal;
      default: return AppColors.primary;
    }
  }

  static IconData categoryIcon(String categoryId) {
    switch (categoryId) {
      case 'real-estate': return Icons.home_work_rounded;
      case 'electronics': return Icons.devices_rounded;
      case 'commercial-farming': return Icons.agriculture_rounded;
      case 'local-farming': return Icons.eco_rounded;
      default: return Icons.category_rounded;
    }
  }
}
