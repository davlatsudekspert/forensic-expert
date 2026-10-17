import sys
from pathlib import Path
from types import SimpleNamespace

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parent))
import pytest
import common as C
from mock_client import MockClient


def v(old, new, lang="uz", **kw):
    return C.validate_arb_suggestion("k", lang, old, new, **kw)


def test_icu_parse_plural_and_plain():
    a, s = C.parse_icu("{count, plural, =0{Yo‘q} other{{count} ta}} {x}")
    assert a == {"count": "plural", "x": "arg"} and s["count"] == {"=0", "other"}


@pytest.mark.parametrize("bad", ["{a", "a}", "{a, plural, other{x}", "{1x}", "{a, plural}"])
def test_icu_parse_errors(bad):
    with pytest.raises(C.IcuError):
        C.parse_icu(bad)


def test_valid_fix_accepted():
    assert v("Natija topilmadi {query}", "Natija topilmadi: {query}") == []


def test_placeholder_changes_rejected():
    assert any("placeholder" in p for p in v("Natija: {value}", "Natija: {qiymat}"))
    assert any("placeholder" in p for p in v("Natija: {value}", "Natija"))
    assert any("placeholder" in p for p in v("Natija", "Natija {value}"))


def test_icu_syntax_break_rejected():
    assert any("ICU" in p for p in v("Natija: {value}", "Natija: {value"))
    assert any("ICU" in p for p in v("{n, plural, other{{n} ta}}", "{n, plural, other{{n} ta}"))


def test_plural_rules():
    old = "{n, plural, =0{Yo‘q} other{{n} ta}}"
    assert any("aniq" in p for p in v(old, "{n, plural, other{{n} ta}}"))
    assert any("other" in p for p in v(old, "{n, plural, =0{Yo‘q} one{{n} ta}}"))
    ru_old = "{n, plural, one{{n} запись} other{{n} записей}}"
    assert v(ru_old, "{n, plural, one{{n} запись} few{{n} записи} other{{n} записей}}", lang="ru") == []


def test_numbers_and_units_changes_rejected():
    assert any("raqam" in p for p in v("Limit 0,5 mg/L", "Limit 5 mg/L"))
    # number_mismatch: boshqa tildagi matn bilan mos bo'lsa ruxsat
    others = {"en": "Limit 5 mg/L", "ru": "Лимит 5 мг/л"}
    assert v("Limit 0,5 mg/L", "Limit 5 mg/L", category="number_mismatch", others=others) == []
    assert v("Limit 0,5 mg/L", "Limit 7 mg/L", category="number_mismatch", others=others)


def test_uz_orthography_and_script():
    assert any("kirill" in p for p in v("Qidiruv natijasi", "Qidiruv натижаси"))
    assert any("apostrof" in p for p in v("Oʻqish", "O'qish"))
    assert any("kirill" in p for p in v("Search", "Поиск", lang="en"))
    assert v("O‘qish", "Ma’no o‘qish") == []


def test_protected_tokens_and_apostrophes():
    assert v("Qator1\nQator2", "Qator1 Qator2")
    assert any("himoyalangan" in p for p in v("<b>x</b> matn", "x matn"))
    assert any("ASCII" in p for p in v("Don't stop", "Do not stop", lang="en"))
    assert any("ASCII" in p for p in v("Dont stop", "Don't stop", lang="en"))


def test_identical_and_empty_and_length():
    assert v("abc", "abc") and v("abc", "") and v("abc", None)
    assert any("uzunlik" in p for p in v("Qisqa", "x" * 200))


def test_forbidden_terms_hook():
    hits = lambda t, l: [("GX-MS", "GC-MS")] if "GX-MS" in t else []  # noqa: E731
    assert any("taqiqlangan" in p for p in v("GC-MS usuli", "GX-MS usuli", forbidden_hits=hits))


def test_budget_and_cost():
    b = C.Budget(0.01)
    assert b.can_afford(0.005) and not b.can_afford(0.02)
    b.add_usage(SimpleNamespace(input_tokens=1_000_000, output_tokens=0, cache_creation_input_tokens=0, cache_read_input_tokens=0))
    assert round(b.spent, 2) == 3.00 and b.calls == 1
    assert C.est_cost(0, 1_000_000) == 15.0


def test_json_call_parses_fenced_and_retries_bad_json(tmp_path):
    texts = iter(["not json", '```json\n{"ok": 1}\n```'])
    cl = MockClient(lambda kw: next(texts))
    b = C.Budget(5)
    assert C.json_call(cl, "sys", "u", 100, "t", b, raw_dir=tmp_path) == {"ok": 1}
    assert len(cl.calls) == 2 and (tmp_path / "raw_t_1.txt").exists()
    assert cl.calls[0]["system"][0]["cache_control"] == {"type": "ephemeral"}
    assert cl.calls[0]["model"] == "claude-sonnet-5-5"


def test_json_call_budget_stop():
    cl = MockClient(lambda kw: "{}")
    b = C.Budget(0.0000001)
    with pytest.raises(C.BudgetExceeded):
        C.json_call(cl, "sys", "x" * 1000, 1000, "t", b)
    assert cl.calls == []


def test_json_call_retries_transient():
    n = {"i": 0}

    def resp(kw):
        n["i"] += 1
        if n["i"] < 3:
            e = RuntimeError("overloaded")
            e.status_code = 529
            raise e
        return "{}"
    assert C.json_call(MockClient(resp), "s", "u", 10, "t", C.Budget(5), sleep=lambda s: None) == {}
    assert n["i"] == 3


def test_terminology_context_real_repo():
    assert "GC-MS" in C.load_terminology_context()
