import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/session.dart';
import '../../../app/theme.dart';
import '../../../data/weekly_repository.dart';
import '../../../l10n/strings.dart';
import '../../../widgets/adaptive.dart';
import '../../../widgets/common.dart';

/// Block 5 (PRD §7.4.5, mockups): logs consumption for this scan. iOS
/// renders a filled green pill, Android the tonal #CDEFCB pill; after
/// logging it becomes "Added to this week", outlined and disabled.
class AteThisButton extends ConsumerStatefulWidget {
  const AteThisButton({super.key, required this.scanId, required this.productName, required this.caloriesKcal});

  final String? scanId;
  final String productName;
  final int caloriesKcal;

  @override
  ConsumerState<AteThisButton> createState() => _AteThisButtonState();
}

class _AteThisButtonState extends ConsumerState<AteThisButton> {
  bool _busy = false;
  bool _added = false;

  Future<void> _log() async {
    final userId = ref.read(currentUserIdProvider);
    final scanId = widget.scanId;
    if (userId == null || scanId == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(weeklyRepositoryProvider).logConsumption(
            userId: userId,
            scanId: scanId,
            productName: widget.productName,
            caloriesKcal: widget.caloriesKcal,
          );
      if (!mounted) return;
      ref.invalidate(weeklyProvider);
      setState(() => _added = true);
    } catch (_) {
      if (mounted) showToast(context, Strings.ateThisFailed, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = ref.watch(currentUserIdProvider) != null;
    final ios = isIos(context);

    if (_added) {
      // Success state per the mockups, still tappable: the same scan can be
      // logged again (the user ate it again, PRD §7.7).
      return Semantics(
        liveRegion: true,
        button: true,
        label: '${Strings.ateThisSuccess} ${Strings.ateThis}',
        child: InkWell(
          onTap: _busy ? null : _log,
          borderRadius: BorderRadius.circular(ios ? 12 : 24),
          child: Container(
            height: ios ? 44 : 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ios ? 12 : 24),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _busy
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check_circle, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  Strings.ateThisSuccess,
                  style: TextStyle(fontFamily: AppFonts.body, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppTonalButton(
      label: Strings.ateThis,
      icon: Icons.restaurant_outlined,
      onPressed: widget.scanId == null || !signedIn || _busy ? null : _log,
    );
  }
}
