// FORENSIC EXPERT — background pre-generation of lesson narration audio.
//
// Fills the same cache the `tts` function reads (tts-cache/v1/<key>.wav), so a
// slide generated here plays for every user without calling Gemini again.
// * Auth: header `x-prefill-token` must match the Vault secret
//   `tts_prefill_token` (checked by public.tts_prefill_token_ok). No JWT.
// * POST { action: "enqueue", items: [{prio, deck_id, slide, text, style}] }
//   → upserts into public.tts_prefill_queue.
// * POST { action: "run", max?, sync? } → generates the next queued slides
//   (lowest prio first) until `max`, the time budget, or the Gemini quota
//   (429 on every model) is reached. Without `sync` it answers 202 at once and
//   keeps working in the background (pg_cron calls it hourly).
// * Never logs text or keys; same models/voice/cache key as `tts`.
import { createClient } from "jsr:@supabase/supabase-js@2";
import { cacheKey, cleanText, MAX_STYLE_CHARS, synthesize } from "./tts_lib.ts";

const BUCKET = "tts-cache";
const MODEL = Deno.env.get("FE_TTS_MODEL") || "gemini-3.8-flash-tts";
const MODEL_LITE = Deno.env.get("FE_TTS_MODEL_LITE") || "gemini-3.8-flash-lite-tts";
const FALLBACK = "gemini-3.1-flash-tts-preview";
const VOICE = Deno.env.get("FE_TTS_VOICE") || "Charon";
const BUDGET_MS = 110_000;

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

// deno-lint-ignore no-explicit-any
type Db = any;

async function cached(db: Db, path: string): Promise<boolean> {
  const [dir, name] = [path.slice(0, path.lastIndexOf("/")), path.slice(path.lastIndexOf("/") + 1)];
  const { data } = await db.storage.from(BUCKET).list(dir, { search: name, limit: 1 });
  return Array.isArray(data) && data.some((f: { name: string }) => f.name === name);
}

async function run(db: Db, key: string, max: number) {
  const started = Date.now();
  const out = { done: 0, skipped: 0, failed: 0, quota: false };
  while (out.done + out.skipped + out.failed < max && Date.now() - started < BUDGET_MS) {
    const { data: rows, error } = await db.from("tts_prefill_queue")
      .select("id,text,style,fail_count")
      .is("done_at", null).lt("fail_count", 3)
      .order("prio").order("id").limit(1);
    if (error || !rows?.length) break;
    const row = rows[0];
    const text = cleanText(row.text);
    const style = cleanText(row.style ?? "", MAX_STYLE_CHARS);
    const path = `v1/${await cacheKey(MODEL, VOICE, style, text)}.wav`;
    if (!text || await cached(db, path)) {
      await db.from("tts_prefill_queue").update({ done_at: new Date().toISOString() }).eq("id", row.id);
      out.skipped++;
      continue;
    }
    const res = await synthesize(key, [MODEL, FALLBACK, MODEL_LITE], VOICE, style, text);
    if (!res.ok) {
      if (res.status === 429) {
        out.quota = true; // daily quota spent on every model: try next hour
        break;
      }
      await db.from("tts_prefill_queue")
        .update({ fail_count: row.fail_count + 1, last_error: res.error }).eq("id", row.id);
      out.failed++;
      continue;
    }
    const up = await db.storage.from(BUCKET).upload(path, res.wav, {
      contentType: "audio/wav",
      upsert: true,
    });
    if (up.error) {
      await db.from("tts_prefill_queue")
        .update({ fail_count: row.fail_count + 1, last_error: "upload" }).eq("id", row.id);
      out.failed++;
      continue;
    }
    await db.from("tts_prefill_queue")
      .update({ done_at: new Date().toISOString(), model: res.model }).eq("id", row.id);
    out.done++;
  }
  console.log("tts-prefill", JSON.stringify(out)); // counts only
  return out;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "method" }, 405);
  const key = Deno.env.get("GEMINI_API_KEY");
  if (!key) return json({ error: "not_configured" }, 503);
  const db = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

  const token = req.headers.get("x-prefill-token") ?? "";
  if (token.length < 32) return json({ error: "unauthorized" }, 401);
  const { data: ok } = await db.rpc("tts_prefill_token_ok", { p_token: token });
  if (ok !== true) return json({ error: "unauthorized" }, 401);

  // deno-lint-ignore no-explicit-any
  let body: any;
  try {
    body = await req.json();
  } catch {
    return json({ error: "bad_request" }, 400);
  }

  if (body?.action === "enqueue") {
    const items = Array.isArray(body.items) ? body.items.slice(0, 1000) : [];
    const rows = items
      // deno-lint-ignore no-explicit-any
      .filter((i: any) => typeof i?.text === "string" && i.text.trim() && typeof i?.deck_id === "string")
      // deno-lint-ignore no-explicit-any
      .map((i: any) => ({
        prio: Number(i.prio) || 100,
        deck_id: String(i.deck_id).slice(0, 120),
        slide: Number(i.slide) || 0,
        text: String(i.text).slice(0, 4000),
        style: String(i.style ?? "").slice(0, MAX_STYLE_CHARS),
      }));
    if (!rows.length) return json({ inserted: 0 });
    const { error } = await db.from("tts_prefill_queue")
      .upsert(rows, { onConflict: "deck_id,slide,style", ignoreDuplicates: true });
    if (error) return json({ error: "db" }, 500);
    return json({ inserted: rows.length });
  }

  if (body?.action === "run") {
    const max = Math.min(Math.max(Number(body.max) || 40, 1), 200);
    if (body.sync === true) return json(await run(db, key, max));
    // deno-lint-ignore no-explicit-any
    (globalThis as any).EdgeRuntime?.waitUntil(run(db, key, max));
    return json({ started: true }, 202);
  }
  return json({ error: "bad_request" }, 400);
});
