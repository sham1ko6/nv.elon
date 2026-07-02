import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class CompareScreen extends StatelessWidget {
  final Listing a, b;
  const CompareScreen({super.key, required this.a, required this.b});

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    final rows = [
      ('Yil', '2021', '2019', true),
      ('Probeg', '42k', '87k', true),
      ('Motor', '2.0 L', '1.5 L', null),
      ('Uzatma', 'Avtomat', 'Mexanika', true),
      ('AI narx', 'Yaxshi', "O'rtacha", null),
    ];

    return Scaffold(
      backgroundColor: rc.bg,
      appBar: RScreenHeader(title: 'Solishtirish'),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _Card(l: a, rc: rc)),
                const SizedBox(width: 11),
                Expanded(child: _Card(l: b, rc: rc)),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(color: rc.card, border: Border.all(color: rc.line), borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: List.generate(rows.length, (i) {
                  final r = rows[i];
                  final shaded = i.isEven;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      color: shaded ? rc.bg : null,
                      border: i < rows.length - 1 ? Border(bottom: BorderSide(color: rc.line)) : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(r.$1.toUpperCase(),
                              style: hanken(size: 10, weight: FontWeight.w700, color: rc.muted).copyWith(letterSpacing: 0.4)),
                        ),
                        Expanded(
                          child: Text(r.$2, textAlign: TextAlign.center,
                              style: hanken(size: 12, weight: r.$4 == true ? FontWeight.w700 : FontWeight.w600,
                                  color: r.$4 == true ? const Color(0xFF2F9E5C) : rc.ink)),
                        ),
                        Expanded(
                          child: Text(r.$3, textAlign: TextAlign.center,
                              style: hanken(size: 12, weight: FontWeight.w600, color: rc.ink)),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: RPrimaryButton(label: "${a.title.split(' ').first}'ni tanlash", height: 44, onTap: () => Navigator.of(context).pop())),
                const SizedBox(width: 11),
                Expanded(child: RSecondaryButton(label: b.title.split(' ').first, height: 44, onTap: () => Navigator.of(context).pop())),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Listing l;
  final RC rc;
  const _Card({required this.l, required this.rc});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: rc.card, border: Border.all(color: rc.line), borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(l.imageUrl, height: 84, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 84, color: rc.line)),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: hanken(size: 11.5, weight: FontWeight.w700, color: rc.ink)),
                Text(l.formattedPrice, style: spectral(size: 14, weight: FontWeight.w700, color: rc.accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
