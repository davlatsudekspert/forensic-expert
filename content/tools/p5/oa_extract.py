#!/usr/bin/env python3
"""PHASE 5: ochiq litsenziyali PMC maqolalaridan dalil jumlalarini
ASL MATNDAN ajratish (nomzodlar; keyin kuratsiya va reviewer).

* Qidiruv: NCBI esearch (db=pmc, open access filter), relevance.
* Matn va litsenziya: PMC BioC (JSON). Faqat CC BY / CC0 / PD, NC emas.
* Jumla barcha regex shartlariga mos bo‘lsa olinadi; parafraz yo‘q.
* Metadata (DOI, PMID, jurnal, yil): esummary (db=pmc).
* Har bir maqsad uchun 2 tagacha nomzod (turli maqolalardan).

Foydalanish: oa_extract.py <spec.json> <out.json>
spec: [{target, entity, field, query, patterns:[...], allow_methods:bool}]
"""
import json, re, sys, threading, time, urllib.parse
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, __file__.rsplit("/", 1)[0])
from fehttp import get  # noqa: E402

ESEARCH = ("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pmc"
           "&retmode=json&retmax={n}&sort=relevance&term={q}")
ESUMMARY = ("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi"
            "?db=pmc&retmode=json&id={ids}")
BIOC = ("https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/"
        "BioC_json/PMC{pmc}/unicode")
OPEN = ("cc by", "cc0", "cc-by", "publicdomain", "public domain")
EXCLUDE_TITLE = re.compile(
    r"\b(fish|carp|salmon|zebrafish|cattle|bovine|porcine|pig|piglets?|rats?|"
    r"mice|mouse|murine|poultry|chickens?|horses?|equine|dogs?|canine|cats?|"
    r"feline|insects?|larva|SARS-CoV-2|COVID|veterinar|wastewater|sewage|"
    r"plant|crop|soil)\b", re.I)

_lock = threading.Lock()
_last = [0.0]


def eutils(url):
    # NCBI: kalitsiz ≤ 3 so‘rov/s.
    with _lock:
        wait = 0.36 - (time.time() - _last[0])
        if wait > 0:
            time.sleep(wait)
        _last[0] = time.time()
    return get(url)


def sentences(text):
    return re.split(r"(?<=[.!?])\s+(?=[A-Z0-9α-ωΔ])", text)


def meta(pmc):
    try:
        r = eutils(ESUMMARY.format(ids=pmc))["result"][str(pmc)]
    except Exception:  # noqa: BLE001
        return {}
    ids = {a["idtype"]: a["value"] for a in r.get("articleids", [])}
    return dict(title=r.get("title"), journal=r.get("fulljournalname") or r.get("source"),
                year=(r.get("pubdate") or "")[:4], doi=ids.get("doi"),
                pmid=ids.get("pmid"),
                authors=[a["name"] for a in r.get("authors", [])][:6])


def run(t, max_articles=25, max_cands=2):
    q = urllib.parse.quote(f"({t['query']}) AND open access[filter]")
    try:
        ids = eutils(ESEARCH.format(n=max_articles, q=q))["esearchresult"]["idlist"]
    except Exception as e:  # noqa: BLE001
        return dict(t, status="error", error=str(e), candidates=[])
    pats = [re.compile(p, re.I) for p in t["patterns"]]
    cands = []
    for pmc in ids:
        try:
            data = get(BIOC.format(pmc=pmc))
        except Exception:  # noqa: BLE001
            continue
        coll = data[0] if isinstance(data, list) else data
        if not coll.get("documents"):
            continue
        doc = coll["documents"][0]
        lic = doc.get("infons", {}).get("license") or ""
        low = lic.lower()
        if not any(o in low for o in OPEN) or "-nc" in low or " nc" in low:
            continue
        title = next((p.get("text", "") for p in doc["passages"]
                      if p.get("infons", {}).get("type") == "front"), "")
        if EXCLUDE_TITLE.search(title):
            continue
        hit = None
        for p in doc["passages"]:
            inf = p.get("infons", {})
            if inf.get("type") not in ("paragraph", "abstract"):
                continue
            sec = inf.get("section_type", "")
            if sec in ("SUPPL", "REF") or (sec == "METHODS" and not t.get("allow_methods")):
                continue
            for s in sentences(p.get("text", "")):
                if 40 <= len(s) <= 360 and all(x.search(s) for x in pats):
                    hit = dict(pmcid=f"PMC{pmc}", license=lic, section=sec,
                               title=title, sentence=s.strip())
                    break
            if hit:
                break
        if hit:
            hit.update(meta(pmc))
            cands.append(hit)
            if len(cands) >= max_cands:
                break
    return dict(t, status="found" if cands else "not_found", candidates=cands)


def main():
    spec = json.load(open(sys.argv[1]))
    out_path = sys.argv[2]
    done = {}
    try:
        for r in json.load(open(out_path)):
            if r["status"] != "error":
                done[r["target"]] = r
    except FileNotFoundError:
        pass
    todo = [t for t in spec if t["target"] not in done]
    results = list(done.values())
    with ThreadPoolExecutor(max_workers=3) as ex:
        for i, r in enumerate(ex.map(run, todo)):
            results.append(r)
            print(f"[{i + 1}/{len(todo)}] {r['target']} {r['status']} "
                  f"{[c['pmcid'] for c in r['candidates']]}", flush=True)
            if i % 10 == 0:
                json.dump(results, open(out_path, "w"), ensure_ascii=False, indent=1)
    json.dump(results, open(out_path, "w"), ensure_ascii=False, indent=1)


if __name__ == "__main__":
    main()
