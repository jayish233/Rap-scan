import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/session.dart';
import '../../data/history_repository.dart';
import '../../data/profile_repository.dart';
import '../../data/scan_api.dart';
import '../../domain/barcode.dart';
import '../../domain/scan_failure.dart';
import '../../domain/scan_result.dart';

enum ScanMode { text, barcode }

class ScanState {
  const ScanState({
    this.mode = ScanMode.text,
    this.busy = false,
    this.outcome,
    this.failure,
    this.inStoreCode,
    this.eventId = 0,
  });

  final ScanMode mode;
  final bool busy;
  final ScanOutcome? outcome;
  final ScanFailure? failure;

  /// A typed/scanned in-store code (local inventory flow, Phase 3).
  final String? inStoreCode;

  /// Bumped on every finished attempt so the UI can toast exactly once.
  final int eventId;

  ScanState copyWith({
    ScanMode? mode,
    bool? busy,
    ScanOutcome? Function()? outcome,
    ScanFailure? Function()? failure,
    String? Function()? inStoreCode,
    int? eventId,
  }) =>
      ScanState(
        mode: mode ?? this.mode,
        busy: busy ?? this.busy,
        outcome: outcome != null ? outcome() : this.outcome,
        failure: failure != null ? failure() : this.failure,
        inStoreCode: inStoreCode != null ? inStoreCode() : this.inStoreCode,
        eventId: eventId ?? this.eventId,
      );
}

class ScanController extends Notifier<ScanState> {
  @override
  ScanState build() {
    ref.watch(currentUserIdProvider); // reset on account change
    return const ScanState();
  }

  void setMode(ScanMode mode) {
    if (state.busy || mode == state.mode) return;
    state = state.copyWith(mode: mode, failure: () => null, inStoreCode: () => null);
  }

  void clearResult() => state = state.copyWith(outcome: () => null, failure: () => null, inStoreCode: () => null);

  Future<void> submitText(String text) async {
    if (state.busy) return;
    if (text.trim().isEmpty) return _fail(const EmptyText());
    await _run(ScanRequest.ingredients(text.trim()));
  }

  Future<void> submitBarcode(String input) async {
    if (state.busy) return;
    // On-device pre-flight: these never reach the server or spend a credit.
    switch (checkBarcode(input)) {
      case BarcodeInStore(:final code):
        state = state.copyWith(
          outcome: () => null,
          failure: () => null,
          inStoreCode: () => code,
          eventId: state.eventId + 1,
        );
      case BarcodeInvalid():
        _fail(const InvalidBarcode());
      case BarcodeSendable(:final code):
        await _run(ScanRequest.barcode(code));
    }
  }

  Future<void> _run(ScanRequest request) async {
    // Zero remaining blocks new scans client-side too; the server enforces it.
    if (ref.read(quotaProvider).value?.isExhausted ?? false) return _fail(const QuotaExceeded());

    state = state.copyWith(busy: true, failure: () => null, inStoreCode: () => null);
    try {
      final outcome = await ref.read(scanApiProvider).analyze(request);
      if (!ref.mounted) return;
      state = state.copyWith(busy: false, outcome: () => outcome, eventId: state.eventId + 1);
      ref.invalidate(historyProvider);
    } on ScanFailure catch (failure) {
      if (!ref.mounted) return;
      if (failure is LocalBarcode) {
        state = state.copyWith(busy: false, inStoreCode: () => failure.code, eventId: state.eventId + 1);
      } else {
        _fail(failure);
      }
    } catch (_) {
      if (ref.mounted) _fail(const AiUnavailable());
    } finally {
      // Credits may have changed even on failure (PRD §15); re-read the server.
      if (ref.mounted) ref.invalidate(quotaProvider);
    }
  }

  void _fail(ScanFailure failure) =>
      state = state.copyWith(busy: false, failure: () => failure, eventId: state.eventId + 1);
}

final scanControllerProvider = NotifierProvider<ScanController, ScanState>(ScanController.new);
