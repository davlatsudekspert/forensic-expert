# O‘zbekcha ovoz (Gemini TTS) — sozlash

Holat (2026-10-31): server qismi production’da **ishlayapti** (`tts` Edge Function v1,
`tts_usage` jadvali, `tts-cache` bucket). Jonli sinov: o‘zbekcha matn, ovozlar Kore, Fola,
Sulafat, Leda, Charon — 200, WAV 24 kHz mono 16-bit, birinchi so‘rov ~7–8 s, keshdan ~1.6 s.

## Arxitektura
- Ilova Google’ga **to‘g‘ridan-to‘g‘ri murojaat qilmaydi**. Kalit faqat Supabase Edge Function
  muhitida: `GEMINI_API_KEY` (AI javob funksiyasi bilan umumiy).
- `POST /functions/v1/tts` — `{ "text", "voice"?, "style"?, "quality"?: "hd" | "lite" }` → `audio/wav`.
  Javob sarlavhasi `x-tts-cache: hit|miss`.
  `{ "action": "voices", "language": "uz" }` — kengaytirilgan ovozlar ro‘yxati (hozircha bo‘sh javob qaytaryapti).
- Kesh: `tts-cache/v1/<sha256(model|voice|style|text)>.wav`. Kesh topilsa Gemini chaqirilmaydi
  va kunlik limitga ham kirmaydi. Ilova ham WAV faylni qurilmada saqlaydi, ikkinchi marta internetsiz chalinadi.
- Uzun matn ≤700 belgili bo‘laklarga bo‘linadi (abzats, keyin gap chegarasi bo‘yicha).
  Har bo‘lak `audio/l16` (sarlavhasiz PCM) shaklida so‘raladi, PCM’lar ulanadi va oxirida bitta 44 baytli WAV sarlavha qo‘shiladi.
- Xatolar: 429 va 5xx bo‘lsa 1 s → 2 s kutib qayta uriniladi (jami 3 urinish), bitta urinish uchun timeout 60 s.
  Agar model topilmasa (404), keyingi modelga o‘tiladi.
- Faqat tizimga kirgan foydalanuvchi. Kunlik limit: `FE_TTS_DAILY_LIMIT` (standart 60 ta generatsiya / 24 soat).
  Matn jurnalga yozilmaydi; `tts_usage` faqat user id, vaqt va belgilar sonini saqlaydi.
  Mijozlarda bu jadvalga ruxsat yo‘q, unga faqat service role yozadi.

## Sozlamalar (Supabase → Edge Functions → Secrets), barchasi ixtiyoriy
| O‘zgaruvchi | Standart | Izoh |
|---|---|---|
| `GEMINI_API_KEY` | — (bor) | Majburiy, allaqachon o‘rnatilgan |
| `FE_TTS_MODEL` | `gemini-3.8-flash-tts` | Sifatli, darslik uchun |
| `FE_TTS_MODEL_LITE` | `gemini-3.8-flash-lite-tts` | `quality: "lite"` — qisqa UI matnlari |
| `FE_TTS_VOICE` | `Charon` | Standart ovoz — erkak (egasi tanlovi, 2026-10-31) |
| `FE_TTS_DAILY_LIMIT` | `60` | Foydalanuvchi boshiga kunlik generatsiya |

Agar 3.8 modellari ishlamasa, avtomatik zaxira modeli: `gemini-3.1-flash-tts-preview`.

## O‘zbek tili uchun matn qoidalari
- Tilni ko‘rsatuvchi parametr yo‘q: model tilni o‘zi aniqlaydi. Matn lotin alifbosida va to‘g‘ri imloda bo‘lsin, o‘ va g‘ harflari saqlansin.
- `text` so‘zma-so‘z o‘qiladi. Ohang bo‘yicha ko‘rsatmalar matnga emas, faqat `style` maydoniga yoziladi.
- Pauzalar inglizcha teglar bilan beriladi: `<short pause>`, `<long pause>`.
- Muhim raqamlarni so‘z bilan yozing.

## Qo‘lda sinash
```bash
curl -X POST "$SUPABASE_URL/functions/v1/tts" \
  -H "apikey: $ANON" -H "Authorization: Bearer $USER_ACCESS_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"text":"Assalomu alaykum! FORENSIC EXPERT ilovasiga xush kelibsiz."}' -o test.wav
```

## Kuzatilganlar
- Beshta so‘rovdan keyin oltinchisiga Google’dan 429 (`quota`) qaytdi. Bu daqiqalik limit;
  ilova foydalanuvchiga «keyinroq urinib ko‘ring» deb xabar beradi.
  Ko‘p ishlatilsa, Google AI Studio’da billing/limitni tekshirish kerak.
- Gemini TTS pullik xizmat (Google AI Studio hisobidan). Kesh xarajatni kamaytiradi.
