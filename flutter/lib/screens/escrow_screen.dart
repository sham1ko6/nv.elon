import 'package:flutter/material.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'delivery_tracking_screen.dart';

class EscrowScreen extends StatefulWidget {
  final Listing listing;
  const EscrowScreen({super.key, required this.listing});

  @override
  State<EscrowScreen> createState() => _EscrowScreenState();
}

class _EscrowScreenState extends State<EscrowScreen> {
  bool _delivery = true;

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    final l = widget.listing;
    final deliveryFee = _delivery ? 25000 : 0;
    final serviceFee = (l.price * 0.02).round();
    final total = l.price + (deliveryFee / (l.currency == 'USD' ? 12800 : 1)) + serviceFee;

    return Scaffold(
      backgroundColor: rc.bg,
      appBar: RScreenHeader(title: 'Xavfsiz savdo'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: rc.card, border: Border.all(color: rc.line), borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(l.imageUrl, width: 58, height: 58, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 58, height: 58, color: rc.line)),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: hanken(size: 12.5, weight: FontWeight.w600, color: rc.ink)),
                        Text(l.formattedPrice, style: spectral(size: 15, weight: FontWeight.w700, color: rc.accent)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: const Color(0xFFE9F4EC), border: Border.all(color: const Color(0xFFBFE0C9)), borderRadius: BorderRadius.circular(14)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(color: const Color(0xFF2F9E5C), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.shield_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pul kafolatlangan', style: hanken(size: 12.5, weight: FontWeight.w700, color: const Color(0xFF1F7A44))),
                        const SizedBox(height: 2),
                        Text("To'lov mahsulotni qabul qilguningizgacha Ravoq hisobida turadi.",
                            style: hanken(size: 10.5, color: const Color(0xFF3D7A55), height: 1.45)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Yetkazib berish', style: hanken(size: 11, weight: FontWeight.w700, color: rc.ink)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _delivery = true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                margin: const EdgeInsets.only(bottom: 9),
                decoration: BoxDecoration(
                  color: rc.card,
                  border: Border.all(color: _delivery ? rc.accent : rc.line, width: _delivery ? 2 : 1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_shipping_outlined, color: rc.accent, size: 20),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ravoq Yetkazib berish', style: hanken(size: 12.5, weight: FontWeight.w700, color: rc.ink)),
                          Text("2–3 kun · butun O'zbekiston bo'ylab", style: hanken(size: 10, color: rc.muted)),
                        ],
                      ),
                    ),
                    Text('25 000', style: spectral(size: 13, weight: FontWeight.w700, color: rc.accent)),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _delivery = false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: rc.card,
                  border: Border.all(color: !_delivery ? rc.accent : rc.line, width: !_delivery ? 2 : 1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: rc.muted, size: 20),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("O'zim olib ketaman", style: hanken(size: 12.5, weight: FontWeight.w700, color: rc.ink)),
                          Text('Sotuvchi bilan kelishilgan joyda', style: hanken(size: 10, color: rc.muted)),
                        ],
                      ),
                    ),
                    Text('Bepul', style: hanken(size: 12, weight: FontWeight.w700, color: const Color(0xFF2F9E5C))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _row('Mahsulot', l.formattedPrice, rc),
            _row('Yetkazib berish', _delivery ? '\$2' : "Bepul", rc),
            _row('Xizmat haqi (2%)', '\$$serviceFee', rc),
            const SizedBox(height: 90),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(color: rc.card, border: Border(top: BorderSide(color: rc.line))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Jami', style: hanken(size: 12, weight: FontWeight.w600, color: rc.muted)),
                const Spacer(),
                Text(l.currency == 'USD' ? '\$${total.toStringAsFixed(0)}' : '${total.toStringAsFixed(0)} so\'m',
                    style: spectral(size: 22, weight: FontWeight.w800, color: rc.ink)),
              ],
            ),
            const SizedBox(height: 10),
            RPrimaryButton(
              label: "Xavfsiz to'lash",
              icon: Icons.credit_card_rounded,
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const DeliveryTrackingScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, RC rc) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: hanken(size: 12, color: rc.muted)),
            Text(value, style: hanken(size: 12, weight: FontWeight.w600, color: rc.ink)),
          ],
        ),
      );
}
