import { assertEquals, assertRejects } from "jsr:@std/assert@1";
import { GeminiModel, isQuotaExhausted, ModelError } from "./gemini.ts";

function reply(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json" } });
}

const OK = { candidates: [{ content: { parts: [{ text: '{"personalAdvice":"ok"}' }] } }] };

function fakeFetch(statuses: number[]) {
  const calls: number[] = [];
  const impl = (() => {
    const status = statuses[calls.length] ?? 200;
    calls.push(status);
    return Promise.resolve(status === 200 ? reply(200, OK) : reply(status, { error: { message: "busy" } }));
  }) as typeof fetch;
  return { impl, calls };
}

Deno.test("retries transient 503 overloads, then succeeds", async () => {
  const f = fakeFetch([503, 503, 200]);
  const model = new GeminiModel("k", f.impl, [0, 0]);
  assertEquals(await model.personalAdvice("s", undefined, "Allergies: peanuts"), "ok");
  assertEquals(f.calls, [503, 503, 200]);
});

Deno.test("gives up after the retry budget with ai_unavailable", async () => {
  const f = fakeFetch([503, 503, 503, 503, 200]);
  const model = new GeminiModel("k", f.impl, [0, 0, 0]);
  const e = await assertRejects(() => model.personalAdvice("s", undefined, "x"), ModelError);
  assertEquals(e.code, "ai_unavailable");
  assertEquals(f.calls.length, 4);
});

Deno.test("does not retry rate limits or client errors", async () => {
  for (const [status, code] of [[429, "rate_limited"], [400, "ai_unavailable"]] as const) {
    const f = fakeFetch([status, 200]);
    const model = new GeminiModel("k", f.impl, [0, 0]);
    const e = await assertRejects(() => model.personalAdvice("s", undefined, "x"), ModelError);
    assertEquals(e.code, code);
    assertEquals(f.calls.length, 1);
  }
});

Deno.test("429 with an exhausted daily/free-tier quota → ai_credits_exhausted", async () => {
  const body = {
    error: {
      code: 429,
      message: "You exceeded your current quota, please check your plan and billing details.",
      details: [{ "@type": "type.googleapis.com/google.rpc.RetryInfo", retryDelay: "79440s" }],
    },
  };
  const impl = (() => Promise.resolve(reply(429, body))) as typeof fetch;
  const e = await assertRejects(() => new GeminiModel("k", impl, []).personalAdvice("s", undefined, "x"), ModelError);
  assertEquals(e.code, "ai_credits_exhausted");
});

Deno.test("isQuotaExhausted: short bursts are plain rate limits", () => {
  assertEquals(isQuotaExhausted('{"error":{"message":"Resource exhausted","details":[{"retryDelay":"7s"}]}}'), false);
  assertEquals(isQuotaExhausted('{"error":{"message":"Quota exceeded for metric: generate_content_free_tier_requests"}}'), true);
  assertEquals(isQuotaExhausted('{"error":{"details":[{"retryDelay":"3600s"}]}}'), true);
});

Deno.test("falls back to next model when primary model free-tier quota is exhausted", async () => {
  const f = fakeFetch([429, 200]);
  const model = new GeminiModel("k", f.impl, [], ["gemini-2.5-flash", "gemini-2.5-flash-lite"]);
  assertEquals(await model.personalAdvice("s", undefined, "Allergies: peanuts"), "ok");
  assertEquals(f.calls, [429, 200]);
});

