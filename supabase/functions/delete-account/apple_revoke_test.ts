// Unit tests for Apple token revocation. Apple is mocked: no network call.
// The signing key is generated in-test (throwaway, never a real .p8).
import { assert, assertEquals } from "jsr:@std/assert@1";
import {
  appleConfigFromEnv,
  appleSubjectOf,
  buildClientSecret,
  jwtSubject,
  revokeAppleAccess,
} from "./apple_revoke.ts";

const SUB = "001234.abcdef.5678";

function b64u(s: string): string {
  return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}
const idToken = (sub: string) => `${b64u('{"alg":"none"}')}.${b64u(JSON.stringify({ sub }))}.sig`;

async function testConfig() {
  const kp = await crypto.subtle.generateKey({ name: "ECDSA", namedCurve: "P-256" }, true, ["sign", "verify"]);
  const der = new Uint8Array(await crypto.subtle.exportKey("pkcs8", kp.privateKey));
  let bin = "";
  for (const b of der) bin += String.fromCharCode(b);
  const pem = `-----BEGIN PRIVATE KEY-----\n${btoa(bin)}\n-----END PRIVATE KEY-----`;
  return {
    cfg: { teamId: "TEAM123456", keyId: "KEY1234567", clientId: "uz.example.app", privateKey: pem },
    publicKey: kp.publicKey,
  };
}

type Call = { url: string; body: URLSearchParams };
function mockFetch(
  calls: Call[],
  responses: Array<Response | Error>,
) {
  return (url: string, init?: RequestInit) => {
    calls.push({ url, body: new URLSearchParams(String(init?.body ?? "")) });
    const r = responses.shift();
    if (r instanceof Error) return Promise.reject(r);
    return Promise.resolve(r ?? new Response("{}", { status: 500 }));
  };
}
const json = (o: unknown, status = 200) =>
  new Response(JSON.stringify(o), { status, headers: { "Content-Type": "application/json" } });

Deno.test("appleConfigFromEnv needs all four secrets", () => {
  const full: Record<string, string> = {
    APPLE_TEAM_ID: "T",
    APPLE_KEY_ID: "K",
    APPLE_CLIENT_ID: "C",
    APPLE_PRIVATE_KEY: "P",
  };
  assert(appleConfigFromEnv((n) => full[n]) !== null);
  for (const missing of Object.keys(full)) {
    const partial = { ...full };
    delete partial[missing];
    assertEquals(appleConfigFromEnv((n) => partial[n]), null);
  }
});

Deno.test("client_secret is a valid ES256 JWT with Apple claims", async () => {
  const { cfg, publicKey } = await testConfig();
  const jwt = await buildClientSecret(cfg, 1_800_000_000);
  const [h, p, s] = jwt.split(".");
  const dec = (x: string) => JSON.parse(atob(x.replace(/-/g, "+").replace(/_/g, "/")));
  assertEquals(dec(h), { alg: "ES256", kid: "KEY1234567", typ: "JWT" });
  assertEquals(dec(p), {
    iss: "TEAM123456",
    iat: 1_800_000_000,
    exp: 1_800_000_300,
    aud: "https://appleid.apple.com",
    sub: "uz.example.app",
  });
  const sig = Uint8Array.from(atob(s.replace(/-/g, "+").replace(/_/g, "/").padEnd(88, "=")), (c) => c.charCodeAt(0));
  assertEquals(sig.length, 64);
  const ok = await crypto.subtle.verify(
    { name: "ECDSA", hash: "SHA-256" },
    publicKey,
    sig,
    new TextEncoder().encode(`${h}.${p}`),
  );
  assert(ok);
});

Deno.test("PEM with literal \\n sequences is accepted", async () => {
  const { cfg } = await testConfig();
  const escaped = { ...cfg, privateKey: cfg.privateKey.replace(/\n/g, "\\n") };
  const jwt = await buildClientSecret(escaped, 1);
  assertEquals(jwt.split(".").length, 3);
});

Deno.test("jwtSubject / appleSubjectOf", () => {
  assertEquals(jwtSubject(idToken(SUB)), SUB);
  assertEquals(jwtSubject("garbage"), null);
  assertEquals(jwtSubject(undefined), null);
  assertEquals(appleSubjectOf({ identities: [{ provider: "google", id: "g" }] }), null);
  assertEquals(appleSubjectOf({ identities: [{ provider: "apple", identity_data: { sub: SUB } }] }), SUB);
  assertEquals(appleSubjectOf({ identities: null }), null);
});

Deno.test("revoke: exchanges the code then revokes the refresh token", async () => {
  const { cfg } = await testConfig();
  const calls: Call[] = [];
  const res = await revokeAppleAccess({
    code: "one-time-code",
    cfg,
    expectedSubject: SUB,
    fetchFn: mockFetch(calls, [
      json({ refresh_token: "r-tok", access_token: "a-tok", id_token: idToken(SUB) }),
      new Response("", { status: 200 }),
    ]),
  });
  assertEquals(res, { revoked: true, reason: "ok" });
  assertEquals(calls.length, 2);
  assertEquals(calls[0].url, "https://appleid.apple.com/auth/token");
  assertEquals(calls[0].body.get("grant_type"), "authorization_code");
  assertEquals(calls[0].body.get("code"), "one-time-code");
  assertEquals(calls[0].body.get("client_id"), "uz.example.app");
  assertEquals(calls[0].body.get("client_secret")?.split(".").length, 3);
  assertEquals(calls[1].url, "https://appleid.apple.com/auth/revoke");
  assertEquals(calls[1].body.get("token"), "r-tok");
  assertEquals(calls[1].body.get("token_type_hint"), "refresh_token");
  assertEquals(calls[1].body.get("client_id"), "uz.example.app");
});

Deno.test("revoke: no secrets -> skipped, Apple never called", async () => {
  const calls: Call[] = [];
  const res = await revokeAppleAccess({
    code: "c",
    cfg: null,
    expectedSubject: SUB,
    fetchFn: mockFetch(calls, []),
  });
  assertEquals(res, { revoked: false, reason: "not_configured" });
  assertEquals(calls.length, 0);
});

Deno.test("revoke: caller without Apple identity -> skipped", async () => {
  const { cfg } = await testConfig();
  const calls: Call[] = [];
  const res = await revokeAppleAccess({ code: "c", cfg, expectedSubject: null, fetchFn: mockFetch(calls, []) });
  assertEquals(res.revoked, false);
  assertEquals(calls.length, 0);
});

Deno.test("revoke: Apple token error -> false, no revoke call, no throw", async () => {
  const { cfg } = await testConfig();
  const calls: Call[] = [];
  const res = await revokeAppleAccess({
    code: "bad",
    cfg,
    expectedSubject: SUB,
    fetchFn: mockFetch(calls, [json({ error: "invalid_grant" }, 400)]),
  });
  assertEquals(res, { revoked: false, reason: "token_http_400" });
  assertEquals(calls.length, 1);
});

Deno.test("revoke: code of another Apple account -> not revoked", async () => {
  const { cfg } = await testConfig();
  const calls: Call[] = [];
  const res = await revokeAppleAccess({
    code: "c",
    cfg,
    expectedSubject: SUB,
    fetchFn: mockFetch(calls, [json({ refresh_token: "r", id_token: idToken("someone.else") })]),
  });
  assertEquals(res, { revoked: false, reason: "subject_mismatch" });
  assertEquals(calls.length, 1);
});

Deno.test("revoke: Apple revoke error / network failure -> false, no throw", async () => {
  const { cfg } = await testConfig();
  const a = await revokeAppleAccess({
    code: "c",
    cfg,
    expectedSubject: SUB,
    fetchFn: mockFetch([], [json({ refresh_token: "r", id_token: idToken(SUB) }), new Response("", { status: 503 })]),
  });
  assertEquals(a, { revoked: false, reason: "revoke_http_503" });
  const b = await revokeAppleAccess({
    code: "c",
    cfg,
    expectedSubject: SUB,
    fetchFn: mockFetch([], [new TypeError("secret-looking detail")]),
  });
  assertEquals(b, { revoked: false, reason: "error_TypeError" });
});

Deno.test("revoke: falls back to access_token when no refresh_token", async () => {
  const { cfg } = await testConfig();
  const calls: Call[] = [];
  const res = await revokeAppleAccess({
    code: "c",
    cfg,
    expectedSubject: SUB,
    fetchFn: mockFetch(calls, [json({ access_token: "a-tok", id_token: idToken(SUB) }), new Response("", { status: 200 })]),
  });
  assertEquals(res.revoked, true);
  assertEquals(calls[1].body.get("token_type_hint"), "access_token");
});

Deno.test("revoke: invalid private key -> false, no throw", async () => {
  const { cfg } = await testConfig();
  const res = await revokeAppleAccess({
    code: "c",
    cfg: { ...cfg, privateKey: "not a key" },
    expectedSubject: SUB,
    fetchFn: mockFetch([], []),
  });
  assertEquals(res.revoked, false);
});
