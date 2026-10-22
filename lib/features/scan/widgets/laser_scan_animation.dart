import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Scan-chamber laser sweep shown while analysis runs (design.md §2.4).
/// Loops until removed; it is a compositor animation and never blocks.
class LaserScanAnimation extends StatefulWidget {
  const LaserScanAnimation({super.key, required this.message});

  final String message;

  @override
  State<LaserScanAnimation> createState() => _LaserScanAnimationState();
}

class _LaserScanAnimationState extends State<LaserScanAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Semantics(
      liveRegion: true,
      label: widget.message,
      excludeSemantics: true,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.teal],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (!reduceMotion)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Align(
                  alignment: Alignment(0, -1 + 2 * Curves.easeInOut.transform(_controller.value)),
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.8), blurRadius: 12, spreadRadius: 2)],
                    ),
                  ),
                ),
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
