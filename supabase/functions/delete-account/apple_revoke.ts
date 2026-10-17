// Sign in with Apple token revocation (App Store Review 5.1.1(v)).
//
// Flow: authorizationCode (one-time, short-lived, obtained by the app via a
// fresh Apple re-authentication) -> POST /auth/token -> refresh_token ->
// POST /auth/revoke. The client_secret is an ES256 JWT signed with the
// Sign in with Apple key (.p8). Every value comes from the function
// environment (Deno.env) — nothing is hard-coded and nothing secret is logged.
//
// Best effort by design: any problem returns { revoked: false, reason } and
// the caller still deletes the account.

const APPLE_AUDIENCE = "https://appleid.apple.com";
const TOKEN_URL = "https://appleid.apple.com/auth/token";
const REVOKE_URL = "https://appleid.apple.com/auth/revoke";
const TIMEOUT_MS = 8000;

export interface AppleConfig {
  teamId: string;
  keyId: string;
  clientId: string;
  privateKey: string;
}

export interface RevokeResult {
  revoked: boolean;
  /** Short machine code, never contains secrets. */
  reason: string;
}

type EnvGetter = (name: string) => string | undefined;
export type FetchFn = (input: string, init?: RequestInit) => Promise<Response>;

/** Reads the four secrets; `null` when any is missing (revoke is skipped). */
export function appleConfigFromEnv(get: EnvGetter): AppleConfig | null {
  const teamId = get("APPLE_TEAM_ID")?.trim();
  const keyId = get("APPLE_KEY_ID")?.trim();
  const clientId = get("APPLE_CLIENT_ID")?.trim();
  const privateKey = get("APPLE_PRIVATE_KEY");
  if (!teamId || !keyId || !clientId || !privateKey?.trim()) return null;
  return { teamId, keyId, clientId, privateKey };
}

function b64url(data: Uint8Array | string): string {
  const bytes = typeof data === "string" ? new TextEncoder().encode(data) : data;
  let s = "";
  for (const b of bytes) s += String.fromCharCode(b);
  return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function pemToDer(pem: string): Uint8Array {
  // Dashboard secrets are often pasted with literal "\n" sequences.
  const body = pem
    .replace(/\\n/g, "\n")
    .replace(/-----BEGIN [A-Z ]+-----/, "")
    .replace(/-----END [A-Z ]+-----/, "")
    .replace(/\s+/g, "");
  const bin = atob(body);
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}

/** ES256 client_secret JWT (valid 5 minutes — it is used immediately). */
export async function buildClientSecret(
  cfg: AppleConfig,
  nowSec: number = Math.floor(Date.now() / 1000),
): Promise<string> {
  const header = { alg: "ES256", kid: cfg.keyId, typ: "JWT" };
  const payload = {
    iss: cfg.teamId,
    iat: nowSec,
    exp: nowSec + 300,
    aud: APPLE_AUDIENCE,
    sub: cfg.clientId,
  };
  const signingInput = `${b64url(JSON.stringify(header))}.${b64url(JSON.stringify(payload))}`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    // pemToDer returns a fresh, zero-offset array, so its buffer is exactly the DER bytes.
    pemToDer(cfg.privateKey).buffer as ArrayBuffer,
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["sign"],
  );
  // WebCrypto ECDSA output is raw r||s (P1363), exactly what JWS ES256 needs.
  const sig = new Uint8Array(
    await crypto.subtle.sign(
      { name: "ECDSA", hash: "SHA-256" },
      key,
      new TextEncoder().encode(signingInput),
    ),
  );
  return `${signingInput}.${b64url(sig)}`;
}

/** `sub` claim of a JWT (signature not verified: it came straight from Apple over TLS). */
export function jwtSubject(jwt: unknown): string | null {
  if (typeof jwt !== "string") return null;
  const parts = jwt.split(".");
  if (parts.length !== 3) return null;
  try {
    const json = atob(parts[1].replace(/-/g, "+").replace(/_/g, "/").padEnd(Math.ceil(parts[1].length / 4) * 4, "="));
    const sub = JSON.parse(json)?.sub;
    return typeof sub === "string" && sub ? sub : null;
  } catch {
    return null;
  }
}

/** Apple user id (`sub`) of the caller's Apple identity, if they have one. */
export function appleSubjectOf(
  user: { identities?: Array<{ provider?: string; id?: string; identity_data?: Record<string, unknown> }> | null },
): string | null {
  const ident = user.identities?.find((i) => i.provider === "apple");
  if (!ident) return null;
  const fromData = ident.identity_data?.["sub"];
  if (typeof fromData === "string" && fromData) return fromData;
  return typeof ident.id === "string" && ident.id ? ident.id : null;
}

function form(fields: Record<string, string>): RequestInit {
  return {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams(fields).toString(),
    signal: AbortSignal.timeout(TIMEOUT_MS),
  };
}

/**
 * Exchanges the code and revokes the resulting token. Never throws.
 * `expectedSubject` is the caller's Apple user id; if the code belongs to a
 * different Apple account nothing is revoked.
 */
export async function revokeAppleAccess(args: {
  code: string;
  cfg: AppleConfig | null;
  expectedSubject: string | null;
  fetchFn?: FetchFn;
  nowSec?: number;
}): Promise<RevokeResult> {
  const { code, cfg, expectedSubject } = args;
  const fetchFn: FetchFn = args.fetchFn ?? ((u, i) => fetch(u, i));
  if (!cfg) return { revoked: false, reason: "not_configured" };
  if (!expectedSubject) return { revoked: false, reason: "no_apple_identity" };
  try {
    const clientSecret = await buildClientSecret(cfg, args.nowSec);
    const tokenRes = await fetchFn(
      TOKEN_URL,
      form({
        grant_type: "authorization_code",
        code,
        client_id: cfg.clientId,
        client_secret: clientSecret,
      }),
    );
    if (!tokenRes.ok) {
      await tokenRes.body?.cancel();
      return { revoked: false, reason: `token_http_${tokenRes.status}` };
    }
    const tok = await tokenRes.json();
    if (jwtSubject(tok?.id_token) !== expectedSubject) {
      return { revoked: false, reason: "subject_mismatch" };
    }
    const refresh = typeof tok?.refresh_token === "string" ? tok.refresh_token : "";
    const access = typeof tok?.access_token === "string" ? tok.access_token : "";
    const token = refresh || access;
    if (!token) return { revoked: false, reason: "no_token" };
    const revokeRes = await fetchFn(
      REVOKE_URL,
      form({
        token,
        token_type_hint: refresh ? "refresh_token" : "access_token",
        client_id: cfg.clientId,
        client_secret: clientSecret,
      }),
    );
    await revokeRes.body?.cancel();
    if (!revokeRes.ok) return { revoked: false, reason: `revoke_http_${revokeRes.status}` };
    return { revoked: true, reason: "ok" };
  } catch (e) {
    // Error class only: message text could echo request details.
    return { revoked: false, reason: `error_${e instanceof Error ? e.name : "unknown"}` };
  }
}
