/// Weekly intake (PRD §7.7). Pure Dart; all dates are device-local.
library;

import 'rating.dart';

const weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// One "I ate this" log row.
class ConsumptionEntry {
  ConsumptionEntry({
    required this.id,
    required this.scanId,
    required this.productName,
    required num? caloriesKcal,
    required this.consumedAt,
  }) : caloriesKcal = clampCalories(caloriesKcal);

  final String id;
  final String scanId;
  final String productName;
  final int caloriesKcal;
  final DateTime consumedAt; // local
}

/// Local midnight at the start of the 7-day window that ends today
/// (the last 7 local calendar days including today).
DateTime weekWindowStart(DateTime now) {
  final local = now.toLocal();
  // The DateTime constructor normalises day underflow and keeps DST right.
  return DateTime(local.year, local.month, local.day - 6);
}

class DayTotal {
  const DayTotal({required this.date, required this.kcal});

  final DateTime date; // local midnight
  final int kcal;

  String get weekday => weekdayShort[date.weekday - 1];
}

class WeeklySummary {
  WeeklySummary._(this.days, this.entries);

  /// Buckets [entries] into the 7 local days ending today. Entries outside
  /// the window are ignored.
  factory WeeklySummary.from(List<ConsumptionEntry> entries, DateTime now) {
    final start = weekWindowStart(now);
    final days = [for (var i = 0; i < 7; i++) DateTime(start.year, start.month, start.day + i)];
    final totals = List.filled(7, 0);
    final inWindow = <ConsumptionEntry>[];
    for (final e in entries) {
      final t = e.consumedAt.toLocal();
      final day = DateTime(t.year, t.month, t.day);
      final index = days.indexOf(day);
      if (index < 0) continue;
      totals[index] += e.caloriesKcal;
      inWindow.add(e);
    }
    inWindow.sort((a, b) => b.consumedAt.compareTo(a.consumedAt));
    return WeeklySummary._([for (var i = 0; i < 7; i++) DayTotal(date: days[i], kcal: totals[i])], inWindow);
  }

  final List<DayTotal> days; // oldest → today
  final List<ConsumptionEntry> entries; // newest first

  int get total => days.fold(0, (sum, d) => sum + d.kcal);

  /// Average per day over the full 7 days (total / 7).
  int get averagePerDay => (total / 7).round();

  int get busiestDayKcal => days.fold(0, (m, d) => d.kcal > m ? d.kcal : m);

  /// Bar height 0–1 relative to the busiest day.
  double barFraction(DayTotal day) => busiestDayKcal == 0 ? 0 : day.kcal / busiestDayKcal;

  bool get isEmpty => entries.isEmpty;
}
