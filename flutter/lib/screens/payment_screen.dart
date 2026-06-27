// ============================================================
// screens/payment_screen.dart  –  Choose Payme or Click, then pay
// ============================================================
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../models.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final int orderId;
  final double amount;
  final String currency;
  final String adTitle;
  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.adTitle,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _provider = 'payme';
  bool _busy = false;
  bool _polling = false;

  String get _amountText =>
      Listing.formatPrice(widget.amount, widget.currency);

  void _err(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.danger));

  // Real payment: open Payme/Click URL then poll for confirmation.
  Future<void> _payReal() async {
    setState(() => _busy = true);
    try {
      final url = await AppStateProvider.of(context)
          .getPaymentUrl(widget.orderId, _provider);
      final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!ok) {
        if (mounted) _err("To'lov sahifasini ochib bo'lmadi.");
        setState(() => _busy = false);
        return;
      }
      // Poll for up to 2 minutes (40 × 3 s).
      await _pollForPayment();
    } catch (e) {
      if (mounted) {
        _err(e.toString());
        setState(() { _busy = false; _polling = false; });
      }
    }
  }

  Future<void> _pollForPayment() async {
    setState(() => _polling = true);
    const maxAttempts = 40;
    for (var i = 0; i < maxAttempts; i++) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      try {
        final orders = await AppStateProvider.of(context).getMyOrders();
        Map<String, dynamic>? order;
        for (final o in orders) {
          final m = o as Map<String, dynamic>;
          if (m['id'] == widget.orderId) {
            order = m;
            break;
          }
        }
        if (order != null && order['status'] == 'paid') {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (_) =>
                    PaymentSuccessScreen(adTitle: widget.adTitle)),
          );
          return;
        }
      } catch (_) {
        // Ignore individual poll errors; keep trying.
      }
    }
    // Timed out
    if (mounted) {
      _err("To'lov tasdiqlanmadi, qayta urinib ko'ring.");
      setState(() { _busy = false; _polling = false; });
    }
  }

  // Test mode: simulate payment so the ad activates immediately.
  Future<void> _payTest() async {
    setState(() => _busy = true);
    try {
      await AppStateProvider.of(context).simulatePayment(widget.orderId);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) => PaymentSuccessScreen(adTitle: widget.adTitle)),
      );
    } catch (e) {
      if (mounted) {
        _err(e.toString());
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text("To'lov")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Order summary ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: kCardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("E'lon joylash to'lovi",
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Text(_amountText,
                    style: GoogleFonts.outfit(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.sell_outlined,
                        size: 14, color: AppColors.textHint),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(widget.adTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text("To'lov usulini tanlang",
              style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),

          _ProviderCard(
            name: 'Payme',
            subtitle: "Payme orqali to'lov",
            color: const Color(0xFF33CCCC),
            selected: _provider == 'payme',
            onTap: () => setState(() => _provider = 'payme'),
          ),
          const SizedBox(height: 12),
          _ProviderCard(
            name: 'Click',
            subtitle: "Click orqali to'lov",
            color: const Color(0xFF00AEEF),
            selected: _provider == 'click',
            onTap: () => setState(() => _provider = 'click'),
          ),

          const SizedBox(height: 28),

          // ── Real payment button ──
          _GradientButton(
            label: _polling
                ? "To'lov kutilmoqda..."
                : (_busy ? '...' : "To'lash"),
            busy: _busy,
            onTap: _busy ? null : _payReal,
          ),

          // Polling spinner
          if (_polling) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary))),
                const SizedBox(width: 10),
                Text("To'lov tasdiqlanishi kutilmoqda...",
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ],

          // ── Test-mode button (debug builds only) ──
          if (kDebugMode) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _payTest,
              icon: const Icon(Icons.science_outlined,
                  size: 18, color: AppColors.textSecondary),
              label: Text("Test rejimi: to'lovni simulyatsiya qilish",
                  style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('Haqiqiy to\'lov uchun merchant hisob ulanishi kerak.',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: AppColors.textHint)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _ProviderCard({
    required this.name,
    required this.subtitle,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.8 : 1),
          boxShadow: kCardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.account_balance_wallet_rounded,
                  color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                    color: selected ? AppColors.primary : AppColors.textHint,
                    width: 2),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: AppColors.onPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback? onTap;
  const _GradientButton(
      {required this.label, required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.primaryGradient),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.30),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: busy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: AppColors.onPrimary, strokeWidth: 2))
            : Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary)),
      ),
    );
  }
}
