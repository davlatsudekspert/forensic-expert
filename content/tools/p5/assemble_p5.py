#!/usr/bin/env python3
"""PHASE 5 qo‘shimchasi — `assemble_pilot.py` chaqiradi.

Kirish (barchasi real so‘rov/tekshiruv natijasi, phase5/):
  identity.json              — PubChem (137 modda)
  international_control.json — INCB Yellow/Green List qatorlari
  curated_substances.json    — PMC CC BY asl jumlalar (kuratsiyadan o‘tgan)
  curated_topics.json        — metod, reagent, skrining, FM, gistologiya, biokimyo
  research_*.json            — PubMed / Crossref / Europe PMC metadata
  images_*.json              — RDKit strukturalar, original sxemalar, CC BY rasmlar

Qoidalar:
* Hamma yangi yozuv NEEDS_REVIEW. Review yozuvi yo‘q.
* Konsentratsiya — faqat «xabar qilingan qiymat» (namuna + kontekst +
  not_a_threshold); chegara sifatida talqin qilinmaydi.
* Bog‘lanish faqat manba jumlasidagi aniq tilga olish asosida (claim ID).
"""
import json, os, re, sys, urllib.parse

sys.path.insert(0, os.path.dirname(__file__))
from fehttp import get  # noqa: E402

P = "phase5/"
FIELD = {"metabolism": "metabolism_note", "analytical_method": "analytical_method",
         "reported_concentration": "reported_concentration"}
METHOD_RE = [
    ("method-lcmsms", r"LC[-–]?MS/MS|LC[-–]MS[-–]MS|UPLC[-–]MS/MS|UHPLC[-–]MS/MS|HPLC[-–]MS/MS|tandem mass spectrometry|QqQ"),
    ("method-gcms", r"GC[-–/]?MS|gas chromatograph\w*[-–‐ ]+mass spectromet"),
    ("method-gc-fid", r"GC[-–/]?FID|flame ionization"),
    ("method-headspace-gc", r"head-?space"),
    ("method-hplc", r"\bHPLC\b(?![-–]MS)|high[- ]p\w+ liquid chromatography(?! ?[-–]? ?(tandem )?mass)"),
    ("method-hrms", r"HRMS|high[- ]resolution|Q-?To?F|Orbitrap"),
    ("method-immunoassay", r"immunoassay|ELISA|\bEIA\b"),
    ("method-tlc", r"\bTLC\b|HPTLC|thin[- ]layer"),
    ("method-uvvis", r"spectrophotomet|UV[-–]Vis"),
]
SPEC = [("femoral blood", r"femoral"), ("cardiac blood", r"cardiac|heart blood"),
        ("peripheral blood", r"peripheral"), ("blood", r"\bblood\b"), ("plasma", r"plasma"),
        ("serum", r"serum"), ("urine", r"urine|urinary"), ("vitreous humour", r"vitreous|intraocular"),
        ("liver", r"liver"), ("kidney", r"kidney"), ("brain", r"brain"), ("gastric contents", r"stomach|gastric"),
        ("bile", r"\bbile\b"), ("CSF", r"\bCSF\b|cerebrospinal")]


def context_of(s):
    if re.search(r"post-?mortem|autops|deceased|decedent|fatal|death|died|cadaver|coronial", s, re.I):
        return "postmortem / fatal cases"
    if re.search(r"driver|DUID|driving", s, re.I):
        return "drivers (DUID)"
    if re.search(r"patient|admission|admitted|overdose|intoxicat|poisoning|hospital", s, re.I):
        return "clinical intoxication"
    return "case report / series (see source)"


def pubtypes(pmids):
    out = {}
    pmids = sorted({p for p in pmids if p})
    for i in range(0, len(pmids), 150):
        chunk = pmids[i:i + 150]
        r = get("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&retmode=json&id="
                + ",".join(chunk))["result"]
        for p in chunk:
            out[p] = [x.lower() for x in r.get(p, {}).get("pubtype", [])]
    return out


def level(pts):
    if any(x in pts for x in ("systematic review", "meta-analysis")):
        return "A"
    if "review" in pts:
        return "C"
    if "case reports" in pts:
        return "D"
    return "B"


def src_record(c, lvl, acc):
    return dict(source_id=f"SRC-{c['pmcid']}", source_type="journal_article", title=(c.get("title") or "").rstrip("."),
                authors=c.get("authors", []), journal=c.get("journal"),
                publication_year=int(c["year"]) if (c.get("year") or "").isdigit() else None,
                doi=c.get("doi"), pmid=c.get("pmid"),
                official_url=f"https://pmc.ncbi.nlm.nih.gov/articles/{c['pmcid']}/", accessed_date=acc,
                tier="tier2", evidence_level=lvl, license_mode="openReuse", identifier_verified=True,
                notes=f"Litsenziya (PMC BioC API): {c['license']}. Jumla asl matndan ({c['section']}) dasturiy ajratilgan; "
                      "kuratsiya: phase5/curation_manual.json.")


def build(existing_ids, acc):
    ident = json.load(open(P + "identity.json"))
    by_id = {s["id"]: s for s in ident}
    spec = json.load(open(P + "spec_substances.json"))
    alias_res = {}
    for t in spec:
        if t["field"] == "metabolism":
            alias_res[t["entity"]] = t["patterns"][0]
    cur = json.load(open(P + "curated_substances.json"))
    pts = pubtypes([c.get("pmid") for c in cur])

    substances, claims, citations, sources, links = [], [], [], {}, []
    for s in ident:
        if s["id"] in existing_ids:
            continue  # PHASE 3 yozuvi saqlanadi (identity claim’i bor).
        substances.append(dict(
            substance_id=s["id"], canonical_name=s["en"].lower(), entity_kind="substance",
            molecular_formula=s["molecular_formula"], tier_access="pro", group=s["group"],
            names={"en": s["en"], "ru": s["ru"], "uz": s["uz"]},
            translation_status={"en": "machine_draft", "ru": "machine_draft", "uz": "machine_draft"},
            synonyms=[]))
        sid = f"SRC-PUBCHEM-{s['pubchem_cid']}"
        sources[sid] = dict(source_id=sid, source_type="database",
                            title=f"PubChem Compound Summary for CID {s['pubchem_cid']} ({s['title']})",
                            organization="National Center for Biotechnology Information (NCBI), U.S. National Library of Medicine",
                            official_url=s["source_url"], accessed_date=s["accessed"], tier="tier2",
                            evidence_level="C", license_mode="openReuse", identifier_verified=True,
                            notes="PubChem PUG REST orqali avtomatik; bitta CID. Stereokimyo reviewer tasdig‘ini talab qiladi.")
        cid = f"C-{s['id'].upper()}-IDENTITY"
        claims.append(dict(claim_id=cid, entity_type="substance", entity_id=s["id"], field="identity",
                           domain="tox", declared_status="NEEDS_REVIEW", evidence_level="C",
                           layer="international_scientific", is_structured_value=True,
                           value=dict(pubchem_cid=s["pubchem_cid"], molecular_formula=s["molecular_formula"],
                                      molecular_weight=s["molecular_weight"], inchikey=s["inchikey"],
                                      iupac_name=s["iupac_name"])))
        citations.append(dict(claim_id=cid, source_id=sid, locator="Computed Properties"))

    # Guruh mavjud (PHASE 3) yozuvlar uchun ham — assemble_pilot o‘rnatadi.
    groups = {s["id"]: s["group"] for s in ident}

    for c in cur:
        lvl = level(pts.get(c.get("pmid"), []))
        sid = f"SRC-{c['pmcid']}"
        if sid not in sources:
            sources[sid] = src_record(c, lvl, acc)
        field = FIELD[c["field"]]
        cid = f"C-{c['entity'].upper()}-{field.upper()}-P5"
        val = dict(excerpt=c["sentence"], section=c["section"])
        if c["field"] == "reported_concentration":
            val.update(specimen=[n for n, rx in SPEC if re.search(rx, c["sentence"], re.I)] or ["see source"],
                       context=context_of(c["sentence"]), not_a_threshold=True)
        claims.append(dict(claim_id=cid, entity_type="substance", entity_id=c["entity"], field=field,
                           domain="lab" if c["field"] == "analytical_method" else "tox",
                           declared_status="NEEDS_REVIEW", evidence_level=lvl,
                           layer="international_scientific", is_structured_value=False, value=val))
        citations.append(dict(claim_id=cid, source_id=sid, locator=c["section"]))
        if c["field"] == "analytical_method":
            for mid, rx in METHOD_RE:
                if re.search(rx, c["sentence"], re.I):
                    links.append(dict(**{"from": c["entity"], "to": mid, "relation": "analysed_by", "basis": cid}))
        if c["field"] == "metabolism":
            for other, rx in alias_res.items():
                if other != c["entity"] and re.search(r"(?<![\w-])" + rx + r"(?![\w-])", c["sentence"], re.I):
                    links.append(dict(**{"from": c["entity"], "to": other, "relation": "metabolism_co_mention", "basis": cid}))

    # INCB qoidalari (yangi moddalar; PHASE 3 dagilari mavjud qoidalar bilan).
    ctrl = json.load(open(P + "international_control.json"))
    rules = []
    for r in ctrl:
        if r["status"] != "found":
            continue
        instr = "INT-INCB-YL-65" if r["list"] == "yellow" else "INT-INCB-GL-36"
        eff = "2026-07-01" if r["list"] == "yellow" else "2025-01-01"
        rules.append(dict(
            rule_id=f"R-INT-{r['substance_id'].upper()}-{r['list'].upper()}", instrument_id=instr,
            rule_type="control_status", subject_type="substance", subject_id=r["substance_id"],
            value=dict(convention=r["convention"], schedules=r["schedules"],
                       ids_code=sorted({h["ids_code"] for h in r["rows"]}),
                       rows=[h["text"] + (" " + h["continuation"] if h.get("continuation") else "") for h in r["rows"]]),
            effective_from=eff, review_status="NEEDS_REVIEW"))
    return dict(substances=substances, claims=claims, citations=citations, sources=list(sources.values()),
                links=links, rules=rules, groups=groups)


# ---------------------------------------------------------------------------
# B–G: metodlar, reagentlar, skrining, sud tibbiyoti, gistologiya, biokimyo
# ---------------------------------------------------------------------------

# Nomzod maqsad → (bundle’dagi entity, claim maydoni) — qayta yo‘naltirish.
RETARGET = {
    "fm-pmi-methods": ("fm-postmortem-interval", "limitation"),
    "fm-postmortem-changes": ("fm-postmortem-changes", "limitation"),
    "fm-decomposition": ("fm-decomposition", "limitation"),
    "his-drowning": ("fm-drowning", "marker"),
    "his-fat-embolism": ("his-fat-embolism", "case_observation"),
    "bio-vitreous-glucose": ("bio-vitreous-glucose", "marker"),
    "scr-fentanyl-ia": ("scr-immunoassay-fentanyl", "limitation"),
    "scr-ia-confirm": ("scr-immunoassay-drugs", "confirmation_requirement"),
    "met-postmortem-redistribution": ("bio-postmortem-redistribution", "limitation"),
}
REAGENT = lambda e: "reagent-" + e[4:] if e.startswith("rea-") else e  # noqa: E731

NAMES = {
    # metodlar
    "method-gc-fid": ("GC-FID (flame ionization detection)", "ГХ-ПИД", "GX-AID (alanga ionizatsiya detektori)"),
    "method-headspace-gc": ("Headspace gas chromatography", "Парофазная газовая хроматография", "Bug‘ fazali gaz xromatografiyasi"),
    "method-lcmsms": ("LC-MS/MS (liquid chromatography–tandem mass spectrometry)", "ВЭЖХ-МС/МС", "SX-MS/MS (tandem mass-spektrometriya)"),
    "method-hplc": ("HPLC (UV / DAD / fluorescence)", "ВЭЖХ (УФ / ДМД)", "YuSSX (UB / DAD)"),
    "method-tlc": ("Thin-layer chromatography (TLC)", "Тонкослойная хроматография (ТСХ)", "Yupqa qatlamli xromatografiya (YuQX)"),
    "method-uvvis": ("UV-Vis spectrophotometry", "УФ-видимая спектрофотометрия", "UB-ko‘rinadigan spektrofotometriya"),
    "method-immunoassay": ("Immunoassay (principle)", "Иммуноанализ (принцип)", "Immunoanaliz (prinsip)"),
    "method-spectroscopy": ("Vibrational spectroscopy (FTIR / Raman)", "Колебательная спектроскопия (ИК / Раман)", "Tebranma spektroskopiya (IQ / Raman)"),
    "method-hrms": ("High-resolution mass spectrometry (HRMS)", "Масс-спектрометрия высокого разрешения", "Yuqori aniqlikdagi mass-spektrometriya"),
    "method-spe": ("Solid-phase extraction (SPE)", "Твердофазная экстракция", "Qattiq fazali ekstraksiya"),
    "method-lle": ("Liquid–liquid extraction (LLE)", "Жидкость-жидкостная экстракция", "Suyuqlik–suyuqlik ekstraksiyasi"),
    "method-protein-precipitation": ("Protein precipitation", "Осаждение белков", "Oqsillarni cho‘ktirish"),
    "method-quechers": ("QuEChERS extraction", "Экстракция QuEChERS", "QuEChERS ekstraksiyasi"),
    "method-derivatization": ("Derivatization for GC", "Дериватизация для ГХ", "GX uchun derivatizatsiya"),
    "method-validation": ("Method validation", "Валидация методик", "Metod validatsiyasi"),
    "method-uncertainty": ("Measurement uncertainty", "Неопределённость измерений", "O‘lchov noaniqligi"),
    "method-identification-criteria": ("Identification criteria (retention time, ion ratios)", "Критерии идентификации", "Identifikatsiya mezonlari"),
    # reagentlar
    "reagent-mecke": ("Mecke reagent", "Реактив Мекке", "Mecke reaktivi"),
    "reagent-duquenois": ("Duquenois reagent", "Реактив Дюкенуа", "Duquenois reaktivi"),
    "reagent-dragendorff": ("Dragendorff reagent", "Реактив Драгендорфа", "Dragendorff reaktivi"),
    # skrining
    "scr-fentanyl-test-strips": ("Fentanyl test strips", "Тест-полоски на фентанил", "Fentanil test chiziqlari"),
    "scr-immunoassay-amphetamines": ("Amphetamines immunoassay", "Иммуноанализ на амфетамины", "Amfetaminlar immunoanalizi"),
    "scr-immunoassay-opiates": ("Opiates immunoassay", "Иммуноанализ на опиаты", "Opiatlar immunoanalizi"),
    "scr-immunoassay-cannabinoids": ("Cannabinoids immunoassay", "Иммуноанализ на каннабиноиды", "Kannabinoidlar immunoanalizi"),
    "scr-immunoassay-fentanyl": ("Fentanyl immunoassay", "Иммуноанализ на фентанил", "Fentanil immunoanalizi"),
    "scr-colour-tests": ("Colour (spot) tests", "Цветные (капельные) тесты", "Rangli (tomchi) testlar"),
    # sud tibbiyoti
    "fm-death-investigation": ("Death investigation", "Расследование смерти", "O‘lim holatini tekshirish"),
    "fm-postmortem-changes": ("Postmortem changes", "Посмертные изменения", "O‘limdan keyingi o‘zgarishlar"),
    "fm-decomposition": ("Decomposition", "Гниение", "Chirish"),
    "fm-blunt-trauma": ("Blunt force trauma", "Тупая травма", "To‘mtoq jism jarohati"),
    "fm-firearm": ("Firearm injuries (reference)", "Огнестрельные повреждения (справочно)", "O‘qotar qurol jarohatlari (ma’lumotnoma)"),
    "fm-asphyxia": ("Asphyxia", "Асфиксия", "Asfiksiya"),
    "fm-drowning": ("Drowning", "Утопление", "Cho‘kish"),
    "fm-burns": ("Burns and fire deaths", "Ожоги и смерть при пожаре", "Kuyish va yong‘inda o‘lim"),
    "fm-hypothermia": ("Hypothermia", "Гипотермия", "Gipotermiya"),
    "fm-anthropology": ("Forensic anthropology and taphonomy", "Судебная антропология и тафономия", "Sud antropologiyasi va tafonomiya"),
    "fm-age-estimation": ("Age estimation", "Определение возраста", "Yoshni aniqlash"),
    "fm-stature-estimation": ("Stature estimation", "Определение роста", "Bo‘yni aniqlash"),
    "fm-odontology": ("Forensic odontology", "Судебная одонтология", "Sud odontologiyasi"),
    "fm-dvi": ("Disaster victim identification (DVI)", "Идентификация жертв катастроф", "Falokat qurbonlarini identifikatsiya qilish"),
    # gistologiya
    "his-fixation": ("Tissue fixation", "Фиксация тканей", "To‘qimalarni fiksatsiya qilish"),
    "his-ihc": ("Immunohistochemistry in forensic pathology", "Иммуногистохимия в судебной патологии", "Sud patologiyasida immunogistokimyo"),
    "his-wound-vitality": ("Wound vitality and age", "Прижизненность и давность ран", "Jarohat hayotiyligi va yoshi"),
    "his-mi-early": ("Early myocardial infarction (histology)", "Ранний инфаркт миокарда (гистология)", "Erta miokard infarkti (gistologiya)"),
    "his-putrefaction-artifact": ("Artefacts and interpretation limits", "Артефакты и ограничения интерпретации", "Artefaktlar va talqin cheklovlari"),
    "his-fat-embolism": ("Fat embolism (histology)", "Жировая эмболия (гистология)", "Yog‘ emboliyasi (gistologiya)"),
    # biokimyo
    "bio-vitreous-sodium-chloride": ("Vitreous sodium and chloride", "Натрий и хлор стекловидного тела", "Shishasimon tana natriy va xlori"),
    "bio-vitreous-urea-creatinine": ("Vitreous urea and creatinine", "Мочевина и креатинин стекловидного тела", "Shishasimon tana mochevina va kreatinini"),
    "bio-vitreous-glucose": ("Vitreous glucose", "Глюкоза стекловидного тела", "Shishasimon tana glyukozasi"),
    "bio-bhb-ketoacidosis": ("β-Hydroxybutyrate and ketoacidosis", "β-гидроксибутират и кетоацидоз", "β-gidroksibutirat va ketoatsidoz"),
    "bio-hba1c": ("Glycated haemoglobin (HbA1c)", "Гликированный гемоглобин", "Glikirlangan gemoglobin"),
    "bio-tryptase": ("Tryptase (anaphylaxis)", "Триптаза (анафилаксия)", "Triptaza (anafilaksiya)"),
    "bio-crp-procalcitonin": ("CRP and procalcitonin (sepsis)", "СРБ и прокальцитонин (сепсис)", "CRP va prokalsitonin (sepsis)"),
    "bio-cardiac-markers": ("Cardiac markers postmortem", "Посмертные кардиомаркеры", "O‘limdan keyingi kardiomarkerlar"),
    "bio-insulin-cpeptide": ("Insulin and C-peptide", "Инсулин и C-пептид", "Insulin va C-peptid"),
    "bio-csf": ("Cerebrospinal fluid biochemistry", "Биохимия ликвора", "Likvor biokimyosi"),
    "bio-preanalytical-hemolysis": ("Pre-analytical factors: haemolysis", "Преаналитика: гемолиз", "Preanalitik omillar: gemoliz"),
    "bio-sampling-site": ("Sampling site (peripheral vs cardiac)", "Место забора (периферическая / сердечная кровь)", "Namuna olish joyi (periferik / yurak qoni)"),
    "bio-ethanol-neoformation": ("Postmortem ethanol formation", "Посмертное образование этанола", "O‘limdan keyin etanol hosil bo‘lishi"),
    "bio-cocaine-stability": ("Cocaine stability in specimens", "Стабильность кокаина в образцах", "Namunalarda kokain barqarorligi"),
    "bio-temperature-effect": ("Temperature effects and hypothermia markers", "Влияние температуры и маркеры гипотермии", "Harorat ta’siri va gipotermiya markerlari"),
    "bio-postmortem-redistribution": ("Postmortem redistribution", "Посмертное перераспределение", "O‘limdan keyingi qayta taqsimlanish"),
}
FM_ENUM = {"fm-death-investigation": "deathInvestigation", "fm-postmortem-changes": "postmortemChanges",
           "fm-decomposition": "decomposition", "fm-blunt-trauma": "bluntForceInjury", "fm-firearm": "firearmInjury",
           "fm-asphyxia": "asphyxia", "fm-drowning": "drowning", "fm-burns": "burns", "fm-hypothermia": "hypoHyperthermia",
           "fm-anthropology": "anthropology", "fm-age-estimation": "ageEstimation", "fm-stature-estimation": "statureEstimation",
           "fm-odontology": "odontology", "fm-dvi": "disasterVictimIdentification"}
TECH = {"method-gc-fid": ["gcFid"], "method-headspace-gc": ["headspaceGc"], "method-lcmsms": ["lcMsMs"],
        "method-hplc": ["hplc"], "method-tlc": ["tlc"], "method-uvvis": ["uvVis"], "method-immunoassay": ["immunoassay"],
        "method-spectroscopy": ["spectroscopy"], "method-spe": ["extraction", "samplePreparation"],
        "method-lle": ["extraction", "samplePreparation"], "method-protein-precipitation": ["samplePreparation"],
        "method-quechers": ["extraction", "samplePreparation"], "method-derivatization": ["samplePreparation"],
        "method-validation": ["validation"], "method-uncertainty": ["uncertainty"], "method-gcms": ["gcMs"]}
SCR_INFO = {  # (analyte, specimen, principle) — manbada aniq bo‘lmagani taxmin qilinmaydi
    "scr-fentanyl-test-strips": ("fentanyl and some analogues (see source)", "not specified in source", "test strip (see source)"),
    "scr-immunoassay-amphetamines": ("amphetamines (class-based)", "not specified in source", "immunoassay"),
    "scr-immunoassay-opiates": ("opiates (class-based)", "not specified in source", "immunoassay"),
    "scr-immunoassay-cannabinoids": ("THC metabolites (class-based)", "not specified in source", "immunoassay"),
    "scr-immunoassay-fentanyl": ("fentanyl (class-based)", "not specified in source", "immunoassay"),
    "scr-colour-tests": ("various (presumptive)", "seized material (see source)", "colour (spot) reaction"),
}
# Dragendorff — manbadagi to‘liq tarkib (PMC11421204, CC BY); tartib aytilmagan.
DRAGENDORFF_INGREDIENTS = [
    ("distilled water", 70, "mL"), ("acetic acid", 20, "mL"),
    ("potassium iodide solution, 40 g% (w/v)", 5, "mL"),
    ("basic bismuth nitrate, 1.7 g% w/v in 20% v/v acetic acid", 5, "mL"),
]


def build_topics(existing_entity_ids, acc, pts_cache):
    cur = json.load(open(P + "curated_topics.json"))
    pts = pubtypes([c.get("pmid") for c in cur])
    out = dict(sources={}, claims=[], citations=[], topics=[], methods=[], recipes=[], screening=[], links=[])
    made = set(existing_entity_ids)
    claims_by_entity = {}
    for c in cur:
        ent0 = c["entity"]
        ent, field = RETARGET.get(ent0, (REAGENT(ent0), c["field"]))
        lvl = level(pts.get(c.get("pmid"), []))
        sid = f"SRC-{c['pmcid']}"
        out["sources"].setdefault(sid, src_record(c, lvl, acc))
        domain = ("lab" if ent.startswith(("method-", "reagent-")) else
                  "tox" if ent.startswith("scr-") else "fm")
        etype = ("method" if ent.startswith("method-") else "reagent" if ent.startswith("reagent-")
                 else "screeningTest" if ent.startswith("scr-") else "topic")
        cid = f"C-{ent.upper()}-{field.upper()}-P5"
        out["claims"].append(dict(claim_id=cid, entity_type=etype, entity_id=ent, field=field, domain=domain,
                                  declared_status="NEEDS_REVIEW", evidence_level=lvl, layer="international_scientific",
                                  is_structured_value=False, value=dict(excerpt=c["sentence"], section=c["section"])))
        out["citations"].append(dict(claim_id=cid, source_id=sid, locator=c["section"]))
        claims_by_entity.setdefault(ent, []).append((cid, sid, c))

    for ent, items in claims_by_entity.items():
        if ent in made:
            continue
        made.add(ent)
        n = NAMES[ent]
        names = {"en": n[0], "ru": n[1], "uz": n[2]}
        srcs = sorted({s for _, s, _ in items})
        if ent.startswith("method-"):
            out["methods"].append(dict(method_id=ent, kind="scientificMethod", titles=names,
                                       techniques=TECH.get(ent, []), sections={}, text_origin="originalSummary",
                                       status="NEEDS_REVIEW", source_ids=srcs))
        elif ent.startswith("reagent-"):
            rec = dict(recipe_id="recipe-" + ent[8:], reagent_id=ent, names=names, domain="lab",
                       status="NEEDS_REVIEW", ingredients=[], steps=[], hazards=[], source_ids=srcs)
            if ent == "reagent-dragendorff":
                sent = items[0][2]["sentence"]
                rec["ingredients"] = [dict(name=a, amount=b, unit=u) for a, b, u in DRAGENDORFF_INGREDIENTS]
                rec["steps"] = [dict(text=sent)]  # tartib raqamsiz — manba aytmagan
                rec["order_explicit_in_source"] = False
            out["recipes"].append(rec)
        elif ent.startswith("scr-"):
            a, sp, pr = SCR_INFO[ent]
            notes = [dict(text=c["sentence"], source_id=s, locator=c["section"]) for _, s, c in items]
            out["screening"].append(dict(screening_id=ent, names=names, analyte=a, specimen=sp, principle=pr,
                                         limitations=notes, confirmatory_method_ids=["method-gcms", "method-lcmsms"],
                                         supports_definitive_identification=False, status="NEEDS_REVIEW",
                                         source_ids=srcs))
        else:
            area = ("forensicMedicine" if ent.startswith("fm-") else
                    "histology" if ent.startswith("his-") else "biochemistry")
            t = dict(topic_id=ent, area=area, names=names)
            if ent in FM_ENUM:
                t["forensic_medicine_topic"] = FM_ENUM[ent]
            out["topics"].append(t)
    # Skrining → tasdiqlovchi metod (asos: P4 «presumptive» claim’i).
    for s in out["screening"]:
        for m in s["confirmatory_method_ids"]:
            out["links"].append({"from": s["screening_id"], "to": m, "relation": "confirmed_by",
                                 "basis": "C-SCR-IMMUNOASSAY-DRUGS-PRESUMPTIVE_NATURE"})
    # Tahririy taksonomik bog‘lanishlar (sud tibbiyoti ↔ gistologiya / biokimyo).
    for a, b in [("fm-postmortem-interval", "bio-vitreous-potassium"), ("fm-drowning", "his-fat-embolism"),
                 ("fm-hypothermia", "bio-temperature-effect"), ("his-mi-early", "bio-cardiac-markers"),
                 ("fm-burns", "bio-sampling-site"), ("fm-postmortem-changes", "his-putrefaction-artifact")]:
        out["links"].append({"from": a, "to": b, "relation": "related_topic", "basis": "editorial:taxonomy"})
    return out


# ---------------------------------------------------------------------------
# H: research kutubxonasi (dedup) va I: rasmlar
# ---------------------------------------------------------------------------
import hashlib  # noqa: E402


def _norm_title(t):
    return re.sub(r"[^a-z0-9]+", " ", re.sub(r"<[^>]+>|&[a-z]+;", " ", (t or "").lower())).strip()


def dedup_key(r):
    if r.get("doi"):
        return "doi:" + r["doi"].lower()
    if r.get("pmid"):
        return "pmid:" + r["pmid"]
    if r.get("handle"):
        return "handle:" + r["handle"].lower()
    first = (r.get("authors") or [""])[0].lower()
    first = re.split(r"[\s,]+", first)[0] if first else ""
    return f"title:{_norm_title(r['title'])}|{first}"


def build_research(known_entities):
    merged, stats = {}, {"input": 0, "duplicates": 0}
    title_index = {}
    for part in ("pubmed", "crossref", "epmc"):
        path = P + f"research_{part}.json"
        if not os.path.exists(path):
            continue
        for r in json.load(open(path)):
            stats["input"] += 1
            r["title"] = re.sub(r"<[^>]+>|&lt;.*?&gt;", "", r["title"]).strip()
            k = dedup_key(r)
            # Ikkinchi himoya: turli identifikatorli, lekin bir xil sarlavha+muallif.
            tk = f"{_norm_title(r['title'])}|{(r.get('authors') or [''])[0].lower()[:12]}"
            if k in merged or tk in title_index:
                stats["duplicates"] += 1
                tgt = merged.get(k) or merged[title_index[tk]]
                tgt["links"] = sorted(set(tgt.get("links", [])) | set(r.get("links", [])))
                continue
            merged[k] = r
            title_index[tk] = k
    out = []
    for k, r in merged.items():
        rid = "RS-" + hashlib.sha1(k.encode()).hexdigest()[:12]
        links = [REAGENT(x) if x.startswith("rea-") else x for x in r.get("links", [])]
        out.append(dict(research_id=rid, kind=r["kind"], title=r["title"], authors=r.get("authors", []),
                        organization=r.get("organization"), container=r.get("container"),
                        year=r.get("year") or None, doi=r.get("doi"), pmid=r.get("pmid"), pmcid=r.get("pmcid"),
                        handle=r.get("handle"), url=r.get("url"), degree=r.get("degree"),
                        open_access=r.get("open_access"), source_api=r.get("source_api"), accessed=r["accessed"],
                        evidence_level=r["evidence_level"], review_status="NEEDS_REVIEW",
                        _links=[x for x in links if x in known_entities]))
    stats["unique"] = len(out)
    return out, stats


IMAGE_ENTITY_REMAP = {"his-sampling": "his-fixation", "his-he-stain": "bio-tryptase", "his-ihc": "his-mi-early"}


def build_images(known_entities):
    out = []
    for part in ("structures", "schematics", "external"):
        for im in json.load(open(P + f"images_{part}.json")):
            ent = IMAGE_ENTITY_REMAP.get(im["entity_id"], REAGENT(im["entity_id"]))
            if part == "external" and im["entity_id"] == "his-he-stain":
                ent = "bio-tryptase"
            if ent not in known_entities:
                print("image skipped (no entity):", im["image_id"], ent)
                continue
            out.append(dict(image_id=im["image_id"], kind=im["kind"] if part != "schematics" else "schematic",
                            entity_id=ent, file="../phase5/" + im["file"][len("phase5/"):],
                            sha256=im.get("sha256"), title=im["title"], alt=im["alt"], license=im["license"],
                            attribution=im["attribution"], is_original_diagram=im["is_original_diagram"],
                            represents_real_data=im["represents_real_data"], creator=im.get("creator"),
                            source_name=im.get("source_name"), source_url=im.get("source_url"), doi=im.get("doi"),
                            caption_original=im.get("caption_original"), graphic=im.get("graphic", False),
                            accessed=im.get("accessed")))
    return out
