#!/usr/bin/env python3
"""Tekshirilgan ma’lumotlardan pilot kontent to‘plamini yig‘adi.

Kirish (barchasi real so‘rov/tekshiruv natijasi):
  pilot/identity.generated.json            — PubChem
  pilot/international_control.generated.json — INCB Yellow/Green List
  pilot/metabolites.verified.json          — PMC asl matn bilan tasdiqlangan
  pilot/names_i18n.json                    — nomlar (machine_draft)
  pilot/evidence_levels.json               — dastlabki dalil darajasi
Chiqish: pilot/bundle.json  (fe_content_schema `BundleCodec` formati)

Qoidalar:
* Har bir claim `NEEDS_REVIEW`. Review yozuvi yo‘q — VERIFIED bo‘lishi
  mumkin emas (StatusResolver + validator FE002).
* Faqat `verification == verified` iqtiboslar claim’ga aylanadi.
* Iqtibos matni faqat ochiq litsenziyada (CC BY / CC0 / public domain)
  ilovaga kiritiladi; aks holda faqat havola va bo‘lim.
* Huquqiy ma’lumot ilmiy claim emas: INCB jadvallari — Jurisdiction Layer
  (INT) qoidalari, ilmiy qatlamdan alohida.
"""
import datetime, json

import assemble_p4

FREE_DEMO = ["ethanol", "methanol", "carbon-monoxide"]  # 3 ta yozuv
PACK_VERSION = "2026.10.2"
# Komponent versiyalari (ilova versiyasidan alohida).
COMPONENT_VERSIONS = {"scientific": "2026.10.2", "jurisdiction": "2026.10.2"}


def main():
    ident = json.load(open("pilot/identity.generated.json"))
    ctrl = json.load(open("pilot/international_control.generated.json"))
    mets = json.load(open("pilot/metabolites.verified.json"))
    names = json.load(open("pilot/names_i18n.json"))
    levels = json.load(open("pilot/evidence_levels.json"))
    today = datetime.date.today().isoformat()

    sources, claims, citations, substances = [], [], [], []
    rules, instruments = [], []

    for r in ident:
        sid = r["substance_id"]
        n = names[sid]
        src_id = f"SRC-PUBCHEM-{r['pubchem_cid']}"
        sources.append(dict(
            source_id=src_id, source_type="database",
            title=f"PubChem Compound Summary for CID {r['pubchem_cid']} "
                  f"({r['iupac_name']})",
            organization="National Center for Biotechnology Information "
                         "(NCBI), U.S. National Library of Medicine",
            official_url=r["source_url"], accessed_date=r["accessed"],
            tier="tier2", evidence_level="C", license_mode="openReuse",
            identifier_verified=True,
            notes="Identifikatorlar PubChem PUG REST orqali avtomatik olingan. "
                  "Litsenziya: PubChem hisoblangan xossalari — legal reviewer "
                  "tasdig‘i kerak."))
        claims.append(dict(
            claim_id=f"C-{sid.upper()}-IDENTITY", entity_type="substance",
            entity_id=sid, field="identity", domain="tox",
            declared_status="NEEDS_REVIEW", evidence_level="C",
            layer="international_scientific", is_structured_value=True,
            value=dict(pubchem_cid=r["pubchem_cid"],
                       molecular_formula=r["molecular_formula"],
                       molecular_weight=r["molecular_weight"],
                       inchikey=r["inchikey"], iupac_name=r["iupac_name"])))
        citations.append(dict(claim_id=claims[-1]["claim_id"],
                              source_id=src_id, locator="Computed Properties"))
        substances.append(dict(
            substance_id=sid, canonical_name=n["en"].lower(),
            entity_kind=n["kind"], molecular_formula=r["molecular_formula"],
            tier_access="free" if sid in FREE_DEMO else "pro",
            names={k: n[k] for k in ("en", "ru", "uz")},
            translation_status={k: "machine_draft" for k in ("en", "ru", "uz")},
            synonyms=r.get("synonyms_verified", [])))

    for m in mets:
        if m.get("verification") != "verified":
            continue
        if m["substance"] in assemble_p4.CLAIM_TARGETS:
            continue  # PHASE 4 bilim obyektlari — assemble_p4.py
        sid = m["substance"]
        src_id = f"SRC-{m['pmcid']}"
        open_text = m["license_mode"] == "openReuse"
        sources.append(dict(
            source_id=src_id, source_type="journal_article", title=m["title"],
            journal=m["journal"], publication_year=int(m["year"]),
            doi=m["doi_api"], pmid=m["pmid"],
            official_url=f"https://pmc.ncbi.nlm.nih.gov/articles/{m['pmcid']}/",
            accessed_date=m["accessed"], tier="tier2",
            evidence_level=levels[m["pmcid"]],
            license_mode=m["license_mode"], identifier_verified=True,
            notes=f"Litsenziya (PMC API): {m.get('license_api')}. "
                  f"Iqtibos asl matn bilan solishtirilgan: {m['match']['type']} "
                  f"({m['match']['ratio']}). " + (m.get("note") or "")))
        field = m.get("field", "metabolites")
        cid = f"C-{sid.upper()}-{field.upper()}"
        value = dict(items=m["metabolites"], section=m["section"])
        if open_text:
            value["excerpt"] = m["source_sentence"]
        claims.append(dict(
            claim_id=cid, entity_type="substance", entity_id=sid, field=field,
            domain="tox", declared_status="NEEDS_REVIEW",
            evidence_level=levels[m["pmcid"]],
            layer="international_scientific", is_structured_value=False,
            value=value))
        citations.append(dict(claim_id=cid, source_id=src_id,
                              locator=m["section"]))

    # --- Jurisdiction Layer (INT): INCB rasmiy ro‘yxatlari ----------------
    lists = {
        "yellow": dict(
            source_id="SRC-INCB-YELLOW-LIST-65", instrument_id="INT-INCB-YL-65",
            title="List of Narcotic Drugs under International Control "
                  "(Yellow List), 65th edition",
            convention="Single Convention on Narcotic Drugs, 1961",
            edition="65th edition, July 2026", effective_from="2026-07-01",
            date_precision="month"),
        "green": dict(
            source_id="SRC-INCB-GREEN-LIST-36", instrument_id="INT-INCB-GL-36",
            title="List of Psychotropic Substances under International "
                  "Control (Green List), 36th edition",
            convention="Convention on Psychotropic Substances of 1971",
            edition="36th edition, 2025", effective_from="2025-01-01",
            date_precision="year"),
    }
    seen = set()
    for c in ctrl:
        if c["status"] != "found":
            continue
        L = lists[c["list"]]
        if c["list"] not in seen:
            seen.add(c["list"])
            sources.append(dict(
                source_id=L["source_id"], source_type="legislation",
                title=L["title"], organization="International Narcotics "
                "Control Board (INCB)", edition=L["edition"],
                official_url=c["source_url"], accessed_date=c["accessed"],
                tier="tier1", evidence_level="A", license_mode="citeOnly",
                identifier_verified=True,
                notes=f"PDF SHA-256: {c['source_sha256']}"))
            instruments.append(dict(
                instrument_id=L["instrument_id"], jurisdiction_id="INT",
                instrument_type="controlled_substance_schedule",
                titles={"en": L["title"]}, official_source_id=L["source_id"],
                official_reference=f"{L['convention']} — {L['edition']}",
                effective_from=L["effective_from"], version=L["edition"],
                last_verified_at=c["accessed"], review_status="NEEDS_REVIEW",
                date_precision=L["date_precision"]))
        rules.append(dict(
            rule_id=f"R-INT-{c['substance_id'].upper()}-{c['list'].upper()}",
            instrument_id=L["instrument_id"], rule_type="control_status",
            subject_type="substance", subject_id=c["substance_id"],
            value=dict(convention=L["convention"], schedules=c["schedules"],
                       ids_code=c["ids_code"],
                       rows=[x["text"] for x in c["rows"]]),
            effective_from=L["effective_from"], review_status="NEEDS_REVIEW"))

    p4 = assemble_p4.build(today)
    sources += p4["sources"]
    claims += p4["claims"]
    citations += p4["citations"]
    instruments += p4["instruments"]
    rules += p4["rules"]

    bundle = dict(
        format="fe-bundle/2", pack_version=PACK_VERSION, channel="development",
        component_versions=COMPONENT_VERSIONS,
        assembled_at=today,
        jurisdictions=[dict(jurisdiction_id="INT", level="international",
                            names={"en": "International"})]
        + p4["jurisdictions"],
        authorities=p4["authorities"],
        sources=sources, substances=substances, claims=claims,
        citations=citations, instruments=instruments, rules=rules,
        topics=p4["topics"], methods=p4["methods"],
        screening_tests=p4["screening_tests"], recipes=p4["recipes"],
        emerging_issues=p4["emerging_issues"],
        reviewers=[], reviews=[])
    json.dump(bundle, open("pilot/bundle.json", "w"), ensure_ascii=False,
              indent=2)
    print(f"substances={len(substances)} claims={len(claims)} "
          f"sources={len(sources)} instruments={len(instruments)} "
          f"rules={len(rules)} topics={len(p4['topics'])} "
          f"knowledge={sum(len(p4[k]) for k in ('methods', 'screening_tests', 'recipes', 'emerging_issues'))}")


if __name__ == "__main__":
    main()
