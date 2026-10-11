// FORENSIC EXPERT — Q&A expert verification (server-side only).
//
// Request (POST, signed-in user):
//   { role, country, mime, data (base64), lang }
// Response:
//   { status: "verified" | "rejected", reason, attempts_today }
//
// * THE DOCUMENT IS NEVER STORED. It is decoded into memory, sent to the
//   vision model, and dropped when the request ends. No storage bucket, no
//   table column, no log line ever receives it. Stored: user id, role,
//   country, status, a short machine reason, dates (qa_profiles).
// * The user cannot verify themselves: the verdict is written with the
//   service-role key through public.qa_service_set_status, which is granted
//   to service_role only. The caller's id comes from their JWT, so one user
//   can never write another user's badge.
// * 3 attempts per calendar day (counted BEFORE the model call, so a failing
//   model cannot be used to farm attempts).
// * The GEMINI_API_KEY lives only in the function environment.
import { createClient } from "jsr:@supabase/supabase-js@2";
import {
  interpretVerdict,
  parseRequest,
  readGeminiReport,
  SYSTEM_PROMPT,
  toBase64,
  userPrompt,
} from "./verify.ts";

const API = "https://generativelanguage.googleapis.com/v1beta";
const MODEL = Deno.env.get("FE_QA_VISION_MODEL") ?? "gemini-flash-latest";
const ATTEMPT_MS = 30_000;

const url = Deno.env.get("SUPABASE_URL")!;
const anon = Deno.env.get("SUPABASE_ANON_KEY")!;
const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "method" }, 405);
  const key = Deno.env.get("GEMINI_API_KEY");
  if (!key) return json({ error: "not_configured" }, 503);

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
  const { role, country, mime, bytes } = parsed.value;

  const admin = createClient(url, service, { auth: { persistSession: false } });

  // Count the attempt first: 3 per day, whatever the outcome.
  const { data: attempts, error: rateError } = await admin
    .rpc("qa_service_verify_attempt", { p_user: u.user.id });
  if (rateError) {
    // Only the code is logged — never the user's document or e-mail.
    console.error("qa_verify_rate", rateError.code ?? "error");
    return json({ error: "too_many_requests" }, 429);
  }

  let report = null;
  try {
    const r = await fetch(`${API}/models/${MODEL}:generateContent`, {
      method: "POST",
      signal: AbortSignal.timeout(ATTEMPT_MS),
      headers: { "Content-Type": "application/json", "x-goog-api-key": key },
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: SYSTEM_PROMPT }] },
        contents: [{
          role: "user",
          parts: [
            { text: userPrompt(role, country) },
            { inlineData: { mimeType: mime, data: toBase64(bytes) } },
          ],
        }],
        generationConfig: {
          temperature: 0,
          maxOutputTokens: 512,
          responseMimeType: "application/json",
          thinkingConfig: { thinkingBudget: 0 },
        },
      }),
    });
    if (r.ok) {
      report = readGeminiReport(await r.json());
    } else {
      console.error("qa_verify_vision_status", r.status);
    }
  } catch (e) {
    console.error("qa_verify_vision_failed", e instanceof Error ? e.name : "error");
  }

  const verdict = interpretVerdict(report, role);
  // The model is unavailable: do not write a rejection the user cannot act on.
  if (verdict.reason === "ai_unavailable") {
    return json({ error: "upstream", attempts_today: attempts ?? null }, 502);
  }

  const { error: writeError } = await admin.rpc("qa_service_set_status", {
    p_user: u.user.id,
    p_role: role,
    p_country: country,
    p_status: verdict.status,
    p_reason: verdict.reason,
    p_manual: false,
  });
  if (writeError) {
    console.error("qa_verify_write", writeError.code ?? "error");
    return json({ error: "server" }, 500);
  }

  return json({
    status: verdict.status,
    reason: verdict.reason,
    attempts_today: attempts ?? null,
  });
});
