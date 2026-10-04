#!/usr/bin/env python3
"""PHASE 4 pilot qo‘shimchasi — `assemble_pilot.py` tomonidan chaqiriladi.

Kirish (barchasi real so‘rov/tekshiruv natijasi):
  pilot/metabolites.verified.json — PMC BioC asl matn iqtiboslari
      (curated_topics.json → verify_excerpts.py tasdiqlagan, CC BY)
  pilot/jurisdiction_gb.generated.json — legislation.gov.uk rasmiy XML
      (verify_legislation_uk.py, SHA-256 bilan)

Qat’iy qoidalar:
* Hammasi NEEDS_REVIEW. Review yozuvi yo‘q.
* Retsept, konsentratsiya, cutoff, sezgirlik — YO‘Q (manbada yo‘q).
  Marquis reagenti uchun tayyorlash ma’lumoti bo‘sh: ilova
  «MA’LUMOT TEKSHIRILMAGAN» holatini ko‘rsatadi.
* Mavzu matni — faqat manbadagi asl jumla (iqtibos), o‘zimiz yozgan
  ilmiy matn yo‘q. Nomlar tarjimasi — machine_draft.
* Huquqiy ma’lumot — Jurisdiction Layer, ilmiy qatlamdan alohida;
  Shimoliy Irlandiya uchun ma’lumot yo‘q → ilova «ma’lumot yo‘q» deydi
  (xulosa chiqarilmaydi).
"""
import json

# Dalil darajasi — maqola turiga ko‘ra DASTLABKI baho (reviewer tasdiqlaydi).
# A: tizimli review / rasmiy; B: birlamchi tadqiqot; C: narrativ review.
LEVELS = {
    "PMC5431803": "B", "PMC13224331": "C", "PMC12147671": "B",
    "PMC12450430": "C", "PMC11580817": "B", "PMC10861637": "C",
    "PMC11929145": "C", "PMC11961553": "B", "PMC5537996": "C",
    "PMC11402778": "B", "PMC2688477": "B",
}

# Curated jumla → (bilim obyekti, claim maydoni, entity_type, domain).
CLAIM_TARGETS = {
    "fm-livor-mortis": ("fm-livor-mortis", "definition", "topic", "fm"),
    "fm-algor-mortis": ("fm-algor-mortis", "definition", "topic", "fm"),
    "fm-pmi-uncertainty": ("fm-postmortem-interval", "limitation", "topic",
                           "fm"),
    "bio-vitreous-potassium": ("bio-vitreous-potassium", "marker", "topic",
                               "fm"),
    "bio-vitreous-confounding": ("bio-vitreous-potassium", "limitation",
                                 "topic", "fm"),
    "met-gcms": ("method-gcms", "role_in_forensic_toxicology", "method",
                 "lab"),
    "scr-immunoassay-presumptive": ("scr-immunoassay-drugs",
                                    "presumptive_nature", "screeningTest",
                                    "tox"),
    "scr-cross-reactivity": ("scr-immunoassay-drugs", "cross_reactivity",
                             "screeningTest", "tox"),
    "rea-marquis": ("reagent-marquis", "use_context", "reagent", "lab"),
    "rea-color-tests-presumptive": ("reagent-marquis", "test_class_limitation",
                                    "reagent", "lab"),
    "emg-nitazenes": ("emg-nitazenes", "summary", "emergingIssue", "tox"),
}

MD = "machine_draft"


def src_id(pmcid):
    return f"SRC-{pmcid}"


def build(accessed_fallback):
    # Faqat verify_excerpts.py tasdiqlagan (asl matnda aniq topilgan,
    # DOI mos, litsenziya API’dan) yozuvlar.
    cur = {d["substance"]: d for d in
           json.load(open("pilot/metabolites.verified.json"))
           if d["substance"] in CLAIM_TARGETS
           and d.get("verification") == "verified"}
    missing = set(CLAIM_TARGETS) - set(cur)
    assert not missing, f"tasdiqlanmagan: {missing}"
    gb = json.load(open("pilot/jurisdiction_gb.generated.json"))

    sources, claims, citations = [], [], []
    seen = set()
    for key, d in cur.items():
        assert d["license_mode"] == "openReuse", key
        sid = src_id(d["pmcid"])
        if sid not in seen:
            seen.add(sid)
            sources.append(dict(
                source_id=sid, source_type="journal_article",
                title=d["title"], journal=d["journal"],
                publication_year=int(d["year"]), doi=d["doi_api"],
                pmid=d.get("pmid"),
                official_url=f"https://pmc.ncbi.nlm.nih.gov/articles/"
                             f"{d['pmcid']}/",
                accessed_date=d.get("accessed", accessed_fallback),
                tier="tier2", evidence_level=LEVELS[d["pmcid"]],
                license_mode="openReuse", identifier_verified=True,
                notes=f"Litsenziya (PMC API): {d['license_api']}. Iqtibos PMC "
                      f"BioC asl matni bilan solishtirilgan: "
                      f"{d['match']['type']} ({d['match']['ratio']}). "
                      f"{d.get('note') or ''}".strip()))
        entity, field, etype, domain = CLAIM_TARGETS[key]
        cid = f"C-{entity.upper()}-{field.upper()}"
        claims.append(dict(
            claim_id=cid, entity_type=etype, entity_id=entity, field=field,
            domain=domain, declared_status="NEEDS_REVIEW",
            evidence_level=LEVELS[d["pmcid"]],
            layer="international_scientific", is_structured_value=False,
            value=dict(excerpt=d["source_sentence"], section=d["section"])))
        citations.append(dict(claim_id=cid, source_id=sid,
                              locator=d["section"]))

    def note(key):
        d = cur[key]
        return dict(text=d["source_sentence"], source_id=src_id(d["pmcid"]),
                    locator=d["section"])

    topics = [
        dict(topic_id="fm-livor-mortis", area="forensicMedicine",
             forensic_medicine_topic="livorMortis", tier_access="free",
             names={"en": "Livor mortis", "ru": "Трупные пятна",
                    "uz": "Murda dog‘lari (livor mortis)"}),
        dict(topic_id="fm-algor-mortis", area="forensicMedicine",
             forensic_medicine_topic="algorMortis",
             names={"en": "Algor mortis", "ru": "Охлаждение трупа",
                    "uz": "Murdaning sovishi (algor mortis)"}),
        dict(topic_id="fm-postmortem-interval", area="forensicMedicine",
             forensic_medicine_topic="postmortemInterval",
             names={"en": "Postmortem interval (PMI)",
                    "ru": "Давность наступления смерти",
                    "uz": "O‘limdan keyingi vaqt (PMI)"}),
        dict(topic_id="bio-vitreous-potassium", area="biochemistry",
             tier_access="free",
             names={"en": "Vitreous potassium and PMI",
                    "ru": "Калий стекловидного тела и давность смерти",
                    "uz": "Shishasimon tana kaliysi va PMI"}),
    ]
    methods = [dict(
        method_id="method-gcms", kind="scientificMethod",
        titles={"en": "Gas chromatography–mass spectrometry (GC-MS)",
                "ru": "Газовая хроматография — масс-спектрометрия (ГХ-МС)",
                "uz": "Gaz xromatografiyasi — mass-spektrometriya (GX-MS)"},
        techniques=["gcMs"], sections={}, text_origin="originalSummary",
        status="NEEDS_REVIEW", source_ids=[src_id("PMC11929145")],
        tier_access="free")]
    screening = [dict(
        screening_id="scr-immunoassay-drugs",
        names={"en": "Immunoassay drug screening",
               "ru": "Иммуноанализ (скрининг наркотиков)",
               "uz": "Immunoanaliz (giyohvand moddalar skriningi)"},
        # Manbada aniq analit/namuna ko‘rsatilmagan — taxmin qilinmaydi.
        analyte="drugs of abuse (class-based; see source)",
        specimen="not specified in source",
        principle="immunoassay",
        cross_reactivity=[note("scr-cross-reactivity")],
        false_positive=[note("scr-cross-reactivity")],
        limitations=[note("scr-immunoassay-presumptive")],
        confirmatory_method_ids=["method-gcms"],
        supports_definitive_identification=False,
        status="NEEDS_REVIEW",
        source_ids=[src_id("PMC11402778"), src_id("PMC2688477")],
        tier_access="free")]
    recipes = [dict(
        recipe_id="recipe-marquis", reagent_id="reagent-marquis",
        names={"en": "Marquis reagent", "ru": "Реактив Марки",
               "uz": "Marquis reaktivi"},
        domain="lab", status="NEEDS_REVIEW",
        # Tayyorlash ma’lumoti YO‘Q: ochiq manbada tasdiqlangan retsept
        # topilmadi — ingredient/miqdor/saqlash taxmin qilinmaydi.
        ingredients=[], steps=[], hazards=[],
        source_ids=[src_id("PMC11961553"), src_id("PMC5537996")],
        tier_access="free")]
    d = cur["emg-nitazenes"]
    emerging = [dict(
        issue_id="emg-nitazenes", category="syntheticOpioids",
        titles={"en": "Newly identified nitazene variants",
                "ru": "Новые варианты нитазенов",
                "uz": "Nitazenlarning yangi variantlari"},
        source_ids=[src_id(d["pmcid"])],
        # PubMed esummary epubdate (2025 May 13).
        date="2025-05-13", evidence_type="peerReviewed",
        # Oxirgi tekshiruv = manba jumlasi asl matn bilan solishtirilgan sana.
        last_checked=d.get("accessed"),
        status="NEEDS_REVIEW", tier_access="free")]

    # --- Jurisdiction Layer: Buyuk Britaniya (pilot) -----------------------
    rta, ssi = gb["rta"], gb["ssi"]
    acc = gb["accessed"]
    jurisdictions = [
        dict(jurisdiction_id="GB", level="country", parent_id="INT",
             iso3166="GB", names={"en": "United Kingdom",
                                  "ru": "Великобритания",
                                  "uz": "Buyuk Britaniya"}),
        dict(jurisdiction_id="GB-ENG", level="subdivision", parent_id="GB",
             iso3166="GB-ENG", names={"en": "England", "ru": "Англия",
                                      "uz": "Angliya"}),
        dict(jurisdiction_id="GB-WLS", level="subdivision", parent_id="GB",
             iso3166="GB-WLS", names={"en": "Wales", "ru": "Уэльс",
                                      "uz": "Uels"}),
        dict(jurisdiction_id="GB-SCT", level="subdivision", parent_id="GB",
             iso3166="GB-SCT", names={"en": "Scotland", "ru": "Шотландия",
                                      "uz": "Shotlandiya"}),
        dict(jurisdiction_id="GB-NIR", level="subdivision", parent_id="GB",
             iso3166="GB-NIR", names={"en": "Northern Ireland",
                                      "ru": "Северная Ирландия",
                                      "uz": "Shimoliy Irlandiya"}),
    ]
    authorities = [
        dict(authority_id="AUTH-GB-PARLIAMENT", jurisdiction_id="GB",
             names={"en": "Parliament of the United Kingdom"}),
        # SSI matnidagi so‘z: «The Scottish Ministers make the following
        # Regulations…».
        dict(authority_id="AUTH-GB-SCT-MINISTERS", jurisdiction_id="GB-SCT",
             names={"en": "The Scottish Ministers"}),
    ]
    ogl = ("Matn legislation.gov.uk dan (Open Government Licence v3.0). "
           "SHA-256: ")
    sources += [
        dict(source_id="SRC-GB-RTA-1988-S11", source_type="legislation",
             title="Road Traffic Act 1988, section 11 — Interpretation of "
                   "sections 4 to 10",
             organization="legislation.gov.uk (The National Archives)",
             official_url=rta["url"], accessed_date=acc, tier="tier1",
             evidence_level="A", license_mode="openReuse",
             identifier_verified=True,
             notes=ogl + rta["sha256"] + f". Matn holati: "
                   f"{rta['version_valid']}; bo‘lim hududi (extent): "
                   f"{rta['extents']}."),
        dict(source_id="SRC-GB-SSI-2014-328", source_type="legislation",
             title="The Road Traffic Act 1988 (Prescribed Limit) (Scotland) "
                   "Regulations 2014 (SSI 2014/328)",
             organization="legislation.gov.uk (The National Archives)",
             official_url=ssi["url"], accessed_date=acc, tier="tier1",
             evidence_level="A", license_mode="openReuse",
             identifier_verified=True,
             notes=ogl + ssi["sha256"] + f". Made: {ssi['made']}; "
                   f"in force: {ssi['in_force']}."),
    ]
    instruments = [
        dict(instrument_id="GB-RTA-1988-S11", jurisdiction_id="GB",
             instrument_type="law", authority_id="AUTH-GB-PARLIAMENT",
             titles={"en": "Road Traffic Act 1988, s. 11"},
             official_source_id="SRC-GB-RTA-1988-S11",
             official_reference="1988 c. 52, s. 11(2)",
             # legislation.gov.uk: shu bo‘lim matni versiyasining boshlanishi
             # (RestrictStartDate), qonun qabul qilingan sana emas.
             effective_from="2018-03-01", version="2018-03-01",
             last_verified_at=acc, legal_status="in_force", language="en",
             review_status="NEEDS_REVIEW", date_precision="day"),
        dict(instrument_id="GB-SCT-SSI-2014-328", jurisdiction_id="GB-SCT",
             instrument_type="regulation",
             authority_id="AUTH-GB-SCT-MINISTERS",
             titles={"en": "The Road Traffic Act 1988 (Prescribed Limit) "
                           "(Scotland) Regulations 2014"},
             official_source_id="SRC-GB-SSI-2014-328",
             official_reference=f"SSI 2014/328, reg. 2 (made {ssi['made']})",
             effective_from=ssi["in_force"], version=ssi["version_valid"],
             last_verified_at=acc, legal_status="in_force", language="en",
             review_status="NEEDS_REVIEW", date_precision="day"),
    ]

    def limits(x):
        return {k: dict(value=v["value"], unit=v["unit"])
                for k, v in x["limits"].items()}

    rta_excerpt = ("“the prescribed limit” means, as the case may require— "
                   "35 microgrammes of alcohol in 100 millilitres of breath, "
                   "80 milligrammes of alcohol in 100 millilitres of blood, "
                   "or 107 milligrammes of alcohol in 100 millilitres of "
                   "urine, or such other proportion as may be prescribed by "
                   "regulations")
    # Iqtibos asl matnda borligini tekshirish (bo‘shliqlar normallashtirilgan).
    norm = lambda s: " ".join(s.replace("“", "").replace("”", "").split())
    assert norm(rta_excerpt.replace("“the prescribed limit” ", "")) in \
        norm(rta["excerpt"]), "RTA excerpt mismatch"
    ssi_excerpt = ssi["excerpt"].split(" Proportion of alcohol for")[0]
    ssi_excerpt = ssi_excerpt.replace("Prescription of proportion of "
                                      "alcohol 2 ", "")
    rules = [
        dict(rule_id="R-GB-ETHANOL-DRINK-DRIVE-LIMIT",
             instrument_id="GB-RTA-1988-S11", rule_type="legal_threshold",
             subject_type="substance", subject_id="ethanol",
             topic_key="drink_drive.prescribed_limit",
             applies_to=["GB-ENG", "GB-WLS", "GB-SCT"],
             article_section="s. 11(2)",
             value=dict(limits=limits(rta), excerpt=rta_excerpt,
                        extent=rta["extents"]),
             effective_from="2018-03-01", review_status="NEEDS_REVIEW"),
        dict(rule_id="R-GB-SCT-ETHANOL-DRINK-DRIVE-LIMIT",
             instrument_id="GB-SCT-SSI-2014-328", rule_type="legal_threshold",
             subject_type="substance", subject_id="ethanol",
             topic_key="drink_drive.prescribed_limit",
             article_section="reg. 2",
             value=dict(limits=limits(ssi), excerpt=ssi_excerpt),
             effective_from=ssi["in_force"], review_status="NEEDS_REVIEW"),
    ]
    return dict(sources=sources, claims=claims, citations=citations,
                topics=topics, methods=methods, screening_tests=screening,
                recipes=recipes, emerging_issues=emerging,
                jurisdictions=jurisdictions, authorities=authorities,
                instruments=instruments, rules=rules)
