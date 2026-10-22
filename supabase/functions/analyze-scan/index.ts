// analyze-scan edge function entry point. Wires the pipeline to Supabase,
// the food registries and Gemini. Secrets come only from the function env.

import { createClient } from "npm:@supabase/supabase-js@2.45.4";
import { GeminiModel } from "./gemini.ts";
import { MESSAGES } from "./messages.ts";
import { type CachedAnalysis, type Deps, runScan, type Store } from "./pipeline.ts";
import { lookupOpenFoodFacts, lookupUpcItemDb } from "./registries.ts";
import type { HealthProfile, QuotaResult } from "./types.ts";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

function env(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`Missing env ${name}`);
  return value;
}

const admin = createClient(env("SUPABASE_URL"), env("SUPABASE_SERVICE_ROLE_KEY"), {
  auth: { persistSession: false, autoRefreshToken: false },
});

const store: Store = {
  async consumeQuota(userId) {
    const { data, error } = await admin.rpc("consume_quota", { p_user: userId });
    if (error) throw error;
    return data as QuotaResult;
  },

  async loadHealthProfile(userId) {
    const { data, error } = await admin
      .from("profiles")
      .select("gender, age, weight_kg, height_cm, illnesses, allergies")
      .eq("id", userId)
      .maybeSingle();
    if (error) throw error;
    if (!data) return null;
    const profile: HealthProfile = {
      gender: data.gender,
      age: data.age,
      weightKg: data.weight_kg === null ? null : Number(data.weight_kg),
      heightCm: data.height_cm === null ? null : Number(data.height_cm),
      illnesses: data.illnesses,
      allergies: data.allergies,
    };
    return profile;
  },

  async getCachedAnalysis(barcode) {
    const { data, error } = await admin
      .from("barcode_cache")
      .select("result")
      .eq("barcode", barcode)
      .maybeSingle();
    if (error) throw error;
    return (data?.result as CachedAnalysis | undefined) ?? null;
  },

  async putCachedAnalysis(barcode, entry) {
    const { error } = await admin
      .from("barcode_cache")
      .upsert({ barcode, result: entry, updated_at: new Date().toISOString() });
    if (error) throw error;
  },

  async insertScan(row) {
    const { data, error } = await admin
      .from("scans")
      .insert({
        user_id: row.userId,
        product_name: row.productName,
        scan_type: row.scanType,
        rating: row.rating,
        health_score: row.healthScore,
        calories_kcal: row.caloriesKcal,
        summary: row.summary,
        input_text: row.inputText,
        result: row.result,
      })
      .select("id")
      .single();
    if (error) throw error;
    return data.id as string;
  },
};

const deps: Deps = {
  store,
  registries: { openFoodFacts: lookupOpenFoodFacts, upcItemDb: lookupUpcItemDb },
  model: new GeminiModel(env("GEMINI_API_KEY")),
  // Never log ingredient text, photos or health fields (PRD §13).
  log: (message, extra) => console.error(JSON.stringify({ message, ...extra })),
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });
  if (req.method !== "POST") return json(405, { error: "validation", message: "Method not allowed." });

  const jwt = req.headers.get("Authorization")?.replace(/^Bearer\s+/i, "");
  if (!jwt) return json(401, { error: "unauthorized", message: "Sign in to scan." });
  const { data: auth, error: authError } = await admin.auth.getUser(jwt);
  if (authError || !auth.user) return json(401, { error: "unauthorized", message: "Sign in to scan." });

  let body: unknown;
  try {
    body = await req.json();
  } catch {
    return json(400, { error: "validation", message: "Invalid request." });
  }

  try {
    const { status, body: out } = await runScan(auth.user.id, body, deps);
    return json(status, out);
  } catch (e) {
    // Failures before quota (e.g. the quota RPC itself) consume nothing.
    deps.log?.("unhandled", { detail: String(e) });
    return json(503, { error: "ai_unavailable", message: MESSAGES.aiUnavailable });
  }
});
