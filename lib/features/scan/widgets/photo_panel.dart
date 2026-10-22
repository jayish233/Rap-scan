import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../data/photo_service.dart';
import '../../../l10n/strings.dart';

/// Photo mode: take (rear camera) or pick, preview with a remove control
/// (PRD §7.3, design.md §4.4).
class PhotoPanel extends StatelessWidget {
  const PhotoPanel({super.key, required this.photo, required this.enabled, required this.onPick, required this.onRemove});

  final PickedPhoto? photo;
  final bool enabled;
  final void Function(PhotoSource source) onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    if (photo == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(Strings.photoHint, style: text.bodyMedium?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: enabled ? () => onPick(PhotoSource.camera) : null,
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text(Strings.takePhoto),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: enabled ? () => onPick(PhotoSource.gallery) : null,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text(Strings.chooseFromLibrary),
          ),
        ],
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          child: Semantics(
            image: true,
            label: 'Selected label photo',
            child: Image.memory(
              photo!.bytes,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => Container(
                height: 220,
                color: AppColors.surfaceMuted,
                alignment: Alignment.center,
                child: const Icon(Icons.image_outlined, size: 48, color: AppColors.textMuted),
              ),
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: IconButton.filled(
            tooltip: Strings.removePhoto,
            onPressed: enabled ? onRemove : null,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              foregroundColor: Colors.white,
              minimumSize: const Size(AppSizes.minTouchTarget, AppSizes.minTouchTarget),
            ),
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}
