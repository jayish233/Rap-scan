import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../data/history_repository.dart';
import '../../data/profile_repository.dart';
import '../../domain/plan.dart';
import '../../l10n/strings.dart';
import '../../widgets/adaptive.dart';
import '../../widgets/common.dart';
import '../scan/result/scan_result_view.dart';

/// Saved scan (`/history/:id`): the stored analysis, no model re-run.
/// Header per mockups: iOS a "< Scan" back link, Android back arrow +
/// "Scan result" title.
class HistoryDetailScreen extends ConsumerWidget {
  const HistoryDetailScreen({super.key, required this.scanId});

  final String scanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(scanDetailProvider(scanId));
    // Gate by the caller's current plan; hide gated blocks until it loads.
    final access = ref.watch(quotaProvider).value?.access ?? FeatureAccess.free;
    final ios = isIos(context);
    void back() => context.canPop() ? context.pop() : context.go(Routes.history);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            ContentWidth(
              padding: EdgeInsets.symmetric(horizontal: ios ? 20 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (ios)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: back,
                        icon: const Icon(Icons.chevron_left, size: 22),
                        label: const Text(Strings.navScan),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          textStyle: const TextStyle(fontFamily: AppFonts.body, fontSize: 17, fontWeight: FontWeight.w600),
                          minimumSize: const Size(0, 44),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 64,
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: Strings.backToHistory,
                            onPressed: back,
                            icon: const Icon(Icons.arrow_back),
                            style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                          ),
                          Text(Strings.scanResultTitle, style: Theme.of(context).textTheme.headlineSmall),
                        ],
                      ),
                    ),
                  switch (detail) {
                    AsyncData(:final value) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (value.stale) const OfflineBanner(),
                          ScanResultView(
                            result: value.value.result,
                            scanId: value.value.id,
                            access: access,
                            scanType: value.value.scanType == 'barcode' ? Strings.scanTypeBarcode : Strings.scanTypeIngredients,
                          ),
                        ],
                      ),
                    AsyncError(:final error) when error is ScanNotFound => _NotFound(onBack: back),
                    AsyncError() => ErrorState(
                        message: Strings.loadFailed,
                        onRetry: () => ref.invalidate(scanDetailProvider(scanId)),
                      ),
                    _ => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
                  },
                ],
              ),
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
