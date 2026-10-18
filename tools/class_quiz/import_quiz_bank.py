#!/usr/bin/env python3
"""«Sinfda test» savollar banki importi: `slides-out` branchidagi `quiz/*.json`
→ ilova asseti `apps/mobile/assets/content/class_quiz/class_quiz_bank.json`.

Takror ishga tushiriladi (idempotent, deterministik: vaqt tamg‘asi yo‘q, tartib
barqaror). Yangi mavzu qo‘shilsa — shunchaki qayta ishga tushiring.

Kirish fayli (tools/slides/generate_quiz.py chiqishi):
  {topic_id, source_lang, title_i18n{uz,ru,en}, translation_status{..},
   questions:[{id, question_i18n, options_i18n{uz,ru,en:[4]}, correct_index,
               explanation_i18n, source{author,title,page}, difficulty,
               translation_status}], sources:[..]}

Qoidalar (CLAUDE.md «Uch tilli kontent», «Testlar»):
  * aniq 4 variant (har tilda), `correct_index` 0–3, savol va izoh har tilda;
  * manba: muallif + sarlavha + bet/joy majburiy; «-», «--» kabi bo‘sh bet —
    savol bankka KIRMAYDI (manbasiz savol baholanadigan rejimga kirmaydi);
  * ru/en tarjima holati (`auto_unreviewed`) saqlanadi — ilova «Avtomatik
    tarjima — tekshirilmagan» belgisini ko‘rsatadi; hech narsa to‘qilmaydi;
  * mavzular kurs/fan bo‘yicha guruhlanadi (topic_id prefiksidan).

Ishga tushirish (repo ildizida):
  git fetch origin slides-out
  python3 tools/class_quiz/import_quiz_bank.py --git-ref origin/slides-out
  # yoki yuklab olingan papkadan:
  python3 tools/class_quiz/import_quiz_bank.py --src /yo‘l/quiz
  # server banki uchun SQL (production’ga QO‘LLANMAYDI — egasi tasdig‘i bilan):
  python3 tools/class_quiz/import_quiz_bank.py --git-ref origin/slides-out \
      --sql build/class_quiz_bank_seed.sql
"""
from __future__ import annotations

import argparse
import json
import os
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / "apps/mobile/assets/content/class_quiz/class_quiz_bank.json"
SOURCE_CHECK = ROOT / "docs/qa/quiz_source_check_20261018.jsonl"
CHECK_DATE = "2026-10-18"
# Tuzatilgan 'wrong' yozuv: javob manbaga ko‘ra to‘g‘rilangan — tekshirilgan hisoblanadi.
CHECK_OK_VERDICTS = {"ok"}
CHECK_FIXED_QIDS = {"4-kurs-davolash-06-q24"}
LANGS = ("uz", "ru", "en")
FORMAT = "fe.class_quiz_bank/1"

# Kurs/fan guruhlari: topic_id prefiksi → guruh. Tartib — ro‘yxatdagi tartib.
GROUPS = [
    (
        r"^2-kurs-bioetika-",
        "bioetika-2",
        {
            "uz": "Bioetika · 2-kurs",
            "ru": "Биоэтика · 2 курс",
            "en": "Bioethics · Year 2",
        },
    ),
    (
        r"^4-kurs-davolash-",
        "sud-tibbiyoti-4-davolash",
        {
            "uz": "Sud tibbiyoti · 4-kurs, davolash ishi",
            "ru": "Судебная медицина · 4 курс, лечебное дело",
            "en": "Forensic medicine · Year 4, General Medicine",
        },
    ),
    (
        r"^4-kurs-pediatriya-",
        "sud-tibbiyoti-4-pediatriya",
        {
            "uz": "Sud tibbiyoti · 4-kurs, pediatriya ishi",
            "ru": "Судебная медицина · 4 курс, педиатрия",
            "en": "Forensic medicine · Year 4, Paediatrics",
        },
    ),
    (
        r"^5-kurs-tibbiy-profilaktika-",
        "sud-tibbiyoti-5-tibbiy-profilaktika",
        {
            "uz": "Sud tibbiyoti · 5-kurs, tibbiy profilaktika",
            "ru": "Судебная медицина · 5 курс, медико-профилактическое дело",
            "en": "Forensic medicine · Year 5, Preventive Medicine",
        },
    ),
    (
        r"^6-kurs-davolash-",
        "sud-tibbiyoti-6-davolash",
        {
            "uz": "Sud tibbiyoti · 6-kurs, davolash ishi",
            "ru": "Судебная медицина · 6 курс, лечебное дело",
            "en": "Forensic medicine · Year 6, General Medicine",
        },
    ),
    (
        r"^ktp26-u-",
        "sud-tibbiyoti-ktp-2026",
        {
            "uz": "Sud tibbiyoti · KTP 2026 (umumiy mavzular)",
            "ru": "Судебная медицина · КТП 2026 (общие темы)",
            "en": "Forensic medicine · 2026 curriculum (common topics)",
        },
    ),
]
OTHER = (
    "boshqa",
    {"uz": "Boshqa mavzular", "ru": "Другие темы", "en": "Other topics"},
)

EMPTY_PAGE = re.compile(r"^[\s\-–—.]*$")


def group_of(topic_id: str):
    for i, (rx, gid, titles) in enumerate(GROUPS):
        if re.match(rx, topic_id):
            return gid, i, titles
    return OTHER[0], len(GROUPS), OTHER[1]


def topic_number(topic_id: str) -> int:
    m = re.search(r"(\d+)$", topic_id)
    return int(m.group(1)) if m else 0


def read_inputs(src: str | None, git_ref: str | None) -> list[tuple[str, dict]]:
    out = []
    if git_ref:
        names = subprocess.check_output(
            ["git", "ls-tree", "-r", "--name-only", git_ref, "quiz/"],
            cwd=ROOT,
            text=True,
        ).split()
        for n in sorted(names):
            if n.endswith(".json"):
                raw = subprocess.check_output(["git", "show", f"{git_ref}:{n}"], cwd=ROOT)
                out.append((n, json.loads(raw)))
    else:
        base = pathlib.Path(src)
        files = sorted(base.glob("*.json")) or sorted(base.glob("quiz/*.json"))
        for f in files:
            out.append((str(f), json.loads(f.read_text(encoding="utf-8"))))
    return out


def clean(s) -> str:
    return re.sub(r"\s+", " ", str(s or "")).strip()


def load_source_check(path) -> set[str]:
    """Manba bilan solishtirilgan savol id'lari (iqtibos/matn ko‘chirilmaydi)."""
    if not path or not pathlib.Path(path).exists():
        return set()
    ids = set(CHECK_FIXED_QIDS)
    for line in pathlib.Path(path).read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        r = json.loads(line)
        if r.get("verdict") in CHECK_OK_VERDICTS and r.get("qid"):
            ids.add(str(r["qid"]))
    return ids


def convert(inputs, checked_ids=frozenset()):
    topics, problems, seen_q = [], [], set()
    skipped = 0
    for name, d in inputs:
        tid = clean(d.get("topic_id"))
        if not re.match(r"^[a-z0-9][a-z0-9-]{1,70}$", tid):
            problems.append(f"{name}: noto‘g‘ri topic_id {tid!r}")
            continue
        titles = {l: clean((d.get("title_i18n") or {}).get(l)) for l in LANGS}
        if not titles["uz"]:
            problems.append(f"{name}: uz sarlavha yo‘q")
            continue
        tstatus = d.get("translation_status") or {}
        qs = []
        for q in d.get("questions") or []:
            qid = clean(q.get("id"))
            why = None
            qi = {l: clean((q.get("question_i18n") or {}).get(l)) for l in LANGS}
            ex = {l: clean((q.get("explanation_i18n") or {}).get(l)) for l in LANGS}
            opts = {l: [clean(o) for o in ((q.get("options_i18n") or {}).get(l) or [])] for l in LANGS}
            ci = q.get("correct_index")
            src = q.get("source") or {}
            page = clean(src.get("page"))
            if not qid or qid in seen_q:
                why = "id yo‘q yoki takror"
            elif any(len(qi[l]) < 5 for l in LANGS):
                why = "savol matni yo‘q (biror tilda)"
            elif any(len(opts[l]) != 4 or any(not o for o in opts[l]) for l in LANGS):
                why = "4 ta variant emas"
            elif not isinstance(ci, int) or not 0 <= ci <= 3:
                why = "correct_index 0–3 emas"
            elif any(not ex[l] for l in LANGS):
                why = "izoh yo‘q (biror tilda)"
            elif not clean(src.get("author")) or not clean(src.get("title")):
                why = "manba muallifi/sarlavhasi yo‘q"
            elif EMPTY_PAGE.match(page):
                why = "manbada bet/joy yo‘q («--»)"
            if why:
                skipped += 1
                problems.append(f"{name}: {qid or '?'} — {why}")
                continue
            seen_q.add(qid)
            source = {
                "author": clean(src.get("author")),
                "title": clean(src.get("title")),
                "page": page,
            }
            if qid in checked_ids:
                source["checked"] = {"method": "source_compare", "date": CHECK_DATE}
            qstatus = q.get("translation_status") or tstatus
            qs.append(
                {
                    "id": qid,
                    "question_i18n": qi,
                    "options_i18n": opts,
                    "correct_index": ci,
                    "explanation_i18n": ex,
                    "source": source,
                    "difficulty": clean(q.get("difficulty")) or None,
                    "translation_status": {
                        l: clean(qstatus.get(l)) or ("source" if l == "uz" else "auto_unreviewed")
                        for l in LANGS
                    },
                }
            )
        if not qs:
            problems.append(f"{name}: yaroqli savol yo‘q — mavzu o‘tkazildi")
            continue
        gid, _, _ = group_of(tid)
        topics.append(
            {
                "id": tid,
                "group": gid,
                "number": topic_number(tid),
                "source_lang": clean(d.get("source_lang")) or "uz",
                "title_i18n": titles,
                "translation_status": {
                    l: clean(tstatus.get(l)) or ("source" if l == "uz" else "auto_unreviewed")
                    for l in LANGS
                },
                "questions": qs,
            }
        )
    order = {gid: i for i, (_, gid, _) in enumerate(GROUPS)}
    order[OTHER[0]] = len(GROUPS)
    topics.sort(key=lambda t: (order[t["group"]], t["number"], t["id"]))
    used = {t["group"] for t in topics}
    groups = [
        {"id": gid, "order": i, "title_i18n": titles}
        for i, (_, gid, titles) in enumerate(GROUPS)
        if gid in used
    ]
    if OTHER[0] in used:
        groups.append({"id": OTHER[0], "order": len(GROUPS), "title_i18n": OTHER[1]})
    return groups, topics, skipped, problems


def sql_quote(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def write_sql(path: pathlib.Path, topics) -> int:
    """Server `class_quiz_questions` uchun: har til — alohida mavzu varianti
    (`<id>` = uz, `<id>~ru`, `<id>~en`); ilova o‘z tilidagi variantni tanlaydi."""
    lines = [
        "-- GENERATED by tools/class_quiz/import_quiz_bank.py — qo‘lda o‘zgartirmang.",
        "-- Production’ga faqat egasi tasdig‘i bilan qo‘llanadi (docs/CLASS_QUIZ.md §5).",
        "begin;",
    ]
    ids = []
    rows = 0
    for t in topics:
        for lang in LANGS:
            vid = t["id"] if lang == "uz" else f"{t['id']}~{lang}"
            ids.append(vid)
    lines.append(
        "delete from public.class_quiz_questions where topic_id in ("
        + ", ".join(sql_quote(i) for i in ids)
        + ");"
    )
    for t in topics:
        for lang in LANGS:
            vid = t["id"] if lang == "uz" else f"{t['id']}~{lang}"
            for pos, q in enumerate(t["questions"]):
                src = dict(q["source"])
                if q["translation_status"][lang] != "source":
                    src["translation"] = q["translation_status"][lang]
                lines.append(
                    "insert into public.class_quiz_questions (topic_id, topic_title, position, "
                    "question, options, correct_index, explanation, source) values ("
                    + ", ".join(
                        [
                            sql_quote(vid),
                            sql_quote(t["title_i18n"][lang][:200]),
                            str(pos),
                            sql_quote(q["question_i18n"][lang][:600]),
                            sql_quote(json.dumps(q["options_i18n"][lang], ensure_ascii=False)) + "::jsonb",
                            str(q["correct_index"]),
                            sql_quote(q["explanation_i18n"][lang][:1200]),
                            sql_quote(json.dumps(src, ensure_ascii=False)) + "::jsonb",
                        ]
                    )
                    + ");"
                )
                rows += 1
    lines.append("commit;")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return rows


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--src", help="quiz/*.json joylashgan papka")
    g.add_argument("--git-ref", help="masalan origin/slides-out (quiz/ papkasi o‘qiladi)")
    ap.add_argument("--out", default=str(OUT))
    ap.add_argument("--sql", help="server banki uchun SQL fayli (ixtiyoriy)")
    ap.add_argument(
        "--source-check",
        default=str(SOURCE_CHECK) if SOURCE_CHECK.exists() else None,
        help="manba bilan solishtirish natijasi (jsonl); ok yozuvlarga source.checked qo‘shiladi",
    )
    ap.add_argument("--check", action="store_true", help="faylni yozmaydi; farq bo‘lsa 1 qaytaradi")
    a = ap.parse_args()

    inputs = read_inputs(a.src, a.git_ref)
    if not inputs:
        print("quiz/*.json topilmadi", file=sys.stderr)
        return 2
    groups, topics, skipped, problems = convert(inputs, load_source_check(a.source_check))
    nq = sum(len(t["questions"]) for t in topics)
    bank = {
        "format": FORMAT,
        "generated_by": "tools/class_quiz/import_quiz_bank.py",
        "source": f"{a.git_ref or 'local'}:quiz/*.json",
        "stats": {"topics": len(topics), "questions": nq, "skipped": skipped},
        "groups": groups,
        "topics": topics,
    }
    text = json.dumps(bank, ensure_ascii=False, separators=(",", ":"), sort_keys=False) + "\n"
    out = pathlib.Path(a.out)
    if a.check:
        same = out.exists() and out.read_text(encoding="utf-8") == text
        print("bank up to date" if same else "bank OUT OF DATE")
        return 0 if same else 1
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(text, encoding="utf-8")
    for p in problems:
        print("  ! " + p)
    print(
        f"class quiz bank: {len(topics)} mavzu, {nq} savol (uz/ru/en), "
        f"{len(groups)} guruh, o‘tkazilgan savol: {skipped} → {os.path.relpath(out, ROOT)}"
    )
    if a.sql:
        rows = write_sql(pathlib.Path(a.sql), topics)
        print(f"SQL: {rows} qator → {a.sql} (QO‘LLANMAGAN)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
