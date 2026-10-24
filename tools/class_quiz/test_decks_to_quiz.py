#!/usr/bin/env python3
"""decks_to_quiz.py + import_quiz_bank.py (uz-only) testlari.

  python3 -m pytest tools/class_quiz -q      # yoki
  python3 tools/class_quiz/test_decks_to_quiz.py
"""
import json
import pathlib
import subprocess
import sys
import tempfile
import unittest

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import decks_to_quiz as d2q  # noqa: E402
import import_quiz_bank as imp  # noqa: E402

SRC = {"author": "Yuldashev A.", "title": "Toksikologik kimyo", "page": "123"}


def mcq(i=1, **kw):
    m = {
        "question": f"Savol matni raqam {i}?",
        "options": [f"A{i}", f"B{i}", f"C{i}", f"D{i}"],
        "correct_index": 1,
        "explanation": "Izoh matni.",
        "source": dict(SRC),
    }
    m.update(kw)
    return m


def deck(*qs, topic="Mavzu sarlavhasi"):
    return {"topic": topic, "slides": [], "mcq": list(qs)}


class DeckToQuiz(unittest.TestCase):
    def test_format(self):
        q, pr = d2q.convert_deck("toks-01-kirish", deck(mcq(1), mcq(2)))
        self.assertEqual(pr, [])
        self.assertEqual(q["topic_id"], "toks-01-kirish")
        self.assertEqual(q["source_lang"], "uz")
        self.assertEqual(q["title_i18n"], {"uz": "Mavzu sarlavhasi", "ru": "Mavzu sarlavhasi", "en": "Mavzu sarlavhasi"})
        self.assertEqual(q["translation_status"], {"uz": "source", "ru": "pending", "en": "pending"})
        self.assertEqual([x["id"] for x in q["questions"]], ["toks-01-kirish-q01", "toks-01-kirish-q02"])
        x = q["questions"][0]
        self.assertEqual(set(x["question_i18n"]), {"uz"})
        self.assertEqual(len(x["options_i18n"]["uz"]), 4)
        self.assertEqual(x["translation_status"]["ru"], "pending")
        self.assertEqual(q["sources"], [{"author": SRC["author"], "title": SRC["title"]}])

    def test_invalid_skipped(self):
        bad = [
            mcq(1, options=["a", "b", "c"]),
            mcq(2, options=["a", "a", "c", "d"]),
            mcq(3, correct_index=4),
            mcq(4, explanation=""),
            mcq(5, source={"author": "X", "title": "Y", "page": "--"}),
            mcq(6, source={"author": "", "title": "Y", "page": "3"}),
        ]
        q, pr = d2q.convert_deck("a-b", deck(mcq(7), *bad))
        self.assertEqual(len(q["questions"]), 1)
        self.assertEqual(len(pr), 6)
        none, pr2 = d2q.convert_deck("a-b", deck(*bad))
        self.assertIsNone(none)

    def test_short_title(self):
        long = "Tibbiy bioetikaning oldingi modellardan farqi: " + "x " * 120 + "(M2)"
        t = d2q.short_title(long)
        self.assertEqual(t, "Tibbiy bioetikaning oldingi modellardan farqi (M2)")
        self.assertLessEqual(len(d2q.short_title("so‘z " * 100)), d2q.TITLE_MAX)

    def test_existing_not_overwritten(self):
        with tempfile.TemporaryDirectory() as a, tempfile.TemporaryDirectory() as b:
            src, dst = pathlib.Path(a), pathlib.Path(b)
            (src / "toks-01-x.json").write_text(json.dumps(deck(mcq())), encoding="utf-8")
            (src / "toks-02-y.json").write_text(json.dumps(deck(mcq())), encoding="utf-8")
            (src / "toks-02-y.unvalidated.json").write_text("{}", encoding="utf-8")
            (src / "toks-02-y.en.json").write_text("{}", encoding="utf-8")
            (dst / "toks-01-x.json").write_text('{"keep": true}', encoding="utf-8")
            r = subprocess.run(
                [sys.executable, str(HERE / "decks_to_quiz.py"), "--src", a, "--dst", b],
                capture_output=True,
                text=True,
            )
            self.assertEqual(r.returncode, 0, r.stderr)
            self.assertEqual(json.loads((dst / "toks-01-x.json").read_text()), {"keep": True})
            self.assertEqual(sorted(p.name for p in dst.glob("*.json")), ["toks-01-x.json", "toks-02-y.json"])


class ImporterUzOnly(unittest.TestCase):
    def convert(self, ids):
        inputs = []
        for i in ids:
            q, _ = d2q.convert_deck(i, deck(mcq(1), mcq(2)))
            inputs.append((i, q))
        return imp.convert(inputs)

    def test_uz_only_accepted_with_pending(self):
        _, topics, skipped, problems = self.convert(["toks-01-x"])
        self.assertEqual((skipped, problems), (0, []))
        t = topics[0]
        self.assertEqual(t["translation_status"]["ru"], "pending")
        q = t["questions"][0]
        for lang in ("ru", "en"):
            self.assertEqual(q["question_i18n"][lang], q["question_i18n"]["uz"])
            self.assertEqual(q["options_i18n"][lang], q["options_i18n"]["uz"])
            self.assertEqual(q["translation_status"][lang], "pending")
        self.assertEqual(q["translation_status"]["uz"], "source")

    def test_groups(self):
        cases = {
            "toks-05-x": "toksikologik-kimyo",
            "ktp26-davolash-M1": "ktp-2026-davolash",
            "ktp26-pediatriya-M6": "ktp-2026-pediatriya",
            "ktp26-stomatologiya-M1": "ktp-2026-stomatologiya",
            "ktp26-u-03": "sud-tibbiyoti-ktp-2026",
            "4-kurs-davolash-06": "sud-tibbiyoti-4-davolash",
            "unknown-1": "boshqa",
        }
        for tid, gid in cases.items():
            self.assertEqual(imp.group_of(tid)[0], gid, tid)
        self.assertEqual(imp.group_of("toks-05-x")[2]["uz"], "Toksikologik kimyo")

    def test_ktp_order(self):
        self.assertLess(imp.topic_number("ktp26-davolash-M6"), imp.topic_number("ktp26-davolash-A2"))
        self.assertLess(imp.topic_number("ktp26-davolash-A10"), imp.topic_number("ktp26-davolash-MR14"))
        self.assertEqual(imp.topic_number("4-kurs-davolash-06"), 6)

    def test_sql_pending_marker(self):
        _, topics, _, _ = self.convert(["ktp26-davolash-M1"])
        with tempfile.TemporaryDirectory() as d:
            p = pathlib.Path(d) / "x.sql"
            rows = imp.write_sql(p, topics)
            text = p.read_text(encoding="utf-8")
        self.assertEqual(rows, 2 * 3)
        self.assertIn("'ktp26-davolash-M1~ru'", text)
        self.assertIn('"translation": "pending"', text)

    def test_three_lang_unchanged(self):
        full = {
            "topic_id": "x-1",
            "title_i18n": {"uz": "T", "ru": "Т", "en": "T"},
            "questions": [
                {
                    "id": "x-1-q1",
                    "question_i18n": {"uz": "Savol?", "ru": "Вопрос?", "en": "Question?"},
                    "options_i18n": {l: ["a", "b", "c", "d"] for l in ("uz", "ru", "en")},
                    "correct_index": 0,
                    "explanation_i18n": {"uz": "u", "ru": "р", "en": "e"},
                    "source": SRC,
                }
            ],
        }
        _, topics, _, _ = imp.convert([("x", full)])
        q = topics[0]["questions"][0]
        self.assertEqual(q["question_i18n"]["ru"], "Вопрос?")
        self.assertEqual(q["translation_status"]["ru"], "auto_unreviewed")


if __name__ == "__main__":
    unittest.main()
