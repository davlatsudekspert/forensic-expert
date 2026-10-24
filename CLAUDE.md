# FORENSIC EXPERT — ishlash qoidalari

- **Til:** foydalanuvchi bilan har doim **o‘zbek tilida** yozing (hisobotlar,
  savollar, izohlar). Kod, commit xabarlari va texnik nomlar inglizcha qolishi
  mumkin.
- **Feature-freeze (2026-10-06, `cf049d8`):** yangi funksiya, redesign yoki katta
  refactor qilinmaydi. Faqat production E2E closeout:
  Supabase → OTP login → identity_admin → Gemini real javob + iqtiboslar →
  referral real E2E → imzolangan store build’lar.
  Holat: `docs/PRODUCTION_CLOSEOUT.md`. Keyingi ishlar: `docs/BACKLOG.md`.
- **Keyingi katta topshiriq (2026-10-08):** `docs/35_MASTER_PROMPT_GLOBAL_PLATFORM.md` — Phase A (read-only audit) dan boshlanadi.
- **ABY 2025 (egasi qarori, 2026-10-17):** ABY ilovadan **to‘liq olib tashlangan** (Apple 2.5.19); qayta qo‘shilmaydi. Tiklash faqat git tarixidan: holat `05bffed`, commitlar va tafsilot — `docs/ABY_COVERAGE.md` tepasida, qaror — `docs/DECISIONS.md`.
- **Til tartibi (egasi qarori, 2026-10-12):** yangi kontent avval **faqat o‘zbek tilida mukammal** qilinadi (ustoz kitoblari/qo‘llanmalari asosida, aniq joyi bilan). RU/EN — keyingi haftada; undan keyin qozoq, tojik, qirg‘iz. Shuning uchun yangi yozuv asl tilini (`source_lang: "uz"`) e’lon qiladi, tarjima alohida jadvalda qo‘shiladi; tarjimasi yo‘q yozuv boshqa tilda asl o‘zbekcha matn bilan va «tarjima kutilmoqda» belgisi bilan ko‘rinadi, tarjima to‘qilmaydi. Quyidagi «Uch tilli kontent» bandi shu hafta uchun yangi kontentga qo‘llanmaydi.
- **Shanba (2026-10-17) birinchi bosqich — faqat audit (egasi topshirig‘i, 2026-10-14):** `docs/MASTER_PROMPT_AUDIT_2026-10-17.md`. Egasi «MA’QULLAYMAN, BOSHLANG» demaguncha: kod/kontent/migratsiya/deploy/build yo‘q; model tanlash va limit tejash qoidalari shu hujjatning A bo‘limida (Fable yo‘q, Sonnet asosiy, Opus faqat murakkab ishlarga).
- **Pro/pullik funksiyalar (egasi qarori, 2026-10-17; yangilandi 2026-10-24 — Pro keyingi versiya 0.4.0 sifatida tayyorlanadi, reja `docs/PRO_PLAN_2026-10-24.md`):** tekshiruvdagi ilovaga Pro kodi, to‘lov tugmalari, paywall ekranlari va yashirin yoki masofadan yoqiladigan bayroqlar QO‘SHILMAYDI; hamma funksiya bepul va ochiq. «Pro · hozircha bepul» kabi belgilar ham qo‘yilmaydi. Faqat serverda ko‘rinmas tayyorgarlik mumkin (`plan`: free/pro, ixtiyoriy `pro_until`), ilovada hech narsani o‘zgartirmaydi. Pro tayyor bo‘lganda — to‘liq ishlaydigan holda, yangi versiya sifatida: do‘kon mahsulotlari va narxlari, sandbox sinovi (xarid, bekor qilish, restore, tugash), server tomonida xarid tekshiruvi, «Restore purchases», ekranda narx/muddat/avto-uzayish/bekor qilish yo‘li, tekshiruvchiga sandbox akkaunt va izoh, «3 oy bepul» — do‘konning intro-offer'i sifatida. Hozirgi vazifa: to‘lovga oid hech narsa yozilmaydi; foydalanuvchi to‘plash, tasdiqlangan kontent va sifat.
- NFCSTORE va BugunBor repolarini o‘zgartirmang; maxfiy kalitlarni chiqarmang.

- **Eslatma (egasi so‘rovi, 2026-10-19):** egasi «nima qilamiz», «shanba», «reja» deb yozsa yoki yangi ish boshlasa — avval `docs/ACTIVE_TASKS.md` dagi **«Shanba (limit tiklanganda)»** rejasini (10 savollik dars testi + «ilovadan chiqmasin» 6 bandi) eslating.

## Model tanlash (egasi talabi, 2026-10-10)
- **Fable ishlatilmaydi** — limitni tez yeydi.
- Agentlar (subagent) uchun standart model — **Sonnet**.
- Kuchli model (Opus) faqat zarur joyda: branchlarni birlashtirish va konflikt
  yechish, ilmiy/huquqiy qaror, xato sababini tahlil qilish, egasi bilan muloqot.
- Uzoq va mexanik ishlar (kontent yig'ish, test yozish, build kutish) — Sonnet.

## Keyingi sessiya uchun (davom ettirish)
1. `docs/PROJECT_STATUS.md`, `docs/ACTIVE_TASKS.md`, `docs/DECISIONS.md`, `docs/TEST_REPORT.md` ni o‘qing — haqiqiy holat shu yerda.
2. `git log --oneline -15` va worktree branchlar (`git branch -a | grep worktree`) — birlashtirilmagan agent ishlari bo‘lishi mumkin.
3. Ish tartibi: audit → ustuvor vazifa → kod → test → tuzatish → qayta test → commit → hujjat yangilash. Mayda texnik qarorlarni o‘zingiz hal qiling.
4. Ruxsat kerak: production DB qaytarib bo‘lmas o‘zgarish, foydalanuvchi ma’lumotlari, pullik billing/infra, ABY yoki cheklangan materialni ommaviy tarqatish, public store release, kalit/credential o‘zgarishi, edge function deploy.
5. Flutter: `export PATH=/opt/flutter/bin:$PATH`; to‘liq suite ~7–10 daqiqa (bir marta ishga tushiring).

## Majburiy real sinov (egasi talabi, 2026-10-09)
- Har yangi funksiya/ekran/tuzatishdan keyin faqat unit test emas: ilovani haqiqatan ishga tushirib
  **STUDENT** va **EXPERT** (admin bo‘lsa **ADMIN**) rollarida sinang. Qabul mezoni:
  KOD → TEST → STUDENT SINOVI → EXPERT SINOVI → TUZATISH → REGRESSION → HISOBOT → COMMIT.
- Tekshiruv ro‘yxati: tugmalar, sahifalar ochilishi, tushunarli xatolar, to‘liq o‘zbekcha matn,
  ma’lumot yuklanishi, 390/320 dp ekranlar, internet o‘chganda, qidiruv sifati, boshqa
  foydalanuvchi ma’lumoti ko‘rinmasligi, real backend yoki demo ekanligi.
- Sinalmagan narsani “sinadim” deb yozmang (real iOS qurilma, real OTP email, xaridlar — ochiq ayting).
- Test akkauntlari/ma’lumotlari production foydalanuvchilarga aralashmasin.
- Real-app harness va hisobot: `tool/qa_real_app.sh`, `docs/qa/REAL_APP_TEST_REPORT.md`.

## Admin panel (2026-10-09)
- Adminlik faqat server tarafidagi rol (`account_roles`, `private.has_role`) orqali; email mos kelishi
  huquq bermaydi. Rol berish faqat himoyalangan server jarayonida, audit log bilan.
- Admin ≠ ilmiy reviewer: ilmiy tasdiq faqat reviewer vakolati bilan.
- «Taklif va murojaatlar»: foydalanuvchi faqat o‘z murojaatini ko‘radi (RLS + SECURITY DEFINER RPC).
- Batafsil: `docs/ADMIN_PANEL.md`.
- Production DB, haqiqiy admin huquqini berish, billing, pullik servis, public release — alohida tasdiq bilan.

## L10n skriptlari tartibi
ARB konfliktida: `--theirs`/`--ours` olib, skriptlarni qayta ishga tushiring; terminologiya
skripti oxirida: `l10n_analysis.py` → `l10n_quote_i18n.py` → `l10n_support_admin.py` → `l10n_qa_fixes.py` → `l10n_qa_admin.py` → `l10n_pmi.py` → `l10n_polish_home.py` → `l10n_polish_tools.py` → `l10n_polish_reading.py` → `l10n_privacy.py` → `l10n_spectro.py` → `l10n_citations.py` → `l10n_toks.py` → `l10n_reagents.py` → `l10n_gmt.py` → `l10n_court.py` → `l10n_glossary.py` → `l10n_study_terms.py` → `l10n_trilingual.py` → `l10n_casebook.py` → `l10n_admin_verify.py` → `l10n_legal_url.py` → `l10n_statement.py` → `l10n_pro_tools.py` → `l10n_method_images.py` → `l10n_method_records.py` → `l10n_qa_community.py` → `l10n_qa_rules.py` → `l10n_admin_gift.py` → `l10n_prov_statement.py` → `l10n_confirmed_source.py` → `l10n_avatar.py` → `l10n_admin_ext.py` → `l10n_social_auth.py` → `l10n_apple_revoke.py` → `l10n_class_quiz.py` → `l10n_class_groups.py` → `l10n_class_lesson_quiz.py` → `l10n_group_lesson_test.py` → `l10n_teacher_mode.py` → `l10n_group_wording.py` → (yangi skriptlar) → `l10n_ux_audit.py` → `flutter gen-l10n`.

## Uch tilli kontent (egasi talabi, 2026-10-09) — har bir yangi kontent/ekran uchun majburiy
- UZ (adabiy lotin), RU, EN — teng chuqurlikda. Foydalanuvchi avval o‘z tilidagi tushuntirishni ko‘radi;
  asl iqtibos/hujjat «Asl matn» orqali alohida ochiladi. Bibliografiya (muallif, asl sarlavha, DOI, sahifa) o‘zgarmaydi.
- Tarjima holati shu tilda ko‘rsatiladi («Avtomatik tarjima — tekshirilmagan»); tekshirilmaganni tasdiqlangan deb ko‘rsatmang.
- Raqam, birlik, formula, modda nomi, cutoff, foiz, usul cheklovlari tarjimada o‘zgarmaydi (avtomatik tekshiruv).
- Terminlar yagona: ilmiy lug‘atga bog‘lang (PMI, PMR, LC-MS/MS, GC-MS, COHb, Rf, Vd …).
- Testlar: mantiqan bog‘liq chalg‘ituvchi variantlar, bitta aniq javob, tushuntirish, manba+sahifa; manbasizlari baholanadigan rejimga kirmaydi.
- Reja va audit: `docs/L10N_AUDIT_20261009.md`.
