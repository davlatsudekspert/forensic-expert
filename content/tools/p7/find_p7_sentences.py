#!/usr/bin/env python3
"""PHASE 7: namuna va FM pilotlari uchun ochiq litsenziyali (CC BY / CC0 /
PD) PMC maqolalaridan shartga mos gapni ASL MATNDAN ajratadi.

`tools/find_oa_sentences.py` mantig‘i qayta ishlatiladi. Qo‘shimcha:
* retraksiya qilingan PMID’lar (`phase7/retraction_check.json`) va
  ularning PMC nusxalari chiqarib tashlanadi;
* tanlangan maqolaning metama’lumoti (DOI, PMID, jurnal, yil) NCBI
  esummary’dan olinadi — qo‘lda yozilmaydi.

Chiqish: phase7/candidates_p7.json (nomzodlar; reviewer tekshiradi).
"""
import json, re, sys, time, urllib.parse

sys.path.insert(0, "tools")
import find_oa_sentences as f  # noqa: E402

EXCLUDE_PMC = {"PMC11580817"}  # retracted (PMID 39575351)

# 1-urinish rad etilgan nomzodlar uchun aniqroq shartlar (sabablar:
# phase7/curation_p7.json).
RETRY = [
    ("fm-rigor-mortis", "definition", "fm",
     '"rigor mortis"[Title/Abstract] AND (forensic OR "postmortem interval")',
     [r"^Rigor mortis\b", r"muscl", r"stiff|rigid", r"death|post-?mortem"]),
    ("blood", "specimen_note", "spec",
     '"postmortem redistribution"[Title/Abstract]',
     [r"post-?mortem redistribution", r"(refers to|describes|is the|is a|defined as)",
      r"(release|diffus|movement|redistribut|change)"]),
    ("liver", "specimen_note", "spec",
     'liver[Title/Abstract] AND postmortem AND toxicology AND (drug OR xenobiotic)',
     [r"\bliver\b", r"(drug|toxicolog|xenobiotic)", r"(useful|valuable|alternative|less (susceptible|affected)|redistribution)"]),
    ("gastric", "specimen_note", "spec",
     '"gastric content"[Title/Abstract] AND (toxicology OR poisoning)',
     [r"gastric contents?", r"(oral|ingest)", r"(indicat|suggest|evidence|route|recent)"]),
]

TOPICS = [
    ("fm-rigor-mortis", "definition", "fm",
     '"rigor mortis"[Title/Abstract] AND (forensic OR autopsy OR "time since death")',
     [r"rigor mortis", r"stiffening|stiffness|rigidity", r"after death|post-?mortem|death"]),
    ("fm-algor-mortis", "definition", "fm",
     '("algor mortis"[Title/Abstract] OR "body cooling"[Title/Abstract]) AND death',
     [r"algor mortis|body cooling|cooling of the body", r"temperature|cool", r"ambient|environment|surround"]),
    ("oral-fluid", "specimen_note", "spec",
     '"oral fluid"[Title] AND drug AND (forensic OR toxicology)',
     [r"oral fluid", r"non-?invasive|easy to collect|ease of collection|observed collection|supervised"]),
    ("hair", "specimen_note", "spec",
     '"hair analysis"[Title/Abstract] AND (forensic OR toxicology)',
     [r"\bhair\b", r"(long|wide|extended|longer|larger|retrospective)\s+(detection\s+)?window|window of detection|months"]),
    ("vitreous", "specimen_note", "spec",
     '"vitreous humor"[Title/Abstract] AND toxicology AND postmortem',
     [r"vitreous", r"(isolated|protected|less (susceptible|prone|affected)|putrefaction|contamination|redistribution)"]),
    ("bile", "specimen_note", "spec",
     'bile[Title/Abstract] AND postmortem AND toxicology',
     [r"\bbile\b", r"specimen|matrix|sample", r"(accumulat|concentrat|alternative|useful)"]),
    ("urine", "specimen_note", "spec",
     'urine[Title/Abstract] AND "detection window" AND drugs',
     [r"\burine\b", r"detection window|window of detection|detection times?"]),
    ("blood", "specimen_note", "spec",
     '"postmortem redistribution"[Title/Abstract]',
     [r"post-?mortem redistribution", r"femoral|peripheral", r"central|cardiac|heart"]),
    ("liver", "specimen_note", "spec",
     'liver[Title/Abstract] AND "postmortem" AND toxicology AND specimen',
     [r"\bliver\b", r"post-?mortem|autopsy", r"alternative|useful|valuable|specimen|matrix"]),
    ("gastric", "specimen_note", "spec",
     '"gastric content"[Title/Abstract] AND toxicology',
     [r"gastric contents?", r"ingest|oral|route|recent|unabsorbed"]),
]


def main():
    retry = len(sys.argv) > 1 and sys.argv[1] == "--retry"
    out = []
    for topic, field, grp, query, pats in (RETRY if retry else TOPICS):
        q = urllib.parse.quote(f"({query}) AND open access[filter]")
        ids = f.get(f.ESEARCH.format(n=40, q=q))["esearchresult"]["idlist"]
        found = None
        for pmc in ids:
            if f"PMC{pmc}" in EXCLUDE_PMC:
                continue
            time.sleep(0.4)
            try:
                data = f.get(f.BIOC.format(pmc=pmc))
            except Exception:  # noqa: BLE001
                continue
            coll = data[0] if isinstance(data, list) else data
            doc = coll["documents"][0]
            lic = (doc.get("infons", {}).get("license") or "")
            if not any(o in lic.lower() for o in f.OPEN) or "nc" in lic.lower():
                continue
            title = next((p.get("text", "") for p in doc["passages"]
                          if p.get("infons", {}).get("type") == "front"), "")
            if f.EXCLUDE_TITLE.search(title):
                continue
            for p in doc["passages"]:
                inf = p.get("infons", {})
                if inf.get("type") not in ("paragraph", "abstract"):
                    continue
                if inf.get("section_type") in ("METHODS", "SUPPL", "REF"):
                    continue
                for s in f.sentences(p.get("text", "")):
                    if 40 <= len(s) <= 320 and all(re.search(x, s, re.I) for x in pats):
                        found = dict(topic=topic, field=field, group=grp, status="found",
                                     pmcid=f"PMC{pmc}", license=lic,
                                     section=inf.get("section_type", ""),
                                     title=title, verbatim_sentence=s.strip())
                        break
                if found:
                    break
            if found:
                break
        if found:
            time.sleep(0.4)
            summ = f.get(f.ESUMMARY.format(ids=found["pmcid"][3:]))["result"][found["pmcid"][3:]]
            art = {i["idtype"]: i["value"] for i in summ.get("articleids", [])}
            found.update(journal=summ.get("fulljournalname") or summ.get("source"),
                         year=(summ.get("pubdate") or "")[:4],
                         doi=art.get("doi"), pmid=art.get("pmid"))
        out.append(found or dict(topic=topic, field=field, group=grp, status="not_found"))
        print(topic, "→", (found["pmcid"], found["pmid"]) if found else "not_found", flush=True)
    name = "phase7/candidates_p7_retry.json" if retry else "phase7/candidates_p7.json"
    json.dump(out, open(name, "w"), ensure_ascii=False, indent=2)


if __name__ == "__main__":
    main()
