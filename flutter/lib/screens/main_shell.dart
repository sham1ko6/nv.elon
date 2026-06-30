// ============================================================
// screens/main_shell.dart  –  Premium bottom navigation
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../l10n/strings.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'post_ad_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoriesScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  void _goToTab(int i) => setState(() => _currentIndex = i);

  void _openPostFlow() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PostAdScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainShellScope(
      goToTab: _goToTab,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          body: IndexedStack(index: _currentIndex, children: _screens),
          bottomNavigationBar: _BottomBar(
            currentIndex: _currentIndex,
            onTap: _goToTab,
            onPost: _openPostFlow,
          ),
        ),
      ),
    );
  }
}

class MainShellScope extends InheritedWidget {
  final void Function(int) goToTab;
  const MainShellScope(
      {super.key, required this.goToTab, required super.child});

  static MainShellScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MainShellScope>();

  @override
  bool updateShouldNotify(MainShellScope oldWidget) => false;
}

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onPost;
  const _BottomBar(
      {required this.currentIndex,
      required this.onTap,
      required this.onPost});

  @override
  Widget build(BuildContext context) {
    // Depend on AppState so this rebuilds when locale changes.
    AppStateProvider.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
              color: Color(0x0E241C15),
              blurRadius: 12,
              offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: S.get('navHome'),
                current: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                index: 1,
                icon: Icons.grid_view_rounded,
                label: S.get('navCategories'),
                current: currentIndex,
                onTap: onTap,
              ),
              _PostBtn(onTap: onPost),
              _NavItem(
                index: 2,
                icon: Icons.favorite_rounded,
                label: S.get('navSaved'),
                current: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                index: 3,
                icon: Icons.person_rounded,
                label: S.get('navProfile'),
                current: currentIndex,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final int current;
  final ValueChanged<int> onTap;
  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = current == index;
    final color = selected ? AppColors.primary : AppColors.textHint;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

class _PostBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _PostBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.40),
                blurRadius: 14,
                offset: const Offset(0, 5)),
          ],
        ),
        child: const Icon(Icons.add_rounded,
            color: AppColors.onPrimary, size: 28),
      ),
    );
  }
}
