// Phase 3 gate, photo half (CLAUDE.md; PRD §14.7). Needs the live model.
//   flutter test integration_test/phase3_gate_test.dart \
//     --dart-define-from-file=config/local.json -d <simulator>
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:learn/data/photo_service.dart';
import 'package:learn/features/scan/scan_controller.dart';
import 'package:learn/features/scan/scan_screen.dart';
import 'package:learn/l10n/strings.dart';

import 'gate_helpers.dart';

/// Renders a plain label image with [lines] of large black text.
Future<Uint8List> renderLabel(List<String> lines) async {
  const width = 1200.0, lineHeight = 110.0;
  final height = 120 + lines.length * lineHeight;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..drawRect(Rect.fromLTWH(0, 0, width, height), Paint()..color = Colors.white);
  for (final (i, line) in lines.indexed) {
    TextPainter(
      text: TextSpan(text: line, style: const TextStyle(color: Colors.black, fontSize: 64, fontWeight: FontWeight.w600)),
      textDirection: TextDirection.ltr,
    )
      ..layout(maxWidth: width - 80)
      ..paint(canvas, Offset(40, 60 + i * lineHeight));
  }
  final image = await recorder.endRecording().toImage(width.toInt(), height.toInt());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('photo → barcode, photo → image analysis, > 5 MB rejected', (tester) async {
    await launchSignedIn(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(ScanScreen)));
    final scan = container.read(scanControllerProvider.notifier);
    final chipBefore = chipText(tester);

    // §14.7 Over 5 MB rejected on device.
    await tapVisible(tester, find.text(Strings.modePhoto));
    await tester.pumpAndSettle();
    scan.setPhoto(PickedPhoto(bytes: Uint8List(maxPhotoBytes + 1), name: 'huge.jpg'));
    await pumpUntil(tester, find.text(Strings.oversizeImage));
    expect(find.byTooltip(Strings.removePhoto), findsNothing);
    expect(chipText(tester), chipBefore);

    // §14.7 Label photo with a barcode → analysed exactly like the barcode.
    scan.setPhoto(PickedPhoto(
      bytes: await tester.runAsync(() => renderLabel(['MAGGI 2-Minute Noodles Masala', 'Net Wt. 70 g   MRP Rs. 14', '8 901058 851298'])) as Uint8List,
      name: 'barcode.png',
    ));
    await pumpUntil(tester, find.byTooltip(Strings.removePhoto));
    await tapVisible(tester, find.text(Strings.scanButton));
    await pumpUntil(tester, find.text(Strings.photoBarcodeToast));
    await pumpUntil(tester, find.text('Maggi Noodles Masala 70Grm Pc'));

    // §14.7 Label photo without a barcode → the model reads the label image.
    await tester.pump(const Duration(seconds: 5)); // let the toast clear
    await tapVisible(tester, find.text(Strings.startOver));
    await tester.pumpAndSettle();
    expect(find.text('Maggi Noodles Masala 70Grm Pc'), findsNothing);
    scan.setPhoto(PickedPhoto(
      bytes: await tester.runAsync(() => renderLabel([
            'ROASTED MAKHANA - Himalayan Salt',
            'Ingredients: Fox nuts (makhana) 92%,',
            'rice bran oil, Himalayan pink salt,',
            'black pepper.',
          ])) as Uint8List,
      name: 'label.png',
    ));
    await pumpUntil(tester, find.byTooltip(Strings.removePhoto));
    await tapVisible(tester, find.text(Strings.scanButton));
    await pumpUntil(tester, find.text(Strings.scanCompleteToast));
    await pumpUntil(tester, find.textContaining(RegExp('makhana', caseSensitive: false)));
    expect(find.text(Strings.summaryTitle), findsOneWidget);
    expect(find.text(Strings.cautionsTitle), findsOneWidget);
  });
}
