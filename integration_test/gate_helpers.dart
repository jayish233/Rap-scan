// Shared helpers for the on-device gate tests.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn/l10n/strings.dart';
import 'package:learn/main.dart' as app;

Future<void> pumpUntil(WidgetTester tester, Finder finder, {Duration timeout = const Duration(seconds: 90)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  final visible = find.byType(Text).evaluate().map((e) => (e.widget as Text).data).whereType<String>().toList();
  throw TestFailure('Timed out waiting for $finder\nOn screen: $visible');
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
}

/// Launches the app and makes sure a user is signed in (signing up a fresh
/// account if the device has no session). Ends on the Scan tab.
Future<void> launchSignedIn(WidgetTester tester) async {
  await app.main();
  await pumpUntil(
    tester,
    find.byWidgetPredicate((w) => w is NavigationBar || (w is Text && w.data == Strings.positioningLine)),
  );
  await tester.pumpAndSettle();
  if (find.byType(NavigationBar).evaluate().isEmpty) {
    await tester.tap(find.text(Strings.homeCta));
    await pumpUntil(tester, find.text(Strings.needAccount));
    await tester.tap(find.text(Strings.needAccount));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, Strings.email),
      'gate-${DateTime.now().millisecondsSinceEpoch}@example.com',
    );
    await tester.enterText(find.widgetWithText(TextFormField, Strings.password), 'gate-pass-123');
    await tapVisible(tester, find.widgetWithText(FilledButton, Strings.createAccount));
  }
  await pumpUntil(tester, find.byType(NavigationBar));
  await tester.tap(find.text(Strings.navScan));
  await pumpUntil(tester, find.textContaining('scans left'));
}

/// From Home (signed out): create [email] and land on the Scan tab.
Future<void> launchSignedInAs(WidgetTester tester, String email) async {
  await tester.tap(find.text(Strings.homeCta));
  await pumpUntil(tester, find.text(Strings.needAccount));
  await tester.tap(find.text(Strings.needAccount));
  await tester.pumpAndSettle();
  await tester.enterText(find.widgetWithText(TextFormField, Strings.email), email);
  await tester.enterText(find.widgetWithText(TextFormField, Strings.password), 'gate-pass-123');
  await tapVisible(tester, find.widgetWithText(FilledButton, Strings.createAccount));
  await pumpUntil(tester, find.textContaining('scans left'));
}

/// The quota chip text currently shown.
String chipText(WidgetTester tester) =>
    find.textContaining('scans left').evaluate().map((e) => (e.widget as Text).data!).first;

Future<void> setField(WidgetTester tester, String key, String value) async {
  final field = find.byKey(ValueKey(key));
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  // On-device, enterText does not reliably replace an already-filled field.
  tester.widget<TextField>(field).controller!.text = value;
  await tester.pump();
}
