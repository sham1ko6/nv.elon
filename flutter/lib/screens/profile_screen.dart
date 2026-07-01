import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_state.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../widgets/ravoq_shield.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }
  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: cAccent,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 76, height: 76,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Center(
                      child: Text(initials,
                          style: GoogleFonts.spectral(
                              fontSize: 30, fontWeight: FontWeight.w700, color: cAccent)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: GoogleFonts.spectral(
                      fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(phone, style: GoogleFonts.hankenGrotesk(
                        fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, size: 13, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(S.get('verified'),
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(width: 8),
                        const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFD700)),
                        const SizedBox(width: 3),
                        Text('4.8', style: GoogleFonts.hankenGrotesk(
                            fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Stats row ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: rc.card,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  _StatItem(label: S.get('myAds'), value: '12', rc: rc),
                  _Divider(),
                  _StatItem(label: S.get('views'), value: '3.4K', rc: rc),
                  _Divider(),
                  _StatItem(label: S.get('rating'), value: '4.8', rc: rc),
                ],
              ),
            ),
          ),

          // ── Wallet card ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C1810), Color(0xFF4A2A18)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.get('balance'),
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
                        const SizedBox(height: 6),
                        Text('125,000 so\'m',
                            style: GoogleFonts.spectral(
                                fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: cAmber,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(S.get('recharge'),
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 13, fontWeight: FontWeight.w700,
                                color: const Color(0xFF3A2000))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── My ads tabs ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(S.get('myAds'),
                      style: GoogleFonts.spectral(
                          fontSize: 18, fontWeight: FontWeight.w700, color: rc.ink)),
                ),
                const SizedBox(height: 10),
                Container(
                  color: rc.card,
                  child: TabBar(
                    controller: _tabs,
                    labelColor: cAccent,
                    unselectedLabelColor: rc.muted,
                    indicatorColor: cAccent,
                    labelStyle: GoogleFonts.hankenGrotesk(
                        fontSize: 13, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: GoogleFonts.hankenGrotesk(fontSize: 13),
                    tabs: [
                      Tab(text: S.get('active')),
                      Tab(text: S.get('sold')),
                      Tab(text: S.get('archived')),
                    ],
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _EmptyTab(label: "${S.get('active')} ${S.get('myAds').toLowerCase()}", rc: rc),
                      _EmptyTab(label: "${S.get('sold')}", rc: rc),
                      _EmptyTab(label: S.get('archived'), rc: rc),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Settings ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.get('language'),
                      style: GoogleFonts.hankenGrotesk(
                          fontSize: 13, fontWeight: FontWeight.w600, color: rc.ink)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final l in [('uz', '🇺🇿 UZ'), ('ru', '🇷🇺 RU'), ('en', '🇬🇧 EN')])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => state.setLang(l.$1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: state.lang == l.$1 ? cAccent : rc.card,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                    color: state.lang == l.$1 ? cAccent : rc.line),
                              ),
                              child: Text(l.$2,
                                  style: GoogleFonts.hankenGrotesk(
                                      fontSize: 13, fontWeight: FontWeight.w600,
                                      color: state.lang == l.$1 ? Colors.white : rc.ink)),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(S.get('theme'),
                      style: GoogleFonts.hankenGrotesk(
                          fontSize: 13, fontWeight: FontWeight.w600, color: rc.ink)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final t in [
                        (ThemeMode.light, S.get('light')),
                        (ThemeMode.dark, S.get('dark')),
                        (ThemeMode.system, S.get('system')),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => state.setThemeMode(t.$1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: state.themeMode == t.$1 ? cAccent : rc.card,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                    color: state.themeMode == t.$1 ? cAccent : rc.line),
                              ),
                              child: Text(t.$2,
                                  style: GoogleFonts.hankenGrotesk(
                                      fontSize: 13, fontWeight: FontWeight.w600,
                                      color: state.themeMode == t.$1 ? Colors.white : rc.ink)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Menu items ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    label: S.get('notifications'),
                    onTap: () {},
                    rc: rc,
                  ),
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Yordam',
                    onTap: () {},
                    rc: rc,
                  ),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    label: 'Foydalanish shartlari',
                    onTap: () {},
                    rc: rc,
                  ),
                  const SizedBox(height: 8),
                  // Logout
                  GestureDetector(
                    onTap: () {
                      state.logout();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.logout_rounded, color: Colors.red, size: 18),
                          const SizedBox(width: 12),
                          Text(S.get('logout'),
                              style: GoogleFonts.hankenGrotesk(
                                  fontSize: 14, fontWeight: FontWeight.w600,
                                  color: Colors.red)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
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
      appBar: AppBar(
        backgroundColor: rc.card,
        title: Row(
          children: [
            RavoqShield(size: 20, color: cAccent, letterColor: Colors.white),
            const SizedBox(width: 7),
            Text('Ravoq.', style: GoogleFonts.spectral(
                fontSize: 18, fontWeight: FontWeight.w700, color: cAccent)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: rc.line),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                    color: cAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.person_outline_rounded, size: 40, color: cAccent),
              ),
              const SizedBox(height: 20),
              Text(S.get('loginRequired'),
                  style: GoogleFonts.spectral(
                      fontSize: 22, fontWeight: FontWeight.w700, color: rc.ink)),
              const SizedBox(height: 8),
              Text(S.get('loginToAccess'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hankenGrotesk(fontSize: 13, color: rc.muted)),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                ),
                child: Container(
                  height: 50, width: double.infinity,
                  decoration: BoxDecoration(
                    color: cAccent, borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                        color: cAccent.withValues(alpha: 0.35), blurRadius: 14,
                        offset: const Offset(0, 6))],
                  ),
                  child: Center(
                    child: Text(S.get('loginBtn'),
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final RC rc;
  const _StatItem({required this.label, required this.value, required this.rc});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: GoogleFonts.spectral(
              fontSize: 20, fontWeight: FontWeight.w700, color: rc.accent)),
          const SizedBox(height: 3),
          Text(label, style: GoogleFonts.hankenGrotesk(fontSize: 11, color: rc.muted)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: RC.of(context).line);
  }
}

class _EmptyTab extends StatelessWidget {
  final String label;
  final RC rc;
  const _EmptyTab({required this.label, required this.rc});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label yo\'q',
        style: GoogleFonts.hankenGrotesk(fontSize: 13, color: rc.muted),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final RC rc;
  const _MenuItem(
      {required this.icon, required this.label, required this.onTap, required this.rc});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: rc.line))),
        child: Row(
          children: [
            Icon(icon, size: 18, color: rc.muted),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.hankenGrotesk(
                fontSize: 14, fontWeight: FontWeight.w500, color: rc.ink)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, size: 18, color: rc.muted),
          ],
        ),
      ),
    );
  }
}
