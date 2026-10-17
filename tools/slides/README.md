# tools/slides — ma'ruza slaydlari generatori (kontent vositasi)

**Maqsad:** `docs/curriculum/TOPICS.md` dagi mavzu uchun, faqat egasi bergan manbalar asosida, 12–18 slaydli reja + 10 ta MCQ (JSON) va `.pptx` tayyorlash. Ilovada PPTX yuklab olish va'dasi yo'q.

## Qanday ishlaydi
1. `topics.py` mavzularni o'qiydi (id: `4-kurs-davolash-01`; ro'yxat: `python topics.py`).
2. `sources.json` (namuna: `sources.example.json`): mavzu uchun {author, title, year, pages, local_text_path | drive_id}. Matn fayllarini repoga qo'shmang.
3. `generate.py` faqat shu matnlarni Claude API (`claude-sonnet-5-5`, system prompt keshlanadi, `max_tokens` cheklangan, temperature 0.2) ga yuboradi.
4. Chiqishda har band/savol manbasi (muallif+kitob+bet) berilgan ro'yxatga tekshiriladi; manbasiz bo'lsa rad etiladi.
5. Manba matni yo'q mavzuda: `ADABIYOT KUTILMOQDA`, API chaqirilmaydi.
6. `build_pptx.py` JSON → 16:9 PPTX (yozuvchi eslatmalari = o'qituvchi izohi, oxirida «Manbalar»).

## Narx baholash usuli
Token ≈ belgilar / 3 (taxmin). Narx = kirish·narx_in + `MAX_TOKENS`·narx_out (eng yomon holat). `generate.py` dagi narx konstantalari **tekshirilmagan taxmin** — egasi rasmiy Anthropic narxlar sahifasida tekshirishi shart. `--max-usd` (standart 0.50) dan oshsa API chaqirilmaydi.

## Mahalliy ishga tushirish
```
pip install anthropic python-pptx pytest
cd tools/slides
python generate.py 4-kurs-davolash-01 --dry-run
export ANTHROPIC_API_KEY=...   # faqat o'z terminalingizda
python generate.py 4-kurs-davolash-01 --max-usd 0.50
python build_pptx.py out/4-kurs-davolash-01.json
pytest tests
```

## Qoidalar
- Kalitni hech qachon chop etmang, logga yozmang, commit qilmang (faqat env / GitHub Secrets).
- Manbasiz da'vo, o'ylab topilgan raqam/bet yo'q; ishonchsiz band `(?)` bilan belgilanadi.
- Natija o'qituvchi tomonidan tekshirilmaguncha tasdiqlangan hisoblanmaydi.
- ABY va cheklangan materiallar: CLAUDE.md qoidalariga amal qiling (ommaviy tarqatilmaydi).
- `apps/` va `content/` ga tegmang.
