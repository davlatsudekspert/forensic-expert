# Production E2E closeout — holat

Feature-freeze nuqtasi: **`cf049d8`** (CI, Release build, Test APK
pre-release `apk-v0.4.0-ref1` — hammasi yashil). Kod o‘zgarmaydi.

Supabase loyihasi: `igvzlmpgwybjdgkyowrl` (yangi loyiha yaratilmaydi).

## 1. Supabase deploy — BAJARILDI (2026-10-06 ~10:40 UTC)

| Narsa | Holat | Tekshiruv |
|---|---|---|
| `email-otp` (bd3984e: jo‘natuvchi/domen xatosi → `email_send_failed`) | **DEPLOYED** v3, `verify_jwt=false` | joylashgan manbada `senderIssue` bor; noto‘g‘ri email → 400 `email_address_invalid` |
| Migratsiya `20261006030000_referrals.sql` | **DEPLOYED** (`referrals`) | anon: dashboard/claim/award/jadval → 401; `award`/`set_status` faqat `service_role`; jadvallar mijozga yopiq |
| Security advisor | yangi ERROR yo‘q | `rls_enabled_no_policy` (INFO, ataylab) va SECURITY DEFINER RPC’lar (WARN, ataylab: ichida `auth.uid()` tekshiriladi) |

Eslatma: `advisor_hardening` obyektlari bazada bor (avval SQL orqali
qo‘llangan), lekin migratsiya tarixida yozuv yo‘q.

## 2. OTP login — EGASI KUTILMOQDA

Bazada **0 akkaunt**. Yagona OTP so‘rovi (07:15 UTC) tasdiqlanmagan; demak
avvalgi login va AI test bu loyihaga yetib bormagan. Egasi
`davlatsudekspert@gmail.com` bilan ilovada (Supabase build, masalan
`apk-v0.4.0-ref1` TELEFON APK) email kod orqali qayta kirishi kerak.

## 3. identity_admin — 2-qadamdan keyin

Akkaunt paydo bo‘lgach, faqat shu email uchun (`granted_by` NULL = egasi):

```sql
insert into public.account_roles (user_id, role, granted_by)
select id, 'identity_admin', null from auth.users
where lower(email) = 'davlatsudekspert@gmail.com'
on conflict do nothing;
```

## 4. Gemini real javob + iqtiboslar — 2-qadamdan keyin

`ai_usage` = 0 (hali real chaqiruv yo‘q). Kirgandan so‘ng AI ekranida savol →
`ai_usage` qatori, javob va iqtiboslar (CitationResolver) tekshiriladi.

## 5. Referral real E2E — 2-qadamdan keyin

Kerak: 2 ta haqiqiy akkaunt (A — egasi, B — yangi email). A: Profil → taklif
kodi; B: kodni kiritadi → `VALID`; A panelida «Tasdiqlangan: 1». Mukofotlar
o‘chiq (`rewards_enabled=false`) — kredit berilmaydi.

## 6. Imzolangan store build’lar — EGASI KUTILMOQDA

Android upload keystore, Apple sertifikat/profil, store ID tasdig‘i.
DEBUG build’lar store’ga yuklanmaydi.

## 2026-10-08 — Expert Publications migratsiyasi (egasi ruxsati bilan)
- Oldingi holat qaydi: 6 migratsiya, 18 public jadval (account_roles 1, ai_usage 21, access_grants 1), `account_role` = identity_admin, scope_grantor.
- Qo‘llandi: `publications` (repo fayli `20261008000000_publications.sql`). Faqat yangi obyektlar: 4 jadval (RLS, to‘g‘ridan-to‘g‘ri huquq yo‘q), 12 funksiya, `account_role` ga `publication_moderator` qiymati.
- Keyingi holat: mavjud jadvallar va yozuvlar o‘zgarmagan; anon faqat `list_published` ni chaqira oladi.
- Smoke (tranzaksiya qaytarilgan, ma’lumot qolmagan): SUBMITTED, can_moderate=true (identity_admin), o‘z maqolasini moderatsiya — FORBIDDEN_OWN.
- Rollback: migratsiya fayli boshidagi izohda.

## 2026-10-09 — Murojaatlar va admin panel migratsiyasi (egasi ruxsati bilan)
- Oldin: 7 migratsiya; users 1, account_roles 1, access_grants 1, ai_usage 21, publications 0, storage buckets 1, storage policies 2.
- Qo‘llandi: `support_and_admin` (repo: `20261009000000_support_and_admin.sql`).
- Keyin: mavjud qatorlar o‘zgarmagan (1/1/1/21); +2 jadval public, +2 jadval private, bucket `support-attachments` (+1), storage policy +2; authenticated jadvalni to‘g‘ridan o‘qiy olmaydi; anon admin RPC chaqira olmaydi.
- Smoke (tranzaksiya qaytarilgan): murojaat CREATED → admin_stats (users=1, awaiting=1) → inbox total=1 → admin javobi SENT. Natijada support_threads=0, admin_audit=0.
- Rollback: migratsiya fayli sarlavhasi + `supabase/rollback/20261009_pre_support_admin_functions.sql`.
- Qolgan ruxsatlar: `delete-account` Edge Function deploy; maxfiylik siyosati bandi; MFA (TOTP ulangach `admin_requires_aal2`).
- 2026-10-09: `delete-account` Edge Function v3 deploy qilindi (egasi ruxsati bilan): hisob o‘chirilganda `credentials` va `support-attachments` bucket’laridagi foydalanuvchi fayllari ham o‘chadi. verify_jwt=true; tokensiz va noto‘g‘ri token — 401 (tekshirildi). Real hisob bilan to‘liq o‘chirish sinalmagan (yagona hisob — egasiniki).

## TestFlight (ichki) — 2026-10-09
- 0.3.0 (82) — `5cd021e`: reaktivlar, GMT, toks, COHb, «Sudda so‘roq», lug‘at, Free/Pro qarori. Delivery f01eb803-e430-4e59-9ffd-61c8811e474f.
- 0.3.0 (85) — `4238338`: + yangi logotip (egasi tasdiqladi: ikon, splash, ilova ichidagi variantlar). Delivery a3f75e67-9e1b-4656-b052-69498a035917.
- Ikkalasi ham UPLOAD SUCCEEDED; ko‘rib chiqishga yuborilmagan (public release yo‘q). CI yashil, to‘liq suite 2514 PASS, real-ilova 374/374.
- Ma’lum: uch tilli ilmiy kontent loyihasi davom etmoqda (`docs/L10N_AUDIT_20261009.md`).
- 0.3.0 (101) — `198452c`: uch tilli lokalizatsiya (C+D+D2+E/F): 882 ta tadqiqot sarlavhasi glossi,
  63 ta karta tushuntirishi, tarjima-birinchi ko‘rinish + «Asl matn», O‘zbekiston qonunlarining rasmiy
  nomlari, yagona terminologiya, qayta qurilgan o‘quv testi (izoh + imtihon/mashq). Delivery
  3c1a955a-2c22-46e0-b809-8bfba466f93c. CI yashil; to‘liq suite 2582 PASS; SQL 229 PASS;
  real-ilova 255/256; lang_audit uz/ru/en 0/0/0 error.
