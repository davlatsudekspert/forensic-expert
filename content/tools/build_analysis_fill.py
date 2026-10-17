#!/usr/bin/env python3
"""«Tahlil» bo‘limi (1 Test / 2 Sifat reaksiyalari / 3 Miqdoriy aniqlash) uchun yozuvlar.

Manbalar:
  * `analysis_fill_data.BOOK` — Yuldashev, Umarova «Toksikologik kimyo» (2025) (ustoz kitobi): faqat o‘zbekcha,
    o‘z so‘zimiz bilan, aniq bet bilan (so‘zma-so‘z iqtibos yo‘q);
  * `analysis_fill_lit.json` — ochiq (CC BY) PMC maqolalaridan ASL MATNDAN olingan jumla (value.excerpt) +
    o‘zbekcha tarjima (machine_draft, tekshirilmagan). `--verify` jumlani PMC BioC da qayta tekshiradi.

Idempotent: `C-AS-` prefiksli claim/citation/link/tarjimalar va shu skript qo‘shgan manbalar
(`notes` da `analysis_fill`) har ishga tushirishda o‘chirilib qayta yoziladi.
Usage: python3 content/tools/build_analysis_fill.py [--check] [--verify]
"""
from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
ROOT = HERE.parents[1]
BUNDLE = ROOT / "content/pilot/bundle.json"
LIT_JSON = HERE / "analysis_fill_lit.json"
PREFIX = "C-AS-"
MARK = "analysis_fill"

from analysis_fill_data import BOOK, SRC_TOKS, SRC_TOKS_UZ  # noqa: E402


def sha(t: str) -> str:
    return hashlib.sha256(t.encode("utf-8")).hexdigest()


def book_claim(row):
    (suffix, sub, field, family, cls, uz, page_uz, page_en, reagents, link) = row
    cid = PREFIX + suffix
    claim = {
        "claim_id": cid,
        "entity_type": "substance",
        "entity_id": sub,
        "field": field,
        "domain": "lab",
        "declared_status": "NEEDS_REVIEW",
        "evidence_level": "C",
        "layer": "international_scientific",
        "is_structured_value": False,
        "value": {
            # Mazmun o‘z so‘zimiz bilan; `excerpt` YO‘Q (u faqat ochiq litsenziyali iqtibos uchun).
            "statement": {"uz": uz},
            "source_lang": "uz",
            "translation_status": {"uz": "authored"},
            "section": page_en,
            "method_family": family,
            "evidence_class": cls,
            "scope": "substance",
            "recipe_ids": [],
            "reagents": reagents,
            "locator_i18n": {"uz": f"{SRC_TOKS_UZ}, {page_uz}"},
            "source_i18n": {"uz": SRC_TOKS_UZ},
            "data": {},
        },
    }
    cit = {"claim_id": cid, "source_id": SRC_TOKS, "locator": page_en}
    lk = None
    if link:
        lk = {"from": sub, "to": link[1], "relation": link[0], "basis": cid}
    return claim, cit, lk


def lit_claim(row):
    cid = PREFIX + row["id"]
    claim = {
        "claim_id": cid,
        "entity_type": "substance",
        "entity_id": row["sub"],
        "field": row["field"],
        "domain": "lab",
        "declared_status": "NEEDS_REVIEW",
        "evidence_level": row.get("level", "C"),
        "layer": "international_scientific",
        "is_structured_value": False,
        "value": {"excerpt": row["sentence"], "section": row["section"]},
    }
    if row.get("perf"):
        # Raqamlar — usul / test ko‘rsatkichi (LOD/LOQ, kross-reaktivlik chegarasi), namunadagi
        # konsentratsiya EMAS; `phase5_test` konsentratsiya-birlik qoidasidan shu bayroq bilan chiqariladi.
        claim["value"]["analytical_performance"] = True
    cit = {"claim_id": cid, "source_id": "SRC-" + row["pmcid"], "locator": row["section"]}
    tr = {
        "target_type": "claim_excerpt",
        "target_id": cid,
        "lang": "uz",
        "source_sha256": sha(row["sentence"]),
        "text": row["uz"],
        "status": "machine_draft",
    }
    src = {
        "source_id": "SRC-" + row["pmcid"],
        "source_type": "journal_article",
        "title": row["title"],
        "authors": row["authors"],
        "journal": row["journal"],
        "publication_year": int(row["year"]),
        "doi": row["doi"],
        "pmid": row["pmid"],
        "official_url": f"https://pmc.ncbi.nlm.nih.gov/articles/{row['pmcid']}/",
        "accessed_date": "2026-10-17",
        "tier": "tier2",
        "evidence_level": row.get("level", "C"),
        "license_mode": "openReuse",
        "identifier_verified": True,
        "notes": (f"Litsenziya (Europe PMC / PMC BioC): {row['license']}. Jumla asl matndan ({row['section']}) "
                  f"ajratilgan ({MARK})."),
    }
    return claim, cit, tr, src


def verify(lit):
    """Har bir jumla manba matnida bormi (bo‘shliqlarsiz solishtirish) va litsenziya ochiqmi.

    Avval PMC BioC (to‘liq matn); BioC javob bermasa (503/yo‘q) — Europe PMC abstrakti (jumla
    ABSTRACT bo‘limidan bo‘lsa). Hisobotda qaysi manba ishlatilgani ko‘rsatiladi.
    """
    import re
    import time
    import urllib.error
    import urllib.parse
    import urllib.request

    def norm(t):
        return re.sub(r"\s+", "", t.replace("\xa0", " "))

    def bioc(pid):
        url = ("https://www.ncbi.nlm.nih.gov/research/bionlp/RESTful/pmcoa.cgi/BioC_json/"
               f"{pid}/unicode")
        for attempt in range(4):
            try:
                data = json.load(urllib.request.urlopen(url, timeout=90))
                coll = data[0] if isinstance(data, list) else data
                doc = coll["documents"][0]
                return (norm(" ".join(p.get("text", "") for p in doc["passages"])),
                        (doc.get("infons", {}).get("license") or "").lower(), "BioC")
            except urllib.error.HTTPError as e:
                if e.code not in (429, 500, 502, 503, 504):
                    break
                time.sleep(4 * (attempt + 1))
            except Exception:  # noqa: BLE001
                break
        return None

    def epmc(pid):
        url = ("https://www.ebi.ac.uk/europepmc/webservices/rest/search?query="
               + urllib.parse.quote(f"PMCID:{pid}") + "&format=json&resultType=core")
        r = json.load(urllib.request.urlopen(url, timeout=60))["resultList"]["result"][0]
        ab = re.sub(r"<[^>]+>", "", r.get("abstractText") or "")
        return norm(ab), (r.get("license") or "").lower(), "EuropePMC-abstract"

    docs = {}
    ok = True
    for row in lit:
        pid = row["pmcid"]
        if pid not in docs:
            docs[pid] = {"bioc": bioc(pid), "epmc": epmc(pid)}
            time.sleep(1.2)
        d = docs[pid]
        want = norm(row["sentence"])
        res, via = False, "-"
        for key in ("bioc", "epmc"):
            v = d[key]
            if v and want in v[0]:
                res, via, lic = True, v[2], v[1]
                break
        lic = (d["bioc"] or d["epmc"])[1]
        open_lic = lic.startswith(("cc by", "cc0")) and "nc" not in lic and "nd" not in lic
        print(f"{row['id']:46s} {pid:12s} sentence={'OK' if res else 'MISSING'} via={via} license={lic or '?'}")
        ok &= res and open_lic
    return ok


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--verify", action="store_true")
    a = ap.parse_args()

    lit = json.loads(LIT_JSON.read_text(encoding="utf-8")) if LIT_JSON.exists() else []
    if a.verify:
        return 0 if verify(lit) else 1

    raw = BUNDLE.read_text(encoding="utf-8")
    b = json.loads(raw)
    subs = {s["substance_id"] for s in b["substances"]}

    # 0. oldingi natijani o‘chirish
    b["claims"] = [c for c in b["claims"] if not c["claim_id"].startswith(PREFIX)]
    b["citations"] = [c for c in b["citations"] if not c["claim_id"].startswith(PREFIX)]
    b["links"] = [l for l in b["links"] if not l["basis"].startswith(PREFIX)]
    b["text_translations"] = [t for t in b["text_translations"] if not t["target_id"].startswith(PREFIX)]
    b["sources"] = [s for s in b["sources"] if MARK not in (s.get("notes") or "")]
    have_sources = {s["source_id"] for s in b["sources"]}
    assert SRC_TOKS in have_sources, "run build_substance_methods.py first (TOKS source)"

    seen_ids = set()
    for row in BOOK:
        claim, cit, lk = book_claim(row)
        assert claim["entity_id"] in subs, claim["entity_id"]
        assert claim["claim_id"] not in seen_ids
        seen_ids.add(claim["claim_id"])
        b["claims"].append(claim)
        b["citations"].append(cit)
        if lk:
            b["links"].append(lk)
    for row in lit:
        claim, cit, tr, src = lit_claim(row)
        assert claim["entity_id"] in subs, claim["entity_id"]
        assert claim["claim_id"] not in seen_ids, claim["claim_id"]
        seen_ids.add(claim["claim_id"])
        b["claims"].append(claim)
        b["citations"].append(cit)
        b["text_translations"].append(tr)
        if src["source_id"] not in have_sources:
            have_sources.add(src["source_id"])
            b["sources"].append(src)

    out = json.dumps(b, indent=1, ensure_ascii=False) + "\n"
    if a.check:
        if out != raw:
            print("bundle.json eskirgan: build_analysis_fill.py ni qayta ishga tushiring", file=sys.stderr)
            return 1
        return 0
    BUNDLE.write_text(out, encoding="utf-8")
    print(f"book claims: {len(BOOK)}, literature claims: {len(lit)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
