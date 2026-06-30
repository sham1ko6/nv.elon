// ============================================================
// screens/home_screen.dart  –  Premium marketplace feed
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../l10n/strings.dart';
import '../mock_data.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';
import 'search_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final filtered = state.filteredListings;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.surface,
                padding:
                    const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Logo
                        Text('nv.elon',
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                        const SizedBox(width: 10),
                        // Location pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('📍',
                                  style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text('Toshkent',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary)),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down_rounded,
                                  size: 14,
                                  color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Bell
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    const NotificationsScreen()),
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(
                                Icons.notifications_none_rounded,
                                color: AppColors.textPrimary,
                                size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Avatar
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('M',
                                style: GoogleFonts.playfairDisplay(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onPrimary)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Search bar (tap → SearchScreen)
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const SearchScreen()),
                      ),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            const Icon(Icons.search_rounded,
                                color: AppColors.textHint, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                S.get('searchHint'),
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.textHint),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(6),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.tune_rounded,
                                  color: AppColors.onPrimary, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Category chips ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.only(bottom: 14),
                child: SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: kCategories.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (ctx, i) {
                      final isAll = i == 0;
                      final cat = isAll ? null : kCategories[i - 1];
                      final selected = isAll
                          ? state.selectedCategoryId.isEmpty
                          : state.selectedCategoryId == cat!.id;
                      final emoji = isAll ? '🔍' : cat!.icon;
                      final label = isAll ? S.get('allCategories') : cat!.uzName;

                      return GestureDetector(
                        onTap: () =>
                            state.setCategory(isAll ? '' : cat!.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.border),
                            boxShadow: selected ? kCardShadow : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(emoji,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(label,
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: selected
                                          ? AppColors.onPrimary
                                          : AppColors.textPrimary)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Hero banner ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Container(
                  height: 128,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFC2613B), Color(0xFF8B3A1A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.30),
                          blurRadius: 18,
                          offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: -30,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 100, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              S.get('heroBannerTitle'),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onPrimary,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              S.get('heroBannerSubtitle'),
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white
                                      .withValues(alpha: 0.78)),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const SearchScreen()),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: AppColors.onPrimary,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(S.get('postAdBtn'),
                                        style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward_rounded,
                                        size: 14, color: AppColors.primary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Section header ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(S.get('listingsSectionTitle'),
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    Text(S.itemCount(filtered.length),
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),

            // ── Grid / loading / empty ──────────────────────────────
            if (state.listingsLoading && state.listings.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                    strokeWidth: 2.5,
                  ),
                ),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.search_off_rounded,
                            size: 34, color: AppColors.textHint),
                      ),
                      const SizedBox(height: 14),
                      Text(S.get('nothingFound'),
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text(S.get('tryAnotherCategory'),
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final item = filtered[i];
                      return ListingCard(
                        listing: item,
                        onTap: () => Navigator.of(ctx).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  ListingDetailScreen(listingId: item.id)),
                        ),
                        onFavoriteTap: () =>
                            state.toggleFavorite(item.id),
                        onCallTap: () {},
                      );
                    },
                    childCount: filtered.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.68,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
