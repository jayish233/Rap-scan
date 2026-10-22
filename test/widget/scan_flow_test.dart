import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn/app/session.dart';
import 'package:learn/app/theme.dart';
import 'package:learn/data/history_repository.dart';
import 'package:learn/data/profile_repository.dart';
import 'package:learn/data/scan_api.dart';
import 'package:learn/domain/plan.dart';
import 'package:learn/domain/rating.dart';
import 'package:learn/domain/scan_failure.dart';
import 'package:learn/domain/scan_result.dart';
import 'package:learn/features/scan/scan_screen.dart';
import 'package:learn/l10n/strings.dart';
import 'package:mocktail/mocktail.dart';

class MockScanApi extends Mock implements ScanApi {}

class _FakeRequest extends Fake implements ScanRequest {}

Quota quota({int remaining = 30, String plan = 'free', bool unlimited = false}) => Quota(
      remaining: remaining,
      scanLimit: 30,
      plan: plan,
      planLabel: plan == 'free' ? 'Free' : 'Pro+',
      isUnlimited: unlimited,
    );

ScanOutcome outcome({String plan = 'free'}) => ScanOutcome(
      scanId: 'scan-1',
      source: ScanSource.ingredients,
      quota: quota(remaining: 29, plan: plan),
      result: ScanResult(
        productName: 'Chocolate cream biscuit',
        brand: 'Bourbon',
        parentCompany: 'Britannia Industries',
        category: 'Cream-filled biscuit',
        rating: Rating.caution,
        healthScore: 31,
        caloriesKcal: 160,
        summary: 'Ultra-processed biscuit high in sugar and palm fat.',
        advantages: const ['Quick energy'],
        disadvantages: const ['High sugar'],
        cautions: const [
          Caution(
            ingredient: 'Sugar',
            concern: 'Adds a lot of free sugar.',
            severity: Severity.high,
            percentage: '~35%',
            chemicalFormula: 'C12H22O11',
            scientificName: 'Sucrose',
          ),
        ],
        personalAdvice: 'You listed diabetes; keep this occasional.',
      ),
    );

Future<MockScanApi> pumpScan(WidgetTester tester, {Quota? initialQuota}) async {
  final api = MockScanApi();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('u1'),
        scanApiProvider.overrideWithValue(api),
        quotaProvider.overrideWith((ref) async => initialQuota ?? quota()),
        historyProvider.overrideWith((ref) async => const Cached(<ScanSummary>[])),
      ],
      child: MaterialApp(theme: buildAppTheme(), home: const ScanScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return api;
}

Future<void> tapScan(WidgetTester tester) async {
  await tester.tap(find.text(Strings.scanButton));
  await tester.pumpAndSettle();
}

Future<void> switchToBarcode(WidgetTester tester) async {
  await tester.tap(find.text(Strings.modeBarcode));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => registerFallbackValue(_FakeRequest()));

  testWidgets('text scan happy path shows the result blocks and a toast', (tester) async {
    final api = await pumpScan(tester);
    when(() => api.analyze(any())).thenAnswer((_) async => outcome());

    await tester.enterText(find.byType(TextField), 'sugar, wheat flour, palm oil');
    await tapScan(tester);

    final request = verify(() => api.analyze(captureAny())).captured.single as ScanRequest;
    expect(request.toJson(), {'scanType': 'ingredients', 'text': 'sugar, wheat flour, palm oil'});
    expect(find.text(Strings.scanCompleteToast), findsOneWidget);
    expect(find.text('Chocolate cream biscuit'), findsOneWidget);
    expect(find.text(Strings.ratingCaution), findsOneWidget);
    expect(find.text('Bourbon · by Britannia Industries · Cream-filled biscuit'), findsOneWidget);
    expect(find.text(Strings.caloriesLine(160)), findsOneWidget);
    expect(find.text('You listed diabetes; keep this occasional.'), findsOneWidget);
    expect(find.text(Strings.cautionsTitle), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Health score 31 out of 100, Eat rarely')), findsOneWidget);
    expect(find.text(Strings.disclaimer), findsOneWidget);
  });

  testWidgets('free plan hides % and formula even when the payload has them', (tester) async {
    final api = await pumpScan(tester);
    when(() => api.analyze(any())).thenAnswer((_) async => outcome(plan: 'free'));
    await tester.enterText(find.byType(TextField), 'sugar');
    await tapScan(tester);
    expect(find.textContaining('~35%'), findsNothing);
    expect(find.textContaining('C12H22O11'), findsNothing);
  });

  testWidgets('Pro+ sees % and formula', (tester) async {
    final api = await pumpScan(tester);
    when(() => api.analyze(any())).thenAnswer((_) async => outcome(plan: 'pro_plus'));
    await tester.enterText(find.byType(TextField), 'sugar');
    await tapScan(tester);
    expect(find.textContaining('~35%'), findsOneWidget);
    expect(find.textContaining('C12H22O11'), findsOneWidget);
  });

  testWidgets('empty text: verbatim error, no server call', (tester) async {
    final api = await pumpScan(tester);
    await tapScan(tester);
    expect(find.text(Strings.emptyTextError), findsOneWidget);
    verifyNever(() => api.analyze(any()));
  });

  testWidgets('bad check digit: verbatim error, no server call (PRD §14.4)', (tester) async {
    final api = await pumpScan(tester);
    await switchToBarcode(tester);
    await tester.enterText(find.byType(TextField), '8901058851299');
    await tapScan(tester);
    expect(find.text(Strings.invalidBarcode), findsOneWidget);
    verifyNever(() => api.analyze(any()));
  });

  testWidgets('barcode field strips non-digits as the user types', (tester) async {
    await pumpScan(tester);
    await switchToBarcode(tester);
    await tester.enterText(find.byType(TextField), '8901 0588-51298');
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '8901058851298');
  });

  testWidgets('in-store code: no server call, local notice', (tester) async {
    final api = await pumpScan(tester);
    await switchToBarcode(tester);
    await tester.enterText(find.byType(TextField), '2000000123455');
    await tapScan(tester);
    expect(find.text(Strings.inStoreTitle), findsOneWidget);
    verifyNever(() => api.analyze(any()));
  });

  testWidgets('valid barcode is sent; registry miss shows verbatim copy (PRD §14.5)', (tester) async {
    final api = await pumpScan(tester);
    when(() => api.analyze(any())).thenThrow(const RegistryMiss('8906000000007'));
    await switchToBarcode(tester);
    await tester.enterText(find.byType(TextField), '8906000000007');
    await tapScan(tester);
    final request = verify(() => api.analyze(captureAny())).captured.single as ScanRequest;
    expect(request.toJson(), {'scanType': 'barcode', 'barcode': '8906000000007'});
    expect(find.text(Strings.registryMiss('8906000000007')), findsOneWidget);
  });

  testWidgets('each server failure shows its verbatim toast', (tester) async {
    final api = await pumpScan(tester);
    for (final failure in <ScanFailure>[
      const RateLimited(),
      const AiUnavailable(),
      const AiCreditsExhausted(),
      const NetworkDown(),
    ]) {
      when(() => api.analyze(any())).thenThrow(failure);
      await tester.enterText(find.byType(TextField), 'sugar');
      await tapScan(tester);
      expect(find.text(failure.message), findsOneWidget, reason: failure.runtimeType.toString());
    }
  });

  testWidgets('zero remaining: button disabled and upgrade card shown', (tester) async {
    final api = await pumpScan(tester, initialQuota: quota(remaining: 0));
    expect(find.text(Strings.quotaExhausted), findsOneWidget);
    final button = tester.widget<ButtonStyleButton>(
      find.ancestor(of: find.text(Strings.scanButton), matching: find.bySubtype<ButtonStyleButton>()),
    );
    expect(button.onPressed, isNull);
    verifyNever(() => api.analyze(any()));
  });

  testWidgets('a second barcode replaces the first and is validated on its own', (tester) async {
    final api = await pumpScan(tester);
    when(() => api.analyze(any())).thenAnswer((_) async => outcome());
    await switchToBarcode(tester);
    final field = find.byKey(const ValueKey('scan-barcode-field'));
    await tester.enterText(field, '8901058851298');
    await tapScan(tester);
    // The result scrolled into view; bring the input back like a user would.
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    await tester.enterText(field, '8901058851299');
    await tester.ensureVisible(find.text(Strings.scanButton));
    await tapScan(tester);
    expect(tester.widget<TextField>(field).controller!.text, '8901058851299');
    expect(find.text(Strings.invalidBarcode), findsOneWidget);
    verify(() => api.analyze(any())).called(1);
  });

  testWidgets('New scan clears the result and returns to the input', (tester) async {
    final api = await pumpScan(tester);
    when(() => api.analyze(any())).thenAnswer((_) async => outcome());
    await tester.enterText(find.byType(TextField), 'sugar');
    await tapScan(tester);
    await tester.pump(const Duration(seconds: 5)); // let the toast clear
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Strings.startOver));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.startOver));
    await tester.pumpAndSettle();
    expect(find.text('Chocolate cream biscuit'), findsNothing);
    expect(find.text(Strings.scanButton).hitTestable(), findsOneWidget);
  });
}
