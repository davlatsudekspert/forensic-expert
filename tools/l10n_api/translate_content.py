#!/usr/bin/env python3
"""Kontentdagi ru/en tarjimasi YO'Q o'zbekcha (source_lang uz) yozuvlarni topadi va Claude API bilan
tarjima TAKLIFI chiqaradi (kontent fayllarini o'zgartirmaydi).

Qayerda qidiradi (standart; --source bilan almashtiriladi): content/pilot/bundle.json,
content/pilot/translations/localized_texts_d.json, content/guidelines/guidelines_v1.json,
content/court_prep/court_prep_v1.json. Har bir {uz: ..., ru?: ..., en?: ...} xaritasida uz bor-u,
ru yoki en yo'q/bo'sh bo'lsa — bo'shliq. Qoidalar:
  * asl til uz bo'lishi shart: eng yaqin `source_lang` uz, yoki (source_lang yo'q bo'lsa) xaritada faqat uz bor;
  * `locale_only` (ABY: faqat o'zbek) yozuvlar TARJIMA QILINMAYDI;
  * statuslar (`translation_status`), `keywords`, `references` o'tkazib yuboriladi.

Tarjima avtomatik tekshiriladi (content/tools/translation_qa.py check_pair: raqam, birlik, foiz, taqqoslash
belgilari, formula/qisqartma, DOI, terminologiya) + [iqtibos], {placeholder}, URL saqlanishi + yozuv (kirill/lotin).
Tekshiruvdan o'tmagani 1 marta qayta so'raladi, keyin `rejected` ga tushadi (to'qilmaydi).

Chiqish (--out-dir, standart out_l10n/):
  content_translations.json  {"translations": {id: {ru, en, translation_status:"auto_unreviewed", ...}},
                              "patch_ops": [...], "rejected": {...}, "stats": {...}}
  content_translations.md    qisqa hisobot
  content_spent.json         sarf (taxminiy)
`translation_status: auto_unreviewed` = «Avtomatik tarjima — tekshirilmagan»; pipeline statusi
(`pipeline_status: machine_draft`) bundle `value.translation_status` ga shu qiymat bilan yoziladi.

  python tools/l10n_api/translate_content.py --dry-run
  ANTHROPIC_API_KEY=... python tools/l10n_api/translate_content.py --max-usd 2
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import common as C  # noqa: E402

DEFAULT_SOURCES = [
    "content/pilot/bundle.json",
    "content/pilot/translations/localized_texts_d.json",
    "content/guidelines/guidelines_v1.json",
    "content/court_prep/court_prep_v1.json",
]
SKIP_KEYS = {"translation_status", "title_status", "status", "keywords", "references", "official_titles",
             "title_verification"}
ID_KEYS = ("claim_id", "topic_id", "method_id", "substance_id", "screening_id", "recipe_id", "source_id", "rule_id",
           "instrument_id", "authority_id", "jurisdiction_id", "term_id", "standard_id", "conflict_id",
           "research_id", "image_id", "target_id", "id", "key")
TARGETS = ("ru", "en")
CITE_RE = re.compile(r"\[[a-z0-9_]+(?:,\s*[a-z0-9_]+)*\]")
KEEP_RE = re.compile(r"\{[^{}]*\}|https?://\S+|\b[a-z_]+(?:\.[a-z0-9_]+){2,}\b")
CYR = re.compile(r"[Ѐ-ӿ]")

SYSTEM_PROMPT = """You translate Uzbek (Latin script) text of a forensic-science education app (forensic medicine, toxicology, chemistry, law) into Russian and English.

RULES
1. Translate faithfully and completely. Do NOT add, drop, soften or strengthen any statement. No commentary.
2. Keep EXACTLY as in the original: every number (also written-out number words stay words; do not convert words to digits or digits to words), unit, formula, percentage, comparison sign (< > ≤ ≥ ±), substance name, cut-off, dosage, date, DOI/PMID, URL, [citation,markers], {placeholders} and dotted ids. Only the decimal separator follows the target language (Russian: comma; English: point) and thousands separator (Russian: space; English: comma).
3. International abbreviations stay unchanged in every language (GC-MS, LC-MS/MS, PMI, THC, COHb, Rf ...). At first mention they may be followed by the expansion in the target language — only if the original does so.
4. Use standard professional terminology (Russian: судебно-медицинская / химико-токсикологическая лексика; English: international forensic terminology) and the GLOSSARY below. Never use the forbidden variants.
5. Uzbek proper names and institutions: use the official Russian/English form (e.g. O‘zbekiston -> Узбекистан / Uzbekistan); keep personal names transliterated consistently. Do not translate titles of laws/books that must stay original (keep them as written, add translation only if the original has one).
6. Preserve punctuation, line breaks (\\n) and list structure. Russian output must be in Cyrillic, English output must contain no Cyrillic.
7. Each item has "need": the languages to produce. Output ONLY JSON, no other text:
{"items":[{"id":str,"ru":str,"en":str}]}   (include only the languages listed in "need")

GLOSSARY
"""


def sha(t: str) -> str:
    return hashlib.sha256(t.encode("utf-8")).hexdigest()


# ----------------------------------------------------------------------------- bo'shliqlarni topish

def _seg_id(v, i):
    if isinstance(v, dict):
        for k in ID_KEYS:
            if isinstance(v.get(k), (str, int)):
                return str(v[k])
    return str(i)


def _is_lang_map(d: dict) -> bool:
    return (isinstance(d.get("uz"), str) and set(d) <= {"uz", "ru", "en"} and all(isinstance(x, str) for x in d.values()))


def find_gaps(obj, label: str, stats: dict | None = None) -> list[dict]:
    """obj ichidagi barcha tarjimasiz uz matnlar. Har biri: id, path, kind, uz, need, holder (xarita)."""
    out: list[dict] = []
    stats = stats if stats is not None else {}

    def walk(o, path, src, locale_only, claim_id, parent_key):
        if isinstance(o, dict):
            if isinstance(o.get("source_lang"), str):
                src = o["source_lang"]
            if o.get("locale_only"):
                locale_only = True
            if isinstance(o.get("claim_id"), str):
                claim_id = o["claim_id"]
            if parent_key not in SKIP_KEYS and _is_lang_map(o):
                uz = o["uz"].strip()
                need = [l for l in TARGETS if not (o.get(l) or "").strip()]
                if uz and need:
                    if locale_only:
                        stats["skipped_locale_only"] = stats.get("skipped_locale_only", 0) + 1
                    elif src is not None and src != "uz":
                        stats["skipped_source_not_uz"] = stats.get("skipped_source_not_uz", 0) + 1
                    elif src is None and any((o.get(l) or "").strip() for l in ("ru", "en")):
                        stats["skipped_source_unknown"] = stats.get("skipped_source_unknown", 0) + 1
                    else:
                        is_stmt = claim_id and path.endswith("value.statement")
                        out.append({"id": claim_id if is_stmt else f"{label}:{path}", "path": path, "label": label,
                                    "kind": "claim_statement" if is_stmt else (parent_key or "text"),
                                    "uz": o["uz"], "need": need, "holder": o, "claim": bool(is_stmt)})
                return
            for k, v in o.items():
                if k in SKIP_KEYS:
                    continue
                walk(v, f"{path}.{k}" if path else k, src, locale_only, claim_id, k)
        elif isinstance(o, list):
            for i, v in enumerate(o):
                walk(v, f"{path}[{_seg_id(v, i)}]", src, locale_only, claim_id, parent_key)

    walk(obj, "", None, False, None, None)
    return out


def load_gaps(sources: list[Path], root: Path) -> tuple[list[dict], dict]:
    gaps, stats = [], {}
    for p in sources:
        f = p if p.is_absolute() else root / p
        if not f.exists():
            stats.setdefault("missing_sources", []).append(str(p))
            continue
        data = json.loads(f.read_text(encoding="utf-8"))
        try:
            rel = str(f.relative_to(root))
        except ValueError:
            rel = str(f)
        for g in find_gaps(data, f.stem, stats):
            g["file"] = rel
            gaps.append(g)
    seen, uniq = set(), []
    for g in gaps:   # bir id ikki marta bo'lmasin
        if g["id"] in seen:
            continue
        seen.add(g["id"])
        uniq.append(g)
    return uniq, stats


# ----------------------------------------------------------------------------- tekshiruv

def check_translation(uz: str, tr, lang: str, qa) -> list[str]:
    if not isinstance(tr, str) or not tr.strip():
        return ["bo'sh tarjima"]
    p = []
    if qa is not None:
        p += qa.check_pair(uz, tr, "uz", lang)
    else:   # zaxira: faqat raqamlar
        if C.numbers_of(uz) != C.numbers_of(tr):
            p.append(f"raqamlar o'zgargan: {C.numbers_of(uz)} -> {C.numbers_of(tr)}")
    if sorted(CITE_RE.findall(uz)) != sorted(CITE_RE.findall(tr)):
        p.append("[iqtibos] belgilari o'zgargan")
    if sorted(KEEP_RE.findall(uz)) != sorted(KEEP_RE.findall(tr)):
        p.append("{placeholder}/URL/id o'zgargan")
    if uz.count("\n") != tr.count("\n"):
        p.append("qator uzilishlari soni o'zgargan")
    letters = re.search(r"[A-Za-zЀ-ӿ]{3}", tr)
    if lang == "ru" and letters and not CYR.search(tr):
        p.append("ru tarjimada kirill harflari yo'q")
    if lang == "en" and CYR.search(tr):
        p.append("en tarjimada kirill harflari bor")
    if len(tr) > 3 * len(uz) + 30 or len(tr) * 3 + 30 < len(uz):
        p.append("uzunlik haddan tashqari farq qiladi")
    return p


# ----------------------------------------------------------------------------- API

def make_batches(gaps: list[dict], max_items=20, max_chars=9000) -> list[list[dict]]:
    out, cur, n = [], [], 0
    for g in gaps:
        if cur and (len(cur) >= max_items or n + len(g["uz"]) > max_chars):
            out.append(cur)
            cur, n = [], 0
        cur.append(g)
        n += len(g["uz"])
    if cur:
        out.append(cur)
    return out


def user_text(batch, feedback: dict | None = None) -> str:
    rows = []
    for g in batch:
        r = {"id": g["id"], "uz": g["uz"], "need": g["need"], "context": g["kind"]}
        if feedback and g["id"] in feedback:
            r["fix"] = feedback[g["id"]]
        rows.append(json.dumps(r, ensure_ascii=False, separators=(",", ":")))
    head = "Translate these items (one JSON object per line)."
    if feedback:
        head = "Re-translate ONLY these items; the previous attempt failed the automatic checks listed in \"fix\"."
    return head + "\n" + "\n".join(rows)


def est_out(batch) -> int:
    return int(sum(C.est_tokens(g["uz"]) * 1.4 * len(g["need"]) for g in batch)) + 100


def estimate(batches, system) -> dict:
    sys_tok = C.est_tokens(system)
    cost = 0.0
    in_t = out_t = 0
    for i, b in enumerate(batches):
        u, o = C.est_tokens(user_text(b)), est_out(b)
        in_t += u
        out_t += o
        cost += C.est_cost(u, o, **(dict(cache_write_tok=sys_tok) if i == 0 else dict(cache_read_tok=sys_tok)))
    return {"batches": len(batches), "input_tokens": in_t, "output_tokens": out_t, "est_usd": round(cost, 3),
            "price_note": f"taxminiy ({C.PRICE_IN_PER_MTOK_USD}/{C.PRICE_OUT_PER_MTOK_USD} USD/MTok), tekshirilmagan; model {C.MODEL}"}


def translate_batch(client, system, batch, budget, tag, out_dir, qa):
    """(accepted {id: {lang: text}}, rejected {id: {lang: {text, problems}}})."""
    by_id = {g["id"]: g for g in batch}
    accepted: dict = {}
    rejected: dict = {}
    todo, feedback = list(batch), None
    for attempt in (1, 2):
        resp = C.json_call(client, system, user_text(todo, feedback), 16000, f"{tag}_{attempt}", budget,
                           raw_dir=Path(out_dir) / "raw", est_out=est_out(todo))
        got = {str(x.get("id")): x for x in (resp.get("items") if isinstance(resp, dict) else None) or [] if isinstance(x, dict)}
        feedback, nxt = {}, []
        for g in todo:
            row = got.get(g["id"], {})
            bad = {}
            for lang in g["need"]:
                probs = check_translation(g["uz"], row.get(lang), lang, qa)
                if probs:
                    bad[lang] = {"text": row.get(lang), "problems": probs}
                else:
                    accepted.setdefault(g["id"], {})[lang] = row[lang].strip()
            if bad:
                feedback[g["id"]] = "; ".join(f"{l}: {', '.join(v['problems'])}" for l, v in bad.items())
                rejected[g["id"]] = bad
                nxt.append({**g, "need": list(bad)})
            else:
                rejected.pop(g["id"], None)
        if not nxt:
            break
        todo = nxt
    for gid in list(rejected):   # 2-urinishda tuzalganlar rejected'da qolmasin
        for lang in list(rejected[gid]):
            if lang in accepted.get(gid, {}):
                del rejected[gid][lang]
        if not rejected[gid]:
            del rejected[gid]
    return accepted, rejected


def build_outputs(gaps, accepted, rejected, stats, budget_meta):
    by_id = {g["id"]: g for g in gaps}
    translations, ops = {}, []
    for gid, langs in accepted.items():
        g = by_id[gid]
        # ikkala kerakli til ham bo'lsa — to'liq; bittasi bo'lsa — qisman (qolgani rejected'da)
        translations[gid] = {**{l: langs[l] for l in g["need"] if l in langs},
                             "translation_status": "auto_unreviewed", "pipeline_status": "machine_draft",
                             "source_lang": "uz", "source_sha256": sha(g["uz"]), "source_text": g["uz"],
                             "kind": g["kind"], "file": g["file"], "path": g["path"],
                             "complete": all(l in langs for l in g["need"])}
        op = {"id": gid, "file": g["file"], "path": g["path"], "set": {l: langs[l] for l in g["need"] if l in langs}}
        if g["claim"]:
            op["status_path"] = g["path"].rsplit(".", 1)[0] + ".translation_status"
            op["status_set"] = {l: "machine_draft" for l in op["set"]}
        ops.append(op)
    return {"format": "fe-content-translations/1", "model": C.MODEL,
            "note": "TAKLIF. Kontent o'zgartirilmagan. Hammasi «Avtomatik tarjima — tekshirilmagan» (auto_unreviewed); "
                    "ilmiy reviewer tasdig'idan oldin tasdiqlangan deb ko'rsatilmaydi. patch_ops ni ko'rib chiqib qo'llang, "
                    "so'ng content/tools/translation_qa.py ni ishga tushiring.",
            "translations": translations, "patch_ops": ops,
            "rejected": rejected, "stats": {**stats, "budget": budget_meta}}


def render_md(res, total_gaps) -> str:
    st = res["stats"]
    L = ["# Kontent tarjima hisoboti (taklif — qo'llanmagan)", "",
         f"- Tarjimasiz o'zbekcha yozuvlar: **{total_gaps}**",
         f"- Qabul qilingan tarjimalar: **{len(res['translations'])}**, rad etilgan: **{len(res['rejected'])}**",
         f"- Sarf (taxminiy): **{st['budget']['spent_usd_estimate']} USD** / limit {st['budget']['max_usd']} USD"]
    if st.get("budget_stop"):
        L.append("- **Byudjet tugadi: to'liq emas** (`--resume`).")
    for k in ("skipped_locale_only", "skipped_source_not_uz", "skipped_source_unknown"):
        if st.get(k):
            L.append(f"- O'tkazib yuborilgan ({k}): {st[k]}")
    L += ["", "Holat: barchasi `auto_unreviewed` — «Avtomatik tarjima — tekshirilmagan».", ""]
    if res["rejected"]:
        L += ["## Rad etilganlar (avtomatik tekshiruvdan o'tmadi)", ""]
        for gid, langs in list(res["rejected"].items())[:40]:
            for l, v in langs.items():
                L.append(f"- `{gid}` [{l}]: {'; '.join(v['problems'])}")
    return "\n".join(L) + "\n"


def run(args, client=None) -> int:
    root, out = C.ROOT, Path(args.out_dir)
    sources = [Path(s) for s in (args.source or DEFAULT_SOURCES)]
    gaps, stats = load_gaps(sources, root)
    if args.only_ids:
        want = set(args.only_ids.split(","))
        gaps = [g for g in gaps if g["id"] in want]
    if args.max_items:
        gaps = gaps[:args.max_items]
    system = SYSTEM_PROMPT + C.load_terminology_context(root)
    batches = make_batches(gaps)
    by_kind: dict = {}
    for g in gaps:
        by_kind[g["kind"]] = by_kind.get(g["kind"], 0) + 1
    if args.dry_run:
        est = {"missing_records": len(gaps), "by_kind": by_kind, "stats": stats, **estimate(batches, system),
               "sample_ids": [g["id"] for g in gaps[:10]]}
        C.write_json(out / "content_dryrun.json", est)
        print("DRY-RUN (API chaqirilmadi)")
        print(json.dumps(est, ensure_ascii=False, indent=1))
        return 0
    if not gaps:
        print("Tarjimasiz o'zbekcha yozuv topilmadi.")
        budget = C.Budget(args.max_usd)
        res = build_outputs(gaps, {}, {}, stats, budget.summary())
        C.write_json(out / "content_translations.json", res)
        (out / "content_translations.md").write_text(render_md(res, 0), encoding="utf-8")
        C.write_json(out / "content_spent.json", budget.summary())
        return 0
    client = client or C.make_client()
    qa = C.load_translation_qa(root)
    budget = C.Budget(args.max_usd)
    prog_path = out / "content_progress.json"
    prog = {"done": [], "accepted": {}, "rejected": {}}
    if args.resume and prog_path.exists():
        prog = json.loads(prog_path.read_text(encoding="utf-8"))
    stop, failed = False, 0
    for i, b in enumerate(batches, 1):
        sig = hashlib.sha1("|".join(g["id"] + sha(g["uz"])[:8] for g in b).encode()).hexdigest()[:12]
        if sig in prog["done"]:
            continue
        try:
            acc, rej = translate_batch(client, system, b, budget, f"content{i}", out, qa)
        except C.BudgetExceeded as e:
            print(f"BYUDJET TUGADI: {e}")
            stop = True
            break
        except Exception as e:  # noqa: BLE001
            print(f"BATCH {i} XATO: {type(e).__name__}: {str(e)[:200]}")
            failed += 1
            continue
        for gid, v in acc.items():
            prog["accepted"].setdefault(gid, {}).update(v)
        prog["rejected"].update(rej)
        prog["done"].append(sig)
        C.write_json(prog_path, prog)
    stats = {**stats, "budget_stop": stop, "failed_batches": failed}
    res = build_outputs(gaps, prog["accepted"], prog["rejected"], stats, budget.summary())
    C.write_json(out / "content_translations.json", res)
    (out / "content_translations.md").write_text(render_md(res, len(gaps)), encoding="utf-8")
    C.write_json(out / "content_spent.json", budget.summary())
    print(f"Tayyor: {len(res['translations'])} tarjima, {len(res['rejected'])} rad, sarf ~{budget.spent:.3f} USD -> {out}")
    return 1 if (failed and not prog["done"]) else 0


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--source", action="append", help="JSON manba (takrorlash mumkin); standart: 4 ta kontent fayli")
    ap.add_argument("--out-dir", default="out_l10n")
    ap.add_argument("--max-usd", type=float, default=2.0)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--resume", action="store_true")
    ap.add_argument("--only-ids", help="vergul bilan id ro'yxati (sinov)")
    ap.add_argument("--max-items", type=int, default=0)
    args = ap.parse_args(argv)
    return run(args)


if __name__ == "__main__":
    sys.exit(main())
