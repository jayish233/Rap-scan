import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app/theme.dart';
import '../../../l10n/strings.dart';
import '../../../widgets/adaptive.dart';
import 'barcode_scanner_page.dart' show acceptScannedValue;
import 'camera_denied_notice.dart';

/// Inline live barcode viewfinder (handoff mockups §4.2): dark #0F1A14
/// panel with green corner brackets, a sweeping laser line, flashlight
/// toggle and the "Align the barcode inside the frame" hint. Calls
/// [onCode] with the first accepted EAN-8/EAN-13/UPC-A/ITF-14 code.
class BarcodeViewfinder extends StatefulWidget {
  const BarcodeViewfinder({super.key, required this.onCode, required this.onDenied, this.paused = false});

  final ValueChanged<String> onCode;
  final VoidCallback onDenied;

  /// Stop reacting to detections (e.g. while a scan is running).
  final bool paused;

  @override
  State<BarcodeViewfinder> createState() => _BarcodeViewfinderState();
}

class _BarcodeViewfinderState extends State<BarcodeViewfinder> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.ean8, BarcodeFormat.ean13, BarcodeFormat.upcA, BarcodeFormat.itf14],
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _torch = false;
  bool _denied = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (widget.paused) return;
    for (final barcode in capture.barcodes) {
      final code = acceptScannedValue(barcode.format, barcode.rawValue);
      if (code != null) {
        widget.onCode(code);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ios = isIos(context);
    final radius = BorderRadius.circular(ios ? 24 : 28);
    return Semantics(
      label: Strings.scannerViewfinderHint,
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          height: ios ? 280 : 296,
          color: AppColors.darkPanel,
          child: _denied
              ? const Center(
                  child: Padding(padding: EdgeInsets.all(AppSizes.gutter), child: CameraDeniedNotice(onDark: true)),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    // No live camera or infinite laser in widget tests.
                    if (!isTestEnv) ...[
                      MobileScanner(
                        controller: _controller,
                        onDetect: _onDetect,
                        errorBuilder: (context, error) {
                          if (error.errorCode == MobileScannerErrorCode.permissionDenied && !_denied) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() => _denied = true);
                                widget.onDenied();
                              }
                            });
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      // Dim the camera feed towards the mockup's dark panel.
                      const ColoredBox(color: Color(0x660F1A14)),
                    ],
                    const _CornerBrackets(),
                    if (!isTestEnv) const _LaserLine(),
                    Positioned(
                      top: ios ? 14 : 12,
                      right: ios ? 14 : 12,
                      child: IconButton(
                        tooltip: Strings.toggleFlashlight,
                        onPressed: () async {
                          await _controller.toggleTorch();
                          if (mounted) setState(() => _torch = !_torch);
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.16),
                          foregroundColor: Colors.white,
                          minimumSize: Size(touchTarget(context), touchTarget(context)),
                          shape: const CircleBorder(),
                        ),
                        icon: Icon(_torch ? Icons.flash_on : Icons.flash_off_outlined, size: ios ? 20 : 22),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: ios ? 16 : 18,
                      child: const Text(
                        Strings.scannerViewfinderHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onDarkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Four green corner brackets, like the mockup's reticle.
class _CornerBrackets extends StatelessWidget {
  const _CornerBrackets();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(child: CustomPaint(painter: _BracketsPainter(), size: Size.infinite));
  }
}

class _BracketsPainter extends CustomPainter {
  const _BracketsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const arm = 26.0;
    const r = 10.0;
    final horizontal = size.width * 0.18;
    final top = size.height * 0.20;
    final bottom = size.height * 0.72;

    void corner(Offset origin, double dx, double dy) {
      final path = Path()
        ..moveTo(origin.dx + (arm + r) * dx, origin.dy)
        ..lineTo(origin.dx + r * dx, origin.dy)
        ..quadraticBezierTo(origin.dx, origin.dy, origin.dx, origin.dy + r * dy)
        ..lineTo(origin.dx, origin.dy + (arm + r) * dy);
      canvas.drawPath(path, paint);
    }

    corner(Offset(horizontal, top), 1, 1);
    corner(Offset(size.width - horizontal, top), -1, 1);
    corner(Offset(horizontal, bottom), 1, -1);
    corner(Offset(size.width - horizontal, bottom), -1, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Cyan laser sweep across the frame.
class _LaserLine extends StatefulWidget {
  const _LaserLine();

  @override
  State<_LaserLine> createState() => _LaserLineState();
}

class _LaserLineState extends State<_LaserLine> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final top = constraints.maxHeight * 0.20 + (constraints.maxHeight * 0.52) * _controller.value;
              return Stack(
                children: [
                  Positioned(
                    left: constraints.maxWidth * 0.12,
                    right: constraints.maxWidth * 0.12,
                    top: top,
                    child: Container(
                      height: 2,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.transparent, AppColors.laser, Colors.transparent]),
                        boxShadow: [BoxShadow(color: AppColors.laser, blurRadius: 14)],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
