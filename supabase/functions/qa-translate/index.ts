// FORENSIC EXPERT — Q&A machine translation (server-side only).
//
// Request (POST, signed-in user): { target_type, target_id, lang }
// Response: { title, body, engine, cached, source_lang } or
//           { source: true, ... } when the post is already in that language.
//
// * The translation key is NEVER in the app: Cloudflare Workers AI
//   (CF_ACCOUNT_ID + CF_API_TOKEN) is the primary engine, Gemini the
//   fallback. Both are function secrets.
// * Every (post, language) pair is translated once and cached in
//   qa_translations (public.qa_service_translation_put, service_role only).
//   The app shows the cached text with a "machine translation" badge and an
//   "original text" switch.
// * Only published posts are translated, and only their title/body: no
//   author id, no e-mail, nothing personal leaves the database.
// * Per-user daily cap so a client cannot farm engine calls.
import { createClient } from "jsr:@supabase/supabase-js@2";
import {
  cacheRow,
  cfLangVariants,
  chunk,
  geminiPrompt,
  GEMINI_SYSTEM,
  type Lang,
  MAX_TOTAL_CHARS,
  parseRequest,
  readCloudflare,
  readGemini,
} from "./translate.ts";

const CF_MODEL = Deno.env.get("FE_QA_CF_MODEL") ?? "@cf/meta/m2m100-1.2b";
const GEMINI_API = "https://generativelanguage.googleapis.com/v1beta";
const GEMINI_MODEL = Deno.env.get("FE_QA_TRANSLATE_MODEL") ?? "gemini-flash-latest";
const DAILY_LIMIT = Number(Deno.env.get("FE_QA_TRANSLATE_DAILY") ?? "200");
const ATTEMPT_MS = 20_000;

const url = Deno.env.get("SUPABASE_URL")!;
const anon = Deno.env.get("SUPABASE_ANON_KEY")!;
const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

async function cloudflare(text: string, from: Lang, to: Lang): Promise<string | null> {
  const account = Deno.env.get("CF_ACCOUNT_ID");
  const token = Deno.env.get("CF_API_TOKEN");
  if (!account || !token) return null;
  const sources = cfLangVariants(from);
  const targets = cfLangVariants(to);
  for (let i = 0; i < sources.length; i++) {
    try {
      const r = await fetch(
        `https://api.cloudflare.com/client/v4/accounts/${account}/ai/run/${CF_MODEL}`,
        {
          method: "POST",
          signal: AbortSignal.timeout(ATTEMPT_MS),
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({
            text,
            source_lang: sources[i],
            target_lang: targets[i],
          }),
        },
      );
      if (!r.ok) {
        // Status only: the post text is never logged.
        console.error("qa_translate_cf_status", r.status);
        continue;
      }
      const out = readCloudflare(await r.json());
      if (out) return out;
    } catch (e) {
      console.error("qa_translate_cf_failed", e instanceof Error ? e.name : "error");
    }
  }
  return null;
}

async function gemini(text: string, to: Lang): Promise<string | null> {
  const key = Deno.env.get("GEMINI_API_KEY");
  if (!key) return null;
  try {
    const r = await fetch(`${GEMINI_API}/models/${GEMINI_MODEL}:generateContent`, {
      method: "POST",
      signal: AbortSignal.timeout(ATTEMPT_MS),
      headers: { "Content-Type": "application/json", "x-goog-api-key": key },
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: GEMINI_SYSTEM }] },
        contents: [{ role: "user", parts: [{ text: geminiPrompt(to, text) }] }],
        generationConfig: {
          temperature: 0,
          maxOutputTokens: 2048,
          responseMimeType: "application/json",
          thinkingConfig: { thinkingBudget: 0 },
        },
      }),
    });
    if (!r.ok) {
      console.error("qa_translate_gemini_status", r.status);
      return null;
    }
    return readGemini(await r.json());
  } catch (e) {
    console.error("qa_translate_gemini_failed", e instanceof Error ? e.name : "error");
    return null;
  }
}

/** Cloudflare first, Gemini as the fallback; returns the engine used. */
async function translate(
  text: string,
  from: Lang,
  to: Lang,
): Promise<{ text: string; engine: string } | null> {
  const pieces = chunk(text);
  const cf: string[] = [];
  for (const p of pieces) {
    const t = await cloudflare(p, from, to);
    if (!t) {
      cf.length = 0;
      break;
    }
    cf.push(t);
  }
  if (cf.length === pieces.length && cf.length > 0) {
    return { text: cf.join("\n\n"), engine: `cf:${CF_MODEL}` };
  }
  const g = await gemini(text, to);
  if (g) return { text: g, engine: `gemini:${GEMINI_MODEL}` };
  return null;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "method" }, 405);

  const auth = req.headers.get("Authorization") ?? "";
  const user = createClient(url, anon, { global: { headers: { Authorization: auth } } });
  const { data: u, error: authError } = await user.auth.getUser();
  if (authError || !u.user) return json({ error: "unauthorized" }, 401);

  let body: unknown;
  try {
    body = await req.json();
  } catch {
    return json({ error: "bad_request" }, 400);
  }
  const parsed = parseRequest(body);
  if (!parsed.ok) return json({ error: parsed.error }, 422);
  const { targetType, targetId, lang } = parsed.value;

  // Cache hit: the user's own RPC, so an unpublished post stays invisible.
  const { data: cached } = await user.rpc("qa_translation", {
    p_target_type: targetType,
    p_target_id: targetId,
    p_lang: lang,
  });
  if (cached) return json({ ...cached, cached: true });

  const admin = createClient(url, service, { auth: { persistSession: false } });
  const { data: post, error: postError } = await admin.rpc("qa_service_translatable", {
    p_target_type: targetType,
    p_target_id: targetId,
  });
  if (postError) {
    console.error("qa_translate_read", postError.code ?? "error");
    return json({ error: "server" }, 500);
  }
  if (!post) return json({ error: "not_found" }, 404);
  const source = post as { lang: Lang; title: string | null; body: string };
  if (source.lang === lang) {
    return json({ source: true, title: source.title, body: source.body });
  }

  const { error: rateError } = await admin.rpc("qa_service_bump", {
    p_user: u.user.id,
    p_kind: "translate",
    p_limit: DAILY_LIMIT,
  });
  if (rateError) {
    console.error("qa_translate_rate", rateError.code ?? "error");
    return json({ error: "too_many_requests" }, 429);
  }

  const total = (source.title ?? "").length + source.body.length;
  if (total > MAX_TOTAL_CHARS) return json({ error: "too_long" }, 422);

  const bodyOut = await translate(source.body, source.lang, lang);
  if (!bodyOut) return json({ error: "upstream" }, 502);
  const titleOut = source.title
    ? await translate(source.title, source.lang, lang)
    : null;

  const row = cacheRow(
    { title: titleOut?.text ?? null, body: bodyOut.text },
    bodyOut.engine,
  );
  if (!row) return json({ error: "upstream" }, 502);

  const { error: putError } = await admin.rpc("qa_service_translation_put", {
    p_target_type: targetType,
    p_target_id: targetId,
    p_lang: lang,
    p_title: row.title,
    p_body: row.body,
    p_engine: row.engine,
  });
  if (putError) {
    console.error("qa_translate_put", putError.code ?? "error");
    // The text is good even if the cache write failed: serve it uncached.
    return json({ ...row, cached: false, source_lang: source.lang });
  }
  return json({ ...row, cached: false, source_lang: source.lang });
});
