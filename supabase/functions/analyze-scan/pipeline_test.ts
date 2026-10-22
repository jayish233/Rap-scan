import { assertEquals } from "jsr:@std/assert@1";
import type { AnalysisModel } from "./gemini.ts";
import { ModelError } from "./gemini.ts";
import { MESSAGES } from "./messages.ts";
import { type CachedAnalysis, type Deps, runScan, type ScanRow } from "./pipeline.ts";
import type { HealthProfile, Plan, QuotaResult, RegistryProduct } from "./types.ts";

const INDIAN_EAN = "8901063010307";
const UNKNOWN_EAN = "8906000000007";
const UPC = "036000291452";

const MODEL_JSON = {
  productName: "Guessed Name",
  brand: "Guessed Brand",
  parentCompany: "Guessed Co",
  category: "guessed category",
  rating: "caution",
  healthScore: 35,
  caloriesKcal: 45,
  summary: "Sweet biscuit with refined flour.",
  advantages: ["Quick energy"],
  disadvantages: ["High sugar"],
  cautions: [{ ingredient: "Sugar", concern: "High.", severity: "high", percentage: "~25%" }],
  personalAdvice: "",
  consumptionTip: { safeDaily: "2", limit: "4", source: "WHO" },
  riskProfile: { illnesses: ["a", "b"], addictions: [], chronicDamage: [], temporaryEffects: [], organDamage: [] },
  bodyDamage: [{ part: "lungs", severity: "high", reason: "model organ" }],
  bodyBenefit: [],
  dietaryType: "veg",
  dietaryReason: "Milk solids.",
};

const OFF_PRODUCT: RegistryProduct = {
  source: "openfoodfacts",
  barcode: INDIAN_EAN,
  productName: "Parle-G Original Glucose Biscuits",
  brand: "Parle",
  parentCompany: "Parle Products",
  category: "Biscuits",
  ingredientsText: "Wheat flour, sugar, palm oil",
  nutriments: { "sugars_100g": 26, "saturated-fat_100g": 6, "salt_100g": 0.4 },
};

interface Harness {
  deps: Deps;
  calls: string[];
  scans: ScanRow[];
  cache: Map<string, CachedAnalysis>;
  quota: { count: number };
}

function harness(opts: {
  plan?: Plan;
  isUnlimited?: boolean;
  limit?: number;
  used?: number;
  profile?: HealthProfile | null;
  off?: Record<string, RegistryProduct>;
  upc?: Record<string, RegistryProduct>;
  ocrText?: string;
  modelError?: ModelError;
} = {}): Harness {
  const calls: string[] = [];
  const scans: ScanRow[] = [];
  const cache = new Map<string, CachedAnalysis>();
  const quota = { count: opts.used ?? 0 };
  const limit = opts.limit ?? 30;
  const plan = opts.plan ?? "free";
  const isUnlimited = opts.isUnlimited ?? false;

  const model: AnalysisModel = {
    analyzeIngredients() {
      calls.push("model:ingredients");
      if (opts.modelError) return Promise.reject(opts.modelError);
      return Promise.resolve({ ...MODEL_JSON });
    },
    analyzeImage() {
      calls.push("model:image");
      return Promise.resolve({ ...MODEL_JSON });
    },
    analyzeRegistryProduct() {
      calls.push("model:registry");
      return Promise.resolve({ ...MODEL_JSON });
    },
    readImageText() {
      calls.push("model:ocr");
      return Promise.resolve(opts.ocrText ?? "");
    },
    personalAdvice() {
      calls.push("model:advice");
      return Promise.resolve("You listed a peanut allergy; this contains none.");
    },
  };

  const deps: Deps = {
    model,
    registries: {
      openFoodFacts: (code) => {
        calls.push(`off:${code}`);
        return Promise.resolve(opts.off?.[code] ?? null);
      },
      upcItemDb: (code) => {
        calls.push(`upc:${code}`);
        return Promise.resolve(opts.upc?.[code] ?? null);
      },
    },
    store: {
      consumeQuota(): Promise<QuotaResult> {
        calls.push("quota");
        const info = {
          scanLimit: isUnlimited ? 999999 : limit,
          plan,
          planLabel: plan === "free" ? "Free" : plan,
          isUnlimited,
        };
        if (!isUnlimited && quota.count >= limit) {
          return Promise.resolve({ ok: false, error: "quota_exceeded", remaining: 0, ...info });
        }
        quota.count++;
        return Promise.resolve({ ok: true, remaining: isUnlimited ? 999999 : limit - quota.count, ...info });
      },
      loadHealthProfile() {
        calls.push("profile");
        return Promise.resolve(opts.profile ?? null);
      },
      getCachedAnalysis(barcode) {
        calls.push(`cache:get:${barcode}`);
        return Promise.resolve(cache.get(barcode) ?? null);
      },
      putCachedAnalysis(barcode, entry) {
        calls.push(`cache:put:${barcode}`);
        cache.set(barcode, structuredClone(entry));
        return Promise.resolve();
      },
      insertScan(row) {
        calls.push("insert");
        scans.push(row);
        return Promise.resolve(`scan-${scans.length}`);
      },
    },
  };
  return { deps, calls, scans, cache, quota };
}

const USER = "user-1";

Deno.test("empty text: validation error, no credit, no model", async () => {
  const h = harness();
  const res = await runScan(USER, { scanType: "ingredients", text: "   " }, h.deps);
  assertEquals(res.status, 400);
  assertEquals(res.body.message, MESSAGES.emptyText);
  assertEquals(h.calls, []);
});

Deno.test("bad check digit: invalid_barcode, never reaches quota or model", async () => {
  const h = harness();
  const res = await runScan(USER, { scanType: "barcode", barcode: "8901063010308" }, h.deps);
  assertEquals(res.body.error, "invalid_barcode");
  assertEquals(res.body.message, MESSAGES.invalidBarcode);
  assertEquals(h.calls, []);
  assertEquals(h.quota.count, 0);
});

Deno.test("in-store code sent directly: local_barcode, no credit", async () => {
  const h = harness();
  const res = await runScan(USER, { scanType: "barcode", barcode: "2000000123455" }, h.deps);
  assertEquals(res.body.error, "local_barcode");
  assertEquals(res.body.localBarcode, "2000000123455");
  assertEquals(h.calls, []);
});

Deno.test("text scan: credit consumed before model, scan row inserted", async () => {
  const h = harness();
  const res = await runScan(USER, { scanType: "ingredients", text: "sugar, wheat flour" }, h.deps);
  assertEquals(res.status, 200);
  assertEquals(h.calls, ["quota", "profile", "model:ingredients", "insert"]);
  assertEquals(res.body.remaining, 29);
  assertEquals(res.body.scanLimit, 30);
  assertEquals(res.body.scanId, "scan-1");
  assertEquals(h.scans[0].scanType, "ingredients");
  assertEquals(h.scans[0].inputText, "sugar, wheat flour");
});

Deno.test("quota exceeded: aborts before the model", async () => {
  const h = harness({ used: 30 });
  const res = await runScan(USER, { scanType: "ingredients", text: "sugar" }, h.deps);
  assertEquals(res.status, 402);
  assertEquals(res.body.message, MESSAGES.quotaExceeded);
  assertEquals(res.body.remaining, 0);
  assertEquals(h.calls, ["quota"]);
});

Deno.test("model failure: credit stays spent and reduced count is returned", async () => {
  const h = harness({ modelError: new ModelError("rate_limited", "429") });
  const res = await runScan(USER, { scanType: "ingredients", text: "sugar" }, h.deps);
  assertEquals(res.body.error, "rate_limited");
  assertEquals(res.body.message, MESSAGES.rateLimited);
  assertEquals(res.body.remaining, 29);
  assertEquals(h.quota.count, 1);
  assertEquals(h.scans.length, 0);
});

Deno.test("barcode: registry identity overwrites model, organs from rules, cached", async () => {
  const h = harness({ plan: "pro_max", limit: 240, off: { [INDIAN_EAN]: OFF_PRODUCT } });
  const res = await runScan(USER, { scanType: "barcode", barcode: INDIAN_EAN }, h.deps);
  assertEquals(res.status, 200);
  const result = res.body.result as Record<string, unknown>;
  assertEquals(result.productName, "Parle-G Original Glucose Biscuits");
  assertEquals(result.brand, "Parle");
  assertEquals(result.parentCompany, "Parle Products");
  assertEquals(result.category, "Biscuits");
  // Model's "lungs" marker replaced by the deterministic rule engine.
  const parts = (result.bodyDamage as Array<{ part: string }>).map((m) => m.part);
  assertEquals(parts.includes("lungs"), false);
  assertEquals(parts.includes("teeth"), true);
  assertEquals(h.calls, [
    "quota",
    "profile",
    `cache:get:${INDIAN_EAN}`,
    `off:${INDIAN_EAN}`,
    "model:registry",
    `cache:put:${INDIAN_EAN}`,
    "insert",
  ]);
  assertEquals(h.scans[0].scanType, "barcode");
  assertEquals(h.scans[0].inputText, INDIAN_EAN);
});

Deno.test("barcode rescan: identical result from cache, still consumes a credit", async () => {
  const h = harness({ off: { [INDIAN_EAN]: OFF_PRODUCT } });
  const first = await runScan(USER, { scanType: "barcode", barcode: INDIAN_EAN }, h.deps);
  const second = await runScan("user-2", { scanType: "barcode", barcode: INDIAN_EAN }, h.deps);
  const a = first.body.result as Record<string, unknown>;
  const b = second.body.result as Record<string, unknown>;
  assertEquals(b.healthScore, a.healthScore);
  assertEquals(b.summary, a.summary);
  assertEquals(b.productName, a.productName);
  assertEquals(second.body.cached, true);
  assertEquals(h.quota.count, 2);
  assertEquals(h.calls.filter((c) => c === "model:registry").length, 1);
  assertEquals(h.scans.length, 2);
});

Deno.test("cache never stores personal advice; cache hit personalises per user", async () => {
  const h = harness({ off: { [INDIAN_EAN]: OFF_PRODUCT }, profile: { allergies: "peanuts" } });
  await runScan(USER, { scanType: "barcode", barcode: INDIAN_EAN }, h.deps);
  assertEquals("personalAdvice" in h.cache.get(INDIAN_EAN)!.analysis, false);
  const second = await runScan(USER, { scanType: "barcode", barcode: INDIAN_EAN }, h.deps);
  assertEquals(
    (second.body.result as Record<string, unknown>).personalAdvice,
    "You listed a peanut allergy; this contains none.",
  );
});

Deno.test("registry fallback: OFF miss → UPCitemdb, with 12-digit leading-0 retry", async () => {
  const upcHit: RegistryProduct = { source: "upcitemdb", barcode: `0${UPC}`, productName: "Corn Flakes", brand: "Kellogg's" };
  const h = harness({ upc: { [`0${UPC}`]: upcHit } });
  const res = await runScan(USER, { scanType: "barcode", barcode: UPC }, h.deps);
  assertEquals(res.status, 200);
  assertEquals(h.calls.slice(2, 7), [
    `cache:get:0${UPC}`,
    `off:${UPC}`,
    `off:0${UPC}`,
    `upc:${UPC}`,
    `upc:0${UPC}`,
  ]);
  assertEquals((res.body.result as Record<string, unknown>).productName, "Corn Flakes");
});

Deno.test("registry miss: verbatim error, no invented identity, no model call", async () => {
  const h = harness();
  const res = await runScan(USER, { scanType: "barcode", barcode: UNKNOWN_EAN }, h.deps);
  assertEquals(res.status, 404);
  assertEquals(res.body.error, "registry_miss");
  assertEquals(res.body.message, MESSAGES.registryMiss(UNKNOWN_EAN));
  assertEquals(h.calls.includes("model:registry"), false);
  assertEquals(h.scans.length, 0);
});

Deno.test("photo: OCR barcode is analysed like a typed barcode", async () => {
  const h = harness({ off: { [INDIAN_EAN]: OFF_PRODUCT }, ocrText: "MRP Rs. 10\n8 901063 010307" });
  const res = await runScan(USER, { scanType: "ingredients", imageDataUrl: "data:image/jpeg;base64,AAAA" }, h.deps);
  assertEquals(res.status, 200);
  assertEquals(res.body.source, "photo_barcode");
  assertEquals(h.calls.includes("model:image"), false);
  assertEquals(h.scans[0].inputText, INDIAN_EAN);
});

Deno.test("photo: in-store code from OCR goes to local inventory", async () => {
  const h = harness({ ocrText: "2000000123455" });
  const res = await runScan(USER, { scanType: "ingredients", imageDataUrl: "data:image/png;base64,AAAA" }, h.deps);
  assertEquals(res.body.error, "local_barcode");
  assertEquals(res.body.localBarcode, "2000000123455");
  assertEquals(res.body.message, MESSAGES.localBarcodeFromPhoto("2000000123455"));
  assertEquals(h.scans.length, 0);
});

Deno.test("photo: no barcode → image analysis, photo never stored", async () => {
  const h = harness({ ocrText: "Ingredients: rice, salt" });
  const res = await runScan(USER, { scanType: "ingredients", imageDataUrl: "data:image/png;base64,AAAA" }, h.deps);
  assertEquals(res.body.source, "image");
  assertEquals(h.scans[0].inputText, null);
});

Deno.test("tier gating: free caller gets no gated fields, even in the stored row", async () => {
  const h = harness({ plan: "free" });
  const res = await runScan(USER, { scanType: "ingredients", text: "sugar" }, h.deps);
  const result = res.body.result as Record<string, unknown>;
  for (const k of ["consumptionTip", "riskProfile", "bodyDamage", "bodyBenefit", "dietaryType", "dietaryReason"]) {
    assertEquals(k in result, false, k);
    assertEquals(k in h.scans[0].result, false, k);
  }
});

Deno.test("tier gating: unlimited role sees Pro Max fields", async () => {
  const h = harness({ plan: "pro_max", isUnlimited: true });
  const res = await runScan(USER, { scanType: "ingredients", text: "sugar" }, h.deps);
  const result = res.body.result as Record<string, unknown>;
  assertEquals(result.dietaryType, "veg");
  assertEquals(res.body.isUnlimited, true);
});
