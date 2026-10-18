# App Store — 0.3.0 (17) tekshiruvga yuborish (2026-10-18)

## 1. Demo akkaunt (ustoz funksiyalari uchun SHART)
«Darslar» va «Sinfda test»ni boshqarish faqat ustoz rolida ochiladi. Apple barcha funksiyani ko‘ra olishi kerak (2.1), shuning uchun demo akkaunt beriladi.
1. Ilovada yangi akkaunt oching: email — siz nazorat qiladigan alohida pochta (masalan `fe.appreview@gmail.com`), **parol bilan** ro‘yxatdan o‘ting, emailni tasdiqlang.
2. Claude’ga emailni yozing — u akkauntga faqat **teacher** rolini beradi (admin emas).
3. App Store Connect → App Review Information → **Sign-in required: ✔**, User name / Password — shu akkaunt.
Parolni chatga yozmang — faqat App Store Connect’ga kiriting.

## 2. Notes (inglizcha, nusxa oling)
```
Demo account (teacher role) is provided above. Sign in: Profile → Sign in →
e-mail and password.

Most of the app (substance library, methods, reagents, guideline cards,
calculators, search, study mode, AI assistant) opens without signing in.

Teacher features (only for accounts with the teacher role):
1. Lessons ("Darslar"): Profile → Teacher panel → Lessons. Search a topic,
   open a lecture, swipe/tap through slides; "Projector" shows the slide
   full-screen in landscape for a classroom screen. Slides are view-only
   (no download, no sharing). After the last slide the teacher can start a
   quiz on the same topic.
2. Class quiz ("Sinfda test"): Teacher panel → Run a test → choose a topic →
   Create. A 6-digit code and QR appear on the big screen. Students join from
   their own phones (Sinfga qo'shilish → enter code), answer timed
   multiple-choice questions; the teacher sees answers count, the correct
   answer after time is up, and a leaderboard. To try it alone, join from a
   second device with any other account.

All content is educational reference material for forensic medicine and
forensic toxicological chemistry, written from university textbooks with
the exact source and page shown on every slide and question. Controlled
substances appear only as analytical identification data (colour tests,
chromatography, spectra). No ads, no tracking, no purchases — everything is
free. Account deletion: Profile → Account → Delete account.
```

## 3. What's New
- **uz:** Ustozlar uchun «Darslar»: 200 dan ortiq ma’ruza taqdimoti, proyektor rejimi, darsdan keyin test. «Sinfda test» yaxshilandi: katta ekran, aloqa uzilganda barqaror ishlash. AI javobi bazada bo‘lmasa internetdan qidiradi (tekshirilmagan deb belgilanadi).
- **ru:** «Уроки» для преподавателей: более 200 лекционных презентаций, режим проектора, тест после урока. Улучшен «Тест в классе»: большой экран, устойчивость при обрыве связи. Если ответа нет в базе, ИИ ищет в интернете (с пометкой «не проверено»).
- **en:** Lessons for teachers: 200+ lecture decks, projector mode and a quiz after the lesson. Improved class quiz: big-screen layout and stable reconnection. When the knowledge base has no answer, the AI searches the web (labelled as unverified).

## 4. Tekshirish ro‘yxati (Submit’dan oldin)
- **Pricing and Availability → All countries or regions** (egasi qarori; bepul). Xitoy materigi AI litsenziyasi sabab rad etilsa, faqat uni olib tashlang.
- Build **0.3.0 (17)** TestFlight’da «Ready to Submit».
- Demo akkaunt ilovada kiradi va Profil’da «Ustoz paneli» ko‘rinadi.
- Privacy/Support URL: https://davlatsudekspert.github.io/forensic-expert-legal/
- «Sign-in required» belgilangan, login/parol kiritilgan.
