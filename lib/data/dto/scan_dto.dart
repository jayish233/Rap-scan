// Wire DTOs for analyze-scan and the scans table (PRD §11.1, §11.2;
// architecture.md §4). The result object is camelCase on the wire; table
// rows are snake_case. Every field the server may omit (tier gating, old
// rows) is nullable or defaulted so parsing never fails on a missing key.
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/plan.dart';
import '../../domain/rating.dart';
import '../../domain/scan_result.dart';

part 'scan_dto.freezed.dart';
part 'scan_dto.g.dart';

@freezed
abstract class CautionDto with _$CautionDto {
  const factory CautionDto({
    @Default('') String ingredient,
    @Default('') String concern,
    String? severity,
    String? percentage,
    String? chemicalFormula,
    String? scientificName,
  }) = _CautionDto;

  factory CautionDto.fromJson(Map<String, dynamic> json) => _$CautionDtoFromJson(json);
}

@freezed
abstract class ConsumptionTipDto with _$ConsumptionTipDto {
  const factory ConsumptionTipDto({
    @Default('') String safeDaily,
    @Default('') String limit,
    @Default('') String source,
  }) = _ConsumptionTipDto;

  factory ConsumptionTipDto.fromJson(Map<String, dynamic> json) => _$ConsumptionTipDtoFromJson(json);
}

@freezed
abstract class RiskProfileDto with _$RiskProfileDto {
  const factory RiskProfileDto({
    @Default([]) List<String> illnesses,
    @Default([]) List<String> addictions,
    @Default([]) List<String> chronicDamage,
    @Default([]) List<String> temporaryEffects,
    @Default([]) List<String> organDamage,
  }) = _RiskProfileDto;

  factory RiskProfileDto.fromJson(Map<String, dynamic> json) => _$RiskProfileDtoFromJson(json);
}

@freezed
abstract class BodyMarkerDto with _$BodyMarkerDto {
  const factory BodyMarkerDto({
    @Default('') String part,
    String? severity,
    @Default('') String reason,
    String? trigger,
  }) = _BodyMarkerDto;

  factory BodyMarkerDto.fromJson(Map<String, dynamic> json) => _$BodyMarkerDtoFromJson(json);
}

@freezed
abstract class ScanResultDto with _$ScanResultDto {
  const factory ScanResultDto({
    @Default('') String productName,
    String? brand,
    String? parentCompany,
    String? category,
    String? rating,
    num? healthScore,
    num? caloriesKcal,
    @Default('') String summary,
    @Default([]) List<String> advantages,
    @Default([]) List<String> disadvantages,
    @Default([]) List<CautionDto> cautions,
    String? personalAdvice,
    ConsumptionTipDto? consumptionTip,
    RiskProfileDto? riskProfile,
    @Default([]) List<BodyMarkerDto> bodyDamage,
    @Default([]) List<BodyMarkerDto> bodyBenefit,
    String? dietaryType,
    String? dietaryReason,
  }) = _ScanResultDto;

  factory ScanResultDto.fromJson(Map<String, dynamic> json) => _$ScanResultDtoFromJson(json);
}

/// analyze-scan success envelope.
@freezed
abstract class ScanEnvelopeDto with _$ScanEnvelopeDto {
  const factory ScanEnvelopeDto({
    required ScanResultDto result,
    String? scanId,
    @Default(0) int remaining,
    @Default(0) int scanLimit,
    @Default('free') String plan,
    @Default('Free') String planLabel,
    @Default(false) bool isUnlimited,
    String? source,
    @Default(false) bool cached,
    String? barcode,
  }) = _ScanEnvelopeDto;

  factory ScanEnvelopeDto.fromJson(Map<String, dynamic> json) => _$ScanEnvelopeDtoFromJson(json);
}

/// analyze-scan error envelope (architecture.md §4.2).
@freezed
abstract class ScanErrorDto with _$ScanErrorDto {
  const factory ScanErrorDto({
    required String error,
    String? message,
    int? remaining,
    int? scanLimit,
    String? plan,
    String? planLabel,
    bool? isUnlimited,
    String? localBarcode,
  }) = _ScanErrorDto;

  factory ScanErrorDto.fromJson(Map<String, dynamic> json) => _$ScanErrorDtoFromJson(json);
}

/// `scans` list projection row.
@freezed
abstract class ScanRowDto with _$ScanRowDto {
  const factory ScanRowDto({
    required String id,
    @JsonKey(name: 'product_name') String? productName,
    @JsonKey(name: 'scan_type') @Default('ingredients') String scanType,
    String? rating,
    @JsonKey(name: 'health_score') num? healthScore,
    @JsonKey(name: 'calories_kcal') num? caloriesKcal,
    String? summary,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _ScanRowDto;

  factory ScanRowDto.fromJson(Map<String, dynamic> json) => _$ScanRowDtoFromJson(json);
}

/// `scans` detail row with the full saved result.
@freezed
abstract class ScanDetailRowDto with _$ScanDetailRowDto {
  const factory ScanDetailRowDto({
    required String id,
    @JsonKey(name: 'scan_type') @Default('ingredients') String scanType,
    @JsonKey(name: 'created_at') required String createdAt,
    required ScanResultDto result,
  }) = _ScanDetailRowDto;

  factory ScanDetailRowDto.fromJson(Map<String, dynamic> json) => _$ScanDetailRowDtoFromJson(json);
}

// ---------- DTO → domain ----------

String? _nonEmpty(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();

extension ScanResultDtoX on ScanResultDto {
  ScanResult toDomain() => ScanResult(
        productName: _nonEmpty(productName) ?? 'Unidentified product',
        brand: _nonEmpty(brand),
        parentCompany: _nonEmpty(parentCompany),
        category: _nonEmpty(category),
        rating: Rating.fromWire(rating),
        healthScore: healthScore,
        caloriesKcal: caloriesKcal,
        summary: summary.trim(),
        advantages: advantages.where((a) => a.trim().isNotEmpty).toList(),
        disadvantages: disadvantages.where((a) => a.trim().isNotEmpty).toList(),
        cautions: [
          for (final c in cautions)
            if (c.ingredient.trim().isNotEmpty)
              Caution(
                ingredient: c.ingredient.trim(),
                concern: c.concern.trim(),
                severity: Severity.fromWire(c.severity),
                percentage: _nonEmpty(c.percentage),
                chemicalFormula: _nonEmpty(c.chemicalFormula),
                scientificName: _nonEmpty(c.scientificName),
              ),
        ],
        personalAdvice: _nonEmpty(personalAdvice),
        consumptionTip: consumptionTip == null || _nonEmpty(consumptionTip!.safeDaily) == null
            ? null
            : ConsumptionTip(
                safeDaily: consumptionTip!.safeDaily,
                limit: consumptionTip!.limit,
                source: consumptionTip!.source,
              ),
        riskProfile: riskProfile == null
            ? null
            : RiskProfile(
                illnesses: riskProfile!.illnesses,
                addictions: riskProfile!.addictions,
                chronicDamage: riskProfile!.chronicDamage,
                temporaryEffects: riskProfile!.temporaryEffects,
                organDamage: riskProfile!.organDamage,
              ),
        bodyDamage: bodyDamage.map((m) => m.toDomain()).toList(),
        bodyBenefit: bodyBenefit.map((m) => m.toDomain()).toList(),
        dietaryType: DietaryType.fromWire(dietaryType),
        dietaryReason: _nonEmpty(dietaryReason),
      );
}

extension BodyMarkerDtoX on BodyMarkerDto {
  BodyMarker toDomain() =>
      BodyMarker(part: part, severity: Severity.fromWire(severity), reason: reason, trigger: _nonEmpty(trigger));
}

ScanSource _source(String? s) => switch (s) {
      'barcode' => ScanSource.barcode,
      'photo_barcode' => ScanSource.photoBarcode,
      'image' => ScanSource.image,
      _ => ScanSource.ingredients,
    };

extension ScanEnvelopeDtoX on ScanEnvelopeDto {
  ScanOutcome toDomain() => ScanOutcome(
        result: result.toDomain(),
        scanId: scanId,
        quota: Quota(
          remaining: remaining,
          scanLimit: scanLimit,
          plan: plan,
          planLabel: planLabel,
          isUnlimited: isUnlimited,
        ),
        source: _source(source),
        cached: cached,
      );
}

extension ScanErrorDtoX on ScanErrorDto {
  Quota? get quota => remaining == null || scanLimit == null || plan == null
      ? null
      : Quota(
          remaining: remaining!,
          scanLimit: scanLimit!,
          plan: plan!,
          planLabel: planLabel ?? 'Free',
          isUnlimited: isUnlimited ?? false,
        );
}

extension ScanRowDtoX on ScanRowDto {
  ScanSummary toDomain() => ScanSummary(
        id: id,
        productName: _nonEmpty(productName) ?? 'Unidentified product',
        scanType: scanType,
        rating: Rating.fromWire(rating),
        healthScore: healthScore == null ? null : clampScore(healthScore),
        summary: summary?.trim() ?? '',
        createdAt: DateTime.parse(createdAt).toLocal(),
      );
}

extension ScanDetailRowDtoX on ScanDetailRowDto {
  ScanDetail toDomain() => ScanDetail(
        id: id,
        scanType: scanType,
        createdAt: DateTime.parse(createdAt).toLocal(),
        result: result.toDomain(),
      );
}
