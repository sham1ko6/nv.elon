import 'package:flutter/material.dart';
import '../app_state.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'auth_screen.dart';
import 'business_plans_screen.dart';
import 'invite_friend_screen.dart';
import 'lang_screen.dart';
import 'my_listings_screen.dart';
import 'notifications_screen.dart';
import 'payment_screen.dart';
import 'saved_screen.dart';
import 'verification_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    final state = AppStateScope.of(context);

    if (!state.isLoggedIn) return _LoginPrompt(rc: rc);

    final user = state.user ?? {};
    final name = user['name']?.toString() ?? 'Foydalanuvchi';
    final phone = user['phone']?.toString() ?? '';
    final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return Scaffold(
      backgroundColor: rc.bg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              color: rc.accent,
              padding: const EdgeInsets.fromLTRB(18, 50, 18, 56),
              child: Stack(
                children: [
                  Positioned(
                    right: 0, top: 0,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.settings_rounded, color: Colors.white, size: 17),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                        alignment: Alignment.center,
                        child: Text(initials, style: spectral(size: 22, weight: FontWeight.w800, color: rc.accent)),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: spectral(size: 20, weight: FontWeight.w700, color: Colors.white, height: 1.1)),
                            const SizedBox(height: 3),
                            Text(phone.isNotEmpty ? phone : 'Foydalanuvchi',
                                style: hanken(size: 11.5, color: Colors.white.withValues(alpha: 0.82))),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, size: 11, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text('4.9 reyting',
                                      style: hanken(size: 10.5, weight: FontWeight.w700, color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Overlapping card ──────────────────────────────────
            Transform.translate(
              offset: const Offset(0, -38),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
                      decoration: BoxDecoration(
                        color: rc.card,
                        border: Border.all(color: rc.line),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: warmShadow(rc.dark),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RLabel(S.get('balance')),
                                const SizedBox(height: 3),
                                RichText(
                                  text: TextSpan(
                                    style: spectral(size: 21, weight: FontWeight.w800, color: rc.ink),
                                    children: [
                                      const TextSpan(text: '1 250 000 '),
                                      TextSpan(text: "so'm", style: hanken(size: 13, weight: FontWeight.w600, color: rc.muted)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const PaymentScreen(amount: 0, planLabel: "Hamyon to'ldirish")),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              decoration: BoxDecoration(color: rc.accent, borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.add_rounded, color: Colors.white, size: 14),
                                  const SizedBox(width: 5),
                                  Text(S.get('recharge'), style: hanken(size: 12, weight: FontWeight.w700, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: rc.card,
                        border: Border.all(color: rc.line),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          _StatItem(label: S.get('myAds'), value: '4', rc: rc, divider: true),
                          _StatItem(label: S.get('sold'), value: '12', rc: rc, divider: true),
                          _StatItem(label: S.get('views'), value: '3.2k', rc: rc, divider: false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _MenuRow(
                      icon: Icons.receipt_long_rounded,
                      label: S.get('myAds'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyListingsScreen())),
                      rc: rc,
                    ),
                    _MenuRow(
                      icon: Icons.favorite_border_rounded,
                      label: S.get('saved'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SavedScreen())),
                      rc: rc,
                    ),
                    _MenuRow(
                      icon: Icons.credit_card_rounded,
                      label: "To'lovlar tarixi",
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PaymentScreen(amount: 249000, planLabel: 'Biznes Pro · 1 oy')),
                      ),
                      rc: rc,
                    ),
                    _MenuRow(
                      icon: Icons.notifications_outlined,
                      label: S.get('notifications'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                      rc: rc,
                    ),
                    _MenuRow(
                      icon: Icons.verified_user_outlined,
                      label: 'Sotuvchini tasdiqlash',
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VerificationScreen())),
                      rc: rc,
                    ),
                    _MenuRow(
                      icon: Icons.card_giftcard_rounded,
                      label: "Do'stni taklif qilish",
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InviteFriendScreen())),
                      rc: rc,
                    ),
                    _MenuRow(
                      icon: Icons.language_rounded,
                      label: S.get('language'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LangScreen())),
                      rc: rc,
                    ),
                    const SizedBox(height: 8),
                    // Biznes CTA
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BusinessPlansScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF3A2A1C), Color(0xFF5A3A22)]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(
                                color: cAmber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.workspace_premium_rounded, color: cAmber, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Biznes profilga o\'tish',
                                      style: hanken(size: 12.5, weight: FontWeight.w700, color: Colors.white)),
                                  Text("Do'kon, statistika, reklama",
                                      style: hanken(size: 9.5, color: Colors.white.withValues(alpha: 0.6))),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: cAmber, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => state.logout(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout_rounded, color: Colors.red, size: 18),
                            const SizedBox(width: 10),
                            Text(S.get('logout'), style: hanken(size: 14, weight: FontWeight.w600, color: Colors.red)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Not logged in ─────────────────────────────────────────────

class _LoginPrompt extends StatelessWidget {
  final RC rc;
  const _LoginPrompt({required this.rc});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: rc.bg,
      body: Center(
        child: REmptyState(
          icon: Icons.person_outline_rounded,
          title: S.get('loginRequired'),
          subtitle: S.get('loginToAccess'),
          actionLabel: S.get('loginBtn'),
          onAction: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final RC rc;
  final bool divider;
  const _StatItem({required this.label, required this.value, required this.rc, required this.divider});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: divider ? BoxDecoration(border: Border(right: BorderSide(color: rc.line))) : null,
        child: Column(
          children: [
            Text(value, style: spectral(size: 18, weight: FontWeight.w800, color: rc.accent)),
            const SizedBox(height: 1),
            Text(label, style: hanken(size: 9.5, color: rc.muted)),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final RC rc;
  const _MenuRow({required this.icon, required this.label, required this.onTap, required this.rc});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: rc.line))),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: rc.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: rc.accent, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: hanken(size: 13, weight: FontWeight.w600, color: rc.ink))),
            Icon(Icons.chevron_right_rounded, size: 16, color: rc.muted),
          ],
        ),
      ),
    );
  }
}
