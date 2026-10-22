import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../domain/plan.dart';
import '../../../domain/scan_result.dart';
import '../../../l10n/strings.dart';
import '../../../widgets/common.dart';
import 'health_score_ring.dart';
import 'result_widgets.dart';

/// The ordered result blocks (PRD §7.4, design.md §4.5). Gated content is
/// shown only when [access] allows it, even if the payload carries it.
///
/// Phase 2 blocks: 1 verdict, 2 summary, 3 for you, 4 calories,
/// 5 I ate this, 7 advantages/disadvantages, 9 cautions, footer.
class ScanResultView extends StatelessWidget {
  const ScanResultView({super.key, required this.result, required this.access, this.scanId, this.onAteThis});

  final ScanResult result;
  final FeatureAccess access;
  final String? scanId;

  /// Wired in Phase 5; the button stays disabled until a scanId exists.
  final VoidCallback? onAteThis;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _VerdictHeader(result: result),
        ResultSection(title: Strings.summaryTitle, child: Text(result.summary, style: text.bodyLarge)),
        if (result.personalAdvice != null)
          ResultSection(
            title: Strings.forYouTitle,
            icon: Icons.favorite,
            iconColor: AppColors.rose,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.rose.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSizes.radius),
                border: Border.all(color: AppColors.rose.withValues(alpha: 0.25)),
              ),
              child: Text(result.personalAdvice!, style: text.bodyMedium),
            ),
          ),
        ResultSection(
          title: Strings.caloriesTitle,
          icon: Icons.local_fire_department,
          iconColor: AppColors.severityMedium,
          child: Text(Strings.caloriesLine(result.caloriesKcal), style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: scanId == null ? null : onAteThis,
          icon: const Icon(Icons.restaurant),
          label: const Text(Strings.ateThis),
        ),
        _AdvantagesDisadvantages(result: result),
        ResultSection(
          title: Strings.cautionsTitle,
          icon: Icons.science_outlined,
          iconColor: AppColors.warning,
          child: result.cautions.isEmpty
              ? Text(Strings.noCautions, style: text.bodyMedium?.copyWith(color: AppColors.textMuted))
              : Column(
                  children: [for (final c in result.cautions) _CautionCard(caution: c, access: access)],
                ),
        ),
        const SizedBox(height: 8),
        const DisclaimerFooter(),
      ],
    );
  }
}

class _VerdictHeader extends StatelessWidget {
  const _VerdictHeader({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final identity = [
      ?result.brand,
      if (result.parentCompany != null) Strings.byParent(result.parentCompany!),
      ?result.category,
    ].join(' · ');

    return Semantics(
      container: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.rating != null) RatingChip(rating: result.rating!),
                const SizedBox(height: 10),
                Semantics(header: true, child: Text(result.productName, style: text.headlineSmall)),
                if (identity.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(identity, style: text.bodyMedium?.copyWith(color: AppColors.textMuted)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          HealthScoreRing(score: result.healthScore),
        ],
      ),
    );
  }
}

class _AdvantagesDisadvantages extends StatelessWidget {
  const _AdvantagesDisadvantages({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final pros = ResultSection(
      title: Strings.advantagesTitle,
      icon: Icons.thumb_up_alt_outlined,
      iconColor: AppColors.success,
      child: BulletList(items: result.advantages, emptyText: Strings.noneNotable, color: AppColors.success),
    );
    final cons = ResultSection(
      title: Strings.disadvantagesTitle,
      icon: Icons.thumb_down_alt_outlined,
      iconColor: AppColors.danger,
      child: BulletList(items: result.disadvantages, emptyText: Strings.noneNotable, color: AppColors.danger),
    );
    // Side by side on wide layouts, stacked on a phone (PRD §7.4.7).
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= 560
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(child: pros), const SizedBox(width: 16), Expanded(child: cons)],
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [pros, cons]),
    );
  }
}

class _CautionCard extends StatelessWidget {
  const _CautionCard({required this.caution, required this.access});

  final Caution caution;
  final FeatureAccess access;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final percentage = access.cautionPercentage ? caution.percentage : null;
    final formula = access.chemicalDetail ? caution.chemicalFormula : null;
    final scientific = access.chemicalDetail ? caution.scientificName : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: caution.ingredient,
                      style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      children: [
                        if (percentage != null)
                          TextSpan(text: '  $percentage', style: text.bodySmall?.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SeverityChip(severity: caution.severity),
              ],
            ),
            const SizedBox(height: 6),
            Text(caution.concern, style: text.bodyMedium),
            if (formula != null || scientific != null) ...[
              const SizedBox(height: 6),
              Text(
                [
                  if (formula != null) '${Strings.formulaLabel}: $formula',
                  if (scientific != null) '${Strings.scientificNameLabel}: $scientific',
                ].join(' · '),
                style: text.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
