import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../data/photo_service.dart';
import '../../../l10n/strings.dart';
import '../../../widgets/adaptive.dart';

/// Photo mode (handoff spec §4.2): dashed drop area "Tap to take a photo or
/// upload the food label"; preview with a remove (X) control.
class PhotoPanel extends StatelessWidget {
  const PhotoPanel({super.key, required this.photo, required this.enabled, required this.onPick, required this.onRemove});

  final PickedPhoto? photo;
  final bool enabled;
  final void Function(PhotoSource source) onPick;
  final VoidCallback onRemove;

  void _chooseSource(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text(Strings.takePhoto),
              onTap: () {
                Navigator.of(sheetContext).pop();
                onPick(PhotoSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text(Strings.chooseFromLibrary),
              onTap: () {
                Navigator.of(sheetContext).pop();
                onPick(PhotoSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ios = isIos(context);
    final radius = BorderRadius.circular(cardRadius(context));
    if (photo == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            label: Strings.photoDropHint,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? () => _chooseSource(context) : null,
                borderRadius: radius,
                child: CustomPaint(
                  painter: _DashedBorderPainter(radius: cardRadius(context)),
                  child: Container(
                    height: ios ? 180 : 190,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.primary),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            Strings.photoDropHint,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const FieldHelper(text: Strings.photoHint),
        ],
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: radius,
          child: Semantics(
            image: true,
            label: 'Selected label photo',
            child: Image.memory(
              photo!.bytes,
              height: ios ? 220 : 230,
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
          top: 8,
          right: 8,
          child: IconButton.filled(
            tooltip: Strings.removePhoto,
            onPressed: enabled ? onRemove : null,
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              foregroundColor: Colors.white,
              minimumSize: Size(touchTarget(context), touchTarget(context)),
            ),
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.inputOutline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rect = Offset.zero & size;
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect.deflate(0.75), Radius.circular(radius)));

    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(metric.extractPath(distance, next.clamp(0, metric.length)), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.radius != radius;
}
