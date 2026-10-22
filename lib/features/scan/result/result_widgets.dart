import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../domain/rating.dart';
import '../../../domain/scan_result.dart';

/// Rating label + colour, never colour alone (design.md §7.3).
class RatingChip extends StatelessWidget {
  const RatingChip({super.key, required this.rating});

  final Rating rating;

  @override
  Widget build(BuildContext context) => LabelChip(label: rating.label, color: toneColor(rating.tone), semanticPrefix: 'Rating');
}

/// Severity word + colour (design.md §7.3).
class SeverityChip extends StatelessWidget {
  const SeverityChip({super.key, required this.severity});

  final Severity severity;

  @override
  Widget build(BuildContext context) =>
      LabelChip(label: severity.label, color: severityColor(severity), semanticPrefix: 'Severity');
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
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Titled result block.
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
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
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

class BulletList extends StatelessWidget {
  const BulletList({super.key, required this.items, required this.emptyText, required this.color});

  final List<String> items;
  final String emptyText;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    if (items.isEmpty) return Text(emptyText, style: style?.copyWith(color: AppColors.textMuted));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
