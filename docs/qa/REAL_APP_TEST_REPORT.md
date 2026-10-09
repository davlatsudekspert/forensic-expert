# Real-ilova test hisoboti — TALABA, MUTAXASSIS va ADMIN (2026-10-09)

Uch xil sinov turi aniq ajratilgan:

| Belgi | Ma’nosi |
|---|---|
| **REAL ILOVA** | Haqiqiy ilova, Linux desktop (Xvfb), MOCK backend (xotiradagi soxta servislar, tarmoq o‘chiq) |
| **SQL (lokal PG)** | Supabase migratsiyalari lokal PostgreSQL 16’da, avtomatik SQL testlari (`supabase/tests/`) |
| **TEKSHIRILMAGAN** | Bu yerda sinalmagan (5-bo‘lim): haqiqiy iOS/Android qurilma, haqiqiy Supabase, haqiqiy OTP xat, push |

## 1. Nima ishga tushirildi

| | |
|---|---|
| Usul | Flutter `integration_test`, **Linux desktop** (`flutter test integration_test/... -d linux`), Xvfb virtual ekrani, debug yig‘ma |
| Ilova | Haqiqiy `bootstrap()` (ilovaning `main()` bilan bir xil yo‘l), haqiqiy imzolangan pilot kontent paketi (`assets/content/pilot`, SQLite/drift), haqiqiy go_router, haqiqiy shriftlar va dvigatel chizgan kadrlar |
| Akkaunt | **MOCK** (`FE_AUTH_MODE=mock`): xotirada, xat yuborilmaydi; OTP kodi MOCK “pochta qutisi”dan olinadi |
| Ekspert maqolalari | Xotiradagi soxta server (`QaPublicationService`, `integration_test/qa/qa_env.dart`) — `bootstrap(testOverrides:)` orqali |
| Murojaatlar / admin | Xotiradagi `InMemorySupportService` (admin javobi `simulateAdminReply` bilan taqlid); admin huquqi — soxta «server» `my_access` javobi (`QaAccountService(admin: true)`), email’dan emas. Skrinshot tanlash: tizim fayl dialogi (GTK) Xvfb’da boshqarilmaydi — `QaImagePicker` haqiqiy PNG baytlarini qaytaradi |
| Tarmoq | **O‘chirilgan**: `HttpOverrides` har bir HTTP ulanishni rad etadi. Yig‘mada `FE_SUPABASE_*`, `FE_AUTH_BASE_URL`, `FE_AI_REMOTE` yo‘q — production Supabase’ga hech narsa yuborilmadi (bloklangan urinishlar soni: 0) |
| Ekran | 390×844 (asosiy) va 320×640 (kichik ekran tekshiruvi), DPR 1 |
| Tekshiruvlar | Har qadamda: tugma/sahifa ochildimi (kutilgan matn), Flutter xatolari (overflow va h.k. — testni yiqitmay yig‘iladi), uz rejimida inglizcha UI so‘zi / xom kod qidiruvi, skrinshot |
| Ishga tushirish | `./tool/qa_real_app.sh` (README → «Real-ilova QA») |
| Vaqt | uchala rol ~6 daqiqa (issiq build) |

**Nega web emas:** ilova kontent bazasini `NativeDatabase(File(...))` bilan
ochadi (dart:io fayl yo‘li) — web’da ishlamaydi; web uchun alohida build
bayrog‘i yo‘q. Linux desktop esa haqiqiy native SQLite, fayl tizimi va
dvigatel bilan ishlaydi (kerakli paketlar: `libgtk-3-dev`, `libsecret-1-dev`,
`xvfb`). Shu sababli Playwright ishlatilmadi.

## 2. Natija

| Rol | Qadamlar | PASS | FAIL | Skrinshot |
|---|---|---|---|---|
| Talaba (REAL ILOVA) | 49 | 49 | 0 | 40 |
| Mutaxassis (REAL ILOVA) | 37 | 37 | 0 | 30 |
| Admin (REAL ILOVA) | 23 | 23 | 0 | 15 |
| RLS rol matritsasi (SQL, lokal PG) | 716 tekshiruv | 716 | 0 | — |

Bu — tuzatishlardan **keyingi** regressiya yugurishi. Birinchi yugurishlarda
topilgan xatolar 4-bo‘limda. Skrinshotlar: [`real_app_20261009/`](real_app_20261009/)
(85 ta PNG: avvalgi 60 + murojaatlar/admin uchun 25 ta yangi, har biri
≤ 120 KB); xom natija: `results_student.json`, `results_expert.json`,
`results_admin.json`. Eslatma: s01–s38 / e01–e33 skrinshotlari avvalgi
yugurishdan (o‘sha qadamlar bu yugurishda ham PASS; murojaatlar xizmati
yoqilgani uchun Profil sahifasida «Taklif va murojaatlar» qatori qo‘shimcha
ko‘rinadi, boshqa farq yo‘q).

### 2.1. TALABA — REAL ILOVA

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
| | **«Taklif va murojaatlar» (yangi)** | | |
| s39 | Profil → «Taklif va murojaatlar» (bo‘sh ro‘yxat) | PASS | [s39](real_app_20261009/s39_profil_taklif_va_murojaatlar_bo_sh_ro_yx.png) |
| s40 | Yangi murojaat: bo‘sh forma → validatsiya | PASS | — |
| s41 | TAKLIF: mavzu, xabar, skrinshot biriktirish | PASS | [s41](real_app_20261009/s41_taklif_mavzu_xabar_skrinshot_biriktirish.png) |
| s42 | Rozilik + Yuborish → chat ochiladi | PASS | [s42](real_app_20261009/s42_rozilik_yuborish_chat_ochiladi.png) |
| s43 | Ro‘yxatda: holat «Yangi» | PASS | — |
| s44 | Admin javobi (simulyatsiya) → Profil belgisi + banner | PASS | [s44](real_app_20261009/s44_admin_javobi_simulyatsiya_profil_belgisi.png) |
| s45 | Boshqa tabda pastki banner | PASS | [s45](real_app_20261009/s45_boshqa_tabda_pastki_banner.png) |
| s46 | Banner → murojaat: javob chatda, holat yangilandi | PASS | [s46](real_app_20261009/s46_banner_murojaat_javob_chatda_holat_yangi.png) |
| s47 | Foydalanuvchi yana yozadi → holat «Yangi» | PASS | — |
| s48 | Talaba /admin marshrutlarini ocha olmaydi | PASS | [s48](real_app_20261009/s48_talaba_admin_marshrutlarini_ocha_olmaydi.png) |
| s49 | Tarmoq o‘chiq: hech bir HTTP so‘rov muvaffaqiyatli emas | PASS | — |

### 2.2. MUTAXASSIS — REAL ILOVA

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
| | **«Xato haqida xabar berish» (yangi)** | | |
| e34 | Etanol sahifasi → ⋮ → «Xato haqida xabar berish» | PASS | [e34](real_app_20261009/e34_etanol_sahifasi_xato_haqida_xabar_berish.png) |
| e35 | SCIENTIFIC_ERROR: xabar + rozilik → yuborish | PASS | [e35](real_app_20261009/e35_scientific_error_xabar_rozilik_yuborish.png) |
| e36 | Admin javobi (simulyatsiya) → chatda ko‘rinadi | PASS | [e36](real_app_20261009/e36_admin_javobi_simulyatsiya_chatda_ko_rina.png) |
| e37 | Tarmoq o‘chiq: oflayn ishladi | PASS | — |

### 2.3. ADMIN (identity_admin) — REAL ILOVA

Admin huquqi faqat soxta «server» javobidan (`my_access.is_admin = true`);
bu UI sinovi. Serverdagi haqiqiy cheklovlar 2.4-bo‘limda (SQL).
Statistika — FIXTURE (`qaAdminStats`, haqiqiy ma’lumot emas), 28 ta
murojaat (25 ta to‘ldiruvchi — sahifalash uchun), 30 ta foydalanuvchi.

| # | Qadam | Natija | Skrinshot |
|---|---|---|---|
| a01 | Onboarding → MOCK OTP bilan kirish | PASS | — |
| a02 | Profil: «Boshqaruv paneli» qatori (server is_admin) | PASS | [a02](real_app_20261009/a02_profil_boshqaruv_paneli_qatori_server_is.png) |
| a03 | Boshqaruv paneli: statistika (FIXTURE) | PASS | [a03](real_app_20261009/a03_boshqaruv_paneli_statistika_fixture.png) |
| a04 | Panel: davlatlar va 14 kunlik grafik | PASS | — |
| a05 | Murojaatlar qutisi: «Javob kutmoqda» | PASS | [a05](real_app_20261009/a05_murojaatlar_qutisi_javob_kutmoqda.png) |
| a06 | Inbox: turkum «Ilmiy xato» | PASS | — |
| a07 | Inbox: qidiruv «user03» + holat filtrlari | PASS | — |
| a08 | Murojaatni ochish (muallif, bog‘liq yozuv nomi) | PASS | [a08](real_app_20261009/a08_murojaatni_ochish_muallif_bog_liq_yozuv_.png) |
| a09 | «Javob yozish» → javob yuborildi | PASS | [a09](real_app_20261009/a09_javob_yozish_javob_yuborildi.png) |
| a10 | Holat → «Yakunlandi» | PASS | [a10](real_app_20261009/a10_holat_yakunlandi.png) |
| a11 | Inbox: yopilgan murojaat «Javob kutmoqda»da yo‘q | PASS | — |
| a12 | Foydalanuvchilar: 1-sahifa (25/30) | PASS | [a12](real_app_20261009/a12_foydalanuvchilar_1_sahifa_25_30.png) |
| a13 | Foydalanuvchilar: «Keyingi» → 2-sahifa | PASS | — |
| a14 | Foydalanuvchilar: qidiruv + rol/tarif filtri | PASS | [a14](real_app_20261009/a14_foydalanuvchilar_qidiruv_rol_tarif_filtr.png) |
| a15 | Amallar jurnali (javob, holat, ochish) | PASS | [a15](real_app_20261009/a15_amallar_jurnali_javob_holat_ochish.png) |
| a16 | RU: панель и обращения | PASS | [a16](real_app_20261009/a16_ru.png) |
| a17 | EN: audit log and users | PASS | [a17](real_app_20261009/a17_en_audit_log_and_users.png) |
| a18 | Til: O‘zbekcha (qaytish) | PASS | — |
| a19 | 320×640: boshqaruv paneli | PASS | [a19](real_app_20261009/a19_320_640_boshqaruv_paneli.png) |
| a20 | 320×640: murojaatlar qutisi | PASS | [a20](real_app_20261009/a20_320_640_murojaatlar_qutisi.png) |
| a21 | 320×640: murojaat (admin) | PASS | [a21](real_app_20261009/a21_320_640_murojaat_admin.png) |
| a22 | 320×640: foydalanuvchilar | PASS | [a22](real_app_20261009/a22_320_640_foydalanuvchilar.png) |
| a23 | Tarmoq o‘chiq: hech bir HTTP so‘rov muvaffaqiyatli emas | PASS | — |

Til: uz qadamlarida inglizcha UI so‘zi / xom kod topilmadi (a01–a15,
a18–a22); ru (a16) va en (a17) ekranlari qisqa tekshirildi.

### 2.4. RLS rol matritsasi — SQL (lokal PostgreSQL 16)

Fayl: `supabase/tests/rls_role_matrix_test.sql` (`run_local.sh` va CI
`db-security` ishida). **Alohida toza bazada**: `stubs.sql` +
`stubs_supabase_defaults.sql` (Supabase’dagidek: `public` jadvallariga
anon/authenticated’ga ALL — shunda faqat RLS va migratsiyadagi REVOKE’lar
himoya qiladi) + barcha migratsiyalar. Natija: **716 tekshiruv, 0 FAIL**;
qolgan 5 ta SQL fayl ham PASS (`ALL … TESTS PASSED`, jami 969 PASS qatori).

Rollar: **anon** (kirmagan), **STUDENT** (oddiy authenticated),
**EXPERT** (professional_profiles + `VERIFIED_PROFESSIONAL` + hujjat +
Pro grant), **MODERATOR** (`publication_moderator`, admin EMAS),
**ADMIN** (`identity_admin`).

| Tekshiruv | anon | STUDENT | EXPERT | MODERATOR | ADMIN |
|---|---|---|---|---|---|
| 29 jadval (public + private): boshqaning qatorlarini SELECT | yo‘q | yo‘q | yo‘q | yo‘q | yo‘q¹ |
| 29 jadval: INSERT (`42501`) | rad | rad² | rad² | rad² | rad² |
| 29 jadval: boshqaning qatorlarini UPDATE / DELETE | 0 qator | 0 qator | 0 qator | 0 qator | 0 qator |
| support_threads / support_messages (to‘g‘ridan) | rad | rad | rad | rad | rad (faqat RPC) |
| Soxta admin xabari (`sender_role='ADMIN'`) INSERT | rad | rad | rad | rad | rad |
| storage `support-attachments`: o‘qish | yo‘q | faqat o‘zi | faqat o‘zi | yo‘q | hammasi (o‘qish) |
| storage: boshqa papkaga yuklash / o‘chirish / nomini o‘zgartirish | rad | rad | rad | rad | rad |
| Murojaat RPC: boshqaning murojaatini ochish / yozish / o‘qildi | rad | rad (`NOT_FOUND`) | rad | rad | ruxsat (audit) |
| Admin RPC (stats, dashboard, inbox, reply, status, users, audit, set_access) | rad | rad | rad | rad | ruxsat |
| account_roles: o‘ziga/boshqaga rol berish yoki olish | rad | rad | rad | rad | **rad** (faqat SQL konsol) |
| access_grants: to‘g‘ridan Pro berish | rad | rad | rad (o‘zinikini ham o‘qiy olmaydi) | rad | rad (faqat `admin_set_access`) |
| ai_usage | rad | o‘zini o‘qish/qo‘shish; o‘chirish/orqaga surish rad | xuddi shunday | xuddi shunday | boshqalarniki yo‘q |
| email_otp_codes | rad | rad | rad | rad | rad |
| referral_* (codes, referrals, rewards, config, private) | rad | rad | rad | rad | rad |
| award_referral_reward / set_referral_reward_status | rad | rad | rad | rad | rad (faqat service_role) |
| Publications: jadval to‘g‘ridan | rad | rad | rad | rad | rad |
| Publications: boshqaning qoralamasini tahrirlash | rad | rad | — | — | — |
| moderation_queue / moderate_publication | rad | rad | rad (o‘zinikini ham) | ruxsat | ruxsat |
| verification: o‘zini tasdiqlash / holatni o‘zgartirish | rad | rad | rad | rad | rad (faqat `decide_identity`) |
| private.admin_audit o‘qish/o‘chirish, admin_settings (MFA) o‘zgartirish | rad | rad | rad | rad | **rad** |

¹ Ataylab: `identity_admin` professional profil / verification / hujjat /
qaror jadvallarini o‘qiy oladi (tasdiqlash ishi uchun mavjud siyosat);
yozish — rad. `reviewer_scopes`, `professional_reviews`, `review_audit`,
`content_records` hamma uchun o‘qiladi (ataylab, nashr qilingan ma’lumot) —
yozish hamma uchun rad.
² Faqat `ai_usage`ga o‘z hisoblagichiga qator qo‘shish mumkin (Edge Function
tezlik cheklovi; faqat o‘ziga zarar).

Qo‘shimcha: admin javobida admin identifikatori/emaili muallifga
ko‘rinmaydi; yopilgan murojaatga yozib bo‘lmaydi; admin amallari auditga
yoziladi; matritsa yangi jadval qo‘shilsa (ro‘yxatda bo‘lmasa) FAIL beradi.
Mutatsiya sinovi: `support_threads`ga ochiq SELECT siyosati qo‘shilganda
matritsa darhol FAIL berdi (`STUDENT: SELECT others' rows`).

Kichik ekran (320×640) va 390×844 qadamlarida birorta ham overflow yoki
boshqa Flutter render xatosi qayd etilmadi.

### 2.x Spektrofotometriya (2026-10-09) — REAL ILOVA

`integration_test/qa_spectro_test.dart`, skrinshotlar va JSON:
`docs/qa/spectro_20261009/`.

| Rejim | Ishga tushirish | Natija |
|---|---|---|
| TALABA (Pro’siz) | `QA_MODE=student ./tool/qa_real_app.sh spectro` | 6/6 PASS |
| MUTAXASSIS (Pro — test override, xarid emas) | `QA_MODE=professional QA_PRO=1 ./tool/qa_real_app.sh spectro` | 11/11 PASS |

Tekshirildi: «Yo‘riqnomalar» ro‘yxatida yangi UB-ko‘rinadigan
spektrofotometriya kartasi; karta ochilishi, ehtiyot choralari, bog‘liq
vositalar va manbalar; kartadan Buger–Lambert–Ber vositasiga o‘tish (talabada —
aniq tarif nomi bilan qulf kartasi); hisoblar qo‘lda tekshirilgan qiymatlar
bilan (0,45/(15000·1) → 30 µmol/L; 25·1·20 mg/L → 0,5); bo‘sh maydon xatosi;
Kalibrlash vositasiga havola; 320 dp. Topilgan va tuzatilgan: 320 dp’da
qo‘shimcha birlik qatorlari («mol/ L») sinardi → bitta izoh qatoriga
ko‘chirildi; uz yorlig‘ida ikki qavs («Optik zichlik (absorbsiya) (A)») →
«Optik zichlik (A)». Bloklangan HTTP urinishlari: 0. ADMIN roli bu ishga
taalluqli emas (yangi admin funksiyasi yo‘q).

### 2.y «Sudda so‘roq: tayyorgarlik» (2026-10-09) — REAL ILOVA

`integration_test/qa_court_test.dart`, skrinshotlar (10 ta) va JSON:
`docs/qa/court_20261009/`.

| Rejim | Ishga tushirish | Natija |
|---|---|---|
| TALABA (bepul) | `QA_MODE=student ./tool/qa_real_app.sh court` | 15/15 PASS |
| MUTAXASSIS (Pro — test override, xarid emas) | `QA_MODE=professional QA_PRO=1 ./tool/qa_real_app.sh court` | 15/15 PASS |

Tekshirildi (390 va 320 dp, uz): Asosiy sahifada kirish (mutaxassisda bor,
talabada yo‘q — Kutubxonada bor); ogohlantirish; bepul foydalanuvchiga
savol-javob kartasining barcha qismlari (A savol, I holat NEEDS_REVIEW,
«Sud nimani tekshiradi», B qisqa javob, C asos, D manba joylari —
masalan «78-modda, 2-qism», E/F qo‘shimcha savollar, G cheklovlar, H BibTeX/
matn eksporti); «Manba tekshirilmagan» belgisi (ISO/IEC 17025 matni
o‘qilmagan); yurisdiksiya O‘zbekiston → JPK va «Sud ekspertizasi
to‘g‘risida»gi qonun moddalari (lex.uz); asosiy simulyator ssenariysi
(4 mezon, NEEDS_REVIEW izohi); Pro: AI tahlili — halol «tez orada» (AI
chaqirilmaydi), ketma-ket 4 rolli mashq, shaxsiy statistika va tarix
(faqat qurilmada); bepulda Pro imkoniyatlari → tariflar sahifasi; qidiruv.
Topilgan va tuzatilgan: simulyator bahosi qatorida `semanticsValue` son
bo‘lmagani uchun semantika xatosi (widget testida ushlandi); «IIIB Table 1
bo‘lim» kabi noqulay joy yozuvi → «§ IIIB Table 1 (bo‘lim)». Bloklangan HTTP
urinishlari: 0. ADMIN roli taalluqli emas. Tekshirilmagan: haqiqiy xarid,
real iOS/Android qurilma, qorong‘i mavzu, ru/en real-ilova yugurishi
(ru/en faqat widget testlarida).

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
| 6 | Murojaat formasi: bo‘sh yuborishdan keyin maydon to‘ldirilsa ham «Mavzuni kiriting.» / «Xabarni kiriting.» xatolari qolib ketardi | `support_screens.dart` | Birinchi yuborishdan keyin maydonlar yozilganda qayta tekshiriladi (widget test qo‘shildi) |
| 7 | Admin javobi kelganda Profil belgisi va banner faqat ilova **qayta ishga tushganda** yangilanardi (push yo‘q, fondan qaytish e’tiborga olinmasdi) | `app_shell.dart` | Ilova fondan qaytganda (`AppLifecycleListener.onResume`) o‘qilmaganlar qayta so‘raladi; QA va widget testi hayot sikli orqali tekshiradi |
| 8 | Admin → Foydalanuvchilar: xom kodlar — tarif «professionalPro»/«studentPro», platforma «android»/«ios», ixtisoslik «forensicToxicology»; moderator roli umuman ko‘rinmasdi | `admin_support_screens.dart`, `support_strings.dart`, ARB (`tool/l10n_qa_admin.py`) | «Mutaxassis Pro», «Android», ixtisoslik nomi; «Maqolalar moderatori» belgisi (yangi kalit `admRolePublicationModerator`) |
| 9 | Admin → Amallar jurnali: «ANSWERED → CLOSED» (xom holat kodlari) | `admin_support_screens.dart` | «Javob berilgan → Yakunlandi» (tarif/rol kodlari ham nomlanadi) |
| 10 | Yopilgan murojaat holati uz’da «Yopilgan» — vazifadagi atama «Yakunlandi» | ARB (`tool/l10n_qa_admin.py`) | `supStatusClosed` = «Yakunlandi», `supClosedNote` = «Bu murojaat yakunlangan…» |

### Tuzatilmadi (kontent yoki kattaroq ish — BACKLOG uchun)

| # | Kuzatuv | Sabab |
|---|---|---|
| 11 | Metabolit nomlari uz rejimida inglizcha: «acetaldehyde», «acetate», «acetyl-CoA» (Etanol → Metabolitlar) | Kontent paketidagi atama tarjimasi yo‘q (term_translations) — kontent ishi |
| 12 | Qidiruvda ba’zi namuna nomlari inglizcha («Gastric contents») | Kontent tarjimasi |
| 13 | Usul sxemasidagi rasm ichidagi yozuvlar inglizcha («Headspace GC — workflow», «Sealed vial»…) | Rasm faylining o‘zi — qayta chizish kerak |
| 14 | AI «Manbalarni oflayn topish» natijalarida iqtibos faqat inglizcha (yozuv sahifasidagi tarjima bu yerda ko‘rsatilmaydi), manba kodi xom ko‘rinishda («SRC-PMC10972208») | Kichik UX yaxshilash; AI ekrani boshqa ish oqimida |
| 15 | «Bu ma’lumot qayerdan?» oynasida: «Manba litsenziyasi … iqtibos ko‘rsatilmaydi» va shu manbada «Ochiq foydalanish» belgisi yonma-yon — foydalanuvchini chalkashtirishi mumkin | `provenance_widgets.dart` (boshqa agent ishlayapti) — tekshirish tavsiya etiladi |
| 16 | Kalkulyatorda ichki modul kodi ko‘rinadi: «lab.dilution.c1v1 · v1.0.0» | Ataylab (hisob-kitobni takrorlash uchun iz) — o‘zgartirilmadi |
| 17 | Profil formasida majburiy maydon (Davlat) to‘ldirilmasa, xabar faqat pastda («Belgilangan maydonlarni to‘g‘rilang.»), sahifa xatoli maydonga aylanmaydi | Kichik UX; feature-freeze sababli qoldirildi |
| 18 | AI xizmati yo‘q yig‘mada sarlavha «AI vaqtincha ishlamayapti» — aslida bu yig‘mada ulanmagan | Matn qarori (ilgari tanlangan) — o‘zgartirilmadi |
| 19 | Murojaat yuborilgandan / admin javob bergandan keyin SnackBar ~4 s davomida pastdagi yozish maydonini to‘sadi | Kichik UX; xatti-harakat to‘g‘ri |
| 20 | Admin yopilgan («Yakunlandi») murojaatga ham javob yoza oladi (foydalanuvchi esa yoza olmaydi) | Server `admin_reply_support` ham ruxsat beradi — ataylab bo‘lishi mumkin, egasi qaror qilsin |
| 21 | SQL: `private.has_role(uid, role)` anon/authenticated uchun EXECUTE ochiq — UUID ma’lum bo‘lsa, biror foydalanuvchi admin ekanini bilish mumkin (ma’lumot sizishi, yozish emas) | RLS siyosatlari shu funksiyaga tayanadi; o‘zgartirish = production migratsiya (ruxsat kerak) — BACKLOG |

## 5. Bu yerda TEKSHIRILMAGAN narsalar

Quyidagilar **sinovdan o‘tkazilmagan** — bu hisobot ularni qamramaydi:

- Haqiqiy iOS/Android qurilma (sensorli ekran, tizim klaviaturasi, «orqaga»
  imo-ishorasi, xavfsiz hudud, haqiqiy DPR). Sinov Linux desktop + Xvfb’da.
- Haqiqiy OTP xat (Supabase Auth, email yetkazilishi) — MOCK backend ishlatildi.
- Haqiqiy Supabase (Edge Function’lar, Storage API, haqiqiy JWT/aal2,
  referral server qismi, professional tasdiqlash, maqolalar va murojaatlar
  serveri) — ilovada xotiradagi soxta servislar. RLS/RPC qoidalari faqat
  **lokal PostgreSQL**da (Supabase stub’lari bilan) tekshirildi, production
  bazada emas.
- Haqiqiy tizim fayl tanlagichi (skrinshot tanlash dialogi) va rasmni
  Supabase Storage’ga yuklash — `QaImagePicker` bilan almashtirildi.
- Push-bildirishnoma / email xabarnoma (admin javobi haqida) — ilovada push
  yo‘q; faqat ilova ichidagi belgi va banner tekshirildi.
- Admin paneli haqiqiy statistikasi — FIXTURE raqamlar.
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

SQL: `bash supabase/tests/run_local.sh` (6 ta fayl, oxirgisi
`rls_role_matrix_test.sql` — alohida toza bazada).

Fayllar: `integration_test/qa_student_test.dart`,
`integration_test/qa_expert_test.dart`, `integration_test/qa_admin_test.dart`, `integration_test/qa/harness.dart`
(qadam, skrinshot, til va overflow tekshiruvi), `integration_test/qa/qa_env.dart`
(ishga tushirish, tarmoqni o‘chirish, soxta maqolalar serveri, `QaAccountService`, `QaImagePicker`, admin FIXTURE’lari),
`integration_test/qa_probe_test.dart` (yangi yo‘llarni o‘rganish uchun).
CI’ga ulanmagan: toza Ubuntu runner’da apt paketlari + Linux build bilan
~5 daqiqadan oshadi; qo‘lda ishga tushiriladi.
