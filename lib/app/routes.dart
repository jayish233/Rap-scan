/// Route paths (design.md §3).
abstract final class Routes {
  static const splash = '/';
  static const home = '/home';
  static const auth = '/auth';
  static const leaderboard = '/leaderboard';
  static const trust = '/trust';
  static const healthySnacks = '/guides/healthy-snacks';
  static const scan = '/scan';
  static const history = '/history';
  static const weekly = '/weekly';
  static const profile = '/profile';

  static String historyDetail(String id) => '$history/$id';

  /// Tabs that require a session (PRD §14.14).
  static const _gated = [scan, history, weekly, profile];

  static bool isGated(String location) =>
      _gated.any((p) => location == p || location.startsWith('$p/'));
}

/// Auth gate (architecture.md §2.4.4). Pure so it can be unit-tested.
/// Signed-out users hitting a gated tab go to sign-in; a signed-in user on
/// the auth screen goes to Scan. Everything else stays where it is.
String? authRedirect({required String location, required bool signedIn}) {
  if (!signedIn && Routes.isGated(location)) return Routes.auth;
  if (signedIn && location == Routes.auth) return Routes.scan;
  return null;
}
