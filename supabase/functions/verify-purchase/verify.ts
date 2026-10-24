// FORENSIC EXPERT — store purchase verification (pure logic, injectable
// fetch / clock, so it is unit-tested without network or database).
//
// iOS: App Store Server API  GET /inApps/v1/subscriptions/{transactionId}
//      (production first, sandbox on 404). Every JWS we rely on is verified
//      against the x5c chain, pinned to Apple Root CA - G3.
// Android: Google Play Developer API purchases.subscriptionsv2.get with a
//      service-account access token.
// Nothing here logs tokens, receipts or keys.

export type FetchFn = (url: string, init?: RequestInit) => Promise<Response>;

export const PRODUCT_RE = /^fe_(student|teacher|expert|premium)_(monthly|yearly)$/;
export const DEFAULT_BUNDLE_ID = "uz.forensicexpert.app";
export const DEFAULT_ANDROID_PACKAGE = "uz.forensicexpert.forensic_expert";
/** SHA-256 of the DER of "Apple Root CA - G3" (https://www.apple.com/certificateauthority/). */
export const APPLE_ROOT_G3_SHA256 =
  "63343abfb89a6a03ebb57e9b3f5fa7be7c4f5c756f3017b3a8c488c3653e9179";
const APPLE_PROD = "https://api.storekit.itunes.apple.com";
const APPLE_SANDBOX = "https://api.storekit-sandbox.itunes.apple.com";
const GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token";
const PLAY_API = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications";

// ------------------------------------------------------------------ bytes
type Bytes = Uint8Array<ArrayBuffer>;
const enc = new TextEncoder();
const dec = new TextDecoder();

export function b64decode(s: string): Bytes {
  const n = s.replace(/-/g, "+").replace(/_/g, "/");
  const bin = atob(n + "=".repeat((4 - (n.length % 4)) % 4));
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}
export function b64url(b: Uint8Array | string): string {
  const u = typeof b === "string" ? enc.encode(b) : b;
  let s = "";
  for (const c of u) s += String.fromCharCode(c);
  return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}
export async function sha256hex(b: Bytes | string): Promise<string> {
  const u = typeof b === "string" ? enc.encode(b) : b;
  const h = new Uint8Array(await crypto.subtle.digest("SHA-256", u));
  return [...h].map((x) => x.toString(16).padStart(2, "0")).join("");
}
function pemToDer(pem: string): Bytes {
  return b64decode(pem.replace(/-----[^-]+-----/g, "").replace(/\s+/g, ""));
}
function same(a: Uint8Array, b: Uint8Array): boolean {
  if (a.length !== b.length) return false;
  for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return false;
  return true;
}

// ------------------------------------------------------------- minimal DER
interface Tlv { tag: number; start: number; end: number; full: Bytes }
function tlv(b: Bytes, off: number): Tlv {
  const tag = b[off];
  let len = b[off + 1];
  let p = off + 2;
  if (len & 0x80) {
    const n = len & 0x7f;
    if (n < 1 || n > 4) throw new Error("der length");
    len = 0;
    for (let i = 0; i < n; i++) len = len * 256 + b[p++];
  }
  if (p + len > b.length) throw new Error("der overflow");
  return { tag, start: p, end: p + len, full: b.subarray(off, p + len) };
}
function children(b: Bytes, t: Tlv): Tlv[] {
  const out: Tlv[] = [];
  for (let p = t.start; p < t.end;) {
    const c = tlv(b, p);
    out.push(c);
    p = c.end;
  }
  return out;
}
function oid(b: Bytes, t: Tlv): string {
  const v = b.subarray(t.start, t.end);
  const parts = [Math.floor(v[0] / 40), v[0] % 40];
  let x = 0;
  for (let i = 1; i < v.length; i++) {
    x = x * 128 + (v[i] & 0x7f);
    if (!(v[i] & 0x80)) {
      parts.push(x);
      x = 0;
    }
  }
  return parts.join(".");
}
function derTime(b: Bytes, t: Tlv): number {
  const s = dec.decode(b.subarray(t.start, t.end));
  const m = t.tag === 0x17
    ? /^(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)Z$/.exec(s)
    : /^(\d{4})(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)Z$/.exec(s);
  if (!m) throw new Error("der time");
  let y = Number(m[1]);
  if (t.tag === 0x17) y += y >= 50 ? 1900 : 2000;
  return Date.UTC(y, Number(m[2]) - 1, Number(m[3]), Number(m[4]), Number(m[5]), Number(m[6]));
}
interface Cert {
  der: Bytes;
  tbs: Bytes;
  sigAlg: string;
  sig: Bytes; // DER ECDSA-Sig-Value
  issuer: Bytes;
  subject: Bytes;
  spki: Bytes;
  curve: "P-256" | "P-384";
  notBefore: number;
  notAfter: number;
}
const CURVES: Record<string, "P-256" | "P-384"> = {
  "1.2.840.10045.3.1.7": "P-256",
  "1.3.132.0.34": "P-384",
};
function parseCert(der: Bytes): Cert {
  const top = tlv(der, 0);
  const [tbs, alg, sigBits] = children(der, top);
  const f = children(der, tbs);
  let i = 0;
  if (f[i].tag === 0xa0) i++; // version
  i++; // serial
  i++; // tbs signature algorithm
  const issuer = f[i++];
  const validity = children(der, f[i++]);
  const subject = f[i++];
  const spki = f[i++];
  const spkiAlg = children(der, children(der, spki)[0]);
  if (oid(der, spkiAlg[0]) !== "1.2.840.10045.2.1") throw new Error("not ec key");
  const curve = CURVES[oid(der, spkiAlg[1])];
  if (!curve) throw new Error("unsupported curve");
  return {
    der,
    tbs: tbs.full,
    sigAlg: oid(der, children(der, alg)[0]),
    sig: der.subarray(sigBits.start + 1, sigBits.end),
    issuer: issuer.full,
    subject: subject.full,
    spki: spki.full,
    curve,
    notBefore: derTime(der, validity[0]),
    notAfter: derTime(der, validity[1]),
  };
}
/** DER ECDSA-Sig-Value -> raw r||s of `size` bytes each. */
function ecdsaDerToRaw(sig: Bytes, size: number): Bytes {
  const seq = tlv(sig, 0);
  const [r, s] = children(sig, seq);
  const out = new Uint8Array(size * 2);
  for (const [t, off] of [[r, 0], [s, size]] as const) {
    let v = sig.subarray(t.start, t.end);
    while (v.length > size && v[0] === 0) v = v.subarray(1);
    if (v.length > size) throw new Error("sig size");
    out.set(v, off + size - v.length);
  }
  return out;
}
async function importEcPublic(spki: Bytes, curve: "P-256" | "P-384"): Promise<CryptoKey> {
  return await crypto.subtle.importKey("spki", spki, { name: "ECDSA", namedCurve: curve }, false, [
    "verify",
  ]);
}
const SIG_HASH: Record<string, "SHA-256" | "SHA-384"> = {
  "1.2.840.10045.4.3.2": "SHA-256",
  "1.2.840.10045.4.3.3": "SHA-384",
};

/**
 * Verifies a JWS signed by an x5c chain (leaf first) that ends in the pinned
 * root. Returns the payload object or throws. `at` (ms) is the moment the
 * certificates must have been valid (the JWS's own signedDate when present).
 */
export async function verifyAppleJws(
  jws: string,
  opts: { rootSha256?: string; now?: () => number } = {},
): Promise<Record<string, unknown>> {
  const parts = jws.split(".");
  if (parts.length !== 3) throw new Error("not a jws");
  const header = JSON.parse(dec.decode(b64decode(parts[0])));
  if (header.alg !== "ES256" || !Array.isArray(header.x5c) || header.x5c.length < 2) {
    throw new Error("bad jws header");
  }
  const payload = JSON.parse(dec.decode(b64decode(parts[1])));
  const at = typeof payload.signedDate === "number" ? payload.signedDate : (opts.now ?? Date.now)();
  const certs = (header.x5c as string[]).map((c) => parseCert(b64decode(c)));
  const pin = opts.rootSha256 ?? APPLE_ROOT_G3_SHA256;
  if ((await sha256hex(certs[certs.length - 1].der)) !== pin) throw new Error("root not pinned");
  for (let i = 0; i < certs.length; i++) {
    const c = certs[i];
    if (at < c.notBefore || at > c.notAfter) throw new Error("cert not valid");
    if (i < certs.length - 1) {
      const parent = certs[i + 1];
      if (!same(c.issuer, parent.subject)) throw new Error("chain mismatch");
      const hash = SIG_HASH[c.sigAlg];
      if (!hash) throw new Error("unsupported sig alg");
      const size = parent.curve === "P-256" ? 32 : 48;
      const key = await importEcPublic(parent.spki, parent.curve);
      const ok = await crypto.subtle.verify(
        { name: "ECDSA", hash },
        key,
        ecdsaDerToRaw(c.sig, size),
        c.tbs,
      );
      if (!ok) throw new Error("cert signature");
    }
  }
  const leaf = certs[0];
  if (leaf.curve !== "P-256") throw new Error("leaf curve");
  const ok = await crypto.subtle.verify(
    { name: "ECDSA", hash: "SHA-256" },
    await importEcPublic(leaf.spki, "P-256"),
    b64decode(parts[2]),
    enc.encode(`${parts[0]}.${parts[1]}`),
  );
  if (!ok) throw new Error("jws signature");
  return payload;
}

// -------------------------------------------------------------- results
export type Verified = {
  ok: true;
  productId: string;
  originalTransactionId: string;
  expiresAt: Date;
  autoRenew: boolean;
};
export type Failed = {
  ok: false;
  /** invalid: the store says no; config: our credentials are wrong; transient: try again. */
  kind: "invalid" | "config" | "transient";
  reason: string;
};
export type VerifyOutcome = Verified | Failed;
const fail = (kind: Failed["kind"], reason: string): Failed => ({ ok: false, kind, reason });

export interface Deps {
  fetch: FetchFn;
  now: () => number;
  appleRootSha256?: string;
}

// ------------------------------------------------------------------ iOS
export interface IosConfig { keyId: string; issuerId: string; privateKey: string; bundleId: string }
export function iosConfigFromEnv(get: (n: string) => string | undefined): IosConfig | null {
  const keyId = get("ASC_IAP_KEY_ID")?.trim();
  const issuerId = get("ASC_IAP_ISSUER_ID")?.trim();
  const privateKey = get("ASC_IAP_PRIVATE_KEY")?.replace(/\\n/g, "\n").trim();
  if (!keyId || !issuerId || !privateKey) return null;
  return { keyId, issuerId, privateKey, bundleId: get("APP_BUNDLE_ID")?.trim() || DEFAULT_BUNDLE_ID };
}
async function appleAppJwt(cfg: IosConfig, nowMs: number): Promise<string> {
  const iat = Math.floor(nowMs / 1000);
  const head = b64url(JSON.stringify({ alg: "ES256", kid: cfg.keyId, typ: "JWT" }));
  const body = b64url(JSON.stringify({
    iss: cfg.issuerId, iat, exp: iat + 300, aud: "appstoreconnect-v1", bid: cfg.bundleId,
  }));
  const key = await crypto.subtle.importKey(
    "pkcs8", pemToDer(cfg.privateKey), { name: "ECDSA", namedCurve: "P-256" }, false, ["sign"],
  );
  const sig = new Uint8Array(
    await crypto.subtle.sign({ name: "ECDSA", hash: "SHA-256" }, key, enc.encode(`${head}.${body}`)),
  );
  return `${head}.${body}.${b64url(sig)}`;
}
function jwsPayloadUnverified(jws: string): Record<string, unknown> | null {
  try {
    const p = jws.split(".");
    if (p.length !== 3) return null;
    return JSON.parse(dec.decode(b64decode(p[1])));
  } catch {
    return null;
  }
}

export async function verifyIos(
  cfg: IosConfig,
  input: { productId: string; signedTransaction: string },
  deps: Deps,
): Promise<VerifyOutcome> {
  const claimed = jwsPayloadUnverified(input.signedTransaction);
  const txId = String(claimed?.originalTransactionId ?? claimed?.transactionId ?? "");
  if (!/^\d{1,20}$/.test(txId)) return fail("invalid", "BAD_TRANSACTION");
  let jwt: string;
  try {
    jwt = await appleAppJwt(cfg, deps.now());
  } catch {
    return fail("config", "BAD_KEY");
  }
  for (const [host, env] of [[APPLE_PROD, "Production"], [APPLE_SANDBOX, "Sandbox"]] as const) {
    let res: Response;
    try {
      res = await deps.fetch(`${host}/inApps/v1/subscriptions/${txId}`, {
        headers: { Authorization: `Bearer ${jwt}` },
      });
    } catch {
      return fail("transient", "APPLE_UNREACHABLE");
    }
    if (res.status === 404) continue; // not found in this environment
    if (res.status === 401 || res.status === 403) return fail("config", "APPLE_AUTH");
    if (res.status === 429 || res.status >= 500) return fail("transient", "APPLE_BUSY");
    if (!res.ok) return fail("invalid", `APPLE_${res.status}`);
    // deno-lint-ignore no-explicit-any
    let data: any;
    try {
      data = await res.json();
    } catch {
      return fail("transient", "APPLE_BAD_BODY");
    }
    if (data?.bundleId !== cfg.bundleId) return fail("invalid", "BUNDLE_MISMATCH");
    for (const group of data?.data ?? []) {
      for (const last of group?.lastTransactions ?? []) {
        let tx: Record<string, unknown>;
        try {
          tx = await verifyAppleJws(String(last.signedTransactionInfo), {
            rootSha256: deps.appleRootSha256, now: deps.now,
          });
        } catch {
          return fail("invalid", "JWS_UNTRUSTED");
        }
        if (tx.productId !== input.productId) continue;
        if (tx.bundleId !== cfg.bundleId) return fail("invalid", "BUNDLE_MISMATCH");
        if (tx.environment !== env) return fail("invalid", "ENV_MISMATCH");
        if (typeof tx.expiresDate !== "number" || tx.revocationDate || last.status === 5) {
          return fail("invalid", "REVOKED");
        }
        let expires = tx.expiresDate;
        let autoRenew = false;
        if (last.signedRenewalInfo) {
          try {
            const ren = await verifyAppleJws(String(last.signedRenewalInfo), {
              rootSha256: deps.appleRootSha256, now: deps.now,
            });
            autoRenew = ren.autoRenewStatus === 1;
            if (last.status === 4 && typeof ren.gracePeriodExpiresDate === "number") {
              expires = Math.max(expires, ren.gracePeriodExpiresDate);
            }
          } catch {
            return fail("invalid", "JWS_UNTRUSTED");
          }
        }
        if (expires <= deps.now()) return fail("invalid", "EXPIRED");
        return {
          ok: true,
          productId: input.productId,
          originalTransactionId: String(tx.originalTransactionId ?? txId),
          expiresAt: new Date(expires),
          autoRenew,
        };
      }
    }
    return fail("invalid", "PRODUCT_NOT_FOUND");
  }
  return fail("invalid", "TRANSACTION_NOT_FOUND");
}

// -------------------------------------------------------------- Android
export interface AndroidConfig { clientEmail: string; privateKey: string; packageName: string }
export function androidConfigFromEnv(get: (n: string) => string | undefined): AndroidConfig | null {
  const raw = get("PLAY_SERVICE_ACCOUNT_JSON")?.trim();
  if (!raw) return null;
  try {
    const j = JSON.parse(raw);
    if (typeof j.client_email !== "string" || typeof j.private_key !== "string") return null;
    return {
      clientEmail: j.client_email,
      privateKey: j.private_key,
      packageName: get("ANDROID_PACKAGE")?.trim() || DEFAULT_ANDROID_PACKAGE,
    };
  } catch {
    return null;
  }
}
async function googleAccessToken(cfg: AndroidConfig, deps: Deps): Promise<string | Failed> {
  const iat = Math.floor(deps.now() / 1000);
  const head = b64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const body = b64url(JSON.stringify({
    iss: cfg.clientEmail, scope: "https://www.googleapis.com/auth/androidpublisher",
    aud: GOOGLE_TOKEN_URL, iat, exp: iat + 3000,
  }));
  let sig: Bytes;
  try {
    const key = await crypto.subtle.importKey(
      "pkcs8", pemToDer(cfg.privateKey),
      { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, false, ["sign"],
    );
    sig = new Uint8Array(await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, enc.encode(`${head}.${body}`)));
  } catch {
    return fail("config", "BAD_KEY");
  }
  let res: Response;
  try {
    res = await deps.fetch(GOOGLE_TOKEN_URL, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion: `${head}.${body}.${b64url(sig)}`,
      }).toString(),
    });
  } catch {
    return fail("transient", "GOOGLE_UNREACHABLE");
  }
  if (res.status === 400 || res.status === 401) return fail("config", "GOOGLE_AUTH");
  if (!res.ok) return fail("transient", "GOOGLE_BUSY");
  const j = await res.json().catch(() => null);
  return typeof j?.access_token === "string" ? j.access_token : fail("transient", "GOOGLE_BAD_BODY");
}

export async function verifyAndroid(
  cfg: AndroidConfig,
  input: { productId: string; purchaseToken: string },
  deps: Deps,
): Promise<VerifyOutcome> {
  if (input.purchaseToken.length < 10 || input.purchaseToken.length > 4000) {
    return fail("invalid", "BAD_TOKEN");
  }
  const at = await googleAccessToken(cfg, deps);
  if (typeof at !== "string") return at;
  const auth = { Authorization: `Bearer ${at}` };
  const tokenPath = encodeURIComponent(input.purchaseToken);
  let res: Response;
  try {
    res = await deps.fetch(
      `${PLAY_API}/${encodeURIComponent(cfg.packageName)}/purchases/subscriptionsv2/tokens/${tokenPath}`,
      { headers: auth },
    );
  } catch {
    return fail("transient", "GOOGLE_UNREACHABLE");
  }
  if (res.status === 400 || res.status === 404 || res.status === 410) return fail("invalid", "TOKEN_UNKNOWN");
  if (res.status === 401 || res.status === 403) return fail("config", "GOOGLE_FORBIDDEN");
  if (res.status === 429 || res.status >= 500) return fail("transient", "GOOGLE_BUSY");
  if (!res.ok) return fail("invalid", `GOOGLE_${res.status}`);
  // deno-lint-ignore no-explicit-any
  const d: any = await res.json().catch(() => null);
  if (!d) return fail("transient", "GOOGLE_BAD_BODY");
  const state = String(d.subscriptionState ?? "");
  // CANCELED keeps access until expiry; ON_HOLD / PAUSED / EXPIRED / PENDING do not.
  if (!["SUBSCRIPTION_STATE_ACTIVE", "SUBSCRIPTION_STATE_IN_GRACE_PERIOD", "SUBSCRIPTION_STATE_CANCELED"]
        .includes(state)) {
    return fail("invalid", state === "SUBSCRIPTION_STATE_PENDING" ? "PENDING" : "NOT_ACTIVE");
  }
  // deno-lint-ignore no-explicit-any
  const line = (d.lineItems ?? []).find((l: any) => l?.productId === input.productId);
  if (!line) return fail("invalid", "PRODUCT_MISMATCH");
  const expires = Date.parse(String(line.expiryTime ?? ""));
  if (!Number.isFinite(expires) || expires <= deps.now()) return fail("invalid", "EXPIRED");
  if (d.acknowledgementState === "ACKNOWLEDGEMENT_STATE_PENDING") {
    // Best effort; Google refunds unacknowledged purchases after 3 days.
    try {
      await deps.fetch(
        `${PLAY_API}/${encodeURIComponent(cfg.packageName)}/purchases/subscriptions/` +
          `${encodeURIComponent(input.productId)}/tokens/${tokenPath}:acknowledge`,
        { method: "POST", headers: { ...auth, "Content-Type": "application/json" }, body: "{}" },
      );
    } catch { /* ignored */ }
  }
  return {
    ok: true,
    productId: input.productId,
    originalTransactionId: "gp:" + await sha256hex(input.purchaseToken),
    expiresAt: new Date(expires),
    autoRenew: line.autoRenewingPlan?.autoRenewEnabled === true,
  };
}

// ----------------------------------------------------------- orchestration
export interface HandleDeps extends Deps {
  env: (n: string) => string | undefined;
  /** Calls public.plan_apply_store with the service-role client. */
  applyPlan: (a: {
    userId: string; platform: "ios" | "android"; productId: string;
    originalTransactionId: string; expiresAt: Date; autoRenew: boolean;
  }) => Promise<{ result?: string; plan?: string; reason?: string } | null>;
}
export interface HandleResult { status: number; body: Record<string, unknown> }

export async function handleVerify(userId: string, body: unknown, deps: HandleDeps): Promise<HandleResult> {
  const b = (body ?? {}) as Record<string, unknown>;
  const platform = b.platform;
  const productId = typeof b.product_id === "string" ? b.product_id : "";
  if ((platform !== "ios" && platform !== "android") || !PRODUCT_RE.test(productId)) {
    return { status: 200, body: { result: "INVALID", reason: "BAD_REQUEST" } };
  }
  let out: VerifyOutcome;
  if (platform === "ios") {
    const cfg = iosConfigFromEnv(deps.env);
    if (!cfg) return { status: 200, body: { result: "NOT_CONFIGURED" } };
    const signed = typeof b.signed_transaction === "string" ? b.signed_transaction : "";
    if (!signed || signed.length > 20_000) return { status: 200, body: { result: "INVALID", reason: "BAD_REQUEST" } };
    out = await verifyIos(cfg, { productId, signedTransaction: signed }, deps);
  } else {
    const cfg = androidConfigFromEnv(deps.env);
    if (!cfg) return { status: 200, body: { result: "NOT_CONFIGURED" } };
    const tok = typeof b.purchase_token === "string" ? b.purchase_token : "";
    if (!tok) return { status: 200, body: { result: "INVALID", reason: "BAD_REQUEST" } };
    out = await verifyAndroid(cfg, { productId, purchaseToken: tok }, deps);
  }
  if (!out.ok) {
    if (out.kind === "config") return { status: 200, body: { result: "NOT_CONFIGURED" } };
    if (out.kind === "transient") return { status: 502, body: { result: "UNAVAILABLE" } };
    return { status: 200, body: { result: "INVALID", reason: out.reason } };
  }
  const applied = await deps.applyPlan({
    userId, platform, productId, originalTransactionId: out.originalTransactionId,
    expiresAt: out.expiresAt, autoRenew: out.autoRenew,
  });
  if (!applied) return { status: 502, body: { result: "UNAVAILABLE" } };
  if (applied.result !== "APPLIED") {
    return { status: 200, body: { result: "INVALID", ...(applied.reason ? { reason: applied.reason } : {}) } };
  }
  return {
    status: 200,
    body: { result: "APPLIED", plan: applied.plan, expires_at: out.expiresAt.toISOString() },
  };
}
