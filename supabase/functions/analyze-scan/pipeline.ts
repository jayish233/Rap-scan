// The analyze-scan pipeline (PRD §10, architecture.md §3.3). Every external
// dependency is injected so the ordering rules can be unit-tested.

import {
  canonicalBarcode,
  digitsOnly,
  extractBarcodeFromText,
  gs1CountryHint,
  hasValidCheckDigit,
  isInStoreCode,
  lookupCandidates,
} from "./barcode.ts";
import { type AnalysisModel, type Image, ModelError, parseDataUrl } from "./gemini.ts";
import { gateForPlan, normaliseResult, withoutPersonalAdvice } from "./gating.ts";
import { type ErrorCode, MESSAGES } from "./messages.ts";
import { computeOrganImpact, hasNutritionData, RULES_VERSION } from "./organImpact.ts";
import { healthContext } from "./prompt.ts";
import type { HealthProfile, QuotaInfo, QuotaResult, RegistryProduct, ScanResult } from "./types.ts";

export const MAX_TEXT_CHARS = 10_000;
export const MAX_IMAGE_DATA_URL_CHARS = 7_500_000;

export interface CachedAnalysis {
  analysis: ScanResult; // full tier, never personal advice
  ingredientsText?: string;
  registry?: RegistryProduct["source"];
  rulesVersion?: string;
}

export interface ScanRow {
  userId: string;
  productName: string;
  scanType: "ingredients" | "barcode";
  rating: string;
  healthScore: number;
  caloriesKcal: number;
  summary: string;
  inputText: string | null; // never a photo
  result: ScanResult;
}

export interface Store {
  consumeQuota(userId: string): Promise<QuotaResult>;
  loadHealthProfile(userId: string): Promise<HealthProfile | null>;
  getCachedAnalysis(barcode: string): Promise<CachedAnalysis | null>;
  putCachedAnalysis(barcode: string, entry: CachedAnalysis): Promise<void>;
  insertScan(row: ScanRow): Promise<string>;
}

export interface Registries {
  openFoodFacts(code: string): Promise<RegistryProduct | null>;
  upcItemDb(code: string): Promise<RegistryProduct | null>;
}

export interface Deps {
  store: Store;
  registries: Registries;
  model: AnalysisModel;
  log?: (message: string, extra?: Record<string, unknown>) => void;
}

export interface PipelineResponse {
  status: number;
  body: Record<string, unknown>;
}

export type ScanSource = "ingredients" | "image" | "barcode" | "photo_barcode";

const STATUS: Record<ErrorCode, number> = {
  validation: 400,
  invalid_barcode: 400,
  unauthorized: 401,
  quota_exceeded: 402,
  registry_miss: 404,
  local_barcode: 422,
  rate_limited: 429,
  ai_unavailable: 503,
  ai_credits_exhausted: 503,
};

function failure(error: ErrorCode, message: string, extra: Record<string, unknown> = {}): PipelineResponse {
  return { status: STATUS[error], body: { error, message, ...extra } };
}

function quotaFields(q: QuotaInfo) {
  return {
    remaining: q.remaining,
    scanLimit: q.scanLimit,
    plan: q.plan,
    planLabel: q.planLabel,
    isUnlimited: q.isUnlimited,
  };
}

type Validated =
  | { kind: "text"; text: string }
  | { kind: "image"; image: Image }
  | { kind: "barcode"; code: string };

/** Step 1–2: validate without touching quota. */
export function validate(body: unknown): Validated | PipelineResponse {
  if (!body || typeof body !== "object") return failure("validation", "Invalid request.");
  const req = body as Record<string, unknown>;
  const scanType = req.scanType;
  if (scanType !== "ingredients" && scanType !== "barcode") {
    return failure("validation", "Invalid request.");
  }

  if (typeof req.imageDataUrl === "string" && req.imageDataUrl.length > 0) {
    if (req.imageDataUrl.length > MAX_IMAGE_DATA_URL_CHARS) {
      return failure("validation", MESSAGES.oversizeImage);
    }
    const image = parseDataUrl(req.imageDataUrl);
    if (!image) return failure("validation", "Invalid image.");
    return { kind: "image", image };
  }

  if (scanType === "ingredients") {
    const text = typeof req.text === "string" ? req.text.trim() : "";
    if (!text) return failure("validation", MESSAGES.emptyText);
    if (text.length > MAX_TEXT_CHARS) {
      return failure("validation", "Ingredient text must be 10,000 characters or fewer.");
    }
    return { kind: "text", text };
  }

  const raw = typeof req.barcode === "string" ? req.barcode.trim() : "";
  if (!/^[A-Za-z0-9-]{1,32}$/.test(raw)) return failure("invalid_barcode", MESSAGES.invalidBarcode);
  const code = digitsOnly(raw);
  // Step 2: in-store codes never reach analysis or quota (PRD §7.5).
  if (isInStoreCode(code)) {
    return failure("local_barcode", MESSAGES.localBarcodeFromPhoto(code), { localBarcode: code });
  }
  if (!hasValidCheckDigit(code)) return failure("invalid_barcode", MESSAGES.invalidBarcode);
  return { kind: "barcode", code };
}

export async function runScan(userId: string, body: unknown, deps: Deps): Promise<PipelineResponse> {
  const log = deps.log ?? (() => {});

  // 1–2. Validate. Nothing below this line runs for a bad request.
  const input = validate(body);
  if ("status" in input) return input;

  // 3. Consume one credit before any model call, including cache hits.
  const quota = await deps.store.consumeQuota(userId);
  if (!quota.ok) {
    if (quota.error === "quota_exceeded") {
      return failure("quota_exceeded", MESSAGES.quotaExceeded, quotaFields(quota));
    }
    return failure("unauthorized", "Profile not found.");
  }
  const q = quotaFields(quota);

  try {
    // 4. Health profile → model context.
    const ctx = healthContext(await deps.store.loadHealthProfile(userId));

    if (input.kind === "text") {
      const result = normaliseResult(await deps.model.analyzeIngredients(input.text, ctx));
      return await finish(deps, userId, quota, result, "ingredients", input.text, "ingredients");
    }

    if (input.kind === "image") {
      // 5. Try to read a barcode off the photo first.
      const ocrText = await deps.model.readImageText(input.image);
      const code = extractBarcodeFromText(ocrText);
      if (code && isInStoreCode(code)) {
        // 6. In-store code from OCR: hand to local inventory, no analysis.
        return failure("local_barcode", MESSAGES.localBarcodeFromPhoto(code), { localBarcode: code, ...q });
      }
      if (code) return await analyzeBarcode(deps, userId, quota, code, ctx, "photo_barcode");
      // 9. No barcode: the model reads the label image directly.
      const result = normaliseResult(await deps.model.analyzeImage(input.image, ctx));
      return await finish(deps, userId, quota, result, "ingredients", null, "image");
    }

    return await analyzeBarcode(deps, userId, quota, input.code, ctx, "barcode");
  } catch (e) {
    // The credit stays spent; the client shows the reduced count (PRD §15).
    if (e instanceof ModelError) {
      log("model error", { code: e.code, detail: e.message });
      const message = e.code === "rate_limited"
        ? MESSAGES.rateLimited
        : e.code === "ai_credits_exhausted"
        ? MESSAGES.aiCreditsExhausted
        : MESSAGES.aiUnavailable;
      return failure(e.code, message, q);
    }
    log("pipeline error", { detail: String(e) });
    return failure("ai_unavailable", MESSAGES.aiUnavailable, q);
  }
}

async function lookupRegistries(deps: Deps, code: string): Promise<RegistryProduct | null> {
  const candidates = lookupCandidates(code);
  for (const c of candidates) {
    const hit = await deps.registries.openFoodFacts(c);
    if (hit) return hit;
  }
  for (const c of candidates) {
    const hit = await deps.registries.upcItemDb(c);
    if (hit) return hit;
  }
  return null;
}

/** Fresh Open Food Facts nutriments for organ recomputation on cache hits. */
async function freshNutrition(deps: Deps, code: string): Promise<RegistryProduct | null> {
  for (const c of lookupCandidates(code)) {
    const hit = await deps.registries.openFoodFacts(c);
    if (hit) return hit;
  }
  return null;
}

/** Registry identity always wins over the model (PRD §10 step 11). */
export function applyRegistryIdentity(result: ScanResult, product: RegistryProduct): ScanResult {
  const out: ScanResult = { ...result };
  // Name and brand come only from the registry; never keep a model guess.
  if (product.productName) out.productName = product.productName;
  if (product.brand) out.brand = product.brand;
  else delete out.brand;
  if (product.parentCompany) out.parentCompany = product.parentCompany;
  if (product.category) out.category = product.category;
  return out;
}

function withRuleOrgans(result: ScanResult, product: RegistryProduct | null): ScanResult {
  if (!product || !hasNutritionData(product.nutriments)) return result;
  return { ...result, ...computeOrganImpact(product.nutriments!, product.ingredientsText) };
}

async function analyzeBarcode(
  deps: Deps,
  userId: string,
  quota: QuotaInfo,
  code: string,
  ctx: string,
  source: ScanSource,
): Promise<PipelineResponse> {
  const key = canonicalBarcode(code);

  // 7. Shared cache: same barcode, same answer for every user.
  const cached = await deps.store.getCachedAnalysis(key);
  if (cached) {
    let analysis = withRuleOrgans(cached.analysis, await freshNutrition(deps, code));
    if (ctx) {
      try {
        const advice = await deps.model.personalAdvice(analysis.summary, cached.ingredientsText, ctx);
        if (advice) analysis = { ...analysis, personalAdvice: advice };
      } catch {
        // Personal advice is optional on a cache hit; the shared verdict stands.
      }
    }
    return await finish(deps, userId, quota, analysis, "barcode", code, source, { cached: true, barcode: key });
  }

  // 8. Registries. A hit is required; identity is never invented.
  const product = await lookupRegistries(deps, code);
  if (!product) {
    return failure("registry_miss", MESSAGES.registryMiss(code), quotaFields(quota));
  }

  // 9–11. Model analysis with identity locked, then registry overwrite + rules.
  const raw = await deps.model.analyzeRegistryProduct(product, gs1CountryHint(code), ctx);
  const analysis = withRuleOrgans(applyRegistryIdentity(normaliseResult(raw), product), product);

  // 12. Cache the shared (non-personal, full-tier) analysis.
  await deps.store.putCachedAnalysis(key, {
    analysis: withoutPersonalAdvice(analysis),
    ingredientsText: product.ingredientsText,
    registry: product.source,
    rulesVersion: RULES_VERSION,
  });

  return await finish(deps, userId, quota, analysis, "barcode", code, source, { cached: false, barcode: key });
}

async function finish(
  deps: Deps,
  userId: string,
  quota: QuotaInfo,
  analysis: ScanResult,
  scanType: "ingredients" | "barcode",
  inputText: string | null,
  source: ScanSource,
  extra: Record<string, unknown> = {},
): Promise<PipelineResponse> {
  // The stored and returned result only carries the caller's tier.
  const result = gateForPlan(analysis, quota.plan, quota.isUnlimited);

  // 12. Personal history row (also for cache hits, PRD §15).
  const scanId = await deps.store.insertScan({
    userId,
    productName: result.productName,
    scanType,
    rating: result.rating,
    healthScore: result.healthScore,
    caloriesKcal: result.caloriesKcal,
    summary: result.summary,
    inputText,
    result,
  });

  // 13. Result + quota envelope.
  return {
    status: 200,
    body: { result, scanId, ...quotaFields(quota), source, ...extra },
  };
}
