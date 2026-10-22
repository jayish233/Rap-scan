// PRD §11.1 scan result + pipeline types.

export const ORGAN_KEYS = [
  "brain",
  "eyes",
  "teeth",
  "throat",
  "heart",
  "lungs",
  "liver",
  "stomach",
  "pancreas",
  "kidneys",
  "intestines",
  "skin",
  "bones",
] as const;
export type OrganKey = (typeof ORGAN_KEYS)[number];

export type Severity = "low" | "medium" | "high";
export type Rating = "good" | "okay" | "caution" | "avoid";
export type DietaryType = "veg" | "non-veg" | "vegan" | "unknown";
export type Plan = "free" | "pro" | "pro_plus" | "pro_max";

export interface Caution {
  ingredient: string;
  concern: string;
  severity: Severity;
  percentage?: string;
  chemicalFormula?: string;
  scientificName?: string;
}

export interface BodyMarker {
  part: OrganKey;
  severity: Severity;
  reason: string;
  trigger?: string;
}

export interface ConsumptionTip {
  safeDaily: string;
  limit: string;
  source: string;
}

export interface RiskProfile {
  illnesses: string[];
  addictions: string[];
  chronicDamage: string[];
  temporaryEffects: string[];
  organDamage: string[];
}

export interface ScanResult {
  productName: string;
  brand?: string;
  parentCompany?: string;
  category?: string;
  rating: Rating;
  healthScore: number;
  caloriesKcal: number;
  summary: string;
  advantages: string[];
  disadvantages: string[];
  cautions: Caution[];
  personalAdvice?: string;
  consumptionTip?: ConsumptionTip;
  riskProfile?: RiskProfile;
  bodyDamage?: BodyMarker[];
  bodyBenefit?: BodyMarker[];
  dietaryType?: DietaryType;
  dietaryReason?: string;
}

export interface Nutriments {
  [key: string]: number | string | undefined;
}

export interface RegistryProduct {
  source: "openfoodfacts" | "upcitemdb";
  barcode: string;
  productName?: string;
  brand?: string;
  parentCompany?: string;
  category?: string;
  quantity?: string;
  labels?: string;
  ingredientsText?: string;
  nutriments?: Nutriments;
}

export interface QuotaInfo {
  remaining: number;
  scanLimit: number;
  plan: Plan;
  planLabel: string;
  isUnlimited: boolean;
}

export type QuotaResult =
  | ({ ok: true } & QuotaInfo)
  | ({ ok: false; error: "quota_exceeded" } & QuotaInfo)
  | { ok: false; error: "profile_not_found" };

export interface HealthProfile {
  gender?: string | null;
  age?: number | null;
  weightKg?: number | null;
  heightCm?: number | null;
  illnesses?: string | null;
  allergies?: string | null;
}

export interface ScanRequest {
  scanType: "ingredients" | "barcode";
  text?: string;
  barcode?: string;
  imageDataUrl?: string;
}
