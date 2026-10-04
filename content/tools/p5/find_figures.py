#!/usr/bin/env python3
"""CC BY PMC maqolalaridan GRAPHIC BO‘LMAGAN ilmiy rasm nomzodlari.

* Faqat CC BY / CC0 (NC emas) — BioC litsenziyasi.
* Tasvir matni (caption) bo‘yicha tur: xromatogramma, mass-spektr,
  gistologik mikrofoto (H&E va boshqalar).
* Tana, yuz, jarohat, autopsiya fotosi va h.k. — RAD (default UI’da
  graphic rasm yo‘q).
Chiqish: phase5/figure_candidates.json (keyin qo‘lda tanlanadi).
"""
import json, re, sys, time, urllib.parse

sys.path.insert(0, __file__.rsplit("/", 1)[0])
from fehttp import get  # noqa: E402

GRAPHIC = re.compile(r"\b(body|bodies|decedent|corpse|cadaver|face|facial|skin|wound|injur|"
                     r"gunshot|stab|autopsy (photo|finding)|external examination|hanging|ligature|"
                     r"burn|blood stain|scene|victim|deceased|dead|death scene|limb|hand|foot|head)\w*", re.I)
QUERIES = [
    ("chromatogram", "method-gcms", '"gas chromatography-mass spectrometry" forensic toxicology chromatogram',
     re.compile(r"chromatogram", re.I), re.compile(r"GC[-–]MS|gas chromatograph", re.I)),
    ("chromatogram", "method-lcmsms", '"LC-MS/MS" forensic toxicology chromatogram blood',
     re.compile(r"chromatogram|MRM|extracted ion", re.I), re.compile(r"LC[-–]MS|liquid chromatograph", re.I)),
    ("mass_spectrum", "method-gcms", 'electron ionization mass spectrum forensic drug identification',
     re.compile(r"mass spectr(um|a)", re.I), re.compile(r"EI|electron ioni|GC[-–]MS", re.I)),
    ("micrograph", "his-he-stain", 'forensic histology "hematoxylin and eosin" postmortem',
     re.compile(r"h(a)?ematoxylin|H&E|HE stain", re.I), re.compile(r"magnification|×|x\s?\d{2,3}|scale bar|µm|μm", re.I)),
    ("micrograph", "his-ihc", 'immunohistochemistry forensic pathology myocardial OR lung postmortem',
     re.compile(r"immunohistochem|immunostain|IHC", re.I), re.compile(r"magnification|×|x\s?\d{2,3}|scale bar|µm|μm", re.I)),
    ("micrograph", "his-fat-embolism", 'fat embolism lung histology "Oil Red O" OR Sudan forensic',
     re.compile(r"fat|Oil Red|Sudan", re.I), re.compile(r"lung|pulmonary|vessel|capillar", re.I)),
    ("tlc_plate", "method-tlc", 'thin-layer chromatography drugs plate forensic',
     re.compile(r"TLC|thin[- ]layer", re.I), re.compile(r"plate|spot|Rf|developed", re.I)),
    ("colour_test", "rea-marquis", 'Marquis reagent color test photograph drugs',
     re.compile(r"Marquis|colou?r (test|reaction|change)", re.I), re.compile(r"reagent|test", re.I)),
]


def main():
    out = []
    for kind, entity, q, p1, p2 in QUERIES:
        ids = get("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pmc&retmode=json&retmax=30"
                  "&sort=relevance&term=" + urllib.parse.quote(f"({q}) AND open access[filter]"))["esearchresult"]["idlist"]
        time.sleep(0.4)
        got = 0
        for pmc in ids:
            try:
                d = get(f"https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_json/PMC{pmc}/unicode")
            except Exception:  # noqa: BLE001
                continue
            coll = d[0] if isinstance(d, list) else d
            if not coll.get("documents"):
                continue
            doc = coll["documents"][0]
            lic = (doc["infons"].get("license") or "")
            low = lic.lower()
            if not ("cc by" in low or "cc0" in low or "cc-by" in low) or "nc" in low.replace("cc-by", ""):
                continue
            title = next((p["text"] for p in doc["passages"] if p["infons"].get("type") == "front"), "")
            caps = {}
            for p in doc["passages"]:
                t = p["infons"].get("type", "")
                if t.startswith("fig") and p["infons"].get("file"):
                    caps.setdefault(p["infons"]["file"], []).append(p["text"])
            for f, texts in caps.items():
                cap = " ".join(texts)
                if p1.search(cap) and p2.search(cap) and not GRAPHIC.search(cap):
                    out.append(dict(kind=kind, entity=entity, pmcid=f"PMC{pmc}", file=f, license=lic,
                                    article_title=title, caption=cap[:600]))
                    got += 1
                    break
            if got >= 3:
                break
        print(kind, entity, got, flush=True)
    json.dump(out, open("phase5/figure_candidates.json", "w"), ensure_ascii=False, indent=1)


if __name__ == "__main__":
    main()
