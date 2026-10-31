// Pure helpers for the `tts` Edge Function (no Deno.serve, no Supabase) so they
// can be unit-tested with a mocked fetch. Nothing here logs text or keys.

export const API = "https://generativelanguage.googleapis.com/v1beta";
export const SAMPLE_RATE = 24_000;
export const MAX_TEXT_CHARS = 4_000;
export const MAX_CHUNK_CHARS = 700;
export const MAX_STYLE_CHARS = 120;
export const ATTEMPT_MS = 60_000;
export const RETRIES = 3;

export type Deps = {
  fetchFn: typeof fetch;
  sleep: (ms: number) => Promise<void>;
};

export const realDeps: Deps = {
  fetchFn: (...a) => fetch(...a),
  sleep: (ms) => new Promise((r) => setTimeout(r, ms)),
};

/** Control characters out, whitespace tidied; letters, o‘/g‘ apostrophes and
 *  inline tags like `<short pause>` are kept verbatim. */
export function cleanText(s: unknown, max = MAX_TEXT_CHARS): string {
  return String(s ?? "")
    .replace(/[\u0000-\u0009\u000B\u000C\u000E-\u001F\u007F]/g, " ")
    .replace(/\r\n?/g, "\n")
    .replace(/[ \t]+/g, " ")
    .replace(/\n{3,}/g, "\n\n")
    .trim()
    .slice(0, max);
}

/** Paragraphs first; a paragraph longer than [max] is cut at sentence ends
 *  (then at spaces) so every chunk stays a natural reading unit. */
export function splitText(text: string, max = MAX_CHUNK_CHARS): string[] {
  const out: string[] = [];
  for (const para of text.split(/\n\s*\n/).map((p) => p.trim()).filter(Boolean)) {
    if (para.length <= max) {
      out.push(para);
      continue;
    }
    let cur = "";
    for (const sentence of para.match(/[^.!?…]+[.!?…]+["»”)]*\s*|[^.!?…]+$/g) ?? [para]) {
      const s = sentence.trim();
      if (!s) continue;
      if ((cur + " " + s).trim().length <= max) {
        cur = (cur + " " + s).trim();
        continue;
      }
      if (cur) out.push(cur);
      cur = "";
      if (s.length <= max) {
        cur = s;
        continue;
      }
      let rest = s;
      while (rest.length > max) {
        const cut = rest.lastIndexOf(" ", max);
        const at = cut > max / 2 ? cut : max;
        out.push(rest.slice(0, at).trim());
        rest = rest.slice(at).trim();
      }
      cur = rest;
    }
    if (cur) out.push(cur);
  }
  return out;
}

export async function sha256Hex(s: string): Promise<string> {
  const d = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(s));
  return [...new Uint8Array(d)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

export function cacheKey(model: string, voice: string, style: string, text: string) {
  return sha256Hex(`${model}|${voice}|${style}|${text}`);
}

export function b64decode(b64: string): Uint8Array {
  const bin = atob(b64);
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}

/** Raw PCM of a RIFF/WAVE file (its `data` chunk); non-RIFF input is assumed
 *  to be headerless PCM already. Concatenating WAV files byte-wise is wrong. */
export function pcmOf(bytes: Uint8Array): Uint8Array {
  const tag = (o: number) => String.fromCharCode(...bytes.subarray(o, o + 4));
  if (bytes.length < 12 || tag(0) !== "RIFF" || tag(8) !== "WAVE") return bytes;
  const v = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  let o = 12;
  while (o + 8 <= bytes.length) {
    const size = v.getUint32(o + 4, true);
    if (tag(o) === "data") return bytes.subarray(o + 8, Math.min(bytes.length, o + 8 + size));
    o += 8 + size + (size % 2);
  }
  return new Uint8Array(0);
}

/** 44-byte PCM WAV header (mono, 16-bit) + data. */
export function wavOf(pcm: Uint8Array, rate = SAMPLE_RATE): Uint8Array {
  const out = new Uint8Array(44 + pcm.length);
  const v = new DataView(out.buffer);
  const str = (o: number, s: string) => [...s].forEach((c, i) => v.setUint8(o + i, c.charCodeAt(0)));
  str(0, "RIFF");
  v.setUint32(4, 36 + pcm.length, true);
  str(8, "WAVE");
  str(12, "fmt ");
  v.setUint32(16, 16, true);
  v.setUint16(20, 1, true); // PCM
  v.setUint16(22, 1, true); // mono
  v.setUint32(24, rate, true);
  v.setUint32(28, rate * 2, true);
  v.setUint16(32, 2, true);
  v.setUint16(34, 16, true);
  str(36, "data");
  v.setUint32(40, pcm.length, true);
  out.set(pcm, 44);
  return out;
}

export function concat(parts: Uint8Array[]): Uint8Array {
  const out = new Uint8Array(parts.reduce((n, p) => n + p.length, 0));
  let o = 0;
  for (const p of parts) {
    out.set(p, o);
    o += p.length;
  }
  return out;
}

/** Request body for one chunk (Interactions API, single speaker). */
export function ttsBody(model: string, voice: string, style: string, text: string) {
  return {
    model,
    input: [{
      type: "user_input",
      content: [{
        type: "text",
        text,
        annotations: [{ type: "speech_metadata", style }],
      }],
    }],
    response_format: { type: "audio", mime_type: "audio/l16", sample_rate: SAMPLE_RATE },
    generation_config: { speech_config: [{ voice }] },
  };
}

/** Last audio part of the model output (base64) — the documented jq path
 *  `[.steps[] | select(.type=="model_output") | .content[] | select(.type=="audio")] | last | .data`,
 *  with the SDK's `output_audio` as a fallback. */
// deno-lint-ignore no-explicit-any
export function audioData(out: any): string | null {
  const parts: string[] = [];
  for (const step of out?.steps ?? []) {
    if (step?.type !== "model_output") continue;
    for (const c of step?.content ?? []) {
      if (c?.type === "audio" && typeof c?.data === "string") parts.push(c.data);
    }
  }
  if (parts.length) return parts[parts.length - 1];
  const oa = out?.output_audio?.data;
  return typeof oa === "string" ? oa : null;
}

export type Fail = { ok: false; status: number; error: string };
export type ChunkResult = { ok: true; pcm: Uint8Array } | Fail;

/** One chunk with retry: 429 / 5xx / network → exponential backoff, at most
 *  [RETRIES] attempts. 404 (unknown model) is returned at once so the caller
 *  can fall back to the next model. */
export async function synthChunk(
  key: string,
  model: string,
  voice: string,
  style: string,
  text: string,
  deps: Deps = realDeps,
): Promise<ChunkResult> {
  let last: Fail = { ok: false, status: 502, error: "upstream" };
  for (let attempt = 0; attempt < RETRIES; attempt++) {
    if (attempt > 0) await deps.sleep(1000 * 2 ** (attempt - 1));
    let res: Response;
    try {
      res = await deps.fetchFn(`${API}/interactions`, {
        method: "POST",
        headers: { "x-goog-api-key": key, "Content-Type": "application/json" },
        body: JSON.stringify(ttsBody(model, voice, style, text)),
        signal: AbortSignal.timeout(ATTEMPT_MS),
      });
    } catch {
      last = { ok: false, status: 504, error: "timeout" };
      continue;
    }
    if (res.ok) {
      const data = audioData(await res.json().catch(() => null));
      if (!data) return { ok: false, status: 502, error: "no_audio" };
      return { ok: true, pcm: pcmOf(b64decode(data)) };
    }
    await res.body?.cancel();
    console.error("tts upstream", model, res.status); // status only
    if (res.status === 404) return { ok: false, status: 404, error: "model_not_found" };
    if (res.status === 429) last = { ok: false, status: 429, error: "quota" };
    else if (res.status >= 500) last = { ok: false, status: 502, error: "upstream" };
    else return { ok: false, status: 502, error: `upstream_${res.status}` };
  }
  return last;
}

/** Whole text: chunk by chunk, PCM joined, one WAV header at the end. */
export async function synthesize(
  key: string,
  models: string[],
  voice: string,
  style: string,
  text: string,
  deps: Deps = realDeps,
): Promise<{ ok: true; wav: Uint8Array; model: string } | Fail> {
  const chunks = splitText(text);
  if (!chunks.length) return { ok: false, status: 422, error: "empty" };
  let fail: Fail = { ok: false, status: 502, error: "upstream" };
  for (const model of models) {
    const pcm: Uint8Array[] = [];
    let modelFail: Fail | null = null;
    for (const c of chunks) {
      const r = await synthChunk(key, model, voice, style, c, deps);
      if (!r.ok) {
        modelFail = r;
        break;
      }
      pcm.push(r.pcm);
    }
    if (!modelFail) return { ok: true, wav: wavOf(concat(pcm)), model };
    fail = modelFail;
    if (modelFail.status !== 404) break; // only an unknown model falls back
  }
  return fail;
}
