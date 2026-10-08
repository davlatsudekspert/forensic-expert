# «O‘quv rejimi» — manbali kartochkalar va o‘z-o‘zini tekshirish testi.
# Ishga tushirish: apps/mobile ichida `python3 tool/l10n_study.py`, so‘ng
# `flutter gen-l10n`.
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}
I = {"type": "int"}
k("studyTitle","Study mode title.","Study mode","Режим обучения","O‘quv rejimi")
k("studyEntrySubtitle","Learn screen entry.","Flashcards and a self-check quiz built only from sourced records in the app","Карточки и самопроверка только на основе записей приложения с источниками","Faqat ilovadagi manbali yozuvlardan tuzilgan kartochkalar va o‘z-o‘zini tekshirish testi")
k("studyIntro","Hub banner.","Every card and question is built from a record that already exists in the app, together with its source. Nothing new is written. Material that is still under expert review is labelled.","Каждая карточка и вопрос построены из записи, уже имеющейся в приложении, вместе с её источником. Новый текст не создаётся. Материал, ещё не прошедший экспертную проверку, отмечен.","Har bir kartochka va savol ilovada mavjud yozuvdan, uning manbasi bilan birga tuziladi. Yangi matn yozilmaydi. Hali ekspert tekshiruvidan o‘tmagan material belgilab qo‘yilgan.")
k("studySectionTopics","Hub section.","Topics by discipline","Темы по дисциплинам","Fanlar bo‘yicha mavzular")
k("studySectionSubstances","Hub section.","Substances: molecular formulas","Вещества: молекулярные формулы","Moddalar: molekulyar formulalar")
k("studySectionGuidelines","Hub section.","Guidelines","Методические руководства","Yo‘riqnomalar")
k("studyDeckCount","Deck size.","{count, plural, =1{1 card} other{{count} cards}}","{count, plural, one{{count} карточка} few{{count} карточки} many{{count} карточек} other{{count} карточки}}","{count, plural, other{{count} ta kartochka}}",{"count":I})
k("studyDueCount","Cards due now.","{count, plural, =0{Nothing due} other{{count} due now}}","{count, plural, =0{Нечего повторять} other{К повторению: {count}}}","{count, plural, =0{Takrorlash yo‘q} other{Takrorlash: {count} ta}}",{"count":I})
k("studyEmpty","Empty state.","No sourced material is available for study yet.","Пока нет материала с источниками для обучения.","Hozircha o‘qish uchun manbali material yo‘q.")
k("studyLoading","Skeleton semantics.","Loading study material","Загрузка учебного материала","O‘quv materiali yuklanmoqda")
k("studyQuizUnavailable","Deck note.","Not enough records of this type for a quiz","Недостаточно записей этого типа для теста","Test uchun bu turdagi yozuvlar yetarli emas")
k("studyFrontTopic","Flashcard front hint.","What does the cited source say about this topic?","Что говорит цитируемый источник об этой теме?","Keltirilgan manba bu mavzu haqida nima deydi?")
k("studyFrontSubstance","Flashcard front hint.","What is the molecular formula?","Какова молекулярная формула?","Molekulyar formulasi qanday?")
k("studyFrontGuideline","Flashcard front hint.","What is the summary of this guideline?","Каково краткое содержание этого руководства?","Bu yo‘riqnomaning qisqa mazmuni qanday?")
k("studyTapToFlip","Flashcard hint.","Tap the card to flip it","Нажмите на карточку, чтобы перевернуть её","Aylantirish uchun kartochkaga bosing")
k("studyHideAnswer","Flashcard action.","Hide answer","Скрыть ответ","Javobni yashirish")
k("studyDidntKnow","Flashcard grade.","Didn’t know","Не знал(а)","Bilmadim")
k("studyCardProgress","Flashcard progress.","Card {current} of {total}","Карточка {current} из {total}","{total} tadan {current}-kartochka",{"current":I,"total":I})
k("studyBox","Leitner box.","Box {box} of {total}","Ячейка {box} из {total}","{total} ta qutidan {box}-quti",{"box":I,"total":I})
k("studyBoxNew","Leitner box.","New card","Новая карточка","Yangi kartochka")
k("studyQuoteLabel","Answer label.","Verbatim quote from the source (original language)","Дословная цитата из источника (на языке оригинала)","Manbadan aynan iqtibos (asl tilda)")
k("studyGroupLabel","Answer meta.","Group (editorial): {group}","Группа (редакционная): {group}","Guruh (tahririy): {group}",{"group":S})
k("studySourcesHeader","Header.","Sources","Источники","Manbalar")
k("studyOpenEntry","Action.","Open the original entry","Открыть исходную запись","Asl yozuvni ochish")
k("studyOpenSourceDetails","Semantics.","Open source details","Открыть сведения об источнике","Manba tafsilotlarini ochish")
k("studyMoreSources","Overflow.","+{count} more","ещё {count}","yana {count} ta",{"count":I})
k("studySessionDone","Session end.","Session complete","Сеанс завершён","Mashg‘ulot tugadi")
k("studySessionSummary","Session end.","Knew {known} of {total}","Знал(а): {known} из {total}","{total} tadan {known} tasini bildingiz",{"known":I,"total":I})
k("studyAllCaughtUp","Nothing due.","Nothing is due in this deck right now. Come back later or review all cards.","Сейчас в этой колоде нечего повторять. Вернитесь позже или повторите все карточки.","Hozir bu to‘plamda takrorlanadigan kartochka yo‘q. Keyinroq qayting yoki barcha kartochkalarni takrorlang.")
k("studyReviewAll","Action.","Review all cards","Повторить все карточки","Barcha kartochkalarni takrorlash")
k("studyResetProgress","Action.","Reset deck progress","Сбросить прогресс колоды","To‘plam natijalarini tozalash")
k("studyResetDone","Snack.","Deck progress reset","Прогресс колоды сброшен","To‘plam natijalari tozalandi")
k("studyBackToDecks","Action.","Back to decks","К списку колод","To‘plamlar ro‘yxatiga qaytish")
k("studyQuizStemTopic","Quiz stem.","Which topic is this source quote cited for?","К какой теме относится эта цитата из источника?","Manbadagi bu iqtibos qaysi mavzuga keltirilgan?")
k("studyQuizStemSubstance","Quiz stem.","What is the molecular formula of {name}?","Какова молекулярная формула вещества «{name}»?","{name} moddasining molekulyar formulasi qanday?",{"name":S})
k("studyQuizStemGuideline","Quiz stem.","Which guideline does this summary describe?","Какое руководство описывает это краткое содержание?","Bu qisqa mazmun qaysi yo‘riqnomaga tegishli?")
k("studyQuizNote","Quiz banner.","Wrong options are other records of the same type from the app; nothing is invented.","Неверные варианты — другие записи того же типа из приложения; ничего не придумано.","Noto‘g‘ri variantlar — ilovadagi shu turdagi boshqa yozuvlar; hech narsa to‘qib chiqarilmagan.")
k("studyQuizQuestionOf","Quiz progress.","Question {current} of {total}","Вопрос {current} из {total}","{total} tadan {current}-savol",{"current":I,"total":I})
k("studyQuizNext","Action.","Next question","Следующий вопрос","Keyingi savol")
k("studyQuizFinish","Action.","See results","Показать результаты","Natijani ko‘rish")
k("studyQuizScore","Quiz result.","Score: {correct} of {total}","Результат: {correct} из {total}","Natija: {total} tadan {correct} ta",{"correct":I,"total":I})
k("studyQuizMistakes","Header.","Review your mistakes","Разбор ошибок","Xatolar tahlili")
k("studyQuizNoMistakes","Result.","No mistakes — every answer was correct.","Ошибок нет — все ответы верны.","Xato yo‘q — barcha javoblar to‘g‘ri.")
k("studyQuizYourAnswer","Mistake review.","Your answer: {answer}","Ваш ответ: {answer}","Sizning javobingiz: {answer}",{"answer":S})
k("studyQuizCorrectAnswer","Mistake review.","Correct answer: {answer}","Правильный ответ: {answer}","To‘g‘ri javob: {answer}",{"answer":S})
k("studyQuizRetry","Action.","New quiz","Новый тест","Yangi test")
k("studyDeckNotFound","Empty state.","This deck is not available.","Эта колода недоступна.","Bu to‘plam mavjud emas.")
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
