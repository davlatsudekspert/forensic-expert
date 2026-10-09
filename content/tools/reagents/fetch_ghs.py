#!/usr/bin/env python3
"""Reaktiv ingrediyentlari uchun GHS xavf tasnifini PubChem’dan oladi.

Kirish:  pilot/reagents/chemicals.json        (`pubchem` — so‘rov nomi)
         pilot/reagents/pubchem_ghs_relay.txt  (zaxira, quyida)
Chiqish: pilot/reagents/pubchem_ghs.generated.json

Har bir qiymat REAL so‘rov natijasi (PUG REST: nom → CID; PUG View:
«GHS Classification» bo‘limi). Hech narsa qo‘lda to‘qilmaydi: topilmasa,
modda `unresolved` ro‘yxatiga tushadi va ilovada unga GHS izohi chiqmaydi.

Tanlash qoidasi: PubChem «GHS Hazard Statements» ning BIRINCHI yozuvi
(odatda ECHA C&L Inventory umumlashmasi). Foiz ko‘rsatilgan bo‘lsa —
faqat xabarnomalarning ≥ 50 % ida keltirilgan H-bayonotlar (foizsiz
yozuv — to‘liq). Signal so‘zi, piktogrammalar va P-kodlar — o‘sha yozuv
(ReferenceNumber) uchun PubChem ko‘rsatganidek (filtrlanmagan).

Zaxira (relay): 2026-10-09 da sessiya egress’i pubchem.ncbi.nlm.nih.gov ga
to‘g‘ridan-to‘g‘ri so‘rovlarni HTTP 429 bilan cheklagan; ayrim moddalar
uchun xuddi shu PUG REST/PUG View URL’lari boshqa kanal (WebFetch) orqali
o‘qilib, `pubchem_ghs_relay.txt` ga so‘zma-so‘z yozilgan. To‘g‘ridan-to‘g‘ri
kesh bo‘lmasa, shu fayl ishlatiladi (`retrieved_via: relay`).

Ishga tushirish (content/ ichidan):
  python3 tools/reagents/fetch_ghs.py            # tarmoq + kesh + relay
  python3 tools/reagents/fetch_ghs.py --offline  # faqat kesh + relay
"""
import datetime
import hashlib
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "p5"))
from fehttp import CACHE, get as _get  # noqa: E402

CHEM = "pilot/reagents/chemicals.json"
RELAY = "pilot/reagents/pubchem_ghs_relay.txt"
OUT = "pilot/reagents/pubchem_ghs.generated.json"
PUG = "https://pubchem.ncbi.nlm.nih.gov/rest/pug"
VIEW = "https://pubchem.ncbi.nlm.nih.gov/rest/pug_view/data/compound"
H_RE = re.compile(
    r"^(H\d{3}[A-Za-z]*(?:\+H\d{3}[A-Za-z]*)*)(?:\s*\*+)?\s*(?:\(([\d.]+)%\))?"
    r"\s*:?\s*(.*)$")
OFFLINE = "--offline" in sys.argv


class Unavailable(Exception):
    pass


def get(url, tries=6):
    """Kesh → tarmoq (429 da uzoq kutish). --offline: faqat kesh."""
    path = os.path.join(CACHE, hashlib.sha256(url.encode()).hexdigest() + ".txt")
    if os.path.exists(path):
        return json.loads(open(path, "rb").read())
    if OFFLINE:
        raise Unavailable(url)
    for attempt in range(tries):
        try:
            return _get(url, tries=2)
        except urllib.error.HTTPError as e:
            if e.code != 429 or attempt == tries - 1:
                raise
            time.sleep(300)


def strings(info):
    return [m.get("String", "")
            for m in info.get("Value", {}).get("StringWithMarkup", [])]


def walk(sec, found):
    if sec.get("TOCHeading") == "GHS Classification":
        found.append(sec)
    for s in sec.get("Section", []):
        walk(s, found)


def statements(lines):
    out = []
    for line in lines:
        m = H_RE.match(line.strip())
        if not m:
            continue
        code, pct, text = m.group(1), m.group(2), m.group(3)
        if pct is not None and float(pct) < 50:
            continue
        text = re.sub(r"\s*\[.*\]?\s*$", "", text).strip()
        out.append({"code": code, "text": text,
                    **({"percent": float(pct)} if pct is not None else {})})
    return out


def codes(s):
    return [c.strip() for c in re.split(r",|\band\b", s or "")
            if re.match(r"^\s*P\d", c)]


def ghs_from_view(data):
    secs = []
    for s in data.get("Record", {}).get("Section", []):
        walk(s, secs)
    if not secs:
        return None
    infos = secs[0].get("Information", [])
    hs = [i for i in infos if i.get("Name") == "GHS Hazard Statements"]
    if not hs:
        return None
    ref = hs[0].get("ReferenceNumber")
    same = [i for i in infos if i.get("ReferenceNumber") == ref]

    def first(name):
        return next((i for i in same if i.get("Name") == name), None)

    sig = first("Signal")
    pic = first("Pictogram(s)")
    pcs = first("Precautionary Statement Codes")
    pictos = []
    if pic:
        for m in pic.get("Value", {}).get("StringWithMarkup", []):
            pictos += [x.get("Extra") for x in m.get("Markup", []) if x.get("Extra")]
    return {"title": data.get("Record", {}).get("RecordTitle"),
            "signal": strings(sig)[0] if sig and strings(sig) else None,
            "statements": statements(strings(hs[0])),
            "pictograms": pictos,
            "p_codes": codes(" ".join(strings(pcs))) if pcs else [],
            "reference_number": ref}


def load_relay():
    """`### CID | query` bloklari; `| +` — shu CID uchun PICTO/PCODES."""
    by_cid, by_query = {}, {}
    if not os.path.exists(RELAY):
        return by_cid, by_query
    cur = None
    for raw in open(RELAY, encoding="utf-8"):
        line = raw.rstrip("\n")
        if line.startswith("### "):
            cid, _, q = line[4:].partition("|")
            cid, q = int(cid.strip()), q.strip()
            cur = by_cid.setdefault(cid, {"lines": [], "pictograms": [],
                                          "p_codes": []})
            if q != "+":
                by_query[q] = cid
                cur["_head"] = True
            continue
        if cur is None or not line.strip() or line.startswith("#"):
            continue
        if line.startswith("REF "):
            cur["reference_number"] = int(line[4:].split()[0])
        elif line.startswith("SIGNAL "):
            cur["signal"] = line[7:].strip()
        elif line.startswith("PICTO "):
            cur["pictograms"] = [p.strip() for p in line[6:].split(",") if p.strip()]
        elif line.startswith("PCODES "):
            cur["p_codes"] = codes(line[7:])
        elif cur.get("_head") and "title" not in cur:
            cur["title"] = line.strip()
        else:
            cur["lines"].append(line)
    return by_cid, by_query


def main():
    chem = json.load(open(CHEM))["chemicals"]
    queries = sorted({c["pubchem"] for c in chem.values() if c.get("pubchem")})
    relay_cid, relay_query = load_relay()
    prev = json.load(open(OUT)) if os.path.exists(OUT) else {}
    out = {"fetched_at": datetime.date.today().isoformat(),
           "method": "PubChem PUG REST name->CID; PUG View 'GHS Classification'; "
                     "first 'GHS Hazard Statements' record, statements reported "
                     "in >=50 % of notifications; signal word, pictograms and "
                     "P-codes of the same record",
           "compounds": {}, "unresolved": []}
    for q in queries:
        via = "direct"
        try:
            r = get(f"{PUG}/compound/name/{urllib.parse.quote(q)}/cids/JSON")
            cid = r.get("IdentifierList", {}).get("CID", [None])[0]
        except (Unavailable, urllib.error.HTTPError) as e:
            cid = relay_query.get(q)
            if cid is None:
                out["unresolved"].append({"query": q, "reason": f"name lookup: {e}"})
                continue
            via = "relay"
        g = None
        try:
            g = ghs_from_view(get(f"{VIEW}/{cid}/JSON?heading=GHS+Classification"))
        except (Unavailable, urllib.error.HTTPError):
            rl = relay_cid.get(cid)
            if rl and rl.get("_head"):
                via = "relay"
                g = {"title": rl.get("title"), "signal": rl.get("signal"),
                     "statements": statements(rl["lines"]),
                     "pictograms": rl["pictograms"], "p_codes": rl["p_codes"],
                     "reference_number": rl.get("reference_number")}
        if not OFFLINE:
            time.sleep(5)
        if not g or not g["statements"]:
            out["unresolved"].append({"query": q, "cid": cid,
                                      "reason": "no GHS hazard statements "
                                                "(>=50 %) or no GHS section"})
            continue
        out["compounds"][q] = {"cid": cid, "retrieved_via": via, **g}
        print(q, cid, via, g["signal"], [s["code"] for s in g["statements"]],
              flush=True)
    if (prev.get("compounds") == out["compounds"]
            and prev.get("unresolved") == out["unresolved"]):
        out["fetched_at"] = prev.get("fetched_at", out["fetched_at"])
    json.dump(out, open(OUT, "w"), ensure_ascii=False, indent=1)
    print("resolved:", len(out["compounds"]), "unresolved:",
          [u["query"] for u in out["unresolved"]])


if __name__ == "__main__":
    main()
