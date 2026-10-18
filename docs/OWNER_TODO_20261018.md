# Egasi bajaradigan ishlar (2026-10-18)

Qolgan hamma ishni Claude qiladi. Bu yerda faqat egasining akkaunti talab qiladigan qadamlar.
Parol yoki kalitni hech qachon chatga yozmang — faqat GitHub Secrets ga qo‘ying.

## 1. Test banki uchun Supabase kaliti — ENG MUHIMI (≈3 daqiqa)
1. https://supabase.com/dashboard/account/tokens → **Generate new token** → nomi: `github-seed` → **Generate** → **Copy** (faqat bir marta ko‘rinadi).
2. https://github.com/davlatsudekspert/forensic-expert/settings/secrets/actions → **New repository secret**
   - Name: `SUPABASE_ACCESS_TOKEN`
   - Secret: nusxalangan kalit → **Add secret**.
3. Claude’ga «qo‘shdim» deb yozing → 18 mavzu × 30 savol × 3 til serverga yuklanadi (faqat qo‘shadi, hech narsa o‘chirmaydi).

## 2. Admin panelning 3 funksiyasi (≈2 daqiqa, kompyuterda)
Rol berish, akkauntni to‘xtatish, blokdan chiqarish + 30 kunlik sinf-test tozalash.
1. https://supabase.com/dashboard/project/igvzlmpgwybjdgkyowrl/sql/new
2. GitHub’da oching: `supabase/manual/20261018_pending_admin_delete_functions.sql`
   (branch `claude/phase-8-12-final-release`) → **Raw** → hammasini nusxalang.
3. SQL Editor’ga joylang → **Run** → «Success» chiqsa, Claude’ga yozing.

## 3. App Store Connect — havolalarni tekshirish (≈1 daqiqa)
App Information / App Privacy bo‘limida:
- **Privacy Policy URL:** https://davlatsudekspert.github.io/forensic-expert-legal/
- **Support URL:** shu manzil (ichida yordam va akkauntni o‘chirish bo‘limi bor).

## 4. Yangi test build chiqqach (Claude xabar beradi)
1. TestFlight (iPhone) / Play Market internal test (Android) orqali yangilang.
2. Ko‘ring: pastki 5 talik menyu (o‘rtada AI), «Sinfda test» (ustoz va talaba), prezentatsiyalar.
3. Ikki telefon bilan sinab ko‘ring: biri ustoz (sizning akkaunt), biri talaba (boshqa email).
4. Kamchilik — skrinshot bilan Claude’ga.

## 5. Keyinroq, shoshilinch emas
- **Google/Apple orqali kirish:** Google Cloud va Apple Developer kalitlari kerak — `docs/SOCIAL_SIGN_IN.md`.
- **Cloudflare / o‘z domeni:** hozir kerak emas (GitHub Pages yetarli). Kerak bo‘lsa — parol emas,
  faqat «Cloudflare Pages: Edit» huquqli API token → GitHub Secret `CLOUDFLARE_API_TOKEN`.
- **Anthropic API krediti:** qolgan prezentatsiyalar va RU/EN tarjimalarni tezlashtiradi (ixtiyoriy).
- **Gemini (ilovadagi AI):** Google AI Studio’da kalit limiti/to‘lovini vaqti-vaqti bilan tekshiring.
