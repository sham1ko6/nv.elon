// ============================================================
// widgets/listing_card.dart  –  OLX-style listing card (light)
// ============================================================
// One ad in the 2-column feed grid: image on top (with a category badge and
// a favorite heart), then title, bold price, and location/date below.
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models.dart';
import '../app_theme.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onCallTap;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    required this.onFavoriteTap,
    required this.onCallTap,
  });

  String get _priceFormatted => listing.formattedPrice;

  @override
  Widget build(BuildContext context) {
    final catColor = AppTheme.categoryColor(listing.categoryId);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: kCardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ───────────────────────────────────────────
            Expanded(
              flex: 11,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (listing.imageUrl.isNotEmpty)
                    Image.network(
                      listing.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (c, child, p) =>
                          p == null ? child : Container(color: AppColors.surfaceAlt),
                      errorBuilder: (c, e, s) => _placeholder(catColor),
                    )
                  else
                    _placeholder(catColor),

                  // Category badge (white pill with a colored icon)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: kCardShadow,
                      ),
                      child: Icon(AppTheme.categoryIcon(listing.categoryId),
                          color: catColor, size: 12),
                    ),
                  ),

                  // Favorite heart (white circle, red when active)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: kCardShadow,
                        ),
                        child: Icon(
                          listing.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: listing.isFavorite ? AppColors.danger : AppColors.textHint,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Text area ────────────────────────────────────────────
            Expanded(
              flex: 9,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      _priceFormatted,
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 11, color: AppColors.textHint),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            listing.location.split(',').first,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textSecondary, fontSize: 10.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A soft tinted placeholder shown when there is no photo.
  Widget _placeholder(Color catColor) => Container(
        color: catColor.withValues(alpha: 0.10),
        child: Center(
          child: Icon(AppTheme.categoryIcon(listing.categoryId),
              color: catColor.withValues(alpha: 0.55), size: 30),
        ),
      );
}
