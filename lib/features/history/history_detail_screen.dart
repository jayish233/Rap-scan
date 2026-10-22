import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../data/history_repository.dart';
import '../../data/profile_repository.dart';
import '../../domain/plan.dart';
import '../../l10n/strings.dart';
import '../../widgets/common.dart';
import '../../widgets/format.dart';
import '../scan/result/scan_result_view.dart';

/// Saved scan (`/history/:id`): the stored analysis, no model re-run.
class HistoryDetailScreen extends ConsumerWidget {
  const HistoryDetailScreen({super.key, required this.scanId});

  final String scanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(scanDetailProvider(scanId));
    // Gate by the caller's current plan; hide gated blocks until it loads.
    final access = ref.watch(quotaProvider).value?.access ?? FeatureAccess.free;
    void back() => context.canPop() ? context.pop() : context.go(Routes.history);

    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: back)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            ContentWidth(
              child: switch (detail) {
                AsyncData(:final value) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (value.stale) const OfflineBanner(),
                      Text(
                        formatDateTime(value.value.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 8),
                      ScanResultView(result: value.value.result, scanId: value.value.id, access: access),
                    ],
                  ),
                AsyncError(:final error) when error is ScanNotFound => _NotFound(onBack: back),
                AsyncError() => ErrorState(
                    message: Strings.loadFailed,
                    onRetry: () => ref.invalidate(scanDetailProvider(scanId)),
                  ),
                _ => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(Strings.scanNotFound, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextButton.icon(onPressed: onBack, icon: const Icon(Icons.arrow_back), label: const Text(Strings.backToHistory)),
        ],
      ),
    );
  }
}
