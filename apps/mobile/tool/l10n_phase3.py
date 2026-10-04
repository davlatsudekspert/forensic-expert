# PHASE 3 lokalizatsiya kalitlari (pilot kontent, provenance, paywall, xarid).
# RU/UZ — review qilinmagan qoralama (RG-11).
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}
I = {"type": "int"}

k("homePilotNotice","Home notice while the content pack is the unreviewed pilot.","Pilot scientific database: every entry is awaiting expert review. Information is shown with its sources and is not a final conclusion.","Пилотная научная база: все записи ожидают экспертной проверки. Сведения приводятся с источниками и не являются окончательным заключением.","Pilot ilmiy baza: barcha yozuvlar ekspert tekshiruvini kutmoqda. Ma’lumotlar manbalari bilan ko‘rsatiladi va yakuniy xulosa emas.")
k("detailIdentity","Detail section.","Identifiers","Идентификаторы","Identifikatorlar")
k("detailMolecularFormula","Identifier row.","Molecular formula","Молекулярная формула","Molekulyar formula")
k("detailMolecularWeight","Identifier row.","Molecular weight (g/mol)","Молекулярная масса (г/моль)","Molekulyar massa (g/mol)")
k("detailIupac","Identifier row.","IUPAC name","Название IUPAC","IUPAC nomi")
k("detailBiomarker","Detail section.","Biomarker","Биомаркер","Biomarker")
k("detailTransformationProduct","Detail section.","Transformation product","Продукт превращения","Hosil bo‘ladigan mahsulot")
k("detailMetabolismNote","Detail section.","Metabolism","Метаболизм","Metabolizm")
k("detailExcerpt","Quoted sentence from the source.","Source excerpt","Цитата из источника","Manbadan iqtibos")
k("detailExcerptWithheld","Licence does not allow showing the quote.","The quotation is not shown because the source licence does not permit reuse. Open the source to read it.","Цитата не показана: лицензия источника не разрешает повторное использование. Откройте источник.","Manba litsenziyasi qayta foydalanishga ruxsat bermagani uchun iqtibos ko‘rsatilmaydi. Manbani ochib o‘qing.")
k("detailProvenance","Provenance block heading.","Provenance","Происхождение данных","Kelib chiqishi (provenance)")
k("detailEvidenceLevel","Evidence level chip.","Evidence level {level}","Уровень доказательности {level}","Dalil darajasi {level}",{"level":S})
k("detailReviewerStatus","Row label.","Reviewer status","Статус рецензирования","Reviewer holati")
k("detailReviewsNone","No reviews yet.","No expert reviews yet (2 required)","Экспертных рецензий пока нет (требуется 2)","Hali ekspert review yo‘q (2 ta talab qilinadi)")
k("detailReviewsCount","Review count.","Expert reviews: {count}","Экспертных рецензий: {count}","Ekspert review’lari: {count}",{"count":I})
k("detailVersion","Row label.","Version","Версия","Versiya")
k("detailVersionValue","Claim and database version.","Claim v{claim} · database {pack}","Утверждение v{claim} · база {pack}","Claim v{claim} · baza {pack}",{"claim":I,"pack":S})
k("detailTranslationDraft","Names are machine draft.","Names: machine draft, translation not reviewed","Названия: машинный черновик, перевод не проверен","Nomlar: mashina qoralamasi, tarjima tekshirilmagan")
k("detailNoContentYet","Section without sourced content.","No sourced content for this section yet.","Для этого раздела пока нет контента с источниками.","Bu bo‘lim uchun manbali kontent hali yo‘q.")
k("detailSourceAccessed","Source access date.","Accessed {date}","Дата обращения: {date}","Murojaat sanasi: {date}",{"date":S})
k("detailIdentifierVerified","Identifier auto-check.","Identifier checked automatically","Идентификатор проверен автоматически","Identifikator avtomatik tekshirilgan")
k("detailSourceLicence","Licence row.","Licence mode: {mode}","Режим лицензии: {mode}","Litsenziya rejimi: {mode}",{"mode":S})
k("legalSchedule","Control schedule line.","{convention}: Schedule {schedules}","{convention}: список {schedules}","{convention}: {schedules}-jadval",{"convention":S,"schedules":S})
k("legalListRow","Row from the official list.","Row in the official list","Строка официального списка","Rasmiy ro‘yxatdagi qator")
k("legalEffective","Effective date.","Edition in force from {date}","Издание действует с {date}","Nashr {date} dan amalda",{"date":S})
k("legalDateYearOnly","Year-only precision.","(source gives the year only)","(в источнике указан только год)","(manbada faqat yil ko‘rsatilgan)")
k("legalLastVerified","Last verified.","Last verified {date}","Последняя проверка: {date}","Oxirgi tekshiruv: {date}",{"date":S})
k("legalInternationalLayer","INT jurisdiction label.","International (UN conventions)","Международный уровень (конвенции ООН)","Xalqaro daraja (BMT konvensiyalari)")
k("legalNotInListNote","Absence is not proof.","Absence from these lists does not mean a substance is uncontrolled: national law may differ.","Отсутствие в этих списках не означает, что вещество не контролируется: национальное законодательство может отличаться.","Bu ro‘yxatlarda yo‘qligi modda nazoratda emas degani emas: milliy qonunchilik farq qilishi mumkin.")
k("legalNoNational","No national content.","No national legal content has been loaded for {name} yet.","Национальный правовой контент для {name} пока не загружен.","{name} uchun milliy huquqiy kontent hali yuklanmagan.",{"name":S})
k("lockedTitle","Paywall card title.","Included in FORENSIC EXPERT Lifetime","Входит в FORENSIC EXPERT Lifetime","FORENSIC EXPERT Lifetime tarkibida")
k("lockedBody","What stays open.","Names, warnings and sources stay open. Scientific details and the jurisdiction layer unlock with Lifetime Access.","Названия, предупреждения и источники остаются открытыми. Научные данные и юрисдикционный слой открываются с Lifetime Access.","Nomlar, ogohlantirishlar va manbalar ochiq qoladi. Ilmiy tafsilotlar va yurisdiksiya qatlami Lifetime Access bilan ochiladi.")
k("freeDemoBadge","Badge on free demo entries.","Free demo","Бесплатно (демо)","Bepul demo")
k("lockedBadge","Badge on locked entries.","Lifetime","Lifetime","Lifetime")
k("searchMoreLocked","Hidden results count.","{count} more results with Lifetime","Ещё {count} результатов в Lifetime","Lifetime bilan yana {count} ta natija",{"count":I})
k("learnEmptyCourses","No real courses yet.","Courses will appear after expert review of the learning content.","Курсы появятся после экспертной проверки учебного контента.","Kurslar o‘quv kontenti ekspert tekshiruvidan o‘tgach paydo bo‘ladi.")
k("contentLoading","Loading DB.","Loading scientific database…","Загрузка научной базы…","Ilmiy baza yuklanmoqda…")
k("libraryNotInstalled","No pack.","The scientific database is not installed in this build.","В этой сборке научная база не установлена.","Bu yig‘mada ilmiy baza o‘rnatilmagan.")
k("purchasePending","Store pending.","Purchase is waiting for confirmation from the store.","Покупка ожидает подтверждения магазина.","Xarid do‘kon tasdig‘ini kutmoqda.")
k("purchaseFailed","Purchase failed.","The purchase was not completed.","Покупка не завершена.","Xarid yakunlanmadi.")
k("purchaseCancelled","Purchase cancelled.","Purchase cancelled.","Покупка отменена.","Xarid bekor qilindi.")
k("purchaseSuccess","Unlocked.","Lifetime access unlocked. Thank you!","Пожизненный доступ открыт. Спасибо!","Umrbod kirish ochildi. Rahmat!")
k("aboutTrademarkPending","Brand status.","Name and logo: trademark clearance pending.","Название и логотип: проверка товарного знака не завершена.","Nom va logo: tovar belgisi tekshiruvi yakunlanmagan.")

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
