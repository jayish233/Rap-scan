import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/local_barcodes_store.dart';
import '../../data/profile_repository.dart';
import '../../domain/scan_result.dart';
import '../../l10n/strings.dart';
import '../../widgets/brand.dart';
import '../../widgets/common.dart';
import 'local/local_inventory.dart';
import 'result/scan_result_view.dart';
import 'scan_controller.dart';
import 'widgets/barcode_scanner_page.dart';
import 'widgets/camera_denied_notice.dart';
import 'widgets/laser_scan_animation.dart';
import 'widgets/photo_panel.dart';
import 'widgets/quota_chip.dart';

const _maxTextChars = 10000;

/// Scan tab (PRD §7.3, design.md §4.4): plan chip, three input modes, one
/// primary button, the running animation, local inventory and the result.
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

  ScanController get _controller => ref.read(scanControllerProvider.notifier);

  void _submit() {
    FocusScope.of(context).unfocus();
    switch (ref.read(scanControllerProvider).mode) {
      case ScanMode.text:
        _controller.submitText(_text.text);
      case ScanMode.photo:
        _controller.submitPhoto();
      case ScanMode.barcode:
        _controller.submitBarcode(_barcode.text);
    }
  }

  /// Live scanner fills the field and submits (PRD §7.3).
  Future<void> _openScanner() async {
    FocusScope.of(context).unfocus();
    final result = await BarcodeScannerPage.open(context);
    if (!mounted) return;
    switch (result) {
      case ScannedCode(:final code):
        _barcode.text = code;
        _controller.submitBarcode(code);
      case ScannerDenied():
        _controller.markCameraDenied();
      case null:
        break;
    }
  }

  void _scrollTo(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = key.currentContext;
      if (target != null && target.mounted) {
        Scrollable.ensureVisible(target, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _onEvent(ScanState? previous, ScanState next) async {
    if (previous?.eventId == next.eventId) return;
    final failure = next.failure;
    if (failure != null) {
      showToast(context, failure.message, error: true);
      return;
    }

    final code = next.inStoreCode;
    if (code != null) {
      if (next.inStoreFromPhoto) showToast(context, Strings.localBarcodeFromPhoto(code));
      // Unknown on this device → open the add dialog straight away (PRD §7.5).
      final saved = await ref.read(localBarcodesStoreProvider).get(code);
      if (saved == null && mounted && ref.read(scanControllerProvider).inStoreCode == code) {
        await showAddLocalItemDialog(context, code);
      }
      return;
    }

    final outcome = next.outcome;
    if (outcome != null) {
      showToast(
        context,
        outcome.source == ScanSource.photoBarcode ? Strings.photoBarcodeToast : Strings.scanCompleteToast,
      );
      _scrollTo(_resultKey);
    }
  }

  String _busyMessage(ScanMode mode) => switch (mode) {
        ScanMode.barcode => Strings.scanningBarcode,
        ScanMode.photo => Strings.scanningShort,
        ScanMode.text => Strings.scanningText,
      };

  @override
  Widget build(BuildContext context) {
    ref.listen(scanControllerProvider, _onEvent);
    final scan = ref.watch(scanControllerProvider);
    final quota = ref.watch(quotaProvider).value;
    final exhausted = quota?.isExhausted ?? false;
    final canSubmit = !scan.busy && !exhausted && (scan.mode != ScanMode.photo || scan.photo != null);

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
                        value: ScanMode.photo,
                        icon: Icon(Icons.photo_camera_outlined),
                        label: Text(Strings.modePhoto),
                      ),
                      ButtonSegment(
                        value: ScanMode.barcode,
                        icon: Icon(Icons.qr_code_2),
                        label: Text(Strings.modeBarcode),
                      ),
                    ],
                    selected: {scan.mode},
                    showSelectedIcon: false,
                    onSelectionChanged: scan.busy ? null : (s) => _controller.setMode(s.first),
                  ),
                  const SizedBox(height: 16),
                  ...switch (scan.mode) {
                    ScanMode.text => [
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
                        ),
                      ],
                    ScanMode.photo => [
                        if (scan.cameraDenied) ...[const CameraDeniedNotice(), const SizedBox(height: 12)],
                        PhotoPanel(
                          photo: scan.photo,
                          enabled: !scan.busy,
                          onPick: _controller.pickPhoto,
                          onRemove: _controller.removePhoto,
                        ),
                      ],
                    ScanMode.barcode => [
                        if (scan.cameraDenied) ...[const CameraDeniedNotice(), const SizedBox(height: 12)],
                        TextField(
                          key: const ValueKey('scan-barcode-field'),
                          controller: _barcode,
                          enabled: !scan.busy,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.go,
                          // Strip spaces and non-digits as the user types (PRD §7.3).
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(14),
                          ],
                          decoration: const InputDecoration(
                            labelText: Strings.barcodeLabel,
                            hintText: Strings.barcodeHint,
                            prefixIcon: Icon(Icons.qr_code_2),
                          ),
                          onSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: scan.busy ? null : _openScanner,
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text(Strings.scanWithCamera),
                        ),
                      ],
                  },
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: canSubmit ? _submit : null,
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: const Text(Strings.scanButton),
                  ),
                  if (scan.busy) ...[
                    const SizedBox(height: 16),
                    LaserScanAnimation(message: _busyMessage(scan.mode)),
                  ],
                  // Local inventory works even at zero scans and offline.
                  if (scan.inStoreCode != null && !scan.busy) ...[
                    const SizedBox(height: 16),
                    LocalInventoryPanel(code: scan.inStoreCode!),
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
                        _controller.clearResult();
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
  const _InlineCard({required this.icon, required this.color, required this.body});

  final IconData icon;
  final Color color;
  final String body;

  @override
  Widget build(BuildContext context) {
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
            Expanded(child: Text(body, style: Theme.of(context).textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
