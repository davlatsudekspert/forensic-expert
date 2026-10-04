#!/usr/bin/env python3
"""Mavzular uchun ochiq litsenziyali (CC BY / CC0 / PD) PMC maqolalaridan
shartga mos gapni ASL MATNDAN ajratib oladi (nomzod; keyin
verify_excerpts.py va reviewer tekshiradi).

* Qidiruv: NCBI E-utilities (esearch, db=pmc, open access filter).
* Matn va litsenziya: PMC BioC API.
* Gap faqat barcha regex shartlari bajarilsa olinadi. Hech narsa
  qo‘lda yozilmaydi yoki parafraz qilinmaydi.

Chiqish: pilot/candidates/topics_<group>.json
"""
import json, re, sys, time, urllib.parse, urllib.request

ESEARCH = ("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pmc"
           "&retmode=json&retmax={n}&sort=relevance&term={q}")
ESUMMARY = ("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi"
            "?db=pmc&retmode=json&id={ids}")
BIOC = ("https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/"
        "BioC_json/PMC{pmc}/unicode")
OPEN = ("cc by", "cc0", "cc-by", "publicdomain", "public domain")
# Odam sud tibbiyotiga taalluqli bo‘lmagan maqolalar (sarlavha bo‘yicha).
EXCLUDE_TITLE = re.compile(
    r"\b(fish|carp|salmon|cattle|bovine|porcine|pig|piglet|rat|rats|mice|"
    r"mouse|poultry|chicken|horse|dog|cat|insect|SARS-CoV-2)\b", re.I)

# (topic, field, group, query, [regex…], key_terms_regex)
TOPICS = [
    ("fm-livor-mortis", "definition", "fm",
     '"livor mortis"[Title/Abstract]',
     [r"livor mortis", r"gravit|settl|pool|hypostas"]),
    ("fm-rigor-mortis", "definition", "fm",
     '"rigor mortis"[Title/Abstract] AND (forensic OR autopsy OR "time since death")',
     [r"rigor mortis", r"stiffening|stiffness|rigidity", r"after death|post-?mortem|death"]),
    ("fm-algor-mortis", "definition", "fm",
     '"algor mortis"[Title/Abstract] OR "body cooling"[Title/Abstract] AND death',
     [r"algor mortis|body cooling|cooling of the body", r"temperature|cool"]),
    ("fm-pmi-uncertainty", "limitation", "fm",
     '"postmortem interval"[Title] AND estimation AND (review[Title] OR forensic[Title])',
     [r"post-?mortem interval|PMI",
      r"(many|several|numerous|various|multiple) (intrinsic |extrinsic |environmental )?factors|uncertaint"]),
    ("bio-vitreous-potassium", "marker", "bio",
     'vitreous potassium "postmortem interval"',
     [r"potassium", r"vitreous", r"post-?mortem interval|PMI|time since death",
      r"increas|rise|rising|linear"]),
    ("bio-postmortem-limits", "limitation", "bio",
     '"postmortem biochemistry"[Title/Abstract]',
     [r"post-?mortem", r"biochem", r"limit|challeng|confound|difficult|caution"]),
    ("scr-immunoassay-presumptive", "principle", "scr",
     'immunoassay screening confirmation "forensic toxicology"',
     [r"immunoassay", r"presumptive|preliminary", r"confirm"]),
    ("scr-cross-reactivity", "limitation", "scr",
     'immunoassay "cross-reactivity" "false positive" drugs',
     [r"cross-?reactiv", r"false[- ]positive"]),
    ("met-gcms", "principle", "met",
     '"gas chromatography-mass spectrometry" "forensic toxicology" confirmation',
     [r"GC[-–]MS|gas chromatography[-–‐ ]mass spectrometry",
      r"(is|are|remains|considered|regarded)\s+(as\s+)?(the\s+)?(gold standard|reference method|method of choice|confirmat)"]),
    ("met-lcmsms", "principle", "met",
     '"LC-MS/MS" "forensic toxicology"',
     [r"LC[-–]MS/MS|liquid chromatography[-–‐ ]tandem mass spectrometry",
      r"(is|has become|offers|provides|allows|enables)\b", r"toxicolog"]),
    ("rea-marquis", "principle", "rea",
     '"Marquis reagent"',
     [r"Marquis (reagent|test)", r"colou?r (test|change|reaction)|presumptive"]),
    ("rea-color-tests-presumptive", "limitation", "rea",
     '"color test" OR "colour test" OR "spot test" presumptive drugs',
     [r"colou?r tests?|spot tests?", r"presumptive|false[- ]positive"]),
    ("bio-vitreous-confounding", "limitation", "bio",
     'vitreous potassium "postmortem interval" temperature',
     [r"vitreous potassium", r"confounding factor"]),
    ("emg-nitazenes", "emerging", "emg",
     'nitazenes',
     [r"nitazene", r"emerg|novel|new"]),
]


def get(url, attempts=5):
    for i in range(attempts):
        try:
            with urllib.request.urlopen(url, timeout=60) as r:
                return json.load(r)
        except urllib.error.HTTPError as e:
            if e.code != 429 or i == attempts - 1:
                raise
            time.sleep(2 ** (i + 1))


def sentences(text):
    return re.split(r"(?<=[.!?])\s+(?=[A-Z0-9α-ω])", text)


def main():
    group = sys.argv[1] if len(sys.argv) > 1 else None
    out = []
    for topic, field, grp, query, pats in TOPICS:
        if group and grp != group:
            continue
        q = urllib.parse.quote(f"({query}) AND open access[filter]")
        ids = get(ESEARCH.format(n=40, q=q))["esearchresult"]["idlist"]
        found = None
        for pmc in ids:
            time.sleep(0.4)
            try:
                data = get(BIOC.format(pmc=pmc))
            except Exception:  # noqa: BLE001
                continue
            coll = data[0] if isinstance(data, list) else data
            doc = coll["documents"][0]
            lic = (doc.get("infons", {}).get("license") or "")
            if not any(o in lic.lower() for o in OPEN) or "nc" in lic.lower():
                continue
            title = next((p.get("text", "") for p in doc["passages"]
                          if p.get("infons", {}).get("type") == "front"), "")
            if EXCLUDE_TITLE.search(title):
                continue
            for p in doc["passages"]:
                inf = p.get("infons", {})
                if inf.get("type") not in ("paragraph", "abstract"):
                    continue
                # Metodlar bo‘limi — mualliflarning qidiruv/kiritish mezonlari.
                if inf.get("section_type") in ("METHODS", "SUPPL", "REF"):
                    continue
                for s in sentences(p.get("text", "")):
                    if 40 <= len(s) <= 320 and all(
                            re.search(x, s, re.I) for x in pats):
                        found = dict(
                            topic=topic, field=field, group=grp, status="found",
                            pmcid=f"PMC{pmc}", license=lic,
                            section=inf.get("section_type", ""),
                            title=title, verbatim_sentence=s.strip(),
                            key_terms=[re.search(x, s, re.I).group(0)
                                       for x in pats[:2]])
                        break
                if found:
                    break
            if found:
                break
        out.append(found or dict(topic=topic, field=field, group=grp,
                                 status="not_found"))
        print(topic, "→", found["pmcid"] if found else "not_found", flush=True)
    name = f"pilot/candidates/topics_{group or 'all'}.json"
    json.dump(out, open(name, "w"), ensure_ascii=False, indent=2)


if __name__ == "__main__":
    main()
