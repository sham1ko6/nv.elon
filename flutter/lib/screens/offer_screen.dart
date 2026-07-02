import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

class OfferScreen extends StatefulWidget {
  final Listing listing;
  const OfferScreen({super.key, required this.listing});

  static Future<void> show(BuildContext context, Listing listing) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OfferScreen(listing: listing),
    );
  }

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  late double _offer;

  @override
  void initState() {
    super.initState();
    _offer = (widget.listing.price * 0.92).roundToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    final l = widget.listing;
    final diff = l.price - _offer;
    final pct = (diff / l.price * 100).round();
    final options = [l.price * 0.9, l.price * 0.923, l.price * 0.96];

    return Container(
      decoration: BoxDecoration(color: rc.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(18, 10, 18, MediaQuery.of(context).padding.bottom + 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: RDragHandle()),
          Text('Narx taklif qiling', style: spectral(size: 19, weight: FontWeight.w700, color: rc.ink)),
          const SizedBox(height: 4),
          Text('Sotuvchi bilan kelishing — bozordagidek.', style: hanken(size: 11.5, color: rc.muted)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: rc.card, border: Border.all(color: rc.line), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(l.imageUrl, width: 50, height: 50, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: rc.line)),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.title, style: hanken(size: 12, weight: FontWeight.w600, color: rc.ink)),
                      RichText(
                        text: TextSpan(
                          style: hanken(size: 10.5, color: rc.muted),
                          children: [
                            const TextSpan(text: "So'rayotgan narx: "),
                            TextSpan(text: l.formattedPrice, style: hanken(size: 10.5, weight: FontWeight.w700, color: rc.ink)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text('SIZNING TAKLIFINGIZ', style: hanken(size: 11, weight: FontWeight.w700, color: rc.muted).copyWith(letterSpacing: 0.6)),
                const SizedBox(height: 6),
                Text(l.currency == 'USD' ? '\$${_offer.toInt()}' : '${_offer.toInt()} so\'m',
                    style: spectral(size: 38, weight: FontWeight.w800, color: rc.accent)),
                const SizedBox(height: 2),
                Text('\$${diff.toInt()} ($pct%) past', style: hanken(size: 11, weight: FontWeight.w600, color: const Color(0xFF2F9E5C))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: options.map((v) {
              final active = v == options[1];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _offer = v.roundToDouble()),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? rc.accent : rc.card,
                      border: active ? null : Border.all(color: rc.line),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: Text('\$${v.toInt()}', style: hanken(size: 12, weight: FontWeight.w700, color: active ? Colors.white : rc.ink)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFFBEEE4), border: Border.all(color: const Color(0xFFECCDB6)), borderRadius: BorderRadius.circular(12)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 15, color: rc.accent),
                const SizedBox(width: 9),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: hanken(size: 10.5, color: const Color(0xFF8A5333), height: 1.45),
                      children: const [
                        TextSpan(text: 'Bu modeldagi sotuvchilar odatda '),
                        TextSpan(text: '5–9%', style: TextStyle(fontWeight: FontWeight.w700)),
                        TextSpan(text: ' chegirma beradi.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          RPrimaryButton(
            label: 'Taklifni yuborish',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
