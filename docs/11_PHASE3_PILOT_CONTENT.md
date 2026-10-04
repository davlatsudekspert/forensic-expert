# 11 — PHASE 3: Pilot ilmiy kontent, Lifetime va R2 brend

Branch: `claude/phase-3-pilot-content` (PHASE 2 ustiga). main’ga merge qilinmagan, PR ochilmagan, store’ga hech narsa yuborilmagan.

> **Holat:** barcha pilot ma’lumotlar `NEEDS_REVIEW`. Reviewer tayinlanmagan (RG-04), shuning uchun **birorta claim VERIFIED/REVIEWED emas**. Ilovada har bir yozuvda «MA’LUMOT TEKSHIRILMAGAN — EKSPERT TASDIG‘I KERAK» banneri ko‘rsatiladi.

## 1. Kontent zanjiri

```
PubChem PUG REST ─┐
INCB Yellow/Green ┼─► content/pilot/*.generated.json ─► assemble_pilot.py ─► bundle.json
PMC BioC (asl matn)┘        (har bir qiymat real so‘rovdan)
bundle.json ─► fe_content_pipeline: ContentValidator ─► content.db (FTS5) ─► Ed25519 imzo
           ─► apps/mobile/assets/content/pilot ─► PackVerifier (ochiq kalit KODDA) ─► PackInstaller ─► UI
```

| Qadam | Vosita | Nima kafolatlaydi |
|---|---|---|
| Identifikatsiya | `content/tools/fetch_identity.py` | CID, formula, MW, InChIKey, IUPAC — PubChem API javobidan. Sinonim faqat PubChem ro‘yxatida bo‘lsa qo‘shiladi («CO» rad etildi) |
| Xalqaro nazorat | `content/tools/verify_incb.py` | Rasmiy PDF yuklanadi, SHA-256 yoziladi, aniq qator (IDS kodi + nom) va bo‘lim (Schedule) dasturiy topiladi |
| Ilmiy claim | `content/tools/verify_excerpts.py` | Agent topgan iqtibos PMC asl matni bilan solishtiriladi; bazaga **asl manbadagi gap** yoziladi; DOI va litsenziya API’dan olinadi |
| Yig‘ish | `content/tools/assemble_pilot.py` | Hammasi `NEEDS_REVIEW`; iqtibos matni faqat ochiq litsenziyada (CC BY / CC0 / PD) |
| Validator | `packages/fe_content_pipeline` | FE001–FE016; production kanal **rad etiladi** (48 × FE008) |
| Paket | `tool/update_bundled_pack.sh` | Development kalit vaqtinchalik; production kalit faqat tashqaridan (`FE_PACK_SIGNING_SEED_B64`) |

## 2. Pilot yozuvlar (18 modda + 2 bog‘liq yozuv)

Jadval `content/pilot/bundle.json` dan generatsiya qilingan. «free» — bepul demo (3 ta).

| Yozuv | Kirish | Identifikatsiya (PubChem) | Ilmiy claim (DOI, dastlabki dalil darajasi, litsenziya) | Xalqaro nazorat (INCB) |
|---|---|---|---|---|
| Ethanol | free | CID 702, C2H6O | metabolites: acetaldehyde, acetate, acetyl-CoA [10.35946/arcr.v34.3.09, dalil C, openReuse, iqtibos bor] | — |
| Methanol | free | CID 887, CH4O | metabolites: formaldehyde, formic acid [10.3390/toxics12120924, dalil C, openReuse, iqtibos bor] | — |
| Ethylene glycol | pro | CID 174, C2H6O2 | metabolites: glycolaldehyde, glycolate [10.1186/s13054-022-04227-2, dalil A, openReuse, iqtibos bor] | — |
| Morphine | pro | CID 5288826, C17H19NO3 | metabolites: morphine-3-glucuronide (M3G), morphine-6-glucuronide (M6G) [10.3389/fnmol.2022.882443, dalil C, openReuse, iqtibos bor] | Single Konv. Narcotic Drugs — I |
| Heroin (diacetylmorphine) | pro | CID 5462328, C21H23NO5 | metabolites: 6-monoacetylmorphine (6-MAM), morphine [10.1038/s41398-023-02406-5, dalil C, openReuse, iqtibos bor] | Single Konv. Narcotic Drugs — I, IV |
| 6-Monoacetylmorphine (6-MAM) | pro | CID 5462507, C19H21NO4 | — | — |
| Fentanyl | pro | CID 3345, C22H28N2O | metabolites: norfentanyl [10.1097/ADM.0000000000001185, dalil C, unknown, iqtibos YO‘Q] | Single Konv. Narcotic Drugs — I |
| Tramadol | pro | CID 33741, C16H25NO2 | metabolites: O-desmethyltramadol, M2, M5 [10.3390/molecules31071177, dalil C, openReuse, iqtibos bor] | — |
| Methamphetamine | pro | CID 10836, C10H15N | metabolites: 4-hydroxymetamphetamine, amphetamine (AM) [10.3390/metabo12121174, dalil B, openReuse, iqtibos bor] | Konv. Psychotropic Substances of 1971 — II |
| Cocaine | pro | CID 446220, C17H21NO4 | metabolites: EME, BE, ecgonine (EC) [10.3390/toxins14040278, dalil C, openReuse, iqtibos bor] | Single Konv. Narcotic Drugs — I |
| Δ9-Tetrahydrocannabinol (THC) | pro | CID 16078, C21H30O2 | metabolites: THC-COOH, 11-OH-THC [10.1007/s00414-026-03790-5, dalil A, openReuse, iqtibos bor] | Konv. Psychotropic Substances of 1971 — II |
| Alprazolam | pro | CID 2118, C17H13ClN4 | metabolites: 4-hydroxyalprazolam, α-hydroxyalprazolam [10.3390/biomedicines10123022, dalil B, openReuse, iqtibos bor] | Konv. Psychotropic Substances of 1971 — IV |
| Phenazepam | pro | CID 40113, C15H10BrClN2O | metabolites: 3-hydroxyphenazepam [10.3390/ph14060560, dalil C, openReuse, iqtibos bor] | Konv. Psychotropic Substances of 1971 — IV |
| Amitriptyline | pro | CID 2160, C20H23N | metabolites: nortriptyline [10.1002/cpt.597, dalil A, unknown, iqtibos YO‘Q] | — |
| Paracetamol (acetaminophen) | pro | CID 1983, C8H9NO2 | metabolites: sulfate, glucuronide, NAPQI [10.3390/livers4030024, dalil C, openReuse, iqtibos bor] | — |
| Pregabalin | pro | CID 5486971, C8H17NO2 | metabolism_note: negligible metabolism, almost exclusive renal elimination [10.3389/ftox.2026.1822851, dalil D, openReuse, iqtibos bor] | — |
| Carbon monoxide | free | CID 281, CO | biomarker: Carboxyhaemoglobin (COHb) [10.3390/diagnostics15050581, dalil C, openReuse, iqtibos bor] | — |
| Chlorpyrifos | pro | CID 2730, C9H11Cl3NO3PS | metabolites: chlorpyrifos-oxon [10.3390/ijms27093909, dalil C, openReuse, iqtibos bor] | — |
| Aluminium phosphide | pro | CID 16126812, AlP | transformation_product: phosphine gas [10.1016/j.dialog.2025.100247, dalil A, nonCommercial, iqtibos YO‘Q] | — |
| Phosphine | pro | CID 24404, H3P | — | — |

Izohlar (reviewer uchun):
- Tramadol (CID 33741) va metamfetamin (CID 10836) — PubChem nom bo‘yicha **aniq stereoizomer** qaytardi; tramadol klinikada rasemat. Reviewer tasdiqlashi kerak.
- Alyuminiy fosfidi CID 16126812 — PubChem nom bo‘yicha qaytargan yozuv; tekshirilsin.
- Pregabalin manbasi — case report (dalil D); kuchliroq manba bilan almashtirish tavsiya etiladi.
- Fenazepam iqtibosi «It is metabolized…» bilan boshlanadi (ega oldingi gapda).
- Kokain: EME = ecgonine methyl ester, BE = benzoylecgonine (maqolaning o‘zida ochilgan).
- Dalil darajalari — maqola turiga ko‘ra **dastlabki** baho (`content/pilot/evidence_levels.json`).
- RU/UZ nomlar — `machine_draft`.

## 3. Ilmiy va huquqiy qatlam ajratilgan

- 38 ta claim → `international_scientific` qatlam, birortasi davlatga bog‘lanmagan, `legal` domenida emas.
- INCB ro‘yxatlari → **Jurisdiction Layer**, `INT` yurisdiksiyasi, 2 ta rasmiy hujjat va 8 ta `control_status` qoidasi. Har birida rasmiy manba, nashr, kuchga kirish sanasi va oxirgi tekshiruv bor. Green List uchun manbada faqat yil berilgan — bu UI’da ko‘rsatiladi.
- Ro‘yxatda topilmagan moddalar (tramadol, pregabalin va boshq.) uchun **qoida yaratilmagan**. UI’da «yo‘qlik nazoratda emas degani emas» ogohlantirishi bor.
- Milliy qonunlar yig‘ilmagan. Davlat tanlansa, «milliy kontent yuklanmagan» deb halol ko‘rsatiladi.

## 4. Ilova

- Kontent paketi birinchi kadrdan keyin o‘rnatiladi va startup’ni kutdirmaydi.
- O‘rnatish tartibi: imzo (Ed25519) → SHA-256 → kanal → versiya → sxema → `integrity_check` → atomik almashtirish.
- `FE_CONTENT_CHANNEL` standarti `development`. Production yig‘ma development paketni **rad etadi** (RG-17).
- TEST fixture’lar standart **o‘chiq**; ular faqat testlarda ishlatiladi (RG-12 ✅).
- Modda kartochkasi quyidagilarni ko‘rsatadi:
  - provenance: dalil holati, reviewer holati («0 / 2»), claim va baza versiyasi, tarjima holati;
  - identifikatorlar;
  - claim’lar (dalil darajasi bilan);
  - iqtibos (faqat litsenziya ruxsat bersa);
  - manbalar (DOI/URL nusxalanadi);
  - yurisdiksiya qatlami.

## 5. Bepul demo va Lifetime

| | Bepul | Lifetime |
|---|---|---|
| Kutubxona | 3 ta yozuv (etanol, metanol, CO) to‘liq | Barchasi |
| Qolgan yozuvlar | Nom, ogohlantirish, provenance, **manbalar** ochiq; ilmiy tafsilot va huquqiy qatlam yopiq | Ochiq |
| Kurslar | 1 ta | Barchasi |
| Vositalar | C₁V₁ | Barchasi |
| Qidiruv | Har guruhda 3 ta natija va qolganlar soni | Cheklovsiz |
| Disclaimer, cheklovlar, manbalar, dalil holati | **Doim ochiq** | Ochiq |

Hozir ilovada real kurs yo‘q (o‘quv kontenti review kutadi), shuning uchun «1 kurs» chegarasi hozircha faqat testda sinalgan.

## 6. Lifetime xarid xavfsizligi

Batafsil: `docs/12_PURCHASE_VERIFICATION.md`.

- Huquq **faqat** store tasdiqlagan xariddan beriladi: StoreKit / Google Play Billing, shu Apple ID / Google akkaunti.
- Ilovada lokal bool, SharedPreferences yoki fayl orqali premium ochilmaydi. Har sessiyada egalik store’dan jim so‘raladi.
- Restore: `restorePurchases` va store’ning joriy egalik ro‘yxati.
- **Server tekshiruvi ulanmagan — RELEASE BLOCKER (RG-18).** Hozirgi holat: «store tasdig‘i, server tekshiruvisiz». U production uchun xavfsiz deb ko‘rsatilmaydi, debug/profile diagnostikasida ochiq yoziladi.

## 7. R2 brend

- `BrandMark` = R2 «Integrated Peak». Geometriya SVG’dan dasturiy olinadi.
- Android: legacy + adaptive ikonka. iOS: AppIcon, alfa-kanalsiz 1024.
- Trademark tekshiruvi tugamaguncha brend **tasdiqlangan emas** (RG-06); bu About ekranida aytiladi.
- Bundle ID o‘zgartirilmadi. Nomzod `com.forensicexpert.app` (RG-09).

## 8. Tekshiruvlar va o‘lchovlar

| Tekshiruv | Natija |
|---|---|
| Analyze (app + packages, `--fatal-infos`) | ✅ toza |
| Testlar | ✅ 663 (ilova 532, paketlar 131) + 1 skip |
| Golden | ✅ 30 kadr |
| gitleaks / OSV | ✅ / ✅ |
| Release APK | ✅ 64.2 MB; label «FORENSIC EXPERT»; `BILLING` ruxsati; pilot paket ichida. ⚠️ **debug sertifikat bilan imzolangan** — RG-20 |

O‘lchovlar **mobil qurilmada emas**. Host VM’da `flutter test` (JIT, debug) bilan olindi, n=5:

| Ko‘rsatkich | Natija |
|---|---|
| Pilot paketni o‘rnatish (imzo + SHA-256 + integrity + atomik) | birinchi 256 ms (sqlite/Ed25519 isishi), keyingilari 12–24 ms |
| Kutubxonani `content.db` dan yuklash | 6–40 ms |
| Qidiruv indeksini qurish | 0.1–12 ms |
| Qidiruv (EN/RU/UZ, xatoli) | 1.1–30 ms, median ≈ 2 ms |

Real qurilmada o‘lchash — RG-10.

