// ============================================================
// screens/favorites_screen.dart  –  Saved ads
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final favs = state.favoriteListings;
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Text(l.savedTitle,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ),
            Container(height: 1, color: AppColors.border),
            Expanded(
              child: favs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.favorite_border_rounded,
                                size: 36, color: AppColors.textHint),
                          ),
                          const SizedBox(height: 16),
                          Text(l.noSavedListings,
                              style: GoogleFonts.playfairDisplay(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          Text(l.saveFavoriteHint,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: favs.length,
                      itemBuilder: (ctx, i) {
                        final item = favs[i];
                        return ListingCard(
                          listing: item,
                          onTap: () => Navigator.of(ctx).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    ListingDetailScreen(listingId: item.id)),
                          ),
                          onFavoriteTap: () => state.toggleFavorite(item.id),
                          onCallTap: () {},
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
