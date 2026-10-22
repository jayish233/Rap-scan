import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../data/history_repository.dart';
import '../../domain/scan_result.dart';
import '../../l10n/strings.dart';
import '../../widgets/adaptive.dart';
import '../../widgets/common.dart';
import '../../widgets/format.dart';
import '../scan/result/health_score_ring.dart';
import '../scan/result/result_widgets.dart';

/// Scan history (handoff spec §4.4, mockups ios/android-history): newest
/// first. iOS rows lead with a rating dot, Android rows lead with the small
/// ring and carry a rating chip.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(historyProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              ContentWidth(
                padding: EdgeInsets.symmetric(horizontal: isIos(context) ? 20 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ScreenHeader(title: Strings.historyTitle, subtitle: Strings.historySubtitle),
                    const SizedBox(height: 14),
                    ...switch (history) {
                      AsyncData(:final value) => [
                          if (value.stale) const OfflineBanner(),
                          if (value.value.isEmpty)
                            const _EmptyHistory()
                          else
                            for (final scan in value.value) ...[
                              _HistoryRow(scan: scan),
                              SizedBox(height: isIos(context) ? 10 : 8),
                            ],
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
    final ios = isIos(context);
    final rating = scan.rating;
    final ratingColor = rating == null ? AppColors.textMuted : toneColor(rating.tone);
    final type = scan.scanType == 'barcode' ? Strings.scanTypeBarcode : Strings.scanTypeIngredients;
    final when = formatRelative(scan.createdAt);

    return AppCard(
      radius: ios ? 18 : 16,
      onTap: () => context.go(Routes.historyDetail(scan.id)),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: ios ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (ios)
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 12),
              child: Semantics(
                label: rating == null ? null : 'Rating: ${rating.label}',
                child: Container(width: 10, height: 10, decoration: BoxDecoration(color: ratingColor, shape: BoxShape.circle)),
              ),
            )
          else if (scan.healthScore != null) ...[
            HealthScoreRing.small(score: scan.healthScore!),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ios) ...[
                  Text(scan.productName, style: text.titleSmall?.copyWith(fontFamily: AppFonts.display, fontSize: 16, letterSpacing: -0.3)),
                  const SizedBox(height: 2),
                  Text(
                    '$when · $type'.toUpperCase(),
                    style: text.labelSmall?.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.7),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          scan.productName,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleSmall?.copyWith(fontFamily: AppFonts.display, fontSize: 16, letterSpacing: -0.3),
                        ),
                      ),
                      if (rating != null) RatingChip(rating: rating),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('$when · $type', style: text.bodySmall?.copyWith(color: AppColors.textMuted)),
                ],
                if (scan.summary.isNotEmpty) ...[
                  SizedBox(height: ios ? 6 : 4),
                  Text(scan.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.bodySmall?.copyWith(height: 1.4, fontSize: 13)),
                ],
              ],
            ),
          ),
          if (ios && scan.healthScore != null) ...[
            const SizedBox(width: 10),
            HealthScoreRing.small(score: scan.healthScore!),
          ],
        ],
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
          AppPrimaryButton(label: Strings.runFirstScan, onPressed: () => context.go(Routes.scan)),
        ],
      ),
    );
  }
}
