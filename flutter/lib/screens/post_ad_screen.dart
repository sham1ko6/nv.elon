// ============================================================
// screens/post_ad_screen.dart  –  Light "Post an ad" form
// ============================================================
// Collects the ad details, creates the ad on the backend (as "pending
// payment"), then sends the user to the Payment screen. The ad only goes
// live after payment, so this screen does NOT publish anything by itself.
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../mock_data.dart';
import '../models.dart'; // for the AppSubcategory type used in the dropdowns
import '../widgets/custom_text_field.dart';
import 'payment_screen.dart';

class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});
  @override
  State<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(text: '+998 90 ');
  final _locationCtrl = TextEditingController(text: 'Toshkent shahar');

  String _catId = kCategories.first.id;
  String _subId = kCategories.first.subcategories.first.id;
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  List<AppSubcategory> get _subs =>
      kCategories.firstWhere((c) => c.id == _catId).subcategories;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // 1) Create the ad on the backend; we get back an "order" to pay.
      final order = await AppStateProvider.of(context).createAd(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
        location: _locationCtrl.text.trim(),
        category: _catId,
        subcategory: _subId,
        contactPhone: _phoneCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _loading = false);

      // 2) Go to the Payment screen. After a successful payment, the success
      //    screen takes the user all the way back to the feed on its own.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            orderId: order['id'] as int,
            amount: (order['amount'] as num).toDouble(),
            currency: (order['currency'] ?? 'UZS').toString(),
            adTitle: _titleCtrl.text.trim(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text("E'lon berish")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            // Info note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text("E'lon joylash uchun bir martalik to'lov olinadi.",
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Image placeholder
            Container(
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(height: 6),
                  Text("Rasm qo'shish (ixtiyoriy)",
                      style: GoogleFonts.outfit(
                          fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel("E'lon ma'lumotlari"),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Sarlavha',
              hint: 'Masalan: Sotiladi – 3 xonali kvartira',
              controller: _titleCtrl,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Sarlavha kiriting' : null,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'Batafsil tavsif',
              hint: 'Mahsulot haqida batafsil...',
              controller: _descCtrl,
              maxLines: 4,
              validator: (v) => (v == null || v.trim().length < 10) ? 'Kamida 10 belgi' : null,
            ),
            const SizedBox(height: 20),

            _SectionLabel('Toifa va narx'),
            const SizedBox(height: 12),
            CustomDropdown(
              label: 'Asosiy toifa',
              value: _catId,
              items: kCategories
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Row(
                          children: [
                            Text(c.icon, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(c.uzName,
                                style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textPrimary)),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (id) {
                if (id == null) return;
                setState(() {
                  _catId = id;
                  _subId = kCategories.firstWhere((c) => c.id == id).subcategories.first.id;
                });
              },
            ),
            const SizedBox(height: 14),
            CustomDropdown(
              label: 'Kichik toifa',
              value: _subId,
              items: _subs
                  .map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(s.uzName,
                            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textPrimary)),
                      ))
                  .toList(),
              onChanged: (id) {
                if (id != null) setState(() => _subId = id);
              },
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'Narxi (USD)',
              hint: '0',
              controller: _priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Narx kiriting';
                if (double.tryParse(v.trim()) == null) return 'Faqat raqam';
                return null;
              },
            ),
            const SizedBox(height: 20),

            _SectionLabel('Aloqa va joylashuv'),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Telefon raqam',
              hint: '+998 90 123 45 67',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().length < 9) ? 'Telefon kiriting' : null,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'Hudud / Manzil',
              hint: 'Toshkent shahar...',
              controller: _locationCtrl,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Manzil kiriting' : null,
            ),
            const SizedBox(height: 28),

            // Continue → Payment
            Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.30), blurRadius: 14, offset: const Offset(0, 6)),
                ],
              ),
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(color: AppColors.onPrimary, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("To'lovga o'tish",
                              style: GoogleFonts.outfit(
                                  fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onPrimary)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.onPrimary),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 16,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: AppColors.primaryGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: GoogleFonts.outfit(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }
}
