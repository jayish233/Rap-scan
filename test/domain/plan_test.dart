import 'package:flutter_test/flutter_test.dart';
import 'package:learn/domain/plan.dart';
import 'package:learn/features/scan/widgets/quota_chip.dart';

Quota quota({int remaining = 30, int limit = 30, String label = 'Free', bool unlimited = false}) => Quota(
      remaining: remaining,
      scanLimit: limit,
      plan: 'free',
      planLabel: label,
      isUnlimited: unlimited,
    );

void main() {
  test('PlanTier.fromWire maps server plans; unlimited counts as Pro Max', () {
    expect(PlanTier.fromWire('free'), PlanTier.free);
    expect(PlanTier.fromWire('pro'), PlanTier.pro);
    expect(PlanTier.fromWire('pro_plus'), PlanTier.proPlus);
    expect(PlanTier.fromWire('pro_max'), PlanTier.proMax);
    expect(PlanTier.fromWire('unlimited'), PlanTier.proMax);
    expect(PlanTier.fromWire(null), PlanTier.free);
    expect(PlanTier.fromWire('garbage'), PlanTier.free);
  });

  test('plan catalog matches PRD §8 prices', () {
    expect(PlanTier.values.map((t) => t.price), ['₹0', '₹200 / mo', '₹500 / mo', '₹1,200 / mo']);
  });

  test('quota chip copy is verbatim (design.md §10)', () {
    expect(quotaLabel(quota()), 'Free · 30 of 30 scans left');
    expect(quotaLabel(quota(remaining: 12, limit: 60, label: 'Pro')), 'Pro · 12 of 60 scans left');
    expect(quotaLabel(quota(label: 'Pro Max', unlimited: true, remaining: 999999, limit: 999999)),
        'Pro Max · Unlimited scans');
  });

  test('exhausted only when limited and at zero', () {
    expect(quota(remaining: 0).isExhausted, isTrue);
    expect(quota(remaining: 1).isExhausted, isFalse);
    expect(quota(remaining: 0, unlimited: true).isExhausted, isFalse);
  });
}
