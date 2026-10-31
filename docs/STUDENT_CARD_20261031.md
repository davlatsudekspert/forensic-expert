# Talaba kartasi (2026-10-31, 1-bosqich)

Egasi qarori (2026-10-31): talaba profili 1-bosqichi — ixtiyoriy «Talaba kartasi»,
ustoz kartasi (`docs/TEACHER_CARD_20261031.md`) asosida. **Layk YO‘Q, obuna YO‘Q,
ommaviy/global ko‘rinish YO‘Q, havola/ijtimoiy tarmoq YO‘Q** (talabalar voyaga yetmagan
bo‘lishi mumkin). Branch: `claude/student-card` (asos `claude/pro-0.4.0`).
**Production’ga HECH NARSA qo‘llanmagan.**

## Dizayn

**Maxfiylik.** Karta ixtiyoriy; **DEFAULT yashirin** (`visible=false`). Egasi «Guruhdoshlarimga
va ustozimga ko‘rsatish» kalitini rozilik matni bilan o‘zi yoqadi; vaqt `consent_at`da.
Karta har qanday kirgan hisobda (faqat talaba emas) bo‘ladi. Qurilmadagi profil rasmi
(`lib/app/avatar.dart`) serverga yuborilmaydi; karta rasmi ALOHIDA.

**Ko‘rinish qoidasi** (`private.student_card_visible_to`) — karta ko‘ruvchiga ko‘rinadi
FAQAT: `visible=true` VA `hidden_by_admin=false` VA ko‘ruvchi uni o‘zi yashirmagan VA:
(a) egasi (`student_card_get_mine`), (b) talaba a’zo bo‘lgan guruhning ustozi
(`class_groups.teacher_id`; moderator sifatida guruhdan yashirilganini ham ko‘radi),
(c) talaba bilan kamida bitta umumiy guruhdagi boshqa a’zo (`class_group_members`) va
shu guruhda karta ustoz tomonidan yashirilmagan. Boshqalarga (boshqa guruh talabalari,
boshqa ustozlar, guruhsizlar, anon) — hech qachon (`42501` yoki `card:null`).

**Server** (`supabase/migrations/20261031040000_student_card.sql`, rollback
`supabase/rollback/20261031040000_student_card_down.sql`). Jadvallar: `student_cards`
(user_id PK → auth.users cascade; `display_name` 2–40; `bio` ≤150; `photo_path`; `visible`;
`consent_at`; `hidden_by_admin`), `student_card_hides` (viewer_id, student_id — «o‘zim uchun
yashirish»), `student_card_group_hides` (group_id, student_id, hidden_by, reason — ustoz
moderatsiyasi), `private.student_card_audit` (ustoz amallari jurnali). Hammasida RLS yoqilgan,
`revoke all` (faqat RPC).

| RPC | Kim | Javob |
|---|---|---|
| `student_card_get_mine()` | har qanday kirgan hisob | `{ok, card|null}`; egasi kartasi: `student_id, display_name, bio, photo_path, updated_at, visible, hidden_by_admin, consent_at, hidden_in_groups` |
| `student_card_upsert(p_display_name, p_bio, p_photo_path, p_visible)` | har qanday kirgan hisob | `{ok:true, card}` yoki `{ok:false, error: invalid_name\|invalid_bio\|invalid_photo\|contact_info(+field name\|bio)\|hidden_by_admin}` |
| `student_card_get(p_student)` | ustoz / guruhdosh / egasi; aloqasiz — 42501 | `{ok, card|null[, hidden_by_me]}` |
| `student_cards_for_group(p_group)` | guruh a’zosi yoki ustozi (aks holda 42501) | `{ok, cards:[…≤200], hidden_ids:[…]}`; ustoz kartalarida `member_id` va `group_hidden`; `hidden_ids` — ko‘ruvchi o‘zi yashirganlar (mazmunsiz) |
| `student_card_hide_for_me(p_student, p_hide=true)` | ko‘ruvchi (aloqa kerak, aks holda 42501; qaytarish har doim) | `{ok}` yoki `{ok:false,error:'limit'}` (≤500) |
| `group_student_card_hide(p_group, p_student, p_hide=true, p_reason)` | FAQAT guruh ustozi (42501), talaba shu guruh a’zosi (`not_found`) | `{ok}`; audit `GROUP_HIDE/GROUP_UNHIDE` |
| `student_card_delete()` | egasi | `{ok, deleted, photo_path}` (ilova Storage obyektini o‘chiradi) |
| `admin_student_card_hide(p_student, p_hide=true, p_reason)` | `identity_admin` (+MFA) | `{ok, found}`; audit `STUDENT_CARD_HIDE/UNHIDE` |

**Matn filtri** (`private.student_card_text_ok`, ism va bio): rad — `http`, `://`, `www`,
domen oxiri (`.com/.uz/.ru/.me/.org/...`, bo‘shliqli ham), `@` (email, @username, to‘liq
kenglikdagi `＠`), tarmoq nomlari (telegram, instagram, whatsapp, tiktok, snapchat, facebook,
youtube, viber, discord, wechat, skype, tg, t.me, kirillcha variantlari), telefon (`+raqam`,
9+ raqamli guruh, 7+ raqam va 2 dan boshqa guruh soni; «2024-2025» o‘tadi). Boshqaruv
belgilari rad (bioda `\n` mumkin). Dart nusxasi: `StudentCardText`
(`lib/domain/student_card/student_card.dart`) — mijozda tez xato; asosiy to‘siq — SERVER.
**Cheklov:** so‘z bilan yozilgan raqam/«dot com» va shaxsiy ismlar filtrdan o‘tadi —
qolgan himoya: shikoyat, yashirish, ustoz/admin moderatsiyasi.

**Rasm.** Xususiy bucket `student-cards` (1 MB, jpeg/png/webp), yo‘l
`<uid>/photo-<uuid>.<ext>`. Storage RLS: yozish — faqat egasi (nom regex’i, ko‘pi bilan 4
obyekt); o‘qish — egasi YOKI yuqoridagi ko‘rinish qoidasidan o‘tgan ko‘ruvchi va faqat
kartadagi **joriy** rasm (o‘zi yashirgan/guruhdan yashirilgan/admin yashirgan/guruhdan
chiqqan holda rasm ham yopiladi); o‘chirish — egasi; yangilash siyosati yo‘q. Ommaviy
bucket va imzolangan URL ishlatilmaydi (ustoz kartasi bilan bir xil qaror).

**Hisob o‘chirish:** jadval qatorlari cascade (karta, ikki yo‘nalishdagi yashirishlar, guruh
yashirishlari); Storage obyektlari `supabase/functions/delete-account/index.ts` da
(`student-cards` bucket ro‘yxatga qo‘shildi, **faqat kod — deploy qilinmagan**).

**Ilova.**
- Profil → «Talaba kartam» (kirgan har qanday hisob + xizmat ulangan) → `StudentCardScreen`
  (`/profile/student-card`): rasm (mavjud `GalleryAvatarPicker` + `AvatarCropScreen`,
  `fitTeacherImage` 1 MB gacha), ism/taxallus (2–40), «o‘zim haqimda» (150), qoida banneri
  («havola, telefon, email, @username, tarmoq nomini yozmang»), rozilik kaliti (DEFAULT
  o‘chiq), «Ko‘rish», «Kartani saqlash», «Kartani o‘chirish». Havola/URL maydoni YO‘Q.
  Matnda aloqa ma’lumoti bo‘lsa maydon ostida darhol xato va saqlash to‘xtaydi.
- Guruh sahifasi: talaba ko‘rinishida «Guruhdoshlar» (faqat ko‘rinadigan kartalar; karta
  yo‘q bo‘lsa bo‘lim ham yo‘q); ustoz ko‘rinishida kartali a’zoda rasm + karta ismi (bosilsa
  oyna), kartasiz a’zo avvalgidek. Oyna (`showStudentCardSheet`): faqat o‘qish +
  «Kartaga shikoyat qilish» (mavjud «Taklif va murojaatlar», `related_entity =
  student_card:<id>`), «Bu kartani yashirish» (o‘zim uchun) va ustozga «Guruhdan yashirish /
  Guruhga qaytarish». «Yashirilgan kartalar» bo‘limi (mazmunsiz «Yashirilgan karta ·
  Qaytarish»). Egasiga: admin yoki ustoz yashirgani haqida banner.
- Fayllar: `lib/domain/student_card/`, `lib/domain/ports/student_card_ports.dart`,
  `lib/data/remote/supabase_student_card.dart`, `lib/data/student_card/` (test/demo «server»),
  `lib/app/student_card.dart`, `lib/features/student_card/`. `TeacherImageKind` va
  `fitTeacherImage` ustoz kartasidan qayta ishlatiladi.
- L10n: `apps/mobile/tool/l10n_student_card.py` (63 kalit uz/ru/en + `privacySummary`ga bir
  gap), so‘ng `flutter gen-l10n`; CLAUDE.md tartibida `l10n_teacher_card.py` dan keyin.
  Yangi kontent avval o‘zbekcha mukammal (2026-10-12 qarori): ru/en matnlari ham bor,
  keyingi haftada tekshiriladi.

## Do‘kon moderatsiya talablari

**Apple App Store 1.2 (User-Generated Content)** va **Google Play UGC siyosati** — bir xil
to‘rt talab:

| Talab | Bajarilishi |
|---|---|
| 1. Nomaqbul kontentni filtrlash | Server matn filtri (aloqa ma’lumoti, havola, telefon — rad); rasm 1 MB, xususiy bucket; DEFAULT yashirin, faqat guruh doirasi |
| 2. Shikoyat mexanizmi va o‘z vaqtida javob | Karta oynasida «Kartaga shikoyat qilish» → mavjud support oqimi → admin inbox; admin kartani darhol yashira oladi (`admin_student_card_hide`) |
| 3. Haqoratlovchi foydalanuvchini bloklash | «Bu kartani yashirish» (har bir ko‘ruvchi o‘zi uchun, serverda, qaytariladi, rasm ham yopiladi); ustoz «Guruhdan yashirish»; talaba guruhdan chiqsa ko‘rinish to‘xtaydi; ustoz a’zoni guruhdan chiqara oladi |
| 4. Ko‘rinadigan aloqa ma’lumoti | Ilovada shikoyat/yashirish bevosita karta oynasida; maxfiylik siyosatida (7c) qoidalar va aloqa e’lon qilingan; **foydalanuvchining o‘z aloqa ma’lumoti kartada YO‘Q** (filtr) |

Qo‘shimcha: karta ommaviy emas, layk/obuna yo‘q; kontent egasi uni o‘chira oladi; admin
amallari audit log’da; ustoz amallari `private.student_card_audit` da. Tekshiruvchi uchun
inglizcha izoh va yosh reytingi eslatmalari: `docs/DATA_SAFETY_STUDENT_CARD.md`.

**App Review Notes (qisqa):** «Student card is optional, off by default and visible only to
members and the teacher of the student's own groups (never public; no links/likes/followers).
The server rejects links, e-mail, @usernames, phone numbers and social-network names. Every
viewer can report a card (flag → in-app support request) and hide it for themselves
(restorable); the group teacher can hide it from the group (audited); an administrator can
hide it entirely and the owner cannot re-enable a moderated card. The card and its photo are
deleted with the account. Test: two student accounts and one teacher account in one group →
Profile → My student card.»

**Yosh reytingi:** UGC mavjud (yopiq guruh ichida, moderatsiyali) — Apple anketasida
User-Generated Content = Ha (reyting kamida 12+ bo‘lishi mumkin), Play Content rating’da
ham UGC = Ha. Ilova 13 yoshgacha bolalarga mo‘ljallanmagan; aks holda funksiya o‘chirilishi
shart (yosh tasdig‘i hozir yo‘q). Qaror — egasi (`docs/DATA_SAFETY_STUDENT_CARD.md`).

## Qo‘llash tartibi (faqat egasi ruxsati bilan)

1. `supabase/tests/run_local.sh` (lokal PG 16) — o‘tgan.
2. Production DB: **avval ustoz kartasi migratsiyasi** (`20261031020000`) qo‘llanganini
   tekshiring (bu migratsiya unga bog‘liq EMAS, lekin `class_groups` va `admin_guard`ga bog‘liq —
   ular production’da bor). So‘ng `20261031040000_student_card.sql` (additiv; mavjud jadvallarga
   tegmaydi). Keyin: `student-cards` bucket `public=false`, 1 MB; `storage.objects`da 3 ta
   `student_cards_*` siyosat; `get_advisors` (security) — yangi ogohlantirish yo‘qligini tekshiring.
3. Edge function `delete-account` deploy (yangi bucket ro‘yxati; ustoz kartasi bilan bitta deploy
   yetadi) — ilova chiqishidan OLDIN.
4. `docs/legal/privacy.html` qayta joylash; do‘kon deklaratsiyalari va yosh reytingi:
   `docs/DATA_SAFETY_STUDENT_CARD.md`.
5. Ilova build/yangi versiya (build raqami bu branchda o‘zgartirilmagan).
6. Smoke (haqiqiy hisoblar bilan): talaba A kartani to‘ldiradi → guruhdosh B ko‘rmaydi → A kalitni
   yoqadi → B ko‘radi, rasm ochiladi → B «Yashirish» → B ko‘rmaydi, A hamon ko‘rinadi C ga →
   B qaytaradi → B shikoyat qiladi → ustoz «Guruhdan yashirish» → B ko‘rmaydi, ustoz ko‘radi →
   admin yashiradi → A o‘chiradi. Aloqa ma’lumotli matn (t.me, @ali, +998…) rad etilishini tekshiring.

## Qaytarish

- Ilova: oldingi build (karta bo‘limi ko‘rinmaydi; server bilan mos).
- Server: `supabase/rollback/20261031040000_student_card_down.sql` (avval bucket ichini
  Storage API/dashboard’da bo‘shating). Talaba kartalari, yashirishlar va rasmlar **o‘chadi**.
- `delete-account` — oldingi versiyaga qaytarish xavfsiz (faqat `student-cards` papkalari
  tozalanmay qoladi; keyin qo‘lda).

## Testlar

- SQL (`supabase/tests/run_local.sh`, lokal PG 16, butun to‘plam exit 0):
  `student_card_test.sql` — 189 PASS (ko‘rinish matritsasi: egasi / guruh ustozi / guruhdosh /
  boshqa guruh talabasi / boshqa ustoz / guruhsiz / anon; visible=false; admin yashirishi va
  qayta yoqib bo‘lmasligi; «o‘zim uchun yashirish» (boshqalarga ta’sir qilmaydi, qaytarish,
  aloqasiz rad, 500 chegara, rasm ham yopiladi); ustoz guruh moderatsiyasi (faqat guruh ustozi,
  boshqa guruhda hamon ko‘rinadi, egasi qayta yoqa olmaydi, audit); matn filtri 38 holat +
  upsert; hajm 40/150; guruhdan chiqish; cascade (hisob/guruh); bucket/siyosatlar),
  `student_card_storage_test.sql` — 37 PASS (Storage RLS), RLS role-matrix’ga 4 jadval qo‘shildi.
- Dart: `test/unit/student_card_test.dart` (63: matn filtri, draft chegaralari, modellar, fake
  server qoidalari, Supabase adapter), `test/widget/student_card_test.dart` (19: rozilik DEFAULT
  o‘chiq, URL maydoni yo‘q, aloqa filtri, faqat ko‘rinadigan kartalar, oyna, shikoyat oqimi,
  yashirish/qaytarish, ustoz moderatsiyasi, 320 dp + 1.6× matn). `flutter analyze` — toza.
  Kengroq to‘plam (architecture, l10n, arb parity, guards, teacher_card, class_groups,
  anti_cheat_group, support_admin) — 251 o‘tdi.

## Sinalmagan / ochiq qolganlar

- HAQIQIY Supabase va Storage: migratsiya production’da qo‘llanmagan; Storage API so‘rovlari
  faqat soxta transport bilan sinalgan.
- Haqiqiy qurilma (iOS/Android), galereyadan rasm tanlash/ruxsatlar; ilovaning haqiqiy
  STUDENT/EXPERT/ADMIN rejimlarida qo‘lda sinovi (faqat widget testlar).
- `delete-account` edge function deploy qilinmagan va haqiqiy hisob bilan sinalmagan.
- Admin ekranida «kartani yashirish» tugmasi YO‘Q: hozir faqat `admin_student_card_hide` RPC
  (SQL konsol/service). Shikoyatlar mavjud «Taklif va murojaatlar» inbox’iga tushadi.
- Matn filtri sodda (so‘z bilan yozilgan raqam, bo‘shliq/belgilar bilan buzilgan havola, ism
  ichidagi shaxsiy ma’lumot ushlanmaydi) — moderatsiya vositalariga tayanadi. Rasm mazmuni
  avtomatik tekshirilmaydi (faqat shikoyat/yashirish).
- Ustozning «guruhdan yashirish» natijasi talabaga faqat banner bilan ma’lum qilinadi
  (sabab ko‘rsatilmaydi); `p_reason` ilovadan hozircha yuborilmaydi.
- Demo/test rejimida (`Fake*`) karta xizmati ulanmagan: release’da Supabase bo‘lmasa bo‘lim
  ko‘rinmaydi.
- Yosh tasdig‘i (age gate) YO‘Q; 13 yoshgacha foydalanuvchilar uchun alohida qaror kerak.
