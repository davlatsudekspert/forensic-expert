#!/usr/bin/env python3
"""PHASE 10: rasmiy huquqiy manbalarda o‘zgarishni aniqlash.

OFFICIAL SOURCE → CHANGE DETECTION → NEEDS LEGAL REVIEW → REVIEW → VERSIONED UPDATE

* Har bir hujjat rasmiy saytdan KESHSIZ qayta yuklanadi.
* Ikki barmoq izi: (1) xom fayl SHA-256 (legal.json dagi bilan), (2) normallashtirilgan
  ro‘yxat yozuvlari SHA-256 — sahifa bezaklari o‘zgarsa ham soxta signal bermaydi.
* O‘zgarish topilsa — faqat taklif (`status: NEEDS_LEGAL_REVIEW`). Bundle’dagi
  qoidalar AVTOMATIK o‘zgartirilmaydi va nashr etilmaydi.

Chiqish: phase10/legal_change_report.json; birinchi ishga tushishda
phase10/legal_baseline.json (normallashtirilgan barmoq izlari) yaratiladi.
"""
import datetime, gzip, hashlib, json, os, re, sys, urllib.request

sys.path.insert(0, "tools/p7")
sys.path.insert(0, "tools/p5")
import fetch_legal as fl  # noqa: E402

UA = "FORENSIC-EXPERT-legal-monitor/1.0 (+change detection; contact via repository)"


def fresh(url, gz=False):
    req = urllib.request.Request(url, headers={"User-Agent": UA, **({"Accept-Encoding": "gzip"} if gz else {})})
    with urllib.request.urlopen(req, timeout=90) as r:
        data = r.read()
        if r.headers.get("Content-Encoding") == "gzip":
            data = gzip.decompress(data)
    return data


def h(b):
    return hashlib.sha256(b if isinstance(b, bytes) else b.encode()).hexdigest()


def gb():
    raw = fresh("https://www.legislation.gov.uk/ukpga/1971/38/schedule/2/data.xml")
    x = raw.decode("utf-8", "ignore")
    items = [fl.norm(e) for e in re.findall(r"<ListItem>(.*?)</ListItem>", x, re.S)]
    return {"GB-MDA-1971-SCH2": dict(raw={"data.xml": h(raw)}, entries=h("\n".join(items)), n=len(items))}


def us():
    t21 = [t for t in json.loads(fresh("https://www.ecfr.gov/api/versioner/v1/titles.json"))["titles"] if t["number"] == 21][0]
    asof = t21["up_to_date_as_of"]
    raw, ents = {}, []
    for s in ["1308.11", "1308.12", "1308.13", "1308.14", "1308.15"]:
        b = fresh(f"https://www.ecfr.gov/api/versioner/v1/full/{asof}/title-21.xml?part=1308&section={s}", gz=True)
        raw[s] = h(b)
        xml = b.decode("utf-8", "ignore")
        ents += [fl.norm(c) for c in re.findall(r'<TD class="left">(.*?)</TD>', xml, re.S)]
    return {"US-21CFR1308": dict(raw=raw, entries=h("\n".join(ents)), n=len(ents), as_of=asof)}


def de():
    raw, ents = {}, []
    for an, label in [("anlage_i", "Anlage I"), ("anlage_ii", "Anlage II"), ("anlage_iii", "Anlage III")]:
        b = fresh(f"https://www.gesetze-im-internet.de/btmg_1981/{an}.html")
        raw[label] = h(b)
        ents += [fl.norm(c) for c in re.findall(r"<td[^>]*>(.*?)</td>", b.decode("iso-8859-1", "ignore"), re.S)]
    return {"DE-BTMG-ANL": dict(raw=raw, entries=h("\n".join(ents)), n=len(ents))}


def uz():
    b = fresh("https://lex.uz/docs/86028")
    t = fl.norm(b.decode("utf-8", "ignore"))
    i = t.find("Наркотические средства, психотропные вещества и прекурсоры, подлежащие контролю")
    art4 = t[i:i + 700] if i >= 0 else ""
    return {"UZ-LAW-813-I": dict(raw={"html": h(b)}, entries=h(art4), n=1 if art4 else 0)}


def main():
    today = datetime.date.today().isoformat()
    legal = json.load(open("phase7/legal.json"))
    stored_raw = {j["instrument_id"]: (j["sha256"] if isinstance(j["sha256"], dict) else {"_": j["sha256"]})
                  for j in legal["jurisdictions"]}
    now, errors = {}, {}
    for fn in (gb, us, de, uz):
        try:
            now.update(fn())
        except Exception as e:  # noqa: BLE001
            errors[fn.__name__] = f"{type(e).__name__}: {e}"
    base_path = "phase10/legal_baseline.json"
    created = not os.path.exists(base_path)
    if created:
        json.dump(dict(created=today, fingerprints={k: v["entries"] for k, v in now.items()}),
                  open(base_path, "w"), indent=1)
    base = json.load(open(base_path))["fingerprints"]
    report = []
    for iid, v in now.items():
        raw_changed = set(v["raw"].values()) != set(stored_raw.get(iid, {}).values())
        entries_changed = base.get(iid) not in (None, v["entries"])
        report.append(dict(
            instrument_id=iid, checked_at=today, entries_fingerprint=v["entries"], entries=v["n"],
            raw_changed_since_ingestion=raw_changed, list_entries_changed=entries_changed,
            status="NEEDS_LEGAL_REVIEW" if entries_changed else "NO_CHANGE_DETECTED",
            note=("Raw file differs from ingestion (may be page metadata only); list entries unchanged."
                  if raw_changed and not entries_changed else None)))
    json.dump(dict(checked_at=today, baseline_created=created, errors=errors, instruments=report,
                   policy="Changes are proposals only; no automatic publication."),
              open("phase10/legal_change_report.json", "w"), ensure_ascii=False, indent=1)
    for r in report:
        print(r["instrument_id"], r["status"], "raw_changed=", r["raw_changed_since_ingestion"], "n=", r["entries"])
    if errors:
        print("errors:", errors)


if __name__ == "__main__":
    main()
