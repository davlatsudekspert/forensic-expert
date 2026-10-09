# FORENSIC EXPERT

**Evidence · Science · Precision**

Sud-tibbiy ekspertiza, sud toksikologiyasi va laboratoriya mutaxassislari, tadqiqotchilar, o‘qituvchilar va talabalar uchun xalqaro professional ma’lumotnoma, ta’lim va ilmiy hisob-kitob platformasi (Android / iOS, Flutter).

> Forensic Expert is intended for professional reference, education and scientific calculation. It does not replace validated laboratory procedures, institutional protocols, applicable law or qualified professional judgment.

## Holat

**PHASE 1 — Foundation tugadi** (egasining tasdig‘i kutilmoqda). Ilmiy kontent hali kiritilmagan.

- Arxitektura rejasi: [`docs/00_ARXITEKTURA_REJASI.md`](docs/00_ARXITEKTURA_REJASI.md)
- Evidence audit va tahlillar: [`docs/01`](docs/01_EVIDENCE_AUDIT.md) – [`docs/07`](docs/07_POLICY_COMPLIANCE.md)
- PHASE 1 hisoboti: [`docs/08_PHASE1_FOUNDATION.md`](docs/08_PHASE1_FOUNDATION.md)
- Progress va release gate’lar: [`PROGRESS.md`](PROGRESS.md)

## Ishga tushirish

```bash
flutter pub get                 # workspace (bitta lockfile)
./tool/ci_local.sh              # CI bilan bir xil: format, analyze, barcha testlar
cd apps/mobile && flutter run   # ilova
```

## Real-ilova QA (talaba va mutaxassis yo‘llari)

Ilova **haqiqiy** holatda (haqiqiy `bootstrap()`, imzolangan pilot kontent
paketi, router, Flutter dvigateli) Linux desktop’da Xvfb ostida ishga
tushiriladi va TALABA hamda MUTAXASSIS yo‘llari foydalanuvchi kabi bosib
chiqiladi; har qadam skrinshoti va PASS/FAIL natijasi saqlanadi.

```bash
# Ubuntu: sudo apt-get install xvfb clang cmake ninja-build pkg-config libgtk-3-dev libsecret-1-dev
./tool/qa_real_app.sh            # ikkala rol (~4 daqiqa, issiq build bilan)
./tool/qa_real_app.sh student    # faqat talaba
```

- Natija: `docs/qa/real_app_YYYYMMDD/` (PNG + `results_<rol>.json`), hisobot:
  [`docs/qa/REAL_APP_TEST_REPORT.md`](docs/qa/REAL_APP_TEST_REPORT.md).
- Production’ga tegmaydi: yig‘ma `FE_SUPABASE_*` siz, akkaunt MOCK
  (`FE_AUTH_MODE=mock`), testlar barcha HTTP ulanishlarni bloklaydi.
- `apps/mobile/linux/` — faqat shu QA uchun (release maqsadi emas).
- Kashfiyot uchun: `QA_TAPS="O‘zbekcha|Davom etish|…"` bilan
  `integration_test/qa_probe_test.dart` (har amaldan keyin ekran matni).
- CI’ga ulanmagan: toza runner’da (apt + Linux build) ~5 daqiqadan oshadi —
  qo‘lda ishga tushiriladi.
