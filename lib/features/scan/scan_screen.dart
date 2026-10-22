import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/local_barcodes_store.dart';
import '../../data/profile_repository.dart';
import '../../domain/scan_result.dart';
import '../../l10n/strings.dart';
import '../../widgets/adaptive.dart';
import '../../widgets/common.dart';
import '../plans/plans_sheet.dart';
import 'local/local_inventory.dart';
import 'result/scan_result_view.dart';
import 'scan_controller.dart';
import 'widgets/barcode_viewfinder.dart';
import 'widgets/camera_denied_notice.dart';
import 'widgets/laser_scan_animation.dart';
import 'widgets/photo_panel.dart';
import 'widgets/quota_chip.dart';

const _maxTextChars = 10000;

/// Scan tab (handoff spec §4.2, mockups Main/android-scan): title + plan
/// chip, Text | Photo | Barcode selector, inline live viewfinder, one
/// primary button, local inventory and the result.
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

  /// Live viewfinder fills the field and submits (PRD §7.3).
  void _onViewfinderCode(String code) {
    if (ref.read(scanControllerProvider).busy) return;
    _barcode.text = code;
    _controller.submitBarcode(code);
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
    final ios = isIos(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            ContentWidth(
              padding: EdgeInsets.symmetric(horizontal: ios ? 24 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: ios ? 12 : 0),
                  ScreenHeader(
                    title: Strings.navScan,
                    subtitle: ios ? Strings.scanSubtitle : null,
                    trailing: const Padding(padding: EdgeInsets.only(bottom: 4), child: QuotaChip()),
                  ),
                  if (exhausted) ...[
                    const SizedBox(height: 12),
                    _InlineCard(
                      icon: Icons.lock_outline,
                      color: AppColors.warning,
                      title: Strings.quotaExhaustedTitle,
                      body: Strings.quotaExhausted,
                      action: TextButton(onPressed: () => showPlansSheet(context), child: const Text(Strings.seePlans)),
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppSegmented<ScanMode>(
                    options: const [
                      (ScanMode.text, Strings.modeText, Icons.description_outlined),
                      (ScanMode.photo, Strings.modePhoto, Icons.photo_camera_outlined),
                      (ScanMode.barcode, Strings.modeBarcode, CupertinoIcons.barcode),
                    ],
                    selected: scan.mode,
                    onChanged: scan.busy ? null : _controller.setMode,
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
                          minLines: ios ? 7 : 6,
                          maxLines: 12,
                          maxLength: _maxTextChars,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          keyboardType: TextInputType.multiline,
                          decoration: appInputDecoration(context, hint: Strings.textPlaceholder),
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
                        BarcodeViewfinder(
                          onCode: _onViewfinderCode,
                          onDenied: _controller.markCameraDenied,
                          paused: scan.busy,
                        ),
                        const SizedBox(height: 16),
                        const FieldCaption(label: Strings.orTypeNumber),
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
                          decoration: appInputDecoration(
                            context,
                            label: Strings.barcodeLabel,
                            hint: Strings.barcodeHintExample,
                            prefixIcon: CupertinoIcons.barcode,
                          ),
                          onSubmitted: (_) => _submit(),
                        ),
                        const FieldHelper(text: Strings.barcodeHelper),
                      ],
                  },
                  const SizedBox(height: 16),
                  AppPrimaryButton(
                    label: Strings.scanButton,
                    icon: Icons.document_scanner_outlined,
                    onPressed: canSubmit ? _submit : null,
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
                    KeyedSubtree(
                      key: _resultKey,
                      child: ScanResultView(
                        result: scan.outcome!.result,
                        scanId: scan.outcome!.scanId,
                        access: scan.outcome!.quota.access,
                        scanType: switch (scan.outcome!.source) {
                          ScanSource.barcode || ScanSource.photoBarcode => Strings.scanTypeBarcode,
                          _ => Strings.scanTypeIngredients,
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          _text.clear();
                          _barcode.clear();
                          _controller.clearResult();
                          _scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text(Strings.startOver),
                      ),
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
  const _InlineCard({required this.icon, required this.color, required this.title, required this.body, this.action});

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(cardRadius(context)),
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
                  Text(title, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(body, style: text.bodySmall?.copyWith(height: 1.45)),
                  ?action,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
