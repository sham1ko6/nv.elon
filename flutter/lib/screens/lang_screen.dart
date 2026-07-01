import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_state.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../widgets/ravoq_shield.dart';
import 'onboarding_screen.dart';

class LangScreen extends StatefulWidget {
  const LangScreen({super.key});

  @override
  State<LangScreen> createState() => _LangScreenState();
}

class _LangScreenState extends State<LangScreen> {
  String _lang = 'uz';
  String _currency = 'USD';

  static const _langs = [
    ('uz', "O'zbek"),
    ('ru', 'Русский'),
    ('en', 'English'),
  ];

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return Scaffold(
      backgroundColor: rc.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Logo
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RavoqShield(size: 28, color: cAccent, letterColor: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Ravoq.',
                      style: GoogleFonts.spectral(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: cAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                S.get('selectLang'),
                style: GoogleFonts.spectral(
                    fontSize: 24, fontWeight: FontWeight.w700, color: rc.ink),
              ),
              const SizedBox(height: 18),
              // Language list
              ...(_langs.map((l) => _LangTile(
                    code: l.$1,
                    label: l.$2,
                    selected: _lang == l.$1,
                    onTap: () {
                      setState(() => _lang = l.$1);
                      S.setLanguage(l.$1);
                    },
                    rc: rc,
                  ))),
              const SizedBox(height: 32),
              // Currency
              Text(
                S.get('selectCurrency'),
                style: GoogleFonts.hankenGrotesk(
                    fontSize: 14, fontWeight: FontWeight.w600, color: rc.ink),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _CurrChip(
                    label: 'USD',
                    selected: _currency == 'USD',
                    onTap: () => setState(() => _currency = 'USD'),
                    rc: rc,
                  ),
                  const SizedBox(width: 10),
                  _CurrChip(
                    label: "So'm",
                    selected: _currency == 'UZS',
                    onTap: () => setState(() => _currency = 'UZS'),
                    rc: rc,
                  ),
                ],
              ),
              const Spacer(),
              // Continue button
              _ContinueBtn(
                label: S.get('continue'),
                onTap: _continue,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _continue() async {
    final state = AppStateScope.of(context);
    state.setLang(_lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', _currency);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String code, label;
  final bool selected;
  final VoidCallback onTap;
  final RC rc;
  const _LangTile(
      {required this.code,
      required this.label,
      required this.selected,
      required this.onTap,
      required this.rc});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 56,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: rc.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? cAccent : rc.line,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected ? warmShadow(rc.dark) : [],
        ),
        child: Row(
          children: [
            Text(
              {'uz': '🇺🇿', 'ru': '🇷🇺', 'en': '🇬🇧'}[code] ?? '🌐',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected ? cAccent : rc.ink,
              ),
            ),
            const Spacer(),
            if (selected)
              Icon(Icons.check_circle_rounded, color: cAccent, size: 20),
          ],
        ),
      ),
    );
  }
}

class _CurrChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final RC rc;
  const _CurrChip(
      {required this.label,
      required this.selected,
      required this.onTap,
      required this.rc});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? cAccent : rc.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? cAccent : rc.line),
        ),
        child: Text(
          label,
          style: GoogleFonts.hankenGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : rc.ink,
          ),
        ),
      ),
    );
  }
}

class _ContinueBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ContinueBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: cAccent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cAccent.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.hankenGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
