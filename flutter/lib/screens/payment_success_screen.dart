// ============================================================
// screens/payment_success_screen.dart  –  "Ad published" confirmation
// ============================================================
// Shown after a successful payment. Tapping the button clears the posting
// flow and returns the user to the main feed.
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String adTitle;
  const PaymentSuccessScreen({super.key, required this.adTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Green success check
              Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 56),
              ),
              const SizedBox(height: 28),
              Text("To'lov muvaffaqiyatli!",
                  style: GoogleFonts.outfit(
                      fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Text("E'loningiz e'lon qilindi va endi hammaga ko'rinadi.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5, color: AppColors.textSecondary, height: 1.5)),
              const SizedBox(height: 6),
              Text('"$adTitle"',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: AppColors.textHint, fontStyle: FontStyle.italic)),
              const SizedBox(height: 36),
              // Done → return true to the previous screens
              SizedBox(
                width: double.infinity,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withValues(alpha: 0.30), blurRadius: 14, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: ElevatedButton(
                    // Pop everything in the posting flow → back to the feed.
                    onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    ),
                    child: Text("E'lonlarga qaytish",
                        style: GoogleFonts.outfit(
                            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onPrimary)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
