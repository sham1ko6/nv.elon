import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return Scaffold(
      backgroundColor: rc.bg,
      appBar: RScreenHeader(title: 'Tasdiqlash'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Column(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(color: rc.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Icon(Icons.verified_user_rounded, color: rc.accent, size: 32),
                  ),
                  const SizedBox(height: 13),
                  Text('Ishonchli sotuvchi bo\'ling', style: spectral(size: 19, weight: FontWeight.w700, color: rc.ink)),
                  const SizedBox(height: 5),
                  Text('Tasdiqlangan sotuvchilar 3× ko\'proq sotadi va xaridorlar ishonadi.',
                      textAlign: TextAlign.center,
                      style: hanken(size: 12, color: rc.muted, height: 1.5)),
                  const SizedBox(height: 20),
                  _Step(
                    icon: Icons.check_circle_rounded,
                    iconBg: const Color(0xFFE9F4EC),
                    iconColor: const Color(0xFF2F9E5C),
                    title: 'Telefon raqami',
                    subtitle: 'Tasdiqlangan',
                    subtitleColor: const Color(0xFF2F9E5C),
                    rc: rc,
                  ),
                  const SizedBox(height: 11),
                  _Step(
                    icon: Icons.badge_outlined,
                    iconBg: const Color(0xFFFBEEE4),
                    iconColor: rc.accent,
                    title: 'Pasport / ID karta',
                    subtitle: 'Rasmga oling — 1 daqiqa',
                    subtitleColor: rc.muted,
                    active: true,
                    trailing: true,
                    rc: rc,
                  ),
                  const SizedBox(height: 11),
                  Opacity(
                    opacity: 0.6,
                    child: _Step(
                      icon: Icons.face_retouching_natural_rounded,
                      iconBg: rc.bg,
                      iconColor: rc.muted,
                      title: 'Selfi tekshiruvi',
                      subtitle: 'Keyingi qadam',
                      subtitleColor: rc.muted,
                      rc: rc,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                    decoration: BoxDecoration(color: const Color(0xFFE9F4EC), border: Border.all(color: const Color(0xFFBFE0C9)), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 15, color: Color(0xFF1F7A44)),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text("Ma'lumotlaringiz shifrlanadi va faqat tekshirish uchun ishlatiladi.",
                              style: hanken(size: 10.5, color: const Color(0xFF3D7A55), height: 1.45)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(color: rc.card, border: Border(top: BorderSide(color: rc.line))),
            child: RPrimaryButton(
              label: 'Hujjatni rasmga olish',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kamera ochilmoqda…')));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final Color subtitleColor;
  final bool active;
  final bool trailing;
  final RC rc;
  const _Step({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.title, required this.subtitle, required this.subtitleColor,
    this.active = false, this.trailing = false, required this.rc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: rc.card,
        border: Border.all(color: active ? rc.accent : rc.line, width: active ? 2 : 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: hanken(size: 12.5, weight: FontWeight.w700, color: rc.ink)),
                Text(subtitle, style: hanken(size: 10, weight: FontWeight.w600, color: subtitleColor)),
              ],
            ),
          ),
          if (trailing) Icon(Icons.chevron_right_rounded, size: 18, color: rc.accent),
        ],
      ),
    );
  }
}
