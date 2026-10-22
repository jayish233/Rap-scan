import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/session.dart';
import '../../app/theme.dart';
import '../../data/leaderboard_repository.dart';
import '../../data/profile_repository.dart';
import '../../domain/leaderboard.dart';
import '../../l10n/strings.dart';
import '../../widgets/adaptive.dart';
import '../../widgets/common.dart';

/// Public leaderboard (PRD §7.8, handoff spec §4.6): rank badges (gold /
/// silver / bronze), average score in primary, and the signed-in user's row
/// pinned at the bottom when they're ranked.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(sessionStateProvider).signedIn;
    final board = ref.watch(leaderboardProvider);
    final ios = isIos(context);
    final username = signedIn ? ref.watch(profileProvider).value?.value.username : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (!signedIn)
              Align(
                alignment: Alignment.centerLeft,
                child: BackButton(onPressed: () => context.canPop() ? context.pop() : context.go(Routes.home)),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.refresh(leaderboardProvider.future),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: ios ? 24 : 12),
                  children: [
                    ContentWidth(
                      padding: EdgeInsets.symmetric(horizontal: ios ? 20 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ScreenHeader(
                            title: Strings.navLeaderboard,
                            subtitle: Strings.leaderboardCopy,
                            trailing: Container(
                              width: ios ? 48 : 44,
                              height: ios ? 48 : 44,
                              decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(14)),
                              alignment: Alignment.center,
                              child: Icon(Icons.emoji_events_outlined, size: ios ? 26 : 24, color: AppColors.onAccent),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ...switch (board) {
                            AsyncData(:final value) when value.isEmpty => [const _Empty()],
                            AsyncData(:final value) => [
                                for (final e in value)
                                  if (e.username != username) ...[
                                    _RankRow(entry: e),
                                    SizedBox(height: ios ? 8 : 0),
                                  ],
                              ],
                            AsyncError() => [
                                ErrorState(message: Strings.loadFailed, onRetry: () => ref.invalidate(leaderboardProvider)),
                              ],
                            _ => [const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))],
                          },
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Pinned "You" row (handoff: new in this design).
            if (signedIn && username != null)
              switch (board) {
                AsyncData(:final value) => () {
                    final me = value.where((e) => e.username == username).firstOrNull;
                    if (me == null) return const SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.fromLTRB(ios ? 20 : 16, 0, ios ? 20 : 16, ios ? 8 : 12),
                      child: ContentWidth(padding: EdgeInsets.zero, child: _YouRow(entry: me)),
                    );
                  }(),
                _ => const SizedBox.shrink(),
              },
          ],
        ),
      ),
    );
  }
}

Color _badgeColor(int rank) => switch (rank) {
      1 => AppColors.gold,
      2 => AppColors.silver,
      3 => AppColors.bronze,
      _ => AppColors.surfaceContainer,
    };

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, this.onPrimary = false});

  final int rank;

  /// White-on-primary badge for the pinned "You" row.
  final bool onPrimary;

  @override
  Widget build(BuildContext context) {
    final ios = isIos(context);
    final medal = rank <= 3;
    return Container(
      width: ios ? 36 : 40,
      height: ios ? 36 : 40,
      decoration: BoxDecoration(
        color: onPrimary ? AppColors.primary : (medal ? _badgeColor(rank) : (ios ? Colors.transparent : AppColors.surfaceContainer)),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: TextStyle(
          fontFamily: AppFonts.display,
          fontSize: ios ? (medal ? 17 : 16) : (medal ? 18 : 16),
          fontWeight: medal ? FontWeight.w800 : FontWeight.w700,
          color: onPrimary ? AppColors.onPrimary : (medal || !ios ? AppColors.text : AppColors.textMuted),
        ),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final ios = isIos(context);
    final score = Text(
      '${entry.averageScore}',
      style: const TextStyle(fontFamily: AppFonts.display, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.7, color: AppColors.primary),
    );
    final name = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(entry.handle, style: ios ? text.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 15) : text.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        Text(Strings.scanCount(entry.scanCount), style: text.bodySmall?.copyWith(color: AppColors.textMuted, fontSize: ios ? 12 : 13)),
      ],
    );

    final row = Semantics(
      label: 'Rank ${entry.rank}, ${entry.handle}, average score ${entry.averageScore}, ${Strings.scanCount(entry.scanCount)}',
      excludeSemantics: true,
      child: Row(
        children: [
          _RankBadge(rank: entry.rank),
          SizedBox(width: ios ? 12 : 16),
          Expanded(child: name),
          score,
        ],
      ),
    );

    if (ios) {
      return AppCard(radius: 16, padding: const EdgeInsets.fromLTRB(12, 10, 16, 10), child: row);
    }
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.only(left: 8, right: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: row,
    );
  }
}

/// Pinned current-user row: iOS light-green card with a primary border and
/// the hard leaf offset shadow; Android a tonal #CDEFCB container.
class _YouRow extends StatelessWidget {
  const _YouRow({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final ios = isIos(context);
    final text = Theme.of(context).textTheme;
    final nameColor = ios ? AppColors.text : AppColors.onTonal;
    final subColor = ios ? AppColors.severityChipLowText : const Color(0xFF1F4A2E);

    return Semantics(
      label: 'Your rank ${entry.rank}, average score ${entry.averageScore}, ${Strings.scanCount(entry.scanCount)}',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.fromLTRB(ios ? 12 : 12, 10, 16, 10),
        constraints: BoxConstraints(minHeight: ios ? 0 : 72),
        decoration: BoxDecoration(
          color: ios ? AppColors.youRowBg : AppColors.tonal,
          borderRadius: BorderRadius.circular(ios ? 16 : 20),
          border: ios ? Border.all(color: AppColors.primary, width: 2) : null,
          boxShadow: ios ? const [BoxShadow(color: AppColors.accent, offset: AppSizes.hardShadowOffset, blurRadius: 0)] : null,
        ),
        child: Row(
          children: [
            _RankBadge(rank: entry.rank, onPrimary: true),
            SizedBox(width: ios ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: ios ? 15 : 16, color: nameColor),
                      children: [
                        TextSpan(text: entry.handle),
                        TextSpan(
                          text: ' · You',
                          style: TextStyle(fontWeight: FontWeight.w600, color: ios ? AppColors.primary : nameColor),
                        ),
                      ],
                    ),
                  ),
                  Text(Strings.scanCount(entry.scanCount), style: text.bodySmall?.copyWith(color: subColor, fontSize: ios ? 12 : 13)),
                ],
              ),
            ),
            Text(
              '${entry.averageScore}',
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontSize: ios ? 24 : 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.7,
                color: ios ? AppColors.primary : AppColors.onTonal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(Strings.leaderboardEmpty, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
