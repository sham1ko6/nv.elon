import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models.dart';

// ── Grid card (2-column) ──────────────────────────────────────

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final VoidCallback onFavTap;
  final bool isFavorite;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    required this.onFavTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: rc.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: warmShadow(rc.dark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 148,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _ListingImage(url: listing.imageUrl),
                    // Gradient bottom
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.25),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // TOP badge
                    if (listing.isTop)
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: cAmber,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'TOP',
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF3A2000),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    // Heart
                    Positioned(
                      top: 6, right: 6,
                      child: GestureDetector(
                        onTap: onFavTap,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 16,
                            color: isFavorite ? Colors.red : rc.muted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: rc.line,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      listing.category,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: rc.muted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Title
                  Text(
                    listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: rc.ink,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Price
                  Text(
                    listing.formattedPrice,
                    style: GoogleFonts.spectral(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: rc.accent,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Location + date
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 10, color: rc.muted),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          listing.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.hankenGrotesk(
                              fontSize: 10, color: rc.muted),
                        ),
                      ),
                      Text(
                        listing.date,
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 10, color: rc.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Row card (search result) ──────────────────────────────────

class ListingRow extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final VoidCallback onFavTap;
  final bool isFavorite;

  const ListingRow({
    super.key,
    required this.listing,
    required this.onTap,
    required this.onFavTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: rc.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: warmShadow(rc.dark),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 82,
                height: 82,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _ListingImage(url: listing.imageUrl),
                    if (listing.isTop)
                      Positioned(
                        top: 5, left: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: cAmber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('TOP',
                              style: GoogleFonts.hankenGrotesk(
                                  fontSize: 7, fontWeight: FontWeight.w800,
                                  color: const Color(0xFF3A2000))),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: rc.line,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      listing.category,
                      style: GoogleFonts.hankenGrotesk(
                          fontSize: 9, fontWeight: FontWeight.w600, color: rc.muted),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hankenGrotesk(
                        fontSize: 13, fontWeight: FontWeight.w600, color: rc.ink, height: 1.3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    listing.formattedPrice,
                    style: GoogleFonts.spectral(
                        fontSize: 15, fontWeight: FontWeight.w700, color: rc.accent),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 10, color: rc.muted),
                      const SizedBox(width: 2),
                      Text(listing.location,
                          style: GoogleFonts.hankenGrotesk(fontSize: 10, color: rc.muted)),
                    ],
                  ),
                ],
              ),
            ),
            // Heart
            GestureDetector(
              onTap: onFavTap,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 20,
                  color: isFavorite ? Colors.red : rc.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared image widget ───────────────────────────────────────

class _ListingImage extends StatelessWidget {
  final String url;
  const _ListingImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _Fallback();
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(color: const Color(0xFFEDE5D8));
      },
      errorBuilder: (_, __, ___) => _Fallback(),
    );
  }
}

class _Fallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StripePainter());
  }
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFEDE5D8));
    final paint = Paint()
      ..color = const Color(0xFFE0D5C4)
      ..strokeWidth = 10;
    for (double i = -size.height; i < size.width + size.height; i += 22) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
    // Center icon
    final icon = Icons.image_outlined;
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          fontSize: 28,
          color: const Color(0xFFC4B8A6),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas,
        Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
