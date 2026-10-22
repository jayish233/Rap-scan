import 'package:flutter_test/flutter_test.dart';
import 'package:learn/app/routes.dart';

void main() {
  group('authRedirect (PRD §14.14)', () {
    test('signed-out users are sent to auth from gated tabs', () {
      for (final path in ['/scan', '/history', '/history/abc', '/weekly', '/profile']) {
        expect(authRedirect(location: path, signedIn: false), Routes.auth, reason: path);
      }
    });

    test('public pages stay reachable signed out', () {
      for (final path in ['/', '/home', '/auth', '/leaderboard', '/trust', '/guides/healthy-snacks']) {
        expect(authRedirect(location: path, signedIn: false), isNull, reason: path);
      }
    });

    test('signed-in users skip the auth screen', () {
      expect(authRedirect(location: '/auth', signedIn: true), Routes.scan);
    });

    test('signed-in users can open every other route', () {
      for (final path in ['/home', '/scan', '/history/abc', '/leaderboard', '/trust']) {
        expect(authRedirect(location: path, signedIn: true), isNull, reason: path);
      }
    });

    test('prefix match does not gate look-alike paths', () {
      expect(Routes.isGated('/scanner'), isFalse);
      expect(Routes.isGated('/history-public'), isFalse);
    });
  });
}
