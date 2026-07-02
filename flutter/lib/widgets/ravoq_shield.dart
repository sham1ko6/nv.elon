import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// The Ravoq shield mark — matches the exact SVG path from the design system
/// (viewBox 0 0 100 120): an outer shield with a nested inner shield cutout
/// and a small amber "jewel" dot at the top.
class RavoqShield extends StatelessWidget {
  final double size;
  final Color outerColor;
  final Color innerColor;
  final Color dotColor;

  const RavoqShield({
    super.key,
    this.size = 56,
    this.outerColor = cAccent,
    this.innerColor = cBg,
    this.dotColor = cAmber,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.2,
      child: CustomPaint(
        painter: _ShieldPainter(
          outerColor: outerColor,
          innerColor: innerColor,
          dotColor: dotColor,
        ),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  final Color outerColor;
  final Color innerColor;
  final Color dotColor;
  _ShieldPainter({
    required this.outerColor,
    required this.innerColor,
    required this.dotColor,
  });

  // Coordinates lifted directly from the design's viewBox="0 0 100 120".
  static Path _outerPath(double sx, double sy) => Path()
    ..moveTo(22 * sx, 112 * sy)
    ..lineTo(22 * sx, 54 * sy)
    ..cubicTo(22 * sx, 32 * sy, 34 * sx, 17 * sy, 50 * sx, 9 * sy)
    ..cubicTo(66 * sx, 17 * sy, 78 * sx, 32 * sy, 78 * sx, 54 * sy)
    ..lineTo(78 * sx, 112 * sy)
    ..close();

  static Path _innerPath(double sx, double sy) => Path()
    ..moveTo(38 * sx, 112 * sy)
    ..lineTo(38 * sx, 60 * sy)
    ..cubicTo(38 * sx, 45 * sy, 43 * sx, 36 * sy, 50 * sx, 31 * sy)
    ..cubicTo(57 * sx, 36 * sy, 62 * sx, 45 * sy, 62 * sx, 60 * sy)
    ..lineTo(62 * sx, 112 * sy)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100;
    final sy = size.height / 120;

    canvas.drawPath(_outerPath(sx, sy), Paint()..color = outerColor);
    canvas.drawPath(_innerPath(sx, sy), Paint()..color = innerColor);
    canvas.drawCircle(Offset(50 * sx, 22 * sy), 7 * sx, Paint()..color = dotColor);
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter old) =>
      old.outerColor != outerColor || old.innerColor != innerColor || old.dotColor != dotColor;
}

/// Full lockup: shield mark + "Ravoq." wordmark with the terracotta dot.
class RavoqLogo extends StatelessWidget {
  final double shieldSize;
  final double textSize;
  final Color outerColor;
  final Color innerColor;
  final Color textColor;
  final Color dotColor;
  final bool showDot;
  final Axis direction;

  const RavoqLogo({
    super.key,
    this.shieldSize = 56,
    this.textSize = 30,
    this.outerColor = cAccent,
    this.innerColor = cBg,
    this.textColor = cInk,
    this.dotColor = cAccent,
    this.showDot = true,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final shield = RavoqShield(size: shieldSize, outerColor: outerColor, innerColor: innerColor);
    final wordmark = RichText(
      text: TextSpan(
        style: GoogleFonts.spectral(
          fontSize: textSize,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: textColor,
          height: 1.0,
        ),
        children: [
          const TextSpan(text: 'Ravoq'),
          if (showDot) TextSpan(text: '.', style: TextStyle(color: dotColor)),
        ],
      ),
    );

    if (direction == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          shield,
          SizedBox(height: textSize * 0.5),
          wordmark,
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        shield,
        SizedBox(width: textSize * 0.35),
        wordmark,
      ],
    );
  }
}
