import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../domain/plan.dart';
import '../../../domain/scan_result.dart';
import '../../../l10n/strings.dart';
import '../../../widgets/adaptive.dart';
import '../../../widgets/common.dart';
import 'ate_this_button.dart';
import 'body_map.dart';
import 'feedback_section.dart';
import 'gated_sections.dart';
import 'health_score_ring.dart';
import 'result_widgets.dart';

/// Monospace style for formulas and percentages (spec §2).
TextStyle monoStyle({double size = 12, FontWeight weight = FontWeight.w400, Color color = AppColors.text}) =>
    TextStyle(
      fontFamily: 'Menlo',
      fontFamilyFallback: const ['Consolas', 'Roboto Mono', 'monospace'],
      fontSize: size,
      fontWeight: weight,
      color: color,
    );

/// The ordered result blocks (PRD §7.4, handoff mockups ios/android-result).
/// Gated content renders only when [access] allows it, even if the payload
/// carries it.
///
/// 1 verdict header · 2 summary · 3 for you · 4 calories · 5 I ate this ·
/// 6 dietary · 7 advantages/disadvantages · 8 consumption guide ·
/// 9 cautions · 10 risk profile · 11 body map · 12 feedback · footer.
class ScanResultView extends StatelessWidget {
  const ScanResultView({super.key, required this.result, required this.access, this.scanId, this.scanType});

  final ScanResult result;
  final FeatureAccess access;
  final String? scanId;

  /// "Barcode" / "Ingredients" for the "scanned by …" subline, when known.
  final String? scanType;

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: isIos(context) ? 14 : 12);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _VerdictCard(result: result, access: access, scanId: scanId, scanType: scanType),
        // 6. Dietary: Pro Max sees the badge + reason; others a teaser that
        // reveals neither.
        if (!access.dietary)
          const LockedDietaryCard()
        else if (result.dietaryType != null)
          DietarySection(type: result.dietaryType!, reason: result.dietaryReason),
        _AdvantagesDisadvantages(result: result),
        if (access.consumptionGuide && result.consumptionTip != null)
          ConsumptionGuideSection(tip: result.consumptionTip!),
        _CautionsCard(result: result, access: access),
        if (access.riskProfile && result.riskProfile != null && !result.riskProfile!.isEmpty)
          RiskProfileSection(risk: result.riskProfile!),
        // 11. Always present; locked teaser below Pro Max.
        access.bodyMap
            ? BodyMapCard(damage: result.bodyDamage, benefit: result.bodyBenefit)
            : const LockedBodyMapCard(),
        if (scanId != null) FeedbackSection(scanId: scanId!),
        gap,
        const DisclaimerFooter(),
      ],
    );
  }
}

/// Block 1–5: banner coloured by rating, product identity, dark score ring,
/// summary, For-you card, kcal chip + I-ate-this.
class _VerdictCard extends StatelessWidget {
  const _VerdictCard({required this.result, required this.access, this.scanId, this.scanType});

  final ScanResult result;
  final FeatureAccess access;
  final String? scanId;
  final String? scanType;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final ios = isIos(context);
    final (bannerBg, bannerFg) = ratingBannerColors(result.rating);

    final identity = [
      ?result.brand,
      if (result.parentCompany != null) Strings.byParent(result.parentCompany!),
      ?result.category,
      if (scanType != null) Strings.scannedBy(scanType!.toLowerCase()),
    ].join(' · ');

    return AppCard(
      radius: ios ? 24 : 20,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ios ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Rating banner. One merged semantics element: rating word,
            // product identity and the score ring (PRD §14.15).
            Container(
              color: bannerBg,
              padding: const EdgeInsets.all(20),
              child: Semantics(
                container: true,
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (result.rating != null)
                          Semantics(
                            label: 'Rating: ${result.rating!.label}',
                            excludeSemantics: true,
                            child: Text(
                              result.rating!.label.toUpperCase(),
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: ios ? 11 : 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: bannerFg.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Semantics(
                          header: true,
                          child: Text(
                            result.productName,
                            style: TextStyle(
                              fontFamily: AppFonts.display,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.9,
                              height: 1.1,
                              color: bannerFg,
                            ),
                          ),
                        ),
                        if (identity.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(identity, style: TextStyle(fontFamily: AppFonts.body, fontSize: 12, color: bannerFg.withValues(alpha: 0.85))),
                        ],
                        // Veg / non-veg mark on the header for Pro Max when known (PRD §7.4.1).
                        if (access.dietary && result.dietaryType != null && result.dietaryType != DietaryType.unknown) ...[
                          const SizedBox(height: 8),
                          DietaryBadge(type: result.dietaryType!, foreground: bannerFg),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  HealthScoreRing(score: result.healthScore),
                ],
              ),
              ),
            ),
            // Summary, For-you, calories + I ate this.
            Padding(
              padding: EdgeInsets.fromLTRB(20, ios ? 18 : 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(result.summary, style: text.bodyLarge?.copyWith(height: 1.5, fontSize: 15)),
                  if (result.personalAdvice != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ios ? AppColors.surfaceMuted : AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: Icon(Icons.favorite, size: 18, color: AppColors.danger),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Semantics(
                              label: '${Strings.forYouTitle}: ${result.personalAdvice!}',
                              excludeSemantics: true,
                              child: Text.rich(
                                TextSpan(
                                  style: text.bodyMedium?.copyWith(height: 1.45),
                                  children: [
                                    const TextSpan(text: '${Strings.forYouTitle}: ', style: TextStyle(fontWeight: FontWeight.w700)),
                                    TextSpan(text: result.personalAdvice!),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Container(
                        height: ios ? 44 : 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.amberTint,
                          borderRadius: BorderRadius.circular(ios ? 12 : 8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department, size: 18, color: AppColors.amberText),
                            const SizedBox(width: 8),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text.rich(
                                  TextSpan(
                                    style: const TextStyle(fontFamily: AppFonts.body, fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
                                    children: [
                                      TextSpan(text: '~${result.caloriesKcal} kcal '),
                                      const TextSpan(
                                        text: 'per serving',
                                        style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AteThisButton(scanId: scanId, productName: result.productName, caloriesKcal: result.caloriesKcal),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdvantagesDisadvantages extends StatelessWidget {
  const _AdvantagesDisadvantages({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final pros = AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(title: Strings.advantagesTitle, icon: Icons.add_circle_outline, iconColor: AppColors.primary),
          const SizedBox(height: 10),
          BulletList(items: result.advantages, emptyText: Strings.noneNotable, color: AppColors.primary, marker: '+'),
        ],
      ),
    );
    final cons = AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(title: Strings.disadvantagesTitle, icon: Icons.do_not_disturb_on_outlined, iconColor: AppColors.danger),
          const SizedBox(height: 10),
          BulletList(items: result.disadvantages, emptyText: Strings.noneNotable, color: AppColors.danger, marker: '−'),
        ],
      ),
    );
    // Side by side on wide layouts, stacked on a phone (PRD §7.4.7).
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= 560
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(child: pros), SizedBox(width: isIos(context) ? 14 : 12), Expanded(child: cons)],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [pros, SizedBox(height: isIos(context) ? 14 : 12), cons],
            ),
    );
  }
}

/// Block 9: cautions with percentage chips, mono formulas and severity chips.
class _CautionsCard extends StatelessWidget {
  const _CautionsCard({required this.result, required this.access});

  final ScanResult result;
  final FeatureAccess access;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(title: Strings.cautionsTitle, icon: Icons.warning_amber_outlined, iconColor: AppColors.warnIcon),
          if (result.cautions.isEmpty) ...[
            const SizedBox(height: 10),
            Text(Strings.noCautions, style: text.bodyMedium?.copyWith(color: AppColors.textMuted)),
          ] else
            for (var i = 0; i < result.cautions.length; i++)
              _CautionRow(caution: result.cautions[i], access: access, topBorder: true, first: i == 0),
        ],
      ),
    );
  }
}

class _CautionRow extends StatelessWidget {
  const _CautionRow({required this.caution, required this.access, required this.topBorder, this.first = false});

  final Caution caution;
  final FeatureAccess access;
  final bool topBorder;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final percentage = access.cautionPercentage ? caution.percentage : null;
    final formula = access.chemicalDetail ? caution.chemicalFormula : null;
    final scientific = access.chemicalDetail ? caution.scientificName : null;

    return Container(
      margin: EdgeInsets.only(top: first ? 12 : 0),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Semantics(
        container: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(caution.ingredient, style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                      if (percentage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.amberTintStrong, borderRadius: BorderRadius.circular(6)),
                          child: Text(percentage, style: monoStyle(size: 12, weight: FontWeight.w700, color: AppColors.percentText)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SeverityChip(severity: caution.severity),
              ],
            ),
            const SizedBox(height: 3),
            Text(caution.concern, style: text.bodySmall?.copyWith(color: AppColors.textMuted, height: 1.4, fontSize: 13)),
            if (formula != null) ...[
              const SizedBox(height: 4),
              Text(formula, style: monoStyle(size: 12, color: AppColors.primary)),
            ],
            if (scientific != null)
              Text(
                scientific,
                style: text.bodySmall?.copyWith(color: AppColors.textMuted, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
