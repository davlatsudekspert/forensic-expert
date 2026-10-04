#!/usr/bin/env python3
"""PHASE 8: kam qamralgan fanlar (DNK, entomologiya, mikrobiologiya,
radiologiya, sifat menejmenti, farmakologiya) uchun ochiq litsenziyali PMC
maqolalaridan shartga mos gapni ASL MATNDAN ajratadi.

`tools/p7/find_p7_sentences.py` bilan bir xil qoidalar: CC BY/CC0/PD,
NC yo‘q, hayvon sarlavhalari yo‘q, retraksiya qilingan PMID’lar chiqarib
tashlanadi; metadata NCBI esummary’dan. Nomzodlar — reviewer tekshiradi.
Chiqish: phase8/candidates_p8.json
"""
import json, re, sys, time, urllib.parse

sys.path.insert(0, "tools")
import find_oa_sentences as f  # noqa: E402

RETRACTED = set(json.load(open("phase7/retraction_check.json"))["retracted"])

TOPICS = [
    ("gen-str-profiling", "principle", "forensic_genetics",
     '"short tandem repeat" forensic DNA profiling[Title/Abstract]',
     [r"short tandem repeats?|\bSTRs?\b", r"forensic", r"identif|profil|individual"]),
    ("gen-str-profiling", "limitation", "forensic_genetics",
     'forensic DNA degraded "low template" STR',
     [r"degrad|low[- ]template|inhibit", r"\bDNA\b", r"profil|STR|amplif"]),
    ("ent-pmi-insects", "principle", "forensic_entomology",
     '"forensic entomology"[Title/Abstract] postmortem interval',
     [r"entomolog|insect|blow ?fl|larva", r"post-?mortem interval|PMI|time since death"]),
    ("ent-pmi-insects", "limitation", "forensic_entomology",
     '"forensic entomology"[Title/Abstract] temperature development',
     [r"temperature", r"development|growth", r"larva|insect|fl(y|ies)"]),
    ("mic-thanatomicrobiome", "principle", "forensic_microbiology",
     'thanatomicrobiome[Title/Abstract]',
     [r"thanatomicrobiome|post-?mortem microbio|microbial communit", r"death|post-?mortem|decomposition"]),
    ("rad-pmct", "principle", "forensic_radiology",
     '"postmortem computed tomography"[Title/Abstract] autopsy',
     [r"post-?mortem computed tomography|PMCT", r"autopsy|forensic"]),
    ("rad-pmct", "limitation", "forensic_radiology",
     '"postmortem computed tomography"[Title/Abstract] limitation',
     [r"PMCT|post-?mortem computed tomography|post-?mortem CT", r"limit|cannot|not (be )?detect|miss|lower sensitivity"]),
    ("qa-accreditation", "principle", "laboratory_quality",
     '"ISO/IEC 17025" forensic laboratory accreditation',
     [r"17025", r"accredit", r"laborator"]),
    ("pharm-pmr", "principle", "forensic_toxicology",
     '"postmortem redistribution"[Title/Abstract] lipophilic volume of distribution',
     [r"post-?mortem redistribution|PMR", r"lipophil|volume of distribution|Vd"]),
]


def main():
    out = []
    for topic, field, disc, query, pats in TOPICS:
        q = urllib.parse.quote(f"({query}) AND open access[filter]")
        ids = f.get(f.ESEARCH.format(n=40, q=q))["esearchresult"]["idlist"]
        found = None
        for pmc in ids:
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
                        found = dict(topic=topic, field=field, discipline=disc, status="found",
                                     pmcid=f"PMC{pmc}", license=lic,
                                     section=inf.get("section_type", ""),
                                     title=title, verbatim_sentence=s.strip())
                        break
                if found:
                    break
            if found:
                time.sleep(0.4)
                summ = f.get(f.ESUMMARY.format(ids=pmc))["result"][pmc]
                art = {i["idtype"]: i["value"] for i in summ.get("articleids", [])}
                if art.get("pmid") in RETRACTED:
                    found = None
                    continue
                found.update(journal=summ.get("fulljournalname") or summ.get("source"),
                             year=(summ.get("pubdate") or "")[:4],
                             doi=art.get("doi"), pmid=art.get("pmid"))
                break
        out.append(found or dict(topic=topic, field=field, discipline=disc, status="not_found"))
        print(topic, field, "→", (found["pmcid"], found.get("pmid")) if found else "not_found", flush=True)
    json.dump(out, open("phase8/candidates_p8.json", "w"), ensure_ascii=False, indent=2)


if __name__ == "__main__":
    main()
