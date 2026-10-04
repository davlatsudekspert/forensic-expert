# 13 — PHASE 4: Global Forensic Knowledge System

**Holat:** PHASE 4 yakunlandi, egasining tasdig‘i kutilmoqda. PHASE 5 boshlanmagan.
**Branch:** `claude/phase-4-global-forensic-system`. Main’ga merge qilinmagan, PR ochilmagan, store’larga hech narsa yuborilmagan.

## 1. Mahsulot pozitsiyasi (egasining aniqlashtirishi)

- FORENSIC EXPERT — **butun dunyo uchun global professional forensic platforma**. U O‘zbekiston yoki MDH bilan cheklanmaydi.
- O‘zbekiston birinchi chuqur ishlab chiqiladigan yurisdiksiyalardan biri bo‘lishi mumkin. Lekin arxitektura, UX, qidiruv, ilmiy baza, Student Mode va Forensic AI xalqaro foydalanuvchi uchun quriladi:
  - EN, RU va UZ tillari;
  - yurisdiksiyadan mustaqil ilmiy yadro;
  - ISO 3166 asosidagi yurisdiksiya qatlami.
- **Sifat > son.** 300 ta tekshirilmagan yozuvdan ko‘ra 50 ta to‘liq manbali va reviewer tasdiqlagan yozuv afzal. Kontent sun’iy ko‘paytirilmaydi.
- Arxitektura bazani bosqichma-bosqich yuzlab, keyin minglab yozuvgacha kengaytirishga tayyor:
  - yagona `knowledge_entities` jadvali;
  - versiyalangan, imzolangan paketlar;
  - review regressiya himoyasi;
  - yangi yurisdiksiya qo‘shish uchun kod o‘zgartirish shart emas.

## 2. Qamrov (bajarilgan)

| Soha | Natija | Hujjat |
|---|---|---|
| Sud tibbiyoti | 25 mavzu taksonomiyasi. 3 mavzuda manbali iqtibos bor, qolgan 22 tasi halol tarzda «manbali ma’lumot yo‘q» | 15 |
| Toksikologiya va moddalar | PHASE 3 dagi 20 yozuv; GB yurisdiksiya qatlami bilan | 14 |
| Biokimyo | Vitreous kaliy va PMI (marker + cheklov) | 15 |
| Laboratoriya | Eritma tayyorlash kalkulyatori `m = C·V(·M)/p`; molyar massa va tozalikni foydalanuvchi kiritadi | 15 |
| Reagentlar va eritmalar | Marquis reagenti. Retsept YO‘Q («MA’LUMOT TEKSHIRILMAGAN» holati) | 15 |
| Skrining / ekspress testlar | Immunoanaliz: «SKRINING ≠ TASDIQLASH» banneri, tasdiqlovchi metod (GC-MS) | 15 |
| Metodlar / SOP | 4 tur alohida (FE024): ilmiy metod, xalqaro standart, milliy metod, muassasa SOP’i | 15 |
| Xalqaro manbalar ierarxiyasi | `SourceClass`: rasmiy birlamchi, peer-reviewed, standart, kitob, ikkilamchi, boshqa (`other` dalil emas — FE017) | 14 |
| Yurisdiksiya + Compare | UK: RTA 1988 s.11(2) va SSI 2014/328 (Shotlandiya); hududiy qamrov; Shimoliy Irlandiya — «ma’lumot yo‘q» | 14 |
| Yangi muammolar | Nitazenlar: manba, sana, dalil turi va qamrov bilan | 15 |
| Student Mode | Darajalar, real manbali kurslar, progress va tarix, xatcho‘plar, imtihon rejimi, «simulyatsiya» belgisi | 16 |
| Forensic AI + Tutor | Provider’dan mustaqil, RAG-first; citation tekshiruvi va xavfsizlik siyosati bor; LLM ulanmagan | 16 |
| Premium dizayn | Home redesign, oflayn baza kartochkasi, yangi komponentlar, audit | 17 |

## 3. Statuslar va reviewer chegaralari

- Statuslar: `DRAFT / NEEDS_REVIEW / REVIEWED / VERIFIED / OUTDATED / REJECTED`.
- Status qo‘lda yozilmaydi — `StatusResolver.resolveSubject` review yozuvlaridan hisoblaydi. Hisobga olinadigan review shartlari:
  - domeni mos;
  - malakasi tasdiqlangan;
  - muallifning o‘zi emas.
- i18n reviewer ilmiy yoki huquqiy claim’ni tasdiqlay olmaydi.
- Barcha pilot yozuvlar **NEEDS_REVIEW**. Reviewer yo‘q (RG-19), shuning uchun hech narsa VERIFIED/PUBLISHED emas.

## 4. Kontent paketi va versiyalar

- Format: `fe-bundle/2` (eski `/1` ham o‘qiladi); DB sxemasi v3.
- Versiyalar alohida: ilova, paket (`2026.10.2`), `component_version.scientific`, `component_version.jurisdiction`.
- **FE027 — review regressiya himoyasi.** Ko‘rib chiqilgan yozuvni quyidagicha almashtirib bo‘lmaydi:
  - jimgina yo‘qotish;
  - NEEDS_REVIEW/DRAFT ga tushirish;
  - versiyani oshirmay o‘zgartirish.

  Ruxsat etilgan yo‘l — faqat aniq OUTDATED yoki REJECTED. `tool/update_bundled_pack.sh` oxirgi commit qilingan bundle bilan avtomatik solishtiradi.
- Production kanal pilotni rad etadi (67 × FE008). Development paket ilovada «pilot» banneri bilan chiqadi.

## 5. Bepul demo va paywall

- Bepul: 3 ta modda yozuvi, 1 ta kurs va 1 ta vosita (C₁V₁). Yangi bo‘limlarda ham bir nechta demo yozuv bor.
- **Hech qachon yopilmaydi:**
  - manbalar;
  - dalil statusi;
  - disclaimer;
  - cheklovlar va xavfsizlik bo‘limi (cheklov, cross-reactivity, xavflar, «skrining ≠ tasdiqlash»).
- Billing xavfsizligi PHASE 3 dagidek: RG-18 ochiq, xarid production-secure EMAS.

## 6. Maxfiylik

- Ilova offline-first.
- Qidiruv, AI qidiruvi va o‘quv progressi faqat qurilmada saqlanadi.
- Telemetriyaga so‘rov yuborilmaydi (`NoopTelemetrySink`).

## 7. Tekshiruvlar

| Tekshiruv | Natija |
|---|---|
| analyze (`--fatal-infos`) | ✅ No issues |
| Paket testlari | ✅ 175 (calc 18, package 15, pipeline 19, schema 77, database 26, search 20) |
| Ilova testlari | ✅ 705 (1 skip — PHASE 1 preview skrinshotlari) |
| Golden | ✅ 37 kadr, shundan 7 tasi yangi PHASE 4 ekrani (haqiqiy pilot paket bilan) |
| a11y | ✅ 32 ekran × light / dark / HC: tap target, label, kontrast |
| 320 dp × katta shrift × EN/RU/UZ | ✅ overflow yo‘q |
| l10n | ✅ ARB pariteti; UZ’da tarjimasiz matn yo‘q; 165 yangi kalit (RU/UZ — qoralama, RG-11) |
| gitleaks (git + dir) | ✅ leak yo‘q |
| OSV (132 paket) | ✅ zaiflik yo‘q |
| Release APK | ✅ 65.8 MB (universal); ⚠️ debug sertifikat bilan imzolangan (RG-20) — faqat tekshiruv uchun |
| Real qurilma | ⛔ Muhitda yo‘q (RG-10) |

## 8. Unumdorlik (host VM, JIT test muhiti; qurilma o‘lchovi emas)

| Amal | Birinchi | Keyingilari |
|---|---|---|
| Paketni o‘rnatish (imzo + SHA-256 + integrity) | 291 ms | 20–28 ms |
| Kutubxona yuklash | 39 ms | 11–34 ms |
| Bilim obyektlari / yurisdiksiya yuklash | 18 / 11 ms | 1–2 ms |
| Qidiruv indeksi | 21.5 ms | 0.3 ms |
| Qidiruv (6 so‘rov, EN/RU, xatoli) | 5–24 ms | 2–4 ms |
| AI lokal qidiruvi (retrieval) | 5 ms | 0.2–0.4 ms |
