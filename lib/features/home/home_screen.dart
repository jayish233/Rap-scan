import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/session.dart';
import '../../app/theme.dart';
import '../../l10n/strings.dart';
import '../../widgets/brand.dart';
import '../../widgets/common.dart';
import 'pricing_cards.dart';

/// Marketing home (PRD §7.2, design.md §4.2).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(sessionStateProvider).signedIn;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const BrandLockup(), centerTitle: false),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: Text(Strings.positioningLine, style: text.displaySmall?.copyWith(height: 1.1)),
                  ),
                  const SizedBox(height: 12),
                  Text(Strings.homeSupportingCopy, style: text.bodyLarge?.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.go(signedIn ? Routes.scan : Routes.auth),
                    child: const Text(Strings.homeCta),
                  ),
                  const SizedBox(height: 36),
                  Semantics(header: true, child: Text(Strings.howItWorksTitle, style: text.headlineSmall)),
                  const SizedBox(height: 16),
                  for (final (i, step) in Strings.howItWorksSteps.indexed) ...[
                    _StepCard(number: i + 1, text: step),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 20),
                  Semantics(header: true, child: Text(Strings.pricingTitle, style: text.headlineSmall)),
                  const SizedBox(height: 4),
                  Text(Strings.pricingSubtitle, style: text.bodyMedium?.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  const PricingCards(),
                  const SizedBox(height: 28),
                  const _Links(),
                  const DisclaimerFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return HardOffsetCard(
      child: Row(
        children: [
          ExcludeSemantics(
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Text(
                '$number',
                style: const TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Semantics(
              label: 'Step $number. $text',
              excludeSemantics: true,
              child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }
}

class _Links extends StatelessWidget {
  const _Links();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      children: [
        TextButton.icon(
          onPressed: () => context.go(Routes.leaderboard),
          icon: const Icon(Icons.emoji_events_outlined),
          label: const Text(Strings.linkLeaderboard),
        ),
        TextButton.icon(
          onPressed: () => context.push(Routes.trust),
          icon: const Icon(Icons.verified_user_outlined),
          label: const Text(Strings.linkTrust),
        ),
        TextButton.icon(
          onPressed: () => context.push(Routes.healthySnacks),
          icon: const Icon(Icons.menu_book_outlined),
          label: const Text(Strings.linkGuide),
        ),
      ],
    );
  }
}
