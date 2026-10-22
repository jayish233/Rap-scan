import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn/app/session.dart';
import 'package:learn/app/theme.dart';
import 'package:learn/data/history_repository.dart';
import 'package:learn/data/local_barcodes_store.dart';
import 'package:learn/data/photo_service.dart';
import 'package:learn/data/profile_repository.dart';
import 'package:learn/data/scan_api.dart';
import 'package:learn/domain/plan.dart';
import 'package:learn/domain/rating.dart';
import 'package:learn/domain/scan_failure.dart';
import 'package:learn/domain/scan_result.dart';
import 'package:learn/features/scan/scan_screen.dart';
import 'package:learn/l10n/strings.dart';
import 'package:mocktail/mocktail.dart';

class MockScanApi extends Mock implements ScanApi {}

class _FakeRequest extends Fake implements ScanRequest {}

/// In-memory stand-in for the on-device inventory.
class MemoryLocalStore implements LocalBarcodesStore {
  final items = <String, LocalItem>{};
  @override
  Future<LocalItem?> get(String barcode) async => items[barcode];
  @override
  Future<void> save(String barcode, LocalItem item) async => items[barcode] = item;
  @override
  Future<void> remove(String barcode) async => items.remove(barcode);
}

/// Photo service that returns a canned picked photo.
class FakePhotoService implements PhotoService {
  PickedPhoto? next;
  bool deny = false;
  String? lastUploaded;
  @override
  Future<PickedPhoto?> pick(PhotoSource source) async {
    if (deny) throw const PhotoAccessDenied();
    return next;
  }

  @override
  Future<String> toUploadDataUrl(PickedPhoto photo) async => lastUploaded = 'data:image/jpeg;base64,QUJD';
}

late MemoryLocalStore localStore;
late FakePhotoService photos;

Quota quota({int remaining = 30, String plan = 'free', bool unlimited = false}) => Quota(
      remaining: remaining,
      scanLimit: 30,
      plan: plan,
      planLabel: plan == 'free' ? 'Free' : 'Pro+',
      isUnlimited: unlimited,
    );

ScanOutcome outcome({String plan = 'free'}) => ScanOutcome(
      scanId: 'scan-1',
      source: ScanSource.ingredients,
      quota: quota(remaining: 29, plan: plan),
      result: ScanResult(
        productName: 'Chocolate cream biscuit',
        brand: 'Bourbon',
        parentCompany: 'Britannia Industries',
        category: 'Cream-filled biscuit',
        rating: Rating.caution,
        healthScore: 31,
        caloriesKcal: 160,
        summary: 'Ultra-processed biscuit high in sugar and palm fat.',
        advantages: const ['Quick energy'],
        disadvantages: const ['High sugar'],
        cautions: const [
          Caution(
            ingredient: 'Sugar',
            concern: 'Adds a lot of free sugar.',
            severity: Severity.high,
            percentage: '~35%',
            chemicalFormula: 'C12H22O11',
            scientificName: 'Sucrose',
          ),
        ],
        personalAdvice: 'You listed diabetes; keep this occasional.',
      ),
    );

Future<MockScanApi> pumpScan(WidgetTester tester, {Quota? initialQuota}) async {
  final api = MockScanApi();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue('u1'),
        scanApiProvider.overrideWithValue(api),
        quotaProvider.overrideWith((ref) async => initialQuota ?? quota()),
        historyProvider.overrideWith((ref) async => const Cached(<ScanSummary>[])),
        localBarcodesStoreProvider.overrideWithValue(localStore),
        photoServiceProvider.overrideWithValue(photos),
      ],
      child: MaterialApp(theme: buildAppTheme(), home: const ScanScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return api;
}

Future<void> tapScan(WidgetTester tester) async {
  await tester.tap(find.text(Strings.scanButton));
  await tester.pumpAndSettle();
}

Future<void> switchToBarcode(WidgetTester tester) async {
  await tester.tap(find.text(Strings.modeBarcode));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => registerFallbackValue(_FakeRequest()));
  setUp(() {
    localStore = MemoryLocalStore();
    photos = FakePhotoService();
  });

  testWidgets('text scan happy path shows the result blocks and a toast', (tester) async {
    final api = await pumpScan(tester);
    when(() => api.analyze(any())).thenAnswer((_) async => outcome());

    await tester.enterText(find.byType(TextField), 'sugar, wheat flour, palm oil');
    await tapScan(tester);

    final request = verify(() => api.analyze(captureAny())).captured.single as ScanRequest;
    expect(request.toJson(), {'scanType': 'ingredients', 'text': 'sugar, wheat flour, palm oil'});
    expect(find.text(Strings.scanCompleteToast), findsOneWidget);
    expect(find.text('Chocolate cream biscuit'), findsOneWidget);
    expect(find.text(Strings.ratingCaution), findsOneWidget);
    expect(find.text('Bourbon · by Britannia Industries · Cream-filled biscuit'), findsOneWidget);
    expect(find.text(Strings.caloriesLine(160)), findsOneWidget);
    expect(find.text('You listed diabetes; keep this occasional.'), findsOneWidget);
    expect(find.text(Strings.cautionsTitle), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Health score 31 out of 100, Eat rarely')), findsOneWidget);
    expect(find.text(Strings.disclaimer), findsOneWidget);
  });

  testWidgets('free plan hides % and formula even when the payload has them', (tester) async {
    final api = await pumpScan(tester);
    when(() => api.analyze(any())).thenAnswer((_) async => outcome(plan: 'free'));
    await tester.enterText(find.byType(TextField), 'sugar');
    await tapScan(tester);
    expect(find.textContaining('~35%'), findsNothing);
    expect(find.textContaining('C12H22O11'), findsNothing);
  });

  testWidgets('Pro+ sees % and formula', (tester) async {
    final api = await pumpScan(tester);
    when(() => api.analyze(any())).thenAnswer((_) async => outcome(plan: 'pro_plus'));
    await tester.enterText(find.byType(TextField), 'sugar');
    await tapScan(tester);
    expect(find.textContaining('~35%'), findsOneWidget);
    expect(find.textContaining('C12H22O11'), findsOneWidget);
  });

  testWidgets('empty text: verbatim error, no server call', (tester) async {
    final api = await pumpScan(tester);
    await tapScan(tester);
    expect(find.text(Strings.emptyTextError), findsOneWidget);
    verifyNever(() => api.analyze(any()));
  });

  testWidgets('bad check digit: verbatim error, no server call (PRD §14.4)', (tester) async {
    final api = await pumpScan(tester);
    await switchToBarcode(tester);
    await tester.enterText(find.byType(TextField), '8901058851299');
    await tapScan(tester);
    expect(find.text(Strings.invalidBarcode), findsOneWidget);
    verifyNever(() => api.analyze(any()));
  });

  testWidgets('barcode field strips non-digits as the user types', (tester) async {
    await pumpScan(tester);
    await switchToBarcode(tester);
    await tester.enterText(find.byType(TextField), '8901 0588-51298');
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '8901058851298');
  });

  testWidgets('in-store code: no server call, add dialog saves on device (PRD §14.6)', (tester) async {
    final api = await pumpScan(tester);
    await switchToBarcode(tester);
    await tester.enterText(find.byKey(const ValueKey('scan-barcode-field')), '2000000123455');
    await tapScan(tester);
    verifyNever(() => api.analyze(any()));

    // Unknown code → dialog opens; name is required.
    expect(find.text(Strings.localAddTitle), findsOneWidget);
    await tester.tap(find.text(Strings.save));
    await tester.pumpAndSettle();
    expect(find.text(Strings.localNameRequired), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('local-name')), 'Loose almonds');
    await tester.enterText(find.byKey(const ValueKey('local-price')), '₹180');
    await tester.enterText(find.byKey(const ValueKey('local-weight')), '250 g');
    await tester.tap(find.text(Strings.save));
    await tester.pumpAndSettle();

    expect(localStore.items['2000000123455']!.name, 'Loose almonds');
    expect(find.text('Loose almonds'), findsOneWidget);
    expect(find.text('₹180 · 250 g'), findsOneWidget);
    expect(find.text(Strings.localSavedCard), findsOneWidget);
  });

  testWidgets('known in-store code shows the saved card, no dialog; remove deletes it', (tester) async {
    localStore.items['20000001'] = LocalItem(name: 'Store bread', savedAt: DateTime(2026, 10, 1));
    final api = await pumpScan(tester);
    await switchToBarcode(tester);
    await tester.enterText(find.byKey(const ValueKey('scan-barcode-field')), '20000001');
    await tapScan(tester);
    expect(find.text(Strings.localAddTitle), findsNothing);
    expect(find.text('Store bread'), findsOneWidget);
    expect(find.text(Strings.localSavedCard), findsOneWidget);

    await tester.ensureVisible(find.text(Strings.localRemove));
    await tester.tap(find.text(Strings.localRemove));
    await tester.pumpAndSettle();
    expect(localStore.items, isEmpty);
    expect(find.text(Strings.localAddButton), findsOneWidget);
    verifyNever(() => api.analyze(any()));
  });

  testWidgets('in-store lookup still works at zero scans', (tester) async {
    localStore.items['20000001'] = LocalItem(name: 'Store bread', savedAt: DateTime(2026, 10, 1));
    await pumpScan(tester, initialQuota: quota(remaining: 0));
    await switchToBarcode(tester);
    await tester.enterText(find.byKey(const ValueKey('scan-barcode-field')), '20000001');
    await tester.testTextInput.receiveAction(TextInputAction.go);
    await tester.pumpAndSettle();
    expect(find.text('Store bread'), findsOneWidget);
  });

  group('photo mode', () {
    Future<void> switchToPhoto(WidgetTester tester) async {
      await tester.tap(find.text(Strings.modePhoto));
      await tester.pumpAndSettle();
    }

    PickedPhoto photoOf(int bytes) => PickedPhoto(bytes: Uint8List(bytes), name: 'label.jpg');

    testWidgets('over 5 MB is rejected on device (PRD §14.7)', (tester) async {
      final api = await pumpScan(tester);
      await switchToPhoto(tester);
      photos.next = photoOf(maxPhotoBytes + 1);
      await tester.tap(find.text(Strings.chooseFromLibrary));
      await tester.pumpAndSettle();
      expect(find.text(Strings.oversizeImage), findsOneWidget);
      expect(find.byTooltip(Strings.removePhoto), findsNothing);
      verifyNever(() => api.analyze(any()));
    });

    testWidgets('preview + remove; submit uploads the compressed data URL', (tester) async {
      final api = await pumpScan(tester);
      when(() => api.analyze(any())).thenAnswer((_) async => outcome());
      await switchToPhoto(tester);
      // Scan is disabled until a photo is chosen.
      final button = find.ancestor(of: find.text(Strings.scanButton), matching: find.bySubtype<ButtonStyleButton>());
      expect(tester.widget<ButtonStyleButton>(button).onPressed, isNull);

      photos.next = photoOf(1024);
      await tester.tap(find.text(Strings.takePhoto));
      await tester.pumpAndSettle();
      expect(find.byTooltip(Strings.removePhoto), findsOneWidget);
      await tester.tap(find.byTooltip(Strings.removePhoto));
      await tester.pumpAndSettle();
      expect(find.byTooltip(Strings.removePhoto), findsNothing);

      await tester.tap(find.text(Strings.takePhoto));
      await tester.pumpAndSettle();
      await tapScan(tester);
      final request = verify(() => api.analyze(captureAny())).captured.single as ScanRequest;
      expect(request.toJson(), {'scanType': 'ingredients', 'imageDataUrl': 'data:image/jpeg;base64,QUJD'});
      expect(find.text('Chocolate cream biscuit'), findsOneWidget);
    });

    testWidgets('photo resolved to a barcode shows the photo toast', (tester) async {
      final api = await pumpScan(tester);
      when(() => api.analyze(any())).thenAnswer((_) async {
        final o = outcome();
        return ScanOutcome(result: o.result, scanId: o.scanId, quota: o.quota, source: ScanSource.photoBarcode);
      });
      await switchToPhoto(tester);
      photos.next = photoOf(1024);
      await tester.tap(find.text(Strings.takePhoto));
      await tester.pumpAndSettle();
      await tapScan(tester);
      expect(find.text(Strings.photoBarcodeToast), findsOneWidget);
    });

    testWidgets('in-store code read from photo → toast + local flow', (tester) async {
      final api = await pumpScan(tester);
      when(() => api.analyze(any())).thenThrow(const LocalBarcode('2000000123455', fromPhoto: true));
      await switchToPhoto(tester);
      photos.next = photoOf(1024);
      await tester.tap(find.text(Strings.takePhoto));
      await tester.pumpAndSettle();
      await tapScan(tester);
      expect(find.text(Strings.localBarcodeFromPhoto('2000000123455')), findsOneWidget);
      expect(find.text(Strings.localAddTitle), findsOneWidget);
    });

    testWidgets('camera denied: explainer, paste and manual entry still work', (tester) async {
      await pumpScan(tester);
      await switchToPhoto(tester);
      photos.deny = true;
      await tester.tap(find.text(Strings.takePhoto));
      await tester.pumpAndSettle();
      expect(find.text(Strings.cameraDeniedTitle), findsOneWidget);
      await tester.tap(find.text(Strings.modeText));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('scan-text-field')), findsOneWidget);
      await switchToBarcode(tester);
      expect(find.byKey(const ValueKey('scan-barcode-field')), findsOneWidget);
      expect(find.text(Strings.cameraDeniedTitle), findsOneWidget);
    });
  });

  testWidgets('valid barcode is sent; registry miss shows verbatim copy (PRD §14.5)', (tester) async {
    final api = await pumpScan(tester);
    when(() => api.analyze(any())).thenThrow(const RegistryMiss('8906000000007'));
    await switchToBarcode(tester);
    await tester.enterText(find.byType(TextField), '8906000000007');
    await tapScan(tester);
    final request = verify(() => api.analyze(captureAny())).captured.single as ScanRequest;
    expect(request.toJson(), {'scanType': 'barcode', 'barcode': '8906000000007'});
    expect(find.text(Strings.registryMiss('8906000000007')), findsOneWidget);
  });

  testWidgets('each server failure shows its verbatim toast', (tester) async {
    final api = await pumpScan(tester);
    for (final failure in <ScanFailure>[
      const RateLimited(),
      const AiUnavailable(),
      const AiCreditsExhausted(),
      const NetworkDown(),
    ]) {
      when(() => api.analyze(any())).thenThrow(failure);
      await tester.enterText(find.byType(TextField), 'sugar');
      await tapScan(tester);
      expect(find.text(failure.message), findsOneWidget, reason: failure.runtimeType.toString());
    }
  });

  testWidgets('zero remaining: button disabled and upgrade card shown', (tester) async {
    final api = await pumpScan(tester, initialQuota: quota(remaining: 0));
    expect(find.text(Strings.quotaExhausted), findsOneWidget);
    final button = tester.widget<ButtonStyleButton>(
      find.ancestor(of: find.text(Strings.scanButton), matching: find.bySubtype<ButtonStyleButton>()),
    );
    expect(button.onPressed, isNull);
    verifyNever(() => api.analyze(any()));
  });

  testWidgets('a second barcode replaces the first and is validated on its own', (tester) async {
    final api = await pumpScan(tester);
    when(() => api.analyze(any())).thenAnswer((_) async => outcome());
    await switchToBarcode(tester);
    final field = find.byKey(const ValueKey('scan-barcode-field'));
    await tester.enterText(field, '8901058851298');
    await tapScan(tester);
    // The result scrolled into view; bring the input back like a user would.
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    await tester.enterText(field, '8901058851299');
    await tester.ensureVisible(find.text(Strings.scanButton));
    await tapScan(tester);
    expect(tester.widget<TextField>(field).controller!.text, '8901058851299');
    expect(find.text(Strings.invalidBarcode), findsOneWidget);
    verify(() => api.analyze(any())).called(1);
  });

  testWidgets('New scan clears the result and returns to the input', (tester) async {
    final api = await pumpScan(tester);
    when(() => api.analyze(any())).thenAnswer((_) async => outcome());
    await tester.enterText(find.byType(TextField), 'sugar');
    await tapScan(tester);
    await tester.pump(const Duration(seconds: 5)); // let the toast clear
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(Strings.startOver));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.startOver));
    await tester.pumpAndSettle();
    expect(find.text('Chocolate cream biscuit'), findsNothing);
    expect(find.text(Strings.scanButton).hitTestable(), findsOneWidget);
  });
}
