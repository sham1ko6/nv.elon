// ============================================================
// screens/auth_screen.dart  –  Light Login / Sign-up
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Login controllers
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();
  bool _loginObscure = true;
  bool _loginLoading = false;

  // Register controllers
  final _regNameCtrl = TextEditingController();
  final _regPhoneCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regFormKey = GlobalKey<FormState>();
  bool _regObscure = true;
  bool _regLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regNameCtrl.dispose();
    _regPhoneCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  void _doLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _loginLoading = true);
    try {
      await AppStateProvider.of(context)
          .login(_loginEmailCtrl.text.trim(), _loginPassCtrl.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loginLoading = false);
    }
  }

  void _doRegister() async {
    if (!_regFormKey.currentState!.validate()) return;
    setState(() => _regLoading = true);
    try {
      await AppStateProvider.of(context).register(
        _regNameCtrl.text.trim(),
        _regPhoneCtrl.text.trim(),
        _regEmailCtrl.text.trim(),
        _regPassCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _regLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Logo header ──
            const SizedBox(height: 36),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.30),
                      blurRadius: 18,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: Center(
                child: Text('nv',
                    style: GoogleFonts.outfit(
                        fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.onPrimary)),
              ),
            ),
            const SizedBox(height: 14),
            Text('nv.elon',
                style: GoogleFonts.outfit(
                    fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context).appTagline,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 28),

            // ── White card with tabs + forms ──
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: kCardShadow,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Segmented tab control
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          gradient: const LinearGradient(colors: AppColors.primaryGradient),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: AppColors.onPrimary,
                        unselectedLabelColor: AppColors.textSecondary,
                        labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700),
                        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 13),
                        tabs: [
                          Tab(text: AppLocalizations.of(context).loginTab),
                          Tab(text: AppLocalizations.of(context).registerTab),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _LoginTab(
                            emailCtrl: _loginEmailCtrl,
                            passCtrl: _loginPassCtrl,
                            formKey: _loginFormKey,
                            obscure: _loginObscure,
                            loading: _loginLoading,
                            onObscureToggle: () =>
                                setState(() => _loginObscure = !_loginObscure),
                            onSubmit: _doLogin,
                          ),
                          _RegisterTab(
                            nameCtrl: _regNameCtrl,
                            phoneCtrl: _regPhoneCtrl,
                            emailCtrl: _regEmailCtrl,
                            passCtrl: _regPassCtrl,
                            formKey: _regFormKey,
                            obscure: _regObscure,
                            loading: _regLoading,
                            onObscureToggle: () =>
                                setState(() => _regObscure = !_regObscure),
                            onSubmit: _doRegister,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A reusable gradient "pill" button used on both tabs.
class _GradientButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback onPressed;
  const _GradientButton({required this.text, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.primaryGradient),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.30), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: loading
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(color: AppColors.onPrimary, strokeWidth: 2))
            : Text(text,
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.onPrimary)),
      ),
    );
  }
}

// ── Login Tab ──
class _LoginTab extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final GlobalKey<FormState> formKey;
  final bool obscure;
  final bool loading;
  final VoidCallback onObscureToggle;
  final VoidCallback onSubmit;

  const _LoginTab({
    required this.emailCtrl,
    required this.passCtrl,
    required this.formKey,
    required this.obscure,
    required this.loading,
    required this.onObscureToggle,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: l.emailOrPhoneLabel,
              hint: 'email@example.com',
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.textHint),
              validator: (v) => (v == null || v.isEmpty) ? l.emailOrPhoneError : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: l.passwordLabel,
              hint: '••••••••',
              controller: passCtrl,
              obscureText: obscure,
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textHint),
              suffixIcon: IconButton(
                onPressed: onObscureToggle,
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18, color: AppColors.textHint),
              ),
              validator: (v) => (v == null || v.length < 4) ? l.passwordError : null,
            ),
            const SizedBox(height: 28),
            _GradientButton(text: l.loginBtn, loading: loading, onPressed: onSubmit),
            const SizedBox(height: 20),
            _DemoHint(),
          ],
        ),
      ),
    );
  }
}

// ── Register Tab ──
class _RegisterTab extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final GlobalKey<FormState> formKey;
  final bool obscure;
  final bool loading;
  final VoidCallback onObscureToggle;
  final VoidCallback onSubmit;

  const _RegisterTab({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.formKey,
    required this.obscure,
    required this.loading,
    required this.onObscureToggle,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: l.fullNameLabel,
              hint: l.nameHint,
              controller: nameCtrl,
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.textHint),
              validator: (v) => (v == null || v.isEmpty) ? l.nameError : null,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: l.phoneLabel,
              hint: '+998 90 000 00 00',
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: AppColors.textHint),
              validator: (v) => (v == null || v.length < 9) ? l.phoneError : null,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'Email',
              hint: 'email@example.com',
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppColors.textHint),
              validator: (v) => (v == null || v.isEmpty) ? l.emailError : null,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: l.passwordLabel,
              hint: l.passwordMinError,
              controller: passCtrl,
              obscureText: obscure,
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textHint),
              suffixIcon: IconButton(
                onPressed: onObscureToggle,
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18, color: AppColors.textHint),
              ),
              validator: (v) => (v == null || v.length < 6) ? l.passwordMinError : null,
            ),
            const SizedBox(height: 28),
            _GradientButton(text: l.registerBtn, loading: loading, onPressed: onSubmit),
          ],
        ),
      ),
    );
  }
}

class _DemoHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.registerFirstHint,
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
