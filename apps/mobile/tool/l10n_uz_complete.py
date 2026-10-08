# O‘zbek (lotin) va rus UI to‘liqligi: inglizcha qolgan qiymatlarni
# tarjima qilish va UI’dagi hardcoded matnlarni ARB’ga ko‘chirish.
# Merge’dan keyin qayta qo‘llash mumkin (idempotent):
#   cd apps/mobile && python3 tool/l10n_uz_complete.py && flutter gen-l10n
# Tekshiruv: test/l10n/uz_completeness_test.dart.
import json, collections
D = "lib/core/l10n/arb"

# --- Yangi kalitlar (avval kodda hardcoded edi) ------------------------------
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
S = {"type": "String"}

# research_screens.dart: l.relationBasis('source excerpt')
k("relationBasisSourceExcerpt", "Basis of a metabolism co-mention link (inserted into relationBasis).",
  "source excerpt", "фрагмент источника", "manba parchasi")
# research_screens.dart: ('Handle', r.handle!) metadata qatori
k("metaHandle", "Metadata row label: Handle System persistent identifier (hdl.handle.net).",
  "Handle", "Идентификатор Handle", "Handle identifikatori")
# verification_screens.dart: '${...} KB' fayl hajmi
k("fileSizeKb", "Attached file size in kilobytes.",
  "{size} KB", "{size} КБ", "{size} KB", {"size": S})

# --- Mavjud kalitlar: faqat RU/UZ qiymatlari tuzatiladi ----------------------
# (inglizcha yoki aralash so‘zlar → savodli o‘zbek / rus tili)
UZ = collections.OrderedDict([
    ("appTagline", "Dalil · Fan · Aniqlik"),
    ("detailConcentrations", "Referens konsentratsiyalar"),
    ("detailProvenance", "Ma’lumotlar kelib chiqishi"),
    ("tpl_cutoff", "Chegara qiymati (cut-off)"),
    ("calcSolutionLimitationRecipe", "Bu reaktiv retsepti emas: modda tanlovi, tartib, saqlash va barqarorlik faqat tasdiqlangan manba yoki SOP’dan."),
    ("learnSimulatedCase", "MODELLASHTIRILGAN HOLAT — haqiqiy ish emas"),
    ("tierProF1", "Student Pro’dagi barcha imkoniyatlar"),
    ("adminTitle", "Boshqaruv paneli"),
    ("adminProGrants", "Pro berilganlar"),
    ("accountTestBackend", "SINOV akkaunt serveri — haqiqiy xat yuborilmaydi, ma’lumot faqat xotirada."),
    ("researchKindGuideline", "Uslubiy tavsiyanoma"),
    ("researchNote", "Faqat metama’lumotlar va havolalar — to‘liq matn ko‘chirilmaydi. Dissertatsiya, tezis va konferensiya materiallari taqrizdan o‘tgan maqola bilan teng ko‘rsatilmaydi."),
    ("stdCatalogue", "Standartlar katalogi (faqat metama’lumotlar)"),
    ("stdVerifiedFrom", "Metama’lumotlar {date} da nashriyot yoki registrda tekshirilgan"),
    ("roleEditor", "Ilmiy muharrir / administrator"),
    ("licenseOriginalWork", "Asl asar (FORENSIC EXPERT)"),
    ("licenseFactualDepiction", "Faktik ma’lumotning asl tasviri"),
    ("tech_headspaceGc", "Bug‘ fazali GC"),
])
RU = collections.OrderedDict([
    ("appTagline", "Доказательность · Наука · Точность"),
])

for idx, code in enumerate(["en", "ru", "uz"]):
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key, (desc, en, ru, uz, ph) in K.items():
        data[key] = (en, ru, uz)[idx]
        if code == "en":
            meta = {"description": desc}
            if ph:
                meta["placeholders"] = ph
            data["@" + key] = meta
    fixes = {"ru": RU, "uz": UZ}.get(code, {})
    for key, value in fixes.items():
        assert key in data, f"{code}: kalit yo‘q: {key}"
        data[key] = value
    json.dump(data, open(p, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    open(p, "a").write("\n")
print(len(K), "new keys;", len(UZ), "uz fixes;", len(RU), "ru fixes")
