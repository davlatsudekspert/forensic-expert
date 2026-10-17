// FORENSIC EXPERT — owner bootstrap of the first admin.
//
// Gives the identity_admin role to the e-mail-CONFIRMED account(s) listed in
// the ADMIN_EMAILS function secret (comma separated). Nothing else:
//   * Callable ONLY with the project's service-role key (compared in constant
//     time); the app and signed-in users can never reach it.
//   * The e-mail list is read from the secret, never from the request body.
//   * The role is granted by public.admin_bootstrap() (service_role only),
//     which skips unconfirmed or unknown addresses and writes an audit row.
//   * After bootstrap, every admin request is still checked on the server by
//     private.admin_guard(); an e-mail address never grants rights by itself.
//   * The response contains only a count — never an address or a key.
import { createClient } from "jsr:@supabase/supabase-js@2";

function safeEqual(a: string, b: string): boolean {
  const enc = new TextEncoder();
  const x = enc.encode(a);
  const y = enc.encode(b);
  let diff = x.length ^ y.length;
  for (let i = 0; i < Math.max(x.length, y.length); i++) {
    diff |= (x[i] ?? 0) ^ (y[i] ?? 0);
  }
  return diff === 0;
}

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "method" }, 405);
  const url = Deno.env.get("SUPABASE_URL");
  const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const emails = (Deno.env.get("ADMIN_EMAILS") ?? "")
    .split(",")
    .map((e) => e.trim().toLowerCase())
    .filter((e) => e.length > 0 && e.length <= 254);
  if (!url || !service) return json({ error: "server" }, 500);

  const bearer = (req.headers.get("Authorization") ?? "").replace(/^Bearer\s+/i, "");
  if (!bearer || !safeEqual(bearer, service)) return json({ error: "unauthorized" }, 401);
  if (emails.length === 0) return json({ error: "ADMIN_EMAILS is empty" }, 400);
  if (emails.length > 10) return json({ error: "too many addresses" }, 400);

  const admin = createClient(url, service, { auth: { persistSession: false } });
  const { data, error } = await admin.rpc("admin_bootstrap", { p_emails: emails });
  if (error) return json({ error: "server" }, 500);
  return json({ granted: data, listed: emails.length });
});
