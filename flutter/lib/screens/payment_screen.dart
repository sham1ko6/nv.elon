import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';

class PaymentScreen extends StatefulWidget {
  final num amount;
  final String planLabel;
  const PaymentScreen({super.key, required this.amount, required this.planLabel});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'click';

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    final amountStr = widget.amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');

    return Scaffold(
      backgroundColor: rc.bg,
      appBar: RScreenHeader(title: "To'lov usuli"),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: rc.card, border: Border.all(color: rc.line), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Text("To'lov summasi", style: hanken(size: 11, color: rc.muted)),
                        const SizedBox(height: 3),
                        RichText(
                          text: TextSpan(
                            style: spectral(size: 30, weight: FontWeight.w800, color: rc.ink),
                            children: [
                              TextSpan(text: amountStr),
                              TextSpan(text: " so'm", style: hanken(size: 15, color: rc.muted)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(widget.planLabel, style: hanken(size: 10.5, color: rc.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RLabel("To'lov tizimini tanlang"),
                  ),
                  const SizedBox(height: 10),
                  _Method(id: 'click', label: 'Click', bg: const Color(0xFF00AEEF), fg: Colors.white, group: _method, onTap: (v) => setState(() => _method = v), rc: rc),
                  const SizedBox(height: 10),
                  _Method(id: 'payme', label: 'Payme', bg: const Color(0xFF33D6C9), fg: const Color(0xFF0A3D3A), group: _method, onTap: (v) => setState(() => _method = v), rc: rc),
                  const SizedBox(height: 10),
                  _Method(id: 'uzum', label: 'Uzum Bank', bg: const Color(0xFF7000FF), fg: Colors.white, group: _method, onTap: (v) => setState(() => _method = v), rc: rc),
                  const SizedBox(height: 10),
                  _Method(id: 'card', label: 'Bank kartasi', icon: Icons.credit_card_rounded, group: _method, onTap: (v) => setState(() => _method = v), rc: rc),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(color: rc.card, border: Border(top: BorderSide(color: rc.line))),
            child: RPrimaryButton(
              label: '$amountStr so\'m to\'lash',
              icon: Icons.lock_outline_rounded,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: rc.card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Text("To'lov muvaffaqiyatli", style: spectral(size: 17, weight: FontWeight.w700, color: rc.ink)),
                    content: Text('$amountStr so\'m to\'landi.', style: hanken(size: 13, color: rc.muted)),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        },
                        child: Text('OK', style: hanken(size: 13, weight: FontWeight.w700, color: rc.accent)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Method extends StatelessWidget {
  final String id, group;
  final String? label;
  final Color? bg, fg;
  final IconData? icon;
  final ValueChanged<String> onTap;
  final RC rc;
  const _Method({required this.id, required this.group, this.label, this.bg, this.fg, this.icon, required this.onTap, required this.rc});

  @override
  Widget build(BuildContext context) {
    final active = id == group;
    return GestureDetector(
      onTap: () => onTap(id),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: rc.card,
          border: Border.all(color: active ? rc.accent : rc.line, width: active ? 2 : 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 32,
              decoration: BoxDecoration(color: bg ?? rc.bg, border: bg == null ? Border.all(color: rc.line) : null, borderRadius: BorderRadius.circular(7)),
              alignment: Alignment.center,
              child: icon != null
                  ? Icon(icon, size: 18, color: rc.muted)
                  : Text(label!, style: spectral(size: 11, weight: FontWeight.w800, color: fg)),
            ),
            const SizedBox(width: 13),
            Expanded(child: Text(label ?? 'Bank kartasi', style: hanken(size: 13, weight: FontWeight.w700, color: rc.ink))),
            if (active) Icon(Icons.check_circle_rounded, color: rc.accent, size: 20),
          ],
        ),
      ),
    );
  }
}
