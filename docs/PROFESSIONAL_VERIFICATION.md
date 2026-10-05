# Ro‘yxatdan o‘tish, professional tasdiqlash va mutaxassis taqrizi

> Holat: **mijoz (ilova) to‘liq tayyor; production server ulanmagan.** Hech kim tasdiqlanmagan, hech qanday taqriz yo‘q, hujjat hech qayerga yuklanmagan. **HUMAN VERIFIED = 0.**

## 1. Beshta alohida tushuncha

| Tushuncha | Qayerda | Kim o‘zgartiradi |
|---|---|---|
| Foydalanish rejimi (Talaba / Mutaxassis) | qurilma (`AppSettings.userMode`, `declaredRole`) | foydalanuvchi, istalgan vaqt |
| Identifikatsiya (akkaunt) | auth server (ixtiyoriy) | foydalanuvchi |
| Professional maqom (`VerificationStatus`) | server `verification` + `verification_decisions` | qo‘lda ko‘rib chiqib: **identity admin** yoki shu soha vakolatiga ega **tasdiqlangan mutaxassis**; o‘zini emas |
| Taqrizchi vakolati (`ReviewerScope`) | server `reviewer_scopes` | faqat **scope grantor**, faqat tasdiqlanganlarga |
| Ilmiy tasdiq (HUMAN VERIFIED) | server, siyosat bo‘yicha hisoblanadi | hech kim qo‘lda emas |

Mutaxassis rejimini tanlash, lavozim yozish, sertifikat yuklash, AI tahlili, admin roli yoki DOI tekshiruvi **maqom ham, ilmiy tasdiq ham bermaydi**. Kod: `lib/domain/professional/`.

## 2. Oqim

1. Til → 2. Ilmiy ogohlantirish → 3. Talaba/Mutaxassis (+ ixtiyoriy kichik rol; Mutaxassisda «maqom tasdiqlanmagan» izohi) → 4. **Hisobsiz davom etish** (asosiy) yoki Hisob yaratish (server ulanmagan bo‘lsa o‘chiq va sababi yozilgan) → Home.
Profil (talaba/mutaxassis) faqat qurilmada saqlanadi.

## 3. Professional tasdiqlash

`ApplicationPending → Verified | ChangesRequested | Rejected`, `Verified ↔ Suspended` — `VerificationStateMachine`. Foydalanuvchi faqat ariza yuboradi (`APPLICATION_PENDING`); boshqa holatga o‘zi o‘ta olmaydi.

Qaror (`IdentityVerification.decide`, server: `decide_identity()`):
* **Kim:** identity admin (inson) **yoki** `p_scope` soha vakolati faol bo‘lgan, allaqachon `VERIFIED_PROFESSIONAL` mutaxassis. To‘xtatish (SUSPEND) — faqat identity admin.
* **Hech qachon:** o‘zini tasdiqlash (admin bo‘lsa ham), talaba, tasdiqlanmagan / kutilayotgan / to‘xtatilgan foydalanuvchi, AI/xizmat akkaunti.
* **Hujjat — dalil, avtomatik tasdiq emas:** VERIFY uchun kamida bitta, aynan arizachiga tegishli malaka hujjati tekshirilgan bo‘lishi shart.
* **Yoziladi** (`verification_decisions`, faqat qo‘shiladi): arizachi, tasdiqlagan shaxs, uning turi (admin / tasdiqlangan hamkasb), vaqt, tekshirilgan hujjat ID’lari, soha, oldingi/yangi holat, ichki izoh.
* Qaror o‘zi taqriz vakolati bermaydi (alohida — `canGrantScope`).
* Barcha tekshiruvlar serverda (RLS + `security definer` funksiyalar); mijozdagi rol bayroqlari faqat UI uchun.

## 4. Malaka hujjati (ixtiyoriy)

* PDF/JPG/PNG — tur **ichki imzo** bo‘yicha tekshiriladi; ≤10 MB; ≤5 fayl.
* Tanlangan fayl faqat xotirada (diskka yozilmaydi, jurnal/analitikaga tushmaydi, `toString` shaxsiy ma’lumotni yashiradi).
* Server: xususiy `credentials` bucket, ochiq URL yo‘q, faqat identity admin uchun ≤5 daqiqalik imzolangan havola; metama’lumotda URL maydoni yo‘q.
* Ish materiallari/dalillar yuklanmasligi, pasport/ID talab qilinmasligi UI’da aytiladi.
* **Hozir:** server yo‘q — «Yuklanmadi: tasdiqlash xizmati ulanmagan» deb ochiq ko‘rsatiladi.

## 5. Soha vakolati

`ReviewScopes.forKind`: modda → toksikologiya/kimyo; metod/standart → laboratoriya/kimyo/toksikologiya; reagent → kimyo/laboratoriya; skrining → toksikologiya/laboratoriya; sud tibbiyoti → sud tibbiyoti; biokimyo → biokimyo; gistologiya → patologiya; huquq → huquq; research → bog‘langan yozuvlardan (bog‘lanmagan bo‘lsa — hech kim). DNK taqrizchisi moddani taqriz qila olmaydi (test bilan).

## 6. Mutaxassis taqrizi

Har bir modda, metod, reagent, skrining, sud tibbiyoti/biokimyo/gistologiya mavzusi va research sahifasida «MUTAXASSIS TAQRIZI»:
* tekshiruv qatlamlari alohida: manba · identifikator · mutaxassis taqrizlari · inson ilmiy tasdig‘i (`0 / 2`);
* taqriz yo‘q — «Bu material hali malakali mutaxassis tomonidan taqriz qilinmagan.»;
* amallar (Ma’qullash, Tuzatish so‘rash, Ziddiyat, Eskirgan, Rad etish) faqat vakolatli tasdiqlangan mutaxassisga ko‘rinadi; izoh ≥20 belgi; manba DOI/PMID/https;
* taqriz aniq kontent versiyasiga bog‘langan; versiya o‘zgarsa — `RE_REVIEW_REQUIRED`, eski taqriz tarixda;
* siyosat (`ReviewPolicy`): HUMAN VERIFIED uchun 2 mustaqil ma’qullash; yuqori xatar (modda, reagent) — turli tashkilotlardan.

## 7. Server shartnomasi

`docs/backend/professional_schema.sql` — jadvallar, RLS, `decide_identity()`, `submit_review()` (verifikatsiya + soha + joriy versiya serverda tekshiriladi). Mijozdagi `ReviewAuthority` faqat UI uchun; server mijoz bayrog‘iga ishonmaydi.

Production uchun kerak (tashqi): auth backend, xususiy storage, admin panel (identity admin / scope grantor rollari), `record_scopes()` / `published_version()` kontent xizmati.

## 8. Testlar

`test/unit/professional_domain_test.dart` (30), `test/widget/registration_test.dart` (18), `test/widget/back_navigation_test.dart` (4), `test/a11y/registration_responsive_test.dart` (360), `test/golden/registration_golden_test.dart` (26; `docs/screenshots/registration/`). FIXTURE taqrizchi va taqrizlar faqat `test/` ichida; `lib/` da yo‘qligi test bilan tekshiriladi.

## 9. Boshqa tuzatishlar

* Modul sahifasi (Toksikologiya/Laboratoriya) «tekshirilgan ma’lumot yo‘q» deb qattiq kodlangan edi — endi paketdagi manbali yozuvlar (moddalar, namunalar, skrining, ziddiyatlar, metodlar, reagentlar, standartlar, research) soni va havolasi bilan.
* Metodlar: «Xalqaro standartlar — yozuv yo‘q» o‘rniga standartlar katalogiga havola (7).
* Navigatsiya: tafsilot sahifalari `push` bilan ochiladi (Back oldingi ekranga, ro‘yxat holati saqlanadi); qidiruv Home tabida; boshqa tab ildizida Android Back → Asosiy; tanlovchilar (til/rejim/yurisdiksiya) sozlama saqlanishidan oldin yopiladi (aks holda yangilanish sahifani qaytarardi).
* Qidiruv: bir yozuv bir nechta guruhda chiqqanda takroriy kalit xatosi tuzatildi.
