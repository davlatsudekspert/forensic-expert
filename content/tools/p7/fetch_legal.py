#!/usr/bin/env python3
"""PHASE 7 yurisdiksiya pilot: rasmiy huquqiy matnlardan nazorat holati.

Manbalar (faqat rasmiy):
* GB — legislation.gov.uk, Misuse of Drugs Act 1971 Schedule 2 (XML, OGL).
* US — eCFR (ecfr.gov) 21 CFR 1308.11/.12/.13/.14/.15 (davlat mulki).
* DE — gesetze-im-internet.de, BtMG Anlage I–III (amtliches Werk).
* UZ — lex.uz, Qonun 813-I (1999) — faqat hujjat va 4-modda (ro‘yxat tizimi).

Qoida: modda faqat rasmiy matnda **aniq nom** (qator) topilsa yoziladi;
topilmasa — `not_found` (bu «nazoratda emas» degani EMAS). Hech narsa
taxmin qilinmaydi; har bir yozuv NEEDS LEGAL REVIEW.
"""
import datetime, hashlib, html, json, re, sys
sys.path.insert(0, "tools/p5")
import fehttp  # noqa: E402

TODAY = datetime.date.today().isoformat()
OUT = "phase7/legal.json"

# Pilot moddalar va rasmiy matndagi nom variantlari (nom tarjimasi — fakt emas;
# fakt faqat matnda topilgan qator).
NAMES = {
    "morphine": {"en": ["Morphine"], "de": ["Morphin"]},
    "heroin": {"en": ["Diamorphine", "Heroin"], "de": ["Diacetylmorphin", "Heroin"]},
    "fentanyl": {"en": ["Fentanyl"], "de": ["Fentanyl"]},
    "methadone": {"en": ["Methadone"], "de": ["Methadon", "Levomethadon"]},
    "tramadol": {"en": ["Tramadol"], "de": ["Tramadol"]},
    "cocaine": {"en": ["Cocaine", "Coca leaves"], "de": ["Cocain", "Kokain"]},
    "amphetamine": {"en": ["Amphetamine"], "de": ["Amfetamin"]},
    "methamphetamine": {"en": ["Methamphetamine", "Methylamphetamine"], "de": ["Metamfetamin"]},
    "mdma": {"en": ["3,4-Methylenedioxymethamphetamine", "N-methyl-3,4-methylenedioxyamphetamine",
                    "Methylenedioxymethamphetamine"], "de": ["Methylendioxymetamfetamin"]},
    "diazepam": {"en": ["Diazepam"], "de": ["Diazepam"]},
    "alprazolam": {"en": ["Alprazolam"], "de": ["Alprazolam"]},
    "pregabalin": {"en": ["Pregabalin"], "de": ["Pregabalin"]},
    "thc": {"en": ["Tetrahydrocannabinols", "Tetrahydrocannabinol", "Dronabinol"],
            "de": ["Dronabinol", "Tetrahydrocannabinole"]},
    "isotonitazene": {"en": ["Isotonitazene"], "de": ["Isotonitazen"]},
}


def norm(t):
    return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", t))).strip()


def entry_match(entries, names):
    """Ro‘yxat **yozuvi** nomi aniq mos kelsa (hosila nomlar emas):
    «Morphine» ✓, «Morphine methobromide» ✗, «Amphetamine, its salts…» ✓."""
    for n in names:
        rx = re.compile(r"^" + re.escape(n) + r"(\s*[,;(\[]|\.?$)", re.I)
        inc = re.compile(r"\(including " + re.escape(n) + r"\)", re.I)
        for e in entries:
            if rx.match(e) or inc.search(e):
                return n, e
    return None, None


def find(text, names):
    for n in names:
        m = re.search(r"(?<![\w-])" + re.escape(n) + r"(?![\w-])", text, re.I)
        if m:
            s = max(0, m.start() - 80)
            return n, text[s:m.end() + 120]
    return None, None


def gz_get(url):
    """eCFR siqilgan javob talab qiladi (Accept-Encoding: gzip)."""
    import gzip, os, urllib.request
    path = os.path.join(fehttp.CACHE, hashlib.sha256(("gz:" + url).encode()).hexdigest() + ".bin")
    if os.path.exists(path):
        return open(path, "rb").read()
    req = urllib.request.Request(url, headers={"User-Agent": fehttp.UA, "Accept-Encoding": "gzip"})
    with urllib.request.urlopen(req, timeout=90) as r:
        data = r.read()
        if r.headers.get("Content-Encoding") == "gzip":
            data = gzip.decompress(data)
    open(path, "wb").write(data)
    return data


def sha(b):
    return hashlib.sha256(b).hexdigest()


def gb():
    url = "https://www.legislation.gov.uk/ukpga/1971/38/schedule/2/data.xml"
    raw = fehttp.get(url, binary=True)
    x = raw.decode("utf-8", "ignore")
    parts = re.findall(r"<Part\b[^>]*>(.*?)</Part>", x, re.S)
    classes = {}
    for p in parts:
        m = re.search(r"Class ([ABC]) drugs", norm(p), re.I)
        if m:
            classes[m.group(1).upper()] = [norm(e).rstrip(".") for e in
                                           re.findall(r"<ListItem>(.*?)</ListItem>", p, re.S)]
    modified = re.search(r"<dc:modified>([^<]+)</dc:modified>", x)
    rules = []
    for sid, nm in NAMES.items():
        for cls, t in classes.items():
            hit, ctx = entry_match(t, nm["en"])
            if hit:
                rules.append(dict(substance=sid, schedule=f"Class {cls}", matched=hit, context=ctx))
                break
    return dict(jurisdiction="GB", instrument_id="GB-MDA-1971-SCH2",
                title="Misuse of Drugs Act 1971, Schedule 2 — Controlled drugs",
                authority="Parliament of the United Kingdom", number="1971 c. 38, Sch. 2",
                publication_date="1971-05-27", effective_from="1973-07-01", language="en",
                official_url="https://www.legislation.gov.uk/ukpga/1971/38/schedule/2",
                data_url=url, sha256=sha(raw),
                version=(modified.group(1) if modified else "legislation.gov.uk revised"),
                license="Open Government Licence v3.0", parts_found=sorted(classes), rules=rules)


def us():
    sec = {"1308.11": "Schedule I", "1308.12": "Schedule II", "1308.13": "Schedule III",
           "1308.14": "Schedule IV", "1308.15": "Schedule V"}
    rules, hashes, versions = [], {}, {}
    t21 = [t for t in fehttp.get("https://www.ecfr.gov/api/versioner/v1/titles.json")["titles"]
           if t["number"] == 21][0]
    asof = t21["up_to_date_as_of"]
    for s, label in sec.items():
        versions[s] = asof
        rawb = gz_get(f"https://www.ecfr.gov/api/versioner/v1/full/{asof}/title-21.xml?part=1308&section={s}")
        hashes[s] = sha(rawb)
        xml = rawb.decode("utf-8", "ignore")
        entries = [re.sub(r"^\([0-9ivxlc]+\)\s*", "", norm(c)).rstrip("*").strip()
                   for c in re.findall(r'<TD class="left">(.*?)</TD>', xml, re.S)
                   + re.findall(r"<P>(.*?)</P>", xml, re.S)]
        for sid, nm in NAMES.items():
            if any(r["substance"] == sid for r in rules):
                continue
            hit, ctx = entry_match(entries, nm["en"])
            if hit:
                rules.append(dict(substance=sid, schedule=label, section=f"21 CFR {s}", matched=hit, context=ctx))
    return dict(jurisdiction="US", instrument_id="US-21CFR1308",
                title="21 CFR Part 1308 — Schedules of Controlled Substances",
                authority="Drug Enforcement Administration (DEA), U.S. Department of Justice",
                number="21 CFR 1308.11–1308.15", language="en",
                official_url="https://www.ecfr.gov/current/title-21/chapter-II/part-1308",
                section_versions=versions, sha256=hashes, license="U.S. Government work (public domain)",
                rules=rules)


def de():
    rules, hashes = [], {}
    for an, label in [("anlage_i", "Anlage I"), ("anlage_ii", "Anlage II"), ("anlage_iii", "Anlage III")]:
        url = f"https://www.gesetze-im-internet.de/btmg_1981/{an}.html"
        rawb = fehttp.get(url, binary=True)
        hashes[label] = sha(rawb)
        doc = rawb.decode("iso-8859-1", "ignore")
        cells = [norm(c) for c in re.findall(r"<td[^>]*>(.*?)</td>", doc, re.S)]
        for sid, nm in NAMES.items():
            if any(r["substance"] == sid for r in rules):
                continue
            hit, ctx = entry_match(cells, nm["de"])
            if hit:
                rules.append(dict(substance=sid, schedule=label, matched=hit, context=ctx))
    return dict(jurisdiction="DE", instrument_id="DE-BTMG-ANL",
                title="Betäubungsmittelgesetz (BtMG), Anlagen I–III",
                authority="Bundesministerium der Justiz (Veröffentlichung)", number="BtMG 1981, Anlagen I–III",
                publication_date="1981-07-28", language="de",
                official_url="https://www.gesetze-im-internet.de/btmg_1981/",
                sha256=hashes, license="Amtliches Werk (§ 5 UrhG)", rules=rules)


def uz():
    url = "https://lex.uz/docs/86028"
    rawb = fehttp.get(url, binary=True)
    t = norm(rawb.decode("utf-8", "ignore"))
    i = t.find("Наркотические средства, психотропные вещества и прекурсоры, подлежащие контролю в Республике Узбекистан, вносятся")
    art4 = t[i:i + 700] if i >= 0 else None
    title = re.search(r"813-I-сон 19\.08\.1999\.\s*(О наркотических средствах и психотропных веществах)", t)
    return dict(jurisdiction="UZ", instrument_id="UZ-LAW-813-I",
                title="Закон Республики Узбекистан «О наркотических средствах и психотропных веществах»",
                authority="Олий Мажлис Республики Узбекистан", number="№ 813-I",
                publication_date="1999-08-19", language="ru",
                official_url=url, sha256=sha(rawb), license="Rasmiy hujjat (mualliflik huquqi obyekti emas)",
                title_verified=bool(title), article_4_excerpt=art4,
                note="Nazorat ro‘yxatlari (I–IV) alohida Vazirlar Mahkamasi hujjatida — bu pilotda modda "
                     "bo‘yicha xaritalanmagan. ПЗ-246 qonun loyihasi kuchga kirmagan.",
                rules=[])


if __name__ == "__main__":
    out = dict(checked=TODAY, jurisdictions=[gb(), us(), de(), uz()])
    json.dump(out, open(OUT, "w"), ensure_ascii=False, indent=1)
    for j in out["jurisdictions"]:
        print(j["jurisdiction"], len(j["rules"]), [(r["substance"], r["schedule"]) for r in j["rules"]])
