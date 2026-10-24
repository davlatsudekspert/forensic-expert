#!/usr/bin/env python3
"""Dars (deck) JSON'idagi `mcq` → «Sinfda test» banki kirish formati.

`out/<deck_id>.json` (DECK_SPEC_V2 §1: topic, slides, mcq[], sources) →
`quiz/<deck_id>.json` (tools/class_quiz/import_quiz_bank.py kirishi):
  topic_id = deck_id, source_lang "uz", title_i18n{uz: dars sarlavhasi;
  ru/en: o‘zbekcha matn}, translation_status{uz: source, ru/en: pending},
  questions[{id, question_i18n{uz}, options_i18n{uz}, correct_index,
  explanation_i18n{uz}, source, translation_status}], sources.

Qoidalar:
  * mavjud `quiz/<id>.json` (--dst ichida yoki --skip-git-ref dagi) ustidan
    YOZILMAYDI — o‘tkaziladi (18 ta uch tilli mavzu);
  * yaroqsiz savol (4 variant emas, takroriy variant, correct_index 0–3 emas,
    izoh yoki manba muallifi/sarlavhasi/beti yo‘q) tushirib qoldiriladi va
    hisobotda ko‘rsatiladi; hech narsa to‘qilmaydi;
  * `*.unvalidated.json`, `*.en.json` va `aliases.json` o‘qilmaydi;
  * ru/en matni YO‘Q: importer uz matnini «pending» belgisi bilan qo‘yadi,
    ilova «tarjima kutilmoqda» ko‘rsatadi.

  python3 tools/class_quiz/decks_to_quiz.py --src <out papka> --dst <quiz papka>
"""
from __future__ import annotations

import argparse
import json
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
MIN_QUESTIONS = 1
TITLE_MAX = 120
PAGE_EMPTY = re.compile(r"^[\s\-–—.]*$")
DECK_ID = re.compile(r"^[A-Za-z0-9][A-Za-z0-9-]{1,70}$")


def clean(s) -> str:
    return re.sub(r"\s+", " ", str(s or "")).strip()


def short_title(topic: str, limit: int = TITLE_MAX) -> str:
    """Uzun dars sarlavhasini qisqartiradi: «…: ro‘yxat» bo‘lsa ikki nuqtagacha,
    keyin so‘z chegarasida «…» bilan. Oxiridagi (M2)/(A6) kodi saqlanadi."""
    t = clean(topic)
    if len(t) <= limit:
        return t
    code = re.search(r"\s*\(([A-Z]{1,3}\d{1,2})\)\s*$", t)
    suffix = f" ({code.group(1)})" if code else ""
    head = t[: code.start()] if code else t
    if ":" in head and len(head.split(":")[0]) >= 15:
        head = head.split(":")[0].rstrip()
    if len(head) + len(suffix) > limit:
        head = head[: limit - len(suffix) - 1].rsplit(" ", 1)[0].rstrip(",;:–- ") + "…"
    return head + suffix


def convert_deck(deck_id: str, d: dict, title: str | None = None):
    """→ (quiz dict | None, problems[])."""
    problems: list[str] = []
    raw_topic = d.get("topic")
    if isinstance(raw_topic, dict):
        raw_topic = raw_topic.get("title") or raw_topic.get("uz")
    title = clean(title) or short_title(raw_topic or "")
    if not title:
        return None, [f"{deck_id}: sarlavha (topic) yo‘q"]
    qs, seen = [], set()
    for n, m in enumerate(d.get("mcq") or [], start=1):
        label = f"{deck_id} mcq#{n}"
        q = clean(m.get("question"))
        opts = [clean(o) for o in (m.get("options") or [])]
        ci = m.get("correct_index")
        ex = clean(m.get("explanation"))
        src = m.get("source") or {}
        author, stitle, page = clean(src.get("author")), clean(src.get("title")), clean(src.get("page"))
        why = None
        if len(q) < 5:
            why = "savol matni yo‘q"
        elif len(opts) != 4 or any(not o for o in opts):
            why = "4 ta variant emas"
        elif len({o.lower() for o in opts}) != 4:
            why = "variantlar takrorlangan"
        elif isinstance(ci, bool) or not isinstance(ci, int) or not 0 <= ci <= 3:
            why = "correct_index 0–3 emas"
        elif not ex:
            why = "izoh yo‘q"
        elif not author or not stitle:
            why = "manba muallifi/sarlavhasi yo‘q"
        elif PAGE_EMPTY.match(page):
            why = "manbada bet/joy yo‘q"
        elif q.lower() in seen:
            why = "takroriy savol"
        if why:
            problems.append(f"{label}: {why} — o‘tkazildi")
            continue
        seen.add(q.lower())
        qs.append(
            {
                "id": f"{deck_id}-q{len(qs) + 1:02d}",
                "question_i18n": {"uz": q},
                "options_i18n": {"uz": opts},
                "correct_index": ci,
                "explanation_i18n": {"uz": ex},
                "source": {"author": author, "title": stitle, "page": page},
                "translation_status": {"uz": "source", "ru": "pending", "en": "pending"},
            }
        )
    if len(qs) < MIN_QUESTIONS:
        return None, problems + [f"{deck_id}: yaroqli savol yo‘q — dars o‘tkazildi"]
    sources, seen_s = [], set()
    for q in qs:
        k = (q["source"]["author"], q["source"]["title"])
        if k not in seen_s:
            seen_s.add(k)
            sources.append({"author": k[0], "title": k[1]})
    quiz = {
        "topic_id": deck_id,
        "source_lang": "uz",
        "title_i18n": {"uz": title, "ru": title, "en": title},
        "translation_status": {"uz": "source", "ru": "pending", "en": "pending"},
        "questions": qs,
        "sources": sources,
    }
    return quiz, problems


def deck_files(src: pathlib.Path):
    for f in sorted(src.glob("*.json")):
        n = f.name
        if n.endswith(".en.json") or ".unvalidated" in n or n == "aliases.json":
            continue
        yield f


def git_quiz_ids(ref: str) -> set[str]:
    names = subprocess.check_output(
        ["git", "ls-tree", "-r", "--name-only", ref, "quiz/"], cwd=ROOT, text=True
    ).split()
    return {pathlib.Path(n).stem for n in names if n.endswith(".json")}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--src", required=True, help="out/<deck_id>.json joylashgan papka")
    ap.add_argument("--dst", required=True, help="quiz/<deck_id>.json yoziladigan papka")
    ap.add_argument("--skip-git-ref", help="masalan origin/slides-out: undagi quiz/*.json id'lari o‘tkaziladi")
    ap.add_argument("--titles", help="JSON {deck_id: sarlavha} (lesson_topics.title); bo‘lmasa deck `topic`i qisqartiriladi")
    a = ap.parse_args()

    src, dst = pathlib.Path(a.src), pathlib.Path(a.dst)
    dst.mkdir(parents=True, exist_ok=True)
    skip = {p.stem for p in dst.glob("*.json")}
    if a.skip_git_ref:
        skip |= git_quiz_ids(a.skip_git_ref)
    titles = json.loads(pathlib.Path(a.titles).read_text(encoding="utf-8")) if a.titles else {}

    written = skipped_existing = skipped_bad = nq = 0
    problems: list[str] = []
    for f in deck_files(src):
        did = f.stem
        if not DECK_ID.match(did):
            problems.append(f"{f.name}: noto‘g‘ri deck_id")
            continue
        if did in skip:
            skipped_existing += 1
            continue
        d = json.loads(f.read_text(encoding="utf-8"))
        quiz, pr = convert_deck(did, d, titles.get(did))
        problems += pr
        if quiz is None:
            skipped_bad += 1
            continue
        (dst / f"{did}.json").write_text(
            json.dumps(quiz, ensure_ascii=False, indent=1) + "\n", encoding="utf-8"
        )
        written += 1
        nq += len(quiz["questions"])
    for p in problems:
        print("  ! " + p)
    print(
        f"decks_to_quiz: {written} fayl, {nq} savol → {dst} "
        f"(mavjud, ustidan yozilmadi: {skipped_existing}; savolsiz o‘tkazildi: {skipped_bad})"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
