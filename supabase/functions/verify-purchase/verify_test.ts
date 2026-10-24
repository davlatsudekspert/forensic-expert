// Unit tests for store verification. No network, no database: Apple / Google
// are mocked, certificates below are throw-away TEST fixtures (never Apple's).
import { assertEquals } from "jsr:@std/assert@1";
import {
  b64url,
  handleVerify,
  type HandleDeps,
  sha256hex,
  verifyAppleJws,
} from "./verify.ts";

const ROOT = "MIIB4DCCAWagAwIBAgIUTUavMaWLkDtMe31iILKk7lrCawMwCgYIKoZIzj0EAwMwJjESMBAGA1UEAwwJVGVzdCBSb290MRAwDgYDVQQKDAdGRSBUZXN0MCAXDTI2MTAyNDE0MDYxM1oYDzIxMjYwOTMwMTQwNjEzWjAmMRIwEAYDVQQDDAlUZXN0IFJvb3QxEDAOBgNVBAoMB0ZFIFRlc3QwdjAQBgcqhkjOPQIBBgUrgQQAIgNiAATEoHIEsIxUoofOubUA2bd+o05An88PV+gAMtsKzn4gD51Vzc40eQEdLS/ZUq91RPa8DmH9bMci791zxitZLuN/iYb0IpBAHdk4M9MDVr6/Tj0HSUMFT+hxuTK29+GV4YmjUzBRMB0GA1UdDgQWBBSkt5aZiB6SziRVXe568aXbtbxflzAfBgNVHSMEGDAWgBSkt5aZiB6SziRVXe568aXbtbxflzAPBgNVHRMBAf8EBTADAQH/MAoGCCqGSM49BAMDA2gAMGUCMQDpuF0K7/UkrYS3dVLcuWkqYqG3sdjwjkGl41j7gBTvBup5MI/hoRkIHlWtGhXHSzQCMB/3AleGAFnCEvCfz69tvZrr/IJpVuHPS8+BKMWA+7BLrwLJs/qkcmSTscBCwrM29g==";
const INT = "MIIB6DCCAW6gAwIBAgIUa2ZNKnwZ142On/1kpbI+oBiBGVYwCgYIKoZIzj0EAwMwJjESMBAGA1UEAwwJVGVzdCBSb290MRAwDgYDVQQKDAdGRSBUZXN0MCAXDTI2MTAyNDE0MDYxM1oYDzIxMjYwOTMwMTQwNjEzWjAuMRowGAYDVQQDDBFUZXN0IEludGVybWVkaWF0ZTEQMA4GA1UECgwHRkUgVGVzdDB2MBAGByqGSM49AgEGBSuBBAAiA2IABKbaf5LiahnyfMyo9ub3gF4eTfWmtPwGyOtylFhTQ2drvgqB7fMX+KXE43Ex6OODzpfNtUOUMCJEQjiJuWTk/wihFcLMXNp6QHwlZw3lgZynp9raYNDRB+S+ogSW7s+9M6NTMFEwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU8WEgpxERdWT8r/G33vQKggfT2eswHwYDVR0jBBgwFoAUpLeWmYgeks4kVV3uevGl27W8X5cwCgYIKoZIzj0EAwMDaAAwZQIwLqevyFL0AZTF9Ml0fU/CNSewysWDBUq0HQc7XkAUv7KToreY0JGOm5u3y1seNtORAjEAqnWMavVnzQmRYu/dIrimj8/0PRTMCnhpGCT3GRZ3dL+hCRQHVaguSe9CMf8nqOpP";
const LEAF = "MIIBcDCB9wIUPx69kCFaVHXdFqImN+nB23vv88EwCgYIKoZIzj0EAwIwLjEaMBgGA1UEAwwRVGVzdCBJbnRlcm1lZGlhdGUxEDAOBgNVBAoMB0ZFIFRlc3QwIBcNMjYxMDI0MTQwNjEzWhgPMjEyNjA5MzAxNDA2MTNaMCYxEjAQBgNVBAMMCVRlc3QgTGVhZjEQMA4GA1UECgwHRkUgVGVzdDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABLhe4iScbuB93r1MucIjEpyNX8N/WdkhYXAOrM70G8biwTE5zHq11Cp5O/xusKvRY8FTS+yoAp9eptMZnwVMUtowCgYIKoZIzj0EAwIDaAAwZQIxAJnfEPTD589/3LLY0VaV1MyWfO5KTpG0qINclJiz4s6uwR+W2U9dI0JUouT1+7/HNgIwERhLPizl9VMEa/67sjkESlp97BH70nse8uNoSN6vMsz2WQnNK8bTB9rIek30Vy5P";
const LEAF_PKCS8 = "MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgTyKM3Rkduiu0jde4DOqmfizNuV3paRPJR73bIJwZOwOhRANCAAS4XuIknG7gfd69TLnCIxKcjV/Df1nZIWFwDqzO9BvG4sExOcx6tdQqeTv8brCr0WPBU0vsqAKfXqbTGZ8FTFLa";
const NOW = Date.parse("2026-10-25T12:00:00Z");
const BUNDLE = "uz.forensicexpert.app";
const b64 = (s: string) => Uint8Array.from(atob(s), (c) => c.charCodeAt(0));
const rootPin = await sha256hex(b64(ROOT));

async function sign(payload: Record<string, unknown>, x5c = [LEAF, INT, ROOT]): Promise<string> {
  const h = b64url(JSON.stringify({ alg: "ES256", x5c }));
  const p = b64url(JSON.stringify({ signedDate: NOW, ...payload }));
  const key = await crypto.subtle.importKey("pkcs8", b64(LEAF_PKCS8), { name: "ECDSA", namedCurve: "P-256" }, false, ["sign"]);
  const sig = new Uint8Array(await crypto.subtle.sign({ name: "ECDSA", hash: "SHA-256" }, key, new TextEncoder().encode(h + "." + p)));
  return h + "." + p + "." + b64url(sig);
}
function pem(der: ArrayBuffer): string {
  const s = btoa(String.fromCharCode(...new Uint8Array(der)));
  return "-----BEGIN PRIVATE KEY-----\n" + s.match(/.{1,64}/g)!.join("\n") + "\n-----END PRIVATE KEY-----";
}
const ecKey = pem(await crypto.subtle.exportKey("pkcs8",
  (await crypto.subtle.generateKey({ name: "ECDSA", namedCurve: "P-256" }, true, ["sign"]) as CryptoKeyPair).privateKey));
const rsaKey = pem(await crypto.subtle.exportKey("pkcs8",
  (await crypto.subtle.generateKey({ name: "RSASSA-PKCS1-v1_5", modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]), hash: "SHA-256" }, true, ["sign"]) as CryptoKeyPair).privateKey));

const IOS_ENV: Record<string, string> = {
  ASC_IAP_KEY_ID: "KEY1234567", ASC_IAP_ISSUER_ID: "11111111-2222-3333-4444-555555555555", ASC_IAP_PRIVATE_KEY: ecKey,
};
const ANDROID_ENV: Record<string, string> = {
  PLAY_SERVICE_ACCOUNT_JSON: JSON.stringify({ client_email: "svc@x.iam.gserviceaccount.com", private_key: rsaKey }),
};
type Applied = Parameters<HandleDeps["applyPlan"]>[0];
function deps(env: Record<string, string>, routes: (url: string, init?: RequestInit) => Response | Promise<Response>,
  applied: Applied[] = [], applyResult: { result?: string; plan?: string; reason?: string } | null = { result: "APPLIED", plan: "student" }): HandleDeps {
  return {
    env: (n) => env[n], now: () => NOW, appleRootSha256: rootPin,
    fetch: (u, init) => Promise.resolve(routes(u, init)),
    applyPlan: (a) => { applied.push(a); return Promise.resolve(applyResult); },
  };
}
const J = (o: unknown, status = 200) => new Response(JSON.stringify(o), { status });
const EXP = NOW + 20 * 86400_000;

async function iosBody(productId = "fe_student_monthly") {
  return { platform: "ios", product_id: productId, signed_transaction: await sign({ transactionId: "2000000111", originalTransactionId: "2000000111" }) };
}
async function appleOk(over: Record<string, unknown> = {}, status = 1, renew = 1, env = "Production") {
  return J({
    bundleId: BUNDLE,
    data: [{ lastTransactions: [{
      status,
      signedTransactionInfo: await sign({ productId: "fe_student_monthly", bundleId: BUNDLE, originalTransactionId: "2000000111", expiresDate: EXP, environment: env, ...over }),
      signedRenewalInfo: await sign({ autoRenewStatus: renew }),
    }] }],
  });
}

Deno.test("verifyAppleJws accepts the pinned chain, rejects wrong root / tamper / expired chain", async () => {
  const jws = await sign({ productId: "x" });
  assertEquals((await verifyAppleJws(jws, { rootSha256: rootPin })).productId, "x");
  let threw = false;
  try { await verifyAppleJws(jws); } catch { threw = true; } // default pin = Apple Root CA G3
  assertEquals(threw, true);
  const [h, p, s] = jws.split(".");
  const evil = h + "." + b64url(JSON.stringify({ signedDate: NOW, productId: "evil" })) + "." + s;
  threw = false;
  try { await verifyAppleJws(evil, { rootSha256: rootPin }); } catch { threw = true; }
  assertEquals(threw, true);
  const late = await sign({ signedDate: Date.parse("2200-01-01T00:00:00Z") });
  threw = false;
  try { await verifyAppleJws(late, { rootSha256: rootPin }); } catch { threw = true; }
  assertEquals(threw, true);
  threw = false;
  try { await verifyAppleJws(h + "." + p, { rootSha256: rootPin }); } catch { threw = true; }
  assertEquals(threw, true);
});

Deno.test("env missing -> NOT_CONFIGURED (both platforms)", async () => {
  const d = deps({}, () => J({}, 500));
  assertEquals((await handleVerify("u1", await iosBody(), d)).body, { result: "NOT_CONFIGURED" });
  assertEquals((await handleVerify("u1", { platform: "android", product_id: "fe_student_monthly", purchase_token: "tok-0123456789" }, d)).body,
    { result: "NOT_CONFIGURED" });
});

Deno.test("bad request -> INVALID", async () => {
  const d = deps(IOS_ENV, () => J({}, 500));
  for (const b of [null, {}, { platform: "web", product_id: "fe_student_monthly" },
    { platform: "ios", product_id: "fe_admin_monthly", signed_transaction: "a.b.c" },
    { platform: "ios", product_id: "fe_student_monthly" }]) {
    assertEquals((await handleVerify("u1", b, d)).body.result, "INVALID");
  }
});

Deno.test("iOS happy path -> APPLIED, plan_apply_store args", async () => {
  const applied: Applied[] = [];
  const urls: string[] = [];
  const d = deps(IOS_ENV, async (u, init) => {
    urls.push(u);
    assertEquals((init?.headers as Record<string, string>).Authorization.startsWith("Bearer "), true);
    return await appleOk();
  }, applied);
  const r = await handleVerify("user-1", await iosBody(), d);
  assertEquals(r.status, 200);
  assertEquals(r.body, { result: "APPLIED", plan: "student", expires_at: new Date(EXP).toISOString() });
  assertEquals(urls, ["https://api.storekit.itunes.apple.com/inApps/v1/subscriptions/2000000111"]);
  assertEquals(applied.length, 1);
  assertEquals(applied[0].userId, "user-1");
  assertEquals(applied[0].platform, "ios");
  assertEquals(applied[0].originalTransactionId, "2000000111");
  assertEquals(applied[0].autoRenew, true);
});

Deno.test("iOS sandbox fallback on 404", async () => {
  const urls: string[] = [];
  const d = deps(IOS_ENV, async (u) => {
    urls.push(u);
    return u.includes("sandbox") ? await appleOk({}, 1, 0, "Sandbox") : J({ errorCode: 4040010 }, 404);
  });
  const r = await handleVerify("u1", await iosBody(), d);
  assertEquals(r.body.result, "APPLIED");
  assertEquals(urls.length, 2);
  assertEquals(urls[1].startsWith("https://api.storekit-sandbox.itunes.apple.com/"), true);
});

Deno.test("iOS rejects: foreign bundle, other product, expired, revoked, untrusted JWS, not found", async () => {
  const run = async (res: () => Promise<Response> | Response, productId = "fe_student_monthly") =>
    (await handleVerify("u1", await iosBody(productId), deps(IOS_ENV, res))).body;
  assertEquals((await run(async () => await appleOk({ bundleId: "evil.app" }))).reason, "BUNDLE_MISMATCH");
  assertEquals((await run(async () => await appleOk(), "fe_expert_yearly")).reason, "PRODUCT_NOT_FOUND");
  assertEquals((await run(async () => await appleOk({ expiresDate: NOW - 1000 }))).reason, "EXPIRED");
  assertEquals((await run(async () => await appleOk({ revocationDate: NOW - 1000 }))).reason, "REVOKED");
  assertEquals((await run(async () => await appleOk({}, 5))).reason, "REVOKED");
  assertEquals((await run(async () => await appleOk({}, 1, 1, "Sandbox"))).reason, "ENV_MISMATCH");
  assertEquals((await run(() => J({ errorCode: 4040010 }, 404))).reason, "TRANSACTION_NOT_FOUND");
  const forged = J({ bundleId: BUNDLE, data: [{ lastTransactions: [{ status: 1,
    signedTransactionInfo: await sign({ productId: "fe_student_monthly" }, [LEAF, INT]) }] }] });
  assertEquals((await run(() => forged.clone())).reason, "JWS_UNTRUSTED");
});

Deno.test("iOS Apple outage -> 502 UNAVAILABLE; bad credentials -> NOT_CONFIGURED; apply failure -> 502", async () => {
  const body = await iosBody();
  assertEquals((await handleVerify("u1", body, deps(IOS_ENV, () => J({}, 503)))).status, 502);
  assertEquals((await handleVerify("u1", body, deps(IOS_ENV, () => { throw new Error("net"); }))).body, { result: "UNAVAILABLE" });
  assertEquals((await handleVerify("u1", body, deps(IOS_ENV, () => J({}, 401)))).body, { result: "NOT_CONFIGURED" });
  assertEquals((await handleVerify("u1", body, deps({ ...IOS_ENV, ASC_IAP_PRIVATE_KEY: "not a key" }, () => J({})))).body, { result: "NOT_CONFIGURED" });
  assertEquals((await handleVerify("u1", body, deps(IOS_ENV, async () => await appleOk(), [], null))).status, 502);
  const linked = await handleVerify("u1", body, deps(IOS_ENV, async () => await appleOk(), [], { result: "INVALID", reason: "LINKED_ELSEWHERE" }));
  assertEquals(linked.body, { result: "INVALID", reason: "LINKED_ELSEWHERE" });
});

function playRoutes(sub: Record<string, unknown> | number, calls: string[] = []) {
  return (u: string) => {
    calls.push(u);
    if (u === "https://oauth2.googleapis.com/token") return J({ access_token: "at-1" });
    if (u.endsWith(":acknowledge")) return J({});
    return typeof sub === "number" ? J({}, sub) : J(sub);
  };
}
const playSub = (over: Record<string, unknown> = {}) => ({
  subscriptionState: "SUBSCRIPTION_STATE_ACTIVE",
  acknowledgementState: "ACKNOWLEDGEMENT_STATE_PENDING",
  lineItems: [{ productId: "fe_teacher_yearly", expiryTime: new Date(EXP).toISOString(), autoRenewingPlan: { autoRenewEnabled: true } }],
  ...over,
});
const androidBody = { platform: "android", product_id: "fe_teacher_yearly", purchase_token: "purchase-token-0123456789" };

Deno.test("Android happy path -> APPLIED + acknowledge", async () => {
  const applied: Applied[] = [];
  const calls: string[] = [];
  const r = await handleVerify("user-2", androidBody, deps(ANDROID_ENV, playRoutes(playSub(), calls), applied, { result: "APPLIED", plan: "teacher" }));
  assertEquals(r.body, { result: "APPLIED", plan: "teacher", expires_at: new Date(EXP).toISOString() });
  assertEquals(applied[0].platform, "android");
  assertEquals(applied[0].originalTransactionId, "gp:" + await sha256hex("purchase-token-0123456789"));
  assertEquals(applied[0].autoRenew, true);
  assertEquals(calls.some((c) => c.includes("/purchases/subscriptionsv2/tokens/purchase-token-0123456789")), true);
  assertEquals(calls.some((c) => c.endsWith(":acknowledge")), true);
});

Deno.test("Android rejects: unknown token, expired state, other product, expired time; outage -> 502", async () => {
  const run = async (sub: Record<string, unknown> | number) =>
    await handleVerify("u2", androidBody, deps(ANDROID_ENV, playRoutes(sub)));
  assertEquals((await run(404)).body.reason, "TOKEN_UNKNOWN");
  assertEquals((await run(playSub({ subscriptionState: "SUBSCRIPTION_STATE_EXPIRED" }))).body.reason, "NOT_ACTIVE");
  assertEquals((await run(playSub({ subscriptionState: "SUBSCRIPTION_STATE_PENDING" }))).body.reason, "PENDING");
  assertEquals((await run(playSub({ lineItems: [{ productId: "fe_student_monthly", expiryTime: new Date(EXP).toISOString() }] }))).body.reason, "PRODUCT_MISMATCH");
  assertEquals((await run(playSub({ lineItems: [{ productId: "fe_teacher_yearly", expiryTime: new Date(NOW - 1000).toISOString() }] }))).body.reason, "EXPIRED");
  assertEquals((await run(503)).status, 502);
  assertEquals((await run(playSub({ subscriptionState: "SUBSCRIPTION_STATE_CANCELED" }))).body.result, "APPLIED");
  assertEquals((await run(403)).body, { result: "NOT_CONFIGURED" });
});
