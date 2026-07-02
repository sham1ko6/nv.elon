import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class InviteFriendScreen extends StatelessWidget {
  const InviteFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A2A1C),
      body: Stack(
        children: [
          Positioned(
            right: -40, top: 40,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(shape: BoxShape.circle, color: cAmber.withValues(alpha: 0.12)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                    child: Column(
                      children: [
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(color: cAmber.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(22)),
                          child: const Icon(Icons.group_add_rounded, color: cAmber, size: 36),
                        ),
                        const SizedBox(height: 16),
                        Text("Do'stingizni\ntaklif qiling", textAlign: TextAlign.center,
                            style: spectral(size: 24, weight: FontWeight.w800, color: Colors.white, height: 1.2)),
                        const SizedBox(height: 10),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: hanken(size: 12.5, color: Colors.white.withValues(alpha: 0.7), height: 1.55),
                            children: const [
                              TextSpan(text: "Har bir do'st birinchi e'lonini bersa — ikkalangizga ham "),
                              TextSpan(text: '1 ta bepul TOP ko\'tarish', style: TextStyle(color: cAmber, fontWeight: FontWeight.w700)),
                              TextSpan(text: '.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3), style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('BOBUR50', style: spectral(size: 19, weight: FontWeight.w800, color: Colors.white).copyWith(letterSpacing: 3)),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(const ClipboardData(text: 'BOBUR50'));
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nusxalandi')));
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.copy_rounded, size: 14, color: cAmber),
                                    const SizedBox(width: 5),
                                    Text('Nusxa', style: hanken(size: 11, weight: FontWeight.w700, color: cAmber)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _Stat(value: '8', label: 'Taklif qilingan'),
                            Container(width: 1, height: 30, margin: const EdgeInsets.symmetric(horizontal: 14), color: Colors.white.withValues(alpha: 0.15)),
                            _Stat(value: '6', label: 'Bonus olingan'),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cAmber,
                        foregroundColor: cInk,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 17),
                          const SizedBox(width: 9),
                          Text('Telegramda ulashish', style: hanken(size: 14, weight: FontWeight.w800, color: cInk)),
                        ],
                      ),
                    ),
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

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: spectral(size: 22, weight: FontWeight.w800, color: cAmber)),
        Text(label, style: hanken(size: 9.5, color: Colors.white.withValues(alpha: 0.6))),
      ],
    );
  }
}
