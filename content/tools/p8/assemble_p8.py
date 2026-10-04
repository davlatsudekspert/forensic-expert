#!/usr/bin/env python3
"""PHASE 8: kam qamralgan fanlar uchun manbali mavzular (PMC OA asl matn).

Qabul/rad qarorlari sabab bilan `phase8/curation_p8.json` ga yoziladi.
Har bir claim NEEDS_REVIEW; mavzu yozuvi — faqat taksonomiya (nom + fan).
"""
import json

TODAY = "2026-10-04"

TOPICS = {
    "gen-str-profiling": dict(area="laboratory", discipline="forensic_genetics",
                              names=dict(en="DNA profiling (STR)", ru="ДНК-профилирование (STR)", uz="DNK profillash (STR)")),
    "ent-pmi-insects": dict(area="forensicMedicine", discipline="forensic_entomology",
                            names=dict(en="Forensic entomology and PMI", ru="Судебная энтомология и давность смерти",
                                       uz="Sud entomologiyasi va o‘lim vaqti")),
    "mic-thanatomicrobiome": dict(area="forensicMedicine", discipline="forensic_microbiology",
                                  names=dict(en="Thanatomicrobiome", ru="Танатомикробиом", uz="Tanatomikrobiom")),
    "rad-pmct": dict(area="forensicMedicine", discipline="forensic_radiology",
                     forensic_medicine_topic="postmortemImaging",
                     names=dict(en="Post-mortem CT (PMCT)", ru="Посмертная КТ (ПМКТ)", uz="O‘limdan keyingi KT (PMCT)")),
    "tox-postmortem-redistribution": dict(area="toxicology", discipline="forensic_toxicology",
                                          names=dict(en="Post-mortem redistribution", ru="Посмертное перераспределение",
                                                     uz="O‘limdan keyingi qayta taqsimlanish")),
}

# (topic, field-in-candidates) → (claim field, domain); None = rad etilgan.
DECISIONS = {
    ("gen-str-profiling", "principle"): ("principle", "lab", None),
    ("gen-str-profiling", "limitation"): ("limitation", "lab", None),
    ("ent-pmi-insects", "principle"): ("principle", "fm", None),
    ("ent-pmi-insects", "limitation"): ("principle_temperature", "fm",
        "Field renamed: the sentence states the temperature–development relationship (a principle), not a limitation."),
    ("mic-thanatomicrobiome", "principle"): ("principle", "fm", None),
    ("rad-pmct", "principle"): None,
    ("rad-pmct", "limitation"): ("application", "fm",
        "Field renamed: the sentence describes a capability of PMCT, not a limitation."),
    ("qa-accreditation", "principle"): None,
    ("pharm-pmr", "principle"): ("principle", "tox", None),
}
REJECT_REASON = {
    ("rad-pmct", "principle"): "Methods-type sentence (lists procedures performed); no statement about PMCT.",
    ("qa-accreditation", "principle"): "Describes one laboratory's accreditation; not a general statement.",
}
TOPIC_OF = {"pharm-pmr": "tox-postmortem-redistribution"}
LINKS = [  # editorial taksonomiya bog‘lanishlari (alohida belgilangan)
    ("rad-pmct", "fm-postmortem-changes"),
    ("ent-pmi-insects", "fm-postmortem-interval"),
    ("mic-thanatomicrobiome", "fm-postmortem-interval"),
    ("mic-thanatomicrobiome", "fm-decomposition"),
    ("tox-postmortem-redistribution", "bio-sampling-site"),
]


def apply(b):
    cands = json.load(open("phase8/candidates_p8.json"))
    have_src = {s["source_id"] for s in b["sources"]}
    have_topics = {t["topic_id"] for t in b["topics"]}
    accepted, rejected = [], []
    for c in cands:
        key = (c["topic"], c["field"])
        dec = DECISIONS.get(key)
        if c["status"] != "found" or dec is None:
            rejected.append(dict(topic=c["topic"], field=c["field"], pmcid=c.get("pmcid"),
                                 reason=REJECT_REASON.get(key, "not found")))
            continue
        field, domain, note = dec
        tid = TOPIC_OF.get(c["topic"], c["topic"])
        if tid not in have_topics:
            t = TOPICS[tid]
            b["topics"].append(dict(topic_id=tid, area=t["area"], names=t["names"],
                                    discipline=t["discipline"], tier_access="pro",
                                    **({"forensic_medicine_topic": t["forensic_medicine_topic"]}
                                       if "forensic_medicine_topic" in t else {})))
            have_topics.add(tid)
        sid = f"SRC-{c['pmcid']}"
        if sid not in have_src:
            b["sources"].append(dict(
                source_id=sid, source_type="journal_article", title=c["title"],
                journal=c["journal"], publication_year=int(c["year"]), doi=c["doi"], pmid=c["pmid"],
                official_url=f"https://pmc.ncbi.nlm.nih.gov/articles/{c['pmcid']}/",
                accessed_date=TODAY, tier="tier2", evidence_level="B", license_mode="openReuse",
                identifier_verified=True, lifecycle="current", lifecycle_checked_at=TODAY,
                lifecycle_basis="Excluded retracted PMIDs at selection (PubMed check).", language="en",
                notes=f"Litsenziya (PMC BioC): {c['license']}. Iqtibos asl matndan dasturiy ajratilgan (find_p8_sentences.py). PHASE 8."))
            have_src.add(sid)
        cid = f"C-{tid.upper()}-{field.upper()}-P8"
        b["claims"].append(dict(claim_id=cid, entity_type="topic", entity_id=tid, field=field,
                                domain=domain, declared_status="NEEDS_REVIEW", evidence_level="B",
                                layer="international_scientific", is_structured_value=False,
                                value=dict(excerpt=c["verbatim_sentence"], section=c["section"])))
        b["citations"].append(dict(claim_id=cid, source_id=sid, locator=c["section"]))
        accepted.append(dict(claim_id=cid, pmcid=c["pmcid"], note=note))
    for a, z in LINKS:
        if a in have_topics and z in have_topics:
            b["links"].append({"from": a, "to": z, "relation": "related_topic", "basis": "editorial:taxonomy"})
    json.dump(dict(curated_at=TODAY, curator="pipeline (Claude) — NOT a human reviewer",
                   accepted=accepted, rejected=rejected),
              open("phase8/curation_p8.json", "w"), ensure_ascii=False, indent=2)
    return dict(accepted=len(accepted), rejected=len(rejected),
                topics=len([t for t in TOPICS if t in have_topics]))
