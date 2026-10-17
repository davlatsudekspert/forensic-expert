// FORENSIC EXPERT — account deletion (Apple 5.1.1(v), Google Play policy).
// Runs server-side with the service-role key from the Edge Function
// environment (never shipped in the app). Deletes only the caller's account.
//
// Request  (POST, signed-in user): { confirm: true, apple_authorization_code?: string }
// Response (200): { ok: true, apple_revoked: boolean, apple_revoke_reason?: string }
//   apple_revoked is true only if the Apple token was exchanged and revoked
//   (Apple 5.1.1(v)). It is best effort: missing secrets, a bad code or an
//   Apple outage give apple_revoked:false and the account is STILL deleted.
// Secrets (Edge Function env): APPLE_TEAM_ID, APPLE_KEY_ID, APPLE_CLIENT_ID,
//   APPLE_PRIVATE_KEY (.p8 text). Never logged.
import { createClient } from "jsr:@supabase/supabase-js@2";
import { appleConfigFromEnv, appleSubjectOf, revokeAppleAccess } from "./apple_revoke.ts";

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("method", { status: 405 });
  const auth = req.headers.get("Authorization") ?? "";
  const url = Deno.env.get("SUPABASE_URL")!;
  const anon = Deno.env.get("SUPABASE_ANON_KEY")!;
  const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const user = createClient(url, anon, { global: { headers: { Authorization: auth } } });
  const { data, error } = await user.auth.getUser();
  if (error || !data.user) return new Response("unauthorized", { status: 401 });
  const admin = createClient(url, service);
  // Apple token revocation (best effort, before the DB delete; never blocks it).
  let body: { apple_authorization_code?: unknown } = {};
  try {
    body = await req.json();
  } catch {
    body = {};
  }
  const code = typeof body?.apple_authorization_code === "string"
    ? body.apple_authorization_code.trim()
    : "";
  let appleRevoked = false;
  let appleReason: string | undefined;
  if (code) {
    const r = await revokeAppleAccess({
      code,
      cfg: appleConfigFromEnv((n) => Deno.env.get(n)),
      expectedSubject: appleSubjectOf(data.user),
    });
    appleRevoked = r.revoked;
    appleReason = r.reason;
    if (!r.revoked) console.warn(`apple revoke skipped/failed: ${r.reason}`);
  }
  // Private files first (credentials, support screenshots), then the auth
  // user (cascades to support threads/messages and all other rows).
  for (const bucket of ["credentials", "support-attachments"]) {
    const { data: files } = await admin.storage.from(bucket).list(data.user.id);
    if (files && files.length > 0) {
      await admin.storage.from(bucket).remove(files.map((f) => `${data.user.id}/${f.name}`));
    }
  }
  const del = await admin.auth.admin.deleteUser(data.user.id);
  if (del.error) return new Response("server", { status: 500 });
  return new Response(JSON.stringify({ ok: true, apple_revoked: appleRevoked, ...(appleReason ? { apple_revoke_reason: appleReason } : {}) }), { headers: { "Content-Type": "application/json" } });
});
