// ============================================================
// screens/home_screen.dart  –  Light OLX-style feed
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../mock_data.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openDetail(BuildContext context, String id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ListingDetailScreen(listingId: id)),
    );
  }

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
            // ── Top bar: location + bell, then search ──
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text("O'zbekiston",
                            style: GoogleFonts.outfit(
                                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const Icon(Icons.expand_more_rounded, size: 18, color: AppColors.textSecondary),
                        const Spacer(),
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_none_rounded,
                              color: AppColors.textPrimary, size: 21),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Search field
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: state.setSearchQuery,
                        style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Qidirish... (uy, traktor, telefon)',
                          hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Category circles ──
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  height: 92,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: kCategories.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(width: 16),
                    itemBuilder: (ctx, i) {
                      final isAll = i == 0;
                      final cat = isAll ? null : kCategories[i - 1];
                      final selected = isAll
                          ? state.selectedCategoryId.isEmpty
                          : state.selectedCategoryId == cat!.id;
                      final label = isAll ? 'Barchasi' : cat!.uzName;
                      final icon = isAll ? Icons.dashboard_rounded : AppTheme.categoryIcon(cat!.id);
                      final gradient = isAll ? AppColors.primaryGradient : AppTheme.categoryGradient(cat!.id);

                      return GestureDetector(
                        onTap: () => state.setCategory(isAll ? '' : cat!.id),
                        child: SizedBox(
                          width: 68,
                          child: Column(
                            children: [
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: gradient,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: selected
                                      ? [BoxShadow(color: gradient.first.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))]
                                      : kCardShadow,
                                  border: Border.all(
                                      color: selected ? AppColors.primaryDeep : Colors.transparent, width: 2),
                                ),
                                child: Icon(icon, color: AppColors.onPrimary, size: 24),
                              ),
                              const SizedBox(height: 6),
                              Text(label,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                      color: selected ? AppColors.textPrimary : AppColors.textSecondary),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── Promo banner ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Container(
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -10, bottom: -16,
                        child: Icon(Icons.sell_rounded, size: 120,
                            color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Soting va xarid qiling",
                                style: GoogleFonts.outfit(
                                    fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.onPrimary)),
                            const SizedBox(height: 4),
                            Text("Minglab e'lonlar bir joyda",
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12, color: Colors.white.withValues(alpha: 0.85))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Section header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("E'lonlar",
                        style: GoogleFonts.outfit(
                            fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    Text('${filtered.length} ta',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),

            // ── Grid / loading / empty state ──
            if (state.listingsLoading && state.listings.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                      const Icon(Icons.search_off_rounded, size: 46, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text('Hech narsa topilmadi',
                          style: GoogleFonts.outfit(
                              color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final item = filtered[i];
                      return ListingCard(
                        listing: item,
                        onTap: () => _openDetail(ctx, item.id),
                        onFavoriteTap: () => state.toggleFavorite(item.id),
                        onCallTap: () {},
                      );
                    },
                    childCount: filtered.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.70,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
