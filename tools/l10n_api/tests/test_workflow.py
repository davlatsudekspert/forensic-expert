from pathlib import Path

import pytest

yaml = pytest.importorskip("yaml")
WF = Path(__file__).resolve().parents[3] / ".github/workflows/l10n-api.yml"


def load():
    d = yaml.safe_load(WF.read_text(encoding="utf-8"))
    d["on"] = d.get("on", d.get(True))   # PyYAML 'on' ni True ga aylantiradi
    return d


def test_dispatch_inputs():
    on = load()["on"]["workflow_dispatch"]["inputs"]
    assert on["task"]["options"] == ["arb", "content", "both"]
    assert {"task", "max_usd", "dry_run"} <= set(on)
    assert on["dry_run"]["default"] is True


def test_concurrency_and_permissions():
    d = load()
    assert "run_id" in d["concurrency"]["group"] and d["permissions"] == {"contents": "write"}


def test_secret_never_printed_and_no_push_on_dry_run():
    txt = WF.read_text(encoding="utf-8")
    assert "echo $ANTHROPIC" not in txt and "echo \"$ANTHROPIC" not in txt
    steps = load()["jobs"]["l10n"]["steps"]
    save = [s for s in steps if "slides-out" in s.get("name", "")][0]
    assert "dry_run != true" in save["if"]
    assert any("pytest tools/l10n_api/tests" in s.get("run", "") for s in steps)


def test_tools_have_budget_and_dry_run_flags():
    txt = WF.read_text(encoding="utf-8")
    assert "--max-usd" in txt and "--dry-run" in txt
