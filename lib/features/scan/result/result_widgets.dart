import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../domain/rating.dart';
import '../../../domain/scan_result.dart';
import '../../../widgets/adaptive.dart';

/// Small rating pill (history rows on Android). Tinted background, dark
/// text, never colour alone (design.md §7.3).
class RatingChip extends StatelessWidget {
  const RatingChip({super.key, required this.rating});

  final Rating rating;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = ratingChipColors(rating);
    return Semantics(
      label: 'Rating: ${rating.label}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(
          rating.label,
          style: TextStyle(fontFamily: AppFonts.body, fontSize: 11, fontWeight: FontWeight.w700, color: fg),
        ),
      ),
    );
  }
}

(Color bg, Color fg) ratingChipColors(Rating rating) => switch (rating.tone) {
      Tone.success => (AppColors.tonal, AppColors.onTonal),
      Tone.accent => (const Color(0xFFE3F4D8), const Color(0xFF1F4A12)),
      Tone.warning => (AppColors.amberTintStrong, AppColors.cautionText),
      _ => (const Color(0xFFF8D7D3), const Color(0xFF7A1A12)),
    };

/// Banner colours for the verdict header: background = rating colour, text
/// dark on warning/accent, dark green on success (spec §2).
(Color bg, Color fg) ratingBannerColors(Rating? rating) => switch (rating?.tone) {
      Tone.success => (AppColors.success, AppColors.onTonal),
      Tone.accent => (AppColors.accent, AppColors.onAccent),
      Tone.warning => (AppColors.warning, AppColors.text),
      Tone.danger || Tone.rose => (AppColors.danger, AppColors.onPrimary),
      null => (AppColors.surfaceMuted, AppColors.text),
    };

/// Severity chip (cautions list): low = grey, medium = amber, high = red.
/// The word is always shown, never colour alone.
class SeverityChip extends StatelessWidget {
  const SeverityChip({super.key, required this.severity});

  final Severity severity;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (severity) {
      Severity.low => (AppColors.severityChipLowBg, AppColors.severityChipLowText),
      Severity.medium => (AppColors.warning, AppColors.text),
      Severity.high => (AppColors.danger, AppColors.onPrimary),
    };
    return Semantics(
      label: 'Severity: ${severity.label}',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: isIos(context) ? 3 : 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(isIos(context) ? 999 : 8)),
        child: Text(
          severity.label,
          style: TextStyle(fontFamily: AppFonts.body, fontSize: 12, fontWeight: FontWeight.w700, color: fg),
        ),
      ),
    );
  }
}

class LabelChip extends StatelessWidget {
  const LabelChip({super.key, required this.label, required this.color, this.semanticPrefix});

  final String label;
  final Color color;
  final String? semanticPrefix;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticPrefix == null ? label : '$semanticPrefix: $label',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.text, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Titled result block (legacy layout for sections not yet card-based).
class ResultSection extends StatelessWidget {
  const ResultSection({super.key, required this.title, this.icon, this.iconColor, required this.child});

  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: iconColor ?? AppColors.primary),
                  const SizedBox(width: 8),
                ],
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// Advantages (+ green) / disadvantages (− red) markers (mockups §4.3).
class BulletList extends StatelessWidget {
  const BulletList({super.key, required this.items, required this.emptyText, required this.color, this.marker});

  final List<String> items;
  final String emptyText;
  final Color color;

  /// Marker glyph ("+" / "−"); a small dot when null.
  final String? marker;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4);
    if (items.isEmpty) return Text(emptyText, style: style?.copyWith(color: AppColors.textMuted));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (marker != null)
                  SizedBox(
                    width: 16,
                    child: Text(marker!, style: TextStyle(fontFamily: AppFonts.body, fontSize: 14, fontWeight: FontWeight.w700, color: color, height: 1.4)),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 7, right: 8),
                    child: Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  ),
                Expanded(child: Text(item, style: style)),
              ],
            ),
          ),
      ],
    );
  }
}
