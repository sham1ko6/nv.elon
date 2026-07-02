import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'messages_screen.dart';

class AiPriceScreen extends StatelessWidget {
  final Listing listing;
  const AiPriceScreen({super.key, required this.listing});

  static const _bars = [65, 72, 78, 88, 95];

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    final maxBar = _bars.reduce((a, b) => a > b ? a : b).toDouble();

    return Scaffold(
      backgroundColor: rc.bg,
      appBar: RScreenHeader(title: 'Narx tahlili'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1F7A44), Color(0xFF2F9E5C)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 17),
                      const SizedBox(width: 7),
                      Text('YAXSHI NARX', style: hanken(size: 11, weight: FontWeight.w800, color: Colors.white).copyWith(letterSpacing: 1.2)),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text('12% arzon', style: spectral(size: 30, weight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text("Bozordagi o'xshash e'lonlarga nisbatan. AI 86 ta e'lonni tahlil qildi.",
                      style: hanken(size: 11.5, color: Colors.white.withValues(alpha: 0.9), height: 1.45)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: rc.card, border: Border.all(color: rc.line), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Bozor narx oralig'i", style: hanken(size: 11, weight: FontWeight.w700, color: rc.ink)),
                  const SizedBox(height: 13),
                  SizedBox(
                    height: 96,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(_bars.length, (i) {
                        final isMe = i == 2;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isMe) Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text("Bu e'lon", style: hanken(size: 8.5, weight: FontWeight.w800, color: rc.accent)),
                                ),
                                Container(
                                  height: (_bars[i] / maxBar) * 70,
                                  decoration: BoxDecoration(
                                    color: isMe ? rc.accent : rc.line,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text('${_bars[i]}k', style: hanken(size: 8, weight: isMe ? FontWeight.w700 : FontWeight.w400, color: isMe ? rc.accent : rc.muted)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 11),
                    child: Container(
                      padding: const EdgeInsets.only(top: 11),
                      decoration: BoxDecoration(border: Border(top: BorderSide(color: rc.line))),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("O'rtacha narx", style: hanken(size: 9.5, color: rc.muted)),
                                Text('\$88 600', style: spectral(size: 15, weight: FontWeight.w700, color: rc.ink)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Siz tejaysiz', style: hanken(size: 9.5, color: rc.muted)),
                              Text('~\$10 600', style: spectral(size: 15, weight: FontWeight.w700, color: const Color(0xFF2F9E5C))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: rc.card, border: Border.all(color: rc.line), borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sotilish vaqti', style: hanken(size: 9.5, color: rc.muted)),
                        const SizedBox(height: 3),
                        Text('~9 kun', style: spectral(size: 16, weight: FontWeight.w700, color: rc.ink)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: rc.card, border: Border.all(color: rc.line), borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Talab darajasi', style: hanken(size: 9.5, color: rc.muted)),
                        const SizedBox(height: 3),
                        Text('Yuqori', style: spectral(size: 16, weight: FontWeight.w700, color: const Color(0xFF2F9E5C))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(color: rc.card, border: Border(top: BorderSide(color: rc.line))),
        child: RPrimaryButton(
          label: 'Sotuvchiga yozish',
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => MessagesScreen(peerName: listing.sellerName, peerInitials: listing.sellerName.isNotEmpty ? listing.sellerName[0] : '?', listing: listing),
          )),
        ),
      ),
    );
  }
}
