import { assertEquals } from "jsr:@std/assert@1";
import {
  canonicalBarcode,
  extractBarcodeFromText,
  gs1CountryHint,
  hasValidCheckDigit,
  isInStoreCode,
  lookupCandidates,
} from "./barcode.ts";

Deno.test("check digit: valid EAN-13, UPC-A, EAN-8, ITF-14", () => {
  assertEquals(hasValidCheckDigit("4006381333931"), true);
  assertEquals(hasValidCheckDigit("8901063010307"), true);
  assertEquals(hasValidCheckDigit("036000291452"), true);
  assertEquals(hasValidCheckDigit("96385074"), true);
  assertEquals(hasValidCheckDigit("10012345678902"), true);
});

Deno.test("check digit: rejects bad digit and bad lengths", () => {
  assertEquals(hasValidCheckDigit("4006381333932"), false);
  assertEquals(hasValidCheckDigit("036000291453"), false);
  assertEquals(hasValidCheckDigit("123456789"), false);
  assertEquals(hasValidCheckDigit("40063813339a1"), false);
});

Deno.test("UPC-A as EAN-13 with leading 0 stays valid", () => {
  assertEquals(canonicalBarcode("036000291452"), "0036000291452");
  assertEquals(hasValidCheckDigit("0036000291452"), true);
  assertEquals(lookupCandidates("036000291452"), ["036000291452", "0036000291452"]);
  assertEquals(lookupCandidates("8901063010307"), ["8901063010307"]);
});

Deno.test("in-store detector: prefix 2, 8–14 digits", () => {
  assertEquals(isInStoreCode("2000000123455"), true);
  assertEquals(isInStoreCode("20000001"), true);
  assertEquals(isInStoreCode("2000000"), false);
  assertEquals(isInStoreCode("8901063010307"), false);
});

Deno.test("GS1 country hint: India is 890, hint only", () => {
  assertEquals(gs1CountryHint("8901063010307"), "India");
  assertEquals(gs1CountryHint("036000291452"), "USA / Canada");
  assertEquals(gs1CountryHint("96385074"), null);
});

Deno.test("OCR: picks the barcode and ignores MRP, dates, phones, weights, licences", () => {
  const label = [
    "PARLE-G Original Glucose Biscuits",
    "Net Wt. 80000001 g",
    "MRP Rs. 10000005",
    "MFG 20250131 EXP 20251031",
    "Customer care: 1800 2091 000",
    "FSSAI Lic. No. 10012345678902",
    "8 901063 010307",
  ].join("\n");
  assertEquals(extractBarcodeFromText(label), "8901063010307");
});

Deno.test("OCR: prefers 13 over 12 over 14 over 8 digits", () => {
  assertEquals(extractBarcodeFromText("96385074\n036000291452\n4006381333931"), "4006381333931");
  assertEquals(extractBarcodeFromText("96385074\n036000291452"), "036000291452");
  assertEquals(extractBarcodeFromText("96385074 and 10012345678902"), "10012345678902");
  assertEquals(extractBarcodeFromText("code 96385074"), "96385074");
});

Deno.test("OCR: no valid candidate returns null", () => {
  assertEquals(extractBarcodeFromText("Ingredients: wheat flour, sugar, edible oil"), null);
  assertEquals(extractBarcodeFromText("4006381333932"), null);
});
