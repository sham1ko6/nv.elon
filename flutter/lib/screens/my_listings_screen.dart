import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});
  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  int _tab = 0;
  final _active = kMockListings.take(2).toList();

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return Scaffold(
      backgroundColor: rc.bg,
      appBar: RScreenHeader(title: "Mening e'lonlarim"),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: rc.card, border: Border(bottom: BorderSide(color: rc.line))),
            child: Row(
              children: [
                _Tab(label: 'Faol 3', active: _tab == 0, onTap: () => setState(() => _tab = 0), rc: rc),
                const SizedBox(width: 18),
                _Tab(label: 'Sotilgan 12', active: _tab == 1, onTap: () => setState(() => _tab = 1), rc: rc),
                const SizedBox(width: 18),
                _Tab(label: 'Arxiv', active: _tab == 2, onTap: () => setState(() => _tab = 2), rc: rc),
              ],
            ),
          ),
          Expanded(
            child: _tab != 0
                ? Center(
                    child: REmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: _tab == 1 ? "Sotilgan e'lonlar yo'q" : "Arxiv bo'sh",
                      subtitle: 'Bu yerda hozircha hech narsa yo\'q.',
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _ListingCard(l: _active[0], top: true, rc: rc),
                      const SizedBox(height: 12),
                      _ListingCard(l: _active[1], top: false, rc: rc),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final RC rc;
  const _Tab({required this.label, required this.active, required this.onTap, required this.rc});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: active ? rc.accent : Colors.transparent, width: 2))),
        child: Text(label, style: hanken(size: 12.5, weight: FontWeight.w700, color: active ? rc.accent : rc.muted)),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final Listing l;
  final bool top;
  final RC rc;
  const _ListingCard({required this.l, required this.top, required this.rc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: rc.card, border: Border.all(color: rc.line), borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(l.imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: rc.line)),
                  ),
                  if (top)
                    Positioned(
                      top: 3, left: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(color: cAmber, borderRadius: BorderRadius.circular(4)),
                        child: Text('TOP', style: hanken(size: 7, weight: FontWeight.w800, color: cInk)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: hanken(size: 12.5, weight: FontWeight.w600, color: rc.ink)),
                    Text(l.formattedPrice, style: spectral(size: 14, weight: FontWeight.w700, color: rc.accent)),
                    Row(
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF2F9E5C))),
                        const SizedBox(width: 4),
                        Text('Faol', style: hanken(size: 9.5, weight: FontWeight.w700, color: const Color(0xFF2F9E5C))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (top) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: rc.line))),
              child: Row(
                children: [
                  Icon(Icons.remove_red_eye_outlined, size: 12, color: rc.muted),
                  const SizedBox(width: 4),
                  Text('320', style: hanken(size: 10.5, color: rc.muted)),
                  const SizedBox(width: 14),
                  Icon(Icons.favorite_border_rounded, size: 12, color: rc.muted),
                  const SizedBox(width: 4),
                  Text('18', style: hanken(size: 10.5, color: rc.muted)),
                  const SizedBox(width: 14),
                  Icon(Icons.chat_bubble_outline_rounded, size: 12, color: rc.muted),
                  const SizedBox(width: 4),
                  Text('5', style: hanken(size: 10.5, color: rc.muted)),
                  const Spacer(),
                  Text('Tahrirlash', style: hanken(size: 10.5, weight: FontWeight.w700, color: rc.accent)),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
            RSecondaryButton(label: "TOP'ga ko'tarish", icon: Icons.auto_awesome_rounded, height: 36, onTap: () {}),
          ],
        ],
      ),
    );
  }
}
