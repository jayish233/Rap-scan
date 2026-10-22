import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_screen.dart';
import '../features/content/healthy_snacks_screen.dart';
import '../features/content/trust_screen.dart';
import '../features/home/home_screen.dart';
import '../features/scan/scan_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/shell/tab_placeholders.dart';
import '../features/splash/splash_screen.dart';
import 'routes.dart';
import 'session.dart';

GoRouter buildRouter(SessionState session, {String initialLocation = Routes.splash}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: session,
    redirect: (context, state) => authRedirect(location: state.uri.path, signedIn: session.signedIn),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(path: Routes.auth, builder: (_, _) => const AuthScreen()),
      GoRoute(path: Routes.trust, builder: (_, _) => const TrustScreen()),
      GoRoute(path: Routes.healthySnacks, builder: (_, _) => const HealthySnacksScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: Routes.scan, builder: (_, _) => const ScanScreen())]),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.history,
                builder: (_, _) => const HistoryPlaceholder(),
                routes: [GoRoute(path: ':id', builder: (_, _) => const HistoryPlaceholder())],
              ),
            ],
          ),
          StatefulShellBranch(routes: [GoRoute(path: Routes.weekly, builder: (_, _) => const WeeklyPlaceholder())]),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.leaderboard, builder: (_, _) => const LeaderboardPlaceholder())],
          ),
          StatefulShellBranch(routes: [GoRoute(path: Routes.profile, builder: (_, _) => const ProfilePlaceholder())]),
        ],
      ),
    ],
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = buildRouter(ref.watch(sessionStateProvider));
  ref.onDispose(router.dispose);
  return router;
});
