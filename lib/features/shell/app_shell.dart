import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/session.dart';
import '../../l10n/strings.dart';

/// Authenticated shell with the 5-tab bottom navigation (design.md §3.2).
/// Signed-out visitors only reach the public Leaderboard branch, so the nav
/// bar is hidden for them.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.qr_code_scanner_outlined),
      selectedIcon: Icon(Icons.qr_code_scanner),
      label: Strings.navScan,
    ),
    NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: Strings.navHistory),
    NavigationDestination(
      icon: Icon(Icons.local_fire_department_outlined),
      selectedIcon: Icon(Icons.local_fire_department),
      label: Strings.navWeekly,
    ),
    NavigationDestination(
      icon: Icon(Icons.emoji_events_outlined),
      selectedIcon: Icon(Icons.emoji_events),
      label: Strings.navLeaderboard,
    ),
    NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Strings.navProfile),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(sessionStateProvider).signedIn;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: signedIn
          ? NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              destinations: _destinations,
              onDestinationSelected: (i) =>
                  navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
            )
          : null,
    );
  }
}
