#!/usr/bin/env python3
"""Build the substance-level «Tekshirish usullari» layer into content/pilot/bundle.json.

Source of truth: content/tools/substance_methods_data*.py (+ sm_vocab.py, sm_core.py).
Idempotent: every artefact created here has the id prefix ``C-SM-`` / ``SRC-YULDASHEV-…`` /
``SRC-UNODC-STNAR-13`` / ``SRC-SWGDRUG-8-2`` / ``scr-microcrystal-tests`` and is removed and
re-created on each run.

What is written (all inside the existing schema v7 structures):
  * sources[]         4 sources (two teaching books with written permission on record,
                      UNODC ST/NAR/13/Rev.1, SWGDRUG v8.2);
  * claims[]/citations[]  one claim per (substance, method) with an exact locator; the English
                      sentence is value.excerpt (+ text_translations uz/ru, machine_draft);
                      value carries method_family, evidence_class (presumptive / supporting /
                      screening / instrumental / physical), SWGDRUG category, recipe_ids and
                      locator_i18n {uz,ru,en};
  * links[]           substance → screening test (screened_by) / method (analysed_by);
  * screening_tests[] scr-microcrystal-tests (new), scr-colour-tests (limitations extended);
  * one identification_methods_overview claim per substance (honest limitation, SWGDRUG framing
    quoted with its own categories).
Usage: python3 content/tools/build_substance_methods.py [--check]
"""
from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import sys
from collections import Counter, defaultdict

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
ROOT = HERE.parents[1]
BUNDLE = ROOT / "content/pilot/bundle.json"
COVERAGE_DOC = ROOT / "docs/SUBSTANCE_METHODS_COVERAGE.md"
LOCALIZED_SRC = ROOT / "content/pilot/translations/localized_texts_d.src.json"

import substance_methods_data  # noqa: E402,F401
import substance_methods_data2  # noqa: E402,F401
import substance_methods_data3  # noqa: E402,F401
import substance_methods_data4  # noqa: E402,F401
import substance_methods_data5  # noqa: E402,F401
from sm_core import SRC, loc as _loc  # noqa: E402
from sm_vocab import FAMILY_LABEL, LANGS  # noqa: E402
from substance_methods_data import E  # noqa: E402

PREFIX = "C-SM-"

FIELD = {
    "colour_test": "colour_test",
    "odour_test": "odour_test",
    "chemical": "chemical_test",
    "tlc": "tlc_system",
    "microcrystal": "microcrystal_test",
    "uv_spectrum": "uv_spectrum",
    "photometric": "photometric_assay",
    "immunoassay": "immunoassay_screen",
    "instrumental": "confirmatory_method",
    "physical": "melting_point",
    "caveat": "method_caveat",
    "spectroscopy": "spectroscopy",
}
LOCAL_FAMILIES = ["colour_test", "odour_test", "chemical", "tlc", "microcrystal", "uv_spectrum", "photometric",
                  "spectroscopy", "physical", "immunoassay"]
SEIZED_GROUPS = {"opioids", "stimulants", "cannabinoids", "hallucinogens_dissociatives", "benzodiazepines",
                 "barbiturates"}

SOURCES = [
    {
        "source_id": "SRC-YULDASHEV-GMT-2024",
        "source_type": "book",
        "source_class": "bookHandbook",
        "title": "Giyohvand moddalar tahlili. O‘quv qo‘llanma",
        "authors": ["Yuldashev Z.A.", "Zulfikariyeva D.A.", "Usmanaliyeva Z.U.", "Nurmatova M.I."],
        "organization": "Toshkent farmatsevtika instituti, Toksikologik kimyo kafedrasi",
        "publication_year": 2024,
        "accessed_date": "2026-10-10",
        "tier": "tier3",
        "evidence_level": "C",
        "license_mode": "licenseRequired",
        "license_agreement_id": "AUTHOR-PERMISSION-YULDASHEV-2026-10-09",
        "identifier_verified": False,
        "language": "uz",
        "notes": "O‘quv qo‘llanma (173 b.). Muallif (Yuldashev Z.A.) yozma ruxsati bilan, 2026-10-09 (docs/DECISIONS.md); matn so‘zma-so‘z ko‘chirilmagan. Sahifa ko‘rsatkichlari — PDF sahifasi (bosma sahifa = PDF − 1). Kitobning ichki qarama-qarshiliklari (masalan, bir xil tizim uchun ikki jadvalda har xil Rf) tegishli yozuvlarda ko‘rsatilgan. Ilmiy review kutilmoqda.",
    },
    {
        "source_id": "SRC-YULDASHEV-TOKS-2025",
        "source_type": "book",
        "source_class": "bookHandbook",
        "title": "Toksikologik kimyo modulidan o‘quv-uslubiy majmua (60910700 – Farmatsiya)",
        "authors": ["Yuldashev Z.A.", "Umarova G.Q."],
        "organization": "Toshkent farmatsevtika instituti, Toksikologik kimyo kafedrasi",
        "publication_year": 2025,
        "accessed_date": "2026-10-10",
        "tier": "tier3",
        "evidence_level": "C",
        "license_mode": "licenseRequired",
        "license_agreement_id": "AUTHOR-PERMISSION-YULDASHEV-2026-10-09",
        "identifier_verified": False,
        "language": "uz",
        "notes": "O‘quv-uslubiy majmua (~355 b.), muallif yozma ruxsati bilan (2026-10-09; docs/DECISIONS.md). Sahifa ko‘rsatkichlari — PDF sahifasi (bosma sahifa bilan bir xil). Matn so‘zma-so‘z ko‘chirilmagan. Ilmiy review kutilmoqda.",
    },
    {
        "source_id": "SRC-UNODC-STNAR-13",
        "source_type": "guideline",
        "title": "Rapid Testing Methods of Drugs of Abuse: Manual for Use by National Law Enforcement and Narcotic Laboratory Personnel (ST/NAR/13/Rev.1)",
        "organization": "United Nations Office on Drugs and Crime (UNODC), Laboratory and Scientific Section",
        "publication_year": 1994,
        "official_url": "https://www.unodc.org/documents/scientific/Rapid_Testing_Methods_of_Drugs_of_Abuse_E.pdf",
        "accessed_date": "2026-10-10",
        "tier": "tier1",
        "evidence_level": "B",
        "license_mode": "citeOnly",
        "identifier_verified": False,
        "language": "en",
        "notes": "UNODC rasmiy PDF (Sales No. E.08.XI.14), 2026-10-10 da yuklab olingan va 37–52-bosma betlar o‘qilgan (PDF sahifasi = bosma sahifa + 10). Faqat mustaqil qisqa mazmun va havola. Bu qo‘llanmadagi barcha rang sinamalari «taxminiy» (possible presence) deb ataladi.",
    },
    {
        "source_id": "SRC-SWGDRUG-8-2",
        "source_type": "guideline",
        "title": "SWGDRUG Recommendations, Version 8.2",
        "organization": "Scientific Working Group for the Analysis of Seized Drugs (SWGDRUG)",
        "publication_year": 2024,
        "official_url": "https://swgdrug.org/approved.htm",
        "accessed_date": "2026-10-10",
        "tier": "tier1",
        "evidence_level": "B",
        "license_mode": "citeOnly",
        "identifier_verified": False,
        "language": "en",
        "notes": "SWGDRUG Recommendations v8.2 (2024-06-27), Part IIIB: Table 1 (bosma 17-bet) va IIIB.2–IIIB.5 (bosma 16–21-betlar) o‘qilgan. Doirasi — musodara qilingan giyohvand moddalar (biologik namunalar emas). Toifalar (A/B/C) shu hujjatning o‘z ta’rifi; ilova o‘z hukmini qo‘shmaydi.",
    },
]

NEW_SCREENING = {
    "screening_id": "scr-microcrystal-tests",
    "names": {
        "en": "Microcrystalline (crystal) tests",
        "ru": "Микрокристаллоскопические пробы",
        "uz": "Mikrokristalloskopik sinamalar",
    },
    "analyte": "various (presumptive)",
    "specimen": "seized material or extract (see source)",
    "principle": "microcrystalline (crystal-formation) reaction",
    "confirmatory_method_ids": ["method-gcms", "method-lcmsms", "method-spectroscopy"],
    "supports_definitive_identification": False,
    "status": "NEEDS_REVIEW",
    "tier_access": "free",
}

# drafts for the new screening fields (localized_texts_d.src.json, keyed by the English original)
SCREENING_DRAFTS = {
    "seized material or extract (see source)": {
        "uz": "musodara qilingan material yoki ekstrakt (manbaga qarang)",
        "ru": "изъятый материал или экстракт (см. источник)",
    },
    "microcrystalline (crystal-formation) reaction": {
        "uz": "mikrokristalloskopik (kristall hosil bo‘lish) reaksiyasi",
        "ru": "микрокристаллоскопическая (кристаллообразующая) реакция",
    },
}


def sha(t: str) -> str:
    return hashlib.sha256(t.encode("utf-8")).hexdigest()


def strip_src(locator: str, key: str) -> str:
    short = SRC[key]["short"][0]
    return locator[len(short) + 2:] if locator.startswith(short + ", ") else locator


def expand(entries):
    """One claim record per (substance, entry)."""
    out = []
    counters = Counter()
    for e in entries:
        for sub in e["subs"]:
            counters[(sub, e["family"])] += 1
            out.append((sub, e, counters[(sub, e["family"])]))
    return out


# --------------------------------------------------------------- overview text
def overview_text(group, rows, n_existing_instr):
    c = Counter(e["family"] for e in rows)
    local = [(f, c[f]) for f in LOCAL_FAMILIES if c.get(f)]
    n_instr_sm = c.get("instrumental", 0)
    seized = group in SEIZED_GROUPS
    parts = {l: [] for l in LANGS}
    for i, lang in enumerate(LANGS):
        lst = "; ".join(f"{FAMILY_LABEL[f][i]}: {n}" for f, n in local) if local else {
            "en": "none documented", "uz": "hujjatlashtirilmagan", "ru": "не задокументировано"}[lang]
        parts[lang].append({
            "en": f"Methods documented for this substance that do not need GC-MS or LC-MS/MS — {lst}.",
            "uz": f"Bu modda uchun hujjatlashtirilgan, GC-MS yoki LC-MS/MS talab qilmaydigan usullar — {lst}.",
            "ru": f"Задокументированные для этого вещества методы, не требующие GC-MS или LC-MS/MS — {lst}.",
        }[lang])
        if n_instr_sm or n_existing_instr:
            tot = n_instr_sm + n_existing_instr
            parts[lang].append({
                "en": f"Instrumental methods documented for confirmation: {tot} entries (GC-MS, LC-MS/MS, HPLC or GC-FID, see the analytical-method entries); they may be unavailable in a local laboratory.",
                "uz": f"Tasdiqlash uchun hujjatlashtirilgan instrumental usullar: {tot} ta yozuv (GC-MS, LC-MS/MS, HPLC yoki GC-FID, tahlil usullari yozuvlariga qarang); ular mahalliy laboratoriyada mavjud bo‘lmasligi mumkin.",
                "ru": f"Задокументированные инструментальные методы для подтверждения: {tot} записей (GC-MS, LC-MS/MS, HPLC или GC-FID, см. записи об аналитических методах); в местной лаборатории они могут быть недоступны.",
            }[lang])
        else:
            parts[lang].append({
                "en": "No instrumental confirmatory method is documented for this substance in the app.",
                "uz": "Bu modda uchun ilovada instrumental tasdiqlovchi usul hujjatlashtirilmagan.",
                "ru": "Для этого вещества в приложении не задокументирован инструментальный подтверждающий метод.",
            }[lang])
        if seized:
            parts[lang].append({
                "en": "All non-instrumental results listed here are presumptive or supporting. In the SWGDRUG scheme (Recommendations v8.2, Part IIIB) colour tests and immunoassay are category C, while TLC, microcrystalline tests and UV/Vis spectroscopy over a wavelength range are category B: techniques without structural information. Without a category A technique (infrared spectroscopy, mass spectrometry, NMR or Raman), IIIB.3.2 requires at least 3 separate techniques, 2 of them from category B and giving a high degree of selectivity together, plus a third from category B or C; hyphenated GC-MS counts as 2 techniques (IIIB.3.4). Negative or inconclusive results do not contribute to identification (IIIB.3.3.4). Whether such a scheme is accepted for an expert opinion depends on the jurisdiction and the laboratory protocol (IIIB.2.2); this app does not decide that.",
                "uz": "Bu yerda keltirilgan instrumental bo‘lmagan natijalarning barchasi taxminiy yoki yordamchi. SWGDRUG sxemasida (Recommendations v8.2, Part IIIB) rang sinamalari va immunoanaliz — C toifasi, TLC, mikrokristalloskopik sinamalar va to‘lqin uzunligi oralig‘ida UB/ko‘rinadigan sohadagi spektroskopiya — B toifasi: tuzilma haqida ma’lumot bermaydigan usullar. A toifasidagi usul (infraqizil spektroskopiya, mass-spektrometriya, NMR yoki Raman) bo‘lmasa, IIIB.3.2 kamida 3 ta alohida usulni talab qiladi: ularning 2 tasi B toifasidan bo‘lib, birgalikda yuqori selektivlik berishi kerak, uchinchisi B yoki C toifasidan; chatishgan GC-MS 2 ta usul hisoblanadi (IIIB.3.4). Manfiy yoki noaniq natijalar aynanlikni aniqlashga hissa qo‘shmaydi (IIIB.3.3.4). Bunday sxema ekspert xulosasi uchun qabul qilinishi yurisdiksiya va laboratoriya protokoliga bog‘liq (IIIB.2.2); ilova buni hal qilmaydi.",
                "ru": "Все приведённые здесь неинструментальные результаты предположительные или вспомогательные. В схеме SWGDRUG (Recommendations v8.2, Part IIIB) цветные реакции и иммуноанализ относятся к категории C, а TLC, микрокристаллоскопические пробы и УФ/видимая спектроскопия в диапазоне длин волн — к категории B: методы без структурной информации. Без метода категории A (инфракрасная спектроскопия, масс-спектрометрия, ЯМР или рамановская спектроскопия) IIIB.3.2 требует не менее 3 отдельных методов, из них 2 из категории B, которые вместе дают высокую избирательность, и третьего из категории B или C; гибридный GC-MS считается 2 методами (IIIB.3.4). Отрицательные или неопределённые результаты не вносят вклад в идентификацию (IIIB.3.3.4). Принимается ли такая схема для экспертного заключения, зависит от юрисдикции и протокола лаборатории (IIIB.2.2); приложение этого не решает.",
            }[lang])
            parts[lang].append({
                "en": "What this means for the expert's opinion: a result based only on the methods listed here supports a presumptive finding (consistent with the substance or class), not an established identity; the scheme actually used must be named, and confirmation by a category A technique such as GC-MS or LC-MS/MS should be recommended when it is not available locally.",
                "uz": "Bu ekspert xulosasi uchun nimani anglatadi: faqat shu yerda keltirilgan usullarga asoslangan natija taxminiy xulosani (modda yoki sinfga mos kelishini) qo‘llab-quvvatlaydi, aynanlik isbotlanganini emas; amalda qo‘llangan sxema nomlanishi va A toifasidagi usul (masalan, GC-MS yoki LC-MS/MS) bilan tasdiqlash mahalliy mavjud bo‘lmasa tavsiya etilishi kerak.",
                "ru": "Что это означает для заключения эксперта: результат, основанный только на приведённых здесь методах, поддерживает предположительный вывод (соответствие веществу или классу), а не установленную идентичность; фактически применённую схему необходимо назвать, а подтверждение методом категории A, например GC-MS или LC-MS/MS, следует рекомендовать, если оно недоступно локально.",
            }[lang])
        else:
            parts[lang].append({
                "en": "The SWGDRUG scheme is written for seized drugs and is not applied to this substance. The teaching source itself states that a chemist must not rely on one reaction result: 2 or more reactions and methods are needed, and some reactions have only a negative value (a positive result proves nothing). Results from the methods listed here are presumptive or supporting; confirmation needs an orthogonal instrumental method, and the limitation must be stated in the expert's opinion.",
                "uz": "SWGDRUG sxemasi musodara qilingan giyohvand moddalar uchun yozilgan va bu modda uchun qo‘llanilmaydi. O‘quv manbaning o‘zi kimyogar bitta reaksiya natijasiga tayanmasligi kerakligini bildiradi: 2 yoki undan ortiq reaksiya va usul kerak, ayrim reaksiyalar esa faqat manfiy ahamiyatga ega (musbat natija hech narsani isbotlamaydi). Bu yerda keltirilgan usullar natijalari taxminiy yoki yordamchi; tasdiqlash uchun ortogonal instrumental usul kerak, cheklov esa ekspert xulosasida ko‘rsatilishi shart.",
                "ru": "Схема SWGDRUG написана для изъятых наркотических средств и к этому веществу не применяется. Сам учебный источник указывает, что химик не должен полагаться на результат одной реакции: нужны 2 или более реакций и методов, а некоторые реакции имеют только отрицательное значение (положительный результат ничего не доказывает). Результаты приведённых здесь методов предположительные или вспомогательные; для подтверждения нужен ортогональный инструментальный метод, а ограничение должно быть указано в заключении эксперта.",
            }[lang])
    return {l: " ".join(parts[l]) for l in LANGS}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true", help="fail if bundle.json differs from the regenerated result")
    a = ap.parse_args()

    b = json.loads(BUNDLE.read_text(encoding="utf-8"))
    subs = {s["substance_id"]: s for s in b["substances"]}
    recipes = {r["recipe_id"] for r in b["recipes"]}

    # ---- 0. strip previous output
    new_source_ids = {s["source_id"] for s in SOURCES}
    b["claims"] = [c for c in b["claims"] if not c["claim_id"].startswith(PREFIX)]
    b["citations"] = [c for c in b["citations"] if not c["claim_id"].startswith(PREFIX)]
    b["links"] = [l for l in b["links"] if not l["basis"].startswith(PREFIX)]
    b["text_translations"] = [t for t in b["text_translations"] if not t["target_id"].startswith(PREFIX)]
    b["sources"] = [s for s in b["sources"] if s["source_id"] not in new_source_ids]
    b["screening_tests"] = [s for s in b["screening_tests"] if s["screening_id"] != NEW_SCREENING["screening_id"]]

    for e in E:
        for sub in e["subs"]:
            assert sub in subs, f"unknown substance {sub}"
        for r in e["recipes"]:
            assert r in recipes, f"unknown recipe {r}"

    rows = expand(E)
    by_sub = defaultdict(list)
    for sub, e, n in rows:
        by_sub[sub].append(e)

    existing_instr = Counter(l["from"] for l in b["links"]
                             if l["relation"] == "analysed_by" and not l["basis"].startswith(PREFIX))

    claims, cits, links, trans = [], [], [], []
    seen_links = {(l["from"], l["to"], l["relation"]) for l in b["links"]}

    def add_link(frm, to, rel, basis):
        k = (frm, to, rel)
        if k in seen_links:
            return
        seen_links.add(k)
        links.append({"from": frm, "to": to, "relation": rel, "basis": basis})

    def add_claim(cid, sub, field, tri, src_key, section_en, value_extra, level, entity_type="substance"):
        # NB: no value.excerpt — the project rule is that `excerpt` text comes only from open-licence
        # sources; these are our own paraphrases of licensed / cite-only sources: value.statement.
        value = {"statement": {l: tri[l] for l in LANGS},
                 "translation_status": {"en": "authored", "uz": "machine_draft", "ru": "machine_draft"},
                 "section": section_en}
        value.update(value_extra)
        claims.append({
            "claim_id": cid, "entity_type": entity_type, "entity_id": sub, "field": field, "domain": "lab",
            "declared_status": "NEEDS_REVIEW", "evidence_level": level, "layer": "international_scientific",
            "is_structured_value": False, "value": value,
        })
        cits.append({"claim_id": cid, "source_id": SRC[src_key]["source_id"], "locator": section_en})

    for sub, e, n in rows:
        cid = f"{PREFIX}{sub.upper()}-{FIELD[e['family']].upper()}-{n:02d}"
        locs = e["loc"]
        section_en = strip_src(locs["en"], e["src"])
        data = e["data"] if isinstance(e.get("data"), dict) else {}
        extra = {
            "method_family": e["family"],
            "evidence_class": e["cls"],
            "scope": data.get("scope", "substance"),
            "recipe_ids": e["recipes"],
            "reagents": e["reagents"],
            "locator_i18n": locs,
            "source_i18n": {lang: SRC[e["src"]]["short"][i] for i, lang in enumerate(LANGS)},
            "data": data,
        }
        if e["cat"]:
            extra["swgdrug_category"] = e["cat"]
            extra["scheme"] = "SWGDRUG Recommendations v8.2, Part IIIB, Table 1 (printed p. 17)"
        level = "B" if e["src"] in ("UNODC", "SWG") else "C"
        add_claim(cid, sub, FIELD[e["family"]], e["text"], e["src"], section_en, extra, level)
        fam = e["family"]
        if fam in ("colour_test", "odour_test", "chemical"):
            add_link(sub, "scr-colour-tests", "screened_by", cid)
        elif fam == "microcrystal":
            add_link(sub, "scr-microcrystal-tests", "screened_by", cid)
        elif fam == "tlc":
            add_link(sub, "method-tlc", "analysed_by", cid)
        elif fam in ("uv_spectrum", "photometric", "spectroscopy"):
            add_link(sub, "method-uvvis", "analysed_by", cid)
        elif fam == "immunoassay":
            add_link(sub, data.get("screening_id", "method-immunoassay"), "screened_by", cid)
        elif fam == "instrumental":
            for m in data.get("methods", []):
                add_link(sub, m, "analysed_by", cid)

    # ---- overview claims
    swg_loc = _loc("SWG", sec=("Part IIIB, Table 1 (printed p. 17); IIIB.2.2; IIIB.3.1–IIIB.3.4 (printed pp. 18–19)",
                               "Part IIIB, 1-jadval (bosma 17-bet); IIIB.2.2; IIIB.3.1–IIIB.3.4 (bosma 18–19-betlar)",
                               "Part IIIB, табл. 1 (печатная с. 17); IIIB.2.2; IIIB.3.1–IIIB.3.4 (печатные сс. 18–19)"))
    toks_loc = _loc("TOKS", pdf=102, to=103)
    for sub in sorted(by_sub):
        group = subs[sub].get("group")
        seized = group in SEIZED_GROUPS
        tri = overview_text(group, by_sub[sub], existing_instr.get(sub, 0))
        src_key = "SWG" if seized else "TOKS"
        locs = swg_loc if seized else toks_loc
        section_en = strip_src(locs["en"], src_key)
        extra = {"method_family": "overview", "evidence_class": "framing", "locator_i18n": locs,
                 "source_i18n": {lang: SRC[src_key]["short"][i] for i, lang in enumerate(LANGS)},
                 "families": dict(Counter(e["family"] for e in by_sub[sub])), "scope": "substance"}
        if seized:
            extra["scheme"] = "SWGDRUG Recommendations v8.2, Part IIIB"
        cid = f"{PREFIX}{sub.upper()}-IDENTIFICATION_METHODS_OVERVIEW-00"
        add_claim(cid, sub, "identification_methods_overview", tri, src_key, section_en, extra,
                  "B" if seized else "C")

    b["sources"].extend(SOURCES)
    b["claims"].extend(claims)
    b["citations"].extend(cits)
    b["links"].extend(links)
    b["text_translations"].extend(trans)

    # ---- screening tests
    scr = dict(NEW_SCREENING)
    scr["limitations"] = [
        {
            "text": "The source states that many substances form crystals of similar shape, so crystal tests are less specific, that crystals often do not form a defined shape (concentration, volume, evaporation, pH, temperature, polymorphism), and that a comparison control is needed for a correct conclusion.",
            "source_id": "SRC-YULDASHEV-GMT-2024", "locator": "PDF pp. 112–113 (printed pp. 111–112)",
            "texts": {
                "en": "The source states that many substances form crystals of similar shape, so crystal tests are less specific, that crystals often do not form a defined shape (concentration, volume, evaporation, pH, temperature, polymorphism), and that a comparison control is needed for a correct conclusion.",
                "uz": "Manba ko‘p moddalar o‘xshash shakldagi kristallar hosil qilishini, shuning uchun kristall sinamalari kamroq xosligini, kristallar ko‘pincha aniq shaklga ega bo‘lmasligini (konsentratsiya, hajm, bug‘lanish, pH, harorat, polimorfizm) va to‘g‘ri xulosa uchun solishtirma nazorat kerakligini bildiradi.",
                "ru": "Источник указывает, что многие вещества образуют кристаллы сходной формы, поэтому кристаллические пробы менее специфичны, что кристаллы часто не образуют определённой формы (концентрация, объём, испарение, pH, температура, полиморфизм) и что для правильного вывода нужен контрольный образец сравнения.",
            },
        },
        {
            "text": "In the SWGDRUG scheme microcrystalline tests are a category B technique (selectivity through chemical and physical characteristics, without structural information); data must be reviewable (images or contemporaneous documented peer-reviewed notes).",
            "source_id": "SRC-SWGDRUG-8-2", "locator": "Part IIIB, Table 1 (printed p. 17); IIIB.5.1 (printed p. 21)",
            "texts": {
                "en": "In the SWGDRUG scheme microcrystalline tests are a category B technique (selectivity through chemical and physical characteristics, without structural information); data must be reviewable (images or contemporaneous documented peer-reviewed notes).",
                "uz": "SWGDRUG sxemasida mikrokristalloskopik sinamalar B toifasidagi usul (kimyoviy va fizik xususiyatlar orqali selektivlik, tuzilma haqida ma’lumotsiz); ma’lumotlar ko‘rib chiqish uchun mavjud bo‘lishi kerak (rasmlar yoki bir vaqtda yuritilgan, tekshirilgan yozuvlar).",
                "ru": "В схеме SWGDRUG микрокристаллоскопические пробы — метод категории B (избирательность за счёт химических и физических характеристик, без структурной информации); данные должны быть доступны для независимой проверки (изображения или одновременно ведущиеся проверяемые записи).",
            },
        },
    ]
    scr["source_ids"] = ["SRC-YULDASHEV-GMT-2024", "SRC-SWGDRUG-8-2"]
    b["screening_tests"].append(scr)
    swg_micro = _loc("SWG", sec=("Part IIIB, Table 1 (printed p. 17); IIIB.5.1 (printed p. 21)",
                                 "Part IIIB, 1-jadval (bosma 17-bet); IIIB.5.1 (bosma 21-bet)",
                                 "Part IIIB, табл. 1 (печатная с. 17); IIIB.5.1 (печатная с. 21)"))
    for k, (lim, key, lk) in enumerate([(scr["limitations"][0], "GMT", _loc("GMT", pdf=112, to=113)),
                                        (scr["limitations"][1], "SWG", swg_micro)], 1):
        cid = f"{PREFIX}SCR-MICROCRYSTAL-TESTS-LIMITATION-{k:02d}"
        add_claim(cid, "scr-microcrystal-tests", "limitation", lim["texts"], key, strip_src(lk["en"], key),
                  {"locator_i18n": lk, "method_family": "microcrystal", "evidence_class": "presumptive"},
                  "B" if key == "SWG" else "C", entity_type="screeningTest")
        b["claims"].append(claims.pop())
        b["citations"].append(cits.pop())
        if k == 2:
            for m in scr["confirmatory_method_ids"]:
                b["links"].append({"from": "scr-microcrystal-tests", "to": m, "relation": "confirmed_by", "basis": cid})
    sct = next(s for s in b["screening_tests"] if s["screening_id"] == "scr-colour-tests")
    sct["limitations"] = [n for n in sct["limitations"] if n.get("source_id") not in new_source_ids]
    sct["limitations"] += [
        {
            "text": "UNODC: a colour test result is reported as the possible presence of a drug, and similar or other colours may occur with other controlled and non-controlled drugs or precursors.",
            "source_id": "SRC-UNODC-STNAR-13", "locator": "printed pp. 37–52 (PDF pp. 47–62), «Result» and «Remarks» of each test",
            "texts": {
                "en": "UNODC: a colour test result is reported as the possible presence of a drug, and similar or other colours may occur with other controlled and non-controlled drugs or precursors.",
                "uz": "UNODC: rang sinamasi natijasi dorining mumkin bo‘lgan mavjudligi sifatida keltiriladi, o‘xshash yoki boshqa ranglar boshqa nazorat ostidagi va nazoratsiz moddalar yoki prekursorlar bilan ham chiqishi mumkin.",
                "ru": "UNODC: результат цветной пробы приводится как возможное наличие вещества, а сходные или иные цвета возможны и с другими контролируемыми и неконтролируемыми веществами или прекурсорами.",
            },
        },
        {
            "text": "The teaching complex states that a chemist must not rely on one reaction: 2 or more reactions and methods are required, and colour reagents can give a colour with foreign substances and lead to a wrong conclusion.",
            "source_id": "SRC-YULDASHEV-TOKS-2025", "locator": "PDF pp. 102–104",
            "texts": {
                "en": "The teaching complex states that a chemist must not rely on one reaction: 2 or more reactions and methods are required, and colour reagents can give a colour with foreign substances and lead to a wrong conclusion.",
                "uz": "O‘quv-uslubiy majmua kimyogar bitta reaksiyaga tayanmasligi kerakligini bildiradi: 2 yoki undan ortiq reaksiya va usul talab qilinadi, rang hosil qiluvchi reaktivlar esa begona moddalar bilan ham rang berib, noto‘g‘ri xulosaga olib kelishi mumkin.",
                "ru": "Учебно-методический комплекс указывает, что химик не должен полагаться на одну реакцию: требуются 2 или более реакций и методов, а цветные реактивы могут давать окраску с посторонними веществами и приводить к ошибочному выводу.",
            },
        },
        {
            "text": "In the SWGDRUG scheme colour tests are a category C technique (low selectivity, general or class information).",
            "source_id": "SRC-SWGDRUG-8-2", "locator": "Part IIIB, Table 1 (printed p. 17)",
            "texts": {
                "en": "In the SWGDRUG scheme colour tests are a category C technique (low selectivity, general or class information).",
                "uz": "SWGDRUG sxemasida rang sinamalari C toifasidagi usul (past selektivlik, umumiy yoki sinf haqida ma’lumot).",
                "ru": "В схеме SWGDRUG цветные реакции — метод категории C (низкая избирательность, общая информация или информация о классе).",
            },
        },
    ]
    sct["source_ids"] = sorted(set(sct["source_ids"]) | {"SRC-UNODC-STNAR-13", "SRC-YULDASHEV-TOKS-2025",
                                                         "SRC-SWGDRUG-8-2"})

    out = json.dumps(b, indent=2, ensure_ascii=False) + "\n"
    if a.check:
        if BUNDLE.read_text(encoding="utf-8") != out:
            print("bundle.json is not up to date: run build_substance_methods.py")
            return 1
        print("bundle.json up to date")
        return 0
    BUNDLE.write_text(out, encoding="utf-8")
    update_localized_src()
    from coverage_doc import render
    COVERAGE_DOC.write_text(render(b, subs, by_sub, existing_instr, LOCAL_FAMILIES, SEIZED_GROUPS), encoding="utf-8")
    print(f"claims +{len(claims)}, links +{len(links)}, translations +{len(trans)}; "
          f"substances with documented entries: {len(by_sub)}")
    return 0


def update_localized_src():
    d = json.loads(LOCALIZED_SRC.read_text(encoding="utf-8"))
    d["texts"].update(SCREENING_DRAFTS)
    LOCALIZED_SRC.write_text(json.dumps(d, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


if __name__ == "__main__":
    sys.exit(main())
