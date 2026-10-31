// FORENSIC EXPERT — text-to-speech (Gemini TTS, server-side only).
//
// * GEMINI_API_KEY lives ONLY in the Edge Function environment; the app calls
//   this function, never Google directly.
// * POST { text, voice?, style?, quality?: "hd" | "lite" }  -> audio/wav
//   (24 kHz, mono, 16-bit PCM). Header `x-tts-cache: hit|miss`.
//   POST { action: "voices", language?: "uz" } -> voice list (no cost).
// * Cache: tts-cache/v1/<sha256(model|voice|style|text)>.wav — a hit never
//   calls Gemini and does not count toward the daily limit.
// * Signed-in users only; per-user daily limit on generations
//   (FE_TTS_DAILY_LIMIT). Text is never logged or stored as text.
// * Config (env, all optional): FE_TTS_MODEL, FE_TTS_MODEL_LITE, FE_TTS_VOICE,
//   FE_TTS_DAILY_LIMIT.
import { createClient } from "jsr:@supabase/supabase-js@2";
import {
  API,
  cacheKey,
  cleanText,
  MAX_STYLE_CHARS,
  MAX_TEXT_CHARS,
  synthesize,
} from "./tts_lib.ts";

const BUCKET = "tts-cache";
const MODEL = Deno.env.get("FE_TTS_MODEL") || "gemini-3.8-flash-tts";
const MODEL_LITE = Deno.env.get("FE_TTS_MODEL_LITE") || "gemini-3.8-flash-lite-tts";
const FALLBACK = "gemini-3.1-flash-tts-preview";
const VOICE = Deno.env.get("FE_TTS_VOICE") || "Charon";
const DAILY_LIMIT = Number(Deno.env.get("FE_TTS_DAILY_LIMIT") ?? "60");

// Eski ilova versiyalari (public.app_config.min_build; 0 = cheklov yo‘q). 60 s kesh.
let gate: { min: number; at: number } | null = null;
// deno-lint-ignore no-explicit-any
async function updateRequired(req: Request, db: any): Promise<boolean> {
  if (req.headers.get("x-fe-check") === "probe") return true;
  if (!gate || Date.now() - gate.at > 60_000) {
    const { data } = await db.rpc("app_version_info");
    gate = { min: Number(data?.min_build ?? 0) || 0, at: Date.now() };
  }
  if (gate.min <= 0) return false;
  const raw = req.headers.get("x-fe-build") ?? "";
  return !/^[0-9]{1,9}$/.test(raw) || Number(raw) < gate.min;
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function wav(bytes: Uint8Array, cache: "hit" | "miss"): Response {
  return new Response(bytes as Uint8Array<ArrayBuffer>, {
    headers: {
      "Content-Type": "audio/wav",
      "Content-Length": String(bytes.length),
      "x-tts-cache": cache,
    },
  });
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "method" }, 405);
  const key = Deno.env.get("GEMINI_API_KEY");
  if (!key) return json({ error: "not_configured" }, 503);

  const url = Deno.env.get("SUPABASE_URL")!;
  const anon = Deno.env.get("SUPABASE_ANON_KEY")!;
  const user = createClient(url, anon, {
    global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
  });
  const { data: u, error: authError } = await user.auth.getUser();
  if (authError || !u.user) return json({ error: "unauthorized" }, 401);
  if (await updateRequired(req, user)) return json({ error: "update_required" }, 426);

  // deno-lint-ignore no-explicit-any
  let body: any;
  try {
    body = await req.json();
  } catch {
    return json({ error: "bad_request" }, 400);
  }

  if (body?.action === "voices") {
    const lang = /^[a-z]{2,3}$/.test(body?.language ?? "") ? body.language : "uz";
    const r = await fetch(`${API}/voices?language_code=${lang}&page_size=50`, {
      headers: { "x-goog-api-key": key },
      signal: AbortSignal.timeout(20_000),
    }).catch(() => null);
    if (!r?.ok) {
      await r?.body?.cancel();
      return json({ error: "upstream", status: r?.status ?? 0 }, 502);
    }
    return json(await r.json());
  }

  const raw = String(body?.text ?? "");
  if (raw.length > MAX_TEXT_CHARS) return json({ error: "too_long", max: MAX_TEXT_CHARS }, 413);
  const text = cleanText(raw);
  if (!text) return json({ error: "empty" }, 422);
  const style = cleanText(body?.style ?? "", MAX_STYLE_CHARS);
  const voice = /^[A-Za-z0-9_\-]{2,64}$/.test(body?.voice ?? "") ? body.voice : VOICE;
  const lite = body?.quality === "lite";
  const models = lite ? [MODEL_LITE, MODEL, FALLBACK] : [MODEL, FALLBACK];

  const admin = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  const path = `v1/${await cacheKey(models[0], voice, style, text)}.wav`;
  const cached = await admin.storage.from(BUCKET).download(path);
  if (cached.data) return wav(new Uint8Array(await cached.data.arrayBuffer()), "hit");

  const since = new Date(Date.now() - 86_400_000).toISOString();
  const { count, error: countError } = await admin.from("tts_usage")
    .select("id", { count: "exact", head: true })
    .eq("user_id", u.user.id).gte("created_at", since);
  if (countError) return json({ error: "server" }, 500);
  if ((count ?? 0) >= DAILY_LIMIT) return json({ error: "too_many_requests" }, 429);
  await admin.from("tts_usage").insert({ user_id: u.user.id, chars: text.length });

  const res = await synthesize(key, models, voice, style, text);
  if (!res.ok) return json({ error: res.error }, res.status === 404 ? 502 : res.status);

  // Best effort: a failed upload must not lose the audio already generated.
  await admin.storage.from(BUCKET).upload(path, res.wav, {
    contentType: "audio/wav",
    upsert: true,
  }).catch(() => null);
  return wav(res.wav, "miss");
});
