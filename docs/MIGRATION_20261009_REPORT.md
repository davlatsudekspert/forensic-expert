# Migratsiya hisoboti: `20261009000000_support_and_admin.sql`

Holat: **production’ga QO‘LLANMAGAN** — egasining alohida ruxsatini kutadi.
Sana: 2026-10-09. Loyiha: `igvzlmpgwybjdgkyowrl`.

## 1. SQL tarkibi (673 qator)

**Yangi jadvallar (4):**
| Jadval | Vazifasi | Himoya |
|---|---|---|
| `public.support_threads` | murojaat (muallif, turkum, mavzu, holat, o‘qilgan vaqtlar, rozilik vaqti) | RLS yoqilgan, policy yo‘q, anon/authenticated huquqi yo‘q |
| `public.support_messages` | murojaat xabarlari (USER/ADMIN, matn ≤4000, rasm yo‘li) | xuddi shunday |
| `private.admin_audit` | admin amallari jurnali (ID, holat, uzunlik — **xabar matnisiz**) | xuddi shunday, API’da ko‘rinmaydi |
| `private.admin_settings` | `admin_requires_aal2` (MFA talabi), sukut bo‘yicha `false` | xuddi shunday |

**Yangi funksiyalar (17):** hammasi `SECURITY DEFINER`, `search_path=''`, aniq `revoke`/`grant`.
- Foydalanuvchi: `create_support_thread`, `add_support_message`, `my_support_threads`,
  `support_thread`, `support_unread_count`, `mark_support_read` — faqat o‘z murojaatlari.
- Admin: `admin_support_inbox`, `admin_reply_support`, `admin_set_support_status`,
  `admin_stats`, `admin_users`, `admin_audit_log` — hammasi `private.admin_guard()` orqali
  (`identity_admin` roli; email bo‘yicha emas).
- Ichki: `private.admin_guard`, `private.admin_log`, `private.support_attachment_ok`,
  `private.audit_account_roles` (trigger funksiyasi).

**Storage:** yopiq `support-attachments` bucket (jpeg/png/webp, ≤5 MB) va `storage.objects`
ga 2 ta policy (faqat shu bucket uchun: foydalanuvchi o‘z `<uid>/` papkasiga yozadi/o‘qiydi,
admin o‘qiydi). O‘chirish/yangilash policy’si yo‘q.

## 2. Mavjud obyektlarga ta’siri

| Obyekt | O‘zgarish | Mavjud ma’lumotga ta’siri |
|---|---|---|
| `public.admin_dashboard()` | `CREATE OR REPLACE`: tekshiruv `admin_guard()` orqali (MFA sozlamasi qo‘shiladi). Qaytaradigan ma’lumot **aynan o‘sha** | yo‘q |
| `public.admin_set_access()` | `CREATE OR REPLACE`: xuddi o‘sha mantiq + audit yozuvi | yo‘q |
| `public.account_roles` | yangi `AFTER INSERT/UPDATE/DELETE` audit trigger | mavjud qatorlar o‘zgarmaydi; faqat kelajakdagi rol o‘zgarishlari jurnalga yoziladi |
| `storage.buckets` | 1 ta yangi qator | boshqa bucket’larga ta’sir yo‘q |
| `storage.objects` | 2 ta yangi policy (`bucket_id = 'support-attachments'` bilan cheklangan) | boshqa bucket’larga ta’sir yo‘q |

**O‘chiriladigan narsa yo‘q.** Mavjud jadvallarga ustun qo‘shilmaydi, mavjud qatorlar o‘zgartirilmaydi.
Sizning `identity_admin` rolingiz o‘zgartirilmaydi.

## 3. Zaxira strategiyasi
1. Qo‘llashdan oldin “oldingi holat” qaydi (migratsiyalar ro‘yxati, jadvallar va qator sonlari).
2. O‘zgaradigan 2 ta funksiyaning production nusxasi allaqachon saqlangan:
   `supabase/rollback/20261009_pre_support_admin_functions.sql` (2026-10-09, `pg_get_functiondef`).
3. To‘liq DB nusxasi: Supabase Dashboard → Database → Backups (yoki `supabase db dump`) —
   DB paroli menda yo‘q, buni egasi bajaradi (ixtiyoriy, chunki mavjud ma’lumot o‘zgarmaydi).
4. Migratsiya bitta tranzaksiyada: xato bo‘lsa to‘liq orqaga qaytadi.

## 4. Rollback rejasi
Migratsiya fayli sarlavhasidagi `ROLLBACK` bloki: trigger va 17 funksiyani o‘chirish, 2 ta storage
policy va bucket’ni o‘chirish, 4 ta jadvalni o‘chirish, so‘ng
`supabase/rollback/20261009_pre_support_admin_functions.sql` ni ishga tushirib
`admin_dashboard()`/`admin_set_access()` ni avvalgi holatiga qaytarish.
Natija: baza migratsiyadan oldingi holatga to‘liq qaytadi (faqat murojaatlar va audit yozuvlari yo‘qoladi).

## 5. RLS va xavfsizlik testlari (lokal PostgreSQL 16, Supabase stub’lari bilan)
| Fayl | Natija |
|---|---|
| security_test | PASS |
| referral_test | PASS |
| admin_test | PASS |
| publications_test | PASS |
| support_admin_test (92 tekshiruv) | PASS |
| rls_role_matrix_test (716 tekshiruv; anon / STUDENT / EXPERT / MODERATOR / ADMIN) | PASS |
| **Jami** | **963 PASS, 0 FAIL** |

Asosiy natijalar:
- A foydalanuvchi B ning murojaati, xabarlari va rasmlarini ko‘rmaydi va o‘zgartira olmaydi.
- Kirmagan foydalanuvchi, talaba, mutaxassis va `publication_moderator` admin RPC’larini chaqira olmaydi.
- Admin ham jadvallarga to‘g‘ridan-to‘g‘ri yoza olmaydi; faqat RPC orqali, har amal audit’ga yoziladi.
- Admin javobida adminning shaxsi foydalanuvchiga ko‘rsatilmaydi («FORENSIC EXPERT jamoasi»).
- Statistikada matn yoki email yo‘q (faqat sonlar).
- Mutatsiya sinovi: ataylab ochiq policy qo‘shilganda matritsa darhol FAIL berdi.

## 6. Ilovadagi ekranlar va real sinov
- Real-ilova sinovi (Linux desktop, MOCK backend, HTTP bloklangan): Talaba 49/49, Mutaxassis 37/37, Admin 23/23.
- Skrinshotlar: `docs/qa/real_app_20261009/` (murojaatlar, chat, admin dashboard, inbox, foydalanuvchilar).
- Sinalmagan: haqiqiy Supabase/Storage/JWT (aal2), haqiqiy iOS qurilma, push/email bildirishnoma.

## 7. Foydalanuvchi ma’lumotlari xavfsizligi
- Murojaat ochishda rozilik majburiy (`consent_at` saqlanadi), maxfiylik izohi ko‘rsatiladi.
- Cheklovlar: mavzu ≤200, xabar ≤4000 belgi; kuniga ≤10 murojaat, soatiga ≤60 xabar; rasm ≤5 MB, faqat jpeg/png/webp.
- Hisob o‘chirilsa, muallif murojaatlari va xabarlari `cascade` bilan o‘chadi; rasmlarni `delete-account`
  Edge Function o‘chiradi (kod tayyor, **deploy alohida ruxsat bilan**).
- Talaba/mutaxassis rejimi serverda saqlanmaydi — statistikada `null` (uydirma son yo‘q).

## 8. Ma’lum kamchiliklar / qarorlar
- `private.has_role()` SQL darajasida ochiq, lekin `private` sxemasi API’ga chiqmaydi (REST orqali chaqirib bo‘lmaydi).
- Admin «Yakunlandi» holatidagi murojaatga javob yoza oladi (murojaatni qayta ochish uchun ataylab qoldirilgan);
  foydalanuvchi yopilgan murojaatga yoza olmaydi.
- MFA: hisobingizda TOTP ulanmagan; `admin_requires_aal2` faqat TOTP ulangandan keyin yoqiladi.

## 9. Ruxsat kerak bo‘lgan qadamlar
1. Ushbu migratsiyani production’ga qo‘llash.
2. `delete-account` Edge Function’ni qayta deploy qilish (rasmlarni ham o‘chirishi uchun).
3. Maxfiylik siyosatiga murojaatlar va skrinshotlar bandini qo‘shish.
