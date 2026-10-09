// FORENSIC EXPERT — account deletion (Apple 5.1.1(v), Google Play policy).
// Runs server-side with the service-role key from the Edge Function
// environment (never shipped in the app). Deletes only the caller's account.
import { createClient } from "jsr:@supabase/supabase-js@2";

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
  return new Response(JSON.stringify({ ok: true }), { headers: { "Content-Type": "application/json" } });
});
