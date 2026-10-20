# Apple 4.3 / 4.2.6 — Resolution Center javobi (2026-10-20)

Apple: "agar ilova talabga mos deb hisoblasangiz, QAYTA YUBORMANG — xabarga javob bering".
Shuning uchun: build/versiyani qayta yubormaymiz, Resolution Center'da **Reply** bosib quyidagini yuboramiz.

`[EGASI: …]` — faqat egasi biladigan joylar, yuborishdan oldin to‘ldiring yoki o‘chiring.

---

Hello App Review team,

Thank you for the review. We believe FORENSIC EXPERT is neither a duplicate, a template-based nor an app-generator product, and we answer your questions below.

**1. What the app does and the problem it solves**
FORENSIC EXPERT is a sourced reference and teaching toolkit for forensic medicine and forensic toxicological chemistry, built from university textbooks used in Uzbekistan. It has three parts:
- *Reference library:* about 140 substance records (properties, analytical methods, metabolites, specimens), 18 analytical methods/SOPs, 76 reagents and solutions, a 115-term glossary and calculators with explicit formulas and limits. Every statement shows its source and page and a review status; content not yet checked by an expert is labelled "Needs review" and is never presented as verified.
- *Teacher toolkit:* lecture decks with a projector mode (view-only, source and page on every slide); a live class quiz where the teacher shows a code/QR on the classroom screen and students answer from their phones with a live leaderboard; groups with topic tests, where each student gets a different question variant and the server scores the result.
- *Student study:* flashcards, self-check quizzes and an exam mode, each question with explanation and source.
The problem: Uzbek-language forensic teaching material exists mostly as scattered printed textbooks and PDFs. Students cannot quickly find sourced analytical data, and lecturers have no tool to present a lecture and check understanding in the same classroom session. `[EGASI: tasdiqlang]`

**2. Intended users**
Students of forensic medicine and toxicological chemistry at medical and pharmaceutical universities; their lecturers; and practising forensic experts and laboratory chemists who need quick sourced reference data. Primary language is Uzbek, with Russian and English interface.

**3. Gap in the market**
We searched the App Store and found no app that combines forensic toxicological chemistry/forensic medicine content in Uzbek with classroom tools. The toxicology apps we found are English-language clinical poison/antidote references (for example "5 Minute Toxicology Consult" and the ACEP antidote app); none offers sourced lecture decks, a QR-based live class quiz, or per-student question variants for a group. Our differentiators are: source and page on every statement, explicit review status, the teacher/classroom workflow, and Uzbek-language content.

**4. Beta testing**
The app went through repeated TestFlight builds (0.3.0, many builds, latest build 303) and Google Play internal testing. Examples of feedback applied to production:
- Lecture slides did not fit on one projector screen → we rebuilt the viewer on a fixed 16:9 canvas with automatic splitting of long slides.
- Class-quiz testing exposed nine defects (scores visible before reveal, rate limit counting successful joins, rejoin after finish, different answer order on phone and projector, etc.) → all fixed.
- The "Close test" button was hidden behind the floating navigation bar → moved to the app bar.
- A duplicated year in source references → fixed.
`[EGASI: tashqi test qilganlar bo‘lsa — nechta ustoz/talaba va ularning haqiqiy fikrlari]`

**5. Standalone or suite?**
Standalone product. `[EGASI: akkauntda boshqa ilovalar bor-yo‘qligini tasdiqlang; bo‘lsa — har birining farqini yozing]`

**6. Could it be delivered inside another app on our account?**
No. `[EGASI: tasdiqlang]` There is no other app on the developer account with this subject matter.

**7. Shared code or assets with other apps on the account?**
None beyond standard open-source packages. `[EGASI: tasdiqlang]`

**8. Shared codebase, SDK or content library with a third-party app?**
No. The app is our own Flutter codebase with our own Supabase backend; only standard third-party packages are used. The content is our own structured adaptation of cited university textbooks, with the exact source and page shown.

**9. Created for a client / template or app-generation service?**
No. It was not created for a client and not built from a template or an app-generation service. It is submitted by the developer who is also the content provider, a practising forensic expert. `[EGASI: tasdiqlang]`

For your convenience the demo account (teacher role) in App Review Information shows the Lessons, Class quiz and Groups features that differentiate the app. We are glad to provide any further information.

Thank you.

---

## Eslatma egasi uchun
- Javobni **Resolution Center → Reply** orqali yuboring; yangi build yoki versiya yubormang.
- 5, 6, 7, 9-javoblar faqat siz biladigan faktlar — ishonch hosil qilib tasdiqlang. Noto‘g‘ri javob Apple’ni yanada qattiqlashtiradi.
- Apple mazmun huquqlarini ham so‘rashi mumkin: darsliklar muallifi/ustoz roziligi (kitoblardan foydalanish) haqidagi hujjat tayyor tursin.
