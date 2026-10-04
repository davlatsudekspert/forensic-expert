# PHASE 8–12 lokalizatsiya kalitlari. RU/UZ — mashina qoralamasi (RG-11).
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}
I = {"type": "int"}

# --- PHASE 8: reagent / ekspress test / metod --------------------------------
k("reagentConcentration","Recipe field.","Concentration","Концентрация","Konsentratsiya")
k("reagentSolvent","Recipe field.","Solvent","Растворитель","Erituvchi")
k("reagentPh","Recipe field.","pH","pH","pH")
k("reagentExpiry","Recipe field.","Expiry / shelf life","Срок годности","Yaroqlilik muddati")
k("reagentHazards","Recipe field.","Hazard","Опасность","Xavf")
k("reagentPpe","Recipe field.","Personal protective equipment","Средства индивидуальной защиты","Shaxsiy himoya vositalari")
k("screeningResultType","Screening field.","Result type (qualitative / semi-quantitative)","Тип результата (качественный / полуколичественный)","Natija turi (sifat / yarim miqdoriy)")
k("screeningDetectionWindow","Screening field.","Detection window (context-dependent)","Окно обнаружения (зависит от условий)","Aniqlash oynasi (sharoitga bog‘liq)")
k("screeningInterference","Screening field.","Interference","Интерференция","Interferensiya")
k("evInternationalStandard","Method evidence type.","International standard","Международный стандарт","Xalqaro standart")
k("evGuideline","Method evidence type.","Guideline","Руководство","Qo‘llanma")
k("evPublishedValidated","Method evidence type.","Published validated method","Опубликованный валидированный метод","Nashr etilgan validatsiyalangan metod")
k("evNationalMethod","Method evidence type.","National method","Национальная методика","Milliy metodika")
k("evLocalSop","Method evidence type.","Local SOP reference","Ссылка на локальную СОП","Mahalliy SOP havolasi")
k("evEducationalSummary","Method evidence type.","Educational summary","Учебное обобщение","Ta’limiy umumlashma")

k("disciplineSourcedTopics","Section.","Sourced topics","Темы с источниками","Manbali mavzular")

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
