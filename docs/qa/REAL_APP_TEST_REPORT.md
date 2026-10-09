# Real-ilova test hisoboti — TALABA va MUTAXASSIS (2026-10-09)

## 1. Nima ishga tushirildi

| | |
|---|---|
| Usul | Flutter `integration_test`, **Linux desktop** (`flutter test integration_test/... -d linux`), Xvfb virtual ekrani, debug yig‘ma |
| Ilova | Haqiqiy `bootstrap()` (ilovaning `main()` bilan bir xil yo‘l), haqiqiy imzolangan pilot kontent paketi (`assets/content/pilot`, SQLite/drift), haqiqiy go_router, haqiqiy shriftlar va dvigatel chizgan kadrlar |
| Akkaunt | **MOCK** (`FE_AUTH_MODE=mock`): xotirada, xat yuborilmaydi; OTP kodi MOCK “pochta qutisi”dan olinadi |
| Ekspert maqolalari | Xotiradagi soxta server (`QaPublicationService`, `integration_test/qa/qa_env.dart`) — `bootstrap(testOverrides:)` orqali |
| Tarmoq | **O‘chirilgan**: `HttpOverrides` har bir HTTP ulanishni rad etadi. Yig‘mada `FE_SUPABASE_*`, `FE_AUTH_BASE_URL`, `FE_AI_REMOTE` yo‘q — production Supabase’ga hech narsa yuborilmadi (bloklangan urinishlar soni: 0) |
| Ekran | 390×844 (asosiy) va 320×640 (kichik ekran tekshiruvi), DPR 1 |
| Tekshiruvlar | Har qadamda: tugma/sahifa ochildimi (kutilgan matn), Flutter xatolari (overflow va h.k. — testni yiqitmay yig‘iladi), uz rejimida inglizcha UI so‘zi / xom kod qidiruvi, skrinshot |
| Ishga tushirish | `./tool/qa_real_app.sh` (README → «Real-ilova QA») |
| Vaqt | ikkala rol ~4 daqiqa (issiq build) |

**Nega web emas:** ilova kontent bazasini `NativeDatabase(File(...))` bilan
ochadi (dart:io fayl yo‘li) — web’da ishlamaydi; web uchun alohida build
bayrog‘i yo‘q. Linux desktop esa haqiqiy native SQLite, fayl tizimi va
dvigatel bilan ishlaydi (kerakli paketlar: `libgtk-3-dev`, `libsecret-1-dev`,
`xvfb`). Shu sababli Playwright ishlatilmadi.

## 2. Natija

| Rol | Qadamlar | PASS | FAIL | Skrinshot |
|---|---|---|---|---|
| Talaba | 39 | 39 | 0 | 33 |
| Mutaxassis | 34 | 34 | 0 | 27 |

Bu — tuzatishlardan **keyingi** regressiya yugurishi. Birinchi yugurishlarda
topilgan xatolar 4-bo‘limda. Skrinshotlar: [`real_app_20261009/`](real_app_20261009/)
(60 ta PNG, har biri ≤ 116 KB, jami 3,8 MB); xom natija:
`results_student.json`, `results_expert.json`.

### 2.1. TALABA

| # | Qadam | Natija | Skrinshot |
|---|---|---|---|
| s01 | Onboarding: til tanlash ekrani | PASS | [s01](real_app_20261009/s01_onboarding_til_tanlash_ekrani.png) |
| s02 | O‘zbekcha → Davom etish → ilmiy ogohlantirish | PASS | [s02](real_app_20261009/s02_o_zbekcha_davom_etish_ilmiy_ogohlantiris.png) |
| s03 | Tushundim → rejim tanlash | PASS | — |
| s04 | Rejim: Talaba → hisob taklifi | PASS | [s04](real_app_20261009/s04_rejim_talaba_hisob_taklifi.png) |
| s05 | Hisobsiz davom etish → Asosiy | PASS | [s05](real_app_20261009/s05_hisobsiz_davom_etish_asosiy.png) |
| s06 | AI ekrani — hisobsiz | PASS | [s06](real_app_20261009/s06_ai_ekrani_hisobsiz.png) |
| s07 | Profil → Kirish (email kod), «SINOV» belgisi | PASS | [s07](real_app_20261009/s07_profil_kirish_email_kod.png) |
| s08 | Noto‘g‘ri email → «To‘g‘ri elektron pochta manzilini kiriting.» | PASS | [s08](real_app_20261009/s08_noto_g_ri_email_tushunarli_xato.png) |
| s09 | To‘g‘ri email → kod kiritish ekrani | PASS | — |
| s10 | Noto‘g‘ri kod → «Kod noto‘g‘ri.» | PASS | [s10](real_app_20261009/s10_noto_g_ri_kod_tushunarli_xato.png) |
| s11 | To‘g‘ri kod → tizimga kirildi (profilda o‘z emaili) | PASS | [s11](real_app_20261009/s11_to_g_ri_kod_tizimga_kirildi.png) |
| s12 | AI — kirgan holat, «Manbalarni oflayn topish» (etanol) | PASS | [s12](real_app_20261009/s12_ai_ekrani_kirgan_holat_oflayn_manbalar.png) |
| s13 | Fanni tanlash: Barcha fanlar → Sud toksikologiyasi | PASS | [s13](real_app_20261009/s13_fanni_tanlash_barcha_fanlar_sud_toksikol.png) |
| s14 | Kutubxona markazi | PASS | — |
| s15 | Yo‘riqnomalar ro‘yxati | PASS | [s15](real_app_20261009/s15_yo_riqnomalar_ro_yxati.png) |
| s16 | Yo‘riqnoma kartasi (etanol, HS-GC-FID) | PASS | [s16](real_app_20261009/s16_yo_riqnoma_kartasini_ochish_etanol_hs_gc.png) |
| s17 | Moddalar → Etanol (Tahlil bo‘limi) | PASS | [s17](real_app_20261009/s17_moddalar_etanol_tahlil_bo_limi.png) |
| s18 | Manba iqtibosi + o‘zbekcha tarjima, «§ Kirish» | PASS | [s18](real_app_20261009/s18_manba_iqtibosi_o_zbekcha_tarjima.png) |
| s19 | Saralanganlarga qo‘shish (yulduzcha) | PASS | [s19](real_app_20261009/s19_saralanganlarga_qo_shish_yulduzcha.png) |
| s20 | «Bu ma’lumot qayerdan?» — kelib chiqish oynasi | PASS | [s20](real_app_20261009/s20_bu_ma_lumot_qayerdan_kelib_chiqish_oynas.png) |
| s21 | Qidiruv «alkogol» (kirill/inglizcha sarlavha yo‘q) | PASS | [s21](real_app_20261009/s21_qidiruv_alkogol.png) |
| s22 | Qidiruv «etanol qon» (yo‘riqnoma ham chiqadi) | PASS | [s22](real_app_20261009/s22_qidiruv_etanol_qon_yo_riqnoma_ham_chiqad.png) |
| s23 | Qidiruv: fan filtri (Sud toksikologiyasi) | PASS | — |
| s24 | Qidiruv: natija yo‘q — tushunarli xabar | PASS | [s24](real_app_20261009/s24_qidiruv_natija_yo_q_tushunarli_xabar.png) |
| s25 | Saqlanganlar Asosiy ekranda | PASS | [s25](real_app_20261009/s25_saqlanganlar_asosiy_ekranda_ko_rinadi.png) |
| s26 | Pro modda (Alprazolam) — qulf kartasi | PASS | [s26](real_app_20261009/s26_pro_modda_alprazolam_qulf_kartasi.png) |
| s27 | Tariflarni ko‘rish → paywall | PASS | [s27](real_app_20261009/s27_tariflarni_ko_rish_paywall.png) |
| s28 | Paywall: do‘kon yo‘q — xarid tugmasi o‘chiq, sabab yozilgan | PASS | [s28](real_app_20261009/s28_paywall_do_kon_yo_q_narx_xarid_o_chiq_xa.png) |
| s29 | Profil va sozlamalar (boshqa foydalanuvchi emaili yo‘q) | PASS | [s29](real_app_20261009/s29_profil_va_sozlamalar.png) |
| s30 | Profilni to‘ldirish (ism + davlat) → saqlandi | PASS | [s30](real_app_20261009/s30_profilni_to_ldirish_talaba.png) |
| s31 | Til: English | PASS | [s31](real_app_20261009/s31_til_english.png) |
| s32 | Til: Русский | PASS | [s32](real_app_20261009/s32_til.png) |
| s33 | Til: O‘zbekcha (qaytish) | PASS | — |
| s34 | 320×640: Asosiy | PASS | [s34](real_app_20261009/s34_320_640_asosiy.png) |
| s35 | 320×640: Etanol yozuvi | PASS | [s35](real_app_20261009/s35_320_640_etanol_yozuvi.png) |
| s36 | 320×640: qidiruv «alkogol» | PASS | [s36](real_app_20261009/s36_320_640_qidiruv_alkogol.png) |
| s37 | 320×640: tariflar | PASS | [s37](real_app_20261009/s37_320_640_tariflar.png) |
| s38 | 320×640: Profil | PASS | [s38](real_app_20261009/s38_320_640_profil.png) |
| s39 | Tarmoq o‘chiq: hech bir HTTP so‘rov o‘tmadi | PASS | — |

### 2.2. MUTAXASSIS

| # | Qadam | Natija | Skrinshot |
|---|---|---|---|
| e01 | Onboarding: O‘zbekcha + ogohlantirish | PASS | [e01](real_app_20261009/e01_onboarding_o_zbekcha_ogohlantirish.png) |
| e02 | Rejim: Mutaxassis + rol (Sud toksikologi) | PASS | [e02](real_app_20261009/e02_rejim_mutaxassis_rol_sud_toksikologi.png) |
| e03 | Davom etish → Hisob yaratish / Kirish | PASS | — |
| e04 | MOCK OTP bilan kirish | PASS | [e04](real_app_20261009/e04_mock_otp_bilan_kirish.png) |
| e05 | Profil 1-qadam (ism, davlat) | PASS | [e05](real_app_20261009/e05_profil_1_qadam_ism_davlat.png) |
| e06 | Profil 2-qadam — tashkilot, lavozim, asosiy ixtisoslik | PASS | [e06](real_app_20261009/e06_profil_2_qadam_ixtisoslik_sud_toksikolog.png) |
| e07 | Profil 3-qadam → Saqlash | PASS | [e07](real_app_20261009/e07_profil_3_qadam_saqlash.png) |
| e08 | Professional maqomni tasdiqlash (server ulanmagan — halol xabar) | PASS | [e08](real_app_20261009/e08_professional_maqomni_tasdiqlash_server_y.png) |
| e09 | Fanlar → Sud kimyosi | PASS | [e09](real_app_20261009/e09_fanlar_sud_kimyosi.png) |
| e10 | Kutubxona → Usullar va SOP | PASS | — |
| e11 | Usul yozuvi (bug‘ fazali GX) | PASS | [e11](real_app_20261009/e11_usul_yozuvini_ochish_gx.png) |
| e12 | Yo‘riqnoma: preanalitika kartasi | PASS | [e12](real_app_20261009/e12_yo_riqnoma_preanalitika_kartasi.png) |
| e13 | Etanol → «Bu ma’lumot qayerdan?» (manba, murojaat sanasi) | PASS | [e13](real_app_20261009/e13_etanol_bu_ma_lumot_qayerdan.png) |
| e14 | Ekspert maqolalari ro‘yxati | PASS | [e14](real_app_20261009/e14_ekspert_maqolalari_ro_yxati.png) |
| e15 | Maqolani ochish | PASS | [e15](real_app_20261009/e15_maqolani_ochish.png) |
| e16 | Bo‘sh forma: yuborish tugmasi o‘chiq, talablar yozilgan | PASS | [e16](real_app_20261009/e16_maqola_yuborish_bo_sh_forma_xato.png) |
| e17 | To‘ldirish (sarlavha, annotatsiya, fan) → «Qoralama saqlandi.» | PASS | [e17](real_app_20261009/e17_maqola_to_ldirish_qoralama_saqlash.png) |
| e18 | Tasdiqlarsiz yuborish → yuborilmaydi | PASS | — |
| e19 | 3 tasdiq → yuborildi → «Mening maqolalarim» (Yuborilgan) | PASS | [e19](real_app_20261009/e19_maqola_3_tasdiq_yuborish_mening_maqolala.png) |
| e20 | Qidiruv «etanol qon» (ruscha sarlavha yo‘q) | PASS | [e20](real_app_20261009/e20_qidiruv_etanol_qon.png) |
| e21 | Qidiruv «HS-GC» | PASS | — |
| e22 | AI: oflayn manbalar «metanol» | PASS | [e22](real_app_20261009/e22_ai_oflayn_manbalar_metanol.png) |
| e23 | Vositalar ro‘yxati | PASS | — |
| e24 | Suyultirish: C₁=10, C₂=1, V₂=100 → V₁=10,0 mL | PASS | [e24](real_app_20261009/e24_suyultirish_c_10_c_1_v_100_v_10.png) |
| e25 | Mantiqsiz kiritish (C₂ > C₁) → ogohlantirish | PASS | [e25](real_app_20261009/e25_suyultirish_mantiqsiz_kiritish_c_c_ogohl.png) |
| e26 | Pro kalkulyator (Widmark) → tariflar | PASS | [e26](real_app_20261009/e26_pro_kalkulyator_widmark_tariflar.png) |
| e27 | Profil va sozlamalar | PASS | [e27](real_app_20261009/e27_profil_va_sozlamalar_mutaxassis.png) |
| e28 | Til: Русский | PASS | [e28](real_app_20261009/e28_til.png) |
| e29 | Til: O‘zbekcha (qaytish) | PASS | — |
| e30 | 320×640: Vositalar | PASS | [e30](real_app_20261009/e30_320_640_vositalar.png) |
| e31 | 320×640: maqola yuborish formasi | PASS | [e31](real_app_20261009/e31_320_640_maqola_yuborish_formasi.png) |
| e32 | 320×640: yo‘riqnomalar | PASS | [e32](real_app_20261009/e32_320_640_yo_riqnomalar.png) |
| e33 | 320×640: profil tahrirlash | PASS | [e33](real_app_20261009/e33_320_640_profil_tahrirlash.png) |
| e34 | Tarmoq o‘chiq: oflayn ishladi | PASS | — |

Kichik ekran (320×640) va 390×844 qadamlarida birorta ham overflow yoki
boshqa Flutter render xatosi qayd etilmadi.

## 3. Til tekshiruvi (uz rejimi)

Avtomatik tekshiruv har ekranda inglizcha UI so‘zlari va xom kodlarni
qidirdi. Tuzatishlardan keyin qolgan yagona belgi — jurnal nomi
(«The journal of the American Academy of Psychiatry…»): bibliografik
ma’lumot, ataylab asl tilda (xato emas). Manba iqtiboslari ham ataylab
inglizcha (asl dalil), ostida «Avtomatik tarjima · tekshirilmagan»
belgili o‘zbekcha tarjima bor.

## 4. Topilgan xatolar

### Tuzatildi (kod + regressiya yugurishida tekshirildi)

| # | Xato | Qayerda | Tuzatish |
|---|---|---|---|
| 1 | uz rejimida qidiruv natijasi **boshqa tildagi sarlavha** bilan chiqardi: «alkogol» → «Алкоголь в крови (Видмарк)», «Ethanol back-calculation»; «etanol qon» → «Место забора (…)» | `search_screen.dart` | Vositalar nomi doim joriy tilda; moslik yozuv nomining boshqa tildagi tarjimasi bo‘lsa — joriy tildagi nom (sinonim mosligi avvalgidek ko‘rinadi) |
| 2 | Yo‘riqnoma kalit so‘z bo‘yicha topilganda qator sarlavhasi shunchaki «alkogol», «etanol» edi — qaysi yo‘riqnoma ekanini bilib bo‘lmasdi | `search_screen.dart` | Yo‘riqnoma qatorida doim uning sarlavhasi |
| 3 | Moddalar ro‘yxati uz rejimida **inglizcha nom** bo‘yicha tartiblangan («Margimush trioksidi» «Amfetamin»dan keyin, «Uglerod monoksidi» «K» harfida) | `library_screen.dart` | Moddalar joriy tildagi nom bo‘yicha alifbo tartibida |
| 4 | Manba joyi xom inglizcha izoh bilan chiqardi: «§ (untitled opening section, before 'ADH Variants')»; «1. Introduction» ham tarjima qilinmasdi | `source_quote.dart` | «§ Kirish»; raqamli standart bo‘lim nomlari ham lokallashtiriladi (unit test yangilandi) |
| 5 | Har bir modda sahifasida tuzilma rasmi atribusiyasi inglizcha: «Structure drawn from PubChem CID 702 SMILES with RDKit»; sxemalarda «Original schematic — FORENSIC EXPERT» | `scientific_image.dart`, ARB (`tool/l10n_qa_fixes.py`) | Standart shablonlar uz/ru/en’da; muallif atribusiyalari o‘zgarmaydi (unit test qo‘shildi) |

### Tuzatilmadi (kontent yoki kattaroq ish — BACKLOG uchun)

| # | Kuzatuv | Sabab |
|---|---|---|
| 6 | Metabolit nomlari uz rejimida inglizcha: «acetaldehyde», «acetate», «acetyl-CoA» (Etanol → Metabolitlar) | Kontent paketidagi atama tarjimasi yo‘q (term_translations) — kontent ishi |
| 7 | Qidiruvda ba’zi namuna nomlari inglizcha («Gastric contents») | Kontent tarjimasi |
| 8 | Usul sxemasidagi rasm ichidagi yozuvlar inglizcha («Headspace GC — workflow», «Sealed vial»…) | Rasm faylining o‘zi — qayta chizish kerak |
| 9 | AI «Manbalarni oflayn topish» natijalarida iqtibos faqat inglizcha (yozuv sahifasidagi tarjima bu yerda ko‘rsatilmaydi), manba kodi xom ko‘rinishda («SRC-PMC10972208») | Kichik UX yaxshilash; AI ekrani boshqa ish oqimida |
| 10 | «Bu ma’lumot qayerdan?» oynasida: «Manba litsenziyasi … iqtibos ko‘rsatilmaydi» va shu manbada «Ochiq foydalanish» belgisi yonma-yon — foydalanuvchini chalkashtirishi mumkin | `provenance_widgets.dart` (boshqa agent ishlayapti) — tekshirish tavsiya etiladi |
| 11 | Kalkulyatorda ichki modul kodi ko‘rinadi: «lab.dilution.c1v1 · v1.0.0» | Ataylab (hisob-kitobni takrorlash uchun iz) — o‘zgartirilmadi |
| 12 | Profil formasida majburiy maydon (Davlat) to‘ldirilmasa, xabar faqat pastda («Belgilangan maydonlarni to‘g‘rilang.»), sahifa xatoli maydonga aylanmaydi | Kichik UX; feature-freeze sababli qoldirildi |
| 13 | AI xizmati yo‘q yig‘mada sarlavha «AI vaqtincha ishlamayapti» — aslida bu yig‘mada ulanmagan | Matn qarori (ilgari tanlangan) — o‘zgartirilmadi |

## 5. Bu yerda TEKSHIRILMAGAN narsalar

Quyidagilar **sinovdan o‘tkazilmagan** — bu hisobot ularni qamramaydi:

- Haqiqiy iOS/Android qurilma (sensorli ekran, tizim klaviaturasi, «orqaga»
  imo-ishorasi, xavfsiz hudud, haqiqiy DPR). Sinov Linux desktop + Xvfb’da.
- Haqiqiy OTP xat (Supabase Auth, email yetkazilishi) — MOCK backend ishlatildi.
- Haqiqiy Supabase (RLS, Edge Function’lar, `identity_admin`, referral server
  qismi, professional tasdiqlash, maqolalar serveri) — maqolalar uchun
  xotiradagi soxta servis.
- Gemini AI’ning haqiqiy javobi va iqtiboslari — yig‘mada AI o‘chiq; faqat
  «AI ishlamayapti» holati va oflayn manbalar qidiruvi tekshirildi.
  «Kirmagan / kirgan» AI holatlari bu yig‘mada bir xil ko‘rinadi.
- In-app xaridlar (App Store / Google Play), obuna tiklash, narxlar — do‘kon
  yo‘q; faqat «Pro» qulfi va tariflar sahifasining do‘konsiz holati.
- Haqiqiy tarmoq uzilishi o‘rtasidagi xatti-harakat (masalan, kirish
  paytida tarmoq yo‘qolishi) — tarmoq butun sinov davomida o‘chiq edi.
- Release yig‘ma (`kReleaseMode`), imzolangan store build’lar, ishlash
  tezligi o‘lchovlari.
- Ekran o‘quvchisi (TalkBack/VoiceOver) va katta shrift masshtabi — bu
  harness’da emas (mavjud `test/a11y` testlari qamraydi).
- Qorong‘i mavzu va yuqori kontrast — bu yugurishda tekshirilmadi.

## 6. Qayta ishga tushirish

```bash
./tool/qa_real_app.sh          # docs/qa/real_app_YYYYMMDD/ ga yozadi
```

Fayllar: `integration_test/qa_student_test.dart`,
`integration_test/qa_expert_test.dart`, `integration_test/qa/harness.dart`
(qadam, skrinshot, til va overflow tekshiruvi), `integration_test/qa/qa_env.dart`
(ishga tushirish, tarmoqni o‘chirish, soxta maqolalar serveri),
`integration_test/qa_probe_test.dart` (yangi yo‘llarni o‘rganish uchun).
CI’ga ulanmagan: toza Ubuntu runner’da apt paketlari + Linux build bilan
~5 daqiqadan oshadi; qo‘lda ishga tushiriladi.
