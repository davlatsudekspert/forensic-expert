# Darslar — prezentatsiya formati v2 (2026-10-24, egasi topshirig‘i)

Egasi talabi: har prezentatsiya **~40 slayd** (38–42), **diagramma va vizual sxemalar ko‘p**
(diagrammali slaydlar ≥ 40 %), har dars oxirida **test** (10/15/20 savol, QR, jonli natija,
qiyin savollar muhokamasi). Matn — faqat ustoz kitoblaridan, manba va bet bilan; to‘qilmaydi.

## 1. Deck JSON (slides-out: `out/<deck_id>.json`)
```
{ "topic": {...}, "slides": [Slide...], "mcq": [Mcq...], "extras": [...], "sources": [...] }
Slide = { "title": str≤70, "bullets": [{"text": str≤160, "source": {"author","title","page"}, "uncertain": bool}] (2–5),
          "diagram": Diagram|null, "diagram_note": str?, "teacher_notes": str }
Mcq   = { "question", "options": [4], "correct_index", "explanation", "source": {"author","title","page"} }
```
Hamma matn — adabiy o‘zbek (lotin, o‘/g‘ to‘g‘ri). Raqam, birlik, formula, modda nomi — kitobdagidek.

## 2. Diagram turlari (v2) — `diagram.kind`
Hamma matnlar qisqa (limitlar qavsda, belgi soni). Diagramma mazmuni ham **manbadan**; manba slayd bulletlaridan meros.
| kind | maydonlar | qachon |
|---|---|---|
| `table` | `header` [≤4], `rows` [≤6 × ≤4], `caption?` | taqqoslash jadvallari, parametrlar |
| `flow` | `nodes` [≤6 × ≤40], `caption?` | ketma-ket jarayon (tahlil bosqichlari) |
| `steps` | `items` [≤6 × {`title`≤30, `text`≤80}], `caption?` | usul/protokol qadamlari |
| `compare` | `columns` [2–3 × {`title`≤24, `items` [≤5 × ≤60]}], `caption?` | A vs B (toksikodinamika/kinetika, usullar) |
| `tree` | `root`≤30, `children` [≤6 × {`label`≤26, `items?` [≤3 × ≤40]}], `caption?` | tasniflar |
| `facts` | `items` [≤6 × {`label`≤24, `value`≤20, `unit?`≤12}], `caption?` | raqamli ko‘rsatkichlar (pH, Rf, LD50, cutoff) |
| `reaction` | `reagents` [≤3], `conditions?`≤40, `products` [≤3], `observation?`≤60, `caption?` | rangli reaksiyalar, cho‘kma |
| `cycle` | `nodes` [3–6 × ≤28], `caption?` | aylanma jarayonlar (metabolizm fazalari) |
Noma’lum kind yoki limitdan oshgan → ilova diagrammani o‘tkazib yuboradi (xatosiz), pptx jadval sifatida chizadi.

## 3. Deck talablari (enrichment)
- 38–42 slayd; 1-slayd: reja va tayanch so‘zlar; oxirgi: «Adabiyotlar» (Yuldashev va boshqalar — manba ro‘yxatidan).
- Diagrammali slaydlar ≥ 16 ta, kamida 4 xil kind; har diagramma mazmuni kitob betiga mos.
- Har bulletda `source.page`; shubhali joy — `uncertain: true` + `diagram_note`/izoh.
- `mcq`: **20 ta** (10 bo‘lsa — kitobning o‘sha sahifalaridan yana 10 ta): 1 to‘g‘ri javob, mantiqan bog‘liq
  chalg‘ituvchilar, `explanation` manbaga tayanadi, `source.page` majburiy. Savollar slayd mazmuni bilan bog‘liq.
- Kitob ziddiyatlari: `docs/toks/kitob_ziddiyatlari.md` (EDITOR_RESOLUTIONS) qaroriga amal qilinadi.

## 4. Test oqimi (ilova)
- Har dars (deck_id) uchun `class_quiz_questions`da topic_id = deck_id (`quiz/<deck_id>.json`, uz; ru/en — «tarjima kutilmoqda»).
- Ustoz: savol soni **10 / 15 / 20** (chip), vaqt 15/30/45/60 s; kod + QR; talaba skanerlaydi;
  kirgan talabada profil ismi avtomatik (o‘zgartirsa bo‘ladi), kirmagan — yozadi.
- Monitor: ism bo‘yicha jonli natija, o‘rin (1, 2, 3…), to‘g‘ri soni, vaqt.
- Yakun: **«Qiyin savollar»** (server `hardest`) — ustoz savolni ochadi: matn, variantlar, to‘g‘ri javob,
  tushuntirish, manba+bet → muhokama. Ismlar ko‘rsatilmaydi (faqat % xato).

## 5. Tekshiruv
- Har yangi matn/diagramma/mcq — manba matnida (`drive_src/pdf/*.full.txt`, bet) tasdiqlanishi shart (verifier).
- `tools/lessons/validate_deck.py` (schema + limitlar) — seed oldidan majburiy.
