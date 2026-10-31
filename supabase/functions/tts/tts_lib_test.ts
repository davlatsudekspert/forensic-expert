import { assert, assertEquals } from "jsr:@std/assert@1";
import {
  audioData,
  cleanText,
  type Deps,
  pcmOf,
  splitText,
  synthesize,
  ttsBody,
  wavOf,
} from "./tts_lib.ts";

const b64 = (b: Uint8Array) => btoa(String.fromCharCode(...b));
const okBody = (pcm: Uint8Array) =>
  new Response(JSON.stringify({
    steps: [
      { type: "user_input" },
      { type: "model_output", content: [{ type: "audio", data: b64(pcm) }] },
    ],
  }), { status: 200 });

function deps(responses: (() => Response)[], calls: string[] = []): Deps {
  let i = 0;
  return {
    fetchFn: (_u, init) => {
      calls.push(JSON.parse(String(init?.body)).model);
      return Promise.resolve(responses[Math.min(i++, responses.length - 1)]());
    },
    sleep: () => Promise.resolve(),
  };
}

Deno.test("cleanText keeps Uzbek apostrophes and inline tags", () => {
  assertEquals(
    cleanText("  O‘zbek  g'alaba\u0007 <short pause> tayyor\r\n"),
    "O‘zbek g'alaba <short pause> tayyor",
  );
});

Deno.test("splitText: paragraphs, long ones at sentence ends", () => {
  assertEquals(splitText("Bir.\n\nIkki."), ["Bir.", "Ikki."]);
  const long = Array.from({ length: 30 }, (_, i) => `Gap raqami ${i} shu yerda tugaydi.`).join(" ");
  const parts = splitText(long, 200);
  assert(parts.length > 1);
  assert(parts.every((p) => p.length <= 200));
  assertEquals(parts.join(" "), long);
  const word = "a".repeat(450);
  assert(splitText(word, 200).every((p) => p.length <= 200));
});

Deno.test("wav header round-trips and pcmOf strips RIFF", () => {
  const pcm = new Uint8Array([1, 2, 3, 4, 5, 6]);
  const w = wavOf(pcm);
  assertEquals(w.length, 44 + 6);
  assertEquals(String.fromCharCode(...w.subarray(0, 4)), "RIFF");
  assertEquals(new DataView(w.buffer).getUint32(24, true), 24000);
  assertEquals([...pcmOf(w)], [...pcm]);
  assertEquals([...pcmOf(pcm)], [...pcm]); // headerless stays as is
});

Deno.test("audioData follows the documented path (last audio part)", () => {
  assertEquals(
    audioData({
      steps: [{ type: "model_output", content: [{ type: "audio", data: "QQ==" }, { type: "audio", data: "Qg==" }] }],
    }),
    "Qg==",
  );
  assertEquals(audioData({ output_audio: { data: "Qw==" } }), "Qw==");
  assertEquals(audioData({}), null);
});

Deno.test("ttsBody matches the Interactions API shape", () => {
  const b = ttsBody("m", "Kore", "", "Salom") as any;
  assertEquals(b.input[0].content[0].annotations[0].type, "speech_metadata");
  assertEquals(b.response_format.type, "audio");
  assertEquals(b.generation_config.speech_config[0].voice, "Kore");
});

Deno.test("synthesize joins PCM of every chunk under ONE header", async () => {
  const text = "Birinchi abzats.\n\nIkkinchi abzats.";
  const r = await synthesize("k", ["m"], "Kore", "", text, deps([
    () => okBody(wavOf(new Uint8Array([1, 1]))), // a WAV reply is unwrapped
    () => okBody(new Uint8Array([2, 2])),
  ]));
  assert(r.ok);
  if (r.ok) assertEquals([...r.wav.subarray(44)], [1, 1, 2, 2]);
});

Deno.test("429 retries with backoff, 404 falls back to next model", async () => {
  const calls: string[] = [];
  const r = await synthesize("k", ["new", "old"], "Kore", "", "Salom.", deps([
    () => new Response("", { status: 404 }),
    () => new Response("", { status: 429 }),
    () => okBody(new Uint8Array([9])),
  ], calls));
  assert(r.ok);
  assertEquals(calls, ["new", "old", "old"]);
  if (r.ok) assertEquals(r.model, "old");
});

Deno.test("persistent 429 gives up after 3 attempts", async () => {
  const calls: string[] = [];
  const r = await synthesize("k", ["m", "n"], "Kore", "", "Salom.", deps([
    () => new Response("", { status: 429 }),
  ], calls));
  assertEquals(r.ok, false);
  if (!r.ok) assertEquals(r.status, 429);
  assertEquals(calls.length, 3); // no fallback on quota
});
