import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class RavoqShield extends StatelessWidget {
  final double size;
  final Color color;
  final Color? letterColor;

  const RavoqShield({
    super.key,
    this.size = 40,
    this.color = Colors.white,
    this.letterColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: CustomPaint(
        painter: _ShieldPainter(color: color),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: size * 0.06),
            child: Text(
              'R',
              style: GoogleFonts.spectral(
                fontSize: size * 0.52,
                fontWeight: FontWeight.w800,
                color: letterColor ?? (color == Colors.white ? cAccent : Colors.white),
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  final Color color;
  _ShieldPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.95, h * 0.10)
      ..cubicTo(w, h * 0.12, w, h * 0.14, w, h * 0.16)
      ..lineTo(w, h * 0.52)
      ..cubicTo(w, h * 0.78, w * 0.72, h * 0.92, w * 0.5, h)
      ..cubicTo(w * 0.28, h * 0.92, 0, h * 0.78, 0, h * 0.52)
      ..lineTo(0, h * 0.16)
      ..cubicTo(0, h * 0.14, 0, h * 0.12, w * 0.05, h * 0.10)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter old) => old.color != color;
}
