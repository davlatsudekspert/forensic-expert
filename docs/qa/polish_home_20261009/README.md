# Birinchi ishga tushirish, Asosiy va Profil — oldin / keyin (2026-10-09)

Haqiqiy ilova, Linux desktop (Xvfb), MOCK akkaunt, tarmoq o‘chiq.
Qayta ishga tushirish: `./tool/qa_real_app.sh home`
(`apps/mobile/integration_test/qa_home_test.dart`, 25/25 PASS).

| # | Ekran | Oldin | Keyin |
|---|-------|-------|-------|
| 01 | Ilmiy ogohlantirish (onboarding) | `01_disclaimer_uz_before.png` | `01_disclaimer_uz_after.png` |
| 02 | Rejim: Mutaxassis + rol | `../real_app_20261009/e02_…` | `02_mode_expert_uz_after.png` |
| 03 | Hisob tanlovi (oxirgi qadam) | `03_…_before.png` | `03_…_after.png` |
| 04–05 | Asosiy — talaba (tepa, pastroq) | `04/05_…_before.png` | `04/05_…_after.png` |
| 06–08 | Profil — talaba (tepa, sozlamalar, ilova haqida) | `06–08_…_before.png` | `06–08_…_after.png` |
| 09 | Asosiy — mutaxassis (past qism) | `09_…_before.png` | `09_…_after.png` |
| 10–11 | Qorong‘i mavzu: Asosiy, Profil (kirgan) | `10/11_…_before.png` | `10/11_…_after.png` |
| 12–13 | 320 dp, ×2 shrift: Asosiy, Profil | `12/13_…_before.png` | `12/13_…_after.png` |
| 14–15 | Asosiy — ru, en | `14/15_…_before.png` | `14/15_…_after.png` |

Asosiy o‘zgarishlar: onboarding’da qadam ko‘rsatkichi (1–4), ogohlantirish
3 ta qisqa band + «To‘liq matn»; hisob ekrani bitta asosiy amal («Boshlash»);
Asosiy’da rejimga mos 4 ta tezkor amal (talaba: o‘qish, yo‘riqnomalar,
moddalar, AI; mutaxassis: moddalar, usullar, kalkulyatorlar, AI), bo‘sh
«Davom ettirish» bo‘limi yashirildi, ogohlantirish pastda bitta sokin qator;
Profil guruhlangan kartalarda (hisob → obuna → sozlamalar → ko‘rinish →
yordam → tasdiqlash → ma’lumotlar → ilova haqida).
