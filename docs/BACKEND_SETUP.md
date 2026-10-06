# FORENSIC EXPERT — backend sozlash (o‘z Supabase loyihasi)

FORENSIC EXPERT boshqa mahsulotlardan (NFCSTORE, BugunBor) **to‘liq ajratilgan**:
o‘z Supabase loyihasi, o‘z email jo‘natuvchisi, o‘z AI kaliti. Hech qanday
boshqa loyihaning ID’si, domeni, foydalanuvchilari yoki sirlari ishlatilmaydi.

## 1. Arxitektura

| Qism | Joy | Izoh |
|---|---|---|
| Email OTP (6 xonali kod) | Supabase Auth (GoTrue REST) | `lib/data/remote/supabase_auth_repository.dart` |
| Sessiya | refresh token — Keychain/Keystore | access token faqat xotirada |
| Profil, ariza, hujjat metadata, taqrizlar | PostgREST + RLS | `supabase/migrations/*.sql` |
| Malaka hujjatlari | Private Storage bucket `credentials` | ochiq URL yo‘q, ≤10 MB, ≤5 fayl |
| Tasdiqlash qarori | `decide_identity()` (security definer) | o‘zini tasdiqlash, talaba, tasdiqlanmagan, noto‘g‘ri soha — bloklanadi |
| Akkaunt o‘chirish | Edge Function `delete-account` | service-role faqat serverda |
| AI (Gemini) | Edge Function `ai-answer` | `GEMINI_API_KEY` faqat serverda |

NFCSTORE dan faqat **naqsh** o‘rganildi (faqat o‘qish uchun): 6 xonali kod,
xesh bilan saqlash, qisqa amal muddati, qayta yuborishga 60 s, email/IP
limitlari, Resend provayderi, server tomonda AI kaliti, ishonchsiz kontekstni
«data, not instruction» deb o‘rash. Kod, brend, shablon, domen, sirlar
ko‘chirilmagan.

## 2. Holat (2026-10-06)

* Supabase loyihasi **yaratildi**: `forensic-expert` (eu-central-1, bepul reja,
  egasining tashkiloti; «news» loyihasiga tegilmagan).
* Migratsiyalar qo‘llandi: core, ai_usage, function_grants, advisor_hardening.
  Security advisor: ERROR yo‘q; qolgan WARN — kirgan foydalanuvchi chaqiradigan
  RPC’lar (ichida rol/scope tekshiruvi bor, ataylab).
* Edge Functions: `delete-account`, `ai-answer` (JWT talab qilinadi) — ACTIVE.
* Ilova konfiguratsiyasi: `apps/mobile/config/backend.json` (URL + publishable
  kalit — ochiq qiymatlar). Jonli tekshiruv: anon RPC → 42501 permission denied,
  hujjatlar jadvali anon uchun bo‘sh, `ai-answer` kirishsiz → 401.
* Email OTP: FORENSIC EXPERT’ning o‘z `email-otp` Edge Function’i (6 xonali
  kod, HMAC-xesh, 10 daqiqa, 5 urinish, 3 kod/email/10 daq, 10/IP/10 daq,
  60 s qayta yuborish oralig‘i) → Resend orqali FORENSIC EXPERT jo‘natuvchisi
  → tasdiqlangach server Supabase sessiyasini qaytaradi. Supabase’ning
  SMTP/shablon sozlamalari KERAK EMAS.
  Kerakli Edge Function secrets: `RESEND_API_KEY`, `FE_EMAIL_FROM`
  (masalan `FORENSIC EXPERT <no-reply@sizning-domeningiz>`), `GEMINI_API_KEY`.
  Sozlanmaguncha funksiya halol `email_not_configured` qaytaradi.
* AI (beta): kirgan foydalanuvchi uchun ochiq, server limiti 30 savol/soat.

## 2b. Egasi bajaradigan qadamlar

1. ✅ Loyiha yaratilgan (`forensic-expert`).
2. Email domeni: FORENSIC EXPERT uchun o‘z domeningiz (masalan
   `no-reply@<sizning-domeningiz>`). Resend (yoki boshqa SMTP) da domenni
   tasdiqlang (SPF/DKIM). **Domen o‘ylab topilmagan — egasi beradi.**
3. GitHub repository secrets (qiymatlar hech qachon chop etilmaydi):

| Secret | Qayerda ishlatiladi |
|---|---|
| `SUPABASE_ACCESS_TOKEN`, `SUPABASE_PROJECT_REF`, `SUPABASE_DB_PASSWORD` | `backend-deploy.yml` (migratsiya, funksiyalar) |
| `FE_SMTP_HOST`, `FE_SMTP_USER`, `FE_SMTP_PASS`, `FE_SMTP_SENDER_EMAIL`, `FE_SITE_URL` | Auth email (brendlangan OTP) |
| `GEMINI_API_KEY` | `ai-answer` Edge Function muhiti |
| `FE_SUPABASE_URL`, `FE_SUPABASE_ANON_KEY` | ilova build (`--dart-define`; anon kalit ochiq, RLS himoyasida) |

4. Actions → **backend-deploy** → Run workflow (faqat qo‘lda).
5. Admin rolini berish (bir marta, SQL editor):
   `insert into account_roles(user_id, role, granted_by) values ('<uid>', 'identity_admin', '<owner uid>');`
6. Release build qayta ishga tushiriladi — ilova backendga ulanadi.

## 3. Email shablonlari

`supabase/templates/otp_confirmation.html`, `otp_magic_link.html` — faqat
FORENSIC EXPERT brendi, EN/RU/UZ (`user_metadata.locale`). Mavzu:
«FORENSIC EXPERT — Verification code / Код подтверждения / Tasdiqlash kodi».
Kod 10 daqiqa amal qiladi (`otp_expiry = 600`), qayta yuborish ≥ 60 s.

## 4. AI (Gemini)

* Kalit ilovada yo‘q. `FE_AI_REMOTE=true` faqat `GEMINI_API_KEY` mavjud
  bo‘lganda build’ga qo‘shiladi.
* RAG-first: ilova faqat oflayn bazadan olingan bo‘laklarni yuboradi; model
  faqat ulardan javob beradi va bo‘lak ID’larini keltiradi; ilova har bir
  iqtibosni qayta tekshiradi (noma’lum ID — javob rad etiladi).
* Rasmiy ekspert xulosasi, o‘lim sababi, huquqiy hukm, doza/maslahat,
  o‘ylab topilgan raqam yoki manba — taqiqlangan (system prompt + ilova
  `SafetyPolicy`).
* Har bir foydalanuvchi uchun soatlik limit (`ai_usage`, RLS); savol/javob
  saqlanmaydi va jurnalga yozilmaydi.
* Kalit yo‘q yoki xato bo‘lsa — «Namoyish · ulanmagan», faqat lokal manbalar.

## 5. Tekshiruv

`supabase/tests/run_local.sh` — PostgreSQL 16 da migratsiya + 19 xavfsizlik
testi (CI: `db-security`). Real loyiha bo‘yicha end-to-end OTP sinovi faqat
yuqoridagi sirlar berilgandan keyin mumkin — ungacha «email yuborildi» deb
da’vo qilinmaydi.
