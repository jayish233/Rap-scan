import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:learn/data/local_barcodes_store.dart';
import 'package:learn/features/scan/widgets/barcode_scanner_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() => SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty());

  test('saves under rapscanz.localBarcodes.v1 with the web shape', () async {
    final store = LocalBarcodesStore(SharedPreferencesAsync());
    await store.save('2000000123455', LocalItem(name: 'Loose almonds', price: '₹180', savedAt: DateTime.utc(2026, 10, 22)));
    final raw = await SharedPreferencesAsync().getString('rapscanz.localBarcodes.v1');
    expect(jsonDecode(raw!), {
      '2000000123455': {'name': 'Loose almonds', 'price': '₹180', 'savedAt': '2026-10-22T00:00:00.000Z'},
    });
  });

  test('survives a new store instance (app restart) and removes per code', () async {
    await LocalBarcodesStore(SharedPreferencesAsync())
        .save('20000001', LocalItem(name: 'Bread', weight: '400 g', savedAt: DateTime.now()));
    await LocalBarcodesStore(SharedPreferencesAsync())
        .save('20000002', LocalItem(name: 'Paneer', savedAt: DateTime.now()));

    final reopened = LocalBarcodesStore(SharedPreferencesAsync());
    expect((await reopened.get('20000001'))!.weight, '400 g');
    await reopened.remove('20000001');
    expect(await reopened.get('20000001'), isNull);
    expect((await reopened.get('20000002'))!.name, 'Paneer');
  });

  test('corrupt storage is treated as empty', () async {
    await SharedPreferencesAsync().setString('rapscanz.localBarcodes.v1', '{not json');
    expect(await LocalBarcodesStore(SharedPreferencesAsync()).get('20000001'), isNull);
  });

  test('scanner accepts EAN-8/13, UPC-A, ITF-14 only', () {
    expect(acceptScannedValue(BarcodeFormat.ean13, '8901058851298'), '8901058851298');
    expect(acceptScannedValue(BarcodeFormat.ean8, '96385074'), '96385074');
    expect(acceptScannedValue(BarcodeFormat.upcA, '036000291452'), '036000291452');
    expect(acceptScannedValue(BarcodeFormat.itf14, '10012345678902'), '10012345678902');
    expect(acceptScannedValue(BarcodeFormat.itf14, '123456'), isNull);
    expect(acceptScannedValue(BarcodeFormat.qrCode, '8901058851298'), isNull);
    expect(acceptScannedValue(BarcodeFormat.ean13, null), isNull);
  });
}
