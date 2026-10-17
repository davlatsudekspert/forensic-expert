"""l10n_api umumiy qismi: API chaqiruvi (streaming, prompt caching, retry), byudjet, validatorlar.

DIQQAT: bu vositalar ARB va kontent fayllarini O'ZGARTIRMAYDI. Faqat taklif/patch fayllarini
(`out_l10n/`) yozadi; egasi ko'rib chiqib qo'llaydi.
Anthropic API kaliti faqat muhit o'zgaruvchisida (`ANTHROPIC_API_KEY`, GitHub secret); hech qachon
chop etilmaydi, faylga yozilmaydi.
"""
from __future__ import annotations

import json
import os
import re
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MODEL = "claude-sonnet-5-5"
# DIQQAT: narxlar taxminiy (tools/slides/generate.py bilan bir xil). Egasi rasmiy Anthropic narxlar
# sahifasida tekshirishi SHART.
PRICE_IN_PER_MTOK_USD = 3.00     # TEKSHIRILMAGAN taxmin
PRICE_OUT_PER_MTOK_USD = 15.00   # TEKSHIRILMAGAN taxmin
CACHE_WRITE_MULT = 1.25
CACHE_READ_MULT = 0.10
CHARS_PER_TOKEN = 3.0            # uz/ru uchun konservativ taxmin
LANGS = ("uz", "ru", "en")
RETRY_STATUS = {408, 409, 429, 500, 502, 503, 504, 529}


class BudgetExceeded(Exception):
    pass


# ----------------------------------------------------------------------------- narx / byudjet

def est_tokens(text: str) -> int:
    return int(len(text) / CHARS_PER_TOKEN) + 1


def est_cost(in_tok=0, out_tok=0, cache_write_tok=0, cache_read_tok=0) -> float:
    return (in_tok + cache_write_tok * CACHE_WRITE_MULT + cache_read_tok * CACHE_READ_MULT) / 1e6 * PRICE_IN_PER_MTOK_USD \
        + out_tok / 1e6 * PRICE_OUT_PER_MTOK_USD


class Budget:
    """Haqiqiy sarf (usage dan) + chaqiruvdan oldin taxminiy tekshiruv."""

    def __init__(self, max_usd: float):
        self.max_usd = float(max_usd)
        self.spent = 0.0
        self.calls = 0
        self.tokens = {"in": 0, "out": 0, "cache_write": 0, "cache_read": 0}

    def can_afford(self, estimate_usd: float) -> bool:
        return self.spent + estimate_usd <= self.max_usd

    def add_usage(self, usage) -> float:
        g = lambda k: int(getattr(usage, k, 0) or 0) if usage is not None else 0  # noqa: E731
        i, o, cw, cr = g("input_tokens"), g("output_tokens"), g("cache_creation_input_tokens"), g("cache_read_input_tokens")
        self.tokens["in"] += i
        self.tokens["out"] += o
        self.tokens["cache_write"] += cw
        self.tokens["cache_read"] += cr
        c = est_cost(i, o, cw, cr)
        self.spent += c
        self.calls += 1
        return c

    def summary(self) -> dict:
        return {"max_usd": self.max_usd, "spent_usd_estimate": round(self.spent, 4), "calls": self.calls,
                "tokens": self.tokens, "price_note": "narxlar taxminiy, tekshirilmagan"}


# ----------------------------------------------------------------------------- API

def make_client():
    """Mijozni kechiktirib yaratadi (dry-run va testlarda `anthropic` kerak emas)."""
    if not os.environ.get("ANTHROPIC_API_KEY"):
        raise SystemExit("ANTHROPIC_API_KEY o'rnatilmagan (GitHub secret orqali beriladi). --dry-run bilan sinab ko'ring.")
    import anthropic  # noqa: PLC0415
    return anthropic.Anthropic()


def _parse_json(text: str):
    t = text.strip()
    if t.startswith("```"):
        t = t.split("\n", 1)[1] if "\n" in t else t
        t = t.rsplit("```", 1)[0]
    try:
        return json.loads(t)
    except json.JSONDecodeError:
        a, b = t.find("{"), t.rfind("}")
        if a != -1 and b > a:
            return json.loads(t[a:b + 1])
        raise


def json_call(client, system: str, user: str, max_tokens: int, tag: str, budget: Budget,
              raw_dir=None, model: str = MODEL, est_out: int | None = None, sleep=time.sleep):
    """Bitta JSON chaqiruv: streaming, system keshlanadi, buzuq JSON bo'lsa 1 marta qayta uriniladi,
    vaqtinchalik API xatolarida (429/5xx/529) 3 marta eksponensial kutish. Byudjetdan oshsa BudgetExceeded."""
    est = est_cost(est_tokens(user), est_out if est_out is not None else max_tokens // 2) \
        + est_cost(0, 0, cache_read_tok=est_tokens(system))
    kw = dict(model=model, max_tokens=max_tokens,
              system=[{"type": "text", "text": system, "cache_control": {"type": "ephemeral"}}],
              messages=[{"role": "user", "content": [{"type": "text", "text": user}]}])
    last = None
    for attempt in (1, 2):
        if not budget.can_afford(est):
            raise BudgetExceeded(f"{tag}: taxminiy {est:.3f} USD, sarflangan {budget.spent:.3f} / {budget.max_usd:.2f} USD")
        resp = None
        for net in range(4):
            try:
                if hasattr(client.messages, "stream"):
                    with client.messages.stream(**kw) as s:
                        resp = s.get_final_message()
                else:
                    resp = client.messages.create(**kw)
                break
            except Exception as e:  # noqa: BLE001
                code = getattr(e, "status_code", None)
                if net < 3 and (code in RETRY_STATUS or "overloaded" in str(e).lower()):
                    sleep(2 ** (net + 1))
                    continue
                raise
        budget.add_usage(getattr(resp, "usage", None))
        text = "".join(b.text for b in resp.content if getattr(b, "type", "") == "text").strip()
        if raw_dir:
            Path(raw_dir).mkdir(parents=True, exist_ok=True)
            Path(raw_dir, f"raw_{tag}_{attempt}.txt").write_text(text, encoding="utf-8")
        print(f"[{tag}#{attempt}] stop={getattr(resp, 'stop_reason', '?')} "
              f"out_tok={getattr(getattr(resp, 'usage', None), 'output_tokens', '?')} spent={budget.spent:.3f} USD", flush=True)
        try:
            return _parse_json(text)
        except json.JSONDecodeError as e:
            last = e
    raise last


# ----------------------------------------------------------------------------- terminologiya konteksti

def load_terminology_context(root: Path = ROOT, max_chars: int = 9000) -> str:
    """canonical_terms.json + abbreviation_glossary.json + bundle term_translations dan ixcham lug'at matni."""
    lines = []
    try:
        ct = json.loads((root / "content/terminology/canonical_terms.json").read_text(encoding="utf-8"))
        lines.append("QISQARTMALAR (hamma tilda o'zgarmaydi; 1-eslatmada kengaytma bilan):")
        for t in ct.get("terms", []):
            ex = t.get("expansion", {})
            forb = "; ".join(f"{k}: {', '.join(v)}" for k, v in (t.get("forbidden") or {}).items() if v)
            lines.append(f"- {t['abbr']} = uz «{ex.get('uz','')}» | ru «{ex.get('ru','')}» | en «{ex.get('en','')}»"
                         + (f" | TAQIQLANGAN variantlar: {forb}" if forb else ""))
        for w in ct.get("words", []):
            lines.append(f"- {w['lang']} tilida «{', '.join(w['forbidden'])}» emas, «{w['use']}» ishlating")
    except (OSError, ValueError, KeyError):
        pass
    try:
        b = json.loads((root / "content/pilot/bundle.json").read_text(encoding="utf-8"))
        lines.append("ATAMALAR (term_translations; uz | ru | en):")
        for t in b.get("term_translations", []):
            loc = t.get("localized", {})
            lines.append(f"- {loc.get('uz','')} | {loc.get('ru','')} | {loc.get('en','')}")
    except (OSError, ValueError, KeyError):
        pass
    out = "\n".join(lines)
    return out[:max_chars]


# ----------------------------------------------------------------------------- ICU / placeholder validator

class IcuError(ValueError):
    pass


_CLDR = {"zero", "one", "two", "few", "many", "other"}


def _match_brace(s: str, i: int) -> int:
    """s[i] == '{' bo'lsa mos '}' indeksi."""
    depth = 0
    for j in range(i, len(s)):
        if s[j] == "{":
            depth += 1
        elif s[j] == "}":
            depth -= 1
            if depth == 0:
                return j
    raise IcuError("yopilmagan '{'")


def parse_icu(s: str, args=None, selectors=None):
    """ICU xabaridan argumentlar {nom: tur} va plural/select selektorlari {nom: set} ni chiqaradi.
    Muvozanatsiz qavslar IcuError."""
    args = {} if args is None else args
    selectors = {} if selectors is None else selectors
    i = 0
    while i < len(s):
        c = s[i]
        if c == "}":
            raise IcuError("ortiqcha '}'")
        if c == "{":
            j = _match_brace(s, i)
            inner = s[i + 1:j]
            parts = inner.split(",", 2)
            name = parts[0].strip()
            if not re.fullmatch(r"[A-Za-z_]\w*", name):
                raise IcuError(f"noto'g'ri argument nomi: {name!r}")
            kind = parts[1].strip() if len(parts) > 1 else "arg"
            prev = args.get(name, "arg")
            if prev != "arg" and kind != "arg" and prev != kind:
                raise IcuError(f"{name} turli turda ishlatilgan")
            if kind != "arg" or name not in args:
                args[name] = kind
            if kind in ("plural", "select", "selectordinal") and len(parts) == 3:
                body = parts[2]
                k = 0
                sels = selectors.setdefault(name, set())
                while k < len(body):
                    if body[k].isspace():
                        k += 1
                        continue
                    b0 = body.find("{", k)
                    if b0 == -1:
                        if body[k:].strip():
                            raise IcuError("selektordan keyin '{' yo'q")
                        break
                    sel = body[k:b0].strip()
                    if not sel:
                        raise IcuError("bo'sh selektor")
                    b1 = _match_brace(body, b0)
                    sels.add(sel)
                    parse_icu(body[b0 + 1:b1], args, selectors)
                    k = b1 + 1
            elif kind in ("plural", "select", "selectordinal"):
                raise IcuError("plural/select tanasi yo'q")
            i = j + 1
        else:
            i += 1
    return args, selectors


_PROTECT_RE = re.compile(r"<[^<>]+>|%\d?\$?[sdif@]|https?://[^\s)»”]+|[\w.+-]+@[\w-]+\.[\w.-]+|\\n")
_NUM_RE = re.compile(r"\d+(?:[.,]\d+)?")
_CYR = re.compile(r"[Ѐ-ӿ]")


def numbers_of(text: str) -> list[str]:
    return sorted(n.replace(",", ".") for n in _NUM_RE.findall(re.sub(r"\{[^{}]*\}", " ", text)))


def validate_arb_suggestion(key: str, lang: str, old: str, new: str, others: dict | None = None,
                            category: str = "", forbidden_hits=None) -> list[str]:
    """Taklif `new` ni `old` ga nisbatan tekshiradi. Bo'sh ro'yxat = qabul. Ro'yxat bo'sh bo'lmasa — RAD."""
    p: list[str] = []
    if not isinstance(new, str) or not new.strip():
        return ["bo'sh taklif"]
    if new == old:
        return ["taklif eskisi bilan bir xil"]
    if lang not in LANGS:
        return [f"noma'lum til {lang!r}"]
    try:
        oa, os_ = parse_icu(old)
    except IcuError:
        oa, os_ = {}, {}  # eski o'zi buzuq bo'lsa, faqat yangisi to'g'ri bo'lishi shart
    try:
        na, ns = parse_icu(new)
    except IcuError as e:
        return [f"ICU sintaksis xatosi: {e}"]
    if oa != na:
        p.append(f"placeholder/ICU argumentlari o'zgargan: {sorted(oa.items())} -> {sorted(na.items())}")
    for name, kind in na.items():
        if kind in ("plural", "select", "selectordinal"):
            sel_new, sel_old = ns.get(name, set()), os_.get(name, set())
            if "other" not in sel_new:
                p.append(f"{name}: 'other' tarmog'i yo'q")
            if kind == "select" and sel_old and sel_new != sel_old:
                p.append(f"{name}: select tarmoqlari o'zgargan")
            if kind != "select":
                lost = {s for s in sel_old if s.startswith("=")} - sel_new
                if lost:
                    p.append(f"{name}: aniq tarmoqlar yo'qolgan {sorted(lost)}")
                bad = {s for s in sel_new - sel_old if s not in _CLDR and not s.startswith("=")}
                if bad:
                    p.append(f"{name}: noma'lum tarmoq {sorted(bad)}")
    if sorted(_PROTECT_RE.findall(old)) != sorted(_PROTECT_RE.findall(new)):
        p.append("himoyalangan belgilar (teg, %s, URL, email, \\n) o'zgargan")
    if old.count("'") != new.count("'"):
        p.append("ASCII apostrof (') soni o'zgargan (ICU escape xavfi)")
    if old.count("\n") != new.count("\n"):
        p.append("qator uzilishlari soni o'zgargan")
    if lang == "uz":
        if _CYR.search(new):
            p.append("uz matnida kirill harflari qolgan")
        if re.search(r"[ʻʼ`´]|(?<=[A-Za-z])'", new):
            p.append("uz apostrofi noto'g'ri belgi (loyiha: o‘/g‘ U+2018, tutuq U+2019)")
    elif lang == "en" and _CYR.search(new):
        p.append("en matnida kirill harflari bor")
    on, nn = numbers_of(old), numbers_of(new)
    if on != nn:
        ok = False
        if category == "number_mismatch" and others:
            ok = any(numbers_of(t) == nn for t in others.values() if isinstance(t, str))
        if not ok:
            p.append(f"raqamlar o'zgargan: {on} -> {nn}")
    if len(new) > 3 * len(old) + 20 or len(new) * 3 + 20 < len(old):
        p.append("uzunlik haddan tashqari o'zgargan")
    if forbidden_hits:
        hits = forbidden_hits(new, lang)
        if hits:
            p.append("taqiqlangan terminologiya: " + ", ".join(f"«{a}» -> «{b}»" for a, b in hits))
    return p


def load_translation_qa(root: Path = ROOT):
    """content/tools/translation_qa.py ni import qiladi (None qaytaradi, agar yo'q bo'lsa)."""
    p = root / "content/tools"
    if not (p / "translation_qa.py").exists():
        return None
    sys.path.insert(0, str(p))
    try:
        import translation_qa  # noqa: PLC0415
        return translation_qa
    except Exception:  # noqa: BLE001
        return None
    finally:
        sys.path.remove(str(p))


def write_json(path, obj):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
