# Talaba kartasi — do‘kon deklaratsiyalarini yangilash (2026-10-31)

Yangi funksiya (1-bosqich): har qanday kirgan foydalanuvchi ixtiyoriy ravishda
**ism yoki taxallus (2–40), 150 belgigacha matn va rasm** kiritadi. Ma’lumot serverda
saqlanadi va **faqat o‘sha foydalanuvchi bilan umumiy guruhdagi a’zolarga va shu
guruh ustoziga** ko‘rinadi (standart holat — yashirin, alohida rozilik kaliti).
Havola, aloqa ma’lumoti, layk, obuna va ommaviy ko‘rinish YO‘Q. Hisob o‘chirilganda
karta, yashirishlar va rasm o‘chadi. Reklama/kuzatuv yo‘q, uchinchi shaxsga uzatilmaydi
(Supabase — ma’lumot qayta ishlovchi, Frankfurt).

> Ilova do‘konga yuborilishidan OLDIN deklaratsiyalar yangilanadi (Apple 5.1.1, Play
> Data safety). Quyidagi jadval FARQNI beradi; mavjud qatorlarga (email, murojaatlar,
> ustoz kartasi, …) tegmang. Talabalar voyaga yetmagan bo‘lishi mumkin — pastdagi
> «Yosh reytingi» bandiga qarang.

## Google Play — Data safety

| Ma’lumot turi (Play toifasi) | Yig‘iladimi | Ulashiladimi* | Ixtiyoriymi | Maqsad | Tranzitda shifrlanadi | O‘chirish |
|---|---|---|---|---|---|---|
| Personal info → **Name** (karta ismi/taxallusi) | Ha | Yo‘q | **Ha** | App functionality | Ha (TLS) | Ilovada: «Kartani o‘chirish» yoki «Hisobni o‘chirish» |
| Photos and videos → **Photos** (karta rasmi) | Ha | Yo‘q | **Ha** | App functionality | Ha | Xuddi shunday (fayl ham o‘chadi) |
| App activity → **Other user-generated content** («o‘zim haqimda» matni; kartani yashirish/shikoyat belgilari) | Ha | Yo‘q | **Ha** | App functionality | Ha | Xuddi shunday |

\* Karta ilova ichida o‘sha guruhning a’zolariga va ustoziga ko‘rinadi — bu Play ta’rifi
bo‘yicha «ulashish» (uchinchi tomonga uzatish) emas, foydalanuvchi kontenti.

Boshqa javoblar o‘zgarmaydi. «O‘chirishni so‘rash yo‘li» — ilova ichida (Profil → Hisobni
o‘chirish; Profil → Talaba kartam → Kartani o‘chirish).

## Apple — App Privacy

| Tur | Ma’lumot | Foydalanuvchiga bog‘liq | Kuzatuv (tracking) | Maqsad |
|---|---|---|---|---|
| Contact Info | **Name** (karta ismi/taxallusi) | Ha | Yo‘q | App Functionality |
| User Content | **Photos or Videos** (karta rasmi) | Ha | Yo‘q | App Functionality |
| User Content | **Other User Content** (matn) | Ha | Yo‘q | App Functionality |

«Data Used to Track You» — hech narsa (o‘zgarmaydi).

## Yosh reytingi va bolalar maxfiyligi (egasi hal qiladi)

- Ilova talabalar uchun; ba’zi foydalanuvchilar 18 yoshgacha bo‘lishi mumkin. Shuning uchun
  karta **minimal**: faqat ism/taxallus, qisqa matn va ixtiyoriy rasm; havola, telefon,
  email, @username, ijtimoiy tarmoq nomi server tomonida RAD etiladi; karta DEFAULT
  yashirin; ommaviy emas; faqat umumiy guruh doirasida.
- Apple yosh reytingi anketasida «User-Generated Content» = Ha (karta matni/rasmi,
  moderatsiya bilan), «Unrestricted Web Access» = Yo‘q (karta havola ochmaydi). Reyting
  kamida **12+** (UGC) bo‘lishi mumkin — App Store Connect anketasini egasi to‘ldiradi.
- Google Play: «Content rating» anketasida foydalanuvchi kontenti almashinuvi = Ha
  (yopiq guruh ichida, moderatsiya bor). **Families / Designed for Children** dasturiga
  kiritilMAGAN ilova ekanini saqlang (maqsadli auditoriya 13+; aniq qarorni egasi beradi).
- Agar maqsadli auditoriya 13 dan kichik bolalarni qamrasa, karta funksiyasi (rasm + matn)
  o‘chirilishi kerak (COPPA/GDPR-K) — bu holda ilovaga yosh tasdig‘i kerak, hozir YO‘Q.

## UGC moderatsiyasi (Apple 1.2 / Play User Generated Content)

| Talab | Qanday bajarilgan |
|---|---|
| Nomaqbul kontentni filtrlash | Server matn filtri (`private.student_card_text_ok`): havola, domen, `t.me`, `@`, telefon, tarmoq nomi — rad. Rasm — ixtiyoriy, 1 MB, xususiy bucket |
| Shikoyat qilish | Karta oynasida «Kartaga shikoyat qilish» → «Taklif va murojaatlar» (`student_card:<id>`) → admin inbox |
| Foydalanuvchini bloklash/yashirish | «Bu kartani yashirish» (har bir ko‘ruvchi o‘zi uchun, server RPC, qaytarish bor); yashirilgan karta va rasm unga hech qachon ko‘rinmaydi |
| Tezkor choralar | Guruh ustozi: «Guruhdan yashirish» (audit jurnali); admin: `admin_student_card_hide` (audit log). Egasi bunday kartani o‘zi qayta yoqa olmaydi |
| Aloqa ma’lumoti ko‘rinadi | Ilovada «Shikoyat»/«Yashirish» bevosita karta oynasida; moderatsiya aloqasi: davlatsudekspert@gmail.com (maxfiylik siyosatida) |
| Kontent egasi o‘chirishi | Kartani o‘chirish / hisobni o‘chirish — rasm bilan |

## App Review Notes (inglizcha, qisqa)

> «Student card» is optional, off by default, and visible only to members and the teacher
> of the groups the student belongs to (never public). It has no links, likes or followers.
> The server rejects links, e-mail, @usernames, phone numbers and social-network names in
> the name/bio fields. Every viewer can report a card (flag → in-app support request) and
> hide it for themselves (restorable); the group teacher can hide it from the group
> (audited); an administrator can hide it entirely, and the owner cannot re-enable a
> moderated card. The card and its photo are deleted with the account (Profile → Delete
> account) or on demand. Test: sign in with the provided student accounts that share a
> group → Profile → My student card (turn on) → open the group page as the other student.»

## Ichki tekshiruv ro‘yxati

- [ ] Play Console → App content → Data safety: 3 qator qo‘shildi, yuborildi.
- [ ] App Store Connect → App Privacy: 3 qator qo‘shildi; yosh reytingi anketasi yangilandi.
- [ ] `docs/legal/privacy.html` qayta joylandi (uz/ru/en, 7c-bo‘lim).
- [ ] App Review Notes ga izoh qo‘shildi; tekshiruvchiga bir guruhdagi ikkita talaba va bitta ustoz akkaunti berildi.
- [ ] Ilova ichidagi `privacySummary` (uz/ru/en) yangilandi — `tool/l10n_student_card.py` bajaradi.
- [ ] Ayrim «Foydalanish shartlari» sahifasi repoda YO‘Q; karta qoidalari maxfiylik siyosatining 7c-bo‘limida va ilova ichida (rozilik matni + qoida bannerida).
