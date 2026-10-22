import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../domain/rating.dart';

/// Circular 0–100 score ring (design.md §7.1). The numeral scales down to
/// fit, so large dynamic type never clips it. Exposes score + label to
/// screen readers.
class HealthScoreRing extends StatelessWidget {
  const HealthScoreRing({super.key, required this.score, this.size = 112, this.showLabel = true});

  /// Small variant for history rows.
  const HealthScoreRing.small({super.key, required this.score})
      : size = 40,
        showLabel = false;

  final int score;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final s = clampScore(score);
    final band = ScoreBand.of(s);
    final color = toneColor(band.tone);
    final text = Theme.of(context).textTheme;
    final stroke = size * 0.09;

    final ring = SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RingPainter(fraction: s / 100, color: color, stroke: stroke),
        child: Padding(
          padding: EdgeInsets.all(stroke * 1.8),
          child: FittedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$s',
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                    fontSize: 40,
                    height: 1,
                    color: AppColors.text,
                  ),
                ),
                if (showLabel)
                  Text(
                    '${scoreOutOfTen(s)} / 10',
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      label: 'Health score $s out of 100, ${band.label}, ${scoreOutOfTen(s)} out of 10',
      excludeSemantics: true,
      child: showLabel
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ring,
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: size * 1.4),
                  child: Text(
                    band.label,
                    textAlign: TextAlign.center,
                    style: text.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            )
          : ring,
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.fraction, required this.color, required this.stroke});

  final double fraction;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color.withValues(alpha: 0.15),
    );
    if (fraction <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * fraction,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction || old.color != color || old.stroke != stroke;
}
