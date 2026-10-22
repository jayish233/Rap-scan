import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/profile_repository.dart';
import '../../domain/scan_result.dart';
import '../../l10n/strings.dart';
import '../../widgets/brand.dart';
import '../../widgets/common.dart';
import 'result/scan_result_view.dart';
import 'scan_controller.dart';
import 'widgets/laser_scan_animation.dart';
import 'widgets/quota_chip.dart';

const _maxTextChars = 10000;

/// Scan tab (PRD §7.3, design.md §4.4): plan chip, input modes, one primary
/// button, the running animation, and the result below.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _text = TextEditingController();
  final _barcode = TextEditingController();
  final _resultKey = GlobalKey();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _text.dispose();
    _barcode.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final controller = ref.read(scanControllerProvider.notifier);
    switch (ref.read(scanControllerProvider).mode) {
      case ScanMode.text:
        controller.submitText(_text.text);
      case ScanMode.barcode:
        controller.submitBarcode(_barcode.text);
    }
  }

  void _onEvent(ScanState? previous, ScanState next) {
    if (previous?.eventId == next.eventId) return;
    final failure = next.failure;
    if (failure != null) {
      showToast(context, failure.message, error: true);
      return;
    }
    final outcome = next.outcome;
    if (outcome != null && next.inStoreCode == null) {
      showToast(
        context,
        outcome.source == ScanSource.photoBarcode ? Strings.photoBarcodeToast : Strings.scanCompleteToast,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = _resultKey.currentContext;
        if (target != null && target.mounted) {
          Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(scanControllerProvider, _onEvent);
    final scan = ref.watch(scanControllerProvider);
    final quota = ref.watch(quotaProvider).value;
    final exhausted = quota?.isExhausted ?? false;
    final controller = ref.read(scanControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const BrandLockup(), centerTitle: false),
      body: SafeArea(
        top: false,
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const Align(alignment: Alignment.centerLeft, child: QuotaChip()),
                  if (exhausted) ...[
                    const SizedBox(height: 12),
                    const _InlineCard(icon: Icons.lock_outline, color: AppColors.warning, body: Strings.quotaExhausted),
                  ],
                  const SizedBox(height: 16),
                  SegmentedButton<ScanMode>(
                    segments: const [
                      ButtonSegment(value: ScanMode.text, icon: Icon(Icons.notes), label: Text(Strings.modeText)),
                      ButtonSegment(
                        value: ScanMode.barcode,
                        icon: Icon(Icons.qr_code_2),
                        label: Text(Strings.modeBarcode),
                      ),
                    ],
                    selected: {scan.mode},
                    showSelectedIcon: false,
                    onSelectionChanged: scan.busy ? null : (s) => controller.setMode(s.first),
                  ),
                  const SizedBox(height: 16),
                  if (scan.mode == ScanMode.text)
                    TextField(
                      // Distinct keys: switching modes must not reuse the
                      // other field's state and input connection.
                      key: const ValueKey('scan-text-field'),
                      controller: _text,
                      enabled: !scan.busy,
                      minLines: 6,
                      maxLines: 12,
                      maxLength: _maxTextChars,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(hintText: Strings.textPlaceholder, alignLabelWithHint: true),
                      // Only show the counter when approaching the server cap.
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) =>
                          currentLength > _maxTextChars * 0.9 ? Text('$currentLength / $maxLength') : null,
                    )
                  else
                    TextField(
                      key: const ValueKey('scan-barcode-field'),
                      controller: _barcode,
                      enabled: !scan.busy,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.go,
                      // Strip spaces and non-digits as the user types (PRD §7.3).
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(14)],
                      decoration: const InputDecoration(
                        labelText: Strings.barcodeLabel,
                        hintText: Strings.barcodeHint,
                        prefixIcon: Icon(Icons.qr_code_2),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: scan.busy || exhausted ? null : _submit,
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: const Text(Strings.scanButton),
                  ),
                  if (scan.busy) ...[
                    const SizedBox(height: 16),
                    LaserScanAnimation(
                      message: scan.mode == ScanMode.barcode ? Strings.scanningBarcode : Strings.scanningText,
                    ),
                  ],
                  if (scan.inStoreCode != null) ...[
                    const SizedBox(height: 16),
                    _InlineCard(
                      icon: Icons.storefront_outlined,
                      color: AppColors.primary,
                      title: Strings.inStoreTitle,
                      body: Strings.inStoreBody(scan.inStoreCode!),
                    ),
                  ],
                  if (scan.outcome != null && !scan.busy) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 8),
                    KeyedSubtree(
                      key: _resultKey,
                      child: ScanResultView(
                        result: scan.outcome!.result,
                        scanId: scan.outcome!.scanId,
                        access: scan.outcome!.quota.access,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        _text.clear();
                        _barcode.clear();
                        controller.clearResult();
                        _scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text(Strings.startOver),
                    ),
                  ] else
                    const DisclaimerFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline warning/notice card (PRD §12: quota and local-barcode notices).
class _InlineCard extends StatelessWidget {
  const _InlineCard({required this.icon, required this.color, required this.body, this.title});

  final IconData icon;
  final Color color;
  final String body;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(AppSizes.radius),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) Text(title!, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  Text(body, style: text.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
