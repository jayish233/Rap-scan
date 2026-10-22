import 'package:flutter_test/flutter_test.dart';
import 'package:learn/domain/leaderboard.dart';
import 'package:learn/domain/profile.dart';
import 'package:learn/domain/weekly.dart';
import 'package:learn/l10n/strings.dart';

ConsumptionEntry entry(String id, DateTime at, int kcal) =>
    ConsumptionEntry(id: id, scanId: 's$id', productName: 'P$id', caloriesKcal: kcal, consumedAt: at);

void main() {
  group('weekly window (PRD §7.7, §15)', () {
    final now = DateTime(2026, 10, 22, 15, 30); // Thursday

    test('starts at local midnight six days ago', () {
      expect(weekWindowStart(now), DateTime(2026, 10, 16));
      expect(weekWindowStart(DateTime(2026, 3, 2, 0, 5)), DateTime(2026, 2, 24)); // month underflow
    });

    test('buckets by local calendar day, ignores entries outside the window', () {
      final s = WeeklySummary.from([
        entry('a', DateTime(2026, 10, 22, 9), 200),
        entry('b', DateTime(2026, 10, 22, 20), 100),
        entry('c', DateTime(2026, 10, 16, 0, 0, 1), 50), // first second of the window
        entry('d', DateTime(2026, 10, 15, 23, 59), 999), // just before the window
        entry('e', DateTime(2026, 10, 20, 12), 400),
      ], now);
      expect(s.days.map((d) => d.weekday), ['Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu']);
      expect(s.days.map((d) => d.kcal), [50, 0, 0, 0, 400, 0, 300]);
      expect(s.total, 750);
      expect(s.averagePerDay, 107); // 750 / 7, rounded
      expect(s.busiestDayKcal, 400);
      expect(s.barFraction(s.days[4]), 1.0);
      expect(s.barFraction(s.days[6]), 0.75);
      expect(s.entries.map((e) => e.id), ['b', 'a', 'e', 'c']); // newest first
    });

    test('the same scan logged twice counts twice', () {
      final s = WeeklySummary.from([entry('a', now, 120), entry('b', now, 120)], now);
      expect(s.total, 240);
    });

    test('empty week', () {
      final s = WeeklySummary.from(const [], now);
      expect(s.isEmpty, isTrue);
      expect(s.barFraction(s.days.first), 0);
      expect(s.averagePerDay, 0);
    });

    test('calories are clamped for dirty rows', () {
      expect(entry('x', now, 99999).caloriesKcal, 5000);
    });
  });

  test('leaderboard rank labels and handle', () {
    LeaderboardEntry e(int rank) => LeaderboardEntry(rank: rank, username: 'asha', averageScore: 74, scanCount: 3);
    expect([1, 2, 3, 4, 12].map((r) => e(r).rankLabel), ['🥇', '🥈', '🥉', '#4', '#12']);
    expect(e(1).handle, '@asha');
  });

  group('profile validators (PRD §7.9)', () {
    test('username: 3–20 letters, numbers, underscore; verbatim error', () {
      for (final ok in ['abc', 'Asha_99', 'a' * 20, '']) {
        expect(validateUsername(ok), isNull, reason: ok);
      }
      for (final bad in ['ab', 'a' * 21, 'has space', 'émile', 'dash-name']) {
        expect(validateUsername(bad), Strings.usernameFormatError, reason: bad);
      }
    });

    test('age 1–129 integer; weight 0–500; height 0–300 exclusive', () {
      expect(validateAge('1'), isNull);
      expect(validateAge('129'), isNull);
      expect(validateAge('0'), isNotNull);
      expect(validateAge('130'), isNotNull);
      expect(validateAge('30.5'), isNotNull);
      expect(validateWeight('499.9'), isNull);
      expect(validateWeight('500'), isNotNull);
      expect(validateWeight('0'), isNotNull);
      expect(validateHeight('299'), isNull);
      expect(validateHeight('300'), isNotNull);
      expect(validateHeight(''), isNull);
      expect(validateFreeText('x' * 500), isNull);
      expect(validateFreeText('x' * 501), isNotNull);
    });

    test('BMI = kg / m², one decimal', () {
      expect(formatBmi(computeBmi(60, 165)!), '22.0');
      expect(formatBmi(computeBmi(82.5, 178)!), '26.0');
      expect(computeBmi(60, null), isNull);
      expect(computeBmi(0, 170), isNull);
    });

    test('gender wire values', () {
      expect(Gender.values.map((g) => g.wire), ['', 'female', 'male', 'non_binary', 'other']);
      expect(Gender.fromWire('non_binary'), Gender.nonBinary);
      expect(Gender.fromWire(null), Gender.unspecified);
    });
  });
}
