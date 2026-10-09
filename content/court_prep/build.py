#!/usr/bin/env python3
"""Assemble content/court_prep/court_prep_v1.json (schema fe-court-prep/2).

Sources (all under src/):
  topic_*.json      - {"topic": {...}, "questions": [...]} or {"topics": [...], "questions": [...]}
                      (a question in a multi-topic file names its "topic")
  answers_*.json    - overlay keyed by question id: short_answer, followups,
                      limitations, locators (merged into the question)
  principles.json   - integrity principles shown on the hub
  simulator.json    - court-questioning simulator scenarios + free-text rubric
  ../guidelines/references.json - shared verified bibliography (single source)

Derived here (never hand-edited):
  question.citations - inline [key] citations in order of first use
  claims             - claim -> source mapping (claim id, source key, locator,
                       support level). Only fully supporting sources are cited
                       in the text, so every mapping is "full".
Only references used somewhere are embedded. The built file is also copied
to apps/mobile/assets/content/court_prep/.
Run from anywhere:  python3 content/court_prep/build.py
"""
import json
import pathlib
import re

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent.parent
ASSET = ROOT / "apps/mobile/assets/content/court_prep/court_prep_v1.json"
UPDATED = "2026-10-09"
TRANSLATION = {"uz": "AUTHORED", "ru": "DRAFT", "en": "DRAFT"}
BLOCKS = ("documents", "explain", "pitfalls")
INLINE = re.compile(r"\[([a-z0-9_]+(?:,\s*[a-z0-9_]+)*)\]")


def keys_in(text: str) -> list[str]:
    out = []
    for grp in INLINE.findall(text):
        out += [k.strip() for k in grp.split(",")]
    return out


def tri_keys(tri) -> list[str]:
    seen = []
    if isinstance(tri, dict):
        for lang in ("uz", "ru", "en"):
            for k in keys_in(tri.get(lang, "")):
                if k not in seen:
                    seen.append(k)
    return seen


def question_texts(q):
    """(field id, tri) pairs in display order."""
    yield "tests", q["tests"]
    yield "short_answer", q.get("short_answer", {})
    for b in BLOCKS:
        for i, it in enumerate(q["prepare"].get(b, [])):
            yield f"{b}.{i}", it
    for i, f in enumerate(q.get("followups", [])):
        yield f"followup.{i}.a", f["a"]
    for i, it in enumerate(q.get("limitations", [])):
        yield f"limitation.{i}", it


def claims_for(owner_id, texts, locators):
    claims = []
    for field, tri in texts:
        ks = tri_keys(tri)
        if not ks:
            continue
        claims.append({
            "id": f"{owner_id}.{field}",
            "sources": [{"key": k, "locator": locators.get(k), "support": "full"} for k in ks],
        })
    return claims


def main() -> None:
    refs = json.loads((HERE.parent / "guidelines/references.json").read_text(encoding="utf-8"))["references"]
    overlay = {}
    for path in sorted((HERE / "src").glob("answers_*.json")):
        overlay.update(json.loads(path.read_text(encoding="utf-8")))

    topics, questions = [], []
    for path in sorted((HERE / "src").glob("topic_*.json")):
        src = json.loads(path.read_text(encoding="utf-8"))
        file_topics = src.get("topics") or [src["topic"]]
        default_topic = file_topics[0]["id"] if "topic" in src else None
        for t in file_topics:
            t.setdefault("pending", False)
            topics.append(t)
        for q in src["questions"]:
            q.setdefault("topic", default_topic)
            q.update(overlay.get(q["id"], {}))
            q.setdefault("sample", False)
            q.setdefault("jurisdiction", "ALL")
            q.setdefault("updated", UPDATED)
            q.setdefault("translation_status", dict(TRANSLATION))
            q.setdefault("links", [])
            q.setdefault("locators", {})
            q["prepare"] = {k: q["prepare"].get(k, []) for k in BLOCKS}
            cites = []
            for _, tri in question_texts(q):
                for k in tri_keys(tri):
                    if k not in cites:
                        cites.append(k)
            q["citations"] = cites
            q["claims"] = claims_for(q["id"], question_texts(q), q["locators"])
            questions.append(q)
    topics.sort(key=lambda t: t["order"])
    for t in topics:
        t["question_ids"] = [q["id"] for q in questions if q["topic"] == t["id"]]
    order = {t["id"]: i for i, t in enumerate(topics)}
    questions.sort(key=lambda q: (order[q["topic"]], topics[order[q["topic"]]]["question_ids"].index(q["id"])))

    principles = json.loads((HERE / "src/principles.json").read_text(encoding="utf-8"))["principles"]
    for p in principles:
        p["citations"] = tri_keys(p["text"])
        p["claims"] = claims_for(p["id"], [("text", p["text"])], p.get("locators", {}))

    sim = json.loads((HERE / "src/simulator.json").read_text(encoding="utf-8"))
    for s in sim["scenarios"]:
        s.setdefault("sample", False)
        texts = [(f"option.{i}.feedback", o["feedback"]) for i, o in enumerate(s["options"])]
        cites = []
        for _, tri in texts:
            for k in tri_keys(tri):
                if k not in cites:
                    cites.append(k)
        s["citations"] = cites
        s["claims"] = claims_for(s["id"], texts, s.get("locators", {}))

    used = {k for q in questions for k in q["citations"]}
    used |= {k for p in principles for k in p["citations"]}
    used |= {k for s in sim["scenarios"] for k in s["citations"]}
    out = {
        "schema": "fe-court-prep/2",
        "generated_by": "content/court_prep/build.py",
        "language_order": ["uz", "ru", "en"],
        "prepare_blocks": list(BLOCKS),
        "topics": topics,
        "questions": questions,
        "principles": principles,
        "simulator": sim,
        "references": [r for r in refs if r["key"] in used],
    }
    text = json.dumps(out, ensure_ascii=False, indent=2) + "\n"
    (HERE / "court_prep_v1.json").write_text(text, encoding="utf-8")
    ASSET.parent.mkdir(parents=True, exist_ok=True)
    ASSET.write_text(text, encoding="utf-8")
    print(f"wrote content/court_prep/court_prep_v1.json (+ app asset): {len(topics)} topics, "
          f"{len(questions)} questions, {len(principles)} principles, "
          f"{len(sim['scenarios'])} scenarios, {len(out['references'])} references")


if __name__ == "__main__":
    main()
