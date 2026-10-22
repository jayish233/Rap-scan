import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:learn/app/router.dart';
import 'package:learn/app/routes.dart';
import 'package:learn/app/session.dart';
import 'package:learn/app/theme.dart';
import 'package:learn/data/auth_repository.dart';
import 'package:learn/data/history_repository.dart';
import 'package:learn/data/leaderboard_repository.dart';
import 'package:learn/data/profile_repository.dart';
import 'package:learn/domain/leaderboard.dart';
import 'package:learn/domain/profile.dart';
import 'package:learn/domain/plan.dart';
import 'package:learn/l10n/strings.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _freeQuota = Quota(remaining: 30, scanLimit: 30, plan: 'free', planLabel: 'Free', isUnlimited: false);

/// Pumps the real router with a controllable session and no network.
Future<({GoRouter router, StreamController<String?> auth, _MockAuthRepository repo})> pumpApp(
  WidgetTester tester, {
  required String initialLocation,
  String? userId,
}) async {
  final auth = StreamController<String?>.broadcast();
  final session = SessionState(userId: userId, userIdChanges: auth.stream);
  final repo = _MockAuthRepository();
  when(repo.signOut).thenAnswer((_) async => auth.add(null));
  final router = buildRouter(session, initialLocation: initialLocation);
  addTearDown(() {
    router.dispose();
    session.dispose();
    auth.close();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionStateProvider.overrideWithValue(session),
        currentUserIdProvider.overrideWith((ref) => ref.watch(sessionStateProvider).userId),
        authRepositoryProvider.overrideWithValue(repo),
        quotaProvider.overrideWith((ref) async => _freeQuota),
        leaderboardProvider.overrideWith((ref) async => const <LeaderboardEntry>[]),
        profileProvider.overrideWith((ref) async => const Cached(Profile(id: 'u1', email: 'a@example.com'))),
      ],
      child: MaterialApp.router(theme: buildAppTheme(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return (router: router, auth: auth, repo: repo);
}

String location(GoRouter router) => router.routerDelegate.currentConfiguration.uri.path;

void main() {
  testWidgets('signed-in user lands on Scan and sees Free · 30 of 30 scans left (PRD §14.1)', (tester) async {
    final app = await pumpApp(tester, initialLocation: Routes.auth, userId: 'u1');
    expect(location(app.router), Routes.scan);
    expect(find.text('Free · 30 of 30 scans left'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text(Strings.disclaimer), findsOneWidget);
  });

  testWidgets('signing in from the auth screen moves to Scan', (tester) async {
    final app = await pumpApp(tester, initialLocation: Routes.auth);
    expect(find.text(Strings.signIn), findsWidgets);
    app.auth.add('u1');
    await tester.pumpAndSettle();
    expect(location(app.router), Routes.scan);
  });

  testWidgets('sign-out from Profile returns to Home (PRD §7.1)', (tester) async {
    final app = await pumpApp(tester, initialLocation: Routes.profile, userId: 'u1');
    await tester.ensureVisible(find.text(Strings.signOut));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.signOut));
    await tester.pumpAndSettle();
    verify(app.repo.signOut).called(1);
    expect(location(app.router), Routes.home);
    expect(find.text(Strings.positioningLine), findsOneWidget);
  });

  testWidgets('expired session on a gated tab returns to sign-in', (tester) async {
    final app = await pumpApp(tester, initialLocation: Routes.weekly, userId: 'u1');
    app.auth.add(null);
    await tester.pumpAndSettle();
    expect(location(app.router), Routes.auth);
  });

  for (final path in [Routes.scan, Routes.history, Routes.weekly, Routes.profile]) {
    testWidgets('signed out: $path redirects to auth', (tester) async {
      final app = await pumpApp(tester, initialLocation: path);
      expect(location(app.router), Routes.auth);
    });
  }

  testWidgets('signed out: leaderboard, trust and guide are reachable without nav bar', (tester) async {
    final app = await pumpApp(tester, initialLocation: Routes.leaderboard);
    expect(location(app.router), Routes.leaderboard);
    expect(find.text(Strings.leaderboardCopy), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    app.router.go(Routes.trust);
    await tester.pumpAndSettle();
    expect(find.text('Trust & privacy'), findsOneWidget);

    app.router.go(Routes.healthySnacks);
    await tester.pumpAndSettle();
    expect(find.text(Strings.guideTitle), findsOneWidget);
  });

  testWidgets('Home: Start scanning goes to auth when signed out', (tester) async {
    final app = await pumpApp(tester, initialLocation: Routes.home);
    expect(find.text(Strings.disclaimer), findsOneWidget);
    await tester.tap(find.text(Strings.homeCta));
    await tester.pumpAndSettle();
    expect(location(app.router), Routes.auth);
  });

  testWidgets('Home shows all four plans and the payments notice', (tester) async {
    await pumpApp(tester, initialLocation: Routes.home);
    for (final tier in PlanTier.values) {
      await tester.scrollUntilVisible(find.text(tier.price), 200);
      expect(find.text(tier.price), findsOneWidget);
    }
    await tester.scrollUntilVisible(find.text(Strings.billingPlaceholder), 200);
    expect(find.text(Strings.billingPlaceholder), findsOneWidget);
  });
}
