#!/usr/bin/env python3
"""ARB (uz/ru/en) ni Claude API bilan tekshiradi va TAKLIF fayli chiqaradi (ARB'ni o'zgartirmaydi).

Har kalit uchun uch tildagi matn solishtiriladi: imlo/grammatika, noto'g'ri tarjima, tillar orasidagi
ma'no farqi, aralash til, placeholder mosligi, raqam/birlik, o'zbek lotin imlosi (o‘/g‘ = U+2018,
tutuq = U+2019), terminologiya izchilligi (content/terminology/ + bundle term_translations).

Chiqish (--out-dir, standart out_l10n/):
  arb_review.json           [{key, lang, old, new, reason, severity, category}]  (validatordan o'tganlar)
  arb_review_rejected.json  validator rad etgan takliflar + sabab
  arb_review.md             qisqa hisobot
  arb_patch_{uz,ru,en}.json {key: new} — qo'llash uchun qulay patch
  arb_spent.json            sarf (taxminiy)

Ishga tushirish (repo ildizidan):
  python tools/l10n_api/proofread_arb.py --dry-run                  # API chaqirilmaydi, narx taxmini
  ANTHROPIC_API_KEY=... python tools/l10n_api/proofread_arb.py --max-usd 3
"""
from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import common as C  # noqa: E402

DEFAULT_ARB_DIR = C.ROOT / "apps/mobile/lib/core/l10n/arb"
SEVERITIES = {"high": 0, "medium": 1, "low": 2}
SEV_ALIAS = {"critical": "high", "error": "high", "major": "high", "warning": "medium", "minor": "low", "info": "low"}
CATEGORIES = ("spelling", "grammar", "mistranslation", "meaning_mismatch", "mixed_language", "placeholder",
              "number_mismatch", "uz_orthography", "terminology", "other")

SYSTEM_PROMPT = """You are a meticulous trilingual (Uzbek Latin / Russian / English) proofreader for the UI strings of a forensic-science mobile app (forensic medicine, toxicology, chemistry, law). You receive a list of UI keys; each has the same text in three languages: "uz", "ru", "en" (plus an optional "note" = developer description, and "ph" = placeholder names).

For EVERY key compare the three texts and report only REAL problems:
1. spelling / grammar errors in any language (category spelling | grammar);
2. wrong translation or a meaning difference between languages (mistranslation | meaning_mismatch). The English text is the reference unless it is clearly the faulty one;
3. mixed language: Cyrillic or Russian words inside the Uzbek Latin text; Latin words inside Russian text that should be Russian (international abbreviations such as GC-MS, PMI, THC, COHb, Rf are fine and must stay unchanged); untranslated English words (mixed_language);
4. placeholders {name} and ICU plural/select must be IDENTICAL in all three languages (names, structure). Never rename, add or drop a placeholder (placeholder);
5. numbers, units, formulas, percentages, substance names, cut-offs must be identical across languages (number_mismatch);
6. Uzbek Latin orthography of this project: o‘ and g‘ use U+2018 (‘); the tutuq belgisi / apostrophe in words like ma’no, a’zo, sur’at uses U+2019 (’). ASCII ' or ʻ ʼ ` are wrong (uz_orthography). Literary Uzbek, not Cyrillic transliteration;
7. terminology consistency with the glossary below (terminology). Forbidden variants such as GX-MS, SX-MS, ГХ-МС, ВЭЖХ must be replaced by the canonical abbreviation.

STRICT RULES
- Do NOT restyle, do not "improve" correct text, do not change tone, do not suggest alternatives of equal quality. If unsure, do not report.
- The brand name and strings that are intentionally identical in all languages are fine.
- Propose the corrected full string in "new" for exactly ONE language per finding (the one that is faulty). If two languages are faulty, make two findings.
- "new" must keep every {placeholder}, ICU structure, "\\n", HTML-like tags and ASCII-apostrophe count of the original exactly; change only what is wrong. Do not add or remove digits unless category is number_mismatch.
- "reason": one short sentence in Uzbek (Latin), concrete (what exactly is wrong).
- "severity": "high" (wrong meaning, broken placeholder, mixed language, wrong number/unit), "medium" (clear grammar/spelling/terminology error), "low" (minor orthography).
- Output ONLY JSON, no other text:
{"findings":[{"key":str,"lang":"uz"|"ru"|"en","new":str,"reason":str,"severity":"high"|"medium"|"low","category":str}]}
If a batch has no problems: {"findings":[]}.

GLOSSARY / TERMINOLOGY
"""


def load_arbs(arb_dir: Path) -> dict:
    return {l: json.loads((arb_dir / f"app_{l}.arb").read_text(encoding="utf-8")) for l in C.LANGS}


def build_items(arbs: dict, only: str | None = None) -> list[dict]:
    """Tekshiriladigan kalitlar (en tartibida). Uch tilda bir xil matnlar (brend, qisqartma) o'tkazib yuboriladi."""
    import re
    rx = re.compile(only) if only else None
    items = []
    for k, en in arbs["en"].items():
        if k.startswith("@") or not isinstance(en, str):
            continue
        if rx and not rx.search(k):
            continue
        uz, ru = arbs["uz"].get(k), arbs["ru"].get(k)
        if not isinstance(uz, str) or not isinstance(ru, str):
            continue
        if uz == ru == en:
            continue
        meta = arbs["en"].get("@" + k) or {}
        it = {"key": k, "uz": uz, "ru": ru, "en": en}
        if meta.get("description"):
            it["note"] = meta["description"]
        if meta.get("placeholders"):
            it["ph"] = sorted(meta["placeholders"])
        items.append(it)
    return items


def make_batches(items: list[dict], size: int) -> list[list[dict]]:
    return [items[i:i + size] for i in range(0, len(items), size)]


def batch_sig(batch: list[dict]) -> str:
    h = hashlib.sha1(json.dumps(batch, ensure_ascii=False, sort_keys=True).encode("utf-8")).hexdigest()[:10]
    return f"{batch[0]['key']}..{batch[-1]['key']}:{len(batch)}:{h}"


def batch_user_text(batch: list[dict]) -> str:
    rows = "\n".join(json.dumps(b, ensure_ascii=False, separators=(",", ":")) for b in batch)
    return f"Check these {len(batch)} UI keys (one JSON object per line):\n{rows}"


def est_out_tokens(n_keys: int) -> int:
    return 400 + 14 * n_keys   # ~10% kalit belgilanadi, har biri ~140 token


def dry_run_estimate(items, batches, system: str) -> dict:
    sys_tok = C.est_tokens(system)
    in_total = out_total = 0
    cost = 0.0
    cost_hi = 0.0
    for i, b in enumerate(batches):
        u = C.est_tokens(batch_user_text(b))
        o = est_out_tokens(len(b))
        in_total += u
        out_total += o
        kw = dict(cache_write_tok=sys_tok) if i == 0 else dict(cache_read_tok=sys_tok)
        cost += C.est_cost(u, o, **kw)
        cost_hi += C.est_cost(u, 25 * len(b) + 400, **kw)
    return {"keys": len(items), "batches": len(batches), "system_tokens": sys_tok, "input_tokens": in_total,
            "output_tokens": out_total, "est_usd": round(cost, 3), "est_usd_upper": round(cost_hi, 3),
            "price_note": f"taxminiy ({C.PRICE_IN_PER_MTOK_USD}/{C.PRICE_OUT_PER_MTOK_USD} USD/MTok), tekshirilmagan; model {C.MODEL}"}


def process_findings(batch, resp, arbs, qa) -> tuple[list[dict], list[dict]]:
    """Model javobini validatsiyadan o'tkazadi: (qabul, rad)."""
    by_key = {b["key"]: b for b in batch}
    ok, bad = [], []
    seen = set()
    hits = getattr(qa, "forbidden_hits", None) if qa else None
    for f in (resp.get("findings") if isinstance(resp, dict) else None) or []:
        if not isinstance(f, dict):
            continue
        key, lang = f.get("key"), f.get("lang")
        rec = {"key": key, "lang": lang, "new": f.get("new"), "reason": f.get("reason", ""),
               "severity": SEV_ALIAS.get(str(f.get("severity", "")).lower(), str(f.get("severity", "")).lower()),
               "category": f.get("category", "other")}
        if key not in by_key:
            bad.append({**rec, "rejected": ["kalit bu batchda yo'q"]})
            continue
        if lang not in C.LANGS:
            bad.append({**rec, "rejected": [f"noma'lum til {lang!r}"]})
            continue
        old = by_key[key][lang]
        rec["old"] = old
        if rec["severity"] not in SEVERITIES:
            rec["severity"] = "medium"
        if rec["category"] not in CATEGORIES:
            rec["category"] = "other"
        if (key, lang) in seen:
            bad.append({**rec, "rejected": ["bir kalit/til uchun takroriy taklif"]})
            continue
        problems = C.validate_arb_suggestion(key, lang, old, f.get("new"), others=by_key[key],
                                             category=rec["category"], forbidden_hits=hits)
        if problems:
            bad.append({**rec, "rejected": problems})
            continue
        seen.add((key, lang))
        ok.append({k: rec[k] for k in ("key", "lang", "old", "new", "reason", "severity", "category")})
    return ok, bad


def render_md(findings, rejected, meta) -> str:
    lines = ["# ARB tekshiruv hisoboti (taklif — qo'llanmagan)", "",
             f"- Kalitlar: {meta['keys']}, batchlar: {meta['batches_done']}/{meta['batches_total']}, "
             f"model: `{C.MODEL}`",
             f"- Qabul qilingan takliflar: **{len(findings)}**, validator rad etgan: **{len(rejected)}**",
             f"- Sarf (taxminiy, tekshirilmagan narx): **{meta['budget']['spent_usd_estimate']} USD** / limit {meta['budget']['max_usd']} USD",
             ]
    if meta.get("budget_stop"):
        lines.append("- **Byudjet tugadi: tekshiruv to'liq emas** (`--resume` bilan davom ettirish mumkin).")
    if meta.get("failed_batches"):
        lines.append(f"- Muvaffaqiyatsiz batchlar: {len(meta['failed_batches'])} ({', '.join(meta['failed_batches'][:5])})")
    lines += ["", "Hech narsa ARB ga yozilmagan. `arb_patch_<til>.json` ni ko'rib chiqib qo'lda qo'llang, so'ng `flutter gen-l10n`.", ""]
    lines += ["## Til x jiddiylik", "", "| til | high | medium | low |", "|---|---:|---:|---:|"]
    for l in C.LANGS:
        c = [sum(1 for f in findings if f["lang"] == l and f["severity"] == s) for s in ("high", "medium", "low")]
        lines.append(f"| {l} | {c[0]} | {c[1]} | {c[2]} |")
    lines += ["", "## Kategoriya bo'yicha", ""]
    cats = {}
    for f in findings:
        cats[f["category"]] = cats.get(f["category"], 0) + 1
    lines += [f"- {k}: {v}" for k, v in sorted(cats.items(), key=lambda x: -x[1])] or ["- (yo'q)"]
    lines += ["", "## Eng jiddiy takliflar (high, 40 tagacha)", ""]
    for f in [f for f in findings if f["severity"] == "high"][:40]:
        lines += [f"- `{f['key']}` [{f['lang']}] ({f['category']}): {f['reason']}",
                  f"  - eski: {f['old']}", f"  - yangi: {f['new']}"]
    if rejected:
        rc = {}
        for r in rejected:
            for p in r.get("rejected", []):
                k = p.split(":")[0][:60]
                rc[k] = rc.get(k, 0) + 1
        lines += ["", "## Validator rad etish sabablari", ""] + [f"- {k}: {v}" for k, v in sorted(rc.items(), key=lambda x: -x[1])[:15]]
    return "\n".join(lines) + "\n"


def write_outputs(out: Path, findings, rejected, meta):
    findings = sorted(findings, key=lambda f: (SEVERITIES[f["severity"]], f["key"], f["lang"]))
    C.write_json(out / "arb_review.json", findings)
    C.write_json(out / "arb_review_rejected.json", rejected)
    for l in C.LANGS:
        C.write_json(out / f"arb_patch_{l}.json", {f["key"]: f["new"] for f in findings if f["lang"] == l})
    (out / "arb_review.md").write_text(render_md(findings, rejected, meta), encoding="utf-8")
    C.write_json(out / "arb_spent.json", meta["budget"])


def run(args, client=None) -> int:
    arb_dir, out = Path(args.arb_dir), Path(args.out_dir)
    arbs = load_arbs(arb_dir)
    items = build_items(arbs, args.only)
    if args.max_keys:
        items = items[:args.max_keys]
    batches = make_batches(items, args.batch_size)
    if args.batch_limit:
        batches = batches[:args.batch_limit]
    system = SYSTEM_PROMPT + C.load_terminology_context()
    if args.dry_run:
        est = dry_run_estimate(items, batches, system)
        C.write_json(out / "arb_dryrun.json", est)
        print("DRY-RUN (API chaqirilmadi)")
        print(json.dumps(est, ensure_ascii=False, indent=1))
        if est["est_usd_upper"] > args.max_usd:
            print(f"OGOHLANTIRISH: yuqori chegara {est['est_usd_upper']} USD > --max-usd {args.max_usd}")
        return 0
    client = client or C.make_client()
    qa = C.load_translation_qa()
    budget = C.Budget(args.max_usd)
    prog_path = out / "arb_progress.json"
    prog = {"done": [], "findings": [], "rejected": []}
    if args.resume and prog_path.exists():
        prog = json.loads(prog_path.read_text(encoding="utf-8"))
    failed, stop = [], False
    for i, b in enumerate(batches, 1):
        sig = batch_sig(b)
        if sig in prog["done"]:
            continue
        try:
            resp = C.json_call(client, system, batch_user_text(b), 12000, f"arb{i}", budget,
                               raw_dir=out / "raw", est_out=est_out_tokens(len(b)))
        except C.BudgetExceeded as e:
            print(f"BYUDJET TUGADI: {e}")
            stop = True
            break
        except Exception as e:  # noqa: BLE001
            print(f"BATCH {i} XATO: {type(e).__name__}: {str(e)[:200]}")
            failed.append(sig)
            continue
        ok, bad = process_findings(b, resp, arbs, qa)
        prog["findings"] += ok
        prog["rejected"] += bad
        prog["done"].append(sig)
        C.write_json(prog_path, prog)   # har batchdan keyin saqlanadi
    meta = {"keys": len(items), "batches_total": len(batches), "batches_done": len(prog["done"]),
            "budget": budget.summary(), "budget_stop": stop, "failed_batches": failed}
    write_outputs(out, prog["findings"], prog["rejected"], meta)
    print(f"Tayyor: {len(prog['findings'])} taklif, {len(prog['rejected'])} rad, sarf ~{budget.spent:.3f} USD -> {out}")
    return 1 if (failed and not prog["done"]) else 0


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--arb-dir", default=str(DEFAULT_ARB_DIR))
    ap.add_argument("--out-dir", default="out_l10n")
    ap.add_argument("--batch-size", type=int, default=70, help="kalit/batch (60-80 tavsiya)")
    ap.add_argument("--max-usd", type=float, default=3.0)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--resume", action="store_true", help="out-dir/arb_progress.json dan davom etish")
    ap.add_argument("--only", help="kalit nomiga regex filtri (sinov uchun)")
    ap.add_argument("--max-keys", type=int, default=0)
    ap.add_argument("--batch-limit", type=int, default=0, help="faqat dastlabki N batch (0 = hammasi)")
    args = ap.parse_args(argv)
    if not 5 <= args.batch_size <= 150:
        ap.error("--batch-size 5..150 oralig'ida bo'lsin")
    return run(args)


if __name__ == "__main__":
    sys.exit(main())
