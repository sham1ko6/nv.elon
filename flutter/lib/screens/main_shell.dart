// ============================================================
// screens/main_shell.dart  –  Light bottom navigation (OLX-style)
// ============================================================
// Holds the 4 main tabs (Home, Categories, Favorites, Profile) and a raised
// center "Post" button. The Post button opens the posting flow as its own
// screen (which then leads to the payment screens).
//
// MainShellScope lets any child screen switch tabs (e.g. the Categories
// screen jumps to Home after you pick a category).
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
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

// Lets descendant screens control the shell (switch tabs).
class MainShellScope extends InheritedWidget {
  final void Function(int) goToTab;
  const MainShellScope({super.key, required this.goToTab, required super.child});

  static MainShellScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MainShellScope>();

  @override
  bool updateShouldNotify(MainShellScope oldWidget) => false;
}

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onPost;
  const _BottomBar({required this.currentIndex, required this.onTap, required this.onPost});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [BoxShadow(color: Color(0x0F101828), blurRadius: 12, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _navItem(0, Icons.home_rounded, 'Asosiy'),
              _navItem(1, Icons.grid_view_rounded, "Bo'limlar"),
              _postButton(),
              _navItem(2, Icons.favorite_rounded, 'Saralangan'),
              _navItem(3, Icons.person_rounded, 'Kabinet'),
            ],
          ),
        ),
      ),
    );
  }

  // One ordinary tab (icon + small label, purple when selected).
  Widget _navItem(int index, IconData icon, String label) {
    final selected = currentIndex == index;
    final color = selected ? AppColors.primaryDeep : AppColors.textHint;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 23, color: color),
            const SizedBox(height: 3),
            Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: color)),
          ],
        ),
      ),
    );
  }

  // The raised center button that opens the posting flow.
  Widget _postButton() {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: onPost,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 5)),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: AppColors.onPrimary, size: 28),
          ),
        ),
      ),
    );
  }
}
