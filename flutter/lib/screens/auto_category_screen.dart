import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'compare_screen.dart';
import 'listing_detail_screen.dart';

const _autoListings = [
  (title: 'Chevrolet Malibu 2', price: r'$23 500', year: '2021', km: '42 000 km', engine: '2.0 L', box: 'Avtomat', loc: 'Toshkent sh. · Bugun, 11:20', img: 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=400'),
  (title: 'Cobalt 2019', price: r'$12 800', year: '2019', km: '87 000 km', engine: '1.5 L', box: 'Mexanika', loc: 'Samarqand · Kecha', img: 'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=400'),
];

class AutoCategoryScreen extends StatelessWidget {
  const AutoCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    final car = kMockListings.firstWhere((l) => l.category == 'Avto', orElse: () => kMockListings.first);

    return Scaffold(
      backgroundColor: rc.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(color: rc.card, border: Border(bottom: BorderSide(color: rc.line))),
              child: Row(
                children: [
                  RRoundIconButton(icon: Icons.arrow_back_ios_new_rounded, size: 32, onTap: () => Navigator.of(context).pop()),
                  const SizedBox(width: 11),
                  Expanded(child: Text('Avtomobillar', style: spectral(size: 16, weight: FontWeight.w700, color: rc.ink))),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CompareScreen(a: kMockListings[3], b: kMockListings[9]),
                    )),
                    child: Icon(Icons.compare_arrows_rounded, color: rc.ink, size: 20),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                children: [
                  _FilterChip(label: 'Marka', rc: rc),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Yil', rc: rc),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Probeg', active: true, rc: rc),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Motor', rc: rc),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                children: [
                  Container(
                    decoration: BoxDecoration(color: rc.card, border: Border.all(color: rc.line), borderRadius: BorderRadius.circular(16)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Image.network(_autoListings[0].img, height: 148, width: double.infinity, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(height: 148, color: rc.line)),
                            Positioned(
                              top: 9, left: 9,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: rc.accent, borderRadius: BorderRadius.circular(6)),
                                child: Text('TOP', style: hanken(size: 8.5, weight: FontWeight.w800, color: Colors.white).copyWith(letterSpacing: 0.5)),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(13),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(child: Text(_autoListings[0].title, style: hanken(size: 13.5, weight: FontWeight.w700, color: rc.ink))),
                                  Text(_autoListings[0].price, style: spectral(size: 16, weight: FontWeight.w700, color: rc.accent)),
                                ],
                              ),
                              const SizedBox(height: 9),
                              Wrap(
                                spacing: 6, runSpacing: 6,
                                children: [_autoListings[0].year, _autoListings[0].km, _autoListings[0].engine, _autoListings[0].box]
                                    .map((t) => RTag(t)).toList(),
                              ),
                              const SizedBox(height: 9),
                              Text(_autoListings[0].loc, style: hanken(size: 10, color: rc.muted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 11),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: car))),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(color: rc.card, border: Border.all(color: rc.line), borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(_autoListings[1].img, width: 88, height: 66, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(width: 88, height: 66, color: rc.line)),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(_autoListings[1].title, style: hanken(size: 12.5, weight: FontWeight.w700, color: rc.ink))),
                                    Text(_autoListings[1].price, style: spectral(size: 14, weight: FontWeight.w700, color: rc.accent)),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text('${_autoListings[1].km} · ${_autoListings[1].engine} · ${_autoListings[1].box}', style: hanken(size: 10, color: rc.muted)),
                                const SizedBox(height: 4),
                                Text(_autoListings[1].loc, style: hanken(size: 10, color: rc.muted)),
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
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final RC rc;
  const _FilterChip({required this.label, required this.rc, this.active = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? rc.accent : rc.card,
        border: active ? null : Border.all(color: rc.line),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: hanken(size: 11, weight: FontWeight.w700, color: active ? Colors.white : rc.ink)),
          const SizedBox(width: 5),
          Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: active ? Colors.white : rc.muted),
        ],
      ),
    );
  }
}
