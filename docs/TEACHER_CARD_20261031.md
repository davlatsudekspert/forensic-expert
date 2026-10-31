# Ustoz kartasi (2026-10-31)

Egasi talabi: ustoz profilida rasm, ish joyi (+logotip), qisqa «o‘zim haqimda» va
ijtimoiy tarmoq havolalari bo‘lsin; talabalar buni guruh sahifasida ko‘rsin
(ilovani jonli va ishonchli qilish uchun). Branch: `claude/teacher-card`
(asos `50e2c98`, 0.4.0+30). **Production’ga HECH NARSA qo‘llanmagan.**

## Dizayn

**Maxfiylik modeli.** Karta — ixtiyoriy; **DEFAULT yashirin** (`visible=false`).
Ustoz «Talabalarimga ko‘rsatish» kalitini rozilik matni bilan o‘zi yoqadi
(«Rasm va ma’lumotlaringiz faqat sizning guruhlaringiz a’zolariga ko‘rinadi»);
yoqilgan vaqt `consent_at`da saqlanadi. Karta faqat shu ustozning guruhlari
a’zolariga ko‘rinadi (guruhdan chiqsa — to‘xtaydi). Qurilmadagi profil rasmi
(`lib/app/avatar.dart`) o‘zgarmagan va serverga yuborilmaydi; karta rasmi ALOHIDA.

**Server** (`supabase/migrations/20261031020000_teacher_card.sql`, rollback
`supabase/rollback/20261031020000_teacher_card_down.sql`):

| RPC | Kim | Javob |
|---|---|---|
| `teacher_card_get_mine()` | har qanday kirgan hisob | `{ok, card|null, is_teacher}`; egasi kartasi: `teacher_id, display_name, workplace, bio, photo_path, logo_path, socials, updated_at, visible, hidden_by_admin, consent_at` |
| `teacher_card_upsert(p_display_name, p_workplace, p_bio, p_photo_path, p_logo_path, p_socials jsonb, p_visible)` | faqat ustoz roli (aks holda 42501) | `{ok:true, card}` yoki `{ok:false, error: invalid_name\|invalid_workplace\|invalid_bio\|invalid_photo\|invalid_logo\|invalid_social(+field)\|hidden_by_admin}` |
| `teacher_card_get(p_teacher uuid)` | shu ustozning guruh a’zosi yoki ustozning o‘zi (aks holda 42501) | `{ok, card|null}`; yashirin/admin yashirgan/roli olingan → `card:null`; talaba javobida `visible/consent_at/hidden_by_admin` YO‘Q |
| `teacher_card_for_group(p_group uuid)` | guruh a’zosi yoki egasi (aks holda 42501) | `teacher_card_get` bilan bir xil (ilova shuni ishlatadi: ustoz id sini oldindan bilmaydi) |
| `teacher_card_delete()` | egasi | `{ok, deleted, photo_path, logo_path}` (ilova Storage obyektlarini o‘chiradi) |
| `admin_teacher_card_hide(p_teacher, p_hide=true, p_reason)` | `identity_admin` (+MFA qoidasi) | `{ok, found}`; `visible=false`, `hidden_by_admin=true`; ustoz o‘zi qayta yoqa olmaydi; audit log `TEACHER_CARD_HIDE/UNHIDE` |

Jadval `teacher_cards`: `user_id` PK → `auth.users` **on delete cascade**; chegaralar:
ism 2–60, ish joyi ≤120, bio ≤300; RLS yoqilgan, `revoke all` (faqat RPC).

**Havola validatsiyasi — serverda** (`private.teacher_card_url_ok`): faqat `https`;
har tarmoq o‘z domeni: telegram `t.me`/`telegram.me`; instagram `instagram.com`;
youtube `youtube.com`/`m.`/`youtu.be`; facebook `facebook.com`/`m.`; linkedin
`linkedin.com`; tiktok `tiktok.com` (faqat aniq host yoki `www.`; `l.facebook.com`
kabi yo‘naltiruvchi subdomenlar yo‘q). `website` — istalgan https domen, ≤255 belgi.
Rad: `javascript:`, `data:`, `http:`, `ftp:`, sxemasiz, userinfo (`t.me@evil`), port,
IP, `localhost`, bo‘shliq/`<>"'\`, noma’lum tarmoq kaliti. Dart nusxasi:
`lib/domain/teacher_card/teacher_card.dart` (`TeacherLinks`) — ilova `@username`/`t.me/ism`/
`forensic.uz` kirishini to‘liq `https://…` ga normallashtiradi va havolani **ochishdan oldin
yana tekshiradi** (`TeacherLinks.openable`).

**Rasm saqlash — tanlangan yechim (hujjatlangan):** xususiy bucket `teacher-cards`
(1 MB, jpeg/png/webp), yo‘l `<uid>/(photo|logo)-<uuid>.<ext>` (har yangi rasm — yangi nom,
shuning uchun kesh xavfsiz). Ommaviy bucket (`lesson-images` uslubi) **TANLANMADI**: u
yashirin kartani ham ochiq URL bilan sizdirardi. Imzolangan URL ham tanlanmadi (muddati
ichida guruhdan chiqqan/yashirilgan holatda ham ishlaydi). Eng oddiy xavfsiz yechim —
**Storage RLS**:
- yozish: faqat egasi (ustoz roli, o‘z papkasi, nom regex’i, ko‘pi bilan 8 obyekt);
- o‘qish: egasi YOKI kartasi ko‘rinadigan (visible, admin yashirmagan, ustoz roli bor)
  ustozning guruhi a’zosi — va faqat kartadagi **joriy** rasm/logotip;
- o‘chirish: egasi; yangilash siyosati yo‘q.
Ilova baytlarni `GET storage/v1/object/authenticated/teacher-cards/<path>` (foydalanuvchi JWT)
bilan oladi. Karta yashirilsa/talaba guruhdan chiqsa — rasmga kirish darhol to‘xtaydi.
`teacher_card_upsert` rasm yo‘li egasiniki ekanini va obyekt mavjudligini tekshiradi.

**Hisob o‘chirish:** karta qatori cascade bilan o‘chadi; Storage obyektlarini
`supabase/functions/delete-account/index.ts` (`teacher-cards` bucket ro‘yxatga qo‘shildi,
mavjud `credentials`/`support-attachments` tartibida, **faqat kod — deploy qilinmagan**).

**Ilova.**
- Profil → «Ustoz kartam» (faqat kirgan + `classIsTeacherProvider` + xizmat ulangan) →
  `TeacherCardScreen` (`/profile/teacher-card`): rasm (mavjud `GalleryAvatarPicker` +
  `AvatarCropScreen`, so‘ng `fitTeacherImage` 1 MB gacha PNG siqadi: 512→384→256→160 px),
  ism, ish joyi, logotip, matn, 7 ta tarmoq maydoni (rangli yumaloq belgi: Material ikonka
  yoki harf; **brend logotiplari yo‘q**), rozilik kaliti (DEFAULT o‘chiq), «Ko‘rish»
  (talaba ko‘rinishi), «Kartani saqlash», «Kartani o‘chirish».
- Talaba: guruh sahifasi tepasida ixcham `TeacherCardView` (`GroupTeacherCard`); belgi
  bosilsa havola `launchUrl(externalApplication)` bilan tashqarida ochiladi (faqat
  ruxsat etilgan domen). Karta yo‘q/yashirin/xato bo‘lsa — hech narsa ko‘rinmaydi.
- «Shikoyat qilish» (bayroq) → mavjud «Taklif va murojaatlar» yangi murojaat ekrani
  (`related_entity = teacher_card:<ustoz id>`, sarlavhada ustoz ismi) — yangi backend kerak emas.
- Fayllar: `lib/domain/teacher_card/`, `lib/domain/ports/teacher_card_ports.dart`,
  `lib/data/remote/supabase_teacher_card.dart`, `lib/data/teacher_card/` (test/demo
  «server»), `lib/app/teacher_card.dart`, `lib/features/teacher_card/`. `BytesFetcher`
  (`supabase_rest.dart`) — rasm baytlari uchun (matnli transport rasmni buzardi).
- L10n: `apps/mobile/tool/l10n_teacher_card.py` (66 kalit uz/ru/en + `privacySummary`ga bir gap),
  so‘ng `flutter gen-l10n`. CLAUDE.md tartibida «(yangi skriptlar)» o‘rnida, `l10n_ux_audit.py` dan oldin.

## Qo‘llash tartibi (faqat egasi ruxsati bilan)

1. Zaxira/preview: `supabase/tests/run_local.sh` (lokal PG) — o‘tgan.
2. Production DB: `20261031020000_teacher_card.sql` (additiv; mavjud jadvallarga tegmaydi).
   Keyin: `teacher-cards` bucket `public=false`, 1 MB; `storage.objects`da 3 ta
   `teacher_cards_*` siyosat; `get_advisors` (security) — yangi ogohlantirish yo‘qligini tekshiring.
3. Edge function `delete-account` deploy (yangi bucket ro‘yxati) — ilova chiqishidan OLDIN.
4. `docs/legal/privacy.html` qayta joylash; do‘kon deklaratsiyalari: `docs/DATA_SAFETY_TEACHER_CARD.md`.
5. Ilova build/yangi versiya (build raqami bu branchda o‘zgartirilmagan).
6. Smoke (haqiqiy hisob bilan): ustoz kartani to‘ldiradi → talaba ko‘rmaydi → kalit yoqiladi →
   talaba ko‘radi → rasm ochiladi → shikoyat → admin yashiradi → ustoz o‘chiradi.

## Qaytarish

- Ilova: oldingi build (karta bo‘limi ko‘rinmaydi; server bilan mos).
- Server: `supabase/rollback/20261031020000_teacher_card_down.sql` (avval bucket ichini
  Storage API/dashboard’da bo‘shating). Ustoz kartalari va rasmlari **o‘chadi** — avval nusxa oling.
- `delete-account` — oldingi versiyaga qaytarish xavfsiz (faqat `teacher-cards` papkalari
  tozalanmay qoladi; keyin qo‘lda).

## Testlar

- SQL (`supabase/tests/run_local.sh`, lokal PG 16): `teacher_card_test.sql` — 124 PASS
  (faqat ustoz yozadi; talaba boshqa ustoz kartasini ko‘rmaydi; visible=false; havola
  validatsiyasi 37 holat; hajm 60/120/300/255; admin yashirishi; rol olinishi; hisob
  o‘chirilsa cascade), `teacher_card_storage_test.sql` — 24 PASS (Storage RLS), RLS
  role-matrix’ga `teacher_cards` qo‘shildi. Butun to‘plam: exit 0.
- Dart: `test/unit/teacher_card_test.dart` (havola normallashtirish/rad, draft chegaralari,
  server nusxasi fake, Supabase adapter), `test/widget/teacher_card_test.dart` (rozilik
  DEFAULT o‘chiq, talaba ko‘rinishi, ruxsat etilmagan havola, 320 dp / 1.6× matn,
  shikoyat oqimi, rasm siqish). `flutter analyze` — toza. Natija: unit 22, widget 17 test o‘tdi; kengroq to‘plam (l10n, architecture, guards, avatar, class_groups, teacher_panel, support_admin, mode_matrix, account_flow) — 207 o‘tdi.

## Sinalmagan / ochiq qolganlar

- HAQIQIY Supabase va Storage: migratsiya production’da qo‘llanmagan; Storage API
  (yuklash POST, `object/authenticated` GET, DELETE) so‘rovlari faqat soxta transport
  bilan sinalgan — haqiqiy bucket siyosati bilan birinchi smoke kerak.
- Haqiqiy qurilma (iOS/Android) va galereyadan rasm tanlash/ruxsatlar; rasm yuklash
  tarmoqda; ilovaning haqiqiy STUDENT/EXPERT/ADMIN rejimlarida qo‘lda sinovi (faqat
  widget testlar).
- `delete-account` edge function deploy qilinmagan va haqiqiy hisob bilan sinalmagan.
- Admin ekranida «kartani yashirish» tugmasi YO‘Q: hozir faqat `admin_teacher_card_hide`
  RPC (SQL konsol/service). Shikoyatlar mavjud «Taklif va murojaatlar» inbox’iga tushadi.
- Ustozni «bloklash» tugmasi kartaga ulanmagan (talaba guruhdan chiqsa karta yo‘qoladi).
- `teacher_card_upsert` uchun alohida rate-limit yo‘q (faqat ustoz roli + 8 fayl limiti).
- Demo/test rejimida (`Fake*`) karta xizmati ulanmagan: release’da Supabase bo‘lmasa bo‘lim
  ko‘rinmaydi.
