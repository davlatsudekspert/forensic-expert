# «Tahlil» bo‘limi — modda biologik ob’ektlarda (qon, siydik…) qanday tahlil
# qilinadi: namunalar, skrining, tasdiqlovchi va tahliliy metodlar,
# nishon metabolitlar. Namuna sahifasida — teskari ro‘yxat (moddalar).
# Ishga tushirish: apps/mobile ichida `python3 tool/l10n_analysis.py`, so‘ng
# `flutter gen-l10n`.
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}
I = {"type": "int"}
k("analysisTitle","Substance page: analysis section header.","Analysis","Анализ","Tahlil")
k("analysisIntro","Analysis section banner.","How this substance is analysed in biological specimens — only links that already exist in the content pack, each with its source. None of them has been expert-reviewed yet.","Как это вещество исследуют в биологических объектах — только связи, уже имеющиеся в пакете контента, каждая со своим источником. Ни одна из них ещё не прошла экспертную проверку.","Bu modda biologik ob’ektlarda qanday tahlil qilinadi — faqat kontent paketidagi mavjud bog‘lanishlar, har biri o‘z manbasi bilan. Ularning hech biri hali ekspert tekshiruvidan o‘tmagan.")
k("analysisSpecimensTitle","Analysis subsection.","Specimens (biological objects)","Объекты исследования (биологические)","Namunalar (biologik ob’ektlar)")
k("analysisSpecimensNote","Specimens note.","A source reports a value for this substance in these specimens. The values are shown below under reported concentrations — they are not thresholds.","Источник приводит значение для этого вещества в этих объектах. Значения показаны ниже в разделе сообщаемых концентраций — это не пороговые значения.","Manbada bu modda uchun shu namunalarda qiymat keltirilgan. Qiymatlar pastda, keltirilgan konsentratsiyalar bo‘limida — ular chegaraviy qiymat emas.")
k("analysisNoSpecimens","Specimens empty.","The pack has no sourced specimen for this substance yet.","В пакете пока нет объекта исследования с источником для этого вещества.","Paketda bu modda uchun hozircha manbali namuna yo‘q.")
k("analysisSourcedRecords","Count of basis records.","{count, plural, =1{1 sourced record} other{{count} sourced records}}","{count, plural, one{{count} запись с источником} few{{count} записи с источником} many{{count} записей с источником} other{{count} записи с источником}}","{count, plural, other{{count} ta manbali yozuv}}",{"count":I})
k("analysisSpecimenMethods","Methods linked to a specimen via the same source.","Methods in the same source: {methods}","Методы в том же источнике: {methods}","Shu manbadagi metodlar: {methods}",{"methods":S})
k("analysisScreeningTitle","Analysis subsection.","Screening (presumptive)","Скрининг (предварительный)","Skrining (taxminiy)")
k("analysisScreeningNote","Screening warning.","A screening result is presumptive and must be confirmed by a confirmation method.","Результат скрининга предварительный и должен быть подтверждён подтверждающим методом.","Skrining natijasi taxminiy — u tasdiqlovchi metod bilan tasdiqlanishi shart.")
k("analysisConfirmedBy","Screening row: confirmation methods.","Confirmation: {methods}","Подтверждение: {methods}","Tasdiqlash: {methods}",{"methods":S})
k("analysisConfirmationTitle","Analysis subsection.","Confirmation methods","Подтверждающие методы","Tasdiqlovchi metodlar")
k("analysisAfterScreening","Confirmation row: screening tests.","After screening: {tests}","После скрининга: {tests}","Skriningdan keyin: {tests}",{"tests":S})
k("analysisMethodsTitle","Analysis subsection.","Analytical methods in sources","Аналитические методы в источниках","Manbalardagi tahlil metodlari")
k("analysisMethodsRoleNote","Analytical methods note.","A method is listed because a source sentence mentions it together with this substance; this is not a validated procedure.","Метод указан, потому что фраза источника упоминает его вместе с этим веществом; это не валидированная методика.","Metod manbadagi jumlada shu modda bilan birga tilga olingani uchun ko‘rsatilgan; bu validatsiyalangan protsedura emas.")
k("analysisMethodsNotPaired","Methods not linked to specimens.","The sources in the pack do not link these methods to a specific specimen, so they are listed for the substance as a whole.","Источники в пакете не связывают эти методы с конкретным объектом, поэтому они указаны для вещества в целом.","Paketdagi manbalar bu metodlarni aniq namunaga bog‘lamaydi, shuning uchun ular modda uchun umumiy ko‘rsatilgan.")
k("analysisMetabolitesTitle","Analysis subsection.","Metabolites to target","Целевые метаболиты","Izlanadigan metabolitlar")
k("analysisMetaboliteSpecimens","Metabolite row: specimens.","Specimens: {specimens}","Объекты: {specimens}","Namunalar: {specimens}",{"specimens":S})
k("analysisEmpty","Analysis empty state.","The content pack has no sourced analysis data (specimens, methods or metabolites) for this substance yet.","В пакете контента пока нет данных анализа с источниками (объекты, методы или метаболиты) для этого вещества.","Kontent paketida bu modda uchun hozircha manbali tahlil ma’lumoti (namuna, metod yoki metabolit) yo‘q.")
k("analysisShowSource","Tooltip: open basis claim provenance.","Show the source","Показать источник","Manbani ko‘rsatish")
k("specimenSubstancesTitle","Specimen page section.","Substances analysed in this specimen","Вещества, исследованные в этом объекте","Bu namunada tahlil qilingan moddalar")
k("specimenSubstancesNote","Specimen page note.","A source reports a value for each of these substances in this specimen.","Для каждого из этих веществ источник приводит значение в этом объекте.","Har bir modda uchun manbada shu namunadagi qiymat keltirilgan.")
k("specimenSubstancesNone","Specimen page empty.","No substance in the pack is linked to this specimen yet.","В пакете пока нет веществ, связанных с этим объектом.","Paketda bu namunaga bog‘langan modda hozircha yo‘q.")

# Qisqa va sodda matnlar (egasi: «ilova oddiy bo‘lishi kerak»).
k("analysisIntro","Analysis section banner.","Which specimens and methods — from sources. Not yet expert-reviewed.","Какие объекты и методы — по источникам. Экспертом пока не проверено.","Qaysi namuna va qaysi usul — manbalar asosida. Hali ekspert tekshirmagan.")
k("analysisSpecimensTitle","Analysis subsection.","Specimens","Объекты исследования","Namunalar")
k("analysisSpecimensNote","Specimens note.","A source reports a value in these specimens (not a threshold).","Источник приводит значение в этих объектах (не пороговое).","Manbada shu namunalarda qiymat keltirilgan (chegaraviy qiymat emas).")
k("analysisSpecimenMethods","Methods linked to a specimen via the same source.","Methods in the same source: {methods}","Методы в том же источнике: {methods}","Shu manbadagi usullar: {methods}",{"methods":S})
k("analysisConfirmationTitle","Analysis subsection.","Confirmation methods","Подтверждающие методы","Tasdiqlovchi usullar")
k("analysisMethodsTitle","Analysis subsection.","Analytical methods","Аналитические методы","Tahlil usullari")
k("analysisMethodsRoleNote","Analytical methods note.","Mentioned with this substance in a source; not a validated procedure.","Упомянут с этим веществом в источнике; не валидированная методика.","Manbada shu modda bilan tilga olingan; tasdiqlangan protsedura emas.")
k("analysisMethodsNotPaired","Methods not linked to specimens.","Sources do not tie these methods to a specific specimen.","Источники не привязывают эти методы к конкретному объекту.","Manbalar bu usullarni aniq namunaga bog‘lamaydi.")

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
