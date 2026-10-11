#!/usr/bin/env python3
"""Butan dossieri — bo'sh moddalarni to'ldirish ishining birinchi bo'lagi.

Qoida: har bir jumla o'z so'zimiz bilan (`value.statement`), so'zma-so'z
iqtibos olinmaydi; manba `citations` da `source_id` + `locator` bilan
ko'rsatiladi. Manbasi bo'lmagan jumla yozilmaydi.

Skript idempotent: bir xil `claim_id` ikki marta qo'shilmaydi.
"""
import json
import sys
from pathlib import Path

BUNDLE = Path(__file__).resolve().parents[2] / "content/pilot/bundle.json"
ACCESSED = "2026-10-11"

SOURCES = [
    {
        "source_id": "SRC-PMID-28718908",
        "source_type": "journal_article",
        "title": "Death From Butane Inhalation Abuse in Teenagers: Two New "
                 "Case Studies and Review of the Literature.",
        "journal": "Journal of Forensic Sciences",
        "publication_year": 2017,
        "doi": "10.1111/1556-4029.13520",
        "pmid": "28718908",
        "official_url": "https://doi.org/10.1111/1556-4029.13520",
        "accessed_date": ACCESSED,
        "tier": "tier2",
        "evidence_level": "C",
        # Ochiq litsenziya tasdiqlanmagan — faqat havola va o'z so'zimiz
        # bilan qisqa mazmun; so'zma-so'z iqtibos olinmaydi.
        "license_mode": "citeOnly",
        "identifier_verified": True,
        "notes": "PubMed metama'lumoti orqali tekshirilgan (PMID, DOI). "
                 "So'zma-so'z iqtibos yo'q.",
    },
    {
        "source_id": "SRC-PMID-26364197",
        "source_type": "journal_article",
        "title": "Is it worth carrying out determination of N-butane in "
                 "postmortem samples? A case report and a comprehensive "
                 "review of the literature.",
        "journal": "International Journal of Legal Medicine",
        "publication_year": 2015,
        "doi": "10.1007/s00414-015-1260-9",
        "pmid": "26364197",
        "official_url": "https://doi.org/10.1007/s00414-015-1260-9",
        "accessed_date": ACCESSED,
        "tier": "tier2",
        "evidence_level": "C",
        "license_mode": "citeOnly",
        "identifier_verified": True,
        "notes": "PubMed metama'lumoti orqali tekshirilgan (PMID, DOI). "
                 "So'zma-so'z iqtibos yo'q.",
    },
    {
        "source_id": "SRC-PMID-26247128",
        "source_type": "journal_article",
        "title": "Quantitative determination of n-butane metabolites in "
                 "three cases of butane sniffing death.",
        "journal": "Forensic Science International",
        "publication_year": 2015,
        "doi": "10.1016/j.forsciint.2015.07.032",
        "pmid": "26247128",
        "official_url": "https://doi.org/10.1016/j.forsciint.2015.07.032",
        "accessed_date": ACCESSED,
        "tier": "tier2",
        "evidence_level": "C",
        "license_mode": "citeOnly",
        "identifier_verified": True,
        "notes": "PubMed metama'lumoti orqali tekshirilgan (PMID, DOI). "
                 "So'zma-so'z iqtibos yo'q.",
    },
]


def claim(cid, field, statement, *, level="C", extra=None):
    """`statement` — {"uz": ..., "ru": ..., "en": ...} (uchala til majburiy).

    Manbalar inglizcha, mazmun ingliz tilida yozilgan (`authored`); o‘zbekcha
    va ruschasi tekshirilmagan tarjima (`machine_draft`) deb belgilanadi —
    ilovada «Avtomatik tarjima — tekshirilmagan» ko‘rinadi.
    """
    assert set(statement) == {"uz", "ru", "en"}, cid
    value = {
        "statement": statement,
        "translation_status": {
            "en": "authored",
            "uz": "machine_draft",
            "ru": "machine_draft",
        },
    }
    if extra:
        value.update(extra)
    return {
        "claim_id": cid,
        "entity_type": "substance",
        "entity_id": "butane",
        "field": field,
        "domain": "tox",
        "declared_status": "NEEDS_REVIEW",
        "evidence_level": level,
        "layer": "international_scientific",
        "is_structured_value": False,
        "value": value,
    }


CLAIMS = [
    claim(
        "C-BUTANE-METABOLISM_NOTE-D1",
        "metabolism_note",
        {
            "uz": "Butanning bir qismi organizmda 2-butanol va 2-butanon "
                  "(metiletilketon) ga aylanadi. Sniffing natijasida o‘lgan uch "
                  "holatdan ikkitasida bu metabolitlar qonda topilgan, "
                  "uchinchisida topilmagan; mualliflar buni nafas olish usuli "
                  "va surunkali iste’mol bilan bog‘laydi. Ya’ni metabolitning "
                  "yo‘qligi butan ta’sirini inkor etmaydi.",
            "ru": "Часть бутана превращается в организме в 2-бутанол и "
                  "2-бутанон (метилэтилкетон). В трёх случаях смерти при "
                  "вдыхании бутана эти метаболиты были обнаружены в крови в "
                  "двух случаях и не обнаружены в третьем; авторы связывают "
                  "это со способом вдыхания и хроническим употреблением. "
                  "Отсутствие метаболитов не исключает воздействия бутана.",
            "en": "Part of absorbed butane is converted to 2-butanol and "
                  "2-butanone (methyl ethyl ketone). In three butane-sniffing "
                  "deaths these metabolites were found in blood in two cases "
                  "and absent in the third; the authors relate this to the "
                  "pattern and duration of inhalation. Their absence therefore "
                  "does not rule out butane exposure.",
        },
    ),
    claim(
        "C-BUTANE-METABOLITES-D1",
        "metabolites",
        {
            "uz": "Aniqlanadigan metabolitlar: 2-butanol va 2-butanon. Uch "
                  "holatli tadqiqotda qondagi miqdorlar 2-butanol uchun 6,5 va "
                  "6,3 µg/mL, 2-butanon uchun 1,8 va 5,6 µg/mL bo‘lgan.",
            "ru": "Определяемые метаболиты: 2-бутанол и 2-бутанон. В "
                  "исследовании трёх случаев концентрации в крови составили "
                  "6,5 и 6,3 мкг/мл для 2-бутанола и 1,8 и 5,6 мкг/мл для "
                  "2-бутанона.",
            "en": "Metabolites that can be measured: 2-butanol and 2-butanone. "
                  "In a three-case series blood levels were 6.5 and 6.3 µg/mL "
                  "for 2-butanol and 1.8 and 5.6 µg/mL for 2-butanone.",
        },
        extra={"items": ["2-butanol", "2-butanone"]},
    ),
    claim(
        "C-BUTANE-ANALYTICAL_METHOD-D1",
        "analytical_method",
        {
            "uz": "Butan uchuvchi gaz bo‘lgani uchun headspace gaz "
                  "xromatografiyasi — mass-spektrometriya (HS-GC-MS) bilan "
                  "aniqlanadi. Namuna olish va saqlash tartibi hal qiluvchi "
                  "ahamiyatga ega: idish to‘liq to‘ldirilib, germetik yopilishi "
                  "va sovuqda saqlanishi kerak, aks holda gaz yo‘qoladi.",
            "ru": "Поскольку бутан — летучий газ, его определяют методом "
                  "парофазной газовой хроматографии с масс-спектрометрией "
                  "(HS-GC-MS). Решающее значение имеют отбор и хранение "
                  "образца: флакон заполняют полностью, герметично укупоривают "
                  "и хранят на холоде, иначе газ теряется.",
            "en": "Because butane is a volatile gas it is determined by "
                  "headspace gas chromatography–mass spectrometry (HS-GC-MS). "
                  "Sampling and storage are decisive: the vial must be filled "
                  "completely, sealed gas-tight and kept cold, otherwise the "
                  "analyte is lost.",
        },
    ),
    claim(
        "C-BUTANE-REPORTED_CONCENTRATION-D1",
        "reported_concentration",
        {
            "uz": "Manbalarda keltirilgan o‘limga olib kelgan holatlardagi "
                  "miqdorlar: son venasi qonida 18 va 22 mg/L (ikki o‘smir); "
                  "yurak qonida 54,3, 25,5 va 30,7 µg/mL (uch holat); yana bir "
                  "holatda yurak qonida 1280 µg/L, son venasi qonida "
                  "1170 µg/L, oshqozon ichidagi massada 326 µg/L, jigarda "
                  "1010 µg/kg, o‘pkada 210 µg/kg. Bular alohida holatlardagi "
                  "o‘lchovlar — chegaraviy (cutoff) qiymat emas.",
            "ru": "Концентрации, приведённые в источниках по смертельным "
                  "случаям: в бедренной крови 18 и 22 мг/л (двух подростков); "
                  "в сердечной крови 54,3, 25,5 и 30,7 мкг/мл (три случая); в "
                  "ещё одном случае в сердечной крови 1280 мкг/л, в бедренной "
                  "1170 мкг/л, в содержимом желудка 326 мкг/л, в печени "
                  "1010 мкг/кг, в лёгком 210 мкг/кг. Это измерения по "
                  "отдельным случаям, а не пороговые значения.",
            "en": "Concentrations reported in fatal cases: femoral blood 18 "
                  "and 22 mg/L (two teenagers); heart blood 54.3, 25.5 and "
                  "30.7 µg/mL (three cases); in a further case heart blood "
                  "1280 µg/L, femoral blood 1170 µg/L, gastric contents "
                  "326 µg/L, liver 1010 µg/kg and lung 210 µg/kg. These are "
                  "single-case measurements, not a cutoff.",
        },
        extra={
            "specimen": ["blood", "gastric", "liver"],
            "context": "postmortem / o‘limga olib kelgan holatlar",
            "not_a_threshold": True,
            # Har kalit majburiy; manbada aytilmagani `not_stated` qoladi.
            "context_strict": {
                "specimen": ["blood", "gastric", "liver"],
                "sampling": "postmortem",
                "subject_state": "deceased",
                "population": "adolescents and adults, individual cases",
                "study_size": "6 cases (2 + 3 + 1)",
                "case_type": "death after inhalation of a volatile substance",
                "co_intoxicants": "propane (one case, blood, tenfold lower)",
                "analytical_method": "headspace GC-MS",
                "timing": "not_stated",
                "statistic": "individual case values (not an average)",
                "reporting": "primary",
                "limitations": [
                    "no lethal threshold is established",
                    "tissue concentrations vary substantially",
                    "sampling and storage strongly affect the result",
                ],
                "curation": "manual",
            },
        },
    ),
    claim(
        "C-BUTANE-LIMITATION-D1",
        "limitation",
        {
            "uz": "Butan uchun o‘limga olib keluvchi chegara belgilanmagan: "
                  "to‘qimalardagi miqdor keng oraliqda o‘zgaradi, namuna olish "
                  "va saqlash natijaga kuchli ta’sir qiladi. Shuning uchun "
                  "faqat raqamga qarab xulosa chiqarib bo‘lmaydi — hodisa "
                  "sharoiti va patomorfologik ma’lumot bilan birga baholanadi. "
                  "Butan bilan bog‘liq o‘limlar kam qayd etiladi deb "
                  "hisoblanadi.",
            "ru": "Смертельный порог для бутана не установлен: концентрации в "
                  "тканях варьируют в широких пределах, а отбор и хранение "
                  "образца сильно влияют на результат. Поэтому вывод нельзя "
                  "строить только на цифре — её оценивают вместе с "
                  "обстоятельствами происшествия и патоморфологическими "
                  "данными. Считается, что смерти, связанные с бутаном, "
                  "регистрируются не полностью.",
            "en": "No lethal threshold is established for butane: tissue "
                  "concentrations vary widely and sampling and storage strongly "
                  "affect the result. A conclusion cannot rest on the number "
                  "alone; it is weighed together with the circumstances and the "
                  "autopsy findings. Butane-related deaths are considered to be "
                  "under-reported.",
        },
    ),
    claim(
        "C-BUTANE-INTERPRETATION-D1",
        "interpretation",
        {
            "uz": "O‘lim mexanizmi — asfiksiya va/yoki yurak aritmiyasi. Butan "
                  "uch xil holatda uchraydi: ataylab nafas olish (uchuvchi "
                  "moddani suiiste’mol qilish), tasodifiy ta’sir va qotillik. "
                  "O‘smirda sababi noma’lum to‘satdan o‘lim bo‘lsa, uchuvchi "
                  "modda bilan zaharlanish tekshirilishi kerak.",
            "ru": "Механизм смерти — асфиксия и/или сердечная аритмия. Бутан "
                  "встречается в трёх ситуациях: намеренное вдыхание "
                  "(злоупотребление летучими веществами), случайное воздействие "
                  "и убийство. При внезапной смерти подростка неясной причины "
                  "следует проверять отравление летучим веществом.",
            "en": "Death is caused by asphyxia and/or cardiac arrhythmia. "
                  "Butane appears in three settings: deliberate inhalation "
                  "(volatile substance abuse), accidental exposure and "
                  "homicide. Volatile substance poisoning should be considered "
                  "in any sudden death of a teenager of unclear cause.",
        },
    ),
]

CITATIONS = [
    ("C-BUTANE-METABOLISM_NOTE-D1", "SRC-PMID-26247128", "Abstract; Results"),
    ("C-BUTANE-METABOLITES-D1", "SRC-PMID-26247128", "Abstract; Results"),
    ("C-BUTANE-ANALYTICAL_METHOD-D1", "SRC-PMID-28718908", "Abstract; Methods"),
    ("C-BUTANE-ANALYTICAL_METHOD-D1", "SRC-PMID-26364197",
     "Discussion; sample handling and storage"),
    ("C-BUTANE-REPORTED_CONCENTRATION-D1", "SRC-PMID-28718908", "Abstract"),
    ("C-BUTANE-REPORTED_CONCENTRATION-D1", "SRC-PMID-26247128", "Abstract"),
    ("C-BUTANE-REPORTED_CONCENTRATION-D1", "SRC-PMID-26364197", "Abstract"),
    ("C-BUTANE-LIMITATION-D1", "SRC-PMID-26364197", "Abstract; Discussion"),
    ("C-BUTANE-INTERPRETATION-D1", "SRC-PMID-26364197", "Abstract"),
    ("C-BUTANE-INTERPRETATION-D1", "SRC-PMID-28718908", "Abstract; Conclusion"),
]

LINKS = [
    ("butane", "blood", "measured_in", "C-BUTANE-REPORTED_CONCENTRATION-D1"),
    ("butane", "gastric", "measured_in", "C-BUTANE-REPORTED_CONCENTRATION-D1"),
    ("butane", "liver", "measured_in", "C-BUTANE-REPORTED_CONCENTRATION-D1"),
    ("butane", "method-headspace-gc", "analysed_by",
     "C-BUTANE-ANALYTICAL_METHOD-D1"),
    ("butane", "method-gcms", "confirmed_by", "C-BUTANE-ANALYTICAL_METHOD-D1"),
]

METABOLITES = [
    ("MR-BUTANE-2-BUTANOL", "2-butanol"),
    ("MR-BUTANE-2-BUTANONE", "2-butanon (metiletilketon)"),
]


def main() -> int:
    b = json.loads(BUNDLE.read_text())
    have_src = {s["source_id"] for s in b["sources"]}
    for s in SOURCES:
        if s["source_id"] not in have_src:
            b["sources"].append(s)
    have_claim = {c["claim_id"] for c in b["claims"]}
    for c in CLAIMS:
        if c["claim_id"] not in have_claim:
            b["claims"].append(c)
    have_cit = {(c["claim_id"], c["source_id"]) for c in b["citations"]}
    for cid, sid, loc in CITATIONS:
        if (cid, sid) not in have_cit:
            b["citations"].append(
                {"claim_id": cid, "source_id": sid, "locator": loc}
            )
    have_link = {(l["from"], l["to"], l["relation"]) for l in b["links"]}
    for f, t, rel, basis in LINKS:
        if (f, t, rel) not in have_link:
            b["links"].append(
                {"from": f, "to": t, "relation": rel, "basis": basis}
            )
    have_mr = {m["relation_id"] for m in b["metabolite_relations"]}
    for rid, name in METABOLITES:
        if rid not in have_mr:
            b["metabolite_relations"].append({
                "relation_id": rid,
                "parent_id": "butane",
                "metabolite_id": None,
                "metabolite_name": name,
                "kind": "metabolite",
                "specimens": ["blood"],
                "basis_claim_id": "C-BUTANE-METABOLITES-D1",
            })
    BUNDLE.write_text(json.dumps(b, ensure_ascii=False, indent=1) + "\n")
    print("butane: claims", len(CLAIMS), "citations", len(CITATIONS),
          "links", len(LINKS), "metabolites", len(METABOLITES))
    return 0


if __name__ == "__main__":
    sys.exit(main())
