import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/session.dart';
import '../../data/auth_repository.dart';
import '../../l10n/strings.dart';
import '../../widgets/common.dart';

// Placeholder tabs for the Phase 1 shell. Each is replaced by its feature
// screen in a later phase (History: 2, Weekly/Leaderboard/Profile: 5).

class _TabPage extends StatelessWidget {
  const _TabPage({required this.title, this.subtitle, this.leading, this.children = const []});

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: leading),
      body: SafeArea(
        top: false,
        child: ListView(
          children: [
            ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [PageHeader(title: title, subtitle: subtitle), const SizedBox(height: 24), ...children],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryPlaceholder extends StatelessWidget {
  const HistoryPlaceholder({super.key});

  @override
  Widget build(BuildContext context) =>
      const _TabPage(title: Strings.historyTitle, subtitle: Strings.historySubtitle);
}

class WeeklyPlaceholder extends StatelessWidget {
  const WeeklyPlaceholder({super.key});

  @override
  Widget build(BuildContext context) =>
      const _TabPage(title: Strings.weeklyTitle, subtitle: Strings.weeklySubtitle);
}

/// Public: reachable signed out (with a way back Home) and as a tab.
class LeaderboardPlaceholder extends ConsumerWidget {
  const LeaderboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(sessionStateProvider).signedIn;
    return _TabPage(
      title: Strings.navLeaderboard,
      subtitle: Strings.leaderboardCopy,
      leading: signedIn
          ? null
          : BackButton(onPressed: () => context.canPop() ? context.pop() : context.go(Routes.home)),
    );
  }
}

class ProfilePlaceholder extends ConsumerWidget {
  const ProfilePlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _TabPage(
      title: Strings.navProfile,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            final auth = ref.read(authRepositoryProvider);
            // Leave the gated tab first so sign-out lands on Home, not Auth.
            context.go(Routes.home);
            auth.signOut();
          },
          icon: const Icon(Icons.logout),
          label: const Text(Strings.signOut),
        ),
      ],
    );
  }
}
