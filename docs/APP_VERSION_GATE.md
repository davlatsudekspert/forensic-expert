# Eski ilova versiyalarini boshqarish (majburiy yangilash)

Holat (2026-10-31): server qismi production’da **o‘rnatilgan, lekin o‘chiq** (`min_build = 0`).
Ilova qismi build 35 dan boshlab ishlaydi.

## Qanday ishlaydi
- Build 35+ har bir Supabase so‘roviga `x-fe-build: <build>` va `x-fe-platform` sarlavhalarini qo‘shadi.
- `public.app_config` jadvali bitta qatordan iborat. Undagi `min_build`, `latest_build`, `android_url`, `ios_url` qiymatlarini
  ilova ishga tushganda `rpc/app_version_info` orqali o‘qiydi. Agar build < min_build bo‘lsa, ilova «Yangi versiya chiqdi»
  sahifasini ko‘rsatadi va o‘tkazib yubormaydi.
- Server tomonda PostgREST `db_pre_request` = `private.check_app_build`. U har bir REST/RPC so‘rovidan oldin ishlaydi.
  Agar min_build > 0 bo‘lsa, quyidagi so‘rovlar **HTTP 426** `UPDATE_REQUIRED` bilan rad etiladi:
  - sarlavhasi yo‘q so‘rovlar, ya’ni build ≤ 34 bo‘lgan barcha eski APK’lar;
  - build raqami min_build dan kichik so‘rovlar.
  Guruhlar, testlar, kartalar, savol-javob, profil va boshqa server funksiyalarining hammasi shu tekshiruvdan o‘tadi.
- Edge Function’larda `ai-answer` va `tts` xuddi shu tekshiruvni o‘zlari bajaradi va 426 `{"error":"update_required"}` qaytaradi.
- Istisnolar:
  - `service_role`;
  - Edge Function ichidagi supabase-js (`x-client-info: supabase-js-deno…`);
  - `app_version_info` RPC’ning o‘zi;
  - Auth (kirish) va Storage — PostgREST emas, ular cheklanmaydi.
- Sinov sarlavhasi `x-fe-check: probe` faqat o‘sha so‘rovni 426 bilan rad etadi. Boshqa foydalanuvchilarga ta’siri yo‘q.

## Yoqish (eski versiyalarni o‘chirish)
```sql
-- Masalan, 35 dan eski barcha versiyalar to'xtaydi:
update public.app_config set min_build = 35, latest_build = 35, updated_at = now();
-- iOS havolasi App Store'da chiqqandan keyin:
update public.app_config set ios_url = 'https://apps.apple.com/app/id<ID>' ;
-- Qaytarish (hammasi ochiq):
update public.app_config set min_build = 0;
```
⚠️ Yoqishdan oldin yangi build do‘konda hammaga ochiq bo‘lishi kerak. Aks holda foydalanuvchilar yangilay olmay qoladi.

## Cheklovlar (halol)
- Ilova ichiga o‘rnatilgan oflayn kontent (kutubxona bazasi) eski APK’da ochiq qolaveradi.
  Uni masofadan o‘chirib bo‘lmaydi.
- Bu himoya — versiyani boshqarish uchun. APK’ni ataylab buzgan odamga qarshi emas: sarlavhani soxtalashtirish mumkin.
  Pullik funksiyalar uchun asosiy himoya — har RPC’da serverda `plan`ni tekshirish. Bu Pro ishga tushirilganda qilinadi.
- Jonli sinov (2026-10-31):
  - `app_version_info` → 200;
  - probe so‘rovi REST, RPC, `ai-answer` va `tts` da → 426;
  - min_build = 0 holatida oddiy so‘rovlar o‘tadi: AI javobi 200, TTS 200.
  - min_build > 0 holati prod’da sinalmadi, chunki u haqiqiy foydalanuvchilarni bloklab qo‘yardi.
    Bu holat lokal PG16 da sinaldi: sarlavhasiz, 34, `abc` → rad; 35 → o‘tdi; istisnolar o‘tdi.
