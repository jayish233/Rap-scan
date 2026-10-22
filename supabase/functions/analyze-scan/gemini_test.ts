import { assertEquals, assertRejects } from "jsr:@std/assert@1";
import { GeminiModel, ModelError } from "./gemini.ts";

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
  const f = fakeFetch([503, 503, 503, 200]);
  const model = new GeminiModel("k", f.impl, [0, 0]);
  const e = await assertRejects(() => model.personalAdvice("s", undefined, "x"), ModelError);
  assertEquals(e.code, "ai_unavailable");
  assertEquals(f.calls.length, 3);
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
