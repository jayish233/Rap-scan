// Deterministic organ rule engine (PRD §7.4.2, architecture.md §3.4).
//
// Same nutriments + ingredient text ⇒ same organs, always. Thresholds are per
// 100 g, from UK FSA front-of-pack "high/medium" bands, WHO sodium/sugar
// guidance and EU nutrient-claim NRV levels (15% "source of", 30% "high in").
// Bump RULES_VERSION whenever a rule changes.

import { type BodyMarker, type Nutriments, ORGAN_KEYS, type OrganKey, type Severity } from "./types.ts";

export const RULES_VERSION = "organRules.v1";

interface RuleContext {
  n: (key: string) => number | null;
  ingredients: string;
}

interface Rule {
  kind: "harm" | "benefit";
  part: OrganKey;
  severity: Severity;
  trigger: string;
  reason: string;
  when: (ctx: RuleContext) => boolean;
}

const has = (pattern: RegExp) => (ctx: RuleContext) => pattern.test(ctx.ingredients);
const atLeast = (key: string, min: number) => (ctx: RuleContext) => {
  const v = ctx.n(key);
  return v !== null && v >= min;
};
const above = (key: string, min: number) => (ctx: RuleContext) => {
  const v = ctx.n(key);
  return v !== null && v > min;
};

const PALM_OIL = /\bpalm(olein| oil|\s?kernel)|\bpalmolein\b/i;
const TRANS_FAT = /partially hydrogenated|hydrogenated (vegetable )?(oil|fat)|\bvanaspati\b|\btrans fat/i;
const MSG = /monosodium glutamate|\bmsg\b|\be ?621\b|\bins ?621\b/i;
const SWEETENERS =
  /aspartame|sucralose|acesulfame|saccharin|neotame|cyclamate|\b(e|ins) ?(950|951|952|954|955|961)\b/i;
const CAFFEINE = /caffeine|\bcoffee\b|guarana|\bcola nut/i;
const ALCOHOL = /(?<!sugar |cetyl |stearyl |cetearyl |benzyl )\balcohol\b|\bethanol\b|\b(rum|whisky|whiskey|brandy|vodka|wine|beer)\b/i;
const AZO_COLOURS =
  /tartrazine|sunset yellow|carmoisine|azorubine|ponceau|allura red|brilliant black|\b(e|ins) ?(102|110|122|124|129|151)\b/i;
const NITRITES = /\bnitrite|\b(e|ins) ?(249|250)\b/i;
const REFINED_FLOUR = /\bmaida\b|refined (wheat )?flour/i;
const PROBIOTICS = /probiotic|live (and active )?cultures|active cultures|lactobacillus|bifidobacter|streptococcus thermophilus/i;
const OMEGA3 = /omega[- ]?3|flax ?seed|linseed|fish oil|\bdha\b|\bepa\b|chia seed/i;
const WHOLE_GRAINS = /whole ?(wheat|grain|meal)|\batta\b|\boats?\b|brown rice|millet|\bragi\b|\bjowar\b|\bbajra\b|quinoa/i;

// Order matters only as a tie-break for equal severity on the same organ.
const RULES: Rule[] = [
  // --- Harms: sugar (FSA high > 22.5 g, medium > 5 g) ---
  { kind: "harm", part: "teeth", severity: "high", trigger: "sugar", when: above("sugars_100g", 22.5),
    reason: "High free sugar feeds the bacteria that cause tooth decay (WHO)." },
  { kind: "harm", part: "teeth", severity: "medium", trigger: "sugar", when: above("sugars_100g", 10),
    reason: "Moderate sugar content raises the risk of tooth decay with frequent eating (WHO)." },
  { kind: "harm", part: "teeth", severity: "low", trigger: "sugar", when: above("sugars_100g", 5),
    reason: "Contains added sugar that can contribute to tooth decay (WHO)." },
  { kind: "harm", part: "pancreas", severity: "high", trigger: "sugar", when: above("sugars_100g", 22.5),
    reason: "A large sugar load spikes blood glucose and makes the pancreas work harder (WHO, AHA)." },
  { kind: "harm", part: "pancreas", severity: "medium", trigger: "sugar", when: above("sugars_100g", 10),
    reason: "Sugar content can push up blood glucose when eaten often (WHO)." },
  { kind: "harm", part: "liver", severity: "medium", trigger: "sugar", when: above("sugars_100g", 22.5),
    reason: "Regular high sugar intake is linked to fat build-up in the liver (NIH)." },
  { kind: "harm", part: "pancreas", severity: "low", trigger: "refined flour", when: has(REFINED_FLOUR),
    reason: "Refined flour digests quickly and can raise blood sugar fast (ICMR-NIN)." },

  // --- Harms: fats (FSA saturates high > 5 g, medium > 1.5 g) ---
  { kind: "harm", part: "heart", severity: "high", trigger: "trans fat",
    when: (ctx) => atLeast("trans-fat_100g", 0.2)(ctx) || has(TRANS_FAT)(ctx),
    reason: "Trans fats raise LDL cholesterol and heart-disease risk (WHO, FDA)." },
  { kind: "harm", part: "heart", severity: "high", trigger: "saturated fat", when: above("saturated-fat_100g", 5),
    reason: "High saturated fat raises LDL cholesterol (AHA, WHO)." },
  { kind: "harm", part: "heart", severity: "medium", trigger: "saturated fat", when: above("saturated-fat_100g", 1.5),
    reason: "Moderate saturated fat adds to daily cholesterol-raising fat intake (AHA)." },
  { kind: "harm", part: "heart", severity: "low", trigger: "palm oil", when: has(PALM_OIL),
    reason: "Palm oil is rich in saturated fat (AHA)." },

  // --- Harms: salt (FSA high > 1.5 g, medium > 0.3 g) ---
  { kind: "harm", part: "heart", severity: "high", trigger: "salt", when: above("salt_100g", 1.5),
    reason: "High salt raises blood pressure, a major heart risk (WHO)." },
  { kind: "harm", part: "kidneys", severity: "medium", trigger: "salt", when: above("salt_100g", 1.5),
    reason: "High sodium makes the kidneys work harder to balance fluids (NIH)." },
  { kind: "harm", part: "heart", severity: "low", trigger: "salt", when: above("salt_100g", 0.3),
    reason: "Adds to daily salt intake, which affects blood pressure (WHO)." },
  { kind: "harm", part: "kidneys", severity: "low", trigger: "salt", when: above("salt_100g", 0.3),
    reason: "Adds sodium the kidneys must clear (NIH)." },

  // --- Harms: named ingredients ---
  { kind: "harm", part: "brain", severity: "low", trigger: "MSG", when: has(MSG),
    reason: "Some people report headaches after large amounts of MSG (FDA)." },
  { kind: "harm", part: "intestines", severity: "low", trigger: "artificial sweeteners", when: has(SWEETENERS),
    reason: "Non-sugar sweeteners may alter gut bacteria; WHO advises against relying on them (WHO 2023)." },
  { kind: "harm", part: "heart", severity: "low", trigger: "caffeine",
    when: (ctx) => has(CAFFEINE)(ctx) || atLeast("caffeine_100g", 0.01)(ctx),
    reason: "Caffeine can raise heart rate and blood pressure briefly (FDA)." },
  { kind: "harm", part: "brain", severity: "low", trigger: "caffeine",
    when: (ctx) => has(CAFFEINE)(ctx) || atLeast("caffeine_100g", 0.01)(ctx),
    reason: "Caffeine is a stimulant that can disturb sleep (FDA, EFSA)." },
  { kind: "harm", part: "liver", severity: "high", trigger: "alcohol",
    when: (ctx) => has(ALCOHOL)(ctx) || above("alcohol_100g", 0.5)(ctx),
    reason: "Alcohol is processed by the liver and damages it over time (WHO)." },
  { kind: "harm", part: "brain", severity: "medium", trigger: "alcohol",
    when: (ctx) => has(ALCOHOL)(ctx) || above("alcohol_100g", 0.5)(ctx),
    reason: "Alcohol affects judgement and coordination (NIH)." },
  { kind: "harm", part: "brain", severity: "low", trigger: "azo colours", when: has(AZO_COLOURS),
    reason: "Some azo colours are linked to hyperactivity in sensitive children (EFSA)." },
  { kind: "harm", part: "intestines", severity: "medium", trigger: "nitrites", when: has(NITRITES),
    reason: "Nitrite-cured processed meat is linked to bowel cancer (WHO IARC)." },

  // --- Benefits: fibre (EU high fibre ≥ 6 g, source ≥ 3 g) ---
  { kind: "benefit", part: "intestines", severity: "high", trigger: "fibre", when: atLeast("fiber_100g", 6),
    reason: "High in fibre, which supports regular digestion (EFSA)." },
  { kind: "benefit", part: "intestines", severity: "medium", trigger: "fibre", when: atLeast("fiber_100g", 3),
    reason: "A source of fibre for digestive health (EFSA)." },

  // --- Benefits: protein (EU high protein ≈ 20% energy; per-100 g proxy) ---
  { kind: "benefit", part: "bones", severity: "medium", trigger: "protein", when: atLeast("proteins_100g", 20),
    reason: "High in protein, which helps maintain muscle and bone (EFSA)." },
  { kind: "benefit", part: "bones", severity: "low", trigger: "protein", when: atLeast("proteins_100g", 10),
    reason: "A useful source of protein (EFSA)." },

  // --- Benefits: micronutrients (g per 100 g; 15% / 30% of EU NRV) ---
  { kind: "benefit", part: "bones", severity: "high", trigger: "calcium", when: atLeast("calcium_100g", 0.24),
    reason: "High in calcium, needed for strong bones (EFSA, ICMR-NIN)." },
  { kind: "benefit", part: "bones", severity: "medium", trigger: "calcium", when: atLeast("calcium_100g", 0.12),
    reason: "A source of calcium for bones (EFSA)." },
  { kind: "benefit", part: "teeth", severity: "low", trigger: "calcium", when: atLeast("calcium_100g", 0.12),
    reason: "Calcium helps maintain teeth (EFSA)." },
  { kind: "benefit", part: "bones", severity: "low", trigger: "vitamin D", when: atLeast("vitamin-d_100g", 0.00000075),
    reason: "Vitamin D helps the body absorb calcium (NIH)." },
  { kind: "benefit", part: "eyes", severity: "medium", trigger: "vitamin A", when: atLeast("vitamin-a_100g", 0.00024),
    reason: "High in vitamin A, which supports normal vision (EFSA)." },
  { kind: "benefit", part: "eyes", severity: "low", trigger: "vitamin A", when: atLeast("vitamin-a_100g", 0.00012),
    reason: "A source of vitamin A for normal vision (EFSA)." },
  { kind: "benefit", part: "skin", severity: "medium", trigger: "vitamin C", when: atLeast("vitamin-c_100g", 0.024),
    reason: "High in vitamin C, which supports collagen for skin (EFSA)." },
  { kind: "benefit", part: "skin", severity: "low", trigger: "vitamin C", when: atLeast("vitamin-c_100g", 0.012),
    reason: "A source of vitamin C for skin (EFSA)." },

  // --- Benefits: named ingredients ---
  { kind: "benefit", part: "intestines", severity: "medium", trigger: "probiotics", when: has(PROBIOTICS),
    reason: "Live cultures can support healthy gut bacteria (NIH)." },
  { kind: "benefit", part: "heart", severity: "low", trigger: "omega-3",
    when: (ctx) => has(OMEGA3)(ctx) || atLeast("omega-3-fat_100g", 0.3)(ctx),
    reason: "Omega-3 fats support normal heart function (EFSA, AHA)." },
  { kind: "benefit", part: "brain", severity: "low", trigger: "omega-3",
    when: (ctx) => has(OMEGA3)(ctx) || atLeast("omega-3-fat_100g", 0.3)(ctx),
    reason: "DHA omega-3 supports normal brain function (EFSA)." },
  { kind: "benefit", part: "intestines", severity: "low", trigger: "whole grains", when: has(WHOLE_GRAINS),
    reason: "Whole grains add fibre for digestion (ICMR-NIN)." },
  { kind: "benefit", part: "heart", severity: "low", trigger: "whole grains", when: has(WHOLE_GRAINS),
    reason: "Whole grains are linked to lower heart-disease risk (AHA)." },
];

const SEVERITY_RANK: Record<Severity, number> = { low: 1, medium: 2, high: 3 };

const KEY_NUTRIENTS = [
  "sugars_100g",
  "saturated-fat_100g",
  "salt_100g",
  "sodium_100g",
  "fiber_100g",
  "proteins_100g",
  "fat_100g",
  "energy-kcal_100g",
];

function numeric(value: unknown): number | null {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (typeof value === "string" && value.trim() !== "" && Number.isFinite(Number(value))) return Number(value);
  return null;
}

/** True when the registry returned usable per-100 g nutrition data. */
export function hasNutritionData(nutriments: Nutriments | undefined): boolean {
  if (!nutriments) return false;
  return KEY_NUTRIENTS.some((k) => numeric(nutriments[k]) !== null);
}

export function computeOrganImpact(
  nutriments: Nutriments,
  ingredientsText: string | undefined,
): { bodyDamage: BodyMarker[]; bodyBenefit: BodyMarker[] } {
  const ctx: RuleContext = {
    n: (key) => {
      const direct = numeric(nutriments[key]);
      if (direct !== null) return direct;
      // Salt is sodium × 2.5 when only sodium is reported.
      if (key === "salt_100g") {
        const sodium = numeric(nutriments["sodium_100g"]);
        return sodium === null ? null : sodium * 2.5;
      }
      return null;
    },
    ingredients: (ingredientsText ?? "").toLowerCase(),
  };

  const best = { harm: new Map<OrganKey, Rule>(), benefit: new Map<OrganKey, Rule>() };
  for (const rule of RULES) {
    if (!rule.when(ctx)) continue;
    const current = best[rule.kind].get(rule.part);
    if (!current || SEVERITY_RANK[rule.severity] > SEVERITY_RANK[current.severity]) {
      best[rule.kind].set(rule.part, rule);
    }
  }

  const toMarkers = (map: Map<OrganKey, Rule>): BodyMarker[] =>
    ORGAN_KEYS.filter((k) => map.has(k)).map((k) => {
      const r = map.get(k)!;
      return { part: k, severity: r.severity, reason: r.reason, trigger: r.trigger };
    });

  return { bodyDamage: toMarkers(best.harm), bodyBenefit: toMarkers(best.benefit) };
}
