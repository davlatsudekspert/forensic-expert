#!/usr/bin/env python3
"""«Darslar» server seed: slides-out/out/*.json (prezentatsiyalar) + out/aliases.json
+ o'quv rejalari (tools/slides/topics.py) → SQL (faqat INSERT ... ON CONFLICT DO UPDATE).

Hech narsa o'chirilmaydi. Test savollari (mcq) yuklanmaydi — ular «Sinfda test»da.
`ktp26-u-*` (KTP takrorlarini birlashtirish uchun ichki ro'yxat) ustozga ko'rsatilmaydi.

  python3 tools/lessons/build_lessons_seed.py --git-ref origin/slides-out --out build/lessons_seed.sql
"""
import argparse
import json
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/slides"))
import topics  # noqa: E402

COURSES = {
    "2 kurs bioetika": "2-kurs · Bioetika",
    "4 kurs davolash": "4-kurs · Davolash ishi",
    "4 kurs pediatriya": "4-kurs · Pediatriya",
    "5 kurs tibbiy profilaktika": "5-kurs · Tibbiy profilaktika",
    "6 kurs davolash": "6-kurs · Davolash ishi",
    "KTP 2026 davolash": "2026–2027 o‘quv yili · Davolash ishi",
    "KTP 2026 pediatriya": "2026–2027 o‘quv yili · Pediatriya ishi",
    "KTP 2026 stomatologiya": "2026–2027 o‘quv yili · Stomatologiya",
}


def git_show(ref, path):
    return subprocess.run(["git", "show", f"{ref}:{path}"], cwd=ROOT, check=True,
                          capture_output=True, text=True).stdout


def q(s):
    return "'" + str(s).replace("'", "''") + "'"


def search_text(deck):
    parts = [deck.get("topic", "")]
    for sl in deck.get("slides", []):
        parts.append(sl.get("title", ""))
        parts += [b.get("text", "") for b in sl.get("bullets", [])]
    return " ".join(p for p in parts if p)[:20000]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--git-ref", default="origin/slides-out")
    ap.add_argument("--out", required=True)
    a = ap.parse_args()

    names = subprocess.run(["git", "ls-tree", "--name-only", a.git_ref, "out/"], cwd=ROOT,
                           check=True, capture_output=True, text=True).stdout.split()
    deck_ids = sorted(n[4:-5] for n in names if n.endswith(".json") and not n.endswith(".en.json")
                      and ".unvalidated" not in n and not n.endswith("aliases.json"))
    aliases = json.loads(git_show(a.git_ref, "out/aliases.json"))["alias"]
    plan = (topics.parse_topics() + topics.parse_topics(topics.BIOETIKA) + topics.parse_ktp())

    decks, rows = {}, []
    for t in plan:
        if t["course"] not in COURSES:
            continue
        did = t["id"] if t["id"] in deck_ids else aliases.get(t["id"])
        if did not in deck_ids:
            continue
        rows.append((t["id"], did, COURSES[t["course"]], t["title"], t.get("number") or 0))
        decks.setdefault(did, None)
    for did in decks:
        d = json.loads(git_show(a.git_ref, f"out/{did}.json"))
        d.pop("mcq", None)
        decks[did] = d

    out = []
    for did, d in sorted(decks.items()):
        out.append(
            "insert into public.lesson_decks (deck_id, title, deck, slide_count, search_text, source_lang) values ("
            f"{q(did)}, {q((d.get('topic') or did)[:400])}, {q(json.dumps(d, ensure_ascii=False))}::jsonb, "
            f"{len(d.get('slides', []))}, {q(search_text(d))}, {q(d.get('lang') or 'uz')}) "
            "on conflict (deck_id) do update set title = excluded.title, deck = excluded.deck, "
            "slide_count = excluded.slide_count, search_text = excluded.search_text, "
            "source_lang = excluded.source_lang, updated_at = now();")
    for tid, did, course, title, pos in rows:
        out.append(
            "insert into public.lesson_topics (topic_id, deck_id, course, title, position) values ("
            f"{q(tid)}, {q(did)}, {q(course)}, {q(title[:400])}, {int(pos)}) "
            "on conflict (topic_id) do update set deck_id = excluded.deck_id, course = excluded.course, "
            "title = excluded.title, position = excluded.position;")
    pathlib.Path(a.out).parent.mkdir(parents=True, exist_ok=True)
    pathlib.Path(a.out).write_text("\n".join(out) + "\n", encoding="utf-8")
    print(f"lessons: {len(decks)} deck, {len(rows)} mavzu → {a.out}")


if __name__ == "__main__":
    main()
