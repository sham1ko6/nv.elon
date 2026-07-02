import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import 'listing_detail_screen.dart';

class StoryScreen extends StatelessWidget {
  final Listing listing;
  const StoryScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(listing.imageUrl, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: cInk)),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x8C140C06), Colors.transparent, Colors.transparent, Color(0xD1140C06)],
                stops: [0, 0.22, 0.55, 1],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Expanded(child: _Bar(active: true)),
                          SizedBox(width: 4),
                          Expanded(child: _Bar()),
                          SizedBox(width: 4),
                          Expanded(child: _Bar()),
                        ],
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              image: DecorationImage(image: NetworkImage(listing.imageUrl), fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(listing.sellerName, style: hanken(size: 12.5, weight: FontWeight.w700, color: Colors.white)),
                                Text('2 soat oldin', style: hanken(size: 10, color: Colors.white.withValues(alpha: 0.75))),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YANGI TUSHDI',
                          style: hanken(size: 9.5, weight: FontWeight.w800, color: cAmber).copyWith(letterSpacing: 1.6)),
                      const SizedBox(height: 6),
                      Text(listing.title,
                          style: spectral(size: 22, weight: FontWeight.w800, color: Colors.white, height: 1.15)),
                      const SizedBox(height: 8),
                      Text(listing.formattedPrice, style: spectral(size: 20, weight: FontWeight.w700, color: cAmber)),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing)),
                              ),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("E'lonni ko'rish", style: hanken(size: 13, weight: FontWeight.w700, color: cInk)),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: cInk),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                            child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final bool active;
  const _Bar({this.active = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
