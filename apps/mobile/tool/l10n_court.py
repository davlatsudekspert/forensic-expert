# «Sudda so‘roq: tayyorgarlik» (2026-10-09): bo‘lim matnlari.
# Idempotent: kalit bo‘lsa — qiymati yangilanadi, bo‘lmasa — qo‘shiladi.
# Tartib (CLAUDE.md): … l10n_court.py → l10n_ux_audit.py → flutter gen-l10n
# Ishga tushirish:
#   cd apps/mobile && python3 tool/l10n_court.py && python3 tool/l10n_ux_audit.py && flutter gen-l10n
# O‘zbekcha — adabiy lotin: o‘ g‘ (U+2018) va ’ (U+2019).
import collections
import json

D = "lib/core/l10n/arb"
K = collections.OrderedDict()
S = {"type": "String"}
I = {"type": "int"}


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)


k("courtTitle", "Section title: preparing for questioning in court.",
  "Court testimony: preparation",
  "Допрос в суде: подготовка",
  "Sudda so‘roq: tayyorgarlik")
k("courtSubtitle", "Short description of the court-preparation section (Home/Library tile).",
  "Questions experts are asked about their conclusions, and how to prepare a scientifically sound answer",
  "Вопросы, которые задают эксперту о его заключении, и подготовка научно обоснованного ответа",
  "Ekspertga xulosasi bo‘yicha beriladigan savollar va ilmiy asosli javobga tayyorgarlik")
k("courtDisclaimer", "Calm disclaimer at the top of every court-preparation screen.",
  "Preparation material; not legal advice; a conclusion rests only on the expert's own examination.",
  "Материал для подготовки; не юридическая консультация; заключение основывается только на собственном исследовании эксперта.",
  "Tayyorgarlik materiali; yuridik maslahat emas; xulosa faqat ekspertning o‘z tadqiqotiga asoslanadi.")
k("courtSearchHint", "Search field hint in the court-preparation section.",
  "Search questions", "Поиск по вопросам", "Savollar bo‘yicha qidirish")
k("courtNoResults", "Empty search result in the court-preparation section.",
  "Nothing found. Try another word.", "Ничего не найдено. Попробуйте другое слово.",
  "Hech narsa topilmadi. Boshqa so‘z bilan urinib ko‘ring.")
k("courtEmpty", "Shown when the court-preparation content could not be loaded.",
  "The section content could not be loaded.", "Не удалось загрузить содержимое раздела.",
  "Bo‘lim ma’lumotlari yuklanmadi.")
k("courtTopics", "Header above the list of topics.", "Topics", "Темы", "Mavzular")
k("courtQuestionCount", "Number of questions in a topic.",
  "{count, plural, =1{1 question} other{{count} questions}}",
  "{count, plural, one{{count} вопрос} few{{count} вопроса} other{{count} вопросов}}",
  "{count} ta savol", {"count": I})
k("courtTests", "Block title: what the court or investigator is testing with the question.",
  "What the court is testing", "Что проверяет суд", "Sud nimani tekshiradi")
k("courtPrepare", "Block title: preparing your answer (checklist).",
  "Preparing your answer", "Подготовка к ответу", "Javobga tayyorgarlik")
k("courtBlockDocuments", "Checklist group: documents and data to have ready.",
  "Have ready: documents and data", "Иметь под рукой: документы и данные",
  "Tayyor turing: hujjatlar va ma’lumotlar")
k("courtBlockExplain", "Checklist group: principles to explain.",
  "Principles to explain", "Какие принципы объяснить", "Tushuntiriladigan tamoyillar")
k("courtBlockPitfalls", "Checklist group: typical pitfalls.",
  "Typical pitfalls", "Типичные ошибки", "Odatiy xatolar")
k("courtRelated", "Header: related content inside the app.",
  "Related in the app", "Связанное в приложении", "Ilovadagi bog‘liq materiallar")
k("courtCopyCitation", "Tooltip: copy a reference citation.",
  "Copy citation", "Скопировать ссылку на источник", "Iqtibosni nusxalash")
k("courtCitationCopied", "Snackbar after copying a citation.",
  "Citation copied", "Ссылка скопирована", "Iqtibos nusxalandi")
k("courtPractice", "Practice mode title / button.",
  "Practice mode", "Режим тренировки", "Mashq rejimi")
k("courtPracticeBody", "Practice mode description (button subtitle).",
  "A random question: think through your answer, then open the checklist.",
  "Случайный вопрос: продумайте ответ, затем откройте чек-лист.",
  "Tasodifiy savol: javobingizni o‘ylab ko‘ring, so‘ng ro‘yxatni oching.")
k("courtPracticeThink", "Prompt under the practice question before reveal.",
  "First prepare your own answer: which documents and which principles would you rely on?",
  "Сначала подготовьте свой ответ: на какие документы и принципы вы опираетесь?",
  "Avval o‘z javobingizni tayyorlang: qaysi hujjat va tamoyillarga tayanasiz?")
k("courtPracticeReveal", "Button: reveal the preparation checklist.",
  "Show the checklist", "Показать чек-лист", "Ro‘yxatni ko‘rsatish")
k("courtPracticeHint", "Accessibility hint on the practice card.",
  "Tap to show what the court is testing", "Нажмите, чтобы увидеть, что проверяет суд",
  "Sud nimani tekshirishini ko‘rish uchun bosing")
k("courtPracticeNext", "Button: next random question.",
  "Next question", "Следующий вопрос", "Keyingi savol")
k("courtPracticeOpen", "Button: open the full question page.",
  "Open full question", "Открыть вопрос полностью", "Savolni to‘liq ochish")
k("courtPracticeProgress", "Practice counter.",
  "Questions practised: {count}", "Отработано вопросов: {count}", "Mashq qilingan savollar: {count}",
  {"count": I})
k("courtPracticeSamplesOnly", "Note: in the free mode practice uses sample questions only.",
  "Free mode: practice uses the sample questions only.",
  "Бесплатный режим: тренировка только по примерам вопросов.",
  "Bepul rejim: mashq faqat namunaviy savollar bo‘yicha.")
k("courtSample", "Badge on free sample questions.",
  "Free sample", "Бесплатный пример", "Bepul namuna")
k("courtLockedTitle", "Upsell card title: full section is in the professional plan.",
  "Full section in {tier}", "Полный раздел — в тарифе {tier}", "To‘liq bo‘lim — {tier} tarifida",
  {"tier": S})
k("courtLockedBody", "Upsell card body.",
  "In the free mode {free} sample questions are open. All {count} questions with checklists and sources, practice mode and the simulator open with this plan.",
  "В бесплатном режиме открыто {free} примера вопросов. Все {count} вопросов с чек-листами и источниками, режим тренировки и симулятор открываются с этим тарифом.",
  "Bepul rejimda {free} ta namunaviy savol ochiq. Barcha {count} ta savol ro‘yxat va manbalari, mashq rejimi va simulyator shu tarifda ochiladi.",
  {"free": I, "count": I})
k("courtLockedQuestion", "Semantics/tooltip on a locked question row.",
  "Opens with {tier}", "Открывается в тарифе {tier}", "{tier} tarifida ochiladi", {"tier": S})
k("courtQuestionOf", "Question position inside its topic.",
  "Question {index} of {count}", "Вопрос {index} из {count}", "{count} tadan {index}-savol",
  {"index": I, "count": I})

# --- Kartaning to‘liq tuzilmasi (A–I), manba joylari, eksport -------------
k("courtShortAnswer", "Card block B: short answer.", "Short answer", "Краткий ответ", "Qisqa javob")
k("courtBasisHeader", "Card section header: scientific and legal basis of the answer.",
  "Scientific and legal basis of the answer", "Научные и правовые основания ответа",
  "Javobning ilmiy va huquqiy asoslari")
k("courtBasis", "Card block C.", "Scientific / legal basis", "Научное / правовое основание",
  "Ilmiy / huquqiy asos")
k("courtWhereWritten", "Card block D: where exactly it is written.",
  "Where is it written?", "Где это написано?", "Qaysi manbada yozilgan?")
k("courtSourceUnverified", "Shown instead of a bibliography line when the exact location was not verified.",
  "Source not verified", "Источник не проверен", "Manba tekshirilmagan")
k("courtSourceUnverifiedNote", "Explains the unverified-source line.",
  "The exact location in this source has not been confirmed from the original text.",
  "Точное место в этом источнике не подтверждено по оригинальному тексту.",
  "Bu manbadagi aniq joy asl matndan tasdiqlanmagan.")
k("courtFollowups", "Card blocks E/F: follow-up questions with answers.",
  "Follow-up questions", "Дополнительные вопросы", "Qo‘shimcha savollar")
k("courtLimitations", "Card block G.", "Limitations, exceptions and uncertainties",
  "Ограничения, исключения и неопределённости", "Cheklovlar, istisnolar va noaniqliklar")
k("courtExport", "Card block H: copy / export sources.", "Copy sources", "Скопировать источники",
  "Manbalarni nusxalash")
k("courtExportText", "Export as plain text.", "As text", "Текстом", "Matn ko‘rinishida")
k("courtExportBibtex", "Export as BibTeX.", "BibTeX", "В формате BibTeX", "BibTeX formatida")
k("courtExportCopied", "Snackbar after copying the list of sources.",
  "Sources copied", "Источники скопированы", "Manbalar nusxalandi")
k("courtLawNote", "Law source note: jurisdiction, site, date of the text.",
  "Uzbekistan · lex.uz · text as of {date}", "Узбекистан · lex.uz · редакция на {date}",
  "O‘zbekiston · lex.uz · {date} holatidagi matn", {"date": S})
k("courtBookNote", "Attribution note for teacher books.",
  "Used with the author's permission; free for everyone",
  "С разрешения автора; бесплатно для всех",
  "Muallif ruxsati bilan, barcha uchun bepul")
k("courtLocArticle", "Locator: article of a law.", "Art. {article}", "ст. {article}", "{article}-modda",
  {"article": S})
k("courtLocArticlePart", "Locator: article and part.", "Art. {article}, part {part}",
  "ст. {article}, ч. {part}", "{article}-modda, {part}-qism", {"article": S, "part": S})
k("courtLocSection", "Locator: section of a document.", "§ {section}", "§ {section} (раздел)",
  "§ {section} (bo‘lim)", {"section": S})
k("courtLocPdfPage", "Locator: PDF page.", "PDF p. {page}", "PDF, с. {page}", "PDF, {page}-bet",
  {"page": S})
k("courtLocPages", "Locator: page range.", "pp. {pages}", "с. {pages}", "{pages}-betlar",
  {"pages": S})
k("courtLocRecommendation", "Locator: numbered recommendation.", "Recommendation {n}",
  "Рекомендация {n}", "{n}-tavsiya", {"n": S})
k("courtLocGuidanceNote", "Locator: guidance note.", "Guidance Note {n}",
  "Руководящее примечание {n}", "{n}-yo‘riq izohi", {"n": S})
k("courtLocAbstract", "Locator: abstract.", "Abstract", "Аннотация", "Annotatsiya")
k("courtLocScope", "Locator: scope statement on the official page.", "Scope (official page)",
  "Область применения (официальная страница)", "Qamrov (rasmiy sahifa)")
k("courtLocTitle", "Locator: title and bibliographic record.", "Title and bibliographic record",
  "Название и библиографическая запись", "Sarlavha va bibliografik yozuv")
k("courtLocGlossary", "Locator: glossary.", "Glossary", "Глоссарий", "Atamalar lug‘ati")

# --- Halollik tamoyillari va yurisdiksiya ------------------------------------
k("courtPrinciples", "Integrity principles card / screen title.",
  "Integrity principles", "Принципы честности", "Halollik tamoyillari")
k("courtPrinciplesBody", "Integrity principles card subtitle.",
  "Report everything, say “I don't know”, correct your errors, stay independent",
  "Сообщать всё, говорить «не знаю», исправлять ошибки, быть независимым",
  "Hammasini ayting, «bilmayman» deng, xatoni tuzating, mustaqil bo‘ling")
k("courtPrinciplesIntro", "Intro on the integrity principles screen.",
  "This section never teaches hiding, softening or misrepresenting real results.",
  "Этот раздел никогда не учит скрывать, смягчать или искажать реальные результаты.",
  "Bu bo‘lim hech qachon haqiqiy natijalarni yashirish, yumshatish yoki buzib ko‘rsatishni o‘rgatmaydi.")
k("courtJurisdictionUz", "Hub note when Uzbekistan is the selected jurisdiction.",
  "Legal questions: under the law of Uzbekistan",
  "Правовые вопросы: по законодательству Узбекистана",
  "Huquqiy savollar: O‘zbekiston qonunchiligi bo‘yicha")
k("courtJurisdictionIntl", "Hub note when another jurisdiction is selected.",
  "Legal questions: general international principles. Select Uzbekistan to see its laws.",
  "Правовые вопросы: общие международные принципы. Выберите Узбекистан, чтобы видеть его законы.",
  "Huquqiy savollar: umumiy xalqaro tamoyillar. O‘zbekiston qonunlari uchun yurisdiksiyani tanlang.")
k("courtJurisdictionChange", "Button: choose jurisdiction.", "Choose jurisdiction",
  "Выбрать юрисдикцию", "Yurisdiksiyani tanlash")
k("courtPendingTopic", "Badge on a topic without verified sources yet.",
  "In preparation — sources being verified", "Готовится — источники проверяются",
  "Tayyorlanmoqda — manbalar tekshirilmoqda")

# --- Sud so‘rog‘i simulyatori -------------------------------------------------
k("courtSimulator", "Simulator title.", "Court questioning simulator", "Симулятор допроса в суде",
  "Sud so‘rog‘i simulyatori")
k("courtSimulatorBody", "Simulator entry subtitle.",
  "Answer a judge, prosecutor, defence lawyer or another expert — scored on accuracy, sources, limitations and impartiality.",
  "Ответьте судье, прокурору, адвокату или другому эксперту — оценка: точность, источники, ограничения, беспристрастность.",
  "Sudya, prokuror, advokat yoki boshqa ekspert savoliga javob bering — baho: aniqlik, manba, cheklov, xolislik.")
k("courtSimulatorNote", "Simulator honesty note.",
  "The simulator never predetermines a case outcome and never teaches false testimony, evasion or hiding results.",
  "Симулятор не предрешает исход дела и не учит ложным показаниям, уклонению или сокрытию результатов.",
  "Simulyator ish natijasini oldindan belgilamaydi va soxta ko‘rsatma, qochish yoki natijani yashirishni o‘rgatmaydi.")
k("courtRoleJudge", "Simulator role.", "Judge", "Судья", "Sudya")
k("courtRoleProsecutor", "Simulator role.", "Prosecutor", "Прокурор", "Prokuror")
k("courtRoleDefense", "Simulator role.", "Defence lawyer", "Адвокат (защитник)", "Advokat (himoyachi)")
k("courtRoleExpert", "Simulator role: another expert.", "Another expert", "Другой эксперт", "Boshqa ekspert")
k("courtSimContext", "Scenario context label.", "Situation", "Ситуация", "Vaziyat")
k("courtSimYourAnswer", "Free-text answer label.", "Your own answer (optional)",
  "Ваш собственный ответ (необязательно)", "O‘z javobingiz (ixtiyoriy)")
k("courtSimYourAnswerHint", "Free-text hint.", "Type your answer…", "Введите ответ…", "Javobingizni yozing…")
k("courtSimEvaluateText", "Button: evaluate the typed answer.", "Check my wording",
  "Проверить формулировку", "Matnni baholash")
k("courtSimChoose", "Header above answer options.", "Choose the best answer",
  "Выберите лучший ответ", "Eng to‘g‘ri javobni tanlang")
k("courtSimCheck", "Button: check the chosen option.", "Check answer", "Проверить ответ",
  "Javobni tekshirish")
k("courtSimResult", "Header: evaluation.", "Evaluation", "Оценка", "Baho")
k("courtSimTotal", "Total score.", "Total: {score}/{max}", "Итого: {score}/{max}", "Jami: {score}/{max}",
  {"score": I, "max": I})
k("courtSimBest", "Header: model answer.", "Model answer", "Образцовый ответ", "Namunaviy javob")
k("courtSimNext", "Button: next scenario.", "Next scenario", "Следующий сценарий", "Keyingi ssenariy")
k("courtSimOpenQuestion", "Button: open related card.", "Open the related card",
  "Открыть связанную карточку", "Bog‘liq kartani ochish")
k("courtSimFreeTextNote", "Note under the automatic free-text evaluation.",
  "Automatic, keyword-based and approximate. Compare scientific accuracy with the model answer yourself.",
  "Автоматическая оценка по ключевым словам, приблизительная. Научную точность сравните с образцовым ответом сами.",
  "Avtomatik baho kalit so‘zlarga asoslangan va taxminiy. Ilmiy aniqlikni namunaviy javob bilan o‘zingiz solishtiring.")
k("courtSimFlagOverstatement", "Warning: absolute wording detected.",
  "Absolute wording found (“100%”, “definitely”…) — certainty may be overstated.",
  "Найдены абсолютные формулировки («100 %», «наверняка»…) — уверенность может быть завышена.",
  "Mutlaq ibora topildi («100 %», «albatta»…) — ishonch oshirib ko‘rsatilgan bo‘lishi mumkin.")
k("courtSimFlagEvasion", "Warning: evasive wording detected.",
  "Evasive wording found — give the reason and what lies within your field.",
  "Найдены уклончивые формулировки — назовите причину и то, что в вашей области.",
  "Javobdan qochish iborasi topildi — sababini va o‘z sohangizdagi ma’lumotni ayting.")
k("courtSimTooShort", "Warning: answer too short.", "The answer is too short.",
  "Ответ слишком короткий.", "Javob juda qisqa.")
k("courtCritAccuracy", "Criterion.", "Scientific accuracy", "Научная точность", "Ilmiy aniqlik")
k("courtCritSources", "Criterion.", "Reliance on sources", "Опора на источники", "Manbaga tayanish")
k("courtCritLimitations", "Criterion.", "Explaining limitations", "Объяснение ограничений",
  "Cheklovlarni tushuntirish")
k("courtCritImpartiality", "Criterion.", "Impartiality", "Беспристрастность", "Xolislik")
k("courtSimSamplesOnly", "Free mode note for the simulator.",
  "Free mode: sample scenarios only.", "Бесплатный режим: только примеры сценариев.",
  "Bepul rejim: faqat namunaviy ssenariylar.")
k("courtScenarioCount", "Number of scenarios.",
  "{count, plural, =1{1 scenario} other{{count} scenarios}}",
  "{count, plural, one{{count} сценарий} few{{count} сценария} other{{count} сценариев}}",
  "{count} ta ssenariy", {"count": I})

# --- Pro: kengaytirilgan tayyorgarlik (savol-javob kartalari — bepul) -------
k("courtProTitle", "Pro features card title.", "Advanced preparation in {tier}",
  "Расширенная подготовка — в тарифе {tier}", "Kengaytirilgan tayyorgarlik — {tier} tarifida",
  {"tier": S})
k("courtProBody", "Pro features card body.",
  "Full simulator (all scenarios), sequential role drills, AI analysis (coming soon), personal statistics and history. Q&A cards with sources are free for everyone.",
  "Полный симулятор (все сценарии), последовательные ролевые тренировки, ИИ-анализ (скоро), личная статистика и история. Карточки вопросов с источниками бесплатны для всех.",
  "To‘liq simulyator (barcha ssenariylar), ketma-ket rol mashqlari, AI tahlili (tez orada), shaxsiy statistika va tarix. Manbali savol-javob kartalari hamma uchun bepul.")
k("courtProBadge", "Small badge on Pro-only entries.", "Pro", "В Pro", "Pro’da")
k("courtAiPro", "AI analysis button label for free users.", "AI analysis (Pro)",
  "ИИ-анализ (Pro)", "AI tahlili (Pro)")
k("courtScoreSemantics", "Screen-reader label of a score bar.", "{criterion}: {score} of 2",
  "{criterion}: {score} из 2", "{criterion}: 2 dan {score}", {"criterion": S, "score": I})
k("courtSimFreeNote", "Simulator list note for free users.",
  "Free: basic scenarios. The other scenarios, role drills and statistics are in Pro.",
  "Бесплатно: базовые сценарии. Остальные сценарии, ролевые тренировки и статистика — в Pro.",
  "Bepul: asosiy ssenariylar. Qolgan ssenariylar, rol mashqlari va statistika — Pro’da.")
k("courtDrill", "Pro: sequential role drill.", "Role drill", "Ролевая тренировка", "Rol mashqi")
k("courtDrillBody", "Role drill subtitle.",
  "Judge → prosecutor → defence → another expert, one after another",
  "Судья → прокурор → защитник → другой эксперт, по очереди",
  "Sudya → prokuror → advokat → boshqa ekspert, ketma-ket")
k("courtDrillStep", "Role drill progress.", "Step {index} of {count}", "Шаг {index} из {count}",
  "{count} tadan {index}-qadam", {"index": I, "count": I})
k("courtDrillNext", "Button: next role in the drill.", "Next role", "Следующая роль", "Keyingi rol")
k("courtDrillDone", "Role drill finished.", "Role drill complete", "Ролевая тренировка завершена",
  "Rol mashqi yakunlandi")
k("courtStats", "Pro: statistics and history.", "Statistics and history", "Статистика и история",
  "Statistika va tarix")
k("courtStatsBody", "Statistics subtitle.",
  "Your scores and attempt history — stored on this device only",
  "Ваши оценки и история попыток — только на этом устройстве",
  "Shaxsiy baholar va urinishlar tarixi — faqat shu qurilmada")
k("courtStatsAttempts", "Number of attempts.", "Attempts: {count}", "Попыток: {count}",
  "Urinishlar: {count}", {"count": I})
k("courtStatsAverage", "Average by criterion header.", "Average score by criterion",
  "Средняя оценка по критериям", "Mezonlar bo‘yicha o‘rtacha baho")
k("courtStatsHistory", "History header.", "History", "История", "Tarix")
k("courtStatsEmpty", "No attempts yet.", "No attempts yet.", "Попыток пока нет.", "Hali urinish yo‘q.")
k("courtStatsClear", "Button: clear history.", "Clear history", "Очистить историю", "Tarixni tozalash")
k("courtAi", "Pro: AI analysis of the answer.", "AI analysis", "ИИ-анализ", "AI tahlili")
k("courtAiUnavailable", "Honest unavailable state for AI analysis.",
  "AI analysis is not connected yet — coming soon. Your answer was not sent anywhere.",
  "ИИ-анализ пока не подключён — скоро. Ваш ответ никуда не отправлен.",
  "AI tahlili hozircha ulanmagan — tez orada. Javobingiz hech qayerga yuborilmadi.")
k("courtSimPartialUnverified", "Cap note: answer relies on an unverified source.",
  "Partial — unverified source: this answer relies on a source whose location is not verified.",
  "Частично — источник не проверен: ответ опирается на источник с неподтверждённым местом.",
  "Qisman — tekshirilmagan manba: bu javob joyi tasdiqlanmagan manbaga tayanadi.")
k("courtSimReviewNote", "Note under every simulator evaluation.",
  "Scores are based on material awaiting expert review (NEEDS_REVIEW); the model answer is not a verified truth either.",
  "Оценка основана на материале, ожидающем экспертной проверки (NEEDS_REVIEW); образцовый ответ — тоже не проверенная истина.",
  "Baho ekspert ko‘rigini kutayotgan (NEEDS_REVIEW) materialga asoslangan; namunaviy javob ham tasdiqlangan haqiqat emas.")


REMOVE = ["courtLockedTitle", "courtLockedBody", "courtLockedQuestion", "courtSample",
          "courtPracticeSamplesOnly", "courtSimSamplesOnly"]


def main():
    for lang, idx in (("en", 1), ("ru", 2), ("uz", 3)):
        p = f"{D}/app_{lang}.arb"
        with open(p, encoding="utf-8") as f:
            data = json.load(f, object_pairs_hook=collections.OrderedDict)
        for key in REMOVE:
            data.pop(key, None)
            data.pop("@" + key, None)
        for key, v in K.items():
            if key in REMOVE:
                continue
            data[key] = v[idx]
            if lang == "en":
                meta = collections.OrderedDict(description=v[0])
                if v[4]:
                    meta["placeholders"] = v[4]
                data["@" + key] = meta
        with open(p, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write("\n")
    print(f"l10n_court: {len(K)} keys")


if __name__ == "__main__":
    main()
