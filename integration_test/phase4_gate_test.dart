// Phase 4 gate (CLAUDE.md; PRD §14.11–12, §15 expired plan), on device
// against the real backend. Driven by tool/phase4_gate.sh, which changes the
// account's plan in the database when this test prints a STEP marker.
// Scans the cached Maggi barcode, so no model call is needed.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:learn/data/profile_repository.dart';
import 'package:learn/features/scan/result/body_map.dart';
import 'package:learn/features/scan/scan_screen.dart';
import 'package:learn/l10n/strings.dart';
import 'package:learn/main.dart' as app;

import 'gate_helpers.dart';

const maggi = '8901058851298';

Future<void> scanMaggi(WidgetTester tester) async {
  await setField(tester, 'scan-barcode-field', maggi);
  await tapVisible(tester, find.text(Strings.scanButton));
  await pumpUntil(tester, find.text('Maggi Noodles Masala 70Grm Pc'));
  await tester.pump(const Duration(seconds: 5)); // let the toast clear
  await tester.pumpAndSettle();
}

/// Prints a marker for the host script, then refreshes the server quota
/// until the chip shows [expectChip].
Future<void> step(WidgetTester tester, String marker, Pattern expectChip) async {
  debugPrint('STEP:$marker');
  final container = ProviderScope.containerOf(tester.element(find.byType(ScanScreen)));
  final end = DateTime.now().add(const Duration(seconds: 60));
  while (DateTime.now().isBefore(end)) {
    container.invalidate(quotaProvider);
    await tester.pump(const Duration(seconds: 1));
    if (find.textContaining(expectChip).evaluate().isNotEmpty) return;
  }
  throw TestFailure('Plan did not change to $expectChip; chip: ${chipText(tester)}');
}

void expectFreeView() {
  expect(find.text(Strings.dietaryLockedTitle), findsOneWidget);
  expect(find.byType(LockedBodyMapCard), findsOneWidget);
  expect(find.text(Strings.consumptionTitle), findsNothing);
  expect(find.text(Strings.riskTitle), findsNothing);
  expect(find.text(Strings.bodyMapHarms), findsNothing);
  expect(find.byType(BodyMapCard), findsNothing);
  expect(find.text('Vegetarian'), findsNothing);
}

void expectProMaxView() {
  expect(find.text(Strings.dietaryTitle.toUpperCase()), findsOneWidget);
  expect(find.text('Vegetarian'), findsNWidgets(2)); // header mark + section
  expect(find.text(Strings.dietaryLockedTitle), findsNothing);
  expect(find.byType(BodyMapCard), findsOneWidget);
  expect(find.byType(LockedBodyMapCard), findsNothing);
  expect(find.text(Strings.riskTitle), findsOneWidget); // Maggi scores 25: not healthy band
  expect(find.text(Strings.consumptionTitle), findsOneWidget);
  expect(find.text(Strings.cautionsTitle), findsOneWidget);
}

/// Both silhouettes live on the full-screen map behind "Open body map".
Future<void> expectBodyMapPage(WidgetTester tester) async {
  await tapVisible(tester, find.text(Strings.openBodyMap));
  await tester.pumpAndSettle();
  expect(find.text(Strings.bodyMapHarms), findsOneWidget);
  expect(find.text(Strings.bodyMapBenefits), findsOneWidget);
  await tester.pageBack();
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('free teasers → pro_max detail → expired = free → founder = pro max', (tester) async {
    // Always a fresh account so the host script knows whose plan to change.
    await app.main();
    await pumpUntil(
      tester,
      find.byWidgetPredicate((w) => w is NavigationBar || (w is Text && w.data == Strings.positioningLine)),
    );
    await tester.pumpAndSettle();
    if (find.byType(NavigationBar).evaluate().isNotEmpty) {
      await tester.tap(find.text(Strings.navProfile));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text(Strings.signOut));
      await pumpUntil(tester, find.text(Strings.positioningLine));
    }
    final email = 'gate4-${DateTime.now().millisecondsSinceEpoch}@example.com';
    debugPrint('GATE_EMAIL=$email');
    await launchSignedInAs(tester, email);

    await tapVisible(tester, find.text(Strings.modeBarcode));
    await tester.pumpAndSettle();

    // §14.11 Free: locked teasers, no formulas / guide / risk profile.
    await scanMaggi(tester);
    expectFreeView();

    // §14.12 Pro Max: dietary + reason, body map card + page, risk profile.
    await step(tester, 'PRO_MAX', 'Pro Max ·');
    await scanMaggi(tester);
    expectProMaxView();
    await expectBodyMapPage(tester);

    // §15 Expired paid plan behaves as Free, including locked sections.
    await step(tester, 'EXPIRED', 'Free ·');
    await scanMaggi(tester);
    expectFreeView();

    // Unlimited role (founder) is treated as Pro Max.
    await step(tester, 'FOUNDER', 'Unlimited scans');
    await scanMaggi(tester);
    expectProMaxView();
    await expectBodyMapPage(tester);
    debugPrint('STEP:DONE');
  });
}
