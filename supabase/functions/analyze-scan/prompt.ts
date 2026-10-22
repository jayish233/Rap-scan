// Model instructions for analyze-scan (PRD §7.4, §10, §11.1).
//
// The model always produces the full schema. Tier differences are applied
// afterwards by gating.ts, so a cached barcode analysis is identical for
// every user and only its visibility depends on the caller's plan.

import type { HealthProfile, RegistryProduct } from "./types.ts";

export const SYSTEM_INSTRUCTIONS = `You are RAPscanz, a food-label analyst for Indian and international packaged foods (Amul, Britannia, Parle, Haldiram's, Mother Dairy, MTR, Tata, ITC, Patanjali, Nestlé India and similar).
Return ONE JSON object matching the response schema. Write in plain English that a non-expert can act on. Be gentle, specific and non-clinical: never diagnose or prescribe.

SCORING (healthScore 0–100, rating):
- Penalise ultra-processing, high sugar, sodium, saturated fat, trans fat and artificial additives.
- Reward whole ingredients, fibre, protein and healthier fats.
- rating: "good" (roughly 70–100), "okay" (40–69), "caution" (20–39), "avoid" (0–19).

CALORIES (caloriesKcal): per typical serving, not per 100 g (examples: 30 g chips, 250 ml drink, 1 biscuit, ~12 g chocolate). Use 0 only for true zero-calorie products such as water.

IDENTITY:
- productName is the consumer-facing product ("Dairy Milk Silk"); brand is the line ("Dairy Milk"); parentCompany is the owner ("Mondelez (formerly Cadbury)").
- category must stay specific: milk chocolate bar, cream-filled biscuit, salted potato chips, energy/protein bar, extruded corn snack, peanut-jaggery chikki, toned milk. An energy bar is not a chocolate bar; a chikki is not an extruded snack. Never copy nutrition numbers across categories.
- If the input is too unclear to analyse, set productName "Unidentified product", category "Unknown", and say in the summary that the image or barcode was not clear enough.
- A barcode's GS1 prefix is only a country-of-issue hint. Never infer a brand or product from it.

CONTENT:
- summary: 1–2 sentences.
- advantages and disadvantages: 3–6 short bullets each (fewer only if genuinely nothing applies).
- cautions: chemicals and ingredients worth a second look (additives, E/INS numbers, sweeteners, colours, preservatives, hydrogenated fats, high sugar/salt sources). For each: ingredient, concern (one sentence), severity low|medium|high, percentage (estimated share of the product such as "~12%", or "" if unknown), chemicalFormula and scientificName ("" if not a defined chemical).
- consumptionTip: safeDaily and limit amounts for this product, and source naming the real guideline the numbers come from (WHO, FDA, EFSA, ICMR-NIN, AHA, NIH). Never invent limits.
- riskProfile: what over-consumption can cause. Leave every list EMPTY when healthScore >= 75 or rating is "good". Otherwise each list has 2–5 short clauses specific to this product's ingredients and grounded in published guidance (WHO, FDA, EFSA, ICMR-NIN, AHA, NIH). Never invent diseases.
- bodyDamage / bodyBenefit: organs harmed or helped. part must be one of: brain, eyes, teeth, throat, heart, lungs, liver, stomach, pancreas, kidneys, intestines, skin, bones. severity low|medium|high, reason one sentence, trigger the nutrient or ingredient responsible.

DIETARY (dietaryType, always include dietaryReason naming the deciding ingredient):
- "vegan": entirely plant-based; no dairy, honey, egg or animal-derived additives.
- "veg": lacto-vegetarian; plants plus milk, butter, ghee, cheese, whey, casein or honey; no non-veg ingredients.
- "non-veg": meat, poultry, fish, seafood, gelatin, lard/tallow, animal rennet, carmine/cochineal (E120), shellac (E904), or EGG (Indian convention: egg is non-vegetarian).
- Mono- and diglycerides (E471) are vegetarian unless the source is clearly animal. Vitamin D3 from lanolin is vegetarian; D3 from lichen is vegan. L-cysteine is non-veg unless labelled microbial. Rennet is non-veg unless labelled microbial or vegetable.
- "unknown" only when the ingredient list is unreadable and brand/category give no reasonable inference.

PERSONAL ADVICE (personalAdvice):
- Use only the health profile provided. Mention any listed allergen found in the product, and conflicts with stated conditions (for example diabetes, hypertension, PCOS) when relevant. You may reference BMI or gender.
- If no health profile is provided, personalAdvice must be "".`;

export function healthContext(profile: HealthProfile | null): string {
  if (!profile) return "";
  const lines: string[] = [];
  if (profile.gender) lines.push(`Gender: ${profile.gender.replace("_", "-")}`);
  if (profile.age) lines.push(`Age: ${profile.age}`);
  if (profile.weightKg) lines.push(`Weight: ${profile.weightKg} kg`);
  if (profile.heightCm) lines.push(`Height: ${profile.heightCm} cm`);
  if (profile.weightKg && profile.heightCm) {
    const bmi = profile.weightKg / Math.pow(profile.heightCm / 100, 2);
    lines.push(`BMI: ${bmi.toFixed(1)}`);
  }
  if (profile.illnesses?.trim()) lines.push(`Conditions: ${profile.illnesses.trim()}`);
  if (profile.allergies?.trim()) lines.push(`Allergies: ${profile.allergies.trim()}`);
  return lines.join("\n");
}

function profileBlock(context: string): string {
  return context
    ? `HEALTH PROFILE (private, use only for personalAdvice):\n${context}`
    : "HEALTH PROFILE: none provided. personalAdvice must be \"\".";
}

export function ingredientsPrompt(text: string, context: string): string {
  return `Analyse this ingredient list pasted by the user.\n\nINGREDIENTS:\n${text}\n\n${profileBlock(context)}`;
}

export function imagePrompt(context: string): string {
  return `Analyse the packaged food in this label photo. Read the product name, brand and ingredient list from the image. If the ingredients are not legible, follow the "Unidentified product" rule.\n\n${profileBlock(context)}`;
}

export function registryPrompt(product: RegistryProduct, countryHint: string | null, context: string): string {
  const facts: string[] = [
    `Barcode: ${product.barcode}`,
    `Registry: ${product.source === "openfoodfacts" ? "Open Food Facts" : "UPCitemdb"}`,
  ];
  if (product.productName) facts.push(`Product name: ${product.productName}`);
  if (product.brand) facts.push(`Brand: ${product.brand}`);
  if (product.parentCompany) facts.push(`Brand owner: ${product.parentCompany}`);
  if (product.category) facts.push(`Category: ${product.category}`);
  if (product.quantity) facts.push(`Quantity: ${product.quantity}`);
  if (product.labels) facts.push(`Labels: ${product.labels}`);
  if (countryHint) facts.push(`GS1 country of issue (hint only, not a brand source): ${countryHint}`);
  if (product.nutriments && Object.keys(product.nutriments).length > 0) {
    facts.push(`Nutrition per 100 g (registry): ${JSON.stringify(product.nutriments)}`);
  }
  const ingredients = product.ingredientsText?.trim()
    ? `INGREDIENTS (registry):\n${product.ingredientsText.trim()}`
    : "INGREDIENTS: not available in the registry. Analyse from the nutrition data and the registry identity only.";
  return `Analyse this product found in a food registry. The identity fields (productName, brand, parentCompany, category) are LOCKED: copy them from the registry facts, do not rewrite or guess them.\n\n${facts.join("\n")}\n\n${ingredients}\n\n${profileBlock(context)}`;
}

export function personalAdvicePrompt(summary: string, ingredients: string | undefined, context: string): string {
  return `A product has already been analysed. Write only the personalAdvice for this user.\n\nANALYSIS SUMMARY: ${summary}\nINGREDIENTS: ${ingredients?.trim() || "not available"}\n\n${profileBlock(context)}\n\nReturn JSON: {"personalAdvice": "..."}. Use "" if nothing in the profile is relevant.`;
}

export const OCR_PROMPT =
  `Transcribe all text visible in this food-package photo, line by line, exactly as printed. Include every number, especially the digits printed under any barcode, keeping their spacing. Return JSON: {"text": "..."}.`;

const STRING = { type: "STRING" };
const STRING_LIST = { type: "ARRAY", items: STRING };
const SEVERITY = { type: "STRING", enum: ["low", "medium", "high"] };
const MARKER = {
  type: "OBJECT",
  properties: { part: STRING, severity: SEVERITY, reason: STRING, trigger: STRING },
  required: ["part", "severity", "reason"],
};

/** Gemini structured-output schema for PRD §11.1. */
export const RESULT_SCHEMA = {
  type: "OBJECT",
  properties: {
    productName: STRING,
    brand: STRING,
    parentCompany: STRING,
    category: STRING,
    rating: { type: "STRING", enum: ["good", "okay", "caution", "avoid"] },
    healthScore: { type: "INTEGER" },
    caloriesKcal: { type: "INTEGER" },
    summary: STRING,
    advantages: STRING_LIST,
    disadvantages: STRING_LIST,
    cautions: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: {
          ingredient: STRING,
          concern: STRING,
          severity: SEVERITY,
          percentage: STRING,
          chemicalFormula: STRING,
          scientificName: STRING,
        },
        required: ["ingredient", "concern", "severity"],
      },
    },
    personalAdvice: STRING,
    consumptionTip: {
      type: "OBJECT",
      properties: { safeDaily: STRING, limit: STRING, source: STRING },
      required: ["safeDaily", "limit", "source"],
    },
    riskProfile: {
      type: "OBJECT",
      properties: {
        illnesses: STRING_LIST,
        addictions: STRING_LIST,
        chronicDamage: STRING_LIST,
        temporaryEffects: STRING_LIST,
        organDamage: STRING_LIST,
      },
      required: ["illnesses", "addictions", "chronicDamage", "temporaryEffects", "organDamage"],
    },
    bodyDamage: { type: "ARRAY", items: MARKER },
    bodyBenefit: { type: "ARRAY", items: MARKER },
    dietaryType: { type: "STRING", enum: ["veg", "non-veg", "vegan", "unknown"] },
    dietaryReason: STRING,
  },
  required: [
    "productName",
    "rating",
    "healthScore",
    "caloriesKcal",
    "summary",
    "advantages",
    "disadvantages",
    "cautions",
    "personalAdvice",
    "consumptionTip",
    "riskProfile",
    "bodyDamage",
    "bodyBenefit",
    "dietaryType",
    "dietaryReason",
  ],
};
