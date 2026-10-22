/// Scan result domain model (PRD §11.1). Pure Dart.
library;

import 'plan.dart';
import 'rating.dart';

enum Severity {
  low('Low'),
  medium('Medium'),
  high('High');

  const Severity(this.label);
  final String label;

  static Severity fromWire(String? value) => switch (value) {
        'high' => Severity.high,
        'medium' => Severity.medium,
        _ => Severity.low,
      };
}

enum DietaryType {
  veg('Vegetarian'),
  nonVeg('Non-Vegetarian'),
  vegan('Vegan'),
  unknown('Unknown');

  const DietaryType(this.label);
  final String label;

  static DietaryType? fromWire(String? value) => switch (value) {
        'veg' => DietaryType.veg,
        'non-veg' => DietaryType.nonVeg,
        'vegan' => DietaryType.vegan,
        'unknown' => DietaryType.unknown,
        _ => null,
      };
}

class Caution {
  const Caution({
    required this.ingredient,
    required this.concern,
    required this.severity,
    this.percentage,
    this.chemicalFormula,
    this.scientificName,
  });

  final String ingredient;
  final String concern;
  final Severity severity;
  final String? percentage;
  final String? chemicalFormula;
  final String? scientificName;
}

class ConsumptionTip {
  const ConsumptionTip({required this.safeDaily, required this.limit, required this.source});

  final String safeDaily;
  final String limit;
  final String source;
}

class RiskProfile {
  const RiskProfile({
    this.illnesses = const [],
    this.addictions = const [],
    this.chronicDamage = const [],
    this.temporaryEffects = const [],
    this.organDamage = const [],
  });

  final List<String> illnesses;
  final List<String> addictions;
  final List<String> chronicDamage;
  final List<String> temporaryEffects;
  final List<String> organDamage;

  bool get isEmpty =>
      illnesses.isEmpty &&
      addictions.isEmpty &&
      chronicDamage.isEmpty &&
      temporaryEffects.isEmpty &&
      organDamage.isEmpty;
}

class BodyMarker {
  const BodyMarker({required this.part, required this.severity, required this.reason, this.trigger});

  final String part;
  final Severity severity;
  final String reason;
  final String? trigger;
}

class ScanResult {
  ScanResult({
    required this.productName,
    this.brand,
    this.parentCompany,
    this.category,
    required this.rating,
    required num? healthScore,
    required num? caloriesKcal,
    required this.summary,
    this.advantages = const [],
    this.disadvantages = const [],
    this.cautions = const [],
    this.personalAdvice,
    this.consumptionTip,
    this.riskProfile,
    this.bodyDamage = const [],
    this.bodyBenefit = const [],
    this.dietaryType,
    this.dietaryReason,
  })  : healthScore = clampScore(healthScore),
        caloriesKcal = clampCalories(caloriesKcal);

  final String productName;
  final String? brand;
  final String? parentCompany;
  final String? category;
  final Rating? rating;
  final int healthScore; // clamped 0–100
  final int caloriesKcal; // clamped 0–5000
  final String summary;
  final List<String> advantages;
  final List<String> disadvantages;
  final List<Caution> cautions;
  final String? personalAdvice;
  final ConsumptionTip? consumptionTip;
  final RiskProfile? riskProfile;
  final List<BodyMarker> bodyDamage;
  final List<BodyMarker> bodyBenefit;
  final DietaryType? dietaryType;
  final String? dietaryReason;

  ScoreBand get scoreBand => ScoreBand.of(healthScore);
}

enum ScanSource { ingredients, image, barcode, photoBarcode }

/// A successful analyze-scan response.
class ScanOutcome {
  const ScanOutcome({
    required this.result,
    required this.scanId,
    required this.quota,
    required this.source,
    this.cached = false,
  });

  final ScanResult result;
  final String? scanId;
  final Quota quota;
  final ScanSource source;
  final bool cached;
}

/// History list row (scans list projection, PRD §11.2).
class ScanSummary {
  const ScanSummary({
    required this.id,
    required this.productName,
    required this.scanType,
    required this.rating,
    required this.healthScore,
    required this.summary,
    required this.createdAt,
  });

  final String id;
  final String productName;
  final String scanType; // 'ingredients' | 'barcode'
  final Rating? rating;
  final int? healthScore; // clamped when present
  final String summary;
  final DateTime createdAt;
}

/// A saved scan opened from history (no re-run of the model).
class ScanDetail {
  const ScanDetail({required this.id, required this.scanType, required this.createdAt, required this.result});

  final String id;
  final String scanType;
  final DateTime createdAt;
  final ScanResult result;
}
