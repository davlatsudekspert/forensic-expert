// FORENSIC EXPERT — email one-time code (6 digits) → Supabase session.
//
// * request: {action:"request", email, locale} → generates a 6-digit code,
//   stores only an HMAC hash (10 min TTL), emails it from FORENSIC EXPERT's
//   own sender via Resend (RESEND_API_KEY + FE_EMAIL_FROM function secrets).
// * verify:  {action:"verify", email, code} → checks hash (max 5 attempts),
//   ensures the auth user exists, mints a Supabase session server-side and
//   returns {access_token, refresh_token, user}.
// * Limits: 3 codes / email / 10 min, 10 / IP / 10 min, 60 s resend gap.
// * Never logs codes, emails or tokens. No other product's identity is used.
import { createClient } from "jsr:@supabase/supabase-js@2";

const TTL_MS = 10 * 60_000;
const WINDOW_MS = 10 * 60_000;
const MAX_PER_EMAIL = 3;
const MAX_PER_IP = 10;
const RESEND_GAP_MS = 60_000;
const MAX_ATTEMPTS = 5;
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

const url = Deno.env.get("SUPABASE_URL")!;
const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const anon = Deno.env.get("SUPABASE_ANON_KEY")!;
const admin = createClient(url, service, { auth: { persistSession: false } });

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

async function hmac(text: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw", new TextEncoder().encode(service), { name: "HMAC", hash: "SHA-256" },
    false, ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(text));
  return [...new Uint8Array(sig)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

function sixDigits(): string {
  const a = new Uint32Array(1);
  crypto.getRandomValues(a);
  return String(a[0] % 1_000_000).padStart(6, "0");
}

function timingSafeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let r = 0;
  for (let i = 0; i < a.length; i++) r |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return r === 0;
}

const T: Record<string, [string, string, string, string]> = {
  en: ["FORENSIC EXPERT — Verification code", "Your FORENSIC EXPERT verification code is:",
    "The code is valid for 10 minutes. If you did not request it, you can ignore this email — no account changes were made.",
    "Never share this code. FORENSIC EXPERT staff will never ask you for it."],
  ru: ["FORENSIC EXPERT — код подтверждения", "Ваш код подтверждения FORENSIC EXPERT:",
    "Код действителен 10 минут. Если вы не запрашивали код, просто проигнорируйте это письмо — изменений в аккаунте не было.",
    "Никому не сообщайте этот код. Сотрудники FORENSIC EXPERT никогда его не запрашивают."],
  uz: ["FORENSIC EXPERT — tasdiqlash kodi", "FORENSIC EXPERT hisobingizni tasdiqlash uchun quyidagi kodni kiriting:",
    "Kod 10 daqiqa amal qiladi. Agar siz kod so‘ramagan bo‘lsangiz, bu xatni e’tiborsiz qoldiring — hisobingizda o‘zgarish bo‘lmadi.",
    "Bu kodni hech kimga bermang. FORENSIC EXPERT xodimlari uni hech qachon so‘ramaydi."],
};

function emailHtml(lang: string, code: string): string {
  const [, lead, valid, warn] = T[lang] ?? T.en;
  return `<!doctype html><html><body style="margin:0;background:#F5F7FA;font-family:Inter,'Helvetica Neue',Arial,sans-serif">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#F5F7FA;padding:24px 0"><tr><td align="center">
<table role="presentation" width="480" cellpadding="0" cellspacing="0" style="max-width:480px;background:#FFFFFF;border:1px solid #DDE3EC;border-radius:12px">
<tr><td style="background:#0F1E3D;border-radius:12px 12px 0 0;padding:20px 28px">
<div style="font-family:Georgia,'Times New Roman',serif;font-size:20px;letter-spacing:1.5px;color:#FFFFFF;font-weight:600">FORENSIC EXPERT</div>
<div style="font-size:11px;letter-spacing:2px;color:#B8C2D6;margin-top:4px">EVIDENCE · SCIENCE · PRECISION</div></td></tr>
<tr><td style="padding:28px">
<p style="margin:0 0 16px;font-size:15px;color:#1E2633">${lead}</p>
<p style="margin:0 0 20px;font-family:Menlo,Consolas,monospace;font-size:32px;letter-spacing:8px;font-weight:700;color:#0F1E3D">${code}</p>
<p style="margin:0 0 8px;font-size:13px;color:#4A5568">${valid}</p>
<p style="margin:0;font-size:13px;color:#4A5568">${warn}</p></td></tr>
<tr><td style="padding:16px 28px;border-top:1px solid #EEF1F5;font-size:11px;color:#6B7585">FORENSIC EXPERT · Scientific reference for forensic professionals</td></tr>
</table></td></tr></table></body></html>`;
}

async function request(email: string, lang: string, ipHash: string): Promise<Response> {
  const key = Deno.env.get("RESEND_API_KEY");
  const from = Deno.env.get("FE_EMAIL_FROM"); // e.g. "FORENSIC EXPERT <no-reply@your-domain>"
  if (!key || !from || !/FORENSIC EXPERT/.test(from)) {
    return json({ error_code: "email_not_configured" }, 503);
  }
  const since = new Date(Date.now() - WINDOW_MS).toISOString();
  const { data: recent } = await admin.from("email_otp_codes")
    .select("created_at").eq("email", email).gte("created_at", since)
    .order("created_at", { ascending: false });
  if ((recent?.length ?? 0) >= MAX_PER_EMAIL) return json({ error_code: "over_email_send_rate_limit" }, 429);
  if (recent?.length && Date.now() - Date.parse(recent[0].created_at) < RESEND_GAP_MS) {
    return json({ error_code: "over_email_send_rate_limit" }, 429);
  }
  const { count: ipCount } = await admin.from("email_otp_codes")
    .select("id", { count: "exact", head: true }).eq("ip_hash", ipHash).gte("created_at", since);
  if ((ipCount ?? 0) >= MAX_PER_IP) return json({ error_code: "over_request_rate_limit" }, 429);

  const code = sixDigits();
  await admin.from("email_otp_codes").update({ used: true }).eq("email", email).eq("used", false);
  const { data: row, error } = await admin.from("email_otp_codes").insert({
    email, code_hash: await hmac(`${email}:${code}`), ip_hash: ipHash,
    expires_at: new Date(Date.now() + TTL_MS).toISOString(),
  }).select("id").single();
  if (error || !row) return json({ error_code: "server" }, 500);

  const [subject, lead, valid] = T[lang] ?? T.en;
  const r = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      from, to: [email], subject,
      html: emailHtml(lang, code),
      text: `${lead}\n\n${code}\n\n${valid}\n\nFORENSIC EXPERT`,
    }),
  });
  if (!r.ok) {
    await admin.from("email_otp_codes").delete().eq("id", row.id);
    // Provider message is inspected, never logged. Sender/domain problems
    // (unverified domain, test-mode sender) are OUR configuration issue,
    // not the user's address.
    const detail = (await r.text()).toLowerCase();
    const senderIssue = r.status === 403 || /domain|testing emails|own email|from/.test(detail);
    console.error("email_send_failed status", r.status, senderIssue ? "sender" : "recipient");
    if (r.status === 422 && !senderIssue) return json({ error_code: "email_address_invalid" }, 400);
    return json({ error_code: "email_send_failed" }, 503);
  }
  return json({ ok: true, ttl_seconds: TTL_MS / 1000 });
}

async function verify(email: string, code: string, lang: string): Promise<Response> {
  if (!/^\d{6}$/.test(code)) return json({ error_code: "bad_code" }, 403);
  const { data: row } = await admin.from("email_otp_codes")
    .select("id, code_hash, expires_at, attempts").eq("email", email).eq("used", false)
    .order("created_at", { ascending: false }).limit(1).maybeSingle();
  if (!row || Date.parse(row.expires_at) < Date.now()) return json({ error_code: "otp_expired" }, 403);
  if (row.attempts >= MAX_ATTEMPTS) {
    await admin.from("email_otp_codes").update({ used: true }).eq("id", row.id);
    return json({ error_code: "otp_expired" }, 403);
  }
  if (!timingSafeEqual(row.code_hash, await hmac(`${email}:${code}`))) {
    await admin.from("email_otp_codes").update({ attempts: row.attempts + 1 }).eq("id", row.id);
    return json({ error_code: "bad_code" }, 403);
  }
  await admin.from("email_otp_codes").update({ used: true }).eq("id", row.id);

  // Ensure the account exists (email confirmed by this code), then mint a session.
  const created = await admin.auth.admin.createUser({
    email, email_confirm: true, user_metadata: { locale: lang },
  });
  if (created.error && !/already|registered|exists/i.test(created.error.message)) {
    return json({ error_code: "server" }, 500);
  }
  const link = await admin.auth.admin.generateLink({ type: "magiclink", email });
  const tokenHash = link.data?.properties?.hashed_token;
  if (link.error || !tokenHash) return json({ error_code: "server" }, 500);
  const s = await fetch(`${url}/auth/v1/verify`, {
    method: "POST",
    headers: { apikey: anon, "Content-Type": "application/json" },
    body: JSON.stringify({ type: "magiclink", token_hash: tokenHash }),
  });
  if (!s.ok) return json({ error_code: "server" }, 500);
  return json(await s.json());
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error_code: "method" }, 405);
  let body: { action?: string; email?: string; code?: string; locale?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error_code: "validation_failed" }, 400);
  }
  const email = String(body.email ?? "").trim().toLowerCase();
  if (!EMAIL_RE.test(email) || email.length > 254) return json({ error_code: "email_address_invalid" }, 400);
  const lang = /^(en|ru|uz)$/.test(body.locale ?? "") ? body.locale! : "en";
  const ip = req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ?? "unknown";
  if (body.action === "request") return request(email, lang, await hmac(`ip:${ip}`));
  if (body.action === "verify") return verify(email, String(body.code ?? "").trim(), lang);
  return json({ error_code: "validation_failed" }, 400);
});
