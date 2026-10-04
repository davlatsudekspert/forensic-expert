# 28 — RG-25: LOD/LOQ — ICH Q2(R1) va Q2(R2) solishtiruvi

**Xulosa:** DL = 3.3σ/S va QL = 10σ/S koeffitsientlari Q2(R2) da **o‘zgarmagan**. Kalkulyator havolasi Q2(R2) §3.2.3.3 ga ko‘chirildi, dvigatel versiyasi `1.0.0 → 1.1.0`, natija o‘zgarmaydi. **RG-25 ochiq qoladi** — laboratoriya reviewer’i tasdiqlashi kerak.

## Manbalar (rasmiy PDF, 2026-10-04 yuklangan)

| Hujjat | URL | SHA-256 |
|---|---|---|
| ICH Q2(R1), Step 4, 2005-11 | https://database.ich.org/sites/default/files/Q2%28R1%29%20Guideline.pdf | `a22ff5f9…e6f293a` |
| ICH Q2(R2), qabul 2023-11-01 (fayl 2023-11-30) | https://database.ich.org/sites/default/files/ICH_Q2%28R2%29_Guideline_2023_1130.pdf | `d935618f…6ad6472c` |

To‘liq xeshlar — `content/tools/p7/assemble_p7.py` (`STANDARDS`) va ilovadagi standartlar katalogida.

## Solishtirish

| Jihat | Q2(R1) | Q2(R2) |
|---|---|---|
| Bo‘lim | 6 (DL), 7 (QL) | 3.2.3 «Validation of Lower Range Limits» |
| σ/S formulasi | 6.3: DL = 3.3σ/S; 7.3: QL = 10σ/S | 3.2.3.3: DL = 3.3σ/S; QL = 10σ/S — **bir xil** |
| σ manbai | bo‘sh namuna SD; regressiya qoldiq SD; y-kesishmalar SD | xuddi shu; qoldiq SD «root mean square error/deviation» deb aniqlashtirilgan; kalibrlash DL/QL atrofida bo‘lishi kerak |
| S/N | DL: «3 or 2:1»; QL: 10:1 | DL: 3:1; QL: «at least 10:1» |
| Yangi | — | 3.2.3.4: QL ni aniqlik va pretsizlik bilan **bevosita** validatsiya qilish |
| Tasdiqlash | hisoblangan DL/QL mos namunalar bilan tasdiqlanadi | 3.2.3.5: xuddi shu; QL hisobot chegarasidan ~10 baravar past bo‘lsa — asoslangan holda tasdiqlash tashlab ketilishi mumkin |
| Doira | farmatsevtik | farmatsevtik (forensik metodga qo‘llash — laboratoriya qarori) |

## Koddagi o‘zgarish

* `packages/fe_calc_engine/lib/src/stats/lod_loq.dart`: `referenceSourceIds: ['STD-ICH-Q2R2']`, `engineVersion: '1.1.0'`, izohlar; koeffitsientlar o‘zgarmagan (test bilan qotirilgan).
* Ilova matni: «ICH Q2(R2) … §3.2.3.3» va izoh (R1 almashtirilgan; S/N va bevosita tasdiqlash ham mumkin; RG-25 kutilmoqda).
* Standartlar katalogi: `STD-ICH-Q2R1` → `superseded`, `superseded_by = STD-ICH-Q2R2` (FE038).

## Reviewer uchun savollar (RG-25)

1. σ ni qaysi usulda hisoblash laboratoriya SOP’iga mos?
2. Forensik toksikologiya uchun ASB/ANSI yoki milliy talab ICH o‘rniga qo‘llanadimi?
3. Hisoblangan QL ni bevosita (3.2.3.4) tasdiqlash ilovada majburiy ogohlantirish bo‘lishi kerakmi?
