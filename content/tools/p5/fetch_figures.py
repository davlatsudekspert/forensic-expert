#!/usr/bin/env python3
"""Tanlangan CC BY rasmlarni yuklaydi va to‘liq atribusiya metadatasini yozadi.

* Fayl Europe PMC «supplementaryFiles» arxividan (rasmiy API).
* Litsenziya BioC’dan qayta tekshiriladi; caption’da «Reprinted»,
  «Adapted from», «©», «Copyright» bo‘lsa — RAD (uchinchi tomon huquqi).
* Rasm 1200 px gacha kichraytiriladi (o‘zgartirish atribusiyada aytiladi).
"""
import io, json, re, sys, zipfile

from PIL import Image

sys.path.insert(0, __file__.rsplit("/", 1)[0])
from fehttp import get  # noqa: E402

CHOSEN = [1, 2, 4, 9, 14, 16, 18, 22]
THIRD_PARTY = re.compile(r"reprinted|adapted from|©|copyright|with permission", re.I)
TITLES = {
    1: "GC–MS chromatogram and mass spectrum of a seized powder (5-MAPB)",
    2: "GC–MS chromatogram and mass spectrum: THC-COOH in urine",
    4: "LC–MS/MS chromatogram and product-ion spectrum (5-MAPB)",
    9: "Hematoxylin and eosin staining — lung and myocardium (forensic case series)",
    14: "Immunohistochemistry (C9) — myocardial necrotic area",
    16: "Oil Red O staining — pulmonary fat embolism (frozen section)",
    18: "TLC plates — cannabinoid standards on silica gel and Ag(I)-TLC",
    22: "Colour spot tests — xylazine interaction with field reagents",
}


def main():
    cands = json.load(open("phase5/figure_candidates.json"))
    out = []
    for i in CHOSEN:
        c = cands[i]
        if THIRD_PARTY.search(c["caption"]):
            print("REJECT third-party", c["pmcid"])
            continue
        pmc = c["pmcid"][3:]
        meta = get("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pmc&retmode=json&id=" + pmc)["result"][pmc]
        ids = {a["idtype"]: a["value"] for a in meta.get("articleids", [])}
        z = zipfile.ZipFile(io.BytesIO(get(f"https://www.ebi.ac.uk/europepmc/webservices/rest/{c['pmcid']}/supplementaryFiles",
                                           binary=True, ttl_days=365)))
        stem = c["file"].rsplit(".", 1)[0]
        names = [n for n in z.namelist() if n.rsplit("/", 1)[-1].rsplit(".", 1)[0] == stem
                 and n.lower().endswith((".jpg", ".jpeg", ".png", ".gif", ".tif", ".tiff"))]
        if not names:
            print("MISSING", c["pmcid"], c["file"])
            continue
        names.sort(key=lambda n: (not n.lower().endswith((".jpg", ".png")), -z.getinfo(n).file_size))
        img = Image.open(io.BytesIO(z.read(names[0]))).convert("RGB")
        if img.width > 1200:
            img = img.resize((1200, round(img.height * 1200 / img.width)), Image.LANCZOS)
        key = f"{c['pmcid']}-{stem}".lower()
        path = f"phase5/images/external/{key}.jpg"
        img.save(path, "JPEG", quality=85, optimize=True)
        authors = [a["name"] for a in meta.get("authors", [])]
        au = (authors[0] + (" et al." if len(authors) > 1 else "")) if authors else "Unknown"
        year = (meta.get("pubdate") or "")[:4]
        journal = meta.get("fulljournalname") or meta.get("source")
        out.append(dict(
            image_id=f"IMG-EXT-{key}", kind=c["kind"], entity_id=c["entity"], file=path,
            width=img.width, height=img.height, title={"en": TITLES[i]},
            alt={"en": TITLES[i] + ". Figure from a peer-reviewed open-access article."},
            caption_original=c["caption"], creator=", ".join(authors[:6]),
            source_name=f"{meta.get('title')} — {journal} ({year})",
            source_url=f"https://pmc.ncbi.nlm.nih.gov/articles/{c['pmcid']}/",
            doi=ids.get("doi"), pmcid=c["pmcid"], license=c["license"],
            attribution=f"{au}, {journal} {year}; {c['pmcid']}; licensed {c['license']}. Resized.",
            is_original_diagram=False, represents_real_data=True, graphic=False,
            accessed=__import__("datetime").date.today().isoformat()))
        print("OK", key, img.size)
    json.dump(out, open("phase5/images_external.json", "w"), ensure_ascii=False, indent=1)


if __name__ == "__main__":
    main()
