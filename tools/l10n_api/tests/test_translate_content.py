import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parent))
import common as C
import translate_content as T
from mock_client import MockClient, user_of


def bundle():
    return {
        "claims": [
            # uz-asl, ru/en yo'q -> bo'shliq (C-AS-* ga o'xshash)
            {"claim_id": "C-AS-001", "value": {"source_lang": "uz", "statement": {"uz": "Etanol qonda 0,5 g/L dan yuqori bo‘lsa, GC-MS bilan tasdiqlanadi."},
                                               "translation_status": {"uz": "authored"}}},
            # faqat en yo'q (ru bor)
            {"claim_id": "C-AS-002", "value": {"source_lang": "uz", "statement": {"uz": "THC 5 ng/mL.", "ru": "THC 5 нг/мл."},
                                               "translation_status": {"uz": "authored", "ru": "machine_draft"}}},
            # ABY: faqat o'zbek -> tarjima qilinmaydi
            {"claim_id": "C-ABY-1", "value": {"locale_only": "uz", "statement": {"uz": "Amaliyot yo‘riqnomasi."}, "translation_status": {"uz": "authored"}}},
            # asl en -> o'tkazib yuboriladi
            {"claim_id": "C-EN-1", "value": {"statement": {"en": "x", "uz": "Bu tarjima"}, "translation_status": {"en": "authored", "uz": "machine_draft"}}},
            # to'liq
            {"claim_id": "C-OK", "value": {"source_lang": "uz", "statement": {"uz": "a", "ru": "б", "en": "a"}}},
        ],
        "topics": [{"topic_id": "t1", "names": {"uz": "Murda dog‘lari"}}],
    }


def make_src(tmp):
    f = tmp / "b.json"
    f.write_text(json.dumps(bundle(), ensure_ascii=False), encoding="utf-8")
    return f


def args(tmp, **kw):
    ns = dict(source=[str(tmp / "b.json")], out_dir=str(tmp / "out"), max_usd=5.0, dry_run=False, resume=False,
              only_ids=None, max_items=0)
    ns.update(kw)
    return type("A", (), ns)()


def test_find_gaps(tmp_path):
    f = make_src(tmp_path)
    gaps, stats = T.load_gaps([f], tmp_path)
    ids = {g["id"]: g for g in gaps}
    assert set(ids) == {"C-AS-001", "C-AS-002", f"b:topics[t1].names"}
    assert ids["C-AS-001"]["need"] == ["ru", "en"] and ids["C-AS-002"]["need"] == ["en"]
    assert ids["C-AS-001"]["claim"] and not ids[f"b:topics[t1].names"]["claim"]
    assert stats.get("skipped_source_unknown") == 1 and not stats.get("skipped_locale_only", 0) == 5
    assert "C-ABY-1" not in ids and "C-EN-1" not in ids


def test_translation_status_dicts_not_treated_as_text():
    assert T.find_gaps({"value": {"translation_status": {"uz": "authored"}}}, "x") == []


def good_responder(kw):
    items = []
    for line in user_of(kw).splitlines()[1:]:
        r = json.loads(line)
        row = {"id": r["id"]}
        if "ru" in r["need"]:
            row["ru"] = r["uz"].replace("Etanol qonda", "Этанол в крови").replace("dan yuqori bo‘lsa, GC-MS bilan tasdiqlanadi.", "выше, подтверждается GC-MS.").replace("Murda dog‘lari", "Трупные пятна")
        if "en" in r["need"]:
            row["en"] = r["uz"].replace("Etanol qonda", "Ethanol in blood").replace("dan yuqori bo‘lsa, GC-MS bilan tasdiqlanadi.", "exceeds, confirmed by GC-MS.").replace("Murda dog‘lari", "Livor mortis").replace("0,5", "0.5").replace("THC 5 ng/mL.", "THC 5 ng/mL.")
        items.append(row)
    return json.dumps({"items": items})


def test_dry_run(tmp_path):
    make_src(tmp_path)
    called = []
    orig = C.make_client
    C.make_client = lambda: called.append(1)
    try:
        assert T.run(args(tmp_path, dry_run=True)) == 0
    finally:
        C.make_client = orig
    d = json.loads((tmp_path / "out/content_dryrun.json").read_text())
    assert not called and d["missing_records"] == 3 and d["est_usd"] > 0


def test_run_accepts_good_and_marks_unreviewed(tmp_path):
    make_src(tmp_path)
    cl = MockClient(good_responder)
    assert T.run(args(tmp_path), client=cl) == 0
    res = json.loads((tmp_path / "out/content_translations.json").read_text())
    t = res["translations"]["C-AS-001"]
    assert t["translation_status"] == "auto_unreviewed" and t["pipeline_status"] == "machine_draft"
    assert "0.5 g/L" in t["en"] and "0,5 g/L" in t["ru"] and "GC-MS" in t["ru"]
    assert set(res["translations"]["C-AS-002"]) >= {"en"} and "ru" not in res["translations"]["C-AS-002"]
    op = [o for o in res["patch_ops"] if o["id"] == "C-AS-001"][0]
    assert op["path"] == "claims[C-AS-001].value.statement" and op["status_set"] == {"ru": "machine_draft", "en": "machine_draft"}
    assert op["status_path"] == "claims[C-AS-001].value.translation_status"
    assert res["rejected"] == {}
    # kontent fayli o'zgarmagan
    assert json.loads((tmp_path / "b.json").read_text()) == bundle()


def test_number_change_rejected_after_retry(tmp_path):
    make_src(tmp_path)

    def bad(kw):
        rows = json.loads(good_responder(kw))["items"]
        for r in rows:
            if r["id"] == "C-AS-001" and "en" in r:
                r["en"] = r["en"].replace("0.5", "5")      # raqam o'zgardi
            if r["id"] == "C-AS-002" and "en" in r:
                r["en"] = "THC 5 ng/L."                    # birlik o'zgardi
        return json.dumps({"items": rows})
    cl = MockClient(bad)
    T.run(args(tmp_path), client=cl)
    res = json.loads((tmp_path / "out/content_translations.json").read_text())
    assert "en" not in res["translations"].get("C-AS-001", {})
    assert "ru" in res["translations"]["C-AS-001"]                    # ru yaxshi, qabul qilindi
    assert any("numbers" in p for p in res["rejected"]["C-AS-001"]["en"]["problems"])
    assert "C-AS-002" in res["rejected"]
    # 2-urinish faqat rad etilganlar uchun va "fix" bilan
    assert len(cl.calls) == 2 and '"fix"' in user_of(cl.calls[1])
    assert "C-AS-001" in user_of(cl.calls[1]) and '"need":["en"]' in user_of(cl.calls[1])


def test_retry_fixes_problem(tmp_path):
    make_src(tmp_path)
    state = {"n": 0}

    def resp(kw):
        state["n"] += 1
        rows = json.loads(good_responder(kw))["items"]
        if state["n"] == 1:
            for r in rows:
                if r["id"] == "C-AS-001":
                    r["en"] = r["en"].replace("0.5", "5")
        return json.dumps({"items": rows})
    T.run(args(tmp_path), client=MockClient(resp))
    res = json.loads((tmp_path / "out/content_translations.json").read_text())
    assert res["rejected"] == {} and "0.5" in res["translations"]["C-AS-001"]["en"]


def test_script_checks():
    qa = C.load_translation_qa()
    assert any("kirill" in p for p in T.check_translation("Salom dunyo", "Привет", "en", qa))
    assert any("kirill" in p for p in T.check_translation("Salom dunyo", "Hello world", "ru", qa))
    assert T.check_translation("Etanol 0,5 g/L", "Этанол 0,5 г/л", "ru", qa) == []
    assert T.check_translation("Qarang [c1,c2]", "See", "en", qa)          # iqtibos yo'qoldi
    assert T.check_translation("GC-MS usuli", "GC-MS method", "en", qa) == []


def test_budget_stop_partial(tmp_path):
    f = tmp_path / "b.json"
    many = {"claims": [{"claim_id": f"C-AS-{i:03d}", "value": {"source_lang": "uz", "statement": {"uz": "Matn " * 400 + str(i)}}} for i in range(12)]}
    f.write_text(json.dumps(many, ensure_ascii=False), encoding="utf-8")
    cl = MockClient(lambda kw: json.dumps({"items": []}))
    T.run(args(tmp_path, max_usd=0.02), client=cl)
    res = json.loads((tmp_path / "out/content_translations.json").read_text())
    assert res["stats"]["budget_stop"] is True
    assert "Byudjet tugadi" in (tmp_path / "out/content_translations.md").read_text()


def test_real_repo_dry_run_runs():
    gaps, stats = T.load_gaps([Path(p) for p in T.DEFAULT_SOURCES], C.ROOT)
    assert isinstance(gaps, list)
    assert not stats.get("missing_sources")
