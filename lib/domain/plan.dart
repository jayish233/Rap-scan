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
}
