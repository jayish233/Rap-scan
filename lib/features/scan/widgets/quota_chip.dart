import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../data/profile_repository.dart';
import '../../../domain/plan.dart';
import '../../../l10n/strings.dart';
import '../../../widgets/adaptive.dart';

/// Copy deck: "{Plan} · {remaining} of {limit} scans left" or
/// "{Plan} · Unlimited scans". Numbers are exactly what the server sent.
String quotaLabel(Quota q) => q.isUnlimited
    ? Strings.quotaChipUnlimited(q.planLabel)
    : Strings.quotaChip(q.planLabel, q.remaining, q.scanLimit);

/// Plan + remaining scans chip (handoff mockups: iOS pill on #F1F6F2 with a
/// hairline, Android outlined chip), sparkle icon in primary.
class QuotaChip extends ConsumerWidget {
  const QuotaChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quota = ref.watch(quotaProvider);
    return switch (quota) {
      AsyncData(:final value) => _chip(
          context,
          label: quotaLabel(value),
          color: value.isExhausted ? AppColors.danger : AppColors.primary,
        ),
      AsyncError() => _chip(
          context,
          label: Strings.quotaUnavailable,
          color: AppColors.textMuted,
          onTap: () => ref.invalidate(quotaProvider),
          tooltip: Strings.retry,
        ),
      _ => _chip(context, label: '…', color: AppColors.textMuted),
    };
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required Color color,
    VoidCallback? onTap,
    String? tooltip,
  }) {
    final ios = isIos(context);
    final chip = Container(
      constraints: BoxConstraints(minHeight: ios ? 34 : 32),
      padding: EdgeInsets.symmetric(horizontal: ios ? 12 : 12, vertical: ios ? 7 : 0),
      decoration: BoxDecoration(
        color: ios ? AppColors.surfaceMuted : Colors.transparent,
        borderRadius: BorderRadius.circular(ios ? 999 : 8),
        border: Border.all(color: ios ? AppColors.border : AppColors.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: ios ? 14 : 18, color: color),
          SizedBox(width: ios ? 6 : 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: ios ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
    final semantic = Semantics(button: onTap != null, label: label, excludeSemantics: true, child: chip);
    if (onTap == null) return semantic;
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(borderRadius: BorderRadius.circular(ios ? 999 : 8), onTap: onTap, child: semantic),
    );
  }
}
