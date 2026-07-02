import 'package:flutter/material.dart';
import '../theme.dart';
import 'payment_screen.dart';

class BusinessPlansScreen extends StatelessWidget {
  const BusinessPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cInk,
      body: SafeArea(
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
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: Column(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: cAmber, size: 34),
                    const SizedBox(height: 9),
                    Text('Biznes uchun Ravoq', style: spectral(size: 23, weight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 5),
                    Text("Ko'proq soting — do'kon, statistika va reklama bilan.",
                        textAlign: TextAlign.center,
                        style: hanken(size: 12, color: Colors.white.withValues(alpha: 0.65), height: 1.5)),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Start', style: hanken(size: 12, weight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.8))),
                                const SizedBox(height: 6),
                                RichText(
                                  text: TextSpan(
                                    style: spectral(size: 22, weight: FontWeight.w800, color: Colors.white),
                                    children: [
                                      const TextSpan(text: '99 000'),
                                      TextSpan(text: '/oy', style: hanken(size: 11, weight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.55))),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
                                ),
                                ...['30 ta e\'lon', "Do'kon sahifasi", 'Asosiy statistika']
                                    .map((f) => Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Text('✓ $f', style: hanken(size: 10.5, color: Colors.white.withValues(alpha: 0.75))),
                                        )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFD27044), Color(0xFFA8472A)]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: const Color(0xFF783719).withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 12))],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  top: -24, right: -2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: cAmber, borderRadius: BorderRadius.circular(6)),
                                    child: Text('OMMABOP', style: hanken(size: 8.5, weight: FontWeight.w800, color: cInk).copyWith(letterSpacing: 0.4)),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Pro', style: hanken(size: 12, weight: FontWeight.w700, color: Colors.white)),
                                    const SizedBox(height: 6),
                                    RichText(
                                      text: TextSpan(
                                        style: spectral(size: 22, weight: FontWeight.w800, color: Colors.white),
                                        children: [
                                          const TextSpan(text: '249 000'),
                                          TextSpan(text: '/oy', style: hanken(size: 11, weight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7))),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: Container(height: 1, color: Colors.white.withValues(alpha: 0.22)),
                                    ),
                                    ...['Cheksiz e\'lon', 'Avto TOP ko\'tarish', "To'liq analitika", 'Reklama bannerlari']
                                        .map((f) => Padding(
                                              padding: const EdgeInsets.only(bottom: 8),
                                              child: Text('✓ $f', style: hanken(size: 10.5, color: Colors.white)),
                                            )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const PaymentScreen(amount: 249000, planLabel: 'Biznes Pro · 1 oy'),
                  )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cAmber,
                    foregroundColor: cInk,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text("Pro'ni tanlash", style: hanken(size: 14, weight: FontWeight.w800, color: cInk)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text("Istalgan vaqtda bekor qilasiz · Click, Payme, Uzum",
                  style: hanken(size: 10.5, color: Colors.white.withValues(alpha: 0.5))),
            ),
          ],
        ),
      ),
    );
  }
}
