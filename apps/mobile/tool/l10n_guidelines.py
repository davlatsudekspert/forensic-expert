# «Yo‘riqnomalar» bo‘limi va admin uchun yopiq amaliyot kodlari katalogi.
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}
I = {"type": "int"}
k("guidelinesTitle","Section title.","Guidelines","Методические руководства","Yo‘riqnomalar")
k("guidelinesSubtitle","Hub subtitle.","Independent scientific-practical guidance by discipline","Независимые научно-практические руководства по дисциплинам","Fanlar bo‘yicha mustaqil ilmiy-amaliy yo‘riqnomalar")
k("guidelinesIntro","Intro banner.","Each guideline is an independent scientific synthesis written from the cited, verified literature. It is not an official methodology and does not replace accredited laboratory procedures or the law of your country. Every card stays under review until a specialist confirms it.","Каждое руководство — независимый научный обзор, написанный по указанной проверенной литературе. Это не официальная методика и не заменяет аккредитованные лабораторные процедуры и законодательство вашей страны. Каждая карточка остаётся на проверке, пока её не подтвердит специалист.","Har bir yo‘riqnoma ko‘rsatilgan va tekshirilgan adabiyot asosida yozilgan mustaqil ilmiy sintezdir. U rasmiy metodika emas, akkreditatsiyadan o‘tgan laboratoriya tartiblari va mamlakatingiz qonunchiligi o‘rnini bosmaydi. Har bir karta mutaxassis tasdiqlaguncha ko‘rik holatida qoladi.")
k("guidelinesSearchHint","Search field.","Search guidelines","Поиск по руководствам","Yo‘riqnomalardan qidirish")
k("guidelinesEmptyArea","Empty state.","No guidelines in this area yet.","В этом разделе пока нет руководств.","Bu yo‘nalishda hozircha yo‘riqnoma yo‘q.")
k("guidelinesNoResults","Empty search.","No results found","Ничего не найдено","Natija topilmadi")
k("guidelinesCount","Count.","{count, plural, =0{No guidelines} =1{1 guideline} other{{count} guidelines}}","{count, plural, =0{Нет руководств} one{{count} руководство} few{{count} руководства} many{{count} руководств} other{{count} руководства}}","{count, plural, =0{Yo‘riqnoma yo‘q} other{{count} ta yo‘riqnoma}}",{"count":I})
k("guidelineAreaForensicMedicine","Area.","Forensic medicine","Судебная медицина","Sud-tibbiyot")
k("guidelineAreaForensicChemistry","Area.","Forensic chemistry and toxicology","Судебная химия и токсикология","Sud-kimyo va toksikologiya")
k("guidelineAreaForensicHistology","Area.","Forensic histology","Судебная гистология","Sud-gistologiya")
k("guidelineAreaForensicBiology","Area.","Forensic biology and genetics","Судебная биология и генетика","Sud-biologiya va genetika")
k("guidelineAreaMedicalCriminalistics","Area.","Medical criminalistics and anthropology","Медицинская криминалистика и антропология","Tibbiy-kriminalistika va antropologiya")
k("guidelineAreaOther","Area.","Other disciplines","Другие дисциплины","Boshqa fanlar")
k("guidelineIndependentNote","Detail banner.","Independent scientific synthesis based on the references below. Not an official methodology; check the requirements of your laboratory and jurisdiction.","Независимый научный обзор на основе приведённой литературы. Не является официальной методикой; сверяйтесь с требованиями вашей лаборатории и юрисдикции.","Quyidagi adabiyotlar asosidagi mustaqil ilmiy sintez. Rasmiy metodika emas; laboratoriyangiz va yurisdiksiyangiz talablarini tekshiring.")
k("guidelineTranslationDraft","Banner.","This translation is a draft and has not been reviewed by a specialist yet.","Этот перевод — черновик и ещё не проверен специалистом.","Bu tarjima qoralama, hali mutaxassis tomonidan tekshirilmagan.")
k("guidelineFallbackLanguage","Banner.","Not yet available in your language — shown in the original language ({language}).","Пока недоступно на вашем языке — показано на языке оригинала ({language}).","Hozircha sizning tilingizda yo‘q — asl tilda ({language}) ko‘rsatilmoqda.",{"language":S})
k("guidelineReferences","Header.","References","Литература","Manbalar")
k("guidelineUpdated","Meta.","Updated {date}","Обновлено {date}","Yangilangan: {date}",{"date":S})
k("guidelineRelatedTools","Header.","Related tools","Связанные инструменты","Bog‘liq vositalar")
k("guidelineOpenReference","Action.","Open source","Открыть источник","Manbani ochish")
k("languageNameUz","Language name.","Uzbek","узбекский","o‘zbekcha")
k("languageNameRu","Language name.","Russian","русский","ruscha")
k("languageNameEn","Language name.","English","английский","inglizcha")
k("restrictedCatalogTitle","Admin section.","Uzbekistan practice codes (restricted)","Коды практик Узбекистана (закрыто)","O‘zbekiston amaliyot kodlari (yopiq)")
k("restrictedCatalogNote","Admin banner.","Visible to administrators only. Catalogue metadata of a restricted source: the full text is not stored in the app, is not sent to AI and must not be distributed.","Видно только администраторам. Метаданные каталога закрытого источника: полный текст не хранится в приложении, не передаётся ИИ и не подлежит распространению.","Faqat administratorlarga ko‘rinadi. Cheklangan manba katalogining metama’lumotlari: to‘liq matn ilovada saqlanmaydi, AI’ga berilmaydi va tarqatilmaydi.")
k("restrictedCatalogImport","Action.","Import catalogue file","Импортировать файл каталога","Katalog faylini import qilish")
k("restrictedCatalogRemove","Action.","Remove from this device","Удалить с устройства","Qurilmadan o‘chirish")
k("restrictedCatalogEmpty","Empty.","No catalogue on this device. Import the file you received privately.","На устройстве нет каталога. Импортируйте файл, полученный закрытым способом.","Bu qurilmada katalog yo‘q. Yopiq yo‘l bilan olingan faylni import qiling.")
k("restrictedCatalogImported","Snack.","Catalogue imported: {count} records.","Каталог импортирован: {count} записей.","Katalog import qilindi: {count} ta yozuv.",{"count":I})
k("restrictedCatalogInvalid","Snack.","This file is not a valid catalogue.","Файл не является корректным каталогом.","Bu fayl yaroqli katalog emas.")
k("restrictedCatalogRecords","Count.","{count} records","{count} записей","{count} ta yozuv",{"count":I})
k("restrictedCatalogPages","Meta.","pp. {from}–{to}","с. {from}–{to}","{from}–{to}-betlar",{"from":S,"to":S})
k("restrictedCatalogPage","Meta.","p. {page}","с. {page}","{page}-bet",{"page":S})
k("restrictedCatalogCodeOriginal","Meta.","Code as written in the source: {code}","Код в источнике: {code}","Manbadagi asl kod: {code}",{"code":S})
k("restrictedCatalogSearchHint","Search.","Search by code, title or term","Поиск по коду, названию или термину","Kod, nom yoki atama bo‘yicha qidirish")
k("restrictedCatalogLinkedCards","Header.","Linked independent guidelines","Связанные независимые руководства","Bog‘langan mustaqil yo‘riqnomalar")
k("restrictedCatalogNormative","Header.","Related official documents","Связанные официальные документы","Bog‘liq rasmiy hujjatlar")
k("restrictedCatalogSection","Label.","Section {section}","Раздел {section}","{section}-bo‘lim",{"section":S})
k("restrictedCatalogTitleDraft","Meta.","Title translation is a draft","Перевод названия — черновик","Sarlavha tarjimasi qoralama")
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
