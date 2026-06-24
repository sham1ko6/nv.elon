// ============================================================
// screens/favorites_screen.dart  –  Saved ads (light)
// ============================================================
// Shows the ads the user tapped the heart on. Reuses the same card grid as
// the home feed for a consistent look.
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final favs = state.favoriteListings;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Text('Saralangan',
                  style: GoogleFonts.outfit(
                      fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ),
            Expanded(
              child: favs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite_border_rounded, size: 48, color: AppColors.textHint),
                          const SizedBox(height: 12),
                          Text("Saralanganlar bo'sh",
                              style: GoogleFonts.outfit(
                                  fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text("Yoqqan e'lonlarni ♡ tugmasi bilan saqlang",
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.70,
                      ),
                      itemCount: favs.length,
                      itemBuilder: (ctx, i) {
                        final item = favs[i];
                        return ListingCard(
                          listing: item,
                          onTap: () => Navigator.of(ctx).push(
                            MaterialPageRoute(
                                builder: (_) => ListingDetailScreen(listingId: item.id)),
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
