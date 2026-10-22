import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app/theme.dart';
import '../../../domain/barcode.dart';
import '../../../l10n/strings.dart';
import 'camera_denied_notice.dart';

sealed class ScannerResult {
  const ScannerResult();
}

final class ScannedCode extends ScannerResult {
  const ScannedCode(this.code);
  final String code;
}

final class ScannerDenied extends ScannerResult {
  const ScannerDenied();
}

/// Accept only the symbologies the product supports (PRD §7.3). ITF reads
/// count only as ITF-14.
String? acceptScannedValue(BarcodeFormat format, String? raw) {
  final code = digitsOnly(raw ?? '');
  return switch (format) {
    BarcodeFormat.ean8 when code.length == 8 => code,
    BarcodeFormat.ean13 when code.length == 13 => code,
    BarcodeFormat.upcA when code.length == 12 => code,
    // Some platforms report UPC-A as EAN-13 with a leading 0; keep as read.
    BarcodeFormat.itf14 when code.length == 14 => code,
    _ => null,
  };
}

/// Full-screen live scanner (EAN-8, EAN-13, UPC-A, ITF-14). Pops with the
/// first accepted code, or [ScannerDenied] when camera access is off.
class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  static Future<ScannerResult?> open(BuildContext context) => Navigator.of(context).push<ScannerResult>(
        MaterialPageRoute(fullscreenDialog: true, builder: (_) => const BarcodeScannerPage()),
      );

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.ean8, BarcodeFormat.ean13, BarcodeFormat.upcA, BarcodeFormat.itf14],
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final barcode in capture.barcodes) {
      final code = acceptScannedValue(barcode.format, barcode.rawValue);
      if (code != null) {
        _done = true;
        Navigator.of(context).pop(ScannedCode(code));
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: Strings.close,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(Strings.scannerTitle, style: TextStyle(color: Colors.white)),
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
        errorBuilder: (context, error) {
          if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_done && context.mounted) {
                _done = true;
                Navigator.of(context).pop(const ScannerDenied());
              }
            });
          }
          return const Center(
            child: Padding(padding: EdgeInsets.all(AppSizes.gutter), child: CameraDeniedNotice(onDark: true)),
          );
        },
        overlayBuilder: (context, constraints) => const _Reticle(),
      ),
    );
  }
}

class _Reticle extends StatelessWidget {
  const _Reticle();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 280,
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accent, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            Strings.scannerHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
