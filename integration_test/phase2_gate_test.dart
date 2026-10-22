// Phase 2 gate (CLAUDE.md; PRD §14.2–5), end to end against the real
// backend + analyze-scan edge function (needs GEMINI_API_KEY served):
//   flutter test integration_test/phase2_gate_test.dart \
//     --dart-define-from-file=config/local.json -d <simulator>
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:learn/features/scan/result/health_score_ring.dart';
import 'package:learn/features/scan/result/result_widgets.dart';
import 'package:learn/l10n/strings.dart';
import 'package:learn/main.dart' as app;

const knownEan = '8901058851298'; // Maggi Masala noodles, in Open Food Facts
const badCheckDigit = '8901058851299';
const unknownEan = '8906000000007'; // checksum-valid, in no registry

Future<void> pumpUntil(WidgetTester tester, Finder finder, {Duration timeout = const Duration(seconds: 90)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  final visible = find.byType(Text).evaluate().map((e) => (e.widget as Text).data).whereType<String>().toList();
  throw TestFailure('Timed out waiting for $finder\nOn screen: $visible');
}

Finder chip(int remaining) => find.text('Free · $remaining of 30 scans left');

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

/// The score and summary currently shown in the result view.
(int, String) shownVerdict(WidgetTester tester) {
  final score = tester.widget<HealthScoreRing>(find.byType(HealthScoreRing).first).score;
  final section = tester.widget<ResultSection>(find.widgetWithText(ResultSection, Strings.summaryTitle));
  return (score, (section.child as Text).data!);
}

Future<void> scanBarcode(WidgetTester tester, String code) async {
  final field = find.byKey(const ValueKey('scan-barcode-field'));
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  // On-device, enterText does not reliably replace an already-filled field;
  // set the controller directly (input filtering is covered by widget tests).
  tester.widget<TextField>(field).controller!.text = code;
  await tester.pump();
  await tapVisible(tester, find.text(Strings.scanButton));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('text + barcode scans, cache consistency, no-credit validation, history', (tester) async {
    await app.main();
    // Past the splash: either Home (signed out) or the tab shell (session kept).
    await pumpUntil(tester, find.byWidgetPredicate((w) => w is NavigationBar || (w is Text && w.data == Strings.positioningLine)));
    await tester.pumpAndSettle();
    if (find.byType(NavigationBar).evaluate().isNotEmpty) {
      await tester.tap(find.text(Strings.navProfile));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text(Strings.signOut));
    }
    await pumpUntil(tester, find.text(Strings.positioningLine));

    // Fresh account.
    await tester.tap(find.text(Strings.homeCta));
    await pumpUntil(tester, find.text(Strings.needAccount));
    await tester.tap(find.text(Strings.needAccount));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, Strings.email),
      'gate2-${DateTime.now().millisecondsSinceEpoch}@example.com',
    );
    await tester.enterText(find.widgetWithText(TextFormField, Strings.password), 'gate-pass-123');
    await tapVisible(tester, find.widgetWithText(FilledButton, Strings.createAccount));
    await pumpUntil(tester, chip(30));

    // §14.2 Pasted ingredients → full un-gated result.
    await tester.enterText(
      find.byKey(const ValueKey('scan-text-field')),
      'Whole wheat flour (atta), jaggery, peanuts, ghee, cardamom, salt',
    );
    await tapVisible(tester, find.text(Strings.scanButton));
    await pumpUntil(tester, find.text(Strings.summaryTitle));
    expect(find.text(Strings.advantagesTitle), findsOneWidget);
    expect(find.text(Strings.disadvantagesTitle), findsOneWidget);
    expect(find.text(Strings.cautionsTitle), findsOneWidget);
    expect(find.textContaining('kcal per serving'), findsOneWidget);
    await pumpUntil(tester, chip(29));

    // §14.3 Known Indian EAN → registry identity, not a guess.
    await tapVisible(tester, find.text(Strings.modeBarcode));
    await tester.pumpAndSettle();
    await scanBarcode(tester, knownEan);
    await pumpUntil(tester, find.text('Maggi Noodles Masala 70Grm Pc'));
    expect(find.textContaining('Maggi ·'), findsOneWidget);
    final first = shownVerdict(tester);
    await pumpUntil(tester, chip(28));

    // Rescan → same score and summary (cache), still one credit.
    await scanBarcode(tester, knownEan);
    await pumpUntil(tester, chip(27));
    await pumpUntil(tester, find.text('Maggi Noodles Masala 70Grm Pc'));
    expect(shownVerdict(tester), first);

    // §14.4 Bad check digit → verbatim error, no credit.
    await scanBarcode(tester, badCheckDigit);
    await pumpUntil(tester, find.text(Strings.invalidBarcode));
    await tester.pump(const Duration(seconds: 2));
    expect(chip(27), findsOneWidget);

    // §14.5 Unknown checksum-valid code → registry miss, no invented brand.
    await scanBarcode(tester, unknownEan);
    await pumpUntil(tester, find.text(Strings.registryMiss(unknownEan)));

    // §14.2 History lists the scans, newest first; detail shows the saved analysis.
    await tester.tap(find.text(Strings.navHistory));
    await pumpUntil(tester, find.text('Maggi Noodles Masala 70Grm Pc'));
    expect(find.text('Maggi Noodles Masala 70Grm Pc'), findsNWidgets(2));
    await tester.tap(find.text('Maggi Noodles Masala 70Grm Pc').first);
    await pumpUntil(tester, find.text(Strings.summaryTitle));
    expect(shownVerdict(tester), first);
  });
}
