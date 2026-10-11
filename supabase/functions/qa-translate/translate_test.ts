// Unit tests for the machine-translation logic. Both engines are mocked:
// these tests make no network call and touch no database.
import { assertEquals } from "jsr:@std/assert@1";
import {
  cacheRow,
  cfLangVariants,
  chunk,
  geminiPrompt,
  MAX_CHUNK_CHARS,
  parseRequest,
  readCloudflare,
  readGemini,
} from "./translate.ts";

const ID = "9f4a1c2e-3b5d-4e6f-8a90-1b2c3d4e5f60";

Deno.test("parseRequest accepts a well formed request", () => {
  const r = parseRequest({ target_type: "question", target_id: ID, lang: "ru" });
  assertEquals(r.ok, true);
  if (r.ok) {
    assertEquals(r.value.targetType, "question");
    assertEquals(r.value.targetId, ID);
    assertEquals(r.value.lang, "ru");
  }
});

Deno.test("parseRequest validates target, id and language", () => {
  const cases: [Record<string, unknown>, string][] = [
    [{ target_type: "user", target_id: ID, lang: "ru" }, "bad_target"],
    [{ target_type: "question", target_id: "123", lang: "ru" }, "bad_id"],
    [{ target_type: "answer", target_id: ID, lang: "de" }, "bad_language"],
    [{ target_type: "answer", target_id: ID }, "bad_language"],
  ];
  for (const [body, expected] of cases) {
    const r = parseRequest(body);
    assertEquals(r.ok, false, JSON.stringify(body));
    if (!r.ok) assertEquals(r.error, expected);
  }
  assertEquals(parseRequest(null).ok, false);
});

Deno.test("both Cloudflare language spellings are tried", () => {
  assertEquals(cfLangVariants("uz"), ["uzbek", "uz"]);
  assertEquals(cfLangVariants("ru"), ["russian", "ru"]);
  assertEquals(cfLangVariants("en"), ["english", "en"]);
});

Deno.test("chunk splits long text on sentence breaks, never mid-word", () => {
  const sentence = "Qon namunasida etanol konsentratsiyasi aniqlandi. ";
  const text = sentence.repeat(60);
  const pieces = chunk(text);
  assertEquals(pieces.length > 1, true);
  for (const p of pieces) {
    assertEquals(p.length <= MAX_CHUNK_CHARS, true);
    assertEquals(p, p.trim());
  }
  // Nothing is lost: joining the words back gives the same word sequence.
  assertEquals(
    pieces.join(" ").split(/\s+/).join(" "),
    text.trim().split(/\s+/).join(" "),
  );
});

Deno.test("chunk keeps short text in one piece", () => {
  assertEquals(chunk("Qisqa savol."), ["Qisqa savol."]);
  assertEquals(chunk("   "), []);
});

Deno.test("chunk handles text with no spaces at all", () => {
  const pieces = chunk("a".repeat(MAX_CHUNK_CHARS * 2 + 5));
  assertEquals(pieces.length, 3);
  assertEquals(pieces.join("").length, MAX_CHUNK_CHARS * 2 + 5);
});

Deno.test("readCloudflare reads a mocked reply", () => {
  assertEquals(
    readCloudflare({ success: true, result: { translated_text: "Проба крови" } }),
    "Проба крови",
  );
  assertEquals(readCloudflare({ result: "Blood sample" }), "Blood sample");
});

Deno.test("readCloudflare rejects failures and empty text", () => {
  assertEquals(readCloudflare({ success: false, result: { translated_text: "x" } }), null);
  assertEquals(readCloudflare({ success: true, result: { translated_text: "   " } }), null);
  assertEquals(readCloudflare({ success: true, result: {} }), null);
  assertEquals(readCloudflare(null), null);
});

Deno.test("readGemini reads JSON and falls back to raw text", () => {
  assertEquals(
    readGemini({
      candidates: [{ content: { parts: [{ text: '{"text":"Blood sample"}' }] } }],
    }),
    "Blood sample",
  );
  assertEquals(
    readGemini({ candidates: [{ content: { parts: [{ text: "Blood sample" }] } }] }),
    "Blood sample",
  );
  assertEquals(readGemini({ promptFeedback: { blockReason: "SAFETY" } }), null);
  assertEquals(readGemini({ candidates: [] }), null);
  assertEquals(
    readGemini({ candidates: [{ content: { parts: [{ text: "x", thought: true }] } }] }),
    null,
  );
});

Deno.test("the translation prompt names the target language and fences the text", () => {
  const p = geminiPrompt("uz", "Blood ethanol 1.2 g/L");
  assertEquals(p.includes("Uzbek (Latin script)"), true);
  assertEquals(p.includes("TEXT:\nBlood ethanol 1.2 g/L"), true);
});

Deno.test("cacheRow trims, drops an empty title and refuses an empty body", () => {
  assertEquals(
    cacheRow({ title: "  Savol  ", body: " Matn " }, "cf:@cf/meta/m2m100-1.2b"),
    { title: "Savol", body: "Matn", engine: "cf:@cf/meta/m2m100-1.2b" },
  );
  assertEquals(
    cacheRow({ title: null, body: "Matn" }, "gemini:x"),
    { title: null, body: "Matn", engine: "gemini:x" },
  );
  assertEquals(cacheRow({ title: "Savol", body: "   " }, "x"), null);
  assertEquals(cacheRow({ title: "Savol", body: null }, "x"), null);
});

Deno.test("the engine label says which engine produced the text", () => {
  const cf = cacheRow({ title: null, body: "t" }, "cf:@cf/meta/m2m100-1.2b");
  const g = cacheRow({ title: null, body: "t" }, "gemini:gemini-flash-latest");
  assertEquals(cf?.engine.startsWith("cf:"), true);
  assertEquals(g?.engine.startsWith("gemini:"), true);
});
