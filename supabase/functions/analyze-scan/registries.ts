// Food registries (PRD §10 step 8): Open Food Facts v2, then UPCitemdb.

import type { Nutriments, RegistryProduct } from "./types.ts";

const USER_AGENT = "RAPscanz/1.0 (https://rapscanz.app)";
const TIMEOUT_MS = 8000;

const OFF_FIELDS = [
  "product_name",
  "product_name_en",
  "product_name_hi",
  "brands",
  "brand_owner",
  "categories",
  "quantity",
  "nutriments",
  "labels",
  "ingredients_text",
  "ingredients_text_en",
  "ingredients_text_hi",
].join(",");

function clean(value: unknown): string | undefined {
  if (typeof value !== "string") return undefined;
  const trimmed = value.trim();
  return trimmed === "" ? undefined : trimmed;
}

/** Most specific entry of a general→specific list ("Snacks, Biscuits" → "Biscuits"). */
function lastSegment(value: string | undefined, separator: RegExp): string | undefined {
  if (!value) return undefined;
  const parts = value.split(separator).map((p) => p.trim()).filter(Boolean);
  return parts.length ? parts[parts.length - 1].replace(/^[a-z]{2}:/, "") : undefined;
}

/** Keep only per-100 g numeric nutriments; that is all the rule engine reads. */
function per100g(nutriments: Record<string, unknown> | undefined): Nutriments | undefined {
  if (!nutriments) return undefined;
  const out: Nutriments = {};
  for (const [key, value] of Object.entries(nutriments)) {
    if (key.endsWith("_100g") && typeof value === "number" && Number.isFinite(value)) out[key] = value;
  }
  return Object.keys(out).length ? out : undefined;
}

async function getJson(url: string, fetchImpl: typeof fetch): Promise<unknown | null> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), TIMEOUT_MS);
  try {
    const res = await fetchImpl(url, {
      headers: { "User-Agent": USER_AGENT, Accept: "application/json" },
      signal: controller.signal,
    });
    if (!res.ok) {
      await res.body?.cancel();
      return null;
    }
    return await res.json();
  } catch {
    return null;
  } finally {
    clearTimeout(timer);
  }
}

export async function lookupOpenFoodFacts(
  code: string,
  fetchImpl: typeof fetch = fetch,
): Promise<RegistryProduct | null> {
  const body = await getJson(
    `https://world.openfoodfacts.org/api/v2/product/${encodeURIComponent(code)}.json?fields=${OFF_FIELDS}`,
    fetchImpl,
  ) as { status?: number; product?: Record<string, unknown> } | null;
  const p = body?.product;
  if (!body || body.status !== 1 || !p) return null;

  const productName = clean(p.product_name) ?? clean(p.product_name_en) ?? clean(p.product_name_hi);
  const brand = clean(p.brands)?.split(",")[0].trim();
  if (!productName && !brand) return null;

  const ingredients = [clean(p.ingredients_text_en) ?? clean(p.ingredients_text), clean(p.ingredients_text_hi)]
    .filter(Boolean)
    .join("\n");

  return {
    source: "openfoodfacts",
    barcode: code,
    productName,
    brand,
    parentCompany: clean(p.brand_owner),
    category: lastSegment(clean(p.categories), /,/),
    quantity: clean(p.quantity),
    labels: clean(p.labels),
    ingredientsText: ingredients || undefined,
    nutriments: per100g(p.nutriments as Record<string, unknown> | undefined),
  };
}

export async function lookupUpcItemDb(
  code: string,
  fetchImpl: typeof fetch = fetch,
): Promise<RegistryProduct | null> {
  const body = await getJson(
    `https://api.upcitemdb.com/prod/trial/lookup?upc=${encodeURIComponent(code)}`,
    fetchImpl,
  ) as { items?: Array<Record<string, unknown>> } | null;
  const item = body?.items?.[0];
  if (!item) return null;
  const productName = clean(item.title);
  if (!productName) return null;
  return {
    source: "upcitemdb",
    barcode: code,
    productName,
    brand: clean(item.brand),
    category: lastSegment(clean(item.category), />/),
  };
}
