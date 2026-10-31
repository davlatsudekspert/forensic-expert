# Ustoz kartasi — do‘kon deklaratsiyalarini yangilash (2026-10-31)

Yangi funksiya: ustoz (server roli `teacher`/`identity_admin`) ixtiyoriy ravishda
**ism-familiya, ish joyi (+logotip), 300 belgigacha matn, tarmoq havolalari va rasm**
kiritadi; ma’lumot serverda saqlanadi va **faqat shu ustozning guruhlari a’zolariga**
ko‘rinadi (standart holat — yashirin, «Talabalarimga ko‘rsatish» alohida rozilik bilan).
Hisob o‘chirilganda karta va rasmlari o‘chadi. Reklama/kuzatuv yo‘q, uchinchi shaxsga
uzatilmaydi (Supabase — ma’lumot qayta ishlovchi, Frankfurt).

> Ilova do‘konga yuborilishidan OLDIN deklaratsiyalar yangilanadi; aks holda do‘kon
> deklaratsiyasi ilova xatti-harakatiga mos kelmaydi (Apple 5.1.1, Play Data safety).
> Hozirgi deklaratsiya matni bu repoda yo‘q — quyidagi jadval FARQNI (yangi qatorlarni)
> beradi; mavjud qatorlarga (email, murojaatlar, …) tegmang.

## Google Play — Data safety

| Ma’lumot turi (Play toifasi) | Yig‘iladimi | Ulashiladimi* | Ixtiyoriymi | Maqsad | Tranzitda shifrlanadi | O‘chirish |
|---|---|---|---|---|---|---|
| Personal info → **Name** (ustoz kartasidagi ism-familiya) | Ha | Yo‘q | **Ha** (faqat ustoz to‘ldirsa) | App functionality | Ha (TLS) | Ilovada: «Kartani o‘chirish» yoki «Hisobni o‘chirish» |
| Photos and videos → **Photos** (karta rasmi va ish joyi logotipi) | Ha | Yo‘q | **Ha** | App functionality | Ha | Xuddi shunday (fayllar ham o‘chadi) |
| App activity → **Other user-generated content** (ish joyi, «o‘zim haqimda», tarmoq/vebsayt havolalari) | Ha | Yo‘q | **Ha** | App functionality | Ha | Xuddi shunday |

\* Play ta’rifi bo‘yicha «ulashish» — uchinchi tomonga uzatish. Karta ilova ichida o‘sha
ustozning talabalariga ko‘rinadi, bu «ulashish» emas (foydalanuvchi kontenti). Ilovaning
o‘zida «ma’lumot uchinchi tomonga berilmaydi» deb qoladi.

Boshqa javoblar o‘zgarmaydi: «Ma’lumot shifrlanganmi» — Ha; «O‘chirishni so‘rash yo‘li» —
ilova ichida (Profil → Hisobni o‘chirish) + maxfiylik siyosatidagi elektron pochta.
**UGC siyosati (Play):** ilovada nomaqbul kontentga shikoyat (karta ustidagi bayroq →
«Taklif va murojaatlar»), administrator kartani yashira oladi; karta faqat yopiq
guruh a’zolariga ko‘rinadi, ommaviy emas.

## Apple — App Privacy («nutrition labels»)

| Tur | Ma’lumot | Foydalanuvchiga bog‘liq | Kuzatuv (tracking) | Maqsad |
|---|---|---|---|---|
| Contact Info | **Name** (ustoz kartasi) | Ha | Yo‘q | App Functionality |
| User Content | **Photos or Videos** (karta rasmi/logotipi) | Ha | Yo‘q | App Functionality |
| User Content | **Other User Content** (matn, havolalar) | Ha | Yo‘q | App Functionality |

«Data Used to Track You» — hech narsa (o‘zgarmaydi). Maxfiylik siyosati URL: o‘zgarmaydi,
lekin matn yangilangan (`docs/legal/privacy.html` 7b-bo‘lim, 2026-10-31) — qayta
joylashtiring (Pages/hosting), so‘ng App Store Connect’da «Privacy Policy URL» ni
tekshiring.

## Apple 1.2 / Play UGC — tekshiruvchiga izoh (App Review Notes uchun)

> «Teacher card» is optional and available only to accounts with the server-assigned
> teacher role. It is hidden by default and becomes visible only to members of that
> teacher's own groups after the teacher turns on an explicit consent switch. Students
> can report a card from the card itself (flag icon → in-app support request); an
> administrator can hide a card (audited) and the teacher cannot re-enable it. Links are
> restricted to https and the network's own domains and open in the external app only
> on tap. The card and its photos are deleted with the account (Profile → Delete
> account) or on demand. Test: sign in with the provided teacher account → Profile →
> My teacher card.»

1.2 bo‘yicha qolgan band: **foydalanuvchini bloklash** — talaba guruhdan chiqsa ustoz
kartasi ko‘rinmaydi (`group_leave`); alohida «ustozni bloklash» tugmasi kartaga
ulanmagan (mavjud `user_blocks` mexanizmi bor, ulash — keyingi qadam, BACKLOG).

## Ichki tekshiruv ro‘yxati

- [ ] Play Console → App content → Data safety: yuqoridagi 3 qator qo‘shildi, yuborildi.
- [ ] App Store Connect → App Privacy: 3 qator qo‘shildi, nashr etildi.
- [ ] `docs/legal/privacy.html` qayta joylandi (uz/ru/en, 7b-bo‘lim).
- [ ] App Review Notes ga izoh qo‘shildi, tekshiruvchiga ustoz akkaunti berildi.
- [ ] Ilova ichidagi `privacySummary` (uz/ru/en) yangilandi — `tool/l10n_teacher_card.py` bajaradi.
