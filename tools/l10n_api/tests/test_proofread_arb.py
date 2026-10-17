import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parent))
import common as C
import proofread_arb as P
from mock_client import MockClient, user_of

CYR_O = "о"  # kirill 'о' (lotin 'o' ga o'xshash)


def write_arbs(d: Path, n=5):
    uz = {"@@locale": "uz", "appTitle": "Forensic Expert"}
    ru = {"@@locale": "ru", "appTitle": "Forensic Expert"}
    en = {"@@locale": "en", "@appTitle": {"description": "Brand"}, "appTitle": "Forensic Expert"}
    for i in range(n):
        k = f"key{i}"
        en[k] = f"Result: {{value}} mg/L ({i})"
        ru[k] = f"Результат: {{value}} мг/л ({i})"
        uz[k] = f"Natija: {{value}} mg/L ({i})"
        en["@" + k] = {"description": f"desc {i}", "placeholders": {"value": {"type": "String"}}}
    uz["key1"] = "Natija: {value} mg/L (1) xat" + CYR_O
    for l, x in (("uz", uz), ("ru", ru), ("en", en)):
        (d / f"app_{l}.arb").write_text(json.dumps(x, ensure_ascii=False), encoding="utf-8")


def args(tmp, **kw):
    ns = dict(arb_dir=str(tmp), out_dir=str(tmp / "out"), batch_size=2, max_usd=5.0, dry_run=False,
              resume=False, only=None, max_keys=0, batch_limit=0)
    ns.update(kw)
    return type("A", (), ns)()


def test_build_items_skips_brand_and_meta(tmp_path):
    write_arbs(tmp_path)
    items = P.build_items(P.load_arbs(tmp_path))
    assert [i["key"] for i in items] == [f"key{i}" for i in range(5)]
    assert items[0]["note"] == "desc 0" and items[0]["ph"] == ["value"]


def test_dry_run_makes_no_calls(tmp_path):
    write_arbs(tmp_path)
    called = []
    orig = C.make_client
    C.make_client = lambda: called.append(1)
    try:
        assert P.run(args(tmp_path, dry_run=True)) == 0
    finally:
        C.make_client = orig
    assert not called
    est = json.loads((tmp_path / "out/arb_dryrun.json").read_text())
    assert est["keys"] == 5 and est["batches"] == 3 and est["est_usd"] > 0
    assert not (tmp_path / "out/arb_review.json").exists()


def test_run_validates_and_never_touches_arb(tmp_path):
    write_arbs(tmp_path)
    before = {p.name: p.read_bytes() for p in tmp_path.glob("*.arb")}

    def responder(kw):
        u = user_of(kw)
        f = []
        if '"key1"' in u:
            f += [
                {"key": "key1", "lang": "uz", "new": "Natija: {value} mg/L (1) xato", "reason": "Kirill harf", "severity": "high", "category": "mixed_language"},
                {"key": "key1", "lang": "ru", "new": "Результат: {znach} мг/л (1)", "reason": "x", "severity": "low", "category": "spelling"},
                {"key": "key9", "lang": "en", "new": "x", "reason": "x", "severity": "low", "category": "spelling"},
            ]
        if '"key3"' in u:
            f += [{"key": "key3", "lang": "en", "new": "Result: {value mg/L (3)", "reason": "x", "severity": "medium", "category": "grammar"},
                  {"key": "key3", "lang": "ru", "new": "Результат: {value} мг/л (30)", "reason": "x", "severity": "error", "category": "spelling"}]
        return json.dumps({"findings": f})

    cl = MockClient(responder)
    assert P.run(args(tmp_path), client=cl) == 0
    out = tmp_path / "out"
    rev = json.loads((out / "arb_review.json").read_text())
    assert [(r["key"], r["lang"]) for r in rev] == [("key1", "uz")]
    assert rev[0]["old"].endswith("xat" + CYR_O) and rev[0]["severity"] == "high"   # old faylning o'zidan
    rej = json.loads((out / "arb_review_rejected.json").read_text())
    assert len(rej) == 4
    reasons = " ".join(" ".join(r["rejected"]) for r in rej)
    assert "placeholder" in reasons and "ICU" in reasons and "raqam" in reasons and "batchda yo'q" in reasons
    assert json.loads((out / "arb_patch_uz.json").read_text()) == {"key1": "Natija: {value} mg/L (1) xato"}
    assert json.loads((out / "arb_patch_ru.json").read_text()) == {}
    md = (out / "arb_review.md").read_text()
    assert "taklif" in md and "key1" in md
    assert {p.name: p.read_bytes() for p in tmp_path.glob("*.arb")} == before   # ARB o'zgarmagan
    assert len(cl.calls) == 3
    assert "appTitle" not in user_of(cl.calls[0])  # brend yuborilmaydi


def test_budget_stop_writes_partial_and_resume(tmp_path):
    write_arbs(tmp_path)
    cl = MockClient(lambda kw: '{"findings":[]}')   # har chaqiruv ~0.0105 USD
    P.run(args(tmp_path, max_usd=0.02), client=cl)   # ikkita chaqiruvga yetadi, uchinchisiga yo'q
    assert (tmp_path / "out/arb_review.md").exists()
    assert "Byudjet tugadi" in (tmp_path / "out/arb_review.md").read_text()
    done_first = len(json.loads((tmp_path / "out/arb_progress.json").read_text())["done"])
    assert done_first < 3
    cl2 = MockClient(lambda kw: '{"findings":[]}')
    P.run(args(tmp_path, resume=True), client=cl2)
    assert len(json.loads((tmp_path / "out/arb_progress.json").read_text())["done"]) == 3
    assert len(cl2.calls) == 3 - done_first


def test_failed_batch_does_not_crash(tmp_path):
    write_arbs(tmp_path)
    n = {"i": 0}

    def responder(kw):
        n["i"] += 1
        return "bu JSON emas" if n["i"] <= 2 else '{"findings":[]}'
    assert P.run(args(tmp_path), client=MockClient(responder)) == 0
    assert "Muvaffaqiyatsiz" in (tmp_path / "out/arb_review.md").read_text()


def test_real_arb_batching():
    items = P.build_items(P.load_arbs(P.DEFAULT_ARB_DIR))
    assert len(items) > 2000
    assert len(P.make_batches(items, 70)) == -(-len(items) // 70)
