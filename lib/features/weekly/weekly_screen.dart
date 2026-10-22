import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../data/weekly_repository.dart';
import '../../domain/weekly.dart';
import '../../l10n/strings.dart';
import '../../widgets/adaptive.dart';
import '../../widgets/common.dart';
import '../../widgets/format.dart';

/// "This week" (handoff spec §4.5, mockups ios/android-weekly): 7-day total
/// + average, seven bars with today highlighted, entries with delete.
class WeeklyScreen extends ConsumerWidget {
  const WeeklyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final week = ref.watch(weeklyProvider);
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(weeklyProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              ContentWidth(
                padding: EdgeInsets.symmetric(horizontal: isIos(context) ? 20 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ScreenHeader(
                      title: Strings.weeklyTitle,
                      subtitle: Strings.weeklySubtitle,
                      trailing: Container(
                        width: isIos(context) ? 48 : 44,
                        height: isIos(context) ? 48 : 44,
                        decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(14)),
                        alignment: Alignment.center,
                        child: Icon(Icons.local_fire_department, size: isIos(context) ? 26 : 24, color: AppColors.text),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...switch (week) {
                      AsyncData(:final value) => [
                          _SummaryCard(summary: value),
                          const SizedBox(height: 14),
                          Text(Strings.entriesTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
                          const SizedBox(height: 8),
                          if (value.isEmpty)
                            const _EmptyWeek()
                          else
                            _Entries(entries: value.entries),
                        ],
                      AsyncError() => [
                          ErrorState(message: Strings.loadFailed, onRetry: () => ref.invalidate(weeklyProvider)),
                        ],
                      _ => [const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))],
                    },
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Total + average + the seven bars (today in accent with a primary inset
/// border). iOS: white card; Android: tonal #EEF4EF container.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final WeeklySummary summary;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final ios = isIos(context);
    return Container(
      padding: EdgeInsets.fromLTRB(18, 18, 18, ios ? 18 : 16),
      decoration: BoxDecoration(
        color: ios ? AppColors.surface : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: ios ? Border.all(color: AppColors.border) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Strings.weeklyTotal.toUpperCase(),
                    style: text.labelSmall?.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w700, letterSpacing: 1.0, fontSize: ios ? 11 : 12),
                  ),
                  Semantics(
                    label: '${Strings.weeklyTotal}: ${Strings.kcal(summary.total)}',
                    excludeSemantics: true,
                    child: Text.rich(
                      TextSpan(
                        style: const TextStyle(
                          fontFamily: AppFonts.display,
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.3,
                          height: 1.1,
                          color: AppColors.text,
                        ),
                        children: [
                          TextSpan(text: formatThousands(summary.total)),
                          const TextSpan(
                            text: ' kcal',
                            style: TextStyle(fontFamily: AppFonts.body, fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 0, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(Strings.avgPerDay(summary.averagePerDay), style: text.bodySmall?.copyWith(color: AppColors.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Bars(summary: summary),
        ],
      ),
    );
  }
}

/// Seven bars, heights relative to the busiest day; today highlighted.
class _Bars extends StatelessWidget {
  const _Bars({required this.summary});

  final WeeklySummary summary;

  @override
  Widget build(BuildContext context) {
    const chartHeight = 168.0;
    const barMax = 118.0;
    final ios = isIos(context);
    final text = Theme.of(context).textTheme;
    final todayIndex = summary.days.length - 1;

    return SizedBox(
      height: chartHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, day) in summary.days.indexed)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: ios ? 4 : 5),
                child: Semantics(
                  label: '${day.weekday}: ${Strings.kcal(day.kcal)}',
                  excludeSemantics: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          day.kcal > 0 ? '${day.kcal}' : '',
                          style: text.labelSmall?.copyWith(
                            fontSize: 10,
                            color: i == todayIndex ? AppColors.text : AppColors.textMuted,
                            fontWeight: i == todayIndex ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        height: day.kcal == 0 ? 4 : (barMax * summary.barFraction(day)).clamp(6, barMax),
                        decoration: BoxDecoration(
                          color: i == todayIndex ? AppColors.accent : (day.kcal == 0 ? AppColors.segmentTrack : AppColors.primary),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(ios ? 6 : 8),
                            bottom: Radius.circular(ios ? 0 : 2),
                          ),
                          border: i == todayIndex ? Border.all(color: AppColors.primary, width: 2) : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          day.weekday,
                          style: text.labelSmall?.copyWith(
                            fontSize: 11,
                            fontWeight: i == todayIndex ? FontWeight.w800 : FontWeight.w600,
                            color: i == todayIndex ? AppColors.text : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Entries extends StatelessWidget {
  const _Entries({required this.entries});

  final List<ConsumptionEntry> entries;

  @override
  Widget build(BuildContext context) {
    final ios = isIos(context);
    if (ios) {
      return Column(
        children: [
          for (final e in entries) ...[
            _IosEntryRow(entry: e),
            const SizedBox(height: 8),
          ],
        ],
      );
    }
    return Column(
      children: [
        for (final (i, e) in entries.indexed) _AndroidEntryRow(entry: e, last: i == entries.length - 1),
      ],
    );
  }
}

class _KcalValue extends StatelessWidget {
  const _KcalValue({required this.kcal});

  final int kcal;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('$kcal', style: const TextStyle(fontFamily: AppFonts.display, fontSize: 20, fontWeight: FontWeight.w700, height: 1.1, color: AppColors.text)),
        Text('kcal', style: text.labelSmall?.copyWith(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}

class _IosEntryRow extends ConsumerWidget {
  const _IosEntryRow({required this.entry});

  final ConsumptionEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      radius: 16,
      padding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.productName, style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
                Text(formatRelative(entry.consumedAt), style: text.bodySmall?.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          _KcalValue(kcal: entry.caloriesKcal),
          IconButton(
            tooltip: Strings.deleteEntry,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.textMuted,
            onPressed: () => _delete(context, ref, entry.id),
          ),
        ],
      ),
    );
  }
}

class _AndroidEntryRow extends ConsumerWidget {
  const _AndroidEntryRow({required this.entry, required this.last});

  final ConsumptionEntry entry;
  final bool last;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.only(left: 8, right: 4),
      decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.tonal, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Icons.restaurant_outlined, size: 20, color: AppColors.onTonal),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.productName, style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                Text(formatRelative(entry.consumedAt), style: text.bodySmall?.copyWith(color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
          _KcalValue(kcal: entry.caloriesKcal),
          IconButton(
            tooltip: Strings.deleteEntry,
            icon: const Icon(Icons.delete_outline, size: 22),
            color: AppColors.textMuted,
            style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => _delete(context, ref, entry.id),
          ),
        ],
      ),
    );
  }
}

Future<void> _delete(BuildContext context, WidgetRef ref, String entryId) async {
  // Removes this log only — the scan stays in history.
  await ref.read(weeklyRepositoryProvider).delete(entryId);
  ref.invalidate(weeklyProvider);
  if (context.mounted) showToast(context, Strings.entryRemoved);
}

class _EmptyWeek extends StatelessWidget {
  const _EmptyWeek();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(Icons.local_fire_department_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(Strings.weeklyEmpty, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          AppPrimaryButton(label: Strings.scanSomething, onPressed: () => context.go(Routes.scan)),
        ],
      ),
    );
  }
}
