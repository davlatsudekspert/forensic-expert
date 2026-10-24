// FORENSIC EXPERT — verify a store subscription and record the plan.
//
// Request  (POST, signed-in user):
//   { platform: 'ios'|'android', product_id, signed_transaction? (iOS JWS), purchase_token? (Android) }
// Response (200): { result: 'APPLIED', plan, expires_at }
//                 | { result: 'INVALID', reason? } | { result: 'NOT_CONFIGURED' }
//           (502): { result: 'UNAVAILABLE' }  (store temporarily unreachable; retry)
// The caller id comes from the JWT, so nobody can activate a plan for another
// account. The plan is written with the service-role key through
// public.plan_apply_store (service_role only). Store credentials live only in
// the function environment: ASC_IAP_KEY_ID, ASC_IAP_ISSUER_ID, ASC_IAP_PRIVATE_KEY,
// APP_BUNDLE_ID, PLAY_SERVICE_ACCOUNT_JSON, ANDROID_PACKAGE. Never logged.
import { createClient } from "jsr:@supabase/supabase-js@2";
import { handleVerify } from "./verify.ts";

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json" } });
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("method", { status: 405 });
  const auth = req.headers.get("Authorization") ?? "";
  const url = Deno.env.get("SUPABASE_URL")!;
  const anon = Deno.env.get("SUPABASE_ANON_KEY")!;
  const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const user = createClient(url, anon, { global: { headers: { Authorization: auth } } });
  const { data, error } = await user.auth.getUser();
  if (error || !data.user) return new Response("unauthorized", { status: 401 });
  let body: unknown = null;
  try {
    body = await req.json();
  } catch {
    body = null;
  }
  const admin = createClient(url, service);
  const r = await handleVerify(data.user.id, body, {
    fetch: (u, init) => fetch(u, init),
    now: () => Date.now(),
    env: (n) => Deno.env.get(n),
    applyPlan: async (a) => {
      const { data: res, error: e } = await admin.rpc("plan_apply_store", {
        p_user_id: a.userId,
        p_platform: a.platform,
        p_product_id: a.productId,
        p_original_transaction_id: a.originalTransactionId,
        p_expires_at: a.expiresAt.toISOString(),
        p_auto_renew: a.autoRenew,
      });
      if (e) {
        console.warn("plan_apply_store failed");
        return null;
      }
      return res as { result?: string; plan?: string; reason?: string };
    },
  });
  return json(r.body, r.status);
});
