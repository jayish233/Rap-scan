import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../l10n/strings.dart';

/// Centers content at the max content width on tablets (design.md §1),
/// with the standard side gutter on phones.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
          child: child,
        ),
      ),
    );
  }
}

/// Marketing card with the hard, primary-green offset shadow (design.md §1).
class HardOffsetCard extends StatelessWidget {
  const HardOffsetCard({super.key, required this.child, this.highlighted = false});

  final Widget child;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: highlighted ? AppColors.surfaceMuted : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.primary, width: 1.5),
        boxShadow: const [
          BoxShadow(color: AppColors.primary, offset: AppSizes.hardShadowOffset, blurRadius: 0),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

/// Persistent disclaimer (CLAUDE.md hard rule 10).
class DisclaimerFooter extends StatelessWidget {
  const DisclaimerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              Strings.disclaimer,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section heading + optional subtitle used across tabs.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(header: true, child: Text(title, style: theme.headlineMedium)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: theme.bodyMedium?.copyWith(color: AppColors.textMuted)),
        ],
      ],
    );
  }
}

/// Short success/failure toast (PRD §12).
void showToast(BuildContext context, String message, {bool error = false}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.danger : AppColors.text,
      ),
    );
}
