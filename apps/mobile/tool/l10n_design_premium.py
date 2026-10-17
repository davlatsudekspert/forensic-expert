#!/usr/bin/env python3
"""Premium dizayn (2026-10-17): yagona nomlash, «Ustoz paneli», holat chipi,
bo‘sh holatlar (uz/ru/en). Idempotent: yangi kalitlarni qo‘shadi va mavjud
kalitlar qiymatini o‘rnatadi (merge’dan keyin qayta ishga tushirilsa, shu
qiymatlar tiklanadi).

Tartib (CLAUDE.md «L10n skriptlari tartibi»): `l10n_avatar.py` dan keyin,
`l10n_ux_audit.py` dan oldin («yangi skriptlar» o‘rni), so‘ng
`flutter gen-l10n`. Ishga tushirish: apps/mobile ichida
`python3 tool/l10n_design_premium.py`.
"""
import json
import pathlib

ARB = pathlib.Path(__file__).resolve().parent.parent / "lib/core/l10n/arb"
LANGS = ("uz", "ru", "en")

# --- 1. Yangi kalitlar: (uz, ru, en, tavsif) -------------------------------
NEW = {
    # Modda sahifasi: bitta qatorli holat chipi (to‘liq matn — unverifiedBanner,
    # semantika va maslahatda).
    "unverifiedChip": (
        "Ekspert hali tasdiqlamagan",
        "Эксперт ещё не подтвердил",
        "Not yet expert-confirmed",
        "Short one-line status chip on a record page. Full meaning is unverifiedBanner (read by screen readers).",
    ),
    "legalNationalMethodsEmpty": (
        "Milliy metodikalar hali yuklanmagan.",
        "Национальные методики ещё не загружены.",
        "National methods are not loaded yet.",
        "Short empty note under 'National methods and procedures' when legal rules exist.",
    ),
    # Ustoz paneli.
    "teacherPanelTitle": (
        "Ustoz paneli",
        "Панель преподавателя",
        "Teacher panel",
        "Home card and screen title: teacher tools for the class quiz.",
    ),
    "teacherPanelHomeBody": (
        "Sinfda test o‘tkazing, natijalarni CSV’da oling",
        "Проведите тест в классе и получите результаты в CSV",
        "Run a class quiz and get the results as CSV",
        "Home card subtitle for users with the teacher role.",
    ),
    "teacherPanelHomeBodyStudent": (
        "Ustoz kodi bilan sinfda testga qo‘shiling",
        "Войдите в тест в классе по коду преподавателя",
        "Join a class quiz with your teacher's code",
        "Home card subtitle for users without the teacher role.",
    ),
    "teacherPanelIntro": (
        "Uchta oddiy amal: test o‘tkazing, natijalarni ko‘ring, talabalar esa kod bilan qo‘shiladi.",
        "Три простых действия: проведите тест, посмотрите результаты, а студенты войдут по коду.",
        "Three simple actions: run a quiz, see the results, and students join with a code.",
        "Intro line on the teacher panel.",
    ),
    "teacherRunTitle": (
        "Test o‘tkazish",
        "Провести тест",
        "Run a quiz",
        "Teacher panel action: create and host a class quiz.",
    ),
    "teacherRunBody": (
        "Mavzuni tanlang — sinf uchun 6 xonali kod va QR chiqadi",
        "Выберите тему — для класса появятся 6-значный код и QR",
        "Pick a topic — a 6-digit code and QR appear for the class",
        "Teacher panel action subtitle.",
    ),
    "teacherResultsTitle": (
        "Natijalar va CSV",
        "Результаты и CSV",
        "Results and CSV",
        "Teacher panel action and screen title: past class quizzes with CSV export.",
    ),
    "teacherResultsBody": (
        "O‘tkazilgan testlar, reyting va CSV fayl",
        "Проведённые тесты, рейтинг и файл CSV",
        "Past quizzes, leaderboard and a CSV file",
        "Teacher panel action subtitle.",
    ),
    "teacherJoinTitle": (
        "Sinfga qo‘shilish (talaba)",
        "Войти в класс (студент)",
        "Join a class (student)",
        "Teacher panel action: the student join flow.",
    ),
    "teacherJoinBody": (
        "Ustoz bergan kod yoki QR bilan",
        "По коду или QR от преподавателя",
        "With the code or QR from the teacher",
        "Teacher panel action subtitle.",
    ),
    "teacherRoleNeeded": (
        "Ustoz roli kerak — pastdagi izohga qarang",
        "Нужна роль преподавателя — см. примечание ниже",
        "Teacher role required — see the note below",
        "Subtitle of a disabled teacher action for users without the teacher role.",
    ),
    "teacherResultsEmpty": (
        "Hali test o‘tkazilmagan. «Test o‘tkazish»dan boshlang — natijalar shu yerda chiqadi.",
        "Тестов ещё не было. Начните с «Провести тест» — результаты появятся здесь.",
        "No quizzes yet. Start with “Run a quiz” — the results will appear here.",
        "Empty state of the teacher results list.",
    ),
    # Fan sahifasi: keyingi qadam.
    "disciplineNextTitle": (
        "Keyingi qadam",
        "Что дальше",
        "Next steps",
        "Section heading at the end of a discipline page.",
    ),
    "disciplineSearchCta": (
        "Shu fan bo‘yicha qidirish",
        "Искать по этой дисциплине",
        "Search this discipline",
        "Discipline page tile: opens search pre-filled with the discipline name.",
    ),
    "disciplineSearchBody": (
        "Moddalar, usullar va manbalar ichidan",
        "Среди веществ, методов и источников",
        "Across substances, methods and sources",
        "Subtitle of the discipline search tile.",
    ),
    # Taklif: xizmat ulanmagan holatda «qanday ishlaydi».
    "referralHowTitle": (
        "Qanday ishlaydi",
        "Как это работает",
        "How it works",
        "Heading of the three referral steps.",
    ),
    "referralHow1": (
        "Shaxsiy kodingiz yoki havolangizni hamkasbingizga yuborasiz.",
        "Вы отправляете коллеге личный код или ссылку.",
        "You send your personal code or link to a colleague.",
        "Referral step 1.",
    ),
    "referralHow2": (
        "Hamkasbingiz shu kod bilan yangi hisob ochadi.",
        "Коллега создаёт новый аккаунт с этим кодом.",
        "Your colleague creates a new account with that code.",
        "Referral step 2.",
    ),
    "referralHow3": (
        "Siz faqat umumiy sonlarni ko‘rasiz — ismlar va ma’lumotlar ko‘rinmaydi.",
        "Вы видите только общие числа — без имён и данных.",
        "You see only totals — never names or personal data.",
        "Referral step 3 (privacy).",
    ),
    # Maqolalar: bo‘sh holat.
    "pubEmptyTitle": (
        "Hali maqola yo‘q",
        "Статей пока нет",
        "No articles yet",
        "Title of the empty published-articles list.",
    ),
    "pubEmptyBody": (
        "Tajribangiz bilan birinchi bo‘lib bo‘lishing: «Maqola yuborish» tugmasi pastda. Moderatsiyadan so‘ng maqola shu yerda chiqadi.",
        "Поделитесь опытом первым: кнопка «Отправить статью» внизу. После модерации статья появится здесь.",
        "Be the first to share your experience: the “Submit an article” button is below. After moderation the article appears here.",
        "Body of the empty published-articles list.",
    ),
}

# --- 2. Mavjud kalitlar: yagona nomlash -------------------------------------
SET = {
    # «O‘qish» — Asosiy kartasi, ekran sarlavhasi va qidiruv guruhi bir xil.
    "moduleLearn": ("O‘qish", "Обучение", "Learning"),
    "homeActLearnTitle": ("O‘qish", "Обучение", "Learning"),
    "searchGroupLearning": ("O‘qish", "Обучение", "Learning"),
    "homeActLearnBody": (
        "Kurslar, mashqlar, sinfda test",
        "Курсы, упражнения, тест в классе",
        "Courses, practice, class quiz",
    ),
    # «O‘quv rejimi» → «Mashqlar» (kartochka + o‘z-o‘zini tekshirish).
    "studyTitle": ("Mashqlar", "Упражнения", "Practice"),
    # «Moddalar kutubxonasi» → «Moddalar» («Kutubxona» — hamma bo‘limlar).
    "moduleSubstances": ("Moddalar", "Вещества", "Substances"),
    "homeLibraryBody": (
        "Hamma bo‘limlar: moddalar, usullar, standartlar, manbalar",
        "Все разделы: вещества, методы, стандарты, источники",
        "Everything: substances, methods, standards, references",
    ),
    # AI: 320 dp da bir qatorda (izoh ostidagi matnda).
    "aiExperienceProfessional": ("Qisqa", "Коротко", "Short"),
    "aiExperienceTutor": ("Batafsil", "Подробно", "Detailed"),
    # Profil: rejim nimani anglatishi aniq.
    "settingsMode": (
        "Rejim: talaba yoki mutaxassis",
        "Режим: студент или специалист",
        "Mode: student or professional",
    ),
}

for i, lang in enumerate(LANGS):
    p = ARB / f"app_{lang}.arb"
    d = json.loads(p.read_text(encoding="utf-8"))
    for k, v in NEW.items():
        d[k] = v[i]
        if lang == "en":
            d["@" + k] = {"description": v[3]}
    for k, v in SET.items():
        assert k in d, f"{lang}: {k} yo‘q"
        d[k] = v[i]
    p.write_text(json.dumps(d, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print("design premium ok")
