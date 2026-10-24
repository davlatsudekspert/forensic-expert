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
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/slides"))
import topics  # noqa: E402

# Egasi qarori (2026-10-18): kurs yozilmaydi, fakultet bo'yicha bitta guruh.
# Joriy reja (KTP 2026) birinchi; eski rejadagi qolgan mavzular oxiriga qo'shiladi.
# Guruh ichida bir xil prezentatsiyani ochadigan takror mavzu yashiriladi.
COURSES = {
    "KTP 2026 davolash": "Davolash ishi fakulteti",
    "KTP 2026 pediatriya": "Pediatriya fakulteti",
    "KTP 2026 stomatologiya": "Stomatologiya fakulteti",
    "4 kurs davolash": "Davolash ishi fakulteti",
    "6 kurs davolash": "Davolash ishi fakulteti",
    "4 kurs pediatriya": "Pediatriya fakulteti",
    "5 kurs tibbiy profilaktika": "Tibbiy profilaktika fakulteti",
    "2 kurs bioetika": "Bioetika",
}
TOKS_COURSE = "Toksikologik kimyo"
# «Apparatlar bilan ishlash» (2026-10-24): deck fayli out/instr-NN-<id>.json, tartib = NN.
INSTR_COURSE = "Apparatlar bilan ishlash"
# Eski rejadagi mavzular joriy rejadan keyin turadi.
# KTP ichida: ma'ruza (M), amaliy (A), mustaqil (MT), qo'shimcha (MR) — shu tartibda.
KTP_PART = {"M": 0, "A": 100, "MT": 200, "MR": 300}
POSITION_OFFSET = {"KTP 2026 davolash": 0, "KTP 2026 pediatriya": 0, "KTP 2026 stomatologiya": 0}


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

    order = list(COURSES)
    plan.sort(key=lambda t: order.index(t["course"]) if t["course"] in COURSES else len(order))
    decks, rows, seen = {}, [], set()
    for t in plan:
        if t["course"] not in COURSES:
            continue
        did = t["id"] if t["id"] in deck_ids else aliases.get(t["id"])
        if did not in deck_ids:
            continue
        course = COURSES[t["course"]]
        pos = ((t.get("number") or 0) + KTP_PART.get(re.sub(r"\d+$", "", t["id"].rsplit("-", 1)[-1]), 0)
               + POSITION_OFFSET.get(t["course"], 1000 * (order.index(t["course"]))))
        hidden = (course, did) in seen
        seen.add((course, did))
        rows.append((t["id"], did, course, t["title"], pos, hidden))
        decks.setdefault(did, None)
    for did in decks:
        d = json.loads(git_show(a.git_ref, f"out/{did}.json"))
        d.pop("mcq", None)
        decks[did] = d

    # «Toksikologik kimyo» kursi (docs/toks/toks_syllabus.json): deck fayli
    # out/toks-NN-<id>.json, mavzu = deck (1:1), tartib = dars raqami.
    syl = json.loads((ROOT / "docs/toks/toks_syllabus.json").read_text(encoding="utf-8"))
    for les in syl:
        did = f"toks-{les['n']:02d}-{les['id']}"
        if did not in deck_ids:
            continue
        title = re.sub(r"^\[[^\]]*\]\s*", "", les["title_uz"]).strip()
        rows.append((did, did, TOKS_COURSE, title, les["n"], False))
        if did not in decks:
            d = json.loads(git_show(a.git_ref, f"out/{did}.json"))
            d.pop("mcq", None)
            decks[did] = d
    for did in deck_ids:
        m = re.match(r"^instr-(\d+)-", did)
        if not m:
            continue
        d = json.loads(git_show(a.git_ref, f"out/{did}.json"))
        d.pop("mcq", None)
        decks[did] = d
        rows.append((did, did, INSTR_COURSE, str(d.get("topic") or did), int(m.group(1)), False))
    out = []
    for did, d in sorted(decks.items()):
        out.append(
            "insert into public.lesson_decks (deck_id, title, deck, slide_count, search_text, source_lang) values ("
            f"{q(did)}, {q((d.get('topic') or did)[:400])}, {q(json.dumps(d, ensure_ascii=False))}::jsonb, "
            f"{len(d.get('slides', []))}, {q(search_text(d))}, {q(d.get('lang') or 'uz')}) "
            "on conflict (deck_id) do update set title = excluded.title, deck = excluded.deck, "
            "slide_count = excluded.slide_count, search_text = excluded.search_text, "
            "source_lang = excluded.source_lang, updated_at = now();")
    for tid, did, course, title, pos, hidden in rows:
        out.append(
            "insert into public.lesson_topics (topic_id, deck_id, course, title, position, hidden) values ("
            f"{q(tid)}, {q(did)}, {q(course)}, {q(title[:400])}, {int(pos)}, {str(hidden).lower()}) "
            "on conflict (topic_id) do update set deck_id = excluded.deck_id, course = excluded.course, "
            "title = excluded.title, position = excluded.position, hidden = excluded.hidden;")
    pathlib.Path(a.out).parent.mkdir(parents=True, exist_ok=True)
    pathlib.Path(a.out).write_text("\n".join(out) + "\n", encoding="utf-8")
    shown = [r for r in rows if not r[5]]
    print(f"lessons: {len(decks)} deck, {len(rows)} mavzu ({len(shown)} ko'rinadi) → {a.out}")
    for c in [*dict.fromkeys(COURSES.values()), TOKS_COURSE, INSTR_COURSE]:
        print(f"  {c}: {sum(1 for r in shown if r[2] == c)}")


if __name__ == "__main__":
    main()
