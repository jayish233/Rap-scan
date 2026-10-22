import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/plan.dart';
import '../../l10n/strings.dart';
import '../../widgets/common.dart';

/// The four plan cards + unlimited note (design.md §5). Display only — there
/// is no checkout in v1 (PRD §9). [current] highlights the user's plan.
class PricingCards extends StatelessWidget {
  const PricingCards({super.key, this.current});

  final PlanTier? current;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final tier in PlanTier.values) ...[
          PlanCard(tier: tier, isCurrent: tier == current),
          const SizedBox(height: 16),
        ],
        Text(
          Strings.unlimitedNote,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 8),
        Text(
          Strings.billingPlaceholder,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class PlanCard extends StatelessWidget {
  const PlanCard({super.key, required this.tier, this.isCurrent = false});

  final PlanTier tier;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label: '${tier.label} plan, ${tier.price}, ${tier.allowance}${isCurrent ? ', current plan' : ''}',
      child: HardOffsetCard(
        highlighted: isCurrent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(child: Text(tier.label, style: text.titleLarge)),
                if (isCurrent)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Chip(label: Text('Current'), visualDensity: VisualDensity.compact),
                  ),
                Text(
                  tier.price,
                  style: text.titleLarge?.copyWith(fontFamily: AppFonts.display, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(tier.allowance, style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            for (final feature in tier.highlights)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.check_circle, size: 16, color: AppColors.success),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature, style: text.bodyMedium)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
