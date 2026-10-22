// Phase 5 gate (CLAUDE.md; PRD §14.8–10, §14.13), on device against the real
// backend. Uses the cached Maggi barcode, so no model call is required.
//   flutter test integration_test/phase5_gate_test.dart \
//     --dart-define-from-file=config/local.json -d <simulator>
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:learn/l10n/strings.dart';
import 'package:learn/main.dart' as app;

import 'gate_helpers.dart';

const maggi = '8901058851298';
const maggiName = 'Maggi Noodles Masala 70Grm Pc';

Future<void> settle(WidgetTester tester, [int seconds = 5]) async {
  await tester.pump(Duration(seconds: seconds)); // let toasts clear
  await tester.pumpAndSettle();
}

Future<void> goTab(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(of: find.byType(NavigationBar), matching: find.text(label)));
  await tester.pumpAndSettle();
}

Future<void> scanMaggi(WidgetTester tester) async {
  await setField(tester, 'scan-barcode-field', maggi);
  await tapVisible(tester, find.text(Strings.scanButton));
  await pumpUntil(tester, find.text(Strings.scanCompleteToast));
  await pumpUntil(tester, find.text(maggiName));
  await settle(tester);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('profile, leaderboard qualification, I ate this + weekly, feedback persistence', (tester) async {
    await app.main();
    await pumpUntil(
      tester,
      find.byWidgetPredicate((w) => w is NavigationBar || (w is Text && w.data == Strings.positioningLine)),
    );
    await tester.pumpAndSettle();
    if (find.byType(NavigationBar).evaluate().isNotEmpty) {
      await goTab(tester, Strings.navProfile);
      await tapVisible(tester, find.text(Strings.signOut));
      await pumpUntil(tester, find.text(Strings.positioningLine));
    }
    final stamp = DateTime.now().millisecondsSinceEpoch.toString();
    final username = 'gate5_${stamp.substring(stamp.length - 8)}';
    await launchSignedInAs(tester, 'gate5-$stamp@example.com');

    // §14.8 Profile: username + weight, height, allergy saved; live BMI.
    await goTab(tester, Strings.navProfile);
    await pumpUntil(tester, find.byKey(const ValueKey('profile-username')));
    await tester.enterText(find.byKey(const ValueKey('profile-username')), username);
    await tester.enterText(find.byKey(const ValueKey('profile-weight')), '60');
    await tester.enterText(find.byKey(const ValueKey('profile-height')), '165');
    await tester.pumpAndSettle();
    expect(find.text('BMI 22.0'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('profile-allergies')), 'peanuts');
    await tapVisible(tester, find.text(Strings.saveProfile));
    await pumpUntil(tester, find.text(Strings.profileSaved));
    await settle(tester);

    // §14.10 Fewer than 3 scans → absent from the leaderboard.
    await goTab(tester, Strings.navLeaderboard);
    await pumpUntil(tester, find.text(Strings.leaderboardCopy));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('@$username'), findsNothing);

    // Three scored scans.
    await goTab(tester, Strings.navScan);
    await tapVisible(tester, find.text(Strings.modeBarcode));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await scanMaggi(tester);
    }

    // §14.9 I ate this → weekly total; log again; delete removes only the log.
    await tapVisible(tester, find.text(Strings.ateThis));
    await pumpUntil(tester, find.text(Strings.ateThisSuccess));
    await tapVisible(tester, find.text(Strings.ateThis));
    await settle(tester, 2);

    // §14.13 Feedback on this scan.
    await tapVisible(tester, find.byTooltip(Strings.starsLabel(4)));
    await tapVisible(tester, find.text('Maybe'));
    await tester.enterText(find.byKey(const ValueKey('feedback-comment')), 'Gate comment');
    await tapVisible(tester, find.text(Strings.feedbackSubmit));
    await pumpUntil(tester, find.text(Strings.feedbackThanks));

    await goTab(tester, Strings.navWeekly);
    await pumpUntil(tester, find.text(Strings.weeklyTotal));
    await pumpUntil(tester, find.text(maggiName));
    expect(find.text(maggiName), findsNWidgets(2)); // logged twice
    final perServing = RegExp(r'^(\d+) kcal$');
    final kcal = find
        .textContaining(perServing)
        .evaluate()
        .map((e) => int.parse(perServing.firstMatch((e.widget as Text).data!)!.group(1)!))
        .toList();
    // Two entry rows share the per-serving value; the total is twice it and
    // the average is total / 7.
    final serving = kcal.firstWhere((k) => kcal.where((x) => x == k).length == 2);
    expect(kcal, containsAll([serving * 2, (serving * 2 / 7).round()]), reason: 'weekly total = 2 servings');

    await tester.tap(find.byTooltip(Strings.deleteEntry).first);
    await tester.pumpAndSettle();
    await pumpUntil(tester, find.text(maggiName));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(maggiName), findsOneWidget);

    // History still has all three scans; reopening shows the saved feedback.
    await goTab(tester, Strings.navHistory);
    await pumpUntil(tester, find.text(maggiName));
    expect(find.text(maggiName), findsNWidgets(3));
    await tester.tap(find.text(maggiName).first);
    await pumpUntil(tester, find.text(Strings.summaryTitle));
    await pumpUntil(tester, find.text(Strings.feedbackThanks));
    await tester.ensureVisible(find.text(Strings.feedbackThanks));
    await tester.pumpAndSettle();
    expect(find.text('“Gate comment”'), findsOneWidget);
    expect(find.text('${Strings.feedbackPrompt} Maybe'), findsOneWidget);

    // §14.10 Qualifies now: @username with the rounded average.
    await goTab(tester, Strings.navLeaderboard);
    // Pull to refresh the visible list (other tabs stay alive offstage).
    await tester.drag(find.byType(Scrollable).hitTestable().first, const Offset(0, 300));
    await pumpUntil(tester, find.text('@$username'));
    expect(find.text('3 scans'), findsWidgets);
    debugPrint('GATE_USERNAME=$username');
  });
}
