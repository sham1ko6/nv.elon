// ============================================================
// screens/profile_screen.dart  –  Light profile / "Kabinet"
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';
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
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    if (!state.isLoggedIn) {
      return _GuestView(
        onLogin: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AuthScreen())),
      );
    }

    final user = state.currentUser!;
    final myListings = state.listings.where((l) => l.sellerName == user.name).toList();
    final favListings = state.favoriteListings;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Mening kabinetim',
                            style: GoogleFonts.outfit(
                                fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: IconButton(
                          onPressed: state.logout,
                          icon: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // User card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: kCardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60, height: 60,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: AppColors.primaryGradient),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(user.initials,
                                style: GoogleFonts.outfit(
                                    fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.onPrimary)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name,
                                  style: GoogleFonts.outfit(
                                      fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              const SizedBox(height: 3),
                              Text(user.phone,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_rounded, color: AppColors.success, size: 12),
                              const SizedBox(width: 4),
                              Text('Faol',
                                  style: GoogleFonts.outfit(
                                      fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.success)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Stats
                  Row(
                    children: [
                      _StatBubble(value: '${myListings.length}', label: "E'lonlar"),
                      const SizedBox(width: 12),
                      _StatBubble(value: '${favListings.length}', label: 'Saralangan'),
                      const SizedBox(width: 12),
                      _StatBubble(
                          value: '${state.listings.fold<int>(0, (s, l) => s + l.views)}',
                          label: "Ko'rishlar"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TabBar(
                    controller: _tabs,
                    labelColor: AppColors.primaryDeep,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    dividerColor: AppColors.border,
                    labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: GoogleFonts.outfit(fontSize: 13),
                    tabs: [
                      Tab(text: "E'lonlarim (${myListings.length})"),
                      Tab(text: 'Saralangan (${favListings.length})'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _ListingTab(
              listings: myListings,
              emptyIcon: Icons.post_add_rounded,
              emptyMsg: "Siz hali e'lon bermadingiz",
              state: state,
            ),
            _ListingTab(
              listings: favListings,
              emptyIcon: Icons.favorite_border_rounded,
              emptyMsg: "Saralanganlar ro'yxati bo'sh",
              state: state,
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingTab extends StatelessWidget {
  final List<dynamic> listings;
  final IconData emptyIcon;
  final String emptyMsg;
  final AppState state;

  const _ListingTab({
    required this.listings,
    required this.emptyIcon,
    required this.emptyMsg,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 46, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(emptyMsg,
                style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.70,
      ),
      itemCount: listings.length,
      itemBuilder: (ctx, i) {
        final l = listings[i];
        return ListingCard(
          listing: l,
          onTap: () => Navigator.of(ctx).push(
            MaterialPageRoute(builder: (_) => ListingDetailScreen(listingId: l.id)),
          ),
          onFavoriteTap: () => state.toggleFavorite(l.id),
          onCallTap: () {},
        );
      },
    );
  }
}

class _StatBubble extends StatelessWidget {
  final String value;
  final String label;
  const _StatBubble({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: kCardShadow,
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _GuestView extends StatelessWidget {
  final VoidCallback onLogin;
  const _GuestView({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text('Kirish talab etiladi',
                  style: GoogleFonts.outfit(
                      fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text("Kabinetingizga kirish uchun tizimga kiring yoki ro'yxatdan o'ting.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: ElevatedButton(
                    onPressed: onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    ),
                    child: Text("Kirish / Ro'yxatdan o'tish",
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.onPrimary)),
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
