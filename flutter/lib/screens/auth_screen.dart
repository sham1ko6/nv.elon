import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api.dart' as api;
import '../app_state.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../widgets/ravoq_shield.dart';
import 'main_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Step 0 = phone, Step 1 = OTP
  int _step = 0;
  String _phone = '';          // 9 digits
  String _otp = '';            // 6 digits
  bool _loading = false;
  String? _error;
  int _resendSec = 60;
  Timer? _timer;

  // ── Numpad input ─────────────────────────────────────────────

  void _numpad(String d) {
    setState(() {
      _error = null;
      if (_step == 0) {
        if (d == '⌫') {
          if (_phone.isNotEmpty) _phone = _phone.substring(0, _phone.length - 1);
        } else if (_phone.length < 9) {
          _phone += d;
        }
      } else {
        if (d == '⌫') {
          if (_otp.isNotEmpty) _otp = _otp.substring(0, _otp.length - 1);
        } else if (_otp.length < 6) {
          _otp += d;
        }
      }
    });

    if (_step == 1 && _otp.length == 6) _verify();
  }

  // ── Actions ───────────────────────────────────────────────────

  Future<void> _sendCode() async {
    if (_phone.length != 9) return;
    setState(() { _loading = true; _error = null; });
    try {
      await api.sendOtp('+998$_phone');
      if (!mounted) return;
      setState(() { _step = 1; _loading = false; _resendSec = 60; });
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  Future<void> _verify() async {
    if (_otp.length != 6) return;
    setState(() { _loading = true; _error = null; });
    try {
      final res = await api.verifyOtp('+998$_phone', _otp);
      if (!mounted) return;
      final state = AppStateScope.of(context);
      state.setAuth(
        res['accessToken'] as String,
        res['user'] as Map<String, dynamic>,
        refreshToken: res['refreshToken'] as String?,
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _otp = '';
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSec <= 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _resendSec--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return Scaffold(
      backgroundColor: rc.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_step == 1) {
                        setState(() { _step = 0; _otp = ''; _error = null; _timer?.cancel(); });
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: rc.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: rc.line),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: rc.ink, size: 15),
                    ),
                  ),
                ],
              ),
            ),
            // Centered hero: shield + wordmark + helper text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  const RavoqShield(size: 56),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: spectral(size: 30, weight: FontWeight.w800, color: rc.ink),
                      children: [
                        const TextSpan(text: 'Ravoq'),
                        TextSpan(text: '.', style: TextStyle(color: rc.accent)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _step == 0
                        ? S.get('enterPhone')
                        : '${S.get('codeSent')} +998 ${_phone.substring(0, 2)} *** ** ${_phone.substring(7)}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.hankenGrotesk(fontSize: 12.5, color: rc.muted, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display
                  _step == 0 ? _PhoneDisplay(phone: _phone, rc: rc) : _OtpDisplay(otp: _otp, rc: rc),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!,
                        style: GoogleFonts.hankenGrotesk(
                            fontSize: 12, color: Colors.red)),
                  ],
                  if (_step == 1) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(S.get('resend') + ' ',
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 13, color: rc.muted)),
                        if (_resendSec > 0)
                          Text(
                            '00:${_resendSec.toString().padLeft(2, '0')}',
                            style: GoogleFonts.hankenGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: cAccent),
                          )
                        else
                          GestureDetector(
                            onTap: () { setState(() { _otp = ''; }); _sendCode(); },
                            child: Text(S.get('resend'),
                                style: GoogleFonts.hankenGrotesk(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: cAccent,
                                    decoration: TextDecoration.underline)),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            // Numpad
            _Numpad(onTap: _numpad),
            const SizedBox(height: 16),
            // Action button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: cAccent))
                  : GestureDetector(
                      onTap: _step == 0
                          ? (_phone.length == 9 ? _sendCode : null)
                          : (_otp.length == 6 ? _verify : null),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 52,
                        decoration: BoxDecoration(
                          color: (_step == 0 ? _phone.length == 9 : _otp.length == 6)
                              ? cAccent
                              : rc.line,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            _step == 0 ? S.get('sendCode') : S.get('verify'),
                            style: GoogleFonts.hankenGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: (_step == 0 ? _phone.length == 9 : _otp.length == 6)
                                  ? Colors.white
                                  : rc.muted,
                            ),
                          ),
                        ),
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

// ── Phone display ─────────────────────────────────────────────

class _PhoneDisplay extends StatelessWidget {
  final String phone;
  final RC rc;
  const _PhoneDisplay({required this.phone, required this.rc});

  @override
  Widget build(BuildContext context) {
    final display = '+998 ${phone.padRight(9, ' ').split('').take(2).join()} '
        '${phone.length > 2 ? phone.substring(2, phone.length.clamp(0, 5)).padRight(3, ' ') : '   '} '
        '${phone.length > 5 ? phone.substring(5, phone.length.clamp(0, 7)).padRight(2, ' ') : '  '} '
        '${phone.length > 7 ? phone.substring(7) : ''}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: rc.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: phone.isNotEmpty ? cAccent : rc.line),
      ),
      child: Text(
        display,
        style: GoogleFonts.spectral(
            fontSize: 22, fontWeight: FontWeight.w600, color: rc.ink, letterSpacing: 2),
      ),
    );
  }
}

// ── OTP display ───────────────────────────────────────────────

class _OtpDisplay extends StatelessWidget {
  final String otp;
  final RC rc;
  const _OtpDisplay({required this.otp, required this.rc});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        final filled = i < otp.length;
        final active = i == otp.length;
        return Container(
          width: 48,
          height: 58,
          decoration: BoxDecoration(
            color: rc.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? cAccent : (filled ? cAccentDk : rc.line),
              width: active ? 2 : 1.5,
            ),
          ),
          child: Center(
            child: Text(
              filled ? otp[i] : '',
              style: GoogleFonts.spectral(
                  fontSize: 24, fontWeight: FontWeight.w700, color: rc.ink),
            ),
          ),
        );
      }),
    );
  }
}

// ── Numpad ────────────────────────────────────────────────────

class _Numpad extends StatelessWidget {
  final ValueChanged<String> onTap;
  const _Numpad({required this.onTap});

  static const _keys = [
    '1', '2', '3',
    '4', '5', '6',
    '7', '8', '9',
    '',  '0', '⌫',
  ];

  @override
  Widget build(BuildContext context) {
    final rc = RC.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.0,
        ),
        itemCount: _keys.length,
        itemBuilder: (_, i) {
          final k = _keys[i];
          if (k.isEmpty) return const SizedBox();
          return GestureDetector(
            onTap: () => onTap(k),
            child: Container(
              decoration: BoxDecoration(
                color: rc.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: rc.line),
              ),
              child: Center(
                child: k == '⌫'
                    ? Icon(Icons.backspace_outlined, size: 20, color: rc.ink)
                    : Text(
                        k,
                        style: GoogleFonts.spectral(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: rc.ink,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
