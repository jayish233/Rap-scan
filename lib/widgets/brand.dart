import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Logo mark (design.md §2.3): rounded square with a green→teal gradient,
/// white scanner-reticle corners, a leaf and a horizontal laser sweep.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'RAPscanz logo',
      image: true,
      child: SizedBox.square(dimension: size, child: const CustomPaint(painter: _BrandMarkPainter())),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  const _BrandMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final rect = Offset.zero & size;

    // Rounded square, green → teal.
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(s * 0.24)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.teal],
        ).createShader(rect),
    );

    // Reticle corners.
    final corner = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.06
      ..strokeCap = StrokeCap.round;
    final inset = s * 0.2;
    final arm = s * 0.16;
    for (final (x, y, dx, dy) in [
      (inset, inset, 1.0, 1.0),
      (s - inset, inset, -1.0, 1.0),
      (inset, s - inset, 1.0, -1.0),
      (s - inset, s - inset, -1.0, -1.0),
    ]) {
      canvas.drawLine(Offset(x, y), Offset(x + arm * dx, y), corner);
      canvas.drawLine(Offset(x, y), Offset(x, y + arm * dy), corner);
    }

    // Leaf.
    final c = Offset(s / 2, s / 2);
    final leaf = Path()
      ..moveTo(c.dx - s * 0.13, c.dy + s * 0.13)
      ..quadraticBezierTo(c.dx - s * 0.16, c.dy - s * 0.14, c.dx + s * 0.14, c.dy - s * 0.15)
      ..quadraticBezierTo(c.dx + s * 0.15, c.dy + s * 0.14, c.dx - s * 0.13, c.dy + s * 0.13)
      ..close();
    canvas.drawPath(leaf, Paint()..color = Colors.white);
    canvas.drawLine(
      Offset(c.dx - s * 0.11, c.dy + s * 0.11),
      Offset(c.dx + s * 0.08, c.dy - s * 0.08),
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = s * 0.025
        ..strokeCap = StrokeCap.round,
    );

    // Laser sweep.
    canvas.drawLine(
      Offset(inset - s * 0.04, c.dy + s * 0.02),
      Offset(s - inset + s * 0.04, c.dy + s * 0.02),
      Paint()
        ..color = AppColors.accent
        ..strokeWidth = s * 0.035
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wordmark: "RAP" in charcoal + "scanz" in primary green.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.fontSize = 28});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: AppFonts.display,
      fontWeight: FontWeight.w800,
      fontSize: fontSize,
      letterSpacing: -0.5,
      color: AppColors.text,
    );
    return Semantics(
      label: 'RAPscanz',
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          style: style,
          children: const [
            TextSpan(text: 'RAP'),
            TextSpan(text: 'scanz', style: TextStyle(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

/// Mark + wordmark in a row, for app bars.
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.markSize = 28, this.fontSize = 20});

  final double markSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(size: markSize),
        const SizedBox(width: 8),
        Wordmark(fontSize: fontSize),
      ],
    );
  }
}
