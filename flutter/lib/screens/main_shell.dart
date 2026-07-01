import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'post_ad_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _idx;

  @override
  void initState() {
    super.initState();
    _idx = widget.initialIndex;
  }

  final _screens = const [
    HomeScreen(),
    CategoriesScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];

  void _openPostAd() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PostAdScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: Container(
        height: 62,
        decoration: BoxDecoration(
          color: rc.card,
          border: Border(top: BorderSide(color: rc.line)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: S.get('home'),
                active: _idx == 0,
                onTap: () => setState(() => _idx = 0),
              ),
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: S.get('categories'),
                active: _idx == 1,
                onTap: () => setState(() => _idx = 1),
              ),
              // FAB
              GestureDetector(
                onTap: _openPostAd,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: rc.accent,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(
                        color: rc.accent.withValues(alpha: 0.38),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
                ),
              ),
              _NavItem(
                icon: Icons.favorite_border_rounded,
                iconActive: Icons.favorite_rounded,
                label: S.get('saved'),
                active: _idx == 2,
                onTap: () => setState(() => _idx = 2),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                iconActive: Icons.person_rounded,
                label: S.get('profile'),
                active: _idx == 3,
                onTap: () => setState(() => _idx = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData? iconActive;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    this.iconActive,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? (iconActive ?? icon) : icon,
              size: 22,
              color: active ? rc.accent : rc.muted,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? rc.accent : rc.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
