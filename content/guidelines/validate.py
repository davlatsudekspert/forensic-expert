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
  G014 'teaching_material' references carry publisher, place and rights (author permission)
  G015 cards citing a teaching_material reference are free (access == "free");
       access, if present, is "free" or "pro"
  G016 quiz items: unique id, q/a in uz/ru/en, exactly 3 distractors per language,
       distractors differ from the answer, pages given (or explicit `cite` keys
       that the card cites; `pages` then belong to the teaching-material key),
       explanation `e` (why the answer is right / distractors wrong) in uz/ru/en;
       no forbidden terminology variants (content/terminology/canonical_terms.json)
  G017 page-cited teaching books (PAGE_CITED): the key stands alone in its
       brackets and is followed by a page locator in the body language,
       e.g. "[key] (23-b.)", "[key] (с. 23–24)", "[key] (pp. 23, 27)"
  G018 term_ids (optional): unique strings, each an existing term_id in
       content/pilot/bundle.json term_translations (glossary link)
"""
import json
import pathlib
import re
import sys

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
LANGS = ("uz", "ru", "en")
TRANSLATION_VALUES = {"AUTHORED", "DRAFT", "REVIEWED"}
# Kanonik terminologiya (content/terminology/canonical_terms.json): taqiqlangan
# shakllar faqat quiz matnlarida tekshiriladi (karta matnlari — alohida bosqich).
_CANON = json.loads((ROOT / "content/terminology/canonical_terms.json").read_text(encoding="utf-8"))
FORBIDDEN_QUIZ_TERMS = sorted({v for t in _CANON["terms"] for lang in ("uz", "ru")
                               for v in t.get("forbidden", {}).get(lang, [])})
INLINE = re.compile(r"\[([a-z0-9_]+(?:,\s*[a-z0-9_]+)*)\]")

errors: list[str] = []

PAGE_CITED = {"gmt_yuldashev2024"}
PAGES = r"\d+(?:[–-]\d+)?(?:, ?\d+(?:[–-]\d+)?)*"
LOCATOR = {
    "uz": re.compile(r"\s\(" + PAGES + r"-b\.\)"),
    "ru": re.compile(r"\s\(с\. " + PAGES + r"\)"),
    "en": re.compile(r"\s\(pp?\. " + PAGES + r"\)"),
}


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
                        err("G017", f"{where}.{lang}", f"{keys[0]} must be cited alone: [{m.group(1)}]")
                    elif not LOCATOR[lang].match(body, m.end()):
                        err("G017", f"{where}.{lang}", f"[{keys[0]}] without page locator: {body[m.end():m.end() + 16]!r}")
            uz_texts += [s["title"]["uz"], s["body"]["uz"]]
        for i, t in enumerate(uz_texts):
            check_uz(t, f"{cid}.uz[{i}]")

    # G014-G016: o‘quv-uslubiy materiallar (muallif ruxsati bilan, bepul) va test savollari
    teaching = {k for k, r in refs.items() if r.get("type") == "teaching_material"}
    for k in teaching:
        for f in ("publisher", "place", "rights"):
            if not refs[k].get(f):
                err("G014", k, f"teaching_material needs {f}")
    quiz_ids = set()
    for card in data.get("cards", []):
        cid = card.get("id", "?")
        access = card.get("access")
        if access is not None and access not in ("free", "pro"):
            err("G015", cid, f"access must be free/pro, got {access!r}")
        if teaching & set(card.get("reference_keys", [])) and access != "free":
            err("G015", cid, "cites a teaching_material source: access must be 'free'")
        for i, q in enumerate(card.get("quiz", [])):
            where = f"{cid}.quiz[{i}]"
            qid = q.get("id")
            if not qid or qid in quiz_ids:
                err("G016", where, f"missing or duplicate id {qid!r}")
            quiz_ids.add(qid)
            tri(q.get("q"), "G016", f"{where}.q")
            tri(q.get("a"), "G016", f"{where}.a")
            tri(q.get("e"), "G016", f"{where}.e")
            qblob = json.dumps(q, ensure_ascii=False)
            for bad in FORBIDDEN_QUIZ_TERMS:
                if re.search(rf"(?<![\w-]){re.escape(bad)}(?![\w-])", qblob):
                    err("G016", where, f"forbidden terminology variant {bad!r}")
            cite = q.get("cite")
            if cite is not None:
                if not cite or any(k not in card.get("reference_keys", []) for k in cite):
                    err("G016", where, f"cite keys must be cited by the card: {cite!r}")
                if teaching & set(cite) and not str(q.get("pages", "")).strip():
                    err("G016", where, "pages missing for the teaching-material source")
            elif not str(q.get("pages", "")).strip():
                err("G016", where, "pages missing")
            for lang in LANGS:
                ds = (q.get("d") or {}).get(lang) or []
                if len(ds) != 3 or not all(isinstance(x, str) and x.strip() for x in ds):
                    err("G016", where, f"d.{lang} must have 3 non-empty distractors")
                ans = (q.get("a") or {}).get(lang, "").strip().lower()
                if ans in {x.strip().lower() for x in ds}:
                    err("G016", where, f"d.{lang} repeats the answer")
            check_uz(" ".join([q.get("q", {}).get("uz", ""), q.get("a", {}).get("uz", ""),
                               (q.get("e") or {}).get("uz", ""),
                               *((q.get("d") or {}).get("uz") or [])]), f"{where}.uz")

    # G018: karta → ilmiy lug‘at atamalari (aniq bog‘lanish)
    bundle = json.loads((ROOT / "content/pilot/bundle.json").read_text(encoding="utf-8"))
    term_ids = {t["term_id"] for t in bundle.get("term_translations", [])}
    for card in data.get("cards", []):
        cid = card.get("id", "?")
        tids = card.get("term_ids", [])
        if not isinstance(tids, list) or len(set(tids)) != len(tids):
            err("G018", cid, "term_ids must be a list of unique ids")
            continue
        for t in tids:
            if t not in term_ids:
                err("G018", cid, f"term {t!r} not in bundle term_translations")

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
    print(f"cards={n_cards} references={len(refs)} words={words}")
    for c in data.get("cards", []):
        per = {lang: sum(len(s['body'][lang].split()) for s in c['sections']) for lang in LANGS}
        print(f"  {c['id']}: sections={len(c['sections'])} refs={len(c['reference_keys'])} words={per}")
    if errors:
        print(f"FAILED: {len(errors)} error(s)")
        for e in errors:
            print("  " + e)
        return 1
    print("OK: all checks passed (G001-G018)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
