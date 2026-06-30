// ============================================================
// widgets/listing_card.dart  –  Premium marketplace card
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
            // ── Image / placeholder ──────────────────────────────
            Expanded(
              flex: 11,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image or diagonal stripe placeholder
                  if (listing.imageUrl.isNotEmpty)
                    Image.network(
                      listing.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (c, child, p) => p == null
                          ? child
                          : _StripePlaceholder(color: catColor),
                      errorBuilder: (c, e, s) =>
                          _StripePlaceholder(color: catColor),
                    )
                  else
                    _StripePlaceholder(color: catColor),

                  // TOP badge
                  if (listing.isTop)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: AppColors.amberGradient),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 10, color: Colors.white),
                            const SizedBox(width: 3),
                            Text('TOP',
                                style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5)),
                          ],
                        ),
                      ),
                    )
                  else
                    // Category icon pill (top-left when no TOP badge)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: kCardShadow,
                        ),
                        child: Icon(
                            AppTheme.categoryIcon(listing.categoryId),
                            color: catColor,
                            size: 12),
                      ),
                    ),

                  // Heart button (top-right)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: kCardShadow,
                        ),
                        child: Icon(
                          listing.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: listing.isFavorite
                              ? AppColors.danger
                              : AppColors.textHint,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Text ──────────────────────────────────────────────
            Expanded(
              flex: 9,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: GoogleFonts.inter(
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
                      listing.formattedPrice,
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 10, color: AppColors.textHint),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            listing.location.split(',').first,
                            style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w400),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          listing.date,
                          style: GoogleFonts.inter(
                              color: AppColors.textHint, fontSize: 9.5),
                          maxLines: 1,
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
}

// Diagonal stripe pattern used when no photo is available
class _StripePlaceholder extends StatelessWidget {
  final Color color;
  const _StripePlaceholder({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StripePainter(color),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.image_rounded,
              size: 22, color: color.withValues(alpha: 0.6)),
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  final Color color;
  _StripePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final light = Paint()..color = color.withValues(alpha: 0.10);
    final dark  = Paint()..color = color.withValues(alpha: 0.16);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), light);

    final stripeW = 18.0;
    final path = Path();
    var x = -stripeW * 2;
    while (x < size.width + size.height) {
      path.moveTo(x, 0);
      path.lineTo(x + stripeW, 0);
      path.lineTo(x + stripeW + size.height, size.height);
      path.lineTo(x + size.height, size.height);
      path.close();
      x += stripeW * 2;
    }
    canvas.drawPath(path, dark);
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.color != color;
}

// Horizontal listing row used in search results
class ListingRow extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const ListingRow({
    super.key,
    required this.listing,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = AppTheme.categoryColor(listing.categoryId);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: kCardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 96,
              height: 88,
              child: listing.imageUrl.isNotEmpty
                  ? Image.network(listing.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _StripePlaceholder(color: catColor))
                  : _StripePlaceholder(color: catColor),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing.title,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(listing.formattedPrice,
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 10, color: AppColors.textHint),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            listing.location.split(',').first,
                            style: GoogleFonts.inter(
                                fontSize: 11, color: AppColors.textSecondary),
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
            // Heart
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: onFavoriteTap,
                child: Icon(
                  listing.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color:
                      listing.isFavorite ? AppColors.danger : AppColors.textHint,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
