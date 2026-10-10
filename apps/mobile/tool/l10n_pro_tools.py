# Pro vositalar: kengaytirilgan qidiruv (faset + teskari qidiruv) va
# «Modda bo‘yicha tahlil rejasi». Idempotent: har ishga tushirishda ARB
# kalitlarini qayta yozadi (qo‘shilmaydi).
import json, collections, re

D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)


S = {"type": "String"}
I = {"type": "int"}


def p(*names, ints=()):
    return {n: (I if n in ints else S) for n in names}


# ---------------------------------------------------------------- QIDIRUV
k("proSearchTitle", "Title of the Pro advanced search screen.",
  "Advanced search", "Расширенный поиск", "Kengaytirilgan qidiruv")
k("proSearchEntry", "Chip on the search screen that opens the Pro advanced search.",
  "Filters and reverse lookups", "Фильтры и обратный поиск", "Filtrlar va teskari qidiruv")
k("proSearchIntro", "Intro text of the advanced search screen.",
  "Narrow the offline pack by specimen, method, reagent, evidence level and more, or go from a specimen, method or reagent to the substances documented for it.",
  "Сузьте поиск по образцу, методу, реагенту, уровню доказательности и другим признакам или перейдите от образца, метода или реагента к веществам, для которых они задокументированы.",
  "Qidiruvni namuna, metod, reagent, dalil darajasi va boshqa belgilar bo‘yicha toraytiring yoki namuna, metod yoki reagentdan unga hujjatlashtirilgan moddalarga o‘ting.")
k("proSearchLockedTitle", "Paywall card title on the advanced search screen. {tier} is the plan name.",
  "Advanced search — {tier}", "Расширенный поиск — {tier}", "Kengaytirilgan qidiruv — {tier}", p("tier"))
k("proSearchLockedBody", "Paywall card body on the advanced search screen.",
  "Filters (discipline, class, specimen, method, reagent, evidence, review status, jurisdiction, year), exact-phrase search and reverse lookups need a paid plan. The regular search stays available to everyone.",
  "Фильтры (дисциплина, класс, образец, метод, реагент, уровень доказательности, статус проверки, юрисдикция, год), поиск по точной фразе и обратный поиск доступны по платному тарифу. Обычный поиск остаётся доступным всем.",
  "Filtrlar (fan, sinf, namuna, metod, reagent, dalil darajasi, tekshiruv holati, yurisdiksiya, yil), aniq ibora bo‘yicha qidiruv va teskari qidiruv pullik tarifga kiradi. Oddiy qidiruv hammaga ochiq.")
k("proSearchHint", "Hint of the advanced search text field.",
  "Name, synonym or \"phrase\"", "Название, синоним или «фраза»", "Nom, sinonim yoki «ibora»")
k("proSearchExact", "Switch: match the whole name or synonym only.",
  "Exact match", "Точное совпадение", "Aniq moslik")
k("proTabSearch", "Tab: faceted search.", "Search", "Поиск", "Qidiruv")
k("proTabReverse", "Tab: reverse lookups.", "Reverse lookup", "Обратный поиск", "Teskari qidiruv")
k("proFilters", "Heading of the filter block.", "Filters", "Фильтры", "Filtrlar")
k("proFiltersClear", "Button: reset all facet filters.", "Clear filters", "Сбросить фильтры", "Filtrlarni tozalash")
k("proFacetAny", "Facet subtitle when nothing is selected.", "Any", "Любой", "Istalgan")
k("proFacetDiscipline", "Facet title.", "Discipline", "Дисциплина", "Fan")
k("proFacetClass", "Facet title.", "Substance class", "Класс вещества", "Modda sinfi")
k("proFacetSpecimen", "Facet title.", "Specimen", "Образец", "Namuna")
k("proFacetFamily", "Facet title.", "Method family", "Семейство методов", "Metodlar oilasi")
k("proFacetReagent", "Facet title.", "Reagent", "Реагент", "Reaktiv")
k("proFacetEvidence", "Facet title.", "Evidence level", "Уровень доказательности", "Dalil darajasi")
k("proFacetStatus", "Facet title.", "Review status", "Статус проверки", "Tekshiruv holati")
k("proFacetJurisdiction", "Facet title.", "Jurisdiction", "Юрисдикция", "Yurisdiksiya")
k("proFacetYear", "Facet title.", "Source year", "Год источника", "Manba yili")
k("proEvidenceAtLeast", "Evidence facet chip. {level} is A, B, C or D.",
  "Level {level} or higher", "Уровень {level} и выше", "{level} daraja va undan yuqori", p("level"))
k("proYearSince", "Year facet chip.", "Since {year}", "С {year} года", "{year}-yildan boshlab", p("year", ints=("year",)))
k("proFamilyName", "Method family label (select on the family code).",
  "{code, select, colourTest{Colour (spot) test} tlc{TLC (thin-layer chromatography)} microcrystal{Microcrystal test} uvVis{UV/Vis spectrophotometry} immunoassay{Immunoassay} gcMs{GC-MS} lcMs{LC-MS, LC-MS/MS} hrms{HRMS (high-resolution MS)} gcFid{GC-FID, headspace GC} hplc{HPLC} other{{code}}}",
  "{code, select, colourTest{Цветная (капельная) реакция} tlc{TLC (тонкослойная хроматография)} microcrystal{Микрокристаллоскопия} uvVis{УФ/видимая спектрофотометрия} immunoassay{Иммунохимический анализ} gcMs{GC-MS} lcMs{LC-MS, LC-MS/MS} hrms{HRMS (масс-спектрометрия высокого разрешения)} gcFid{GC-FID, парофазная GC} hplc{HPLC} other{{code}}}",
  "{code, select, colourTest{Rangli (tomchi) test} tlc{TQX (yupqa qatlamli xromatografiya)} microcrystal{Mikrokristal test} uvVis{UB/ko‘rinuvchi spektrofotometriya} immunoassay{Immunokimyoviy tahlil} gcMs{GC-MS} lcMs{LC-MS, LC-MS/MS} hrms{HRMS (yuqori aniqlikdagi mass-spektrometriya)} gcFid{GC-FID, bug‘ fazali GC} hplc{HPLC} other{{code}}}",
  p("code"))
k("proResultCount", "Number of search results.",
  "{count, plural, =1{1 result} other{{count} results}}",
  "{count, plural, one{{count} результат} few{{count} результата} many{{count} результатов} other{{count} результата}}",
  "{count} ta natija", p("count", ints=("count",)))
k("proResultsNoneTitle", "Empty-result title.",
  "No match in the pack", "В пакете ничего не найдено", "Paketda mos yozuv topilmadi")
k("proResultsNoneBody", "Empty-result body.",
  "Nothing matches this combination. Remove a filter, switch off exact match or try another spelling or language.",
  "Ничего не подходит под эту комбинацию. Уберите фильтр, отключите точное совпадение или попробуйте другое написание или язык.",
  "Bu birikmaga hech narsa mos kelmadi. Filtrni olib tashlang, aniq moslikni o‘chiring yoki boshqa yozilish yoki tilni sinab ko‘ring.")
k("proResultsStart", "Hint before any query or filter.",
  "Type a name or pick a filter to see results.", "Введите название или выберите фильтр, чтобы увидеть результаты.",
  "Natijalarni ko‘rish uchun nom yozing yoki filtr tanlang.")
# teskari qidiruv
k("proReverseReagent", "Reverse lookup mode.", "Reagent → substances", "Реагент → вещества", "Reagent → moddalar")
k("proReverseSpecimen", "Reverse lookup mode.", "Specimen → analytes", "Образец → аналиты", "Namuna → analitlar")
k("proReverseMethod", "Reverse lookup mode.", "Method → substances", "Метод → вещества", "Metod → moddalar")
k("proReversePick", "Prompt in reverse lookup.",
  "Choose one to see which substances the pack documents for it.",
  "Выберите, чтобы увидеть, для каких веществ в пакете есть данные.",
  "Paketda qaysi moddalar hujjatlashtirilganini ko‘rish uchun birini tanlang.")
k("proReverseCount", "Number of substances in a reverse lookup.",
  "{count, plural, =1{1 substance} other{{count} substances}}",
  "{count, plural, one{{count} вещество} few{{count} вещества} many{{count} веществ} other{{count} вещества}}",
  "{count} ta modda", p("count", ints=("count",)))
k("proReverseNoReagents", "Reverse reagent lookup when the pack has no reagent-substance link.",
  "The pack documents no link between a reagent and a substance yet ({count} reagent recipes exist). Nothing is guessed.",
  "В пакете пока нет связей «реагент — вещество» (рецептов реагентов: {count}). Ничего не домысливается.",
  "Paketda reagent va modda orasidagi bog‘lanish hali yo‘q (reagent retseptlari: {count} ta). Hech narsa taxmin qilinmaydi.",
  p("count", ints=("count",)))
k("proReverseEmpty", "Reverse lookup with no substances.",
  "No substance is documented for this item in the pack.",
  "Для этого элемента в пакете нет задокументированных веществ.",
  "Bu element uchun paketda hujjatlashtirilgan modda yo‘q.")
k("proReverseNote", "Reverse lookup caveat.",
  "Only links stated in the sources. Not found here does not mean not possible.",
  "Только связи, указанные в источниках. «Не найдено» не означает «невозможно».",
  "Faqat manbalarda ko‘rsatilgan bog‘lanishlar. Bu yerda topilmasa — mumkin emas degani emas.")
k("proRoleAnalysed", "Reverse lookup role.", "analysed with this method (source)",
  "анализировалось этим методом (источник)", "shu metod bilan tahlil qilingan (manba)")
k("proRoleConfirmation", "Reverse lookup role.", "confirmation after screening",
  "подтверждение после скрининга", "skriningdan keyingi tasdiqlash")
k("proRoleScreened", "Reverse lookup role.", "screened with this test",
  "скрининг этим тестом", "shu test bilan skrining")
k("proRoleMeasured", "Reverse lookup role.", "value reported in this specimen (not a threshold)",
  "значение приведено для этого образца (не порог)", "shu namunada qiymat keltirilgan (chegara emas)")
k("proViaLabel", "Reverse lookup: intermediate record names.", "via {names}", "через {names}", "{names} orqali", p("names"))

# ---------------------------------------------------------------- REJA
k("planEntryTitle", "Entry card on the substance page.",
  "Analysis plan for this substance", "План анализа для этого вещества", "Modda bo‘yicha tahlil rejasi")
k("planEntryBody", "Entry card body.",
  "Specimens, presumptive tests, confirmation, interferences, limits and a note for your conclusion on one page, with sources.",
  "Образцы, предварительные тесты, подтверждение, помехи, ограничения и памятка для заключения на одной странице, с источниками.",
  "Namunalar, taxminiy testlar, tasdiqlash, halaqitlar, cheklovlar va xulosa uchun eslatma — bitta sahifada, manbalari bilan.")
k("planTitle", "Screen title.", "Analysis plan", "План анализа", "Tahlil rejasi")
k("planIntro", "Banner at the top of the plan.",
  "Assembled only from sourced statements already in the pack. It is a reference outline, not a validated procedure and not an expert conclusion.",
  "Составлен только из утверждений с источниками, уже имеющихся в пакете. Это справочная схема, а не валидированная методика и не заключение эксперта.",
  "Faqat paketdagi manbali bayonlardan yig‘ilgan. Bu ma’lumotnoma sxema — tasdiqlangan protsedura ham, ekspert xulosasi ham emas.")
k("planSummary", "Free preview summary line.",
  "Specimens: {s} · Presumptive tests: {p} · Confirmation: {c} · Limits: {l}",
  "Образцы: {s} · Предварительные тесты: {p} · Подтверждение: {c} · Ограничения: {l}",
  "Namunalar: {s} · Taxminiy testlar: {p} · Tasdiqlash: {c} · Cheklovlar: {l}",
  p("s", "p", "c", "l", ints=("s", "p", "c", "l")))
k("planLockedTitle", "Paywall card title on the plan. {tier} is the plan name.",
  "Full analysis plan — {tier}", "Полный план анализа — {tier}", "To‘liq tahlil rejasi — {tier}", p("tier"))
k("planLockedBody", "Paywall card body on the plan.",
  "The free preview shows the counts and the specimens. The paid plan adds presumptive tests with reagents, bench and confirmation steps, interferences, limits, the note for your conclusion and a copyable text with full citations.",
  "Бесплатный просмотр показывает количество и образцы. Платный тариф добавляет предварительные тесты с реагентами, лабораторные и подтверждающие этапы, помехи, ограничения, памятку для заключения и копируемый текст с полными ссылками.",
  "Bepul ko‘rinishda sonlar va namunalar ko‘rsatiladi. Pullik tarif reagentli taxminiy testlar, stol usullari va tasdiqlash bosqichlari, halaqitlar, cheklovlar, xulosa uchun eslatma hamda to‘liq iqtiboslar bilan nusxalanadigan matnni qo‘shadi.")
k("planSecSpecimens", "Plan section title.", "Specimens and sampling notes",
  "Образцы и заметки о взятии", "Namunalar va namuna olish bo‘yicha izohlar")
k("planSecPresumptive", "Plan section title.", "Presumptive tests (reagent and observation)",
  "Предварительные тесты (реагент и наблюдение)", "Taxminiy (presumptive) testlar: reagent va kuzatuv")
k("planSecBench", "Plan section title.", "TLC, microcrystal and UV/Vis",
  "TLC, микрокристаллоскопия и УФ/Вид", "TLC, mikrokristal va UB/Vis")
k("planSecConfirmation", "Plan section title.", "Confirmation step",
  "Этап подтверждения", "Tasdiqlash bosqichi")
k("planSecInstrumental", "Plan section title.", "Other instrumental methods in the sources",
  "Другие инструментальные методы в источниках", "Manbalardagi boshqa instrumental metodlar")
k("planSecInterferences", "Plan section title.", "Interferences, cross-reactivity and false results",
  "Помехи, перекрёстная реактивность и ложные результаты", "Halaqitlar, o‘zaro reaksiya va yolg‘on natijalar")
k("planSecLimits", "Plan section title.", "Interpretation limits",
  "Границы интерпретации", "Talqin chegaralari")
k("planSecReminder", "Plan section title.", "Note for the conclusion",
  "Памятка для заключения", "Xulosa uchun eslatma")
k("planNoSpecimens", "Empty block.", "No specimen is documented for this substance in the pack.",
  "Для этого вещества в пакете нет задокументированных образцов.", "Bu modda uchun paketda hujjatlashtirilgan namuna yo‘q.")
k("planNoSamplingNotes", "Empty block.", "No collection or preservation note is documented for these specimens in the pack.",
  "Для этих образцов в пакете нет заметок о взятии или консервации.", "Bu namunalar uchun paketda namuna olish yoki saqlash bo‘yicha izoh yo‘q.")
k("planNoPresumptive", "Empty block.", "No presumptive test is documented for this substance in the pack.",
  "Для этого вещества в пакете нет предварительных тестов.", "Bu modda uchun paketda taxminiy test hujjatlashtirilmagan.")
k("planNoReagents", "Empty block.", "No reagent and expected observation pair is documented for this test in the pack.",
  "Для этого теста в пакете нет пары «реагент — ожидаемое наблюдение».", "Bu test uchun paketda «reagent — kutilgan kuzatuv» jufti hujjatlashtirilmagan.")
k("planNoBench", "Empty block.", "No TLC, microcrystal or UV/Vis system is documented for this substance in the pack.",
  "Для этого вещества в пакете нет систем TLC, микрокристаллоскопии или УФ/Вид.", "Bu modda uchun paketda TLC, mikrokristal yoki UB/Vis tizimi hujjatlashtirilmagan.")
k("planNoConfirmation", "Empty block.", "No confirmation method is documented for this substance in the pack.",
  "Для этого вещества в пакете нет подтверждающего метода.", "Bu modda uchun paketda tasdiqlovchi metod hujjatlashtirilmagan.")
k("planNoInstrumental", "Empty block.", "No other instrumental method is mentioned with this substance in the pack.",
  "Других инструментальных методов для этого вещества в пакете не упоминается.", "Bu modda bilan paketda boshqa instrumental metod tilga olinmagan.")
k("planNoInterferences", "Empty block.", "No interference, cross-reactivity or false result is documented for the tests of this substance in the pack.",
  "Для тестов этого вещества в пакете нет помех, перекрёстной реактивности и ложных результатов.", "Bu moddaning testlari uchun paketda halaqit, o‘zaro reaksiya yoki yolg‘on natija hujjatlashtirilmagan.")
k("planNoLimits", "Empty block.", "No sourced limitation statement for these specimens and methods in the pack.",
  "Для этих образцов и методов в пакете нет ограничений с источником.", "Bu namunalar va metodlar uchun paketda manbali cheklov bayoni yo‘q.")
k("planConfirmRequired", "Chip on the confirmation block.", "Confirmation required",
  "Требуется подтверждение", "Tasdiqlash shart")
k("planReagentsLabel", "Label above the reagents of a presumptive test.", "Reagents linked in the sources",
  "Реагенты, связанные в источниках", "Manbalarda bog‘langan reagentlar")
k("planReagentRecipe", "Button: open the reagent recipe.", "Reagent recipe", "Рецепт реагента", "Reagent retsepti")
k("planPrinciple", "Presumptive test principle line.", "Principle: {principle}",
  "Принцип: {principle}", "Tamoyil: {principle}", p("principle"))
k("planNotDefinitive", "Presumptive test note.", "The sources do not present this test as definitive identification.",
  "Источники не представляют этот тест как окончательную идентификацию.", "Manbalar bu testni aniq identifikatsiya sifatida ko‘rsatmaydi.")
k("planAbout", "Line under a quote: which test, method or specimen the statement belongs to (not the substance).",
  "Applies to: {name}", "Относится к: {name}", "Tegishli: {name}", p("name"))
k("planSourceLine", "Source line under a plan statement.", "Source: {title}",
  "Источник: {title}", "Manba: {title}", p("title"))
k("planLocatorLine", "Locator line under a plan statement.", "Location: {locator}",
  "Место в источнике: {locator}", "Manbadagi joyi: {locator}", p("locator"))
k("planNoSource", "Statement without a source.", "Source not stated", "Источник не указан", "Manba ko‘rsatilmagan")
k("planRoleName", "Role label of a quote (select on the role code).",
  "{role, select, basis{Source statement} presumptive{Presumptive nature} confirmationRequirement{Confirmation requirement} limitation{Limitation} crossReactivity{Cross-reactivity} falsePositive{False positive} falseNegative{False negative} interference{Interference} detectionWindow{Detection window} use{Collection / use note} principle{Principle} application{Application} observation{Expected observation} other{{role}}}",
  "{role, select, basis{Утверждение источника} presumptive{Предварительный характер} confirmationRequirement{Требование подтверждения} limitation{Ограничение} crossReactivity{Перекрёстная реактивность} falsePositive{Ложноположительный результат} falseNegative{Ложноотрицательный результат} interference{Помеха} detectionWindow{Окно обнаружения} use{Заметка о взятии / применении} principle{Принцип} application{Применение} observation{Ожидаемое наблюдение} other{{role}}}",
  "{role, select, basis{Manba bayoni} presumptive{Taxminiy xususiyati} confirmationRequirement{Tasdiqlash talabi} limitation{Cheklov} crossReactivity{O‘zaro reaksiya} falsePositive{Yolg‘on musbat natija} falseNegative{Yolg‘on manfiy natija} interference{Halaqit} detectionWindow{Aniqlash oynasi} use{Namuna olish / qo‘llash izohi} principle{Tamoyil} application{Qo‘llanilishi} observation{Kutilgan kuzatuv} other{{role}}}",
  p("role"))
k("planMayHeading", "Reminder group heading.", "May rely on", "На что можно опираться", "Tayanish mumkin")
k("planMayNotHeading", "Reminder group heading.", "Do not state", "Чего не утверждать", "Aytmaslik kerak")
k("planRemPresumptiveOnly", "Reminder. {tests} are screening test names.",
  "The sources do not support definitive identification by: {tests}. State such a result as presumptive only.",
  "Источники не подтверждают окончательную идентификацию по: {tests}. Такой результат указывайте только как предварительный.",
  "Manbalar quyidagilar bo‘yicha aniq identifikatsiyani tasdiqlamaydi: {tests}. Bunday natijani faqat taxminiy deb yozing.", p("tests"))
k("planRemConfirmDocumented", "Reminder. {methods} are confirmation method names.",
  "The pack names these confirmation methods: {methods}. Cite them only if your laboratory actually performed them.",
  "Пакет называет эти подтверждающие методы: {methods}. Ссылайтесь на них, только если ваша лаборатория действительно их выполнила.",
  "Paketda quyidagi tasdiqlovchi metodlar nomlangan: {methods}. Ularni faqat laboratoriyangiz haqiqatan bajargan bo‘lsa keltiring.", p("methods"))
k("planRemConfirmMissing", "Reminder.",
  "No confirmation method is documented in the pack for the tests above. Do not state a confirmed identification on the basis of this pack.",
  "Для тестов выше в пакете нет подтверждающего метода. Не утверждайте подтверждённую идентификацию на основании этого пакета.",
  "Yuqoridagi testlar uchun paketda tasdiqlovchi metod yo‘q. Shu paket asosida tasdiqlangan identifikatsiya haqida yozmang.")
k("planRemNotThreshold", "Reminder.",
  "Concentration records in the pack ({count}) are reported observations, not thresholds or cut-offs. Do not present them as reference limits.",
  "Записи о концентрации в пакете ({count}) — сообщённые наблюдения, а не пороги или cut-off. Не выдавайте их за референсные границы.",
  "Paketdagi konsentratsiya yozuvlari ({count} ta) — manbada keltirilgan kuzatuv, chegara yoki cut-off emas. Ularni mezon chegarasi sifatida ko‘rsatmang.",
  p("count", ints=("count",)))
k("planRemNotPaired", "Reminder.",
  "The sources do not tie the methods to the specimens. Do not state which method was used on which specimen on the basis of this pack.",
  "Источники не связывают методы с образцами. Не утверждайте, какой метод применялся к какому образцу, на основании этого пакета.",
  "Manbalar metodlarni namunalarga bog‘lamaydi. Shu paket asosida qaysi metod qaysi namunada qo‘llanganini yozmang.")
k("planRemNothingVerified", "Reminder.",
  "No statement here has been verified by an expert reviewer. Do not present it as verified scientific data.",
  "Ни одно утверждение здесь не проверено рецензентом-экспертом. Не выдавайте его за проверенные научные данные.",
  "Bu yerdagi birorta bayon ekspert-reviewer tomonidan tasdiqlanmagan. Uni tasdiqlangan ilmiy ma’lumot deb ko‘rsatmang.")
k("planRemConflict", "Reminder.",
  "Open evidence conflicts recorded for this substance: {count}. Check before relying on it.",
  "Открытых конфликтов данных по этому веществу: {count}. Проверьте, прежде чем опираться.",
  "Bu modda bo‘yicha ochiq dalillar ziddiyatlari: {count} ta. Tayanishdan oldin tekshiring.",
  p("count", ints=("count",)))
k("planRemNoData", "Reminder.",
  "The pack has no analysis data for this substance. This page cannot support a conclusion.",
  "В пакете нет данных об анализе этого вещества. Эта страница не может служить основанием для заключения.",
  "Paketda bu modda uchun tahlil ma’lumoti yo‘q. Bu sahifa xulosaga asos bo‘la olmaydi.")
k("planReminderFootnote", "Footnote under the conclusion note.",
  "Based only on flags and sourced limitation statements in the pack. It adds no new scientific claim and is not an expert opinion.",
  "Основано только на признаках и ограничениях с источниками в пакете. Не добавляет новых научных утверждений и не является заключением эксперта.",
  "Faqat paketdagi belgilar va manbali cheklov bayonlariga asoslangan. Yangi ilmiy da’vo qo‘shmaydi va ekspert xulosasi emas.")
k("planCopy", "Tooltip: copy the plan as text.", "Copy the plan with citations", "Скопировать план со ссылками", "Rejani iqtiboslari bilan nusxalash")
k("planCopied", "Snackbar after copying.", "Plan copied with full citations", "План скопирован с полными ссылками", "Reja to‘liq iqtiboslari bilan nusxalandi")
k("planExportHeader", "Header of the copied text.", "ANALYSIS PLAN — {name}", "ПЛАН АНАЛИЗА — {name}", "TAHLIL REJASI — {name}", p("name"))
k("planExportDisclaimer", "Disclaimer in the copied text.",
  "Reference outline compiled from the sourced statements of the content pack. Not a validated procedure and not an expert conclusion; check every statement against the original source.",
  "Справочная схема, составленная из утверждений с источниками в пакете контента. Не валидированная методика и не заключение эксперта; проверяйте каждое утверждение по первоисточнику.",
  "Kontent paketidagi manbali bayonlardan tuzilgan ma’lumotnoma sxema. Tasdiqlangan protsedura ham, ekspert xulosasi ham emas; har bir bayonni asl manba bilan tekshiring.")
k("planExportSources", "Heading of the reference list in the copied text.", "SOURCES", "ИСТОЧНИКИ", "MANBALAR")
k("planExportOriginal", "Label of the original quote in the copied text.", "Original", "Оригинал", "Asl matn")
k("planExportStatus", "Status and level in the copied text. {status} is the review status, {level} the evidence level.",
  "status: {status}; evidence level: {level}", "статус: {status}; уровень доказательности: {level}",
  "holati: {status}; dalil darajasi: {level}", p("status", "level"))

for idx, code in enumerate(["en", "ru", "uz"]):
    path = f"{D}/app_{code}.arb"
    data = json.load(open(path, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key, (desc, en, ru, uz, ph) in K.items():
        data[key] = (en, ru, uz)[idx]
        if code == "en":
            meta = {"description": desc}
            names = sorted(set(re.findall(r"\{(\w+)(?:,|\})", en)) - {"other"})
            if ph:
                meta["placeholders"] = ph
            data["@" + key] = meta
    json.dump(data, open(path, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    open(path, "a").write("\n")
print(len(K), "keys")
