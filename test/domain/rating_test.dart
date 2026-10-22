import 'package:flutter_test/flutter_test.dart';
import 'package:learn/domain/plan.dart';
import 'package:learn/domain/rating.dart';

void main() {
  test('score bands and labels (design.md §7.1)', () {
    expect(ScoreBand.of(100).label, 'Excellent for you');
    expect(ScoreBand.of(85).label, 'Excellent for you');
    expect(ScoreBand.of(84).label, 'Healthy choice');
    expect(ScoreBand.of(70).label, 'Healthy choice');
    expect(ScoreBand.of(69).label, 'Okay in moderation');
    expect(ScoreBand.of(40).label, 'Okay in moderation');
    expect(ScoreBand.of(39).label, 'Eat rarely');
    expect(ScoreBand.of(20).label, 'Eat rarely');
    expect(ScoreBand.of(19).label, 'Better avoid');
    expect(ScoreBand.of(0).label, 'Better avoid');
  });

  test('ring tones: green ≥ 70, amber 40–69, rose < 40', () {
    expect(ScoreBand.of(70).tone, Tone.success);
    expect(ScoreBand.of(55).tone, Tone.warning);
    expect(ScoreBand.of(39).tone, Tone.rose);
  });

  test('clamps for dirty rows (PRD §15)', () {
    expect(clampScore(140), 100);
    expect(clampScore(-3), 0);
    expect(clampScore(null), 0);
    expect(clampScore(72.6), 73);
    expect(ScoreBand.of(250).label, 'Excellent for you');
    expect(clampCalories(99999), 5000);
    expect(clampCalories(-1), 0);
  });

  test('score out of ten, one decimal', () {
    expect(scoreOutOfTen(64), '6.4');
    expect(scoreOutOfTen(100), '10.0');
    expect(scoreOutOfTen(-5), '0.0');
  });

  test('rating labels are verbatim', () {
    expect(Rating.values.map((r) => r.label), ['Good choice', 'Okay-ish', 'Caution', 'Better avoid']);
    expect(Rating.fromWire('nope'), isNull);
  });

  group('plan gating (PRD §8)', () {
    FeatureAccess access(String plan, {bool unlimited = false}) =>
        FeatureAccess.of(plan: plan, isUnlimited: unlimited);

    test('free and pro: nothing gated', () {
      for (final plan in ['free', 'pro']) {
        final a = access(plan);
        expect([a.cautionPercentage, a.chemicalDetail, a.consumptionGuide, a.riskProfile, a.dietary, a.bodyMap],
            everyElement(isFalse),
            reason: plan);
      }
    });

    test('pro_plus: %, formula, guide only', () {
      final a = access('pro_plus');
      expect([a.cautionPercentage, a.chemicalDetail, a.consumptionGuide], everyElement(isTrue));
      expect([a.riskProfile, a.dietary, a.bodyMap], everyElement(isFalse));
    });

    test('pro_max, unlimited plan and unlimited role: everything', () {
      for (final a in [access('pro_max'), access('unlimited'), access('free', unlimited: true)]) {
        expect([a.cautionPercentage, a.chemicalDetail, a.consumptionGuide, a.riskProfile, a.dietary, a.bodyMap],
            everyElement(isTrue));
      }
    });

    test('expired paid plan is Free', () {
      final now = DateTime(2026, 10, 22);
      expect(effectivePlan(plan: 'pro_max', planExpiresAt: DateTime(2026, 10, 1), now: now), 'free');
      expect(effectivePlan(plan: 'pro_max', planExpiresAt: DateTime(2026, 11, 1), now: now), 'pro_max');
      expect(effectivePlan(plan: 'pro', now: now), 'pro');
    });
  });
}
