import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn/app/session.dart';
import 'package:learn/app/theme.dart';
import 'package:learn/data/feedback_repository.dart';
import 'package:learn/data/history_repository.dart';
import 'package:learn/data/leaderboard_repository.dart';
import 'package:learn/data/profile_repository.dart';
import 'package:learn/data/weekly_repository.dart';
import 'package:learn/domain/leaderboard.dart';
import 'package:learn/domain/plan.dart';
import 'package:learn/domain/profile.dart';
import 'package:learn/domain/rating.dart';
import 'package:learn/domain/scan_result.dart';
import 'package:learn/domain/weekly.dart';
import 'package:learn/features/leaderboard/leaderboard_screen.dart';
import 'package:learn/features/profile/profile_screen.dart';
import 'package:learn/features/scan/result/scan_result_view.dart';
import 'package:learn/features/weekly/weekly_screen.dart';
import 'package:learn/l10n/strings.dart';
import 'package:mocktail/mocktail.dart';

class MockWeeklyRepository extends Mock implements WeeklyRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockFeedbackRepository extends Mock implements FeedbackRepository {}

class _FakeUpdate extends Fake implements ProfileUpdate {}

final now = DateTime(2026, 10, 22, 15);
const quota = Quota(remaining: 25, scanLimit: 30, plan: 'free', planLabel: 'Free', isUnlimited: false);

Future<void> pump(WidgetTester tester, Widget child, List overrides) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('u1'),
        quotaProvider.overrideWith((ref) async => quota),
        clockProvider.overrideWithValue(() => now),
        ...overrides.cast(),
      ],
      child: MaterialApp(theme: buildAppTheme(), home: child),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => registerFallbackValue(_FakeUpdate()));

  group('Weekly', () {
    late MockWeeklyRepository repo;
    late List<ConsumptionEntry> rows;

    setUp(() {
      repo = MockWeeklyRepository();
      rows = [
        ConsumptionEntry(id: 'e1', scanId: 's1', productName: 'Curd', caloriesKcal: 100, consumedAt: DateTime(2026, 10, 22, 9)),
        ConsumptionEntry(id: 'e2', scanId: 's2', productName: 'Chikki', caloriesKcal: 250, consumedAt: DateTime(2026, 10, 20, 18)),
      ];
      when(() => repo.week(any())).thenAnswer((_) async => WeeklySummary.from(rows, now));
      when(() => repo.delete(any())).thenAnswer((inv) async {
        rows.removeWhere((r) => r.id == inv.positionalArguments.first);
      });
    });

    testWidgets('totals, 7 weekday bars, entries; delete removes the log only', (tester) async {
      await pump(tester, const WeeklyScreen(), [weeklyRepositoryProvider.overrideWithValue(repo)]);
      expect(find.text(Strings.weeklyTitle), findsOneWidget);
      expect(find.text(Strings.weeklySubtitle), findsOneWidget);
      expect(find.textContaining('350', findRichText: true), findsWidgets); // total
      expect(find.text(Strings.avgPerDay(50)), findsOneWidget); // 350 / 7
      for (final d in ['Fri', 'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu']) {
        expect(find.text(d), findsOneWidget);
      }
      expect(find.text('Curd'), findsOneWidget);
      expect(find.text('Chikki'), findsOneWidget);

      await tester.tap(find.byTooltip(Strings.deleteEntry).first);
      await tester.pumpAndSettle();
      verify(() => repo.delete('e1')).called(1);
      expect(find.text('Curd'), findsNothing);
      expect(find.text('250 kcal'), findsWidgets);
    });

    testWidgets('empty week', (tester) async {
      rows.clear();
      await pump(tester, const WeeklyScreen(), [weeklyRepositoryProvider.overrideWithValue(repo)]);
      expect(find.text(Strings.weeklyEmpty), findsOneWidget);
    });
  });

  group('Leaderboard', () {
    testWidgets('medals, #n, @username, rounded average, scan count', (tester) async {
      await pump(tester, const LeaderboardScreen(), [
        sessionStateProvider.overrideWithValue(SessionState(userId: 'u1')),
        leaderboardProvider.overrideWith((ref) async => [
              for (final (i, name) in ['asha', 'bo', 'cy', 'dee'].indexed)
                LeaderboardEntry(rank: i + 1, username: name, averageScore: 90 - i, scanCount: 3 + i),
            ]),
      ]);
      expect(find.text(Strings.leaderboardCopy), findsOneWidget);
      // Handoff design: numbered badges (gold/silver/bronze 1–3, plain after).
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('@asha'), findsOneWidget);
      expect(find.text('90'), findsOneWidget);
      expect(find.text('6 scans'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Rank 1, @asha, average score 90')), findsOneWidget);
    });

    testWidgets('empty state', (tester) async {
      await pump(tester, const LeaderboardScreen(), [
        sessionStateProvider.overrideWithValue(SessionState()),
        leaderboardProvider.overrideWith((ref) async => const <LeaderboardEntry>[]),
      ]);
      expect(find.text(Strings.leaderboardEmpty), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget); // signed out → back to Home
    });
  });

  group('Profile', () {
    late MockProfileRepository repo;

    setUp(() {
      repo = MockProfileRepository();
      when(() => repo.fetchProfile(any())).thenAnswer(
        (_) async => const Cached(Profile(id: 'u1', email: 'a@example.com', username: 'asha')),
      );
      when(() => repo.saveProfile(any(), any())).thenAnswer((_) async => const Profile(id: 'u1'));
    });

    Future<void> pumpProfile(WidgetTester tester) => pump(tester, const ProfileScreen(), [
          profileRepositoryProvider.overrideWithValue(repo),
          sessionStateProvider.overrideWithValue(SessionState(userId: 'u1')),
        ]);

    Future<void> tapSave(WidgetTester tester) async {
      await tester.ensureVisible(find.text(Strings.saveProfile));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.saveProfile));
      await tester.pumpAndSettle();
    }

    testWidgets('live BMI, privacy copy, save sends only editable fields', (tester) async {
      await pumpProfile(tester);
      expect(find.text('@asha'), findsNothing); // prefix + field, not leaked elsewhere
      await tester.enterText(find.byKey(const ValueKey('profile-weight')), '60');
      await tester.enterText(find.byKey(const ValueKey('profile-height')), '165');
      await tester.pump();
      expect(find.text('22.0'), findsOneWidget); // live BMI value
      expect(find.text(Strings.healthInfoHelp), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('profile-allergies')), 'peanuts');
      await tapSave(tester);

      final update = verify(() => repo.saveProfile('u1', captureAny())).captured.single as ProfileUpdate;
      expect(update.username, 'asha');
      expect(update.weightKg, 60);
      expect(update.heightCm, 165);
      expect(update.allergies, 'peanuts');
      expect(find.text(Strings.profileSaved), findsOneWidget);
    });

    testWidgets('verbatim username format error blocks save', (tester) async {
      await pumpProfile(tester);
      await tester.enterText(find.byKey(const ValueKey('profile-username')), 'no spaces!');
      await tapSave(tester);
      expect(find.text(Strings.usernameFormatError), findsOneWidget);
      verifyNever(() => repo.saveProfile(any(), any()));
    });

    testWidgets('server uniqueness conflict shows "That username is taken."', (tester) async {
      when(() => repo.saveProfile(any(), any())).thenThrow(const UsernameTaken());
      await pumpProfile(tester);
      await tapSave(tester);
      expect(find.text(Strings.usernameTaken), findsOneWidget);
    });

    testWidgets('out-of-range health values are rejected on device', (tester) async {
      await pumpProfile(tester);
      await tester.enterText(find.byKey(const ValueKey('profile-age')), '130');
      await tester.enterText(find.byKey(const ValueKey('profile-weight')), '500');
      await tapSave(tester);
      expect(find.text(Strings.ageError), findsOneWidget);
      expect(find.text(Strings.weightError), findsOneWidget);
      verifyNever(() => repo.saveProfile(any(), any()));
    });
  });

  group('Result: I ate this + feedback', () {
    late MockWeeklyRepository weekly;
    late MockFeedbackRepository feedback;
    ScanFeedback? stored;

    setUp(() {
      weekly = MockWeeklyRepository();
      feedback = MockFeedbackRepository();
      stored = null;
      registerFallbackValue(const ScanFeedback(rating: 1, buyAgain: BuyAgain.no));
      when(() => weekly.logConsumption(
            userId: any(named: 'userId'),
            scanId: any(named: 'scanId'),
            productName: any(named: 'productName'),
            caloriesKcal: any(named: 'caloriesKcal'),
          )).thenAnswer((_) async {});
      when(() => weekly.week(any())).thenAnswer((_) async => WeeklySummary.from(const [], now));
      when(() => feedback.load(any())).thenAnswer((_) async => stored);
      when(() => feedback.save(userId: any(named: 'userId'), scanId: any(named: 'scanId'), feedback: any(named: 'feedback')))
          .thenAnswer((inv) async => stored = inv.namedArguments[#feedback] as ScanFeedback);
    });

    Future<void> pumpView(WidgetTester tester) => pump(
          tester,
          Scaffold(
            body: SingleChildScrollView(
              child: ScanResultView(
                scanId: 's1',
                access: FeatureAccess.free,
                result: ScanResult(
                  productName: 'Curd',
                  rating: Rating.good,
                  healthScore: 80,
                  caloriesKcal: 98,
                  summary: 'Fermented dairy.',
                ),
              ),
            ),
          ),
          [
            weeklyRepositoryProvider.overrideWithValue(weekly),
            feedbackRepositoryProvider.overrideWithValue(feedback),
          ],
        );

    testWidgets('I ate this logs the scan and can log again', (tester) async {
      await pumpView(tester);
      await tester.ensureVisible(find.text(Strings.ateThis));
      await tester.tap(find.text(Strings.ateThis));
      await tester.pumpAndSettle();
      expect(find.text(Strings.ateThisSuccess), findsOneWidget);
      // Success state stays tappable: the same scan can be logged again (PRD §7.7).
      await tester.tap(find.text(Strings.ateThisSuccess));
      await tester.pumpAndSettle();
      verify(() => weekly.logConsumption(userId: 'u1', scanId: 's1', productName: 'Curd', caloriesKcal: 98)).called(2);
    });

    testWidgets('feedback: requires answers, upserts, thanks, shows saved values on reopen (PRD §14.13)', (tester) async {
      await pumpView(tester);
      final submit = find.text(Strings.sendFeedback);
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text(Strings.feedbackNeedsAnswers), findsOneWidget);

      Future<void> tapVisible(Finder f) async {
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      await tester.pump(const Duration(seconds: 5)); // let the toast clear
      await tapVisible(find.bySemanticsLabel(Strings.starsLabel(4)));
      await tapVisible(find.text('Maybe'));
      await tester.enterText(find.byKey(const ValueKey('feedback-comment')), 'Bit sour');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text(Strings.feedbackThanks), findsOneWidget);
      expect(stored!.rating, 4);
      expect(stored!.buyAgain, BuyAgain.maybe);
      expect(stored!.comment, 'Bit sour');

      // Reopen: a fresh view loads the saved row.
      await tester.pumpWidget(const SizedBox());
      await pumpView(tester);
      await tester.ensureVisible(find.text(Strings.feedbackThanks));
      expect(find.text(Strings.feedbackThanks), findsOneWidget);
      expect(find.text('“Bit sour”'), findsOneWidget);
      expect(find.text('${Strings.feedbackPrompt} Maybe'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Rated 4 stars out of 5')), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(4)); // saved rating, read-only
    });
  });
}
