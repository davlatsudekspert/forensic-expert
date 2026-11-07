// FORENSIC EXPERT — R2 upload gateway (operator tool).
//
// Writes lesson audio (and tests) to the Cloudflare R2 bucket using S3 SigV4,
// so the S3 keys never leave Supabase (function secrets) and never reach chat
// or the app. Auth: header `x-upload-token` must match the Vault secret
// `r2_upload_token` (checked in the database via public.r2_upload_token_ok).
//
//   POST ?key=<path>&ct=<content-type>   body = raw bytes   → PUT object
//   GET  ?list=<prefix>&max=<n>                              → list keys/sizes
//   GET  ?head=<key>                                         → size/type or 404
// Keys are limited to `audio/…` and `test/…`; max 12 MB per object.
import { createClient } from "jsr:@supabase/supabase-js@2";
import { AwsClient } from "npm:aws4fetch@1.0.20";

const MAX_BYTES = 12 * 1024 * 1024;
const KEY_RE = /^(audio|test)\/[a-z0-9][a-z0-9/_.\-]{0,200}$/;

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json" } });
}

Deno.serve(async (req) => {
  const acc = Deno.env.get("R2_ACCOUNT_ID");
  const ak = Deno.env.get("R2_ACCESS_KEY_ID");
  const sk = Deno.env.get("R2_SECRET_ACCESS_KEY");
  const bucket = Deno.env.get("R2_BUCKET");
  if (!acc || !ak || !sk || !bucket) return json({ error: "not_configured" }, 503);

  const token = req.headers.get("x-upload-token") ?? "";
  if (token.length < 32) return json({ error: "unauthorized" }, 401);
  const db = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  const { data: ok } = await db.rpc("r2_upload_token_ok", { p_token: token });
  if (ok !== true) return json({ error: "unauthorized" }, 401);

  const r2 = new AwsClient({ accessKeyId: ak, secretAccessKey: sk, service: "s3", region: "auto" });
  const base = `https://${acc}.r2.cloudflarestorage.com/${bucket}`;
  const url = new URL(req.url);

  if (req.method === "GET" && url.searchParams.has("list")) {
    const prefix = url.searchParams.get("list") ?? "";
    const max = Math.min(Math.max(Number(url.searchParams.get("max")) || 50, 1), 1000);
    const r = await r2.fetch(`${base}?list-type=2&max-keys=${max}&prefix=${encodeURIComponent(prefix)}`);
    const xml = await r.text();
    if (!r.ok) return json({ error: "r2", status: r.status }, 502);
    const keys = [...xml.matchAll(/<Key>([^<]*)<\/Key><LastModified>[^<]*<\/LastModified><ETag>[^<]*<\/ETag><Size>(\d+)<\/Size>/g)]
      .map((m) => ({ key: m[1], size: Number(m[2]) }));
    const truncated = /<IsTruncated>true<\/IsTruncated>/.test(xml);
    return json({ count: keys.length, truncated, keys });
  }

  if (req.method === "GET" && url.searchParams.has("head")) {
    const key = url.searchParams.get("head") ?? "";
    if (!KEY_RE.test(key)) return json({ error: "bad_key" }, 400);
    const r = await r2.fetch(`${base}/${key}`, { method: "HEAD" });
    if (r.status === 404) return json({ exists: false });
    return json({ exists: r.ok, size: Number(r.headers.get("content-length") ?? 0), type: r.headers.get("content-type") });
  }

  if (req.method === "POST") {
    const key = url.searchParams.get("key") ?? "";
    if (!KEY_RE.test(key)) return json({ error: "bad_key" }, 400);
    const ct = url.searchParams.get("ct") ?? "application/octet-stream";
    if (!/^[a-z0-9.+\-]+\/[a-z0-9.+\-]+$/.test(ct)) return json({ error: "bad_type" }, 400);
    const body = new Uint8Array(await req.arrayBuffer());
    if (body.length === 0 || body.length > MAX_BYTES) return json({ error: "bad_size" }, 400);
    const r = await r2.fetch(`${base}/${key}`, {
      method: "PUT",
      headers: { "Content-Type": ct, "Cache-Control": "public, max-age=31536000, immutable" },
      body,
    });
    if (!r.ok) return json({ error: "r2", status: r.status }, 502);
    return json({ ok: true, key, size: body.length });
  }

  return json({ error: "bad_request" }, 400);
});
