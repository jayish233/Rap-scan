import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/session.dart';
import '../../data/history_repository.dart';
import '../../data/photo_service.dart';
import '../../data/profile_repository.dart';
import '../../data/scan_api.dart';
import '../../domain/barcode.dart';
import '../../domain/scan_failure.dart';
import '../../domain/scan_result.dart';

enum ScanMode { text, photo, barcode }

class ScanState {
  const ScanState({
    this.mode = ScanMode.text,
    this.busy = false,
    this.outcome,
    this.failure,
    this.photo,
    this.inStoreCode,
    this.inStoreFromPhoto = false,
    this.cameraDenied = false,
    this.eventId = 0,
  });

  final ScanMode mode;
  final bool busy;
  final ScanOutcome? outcome;
  final ScanFailure? failure;

  /// Picked label photo, in memory only (never persisted).
  final PickedPhoto? photo;

  /// An in-store code → local inventory flow (PRD §7.5).
  final String? inStoreCode;
  final bool inStoreFromPhoto;

  /// Camera permission was denied; show the Settings explainer.
  final bool cameraDenied;

  /// Bumped on every finished attempt so the UI reacts exactly once.
  final int eventId;

  ScanState copyWith({
    ScanMode? mode,
    bool? busy,
    ScanOutcome? Function()? outcome,
    ScanFailure? Function()? failure,
    PickedPhoto? Function()? photo,
    String? Function()? inStoreCode,
    bool? inStoreFromPhoto,
    bool? cameraDenied,
    int? eventId,
  }) =>
      ScanState(
        mode: mode ?? this.mode,
        busy: busy ?? this.busy,
        outcome: outcome != null ? outcome() : this.outcome,
        failure: failure != null ? failure() : this.failure,
        photo: photo != null ? photo() : this.photo,
        inStoreCode: inStoreCode != null ? inStoreCode() : this.inStoreCode,
        inStoreFromPhoto: inStoreFromPhoto ?? this.inStoreFromPhoto,
        cameraDenied: cameraDenied ?? this.cameraDenied,
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

  void clearResult() => state = state.copyWith(
        outcome: () => null,
        failure: () => null,
        inStoreCode: () => null,
        photo: () => null,
      );

  /// Clears the in-store panel (e.g. after the user dismisses it).
  void clearInStore() => state = state.copyWith(inStoreCode: () => null);

  void markCameraDenied() => state = state.copyWith(
        cameraDenied: true,
        failure: () => const CameraDenied(),
        eventId: state.eventId + 1,
      );

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
        _openLocal(code, fromPhoto: false);
      case BarcodeInvalid():
        _fail(const InvalidBarcode());
      case BarcodeSendable(:final code):
        await _run(ScanRequest.barcode(code));
    }
  }

  Future<void> pickPhoto(PhotoSource source) async {
    if (state.busy) return;
    final PickedPhoto? photo;
    try {
      photo = await ref.read(photoServiceProvider).pick(source);
    } on PhotoAccessDenied {
      if (ref.mounted) markCameraDenied();
      return;
    }
    if (!ref.mounted || photo == null) return;
    // > 5 MB never leaves the device (PRD §7.3).
    if (photo.isTooLarge) return _fail(const PhotoTooLarge());
    state = state.copyWith(photo: () => photo, failure: () => null, inStoreCode: () => null);
  }

  void removePhoto() => state = state.copyWith(photo: () => null);

  /// Accepts a photo from any source (used by the picker and by tests).
  void setPhoto(PickedPhoto photo) {
    if (photo.isTooLarge) return _fail(const PhotoTooLarge());
    state = state.copyWith(photo: () => photo, failure: () => null, inStoreCode: () => null);
  }

  Future<void> submitPhoto() async {
    final photo = state.photo;
    if (state.busy || photo == null) return;
    if (photo.isTooLarge) return _fail(const PhotoTooLarge());
    await _run(() async => ScanRequest.photo(await ref.read(photoServiceProvider).toUploadDataUrl(photo)));
  }

  void _openLocal(String code, {required bool fromPhoto}) => state = state.copyWith(
        busy: false,
        outcome: () => null,
        failure: () => null,
        inStoreCode: () => code,
        inStoreFromPhoto: fromPhoto,
        eventId: state.eventId + 1,
      );

  /// [request] is a [ScanRequest] or a function building one (so photo
  /// compression runs under the busy indicator).
  Future<void> _run(Object request) async {
    // Zero remaining blocks new scans client-side too; the server enforces it.
    if (ref.read(quotaProvider).value?.isExhausted ?? false) return _fail(const QuotaExceeded());

    state = state.copyWith(busy: true, failure: () => null, inStoreCode: () => null);
    try {
      final body = request is ScanRequest ? request : await (request as Future<ScanRequest> Function())();
      final outcome = await ref.read(scanApiProvider).analyze(body);
      if (!ref.mounted) return;
      state = state.copyWith(busy: false, outcome: () => outcome, photo: () => null, eventId: state.eventId + 1);
      ref.invalidate(historyProvider);
    } on LocalBarcode catch (local) {
      if (ref.mounted) _openLocal(local.code, fromPhoto: local.fromPhoto);
    } on ScanFailure catch (failure) {
      if (ref.mounted) _fail(failure);
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
