import { assertEquals } from "jsr:@std/assert@1";
import { gateForPlan, normaliseResult, withoutPersonalAdvice } from "./gating.ts";
import type { ScanResult } from "./types.ts";

const FULL: ScanResult = normaliseResult({
  productName: "Choco Cream Biscuit",
  brand: "Bourbon",
  parentCompany: "Britannia Industries",
  category: "cream-filled biscuit",
  rating: "caution",
  healthScore: 32,
  caloriesKcal: 52,
  summary: "Sweet cream biscuit high in sugar and palm fat.",
  advantages: ["Quick energy"],
  disadvantages: ["High sugar", "Palm oil"],
  cautions: [{
    ingredient: "Sugar",
    concern: "Adds a lot of free sugar.",
    severity: "high",
    percentage: "~35%",
    chemicalFormula: "C12H22O11",
    scientificName: "Sucrose",
  }],
  personalAdvice: "You listed diabetes; keep this occasional.",
  consumptionTip: { safeDaily: "2 biscuits", limit: "4 biscuits", source: "WHO free-sugar guideline" },
  riskProfile: {
    illnesses: ["Type 2 diabetes risk", "Weight gain"],
    addictions: ["Sugar cravings", "Snacking habit"],
    chronicDamage: ["Tooth decay", "Raised LDL"],
    temporaryEffects: ["Energy crash", "Thirst"],
    organDamage: ["Pancreas strain", "Fatty liver"],
  },
  bodyDamage: [{ part: "teeth", severity: "high", reason: "Sugar", trigger: "sugar" }],
  bodyBenefit: [],
  dietaryType: "veg",
  dietaryReason: "Contains milk solids (lacto-vegetarian).",
});

const GATED_KEYS = ["consumptionTip", "riskProfile", "bodyDamage", "bodyBenefit", "dietaryType", "dietaryReason"];

Deno.test("free: no %, formula, guide, risk profile, dietary or body map", () => {
  const r = gateForPlan(FULL, "free", false);
  for (const k of GATED_KEYS) assertEquals(k in r, false, k);
  assertEquals(r.cautions[0], { ingredient: "Sugar", concern: "Adds a lot of free sugar.", severity: "high" });
  assertEquals(r.personalAdvice, "You listed diabetes; keep this occasional.");
});

Deno.test("pro: percentage folded into concern text only", () => {
  const r = gateForPlan(FULL, "pro", false);
  for (const k of GATED_KEYS) assertEquals(k in r, false, k);
  assertEquals(r.cautions[0], {
    ingredient: "Sugar",
    concern: "Adds a lot of free sugar. (estimated ~35% of the product)",
    severity: "high",
  });
});

Deno.test("pro_plus: % field, formula, scientific name and consumption guide", () => {
  const r = gateForPlan(FULL, "pro_plus", false);
  assertEquals(r.cautions[0], FULL.cautions[0]);
  assertEquals(r.consumptionTip, FULL.consumptionTip);
  for (const k of ["riskProfile", "bodyDamage", "bodyBenefit", "dietaryType", "dietaryReason"]) {
    assertEquals(k in r, false, k);
  }
});

Deno.test("pro_max and unlimited roles: everything", () => {
  assertEquals(gateForPlan(FULL, "pro_max", false), FULL);
  assertEquals(gateForPlan(FULL, "free", true), FULL);
});

Deno.test("normalise: clamps score and calories, drops unknown organs", () => {
  const r = normaliseResult({
    productName: "X",
    rating: "nonsense",
    healthScore: 140,
    caloriesKcal: -20,
    summary: "s",
    bodyDamage: [{ part: "spleen", severity: "high", reason: "r" }, { part: "Heart", severity: "x", reason: "r" }],
  });
  assertEquals(r.healthScore, 100);
  assertEquals(r.caloriesKcal, 0);
  assertEquals(r.rating, "good");
  assertEquals(r.bodyDamage, [{ part: "heart", severity: "low", reason: "r" }]);
  assertEquals(normaliseResult({ caloriesKcal: 99999 }).caloriesKcal, 5000);
});

Deno.test("normalise: risk profile emptied for healthy products", () => {
  const r = normaliseResult({ ...FULL, healthScore: 80, rating: "good" });
  assertEquals(Object.values(r.riskProfile!).every((l) => l.length === 0), true);
});

Deno.test("cache entries never carry personal advice", () => {
  assertEquals("personalAdvice" in withoutPersonalAdvice(FULL), false);
});
