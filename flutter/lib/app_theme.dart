// ============================================================
// app_theme.dart  –  nv.elon Design System (Terracotta Edition)
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Brand: terracotta ─────────────────────────────────────
  static const primary      = Color(0xFFC2613B);
  static const primaryDark  = Color(0xFFA84E2A);
  static const primaryLight = Color(0xFFD4795A);
  static const primaryGradient = [Color(0xFFC2613B), Color(0xFFA84E2A)];

  // ── Amber – TOP badge ─────────────────────────────────────
  static const amber = Color(0xFFE0A33E);
  static const amberGradient = [Color(0xFFE8B04A), Color(0xFFCA8A04)];

  // ── Surfaces ──────────────────────────────────────────────
  static const bg         = Color(0xFFF6EFE4); // warm cream
  static const surface    = Color(0xFFFFFDF9); // card background
  static const surfaceAlt = Color(0xFFEFE8DC); // input fill / alt surface

  // ── Text ──────────────────────────────────────────────────
  static const textPrimary   = Color(0xFF241C15); // near-black warm
  static const textSecondary = Color(0xFF9B8A73); // muted brown
  static const textHint      = Color(0xFFB8A898); // placeholder
  static const onPrimary     = Color(0xFFFFFFFF);

  // ── Lines ─────────────────────────────────────────────────
  static const border = Color(0xFFE7DCC9);

  // ── Status ────────────────────────────────────────────────
  static const success = Color(0xFF16A34A);
  static const danger  = Color(0xFFEF4444);
  static const star    = Color(0xFFF59E0B);

  // ── Category accent colors ────────────────────────────────
  static const catRealEstate  = Color(0xFFE0A33E);
  static const catTransport   = Color(0xFFEF4444);
  static const catElectronics = Color(0xFF8B5CF6);
  static const catCommercial  = Color(0xFF3B82F6);
  static const catLocal       = Color(0xFF16A34A);
  static const catClothing    = Color(0xFFEC4899);
  static const catFurniture   = Color(0xFF7C3AED);

  // ── Category gradients ────────────────────────────────────
  static const realEstateGradient  = [Color(0xFFFCD34D), Color(0xFFE0A33E)];
  static const transportGradient   = [Color(0xFFFCA5A5), Color(0xFFEF4444)];
  static const electronicsGradient = [Color(0xFFC4B5FD), Color(0xFF8B5CF6)];
  static const commercialGradient  = [Color(0xFF93C5FD), Color(0xFF3B82F6)];
  static const localGradient       = [Color(0xFF86EFAC), Color(0xFF16A34A)];
  static const clothingGradient    = [Color(0xFFF9A8D4), Color(0xFFEC4899)];
  static const furnitureGradient   = [Color(0xFFC4B5FD), Color(0xFF7C3AED)];
}

const kCardShadow = [
  BoxShadow(color: Color(0x12241C15), blurRadius: 10, offset: Offset(0, 4)),
];

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.amber,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w700,
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
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
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
        hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
        labelStyle: GoogleFonts.inter(
          color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500,
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

  // ── Category helpers ──────────────────────────────────────
  static List<Color> categoryGradient(String categoryId) {
    switch (categoryId) {
      case 'real-estate':        return AppColors.realEstateGradient;
      case 'transport':          return AppColors.transportGradient;
      case 'electronics':        return AppColors.electronicsGradient;
      case 'commercial-farming': return AppColors.commercialGradient;
      case 'local-farming':      return AppColors.localGradient;
      case 'clothing':           return AppColors.clothingGradient;
      case 'furniture':          return AppColors.furnitureGradient;
      default:                   return AppColors.primaryGradient;
    }
  }

  static Color categoryColor(String categoryId) {
    switch (categoryId) {
      case 'real-estate':        return AppColors.catRealEstate;
      case 'transport':          return AppColors.catTransport;
      case 'electronics':        return AppColors.catElectronics;
      case 'commercial-farming': return AppColors.catCommercial;
      case 'local-farming':      return AppColors.catLocal;
      case 'clothing':           return AppColors.catClothing;
      case 'furniture':          return AppColors.catFurniture;
      default:                   return AppColors.primary;
    }
  }

  static IconData categoryIcon(String categoryId) {
    switch (categoryId) {
      case 'real-estate':        return Icons.home_work_rounded;
      case 'transport':          return Icons.directions_car_rounded;
      case 'electronics':        return Icons.devices_rounded;
      case 'commercial-farming': return Icons.agriculture_rounded;
      case 'local-farming':      return Icons.eco_rounded;
      case 'clothing':           return Icons.checkroom_rounded;
      case 'furniture':          return Icons.weekend_rounded;
      default:                   return Icons.category_rounded;
    }
  }
}
