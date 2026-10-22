// Normalising model output and tier gating (PRD §8, §10 steps 10–11).

import {
  type BodyMarker,
  type Caution,
  type ConsumptionTip,
  type DietaryType,
  ORGAN_KEYS,
  type OrganKey,
  type Plan,
  type Rating,
  type RiskProfile,
  type ScanResult,
  type Severity,
} from "./types.ts";

const RATINGS: Rating[] = ["good", "okay", "caution", "avoid"];
const SEVERITIES: Severity[] = ["low", "medium", "high"];
const DIETARY: DietaryType[] = ["veg", "non-veg", "vegan", "unknown"];
const RISK_KEYS: Array<keyof RiskProfile> = [
  "illnesses",
  "addictions",
  "chronicDamage",
  "temporaryEffects",
  "organDamage",
];

export function clamp(value: unknown, min: number, max: number): number {
  const n = typeof value === "number" ? value : Number(value);
  if (!Number.isFinite(n)) return min;
  return Math.min(max, Math.max(min, Math.round(n)));
}

function str(value: unknown): string | undefined {
  if (typeof value !== "string") return undefined;
  const trimmed = value.trim();
  return trimmed === "" ? undefined : trimmed;
}

// Model placeholders that must never be shown as a real brand or owner.
const PLACEHOLDER = /^(unknown|unidentified|generic|n\/?a|none|not (stated|specified|available|provided))\b/i;

function identity(value: unknown): string | undefined {
  const s = str(value);
  return s && !PLACEHOLDER.test(s) ? s : undefined;
}

function strList(value: unknown, max = 8): string[] {
  if (!Array.isArray(value)) return [];
  return value.map(str).filter((s): s is string => !!s).slice(0, max);
}

function oneOf<T extends string>(value: unknown, allowed: readonly T[], fallback: T): T {
  return allowed.includes(value as T) ? (value as T) : fallback;
}

function markers(value: unknown): BodyMarker[] {
  if (!Array.isArray(value)) return [];
  const seen = new Set<OrganKey>();
  const out: BodyMarker[] = [];
  for (const raw of value) {
    const part = typeof raw?.part === "string" ? raw.part.toLowerCase().trim() : "";
    if (!(ORGAN_KEYS as readonly string[]).includes(part) || seen.has(part as OrganKey)) continue;
    const reason = str(raw.reason);
    if (!reason) continue;
    seen.add(part as OrganKey);
    out.push({
      part: part as OrganKey,
      severity: oneOf(raw.severity, SEVERITIES, "low"),
      reason,
      ...(str(raw.trigger) ? { trigger: str(raw.trigger) } : {}),
    });
  }
  return out;
}

/** Turn untrusted model JSON into a valid PRD §11.1 result, clamping numbers. */
export function normaliseResult(raw: Record<string, unknown>): ScanResult {
  const healthScore = clamp(raw.healthScore, 0, 100);
  const rating = oneOf(raw.rating, RATINGS, healthScore >= 70 ? "good" : healthScore >= 40 ? "okay" : healthScore >= 20 ? "caution" : "avoid");

  const cautions: Caution[] = Array.isArray(raw.cautions)
    ? raw.cautions
      .map((c: Record<string, unknown>) => ({
        ingredient: str(c?.ingredient) ?? "",
        concern: str(c?.concern) ?? "",
        severity: oneOf(c?.severity, SEVERITIES, "low"),
        ...(str(c?.percentage) ? { percentage: str(c.percentage) } : {}),
        ...(str(c?.chemicalFormula) ? { chemicalFormula: str(c.chemicalFormula) } : {}),
        ...(str(c?.scientificName) ? { scientificName: str(c.scientificName) } : {}),
      }))
      .filter((c) => c.ingredient && c.concern)
    : [];

  const tipRaw = raw.consumptionTip as Record<string, unknown> | undefined;
  const consumptionTip: ConsumptionTip | undefined =
    str(tipRaw?.safeDaily) && str(tipRaw?.limit) && str(tipRaw?.source)
      ? { safeDaily: str(tipRaw!.safeDaily)!, limit: str(tipRaw!.limit)!, source: str(tipRaw!.source)! }
      : undefined;

  // Risk profile is empty for clearly healthy products (PRD §11.1).
  const healthy = healthScore >= 75 || rating === "good";
  const riskRaw = (raw.riskProfile ?? {}) as Record<string, unknown>;
  const riskProfile = Object.fromEntries(
    RISK_KEYS.map((k) => [k, healthy ? [] : strList(riskRaw[k], 5)]),
  ) as unknown as RiskProfile;

  return {
    productName: str(raw.productName) ?? "Unidentified product",
    ...(identity(raw.brand) ? { brand: identity(raw.brand) } : {}),
    ...(identity(raw.parentCompany) ? { parentCompany: identity(raw.parentCompany) } : {}),
    ...(str(raw.category) ? { category: str(raw.category) } : {}),
    rating,
    healthScore,
    caloriesKcal: clamp(raw.caloriesKcal, 0, 5000),
    summary: str(raw.summary) ?? "",
    advantages: strList(raw.advantages, 6),
    disadvantages: strList(raw.disadvantages, 6),
    cautions,
    ...(str(raw.personalAdvice) ? { personalAdvice: str(raw.personalAdvice) } : {}),
    ...(consumptionTip ? { consumptionTip } : {}),
    riskProfile,
    bodyDamage: markers(raw.bodyDamage),
    bodyBenefit: markers(raw.bodyBenefit),
    dietaryType: oneOf(raw.dietaryType, DIETARY, "unknown"),
    ...(str(raw.dietaryReason) ? { dietaryReason: str(raw.dietaryReason) } : {}),
  };
}

/** Pro Max features: pro_max plan, or an unlimited role (PRD §8). */
export function isProMax(plan: Plan | "unlimited", isUnlimited: boolean): boolean {
  return plan === "pro_max" || plan === "unlimited" || isUnlimited;
}

/**
 * Omit fields the caller's effective plan does not include (PRD §8 matrix).
 * Free: no %, formula, guide, risk, dietary, body map. Pro: % folded into the
 * concern text. Pro+: % field, formula/scientific name, consumption guide.
 * Pro Max / unlimited: everything.
 */
export function gateForPlan(result: ScanResult, plan: Plan, isUnlimited: boolean): ScanResult {
  if (isProMax(plan, isUnlimited)) return structuredClone(result);

  const {
    consumptionTip,
    riskProfile: _risk,
    bodyDamage: _damage,
    bodyBenefit: _benefit,
    dietaryType: _dietary,
    dietaryReason: _reason,
    ...base
  } = structuredClone(result);

  const cautions = base.cautions.map(({ percentage, chemicalFormula, scientificName, ...c }) => {
    if (plan === "pro_plus") {
      return {
        ...c,
        ...(percentage ? { percentage } : {}),
        ...(chemicalFormula ? { chemicalFormula } : {}),
        ...(scientificName ? { scientificName } : {}),
      };
    }
    if (plan === "pro" && percentage) {
      return { ...c, concern: `${c.concern} (estimated ${percentage} of the product)` };
    }
    return c;
  });

  return {
    ...base,
    cautions,
    ...(plan === "pro_plus" && consumptionTip ? { consumptionTip } : {}),
  };
}

/** The shared cache never carries anyone's personal advice. */
export function withoutPersonalAdvice(result: ScanResult): ScanResult {
  const { personalAdvice: _p, ...rest } = result;
  return rest;
}
