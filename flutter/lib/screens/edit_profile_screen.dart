// ============================================================
// screens/edit_profile_screen.dart  –  Edit name & phone
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = AppStateProvider.of(context).currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AppStateProvider.of(context).updateProfile(
        _nameCtrl.text.trim(),
        _phoneCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
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
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(l.editProfileTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            CustomTextField(
              label: l.fullNameLabel,
              hint: l.nameHint,
              controller: _nameCtrl,
              prefixIcon: const Icon(Icons.person_outline_rounded,
                  size: 18, color: AppColors.textHint),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.nameError : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: l.phoneLabel,
              hint: '+998 90 000 00 00',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined,
                  size: 18, color: AppColors.textHint),
              validator: (v) =>
                  (v == null || v.trim().length < 9) ? l.phoneError : null,
            ),
            const SizedBox(height: 28),
            Container(
              height: 52,
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: AppColors.onPrimary, strokeWidth: 2))
                    : Text(l.saveBtn,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onPrimary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
