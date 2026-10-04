#!/usr/bin/env python3
"""PHASE 5: INCB Yellow/Green List — nom bo‘yicha aniq qator.

Har bir `incb_name` uchun rasmiy PDF matnida IDS kodi bilan boshlanadigan va
aynan shu nom (so‘z chegarasi bilan) turgan qator qidiriladi.
Topilmasa — claim yaratilmaydi (yo‘qlik «nazoratda emas» degani EMAS).
Bir nechta mos qator (masalan, tuz shakllari) — barchasi yoziladi.

Chiqish: phase5/international_control.json
"""
import datetime, hashlib, json, re, subprocess, sys, tempfile

sys.path.insert(0, __file__.rsplit("/", 1)[0])
from fehttp import get  # noqa: E402

YELLOW = ("https://www.incb.org/incb/uploads/documents/Narcotic-Drugs/"
          "Yellow_List/65th_Edition/YL_65th_EN_unedited.pdf")
GREEN = ("https://www.incb.org/incb/uploads/documents/Psychotropics/forms/"
         "greenlist/2026/2510307E.pdf")
IDS = re.compile(r"^\s*([NP][A-Z]\s?\d{3})\s+(.*)$")


def pdf(url):
    data = get(url, binary=True, ttl_days=365)
    sha = hashlib.sha256(data).hexdigest()
    p = tempfile.mktemp(suffix=".pdf")
    open(p, "wb").write(data)
    txt = subprocess.run(["pdftotext", "-layout", p, "-"], capture_output=True,
                         text=True, check=True).stdout
    return sha, txt.splitlines()


def secs(lines, pattern):
    return [(i, m.group(1)) for i, l in enumerate(lines)
            if (m := re.search(pattern, l))]


def at(s, idx):
    cur = None
    for start, name in s:
        if start <= idx:
            cur = name
    return cur


def main():
    acc = datetime.date.today().isoformat()
    ysha, y = pdf(YELLOW)
    gsha, g = pdf(GREEN)
    docs = {
        "yellow": dict(url=YELLOW, sha=ysha, lines=y, end=len(y),
                       secs=secs(y, r"Narcotic Drugs Included in Schedule (I|II|IV) of the 1961"),
                       convention="Single Convention on Narcotic Drugs, 1961",
                       edition="Yellow List, 65th edition, July 2026"),
        "green": dict(url=GREEN, sha=gsha, lines=g,
                      end=next(i for i, l in enumerate(g) if l.startswith("Part two.")),
                      secs=secs(g, r"^\s*Substances in Schedule (I|II|III|IV)\s*$"),
                      convention="Convention on Psychotropic Substances of 1971",
                      edition="Green List, 36th edition, 2025"),
    }
    ident = json.load(open("phase5/identity.json"))
    out = []
    for s in ident:
        name = s.get("incb_name")
        if not name:
            continue
        rec = dict(substance_id=s["id"], incb_name=name, accessed=acc)
        hits = []
        for lst, d in docs.items():
            for i, l in enumerate(d["lines"][: d["end"]]):
                m = IDS.match(l)
                if not m:
                    continue
                # Ustunlar (2+ bo‘shliq bilan ajratilgan): CAS, INN, boshqa
                # nomlar, kimyoviy nom. Nom INN yoki boshqa nom ustunida
                # AYNAN (registrsiz) turishi shart — kimyoviy nom ichidagi
                # qism moslik hisoblanmaydi.
                cols = [c.strip() for c in re.split(r"\s{2,}", m.group(2).strip())]
                names = {x.strip().lower() for c in cols[:3] for x in c.split(",")}
                if name.lower() not in names:
                    continue
                nxt = d["lines"][i + 1] if i + 1 < len(d["lines"]) else ""
                hits.append(dict(list=lst, line=i + 1, ids_code=m.group(1),
                                 text=re.sub(r"\s+", " ", l.strip()),
                                 # Ustun keyingi qatorga ko‘chgan bo‘lishi mumkin
                                 # (masalan, «delta-9-tetrahydro- / cannabinol»).
                                 continuation=None if IDS.match(nxt) else
                                 re.sub(r"\s+", " ", nxt.strip()),
                                 schedule=at(d["secs"], i)))
        if not hits:
            rec["status"] = "not_found"
        else:
            lsts = {h["list"] for h in hits}
            if len(lsts) > 1:
                rec["status"] = "ambiguous"
            else:
                d = docs[hits[0]["list"]]
                rec.update(status="found", list=hits[0]["list"],
                           source_url=d["url"], source_sha256=d["sha"],
                           convention=d["convention"], edition=d["edition"],
                           schedules=sorted({h["schedule"] for h in hits if h["schedule"]}),
                           rows=hits)
        out.append(rec)
    json.dump(out, open("phase5/international_control.json", "w"),
              ensure_ascii=False, indent=1)
    for r in out:
        print(f"{r['substance_id']:18} {r['status']:10} {r.get('list','')} {r.get('schedules','')} {[h['text'][:70] for h in r.get('rows',[])][:2]}")


if __name__ == "__main__":
    main()
