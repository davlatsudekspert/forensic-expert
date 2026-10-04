#!/usr/bin/env python3
"""PHASE 7: tasdiqlanadigan kontent pipeline’i qatlamini bundle’ga qo‘shadi.

Kirish (barchasi real so‘rov/tekshiruv natijasi):
  phase7/legal.json             — legislation.gov.uk, eCFR, gesetze-im-internet,
                                  lex.uz (fetch_legal.py)
  phase7/retraction_check.json  — PubMed `Retracted Publication[pt]`
  phase7/candidates_p7*.json    — PMC OA asl matndan gaplar (find_p7_sentences.py)
  phase7/curation_p7.json       — qabul/rad qarorlari (sabab bilan)

Qoidalar:
* Hech qanday claim VERIFIED/REVIEWED emas — reviewer yo‘q, review_actions = [].
* Konsentratsiya konteksti FAQAT iqtibos matnidan; aytilmagan — `not_stated`.
  Pilotdan tashqari claim’lar `curation: auto_minimal`, `reporting:
  not_assessed`.
* Metabolit roli (active/inactive/marker) faqat iqtibosda aytilgan bo‘lsa.
* Ziddiyatlar yashirilmaydi; hal qilish — faqat reviewer.
* Standartlar — faqat metadata va havola; litsenziyali matn yo‘q.
* Huquqiy yozuvlar NEEDS_REVIEW; «topilmadi» ≠ «nazorat qilinmaydi».
"""
import json

TODAY = "2026-10-04"

PILOT = ["ethanol", "methanol", "isopropanol", "morphine", "heroin",
         "fentanyl", "methadone", "tramadol", "cocaine", "amphetamine",
         "methamphetamine", "mdma", "diazepam", "alprazolam", "pregabalin",
         "thc", "isotonitazene"]
PILOT_METABOLITES = ["6-mam", "benzoylecgonine", "thc-cooh", "nordiazepam",
                     "11-oh-thc"]

# --------------------------------------------------------------------------
# Namunalar (nomlar RU/UZ — machine_draft, RG-11)
# --------------------------------------------------------------------------
SPECIMENS = [
    ("blood", "fluid", "Blood", "Кровь", "Qon",
     ["blood", "whole blood", "cardiac blood", "femoral blood",
      "peripheral blood", "heart blood"]),
    ("serum-plasma", "fluid", "Serum / plasma", "Сыворотка / плазма",
     "Zardob / plazma", ["serum", "plasma"]),
    ("urine", "fluid", "Urine", "Моча", "Siydik", ["urine"]),
    ("vitreous", "fluid", "Vitreous humour", "Стекловидное тело",
     "Shishasimon tana", ["vitreous humour", "vitreous humor", "vitreous"]),
    ("oral-fluid", "fluid", "Oral fluid", "Ротовая жидкость",
     "Og‘iz suyuqligi", ["oral fluid", "saliva"]),
    ("hair", "keratinous", "Hair", "Волосы", "Soch", ["hair"]),
    ("gastric", "content", "Gastric contents", "Содержимое желудка",
     "Oshqozon tarkibi", ["gastric contents", "gastric content",
                          "stomach content"]),
    ("liver", "tissue", "Liver", "Печень", "Jigar", ["liver"]),
    ("bile", "fluid", "Bile", "Желчь", "O‘t suyuqligi", ["bile"]),
    ("kidney", "tissue", "Kidney", "Почка", "Buyrak", ["kidney"]),
    ("brain", "tissue", "Brain", "Головной мозг", "Bosh miya", ["brain"]),
    ("csf", "fluid", "Cerebrospinal fluid", "Спинномозговая жидкость",
     "Orqa miya suyuqligi", ["CSF", "cerebrospinal fluid"]),
]
ALIAS = {a.lower(): sid for sid, *_rest, aliases in SPECIMENS for a in aliases}

# --------------------------------------------------------------------------
# Qat’iy konsentratsiya konteksti — pilot (iqtibos matnidan qo‘lda).
# --------------------------------------------------------------------------
NS = "not_stated"
STRICT = {
    "C-MORPHINE-REPORTED_CONCENTRATION-P5": dict(
        specimen=["blood"], sampling="postmortem", subject_state="deceased",
        population="morphine deaths (study cohort; see source)",
        study_size=NS, case_type="deaths with morphine findings",
        co_intoxicants="stratified: none / alcohol / benzodiazepines / alcohol + benzodiazepines",
        analytical_method=NS, timing=NS,
        statistic="median per group: 0.30 / 0.40 / 0.53 / 0.80 μg/mL",
        reporting="primary",
        limitations=["Analyte reported as free morphine.",
                     "Group medians only; ranges and group sizes are not in the excerpt."]),
    "C-6-MAM-REPORTED_CONCENTRATION-P5": dict(
        specimen=["vitreous"], sampling="postmortem", subject_state="deceased",
        population="heroin-related fatalities, Jeddah 2008–2018; 61–70-year age group",
        study_size=NS, case_type="heroin-related fatalities", co_intoxicants=NS,
        analytical_method=NS, timing=NS,
        statistic="median 21 ng/mL (BNaF); median 52 ng/mL (vitreous humor)",
        reporting="primary",
        limitations=["Second matrix is given as 'BNaF'; the abbreviation is not expanded in the excerpt.",
                     "Values refer to one age group only."]),
    "C-METHADONE-REPORTED_CONCENTRATION-P5": dict(
        specimen=["blood"], sampling="postmortem", subject_state="deceased",
        population="adult methadone-related deaths (compared with children)",
        study_size=NS, case_type="methadone-related deaths", co_intoxicants=NS,
        analytical_method=NS, timing=NS, statistic="mean 503 ng/mL (adults)",
        reporting="primary",
        limitations=["The 400–1000 ng/mL range quoted alongside refers to living patients in methadone maintenance treatment, not to this cohort.",
                     "Post-mortem values overlap living-patient values (see EVIDENCE CONFLICT)."]),
    "C-TRAMADOL-REPORTED_CONCENTRATION-P5": dict(
        specimen=["serum-plasma"], sampling=NS, subject_state=NS,
        population="single previously reported case", study_size="1",
        case_type="tramadol poisoning with hypoglycaemia and cardiac arrest (fatal outcome)",
        co_intoxicants=NS, analytical_method=NS, timing=NS,
        statistic="single value 5.2 mg/L (plasma)", reporting="secondary_citation",
        limitations=["Value is cited from an earlier report, not measured by the citing authors.",
                     "Whether the plasma sample was taken before or after death is not stated in the excerpt."]),
    "C-FENTANYL-REPORTED_CONCENTRATION-P5": dict(
        specimen=["blood"], sampling="postmortem", subject_state="deceased",
        population="deaths from natural causes with an incidental fentanyl finding",
        study_size="12", case_type="natural deaths; fentanyl considered incidental",
        co_intoxicants=NS, analytical_method=NS, timing=NS,
        statistic="range 2.7–33 ng/mL; mean 12 ng/mL", reporting="secondary_citation",
        limitations=["Literature values summarised in a case report / literature review.",
                     "Partially overlaps values in fentanyl-attributed deaths (see EVIDENCE CONFLICT)."]),
    "C-COCAINE-REPORTED_CONCENTRATION-P5": dict(
        specimen=["blood"], sampling="postmortem", subject_state="deceased",
        population="deaths reported to the National Programme on Substance Abuse Deaths (2000–2019)",
        study_size="5339",
        case_type="stratified: cardiac-related deaths / acute intoxication / chronic or binge use",
        co_intoxicants=NS, analytical_method=NS, timing=NS,
        statistic="mean ≈900 / ≈19,100 / ≈6,200 ng/mL", reporting="secondary_citation",
        limitations=["Approximate means quoted in the introduction of another paper."]),
    "C-BENZOYLECGONINE-REPORTED_CONCENTRATION-P5": dict(
        specimen=["blood"], sampling="antemortem", subject_state="living",
        population="motor vehicle drivers in Brittany, France, with at least one positive test",
        study_size="10996", case_type="drivers tested for alcohol/drugs",
        co_intoxicants=NS, analytical_method=NS, timing=NS,
        statistic="median 173.3 ng/mL", reporting="primary",
        limitations=["Median across all positive drivers; not limited to cocaine-only cases."]),
    "C-AMPHETAMINE-REPORTED_CONCENTRATION-P5": dict(
        specimen=["urine", "gastric"], sampling="postmortem", subject_state="deceased",
        population="two fatal cases after oral ingestion", study_size="2",
        case_type="fatal oral amphetamine ingestion (case reports)",
        co_intoxicants=NS, analytical_method=NS, timing=NS,
        statistic="highest values: urine 2600 μg/mL (case 1); stomach content 14,000 μg/g (case 2)",
        reporting="primary",
        limitations=["Highest values only; different units (μg/mL vs μg/g).",
                     "Two cases — not generalisable."]),
    "C-METHAMPHETAMINE-REPORTED_CONCENTRATION-P5": dict(
        specimen=["blood"], sampling="postmortem", subject_state="deceased",
        population="nation-wide 7-year post-mortem study (see source)", study_size=NS,
        case_type="methamphetamine-positive post-mortem cases",
        co_intoxicants="compared: methamphetamine only vs multiple substances",
        analytical_method=NS, timing=NS,
        statistic="mean 2.68 (SD 13.7) vs 1.62 (SD 7.59) µg/mL; P = 0.255 (not significant)",
        reporting="primary",
        limitations=["SD exceeds the mean — strongly skewed distribution."]),
    "C-MDMA-REPORTED_CONCENTRATION-P5": dict(
        specimen=["blood"], sampling="postmortem", subject_state="deceased",
        population="MDMA-positive coronial cases, New Zealand", study_size="73 quantified of 131",
        case_type="coronial cases", co_intoxicants=NS, analytical_method=NS, timing=NS,
        statistic="mean 0.88 mg/L; range 0.01–9.30 mg/L (peripheral blood)",
        reporting="primary",
        limitations=["Coronial cases include deaths not caused by MDMA; cause of death is not in the excerpt."]),
    "C-THC-REPORTED_CONCENTRATION-P5": dict(
        specimen=["serum-plasma"], sampling=NS, subject_state=NS,
        population="paediatric cannabis intoxication cases, France", study_size="26",
        case_type="paediatric cannabis intoxication", co_intoxicants=NS,
        analytical_method=NS, timing=NS,
        statistic="mean THC 29 ng/mL; 11-OH-THC 21 ng/mL; THC-COOH 255 ng/mL (plasma)",
        reporting="secondary_citation",
        limitations=["Cited from another study.", "Time since exposure not stated in the excerpt."]),
    "C-THC-COOH-REPORTED_CONCENTRATION-P5": dict(
        specimen=["liver", "kidney"], sampling=NS, subject_state=NS,
        population="case study reports (see source)", study_size=NS,
        case_type="cannabis-related case reports", co_intoxicants=NS,
        analytical_method=NS, timing=NS,
        statistic="range 8.0–3894 ng/g (liver); 3–1774 ng/mL (kidney, as written)",
        reporting="secondary_citation",
        limitations=["Kidney tissue values are written in ng/mL in the source — reviewer to check units."]),
    "C-ALPRAZOLAM-REPORTED_CONCENTRATION-P5": dict(
        specimen=["blood"], sampling="antemortem", subject_state=NS,
        population="two alprazolam toxicity cases", study_size="2",
        case_type="alprazolam toxicity", co_intoxicants=NS, analytical_method=NS,
        timing=NS, statistic="32.8 and 13.0 ng/mL", reporting="secondary_citation",
        limitations=["Cited from other authors.", "Outcome of the two cases is not stated in the excerpt."]),
    "C-PREGABALIN-REPORTED_CONCENTRATION-P5": dict(
        specimen=["blood"], sampling="postmortem", subject_state="deceased",
        population="drug-related deaths, Australia, 2000–2020", study_size=NS,
        case_type="drug-related deaths", co_intoxicants=NS, analytical_method=NS,
        timing=NS, statistic="mean 16.3 mg/L", reporting="secondary_citation",
        limitations=["National data quoted for comparison, not measured in the citing study."]),
}

# --------------------------------------------------------------------------
# Metabolit munosabatlari (rol faqat iqtibosda aytilgan bo‘lsa).
# --------------------------------------------------------------------------
MET = [
    ("ethanol", None, "acetaldehyde", "metabolite", "C-ETHANOL-METABOLITES"),
    ("ethanol", None, "acetate", "metabolite", "C-ETHANOL-METABOLITES"),
    ("methanol", None, "formaldehyde", "metabolite", "C-METHANOL-METABOLITES"),
    ("methanol", None, "formic acid", "metabolite", "C-METHANOL-METABOLITES"),
    ("morphine", None, "morphine-3-glucuronide (M3G)", "active_metabolite", "C-MORPHINE-METABOLITES"),
    ("morphine", None, "morphine-6-glucuronide (M6G)", "active_metabolite", "C-MORPHINE-METABOLITES"),
    ("heroin", "6-mam", "6-monoacetylmorphine (6-MAM)", "active_metabolite", "C-6-MAM-METABOLISM_NOTE-P5"),
    ("heroin", "morphine", "morphine", "metabolite", "C-HEROIN-METABOLITES"),
    ("fentanyl", None, "norfentanyl", "metabolite", "C-FENTANYL-METABOLITES"),
    ("tramadol", None, "O-desmethyltramadol (M1)", "active_metabolite", "C-TRAMADOL-METABOLITES"),
    ("tramadol", None, "N-desmethyltramadol (M2)", "metabolite", "C-TRAMADOL-METABOLITES"),
    ("methadone", None, "EDDP", "metabolite", "C-METHADONE-METABOLISM_NOTE-P5"),
    ("methamphetamine", None, "4-hydroxymethamphetamine", "metabolite", "C-METHAMPHETAMINE-METABOLITES"),
    ("methamphetamine", "amphetamine", "amphetamine", "metabolite", "C-METHAMPHETAMINE-METABOLITES"),
    ("cocaine", "benzoylecgonine", "benzoylecgonine (BE)", "metabolite", "C-BENZOYLECGONINE-METABOLISM_NOTE-P5"),
    ("cocaine", None, "ecgonine methyl ester (EME)", "metabolite", "C-COCAINE-METABOLITES"),
    ("cocaine", None, "ecgonine (EC)", "metabolite", "C-COCAINE-METABOLITES"),
    ("thc", "11-oh-thc", "11-OH-THC", "active_metabolite", "C-11-OH-THC-METABOLISM_NOTE-P5"),
    ("thc", "thc-cooh", "THC-COOH", "inactive_metabolite", "C-THC-METABOLISM_NOTE-P5"),
    ("diazepam", "nordiazepam", "nordiazepam", "metabolite", "C-DIAZEPAM-METABOLISM_NOTE-P5"),
    ("diazepam", None, "temazepam", "metabolite", "C-DIAZEPAM-METABOLISM_NOTE-P5"),
    ("diazepam", None, "oxazepam", "metabolite", "C-DIAZEPAM-METABOLISM_NOTE-P5"),
    ("alprazolam", None, "4-hydroxyalprazolam", "metabolite", "C-ALPRAZOLAM-METABOLITES"),
    ("alprazolam", None, "α-hydroxyalprazolam", "metabolite", "C-ALPRAZOLAM-METABOLITES"),
]
# Ataylab yo‘q: isotonitazene (iqtibos aniq emas), MDMA (faqat umumiy
# konjugatlar), pregabalin (ahamiyatsiz metabolizm) — `phase7/dossier.json`.

CONFLICTS = [
    dict(conflict_id="CF-VITREOUS-K-PMI", entity_id="bio-vitreous-potassium",
         question="Can vitreous potassium be used to estimate the post-mortem interval?",
         kind="context_dependent",
         claim_ids=["C-BIO-VITREOUS-POTASSIUM-MARKER", "C-BIO-VITREOUS-POTASSIUM-LIMITATION"],
         note="One source reports a linear rise of vitreous potassium with advancing PMI; another reports an inconsistent influence of temperature and calls it a potential confounding factor."),
    dict(conflict_id="CF-METHADONE-PM-VS-LIVING", entity_id="methadone",
         question="Does a post-mortem methadone blood concentration distinguish toxicity from therapeutic use?",
         kind="value_overlap", claim_ids=["C-METHADONE-REPORTED_CONCENTRATION-P5"],
         note="The source states that the mean adult post-mortem concentration (503 ng/mL) overlaps the range reported in living patients on maintenance treatment (400–1000 ng/mL)."),
    dict(conflict_id="CF-FENTANYL-INCIDENTAL", entity_id="fentanyl",
         question="Can a fentanyl blood concentration alone separate fentanyl-attributed deaths from incidental findings?",
         kind="value_overlap", claim_ids=["C-FENTANYL-REPORTED_CONCENTRATION-P5"],
         note="The source reports partial overlap with blood values in natural-cause deaths where fentanyl was considered incidental (n = 12, 2.7–33 ng/mL)."),
    dict(conflict_id="CF-TRAMADOL-M2-ACTIVITY", entity_id="tramadol",
         question="Is N-desmethyltramadol (M2) described as an active metabolite?",
         kind="inconsistent_characterisation",
         claim_ids=["C-TRAMADOL-METABOLITES", "C-TRAMADOL-METABOLISM_NOTE-P5"],
         note="One source names only O-desmethyltramadol as the active metabolite and M2 simply as 'the metabolite M2'; another describes both M1 and M2 as 'active metabolites'."),
]

# Skrining → modda (asos: claim matnida ikkalasi tilga olingan).
SCREENED = [
    ("cocaine", "scr-immunoassay-drugs", "C-METHOD-IMMUNOASSAY-PRINCIPLE-P5"),
    ("benzoylecgonine", "scr-immunoassay-drugs", "C-METHOD-IMMUNOASSAY-PRINCIPLE-P5"),
    ("fentanyl", "scr-fentanyl-test-strips", "C-SCR-FENTANYL-TEST-STRIPS-LIMITATION-P5"),
    ("fentanyl", "scr-immunoassay-fentanyl", "C-SCR-IMMUNOASSAY-FENTANYL-LIMITATION-P5"),
    ("amphetamine", "scr-immunoassay-amphetamines", "C-SCR-IMMUNOASSAY-CANNABINOIDS-LIMITATION-P5"),
    ("methamphetamine", "scr-immunoassay-amphetamines", "C-SCR-IMMUNOASSAY-CANNABINOIDS-LIMITATION-P5"),
    ("thc", "scr-immunoassay-cannabinoids", "C-SCR-IMMUNOASSAY-CANNABINOIDS-LIMITATION-P5"),
]

STANDARDS = [
    dict(standard_id="STD-ICH-Q2R2", designation="ICH Q2(R2)",
         title="Validation of Analytical Procedures", publisher="ICH",
         document_kind="guideline", status="current", reuse="CITE_ONLY",
         year="2023", edition="Adopted 1 November 2023",
         url="https://database.ich.org/sites/default/files/ICH_Q2%28R2%29_Guideline_2023_1130.pdf",
         verified_from="https://database.ich.org/sites/default/files/ICH_Q2%28R2%29_Guideline_2023_1130.pdf",
         sha256="d935618fd3c51d2f063eec7a227d19da50db8b6cfe44f59d09ab43039ad6472c",
         disciplines=["analytical_science", "forensic_toxicology"],
         note="Pharmaceutical scope; applicability to forensic methods is a laboratory decision."),
    dict(standard_id="STD-ICH-Q2R1", designation="ICH Q2(R1)",
         title="Validation of Analytical Procedures: Text and Methodology",
         publisher="ICH", document_kind="guideline", status="superseded",
         superseded_by="STD-ICH-Q2R2", reuse="CITE_ONLY", year="2005",
         edition="Step 4, November 2005",
         url="https://database.ich.org/sites/default/files/Q2%28R1%29%20Guideline.pdf",
         verified_from="https://database.ich.org/sites/default/files/Q2%28R1%29%20Guideline.pdf",
         sha256="a22ff5f9a9f851eebcac99fe8895d62ee510a6359d8c0cc9b2888ae68e6f293a",
         disciplines=["analytical_science"],
         note="Superseded by Q2(R2) (complete revision; history table in Q2(R2))."),
    dict(standard_id="STD-UNODC-ST-NAR-41", designation="UNODC ST/NAR/41",
         title="Guidance for the Validation of Analytical Methodology and Calibration of Equipment used for Testing of Illicit Drugs in Seized Materials and Biological Specimens",
         publisher="United Nations Office on Drugs and Crime", document_kind="guideline",
         status="current", reuse="CITE_ONLY", year="2009",
         edition="ISBN 978-92-1-148243-0, Sales No. E.09.XI.16",
         url="https://www.unodc.org/documents/scientific/validation_E.pdf",
         verified_from="https://www.unodc.org/documents/scientific/validation_E.pdf",
         sha256="acdc6b7a1621f8efaac7bf9aac337a1b1ca69316fe2bbbbfb7dc3c59c18e2751",
         disciplines=["forensic_toxicology", "forensic_chemistry"],
         note="Status 'current' means no successor was found on the publisher page; not a statement of endorsement."),
    dict(standard_id="STD-ASB-056-25", designation="ANSI/ASB Standard 056-25",
         title="Standard for Evaluation of Measurement Uncertainty in Forensic Toxicology",
         publisher="Academy Standards Board (ASB)", document_kind="standard",
         status="current", reuse="LICENSE_REQUIRED", year="2025", edition="1st Ed.",
         verified_from="https://www.nist.gov/organization-scientific-area-committees-forensic-science/osac-registry",
         disciplines=["forensic_toxicology"],
         note="Listed on the OSAC Registry (SDO published standard). Text not reproduced."),
    dict(standard_id="STD-ASB-017-25", designation="ANSI/ASB Standard 017-25",
         title="Standard Practices for Measurement Traceability in Forensic Toxicology",
         publisher="Academy Standards Board (ASB)", document_kind="standard",
         status="current", reuse="LICENSE_REQUIRED", year="2025", edition="2nd Ed.",
         verified_from="https://www.nist.gov/organization-scientific-area-committees-forensic-science/osac-registry",
         disciplines=["forensic_toxicology"],
         note="Listed on the OSAC Registry (SDO published standard). Text not reproduced."),
    dict(standard_id="STD-ASTM-E2329-25", designation="ANSI/ASTM E2329-25",
         title="Standard Practice for Identification of Seized Drugs",
         publisher="ASTM International", document_kind="standard", status="current",
         reuse="LICENSE_REQUIRED", year="2025",
         verified_from="https://www.nist.gov/organization-scientific-area-committees-forensic-science/osac-registry",
         disciplines=["forensic_chemistry"],
         note="Listed on the OSAC Registry (SDO published standard). Text not reproduced."),
    dict(standard_id="STD-OSAC-2025-S-0010", designation="OSAC 2025-S-0010",
         title="Standard Practice for Reporting Results of the Analysis of Seized Drugs",
         publisher="Organization of Scientific Area Committees for Forensic Science (OSAC)",
         document_kind="standard", status="proposed", reuse="CITE_ONLY", year="2025",
         verified_from="https://www.nist.gov/organization-scientific-area-committees-forensic-science/osac-registry",
         disciplines=["forensic_chemistry"],
         note="OSAC Proposed Standard, in SDO development — not a published SDO standard."),
]
STANDARD_FOR = [
    ("STD-ICH-Q2R2", "method-validation"),
    ("STD-UNODC-ST-NAR-41", "method-validation"),
    ("STD-ASB-056-25", "method-uncertainty"),
    ("STD-ASB-017-25", "method-uncertainty"),
    ("STD-ASTM-E2329-25", "method-identification-criteria"),
]

# Ilmiy terminlar (RU/UZ — machine_draft; DOI/formula/qisqartma tarjima qilinmaydi).
TERMS = [
    ("postmortem-redistribution", "term", "postmortem redistribution", "посмертное перераспределение", "o‘limdan keyingi qayta taqsimlanish"),
    ("livor-mortis", "term", "livor mortis", "трупные пятна", "murda dog‘lari"),
    ("rigor-mortis", "term", "rigor mortis", "трупное окоченение", "murda qotishi"),
    ("algor-mortis", "term", "algor mortis", "трупное охлаждение", "murda sovishi"),
    ("postmortem-interval", "term", "postmortem interval", "давность наступления смерти", "o‘limdan keyin o‘tgan vaqt"),
    ("vitreous-humour", "term", "vitreous humour", "стекловидное тело", "shishasimon tana"),
    ("oral-fluid", "term", "oral fluid", "ротовая жидкость", "og‘iz suyuqligi"),
    ("screening-test", "term", "screening test", "скрининговый тест", "skrining testi"),
    ("confirmatory-analysis", "term", "confirmatory analysis", "подтверждающий анализ", "tasdiqlovchi tahlil"),
    ("active-metabolite", "term", "active metabolite", "активный метаболит", "faol metabolit"),
    ("measurement-uncertainty", "term", "measurement uncertainty", "неопределённость измерения", "o‘lchash noaniqligi"),
    ("limit-of-detection", "term", "limit of detection", "предел обнаружения", "aniqlash chegarasi"),
    ("limit-of-quantitation", "term", "limit of quantitation", "предел количественного определения", "miqdoriy aniqlash chegarasi"),
    ("lc-ms-ms", "abbreviation", "LC-MS/MS", None, None),
    ("gc-ms", "abbreviation", "GC-MS", None, None),
    ("6-mam", "abbreviation", "6-MAM", None, None),
    ("thc-cooh", "abbreviation", "THC-COOH", None, None),
    ("doi", "identifier", "DOI", None, None),
    ("pmid", "identifier", "PMID", None, None),
    ("morphine-formula", "formula", "C17H19NO3", None, None),
]

# Rasmiy hujjat sarlavhalari: asl til + EN/RU/UZ (machine_draft, RG-11).
TITLE_I18N = {
    "GB-MDA-1971-SCH2": dict(ru="Закон о злоупотреблении наркотиками 1971 г., Приложение 2 — контролируемые наркотики",
                             uz="1971-yilgi Giyohvand moddalarni suiiste’mol qilish to‘g‘risidagi qonun, 2-ilova — nazorat qilinadigan moddalar"),
    "US-21CFR1308": dict(ru="21 CFR, часть 1308 — Списки контролируемых веществ",
                         uz="21 CFR, 1308-qism — Nazorat qilinadigan moddalar jadvallari"),
    "DE-BTMG-ANL": dict(en="Narcotics Act (BtMG), Annexes I–III",
                        ru="Закон о наркотических средствах (BtMG), приложения I–III",
                        uz="Giyohvandlik vositalari to‘g‘risidagi qonun (BtMG), I–III ilovalar"),
    "UZ-LAW-813-I": dict(en="Law of the Republic of Uzbekistan “On Narcotic Drugs and Psychotropic Substances”",
                         uz="O‘zbekiston Respublikasining «Giyohvandlik vositalari va psixotrop moddalar to‘g‘risida»gi Qonuni"),
}

COUNTRIES = {
    "US": ("United States", "США", "AQSH"),
    "DE": ("Germany", "Германия", "Germaniya"),
    "UZ": ("Uzbekistan", "Узбекистан", "O‘zbekiston"),
}


def specimens_of(strings):
    out = []
    for s in strings or []:
        sid = ALIAS.get(s.lower())
        if sid and sid not in out:
            out.append(sid)
    return out


def apply(b):
    """Bundle (dict) ni joyida PHASE 7 qatlami bilan to‘ldiradi."""
    stats = {}
    claims = {c["claim_id"]: c for c in b["claims"]}
    known = ({s["substance_id"] for s in b["substances"]}
             | {t["topic_id"] for t in b["topics"]}
             | {m["method_id"] for m in b["methods"]}
             | {s["screening_id"] for s in b["screening_tests"]})

    links = b["links"]

    # --- Manba provenance / hayot sikli ---------------------------------
    retr = json.load(open("phase7/retraction_check.json"))
    retracted_pmids = set(retr["retracted"])
    retraction_notice = {"39575351": "Retraction notice: Cureus 2025;17(1):r156, doi:10.7759/cureus.r156 (PMID 39791019)."}
    for s in b["sources"]:
        pmid = s.get("pmid")
        if pmid:
            s["lifecycle_checked_at"] = retr["checked"]
            if pmid in retracted_pmids:
                s["lifecycle"] = "retracted"
                s["lifecycle_basis"] = ("PubMed publication type 'Retracted Publication' "
                                        f"(PMID {pmid}). " + retraction_notice.get(pmid, ""))
            else:
                s["lifecycle"] = "current"
                s["lifecycle_basis"] = "PubMed 'Retracted Publication[pt]' check: not retracted."
        notes = s.get("notes") or ""
        if "PDF SHA-256: " in notes:
            s["sha256"] = notes.split("PDF SHA-256: ")[1].split()[0].strip(".")
        if s.get("edition") and s["source_type"] == "legislation":
            s["source_version"] = s["edition"]
    stats["retracted_sources"] = [s["source_id"] for s in b["sources"]
                                  if s.get("lifecycle") == "retracted"]

    # --- FM pilot: rigor mortis mavzusi (taksonomiya yozuvi; mazmuni claim’da)
    if not any(t["topic_id"] == "fm-rigor-mortis" for t in b["topics"]):
        b["topics"].append(dict(topic_id="fm-rigor-mortis", area="forensicMedicine",
                                forensic_medicine_topic="rigorMortis", tier_access="pro",
                                names=dict(en="Rigor mortis", ru="Трупное окоченение",
                                           uz="Murda qotishi (rigor mortis)")))
        known.add("fm-rigor-mortis")
        for other in ("fm-livor-mortis", "fm-algor-mortis", "fm-postmortem-changes"):
            links.append({"from": "fm-rigor-mortis", "to": other,
                          "relation": "related_topic", "basis": "editorial:taxonomy"})

    # --- Yangi manbali claim’lar (namuna va FM) -------------------------
    cur = json.load(open("phase7/curation_p7.json"))
    src_ids = {s["source_id"] for s in b["sources"]}
    added = []
    for c in cur["accepted"]:
        sid = f"SRC-{c['pmcid']}"
        if sid not in src_ids:
            b["sources"].append(dict(
                source_id=sid, source_type="journal_article", title=c["title"],
                journal=c["journal"], publication_year=int(c["year"]),
                doi=c["doi"], pmid=c["pmid"],
                official_url=f"https://pmc.ncbi.nlm.nih.gov/articles/{c['pmcid']}/",
                accessed_date=TODAY, tier="tier2", evidence_level="B",
                license_mode="openReuse", identifier_verified=True,
                lifecycle="current", lifecycle_checked_at=TODAY,
                lifecycle_basis="Excluded retracted PMIDs at selection (PubMed check).",
                language="en",
                notes=f"Litsenziya (PMC BioC): {c['license']}. Iqtibos asl matndan "
                      f"dasturiy ajratilgan (find_p7_sentences.py). PHASE 7."))
            src_ids.add(sid)
        cid = c["claim_id"]
        b["claims"].append(dict(
            claim_id=cid, entity_type=c["entity_type"], entity_id=c["entity_id"],
            field=c["field"], domain=c["domain"], declared_status="NEEDS_REVIEW",
            evidence_level="B", layer="international_scientific",
            is_structured_value=False,
            value=dict(excerpt=c["verbatim_sentence"], section=c["section"])))
        b["citations"].append(dict(claim_id=cid, source_id=sid, locator=c["section"]))
        added.append(cid)
    stats["new_claims"] = added

    # --- Namunalar ----------------------------------------------------
    b["specimens"] = [dict(specimen_id=i, category=cat,
                           names=dict(en=en, ru=ru, uz=uz), aliases=al)
                      for i, cat, en, ru, uz, al in SPECIMENS]
    spec_ids = {s["specimen_id"] for s in b["specimens"]}

    # --- Qat’iy konsentratsiya konteksti --------------------------------
    curated = 0
    for c in b["claims"]:
        if c["field"] != "reported_concentration":
            continue
        v = c["value"]
        if c["claim_id"] in STRICT:
            ctx = dict(STRICT[c["claim_id"]], curation="pilot_manual")
            curated += 1
            # P5 avtomatik yorlig‘i iqtibosga zid bo‘lsa — tuzatiladi va qayd etiladi.
            if c["claim_id"] == "C-METHADONE-REPORTED_CONCENTRATION-P5":
                v["context_label_correction"] = ("P5 label 'clinical intoxication' replaced: "
                                                 "excerpt and title describe post-mortem deaths.")
                v["context"] = "postmortem / fatal cases"
        else:
            ctx = dict(specimen=specimens_of(v.get("specimen")) or ["blood"],
                       sampling=NS, subject_state=NS, population=NS, study_size=NS,
                       case_type=NS, co_intoxicants=NS, analytical_method=NS,
                       timing=NS, statistic=NS, reporting="not_assessed",
                       limitations=["Context not yet curated (PHASE 7 pilot covers 17 substances)."],
                       curation="auto_minimal")
            if not specimens_of(v.get("specimen")):
                ctx["specimen"] = []
        assert all(x in spec_ids for x in ctx["specimen"]), c["claim_id"]
        v["context_strict"] = ctx
        if c["entity_id"] in known:
            for sp in ctx["specimen"]:
                links.append({"from": c["entity_id"], "to": sp,
                              "relation": "measured_in", "basis": c["claim_id"]})
    stats["concentration_curated"] = curated
    # Namunasiz qolgan auto claim’lar FE033 da xato beradi — ro‘yxat.
    empty = [c["claim_id"] for c in b["claims"] if c["field"] == "reported_concentration"
             and not c["value"]["context_strict"]["specimen"]]
    stats["concentration_without_specimen"] = empty

    # --- Metabolitlar ---------------------------------------------------
    rels = []
    for parent, mid, name, kind, basis in MET:
        assert basis in claims, basis
        rid = f"MR-{parent.upper()}-{(mid or name).upper()}"
        rid = "".join(ch if ch.isalnum() or ch == "-" else "-" for ch in rid)
        rels.append(dict(relation_id=rid, parent_id=parent, metabolite_id=mid,
                         metabolite_name=name, kind=kind, specimens=[],
                         basis_claim_id=basis))
        if mid and mid in known:
            links.append({"from": parent, "to": mid, "relation": "has_metabolite",
                          "basis": rid})
    b["metabolite_relations"] = rels

    # --- Skrining, standartlar ------------------------------------------
    for sub, scr, basis in SCREENED:
        assert basis in claims and scr in known and sub in known, (sub, scr)
        links.append({"from": sub, "to": scr, "relation": "screened_by", "basis": basis})
    for st in STANDARDS:
        st.setdefault("verified_at", TODAY)
    b["standards"] = STANDARDS
    for std, target in STANDARD_FOR:
        links.append({"from": std, "to": target, "relation": "standard_for", "basis": std})

    # --- Ziddiyatlar ----------------------------------------------------
    for k in CONFLICTS:
        k["state"] = "open"
        k["detected_at"] = TODAY
        assert all(cid in claims for cid in k["claim_ids"]), k["conflict_id"]
    b["conflicts"] = CONFLICTS

    # --- Terminlar ------------------------------------------------------
    b["term_translations"] = [
        dict(term_id=f"T-{tid.upper()}", kind=kind, original=en, original_lang="en",
             canonical=en,
             localized=dict(en=en, ru=ru or en, uz=uz or en),
             status=dict(en="reviewed" if kind != "term" else "machine_draft",
                         ru="machine_draft", uz="machine_draft"))
        for tid, kind, en, ru, uz in TERMS]
    # Tarjima qilinmaydigan turlar: lokal qiymat = asl; holat baribir qayd etiladi.
    for t in b["term_translations"]:
        if t["kind"] != "term":
            t["status"] = dict(en="machine_draft", ru="machine_draft", uz="machine_draft")

    # --- Yurisdiksiya pilot (GB/US/DE/UZ) --------------------------------
    legal = json.load(open("phase7/legal.json"))
    have_j = {j["jurisdiction_id"] for j in b["jurisdictions"]}
    for code, (en, ru, uz) in COUNTRIES.items():
        if code not in have_j:
            b["jurisdictions"].append(dict(jurisdiction_id=code, level="country",
                                           parent_id="INT", iso3166=code,
                                           names=dict(en=en, ru=ru, uz=uz)))
    rule_count = 0
    for j in legal["jurisdictions"]:
        jid, iid = j["jurisdiction"], j["instrument_id"]
        auth = f"AUTH-{iid}"
        b["authorities"].append(dict(authority_id=auth, jurisdiction_id=jid,
                                     names=dict(en=j["authority"])))
        sha = j["sha256"] if isinstance(j["sha256"], str) else None
        src = f"SRC-{iid}"
        b["sources"].append(dict(
            source_id=src, source_type="legislation", title=j["title"],
            organization=j["authority"], official_url=j["official_url"],
            accessed_date=legal["checked"], tier="tier1", evidence_level="A",
            license_mode="openReuse" if jid in ("GB", "US") else "citeOnly",
            identifier_verified=True, language=j["language"], sha256=sha,
            source_version=j.get("version") or legal["checked"],
            notes=(f"Licence: {j['license']}. Retrieved {legal['checked']}. "
                   + ("Per-part SHA-256: " + json.dumps(j["sha256"], ensure_ascii=False)
                      if not sha else "")
                   + (" " + j["note"] if j.get("note") else ""))))
        effective = j.get("effective_from")
        b["instruments"].append(dict(
            instrument_id=iid, jurisdiction_id=jid,
            instrument_type="law" if jid == "UZ" else "controlled_substance_schedule",
            authority_id=auth, titles={**TITLE_I18N.get(iid, {}), j["language"]: j["title"]},
            translation_status="machine_draft",
            official_source_id=src,
            official_reference=j["number"] + ("" if effective else
                f" — consolidated text retrieved {legal['checked']}; date of entry into force not recorded (NEEDS LEGAL REVIEW)"),
            effective_from=effective or legal["checked"],
            version=j.get("version") or legal["checked"],
            last_verified_at=legal["checked"], legal_status="in_force",
            publication_date=j.get("publication_date"), language=j["language"],
            review_status="NEEDS_REVIEW", date_precision="day"))
        for r in j["rules"]:
            rid = f"R-{jid}-{r['substance'].upper()}-CONTROL"
            b["rules"].append(dict(
                rule_id=rid, instrument_id=iid, rule_type="control_status",
                subject_type="substance", subject_id=r["substance"],
                article_section=r.get("section") or r["schedule"],
                value=dict(schedule=r["schedule"], list_entry=r["matched"],
                           entry_text=r["context"][:400],
                           note="Exact list-entry match on the official text. "
                                "Absence of a match does not mean a substance is uncontrolled."),
                effective_from=effective or legal["checked"],
                review_status="NEEDS_REVIEW"))
            rule_count += 1
    stats["legal_rules_added"] = rule_count
    for r in b["rules"]:
        if r["rule_type"] == "control_status" and r["subject_id"] in known:
            links.append({"from": r["subject_id"], "to": r["rule_id"],
                          "relation": "legal_status", "basis": r["rule_id"]})

    b["review_actions"] = []  # HUMAN VERIFIED = 0: reviewer qatnashmagan.
    seen, uniq = set(), []
    for l in links:
        k = (l["from"], l["to"], l["relation"])
        if k not in seen:
            seen.add(k)
            uniq.append(l)
    b["links"] = uniq
    stats["metabolite_relations"] = len(rels)
    stats["conflicts"] = len(CONFLICTS)
    stats["standards"] = len(STANDARDS)
    return stats
