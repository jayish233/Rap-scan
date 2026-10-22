// Phase 1 gate (CLAUDE.md, PRD §14.1 + §14.14 partial), end to end against
// a real Supabase backend:
//   flutter test integration_test/phase1_gate_test.dart \
//     --dart-define-from-file=config/local.json -d <simulator>
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:learn/l10n/strings.dart';
import 'package:learn/main.dart' as app;

import 'gate_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sign up → Scan with Free · 30 of 30; sign out → Home; public pages reachable', (tester) async {
    await app.main();
    // Past the splash: Home (signed out) or the tab shell (session kept).
    await pumpUntil(
      tester,
      find.byWidgetPredicate((w) => w is NavigationBar || (w is Text && w.data == Strings.positioningLine)),
    );
    await tester.pumpAndSettle();
    if (find.byType(NavigationBar).evaluate().isNotEmpty) {
      await tester.tap(find.text(Strings.navProfile));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text(Strings.signOut));
    }
    await pumpUntil(tester, find.text(Strings.positioningLine));

    // Home → Start scanning → Auth (signed out).
    await tester.tap(find.text(Strings.homeCta));
    await pumpUntil(tester, find.text(Strings.needAccount));
    await tester.tap(find.text(Strings.needAccount));
    await tester.pumpAndSettle();

    final email = 'gate${DateTime.now().millisecondsSinceEpoch}@example.com';
    await tester.enterText(find.widgetWithText(TextFormField, Strings.email), email);
    await tester.enterText(find.widgetWithText(TextFormField, Strings.password), 'gate-pass-123');
    final submit = find.widgetWithText(FilledButton, Strings.createAccount);
    FocusManager.instance.primaryFocus?.unfocus(); // dismiss the keyboard
    await tester.pumpAndSettle();
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);

    // Lands on Scan with the server-reported quota.
    await pumpUntil(tester, find.text('Free · 30 of 30 scans left'));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text(Strings.disclaimer), findsOneWidget);

    // Sign out from Profile → Home.
    await tester.tap(find.text(Strings.navProfile));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text(Strings.signOut));
    await pumpUntil(tester, find.text(Strings.positioningLine));
    expect(find.byType(NavigationBar), findsNothing);

    // Public pages while signed out.
    await tester.ensureVisible(find.text(Strings.linkLeaderboard));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.linkLeaderboard));
    await pumpUntil(tester, find.text(Strings.leaderboardCopy));
    await tester.tap(find.byType(BackButton));
    await pumpUntil(tester, find.text(Strings.positioningLine));

    await tester.ensureVisible(find.text(Strings.linkTrust));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.linkTrust));
    await pumpUntil(tester, find.text('Trust & privacy'));
    await tester.tap(find.byType(BackButton));
    await pumpUntil(tester, find.text(Strings.positioningLine));

    await tester.ensureVisible(find.text(Strings.linkGuide));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.linkGuide));
    await pumpUntil(tester, find.text(Strings.guideTitle));
  });
}
