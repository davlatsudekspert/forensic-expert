#!/usr/bin/env python3
"""Ilmiy iqtiboslarni PMC asl matni bilan dasturiy solishtiradi.

Kirish:  content/pilot/candidates/metabolites_*.json (qidiruv natijalari)
Chiqish: content/pilot/metabolites.verified.json

Har bir nomzod uchun:
* PMC BioC API’dan to‘liq matn olinadi (NCBI BioNLP, Open Access subset);
* litsenziya va DOI shu API’ning o‘zidan olinadi (nomzoddagi qiymatga
  ishonilmaydi);
* iqtibos asl matnda **so‘zma-so‘z** bor-yo‘qligi tekshiriladi (faqat
  bo‘shliqlar va havola raqamlari [12] / (3) normallashtiriladi);
* har bir metabolit nomi iqtibos ichida borligi tekshiriladi.
Biror shart bajarilmasa — `rejected`, claim yaratilmaydi.
"""
import datetime, difflib, glob, json, re, sys, time, urllib.error, urllib.request

API = ("https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/"
       "BioC_json/{}/unicode")


def get_json(url, attempts=5):
    """NCBI 429 (rate limit) uchun eksponensial kutish bilan qayta urinish."""
    for i in range(attempts):
        try:
            with urllib.request.urlopen(url, timeout=60) as r:
                return json.load(r)
        except urllib.error.HTTPError as e:
            if e.code != 429 or i == attempts - 1:
                raise
            time.sleep(2 ** (i + 1))


def norm(s):
    s = s.replace(" ", " ").replace(" ", " ")
    # havola markerlari: [12], [1,2], [3–5], (12), () , []
    s = re.sub(r"\[[\d,\s–\-–]*\]", "", s)
    s = re.sub(r"\(\s*[\d,\s–\-–]*\)", "", s)
    s = re.sub(r"\s+", " ", s)
    s = re.sub(r"\s+([.,;:])", r"\1", s)
    return s.strip()


def best_sentence(text, cand):
    """Asl matndagi eng yaqin gap (nomzod uzunligi atrofidagi oynalar)."""
    sents = re.split(r"(?<=[.!?])\s+(?=[A-Z0-9α-ωΑ-Ω])", text)
    best, score = None, 0.0
    for s_ in sents:
        r = difflib.SequenceMatcher(None, s_, cand, autojunk=False).ratio()
        if r > score:
            best, score = s_, r
    return best, score


def fetch(pmcid):
    data = get_json(API.format(pmcid))
    coll = data[0] if isinstance(data, list) else data
    doc = coll["documents"][0]
    license_ = doc.get("infons", {}).get("license")
    doi = None
    texts = []
    for p in doc["passages"]:
        inf = p.get("infons", {})
        doi = doi or inf.get("article-id_doi")
        if p.get("text"):
            texts.append(p["text"])
    return license_, doi, norm(" ".join(texts))


IDCONV = ("https://pmc.ncbi.nlm.nih.gov/tools/idconv/api/v1/articles/"
          "?ids={}&format=json&tool=forensic-expert&email=none@example.invalid")


def doi_from_idconv(pmcid):
    """BioC’da DOI bo‘lmasa — NCBI ID Converter (rasmiy xizmat)."""
    recs = get_json(IDCONV.format(pmcid)).get("records", [])
    return recs[0].get("doi") if recs else None


def license_mode(lic):
    if not lic:
        return "unknown"
    l = lic.lower()
    if "nc" in l.replace("cc0", "") and "by-nc" in l.replace(" ", "-"):
        return "nonCommercial"
    if l.startswith("cc by") or l.startswith("cc0") or "publicdomain" in l:
        return "openReuse"
    if "by-nc" in l or "non-commercial" in l or "noncommercial" in l:
        return "nonCommercial"
    return "unknown"


def main():
    accessed = datetime.date.today().isoformat()
    out = []
    for path in sorted(glob.glob("pilot/candidates/metabolites_*.json")):
        for c in json.load(open(path)):
            rec = dict(c, accessed=accessed, candidate_file=path)
            if c.get("status") != "found":
                rec["verification"] = "not_found"
                out.append(rec)
                continue
            try:
                lic, doi, text = fetch(c["pmcid"])
                rec["license_api"] = lic
                rec["license_mode"] = license_mode(lic)
                if doi is None:
                    doi = doi_from_idconv(c["pmcid"])
                    rec["doi_source"] = "ncbi_idconv"
                rec["doi_api"] = doi
                cand = norm(c["verbatim_sentence"])
                # Bazaga AGENT matni emas, ASL MANBADAGI gap yoziladi.
                if cand in text:
                    src, ratio, match = cand, 1.0, "exact"
                else:
                    src, ratio = best_sentence(text, cand)
                    match = "fuzzy" if ratio >= 0.9 else "none"
                ok_text = match != "none"
                rec["source_sentence"] = src if ok_text else None
                rec["match"] = dict(type=match, ratio=round(ratio, 3))
                missing = [m for m in c["metabolites"]
                           if norm(m) not in (src or "")]
                doi_ok = (doi or "").lower() == (c.get("doi") or "").lower()
                rec["checks"] = dict(excerpt_in_fulltext=ok_text,
                                     metabolites_in_excerpt=not missing,
                                     doi_matches=doi_ok)
                rec["verification"] = ("verified"
                                       if ok_text and not missing and doi_ok
                                       else "rejected")
            except Exception as e:  # noqa: BLE001
                rec["verification"] = f"error: {e}"
            out.append(rec)
            time.sleep(0.4)
    json.dump(out, open("pilot/metabolites.verified.json", "w"),
              ensure_ascii=False, indent=2)
    for r in out:
        print(f"{r['substance']:<18} {r['verification']:<10} "
              f"{r.get('license_api')!s:<18} {r.get('match')} "
              f"{r.get('checks')}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
