// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CautionDto _$CautionDtoFromJson(Map<String, dynamic> json) => _CautionDto(
  ingredient: json['ingredient'] as String? ?? '',
  concern: json['concern'] as String? ?? '',
  severity: json['severity'] as String?,
  percentage: json['percentage'] as String?,
  chemicalFormula: json['chemicalFormula'] as String?,
  scientificName: json['scientificName'] as String?,
);

Map<String, dynamic> _$CautionDtoToJson(_CautionDto instance) =>
    <String, dynamic>{
      'ingredient': instance.ingredient,
      'concern': instance.concern,
      'severity': ?instance.severity,
      'percentage': ?instance.percentage,
      'chemicalFormula': ?instance.chemicalFormula,
      'scientificName': ?instance.scientificName,
    };

_ConsumptionTipDto _$ConsumptionTipDtoFromJson(Map<String, dynamic> json) =>
    _ConsumptionTipDto(
      safeDaily: json['safeDaily'] as String? ?? '',
      limit: json['limit'] as String? ?? '',
      source: json['source'] as String? ?? '',
    );

Map<String, dynamic> _$ConsumptionTipDtoToJson(_ConsumptionTipDto instance) =>
    <String, dynamic>{
      'safeDaily': instance.safeDaily,
      'limit': instance.limit,
      'source': instance.source,
    };

_RiskProfileDto _$RiskProfileDtoFromJson(Map<String, dynamic> json) =>
    _RiskProfileDto(
      illnesses:
          (json['illnesses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      addictions:
          (json['addictions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      chronicDamage:
          (json['chronicDamage'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      temporaryEffects:
          (json['temporaryEffects'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      organDamage:
          (json['organDamage'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$RiskProfileDtoToJson(_RiskProfileDto instance) =>
    <String, dynamic>{
      'illnesses': instance.illnesses,
      'addictions': instance.addictions,
      'chronicDamage': instance.chronicDamage,
      'temporaryEffects': instance.temporaryEffects,
      'organDamage': instance.organDamage,
    };

_BodyMarkerDto _$BodyMarkerDtoFromJson(Map<String, dynamic> json) =>
    _BodyMarkerDto(
      part: json['part'] as String? ?? '',
      severity: json['severity'] as String?,
      reason: json['reason'] as String? ?? '',
      trigger: json['trigger'] as String?,
    );

Map<String, dynamic> _$BodyMarkerDtoToJson(_BodyMarkerDto instance) =>
    <String, dynamic>{
      'part': instance.part,
      'severity': ?instance.severity,
      'reason': instance.reason,
      'trigger': ?instance.trigger,
    };

_ScanResultDto _$ScanResultDtoFromJson(Map<String, dynamic> json) =>
    _ScanResultDto(
      productName: json['productName'] as String? ?? '',
      brand: json['brand'] as String?,
      parentCompany: json['parentCompany'] as String?,
      category: json['category'] as String?,
      rating: json['rating'] as String?,
      healthScore: json['healthScore'] as num?,
      caloriesKcal: json['caloriesKcal'] as num?,
      summary: json['summary'] as String? ?? '',
      advantages:
          (json['advantages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      disadvantages:
          (json['disadvantages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      cautions:
          (json['cautions'] as List<dynamic>?)
              ?.map((e) => CautionDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      personalAdvice: json['personalAdvice'] as String?,
      consumptionTip: json['consumptionTip'] == null
          ? null
          : ConsumptionTipDto.fromJson(
              json['consumptionTip'] as Map<String, dynamic>,
            ),
      riskProfile: json['riskProfile'] == null
          ? null
          : RiskProfileDto.fromJson(
              json['riskProfile'] as Map<String, dynamic>,
            ),
      bodyDamage:
          (json['bodyDamage'] as List<dynamic>?)
              ?.map((e) => BodyMarkerDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      bodyBenefit:
          (json['bodyBenefit'] as List<dynamic>?)
              ?.map((e) => BodyMarkerDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      dietaryType: json['dietaryType'] as String?,
      dietaryReason: json['dietaryReason'] as String?,
    );

Map<String, dynamic> _$ScanResultDtoToJson(_ScanResultDto instance) =>
    <String, dynamic>{
      'productName': instance.productName,
      'brand': ?instance.brand,
      'parentCompany': ?instance.parentCompany,
      'category': ?instance.category,
      'rating': ?instance.rating,
      'healthScore': ?instance.healthScore,
      'caloriesKcal': ?instance.caloriesKcal,
      'summary': instance.summary,
      'advantages': instance.advantages,
      'disadvantages': instance.disadvantages,
      'cautions': instance.cautions.map((e) => e.toJson()).toList(),
      'personalAdvice': ?instance.personalAdvice,
      'consumptionTip': ?instance.consumptionTip?.toJson(),
      'riskProfile': ?instance.riskProfile?.toJson(),
      'bodyDamage': instance.bodyDamage.map((e) => e.toJson()).toList(),
      'bodyBenefit': instance.bodyBenefit.map((e) => e.toJson()).toList(),
      'dietaryType': ?instance.dietaryType,
      'dietaryReason': ?instance.dietaryReason,
    };

_ScanEnvelopeDto _$ScanEnvelopeDtoFromJson(Map<String, dynamic> json) =>
    _ScanEnvelopeDto(
      result: ScanResultDto.fromJson(json['result'] as Map<String, dynamic>),
      scanId: json['scanId'] as String?,
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
      scanLimit: (json['scanLimit'] as num?)?.toInt() ?? 0,
      plan: json['plan'] as String? ?? 'free',
      planLabel: json['planLabel'] as String? ?? 'Free',
      isUnlimited: json['isUnlimited'] as bool? ?? false,
      source: json['source'] as String?,
      cached: json['cached'] as bool? ?? false,
      barcode: json['barcode'] as String?,
    );

Map<String, dynamic> _$ScanEnvelopeDtoToJson(_ScanEnvelopeDto instance) =>
    <String, dynamic>{
      'result': instance.result.toJson(),
      'scanId': ?instance.scanId,
      'remaining': instance.remaining,
      'scanLimit': instance.scanLimit,
      'plan': instance.plan,
      'planLabel': instance.planLabel,
      'isUnlimited': instance.isUnlimited,
      'source': ?instance.source,
      'cached': instance.cached,
      'barcode': ?instance.barcode,
    };

_ScanErrorDto _$ScanErrorDtoFromJson(Map<String, dynamic> json) =>
    _ScanErrorDto(
      error: json['error'] as String,
      message: json['message'] as String?,
      remaining: (json['remaining'] as num?)?.toInt(),
      scanLimit: (json['scanLimit'] as num?)?.toInt(),
      plan: json['plan'] as String?,
      planLabel: json['planLabel'] as String?,
      isUnlimited: json['isUnlimited'] as bool?,
      localBarcode: json['localBarcode'] as String?,
    );

Map<String, dynamic> _$ScanErrorDtoToJson(_ScanErrorDto instance) =>
    <String, dynamic>{
      'error': instance.error,
      'message': ?instance.message,
      'remaining': ?instance.remaining,
      'scanLimit': ?instance.scanLimit,
      'plan': ?instance.plan,
      'planLabel': ?instance.planLabel,
      'isUnlimited': ?instance.isUnlimited,
      'localBarcode': ?instance.localBarcode,
    };

_ScanRowDto _$ScanRowDtoFromJson(Map<String, dynamic> json) => _ScanRowDto(
  id: json['id'] as String,
  productName: json['product_name'] as String?,
  scanType: json['scan_type'] as String? ?? 'ingredients',
  rating: json['rating'] as String?,
  healthScore: json['health_score'] as num?,
  caloriesKcal: json['calories_kcal'] as num?,
  summary: json['summary'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$ScanRowDtoToJson(_ScanRowDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_name': ?instance.productName,
      'scan_type': instance.scanType,
      'rating': ?instance.rating,
      'health_score': ?instance.healthScore,
      'calories_kcal': ?instance.caloriesKcal,
      'summary': ?instance.summary,
      'created_at': instance.createdAt,
    };

_ScanDetailRowDto _$ScanDetailRowDtoFromJson(Map<String, dynamic> json) =>
    _ScanDetailRowDto(
      id: json['id'] as String,
      scanType: json['scan_type'] as String? ?? 'ingredients',
      createdAt: json['created_at'] as String,
      result: ScanResultDto.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ScanDetailRowDtoToJson(_ScanDetailRowDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scan_type': instance.scanType,
      'created_at': instance.createdAt,
      'result': instance.result.toJson(),
    };
