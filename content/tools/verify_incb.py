#!/usr/bin/env python3
"""Xalqaro nazorat holatini INCB rasmiy ro‘yxatlaridan dasturiy tekshiradi.

* Yellow List (1961 yilgi Yagona konvensiya, giyohvand vositalar).
* Green List (1971 yilgi Psixotrop moddalar konvensiyasi).

PDF yuklanadi, SHA-256 yoziladi, `pdftotext -layout` bilan matnga
aylantiriladi va har bir pilot modda uchun **aniq qator** (IDS kodi + CAS +
nom) va qaysi bo‘lim (Schedule) ichida ekani topiladi. Topilmasa — claim
yaratilmaydi (yo‘qlik «nazoratda emas» degani EMAS).

Natija: content/pilot/international_control.generated.json
"""
import datetime, hashlib, json, re, subprocess, sys, tempfile, urllib.request

YELLOW = ("https://www.incb.org/incb/uploads/documents/Narcotic-Drugs/"
          "Yellow_List/65th_Edition/YL_65th_EN_unedited.pdf")
GREEN = ("https://www.incb.org/incb/uploads/documents/Psychotropics/forms/"
         "greenlist/2026/2510307E.pdf")

# (substance_id, ro‘yxat, qatordagi nom regex’i, IDS kodi)
TARGETS = [
    ("morphine", "yellow", r"MORPHINE", "NM 009"),
    ("heroin", "yellow", r"HEROIN", "NH 001"),
    ("fentanyl", "yellow", r"FENTANYL", "NF 001"),
    ("cocaine", "yellow", r"COCAINE", "NC 004"),
    ("methamphetamine", "green", r"METAMFETAMINE", "PM 005"),
    ("thc", "green", r"delta-9-tetrahydro-", "PD 010"),
    ("alprazolam", "green", r"ALPRAZOLAM", "PA 004"),
    ("phenazepam", "green", r"phenazepam", "PP 024"),
]


def fetch(url, tmp):
    path = f"{tmp}/{hashlib.md5(url.encode()).hexdigest()}.pdf"
    with urllib.request.urlopen(url, timeout=60) as r, open(path, "wb") as f:
        f.write(r.read())
    sha = hashlib.sha256(open(path, "rb").read()).hexdigest()
    txt = subprocess.run(["pdftotext", "-layout", path, "-"],
                         capture_output=True, text=True, check=True).stdout
    return sha, txt.splitlines()


def sections(lines, pattern):
    """(boshlanish qatori, schedule nomi) ro‘yxati."""
    out = []
    for i, l in enumerate(lines):
        m = re.search(pattern, l)
        if m:
            out.append((i, m.group(1)))
    return out


def schedule_at(secs, idx):
    current = None
    for start, name in secs:
        if start <= idx:
            current = name
    return current


def main():
    accessed = datetime.date.today().isoformat()
    tmp = tempfile.mkdtemp()
    docs = {}
    y_sha, y = fetch(YELLOW, tmp)
    docs["yellow"] = dict(
        url=YELLOW, sha256=y_sha, lines=y,
        secs=sections(y, r"Narcotic Drugs Included in Schedule (I|II|IV) of the 1961"),
        instrument="INT-UN-1961", edition="Yellow List, 65th edition, July 2026")
    g_sha, g = fetch(GREEN, tmp)
    gsecs = sections(g, r"^\s*Substances in Schedule (I|II|III|IV)\s*$")
    part2 = next(i for i, l in enumerate(g) if l.startswith("Part two."))
    docs["green"] = dict(
        url=GREEN, sha256=g_sha, lines=g, secs=gsecs, part1_end=part2,
        instrument="INT-UN-1971", edition="Green List, 36th edition, 2025")

    out = []
    for sid, lst, name_re, ids in TARGETS:
        d = docs[lst]
        hits = []
        for i, l in enumerate(d["lines"]):
            if l.strip().startswith(ids) and re.search(name_re, l):
                if lst == "green" and i >= d["part1_end"]:
                    continue
                hits.append((i, l.strip(), schedule_at(d["secs"], i)))
        rec = dict(substance_id=sid, list=lst, instrument_id=d["instrument"],
                   edition=d["edition"], source_url=d["url"],
                   source_sha256=d["sha256"], accessed=accessed,
                   ids_code=ids)
        if not hits:
            rec["status"] = "not_found"
        else:
            rec["status"] = "found"
            rec["schedules"] = sorted({h[2] for h in hits})
            rec["rows"] = [dict(line=h[0] + 1, text=re.sub(r"\s+", " ", h[1]),
                                schedule=h[2]) for h in hits]
        out.append(rec)
    json.dump(out, open("pilot/international_control.generated.json", "w"),
              ensure_ascii=False, indent=2)
    for r in out:
        print(r["substance_id"], r["status"], r.get("schedules"))
    return 0 if all(r["status"] == "found" for r in out) else 1


if __name__ == "__main__":
    sys.exit(main())
