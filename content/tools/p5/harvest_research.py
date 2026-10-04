#!/usr/bin/env python3
"""PHASE 5: Research / Evidence Library — faqat METADATA.

Manbalar (qonuniy, ochiq API):
* PubMed (E-utilities): maqolalar, review, systematic review, case report,
  konferensiya tezislari (publication type «Congress»).
* Crossref: dissertatsiyalar (PhD → dissertation, boshqa daraja → thesis),
  konferensiya maqolalari (proceedings-article).
* Europe PMC (SRC:ETH): Britaniya universitetlari dissertatsiyalari.

To‘liq matn yoki annotatsiya ko‘chirilmaydi: sarlavha, mualliflar, tashkilot,
nashr, sana, identifikatorlar va rasmiy havola. Dalil darajasi turga qarab:
systematic review / meta-analysis → A; peer-reviewed tadqiqot → B;
narrativ review → C; case report → D; konferensiya tezisi, dissertatsiya,
tezis → E (peer-reviewed to‘liq maqola bilan teng EMAS).

Dublikatlar: DOI → PMID → Handle → normallashtirilgan sarlavha + 1-muallif.

Foydalanish: harvest_research.py [pubmed|crossref|epmc|all]
Chiqish: phase5/research_<part>.json
"""
import datetime, json, re, sys, time, urllib.parse

sys.path.insert(0, __file__.rsplit("/", 1)[0])
from fehttp import get  # noqa: E402

ACC = datetime.date.today().isoformat()
# Kamida bitta kuchli sud-tibbiy atama bo‘lishi shart.
TOPICAL = re.compile(
    r"forensic|toxicolog|autops|medico-?legal|overdose|intoxicat|poisoning|"
    r"cadaver|decedent|psychoactive|drugs? of abuse|opioid|fentanyl|cannabin|"
    r"cocaine|amphetamine|benzodiazepine|time since death|human remains|"
    r"skeletal remains|odontolog|anthropolog|wound age|seized|"
    r"post-?mortem (interval|redistribution|toxicolog|biochem|imaging|changes|blood|vitreous|specimens?)|"
    r"postmortem (interval|redistribution|toxicolog|biochem|imaging|changes|blood|vitreous|specimens?)|"
    r"redistribui|toxicol[oó]gic|forense|m[eé]dico-?legal|necr[oó]psia", re.I)
EXCLUDE = re.compile(
    r"\b(pork|meat|carcass|beef|bovine|swine|pigs?|poultry|fish|cattle|lamb|broiler|"
    r"fotografia|photograph\w*|derrida|love|literary|novel by|poetry|veterinar\w*)\b", re.I)
DOCTORAL = re.compile(r"ph\.?\s?d|doctor|doutor|doktor|dr\.|doctorat|kandidat", re.I)


# Hayotiy fan (toksikologiya / tibbiyot / antropologiya) sharti.
LIFE = re.compile(
    r"toxicolog|toxicol[oó]gic|post-?mortem|autops(y|ies)\b(?! (tsk|tools?|mobile))|"
    r"drugs?|psychoactive|opioid|fentanyl|cannabin|cocaine|amphetamine|"
    r"benzodiazepine|barbitur|methamphetamine|morphine|alcohol|ethanol|"
    r"poison|intoxicat|overdose|decompos|skelet|bones?|dental|odontolog|"
    r"anthropolog|histolog|wound|injur|patholog|cadaver|decedent|vitreous|"
    r"blood|urine|chromatograph|mass spectrom|time since death|remains|"
    r"medico-?legal|forensic medic|redistribui|necr[oó]psia", re.I)
NON_LIFE = re.compile(
    r"engineer|digital|network|camera|smartphone|whatsapp|software|scada|hmi|"
    r"linguistic|psycholog|psychiatr|assertive community|juror|eyewitness|"
    r"legal status|prevention|school|adolescent|awareness|valve|laser|"
    r"icosahedral|droplet|border|trafficking|counterf|harm perception|"
    r"epidemiology of|front matter|awards?|division|association of|"
    r"cerebrovascular|parrot|vulture|missing persons|road safety|cluster analysis|"
    r"quantum|communication|expertolog|customs|private|tiktok|serbia after|"
    r"productivity|ergonomic|institutional autopsy|mental health|law on|risk factors|"
    r"characteristics of the use|landscape|socio-political", re.I)


def topical(title):
    return (bool(TOPICAL.search(title)) and bool(LIFE.search(title))
            and not EXCLUDE.search(title) and not NON_LIFE.search(title))


CROSSREF_QUERIES = [
    "forensic toxicology postmortem", "postmortem interval estimation",
    "forensic pathology autopsy", "forensic histology", "postmortem biochemistry vitreous",
    "LC-MS/MS drugs blood forensic", "seized drugs analysis", "new psychoactive substances",
    "disaster victim identification", "forensic anthropology skeletal", "drug-facilitated crime",
]
EPMC_QUERIES = [
    '"forensic toxicology"', '"post-mortem" toxicology', '"postmortem interval"',
    '"forensic pathology"', '"new psychoactive substances"', 'forensic drug analysis',
    'forensic anthropology', 'forensic histology OR "wound age"',
]


def evidence(kind):
    return {"systematic_review": "A", "meta_analysis": "A", "journal_article": "B",
            "review": "C", "case_report": "D", "conference_abstract": "E",
            "conference_paper": "E", "dissertation": "E", "thesis": "E"}.get(kind, "E")


def norm_title(t):
    return re.sub(r"[^a-z0-9]+", " ", (t or "").lower()).strip()


def rec(**k):
    k.setdefault("authors", [])
    k.setdefault("links", [])
    k["evidence_level"] = evidence(k["kind"])
    k["peer_reviewed"] = k["kind"] in ("journal_article", "review", "systematic_review",
                                       "meta_analysis", "case_report")
    k["accessed"] = ACC
    k["review_status"] = "NEEDS_REVIEW"
    return k


# ---------------------------------------------------------------- PubMed
def pubmed():
    ident = json.load(open("phase5/identity.json"))
    topics = json.load(open("phase5/spec_topics.json"))
    spec = json.load(open("phase5/spec_substances.json"))
    alias = {}
    for t in spec:
        if t["field"] == "metabolism":
            alias[t["entity"]] = t["query"].split(") AND")[0].strip("(")
    jobs = []
    for s in ident:
        q = f"({alias[s['id']].replace('[Title/Abstract]', '[Title]')}) AND (forensic OR postmortem OR fatal OR autopsy OR intoxication OR poisoning)"
        jobs.append((q, [s["id"]], 4))
    seen_ent = set()
    for t in topics:
        if t["entity"] in seen_ent:
            continue
        seen_ent.add(t["entity"])
        jobs.append((t["query"], [t["entity"]], 3))
    jobs.append(('"Congress"[Publication Type] AND ("forensic toxicology" OR "postmortem")', [], 15))
    jobs.append(('"Systematic Review"[Publication Type] AND (forensic[Title] OR postmortem[Title])', [], 25))
    out = []
    for i, (q, links, n) in enumerate(jobs):
        try:
            ids = get("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&retmode=json"
                      f"&sort=relevance&retmax={n}&term=" + urllib.parse.quote(q))["esearchresult"]["idlist"]
            time.sleep(0.35)
            if not ids:
                continue
            res = get("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&retmode=json&id="
                      + ",".join(ids))["result"]
            time.sleep(0.35)
        except Exception as e:  # noqa: BLE001
            print("ERR", q[:60], e)
            continue
        for pid in ids:
            r = res.get(pid)
            if not r or "error" in r:
                continue
            pts = [p.lower() for p in r.get("pubtype", [])]
            kind = ("meta_analysis" if "meta-analysis" in pts else
                    "systematic_review" if "systematic review" in pts else
                    "review" if "review" in pts else
                    "case_report" if "case reports" in pts else
                    "conference_abstract" if "congress" in pts else
                    "journal_article")
            ids2 = {a["idtype"]: a["value"] for a in r.get("articleids", [])}
            out.append(rec(kind=kind, title=r.get("title", "").rstrip("."),
                           authors=[a["name"] for a in r.get("authors", [])][:8],
                           container=r.get("fulljournalname") or r.get("source"),
                           year=(r.get("pubdate") or "")[:4], date=r.get("sortpubdate", "")[:10].replace("/", "-"),
                           doi=ids2.get("doi"), pmid=pid, pmcid=ids2.get("pmc"),
                           url=f"https://pubmed.ncbi.nlm.nih.gov/{pid}/",
                           open_access="pmc" if ids2.get("pmc") else "unknown",
                           source_api="pubmed", links=list(links)))
        print(f"[{i + 1}/{len(jobs)}] {len(out)}", flush=True)
    return out


# ---------------------------------------------------------------- Crossref
def crossref():
    out = []
    for q in CROSSREF_QUERIES:
        for typ in ("dissertation", "proceedings-article"):
            url = (f"https://api.crossref.org/works?query={urllib.parse.quote(q)}"
                   f"&filter=type:{typ}&rows=15")
            try:
                items = get(url)["message"]["items"]
            except Exception as e:  # noqa: BLE001
                print("ERR", q, typ, e)
                continue
            for it in items:
                title = (it.get("title") or [""])[0]
                if not title or not topical(title):
                    continue
                deg = " ".join(it.get("degree") or [])
                if typ == "dissertation":
                    kind = "dissertation" if DOCTORAL.search(deg) else "thesis"
                    org = ", ".join(x.get("name", "") for x in it.get("institution") or []) or it.get("publisher")
                    container = None
                else:
                    kind = "conference_paper"
                    org = None
                    container = ((it.get("container-title") or [None])[0]
                                 or (it.get("event") or {}).get("name"))
                dp = (it.get("issued", {}).get("date-parts") or [[None]])[0]
                if not dp or dp[0] is None:
                    dp = (it.get("approved", {}).get("date-parts") or [[None]])[0]
                year = str(dp[0]) if dp and dp[0] else ""
                authors = [" ".join(x for x in (a.get("family"), a.get("given")) if x)
                           for a in it.get("author", []) if a.get("family")]
                out.append(rec(kind=kind, title=title, authors=authors[:8], organization=org,
                               container=container, year=year, doi=it.get("DOI"),
                               degree=deg or None, url=it.get("URL"),
                               open_access="unknown", source_api="crossref"))
        print("crossref", q, len(out), flush=True)
    return out


# ---------------------------------------------------------------- Europe PMC
def epmc():
    out = []
    for q in EPMC_QUERIES:
        url = ("https://www.ebi.ac.uk/europepmc/webservices/rest/search?format=json&pageSize=15"
               "&resultType=core&query=" + urllib.parse.quote(f"({q}) AND SRC:ETH"))
        try:
            res = get(url)["resultList"]["result"]
        except Exception as e:  # noqa: BLE001
            print("ERR", q, e)
            continue
        for r in res:
            title = (r.get("title") or "").rstrip(".")
            if not topical(title):
                continue
            pub = (r.get("bookOrReportDetails") or {}).get("publisher")
            links = [u["url"] for u in (r.get("fullTextUrlList") or {}).get("fullTextUrl", [])]
            authors = [a.get("fullName") for a in (r.get("authorList") or {}).get("author", [])]
            out.append(rec(kind="dissertation", title=title, authors=authors[:4], organization=pub,
                           year=r.get("pubYear"), doi=r.get("doi"),
                           handle=f"ETH:{r['id']}",
                           url=links[0] if links else f"https://europepmc.org/abstract/ETH/{r['id']}",
                           open_access="free_link" if links else "unknown", source_api="europepmc"))
        print("epmc", q, len(out), flush=True)
    return out


def main():
    part = sys.argv[1] if len(sys.argv) > 1 else "all"
    fns = {"pubmed": pubmed, "crossref": crossref, "epmc": epmc}
    for name, fn in fns.items():
        if part in (name, "all"):
            json.dump(fn(), open(f"phase5/research_{name}.json", "w"), ensure_ascii=False, indent=1)


if __name__ == "__main__":
    main()
