import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'listing_detail_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    final listing = kMockListings[1];
    return Scaffold(
      backgroundColor: rc.bg,
      body: Stack(
        children: [
          // Fake map background
          Positioned.fill(child: CustomPaint(painter: _MapPainter(rc: rc))),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      RRoundIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.of(context).pop()),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          decoration: BoxDecoration(
                            color: rc.card,
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: warmShadow(rc.dark),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded, size: 16, color: rc.muted),
                              const SizedBox(width: 9),
                              Text('Toshkent sh.', style: hanken(size: 12.5, weight: FontWeight.w600, color: rc.ink)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      RRoundIconButton(icon: Icons.tune_rounded, color: rc.accent, onTap: () {}),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),

          // Price pins
          const _Pin(top: 0.48, left: 0.24, label: '\$125k', active: true),
          const _Pin(top: 0.33, left: 0.64, label: '\$78k'),
          const _Pin(top: 0.6, left: 0.78, label: '\$2.6k'),

          // Zoom controls
          Positioned(
            right: 14, top: MediaQuery.of(context).size.height * 0.42,
            child: Column(
              children: [
                RRoundIconButton(icon: Icons.add_rounded, color: rc.accent, onTap: () {}),
                const SizedBox(height: 9),
                RRoundIconButton(icon: Icons.my_location_rounded, color: rc.accent, onTap: () {}),
              ],
            ),
          ),

          // Bottom sheet
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: rc.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 26, offset: const Offset(0, -10))],
              ),
              padding: EdgeInsets.fromLTRB(14, 9, 14, MediaQuery.of(context).padding.bottom + 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const RDragHandle(),
                  Row(
                    children: [
                      Text("Bu hududda 24 e'lon", style: spectral(size: 15, weight: FontWeight.w700, color: rc.ink)),
                      const Spacer(),
                      Text("Ro'yxat", style: hanken(size: 11.5, weight: FontWeight.w700, color: rc.accent)),
                    ],
                  ),
                  const SizedBox(height: 11),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(color: rc.bg, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(listing.imageUrl, width: 64, height: 64, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(width: 64, height: 64, color: rc.line)),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: hanken(size: 12, weight: FontWeight.w600, color: rc.ink)),
                                Text(listing.formattedPrice, style: spectral(size: 15, weight: FontWeight.w700, color: rc.accent)),
                                Text('${listing.location} · 1.2 km', style: hanken(size: 10, color: rc.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  final double top, left;
  final String label;
  final bool active;
  const _Pin({required this.top, required this.left, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return Positioned(
      top: MediaQuery.of(context).size.height * top,
      left: MediaQuery.of(context).size.width * left,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: active ? rc.accent : rc.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: active ? 0.3 : 0.16), blurRadius: 10)],
              ),
              child: Text(label, style: spectral(size: 12, weight: FontWeight.w700, color: active ? Colors.white : rc.ink)),
            ),
            Transform.rotate(
              angle: 0.785,
              child: Container(width: 9, height: 9, color: active ? rc.accent : rc.card, margin: const EdgeInsets.only(top: -4)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final RC rc;
  _MapPainter({required this.rc});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE7E3D6));
    final roadPaint = Paint()..color = const Color(0xFFD6D0BD)..strokeWidth = 10;
    for (final y in [0.25, 0.5, 0.75]) {
      canvas.drawLine(Offset(0, size.height * y), Offset(size.width, size.height * y), roadPaint);
    }
    for (final x in [0.24, 0.53, 0.76]) {
      canvas.drawLine(Offset(size.width * x, 0), Offset(size.width * x, size.height), roadPaint);
    }
    final blockPaint = Paint()..color = const Color(0xFFDCD6C4);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.06, size.height * 0.08, 44, 80), const Radius.circular(4)), blockPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.62, size.height * 0.14, 70, 50), const Radius.circular(4)), blockPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.3, size.height * 0.55, 60, 60), const Radius.circular(4)), blockPaint);
    canvas.drawCircle(Offset(size.width * 0.16, size.height * 0.82), 48, Paint()..color = const Color(0xFFC4DCC8).withValues(alpha: 0.6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
