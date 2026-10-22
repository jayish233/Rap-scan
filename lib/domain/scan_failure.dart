/// Typed scan failures (architecture.md §2.3), each mapped to verbatim copy.
library;

import '../l10n/strings.dart';
import 'plan.dart';

sealed class ScanFailure implements Exception {
  const ScanFailure({this.quota});

  /// Server quota after the failure, when the server reported it (the
  /// credit stays spent on model failures, PRD §15).
  final Quota? quota;

  String get message;
}

final class QuotaExceeded extends ScanFailure {
  const QuotaExceeded({super.quota});
  @override
  String get message => Strings.quotaExhausted;
}

final class RateLimited extends ScanFailure {
  const RateLimited({super.quota});
  @override
  String get message => Strings.rateLimited;
}

final class AiUnavailable extends ScanFailure {
  const AiUnavailable({super.quota});
  @override
  String get message => Strings.aiUnavailable;
}

final class AiCreditsExhausted extends ScanFailure {
  const AiCreditsExhausted({super.quota});
  @override
  String get message => Strings.aiCreditsExhausted;
}

final class RegistryMiss extends ScanFailure {
  const RegistryMiss(this.code, {super.quota});
  final String code;
  @override
  String get message => Strings.registryMiss(code);
}

final class InvalidBarcode extends ScanFailure {
  const InvalidBarcode();
  @override
  String get message => Strings.invalidBarcode;
}

final class EmptyText extends ScanFailure {
  const EmptyText();
  @override
  String get message => Strings.emptyTextError;
}

/// Server-side validation the client did not catch; shows the server copy.
final class ValidationFailure extends ScanFailure {
  const ValidationFailure(this.serverMessage);
  final String serverMessage;
  @override
  String get message => serverMessage;
}

/// The code is an in-store item; hand it to the local inventory flow.
final class LocalBarcode extends ScanFailure {
  const LocalBarcode(this.code, {this.fromPhoto = false, super.quota});
  final String code;
  final bool fromPhoto;
  @override
  String get message => Strings.localBarcodeFromPhoto(code);
}

final class NetworkDown extends ScanFailure {
  const NetworkDown();
  @override
  String get message => Strings.noNetwork;
}

final class SignedOut extends ScanFailure {
  const SignedOut();
  @override
  String get message => Strings.genericError;
}
