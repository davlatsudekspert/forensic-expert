# «Sinfda test» (Kahoot uslubidagi jonli sinf testi)

Yangilangan: 2026-10-17. Branch: `claude/class-quiz`. Holat: kod + migratsiya fayli + testlar tayyor;
**production DB'ga QO'LLANMAGAN**, edge function yo'q, bayroq yo'q (funksiya ochiq va bepul).

## 1. Oqim

1. **Ustoz** (server rolli hisob) «O'quv rejimi → Sinfda test → Yangi sinf testi»: mavzu, savollar soni (5–20),
   talaba chegarasi (5–200), har savolga vaqt (15/30/45/60 s).
2. Ilova proyektorga mos (to'q fon, 16:9 landshaft) ekranda **6 xonali kod** va **QR** ko'rsatadi.
3. **Talaba** (kirgan hisob) kodni qo'lda kiritadi (yoki QR skanerlaydi — ixtiyoriy), **laqab** (2–20 belgi) yozadi.
   Server `user_id` bilan bog'laydi; ustozga **faqat laqab** ko'rinadi.
4. Ustoz «Boshlash», keyin «Keyingi savol» (yoki «Savolni yopish»). Vaqt tugashi **server vaqti** bilan.
5. Ustozda jonli: nechta qo'shildi, nechta javob berdi, to'g'ri foizi, eng qiyin savollar, reyting (laqab+ball).
6. Tugagach talaba natijasi + xato savollar tushuntirishi va **manbasi**; ustoz CSV ulashadi
   (`laqab,ball,togri_soni,javob_vaqti_s`; fayl nomi ASCII: `sinf_test_123456_2026-10-17.csv`).
7. Tugagach **30 kundan keyin** sessiya, ishtirokchilar, javoblar avtomatik o'chadi.

## 2. Egasi qarori (2026-10-17): hozircha faqat KOD

Domen yo'q. Shuning uchun:
* Qo'shilish — **6 xonali kodni qo'lda kiritish** (asosiy, mukammal qilingan oqim).
* QR ichida `forensicexpert://app/join/<kod>` (ilova sxemasi) — ixtiyoriy qulaylik. Android'da shu sxema uchun
  intent-filter bor, iOS'da `forensicexpert` sxemasi allaqachon ro'yxatda. Ilova ichida `/join/:code` route ham bor.
* Ilova ichidagi QR skaner (`mobile_scanner`) ixtiyoriy: faqat Android/iOS'da tugma ko'rinadi; ruxsat rad etilsa
  qo'lda kiritishga yo'naltiradi.
* **Universal link / App Link / AASA / assetlinks YOZILMAGAN.**

### Keyingi qadam: domen tayyor bo'lganda
1. Domen oling; `https://<domen>/.well-known/apple-app-site-association` (paths: `/join/*`, `/invite/*`) va
   `/.well-known/assetlinks.json` (SHA-256 imzo barmoq izi) joylang.
2. iOS: Associated Domains (`applinks:<domen>`) entitlement; Android: `https` + `autoVerify` intent-filter
   (`pathPrefix="/join/"`).
3. Build'ga `--dart-define=FE_REFERRAL_BASE_URL=https://<domen>` bering va `classJoinLinkProvider`
   (`lib/app/class_quiz.dart`) da `ClassCode.joinLink(code, publicBase: …)` ni yoqing (funksiya tayyor, testlangan).
4. Veb zaxira sahifa `/join/<kod>`: ilova o'rnatilmagan bo'lsa do'kon havolasi + «Kodni ilovada kiriting».

## 3. Rol: ustoz

Mavjud rol tizimida «ustoz» yo'q edi (`identity_admin`, `scope_grantor`, `publication_moderator`; «expert» —
tasdiqlangan mutaxassis, ustoz emas). Shuning uchun `account_role` ga **`teacher`** qiymati qo'shildi.
Faqat server tomonida: egasi SQL konsolda beradi (audit trigger `ROLE_GRANTED` yozadi); email mosligi huquq bermaydi.
`identity_admin` ham sinf o'tkaza oladi. Rol har chaqiruvda qayta tekshiriladi (olib tashlansa — darrov 403).

```sql
insert into public.account_roles (user_id, role)
select id, 'teacher' from auth.users where email = '<ustoz emaili>';
-- olib tashlash: delete from public.account_roles where user_id = '<uuid>' and role = 'teacher';
```

## 4. Migratsiya va RPC

Fayl: `supabase/migrations/20261017010000_class_quiz.sql` (rollback: `supabase/rollback/20261017010000_class_quiz_down.sql`).
Jadvallar: `class_quiz_questions` (savol banki), `class_sessions`, `class_session_questions` (sessiyaga nusxa,
variantlar serverda aralashtirilgan), `class_participants`, `class_answers`, `class_reports`, `class_join_attempts`.

| RPC | Kim | Vazifa |
|---|---|---|
| `class_status()` | kirgan | `{is_teacher}` |
| `class_topics()` | ustoz | mavzular + savollar soni |
| `class_create_session(topic, n, limit, seconds)` | ustoz | sessiya, 6 xonali kod (CSPRNG), savollarni nusxalash |
| `class_my_sessions()` | ustoz | oxirgi 20 sinf |
| `class_join_session(code, nickname)` | kirgan | chegara, holat, laqab filtri, takror laqab (`ali2`), rate limit |
| `class_start / class_next / class_close_question / class_finish(session)` | egasi ustoz | holat boshqaruvi |
| `class_kick(session, participant)` | egasi ustoz | talabani chiqarish (qayta kira olmaydi) |
| `class_submit_answer(session, index, option)` | a'zo talaba | bir marta, vaqt ichida; **to'g'ri/noto'g'ri qaytarilmaydi** |
| `class_session_state(session)` | a'zo talaba | holat, savol (to'g'ri javobsiz), o'z balli |
| `class_teacher_dashboard(session)` | egasi ustoz | jonli agregatlar |
| `class_my_results(session)` | a'zo, tugagach | savollar bo'yicha natija, izoh, manba |
| `class_export_results(session)` | egasi ustoz | CSV uchun qatorlar |
| `class_report_nickname(session, participant, reason)` | a'zo/ustoz | UGC shikoyat |

**Muhim server qoidalari**
* Barcha jadval: RLS yoqilgan, jadval huquqi yo'q (`revoke … from anon, authenticated`); faqat `SECURITY DEFINER`,
  `search_path = ''` RPC. Himoya qatlami: tasodifan huquq berilsa ham siyosatlar faqat o'z qatorini ochadi
  (ustoz — o'z sessiyasi, talaba — o'z ishtirokchi/javob qatori); savollar jadvallariga siyosat umuman yo'q.
* Huquq xatosi → SQLSTATE `42501` (PostgREST: HTTP **403**). Kutilgan xatolar (`not_found`, `full`, …) `{ok:false,error}`
  qaytaradi (EXCEPTION emas) — shunda urinish hisoblagichi rollback bo'lmaydi.
* **Kod taxmini:** foydalanuvchi bo'yicha va (bor bo'lsa) IP (`x-forwarded-for` md5) bo'yicha soatiga 30 urinish.
* **Vaqt:** `question_started_at` + `seconds`. Javob muddat+1 s gacha qabul; to'g'ri javob muddat+1.5 s dan keyin
  ochiladi. Ball: to'g'ri bo'lsa `500 + 500·(limit−o'tgan)/limit` (butun bo'lish), noto'g'ri — 0 (mijoz `ClassScoring` bilan bir xil).
* Qo'shilish faqat lobby'da (boshlangandan keyin faqat avval a'zo bo'lganlar qayta kiradi).
* Ustozning o'z sinfiga talaba sifatida qo'shilishi rad (`own_session`); ochiq sinflar ≤ 10.
* Proyektor: ochiq savol paytida ustoz ekrani to'g'ri javob va variant sonlarini **ko'rsatmaydi** (talabalar ko'rib qolmasin).

### 30 kunlik tozalash
`private.class_cleanup()` tugagan va muddati o'tgan (`expires_at`) sessiyalarni o'chiradi (cascade), 24 soatdan oshgan
tugatilmagan sessiyalarni yopadi, eski urinish yozuvlarini tozalaydi. `class_create_session` uni zaxira sifatida chaqiradi.
**Rejalash (egasi, pg_cron yoqilgach; migratsiya BAJARMAYDI):**
```sql
select cron.schedule('class_quiz_cleanup', '17 3 * * *', $$select private.class_cleanup()$$);
```

## 5. Savol banki: import formati

Savollar `class_quiz_questions` ga yoziladi (mijozga huquq yo'q; faqat egasi/service role). **`tools/slides/out/*.json` dagi
`mcq[i]` bilan bir xil shakl:**
```json
{"question": "…", "options": ["a","b","c","d"], "correct_index": 2,
 "explanation": "…", "source": {"author": "…", "title": "…", "page": "…"}}
```
Qoidalar: aniq 4 variant; `correct_index` 0–3; `source.author/title/page` majburiy (manbasiz savol bankka kirmaydi —
`ClassBankQuestion.tryParse` ham, SQL CHECK ham). Mavzu: `topic_id` (matn), `topic_title`.
Import namunasi (JSON fayl → SQL):
```sql
insert into public.class_quiz_questions (topic_id, topic_title, position, question, options, correct_index, explanation, source)
select 'mavzu-id', 'Mavzu nomi', ord::int, q->>'question', q->'options', (q->>'correct_index')::int,
       coalesce(q->>'explanation',''), q->'source'
from jsonb_array_elements('<mcq JSON massivi>'::jsonb) with ordinality t(q, ord);
```
ABY asosidagi savollar CLAUDE.md qoidalariga bo'ysunadi (so'zma-so'z iqtibos yo'q, aniq joyi bilan, faqat o'zbekcha).
Hozir ilovada slayd/test kontenti yo'q (`tools/slides/out` bo'sh), shuning uchun **DEMO** fixture:
`lib/data/class_quiz/class_quiz_demo_bank.dart` — 10 ta oddiy umumiy savol, hammasi «DEMO» belgili, ilmiy manba emas.

## 6. Realtime tanlovi: 2 s polling

Tanlandi: **polling** (`class_teacher_dashboard`, `class_session_state` har ~2 s; Realtime — zaxira emas, kerak emas).
Sabab: (1) ilova SDK'siz REST mijoz (arxitektura testi vendor SDK'ni `data/remote` dan tashqarida taqiqlaydi);
(2) jadvallar yopiq (RLS siyosatsiz) — `postgres_changes` hodisalari yetib bormaydi, ularni ochish to'g'ri javobni sizdirish
xavfini tug'diradi; (3) polling oddiy, qayta ulanishda o'zi tiklanadi. Yuk: 200 talaba ≈ 100 so'rov/s eng yomon holatda
(bitta engil RPC) — bir sinf uchun yetarli; ko'p sinf bir vaqtda bo'lsa Realtime Broadcast «tick» (faqat «yangila» signali,
ma'lumotsiz) keyingi optimallashtirish. Mijoz: `classQuizPollIntervalProvider`.

## 7. Xavfsizlik / Apple (UGC 1.2) / maxfiylik

* Laqab = foydalanuvchi kontenti: (1) mijoz va server filtri (uzunlik, belgilar, qisqa nomaqbul ro'yxat), (2) ustoz
  «Chiqarish» (qayta kira olmaydi), (3) talaba/ustoz shikoyati (`class_reports`; ustozga soni ko'rinadi, egasi SQL'da ko'radi).
  Ro'yxat `private.class_nick_check` va `ClassNickname` da bir xil; tahrirlashda ikkalasini birga yangilang.
* To'g'ri javob ochiq savol paytida hech qaysi mijozga kelmaydi (SQL testi: payload'da `correct_option|my_correct` yo'q).
* Ustozga ism/email/user_id ko'rinmaydi (testlar: dashboard/export matnida `@` va UUID yo'q).
* **Privacy matniga qo'shiladigan jumla (egasi tasdiqlagach `LegalDocument.privacy` ga):**
  «Sinfda test: ustoz tashkil qilgan sinfga qo'shilganingizda siz kiritgan laqab, javoblaringiz va ballingiz serverda
  hisobingizga bog'liq holda saqlanadi. Ustoz va boshqa ishtirokchilar faqat laqabingizni ko'radi. Ma'lumotlar test
  tugagach 30 kundan keyin avtomatik o'chiriladi. Kamera faqat QR kodni o'qish uchun ishlatiladi; tasvir saqlanmaydi.»
* **EULA/Terms:** UGC bandiga «sinf laqabi» qo'shilsin: nomaqbul laqab ustoz tomonidan olib tashlanadi, takroriy buzuvchi
  hisob cheklanishi mumkin. Apple App Privacy: «User Content», «User ID» (ilova funksiyasi, trekingsiz). Google Play
  Data safety: «App activity» (test javoblari), 30 kunda o'chiriladi. Bu matnlar hali ilova ichidagi hujjatlarga KIRITILMAGAN
  (feature-freeze; egasi tasdig'i kerak).
* Kamera: iOS `NSCameraUsageDescription`, Android `CAMERA` (+ `uses-feature … required=false`).

## 8. Egasining qo'lda ishlari

1. Migratsiyani ko'rib chiqib production'ga qo'llash (`supabase db push`) — **bu agent qo'llamadi**.
2. Ustoz rolini berish (§3).
3. Savol bankini import qilish (§5) — aks holda ustoz «savollar banki yo'q» ko'radi.
4. pg_cron'ni yoqib tozalashni rejalash (§4).
5. Privacy/Terms matni, App Privacy/Data safety (§7).
6. Domen/AASA/assetlinks — keyinga qoldirildi (§2).
7. Real qurilmada sinov (QR kamera, ikki telefon, proyektor/AirPlay).

## 9. Test holati

Qarang `docs/TEST_REPORT.md` (Sinfda test bo'limi). SQL: `supabase/tests/class_quiz_test.sql`
(`bash supabase/tests/run_local.sh`). Dart: `test/unit/class_quiz*_test.dart`, `test/widget/class_quiz_test.dart`.
Sinalmagan: real backend, real kamera/QR, real telefon, iOS, universal link, proyektor.
