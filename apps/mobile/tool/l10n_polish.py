# Real-device polish: ichki/dev so‘zlarsiz matnlar, bo‘sh holatlar, AI
# preview, konsentratsiya kartasi, kalkulyator statuslari. RU/UZ — tahrir
# qilingan; yakuniy tarjima reviewer tasdig‘i kerak (RG-11).
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}
I = {"type": "int"}

# --- Mavjud kalitlar: professional matn --------------------------------------
k("inDevelopmentTitle","Empty state title.","No reviewed content to show","Нет проверенного содержания","Ko‘rsatish uchun tekshirilgan ma’lumot yo‘q")
k("inDevelopmentBody","Empty state body.","Content appears here only when it has a verifiable source and has passed expert review. Nothing is filled in just to make the screen look complete.","Содержание появляется здесь только при наличии проверяемого источника и после экспертной проверки. Экран не заполняется данными ради внешнего вида.","Bu yerda ma’lumot faqat tekshiriladigan manbaga ega bo‘lsa va ekspert tekshiruvidan o‘tgandan keyin paydo bo‘ladi. Ekran to‘liq ko‘rinishi uchun ma’lumot to‘qilmaydi.")
k("homePrototypeNotice","Demo-build notice.","Demonstration build: entries marked SAMPLE are illustrative and are not scientific content.","Демонстрационная сборка: записи с пометкой ОБРАЗЕЦ носят иллюстративный характер и не являются научным содержанием.","Namoyish yig‘masi: NAMUNA belgili yozuvlar faqat tasviriy, ilmiy ma’lumot emas.")
k("testDataBadge","Badge for illustrative sample entries.","SAMPLE","ОБРАЗЕЦ","NAMUNA")
k("detailPlaceholder","Entry without reviewed details.","No reviewed scientific details are available for this entry yet.","Проверенные научные сведения для этой записи пока отсутствуют.","Bu yozuv uchun tekshirilgan ilmiy ma’lumot hozircha mavjud emas.")
k("sourcesNone","No sources.","No sources are linked to this entry.","К этой записи не привязаны источники.","Bu yozuvga manba biriktirilmagan.")
k("homePilotNotice","Home review notice.","The scientific database is under expert review. Every entry is shown with its sources and review status and is not a final conclusion.","Научная база проходит экспертную проверку. Каждая запись показана с источниками и статусом проверки и не является окончательным выводом.","Ilmiy baza ekspert tekshiruvida. Har bir yozuv manbasi va tekshiruv holati bilan ko‘rsatiladi va yakuniy xulosa hisoblanmaydi.")
k("jurisdictionWithContent","Section.","Jurisdictions with legal records","Юрисдикции с правовыми записями","Huquqiy yozuvlari bor yurisdiksiyalar")
k("jurisdictionPilotContent","Status.","Legal records · under legal review","Правовые записи · на юридической проверке","Huquqiy yozuvlar · yuridik tekshiruvda")
k("ctxAutoMinimal","Concentration context not curated.","Reviewed contextual data for this record is not yet available.","Проверенные контекстные данные для этой записи пока отсутствуют.","Ushbu yozuv bo‘yicha tekshirilgan kontekstual ma’lumot hozircha mavjud emas.")
k("searchExternalBody","External search note.","External databases (PubMed, PubChem, Crossref) are not connected in this version. External results are never mixed with the reviewed internal database.","Внешние базы (PubMed, PubChem, Crossref) в этой версии не подключены. Внешние результаты никогда не смешиваются с проверенной внутренней базой.","Tashqi bazalar (PubMed, PubChem, Crossref) bu versiyada ulanmagan. Tashqi natijalar hech qachon tekshirilgan ichki baza bilan aralashtirilmaydi.")
k("disciplinesIntro","Disciplines intro.","FORENSIC EXPERT covers these disciplines. Content is added gradually and only with sources and expert review — an empty discipline means “no sourced content yet”, not “no knowledge exists”.","FORENSIC EXPERT охватывает эти дисциплины. Содержание добавляется постепенно и только с источниками и экспертной проверкой — пустая дисциплина означает «пока нет материалов с источниками», а не «знаний нет».","FORENSIC EXPERT shu fanlarni qamrab oladi. Ma’lumotlar bosqichma-bosqich, faqat manba va ekspert tekshiruvi bilan qo‘shiladi — bo‘sh fan «hali manbali ma’lumot yo‘q» degani, «bilim yo‘q» degani emas.")
k("aiPreviewTitle","Section.","Answer layout (demonstration)","Структура ответа (демонстрация)","Javob tuzilmasi (namoyish)")
k("aiPreviewNotice","Demo notice.","DEMONSTRATION — this is not an AI response and not scientific advice. It only shows how a connected answer will be structured.","ДЕМОНСТРАЦИЯ — это не ответ ИИ и не научная рекомендация. Показано лишь, как будет устроен ответ после подключения.","NAMOYISH — bu AI javobi ham, ilmiy tavsiya ham emas. Faqat ulangan javob qanday tuzilishini ko‘rsatadi.")
k("aiSampleInternal","Demo statement.","Example statement linked to a reviewed internal source.","Пример утверждения со ссылкой на проверенный внутренний источник.","Tekshirilgan ichki manbaga bog‘langan fikr namunasi.")
k("aiSampleExternal","Demo statement.","Example statement from an external source that has not been reviewed.","Пример утверждения из внешнего источника, не прошедшего проверку.","Tekshirilmagan tashqi manbadan olingan fikr namunasi.")
k("aiSampleLimitation","Demo statement.","Example limitation — a final interpretation requires the full case context.","Пример ограничения — окончательная интерпретация требует полного контекста случая.","Cheklov namunasi — yakuniy talqin uchun holatning to‘liq konteksti kerak.")
k("aiPlaceholderSource","Demo source.","Example source {number}","Пример источника {number}","Manba namunasi {number}",{"number":I})
k("aiLimMock","Limitation.","Demonstration provider — no real AI answer was generated.","Демонстрационный провайдер — реальный ответ ИИ не сформирован.","Namoyish provayderi — haqiqiy AI javobi yaratilmadi.")
k("aiNotConnectedTitle","AI state title.","Production AI service is not connected","Рабочий ИИ-сервис не подключён","Ishchi AI xizmati ulanmagan")

# --- Bo‘sh / mavjudlik holatlari ---------------------------------------------
k("availNoDataTitle","Empty state.","No records yet","Записей пока нет","Hozircha yozuvlar yo‘q")
k("availNoDataBody","Empty state.","The installed scientific database has no records for this section.","В установленной научной базе для этого раздела записей нет.","O‘rnatilgan ilmiy bazada bu bo‘lim uchun yozuvlar yo‘q.")
k("availFilterTitle","Empty state.","No results for the selected filter","По выбранному фильтру ничего не найдено","Tanlangan filtr bo‘yicha natija yo‘q")
k("availFilterBody","Empty state.","No reviewed records match the selected filter. Clear the filter or search the whole database.","Нет проверенных записей, соответствующих фильтру. Сбросьте фильтр или выполните поиск по всей базе.","Tanlangan filtr bo‘yicha ko‘rsatish uchun tekshirilgan yozuvlar mavjud emas. Filtrni tozalang yoki butun bazadan qidiring.")
k("availNotConnectedTitle","Empty state.","Not available in this version","Недоступно в этой версии","Bu versiyada mavjud emas")
k("availNotConnectedBody","Empty state.","This feature needs an online service that is not connected in this version. All offline features keep working.","Для этой функции нужен онлайн-сервис, который в этой версии не подключён. Все офлайн-функции продолжают работать.","Bu funksiya uchun bu versiyada ulanmagan onlayn xizmat kerak. Barcha oflayn funksiyalar ishlashda davom etadi.")
k("availServiceTitle","Empty state.","Service temporarily unavailable","Сервис временно недоступен","Xizmat vaqtincha ishlamayapti")
k("availServiceBody","Empty state.","Check the connection and try again later. Offline features keep working.","Проверьте подключение и повторите позже. Офлайн-функции продолжают работать.","Aloqani tekshirib, keyinroq qayta urinib ko‘ring. Oflayn funksiyalar ishlashda davom etadi.")
k("availClearFilters","Action.","Clear filters","Сбросить фильтры","Filtrlarni tozalash")
k("availBrowseAll","Action.","Browse all records","Все записи","Barcha yozuvlarni ko‘rish")
k("availSearch","Action.","Search","Поиск","Qidirish")

# --- Forensic AI preview ------------------------------------------------------
k("aiStatusPreview","AI status chip.","Preview · not connected","Предпросмотр · не подключён","Namoyish · ulanmagan")
k("aiPreviewPoint1","AI preview bullet.","This screen is an interface preview.","Этот экран — предпросмотр интерфейса.","Bu ekran — interfeys namoyishi.")
k("aiPreviewPoint2","AI preview bullet.","The production AI service is not connected, so no AI answer is generated.","Рабочий ИИ-сервис не подключён, поэтому ответ ИИ не формируется.","Ishchi AI xizmati ulanmagan, shuning uchun AI javobi yaratilmaydi.")
k("aiPreviewPoint3","AI preview bullet.","The sample answer below is a demonstration of the layout only.","Пример ответа ниже — только демонстрация структуры.","Quyidagi javob namunasi faqat tuzilma namoyishi.")
k("aiPreviewPoint4","AI preview bullet.","“Find sources offline” searches the local database and works now.","«Найти источники офлайн» ищет в локальной базе и работает уже сейчас.","«Manbalarni oflayn topish» lokal bazadan qidiradi va hozir ishlaydi.")
k("aiSendUnavailable","AI send note.","Sending is disabled until the AI service is connected.","Отправка недоступна, пока ИИ-сервис не подключён.","AI xizmati ulanmaguncha yuborish o‘chirilgan.")

# --- Konsentratsiya kartasi ---------------------------------------------------
k("concWarning","Critical warning on concentration values.","This value comes from an individual case or study. It must not be interpreted as a universal toxic, lethal, therapeutic or legal threshold.","Это значение получено из отдельного случая или исследования. Его нельзя трактовать как универсальный токсический, смертельный, терапевтический или правовой порог.","Bu qiymat alohida holat yoki tadqiqotdan olingan. Universal toksik, o‘limga olib keluvchi, terapevtik yoki huquqiy chegara sifatida talqin qilinmasligi kerak.")
k("concTitle","Card title.","Reported concentration","Сообщаемая концентрация","Qayd etilgan konsentratsiya")
k("concSubstance","Row.","Substance","Вещество","Modda")
k("concValue","Row.","Value and unit","Значение и единица","Qiymat va birlik")
k("concValueInQuote","Value.","As quoted in the source (see excerpt)","Как приведено в источнике (см. цитату)","Manbada keltirilganidek (iqtibosga qarang)")
k("concLivingPostmortem","Row.","Living / post-mortem","Прижизненно / посмертно","Tirik / o‘limdan keyin")
k("concSourceType","Row.","Source type","Тип источника","Manba turi")
k("concSectionCase","Source section.","Case description","Описание случая","Holat tavsifi")
k("concSectionAbstract","Source section.","Abstract","Аннотация","Annotatsiya")
k("concSectionIntro","Source section.","Introduction (background)","Введение (обзор)","Kirish (umumiy ma’lumot)")
k("concSectionResults","Source section.","Results","Результаты","Natijalar")
k("concSectionDiscussion","Source section.","Discussion","Обсуждение","Muhokama")
k("concStudyContext","Row.","Case / study context","Контекст случая / исследования","Holat / tadqiqot konteksti")
k("concEvidenceLevel","Row.","Evidence level","Уровень доказательности","Dalil darajasi")
k("concReviewStatus","Row.","Review status","Статус проверки","Tekshiruv holati")
k("concSource","Row.","Source","Источник","Manba")
k("concNotAvailable","Missing metadata.","Not available","Нет данных","Ma’lumot mavjud emas")
k("concExcerpt","Row.","Source excerpt","Цитата из источника","Manbadan iqtibos")

# --- Kalkulyator statuslari ---------------------------------------------------
k("calcStatusTitle","Section.","Status","Статус","Holat")
k("calcEngineLabel","Row.","Calculation engine","Расчётный модуль","Hisoblash moduli")
k("calcEngineTested","Value.","Checked by automated software tests — this is not a scientific review","Проверен автоматическими программными тестами — это не научная экспертиза","Avtomatik dasturiy testlar bilan tekshirilgan — bu ilmiy ekspertiza emas")
k("calcEngineChip","Tile chip.","Engine tested","Модуль протестирован","Modul sinovdan o‘tgan")
k("calcReferenceLabel","Row.","Formula reference","Источник формулы","Formula manbasi")
k("calcInterpretationLabel","Row.","Interpretation","Интерпретация","Talqin")
k("calcInterpretationValue","Value.","Context dependent — requires professional judgement","Зависит от контекста — требует профессиональной оценки","Kontekstga bog‘liq — professional baho talab qiladi")
k("homeHeaderSubtitle","Home header subtitle.","Forensic science reference","Справочник судебной экспертизы","Sud ekspertizasi ma’lumotnomasi")
k("statusRejected","Review status.","Rejected","Отклонено","Rad etilgan")

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
