import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/profile_repository.dart';
import '../../../domain/plan.dart';
import '../../../l10n/strings.dart';

/// Copy deck: "{Plan} · {remaining} of {limit} scans left" or
/// "{Plan} · Unlimited scans". Numbers are exactly what the server sent.
String quotaLabel(Quota q) => q.isUnlimited
    ? Strings.quotaChipUnlimited(q.planLabel)
    : Strings.quotaChip(q.planLabel, q.remaining, q.scanLimit);

/// Plan + remaining scans chip on the Scan screen (design.md §4.4).
class QuotaChip extends ConsumerWidget {
  const QuotaChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quota = ref.watch(quotaProvider);
    return switch (quota) {
      AsyncData(:final value) => _chip(
          context,
          label: quotaLabel(value),
          icon: value.isUnlimited ? Icons.all_inclusive : Icons.bolt,
          color: value.isExhausted ? AppColors.danger : AppColors.primary,
        ),
      AsyncError() => _chip(
          context,
          label: Strings.quotaUnavailable,
          icon: Icons.refresh,
          color: AppColors.textMuted,
          onTap: () => ref.invalidate(quotaProvider),
          tooltip: Strings.retry,
        ),
      _ => _chip(context, label: '…', icon: Icons.bolt, color: AppColors.textMuted),
    };
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    String? tooltip,
  }) {
    final chip = Container(
      constraints: const BoxConstraints(minHeight: 36),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    final semantic = Semantics(
      button: onTap != null,
      label: label,
      excludeSemantics: true,
      child: chip,
    );
    if (onTap == null) return semantic;
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(borderRadius: BorderRadius.circular(999), onTap: onTap, child: semantic),
    );
  }
}
