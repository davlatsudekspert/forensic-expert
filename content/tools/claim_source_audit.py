#!/usr/bin/env python3
"""Claim <-> source integrity audit for the whole content pack (2026-10-10).

For every statement that cites a source the checker records:

  * does the citation carry a CONCRETE locator (page / article / section /
    table)?  Coarse locators (abstract, scope, title, glossary) do not count;
  * was the source checked against FULL TEXT (PDF / official document read,
    verbatim excerpt matched in PMC full text) or only against an ABSTRACT /
    bibliographic record, or only for its existence and scope?  This is read
    from the reference's own ``verified_via`` / ``verified_on`` / ``note``
    fields (plus the explicit overrides in claim_source_reviews.json);
  * does the source's DECLARED scope (title + used_for + note: species, matrix,
    population, method) match what the claim asserts?
  * is the claim STRONGER than the cited passage supports (an abstract-level
    finding stated as a general rule; a scope-only reference used for
    normative content)?

Corpora (all read from the repository, nothing is fetched):
  guidelines   content/guidelines/src/card_*.json   sentence-level units with an
               inline [key] citation (uz text) + the quiz items of the cards
  court_prep   content/court_prep/court_prep_v1.json  question / principle /
               scenario claims (locators come from the built file)
  bundle       content/pilot/bundle.json  claims + citations (verbatim excerpts)

Verdicts (first match wins):
  UNSUPPORTED     the citation cannot support anything: unknown / unverified
                  reference, retracted record, locator outside the book, claim
                  without an excerpt
  SCOPE_MISMATCH  source scope (species, matrix, population, method) differs from
                  what the claim asserts, or a scope-only reference is used for
                  content claims, or a foreign guideline is worded as binding
  ABSTRACT_ONLY   every cited source was checked only at abstract / bibliographic
                  level, no concrete locator (``general_rule`` marks claims worded
                  as a general rule - highest review priority within this verdict)
  NO_LOCATOR      the source was read in full, but the citation names no
                  concrete locator
  PARTIAL         some cited sources are located + read in full, others are not,
                  or the excerpt does not name its subject
  SUPPORTED       every cited source is located and was read in full / matched
                  verbatim, no scope flag

A human review ledger (content/tools/claim_source_reviews.json) can override
the automatic verdict for one claim; an entry is bound to the SHA-256 of the
claim text, so editing the text invalidates it ("stale"). Entries are written
with --record-review. The result is deterministic (no clock, no network).

Usage (repository root):
  python3 content/tools/claim_source_audit.py                 # write reports
  python3 content/tools/claim_source_audit.py --check         # CI: stale/unreviewed
  python3 content/tools/claim_source_audit.py --root <dir>    # audit another checkout
  python3 content/tools/claim_source_audit.py --record-review ID --verdict SUPPORTED --basis "..."
  python3 content/tools/claim_source_audit.py --teaching-text toks=.tmp/toks.txt:0 ...
                                    # optional page-level numeric cross-check
                                    # against owner PDFs (never in CI)
"""
from __future__ import annotations

import argparse
import collections
import hashlib
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
VERDICTS = ("UNSUPPORTED", "SCOPE_MISMATCH", "ABSTRACT_ONLY", "NO_LOCATOR", "PARTIAL", "SUPPORTED")
REVIEW_ACTIONS = ("none", "narrowed", "locator_added", "marked_needs_verification", "kept")

# --------------------------------------------------------------------------
# Small helpers
# --------------------------------------------------------------------------
INLINE = re.compile(r"\[([a-z0-9_]+(?:,\s*[a-z0-9_]+)*)\]")
_LOC_UZ = re.compile(r"^\s*\(\s*([\d][\d,\s–\-]*?)\s*-\s*b\.\s*\)")
_LOC_PN = re.compile(r"^\s*\(\s*(?:p|pp|с|s|стр)\.\s*([\d][\d,\s–\-]*?)\s*\)")
SENT_SPLIT = re.compile(r"(?<=[.!?])\s+(?=[A-ZА-ЯЎҚҒҲЁ«“\"•(\d])")


def sha(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def norm_ws(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def read_json(path: pathlib.Path):
    return json.loads(path.read_text(encoding="utf-8"))


def keys_in(text: str) -> list[str]:
    out: list[str] = []
    for grp in INLINE.findall(text or ""):
        for k in grp.split(","):
            k = k.strip()
            if k and k not in out:
                out.append(k)
    return out


def parse_pages(spec: str) -> list[int]:
    """'25, 28–29' -> [25, 28, 29]; invalid -> []."""
    pages: list[int] = []
    for part in re.split(r"\s*,\s*", spec.strip()):
        m = re.fullmatch(r"(\d+)\s*[–\-]\s*(\d+)", part)
        if m:
            a, b = int(m.group(1)), int(m.group(2))
            if a <= b and b - a < 200:
                pages.extend(range(a, b + 1))
            else:
                return []
        elif re.fullmatch(r"\d+", part):
            pages.append(int(part))
        else:
            return []
    return pages


# --------------------------------------------------------------------------
# Reference model (verification level read from the registry's own fields)
# --------------------------------------------------------------------------
SCOPE_ONLY_PAT = re.compile(
    r"only the scope statement|scope statement read|cited only for the existence|"
    r"metadata only|number, title, edition and scope read|"
    r"title, abstract and doi read|title, edition, year and scope statement read|"
    r"normative (?:text|content) not reproduced", re.I)
ABSTRACT_PAT = re.compile(r"abstract-level|abstract used|abstract read|efetch abstract", re.I)
FULLTEXT_PAT = re.compile(
    r"\bpdf\b.*\b(read|downloaded|extracted|text)|text read|full text read|"
    r"read in full|passages located|consolidated text read|articles? [\d, ]+ read|"
    r"summary recommendations read|guidance note 1 read|pages? [\d\-–, and]+ read|"
    r"chapter on testimony read", re.I)
PUBMED_PAT = re.compile(r"pubmed|e-utilities|esummary|efetch|crossref|get_article_metadata|lookup_article", re.I)

# issuing body -> (jurisdiction layer, kind). Used for the international-source table.
BODY_RULES = [
    (r"\bASB\b|AAFS Standards Board|\bNIST\b|\bOSAC\b|\bSWGDRUG\b|\bASTM\b|\bSWG[A-Z]+\b|\bDEA\b|NAS\b|PCAST|National Academy|National Academies|21 CFR", "US", "voluntary standard / US guidance"),
    (r"ENFSI|Eurachem|EURACHEM|CITAC", "EU", "European voluntary guidance"),
    (r"UNODC|United Nations Office on Drugs", "INT", "UN guidance (non-binding)"),
    (r"\bINCB\b|Single Convention|Convention on", "INT", "UN treaty list"),
    (r"\bWHO\b|World Health Organization", "INT", "WHO guidance (non-binding)"),
    (r"ILAC|ISO/IEC|\bISO\b|\bIEC\b|BIPM|JCGM|\bICH\b|IUPAC", "INT", "international voluntary standard"),
    (r"\bISFG\b|ISFG", "INT", "scientific-society recommendation"),
    (r"lex\.uz|O‘zbekiston|Uzbekistan|ZRU|VM |Vazirlar Mahkamasi", "UZ", "national law"),
]


def classify_body(text: str) -> tuple[str, str]:
    for pat, jur, kind in BODY_RULES:
        if re.search(pat, text or ""):
            return jur, kind
    return "UNKNOWN", "unclassified"


class Ref:
    __slots__ = ("key", "type", "title", "scope_text", "level", "verified", "evidence_level",
                 "pages_total", "pmid", "doi", "note", "jurisdiction", "body_kind", "teaching")

    def __init__(self, **kw):
        for s in self.__slots__:
            setattr(self, s, kw.get(s))


def ref_from_guidelines(r: dict, overrides: dict, retracted: set[str]) -> Ref:
    vv = r.get("verified_via") or ""
    note = r.get("note") or ""
    typ = r.get("type") or ""
    ov = overrides.get(r["key"])
    if ov:
        level = ov["level"]
    elif typ == "teaching_material":
        level = "fulltext"  # page-located against the owner PDF (docs/qa/TOKS_SOURCE_AUDIT.md, REVIEW_GMT.md)
    elif typ == "database":
        level = "fulltext"  # the record itself was queried (PubChem PUG REST / PUG-View)
    elif SCOPE_ONLY_PAT.search(note) or SCOPE_ONLY_PAT.search(vv):
        level = "scope_only"
    elif ABSTRACT_PAT.search(note) or ABSTRACT_PAT.search(vv):
        level = "abstract"
    elif FULLTEXT_PAT.search(vv) or FULLTEXT_PAT.search(note):
        level = "fulltext"
    elif PUBMED_PAT.search(vv):
        level = "abstract"
    else:
        level = "scope_only"
    verified = bool(r.get("verified_on") and r.get("verified_via"))
    bad = (r.get("pmid") in retracted) or bool(re.match(r"\s*(retracted|withdrawn)", r.get("title") or "", re.I))
    jur, kind = classify_body(" ".join([r.get("publisher") or "", " ".join(r.get("authors") or []), r.get("title") or "", r.get("url") or ""]))
    return Ref(key=r["key"], type=typ, title=r.get("title") or "",
               scope_text=" ".join([r.get("title") or "", r.get("used_for") or "", note]),
               level=level, verified=verified and not bad, evidence_level=None,
               pages_total=r.get("pages_total"), pmid=r.get("pmid"), doi=r.get("doi"), note=note,
               jurisdiction=jur, body_kind=kind, teaching=typ == "teaching_material")


# --------------------------------------------------------------------------
# Locators
# --------------------------------------------------------------------------
CONCRETE_LOC = re.compile(r"^(art:\d+(:\d+)?|sec:.+|pdfp:\d+|pp:\d+(-\d+)?|rec:\d+|gn:\d+|page:\d+)$")
COARSE_LOC = re.compile(r"^(abstract|scope|title|glossary)$", re.I)
SECTION_LOC = re.compile(r"[A-Za-z]")  # bundle locators: section names


def loc_kind(loc: str) -> str:
    if CONCRETE_LOC.match(loc):
        return "concrete"
    if COARSE_LOC.match(loc):
        return "coarse"
    return "other"


# --------------------------------------------------------------------------
# Scope vocabulary (English claim text vs. declared source scope)
# --------------------------------------------------------------------------
MATRIX = {
    "blood": r"\b(?:whole[- ])?blood\b|\bserum\b|\bplasma\b|\bhaemolys|\bhemolys",
    "urine": r"\burine\b|\burinary\b",
    "vitreous": r"\bvitreous\b",
    "bile": r"\bbile\b",
    "hair": r"\bhair\b",
    "oral_fluid": r"\boral fluid\b|\bsaliva",
    "breath": r"\bbreath\b|\bexhaled\b",
    "liver": r"\bliver\b|\bhepatic\b",
    "gastric": r"\bgastric\b|\bstomach\b",
    "csf": r"cerebrospinal|\bCSF\b",
    "bone": r"\bbone\b|\bskeletal\b|\bfemur\b",
}
SPECIES_ANIMAL = r"\b(?:swine|pigs?|porcine|rats?|mouse|mice|murine|rabbits?|dogs?|canine|rodents?|animals?|sheep|monkeys?|primates?)\b"
SPECIES_HUMAN = r"\b(?:humans?|patients?|persons?|people|subjects?|volunteers?|cadavers?|decedents?|deceased|victims?|corpses?|bodies|body|individuals?|users?|drivers?|cases?)\b"
RESTRICT = {
    "animal": (SPECIES_ANIMAL, SPECIES_ANIMAL + r"|\bexperimental model\b|\bin vivo model\b"),
    "pediatric": (r"\b(?:children|child|paediatric|pediatric|infants?|neonat\w+|newborns?|juvenile)\b", r"\b(?:children|child|paediatric|pediatric|infants?|neonat\w+|newborns?|juvenile|young)\b"),
    "in_vitro": (r"\bin vitro\b|\bmicrosomes?\b|\bhepatocytes?\b|\bcell lines?\b", r"\bin vitro\b|\bmicrosom\w+|\bhepatocytes?\b|\bcell\b|\blaboratory\b"),
    "single_case": (r"\bcase report\b|\bcase series\b|\ba case of\b|\bfatal case\b|\bcase study\b", r"\bcase\b|\bcases\b|\breport(?:ed|s)?\b|\bone\b|\bsingle\b|\bpatient\b"),
}
METHOD = {
    "gc": r"\bGC\b|\bGLC\b|gas chromatograph|\bHS-GC|\bGC-MS|\bGC-FID",
    "lc": r"\bLC\b|\bHPLC\b|\bUHPLC\b|liquid chromatograph|\bLC-MS",
    "immunoassay": r"immunoassay|immunochem|\bELISA\b|\bEMIT\b|\bCEDIA\b",
    "tlc": r"\bTLC\b|thin[- ]layer",
    "spectro": r"\bUV\b|\bIR\b|spectrophotomet|spectroscop|\bFTIR\b|\bNMR\b|\bRaman\b",
    "colour": r"colou?r test|spot test|colorimetr|\bMarquis\b|\bScott\b",
    "microscopy": r"microscop|diatom",
    "dna": r"\bDNA\b|\bPCR\b|\bSTR\b|metagenom",
}
GENERAL_CUES = re.compile(
    r"\b(always|never|every|universal(?:ly)?|in all cases|without exception|invariably|"
    r"regardless|all (?:cases|samples|specimens|methods|laboratories|studies|bodies|individuals|persons|people|drugs|substances)|"
    r"gold standard|the only|no (?:case|exception)|proves?|definitively|cannot ever|is always|as a rule|general rule)\b", re.I)
NORMATIVE_CUES = re.compile(r"\b(must|shall|should|required?|requires?|minimum|at least|mandatory|criteria|criterion|acceptance|threshold|cut-?off)\b", re.I)
# bundle fields whose excerpt is expected to name the substance (or one of its listed items)
SUBJECT_FIELDS = {"analytical_method", "metabolism_note", "reported_concentration", "metabolites",
                  "transformation_product", "case_observation", "composition_statement"}
HEDGE_CUES = re.compile(r"\b(recommend\w*|advis\w*|voluntary|suggest\w*|propos\w*|written for|guidance)\b", re.I)
BINDING_CUES = re.compile(r"\b(legally binding|mandatory|obligatory|compulsory|required by law|by law|statutory|is binding)\b", re.I)


def tags(text: str, table: dict) -> set[str]:
    out = set()
    for name, pat in table.items():
        if re.search(pat, text or "", re.I):
            out.add(name)
    return out



HARD_NORM = re.compile(r"\b(must|shall|mandatory|minimum|at least|cut-?off|threshold|no fewer than|not fewer than|three|two)\b", re.I)


def beyond_scope(claim_en: str, declared: str) -> list[str]:
    """Specific content a scope-only reference cannot back: numbers not present in
    its declared scope, or hard normative wording (must / shall / minimum /
    at least / cut-off / threshold) that the declared scope does not contain."""
    nums = sorted(set(re.findall(r"\d+(?:[.,]\d+)?", claim_en or "")) - set(re.findall(r"\d+(?:[.,]\d+)?", declared or "")))
    hard = sorted({m.group(1).lower() for m in HARD_NORM.finditer(claim_en or "")}
                  - {m.group(1).lower() for m in HARD_NORM.finditer(declared or "")})
    return nums + hard


def scope_flags(claim_en: str, ref: Ref, union_text: str) -> list[str]:
    """Deterministic scope comparison (claim text vs declared source scope).

    Matrix and method are compared with the UNION of the declared scopes of all
    sources cited for the claim (a sentence with several citations is supported
    jointly); population restrictions (animal, in vitro, paediatric, single case)
    are checked for each source on its own."""
    if ref.teaching or ref.type in ("law", "legislation", "database"):
        return []
    flags: list[str] = []
    src = union_text
    src_pos = re.sub(r"\bnot (?:for|applicable to|covering|about)\b[^.;]*", " ", src, flags=re.I)
    cm, sm = tags(claim_en, MATRIX) - {"blood"}, tags(src_pos, MATRIX)
    if cm and sm and not (cm & sm):
        flags.append(f"matrix: claim={sorted(cm)} source={sorted(sm)}")
    cmeth, smeth = tags(claim_en, METHOD), tags(src, METHOD)
    if cmeth and smeth and not (cmeth & smeth):
        flags.append(f"method: claim={sorted(cmeth)} source={sorted(smeth)}")
    for name, (src_pat, claim_pat) in RESTRICT.items():
        if re.search(src_pat, ref.scope_text, re.I) and not re.search(claim_pat, claim_en or "", re.I):
            human_in_src = bool(re.search(SPECIES_HUMAN, ref.title, re.I)) if name == "animal" else False
            if name == "animal" and human_in_src:
                continue
            flags.append(f"{name}: source scope is {name}-restricted, claim does not say so")
    return flags


# --------------------------------------------------------------------------
# Claim model
# --------------------------------------------------------------------------
class Claim:
    def __init__(self, cid, corpus, container, text, text_en, sources, extra=None):
        self.id = cid
        self.corpus = corpus
        self.container = container
        self.text = text            # authoritative text (uz for guidelines/court, excerpt for bundle)
        self.text_en = text_en or text
        self.sources = sources      # list of {"key", "locators": [..]}
        self.extra = extra or {}


def first_sentence_units(body: str):
    for para in re.split(r"\n+", body):
        para = para.strip()
        if not para:
            continue
        for sent in SENT_SPLIT.split(para):
            if INLINE.search(sent):
                yield sent.strip()


def locator_after(sentence: str, group_end: int) -> str | None:
    tail = sentence[group_end:]
    m = _LOC_UZ.match(tail) or _LOC_PN.match(tail)
    return norm_ws(m.group(1)) if m else None


def load_guideline_claims(root: pathlib.Path, refs: dict[str, Ref]):
    claims: list[Claim] = []
    for path in sorted((root / "content/guidelines/src").glob("card_*.json")):
        card = read_json(path)
        cid = card["id"]
        teach_counter = collections.Counter()
        for sec in card["sections"]:
            uz = sec["body"]["uz"]
            en = sec["body"].get("en", "")
            en_units = list(first_sentence_units(en))
            en_ptr = 0
            for n, sent in enumerate(first_sentence_units(uz), 1):
                srcs = []
                for m in INLINE.finditer(sent):
                    loc = locator_after(sent, m.end())
                    for k in [x.strip() for x in m.group(1).split(",")]:
                        r = refs.get(k)
                        if loc and r is not None and r.teaching:
                            locs = [loc]
                        elif loc and r is not None:
                            # page-cited non-teaching source (e.g. the UNODC manual): pp:N / pp:N-M
                            locs = ["pp:" + part.strip().replace("–", "-") for part in loc.split(",") if part.strip()]
                        else:
                            locs = []
                        if r is not None and r.teaching:
                            teach_counter[k] += 1
                        for s in srcs:
                            if s["key"] == k:
                                s["locators"] += [l for l in locs if l not in s["locators"]]
                                break
                        else:
                            srcs.append({"key": k, "locators": locs})
                # align the en sentence by its citation-key set (sentence splitting may differ)
                kset = set(keys_in(sent))
                en_u = en
                for j in range(en_ptr, len(en_units)):
                    if set(keys_in(en_units[j])) == kset:
                        en_u = en_units[j]
                        en_ptr = j + 1
                        break
                claims.append(Claim(f"{cid}/{sec['key']}#{n}", "guidelines", cid, sent, en_u, srcs,
                                    {"section": sec["key"], "card_file": path.name}))
        # quiz items: `cite` lists explicit keys; `pages` belong to the card's teaching manual
        main = teach_counter.most_common(1)[0][0] if teach_counter else None
        for q in card.get("quiz", []) or []:
            keys = list(q.get("cite") or [])
            teach_keys = [k for k in keys if refs.get(k) is not None and refs[k].teaching]
            page_key = teach_keys[0] if teach_keys else main
            srcs = []
            if q.get("pages") and page_key:
                srcs.append({"key": page_key, "locators": [str(q["pages"])]})
            for k in keys:
                if not any(s["key"] == k for s in srcs):
                    srcs.append({"key": k, "locators": []})
            if not srcs and main:
                srcs.append({"key": main, "locators": []})
            if not srcs:
                continue
            claims.append(Claim(f"{cid}/quiz#{q['id']}", "guidelines", cid, norm_ws(q["e"]["uz"]), q["e"].get("en"),
                                srcs, {"section": "quiz", "card_file": path.name, "quiz": True}))
    return claims


def court_texts(q):
    yield "tests", q["tests"]
    yield "short_answer", q.get("short_answer", {})
    for b in ("documents", "explain", "pitfalls"):
        for i, it in enumerate(q["prepare"].get(b, [])):
            yield f"{b}.{i}", it
    for i, f in enumerate(q.get("followups", [])):
        yield f"followup.{i}.a", f["a"]
    for i, it in enumerate(q.get("limitations", [])):
        yield f"limitation.{i}", it


def load_court_claims(root: pathlib.Path):
    path = root / "content/court_prep/court_prep_v1.json"
    if not path.exists():
        return []
    d = read_json(path)
    claims: list[Claim] = []

    def add(owner, field_texts, claim_list, jurisdiction):
        by_id = {c["id"]: c for c in claim_list}
        for field, tri in field_texts:
            cid = f"{owner}.{field}"
            c = by_id.get(cid)
            if not c:
                continue
            srcs = [{"key": s["key"], "locators": list(s.get("locator") or [])} for s in c["sources"]]
            claims.append(Claim(cid, "court_prep", owner, tri.get("uz", ""), tri.get("en"), srcs,
                                {"jurisdiction": jurisdiction}))

    for q in d["questions"]:
        add(q["id"], court_texts(q), q["claims"], q.get("jurisdiction"))
    for p in d["principles"]:
        add(p["id"], [("text", p["text"])], p["claims"], "ALL")
    for s in d["simulator"]["scenarios"]:
        add(s["id"], [(f"option.{i}.feedback", o["feedback"]) for i, o in enumerate(s["options"])], s["claims"], "ALL")
    return claims


def bundle_ref(s: dict) -> Ref:
    note = s.get("notes") or ""
    typ = s.get("source_type") or ""
    if typ == "journal_article" and re.search(r"BioC|asl matn", note):
        level = "fulltext"
    elif typ == "journal_article":
        level = "abstract"
    elif typ in ("legislation", "report", "guideline", "standard"):
        # official documents whose own PDF was downloaded and read page by page
        level = "fulltext"
    elif typ == "database":
        level = "fulltext"
    elif typ == "book" and s.get("license_agreement_id"):
        # teaching material supplied in full by its author under a recorded permission
        level = "fulltext"
    else:
        level = "scope_only"
    jur, kind = classify_body(" ".join([s.get("organization") or "", s.get("title") or "", s.get("official_url") or ""]))
    retracted_src = s.get("lifecycle") == "retracted"
    # A DOI/ISBN is not the only way a reference can be identified: an official
    # publisher URL, or a recorded permission from the author, identifies the
    # document just as concretely for a book / guideline / standard / report.
    document_identified = bool(s.get("official_url")) or bool(s.get("license_agreement_id"))
    identified = bool(s.get("identifier_verified")) or (
        typ in ("book", "guideline", "standard", "report", "legislation") and document_identified)
    return Ref(key=s["source_id"], type=typ, title=s.get("title") or "", scope_text=s.get("title") or "",
               level=level, verified=identified and not retracted_src,
               evidence_level=s.get("evidence_level"),
               pmid=s.get("pmid"), doi=s.get("doi"), note=note, jurisdiction=jur, body_kind=kind,
               teaching=False, pages_total=None)


def load_bundle_claims(root: pathlib.Path, retracted: set[str]):
    path = root / "content/pilot/bundle.json"
    if not path.exists():
        return [], {}
    b = read_json(path)
    refs: dict[str, Ref] = {}
    for s in b["sources"]:
        r = bundle_ref(s)
        if r.pmid in retracted:
            r.verified = False
        refs[s["source_id"]] = r
    cites = collections.defaultdict(list)
    for c in b["citations"]:
        cites[c["claim_id"]].append(c)
    subs = {s["substance_id"]: s for s in b["substances"]}
    claims: list[Claim] = []
    for c in b["claims"]:
        v = c["value"]
        structured = c["is_structured_value"]
        if structured:
            text = json.dumps(v, ensure_ascii=False, sort_keys=True)
        else:
            # `excerpt` is a verbatim quote. Closed-licence sources may not be
            # quoted, so those claims carry the app's own sourced wording in
            # `value.statement`; it is audited as text but never counted as a
            # quotation (the `no_excerpt` flag still applies below).
            text = v.get("excerpt") or ""
            paraphrase = False
            if not text.strip():
                st = v.get("statement")
                if isinstance(st, dict):
                    text = st.get("en") or st.get("uz") or st.get("ru") or ""
                    paraphrase = bool(text.strip())
        names = set()
        s = subs.get(c["entity_id"])
        if s:
            names |= {s["canonical_name"]} | set(s.get("names", {}).values()) | set(s.get("synonyms", []))
        else:
            names.add(c["entity_id"].replace("-", " "))
        srcs = [{"key": ct["source_id"], "locators": [ct["locator"]] if ct.get("locator") else []} for ct in cites.get(c["claim_id"], [])]
        claims.append(Claim(c["claim_id"], "bundle", c["entity_id"], text, text, srcs,
                            {"field": c["field"], "structured": structured, "names": sorted(names),
                             "section": v.get("section"), "items": v.get("items") or [], "scope_note": v.get("scope_note"), "claim_evidence_level": c["evidence_level"],
                             "paraphrase": paraphrase if not structured else False,
                             "domain": c.get("domain")}))
    return claims, refs


# --------------------------------------------------------------------------
# Evaluation
# --------------------------------------------------------------------------
_NAME_STOP = {"acid", "reagent", "test", "the", "and", "sulfate", "oxide", "salt", "his", "fm", "bio", "scr", "method"}


def entity_named(text: str, names: list[str]) -> bool:
    """True when the excerpt names the subject: a full name / synonym, or any
    distinctive word (>= 3 letters) of a name (e.g. 'Mecke' for 'reagent mecke')."""
    low = re.sub(r"[\-‐‑–’']", " ", text.lower())
    for n in names:
        n = re.sub(r"[\-‐‑–’']", " ", n.lower()).strip()
        if len(n) >= 3 and n in low:
            return True
        base = re.sub(r"\s*\(.*\)$", "", n)
        if len(base) > 3 and base in low:
            return True
        for w in re.findall(r"[^\W\d_]{3,}", n):
            if w not in _NAME_STOP and re.search(r"\b" + re.escape(w) + r"\w*", low):
                return True
    return False


def evaluate(claim: Claim, refs: dict[str, Ref], teaching_pages: dict[str, int]) -> dict:
    reasons: list[str] = []
    flags: list[str] = []
    per_source = []
    unsupported = False
    scope_hits: list[str] = []
    n_full_located = n_abs = n_nolc_full = 0
    en = INLINE.sub("", claim.text_en or "")
    union_text = " ".join(refs[x["key"]].scope_text for x in claim.sources if x["key"] in refs and not refs[x["key"]].teaching)
    general = bool(GENERAL_CUES.search(en))
    normative = bool(NORMATIVE_CUES.search(en)) or bool(re.search(r"\d", en))

    if claim.corpus == "bundle" and not claim.sources:
        unsupported = True
        reasons.append("claim has no citation")
    if claim.corpus == "bundle" and not claim.extra.get("structured") and not claim.text.strip():
        # claims whose value carries items/context instead of an excerpt are structured lists
        pass

    for s in claim.sources:
        k = s["key"]
        r = refs.get(k)
        locs = s["locators"]
        kinds = [loc_kind(l) if claim.corpus != "bundle" else ("concrete" if SECTION_LOC.search(l) else "other") for l in locs]
        if claim.corpus == "guidelines" and r is not None and r.teaching:
            kinds = ["concrete" if parse_pages(l) else "other" for l in locs]
        if r is None:
            unsupported = True
            reasons.append(f"{k}: reference missing from the registry")
            per_source.append({"key": k, "locators": locs, "level": "missing", "located": False})
            continue
        if not r.verified:
            unsupported = True
            reasons.append(f"{k}: reference not verified / retracted")
        # page range check for page-located teaching material
        if r.teaching and claim.corpus == "guidelines":
            total = teaching_pages.get(k)
            for l in locs:
                pages = parse_pages(l)
                if not pages:
                    unsupported = True
                    reasons.append(f"{k}: malformed page locator '{l}'")
                elif total and max(pages) > total:
                    unsupported = True
                    reasons.append(f"{k}: page {max(pages)} is outside the book ({total} pp.)")
        has_concrete = "concrete" in kinds
        coarse_only = bool(locs) and not has_concrete and all(x == "coarse" for x in kinds)
        lvl = r.level
        if lvl == "abstract" and any(l.lower() == "abstract" for l in locs):
            pass
        per_source.append({"key": k, "locators": locs, "level": lvl, "located": has_concrete,
                           "jurisdiction": r.jurisdiction})
        if lvl == "scope_only" and not r.teaching and r.type not in ("database",):
            # a scope-only reference may support only existence / scope statements:
            # flag claims whose content words (or numbers) go beyond the declared scope
            beyond = beyond_scope(en, union_text)
            if beyond:
                scope_hits.append(f"{k}: read for existence/scope only, claim goes beyond it ({', '.join(beyond[:6])})")
        if claim.corpus == "bundle":
            sec = (claim.extra.get("section") or "").upper()
            own_finding = sec in ("ABSTRACT", "RESULTS", "DISCUSS", "METHODS", "CASE", "CONCL")
            # bundle sources declare only a title: matrix / method comparison is meaningless
            # (an excerpt is a verbatim quote); only population restrictions are checked,
            # and only for statements the paper makes about its own findings
            fl = [f for f in scope_flags(en, r, union_text)
                  if own_finding and not f.startswith(("single_case", "matrix", "method", "pediatric"))]
        else:
            fl = scope_flags(en, r, union_text)
        scope_hits += [f"{k}: {f}" for f in fl]
        if r.jurisdiction not in ("UZ", "UNKNOWN") and r.type in ("standard", "guideline", "report") and BINDING_CUES.search(en) and not HEDGE_CUES.search(en):
            scope_hits.append(f"{k}: {r.jurisdiction} guidance worded as binding")
        if lvl == "fulltext" and has_concrete:
            n_full_located += 1
        elif lvl == "fulltext":
            n_nolc_full += 1
        else:
            n_abs += 1

    if claim.corpus == "bundle" and not claim.extra.get("structured"):
        ex = claim.text
        names = list(claim.extra.get("names") or []) + list(claim.extra.get("items") or [])
        if claim.extra.get("paraphrase"):
            # sourced wording of our own: the passage itself may not be quoted
            # (closed licence), so the reader is told it is not a quotation
            flags.append("paraphrase_not_quoted")
        if not ex.strip():
            flags.append("no_excerpt")          # section locator only, passage not quoted
        elif names and not entity_named(ex, names) and claim.extra.get("field") in SUBJECT_FIELDS:
            flags.append("subject_not_named_in_excerpt")

    # a scope limitation already recorded on the claim itself (bundle value.scope_note)
    # counts as marked, not as an unflagged mismatch
    scope_marked = bool(claim.extra.get("scope_note"))
    if scope_marked and scope_hits:
        flags.append("scope_marked")
        scope_hits = []
    # --- verdict
    nsrc = len(claim.sources)
    if unsupported:
        verdict = "UNSUPPORTED"
    elif scope_hits:
        verdict = "SCOPE_MISMATCH"
        reasons += scope_hits
    elif nsrc and n_full_located == nsrc and not (set(flags) & {"subject_not_named_in_excerpt", "no_excerpt", "scope_marked"}):
        verdict = "SUPPORTED"
    elif nsrc and n_full_located and (n_abs or n_nolc_full or flags):
        verdict = "PARTIAL"
    elif nsrc and n_abs == 0 and (set(flags) & {"subject_not_named_in_excerpt", "no_excerpt", "scope_marked"}):
        verdict = "PARTIAL"
    elif nsrc and n_abs == nsrc:
        verdict = "ABSTRACT_ONLY"
    elif nsrc and n_abs:
        verdict = "ABSTRACT_ONLY"
    elif nsrc and n_nolc_full:
        verdict = "NO_LOCATOR"
    else:
        verdict = "UNSUPPORTED"
    if verdict == "ABSTRACT_ONLY":
        reasons.append("source checked at abstract / bibliographic level; no concrete locator")
        if general:
            flags.append("general_rule")
    if verdict == "NO_LOCATOR":
        reasons.append("source read in full but citation names no concrete locator")
    if verdict == "PARTIAL":
        if "scope_marked" in flags:
            reasons.append("source scope differs from the claim framing; limitation recorded in value.scope_note, expert review needed")
        elif "no_excerpt" in flags:
            reasons.append("section locator only: the supporting passage is not quoted")
        elif "subject_not_named_in_excerpt" in flags:
            reasons.append("excerpt does not name the substance it is attached to")
        else:
            reasons.append("only part of the cited sources is located and read in full")
    if normative:
        flags.append("numbers_or_norms")
    if re.search(r"\b(must|shall|should|need(?:s|ed)? to|required|mandatory)\b", en, re.I):
        flags.append("prescriptive")
    return {"auto_verdict": verdict, "sources": per_source, "reasons": reasons, "flags": sorted(set(flags))}


# --------------------------------------------------------------------------
# Optional page-level numeric cross-check against owner PDFs
# --------------------------------------------------------------------------
NUM_TOK = re.compile(r"\d+(?:[.,]\d+)?")


def page_check(claim: Claim, pages_by_key: dict[str, dict[int, str]]):
    out = {}
    for s in claim.sources:
        pg = pages_by_key.get(s["key"])
        if not pg or not s["locators"]:
            continue
        nums = set()
        for l in s["locators"]:
            nums |= set(parse_pages(l))
        text = " ".join(pg.get(p, "") for p in sorted(nums))
        body = INLINE.sub("", re.sub(r"\([\d,\s–\-]+-b\.\)", "", claim.text))
        toks = {t.replace(",", ".") for t in NUM_TOK.findall(body) if len(t.replace(",", "").replace(".", "")) >= 2}
        have = {t.replace(",", ".") for t in NUM_TOK.findall(text)}
        missing = sorted(t for t in toks if t not in have)
        out[s["key"]] = {"pages": sorted(nums), "numbers_checked": len(toks), "numbers_missing": missing}
    return out


def load_teaching_text(specs: list[str]):
    res: dict[str, dict[int, str]] = {}
    for spec in specs:
        key, rest = spec.split("=", 1)
        path, _, off = rest.partition(":")
        off = int(off or 0)
        pages = pathlib.Path(path).read_text(encoding="utf-8").split("\f")
        res[key] = {i + 1 - off: p for i, p in enumerate(pages)}
    return res


# --------------------------------------------------------------------------
# Review ledger
# --------------------------------------------------------------------------
def load_ledger(path: pathlib.Path) -> dict:
    if path.exists():
        return read_json(path)
    return {"schema": "fe-claim-reviews/1", "note": "", "reference_levels": {}, "reviews": []}


def save_ledger(path: pathlib.Path, led: dict) -> None:
    led["reviews"] = sorted(led["reviews"], key=lambda r: r["id"])
    path.write_text(json.dumps(led, ensure_ascii=False, indent=1, sort_keys=False) + "\n", encoding="utf-8")



# --------------------------------------------------------------------------
# Evidence levels (A-E) of the bundle: offline consistency checks
# --------------------------------------------------------------------------
def evidence_audit(root: pathlib.Path) -> dict:
    """Where does an A-E level come from, and where is it ungrounded?

    The pack grades by PUBLICATION TYPE only (A systematic review / meta-analysis /
    official guideline, B primary study, C narrative review or database, D case
    report, E conference paper / thesis / editorial text).  The criterion lives in
    code (content/tools/p5/assemble_p5.py level(), content/tools/p5/harvest_research.py
    evidence(), content/pilot/evidence_levels.json), not in the data.  This check
    only uses what the bundle itself carries (source type, title, claim level)."""
    path = root / "content/pilot/bundle.json"
    if not path.exists():
        return {}
    b = read_json(path)
    src = {s["source_id"]: s for s in b["sources"]}
    cites = {c["claim_id"]: c["source_id"] for c in b["citations"]}
    by_type = collections.Counter((s["source_type"], s["tier"], s["evidence_level"]) for s in b["sources"])
    flags = []
    for s in b["sources"]:
        lvl, typ, title = s["evidence_level"], s["source_type"], s.get("title") or ""
        why = []
        if typ == "legislation":
            why.append("a legal instrument has no study-design level; A conflates legal authority with scientific evidence")
        if re.search(r"\bcase report\b|\bcase series\b", title, re.I) and lvl != "D":
            why.append("title says case report/series but level is not D")
        if re.search(r"systematic review|meta-analysis", title, re.I) and lvl != "A":
            why.append("title says systematic review/meta-analysis but level is not A")
        if re.search(r"\b(a |critical |literature |narrative )?review\b", title, re.I) and not re.search(r"systematic", title, re.I) and lvl in ("A", "B"):
            why.append("title says (narrative) review but level is A/B (the pipeline rule gives C)")
        if lvl == "A" and typ == "journal_article" and not re.search(r"systematic|meta-analysis|guideline", title, re.I):
            why.append("level A without 'systematic review/meta-analysis/guideline' in the title - check PubMed publication type")
        if why:
            flags.append({"source_id": s["source_id"], "level": lvl, "type": typ, "title": title[:100], "why": why})
    claim_diff = [cid for cid, sid in cites.items()
                  if sid in src and next((c for c in b["claims"] if c["claim_id"] == cid), {}).get("evidence_level") != src[sid]["evidence_level"]]
    return {
        "levels_by_source_type": {f"{t}/{tier}/{lvl}": n for (t, tier, lvl), n in sorted(by_type.items())},
        "claims_whose_level_differs_from_their_source": claim_diff,
        "claim_level_is_copied_from_source": len(claim_diff) == 0,
        "ungrounded_or_inconsistent_sources": sorted(flags, key=lambda x: x["source_id"]),
    }

# --------------------------------------------------------------------------
# International / jurisdiction table
# --------------------------------------------------------------------------

# Hand-checked jurisdiction / legal status of each standard or guidance document
# (registry fields do not carry it).  "binding" is True only inside the stated jurisdiction.
INTL_META = {
    "asb036_2019": ("US", "voluntary US standard (ANSI/ASB; AAFS Standards Board); scope forensic toxicology, not breath alcohol", False),
    "asb098_2023": ("US", "voluntary US standard (ANSI/ASB); mass spectral acceptance criteria, explicitly not identification criteria", False),
    "asb113_2023": ("US", "voluntary US standard (ANSI/ASB); identification criteria; excludes alcohols/volatiles, CO, cyanide, metals", False),
    "asb_bpr037_2019": ("US", "US best-practice recommendation (ANSI/ASB BPR 037); opinions and testimony", False),
    "asb_bpr156_2023": ("US", "US best-practice recommendation (ANSI/ASB BPR 156); specimen collection, not breath alcohol", False),
    "swgdrug2024": ("INT-US-led", "SWGDRUG Recommendations v8.2: international working group sponsored by the US DEA/ONDCP; recommendations for SEIZED drugs only; voluntary", False),
    "court_enfsi2015": ("EU", "ENFSI Guideline (European network of forensic institutes); voluntary even for EU member institutes", False),
    "court_ilac_g19_2022": ("INT", "ILAC guidance on applying ISO/IEC 17025 and 17020 to the forensic process; guidance, not law", False),
    "court_iso17025_2017": ("INT", "ISO/IEC 17025:2017 voluntary international standard (text not read; cited by title and edition); accreditation may be required by national law", False),
    "court_jcgm100_2008": ("INT", "JCGM 100:2008 (GUM): international guidance on measurement uncertainty (scope read only)", False),
    "court_quam2012": ("EU", "Eurachem/CITAC guide: voluntary guidance (scope read only)", False),
    "court_nas2009": ("US", "US National Academies report: US-focused policy recommendations, no legal force", False),
    "court_pcast2016": ("US", "US PCAST report: advice to the US President, no legal force; scope feature-comparison methods", False),
    "ich_q2r2_2023": ("INT", "ICH Q2(R2): pharmaceutical analytical validation guideline; scope = release/stability testing of drug substances and products; forensic use is a laboratory decision", False),
    "gmt_unodc_rapid_tests": ("INT", "UNODC manual ST/NAR/13/Rev.1 (rapid tests): UN guidance, non-binding", False),
    "court_uz_cpc": ("UZ", "Uzbekistan Civil Procedure Code (lex.uz): binding in Uzbekistan only", True),
    "court_uz_expertise_law": ("UZ", "Uzbekistan law on forensic expert activity (lex.uz): binding in Uzbekistan only", True),
    "gmt_lex_law813": ("UZ", "Uzbekistan Law No. 813-I on narcotic drugs (lex.uz): binding in Uzbekistan only", True),
    "gmt_lex_cm330": ("UZ", "Uzbekistan Cabinet of Ministers Resolution No. 330 (lex.uz): binding in Uzbekistan only", True),
}

def international_table(refs: dict[str, Ref], used: collections.Counter, binding_claims: dict[str, list[str]]):
    rows = []
    for k, r in sorted(refs.items()):
        if r.type not in ("standard", "guideline", "report", "law", "legislation"):
            continue
        m = INTL_META.get(k)
        rows.append({"key": k, "type": r.type, "jurisdiction": m[0] if m else r.jurisdiction,
                     "kind": m[1] if m else r.body_kind, "binding": m[2] if m else None,
                     "documented": m is not None, "title": r.title[:110], "level": r.level,
                     "claims": used.get(k, 0), "binding_wording_in": binding_claims.get(k, [])})
    return rows


# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------
def run(root: pathlib.Path, ledger_path: pathlib.Path, teach_text: dict | None = None):
    grefs_raw = read_json(root / "content/guidelines/references.json")["references"]
    led = load_ledger(ledger_path)
    ref_levels = led.get("reference_levels", {})
    retracted: set[str] = set()
    rp = root / "content/phase7/retraction_check.json"
    if rp.exists():
        retracted = set(read_json(rp).get("retracted", []))
    refs = {r["key"]: ref_from_guidelines(r, ref_levels, retracted) for r in grefs_raw}
    teaching_pages = {}
    for r in grefs_raw:
        if r.get("type") == "teaching_material" and isinstance(r.get("pages_total"), int):
            teaching_pages[r["key"]] = r["pages_total"]
    teaching_pages.setdefault("toks_majmua2025", 355)
    teaching_pages.setdefault("dvssm_majmua2025", 350)

    claims = load_guideline_claims(root, refs) + load_court_claims(root)
    bclaims, brefs = load_bundle_claims(root, retracted)
    # locators found in the source itself by a reviewer (ledger "locators"); each entry is
    # bound to the claim text hash, so editing the text invalidates it
    extra_loc = {}
    stale_loc = []
    by_id = {c.id: c for c in claims + bclaims}
    for ent in led.get("locators", []):
        for cid_, h in ent["claims"].items():
            c = by_id.get(cid_)
            if c is None or sha(c.text)[:16] != h:
                stale_loc.append(cid_)
                continue
            extra_loc[(cid_, ent["key"])] = list(ent["locator"])
    for c in claims + bclaims:
        for s_ in c.sources:
            for l in extra_loc.get((c.id, s_["key"]), []):
                if l not in s_["locators"]:
                    s_["locators"].append(l)

    reviews = {r["id"]: r for r in led.get("reviews", [])}
    rows = []
    stale = []
    used = collections.Counter()
    binding: dict[str, list[str]] = collections.defaultdict(list)
    for c in claims + bclaims:
        pool = brefs if c.corpus == "bundle" else refs
        ev = evaluate(c, pool, teaching_pages)
        for s in c.sources:
            used[s["key"]] += 1
            r = pool.get(s["key"])
            if r is not None and r.jurisdiction not in ("UZ", "UNKNOWN") and r.type in ("standard", "guideline", "report") and BINDING_CUES.search(c.text_en or "") and not HEDGE_CUES.search(c.text_en or ""):
                binding[s["key"]].append(c.id)
        digest = sha(c.text)
        row = {
            "id": c.id, "corpus": c.corpus, "container": c.container,
            "sources": [{"key": s["key"], "locators": s["locators"], "level": s2["level"]} for s, s2 in zip(c.sources, ev["sources"])],
            "auto_verdict": ev["auto_verdict"], "verdict": ev["auto_verdict"], "reviewed": False,
            "flags": ev["flags"], "reasons": ev["reasons"], "text_sha": digest[:16],
            "text": norm_ws(c.text)[:220],
        }
        if teach_text:
            row["page_check"] = page_check(c, teach_text)
        rv = reviews.get(c.id)
        if rv:
            if rv.get("text_sha") == digest[:16]:
                row["verdict"] = rv["verdict"]
                row["reviewed"] = True
                row["review"] = {k: rv[k] for k in ("action", "basis", "on") if k in rv}
            else:
                stale.append(c.id)
                row["flags"] = sorted(set(row["flags"]) | {"stale_review"})
        rows.append(row)
    known = {r["id"] for r in rows}
    orphan = sorted(i for i in reviews if i not in known)
    return rows, refs, brefs, stale + [x + ' (locator)' for x in stale_loc], orphan, used, binding, led


def totals(rows, key="verdict"):
    t = collections.OrderedDict((v, 0) for v in VERDICTS)
    for r in rows:
        t[r[key]] += 1
    return t


def render_md(rows, stale, orphan, intl, baseline=None, evidence=None):
    L = []
    w = L.append
    w("# Claim ↔ source integrity audit")
    w("")
    w("Generated by `content/tools/claim_source_audit.py` (deterministic, offline). "
      "Do not edit by hand; re-run the tool. Human reviews live in `content/tools/claim_source_reviews.json`.")
    w("")
    w("Verdict = `reviewed` verdict if a ledger entry matches the claim text, otherwise the automatic verdict. "
      "`SUPPORTED` is reached only when every cited source is located (concrete locator) and was read in full / matched verbatim.")
    w("")
    w("## Totals")
    w("")
    corp = sorted({r["corpus"] for r in rows})
    w("| Verdict | " + " | ".join(corp) + " | all |")
    w("|---|" + "---|" * (len(corp) + 1))
    for v in VERDICTS:
        cells = [str(sum(1 for r in rows if r["corpus"] == c and r["verdict"] == v)) for c in corp]
        w(f"| {v} | " + " | ".join(cells) + f" | {sum(1 for r in rows if r['verdict'] == v)} |")
    w("| **claims** | " + " | ".join(str(sum(1 for r in rows if r["corpus"] == c)) for c in corp) + f" | {len(rows)} |")
    w("")
    a = totals(rows, "auto_verdict")
    w("Automatic verdicts only (before human review overrides): " + ", ".join(f"{k} {v}" for k, v in a.items()) + ".")
    w(f"Reviewed claims (ledger, text hash matches): {sum(1 for r in rows if r['reviewed'])}; stale review entries: {len(stale)}; orphan entries: {len(orphan)}.")
    if baseline:
        w("")
        w("Baseline (before fixes): " + ", ".join(f"{k} {v}" for k, v in baseline.items()) + ".")
    w("")
    w("General-rule wording backed only by an abstract (`ABSTRACT_ONLY` + `general_rule`), not yet reviewed: "
      f"{sum(1 for r in rows if r['verdict'] == 'ABSTRACT_ONLY' and 'general_rule' in r['flags'] and not r['reviewed'])} "
      f"(reviewed: {sum(1 for r in rows if r['verdict'] == 'ABSTRACT_ONLY' and 'general_rule' in r['flags'] and r['reviewed'])}).")
    w("")
    w("## Review priority lists")
    w("")
    order = [("UNSUPPORTED", None), ("SCOPE_MISMATCH", None), ("ABSTRACT_ONLY", "general_rule"), ("NO_LOCATOR", None)]
    for v, flag in order:
        sel = [r for r in rows if r["verdict"] == v and (flag is None or flag in r["flags"]) and not (flag and r["reviewed"])]
        w(f"### {v}{' + ' + flag if flag else ''} ({len(sel)})")
        w("")
        if not sel:
            w("_none_")
            w("")
            continue
        w("| Claim | Sources | Reasons | Text |")
        w("|---|---|---|---|")
        for r in sel:
            w(f"| `{r['id']}` | {', '.join(s['key'] for s in r['sources'])} | {'; '.join(r['reasons'])[:200]} | {r['text'][:110].replace('|', '/')} |")
        w("")
    w("## International standards / guidance and jurisdiction")
    w("")
    w("| Key | Type | Jurisdiction layer | Status / scope | Binding where | Verification | Claims | Foreign guidance worded as binding |")
    w("|---|---|---|---|---|---|---|---|")
    for i in intl:
        bind = {True: "only in " + i["jurisdiction"], False: "nowhere (voluntary)", None: "unknown"}[i["binding"]]
        w(f"| {i['key']} | {i['type']} | {i['jurisdiction']} | {i['kind']} | {bind} | {i['level']} | {i['claims']} | {', '.join(i['binding_wording_in']) or '-'} |")
    w("")
    if evidence:
        w("## Evidence levels (A-E) in the bundle")
        w("")
        w("Levels grade the PUBLICATION TYPE only; the criterion is in code, not in the data (see `docs/EVIDENCE_LEVELS_AUDIT.md`).")
        w("")
        w("| source type / tier / level | sources |")
        w("|---|---|")
        for k, n in evidence["levels_by_source_type"].items():
            w(f"| {k} | {n} |")
        w("")
        w(f"Claim level copied from its source level: {evidence['claim_level_is_copied_from_source']}.")
        w("")
        w("Sources whose level is ungrounded or inconsistent with their own title / type:")
        w("")
        w("| source | level | why |")
        w("|---|---|---|")
        for f in evidence["ungrounded_or_inconsistent_sources"]:
            w(f"| {f['source_id']} {f['title'][:60].replace('|', '/')} | {f['level']} | {'; '.join(f['why'])} |")
        w("")
    w("## Full table")
    w("")
    w("| Claim id | Source | Locator | Verdict | Flags |")
    w("|---|---|---|---|---|")
    for r in rows:
        srcs = r["sources"] or [{"key": "-", "locators": []}]
        src = "<br>".join(s["key"] for s in srcs)
        loc = "<br>".join((", ".join(s["locators"]) or "-") for s in srcs)
        mark = "✔ " if r["reviewed"] else ""
        w(f"| `{r['id']}` | {src} | {loc} | {mark}{r['verdict']} | {', '.join(r['flags'])} |")
    w("")
    return "\n".join(L)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--root", default=str(ROOT))
    ap.add_argument("--ledger", default=None)
    ap.add_argument("--out-json", default="docs/qa/claim_source_audit.json")
    ap.add_argument("--out-md", default="docs/qa/CLAIM_SOURCE_AUDIT.md")
    ap.add_argument("--check", action="store_true", help="CI mode: write nothing; fail on stale/orphan reviews, UNSUPPORTED/SCOPE_MISMATCH, or out-of-date reports")
    ap.add_argument("--baseline", default=None, help="JSON written by a previous run (totals shown in the report)")
    ap.add_argument("--no-write", action="store_true")
    ap.add_argument("--record-review", metavar="CLAIM_ID")
    ap.add_argument("--verdict", choices=VERDICTS + ("AUTO",), help="AUTO = confirm the automatic verdict")
    ap.add_argument("--action", choices=REVIEW_ACTIONS, default="none")
    ap.add_argument("--basis", default="")
    ap.add_argument("--on", default="2026-10-10")
    ap.add_argument("--record-locator", metavar="SOURCE_KEY",
                    help="store a locator found in the source for the claims given by --claims")
    ap.add_argument("--locator", action="append", default=[], help="e.g. sec:IIIB.3.2, pp:43, art:28")
    ap.add_argument("--claims", default="", help="comma-separated claim ids (suffix * allowed: prefix match)")
    ap.add_argument("--teaching-text", action="append", default=[], metavar="KEY=FILE[:OFFSET]")
    ap.add_argument("--print", dest="show", action="store_true", help="print totals and flagged ids")
    args = ap.parse_args()

    root = pathlib.Path(args.root).resolve()
    ledger_path = pathlib.Path(args.ledger) if args.ledger else root / "content/tools/claim_source_reviews.json"
    teach = load_teaching_text(args.teaching_text) if args.teaching_text else None
    rows, refs, brefs, stale, orphan, used, binding, led = run(root, ledger_path, teach)

    if args.record_review:
        row = next((r for r in rows if r["id"] == args.record_review), None)
        if not row or not args.verdict or not args.basis:
            sys.exit("--record-review needs an existing claim id, --verdict and --basis")
        verdict = row["auto_verdict"] if args.verdict == "AUTO" else args.verdict
        led["reviews"] = [r for r in led["reviews"] if r["id"] != args.record_review]
        led["reviews"].append({"id": row["id"], "text_sha": row["text_sha"], "verdict": verdict,
                               "action": args.action, "basis": args.basis, "on": args.on})
        save_ledger(ledger_path, led)
        print(f"recorded review for {row['id']} -> {verdict}")
        return 0

    if args.record_locator:
        if not args.locator or not args.basis or not args.claims:
            sys.exit("--record-locator needs --locator, --claims and --basis")
        ids = []
        for part in [x.strip() for x in args.claims.split(",") if x.strip()]:
            if part.endswith("*"):
                ids += [r["id"] for r in rows if r["id"].startswith(part[:-1])]
            else:
                ids.append(part)
        sel = {}
        for r in rows:
            if r["id"] in ids and any(x["key"] == args.record_locator for x in r["sources"]):
                sel[r["id"]] = r["text_sha"]
        missing = [i for i in ids if i not in sel]
        if missing:
            sys.exit(f"claims not found / not citing {args.record_locator}: {missing[:5]}")
        for ent in led.setdefault("locators", []):
            if ent["key"] == args.record_locator and ent["locator"] == args.locator:
                ent["claims"].update(sel)
                ent["basis"] = args.basis
                break
        else:
            led["locators"].append({"key": args.record_locator, "locator": args.locator, "basis": args.basis,
                                    "on": args.on, "claims": sel})
        save_ledger(ledger_path, led)
        print(f"recorded {args.locator} for {len(sel)} claims of {args.record_locator}")
        return 0

    intl = international_table({**refs}, used, binding)
    baseline = None
    bpath = pathlib.Path(args.baseline) if args.baseline else root / "docs/qa/claim_source_audit_baseline.json"
    if bpath.exists():
        baseline = json.loads(bpath.read_text(encoding="utf-8"))["totals"]["verdict"]
    result = {
        "schema": "fe-claim-source-audit/1",
        "totals": {"verdict": totals(rows), "auto_verdict": totals(rows, "auto_verdict"),
                   "by_corpus": {c: totals([r for r in rows if r["corpus"] == c]) for c in sorted({r["corpus"] for r in rows})},
                   "claims": len(rows), "reviewed": sum(1 for r in rows if r["reviewed"]),
                   "general_rule_abstract_only_unreviewed": sum(1 for r in rows if r["verdict"] == "ABSTRACT_ONLY" and "general_rule" in r["flags"] and not r["reviewed"])},
        "stale_reviews": stale, "orphan_reviews": orphan,
        "international_sources": intl,
        "evidence_levels": evidence_audit(root),
        "claims": rows,
    }
    js = json.dumps(result, ensure_ascii=False, indent=1) + "\n"
    md = render_md(rows, stale, orphan, intl, baseline, result['evidence_levels']) + "\n"

    if args.show:
        print(json.dumps(result["totals"], ensure_ascii=False, indent=1))
    if args.check:
        problems = []
        if stale:
            problems.append(f"{len(stale)} stale review entries (claim text changed): {stale[:5]}")
        if orphan:
            problems.append(f"{len(orphan)} orphan review entries: {orphan[:5]}")
        bad = [r["id"] for r in rows if r["verdict"] in ("UNSUPPORTED", "SCOPE_MISMATCH") and not r["reviewed"]]
        if bad:
            problems.append(f"{len(bad)} UNSUPPORTED/SCOPE_MISMATCH claims without a review: {bad[:8]}")
        for path, text in ((root / args.out_json, js), (root / args.out_md, md)):
            if not path.exists() or path.read_text(encoding="utf-8") != text:
                problems.append(f"{path.relative_to(root)} is out of date - re-run claim_source_audit.py")
        for p in problems:
            print("FAIL:", p)
        if problems:
            return 1
        print("claim_source_audit: OK", dict(result["totals"]["verdict"]))
        return 0
    if not args.no_write:
        for rel, text in ((args.out_json, js), (args.out_md, md)):
            p = root / rel
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_text(text, encoding="utf-8")
        print("wrote", args.out_json, args.out_md)
    print("verdicts:", dict(result["totals"]["verdict"]), "| auto:", dict(result["totals"]["auto_verdict"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
