#!/usr/bin/env python3
"""Validate content/court_prep/court_prep_v1.json (fe-court-prep/2).

Checks (exit code 1 on any error):
  C001 schema id is fe-court-prep/2
  C002 every status is NEEDS_REVIEW; no HUMAN_VERIFIED / VERIFIED / REVIEWED
       status anywhere in the bundle
  C003 topic title/summary, question, "tests" and short answer in uz, ru, en
  C004 card structure: documents/explain/pitfalls non-empty; 2-5 follow-ups
       each with question and answer; >= 1 limitation; all items tri-lingual
  C005 every question cites >= 1 reference; every inline [key] exists in the
       shared registry and in the embedded references
  C006 every embedded reference has verified_via + verified_on; doi/pmid
       well-formed
  C007 links resolve (guideline ids, tool ids, allowed pages)
  C008 Q&A cards are free: no question carries a paywall "sample" flag
  C009 30-60 questions; unique ids; ready topics have >= 1 question, pending
       topics have none; jurisdiction in ALL/UZ/INTL and the rights topic has
       both UZ and INTL questions
  C010 Uzbek text uses U+2018 for o‘/g‘
  C011 no reference to the restricted 'ABY' manual
  C012 translation_status valid; updated is yyyy-mm-dd
  C013 built file and app asset are in sync with src/ (re-run build.py)
  C014 no prescriptive verdict phrasing
  C015 claim->source mapping: every cited key of a question/principle/scenario
       has a locator; a null locator ("Manba tekshirilmagan" in the UI) is
       allowed only for references whose text could not be read; locator
       tokens are well-formed
  C016 integrity principles: >= 5, each cited
  C017 simulator: roles judge/prosecutor/defense/expert all present; 2-4
       options; scores 0-2 on the 4 criteria; exactly one best option scoring
       full marks; every feedback cited; linked question exists; 1-3 free
       basic scenarios
  C018 the simulator never rates an unverified point as correct: the best
       option must not rely on a reference whose location is unverified, and
       no feedback opens with an absolute verdict ("To‘g‘ri", "Correct", "Верно")
"""
import json
import pathlib
import re
import subprocess
import sys

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
ASSET = ROOT / "apps/mobile/assets/content/court_prep/court_prep_v1.json"
LANGS = ("uz", "ru", "en")
BLOCKS = ("documents", "explain", "pitfalls")
PAGES = {"sources", "specimens", "standards", "conflicts"}
CRITERIA = ("accuracy", "sources", "limitations", "impartiality")
ROLES = {"judge", "prosecutor", "defense", "expert"}
# References cited only by title/edition (text not readable here).
LOCATOR_NULL_OK = {"court_iso17025_2017"}
LOCATOR = re.compile(r"^(abstract|scope|title|glossary|art:\d+(:\d+)?|sec:.+|pdfp:\d+|pp:\d+(-\d+)?|rec:\d+|gn:\d+)$")
INLINE = re.compile(r"\[([a-z0-9_]+(?:,\s*[a-z0-9_]+)*)\]")
PRESCRIPTIVE = [
    re.compile(p, re.I) for p in (
        r"\bthe correct conclusion is\b", r"\byou must conclude\b",
        r"\banswer that the (defendant|accused)\b", r"\bxulosa shunday bo‘lishi kerak\b",
        r"\bвывод должен быть таким\b",
    )
]

errors: list[str] = []


def err(code, where, msg):
    errors.append(f"{code} {where}: {msg}")


def tri(obj, code, where):
    if not isinstance(obj, dict):
        err(code, where, "missing language map")
        return
    for lang in LANGS:
        v = obj.get(lang)
        if not isinstance(v, str) or not v.strip():
            err(code, where, f"empty or missing '{lang}'")


def check_uz(text, where):
    for bad in ("o'", "g'", "O'", "G'", "o`", "g`", "oʻ", "gʻ", "o’", "g’"):
        if bad in text:
            err("C010", where, f"Uzbek apostrophe convention: found {bad!r}; use U+2018")
            return


def inline_keys(obj):
    out = set()
    if isinstance(obj, dict):
        for lang in LANGS:
            for grp in INLINE.findall(obj.get(lang, "")):
                out |= {k.strip() for k in grp.split(",")}
    return out


def tool_ids():
    src = (ROOT / "apps/mobile/lib/domain/catalog/tools_catalog.dart").read_text(encoding="utf-8")
    return set(re.findall(r"id: '(tool\.[a-z_.]+)'", src))


def guideline_ids():
    g = json.loads((ROOT / "content/guidelines/guidelines_v1.json").read_text(encoding="utf-8"))
    return {c["id"] for c in g["cards"]}


def check_texts(owner, texts, refs):
    for obj in texts:
        for k in inline_keys(obj):
            if k not in refs:
                err("C005", owner, f"inline [{k}] not in references")
        if isinstance(obj, dict):
            for lang in LANGS:
                for rx in PRESCRIPTIVE:
                    if rx.search(obj.get(lang, "")):
                        err("C014", f"{owner}.{lang}", rx.pattern)
            if obj.get("uz"):
                check_uz(obj["uz"], owner)


def check_claims(owner, item):
    loc = item.get("locators", {})
    for k in item.get("citations", []):
        if k not in loc:
            err("C015", owner, f"no locator for {k!r}")
            continue
        v = loc[k]
        if v is None:
            if k not in LOCATOR_NULL_OK:
                err("C015", owner, f"null locator for verified reference {k!r}")
            continue
        if not isinstance(v, list) or not v:
            err("C015", owner, f"locator for {k!r} must be a non-empty list or null")
            continue
        for tok in v:
            if not LOCATOR.match(str(tok)):
                err("C015", owner, f"malformed locator {tok!r} for {k!r}")
    for c in item.get("claims", []):
        for s in c["sources"]:
            if s.get("support") != "full":
                err("C015", c["id"], "only fully supporting sources may be cited")


def main():
    data = json.loads((HERE / "court_prep_v1.json").read_text(encoding="utf-8"))
    if data.get("schema") != "fe-court-prep/2":
        err("C001", "root", "schema must be fe-court-prep/2")
    blob = json.dumps(data, ensure_ascii=False)
    if re.search(r'"status":\s*"(HUMAN_VERIFIED|VERIFIED|REVIEWED)"', blob):
        err("C002", "root", "forbidden status value present")
    if re.search(r"\bABY\b", blob):
        err("C011", "root", "reference to restricted ABY manual found")

    refs = {r["key"]: r for r in data.get("references", [])}
    registry = {r["key"] for r in json.loads(
        (ROOT / "content/guidelines/references.json").read_text(encoding="utf-8"))["references"]}
    for key, r in refs.items():
        if key not in registry:
            err("C005", key, "embedded reference not in registry")
        if not r.get("verified_via") or not r.get("verified_on"):
            err("C006", key, "verified_via / verified_on missing")
        doi = r.get("doi")
        if doi is not None and not re.match(r"^10\.\d{4,9}/\S+$", doi):
            err("C006", key, f"malformed doi {doi!r}")
        pmid = r.get("pmid")
        if pmid is not None and not re.fullmatch(r"\d+", str(pmid)):
            err("C006", key, f"malformed pmid {pmid!r}")
        for f in ("authors", "title", "year"):
            if not r.get(f):
                err("C006", key, f"missing {f}")

    topics = data["topics"]
    questions = data["questions"]
    tids = [t["id"] for t in topics]
    if len(set(tids)) != len(tids):
        err("C009", "topics", "duplicate topic id")
    if not 30 <= len(questions) <= 60:
        err("C009", "questions", f"expected 30-60 questions, got {len(questions)}")
    for t in topics:
        tri(t.get("title"), "C003", f"{t['id']}.title")
        tri(t.get("summary"), "C003", f"{t['id']}.summary")
        check_uz(t["title"]["uz"] + " " + t["summary"]["uz"], t["id"])
        n = sum(1 for q in questions if q["topic"] == t["id"])
        if t.get("pending") and n:
            err("C009", t["id"], "pending topic must not have questions")
        if not t.get("pending") and n < 1:
            err("C009", t["id"], "ready topic has no questions")

    tools, guides = tool_ids(), guideline_ids()
    seen, samples = set(), []
    for q in questions:
        qid = q["id"]
        if qid in seen:
            err("C009", qid, "duplicate question id")
        seen.add(qid)
        if q["topic"] not in tids:
            err("C009", qid, "unknown topic")
        if q.get("jurisdiction") not in {"ALL", "UZ", "INTL"}:
            err("C009", qid, "jurisdiction must be ALL, UZ or INTL")
        if q.get("status") != "NEEDS_REVIEW":
            err("C002", qid, f"status must be NEEDS_REVIEW, got {q.get('status')!r}")
        if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", str(q.get("updated", ""))):
            err("C012", qid, "updated must be yyyy-mm-dd")
        for lang in LANGS:
            if q.get("translation_status", {}).get(lang) not in {"AUTHORED", "DRAFT", "REVIEWED"}:
                err("C012", qid, f"translation_status.{lang} invalid")
        if q.get("sample"):
            samples.append(q)
        tri(q.get("question"), "C003", f"{qid}.question")
        tri(q.get("tests"), "C003", f"{qid}.tests")
        tri(q.get("short_answer"), "C003", f"{qid}.short_answer")
        texts = [q.get("question", {}), q.get("tests", {}), q.get("short_answer", {})]
        for b in BLOCKS:
            items = q["prepare"].get(b) or []
            if not items:
                err("C004", qid, f"prepare.{b} is empty")
            for i, it in enumerate(items):
                tri(it, "C004", f"{qid}.{b}[{i}]")
                texts.append(it)
        fus = q.get("followups", [])
        if not 2 <= len(fus) <= 5:
            err("C004", qid, f"expected 2-5 follow-ups, got {len(fus)}")
        for i, f in enumerate(fus):
            tri(f.get("q"), "C004", f"{qid}.followup[{i}].q")
            tri(f.get("a"), "C004", f"{qid}.followup[{i}].a")
            texts += [f.get("q", {}), f.get("a", {})]
        lims = q.get("limitations", [])
        if not lims:
            err("C004", qid, "no limitations")
        for i, it in enumerate(lims):
            tri(it, "C004", f"{qid}.limitation[{i}]")
            texts.append(it)
        if not q.get("citations"):
            err("C005", qid, "no citations")
        check_texts(qid, texts, refs)
        check_claims(qid, q)
        for link in q.get("links", []):
            kind, _, ident = link.partition(":")
            ok = (kind == "guideline" and ident in guides) or \
                 (kind == "tool" and ident in tools) or \
                 (kind == "page" and ident in PAGES)
            if not ok:
                err("C007", qid, f"unresolved link {link!r}")
    rights = [q for q in questions if q["topic"] == "court.topic.rights"]
    if {q["jurisdiction"] for q in rights} != {"UZ", "INTL"}:
        err("C009", "court.topic.rights", "needs both UZ and INTL questions")

    if samples:
        err("C008", "questions", "Q&A cards are free; remove 'sample' flags")

    principles = data.get("principles", [])
    if len(principles) < 5:
        err("C016", "principles", "expected >= 5 integrity principles")
    for p in principles:
        tri(p.get("text"), "C016", p["id"])
        if not p.get("citations"):
            err("C016", p["id"], "uncited principle")
        check_texts(p["id"], [p["text"]], refs)
        check_claims(p["id"], p)

    sim = data.get("simulator", {})
    scenarios = sim.get("scenarios", [])
    if {s["role"] for s in scenarios} != ROLES:
        err("C017", "simulator", f"roles must be exactly {sorted(ROLES)}")
    nsample = sum(1 for s in scenarios if s.get("sample"))
    if not 1 <= nsample <= 3:
        err("C017", "simulator", "expected 1-3 free sample scenarios")
    for s in scenarios:
        sid = s["id"]
        if s.get("question_id") not in seen:
            err("C017", sid, "linked question does not exist")
        tri(s.get("context"), "C017", f"{sid}.context")
        tri(s.get("prompt"), "C017", f"{sid}.prompt")
        opts = s.get("options", [])
        if not 2 <= len(opts) <= 4:
            err("C017", sid, "expected 2-4 options")
        best = 0
        for i, o in enumerate(opts):
            tri(o.get("text"), "C017", f"{sid}.option[{i}]")
            tri(o.get("feedback"), "C017", f"{sid}.feedback[{i}]")
            if not inline_keys(o.get("feedback")):
                err("C017", sid, f"feedback[{i}] uncited")
            sc = o.get("scores", {})
            if set(sc) != set(CRITERIA) or any(v not in (0, 1, 2) for v in sc.values()):
                err("C017", sid, f"option[{i}] scores must be 0-2 for {CRITERIA}")
            if sum(sc.values()) == 2 * len(CRITERIA):
                best += 1
            check_texts(sid, [o.get("text", {}), o.get("feedback", {})], refs)
        if best != 1:
            err("C017", sid, f"exactly one best option required, got {best}")
        nulls = {k for k, v in s.get("locators", {}).items() if v is None}
        for i, o in enumerate(opts):
            fb = o.get("feedback", {})
            if sum(o.get("scores", {}).values()) == 2 * len(CRITERIA) and inline_keys(fb) & nulls:
                err("C018", sid, f"best option[{i}] relies on an unverified source")
            for lang in LANGS:
                if re.match(r"^(To‘g‘ri|Correct|Верно)\b", fb.get(lang, "")):
                    err("C018", f"{sid}.{lang}", "feedback must not open with an absolute verdict")
        check_claims(sid, s)

    before = (HERE / "court_prep_v1.json").read_bytes()
    asset_before = ASSET.read_bytes() if ASSET.exists() else b""
    subprocess.run([sys.executable, str(HERE / "build.py")], check=True, capture_output=True)
    after = (HERE / "court_prep_v1.json").read_bytes()
    if before != after or asset_before != after:
        err("C013", "court_prep_v1.json", "was out of date; rebuilt — commit the new files")

    unverified = sorted({k for q in questions for k, v in q["locators"].items() if v is None})
    print(f"topics={len(topics)} (pending={sum(1 for t in topics if t.get('pending'))}) "
          f"questions={len(questions)} samples={len(samples)} principles={len(principles)} "
          f"scenarios={len(scenarios)} references={len(refs)} "
          f"claims={sum(len(q['claims']) for q in questions)} null_locators={unverified}")
    if errors:
        print(f"FAILED: {len(errors)} error(s)")
        for e in errors:
            print("  " + e)
        return 1
    print("OK: all checks passed (C001-C018)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
