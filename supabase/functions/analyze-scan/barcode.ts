// GS1 barcode helpers (PRD §7.3, §7.5, §10 step 5). Pure functions.

export const VALID_LENGTHS = [8, 12, 13, 14] as const;

export function digitsOnly(input: string): string {
  return input.replace(/\D/g, "");
}

/** GS1 mod-10 check digit over the full code (last digit is the check). */
export function hasValidCheckDigit(code: string): boolean {
  if (!/^\d+$/.test(code) || !(VALID_LENGTHS as readonly number[]).includes(code.length)) {
    return false;
  }
  const digits = code.split("").map(Number);
  const check = digits.pop()!;
  let sum = 0;
  // Weights alternate 3,1 starting from the digit next to the check digit.
  for (let i = digits.length - 1, w = 3; i >= 0; i--, w = w === 3 ? 1 : 3) {
    sum += digits[i] * w;
  }
  return (10 - (sum % 10)) % 10 === check;
}

/** GS1 restricted-circulation / in-store codes: prefix 2, 8–14 digits. */
export function isInStoreCode(code: string): boolean {
  return /^2\d{7,13}$/.test(code);
}

/** UPC-A is EAN-13 with a leading 0; use the 13-digit form as the cache key. */
export function canonicalBarcode(code: string): string {
  return code.length === 12 ? `0${code}` : code;
}

/** Registry lookup candidates: the code itself, then the leading-0 retry for UPC-A. */
export function lookupCandidates(code: string): string[] {
  return code.length === 12 ? [code, `0${code}`] : [code];
}

const GS1_COUNTRY_PREFIXES: Array<[number, number, string]> = [
  [0, 139, "USA / Canada"],
  [300, 379, "France"],
  [400, 440, "Germany"],
  [450, 459, "Japan"],
  [490, 499, "Japan"],
  [500, 509, "United Kingdom"],
  [690, 699, "China"],
  [760, 769, "Switzerland"],
  [800, 839, "Italy"],
  [840, 849, "Spain"],
  [870, 879, "Netherlands"],
  [880, 880, "South Korea"],
  [885, 885, "Thailand"],
  [888, 888, "Singapore"],
  [890, 890, "India"],
  [893, 893, "Vietnam"],
  [896, 896, "Pakistan"],
  [899, 899, "Indonesia"],
  [930, 939, "Australia"],
  [940, 949, "New Zealand"],
  [955, 955, "Malaysia"],
  [628, 628, "Saudi Arabia"],
  [629, 629, "United Arab Emirates"],
];

/** Country-of-issue hint only. Never used to infer a brand (PRD §10). */
export function gs1CountryHint(code: string): string | null {
  const canonical = canonicalBarcode(code);
  if (canonical.length < 13) return null;
  const prefix = Number(canonical.slice(0, 3));
  for (const [from, to, country] of GS1_COUNTRY_PREFIXES) {
    if (prefix >= from && prefix <= to) return country;
  }
  return null;
}

// Keywords that mark a nearby digit run as something other than a barcode.
const NON_BARCODE_BEFORE =
  /(mrp|m\.r\.p|rs\.?|inr|₹|\$|price|batch|b\.?\s?no|lot|mfg|mfd|manufactured|pkd|packed|exp|expiry|best before|use by|bb|date|tel|ph|phone|mobile|call|care|toll|fax|helpline|fssai|lic|licen[cs]e|reg|net\s?wt|net\s?weight|net\s?qty|weight|wt)\W{0,6}$/i;
const NON_BARCODE_AFTER = /^\s?(g|gm|gms|kg|mg|ml|l|ltr|litre|liter|oz|lb|kcal|cal|%)\b/i;

/**
 * Pick a barcode from OCR text (PRD §10 step 5): digit runs of 8–14 (allowing
 * single spaces/hyphens between groups), ignoring dates, prices, batch codes,
 * phone numbers, licence numbers and weights. Keeps the first candidate with a
 * valid check digit, preferring length 13, then 12, then 14, then 8.
 */
export function extractBarcodeFromText(text: string): string | null {
  const runs = /\d(?:[ -]?\d){7,16}/g;
  const valid: Array<{ code: string; index: number }> = [];
  for (const match of text.matchAll(runs)) {
    const index = match.index ?? 0;
    const raw = match[0];
    const before = text.slice(Math.max(0, index - 24), index);
    const after = text.slice(index + raw.length, index + raw.length + 8);
    if (NON_BARCODE_BEFORE.test(before) || NON_BARCODE_AFTER.test(after)) continue;
    // Dates like 12-2025 or 01 01 2025 never contain a valid 8+ digit code;
    // a separator of '/' or '.' already breaks the run.
    const code = digitsOnly(raw);
    if (code.length < 8 || code.length > 14) continue;
    if (hasValidCheckDigit(code)) valid.push({ code, index });
  }
  for (const length of [13, 12, 14, 8]) {
    const hit = valid.find((v) => v.code.length === length);
    if (hit) return hit.code;
  }
  return null;
}
