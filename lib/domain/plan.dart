/// Plans, prices and quota display (PRD §8). Pure Dart.
///
/// The client never computes or resets quotas; [Quota] only carries the
/// numbers the server returned.
library;

enum PlanTier {
  free('Free', '₹0', '30 total scans'),
  pro('Pro', '₹200 / mo', '60 scans'),
  proPlus('Pro+', '₹500 / mo', '120 scans'),
  proMax('Pro Max', '₹1,200 / mo', '240 scans');

  const PlanTier(this.label, this.price, this.allowance);

  final String label;
  final String price;
  final String allowance;

  /// Features shown on the plan card, beyond the shared core.
  List<String> get highlights => switch (this) {
        PlanTier.free => const [
            'Ingredient, photo and barcode analysis',
            'Health score, rating, summary, calories',
            'Advantages, disadvantages, cautions',
            'Personal advice, history, weekly log, leaderboard',
          ],
        PlanTier.pro => const [
            'Everything in Free',
            'Estimated % on each caution',
          ],
        PlanTier.proPlus => const [
            'Everything in Pro',
            'Chemical formula and scientific name',
            'Safe consumption guide',
          ],
        PlanTier.proMax => const [
            'Everything in Pro+',
            'Over-consumption risk profile',
            'Dietary classification with reason',
            'Body-impact map',
          ],
      };

  static PlanTier fromWire(String? value) => switch (value) {
        'pro' => PlanTier.pro,
        'pro_plus' => PlanTier.proPlus,
        'pro_max' || 'unlimited' => PlanTier.proMax,
        _ => PlanTier.free,
      };
}

/// Server-reported quota (`get_my_quota` / analyze-scan envelope).
class Quota {
  const Quota({
    required this.remaining,
    required this.scanLimit,
    required this.plan,
    required this.planLabel,
    required this.isUnlimited,
  });

  final int remaining;
  final int scanLimit;
  final String plan;
  final String planLabel;
  final bool isUnlimited;

  bool get isExhausted => !isUnlimited && remaining <= 0;

  FeatureAccess get access => FeatureAccess.of(plan: plan, isUnlimited: isUnlimited);
}

/// A paid plan whose expiry is in the past behaves as Free (PRD §8, §15).
/// The server already applies this; the client re-applies it to any plan
/// it reads from a profile row so a stale row never unlocks features.
String effectivePlan({required String plan, DateTime? planExpiresAt, required DateTime now}) {
  if (plan != 'free' && planExpiresAt != null && planExpiresAt.isBefore(now)) return 'free';
  return plan;
}

/// Pro Max features: `plan == pro_max` OR `isUnlimited` OR `plan == unlimited`.
bool isProMax({required String plan, required bool isUnlimited}) =>
    plan == 'pro_max' || plan == 'unlimited' || isUnlimited;

/// Which gated result sections the caller may see (PRD §8 matrix). The UI
/// hides anything not allowed even if a stale payload contains it.
class FeatureAccess {
  const FeatureAccess._({
    required this.cautionPercentage,
    required this.chemicalDetail,
    required this.consumptionGuide,
    required this.riskProfile,
    required this.dietary,
    required this.bodyMap,
  });

  factory FeatureAccess.of({required String plan, required bool isUnlimited}) {
    final proMax = isProMax(plan: plan, isUnlimited: isUnlimited);
    final proPlus = proMax || plan == 'pro_plus';
    return FeatureAccess._(
      cautionPercentage: proPlus,
      chemicalDetail: proPlus,
      consumptionGuide: proPlus,
      riskProfile: proMax,
      dietary: proMax,
      bodyMap: proMax,
    );
  }

  static const free = FeatureAccess._(
    cautionPercentage: false,
    chemicalDetail: false,
    consumptionGuide: false,
    riskProfile: false,
    dietary: false,
    bodyMap: false,
  );

  /// `percentage` as its own field (Pro shows it inside the concern text).
  final bool cautionPercentage;

  /// Chemical formula and scientific name.
  final bool chemicalDetail;
  final bool consumptionGuide;
  final bool riskProfile;
  final bool dietary;
  final bool bodyMap;
}
