#!/usr/bin/env python3
"""Validate content/guidelines/guidelines_v1.json (fe-guidelines/1).

Checks (exit code 1 on any error):
  G001 schema id is fe-guidelines/1
  G002 card status is NEEDS_REVIEW (no human review has been recorded)
  G003 title / summary / every section title and body present and non-empty in uz, ru, en
  G004 every section citation key and every inline [key] in a body exists in references
  G005 every inline [key] in a body is also listed in that section's citations
  G006 every reference has verified_via and verified_on; no fabricated identifiers
       (doi must look like 10.x/..., pmid must be digits, or null)
  G007 translation_status present for uz/ru/en with allowed values
  G008 discipline codes exist in packages/fe_content_schema/lib/src/taxonomy.dart
  G009 keywords present (non-empty list) for uz, ru, en
  G010 Uzbek text uses U+2018 for o‘/g‘ (no ASCII ' or backtick or U+02BB after o/g)
  G011 updated date is ISO yyyy-mm-dd
  G012 no reference to the restricted 'ABY' manual
  G013 built file is in sync with src/ and references.json (re-run build.py)
  G014 quiz items: unique id, question/answer/3 distractors in uz/ru/en, answer
       differs from distractors, every citation key is cited by the card
  G015 page-cited book sources (PAGE_CITED): the key stands alone in its
       brackets and is followed by a page locator in the body language
  G016 cards citing a FREE_SOURCES key declare source_access.access == "free"
       (owner decision 2026-10-09: author-permitted material is free for all)
"""
import json
import pathlib
import re
import sys

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
LANGS = ("uz", "ru", "en")
TRANSLATION_VALUES = {"AUTHORED", "DRAFT", "REVIEWED"}
INLINE = re.compile(r"\[([a-z0-9_]+(?:,\s*[a-z0-9_]+)*)\]")

errors: list[str] = []

# G015: textbook cited with printed page numbers, e.g. "[key] (23-b.)",
# "[key] (с. 23–24)", "[key] (pp. 23, 27)".
PAGE_CITED = {"gmt_yuldashev2024"}
PAGES = r"\d+(?:[–-]\d+)?(?:, ?\d+(?:[–-]\d+)?)*"
LOCATOR = {
    "uz": re.compile(r"\s\(" + PAGES + r"-b\.\)"),
    "ru": re.compile(r"\s\(с\. " + PAGES + r"\)"),
    "en": re.compile(r"\s\(pp?\. " + PAGES + r"\)"),
}
# G016: sources whose derived content must be free for everyone.
FREE_SOURCES = {"gmt_yuldashev2024"}


def err(code: str, where: str, msg: str) -> None:
    errors.append(f"{code} {where}: {msg}")


def tri(obj, code, where):
    if not isinstance(obj, dict):
        err(code, where, "missing language map")
        return
    for lang in LANGS:
        v = obj.get(lang)
        if not isinstance(v, str) or not v.strip():
            err(code, where, f"empty or missing '{lang}'")


def taxonomy_codes() -> set[str]:
    src = (ROOT / "packages/fe_content_schema/lib/src/taxonomy.dart").read_text(encoding="utf-8")
    block = src.split("enum ForensicDiscipline", 1)[1].split(";", 1)[0]
    return set(re.findall(r"'([a-z_]+)'", block))


def check_uz(text: str, where: str) -> None:
    for bad in ("o'", "g'", "O'", "G'", "o`", "g`", "oʻ", "gʻ", "o’", "g’"):
        if bad in text:
            err("G010", where, f"Uzbek apostrophe convention: found {bad!r}; use U+2018")
            return


def main() -> int:
    data = json.loads((HERE / "guidelines_v1.json").read_text(encoding="utf-8"))
    if data.get("schema") != "fe-guidelines/1":
        err("G001", "root", "schema must be fe-guidelines/1")

    refs = {r["key"]: r for r in data.get("references", [])}
    for key, r in refs.items():
        if not r.get("verified_via") or not r.get("verified_on"):
            err("G006", key, "verified_via / verified_on missing")
        doi = r.get("doi")
        if doi is not None and not re.match(r"^10\.\d{4,9}/\S+$", doi):
            err("G006", key, f"malformed doi {doi!r}")
        pmid = r.get("pmid")
        if pmid is not None and not re.fullmatch(r"\d+", str(pmid)):
            err("G006", key, f"malformed pmid {pmid!r}")
        for f in ("authors", "title", "year"):
            if not r.get(f):
                err("G006", key, f"missing {f}")

    codes = taxonomy_codes()
    ids = set()
    quiz_ids = set()
    for card in data.get("cards", []):
        cid = card.get("id", "?")
        if cid in ids:
            err("G002", cid, "duplicate card id")
        ids.add(cid)
        if card.get("status") != "NEEDS_REVIEW":
            err("G002", cid, f"status must be NEEDS_REVIEW, got {card.get('status')!r}")
        if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", str(card.get("updated", ""))):
            err("G011", cid, "updated must be yyyy-mm-dd")
        ts = card.get("translation_status", {})
        for lang in LANGS:
            if ts.get(lang) not in TRANSLATION_VALUES:
                err("G007", cid, f"translation_status.{lang} invalid: {ts.get(lang)!r}")
        for dc in card.get("discipline_codes", []):
            if dc not in codes:
                err("G008", cid, f"unknown discipline code {dc!r}")
        if not card.get("discipline_codes"):
            err("G008", cid, "no discipline codes")
        kw = card.get("keywords", {})
        for lang in LANGS:
            if not kw.get(lang):
                err("G009", cid, f"keywords.{lang} empty")
        tri(card.get("title"), "G003", f"{cid}.title")
        tri(card.get("summary"), "G003", f"{cid}.summary")
        if not card.get("sections"):
            err("G003", cid, "no sections")
        uz_texts = [card["title"]["uz"], card["summary"]["uz"], *kw.get("uz", [])]
        for s in card.get("sections", []):
            where = f"{cid}.{s.get('key')}"
            tri(s.get("title"), "G003", f"{where}.title")
            tri(s.get("body"), "G003", f"{where}.body")
            cites = s.get("citations", [])
            for k in cites:
                if k not in refs:
                    err("G004", where, f"citation {k!r} not in references")
            for lang in LANGS:
                body = s.get("body", {}).get(lang, "")
                for grp in INLINE.findall(body):
                    for k in (x.strip() for x in grp.split(",")):
                        if k not in refs:
                            err("G004", f"{where}.{lang}", f"inline [{k}] not in references")
                        elif k not in cites:
                            err("G005", f"{where}.{lang}", f"inline [{k}] not in section citations")
            for lang in LANGS:
                body = s.get("body", {}).get(lang, "")
                for m in INLINE.finditer(body):
                    keys = [x.strip() for x in m.group(1).split(",")]
                    if not PAGE_CITED.intersection(keys):
                        continue
                    if len(keys) != 1:
                        err("G015", f"{where}.{lang}", f"{keys[0]} must be cited alone: [{m.group(1)}]")
                    elif not LOCATOR[lang].match(body, m.end()):
                        err("G015", f"{where}.{lang}", f"[{keys[0]}] without page locator: {body[m.end():m.end() + 16]!r}")
            uz_texts += [s["title"]["uz"], s["body"]["uz"]]
        card_keys = {k for s in card.get("sections", []) for k in s.get("citations", [])}
        if card_keys & FREE_SOURCES:
            acc = card.get("source_access") or {}
            if acc.get("access") != "free" or acc.get("source_key") not in FREE_SOURCES:
                err("G016", cid, "cards built on author-permitted sources must declare source_access.access = free")
        qids = set()
        for i, q in enumerate(card.get("quiz", [])):
            qw = f"{cid}.quiz[{i}]"
            qid = q.get("id")
            if not qid or qid in quiz_ids:
                err("G014", qw, f"missing or duplicate quiz id {qid!r}")
            quiz_ids.add(qid)
            qids.add(qid)
            tri(q.get("question"), "G014", f"{qw}.question")
            tri(q.get("answer"), "G014", f"{qw}.answer")
            ds = q.get("distractors", [])
            if len(ds) != 3:
                err("G014", qw, "exactly 3 distractors required")
            for j, d in enumerate(ds):
                tri(d, "G014", f"{qw}.distractors[{j}]")
                for lang in LANGS:
                    if (d or {}).get(lang, "").strip().lower() == (q.get("answer") or {}).get(lang, "").strip().lower():
                        err("G014", qw, f"distractor {j} equals the answer ({lang})")
            cits = q.get("citations", [])
            if not cits:
                err("G014", qw, "no citations")
            for c in cits:
                if c.get("key") not in card_keys:
                    err("G014", qw, f"quiz citation {c.get('key')!r} is not cited by the card")
            uz_texts += [(q.get("question") or {}).get("uz", ""), (q.get("answer") or {}).get("uz", "")]
            uz_texts += [(d or {}).get("uz", "") for d in ds]
        for i, t in enumerate(uz_texts):
            check_uz(t, f"{cid}.uz[{i}]")

    blob = json.dumps(data, ensure_ascii=False)
    if re.search(r"\bABY\b", blob):
        err("G012", "root", "reference to restricted ABY manual found")

    # G013: rebuild in memory and compare
    import subprocess
    before = (HERE / "guidelines_v1.json").read_bytes()
    subprocess.run([sys.executable, str(HERE / "build.py")], check=True, capture_output=True)
    after = (HERE / "guidelines_v1.json").read_bytes()
    if before != after:
        err("G013", "guidelines_v1.json", "was out of date; rebuilt — commit the new file")

    n_cards = len(data.get("cards", []))
    words = {lang: 0 for lang in LANGS}
    for c in data.get("cards", []):
        for s in c["sections"]:
            for lang in LANGS:
                words[lang] += len(s["body"][lang].split())
    n_quiz = sum(len(c.get("quiz", [])) for c in data.get("cards", []))
    print(f"cards={n_cards} references={len(refs)} quiz={n_quiz} words={words}")
    for c in data.get("cards", []):
        per = {lang: sum(len(s['body'][lang].split()) for s in c['sections']) for lang in LANGS}
        print(f"  {c['id']}: sections={len(c['sections'])} refs={len(c['reference_keys'])} words={per}")
    if errors:
        print(f"FAILED: {len(errors)} error(s)")
        for e in errors:
            print("  " + e)
        return 1
    print("OK: all checks passed (G001-G016)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
