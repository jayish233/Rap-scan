import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../l10n/strings.dart';

/// Explains how to re-enable the camera; paste and manual barcode entry stay
/// available (design.md §8).
class CameraDeniedNotice extends StatelessWidget {
  const CameraDeniedNotice({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fg = onDark ? Colors.white : AppColors.text;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: onDark ? Colors.white.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSizes.radius),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.no_photography_outlined, color: AppColors.warning),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Strings.cameraDeniedTitle, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: fg)),
                  const SizedBox(height: 2),
                  Text(Strings.cameraDeniedBody, style: text.bodyMedium?.copyWith(color: fg)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
