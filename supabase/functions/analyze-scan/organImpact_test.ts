import { assertEquals } from "jsr:@std/assert@1";
import { computeOrganImpact, hasNutritionData, RULES_VERSION } from "./organImpact.ts";

// Fixture: cream biscuit — high sugar, high saturates via palm oil, medium salt.
const CREAM_BISCUIT = {
  nutriments: { "sugars_100g": 35, "saturated-fat_100g": 9, "salt_100g": 0.6, "fiber_100g": 1.5, "proteins_100g": 6 },
  ingredients: "Refined wheat flour (maida), sugar, palm oil, invert syrup, raising agents, salt, emulsifier (E471)",
};

// Fixture: plain curd — calcium, protein, live cultures, almost no sugar.
const CURD = {
  nutriments: { "sugars_100g": 4, "saturated-fat_100g": 2.4, "salt_100g": 0.1, "proteins_100g": 11, "calcium_100g": 0.13 },
  ingredients: "Pasteurised toned milk, milk solids, live active cultures (Lactobacillus)",
};

Deno.test("rules are versioned", () => {
  assertEquals(RULES_VERSION, "organRules.v1");
});

Deno.test("cream biscuit fixture", () => {
  const { bodyDamage, bodyBenefit } = computeOrganImpact(CREAM_BISCUIT.nutriments, CREAM_BISCUIT.ingredients);
  assertEquals(
    bodyDamage.map((m) => [m.part, m.severity, m.trigger]),
    [
      ["teeth", "high", "sugar"],
      ["heart", "high", "saturated fat"],
      ["liver", "medium", "sugar"],
      ["pancreas", "high", "sugar"],
      ["kidneys", "low", "salt"],
    ],
  );
  assertEquals(bodyBenefit, []);
});

Deno.test("curd fixture", () => {
  const { bodyDamage, bodyBenefit } = computeOrganImpact(CURD.nutriments, CURD.ingredients);
  assertEquals(bodyDamage.map((m) => [m.part, m.severity]), [["heart", "medium"]]);
  assertEquals(
    bodyBenefit.map((m) => [m.part, m.severity, m.trigger]),
    [
      ["teeth", "low", "calcium"],
      ["intestines", "medium", "probiotics"],
      ["bones", "medium", "calcium"],
    ],
  );
});

Deno.test("deterministic: same inputs give identical output", () => {
  const a = computeOrganImpact(CREAM_BISCUIT.nutriments, CREAM_BISCUIT.ingredients);
  for (let i = 0; i < 20; i++) {
    assertEquals(computeOrganImpact({ ...CREAM_BISCUIT.nutriments }, CREAM_BISCUIT.ingredients), a);
  }
});

Deno.test("salt derived from sodium when salt is missing", () => {
  const { bodyDamage } = computeOrganImpact({ "sodium_100g": 0.8 }, "");
  assertEquals(bodyDamage.map((m) => [m.part, m.severity]), [["heart", "high"], ["kidneys", "medium"]]);
});

Deno.test("named ingredients: trans fat, sweeteners, azo colours, nitrites", () => {
  const { bodyDamage } = computeOrganImpact(
    { "sugars_100g": 0 },
    "partially hydrogenated vegetable oil, aspartame (E951), sunset yellow (INS 110), sodium nitrite",
  );
  assertEquals(
    bodyDamage.map((m) => [m.part, m.severity, m.trigger]),
    [
      ["brain", "low", "azo colours"],
      ["heart", "high", "trans fat"],
      ["intestines", "medium", "nitrites"],
    ],
  );
});

Deno.test("sugar alcohols are not alcohol", () => {
  const { bodyDamage } = computeOrganImpact({ "sugars_100g": 1 }, "sugar alcohol (maltitol), cetyl alcohol");
  assertEquals(bodyDamage, []);
});

Deno.test("only organ keys from the allowed list", () => {
  const allowed = new Set([
    "brain", "eyes", "teeth", "throat", "heart", "lungs", "liver",
    "stomach", "pancreas", "kidneys", "intestines", "skin", "bones",
  ]);
  const { bodyDamage, bodyBenefit } = computeOrganImpact(
    { "sugars_100g": 50, "salt_100g": 3, "fiber_100g": 10, "vitamin-a_100g": 0.001, "vitamin-c_100g": 0.05 },
    "caffeine, rum, oats, flaxseed, msg",
  );
  for (const m of [...bodyDamage, ...bodyBenefit]) assertEquals(allowed.has(m.part), true);
});

Deno.test("hasNutritionData", () => {
  assertEquals(hasNutritionData(undefined), false);
  assertEquals(hasNutritionData({}), false);
  assertEquals(hasNutritionData({ "vitamin-c_100g": 0.01 }), false);
  assertEquals(hasNutritionData({ "sugars_100g": 0 }), true);
});
