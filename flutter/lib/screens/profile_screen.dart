// ============================================================
// screens/profile_screen.dart  –  Premium kabinet
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../widgets/listing_card.dart';
import '../mock_data.dart';
import 'listing_detail_screen.dart';
import 'edit_profile_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppStateProvider.of(context).loadMyListings();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final l = AppLocalizations.of(context);
    final user = state.currentUser ??
        const AppUser(
          name: 'Mehmon',
          phone: '+998 90 000 00 00',
          role: 'seller',
          initials: 'M',
        );
    final myListings =
        state.isLoggedIn ? state.myListings : kGuestMyListings;
    final totalViews =
        state.listings.fold<int>(0, (s, listing) => s + listing.views);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              child: Column(
                children: [
                  // ── Top row ──────────────────────────────────────
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(l.profileTitle,
                                style: GoogleFonts.playfairDisplay(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                          ),
                          _IconCircle(
                            icon: Icons.edit_rounded,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const EditProfileScreen()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _IconCircle(
                            icon: Icons.logout_rounded,
                            iconColor: AppColors.danger,
                            onTap: () => state.logout(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Avatar + name ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(user.initials,
                                style: GoogleFonts.playfairDisplay(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onPrimary)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(user.name,
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(user.phone,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // ── Stats row ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      children: [
                        _StatCell(
                            value: '${myListings.length}',
                            label: l.listingsStat),
                        _Divider(),
                        _StatCell(
                            value: '${totalViews ~/ 1000}K',
                            label: l.viewsStat),
                        _Divider(),
                        _StatCell(
                            value: '4.8',
                            label: l.ratingStat,
                            trailing: const Icon(Icons.star_rounded,
                                size: 12, color: AppColors.amber)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Language switcher ────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      children: [
                        Text(l.languageLabel,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        ...['uz', 'ru', 'en'].map((code) {
                          final selected =
                              state.locale.languageCode == code;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () =>
                                  state.setLocale(Locale(code)),
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.surfaceAlt,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.border),
                                ),
                                child: Text(code.toUpperCase(),
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: selected
                                            ? AppColors.onPrimary
                                            : AppColors.textPrimary)),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Wallet card ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: AppColors.primaryGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded,
                              color: Colors.white70, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.walletBalance,
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Colors.white70)),
                                Text('\$0.00',
                                    style: GoogleFonts.playfairDisplay(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.35)),
                              ),
                              child: Text(l.topUpBtn,
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Tab bar ───────────────────────────────────────
                  TabBar(
                    controller: _tabs,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 2,
                    dividerColor: AppColors.border,
                    labelStyle: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w700),
                    unselectedLabelStyle:
                        GoogleFonts.inter(fontSize: 13),
                    tabs: [
                      Tab(text: l.activeTab(myListings.length)),
                      Tab(text: l.pendingTab),
                      Tab(text: l.archiveTab),
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
            _ListingGrid(
                listings: myListings, state: state, status: 'active'),
            _EmptyState(
                icon: Icons.hourglass_top_rounded,
                msg: l.noPendingListings),
            _EmptyState(
                icon: Icons.archive_rounded,
                msg: l.noArchiveListings),
          ],
        ),
      ),
    );
  }
}

// ── Tab view for my listings ──────────────────────────────────

class _ListingGrid extends StatelessWidget {
  final List<Listing> listings;
  final AppState state;
  final String status;
  const _ListingGrid(
      {required this.listings, required this.state, required this.status});

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return _EmptyState(
          icon: Icons.post_add_rounded,
          msg: AppLocalizations.of(context).noMyListings);
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.65,
      ),
      itemCount: listings.length,
      itemBuilder: (ctx, i) {
        final l = listings[i];
        return Stack(
          children: [
            ListingCard(
              listing: l,
              onTap: () => Navigator.of(ctx).push(
                MaterialPageRoute(
                    builder: (_) =>
                        ListingDetailScreen(listingId: l.id)),
              ),
              onFavoriteTap: () => state.toggleFavorite(l.id),
              onCallTap: () {},
            ),
            // Status badge
            Positioned(
              bottom: 8,
              left: 8,
              child: _StatusBadge(status: l.status),
            ),
          ],
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    final l = AppLocalizations.of(context);
    switch (status) {
      case 'pending':
        color = AppColors.star;
        label = l.statusPending;
        break;
      case 'expired':
        color = AppColors.danger;
        label = l.statusExpired;
        break;
      default:
        color = AppColors.success;
        label = l.statusActive;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String msg;
  const _EmptyState({required this.icon, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: AppColors.surfaceAlt, shape: BoxShape.circle),
            child: Icon(icon, size: 32, color: AppColors.textHint),
          ),
          const SizedBox(height: 14),
          Text(msg,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  const _IconCircle({required this.icon, this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.bg,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon,
            size: 18,
            color: iconColor ?? AppColors.textSecondary),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Widget? trailing;
  const _StatCell(
      {required this.value, required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              if (trailing != null) ...[
                const SizedBox(width: 3),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.border,
    );
  }
}
