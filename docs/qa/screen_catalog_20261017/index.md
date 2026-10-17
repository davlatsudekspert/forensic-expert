# Ekranlar katalogi — 2026-10-17 (premium dizayn)

Yaratilgan: `flutter test --tags catalog --run-skipped test/catalog`
(haqiqiy shriftlar, soyalar yoqilgan, 1x — 390 px kenglik; 320 dp — 320 px),
so‘ng `python3 tool/compress_catalog_png.py` (256 rang, hajm kichik).
Ma’lumot: ilovadagi pilot kontent paketi; akkaunt MOCK; sinf serveri, murojaatlar
va admin statistikasi — TEST soxta xizmatlari (FIXTURE). Tarmoq yo‘q, AI serveri
ulanmagan (AI oflayn holati ko‘rsatiladi). Real iOS/Android qurilma emas.

Variantlar: `uz` — o‘zbekcha 390 dp yorug‘, `uzdark` — qorong‘i, `ru`/`en` —
yorug‘ 390 dp, `uz320` — 320 dp. «Xato» ustuni — chizishda ushlangan Flutter
xatosi (masalan, overflow); bo‘sh bo‘lsa — xato yo‘q.

| # | Ekran | Marshrut | Holat | Persona | Fayllar | Xato |
|---|---|---|---|---|---|---|
| 001 | Onboarding: til tanlash | `/onboarding/language` | standart | guestOnboarding | [uz.png](001_onboarding_til_uz.png) [uzdark.png](001_onboarding_til_uzdark.png) [ru.png](001_onboarding_til_ru.png) [en.png](001_onboarding_til_en.png) [uz320.png](001_onboarding_til_uz320.png) |  |
| 002 | Onboarding: ilmiy ogohlantirish | `/onboarding/disclaimer` | standart | guestOnboarding | [uz.png](002_onboarding_ogohlantirish_uz.png) [uzdark.png](002_onboarding_ogohlantirish_uzdark.png) [ru.png](002_onboarding_ogohlantirish_ru.png) [en.png](002_onboarding_ogohlantirish_en.png) [uz320.png](002_onboarding_ogohlantirish_uz320.png) |  |
| 003 | Onboarding: rejim (talaba/mutaxassis) | `/onboarding/mode` | standart | guestOnboarding | [uz.png](003_onboarding_rejim_uz.png) [uzdark.png](003_onboarding_rejim_uzdark.png) [ru.png](003_onboarding_rejim_ru.png) [en.png](003_onboarding_rejim_en.png) [uz320.png](003_onboarding_rejim_uz320.png) |  |
| 004 | Onboarding: hisob taklifi | `/welcome/account` | standart | guestOnboarding | [uz.png](004_onboarding_hisob_uz.png) [uzdark.png](004_onboarding_hisob_uzdark.png) |  |
| 005 | Asosiy (talaba) | `/home` | standart | student | [uz.png](005_asosiy_talaba_uz.png) [uzdark.png](005_asosiy_talaba_uzdark.png) [ru.png](005_asosiy_talaba_ru.png) [en.png](005_asosiy_talaba_en.png) [uz320.png](005_asosiy_talaba_uz320.png) |  |
| 006 | Asosiy (talaba) | `/home` | pastki qism | student | [uz.png](006_asosiy_talaba_pastki_uz.png) [uzdark.png](006_asosiy_talaba_pastki_uzdark.png) |  |
| 007 | Asosiy (mutaxassis) | `/home` | standart | expert | [uz.png](007_asosiy_mutaxassis_uz.png) [uzdark.png](007_asosiy_mutaxassis_uzdark.png) [ru.png](007_asosiy_mutaxassis_ru.png) [en.png](007_asosiy_mutaxassis_en.png) [uz320.png](007_asosiy_mutaxassis_uz320.png) |  |
| 008 | Asosiy (mutaxassis) | `/home` | pastki qism | expert | [uz.png](008_asosiy_mutaxassis_pastki_uz.png) [uzdark.png](008_asosiy_mutaxassis_pastki_uzdark.png) |  |
| 009 | Ustoz paneli | `/home/teacher` | standart | student | [uz.png](009_ustoz_paneli_uz.png) [uzdark.png](009_ustoz_paneli_uzdark.png) [ru.png](009_ustoz_paneli_ru.png) [en.png](009_ustoz_paneli_en.png) [uz320.png](009_ustoz_paneli_uz320.png) |  |
| 010 | Ustoz: natijalar va CSV | `/home/teacher/results` | bo‘sh | student | [uz.png](010_ustoz_natijalar_bosh_uz.png) [uzdark.png](010_ustoz_natijalar_bosh_uzdark.png) |  |
| 011 | Sinfda test (qo‘shilish) | `/home/learn/class` | standart | student | [uz.png](011_sinfda_test_uz.png) [uzdark.png](011_sinfda_test_uzdark.png) [ru.png](011_sinfda_test_ru.png) [en.png](011_sinfda_test_en.png) [uz320.png](011_sinfda_test_uz320.png) |  |
| 012 | Sinfda test (qo‘shilish) | `/home/learn/class` | noto‘g‘ri kod xatosi | student | [uz.png](012_sinfda_test_notogri_uz.png) [uzdark.png](012_sinfda_test_notogri_uzdark.png) |  |
| 013 | Ustoz: test yaratish (mavzu tanlash) | `/home/learn/class/new` | standart | student | [uz.png](013_sinf_yaratish_uz.png) [uzdark.png](013_sinf_yaratish_uzdark.png) [ru.png](013_sinf_yaratish_ru.png) [en.png](013_sinf_yaratish_en.png) [uz320.png](013_sinf_yaratish_uz320.png) |  |
| 014 | Ustoz: kod va QR (kutish zali) | `/class-host` | standart | student | [uz.png](014_sinf_kod_qr_uz.png) [uzdark.png](014_sinf_kod_qr_uzdark.png) [ru.png](014_sinf_kod_qr_ru.png) [en.png](014_sinf_kod_qr_en.png) [uz320.png](014_sinf_kod_qr_uz320.png) |  |
| 015 | Ustoz: savol jarayoni | `/class-host` | standart | student | [uz.png](015_sinf_savol_ustoz_uz.png) [uzdark.png](015_sinf_savol_ustoz_uzdark.png) |  |
| 016 | Ustoz: yakuniy natija va CSV | `/class-host` | standart | student | [uz.png](016_sinf_natija_ustoz_uz.png) [uzdark.png](016_sinf_natija_ustoz_uzdark.png) |  |
| 017 | Ustoz: natijalar ro‘yxati (tugagan sinf, CSV tugmasi) | `/class-host` | standart | student | [uz.png](017_sinf_natijalar_royxat_uz.png) [uzdark.png](017_sinf_natijalar_royxat_uzdark.png) |  |
| 018 | Talaba: kod + laqab | `/class-join` | standart | student | [uz.png](018_sinf_qoshilish_talaba_uz.png) [uzdark.png](018_sinf_qoshilish_talaba_uzdark.png) [ru.png](018_sinf_qoshilish_talaba_ru.png) [en.png](018_sinf_qoshilish_talaba_en.png) [uz320.png](018_sinf_qoshilish_talaba_uz320.png) |  |
| 019 | Talaba: savolga javob | `/class-play` | standart | student | [uz.png](019_sinf_savol_talaba_uz.png) [uzdark.png](019_sinf_savol_talaba_uzdark.png) |  |
| 020 | Talaba: yakuniy natija | `/class-play` | standart | student | [uz.png](020_sinf_natija_talaba_uz.png) [uzdark.png](020_sinf_natija_talaba_uzdark.png) |  |
| 021 | O‘qish | `/home/learn` | standart | student | [uz.png](021_oqish_uz.png) [uzdark.png](021_oqish_uzdark.png) [ru.png](021_oqish_ru.png) [en.png](021_oqish_en.png) [uz320.png](021_oqish_uz320.png) |  |
| 022 | O‘qish: kurs/dars | `/home/learn` | dars ochilgan | student | [uz.png](022_oqish_kurs_dars_uz.png) [uzdark.png](022_oqish_kurs_dars_uzdark.png) |  |
| 023 | Mashqlar (to‘plamlar) | `/home/learn/study` | standart | student | [uz.png](023_mashqlar_uz.png) [uzdark.png](023_mashqlar_uzdark.png) |  |
| 024 | Mashq: kartochka | `/home/learn/study` | standart | student | [uz.png](024_mashq_kartochka_uz.png) [uzdark.png](024_mashq_kartochka_uzdark.png) |  |
| 025 | Mashq: test savoli | `/home/learn/study` | standart | student | [uz.png](025_mashq_test_uz.png) [uzdark.png](025_mashq_test_uzdark.png) |  |
| 026 | Mashq: test savoli | `/home/learn/study` | javob tekshirildi | student | [uz.png](026_mashq_test_javob_uz.png) [uzdark.png](026_mashq_test_javob_uzdark.png) |  |
| 027 | Imtihon | `/home/learn/study` | standart | student | [uz.png](027_imtihon_uz.png) [uzdark.png](027_imtihon_uzdark.png) |  |
| 028 | Qidiruv | `/home/search` | bo‘sh | student | [uz.png](028_qidiruv_bosh_uz.png) [uzdark.png](028_qidiruv_bosh_uzdark.png) [ru.png](028_qidiruv_bosh_ru.png) [en.png](028_qidiruv_bosh_en.png) [uz320.png](028_qidiruv_bosh_uz320.png) |  |
| 029 | Qidiruv | `/home/search?q=etanol` | natijalar | student | [uz.png](029_qidiruv_natijalar_uz.png) [uzdark.png](029_qidiruv_natijalar_uzdark.png) [ru.png](029_qidiruv_natijalar_ru.png) [en.png](029_qidiruv_natijalar_en.png) [uz320.png](029_qidiruv_natijalar_uz320.png) |  |
| 030 | Qidiruv | `/home/search?q=zzqxw` | natija yo‘q | student | [uz.png](030_qidiruv_natija_uz.png) [uzdark.png](030_qidiruv_natija_uzdark.png) |  |
| 031 | Kengaytirilgan qidiruv | `/home/search/pro?q=morfin` | standart | expert | [uz.png](031_kengaytirilgan_qidiruv_uz.png) [uzdark.png](031_kengaytirilgan_qidiruv_uzdark.png) |  |
| 032 | Kutubxona | `/library` | standart | student | [uz.png](032_kutubxona_uz.png) [uzdark.png](032_kutubxona_uzdark.png) [ru.png](032_kutubxona_ru.png) [en.png](032_kutubxona_en.png) [uz320.png](032_kutubxona_uz320.png) |  |
| 033 | Moddalar ro‘yxati | `/library/section/substances` | standart | student | [uz.png](033_moddalar_uz.png) [uzdark.png](033_moddalar_uzdark.png) |  |
| 034 | Modda: Etanol | `/library/entry/ethanol` | standart | student | [uz.png](034_modda_etanol_uz.png) [uzdark.png](034_modda_etanol_uzdark.png) [ru.png](034_modda_etanol_ru.png) [en.png](034_modda_etanol_en.png) [uz320.png](034_modda_etanol_uz320.png) |  |
| 035 | Modda: Etanol | `/library/entry/ethanol` | Tahlil bo‘limi | student | [uz.png](035_modda_etanol_Tahlil_uz.png) [uzdark.png](035_modda_etanol_Tahlil_uzdark.png) |  |
| 036 | Modda: Etanol | `/library/entry/ethanol` | yurisdiksiya qatlami | student | [uz.png](036_modda_etanol_yurisdiksiya_uz.png) [uzdark.png](036_modda_etanol_yurisdiksiya_uzdark.png) |  |
| 037 | Modda: Etanol | `/library/entry/ethanol` | bog‘liq materiallar | student | [uz.png](037_modda_etanol_bogliq_uz.png) [uzdark.png](037_modda_etanol_bogliq_uzdark.png) |  |
| 038 | Modda: Etanol | `/library/entry/ethanol` | manbalar | student | [uz.png](038_modda_etanol_manbalar_uz.png) [uzdark.png](038_modda_etanol_manbalar_uzdark.png) |  |
| 039 | Modda: Etanol | `/library/entry/ethanol` | provenance bottom sheet | student | [uz.png](039_modda_etanol_provenance_uz.png) [uzdark.png](039_modda_etanol_provenance_uzdark.png) |  |
| 040 | Modda: Morfin | `/library/entry/morphine` | standart | student | [uz.png](040_modda_morfin_uz.png) [uzdark.png](040_modda_morfin_uzdark.png) [ru.png](040_modda_morfin_ru.png) [en.png](040_modda_morfin_en.png) [uz320.png](040_modda_morfin_uz320.png) |  |
| 041 | Tahlil rejasi | `/home/substance/morphine/plan` | standart | student | [uz.png](041_tahlil_rejasi_uz.png) [uzdark.png](041_tahlil_rejasi_uzdark.png) |  |
| 042 | Usullar va SOP | `/home/knowledge/method` | standart | student | [uz.png](042_usullar_uz.png) [uzdark.png](042_usullar_uzdark.png) |  |
| 043 | Usul sahifasi | `/home/knowledge/method` | standart | student | [uz.png](043_usul_uz.png) [uzdark.png](043_usul_uzdark.png) |  |
| 044 | Reagentlar | `/home/knowledge/reagent` | standart | student | [uz.png](044_reagentlar_uz.png) [uzdark.png](044_reagentlar_uzdark.png) |  |
| 045 | Reagent sahifasi | `/home/knowledge/reagent` | standart | student | [uz.png](045_reagent_uz.png) [uzdark.png](045_reagent_uzdark.png) |  |
| 046 | Skrining testlari | `/home/knowledge/screeningTest` | standart | student | [uz.png](046_skrining_uz.png) [uzdark.png](046_skrining_uzdark.png) |  |
| 047 | Skrining test sahifasi | `/home/knowledge/screeningTest` | standart | student | [uz.png](047_skrining_test_uz.png) [uzdark.png](047_skrining_test_uzdark.png) |  |
| 048 | Yo‘riqnomalar | `/library/guidelines` | standart | student | [uz.png](048_yoriqnomalar_uz.png) [uzdark.png](048_yoriqnomalar_uzdark.png) [ru.png](048_yoriqnomalar_ru.png) [en.png](048_yoriqnomalar_en.png) [uz320.png](048_yoriqnomalar_uz320.png) |  |
| 049 | Yo‘riqnoma kartasi | `/library/guidelines` | standart | student | [uz.png](049_yoriqnoma_uz.png) [uzdark.png](049_yoriqnoma_uzdark.png) |  |
| 050 | Manbalar ro‘yxati | `/library/sources` | standart | student | [uz.png](050_manbalar_uz.png) [uzdark.png](050_manbalar_uzdark.png) |  |
| 051 | Manba sahifasi | `/library/sources` | standart | student | [uz.png](051_manba_uz.png) [uzdark.png](051_manba_uzdark.png) |  |
| 052 | Ilmiy lug‘at | `/library/glossary` | standart | student | [uz.png](052_lugat_uz.png) [uzdark.png](052_lugat_uzdark.png) |  |
| 053 | Lug‘at: termin | `/library/glossary` | standart | student | [uz.png](053_lugat_termin_uz.png) [uzdark.png](053_lugat_termin_uzdark.png) |  |
| 054 | Biologik namunalar | `/library/specimens` | standart | student | [uz.png](054_namunalar_uz.png) [uzdark.png](054_namunalar_uzdark.png) |  |
| 055 | Namuna sahifasi | `/library/specimens` | standart | student | [uz.png](055_namuna_uz.png) [uzdark.png](055_namuna_uzdark.png) |  |
| 056 | Ziddiyatlar | `/library/conflicts` | standart | student | [uz.png](056_ziddiyatlar_uz.png) [uzdark.png](056_ziddiyatlar_uzdark.png) |  |
| 057 | Tekshiruv holati | `/library/review` | standart | student | [uz.png](057_tekshiruv_holati_uz.png) [uzdark.png](057_tekshiruv_holati_uzdark.png) |  |
| 058 | Tadqiqotlar va dalillar | `/home/research` | standart | student | [uz.png](058_tadqiqotlar_uz.png) [uzdark.png](058_tadqiqotlar_uzdark.png) |  |
| 059 | Tadqiqot sahifasi | `/home/research` | standart | student | [uz.png](059_tadqiqot_uz.png) [uzdark.png](059_tadqiqot_uzdark.png) |  |
| 060 | Standartlar | `/library/standards` | standart | student | [uz.png](060_standartlar_uz.png) [uzdark.png](060_standartlar_uzdark.png) |  |
| 061 | Barcha fanlar | `/home/disciplines` | standart | student | [uz.png](061_fanlar_uz.png) [uzdark.png](061_fanlar_uzdark.png) |  |
| 062 | Fan sahifasi | `/home/disciplines/forensic_chemistry` | standart | student | [uz.png](062_fan_uz.png) [uzdark.png](062_fan_uzdark.png) [ru.png](062_fan_ru.png) [en.png](062_fan_en.png) [uz320.png](062_fan_uz320.png) |  |
| 063 | Sud tibbiyoti | `/home/area/forensicMedicine` | standart | student | [uz.png](063_sud_tibbiyoti_uz.png) [uzdark.png](063_sud_tibbiyoti_uzdark.png) |  |
| 064 | Biokimyo | `/home/area/biochemistry` | standart | student | [uz.png](064_biokimyo_uz.png) [uzdark.png](064_biokimyo_uzdark.png) |  |
| 065 | Gistologiya | `/home/area/histology` | standart | student | [uz.png](065_gistologiya_uz.png) [uzdark.png](065_gistologiya_uzdark.png) |  |
| 066 | Huquq va yurisdiksiyalar | `/home/jurisdictions` | standart | student | [uz.png](066_yurisdiksiyalar_uz.png) [uzdark.png](066_yurisdiksiyalar_uzdark.png) |  |
| 067 | Yurisdiksiya: O‘zbekiston | `/home/jurisdictions/UZ` | standart | student | [uz.png](067_yurisdiksiya_uz.png) [uzdark.png](067_yurisdiksiya_uzdark.png) |  |
| 068 | Yurisdiksiyalarni solishtirish | `/home/compare` | standart | student | [uz.png](068_solishtirish_uz.png) [uzdark.png](068_solishtirish_uzdark.png) |  |
| 069 | Sudda so‘roq | `/library/court-prep` | standart | expert | [uz.png](069_sudda_soroq_uz.png) [uzdark.png](069_sudda_soroq_uzdark.png) [ru.png](069_sudda_soroq_ru.png) [en.png](069_sudda_soroq_en.png) [uz320.png](069_sudda_soroq_uz320.png) |  |
| 070 | Sudda so‘roq: mashq | `/library/court-prep/practice` | standart | expert | [uz.png](070_sudda_soroq_mashq_uz.png) [uzdark.png](070_sudda_soroq_mashq_uzdark.png) |  |
| 071 | Sudda so‘roq: tamoyillar | `/library/court-prep/principles` | standart | expert | [uz.png](071_sudda_soroq_tamoyillar_uz.png) [uzdark.png](071_sudda_soroq_tamoyillar_uzdark.png) |  |
| 072 | Sudda so‘roq: simulyator | `/library/court-prep/simulator` | standart | expert | [uz.png](072_sudda_soroq_simulyator_uz.png) [uzdark.png](072_sudda_soroq_simulyator_uzdark.png) |  |
| 073 | Sudda so‘roq: ssenariy | `/library/court-prep/simulator` | standart | expert | [uz.png](073_sudda_soroq_ssenariy_uz.png) [uzdark.png](073_sudda_soroq_ssenariy_uzdark.png) |  |
| 074 | Sudda so‘roq: tezkor mashq | `/library/court-prep/drill` | standart | expert | [uz.png](074_sudda_soroq_drill_uz.png) [uzdark.png](074_sudda_soroq_drill_uzdark.png) |  |
| 075 | Sudda so‘roq: statistika | `/library/court-prep/stats` | standart | expert | [uz.png](075_sudda_soroq_statistika_uz.png) [uzdark.png](075_sudda_soroq_statistika_uzdark.png) |  |
| 076 | Sudda so‘roq: mavzu | `/library/court-prep` | standart | expert | [uz.png](076_sudda_soroq_mavzu_uz.png) [uzdark.png](076_sudda_soroq_mavzu_uzdark.png) |  |
| 077 | Vositalar | `/tools` | standart | expert | [uz.png](077_vositalar_uz.png) [uzdark.png](077_vositalar_uzdark.png) [ru.png](077_vositalar_ru.png) [en.png](077_vositalar_en.png) [uz320.png](077_vositalar_uz320.png) |  |
| 078 | Kalkulyator: tool.fm.pmi_henssge | `/tools/tool/tool.fm.pmi_henssge` | bo‘sh | expert | [uz.png](078_kalk_pmi_henssge_bosh_uz.png) [uzdark.png](078_kalk_pmi_henssge_bosh_uzdark.png) |  |
| 079 | Kalkulyator: tool.fm.pmi_henssge | `/tools/tool/tool.fm.pmi_henssge` | to‘g‘ri kiritish (har maydon «2») | expert | [uz.png](079_kalk_pmi_henssge_togri_uz.png) [uzdark.png](079_kalk_pmi_henssge_togri_uzdark.png) |  |
| 080 | Kalkulyator: tool.fm.pmi_henssge | `/tools/tool/tool.fm.pmi_henssge` | xato kiritish (har maydon «0») | expert | [uz.png](080_kalk_pmi_henssge_xato_uz.png) [uzdark.png](080_kalk_pmi_henssge_xato_uzdark.png) |  |
| 081 | Kalkulyator: tool.tox.widmark | `/tools/tool/tool.tox.widmark` | bo‘sh | expert | [uz.png](081_kalk_widmark_bosh_uz.png) [uzdark.png](081_kalk_widmark_bosh_uzdark.png) [ru.png](081_kalk_widmark_bosh_ru.png) [en.png](081_kalk_widmark_bosh_en.png) [uz320.png](081_kalk_widmark_bosh_uz320.png) |  |
| 082 | Kalkulyator: tool.tox.widmark | `/tools/tool/tool.tox.widmark` | to‘g‘ri kiritish (har maydon «2») | expert | [uz.png](082_kalk_widmark_togri_uz.png) [uzdark.png](082_kalk_widmark_togri_uzdark.png) |  |
| 083 | Kalkulyator: tool.tox.widmark | `/tools/tool/tool.tox.widmark` | xato kiritish (har maydon «0») | expert | [uz.png](083_kalk_widmark_xato_uz.png) [uzdark.png](083_kalk_widmark_xato_uzdark.png) |  |
| 084 | Kalkulyator: tool.tox.back_calculation | `/tools/tool/tool.tox.back_calculation` | bo‘sh | expert | [uz.png](084_kalk_back_calculation_bosh_uz.png) [uzdark.png](084_kalk_back_calculation_bosh_uzdark.png) |  |
| 085 | Kalkulyator: tool.tox.back_calculation | `/tools/tool/tool.tox.back_calculation` | to‘g‘ri kiritish (har maydon «2») | expert | [uz.png](085_kalk_back_calculation_togri_uz.png) [uzdark.png](085_kalk_back_calculation_togri_uzdark.png) |  |
| 086 | Kalkulyator: tool.tox.back_calculation | `/tools/tool/tool.tox.back_calculation` | xato kiritish (har maydon «0») | expert | [uz.png](086_kalk_back_calculation_xato_uz.png) [uzdark.png](086_kalk_back_calculation_xato_uzdark.png) |  |
| 087 | Kalkulyator: tool.lab.dilution | `/tools/tool/tool.lab.dilution` | bo‘sh | expert | [uz.png](087_kalk_dilution_bosh_uz.png) [uzdark.png](087_kalk_dilution_bosh_uzdark.png) |  |
| 088 | Kalkulyator: tool.lab.dilution | `/tools/tool/tool.lab.dilution` | to‘g‘ri kiritish (har maydon «2») | expert | [uz.png](088_kalk_dilution_togri_uz.png) [uzdark.png](088_kalk_dilution_togri_uzdark.png) |  |
| 089 | Kalkulyator: tool.lab.dilution | `/tools/tool/tool.lab.dilution` | xato kiritish (har maydon «0») | expert | [uz.png](089_kalk_dilution_xato_uz.png) [uzdark.png](089_kalk_dilution_xato_uzdark.png) |  |
| 090 | Kalkulyator: tool.lab.solution | `/tools/tool/tool.lab.solution` | bo‘sh | expert | [uz.png](090_kalk_solution_bosh_uz.png) [uzdark.png](090_kalk_solution_bosh_uzdark.png) |  |
| 091 | Kalkulyator: tool.lab.solution | `/tools/tool/tool.lab.solution` | to‘g‘ri kiritish (har maydon «2») | expert | [uz.png](091_kalk_solution_togri_uz.png) [uzdark.png](091_kalk_solution_togri_uzdark.png) |  |
| 092 | Kalkulyator: tool.lab.solution | `/tools/tool/tool.lab.solution` | xato kiritish (har maydon «0») | expert | [uz.png](092_kalk_solution_xato_uz.png) [uzdark.png](092_kalk_solution_xato_uzdark.png) |  |
| 093 | Kalkulyator: tool.lab.percent | `/tools/tool/tool.lab.percent` | bo‘sh | expert | [uz.png](093_kalk_percent_bosh_uz.png) [uzdark.png](093_kalk_percent_bosh_uzdark.png) |  |
| 094 | Kalkulyator: tool.lab.percent | `/tools/tool/tool.lab.percent` | to‘g‘ri kiritish (har maydon «2») | expert | [uz.png](094_kalk_percent_togri_uz.png) [uzdark.png](094_kalk_percent_togri_uzdark.png) |  |
| 095 | Kalkulyator: tool.lab.percent | `/tools/tool/tool.lab.percent` | xato kiritish (har maydon «0») | expert | [uz.png](095_kalk_percent_xato_uz.png) [uzdark.png](095_kalk_percent_xato_uzdark.png) |  |
| 096 | Kalkulyator: tool.lab.molarity | `/tools/tool/tool.lab.molarity` | bo‘sh | expert | [uz.png](096_kalk_molarity_bosh_uz.png) [uzdark.png](096_kalk_molarity_bosh_uzdark.png) |  |
| 097 | Kalkulyator: tool.lab.molarity | `/tools/tool/tool.lab.molarity` | to‘g‘ri kiritish (har maydon «2») | expert | [uz.png](097_kalk_molarity_togri_uz.png) [uzdark.png](097_kalk_molarity_togri_uzdark.png) |  |
| 098 | Kalkulyator: tool.lab.molarity | `/tools/tool/tool.lab.molarity` | xato kiritish (har maydon «0») | expert | [uz.png](098_kalk_molarity_xato_uz.png) [uzdark.png](098_kalk_molarity_xato_uzdark.png) |  |
| 099 | Kalkulyator: tool.lab.calibration | `/tools/tool/tool.lab.calibration` | bo‘sh | expert | [uz.png](099_kalk_calibration_bosh_uz.png) [uzdark.png](099_kalk_calibration_bosh_uzdark.png) |  |
| 100 | Kalkulyator: tool.lab.calibration | `/tools/tool/tool.lab.calibration` | to‘g‘ri kiritish (har maydon «2») | expert | [uz.png](100_kalk_calibration_togri_uz.png) [uzdark.png](100_kalk_calibration_togri_uzdark.png) |  |
| 101 | Kalkulyator: tool.lab.calibration | `/tools/tool/tool.lab.calibration` | xato kiritish (har maydon «0») | expert | [uz.png](101_kalk_calibration_xato_uz.png) [uzdark.png](101_kalk_calibration_xato_uzdark.png) |  |
| 102 | Kalkulyator: tool.lab.lod_loq | `/tools/tool/tool.lab.lod_loq` | bo‘sh | expert | [uz.png](102_kalk_lod_loq_bosh_uz.png) [uzdark.png](102_kalk_lod_loq_bosh_uzdark.png) |  |
| 103 | Kalkulyator: tool.lab.lod_loq | `/tools/tool/tool.lab.lod_loq` | to‘g‘ri kiritish (har maydon «2») | expert | [uz.png](103_kalk_lod_loq_togri_uz.png) [uzdark.png](103_kalk_lod_loq_togri_uzdark.png) |  |
| 104 | Kalkulyator: tool.lab.lod_loq | `/tools/tool/tool.lab.lod_loq` | xato kiritish (har maydon «0») | expert | [uz.png](104_kalk_lod_loq_xato_uz.png) [uzdark.png](104_kalk_lod_loq_xato_uzdark.png) |  |
| 105 | Kalkulyator: tool.lab.descriptive_stats | `/tools/tool/tool.lab.descriptive_stats` | bo‘sh | expert | [uz.png](105_kalk_descriptive_stats_bosh_uz.png) [uzdark.png](105_kalk_descriptive_stats_bosh_uzdark.png) |  |
| 106 | Kalkulyator: tool.lab.descriptive_stats | `/tools/tool/tool.lab.descriptive_stats` | to‘g‘ri kiritish (har maydon «2») | expert | [uz.png](106_kalk_descriptive_stats_togri_uz.png) [uzdark.png](106_kalk_descriptive_stats_togri_uzdark.png) |  |
| 107 | Kalkulyator: tool.lab.descriptive_stats | `/tools/tool/tool.lab.descriptive_stats` | xato kiritish (har maydon «0») | expert | [uz.png](107_kalk_descriptive_stats_xato_uz.png) [uzdark.png](107_kalk_descriptive_stats_xato_uzdark.png) |  |
| 108 | Kalkulyator: tool.conv.concentration_units | `/tools/tool/tool.conv.concentration_units` | bo‘sh | expert | [uz.png](108_kalk_concentration_units_bosh_uz.png) [uzdark.png](108_kalk_concentration_units_bosh_uzdark.png) |  |
| 109 | Kalkulyator: tool.conv.concentration_units | `/tools/tool/tool.conv.concentration_units` | to‘g‘ri kiritish (har maydon «2») | expert | [uz.png](109_kalk_concentration_units_togri_uz.png) [uzdark.png](109_kalk_concentration_units_togri_uzdark.png) |  |
| 110 | Kalkulyator: tool.conv.concentration_units | `/tools/tool/tool.conv.concentration_units` | xato kiritish (har maydon «0») | expert | [uz.png](110_kalk_concentration_units_xato_uz.png) [uzdark.png](110_kalk_concentration_units_xato_uzdark.png) |  |
| 111 | Kalkulyator: tool.conv.ethanol_units | `/tools/tool/tool.conv.ethanol_units` | bo‘sh | expert | [uz.png](111_kalk_ethanol_units_bosh_uz.png) [uzdark.png](111_kalk_ethanol_units_bosh_uzdark.png) |  |
| 112 | Kalkulyator: tool.conv.ethanol_units | `/tools/tool/tool.conv.ethanol_units` | to‘g‘ri kiritish (har maydon «2») | expert | [uz.png](112_kalk_ethanol_units_togri_uz.png) [uzdark.png](112_kalk_ethanol_units_togri_uzdark.png) |  |
| 113 | Kalkulyator: tool.conv.ethanol_units | `/tools/tool/tool.conv.ethanol_units` | xato kiritish (har maydon «0») | expert | [uz.png](113_kalk_ethanol_units_xato_uz.png) [uzdark.png](113_kalk_ethanol_units_xato_uzdark.png) |  |
| 114 | Kalkulyator: tool.lab.beer_lambert | `/tools/tool/tool.lab.beer_lambert` | bo‘sh | expert | [uz.png](114_kalk_beer_lambert_bosh_uz.png) [uzdark.png](114_kalk_beer_lambert_bosh_uzdark.png) |  |
| 115 | Kalkulyator: tool.lab.beer_lambert | `/tools/tool/tool.lab.beer_lambert` | to‘g‘ri kiritish (har maydon «2») | expert | [uz.png](115_kalk_beer_lambert_togri_uz.png) [uzdark.png](115_kalk_beer_lambert_togri_uzdark.png) |  |
| 116 | Kalkulyator: tool.lab.beer_lambert | `/tools/tool/tool.lab.beer_lambert` | xato kiritish (har maydon «0») | expert | [uz.png](116_kalk_beer_lambert_xato_uz.png) [uzdark.png](116_kalk_beer_lambert_xato_uzdark.png) |  |
| 117 | Ekspert ish daftari | `/tools/casebook` | bo‘sh | expert | [uz.png](117_ish_daftari_bosh_uz.png) [uzdark.png](117_ish_daftari_bosh_uzdark.png) |  |
| 118 | Ekspert ish daftari | `/tools/casebook` | yangi yozuv | expert | [uz.png](118_ish_daftari_yangi_uz.png) [uzdark.png](118_ish_daftari_yangi_uzdark.png) |  |
| 119 | Forensic AI | `/ai` | bo‘sh | student | [uz.png](119_ai_bosh_uz.png) [uzdark.png](119_ai_bosh_uzdark.png) [ru.png](119_ai_bosh_ru.png) [en.png](119_ai_bosh_en.png) [uz320.png](119_ai_bosh_uz320.png) |  |
| 120 | Forensic AI | `/ai` | savol + oflayn manbalar (AI serveri yo‘q) | student | [uz.png](120_ai_savol_uz.png) [uzdark.png](120_ai_savol_uzdark.png) [ru.png](120_ai_savol_ru.png) [en.png](120_ai_savol_en.png) [uz320.png](120_ai_savol_uz320.png) |  |
| 121 | Forensic AI | `/ai` | javob uslubi (Qisqa / Batafsil) | student | [uz.png](121_ai_javob_uz.png) [uzdark.png](121_ai_javob_uzdark.png) [ru.png](121_ai_javob_ru.png) [en.png](121_ai_javob_en.png) [uz320.png](121_ai_javob_uz320.png) |  |
| 122 | Forensic AI | `/ai` | shaxsiy ma’lumot ogohlantirishi | student | [uz.png](122_ai_shaxsiy_uz.png) [uzdark.png](122_ai_shaxsiy_uzdark.png) |  |
| 123 | Profil (mehmon) | `/profile` | standart | student | [uz.png](123_profil_uz.png) [uzdark.png](123_profil_uzdark.png) [ru.png](123_profil_ru.png) [en.png](123_profil_en.png) [uz320.png](123_profil_uz320.png) |  |
| 124 | Profil (mehmon) | `/profile` | pastki qism | student | [uz.png](124_profil_pastki_uz.png) [uzdark.png](124_profil_pastki_uzdark.png) |  |
| 125 | Profil (kirgan admin) | `/profile` | standart | admin | [uz.png](125_profil_admin_uz.png) [uzdark.png](125_profil_admin_uzdark.png) |  |
| 126 | Sozlama: til | `/profile/language` | standart | student | [uz.png](126_sozlama_til_uz.png) [uzdark.png](126_sozlama_til_uzdark.png) |  |
| 127 | Sozlama: rejim | `/profile/mode` | standart | student | [uz.png](127_sozlama_rejim_uz.png) [uzdark.png](127_sozlama_rejim_uzdark.png) |  |
| 128 | Sozlama: yurisdiksiya | `/profile/jurisdiction` | standart | student | [uz.png](128_sozlama_yurisdiksiya_uz.png) [uzdark.png](128_sozlama_yurisdiksiya_uzdark.png) |  |
| 129 | Ilmiy ogohlantirish | `/profile/disclaimer` | standart | student | [uz.png](129_sozlama_ogohlantirish_uz.png) [uzdark.png](129_sozlama_ogohlantirish_uzdark.png) |  |
| 130 | Profilni tahrirlash | `/profile/edit` | standart | student | [uz.png](130_profil_tahrir_uz.png) [uzdark.png](130_profil_tahrir_uzdark.png) |  |
| 131 | Maxfiylik siyosati | `/profile/privacy` | standart | student | [uz.png](131_maxfiylik_uz.png) [uzdark.png](131_maxfiylik_uzdark.png) |  |
| 132 | Foydalanish shartlari | `/profile/terms` | standart | student | [uz.png](132_shartlar_uz.png) [uzdark.png](132_shartlar_uzdark.png) |  |
| 133 | Ilova haqida | `/profile/about` | standart | student | [uz.png](133_ilova_haqida_uz.png) [uzdark.png](133_ilova_haqida_uzdark.png) |  |
| 134 | Manbalar va mualliflar | `/profile/about/sources` | standart | student | [uz.png](134_manbalar_mualliflar_uz.png) [uzdark.png](134_manbalar_mualliflar_uzdark.png) |  |
| 135 | AI ogohlantirishi | `/profile/ai-disclaimer` | standart | student | [uz.png](135_ai_ogohlantirish_uz.png) [uzdark.png](135_ai_ogohlantirish_uzdark.png) |  |
| 136 | Professional tasdiqlash | `/profile/verification` | standart | expert | [uz.png](136_tasdiqlash_uz.png) [uzdark.png](136_tasdiqlash_uzdark.png) |  |
| 137 | Tasdiqlash: hujjatlar | `/profile/verification/documents` | standart | expert | [uz.png](137_tasdiqlash_hujjatlar_uz.png) [uzdark.png](137_tasdiqlash_hujjatlar_uzdark.png) |  |
| 138 | Taqriz ish joyi | `/profile/reviews` | standart | expert | [uz.png](138_taqriz_paneli_uz.png) [uzdark.png](138_taqriz_paneli_uzdark.png) |  |
| 139 | Hamkasbni taklif qilish | `/profile/invite` | standart | student | [uz.png](139_taklif_uz.png) [uzdark.png](139_taklif_uzdark.png) |  |
| 140 | Taklif va murojaatlar | `/profile/support` | standart | admin | [uz.png](140_murojaatlar_uz.png) [uzdark.png](140_murojaatlar_uzdark.png) |  |
| 141 | Yangi murojaat | `/profile/support/new` | standart | admin | [uz.png](141_murojaat_yozish_uz.png) [uzdark.png](141_murojaat_yozish_uzdark.png) |  |
| 142 | Murojaat suhbati | `/profile/support/thread/thread-1` | standart | admin | [uz.png](142_murojaat_suhbat_uz.png) [uzdark.png](142_murojaat_suhbat_uzdark.png) |  |
| 143 | Shikoyat yuborish | `/profile/report` | standart | student | [uz.png](143_shikoyat_uz.png) [uzdark.png](143_shikoyat_uzdark.png) |  |
| 144 | Kirish: email kod (Google/Apple tugmalari) | `/profile/account/email` | standart | student | [uz.png](144_kirish_email_kod_uz.png) [uzdark.png](144_kirish_email_kod_uzdark.png) [ru.png](144_kirish_email_kod_ru.png) [en.png](144_kirish_email_kod_en.png) [uz320.png](144_kirish_email_kod_uz320.png) |  |
| 145 | Kirish: email kod | `/profile/account/email` | noto‘g‘ri email xatosi | student | [uz.png](145_kirish_email_kod_notogri_uz.png) [uzdark.png](145_kirish_email_kod_notogri_uzdark.png) |  |
| 146 | Kirish (parol) | `/profile/account/sign-in` | standart | student | [uz.png](146_kirish_parol_uz.png) [uzdark.png](146_kirish_parol_uzdark.png) |  |
| 147 | Ro‘yxatdan o‘tish | `/profile/account/register` | standart | student | [uz.png](147_royxatdan_otish_uz.png) [uzdark.png](147_royxatdan_otish_uzdark.png) |  |
| 148 | Parolni tiklash | `/profile/account/forgot` | standart | student | [uz.png](148_parol_tiklash_uz.png) [uzdark.png](148_parol_tiklash_uzdark.png) |  |
| 149 | Hisobni o‘chirish | `/profile/account/delete` | standart | admin | [uz.png](149_hisobni_ochirish_uz.png) [uzdark.png](149_hisobni_ochirish_uzdark.png) |  |
| 150 | Ekspert maqolalari | `/library/publications` | server ulanmagan | expert | [uz.png](150_maqolalar_server_uz.png) [uzdark.png](150_maqolalar_server_uzdark.png) |  |
| 151 | Maqola yuborish | `/library/publications/submit` | standart | expert | [uz.png](151_maqola_yuborish_uz.png) [uzdark.png](151_maqola_yuborish_uzdark.png) |  |
| 152 | Mening maqolalarim | `/library/publications/mine` | standart | expert | [uz.png](152_maqolalarim_uz.png) [uzdark.png](152_maqolalarim_uzdark.png) |  |
| 153 | Boshqaruv paneli | `/profile/admin` | standart | admin | [uz.png](153_admin_panel_uz.png) [uzdark.png](153_admin_panel_uzdark.png) [ru.png](153_admin_panel_ru.png) [en.png](153_admin_panel_en.png) [uz320.png](153_admin_panel_uz320.png) |  |
| 154 | Admin: murojaatlar qutisi | `/profile/admin/inbox` | standart | admin | [uz.png](154_admin_murojaatlar_uz.png) [uzdark.png](154_admin_murojaatlar_uzdark.png) |  |
| 155 | Admin: murojaat | `/profile/admin/inbox/thread-3` | standart | admin | [uz.png](155_admin_suhbat_uz.png) [uzdark.png](155_admin_suhbat_uzdark.png) |  |
| 156 | Admin: foydalanuvchilar | `/profile/admin/users` | standart | admin | [uz.png](156_admin_foydalanuvchilar_uz.png) [uzdark.png](156_admin_foydalanuvchilar_uzdark.png) |  |
| 157 | Admin: amallar jurnali | `/profile/admin/audit` | standart | admin | [uz.png](157_admin_jurnal_uz.png) [uzdark.png](157_admin_jurnal_uzdark.png) |  |
| 158 | Admin: shikoyatlar | `/profile/admin/reports` | standart | admin | [uz.png](158_admin_shikoyatlar_uz.png) [uzdark.png](158_admin_shikoyatlar_uzdark.png) |  |
| 159 | Admin: tasdiqlash arizalari | `/profile/admin/verifications` | standart | admin | [uz.png](159_admin_tasdiqlash_uz.png) [uzdark.png](159_admin_tasdiqlash_uzdark.png) |  |
| 160 | Admin: maqolalar moderatsiyasi | `/library/publications/moderation` | standart | admin | [uz.png](160_admin_moderatsiya_uz.png) [uzdark.png](160_admin_moderatsiya_uzdark.png) |  |
| 161 | Dialog: ish daftarini tozalash | `/tools/casebook` | standart | expert | [uz.png](161_dialog_daftar_tozalash_uz.png) [uzdark.png](161_dialog_daftar_tozalash_uzdark.png) |  |
| 162 | Bottom sheet: iqtibos (ГОСТ/APA) | `/library/entry/ethanol` | standart | student | [uz.png](162_sheet_iqtibos_uz.png) [uzdark.png](162_sheet_iqtibos_uzdark.png) |  |
| 163 | Snackbar: natija nusxalandi | `/tools/tool/tool.lab.dilution` | standart | expert | [uz.png](163_snackbar_nusxa_uz.png) [uzdark.png](163_snackbar_nusxa_uzdark.png) |  |
| 164 | Dialog: sinfni tugatish | `/class-host` | standart | student | [uz.png](164_dialog_ustoz_tugatish_uz.png) [uzdark.png](164_dialog_ustoz_tugatish_uzdark.png) |  |
