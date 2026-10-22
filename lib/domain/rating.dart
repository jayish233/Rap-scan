/// Rating, score bands and display clamps (PRD §7.4.1, design.md §7.1).
/// Pure Dart: colours are expressed as [Tone] and mapped in the theme.
library;

import '../l10n/strings.dart';

/// Semantic colour role, resolved to a theme token by the UI.
enum Tone { success, accent, warning, danger, rose }

enum Rating {
  good(Strings.ratingGood, Tone.success),
  okay(Strings.ratingOkay, Tone.accent),
  caution(Strings.ratingCaution, Tone.warning),
  avoid(Strings.ratingAvoid, Tone.danger);

  const Rating(this.label, this.tone);

  final String label;
  final Tone tone;

  static Rating? fromWire(String? value) => switch (value) {
        'good' => Rating.good,
        'okay' => Rating.okay,
        'caution' => Rating.caution,
        'avoid' => Rating.avoid,
        _ => null,
      };
}

enum ScoreBand {
  excellent(85, Strings.scoreExcellent, Tone.success),
  healthy(70, Strings.scoreHealthy, Tone.success),
  moderation(40, Strings.scoreModeration, Tone.warning),
  rarely(20, Strings.scoreRarely, Tone.rose),
  avoid(0, Strings.scoreAvoid, Tone.rose);

  const ScoreBand(this.min, this.label, this.tone);

  final int min;
  final String label;
  final Tone tone;

  static ScoreBand of(int score) {
    final s = clampScore(score);
    return ScoreBand.values.firstWhere((b) => s >= b.min);
  }
}

/// Health score is always shown in 0–100, even for dirty old rows (PRD §15).
int clampScore(num? value) => value == null || value.isNaN ? 0 : value.round().clamp(0, 100);

/// Calories are always shown in 0–5000 (PRD §15).
int clampCalories(num? value) => value == null || value.isNaN ? 0 : value.round().clamp(0, 5000);

/// "6.4" — score out of 10 with one decimal.
String scoreOutOfTen(int score) => (clampScore(score) / 10).toStringAsFixed(1);
