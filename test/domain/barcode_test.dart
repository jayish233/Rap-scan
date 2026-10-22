import 'package:flutter_test/flutter_test.dart';
import 'package:learn/domain/barcode.dart';

void main() {
  test('GS1 check digit: valid EAN-13, UPC-A, EAN-8, ITF-14', () {
    for (final code in ['8901058851298', '4006381333931', '036000291452', '96385074', '10012345678902']) {
      expect(hasValidCheckDigit(code), isTrue, reason: code);
    }
  });

  test('GS1 check digit: bad digit, bad length, non-digits', () {
    for (final code in ['8901058851299', '036000291453', '123456789', '', '89010588512a8']) {
      expect(hasValidCheckDigit(code), isFalse, reason: code);
    }
  });

  test('digitsOnly strips spaces and separators', () {
    expect(digitsOnly(' 8 901058-851298 '), '8901058851298');
  });

  test('in-store detector: ^2\\d{7,13}\$', () {
    expect(isInStoreCode('20000001'), isTrue);
    expect(isInStoreCode('2000000123455'), isTrue);
    expect(isInStoreCode('2000000'), isFalse);
    expect(isInStoreCode('200000012345678'), isFalse);
    expect(isInStoreCode('8901058851298'), isFalse);
  });

  group('checkBarcode', () {
    test('valid code is sendable, digits stripped', () {
      final c = checkBarcode('8901 0588 51298');
      expect(c, isA<BarcodeSendable>());
      expect(c.code, '8901058851298');
    });

    test('bad check digit never reaches the server', () {
      expect(checkBarcode('8901058851299'), isA<BarcodeInvalid>());
      expect(checkBarcode('12345'), isA<BarcodeInvalid>());
      expect(checkBarcode(''), isA<BarcodeInvalid>());
    });

    test('in-store wins over validation, so no credit is spent', () {
      expect(checkBarcode('2000000123455'), isA<BarcodeInStore>());
      expect(checkBarcode('2000000123456'), isA<BarcodeInStore>()); // bad check digit, still local
    });

    test('12-digit UPC failing locally is still sent (server retries with leading 0)', () {
      expect(checkBarcode('036000291453'), isA<BarcodeSendable>());
    });
  });
}
