// Pure Gemini calling logic for `ai-answer` (no Deno.serve, no Supabase), so it
// can be unit-tested with a mocked fetch. Only status codes are ever logged
// (never key, question or answer text).

export const API = "https://generativelanguage.googleapis.com/v1beta";
export const DEADLINE_MS = 45_000; // the app waits up to 60 s: keep a >= 15 s margin
export const ATTEMPT_MS = 12_000;
export const MIN_ATTEMPT_MS = 3_000;
export const BACKOFF_MS = 1_200;
export const MAX_MODELS = 4;
export const MAX_WEB_SOURCES = 8;

export type Mode = "kb" | "web";
export type FailKind = "quota" | "overloaded" | "upstream";
export type WebSource = { title: string; uri: string };

export type Deps = {
  fetchFn: typeof fetch;
  sleep: (ms: number) => Promise<void>;
  now: () => number;
  log: (...a: unknown[]) => void;
};

export const realDeps: Deps = {
  fetchFn: (...a) => fetch(...a),
  sleep: (ms) => new Promise((r) => setTimeout(r, ms)),
  now: () => Date.now(),
  log: (...a) => console.error(...a),
};

type ModelInfo = { name?: string; supportedGenerationMethods?: string[] };

/** Stable text "flash" models only: no image/tts/audio/live/embedding and no
 *  preview/experimental/omni variants (those return 429/400 in production). */
export function isStableFlash(name: string): boolean {
  return /flash/i.test(name) &&
    !/(image|tts|audio|live|embedding|omni|preview|exp|thinking|vision|robotics|computer|learnlm)/i
      .test(name);
}

/** Stable "*-flash" first (newest first), then "*-flash-lite". */
export function rankModels(models: ModelInfo[]): string[] {
  const names = models
    .filter((m) => (m.supportedGenerationMethods ?? []).includes("generateContent"))
    .map((m) => (m.name ?? "").replace(/^models\//, ""))
    .filter(isStableFlash);
  const byNewest = (a: string, b: string) => b.localeCompare(a);
  const lite = names.filter((n) => /lite/i.test(n)).sort(byNewest);
  const full = names.filter((n) => !/lite/i.test(n)).sort(byNewest);
  return [...full, ...lite];
}

/** Preferred (explicit FE_AI_MODEL may name anything, e.g. a preview) first. */
export function candidateList(preferred: string[], discovered: string[]): string[] {
  return [...new Set([...preferred, ...discovered])].slice(0, MAX_MODELS);
}

export async function discoverModels(key: string, d: Deps = realDeps): Promise<string[]> {
  try {
    const r = await d.fetchFn(`${API}/models?pageSize=200`, {
      headers: { "x-goog-api-key": key },
      signal: AbortSignal.timeout(5_000),
    });
    if (!r.ok) {
      d.log("gemini_models_status", r.status);
      return [];
    }
    const out = await r.json();
    return rankModels(out?.models ?? []);
  } catch (e) {
    d.log("gemini_models_failed", e instanceof Error ? e.name : "error");
    return [];
  }
}

export type CallOk = { ok: true; model: string; out: any };
export type CallFail = { ok: false; error: FailKind | "blocked"; status: number };

/** Classify the collected per-attempt outcomes into one app-facing error. */
export function classifyFailure(seen: (number | "timeout")[]): { error: FailKind; status: number } {
  if (seen.length > 0 && seen.every((s) => s === 429)) return { error: "quota", status: 429 };
  if (seen.some((s) => s === 503) && seen.every((s) => s === 429 || s === 503 || s === "timeout")) {
    return { error: "overloaded", status: 503 };
  }
  return { error: "upstream", status: 502 };
}

/**
 * Try models in order. 429 -> next model at once (quota, never retry the same
 * model); 503/500 -> one retry with backoff; 400 -> one retry without
 * thinkingConfig, then next model; 404/timeout/other -> next model.
 * `accept` may reject a 200 body (e.g. unparsable) -> next model.
 */
export async function callModels(
  key: string,
  models: string[],
  buildBody: (thinking: boolean) => unknown,
  accept: (out: any) => boolean,
  d: Deps = realDeps,
  started: number = d.now(),
): Promise<CallOk | CallFail> {
  const seen: (number | "timeout")[] = [];
  for (const model of models) {
    let thinking = true;
    let retried503 = false;
    for (;;) {
      const remaining = DEADLINE_MS - (d.now() - started);
      if (remaining < MIN_ATTEMPT_MS) {
        const c = classifyFailure(seen);
        return { ok: false, error: c.error, status: 504 };
      }
      const ctl = new AbortController();
      const timer = setTimeout(() => ctl.abort(), Math.min(ATTEMPT_MS, remaining));
      try {
        const r = await d.fetchFn(`${API}/models/${model}:generateContent`, {
          method: "POST",
          signal: ctl.signal,
          headers: { "Content-Type": "application/json", "x-goog-api-key": key },
          body: JSON.stringify(buildBody(thinking)),
        });
        if (!r.ok) {
          d.log("gemini_status", model, r.status, thinking ? "t" : "n");
          if (r.status === 400 && thinking) {
            thinking = false; // retry once without thinkingConfig
            seen.push(400);
            continue;
          }
          if ((r.status === 503 || r.status === 500) && !retried503) {
            retried503 = true;
            seen.push(r.status);
            await d.sleep(BACKOFF_MS);
            continue;
          }
          seen.push(r.status); // 429 and everything else: next model
          break;
        }
        const out = await r.json();
        if (out?.promptFeedback?.blockReason) {
          d.log("gemini_blocked", model);
          return { ok: false, error: "blocked", status: 422 };
        }
        if (!accept(out)) {
          d.log("gemini_unparsable", model, out?.candidates?.[0]?.finishReason ?? "none");
          seen.push(-1);
          break;
        }
        return { ok: true, model, out };
      } catch (e) {
        d.log("gemini_fetch_failed", model, e instanceof Error ? e.name : "error");
        seen.push("timeout");
        break;
      } finally {
        clearTimeout(timer);
      }
    }
  }
  const c = classifyFailure(seen);
  return { ok: false, error: c.error, status: c.status };
}

export function partsText(out: any): string {
  return out?.candidates?.[0]?.content?.parts
    ?.map((p: { text?: string; thought?: boolean }) => (p.thought ? "" : p.text ?? ""))
    .join("") ?? "";
}

/** Deduplicated http(s) sources from groundingMetadata.groundingChunks. */
export function webSourcesOf(out: any): WebSource[] {
  const chunks = out?.candidates?.[0]?.groundingMetadata?.groundingChunks;
  if (!Array.isArray(chunks)) return [];
  const seen = new Set<string>();
  const res: WebSource[] = [];
  for (const c of chunks) {
    const uri = String(c?.web?.uri ?? "").trim();
    if (!/^https?:\/\//i.test(uri) || seen.has(uri)) continue;
    seen.add(uri);
    const title = String(c?.web?.title ?? "").trim().slice(0, 200);
    res.push({ title: title || uri, uri });
    if (res.length >= MAX_WEB_SOURCES) break;
  }
  return res;
}

export function kbBody(system: string, prompt: string) {
  return (thinking: boolean) => {
    const generationConfig: Record<string, unknown> = {
      temperature: 0.1,
      maxOutputTokens: 4096, // JSON mode: a truncated object is unparsable
      responseMimeType: "application/json",
    };
    if (thinking) generationConfig.thinkingConfig = { thinkingBudget: 0 };
    return {
      systemInstruction: { parts: [{ text: system }] },
      contents: [{ role: "user", parts: [{ text: prompt }] }],
      generationConfig,
    };
  };
}

export function webBody(system: string, prompt: string) {
  return (thinking: boolean) => {
    // Grounding does not support responseMimeType JSON: plain text only.
    const generationConfig: Record<string, unknown> = { temperature: 0.2, maxOutputTokens: 2048 };
    if (thinking) generationConfig.thinkingConfig = { thinkingBudget: 0 };
    return {
      systemInstruction: { parts: [{ text: system }] },
      contents: [{ role: "user", parts: [{ text: prompt }] }],
      tools: [{ google_search: {} }],
      generationConfig,
    };
  };
}
