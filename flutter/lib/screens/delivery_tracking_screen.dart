import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'reviews_screen.dart';

class DeliveryTrackingScreen extends StatelessWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return Scaffold(
      backgroundColor: rc.bg,
      appBar: RScreenHeader(title: 'Buyurtma #RV-2841'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
              decoration: BoxDecoration(color: rc.accent, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Yetkazish kutilmoqda', style: hanken(size: 11, color: Colors.white.withValues(alpha: 0.85))),
                  const SizedBox(height: 3),
                  Text('Ertaga, 14:00–18:00', style: spectral(size: 21, weight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Kuryer: Sardor · +998 90 *** 12 34', style: hanken(size: 11, color: Colors.white.withValues(alpha: 0.85))),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Step(title: 'Buyurtma qabul qilindi', subtitle: 'Bugun, 09:12', state: _StepState.done, rc: rc),
                    _Step(title: "Sotuvchi jo'natdi", subtitle: 'Bugun, 13:40', state: _StepState.done, rc: rc),
                    _Step(title: "Yo'lda", subtitle: 'Toshkent sortlash markazi', state: _StepState.active, rc: rc),
                    _Step(title: 'Yetkazildi', subtitle: 'Kutilmoqda', state: _StepState.pending, isLast: true, rc: rc),
                  ],
                ),
              ),
            ),
            RSecondaryButton(
              label: 'Kuryerga qo\'ng\'iroq',
              icon: Icons.phone_rounded,
              onTap: () {},
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => ReviewsScreen.show(context, peerName: 'Tashkent Realty', peerInitials: 'TR'),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Center(child: Text('Yetkazilgach sharh qoldirish', style: hanken(size: 11.5, weight: FontWeight.w700, color: rc.muted))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _StepState { done, active, pending }

class _Step extends StatelessWidget {
  final String title, subtitle;
  final _StepState state;
  final bool isLast;
  final RC rc;
  const _Step({required this.title, required this.subtitle, required this.state, this.isLast = false, required this.rc});

  @override
  Widget build(BuildContext context) {
    final done = state == _StepState.done;
    final active = state == _StepState.active;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? const Color(0xFF2F9E5C) : active ? rc.accent : rc.bg,
                  border: !done && !active ? Border.all(color: rc.line, width: 2) : null,
                  boxShadow: active ? [BoxShadow(color: const Color(0xFFFBEEE4), blurRadius: 0, spreadRadius: 4)] : null,
                ),
                child: Icon(
                  done ? Icons.check_rounded : active ? Icons.local_shipping_outlined : Icons.house_outlined,
                  size: 13,
                  color: done || active ? Colors.white : rc.muted,
                ),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: rc.line)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: hanken(size: 12.5, weight: FontWeight.w700, color: active ? rc.accent : (state == _StepState.pending ? rc.muted : rc.ink))),
                  Text(subtitle, style: hanken(size: 10, color: rc.muted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
