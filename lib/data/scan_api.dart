import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/scan_failure.dart';
import '../domain/scan_result.dart';
import 'dto/scan_dto.dart';
import 'supabase_client.dart';

/// Body of an analyze-scan call (architecture.md §3.3).
class ScanRequest {
  const ScanRequest.ingredients(String this.text)
      : scanType = 'ingredients',
        barcode = null,
        imageDataUrl = null;

  const ScanRequest.barcode(String this.barcode)
      : scanType = 'barcode',
        text = null,
        imageDataUrl = null;

  const ScanRequest.photo(String this.imageDataUrl)
      : scanType = 'ingredients',
        text = null,
        barcode = null;

  final String scanType;
  final String? text;
  final String? barcode;
  final String? imageDataUrl;

  Map<String, dynamic> toJson() => {
        'scanType': scanType,
        'text': ?text,
        'barcode': ?barcode,
        'imageDataUrl': ?imageDataUrl,
      };
}

/// The only path to analysis: the analyze-scan edge function. The app never
/// calls the model or the food registries itself (CLAUDE.md hard rule 1).
class ScanApi {
  ScanApi(this._client);

  final SupabaseClient _client;

  static const timeout = Duration(seconds: 90);

  /// Returns the outcome or throws a [ScanFailure].
  Future<ScanOutcome> analyze(ScanRequest request) async {
    try {
      final res = await _client.functions
          .invoke('analyze-scan', body: request.toJson())
          .timeout(timeout);
      return ScanEnvelopeDto.fromJson(_asMap(res.data)).toDomain();
    } on FunctionsFetchException {
      throw const NetworkDown();
    } on FunctionException catch (e) {
      throw failureFromError(e.status, e.details, fromPhoto: request.imageDataUrl != null);
    } on TimeoutException {
      throw const AiUnavailable();
    }
  }

  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const AiUnavailable();
  }
}

/// Map an analyze-scan error envelope to a typed failure (design.md §10 copy
/// is attached by the failure type, never taken from raw exceptions).
ScanFailure failureFromError(int status, Object? details, {bool fromPhoto = false}) {
  final ScanErrorDto dto;
  try {
    dto = ScanErrorDto.fromJson(ScanApi._asMap(details));
  } catch (_) {
    return status == 401 ? const SignedOut() : const AiUnavailable();
  }
  final quota = dto.quota;
  return switch (dto.error) {
    'quota_exceeded' => QuotaExceeded(quota: quota),
    'rate_limited' => RateLimited(quota: quota),
    'ai_credits_exhausted' => AiCreditsExhausted(quota: quota),
    'registry_miss' => RegistryMiss(_codeFrom(dto.message) ?? '', quota: quota),
    'invalid_barcode' => const InvalidBarcode(),
    'local_barcode' => LocalBarcode(dto.localBarcode ?? '', fromPhoto: fromPhoto, quota: quota),
    'validation' => ValidationFailure(dto.message ?? ''),
    'unauthorized' => const SignedOut(),
    _ => AiUnavailable(quota: quota),
  };
}

String? _codeFrom(String? message) =>
    message == null ? null : RegExp(r'barcode (\d{8,14})').firstMatch(message)?.group(1);

final scanApiProvider = Provider<ScanApi>((ref) => ScanApi(ref.watch(supabaseClientProvider)));
