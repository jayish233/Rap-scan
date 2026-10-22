import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../domain/rating.dart';

/// Ring palette per score band (handoff spec §2): ≥70 green, 40–69 amber,
/// <40 rose, each with its numeral tint.
(Color progress, Color numeral) ringColors(int score) => switch (score) {
      >= 70 => (AppColors.ringGood, AppColors.ringGoodText),
      >= 40 => (AppColors.ringMid, AppColors.ringMidText),
      _ => (AppColors.ringBad, AppColors.ringBadText),
    };

/// Health score ring (handoff spec §2): near-black disc (#0B1220), slate
/// track, coloured progress arc, Bricolage numeral. Large 92 (stroke 9),
/// small 56 (stroke 6). Exposes score + label to screen readers.
class HealthScoreRing extends StatelessWidget {
  const HealthScoreRing({super.key, required this.score, this.size = 92, this.showLabel = true});

  /// Small variant for history rows.
  const HealthScoreRing.small({super.key, required this.score})
      : size = 56,
        showLabel = false;

  final int score;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final s = clampScore(score);
    final band = ScoreBand.of(s);
    final (progress, numeral) = ringColors(s);
    final stroke = size >= 92 ? 9.0 : 6.0;

    final ring = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: AppColors.ringDisc, shape: BoxShape.circle),
      child: CustomPaint(
        painter: _RingPainter(fraction: s / 100, color: progress, stroke: stroke),
        child: Padding(
          padding: EdgeInsets.all(stroke + 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$s',
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                    fontSize: size >= 92 ? 26 : 16,
                    height: 1,
                    letterSpacing: -0.5,
                    color: numeral,
                  ),
                ),
                if (size >= 92) ...[
                  const SizedBox(height: 2),
                  const Text(
                    '/ 100',
                    style: TextStyle(fontFamily: AppFonts.body, fontSize: 9, letterSpacing: 0.7, color: AppColors.ringSubtext),
                  ),
                ],
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
                  constraints: BoxConstraints(maxWidth: size * 1.5),
                  child: Text(
                    band.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: AppFonts.body, fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text),
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
    final rect = (Offset.zero & size).deflate(stroke / 2 + 1);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.ringTrack,
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
