import 'package:flutter_test/flutter_test.dart';
import 'package:learn/data/dto/scan_dto.dart';
import 'package:learn/data/scan_api.dart';
import 'package:learn/domain/rating.dart';
import 'package:learn/domain/scan_failure.dart';
import 'package:learn/domain/scan_result.dart';
import 'package:learn/l10n/strings.dart';

/// Shape captured from the live analyze-scan function (free caller).
const _freeEnvelope = {
  'result': {
    'productName': 'Maggi Noodles Masala 70Grm Pc',
    'brand': 'Maggi',
    'parentCompany': 'Nestlé India',
    'category': 'Instant noodles',
    'rating': 'caution',
    'healthScore': 25,
    'caloriesKcal': 310,
    'summary': 'Instant noodles high in refined flour, salt and palm oil.',
    'advantages': ['Quick to prepare'],
    'disadvantages': ['High sodium', 'Refined flour'],
    'cautions': [
      {'ingredient': 'Palm oil', 'concern': 'High in saturated fat.', 'severity': 'medium'},
    ],
  },
  'scanId': '2a8d7e29-e667-4601-94d5-bcbb3750519d',
  'remaining': 29,
  'scanLimit': 30,
  'plan': 'free',
  'planLabel': 'Free',
  'isUnlimited': false,
  'source': 'barcode',
  'cached': false,
  'barcode': '8901058851298',
};

void main() {
  test('parses a free-tier envelope with gated fields absent', () {
    final outcome = ScanEnvelopeDto.fromJson(_freeEnvelope).toDomain();
    expect(outcome.scanId, '2a8d7e29-e667-4601-94d5-bcbb3750519d');
    expect(outcome.quota.remaining, 29);
    expect(outcome.quota.planLabel, 'Free');
    expect(outcome.source, ScanSource.barcode);
    final r = outcome.result;
    expect(r.productName, 'Maggi Noodles Masala 70Grm Pc');
    expect(r.rating, Rating.caution);
    expect(r.cautions.single.severity, Severity.medium);
    expect(r.consumptionTip, isNull);
    expect(r.riskProfile, isNull);
    expect(r.bodyDamage, isEmpty);
    expect(r.dietaryType, isNull);
  });

  test('clamps dirty values and tolerates missing keys', () {
    final r = ScanResultDto.fromJson({'healthScore': 180, 'caloriesKcal': -40, 'rating': '??'}).toDomain();
    expect(r.healthScore, 100);
    expect(r.caloriesKcal, 0);
    expect(r.rating, isNull);
    expect(r.productName, 'Unidentified product');
    expect(r.advantages, isEmpty);
  });

  test('history row: snake_case projection, local time, clamped score', () {
    final s = ScanRowDto.fromJson({
      'id': 'x',
      'product_name': 'Curd',
      'scan_type': 'barcode',
      'rating': 'good',
      'health_score': 104,
      'summary': 'Fermented dairy.',
      'created_at': '2026-10-22T08:00:00+00:00',
    }).toDomain();
    expect(s.healthScore, 100);
    expect(s.createdAt.isUtc, isFalse);
    expect(s.rating, Rating.good);
  });

  group('error envelope → typed failure with verbatim copy', () {
    Map<String, dynamic> err(String code, [Map<String, dynamic> extra = const {}]) =>
        {'error': code, 'message': 'server text', ...extra};

    test('quota exceeded carries the server quota', () {
      final f = failureFromError(402, err('quota_exceeded', {'remaining': 0, 'scanLimit': 30, 'plan': 'free', 'planLabel': 'Free'}));
      expect(f, isA<QuotaExceeded>());
      expect(f.message, Strings.quotaExhausted);
      expect(f.quota!.remaining, 0);
    });

    test('model failures keep the reduced remaining count', () {
      final f = failureFromError(429, err('rate_limited', {'remaining': 28, 'scanLimit': 30, 'plan': 'free'}));
      expect(f, isA<RateLimited>());
      expect(f.message, Strings.rateLimited);
      expect(f.quota!.remaining, 28);
      expect(failureFromError(503, err('ai_unavailable')).message, Strings.aiUnavailable);
      expect(failureFromError(503, err('ai_credits_exhausted')).message, Strings.aiCreditsExhausted);
    });

    test('registry miss names the code', () {
      final f = failureFromError(404, {
        'error': 'registry_miss',
        'message': 'Product not found in the Open Food Facts / GS1 registry for barcode 8906000000007. …',
      });
      expect(f, isA<RegistryMiss>());
      expect(f.message, Strings.registryMiss('8906000000007'));
    });

    test('invalid barcode, local barcode, unknown and non-JSON', () {
      expect(failureFromError(400, err('invalid_barcode')).message, Strings.invalidBarcode);
      final local = failureFromError(422, err('local_barcode', {'localBarcode': '2000000123455'}), fromPhoto: true);
      expect(local, isA<LocalBarcode>());
      expect((local as LocalBarcode).code, '2000000123455');
      expect(local.message, Strings.localBarcodeFromPhoto('2000000123455'));
      expect(failureFromError(500, err('something_new')), isA<AiUnavailable>());
      expect(failureFromError(502, 'Bad gateway'), isA<AiUnavailable>());
      expect(failureFromError(401, null), isA<SignedOut>());
    });
  });

  test('request bodies match the edge-function contract', () {
    expect(const ScanRequest.ingredients('sugar').toJson(), {'scanType': 'ingredients', 'text': 'sugar'});
    expect(const ScanRequest.barcode('8901058851298').toJson(), {'scanType': 'barcode', 'barcode': '8901058851298'});
  });
}
