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
