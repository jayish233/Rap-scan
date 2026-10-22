// Gemini 2.5 Flash client, JSON mode (architecture.md §3.3). The API key
// lives only in the edge-function environment.

import {
  imagePrompt,
  ingredientsPrompt,
  OCR_PROMPT,
  personalAdvicePrompt,
  registryPrompt,
  RESULT_SCHEMA,
  SYSTEM_INSTRUCTIONS,
} from "./prompt.ts";
import type { RegistryProduct } from "./types.ts";

const MODEL = "gemini-2.5-flash";
const ENDPOINT = `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent`;
const TIMEOUT_MS = 60_000;

export type ModelErrorCode = "rate_limited" | "ai_unavailable" | "ai_credits_exhausted";

export class ModelError extends Error {
  constructor(public code: ModelErrorCode, detail: string) {
    super(detail);
  }
}

export interface Image {
  mimeType: string;
  base64: string;
}

/** What the pipeline needs from a model; swapped for a fake in tests. */
export interface AnalysisModel {
  analyzeIngredients(text: string, healthContext: string): Promise<Record<string, unknown>>;
  analyzeImage(image: Image, healthContext: string): Promise<Record<string, unknown>>;
  analyzeRegistryProduct(
    product: RegistryProduct,
    countryHint: string | null,
    healthContext: string,
  ): Promise<Record<string, unknown>>;
  readImageText(image: Image): Promise<string>;
  personalAdvice(summary: string, ingredients: string | undefined, healthContext: string): Promise<string>;
}

export function parseDataUrl(dataUrl: string): Image | null {
  const match = /^data:(image\/[a-z0-9.+-]+);base64,([A-Za-z0-9+/=\s]+)$/i.exec(dataUrl);
  return match ? { mimeType: match[1].toLowerCase(), base64: match[2].replace(/\s/g, "") } : null;
}

export class GeminiModel implements AnalysisModel {
  constructor(private apiKey: string, private fetchImpl: typeof fetch = fetch) {}

  analyzeIngredients(text: string, ctx: string) {
    return this.generate([{ text: ingredientsPrompt(text, ctx) }], RESULT_SCHEMA);
  }

  analyzeImage(image: Image, ctx: string) {
    return this.generate([{ text: imagePrompt(ctx) }, inline(image)], RESULT_SCHEMA);
  }

  analyzeRegistryProduct(product: RegistryProduct, countryHint: string | null, ctx: string) {
    return this.generate([{ text: registryPrompt(product, countryHint, ctx) }], RESULT_SCHEMA);
  }

  async readImageText(image: Image): Promise<string> {
    const out = await this.generate([{ text: OCR_PROMPT }, inline(image)], {
      type: "OBJECT",
      properties: { text: { type: "STRING" } },
      required: ["text"],
    }, false);
    return typeof out.text === "string" ? out.text : "";
  }

  async personalAdvice(summary: string, ingredients: string | undefined, ctx: string): Promise<string> {
    const out = await this.generate([{ text: personalAdvicePrompt(summary, ingredients, ctx) }], {
      type: "OBJECT",
      properties: { personalAdvice: { type: "STRING" } },
      required: ["personalAdvice"],
    });
    return typeof out.personalAdvice === "string" ? out.personalAdvice.trim() : "";
  }

  private async generate(
    parts: unknown[],
    schema: unknown,
    withSystem = true,
  ): Promise<Record<string, unknown>> {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), TIMEOUT_MS);
    let res: Response;
    try {
      res = await this.fetchImpl(ENDPOINT, {
        method: "POST",
        headers: { "Content-Type": "application/json", "x-goog-api-key": this.apiKey },
        signal: controller.signal,
        body: JSON.stringify({
          ...(withSystem ? { systemInstruction: { parts: [{ text: SYSTEM_INSTRUCTIONS }] } } : {}),
          contents: [{ role: "user", parts }],
          generationConfig: {
            temperature: 0,
            responseMimeType: "application/json",
            responseSchema: schema,
          },
        }),
      });
    } catch (e) {
      throw new ModelError("ai_unavailable", `request failed: ${e}`);
    } finally {
      clearTimeout(timer);
    }

    if (!res.ok) {
      const detail = await res.text().catch(() => "");
      if (res.status === 429) throw new ModelError("rate_limited", detail);
      if (res.status === 402) throw new ModelError("ai_credits_exhausted", detail);
      throw new ModelError("ai_unavailable", `HTTP ${res.status}: ${detail.slice(0, 500)}`);
    }

    const body = await res.json().catch(() => null) as
      | { candidates?: Array<{ content?: { parts?: Array<{ text?: string }> } }> }
      | null;
    const text = body?.candidates?.[0]?.content?.parts?.map((p) => p.text ?? "").join("") ?? "";
    try {
      const parsed = JSON.parse(text);
      if (parsed && typeof parsed === "object" && !Array.isArray(parsed)) return parsed;
    } catch {
      // fall through
    }
    throw new ModelError("ai_unavailable", "model returned non-JSON output");
  }
}

function inline(image: Image) {
  return { inline_data: { mime_type: image.mimeType, data: image.base64 } };
}
