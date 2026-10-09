#!/usr/bin/env python3
"""Translation QA: claim preservation + terminology gate (Phase D, 2026-10-09).

Every translation is checked against its ORIGINAL text:

1. Claim preservation — the set of numbers (decimal comma/point and thousands
   separators normalised), units (mg/L ≡ мг/л ≡ mg/l …), percentages,
   comparison signs (≥ ≤ < > ±), chemical formulas, DOIs / PMIDs and
   international abbreviations (THC, PMR, LC-MS/MS, COHb …) of the original
   must appear unchanged in the translation, and the translation must not
   introduce numbers that are not in the original.
2. Terminology — forbidden variants from content/terminology/canonical_terms.json
   (GX-MS, SX-MS, YuSSX, ГХ-МС, ВЭЖХ … and English words such as «postmortem»
   in Uzbek text) must not occur in displayed text of that language.

Checked corpora (each is optional; all are checked by default):
  --bundle     content/pilot/bundle.json   text_translations, recipe names/texts,
               term_translations, method titles/sections, names maps
  --localized  content/pilot/translations/localized_texts_d.json (sidecar)
  --guidelines content/guidelines/guidelines_v1.json  (uz AUTHORED → ru/en)
  --court      content/court_prep/court_prep_v1.json  (uz AUTHORED → ru/en)

Exit status 1 when any ERROR is found (the build must stop). Documented
exceptions live in content/terminology/qa_exceptions.json (id + reason);
an exception that no longer matches anything is itself reported.

Usage (from the repository root):
  python3 content/tools/translation_qa.py                 # all corpora
  python3 content/tools/translation_qa.py --guidelines content/guidelines/guidelines_v1.json
  python3 content/tools/translation_qa.py --self-test
"""
from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import re
import sys
import unicodedata

ROOT = pathlib.Path(__file__).resolve().parents[2]
TERMS_PATH = ROOT / "content/terminology/canonical_terms.json"
EXCEPTIONS_PATH = ROOT / "content/terminology/qa_exceptions.json"

# ---------------------------------------------------------------------------
# Normalisation helpers
# ---------------------------------------------------------------------------

DASHES = "‐‑‒–—−"
_CITE = re.compile(r"\[[a-z0-9_]+(?:,\s*[a-z0-9_]+)*\]")
_URL = re.compile(r"https?://\S+")
_DOI = re.compile(r"\b10\.\d{4,9}/[^\s\"<>»«)\]]+")
_PMID = re.compile(r"\bPMID:?\s*(\d{5,9})\b")
_DOTTED_ID = re.compile(r"\b[a-z_]+(?:\.[a-z0-9_]+){2,}\b")
_PAGE_LOC = re.compile(r"\((?:p|pp|s|с|стр|b|bet)\.\s*[\d–-]+\)|\(\d+(?:[–-]\d+)?-b\.\)|\(\d+(?:[–-]\d+)?-betlar?\)")


def sha(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def _clean(text: str) -> str:
    t = unicodedata.normalize("NFC", text)
    t = _URL.sub(" ", t)
    t = _CITE.sub(" ", t)
    t = _DOTTED_ID.sub(" ", t)
    return t


# English number words (original side) — «Twenty-One Cases» ≡ «21 ta holat».
_NUM_WORDS = {
    "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7,
    "eight": 8, "nine": 9, "ten": 10, "eleven": 11, "twelve": 12,
    "thirteen": 13, "fourteen": 14, "fifteen": 15, "sixteen": 16,
    "seventeen": 17, "eighteen": 18, "nineteen": 19, "twenty": 20,
    "thirty": 30, "forty": 40, "fifty": 50, "hundred": 100,
}
_NUM_WORD_RE = re.compile(
    r"\b(twenty|thirty|forty|fifty)[-\s](one|two|three|four|five|six|seven|eight|nine)\b"
    r"|\b(" + "|".join(sorted(_NUM_WORDS, key=len, reverse=True)) + r")\b",
    re.I,
)
# Words in uz/ru translations that legitimately stand for a number of the
# original (only used to excuse an ORIGINAL number missing as digits).
_TARGET_NUM_WORDS = {
    1: ("bir", "один", "одн", "single", "единствен", "yagona", "one"),
    2: ("ikki", "два", "две", "двух", "двум", "two", "оба", "обоих", "ikkala", "двойн", "второ"),
    3: ("uch", "три", "трёх", "трех", "three", "трем", "трём"),
    4: ("to‘rt", "четыр", "four"),
    5: ("besh", "пят", "five"),
    6: ("olti", "шест", "six"),
    7: ("yetti", "сем", "seven"),
    8: ("sakkiz", "восем", "восьм", "eight"),
    9: ("to‘qqiz", "девят", "nine"),
    10: ("o‘n", "десят", "ten"),
    12: ("o‘n ikki", "двенадцат", "twelve"),
    24: ("sutka", "сутк", "суток", "кругл", "day"),
    100: ("yuz", "сто", "hundred"),
}


_MONTHS = [
    ("yanvar", "январ", "january"), ("fevral", "феврал", "february"), ("mart", "март", "march"),
    ("aprel", "апрел", "april"), ("may", "ма[йя]", "may"), ("iyun", "июн", "june"),
    ("iyul", "июл", "july"), ("avgust", "август", "august"), ("sentabr", "сентябр", "september"),
    ("oktabr", "октябр", "october"), ("noyabr", "ноябр", "november"), ("dekabr", "декабр", "december"),
]
# uz/ru month names (lower case, case suffixes allowed; «marta» = «times» is
# not March); English month names must be capitalised («5 may be» is not May).
_MONTH_RE = [(i + 1, re.compile(r"(?<=\d )(?:(?:%s)(?!a\b|aba)|%s\b)" % (
    "|".join(m[:2]), m[2].capitalize()))) for i, m in enumerate(_MONTHS)]


def numbers(text: str, lang: str, words: bool = True) -> set[str]:
    """Numbers of a text. ``words`` adds English number words (original side)."""
    t = _clean(text)
    t = re.sub(r"\b(\d{1,2})\.(\d{1,2})\.(\d{4})\b", r"\1 \2 \3", t)  # 12.11.2015
    month_nums = {str(n) for n, rx in _MONTH_RE if rx.search(t)}
    t = _DOI.sub(" ", t)
    t = _PAGE_LOC.sub(" ", t)
    # thousands separators: «1 000», «1 000» (nbsp / thin space)
    t = re.sub(r"(?<=\d)[    ](?=\d{3}\b)", "", t)
    if lang == "en":
        t = re.sub(r"(?<=\d),(?=\d{3}\b)", "", t)
    t = re.sub(r"(?<=\d),(?=\d)", ".", t)  # decimal comma → point
    out = set()
    for m in re.finditer(r"\d+(?:\.\d+)?", t):
        v = m.group(0)
        if "." in v:
            v = v.rstrip("0").rstrip(".") if not v.endswith(".") else v
        out.add(v.lstrip("0") or "0")
    out |= month_nums
    if lang == "en" and words:
        for m in _NUM_WORD_RE.finditer(text):
            if m.group(1):
                out.add(str(_NUM_WORDS[m.group(1).lower()] + {"one": 1, **_NUM_WORDS}[m.group(2).lower()]))
            else:
                out.add(str(_NUM_WORDS[m.group(3).lower()]))
    return out


# Units: canonical form ← variants (case-sensitive where it matters).
_UNIT_VARIANTS = {
    "mg/L": ["mg/L", "mg/l", "мг/л", "mg l-1", "mg L-1", "mg·L-1"],
    "µg/mL": ["µg/mL", "μg/mL", "µg/ml", "μg/ml", "mcg/mL", "мкг/мл", "mkg/ml", "mkg/mL"],
    "µg/L": ["µg/L", "μg/L", "µg/l", "μg/l", "мкг/л", "mkg/l", "mkg/L"],
    "ng/mL": ["ng/mL", "ng/ml", "нг/мл"],
    "ng/g": ["ng/g", "нг/г"],
    "pg/mg": ["pg/mg", "пг/мг"],
    "mg/kg": ["mg/kg", "мг/кг"],
    "g/L": ["g/L", "g/l", "г/л"],
    "g/kg": ["g/kg", "г/кг"],
    "L/kg": ["L/kg", "l/kg", "л/кг"],
    "mmol/L": ["mmol/L", "mmol/l", "ммоль/л"],
    "mol/L": ["mol/L", "mol/l", "моль/л"],
    "mEq/L": ["mEq/L", "mEq/l", "мэкв/л", "mekv/l"],
    "‰": ["‰"],
    "%": ["%"],
    "°C": ["°C", "°С", "° C", "℃"],
    "nm": ["nm", "нм"],
    "µm": ["µm", "μm", "мкм", "mkm"],
    "mL": ["mL", "ml", "мл"],
    "µL": ["µL", "μL", "µl", "μl", "мкл", "mkl"],
    "mg": ["mg", "мг"],
    "µg": ["µg", "μg", "мкг", "mkg"],
    "ng": ["ng", "нг"],
    "kg": ["kg", "кг"],
    "g": ["g", "г"],
    "L": ["L", "l", "л", "litr", "литр", "литра", "литре", "litre", "liter"],
    "mm": ["mm", "мм"],
    "cm": ["cm", "см", "sm"],
}
_UNIT_LOOKUP = {}
for canon, vs in _UNIT_VARIANTS.items():
    for v in vs:
        _UNIT_LOOKUP[v] = canon
_UNIT_RE = re.compile(
    r"(?<=\d)\s?(" + "|".join(re.escape(v) for v in sorted(_UNIT_LOOKUP, key=len, reverse=True)) + r")(?![\w/])"
)


def units(text: str) -> set[str]:
    t = _clean(text)
    t = re.sub(r"\b(1[5-9]\d\d|20\d\d)\s?(?:г\.|гг\.|г\b)", r"\1 ", t)  # «1971 г.» = year
    t = re.sub(r"\bсм\.(?=\s)", " ", t)  # «см.» = «see»
    t = re.sub(r"(?<=\d),(?=\d)", ".", t)
    return {_UNIT_LOOKUP[m.group(1)] for m in _UNIT_RE.finditer(t)}


_COMPARATORS = {"≥": "≥", "⩾": "≥", "≤": "≤", "⩽": "≤", "±": "±", "<": "<", ">": ">"}


def comparators(text: str) -> set[str]:
    t = _clean(text)
    t = t.replace(">=", "≥").replace("<=", "≤")
    t = re.sub(r"<[^>]{1,40}>", " ", t)  # html-ish tags
    return {_COMPARATORS[c] for c in t if c in _COMPARATORS}


# International abbreviations / identifiers: ≥2 Latin capitals, optional
# digits, Greek prefix, hyphen/slash joined parts (THC, 11-OH-THC, LC-MS/MS,
# COHb, CYP2D6, M3G, Δ9-THC).  Chemical formulas (C2H5OH, CO2) included.
_ABBR_RE = re.compile(
    r"(?<![\wЀ-ӿ‘’])"
    r"((?:[ΔαβγδΑ-Ω]\(?\d*\)?-?)?(?:\d+-)?[A-Z][A-Za-z0-9]*[A-Z0-9][A-Za-z0-9]*(?:[-/–][A-Za-z0-9]+)*)"
    r"(?![\wЀ-ӿ])"
)
# Abbreviations that are legitimately translated (not claims): DNA → ДНК/DNK.
TRANSLATABLE_ABBR = {
    "DNA", "RNA", "mRNA", "miRNA", "mtDNA", "UV", "IR", "NMR", "WHO", "UN", "EU", "USA", "US", "UK",
    "AIDS", "HIV", "CNS", "ECG", "EEG", "CT", "MRI", "PCR", "ICU", "OK", "II", "III", "IV", "VI",
    "VII", "VIII", "IX", "XI", "XII", "XX", "XXI", "XIX", "CME", "PhD", "MSc", "BSc", "MD", "ER",
    "ED", "UV-Vis", "UV/Vis", "FT-IR", "FTIR", "ATR-FTIR", "IUPAC", "SOP", "QC", "QA", "LOD", "LOQ",
    "ROC", "AUC", "SD", "CI", "OR", "RR", "TV", "GP", "NA", "NHS", "COVID", "SARS",
}


def abbreviations(text: str) -> set[str]:
    t = _clean(text)
    t = _DOI.sub(" ", t)
    out = set()
    for m in _ABBR_RE.finditer(t):
        tok = m.group(1).replace("–", "-").strip("-/")
        # «HPLC-chemiluminescence», «CYP2D6-mediated», «MDMA/methamphetamine»
        tok = re.split(r"[-/](?=[a-z]{3,})", tok)[0]
        tok = re.sub(r"(?<=[A-Z0-9])s$", "", tok)  # plural «SNPs» → «SNP»
        if len(tok) < 2 or tok.isdigit():
            continue
        if not re.search(r"[A-Z].*[A-Z0-9]|[A-Z]{2}", tok):
            continue
        if re.fullmatch(r"(?:[A-Z][a-z]+)+|[A-Z]{7,}", tok):  # word, CamelCase or SHOUTED word
            continue
        if tok in TRANSLATABLE_ABBR:
            continue
        out.add(tok)
    return out


def dois(text: str) -> set[str]:
    return {d.rstrip(".,;").lower() for d in _DOI.findall(text)} | set(_PMID.findall(text))


# ---------------------------------------------------------------------------
# Terminology
# ---------------------------------------------------------------------------

def load_terms(path: pathlib.Path = TERMS_PATH) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def _term_patterns(terms: dict) -> dict[str, list[tuple[str, re.Pattern, str]]]:
    by_lang: dict[str, list[tuple[str, re.Pattern, str]]] = {"uz": [], "ru": [], "en": []}
    for t in terms["terms"]:
        for lang, variants in t.get("forbidden", {}).items():
            for v in sorted(variants, key=len, reverse=True):
                pat = re.compile(r"(?<![\wЀ-ӿ‘’.])" + re.escape(v) + r"(?![\wЀ-ӿ‘’])")
                by_lang[lang].append((v, pat, t["abbr"]))
    for w in terms.get("words", []):
        for v in w["forbidden"]:
            pat = re.compile(r"(?<![\w.‘’])" + re.escape(v) + r"\w*", re.I)
            by_lang[w["lang"]].append((v, pat, w["use"]))
    # longest variants first so «GX-MS» is reported instead of «GX».
    for lang in by_lang:
        by_lang[lang].sort(key=lambda x: -len(x[0]))
    return by_lang


_PATTERNS: dict | None = None


def forbidden_hits(text: str, lang: str) -> list[tuple[str, str]]:
    global _PATTERNS
    if _PATTERNS is None:
        _PATTERNS = _term_patterns(load_terms())
    t = _clean(text)
    hits = []
    for variant, pat, use in _PATTERNS.get(lang, []):
        def repl(m, variant=variant, use=use):
            hits.append((m.group(0), use))
            return " " * len(m.group(0))
        t = pat.sub(repl, t)
    return hits


# ---------------------------------------------------------------------------
# Pair check
# ---------------------------------------------------------------------------

def _num_word_present(n: str, text: str) -> bool:
    try:
        v = int(n)
    except ValueError:
        return False
    words = _TARGET_NUM_WORDS.get(v, ())
    low = text.lower()
    return any(w in low for w in words)


def check_pair(original: str, translation: str, src_lang: str, tgt_lang: str,
               terminology: bool = True, abbr: bool = True) -> list[str]:
    """Returns human-readable violations (empty list = OK)."""
    problems = []
    if not translation or not translation.strip():
        return ["empty translation"]
    on, tn = numbers(original, src_lang), numbers(translation, tgt_lang, words=False)
    missing = sorted(n for n in on - tn if not _num_word_present(n, translation))
    if missing:
        problems.append(f"numbers missing in translation: {missing}")
    # numbers introduced by the translation (digits only on the original side
    # count words too, so «Twenty-One» → 21 is fine)
    extra = sorted(tn - on)
    if extra:
        problems.append(f"numbers not in original: {extra}")
    ou, tu = units(original), units(translation)
    if ou - tu:
        problems.append(f"units missing: {sorted(ou - tu)}")
    if tu - ou:
        problems.append(f"units not in original: {sorted(tu - ou)}")
    oc, tc = comparators(original), comparators(translation)
    if oc != tc:
        problems.append(f"comparison signs differ: {sorted(oc)} vs {sorted(tc)}")
    oa, ta = abbreviations(original), abbreviations(translation)
    miss_a = sorted(a for a in oa - ta if a not in translation)
    if miss_a and abbr:
        problems.append(f"abbreviations/formulas missing: {miss_a}")
    od, td = dois(original), dois(translation)
    if od - td and td:
        problems.append(f"DOI/PMID changed: {sorted(od - td)}")
    if terminology:
        for found, use in forbidden_hits(translation, tgt_lang):
            problems.append(f"terminology: «{found}» → use «{use}»")
    return problems


def check_text(text: str, lang: str) -> list[str]:
    return [f"terminology: «{f}» → use «{u}»" for f, u in forbidden_hits(text, lang)]


# ---------------------------------------------------------------------------
# Corpora
# ---------------------------------------------------------------------------

class Report:
    def __init__(self, exceptions: dict[str, str]):
        self.errors: list[tuple[str, str]] = []
        self.checked = 0
        self.exceptions = exceptions
        self.used_exceptions: set[str] = set()

    def pair(self, rid: str, original, translation, src, tgt, terminology=True, abbr=True):
        if not isinstance(original, str) or not isinstance(translation, str):
            return
        self.checked += 1
        for p in check_pair(original, translation, src, tgt, terminology, abbr):
            self._add(rid, p)

    def text(self, rid: str, text, lang):
        if not isinstance(text, str):
            return
        self.checked += 1
        for p in check_text(text, lang):
            self._add(rid, p)

    def _add(self, rid, problem):
        key = f"{rid} :: {problem}"
        for ex in self.exceptions:
            if key.startswith(ex) or ex == rid:
                self.used_exceptions.add(ex)
                return
        self.errors.append((rid, problem))


def check_bundle(path: pathlib.Path, rep: Report):
    b = json.loads(path.read_text(encoding="utf-8"))
    claim_src = {c["claim_id"]: c["value"]["excerpt"] for c in b["claims"]
                 if isinstance(c.get("value"), dict) and c["value"].get("excerpt")}
    rule_src = {r["rule_id"]: r["value"]["excerpt"] for r in b["rules"]
                if isinstance(r.get("value"), dict) and r["value"].get("excerpt")}
    research_src = {r["research_id"]: r["title"] for r in b["research"]}
    srcs = {"claim_excerpt": claim_src, "rule_excerpt": rule_src, "research_title": research_src}
    for t in b.get("text_translations", []):
        orig = srcs.get(t["target_type"], {}).get(t["target_id"])
        rid = f"bundle:text_translations:{t['target_type']}:{t['target_id']}:{t['lang']}"
        if orig is None:
            rep._add(rid, "original not found")
            continue
        if sha(orig) != t["source_sha256"]:
            rep._add(rid, "stale translation (source_sha256 mismatch)")
            continue
        if t["status"] not in ("machine_draft",):
            rep._add(rid, f"status {t['status']} not allowed for automated drafts")
        rep.pair(rid, orig, t["text"], "en", t["lang"])
    for r in b.get("recipes", []):
        rid = r.get("recipe_id") or r.get("screening_id")
        for i, ing in enumerate(r.get("ingredients", [])):
            for lang, txt in (ing.get("names") or {}).items():
                if lang != "en":
                    rep.pair(f"bundle:recipe:{rid}:ingredients[{i}]:{lang}", ing["name"], txt, "en", lang)
        for i, st in enumerate(r.get("steps", [])):
            for lang, txt in (st.get("texts") or {}).items():
                if lang != "en":
                    rep.pair(f"bundle:recipe:{rid}:steps[{i}]:{lang}", st["text"], txt, "en", lang)
    for t in b.get("term_translations", []):
        for lang, txt in (t.get("localized") or {}).items():
            rep.text(f"bundle:term:{t['term_id']}:{lang}", txt, lang)
    for coll, key, field in (("methods", "method_id", "titles"), ("topics", "topic_id", "names"),
                             ("screening_tests", "screening_id", "names"),
                             ("substances", "substance_id", "names"),
                             ("authorities", "authority_id", "names"),
                             ("jurisdictions", "jurisdiction_id", "names"),
                             ("instruments", "instrument_id", "titles")):
        for e in b.get(coll, []):
            m = e.get(field) or {}
            if not isinstance(m, dict):
                continue
            for lang in ("uz", "ru", "en"):
                rep.text(f"bundle:{coll}:{e[key]}:{field}:{lang}", m.get(lang), lang)
            # names are names: only terminology (above) — «LSD» ≡ «ЛСД» is not a claim.
    for i in b.get("instruments", []):
        ref = i.get("official_reference") or ""
        if "NEEDS LEGAL REVIEW" in ref or "retrieved" in ref:
            rep._add(f"bundle:instruments:{i['instrument_id']}:official_reference",
                     "editor note in displayed official_reference (move to internal_note)")


def check_localized(path: pathlib.Path, rep: Report):
    d = json.loads(path.read_text(encoding="utf-8"))
    for r in d["records"]:
        rid = f"localized:{r['target_type']}:{r['target_id']}"
        if r.get("status") not in ("machine_draft", "terminology_checked", "claim_checked"):
            rep._add(rid, f"status {r.get('status')} not allowed for automated drafts")
        src = r.get("source_text")
        if src is not None and sha(src) != r.get("source_sha256"):
            rep._add(rid, "stale (source_sha256 mismatch)")
        for lang in ("uz", "ru", "en"):
            txt = r.get("text", {}).get(lang)
            if txt is None or (lang == r.get("source_lang") and not r.get("derived")):
                continue
            if r.get("derived"):
                # explanatory text written from several claims: every number
                # it uses must come from the cited claims (no new facts)
                for n in sorted(numbers(txt, lang) - numbers(src or "", r.get("source_lang", "en"))):
                    rep._add(f"{rid}:{lang}", f"number {n} not found in source claims")
                for u in sorted(units(txt) - units(src or "")):
                    rep._add(f"{rid}:{lang}", f"unit {u} not found in source claims")
                rep.text(f"{rid}:{lang}", txt, lang)
            else:
                rep.pair(f"{rid}:{lang}", src, txt, r.get("source_lang", "en"), lang)


def _tri_walk(obj, path=""):
    """Yields (path, tri-dict) for every {uz, ru, en} string map."""
    if isinstance(obj, dict):
        if {"uz", "ru", "en"} <= obj.keys() and all(isinstance(obj[k], str) for k in ("uz", "ru", "en")):
            yield path, obj
            return
        for k, v in obj.items():
            if k in ("keywords", "references", "omitted_unverified", "translation_status"):
                continue
            yield from _tri_walk(v, f"{path}.{k}" if path else k)
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            yield from _tri_walk(v, f"{path}[{i}]")


def check_tri_file(path: pathlib.Path, rep: Report, label: str):
    d = json.loads(path.read_text(encoding="utf-8"))
    canon = {t["abbr"] for t in load_terms()["terms"]}
    for p, tri in _tri_walk(d):
        rid = f"{label}:{p}"
        rep.text(f"{rid}:uz", tri["uz"], "uz")
        ab = {lang: abbreviations(tri[lang]) for lang in ("uz", "ru", "en")}
        for lang in ("ru", "en"):
            other = "en" if lang == "ru" else "ru"
            rep.pair(f"{rid}:{lang}", tri["uz"], tri[lang], "uz", lang, abbr=False)
            # Uzbek source may use local abbreviations (JPK = УПК = CPC); an
            # abbreviation must be kept when the uz text AND the other
            # translation share it, or when it is a canonical term.
            # (canonical decision: only the canonical international
            # abbreviations are mandatory in every language — «MDMA» may be
            # «МДМА» in Russian running text).
            need = ab["uz"] & canon
            miss = sorted(a for a in need if a not in tri[lang])
            if miss:
                rep._add(f"{rid}:{lang}", f"abbreviations/formulas missing: {miss}")
    # bibliographic titles: per-language titles of official documents
    for r in d.get("references", []):
        for lang, txt in (r.get("titles") or {}).items():
            rep.text(f"{label}:references:{r['key']}:titles:{lang}", txt, lang)


def load_exceptions() -> dict[str, str]:
    if not EXCEPTIONS_PATH.exists():
        return {}
    d = json.loads(EXCEPTIONS_PATH.read_text(encoding="utf-8"))
    return {e["match"]: e["reason"] for e in d.get("exceptions", [])}


def run(args) -> int:
    rep = Report(load_exceptions())
    any_given = any([args.bundle, args.localized, args.guidelines, args.court])
    bundle = args.bundle or (None if any_given else ROOT / "content/pilot/bundle.json")
    localized = args.localized or (None if any_given else ROOT / "content/pilot/translations/localized_texts_d.json")
    guidelines = args.guidelines or (None if any_given else ROOT / "content/guidelines/guidelines_v1.json")
    court = args.court or (None if any_given else ROOT / "content/court_prep/court_prep_v1.json")
    if bundle:
        check_bundle(pathlib.Path(bundle), rep)
    if localized and pathlib.Path(localized).exists():
        check_localized(pathlib.Path(localized), rep)
    if guidelines:
        check_tri_file(pathlib.Path(guidelines), rep, "guidelines")
    if court:
        check_tri_file(pathlib.Path(court), rep, "court_prep")
    for rid, p in rep.errors[: args.limit]:
        print(f"ERROR {rid}: {p}")
    if len(rep.errors) > args.limit:
        print(f"... and {len(rep.errors) - args.limit} more")
    unused = sorted(set(rep.exceptions) - rep.used_exceptions) if not any_given else []
    for u in unused:
        print(f"WARN unused exception: {u}")
    print(f"translation_qa: {rep.checked} texts checked, {len(rep.errors)} errors, "
          f"{len(rep.used_exceptions)} documented exceptions used")
    if args.json_out:
        pathlib.Path(args.json_out).write_text(json.dumps(
            {"checked": rep.checked, "errors": [{"id": a, "problem": b} for a, b in rep.errors]},
            ensure_ascii=False, indent=1), encoding="utf-8")
    return 1 if rep.errors else 0


def self_test() -> int:
    ok = True

    def expect(cond, msg):
        nonlocal ok
        if not cond:
            ok = False
            print("FAIL", msg)

    en = "For example, basic lipophilic drugs with a Vd above 3 L/kg are prone to PMR."
    uz = "Masalan, taqsimlanish hajmi (Vd) 3 L/kg dan yuqori bo‘lgan asosli lipofil dori vositalari PMR ga moyil."
    expect(check_pair(en, uz, "en", "uz") == [], f"good pair flagged: {check_pair(en, uz, 'en', 'uz')}")
    expect(any("numbers" in p for p in check_pair(en, uz.replace("3 L", "5 L"), "en", "uz")), "changed number")
    expect(any("units" in p for p in check_pair(en, uz.replace("L/kg", "mL/kg"), "en", "uz")), "changed unit")
    expect(any("PMR" in p for p in check_pair(en, uz.replace("PMR", "qayta taqsimlanish"), "en", "uz")), "dropped abbr")
    expect(check_pair("1.18 g/L", "1,18 г/л", "en", "ru") == [], "decimal comma + unit equivalence")
    expect(check_pair("1,000 cases", "1000 ta holat", "en", "uz") == [], "thousands separator")
    expect(any("comparison" in p for p in check_pair("≥ 0.5 mg/L", "0,5 mg/L", "en", "uz")), "comparator")
    expect(any("terminology" in p for p in check_text("GX-MS bilan tasdiqlash", "uz")), "GX-MS forbidden")
    expect(check_text("GC-MS bilan tasdiqlash", "uz") == [], "GC-MS allowed")
    expect(any("terminology" in p for p in check_text("методом ГХ-МС", "ru")), "ГХ-МС forbidden")
    expect(any("terminology" in p for p in check_text("postmortem namuna", "uz")), "postmortem in uz")
    expect(check_text("tool.conv.ethanol_units kalkulyatori", "uz") == [], "dotted id exempt")
    expect(check_pair("Twenty-One Cases Involving α-PVP", "α-PVP bilan bog‘liq 21 ta holat", "en", "uz") == [],
           "number word")
    expect(any("DOI" in p for p in check_pair("doi 10.1000/abc", "doi 10.1000/abd", "en", "uz")), "doi")
    print("self-test:", "OK" if ok else "FAILED")
    return 0 if ok else 1


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--bundle")
    ap.add_argument("--localized")
    ap.add_argument("--guidelines")
    ap.add_argument("--court")
    ap.add_argument("--limit", type=int, default=200)
    ap.add_argument("--json-out")
    ap.add_argument("--self-test", action="store_true")
    a = ap.parse_args()
    if a.self_test:
        return self_test()
    return run(a)


if __name__ == "__main__":
    sys.exit(main())
