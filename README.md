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
