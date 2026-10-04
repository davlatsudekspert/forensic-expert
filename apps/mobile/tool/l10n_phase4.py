# PHASE 4 lokalizatsiya kalitlari (global bilim tizimi, premium UX).
# RU/UZ — review qilinmagan qoralama (RG-11).
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}
I = {"type": "int"}

k("statusDraft","Scientific status: draft, not yet submitted for review.","Draft","Черновик","Qoralama")

k("searchGroupTopics","Search group.","Forensic medicine & biochemistry","Судебная медицина и биохимия","Sud tibbiyoti va biokimyo")
k("searchGroupReagents","Search group.","Reagents & solutions","Реактивы и растворы","Reagentlar va eritmalar")
k("searchGroupScreening","Search group.","Screening tests","Скрининговые тесты","Skrining testlari")
k("searchGroupStandardsLaws","Search group.","Standards & laws","Стандарты и законы","Standartlar va qonunlar")


# --- Modullar / Home ---------------------------------------------------------
k("moduleBiochemistry","Home module.","Biochemistry","Биохимия","Biokimyo")
k("moduleReagents","Home module.","Reagents & solutions","Реактивы и растворы","Reagentlar va eritmalar")
k("moduleScreening","Home module.","Screening & express tests","Скрининг и экспресс-тесты","Skrining va ekspress testlar")
k("moduleMethods","Home module.","Methods & SOP","Методы и СОП","Metodlar va SOP")
k("moduleStandardsLaws","Home module: standards, laws, jurisdiction comparison.","Standards & laws","Стандарты и законы","Standartlar va qonunlar")
k("moduleEmerging","Home module.","Emerging issues","Новые проблемы","Yangi muammolar")
k("homeAreasHeading","Home section heading.","Professional areas","Профессиональные разделы","Professional bo‘limlar")
k("homeDbTitle","Home: offline database card title.","Offline database","Офлайн-база","Oflayn baza")
k("homeDbPack","Content pack version.","Content pack {version}","Пакет контента {version}","Kontent paketi {version}",{"version":S})
k("homeDbScientific","Scientific DB component version.","Scientific data {version}","Научные данные {version}","Ilmiy ma’lumot {version}",{"version":S})
k("homeDbJurisdiction","Jurisdiction data component version.","Jurisdiction data {version}","Юрисдикционные данные {version}","Yurisdiksiya ma’lumoti {version}",{"version":S})
k("homeDbOffline","Home: privacy/offline note.","Works offline. Searches and questions stay on this device.","Работает офлайн. Поиск и вопросы остаются на устройстве.","Oflayn ishlaydi. Qidiruv va savollar shu qurilmada qoladi.")
k("homeDbNotInstalled","Home: no content pack.","Content pack is not installed.","Пакет контента не установлен.","Kontent paketi o‘rnatilmagan.")
k("homeDbLoading","Home: content pack loading.","Opening the offline database…","Открытие офлайн-базы…","Oflayn baza ochilmoqda…")

# --- Umumiy bilim yozuvi -----------------------------------------------------
k("knowledgeEmpty","Knowledge list empty state.","No records in the installed content pack yet.","В установленном пакете пока нет записей.","O‘rnatilgan paketda hozircha yozuv yo‘q.")
k("knowledgeNoSourcedContent","Taxonomy topic without content.","No sourced content yet","Пока нет материалов с источниками","Hozircha manbali ma’lumot yo‘q")
k("knowledgeStatements","Section: sourced statements (claims).","Sourced statements","Утверждения с источниками","Manbali ma’lumotlar")
k("knowledgeSafety","Section: limitations and safety (never paywalled).","Limitations & safety","Ограничения и безопасность","Cheklovlar va xavfsizlik")
k("knowledgeSources","Section: sources.","Sources","Источники","Manbalar")
k("knowledgeDetails","Section: structured details.","Details","Подробности","Tafsilotlar")
k("knowledgeSourceRef","Value attribution to a source.","Source: {source}","Источник: {source}","Manba: {source}",{"source":S})
k("knowledgeNotInSource","Field not stated by any source.","Not stated in the sources — not estimated","В источниках не указано — не оценивается","Manbalarda ko‘rsatilmagan — taxmin qilinmaydi")
k("knowledgeTaxonomy","Section: topic taxonomy.","Topics","Темы","Mavzular")
k("knowledgeTopicCount","Topics with content count.","{count} of {total} topics have sourced content","Материалы с источниками: {count} из {total} тем","{total} mavzudan {count} tasida manbali ma’lumot bor",{"count":I,"total":I})

# --- Reagent -----------------------------------------------------------------
k("reagentPreparation","Reagent: preparation section.","Preparation","Приготовление","Tayyorlash")
k("reagentNoRecipe","Reagent without verified recipe.","No verified preparation recipe was found in the sources. Ingredients, amounts, order of addition, storage and shelf life are not shown and are never estimated.","В источниках не найден проверенный рецепт приготовления. Компоненты, количества, порядок, хранение и срок годности не показываются и не оцениваются.","Manbalarda tasdiqlangan tayyorlash retsepti topilmadi. Tarkib, miqdor, qo‘shish tartibi, saqlash va yaroqlilik muddati ko‘rsatilmaydi va taxmin qilinmaydi.")
k("reagentIngredients","Recipe ingredients.","Ingredients","Компоненты","Tarkib")
k("reagentFinalVolume","Recipe final volume.","Final volume","Конечный объём","Yakuniy hajm")
k("reagentSteps","Recipe steps.","Steps","Этапы","Bosqichlar")
k("reagentOrderNotStated","Source does not state order.","The source does not state the order of addition — steps are listed without numbering.","Источник не указывает порядок добавления — этапы перечислены без нумерации.","Manba qo‘shish tartibini aytmaydi — bosqichlar raqamsiz ko‘rsatilgan.")
k("reagentStorage","Recipe storage.","Storage","Хранение","Saqlash")
k("reagentTemperature","Recipe temperature.","Temperature","Температура","Harorat")
k("reagentStability","Recipe stability / shelf life.","Stability","Стабильность","Barqarorlik")
k("reagentHazards","Recipe hazards.","Hazards","Опасности","Xavflar")
k("reagentDisposal","Recipe disposal reference.","Disposal","Утилизация","Utilizatsiya")
k("reagentQc","Recipe QC requirement.","Quality control","Контроль качества","Sifat nazorati")
k("reagentOpenCalculator","Button to the solution preparation calculator.","Solution preparation calculator","Калькулятор приготовления раствора","Eritma tayyorlash kalkulyatori")

# --- Skrining ----------------------------------------------------------------
k("screeningBanner","Permanent screening disclaimer.","SCREENING RESULT ≠ CONFIRMED IDENTIFICATION. A positive screen is presumptive and requires a validated confirmatory method.","РЕЗУЛЬТАТ СКРИНИНГА ≠ ПОДТВЕРЖДЁННАЯ ИДЕНТИФИКАЦИЯ. Положительный скрининг предварителен и требует валидированного подтверждающего метода.","SKRINING NATIJASI ≠ TASDIQLANGAN IDENTIFIKATSIYA. Ijobiy skrining dastlabki natija bo‘lib, validatsiyadan o‘tgan tasdiqlovchi metodni talab qiladi.")
k("screeningAnalyte","Screening field.","Analyte","Аналит","Analit")
k("screeningSpecimen","Screening field.","Specimen","Образец","Namuna")
k("screeningPrinciple","Screening field.","Principle","Принцип","Prinsip")
k("screeningCutoff","Screening field.","Cut-off","Пороговое значение","Chegara qiymati (cut-off)")
k("screeningSensitivity","Screening field.","Sensitivity","Чувствительность","Sezgirlik")
k("screeningSpecificity","Screening field.","Specificity","Специфичность","Spetsifiklik")
k("screeningCrossReactivity","Screening field.","Cross-reactivity","Перекрёстная реактивность","Kross-reaktivlik")
k("screeningFalsePositive","Screening field.","False positives","Ложноположительные","Soxta ijobiy natijalar")
k("screeningFalseNegative","Screening field.","False negatives","Ложноотрицательные","Soxta salbiy natijalar")
k("screeningLimitations","Screening field.","Limitations","Ограничения","Cheklovlar")
k("screeningConfirmatory","Screening: confirmatory methods.","Confirmatory methods","Подтверждающие методы","Tasdiqlovchi metodlar")

# --- Metod -------------------------------------------------------------------
k("methodKindScientific","Method kind.","Scientific methods","Научные методы","Ilmiy metodlar")
k("methodKindInternational","Method kind.","International standards","Международные стандарты","Xalqaro standartlar")
k("methodKindNational","Method kind.","National methods","Национальные методики","Milliy metodikalar")
k("methodKindSop","Method kind.","Institutional SOPs","СОП учреждений","Muassasa SOP’lari")
k("methodKindNote","Explains that method kinds are never mixed.","Method types are kept separate: a scientific method is not a legal requirement, and an institutional SOP applies only to its institution.","Типы методов не смешиваются: научный метод — не правовое требование, а СОП действует только в своём учреждении.","Metod turlari aralashtirilmaydi: ilmiy metod huquqiy talab emas, muassasa SOP’i esa faqat o‘sha muassasada amal qiladi.")
k("methodNoKindEntries","No method records of a kind.","No records of this type yet.","Записей этого типа пока нет.","Bu turdagi yozuv hozircha yo‘q.")
k("methodOrganization","Method field.","Organization","Организация","Tashkilot")
k("methodJurisdiction","Method field.","Jurisdiction","Юрисдикция","Yurisdiksiya")
k("methodTechniques","Method field.","Techniques","Методы анализа","Tahlil texnikalari")
k("methodDocumentVersion","Method field.","Document version","Версия документа","Hujjat versiyasi")

# --- Yangi muammolar ---------------------------------------------------------
k("emergingDate","Emerging issue date.","Published {date}","Опубликовано {date}","Nashr qilingan: {date}",{"date":S})
k("emergingEvidenceType","Emerging issue field.","Evidence type","Тип доказательства","Dalil turi")
k("emergingScopeGlobal","Emerging issue scope.","Scope: global","Охват: глобальный","Qamrov: global")
k("evidenceTypeOfficialAlert","Evidence type.","Official alert","Официальное предупреждение","Rasmiy ogohlantirish")
k("evidenceTypePeerReviewed","Evidence type.","Peer-reviewed publication","Рецензируемая публикация","Taqrizdan o‘tgan nashr")
k("evidenceTypeReport","Evidence type.","Report","Отчёт","Hisobot")
k("evidenceTypeStandard","Evidence type.","Standard","Стандарт","Standart")
k("emergingNote","Emerging issues explainer.","Each item has a source, a date, an evidence type and a scope. This is not a news feed.","У каждой записи есть источник, дата, тип доказательства и охват. Это не новостная лента.","Har bir yozuvda manba, sana, dalil turi va qamrov bor. Bu yangiliklar lentasi emas.")
k("emergingCatNps","Emerging category.","New psychoactive substances","Новые психоактивные вещества","Yangi psixoaktiv moddalar")
k("emergingCatSyntheticOpioids","Emerging category.","Synthetic opioids","Синтетические опиоиды","Sintetik opioidlar")
k("emergingCatStimulants","Emerging category.","Novel stimulants","Новые стимуляторы","Yangi stimulyatorlar")
k("emergingCatAnalytical","Emerging category.","Analytical challenges","Аналитические проблемы","Analitik muammolar")
k("emergingCatInterferences","Emerging category.","New interferences","Новые интерференции","Yangi interferensiyalar")
k("emergingCatPostmortem","Emerging category.","Postmortem interpretation","Посмертная интерпретация","O‘limdan keyingi talqin")
k("emergingCatStandards","Emerging category.","New standards","Новые стандарты","Yangi standartlar")
k("emergingCatValidation","Emerging category.","Method validation","Валидация методов","Metod validatsiyasi")
k("emergingCatQuality","Emerging category.","Laboratory quality","Качество лаборатории","Laboratoriya sifati")
k("emergingCatAlert","Emerging category.","Scientific alert","Научное предупреждение","Ilmiy ogohlantirish")

# --- Sud tibbiyoti taksonomiyasi (25) ----------------------------------------
FM = [
 ("deathInvestigation","Death investigation","Расследование смерти","O‘lim holatini tekshirish"),
 ("causeMechanismManner","Cause, mechanism and manner of death","Причина, механизм и род смерти","O‘lim sababi, mexanizmi va turi"),
 ("postmortemChanges","Postmortem changes","Посмертные изменения","O‘limdan keyingi o‘zgarishlar"),
 ("postmortemInterval","Postmortem interval","Давность наступления смерти","O‘limdan keyingi vaqt"),
 ("algorMortis","Algor mortis","Охлаждение трупа","Murdaning sovishi"),
 ("rigorMortis","Rigor mortis","Трупное окоченение","Murda qotishi"),
 ("livorMortis","Livor mortis","Трупные пятна","Murda dog‘lari"),
 ("decomposition","Decomposition","Гниение","Chirish"),
 ("trauma","Trauma","Травма","Jarohat"),
 ("bluntForceInjury","Blunt force injury","Тупая травма","To‘mtoq jism jarohati"),
 ("sharpForceInjury","Sharp force injury","Острая травма","O‘tkir jism jarohati"),
 ("firearmInjury","Firearm injury","Огнестрельная травма","O‘qotar qurol jarohati"),
 ("asphyxia","Asphyxia","Асфиксия","Asfiksiya"),
 ("burns","Burns","Ожоги","Kuyishlar"),
 ("electricalInjury","Electrical injury","Электротравма","Elektr jarohati"),
 ("hypoHyperthermia","Hypothermia and hyperthermia","Гипо- и гипертермия","Gipo- va gipertermiya"),
 ("drowning","Drowning","Утопление","Cho‘kish"),
 ("anthropology","Forensic anthropology","Судебная антропология","Sud antropologiyasi"),
 ("ageEstimation","Age estimation","Определение возраста","Yoshni aniqlash"),
 ("sexEstimation","Sex estimation","Определение пола","Jinsni aniqlash"),
 ("statureEstimation","Stature estimation","Определение роста","Bo‘yni aniqlash"),
 ("odontology","Forensic odontology","Судебная одонтология","Sud odontologiyasi"),
 ("disasterVictimIdentification","Disaster victim identification","Идентификация жертв катастроф","Falokat qurbonlarini identifikatsiya qilish"),
 ("histology","Forensic histology","Судебная гистология","Sud gistologiyasi"),
 ("postmortemImaging","Postmortem imaging","Посмертная визуализация","O‘limdan keyingi vizualizatsiya"),
]
for key,en,ru,uz in FM:
    k("fmTopic"+key[0].upper()+key[1:],"Forensic medicine taxonomy topic name.",en,ru,uz)

# --- Yurisdiksiyalarni solishtirish ------------------------------------------
k("compareTitle","Compare jurisdictions screen title.","Compare jurisdictions","Сравнение юрисдикций","Yurisdiksiyalarni solishtirish")
k("compareTopicDrinkDrive","Comparison topic: drink-driving limit.","Drink-driving: prescribed alcohol limit","Вождение в нетрезвом виде: установленный предел алкоголя","Mast holda haydash: belgilangan alkogol chegarasi")
k("compareNoData","Comparison cell without data.","No data — no conclusion is drawn","Нет данных — вывод не делается","Ma’lumot yo‘q — xulosa chiqarilmaydi")
k("compareNoTopics","No comparable legal data.","No comparable legal data in the content pack yet.","В пакете пока нет сопоставимых правовых данных.","Paketda hozircha solishtiriladigan huquqiy ma’lumot yo‘q.")
k("compareNotAdvice","Comparison disclaimer.","Reference information, not legal advice. Always check the current official text.","Справочная информация, не юридическая консультация. Сверяйтесь с действующим официальным текстом.","Ma’lumotnoma, yuridik maslahat emas. Har doim amaldagi rasmiy matnni tekshiring.")
k("compareNoInference","Explains noData semantics.","Missing data never means “allowed”, “not controlled” or “prohibited”.","Отсутствие данных не означает «разрешено», «не контролируется» или «запрещено».","Ma’lumot yo‘qligi «ruxsat», «nazoratda emas» yoki «taqiqlangan» degani emas.")
k("compareOverrides","Rule overrides a less specific one.","Overrides the rule of {jurisdiction}","Заменяет правило: {jurisdiction}","{jurisdiction} qoidasi o‘rniga amal qiladi",{"jurisdiction":S})
k("compareArticle","Article / section of instrument.","Section: {section}","Статья/раздел: {section}","Modda/bo‘lim: {section}",{"section":S})
k("compareAuthority","Issuing authority.","Authority: {name}","Орган: {name}","Organ: {name}",{"name":S})
k("compareOfficialExcerpt","Official text excerpt label.","Official text","Официальный текст","Rasmiy matn")
k("specimenBreath","Specimen.","Breath","Выдыхаемый воздух","Nafas")
k("specimenBlood","Specimen.","Blood","Кровь","Qon")
k("specimenUrine","Specimen.","Urine","Моча","Siydik")
k("legalThresholdTitle","Legal threshold rule title.","Legal limit","Правовой предел","Huquqiy chegara")
k("legalLayerNational","Legal layer chip: national/regional law.","National / regional law","Национальное / региональное право","Milliy / hududiy qonun")
k("legalOpenCompare","Button opening jurisdiction comparison.","Compare jurisdictions","Сравнить юрисдикции","Yurisdiksiyalarni solishtirish")

# --- Eritma kalkulyatori -----------------------------------------------------
k("toolSolutionName","Tool name.","Solution preparation (mass required)","Приготовление раствора (необходимая масса)","Eritma tayyorlash (kerakli massa)")
k("toolSolutionDesc","Tool description.","Mass of substance for a target concentration and final volume: m = C·V(·M)/p. Molar mass and purity come from you (certificate/label).","Масса вещества для заданной концентрации и объёма: m = C·V(·M)/p. Молярную массу и чистоту вводите вы (сертификат/этикетка).","Berilgan konsentratsiya va hajm uchun modda massasi: m = C·V(·M)/p. Molyar massa va tozalikni siz kiritasiz (sertifikat/yorliq).")
k("calcTargetConc","Calculator field.","Target concentration","Целевая концентрация","Maqsadli konsentratsiya")
k("calcMolarMass","Calculator field.","Molar mass (g/mol)","Молярная масса (г/моль)","Molyar massa (g/mol)")
k("calcPurity","Calculator field.","Purity (0–1)","Чистота (0–1)","Tozalik (0–1)")
k("calcMassRequired","Calculator result label.","Mass required","Необходимая масса","Kerakli massa")
k("calcErrorMolarMass","Calculator error.","Enter the molar mass from the certificate or label for a molar concentration.","Для молярной концентрации введите молярную массу из сертификата или этикетки.","Molyar konsentratsiya uchun molyar massani sertifikat yoki yorliqdan kiriting.")
k("calcErrorPurity","Calculator error.","Purity must be greater than 0 and at most 1.","Чистота должна быть больше 0 и не больше 1.","Tozalik 0 dan katta va 1 dan oshmasligi kerak.")
k("calcSolutionAssumptionDefinition","Calculator assumption.","Definitional calculation of concentration (no empirical coefficients).","Расчёт по определению концентрации (без эмпирических коэффициентов).","Konsentratsiya ta’rifi bo‘yicha hisob (empirik koeffitsiyentsiz).")
k("calcSolutionAssumptionInputs","Calculator assumption.","Molar mass and purity are supplied by the user; nothing is estimated.","Молярную массу и чистоту вводит пользователь; ничего не оценивается.","Molyar massa va tozalikni foydalanuvchi kiritadi; hech narsa taxmin qilinmaydi.")
k("calcSolutionLimitationRecipe","Calculator limitation.","This is not a reagent recipe: substance choice, order, storage and stability come only from a verified source or SOP.","Это не рецепт реактива: выбор вещества, порядок, хранение и стабильность — только из проверенного источника или СОП.","Bu reagent retsepti emas: modda tanlovi, tartib, saqlash va barqarorlik faqat tasdiqlangan manba yoki SOP’dan.")
k("calcSolutionLimitationVolume","Calculator limitation.","Volume change on dissolution is ignored.","Изменение объёма при растворении не учитывается.","Eritishda hajm o‘zgarishi hisobga olinmaydi.")
k("calcWarnPurity","Calculator warning.","Purity correction applied.","Применена поправка на чистоту.","Tozalik tuzatmasi qo‘llandi.")


k("legalExtent","Territorial extent of a legal provision.","Territorial extent: {extent}","Территориальное действие: {extent}","Hududiy amal qilishi: {extent}",{"extent":S})
k("legalAppliesTo","Rule applies to listed subdivisions.","Applies to: {places}","Применяется: {places}","Qo‘llaniladi: {places}",{"places":S})
k("legalStatusInForce","Instrument legal status.","In force","Действует","Amalda")
k("legalStatusAmended","Instrument legal status.","Amended","С изменениями","O‘zgartirilgan")
k("legalStatusSuperseded","Instrument legal status.","Superseded","Заменён","Almashtirilgan")
k("legalStatusRepealed","Instrument legal status.","Repealed","Утратил силу","Kuchini yo‘qotgan")


# --- Forensic AI / Tutor -----------------------------------------------------
k("aiExperienceProfessional","AI experience toggle.","Professional","Профессионал","Mutaxassis")
k("aiExperienceTutor","AI experience toggle.","Tutor","Наставник","Ustoz (Tutor)")
k("aiExperienceProfessionalHint","AI experience hint.","Concise, source-first answers for practitioners.","Краткие ответы с источниками для специалистов.","Mutaxassislar uchun qisqa, manbaga tayangan javoblar.")
k("aiExperienceTutorHint","AI experience hint.","Step-by-step explanations for learning, always with sources.","Пошаговые объяснения для обучения, всегда с источниками.","O‘rganish uchun bosqichma-bosqich tushuntirish, har doim manba bilan.")
k("aiFindSources","Button: offline retrieval.","Find sources offline","Найти источники офлайн","Manbalarni oflayn topish")
k("aiRetrievalTitle","Retrieval results heading.","Matching statements in the offline database","Подходящие утверждения в офлайн-базе","Oflayn bazadagi mos ma’lumotlar")
k("aiRetrievalNote","Retrieval results disclaimer.","This is not an AI answer: these are local search results, each with its source.","Это не ответ ИИ: это результаты локального поиска, у каждого есть источник.","Bu AI javobi emas: bular lokal qidiruv natijalari, har birining manbasi bor.")
k("aiNoContext","No retrieval context.","No reliable context in the offline database — no answer is given.","В офлайн-базе нет надёжного контекста — ответ не даётся.","Oflayn bazada ishonchli kontekst yo‘q — javob berilmaydi.")
k("aiBlockedConclusion","Safety block.","Final conclusions on the cause or manner of death are not provided. That decision belongs to the expert with the full case.","Окончательные выводы о причине или роде смерти не даются. Это решение эксперта с полными материалами дела.","O‘lim sababi yoki turi bo‘yicha yakuniy xulosa berilmaydi. Bu — ish materiallari to‘liq bo‘lgan ekspert qarori.")
k("aiBlockedLegal","Safety block.","Legal conclusions (guilt, charges, sentencing) are not provided.","Юридические выводы (вина, обвинение, наказание) не даются.","Huquqiy xulosa (aybdorlik, ayblov, jazo) berilmaydi.")
k("aiBlockedPii","Safety block.","Remove personal data before searching or asking.","Удалите персональные данные перед поиском или вопросом.","Qidirish yoki so‘rashdan oldin shaxsiy ma’lumotni olib tashlang.")


# --- Student Mode ------------------------------------------------------------
k("learnLevelAll","Study level filter.","All levels","Все уровни","Barcha darajalar")
k("learnLevelFoundation","Study level.","Foundation","Базовый","Boshlang‘ich")
k("learnLevelIntermediate","Study level.","Intermediate","Средний","O‘rta")
k("learnLevelAdvanced","Study level.","Advanced","Продвинутый","Yuqori")
k("learnProgressValue","Lessons completed.","{done} of {total} lessons completed","Пройдено уроков: {done} из {total}","{total} darsdan {done} tasi tugatildi",{"done":I,"total":I})
k("learnHistory","Recently opened lessons.","Recently studied","Недавно изученные","Yaqinda o‘rganilgan")
k("learnBookmarks","Bookmarks section.","Bookmarks","Закладки","Xatcho‘plar")
k("learnBookmarksEmpty","No bookmarks.","Bookmark a topic with the star to find it here.","Добавьте тему в закладки звёздочкой, чтобы найти её здесь.","Mavzuni yulduzcha bilan belgilang — u shu yerda chiqadi.")
k("learnMarkComplete","Toggle lesson completion.","Mark as completed","Отметить как пройденный","Tugatildi deb belgilash")
k("learnCompleted","Lesson completed chip.","Completed","Пройден","Tugatildi")
k("learnCourseSourceNote","Explains content-based course.","Lessons show original source statements. No new scientific text is written; content awaits expert review.","Уроки показывают исходные утверждения источников. Новый научный текст не пишется; материалы ждут экспертной проверки.","Darslar manbadagi asl jumlalarni ko‘rsatadi. Yangi ilmiy matn yozilmaydi; mazmun ekspert tekshiruvini kutmoqda.")
k("learnExam","Exam mode tile/title.","Exam mode","Режим экзамена","Imtihon rejimi")
k("learnExamIntro","Exam mode intro.","Answer all questions. Results and explanations appear only after you submit.","Ответьте на все вопросы. Результаты и пояснения появятся только после отправки.","Barcha savollarga javob bering. Natija va izohlar faqat topshirgandan keyin chiqadi.")
k("learnExamSubmit","Exam submit button.","Submit exam","Завершить экзамен","Imtihonni topshirish")
k("learnExamScore","Exam score.","Score: {correct} of {total}","Результат: {correct} из {total}","Natija: {total} dan {correct}",{"correct":I,"total":I})
k("learnExamEmpty","No exam questions.","No reviewed exam questions yet. Questions are not generated automatically.","Проверенных экзаменационных вопросов пока нет. Вопросы не генерируются автоматически.","Tekshirilgan imtihon savollari hozircha yo‘q. Savollar avtomatik yaratilmaydi.")
k("learnExamRetry","Exam retry.","Try again","Пройти снова","Qayta urinish")
k("learnSimulatedCase","Label for simulated (non-real) case studies.","SIMULATED CASE — not a real case","СМОДЕЛИРОВАННЫЙ СЛУЧАЙ — не реальное дело","SIMULYATSIYA QILINGAN HOLAT — real ish emas")

for idx, code in enumerate(["en","ru","uz"]):
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key,(desc,en,ru,uz,ph) in K.items():
        data[key] = (en,ru,uz)[idx]
        if code == "en":
            meta = {"description": desc}
            if ph: meta["placeholders"] = ph
            data["@"+key] = meta
    json.dump(data, open(p,"w",encoding="utf-8"), ensure_ascii=False, indent=2)
    open(p,"a").write("\n")
print(len(K), "keys")
