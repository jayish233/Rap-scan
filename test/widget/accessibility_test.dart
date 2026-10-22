// Accessibility pass (design.md §8, PRD §14.15): tap targets, labels,
// contrast, and large dynamic type on every main screen.
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
import 'package:learn/features/auth/auth_screen.dart';
import 'package:learn/features/content/trust_screen.dart';
import 'package:learn/features/history/history_screen.dart';
import 'package:learn/features/home/home_screen.dart';
import 'package:learn/features/plans/plans_sheet.dart';
import 'package:learn/features/leaderboard/leaderboard_screen.dart';
import 'package:learn/features/profile/profile_screen.dart';
import 'package:learn/features/scan/result/scan_result_view.dart';
import 'package:learn/features/scan/scan_screen.dart';
import 'package:learn/features/weekly/weekly_screen.dart';
import 'package:learn/l10n/strings.dart';

final now = DateTime(2026, 10, 22, 15);

const proMax = Quota(remaining: 200, scanLimit: 240, plan: 'pro_max', planLabel: 'Pro Max', isUnlimited: false);

ScanResult result() => ScanResult(
      productName: 'Maggi Noodles Masala 70Grm Pc',
      brand: 'Maggi',
      parentCompany: 'Nestlé India',
      category: 'Instant noodles',
      rating: Rating.caution,
      healthScore: 25,
      caloriesKcal: 306,
      summary: 'Instant noodles high in salt and saturated fat.',
      advantages: const ['Quick to prepare'],
      disadvantages: const ['High sodium'],
      cautions: const [Caution(ingredient: 'Salt', concern: 'High sodium.', severity: Severity.high, chemicalFormula: 'NaCl')],
      personalAdvice: 'You listed peanuts; the tastemaker contains peanut protein.',
      consumptionTip: const ConsumptionTip(safeDaily: 'Not daily', limit: 'Once a week', source: 'WHO'),
      riskProfile: const RiskProfile(illnesses: ['Raised blood pressure']),
      bodyDamage: const [BodyMarker(part: 'heart', severity: Severity.high, reason: 'Salt raises blood pressure.')],
      bodyBenefit: const [BodyMarker(part: 'bones', severity: Severity.medium, reason: 'Calcium.')],
      dietaryType: DietaryType.veg,
      dietaryReason: 'Plant ingredients only.',
    );

final _screens = <String, Widget>{
  'home': const HomeScreen(),
  'auth': const AuthScreen(),
  'trust': const TrustScreen(),
  'scan': const ScanScreen(),
  'result (Pro Max)': Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ScanResultView(result: result(), access: proMax.access, scanId: 's1'),
      ),
    ),
  ),
  'result (Free)': Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ScanResultView(result: result(), access: FeatureAccess.free, scanId: 's1'),
      ),
    ),
  ),
  'history': const HistoryScreen(),
  'weekly': const WeeklyScreen(),
  'leaderboard': const LeaderboardScreen(),
  'profile': const ProfileScreen(),
  'plans sheet': const Scaffold(body: PlansSheet()),
};

Future<void> pumpScreen(WidgetTester tester, Widget screen, {double textScale = 1}) async {
  tester.view.physicalSize = const Size(1170, 2532); // iPhone 13-class
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionStateProvider.overrideWithValue(SessionState(userId: 'u1')),
        currentUserIdProvider.overrideWithValue('u1'),
        quotaProvider.overrideWith((ref) async => proMax),
        clockProvider.overrideWithValue(() => now),
        feedbackProvider.overrideWith((ref, id) async => null),
        historyProvider.overrideWith((ref) async => Cached([
              ScanSummary(
                id: 's1',
                productName: 'Maggi Noodles Masala 70Grm Pc',
                scanType: 'barcode',
                rating: Rating.caution,
                healthScore: 25,
                summary: 'Instant noodles high in salt and saturated fat.',
                createdAt: now,
              ),
            ])),
        weeklyProvider.overrideWith((ref) async => WeeklySummary.from([
              ConsumptionEntry(id: 'e1', scanId: 's1', productName: 'Maggi', caloriesKcal: 306, consumedAt: now),
            ], now)),
        leaderboardProvider.overrideWith((ref) async => const [
              LeaderboardEntry(rank: 1, username: 'asha_k', averageScore: 81, scanCount: 12),
              LeaderboardEntry(rank: 4, username: 'bo', averageScore: 60, scanCount: 3),
            ]),
        profileProvider.overrideWith((ref) async => const Cached(
              Profile(id: 'u1', email: 'a@example.com', username: 'asha_k', weightKg: 60, heightCm: 165),
            )),
      ],
      child: MaterialApp(
        theme: buildAppTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final MapEntry(key: name, value: screen) in _screens.entries) {
    testWidgets('$name: tap targets, labels and contrast', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, screen);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('$name: renders at 2× text size without overflow', (tester) async {
      final errors = <String>[];
      final previous = FlutterError.onError;
      FlutterError.onError = (details) {
        final text = details.toString();
        final creator = RegExp(r'lib/[\w/]+\.dart:\d+:\d+').firstMatch(text)?.group(0) ?? '?';
        errors.add('${details.exceptionAsString().split('\n').first} @ $creator');
      };
      try {
        await pumpScreen(tester, screen, textScale: 2);
      } finally {
        FlutterError.onError = previous;
      }
      expect(errors, isEmpty, reason: errors.toSet().join('\n'));
    });
  }

  testWidgets('screen reader gets verdict, score label and each caution without colour (PRD §14.15)', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(tester, _screens['result (Free)']!);
    // The verdict header is announced as one element: rating word, product,
    // score and its label — no colour needed.
    expect(
      find.bySemanticsLabel(RegExp(r'Rating: Caution\nMaggi Noodles.*Health score 25 out of 100, Eat rarely, 2\.5 out of 10', dotAll: true)),
      findsOneWidget,
    );
    // Each caution card is one element: ingredient, severity word, concern.
    expect(find.bySemanticsLabel(RegExp(r'Salt\nSeverity: High\nHigh sodium\.')), findsOneWidget);
    // Locked map announces itself without revealing organs.
    expect(find.bySemanticsLabel(RegExp('Body-impact map locked')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('Pro Max body map is readable as text', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(tester, _screens['result (Pro Max)']!);
    // Silhouettes and their text equivalent live on the full-screen map.
    await tester.ensureVisible(find.text(Strings.openBodyMap));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.openBodyMap));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('Harms map: Heart High')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Benefits map: Bones Medium')), findsOneWidget);
    expect(find.textContaining('Heart — Harms, High.', findRichText: true), findsOneWidget);
    handle.dispose();
  });
}
