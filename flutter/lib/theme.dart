import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Design tokens ─────────────────────────────────────────────
const cAccent    = Color(0xFFC2613B);
const cAccentDk  = Color(0xFF9E4A2B);
const cInk       = Color(0xFF241C15);
const cMuted     = Color(0xFF9B8A73);
const cBg        = Color(0xFFF6EFE4);
const cCard      = Color(0xFFFFFDF9);
const cLine      = Color(0xFFE7DCC9);
const cAmber     = Color(0xFFE0A33E);

// Dark equivalents
const cBgDk      = Color(0xFF1A1209);
const cCardDk    = Color(0xFF2A1F14);
const cAccentDm  = Color(0xFFD4744E);
const cLineDk    = Color(0xFF3D2E1E);
const cInkDk     = Color(0xFFF0E8D8);
const cMutedDk   = Color(0xFF8A7560);

// ── Adaptive color helper ─────────────────────────────────────
class RC {
  final bool dark;
  const RC(this.dark);

  Color get bg     => dark ? cBgDk    : cBg;
  Color get card   => dark ? cCardDk  : cCard;
  Color get ink    => dark ? cInkDk   : cInk;
  Color get muted  => dark ? cMutedDk : cMuted;
  Color get line   => dark ? cLineDk  : cLine;
  Color get accent => dark ? cAccentDm : cAccent;
  Color get accentDk => dark ? cAccent : cAccentDk;

  static RC of(BuildContext context) =>
      RC(Theme.of(context).brightness == Brightness.dark);
}

// ── Text style helpers ────────────────────────────────────────
TextStyle spectral({double size = 16, FontWeight weight = FontWeight.w700, Color? color, double? height}) =>
    GoogleFonts.spectral(fontSize: size, fontWeight: weight, color: color, height: height);

TextStyle hanken({double size = 14, FontWeight weight = FontWeight.w400, Color? color, double? height}) =>
    GoogleFonts.hankenGrotesk(fontSize: size, fontWeight: weight, color: color, height: height);

// ── Themes ────────────────────────────────────────────────────
final lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: cBg,
  cardColor: cCard,
  primaryColor: cAccent,
  colorScheme: const ColorScheme.light(primary: cAccent, surface: cCard, onPrimary: Colors.white),
  appBarTheme: const AppBarTheme(
    backgroundColor: cCard,
    foregroundColor: cInk,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  textTheme: GoogleFonts.hankenGroteskTextTheme(),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: cBgDk,
  cardColor: cCardDk,
  primaryColor: cAccentDm,
  colorScheme: const ColorScheme.dark(primary: cAccentDm, surface: cCardDk, onPrimary: Colors.white),
  appBarTheme: const AppBarTheme(
    backgroundColor: cCardDk,
    foregroundColor: cInkDk,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  textTheme: GoogleFonts.hankenGroteskTextTheme(ThemeData.dark().textTheme),
);

// ── Shared decorations ────────────────────────────────────────
List<BoxShadow> warmShadow(bool dark) => [
  BoxShadow(
    color: dark
        ? Colors.black.withValues(alpha: 0.3)
        : const Color(0xFF8B6A4A).withValues(alpha: 0.10),
    blurRadius: 16,
    offset: const Offset(0, 4),
  ),
];
