// Unit tests for the expert-verification logic. The AI is mocked: these
// tests make no network call and touch no database.
import { assertEquals } from "jsr:@std/assert@1";
import {
  interpretVerdict,
  MAX_BYTES,
  parseRequest,
  readGeminiReport,
  toBase64,
} from "./verify.ts";

const b64 = (s: string) => btoa(s);

Deno.test("parseRequest accepts a well formed request", () => {
  const r = parseRequest({
    role: "forensic_chemist",
    country: "uz",
    mime: "image/jpeg",
    data: b64("fake-jpeg-bytes"),
    lang: "uz",
  });
  assertEquals(r.ok, true);
  if (r.ok) {
    assertEquals(r.value.country, "UZ");
    assertEquals(r.value.role, "forensic_chemist");
    assertEquals(r.value.lang, "uz");
    assertEquals(r.value.bytes.length, "fake-jpeg-bytes".length);
  }
});

Deno.test("parseRequest refuses roles that cannot be verified by document", () => {
  for (const role of ["student", "other"]) {
    const r = parseRequest({
      role,
      country: "UZ",
      mime: "image/png",
      data: b64("x"),
    });
    assertEquals(r.ok, false);
    if (!r.ok) assertEquals(r.error, "role_not_verifiable");
  }
});

Deno.test("parseRequest validates role, country, mime and payload", () => {
  const cases: [Record<string, unknown>, string][] = [
    [{ role: "wizard", country: "UZ", mime: "image/png", data: b64("x") }, "bad_role"],
    [{ role: "forensic_chemist", country: "UZB", mime: "image/png", data: b64("x") }, "bad_country"],
    [{ role: "forensic_chemist", country: "UZ", mime: "image/gif", data: b64("x") }, "bad_mime"],
    [{ role: "forensic_chemist", country: "UZ", mime: "image/png", data: "" }, "no_document"],
    [{ role: "forensic_chemist", country: "UZ", mime: "image/png" }, "no_document"],
  ];
  for (const [body, expected] of cases) {
    const r = parseRequest(body);
    assertEquals(r.ok, false, JSON.stringify(body));
    if (!r.ok) assertEquals(r.error, expected);
  }
  assertEquals(parseRequest("not an object").ok, false);
});

Deno.test("parseRequest rejects an oversized document", () => {
  const r = parseRequest({
    role: "forensic_physician",
    country: "UZ",
    mime: "application/pdf",
    data: "A".repeat(Math.ceil(MAX_BYTES / 3) * 4 + 16),
  });
  assertEquals(r.ok, false);
  if (!r.ok) assertEquals(r.error, "too_large");
});

Deno.test("parseRequest defaults the language to Uzbek", () => {
  const r = parseRequest({
    role: "lab_technician",
    country: "uz",
    mime: "image/webp",
    data: b64("x"),
    lang: "de",
  });
  assertEquals(r.ok, true);
  if (r.ok) assertEquals(r.value.lang, "uz");
});

Deno.test("interpretVerdict verifies only a readable, matching credential", () => {
  assertEquals(
    interpretVerdict({
      is_credential: true,
      readable: true,
      profession: "forensic_chemist",
      expired: false,
      confidence: 0.9,
    }, "forensic_chemist"),
    { status: "verified", reason: "document_ok" },
  );
});

Deno.test("interpretVerdict rejects conservatively", () => {
  const base = {
    is_credential: true,
    readable: true,
    profession: "forensic_chemist",
    expired: false,
    confidence: 0.9,
  };
  assertEquals(
    interpretVerdict({ ...base, readable: false }, "forensic_chemist").reason,
    "unreadable",
  );
  assertEquals(
    interpretVerdict({ ...base, is_credential: false }, "forensic_chemist").reason,
    "not_a_credential",
  );
  assertEquals(
    interpretVerdict({ ...base, expired: true }, "forensic_chemist").reason,
    "expired",
  );
  assertEquals(
    interpretVerdict({ ...base, profession: "forensic_physician" }, "forensic_chemist").reason,
    "role_mismatch",
  );
  assertEquals(
    interpretVerdict({ ...base, confidence: 0.4 }, "forensic_chemist").reason,
    "low_confidence",
  );
  assertEquals(interpretVerdict(null, "forensic_chemist").reason, "ai_unavailable");
  for (const v of ["unreadable", "not_a_credential", "expired", "role_mismatch", "low_confidence"]) {
    assertEquals(v.length <= 64, true);
  }
});

Deno.test("a laboratory credential also backs the technician role", () => {
  assertEquals(
    interpretVerdict({
      is_credential: true,
      readable: true,
      profession: "forensic_chemist",
      confidence: 0.8,
    }, "lab_technician").status,
    "verified",
  );
  assertEquals(
    interpretVerdict({
      is_credential: true,
      readable: true,
      profession: "lab_technician",
      confidence: 0.8,
    }, "forensic_physician").reason,
    "role_mismatch",
  );
});

Deno.test("readGeminiReport reads a mocked model reply", () => {
  const out = {
    candidates: [{
      content: {
        parts: [{
          text: JSON.stringify({
            is_credential: true,
            readable: true,
            profession: "forensic_physician",
            expired: false,
            confidence: 0.77,
          }),
        }],
      },
    }],
  };
  const report = readGeminiReport(out);
  assertEquals(report?.profession, "forensic_physician");
  assertEquals(report?.confidence, 0.77);
  assertEquals(
    interpretVerdict(report, "forensic_physician"),
    { status: "verified", reason: "document_ok" },
  );
});

Deno.test("readGeminiReport survives blocked, empty and unparsable replies", () => {
  assertEquals(readGeminiReport({ promptFeedback: { blockReason: "SAFETY" } }), null);
  assertEquals(readGeminiReport({ candidates: [] }), null);
  assertEquals(readGeminiReport({ candidates: [{ content: { parts: [{ text: "oops" }] } }] }), null);
  assertEquals(readGeminiReport(null), null);
  // Thinking parts are not content.
  assertEquals(
    readGeminiReport({ candidates: [{ content: { parts: [{ text: "x", thought: true }] } }] }),
    null,
  );
});

Deno.test("the verdict never carries text from the document", () => {
  const report = readGeminiReport({
    candidates: [{
      content: {
        parts: [{
          text: JSON.stringify({
            is_credential: true,
            readable: true,
            profession: "forensic_chemist",
            confidence: 0.95,
            // A model that leaks personal data must not leak it onwards.
            holder_name: "Ism Familiya",
            document_number: "AB-123456",
          }),
        }],
      },
    }],
  });
  assertEquals(Object.keys(report ?? {}).sort(), [
    "confidence",
    "expired",
    "is_credential",
    "profession",
    "readable",
  ]);
  const verdict = interpretVerdict(report, "forensic_chemist");
  assertEquals(Object.keys(verdict).sort(), ["reason", "status"]);
  assertEquals(JSON.stringify(verdict).includes("Ism"), false);
  assertEquals(JSON.stringify(verdict).includes("AB-123456"), false);
});

Deno.test("toBase64 round-trips the in-memory bytes", () => {
  const bytes = new Uint8Array([0, 1, 2, 250, 251, 255]);
  const encoded = toBase64(bytes);
  const decoded = atob(encoded);
  assertEquals(decoded.length, bytes.length);
  for (let i = 0; i < bytes.length; i++) {
    assertEquals(decoded.charCodeAt(i), bytes[i]);
  }
});
