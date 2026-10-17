# Admin kengaytmasi — EGASI QILADIGAN ISHLAR

Sana: 2026-10-17. Branch: `claude/admin-ext`. Bu hujjatdagi hech narsa **avtomatik bajarilmagan**:
production DB’ga migratsiya qo‘llanmagan, Edge Function deploy qilinmagan, sir qo‘yilmagan.
Hammasi egasining tasdig‘i bilan, shu tartibda. Maxfiy kalitlarni chatga, repoga yoki
hujjatga yozmang.

Nima o‘zgardi: `docs/ADMIN_PANEL.md` §9.

## 0. Boshlashdan oldin

1. PR’ni ko‘rib chiqing va (xohlasangiz) `main`/release branch’ga qo‘shing. Bu branch’da
   `claude/phase-8-12-final-release` ga hech narsa push qilinmagan.
2. Production DB zaxirasi: Supabase Dashboard → Database → Backups (yoki `supabase db dump`).
3. Migratsiya **qaytarib bo‘lmaydigan o‘zgarish**: yangi jadvallar, `qa_feed`/`qa_question`
   qayta yoziladi, `qa_questions`/`qa_answers` ga trigger qo‘shiladi, `admin_guard` qayta yoziladi.
   Qaytarish: faylning boshidagi `ROLLBACK` izohi (qo‘lda).
4. Muhim ta’sir: trigger `qa_terms_required` yoqilgach **foydalanuvchi qoidalarni qabul
   qilmaguncha yangi savol/javob yozolmaydi**. Q&A hozir ommaga yopiq (`FE_QA`) bo‘lsa — xavfsiz.
   Ochiq bo‘lsa — avval yangi ilova buildini chiqaring (u qoidalar ekranini ko‘rsatadi), keyin
   migratsiyani qo‘llang; aks holda eski build yozishda xato beradi.

## 1. Migratsiyani production’ga qo‘llash (tasdiq bilan)

Lokal tekshiruv (allaqachon o‘tgan; qayta ishlatib ko‘rishingiz mumkin):

```bash
bash supabase/tests/run_local.sh   # PostgreSQL 16 kerak; "ALL ADMIN EXTENSION TESTS PASSED"
```

Qo‘llash (bitta usulni tanlang):

```bash
supabase link --project-ref <FE_PROJECT_REF>
supabase db push                    # 20261017000000_admin_extension.sql ni qo‘llaydi
```

yoki Dashboard → SQL Editor’da `supabase/migrations/20261017000000_admin_extension.sql`
mazmunini bir martada ishga tushiring.

Qo‘llagach tekshiruv (SQL Editor):

```sql
-- 1) Yangi jadvallar RLS bilan va hech kimga to‘g‘ridan-to‘g‘ri huquqsiz
select c.relname, c.relrowsecurity from pg_class c join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public' and c.relname in ('user_reports','user_blocks','user_terms','account_suspensions');
-- 2) anon faqat submit_report ni chaqira oladi (boshqa yangi RPC lar yo‘q bo‘lishi kerak)
select p.proname from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' and has_function_privilege('anon', p.oid, 'execute')
  and p.proname in ('submit_report','admin_reports','admin_set_role','admin_set_suspension','admin_stats_ext','my_blocks');
-- kutiladi: faqat submit_report
```

### auth.sessions huquqini tekshirish (to‘xtatish uchun MUHIM)

`admin_set_suspension` `auth.sessions` va `auth.refresh_tokens` dan o‘chiradi. Supabase’da
`postgres` roli odatda bunga ega, lekin **tekshirilmagan**. Sinov (test hisob bilan, haqiqiy
foydalanuvchida emas):

1. Test hisob yarating va ilovada kiring.
2. Admin sifatida shu hisobni to‘xtating (Admin → Foydalanuvchilar → ⋮ → «Hisobni to‘xtatish»).
3. Natija `permission denied for table sessions/refresh_tokens` bo‘lsa — SQL Editor’da:
   `grant delete on auth.sessions, auth.refresh_tokens to postgres;` (Supabase bunga ruxsat bersa),
   bo‘lmasa shu funksiyadan `delete from auth.…` ikki qatorni olib tashlab, to‘xtatish faqat
   `banned_until` bilan ishlaydi (kirish va yangilash rad etiladi; mavjud token ≤ 1 soat yashaydi)
   va sessiyalarni Dashboard → Authentication → Users → ⋯ → «Sign out user» bilan yoping.
4. To‘xtatilgan hisob bilan kirishga urinib ko‘ring — rad etilishi kerak. Keyin «Hisobni qayta
   yoqish» va qayta kirish.

## 2. Birinchi adminni tayinlash (bootstrap) — `ADMIN_EMAILS`

Admin huquqi emailga qarab emas, **server roli** bilan beriladi. `ADMIN_EMAILS` faqat birinchi
marta rol berish uchun. Hisobingiz ilovada email kodi bilan **kirgan va tasdiqlangan** bo‘lishi shart.

### Variant A — Edge Function (tavsiya)

```bash
# 1. Sirni qo‘ying (qiymat terminal tarixida qolmasligi uchun faylga yozmang; bevosita kiriting)
supabase secrets set ADMIN_EMAILS="siz@example.com" --project-ref <FE_PROJECT_REF>

# 2. Funksiyani deploy qiling (verify_jwt=false: u service-role kalitni o‘zi tekshiradi)
supabase functions deploy admin-bootstrap --project-ref <FE_PROJECT_REF> --no-verify-jwt

# 3. Bir marta chaqiring (SERVICE ROLE kalit: Dashboard → Settings → API; boshqa hech kimga bermang)
curl -sS -X POST "https://<FE_PROJECT_REF>.supabase.co/functions/v1/admin-bootstrap" \
  -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY"
# kutiladi: {"granted":1,"listed":1}
```

4. **Bootstrapdan keyin**: funksiyani o‘chiring yoki sirni olib tashlang:
   `supabase functions delete admin-bootstrap` va `supabase secrets unset ADMIN_EMAILS`.
   Funksiya faqat service-role kalit bilan ishlaydi, lekin keraksiz yuzani qoldirmang.

### Variant B — SQL Editor (Edge Function’siz)

```sql
select private.admin_bootstrap(array['siz@example.com']);   -- 1 qaytaradi
```

Ikkala variantda ham: tasdiqlanmagan yoki mavjud bo‘lmagan manzil o‘tkazib yuboriladi (0 qaytadi);
natija `private.admin_audit` da `ADMIN_BOOTSTRAP` sifatida qoladi.

### Tekshiruv

Ilovani oching → Profil → «Admin panel» qatori ko‘rinadi (faqat server `my_access.is_admin`).
Boshqa (oddiy) hisob bilan ko‘rinmasligini ham tekshiring.

### Ikkinchi admin kerak bo‘lsa

Ilovadan admin berish sukut bo‘yicha o‘chiq. Yoqish (ixtiyoriy, SQL Editor):
`update private.admin_settings set allow_admin_grant_in_app = true;` — hozirgi UI admin berish
tugmasini ko‘rsatmaydi, shuning uchun amalda ikkinchi adminni bootstrap ro‘yxati bilan
tayinlang (`ADMIN_EMAILS="a@x,b@y"` + Variant A/B).

## 3. Edge function deploy (faqat o‘zgarganlar)

- `admin-bootstrap` — yuqorida (bir martalik).
- `delete-account` (avvalgi o‘zgarish, `docs/ADMIN_PANEL.md` §5) hali deploy qilinmagan bo‘lsa:
  `supabase functions deploy delete-account --project-ref <FE_PROJECT_REF>`.
  Yangi `user_blocks`, `user_terms`, `user_reports` hisob o‘chirilganda `ON DELETE CASCADE`
  (`user_reports.reporter_id` — `SET NULL`, shikoyat qoladi, muallifi ko‘rinmaydi).
- `.github/workflows/backend-deploy.yml` faqat qo‘lda ishga tushadi (`workflow_dispatch`); u
  barcha funksiyalarni deploy qiladi — `admin-bootstrap` ham shunga kiradi. Bootstrapdan keyin
  uni qayta deploy qilmaslik uchun funksiyani o‘chirib qo‘ying (yuqoridagi 4-qadam).

## 4. Qo‘shimcha sozlamalar (tavsiya)

- **MFA (TOTP) admin uchun**: `docs/ADMIN_PANEL.md` §4 (hozir yoqmang — ilovada enroll ekrani yo‘q).
- **Spam limiti**: IP sarlavhasi (`cf-connecting-ip` / `x-real-ip` / `x-forwarded-for`) Supabase
  proksisidan keladi. Haqiqiy so‘rovda ishlashini tekshiring: kirmagan holda 6 ta shikoyat yuboring
  (alohida qurilma kalitisiz) — oltinchisi «Soatiga 5 tagacha…» deyishi kerak.
- **Maxfiylik siyosati**: «shikoyatlar» (matn, tuzlangan IP/qurilma xeshi), «bloklashlar» va
  «qoidalarni qabul qilish sanasi»ni `docs/legal/privacy.html` ga qo‘shing (yurist bilan).
- **App Privacy (ASC)** javoblarini yangilang: User Content / Other User Content, User ID.
- **Terms of Use (EULA)**: ilovadagi matn QORALAMA; yurist tekshirgan matn bilan almashtiring
  (RG-05) va ASC’da «EULA» maydoniga qo‘ying.

## 5. Apple «Notes for review» — admin panel haqida (nusxa)

### O‘zbekcha

```
Administrator paneli (Profil -> "Admin panel"): faqat server tomonidagi admin roliga ega
hisoblarga ko‘rinadi. Ko‘rib chiquvchi (review) hisobida admin huquqi YO‘Q, shuning uchun panel
ko‘rinmaydi. Huquq email manziliga emas, serverdagi rolga bog‘liq va har so‘rovda serverda
qayta tekshiriladi. Panelda: shikoyatlarni ko‘rish/hal qilish, foydalanuvchini qidirish,
hisobni to‘xtatish va qayta yoqish (to‘xtatilgan hisob kira olmaydi), umumiy statistika.

Foydalanuvchi tomonidagi kontent (Savol-javob, agar bu buildda yoqilgan bo‘lsa), Guideline 1.2:
- Birinchi yozishdan oldin "Foydalanish qoidalari" qabul qilinadi (haqoratli, noqonuniy kontent
  va spamga yo‘l qo‘yilmaydi); qabul serverda saqlanadi, qabulsiz yozib bo‘lmaydi.
- Har bir savol/javobda "Shikoyat" va "Muallifni bloklash" tugmalari bor; bloklangan muallifning
  postlari ko‘rinmaydi (Qoidalar -> Bloklangan mualliflar).
- Shikoyat hisobsiz ham yuboriladi (Profil -> "Shikoyat yuborish"); administrator shikoyatni
  ko‘rib chiqadi, kontentni olib tashlaydi yoki hisobni to‘xtatadi.
- Ko‘rinadigan aloqa: davlatsudekspert@gmail.com.
Ilovada to‘lov yoki reklama funksiyasi admin paneliga bog‘liq emas.
```

### English

```
Administrator panel (Profile -> "Admin panel"): visible only to accounts that hold a
server-side admin role. The App Review account has NO admin role, so the panel is not shown to
it. Access depends on the server-side role, not on an e-mail address, and is re-checked on the
server for every request. The panel offers: viewing and resolving reports, user search,
suspending and restoring an account (a suspended account cannot sign in), and aggregate
statistics.

User-generated content (Community Q&A, if enabled in this build), Guideline 1.2:
- Before the first post the user accepts the "Community rules" (abusive, illegal content and
  spam are not allowed); the acceptance is stored on the server and posting is refused without it.
- Every question and answer has "Report" and "Block author" buttons; a blocked author's posts
  are hidden (Rules -> Blocked authors).
- Reports can be sent without an account (Profile -> "Send a report"); the administrator reviews
  reports, removes content or suspends the account.
- Visible contact: davlatsudekspert@gmail.com.
The admin panel has no connection to payments or advertising.
```

Eslatma: ASC’dagi mavjud Notes matni bilan birlashtiring (`docs/APPLE_REVIEW_GUIDELINES_AUDIT_2026-10-17.md`
«Notes for review — namuna»). Q&A bu buildda O‘CHIQ bo‘lsa, 1.2 bo‘limini yozmang.

## 6. Qo‘lda sinab ko‘rish ro‘yxati (production’da, test hisoblar bilan)

1. Kirmagan holda: Profil → «Shikoyat yuborish» → yuboring → muvaffaqiyat xabari; 6-sini yuborib limitni ko‘ring.
2. Admin hisobi: Admin → «Shikoyatlar» → shu shikoyat ko‘rinadi → izoh → «Hal qilindi deb belgilash».
3. Admin → Foydalanuvchilar → test hisob → ⋮ → «Hisobni to‘xtatish» (sabab bilan) → test hisob qurilmasida
   keyingi so‘rovda chiqarib yuboriladi / qayta kira olmaydi; «Hisobni qayta yoqish».
4. Admin → Foydalanuvchilar → o‘zingiz va boshqa admin: to‘xtatish tugmasi yo‘q.
5. Q&A yoqilgan bo‘lsa: yangi test hisob birinchi javob yozishda qoidalar ekranini ko‘radi; qabulsiz yozolmaydi;
   savolda «Muallifni bloklash» → post lentadan yo‘qoladi; «Bloklangan mualliflar»da qaytariladi.
6. Admin → Statistika bo‘limi: sotuvlar «0 — to‘lov tizimi yo‘q», «Hozir tizimda» — mavjud emas, ASC/Play tugmalari ochiladi.
