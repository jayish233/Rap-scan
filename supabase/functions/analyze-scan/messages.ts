// Verbatim user copy from design.md §10. Do not paraphrase.

export const MESSAGES = {
  emptyText: "Paste the ingredient list first.",
  invalidBarcode:
    "Invalid or fake barcode. Real product barcodes are 8, 12, 13, or 14 digits with a valid check digit (EAN/UPC). Please re-enter or rescan.",
  registryMiss: (code: string) =>
    `Product not found in the Open Food Facts / GS1 registry for barcode ${code}. We don't guess product identity from barcode prefixes — please scan the label photo or paste the ingredients instead.`,
  quotaExceeded:
    "You've used all your scans for this cycle. Upgrade to Pro (₹200/mo · 60), Pro+ (₹500/mo · 120) or Pro Max (₹1200/mo · 240 + 3D body-damage map) to keep scanning.",
  rateLimited: "Too many scans right now. Please try again in a moment.",
  aiUnavailable: "The analysis service is temporarily unavailable. Please try again.",
  aiCreditsExhausted: "AI credits exhausted. Please contact the app owner.",
  oversizeImage: "Image must be under 5MB.",
  localBarcodeFromPhoto: (code: string) =>
    `Barcode ${code} read from photo — looks like a local/in-store item.`,
} as const;

export type ErrorCode =
  | "quota_exceeded"
  | "rate_limited"
  | "ai_unavailable"
  | "ai_credits_exhausted"
  | "registry_miss"
  | "invalid_barcode"
  | "validation"
  | "local_barcode"
  | "unauthorized";
