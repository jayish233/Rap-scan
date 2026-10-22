import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../data/history_repository.dart';
import '../../domain/scan_result.dart';
import '../../l10n/strings.dart';
import '../../widgets/common.dart';
import '../../widgets/format.dart';
import '../scan/result/health_score_ring.dart';

/// Scan history list (PRD §7.6, design.md §4.6).
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(historyProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              ContentWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const PageHeader(title: Strings.historyTitle, subtitle: Strings.historySubtitle),
                    const SizedBox(height: 16),
                    ...switch (history) {
                      AsyncData(:final value) => [
                          if (value.stale) const OfflineBanner(),
                          if (value.value.isEmpty)
                            const _EmptyHistory()
                          else
                            for (final scan in value.value) _HistoryRow(scan: scan),
                        ],
                      AsyncError() => [
                          ErrorState(message: Strings.loadFailed, onRetry: () => ref.invalidate(historyProvider)),
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

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.scan});

  final ScanSummary scan;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final rating = scan.rating;
    final ratingColor = rating == null ? AppColors.textMuted : toneColor(rating.tone);
    final type = scan.scanType == 'barcode' ? Strings.scanTypeBarcode : Strings.scanTypeIngredients;
    final meta = [formatDateTime(scan.createdAt), type, ?rating?.label].join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(Routes.historyDetail(scan.id)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 10),
                child: Semantics(
                  label: rating == null ? null : 'Rating: ${rating.label}',
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: ratingColor, shape: BoxShape.circle),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(scan.productName, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(meta, style: text.bodySmall?.copyWith(color: AppColors.textMuted)),
                    if (scan.summary.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(scan.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.bodyMedium),
                    ],
                  ],
                ),
              ),
              if (scan.healthScore != null) ...[
                const SizedBox(width: 10),
                HealthScoreRing.small(score: scan.healthScore!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.history, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(Strings.historyEmpty, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => context.go(Routes.scan), child: const Text(Strings.homeCta)),
        ],
      ),
    );
  }
}
