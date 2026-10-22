import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/profile_repository.dart';
import '../../domain/plan.dart';
import '../../l10n/strings.dart';
import '../home/pricing_cards.dart';
import '../scan/widgets/quota_chip.dart';

/// Plans sheet (PRD §9, design.md §4.10): the four plans and the user's
/// current plan. Display only — no checkout in v1; upgrade buttons say
/// payments are coming and never pretend a purchase succeeded.
Future<void> showPlansSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => const PlansSheet(),
  );
}

class PlansSheet extends ConsumerWidget {
  const PlansSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quota = ref.watch(quotaProvider).value;
    final current = quota == null ? null : PlanTier.fromWire(quota.plan);
    final text = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 0, AppSizes.gutter, 24),
        children: [
          Semantics(header: true, child: Text(Strings.plansTitle, style: text.headlineSmall)),
          const SizedBox(height: 4),
          if (quota != null) ...[
            Text(Strings.currentPlanLine(quotaLabel(quota)), style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            if (quota.isUnlimited) ...[
              const SizedBox(height: 4),
              Text(Strings.unlimitedPlanNote, style: text.bodySmall?.copyWith(color: AppColors.textMuted)),
            ],
          ],
          const SizedBox(height: 16),
          for (final tier in PlanTier.values) ...[
            PlanCard(tier: tier, isCurrent: tier == current),
            if (tier != PlanTier.free && tier != current && !(quota?.isUnlimited ?? false)) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(Strings.upgradeTo(tier.label)),
                    content: const Text(Strings.billingPlaceholder),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text(Strings.close)),
                    ],
                  ),
                ),
                child: Text(Strings.upgradeTo(tier.label)),
              ),
            ],
            const SizedBox(height: 18),
          ],
          Text(Strings.unlimitedNote, style: text.bodySmall?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  Strings.billingPlaceholder,
                  style: text.bodySmall?.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
