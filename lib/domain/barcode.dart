/// On-device barcode pre-flight (PRD §7.3, §7.5; architecture.md §2.4.1).
/// Pure Dart. Validation failures never reach the server, so they never
/// spend a credit.
library;

const validBarcodeLengths = {8, 12, 13, 14};

String digitsOnly(String input) => input.replaceAll(RegExp(r'\D'), '');

/// GS1 mod-10 check digit over the full code (last digit is the check).
bool hasValidCheckDigit(String code) {
  if (!RegExp(r'^\d+$').hasMatch(code) || !validBarcodeLengths.contains(code.length)) return false;
  final digits = code.split('').map(int.parse).toList();
  final check = digits.removeLast();
  var sum = 0;
  var weight = 3;
  for (var i = digits.length - 1; i >= 0; i--) {
    sum += digits[i] * weight;
    weight = weight == 3 ? 1 : 3;
  }
  return (10 - sum % 10) % 10 == check;
}

/// GS1 restricted-circulation / in-store codes: prefix 2, 8–14 digits.
bool isInStoreCode(String code) => RegExp(r'^2\d{7,13}$').hasMatch(code);

sealed class BarcodeCheck {
  const BarcodeCheck(this.code);
  final String code;
}

/// Send to the server for registry lookup.
final class BarcodeSendable extends BarcodeCheck {
  const BarcodeSendable(super.code);
}

/// In-store code → local inventory, no server call, no credit.
final class BarcodeInStore extends BarcodeCheck {
  const BarcodeInStore(super.code);
}

/// Bad length or check digit → verbatim error, no server call, no credit.
final class BarcodeInvalid extends BarcodeCheck {
  const BarcodeInvalid(super.code);
}

BarcodeCheck checkBarcode(String input) {
  final code = digitsOnly(input);
  if (isInStoreCode(code)) return BarcodeInStore(code);
  if (hasValidCheckDigit(code)) return BarcodeSendable(code);
  // architecture.md §2.4.1: a 12-digit UPC failing validation is still sent;
  // the server retries it as EAN-13 with a leading 0 (and rejects it there,
  // before quota, if it is still invalid).
  if (code.length == 12) return BarcodeSendable(code);
  return BarcodeInvalid(code);
}
