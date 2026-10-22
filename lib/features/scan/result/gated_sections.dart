import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../domain/scan_result.dart';
import '../../../l10n/strings.dart';
import '../../../widgets/adaptive.dart';
import '../../plans/plans_sheet.dart';
import 'result_widgets.dart';

Color dietaryColor(DietaryType type) => switch (type) {
      DietaryType.veg => AppColors.veg,
      DietaryType.nonVeg => AppColors.nonVeg,
      DietaryType.vegan => AppColors.vegan,
      DietaryType.unknown => AppColors.textMuted,
    };

/// Indian-convention food mark: square outline with dot (veg), triangle
/// (non-veg) or leaf (vegan).
class DietaryMark extends StatelessWidget {
  const DietaryMark({super.key, required this.type, this.size = 22});

  final DietaryType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = dietaryColor(type);
    final inner = size * 0.55;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(border: Border.all(color: color, width: size * 0.09), borderRadius: BorderRadius.circular(size * 0.18)),
      alignment: Alignment.center,
      child: switch (type) {
        DietaryType.veg => Container(
            width: inner,
            height: inner,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(inner * 0.2)),
          ),
        DietaryType.nonVeg => CustomPaint(size: Size.square(inner), painter: _TrianglePainter(color)),
        DietaryType.vegan => Icon(Icons.eco, size: inner * 1.2, color: color),
        DietaryType.unknown => Text('?', style: TextStyle(fontSize: inner, color: color, height: 1)),
      },
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}

/// Mark + label, e.g. for the verdict header (Pro Max only).
class DietaryBadge extends StatelessWidget {
  const DietaryBadge({super.key, required this.type, this.foreground});

  final DietaryType type;

  /// Overrides the label colour (e.g. on the coloured rating banner).
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Dietary type: ${type.label}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DietaryMark(type: type, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              type.label,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: foreground ?? dietaryColor(type),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Block 6 for Pro Max (mockups): card with a header strip
/// ("DIETARY CLASSIFICATION" + Pro Max badge), the mark in a bordered box,
/// the type name and the deciding reason.
class DietarySection extends StatelessWidget {
  const DietarySection({super.key, required this.type, this.reason});

  final DietaryType type;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final ios = isIos(context);
    final radius = BorderRadius.circular(ios ? 20 : 16);
    final borderColor = AppColors.primary.withValues(alpha: ios ? 0.4 : 0.45);
    return Semantics(
      container: true,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius,
          border: Border.all(color: borderColor, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: ios ? AppColors.surfaceMuted : AppColors.surfaceContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      Strings.dietaryTitle.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: AppFonts.body, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0),
                    ),
                  ),
                  const PlanBadge(label: 'Pro Max'),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: DietaryMark(type: type, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.label,
                          style: text.titleLarge?.copyWith(color: type == DietaryType.unknown ? AppColors.text : dietaryColor(type)),
                        ),
                        if (reason != null) ...[
                          const SizedBox(height: 2),
                          Text(reason!, style: text.bodySmall?.copyWith(color: AppColors.textMuted, height: 1.4, fontSize: 13)),
                        ],
                      ],
                    ),
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

/// Block 6 below Pro Max. Static copy only — never the type or the reason.
class LockedDietaryCard extends StatelessWidget {
  const LockedDietaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      onTap: () => showPlansSheet(context),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.lock_outline, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(Strings.dietaryLockedTitle, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
                    const PlanBadge(label: 'Pro Max'),
                  ],
                ),
                const SizedBox(height: 2),
                Text(Strings.dietaryLockedBody, style: text.bodySmall?.copyWith(color: AppColors.textMuted, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Block 8 (Pro+): safe/day, upper limit, source.
class ConsumptionGuideSection extends StatelessWidget {
  const ConsumptionGuideSection({super.key, required this.tip});

  final ConsumptionTip tip;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget line(String label, String value, Color labelColor) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text.rich(
            TextSpan(
              style: text.bodyMedium?.copyWith(height: 1.4),
              children: [
                TextSpan(text: '$label: ', style: TextStyle(fontWeight: FontWeight.w700, color: labelColor)),
                TextSpan(text: value),
              ],
            ),
          ),
        );
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(
            title: Strings.consumptionTitle,
            icon: Icons.favorite_border,
            iconColor: AppColors.primary,
            trailing: PlanBadge(label: 'Pro+'),
          ),
          const SizedBox(height: 10),
          line(Strings.safeDailyLabel, tip.safeDaily, AppColors.primary),
          line(Strings.upperLimitLabel, tip.limit, AppColors.danger),
          Text('${Strings.sourceLabel}: ${tip.source}', style: text.bodySmall?.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

/// Block 10 (Pro Max): the five over-consumption groups, empty ones hidden.
class RiskProfileSection extends StatelessWidget {
  const RiskProfileSection({super.key, required this.risk});

  final RiskProfile risk;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final groups = [
      (Strings.riskIllnesses, risk.illnesses),
      (Strings.riskAddictions, risk.addictions),
      (Strings.riskChronic, risk.chronicDamage),
      (Strings.riskTemporary, risk.temporaryEffects),
      (Strings.riskOrgan, risk.organDamage),
    ];
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle(
            title: Strings.riskTitle,
            icon: Icons.warning_amber_outlined,
            iconColor: AppColors.danger,
            trailing: PlanBadge(label: 'Pro Max'),
          ),
          const SizedBox(height: 10),
          for (final (title, items) in groups)
            if (items.isNotEmpty) ...[
              Text(title, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              BulletList(items: items, emptyText: '', color: AppColors.danger),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}
