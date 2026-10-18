// Unit tests for the Gemini calling logic. fetch is mocked: no network call.
import { assert, assertEquals } from "jsr:@std/assert@1";
import {
  callModels,
  classifyFailure,
  type Deps,
  isStableFlash,
  kbBody,
  partsText,
  rankModels,
  webBody,
  webSourcesOf,
} from "./gemini.ts";

type Step = { status: number; body?: unknown } | "abort";

function mock(steps: Record<string, Step[]>, clock = { t: 0 }) {
  const calls: { model: string; body: any }[] = [];
  const sleeps: number[] = [];
  const deps: Deps = {
    fetchFn: ((url: string, init?: RequestInit) => {
      const model = /models\/([^:]+):generateContent/.exec(String(url))![1];
      calls.push({ model, body: JSON.parse(String(init?.body)) });
      const step = (steps[model] ?? []).shift();
      if (!step) return Promise.resolve(new Response("{}", { status: 404 }));
      if (step === "abort") {
        return Promise.reject(Object.assign(new Error("aborted"), { name: "AbortError" }));
      }
      return Promise.resolve(new Response(JSON.stringify(step.body ?? {}), { status: step.status }));
    }) as typeof fetch,
    sleep: (ms) => {
      sleeps.push(ms);
      clock.t += ms;
      return Promise.resolve();
    },
    now: () => clock.t,
    log: () => {},
  };
  return { deps, calls, sleeps };
}

const okKb = (text: string, cited: string[] = []) => ({
  status: 200,
  body: { candidates: [{ content: { parts: [{ text: JSON.stringify({ text, cited }) }] } }] },
});
const accept = () => true;
const kb = kbBody("sys", "prompt");

Deno.test("429 skips to the next model without retrying the same one", async () => {
  const m = mock({ a: [{ status: 429 }], b: [okKb("hi", ["c1"])] });
  const r = await callModels("k", ["a", "b"], kb, accept, m.deps);
  assert(r.ok);
  if (r.ok) assertEquals(r.model, "b");
  assertEquals(m.calls.map((c) => c.model), ["a", "b"]);
  assertEquals(m.sleeps, []);
});

Deno.test("503 is retried once with backoff on the same model", async () => {
  const m = mock({ a: [{ status: 503 }, okKb("hi")] });
  const r = await callModels("k", ["a", "b"], kb, accept, m.deps);
  assert(r.ok);
  assertEquals(m.calls.map((c) => c.model), ["a", "a"]);
  assertEquals(m.sleeps, [1200]);
});

Deno.test("second 503 moves on to the next model", async () => {
  const m = mock({ a: [{ status: 503 }, { status: 503 }], b: [okKb("hi")] });
  const r = await callModels("k", ["a", "b"], kb, accept, m.deps);
  assert(r.ok);
  assertEquals(m.calls.map((c) => c.model), ["a", "a", "b"]);
});

Deno.test("400 is retried once without thinkingConfig, then next model", async () => {
  const m = mock({ a: [{ status: 400 }, { status: 400 }], b: [okKb("hi")] });
  const r = await callModels("k", ["a", "b"], kb, accept, m.deps);
  assert(r.ok);
  assertEquals(m.calls.map((c) => c.model), ["a", "a", "b"]);
  assert(m.calls[0].body.generationConfig.thinkingConfig);
  assertEquals(m.calls[1].body.generationConfig.thinkingConfig, undefined);
});

Deno.test("all 429 -> quota", async () => {
  const m = mock({ a: [{ status: 429 }], b: [{ status: 429 }] });
  const r = await callModels("k", ["a", "b"], kb, accept, m.deps);
  assertEquals(r.ok, false);
  if (!r.ok) assertEquals([r.error, r.status], ["quota", 429]);
});

Deno.test("503s (and timeouts) -> overloaded", async () => {
  const m = mock({ a: [{ status: 503 }, { status: 503 }], b: ["abort"] });
  const r = await callModels("k", ["a", "b"], kb, accept, m.deps);
  if (!r.ok) assertEquals([r.error, r.status], ["overloaded", 503]);
  else throw new Error("expected failure");
});

Deno.test("other statuses -> upstream", () => {
  assertEquals(classifyFailure([503, 429, 400]).error, "upstream");
  assertEquals(classifyFailure([]).error, "upstream");
  assertEquals(classifyFailure([429, 429]).error, "quota");
  assertEquals(classifyFailure([503, 429, "timeout"]).error, "overloaded");
});

Deno.test("blockReason is surfaced as blocked", async () => {
  const m = mock({ a: [{ status: 200, body: { promptFeedback: { blockReason: "SAFETY" } } }] });
  const r = await callModels("k", ["a"], kb, accept, m.deps);
  if (!r.ok) assertEquals([r.error, r.status], ["blocked", 422]);
  else throw new Error("expected failure");
});

Deno.test("deadline stops further attempts", async () => {
  const clock = { t: 0 };
  const m = mock({ a: [{ status: 503 }, { status: 503 }] }, clock);
  m.deps.sleep = (ms) => {
    clock.t += ms + 44_000; // simulate a very slow retry
    return Promise.resolve();
  };
  const r = await callModels("k", ["a", "b"], kb, accept, m.deps, 0);
  assertEquals(r.ok, false);
  assertEquals(m.calls.length, 1);
});

Deno.test("rankModels drops preview/omni/exp, stable flash before lite", () => {
  const gen = ["generateContent"];
  const names = [
    "models/gemini-omni-flash-preview",
    "models/gemini-2.5-flash-lite",
    "models/gemini-2.5-flash",
    "models/gemini-3-flash-preview",
    "models/gemini-2.0-flash-exp",
    "models/gemini-2.5-flash-image",
    "models/gemini-2.0-flash",
  ];
  const ranked = rankModels(names.map((name) => ({ name, supportedGenerationMethods: gen })));
  assertEquals(ranked, ["gemini-2.5-flash", "gemini-2.0-flash", "gemini-2.5-flash-lite"]);
  assertEquals(isStableFlash("gemini-omni-1.1-flash"), false);
  assertEquals(isStableFlash("gemini-flash-latest"), true);
  assertEquals(rankModels([{ name: "models/gemini-2.5-flash", supportedGenerationMethods: [] }]), []);
});

Deno.test("kb body keeps JSON mime; web body uses google_search and plain text", () => {
  const k = kbBody("s", "p")(true) as any;
  assertEquals(k.generationConfig.responseMimeType, "application/json");
  assertEquals(k.tools, undefined);
  const w = webBody("s", "p")(true) as any;
  assertEquals(w.tools, [{ google_search: {} }]);
  assertEquals(w.generationConfig.responseMimeType, undefined);
});

Deno.test("web mode: text and deduplicated groundingChunks sources (max 8)", async () => {
  const chunks = [
    { web: { uri: "https://a.org/x", title: "A" } },
    { web: { uri: "https://a.org/x", title: "A again" } },
    { web: { uri: "javascript:alert(1)", title: "bad" } },
    { web: { uri: "https://b.org/y" } },
    ...Array.from({ length: 12 }, (_, i) => ({ web: { uri: `https://s${i}.org`, title: `S${i}` } })),
  ];
  const body = {
    candidates: [{
      content: { parts: [{ text: "Plain ", thought: false }, { text: "answer" }, { text: "hidden", thought: true }] },
      groundingMetadata: { groundingChunks: chunks },
    }],
  };
  const m = mock({ a: [{ status: 200, body }] });
  const r = await callModels("k", ["a"], webBody("s", "p"), (o) => partsText(o).length > 0, m.deps);
  assert(r.ok);
  if (r.ok) {
    assertEquals(partsText(r.out), "Plain answer");
    const src = webSourcesOf(r.out);
    assertEquals(src.length, 8);
    assertEquals(src[0], { title: "A", uri: "https://a.org/x" });
    assertEquals(src[1], { title: "https://b.org/y", uri: "https://b.org/y" });
  }
  assertEquals(m.calls[0].body.tools, [{ google_search: {} }]);
  assertEquals(webSourcesOf({}), []);
});
