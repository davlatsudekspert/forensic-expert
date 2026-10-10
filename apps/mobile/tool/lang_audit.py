#!/usr/bin/env python3
"""Uch tilli matn auditi va aralash-til detektori (READ-ONLY).

Ilova foydalanuvchiga ko‘rsatadigan barcha matn manbalarini (ARB, kontent
paketi `content.db`, yo‘riqnoma kartalari, «Sudda so‘roq» paketi, Dart
ichidagi qattiq yozilgan matnlar) yig‘adi, har bir maydonni A–G toifasiga
ajratadi va har bir til (uz/ru/en) uchun:

* qamrov: present / missing / machine_draft / draft / authored / reviewed;
* til mosligi: uz/en ichida kirillcha, uz/ru ichida inglizcha so‘zlar
  (allowlist’dan tashqari), ru/en ichida o‘zbekcha so‘zlar, tarjima qilinmay
  qolgan (inglizcha bilan bir xil) qiymatlar.

Toifalar (egasining 2026-10-09 qarori):
  A  UI (ARB)                         — tekshiriladi
  B  ilmiy tushuntirish / nom / izoh  — tekshiriladi
  C  ilmiy savol-javob (test, sud)    — tekshiriladi
  D  asl iqtibos (verbatim)           — asl matn TEKSHIRILMAYDI; tarjimasi
                                         (uz/ru) maqsadli til sifatida tekshiriladi
  E  bibliografiya (sarlavha, muallif) — tekshirilmaydi (faqat qamrov:
                                         tarjima qilingan «sarlavha mazmuni» bormi)
  F  rasmiy hujjat nomi / matni       — asl matn tekshirilmaydi; rasmiy
                                         tildagi nom bor-yo‘qligi qayd etiladi
  G  formula / birlik / identifikator — tekshirilmaydi

Ishlatish (apps/mobile ichida):
  python3 tool/lang_audit.py                       # hisobot: build/lang_audit/
  python3 tool/lang_audit.py --out ../../docs/qa/l10n_audit_20261009
  python3 tool/lang_audit.py --fail-on error       # CI: ERROR topilsa exit 1
  python3 tool/lang_audit.py --self-test           # detektor birlik sinovlari

Natija: lang_audit.json (mashina o‘qiydigan) va lang_audit.md (jadval).
Deterministik: tasodif yo‘q, tartib — manba/ID bo‘yicha saralangan.
Hech qanday fayl o‘zgartirilmaydi (faqat --out katalogiga yoziladi).
"""
from __future__ import annotations

import argparse
import collections
import hashlib
import json
import os
import re
import sqlite3
import sys
from dataclasses import dataclass, field
from pathlib import Path

LANGS = ("uz", "ru", "en")
CHECKED_CATEGORIES = {"A", "B", "C"}

# --------------------------------------------------------------------------
# 28 bo‘lim (egasining ro‘yxati)
# --------------------------------------------------------------------------
SECTIONS = collections.OrderedDict(
    [
        ("01_home", "Bosh sahifa"),
        ("02_disciplines", "Fanlar"),
        ("03_library", "Kutubxona (moddalar)"),
        ("04_research", "Ilmiy maqolalar"),
        ("05_guidelines", "Yo‘riqnomalar (ilmiy kartalar)"),
        ("06_reagents", "Reaktivlar / retseptlar"),
        ("07_narcotics", "Giyohvand moddalar va nazorat ro‘yxatlari"),
        ("08_toxicology", "Toksikologiya (skrining, metodlar, ilmiy da’volar)"),
        ("09_forensic_medicine", "Sud tibbiyoti"),
        ("10_histology", "Gistologiya"),
        ("11_biology", "Biologiya / biokimyo"),
        ("12_genetics", "Genetika"),
        ("13_med_criminalistics", "Tibbiy kriminalistika"),
        ("14_glossary", "Glossariy / terminlar"),
        ("15_study", "O‘quv rejimi va testlar"),
        ("16_court", "Sudda so‘roq: tayyorgarlik"),
        ("17_ai", "AI yordamchi"),
        ("18_tools", "Professional asboblar / kalkulyatorlar"),
        ("19_free_pro", "Free / Pro, obuna"),
        ("20_auth_profile", "Kirish va profil"),
        ("21_admin", "Admin panel"),
        ("22_support", "Taklif va murojaatlar"),
        ("23_errors", "Xatolar / ogohlantirishlar"),
        ("24_empty_loading", "Bo‘sh / yuklanish holatlari"),
        ("25_notifications", "Bildirishnomalar"),
        ("26_privacy_terms", "Maxfiylik / shartlar"),
        ("27_offline", "Oflayn kontent / paket holati"),
        ("28_sources_citation", "Manbalar va iqtibos nusxalash"),
    ]
)

# ARB kalit prefiksi → bo‘lim (birinchi mos kelgan qoida).
ARB_SECTION_RULES = [
    (r"^(home|first|search|nav|banner|dashboard|appTitle|onb|language|mode|disclaimer|theme|contrast)", "01_home"),
    (r"^(disc|discipline|disciplines|module|field|tech_|group)", "02_disciplines"),
    (r"^(library|detail|rd|conc|concentration|spec|specimen|specimens|met[A-Z]|metKind|image|images|chain|analysis|substance|favorite|saved)", "03_library"),
    (r"^(research|relevance|pub)", "04_research"),
    (r"^(guideline|guidelines|tpl|practice|restricted)", "05_guidelines"),
    (r"^(reagent)", "06_reagents"),
    (r"^(legal|jurisdiction|jurisdictions|instr|compare|ctx|binding|lc|lf)", "07_narcotics"),
    (r"^(screening|method|methods|emerging|knowledge|quote)", "08_toxicology"),
    (r"^(fm|histology)", "09_forensic_medicine"),
    (r"^(glossary)", "14_glossary"),
    (r"^(study|learn|quiz|flashcard)", "15_study"),
    (r"^(court)", "16_court"),
    (r"^(ai)", "17_ai"),
    (r"^(calc|tool|tools|ld|st[A-Z]|unit)", "18_tools"),
    (r"^(tier|purchase|subscription|offer|period|pro[A-Z]|free|locked|plan|store|restore|paywall|access|avail|referral)", "19_free_pro"),
    (r"^(account|auth|profile|email|pw|password|forgot|verif|verify|cred|role|delete|reset|form|choose|settings|professional|review)", "20_auth_profile"),
    (r"^(adm|admin|queue|diag|diagnostics|severity|pii|action)", "21_admin"),
    (r"^(sup|support|file)", "22_support"),
    (r"^(error|err|not[A-Z]|status|state|unverified|scientific|lifecycle|conflict|conflicts|evidence|ev[A-Z]|warning)", "23_errors"),
    (r"^(empty|loading|no[A-Z]|in[A-Z]|test)", "24_empty_loading"),
    (r"^(notif|unread)", "25_notifications"),
    (r"^(privacy|terms|about|license|legalDoc|doc|meta|app[A-Z])", "26_privacy_terms"),
    (r"^(offline|pack|content|database|translation)", "27_offline"),
    (r"^(source|sources|src|cite|citation|prov|reuse|std|standards|section|share|see|open|relation|layer|filter|manage|full|template|scope)", "28_sources_citation"),
]

KNOWLEDGE_AREA_SECTION = {
    "forensicMedicine": "09_forensic_medicine",
    "histology": "10_histology",
    "biochemistry": "11_biology",
    "toxicology": "08_toxicology",
    "laboratory": "08_toxicology",
    "reagents": "06_reagents",
    "screening": "08_toxicology",
    "methods": "08_toxicology",
    "emergingIssues": "07_narcotics",
}

NARCOTIC_GROUPS = {
    "opioids", "stimulants", "cannabinoids", "hallucinogens", "nps",
    "synthetic_opioids", "synthetic_cannabinoids", "cathinones",
    "benzodiazepines", "barbiturates", "phenylalkylamines", "cocaine",
}

# --------------------------------------------------------------------------
# Leksikonlar (qasddan qisqa va izohlanadigan — deterministik)
# --------------------------------------------------------------------------
# Inglizcha «signal» so‘zlari: funksional so‘zlar + o‘zbek/rus matnida
# qarz so‘z sifatida uchramaydigan keng tarqalgan so‘zlar. O‘zbekcha bilan
# to‘qnashadiganlari (on, son, men, tan, it, bor, test, marker, format,
# status, filtr, standart…) ATAYLAB yo‘q.
EN_WORDS = set(
    """
    the of and to for with from by are was were be been being has have had
    that this these those which who whom whose what when where why how not
    no yes or but if then than also only more most less least very can could
    may might must should would will shall into onto upon about after before
    between during within without under over through against among per
    its their there they them our your you we he she his her it's isn't
    don't does did done do any all each every some such other another same
    both either neither one two three first second new used use using uses
    based may however therefore thus because while although whether
    blood urine death dead body bodies sample samples specimen specimens
    analysis analytical method methods result results reported report reports
    study studies case cases drug drugs poisoning concentration concentrations
    level levels found showed shown observed detected detection identified
    identification determined determination quantification confirmation
    screening confirmatory presumptive positive negative false true
    postmortem post-mortem antemortem interval change changes time
    source sources quote original translation reviewed review not verified
    please try again search settings cancel continue save open close back next
    loading error sign account profile library tools home favorites saved
    submit retry language subscription unlock locked free details show less
    privacy terms delete edit add remove share copy select choose student
    expert professional email password verify register today yesterday
    unknown none calculator
    liver heart lung lungs brain kidney stomach gastric vitreous humor humour
    hair tissue tissues fluid fluids femoral cardiac peripheral whole
    strip immunoassay class-based specified see stated
    """.split()
)

# Lotin turlari / iboralari (o‘zbek va rus matnida ruxsat etiladi).
LATIN_PHRASES = [
    r"\bin\s+vitro\b", r"\bin\s+vivo\b", r"\bin\s+situ\b", r"\bpost\s+mortem\b",
    r"\bante\s+mortem\b", r"\blivor\s+mortis\b", r"\brigor\s+mortis\b",
    r"\balgor\s+mortis\b", r"\bet\s+al\.?", r"\bper\s+se\b", r"\bde\s+novo\b",
    r"\bsensu\s+stricto\b", r"\bvice\s+versa\b",
]

# O‘zbekcha (lotin) signal: o‘/g‘ (har xil apostrof) va funksional so‘zlar.
UZ_APOS = r"[‘ʻ’'`]"
# Inglizcha egalik «Fehling's», «drug's» o‘zbekcha emas (’s / 's so‘z oxirida).
UZ_OG = re.compile(r"\b\w*[oOgG]" + UZ_APOS + r"(?!s\b)[a-zA-Z]\w*")
UZ_WORDS = set(
    """
    va bilan uchun yoki emas ham kerak haqida mumkin qilish bo‘yicha sifatida
    tomonidan orqali hamda lekin ammo agar keyin oldin bu shu ushbu qanday
    nima qaysi hozircha tekshirilmagan tarjima manba manbalar asl matn
    ko‘rish ochish yopish saqlash bekor qidirish
    """.split()
)
UZ_SUFFIX = re.compile(r"\b[a-z]{3,}(lari|larni|larning|ning|dagi|lardan|ga|dan|da)\b")

CYR = re.compile(r"[А-Яа-яЁёЎўҚқҒғҲҳ]")
LAT_WORD = re.compile(r"[A-Za-z](?:[A-Za-z\-]|[‘ʻ’'`](?=[A-Za-z]))*")

# ARB: inglizcha qiymat qolishi ruxsat etilgan kalitlar (brend, qisqartma,
# bibliografik nom — E toifa) — qarang: hujjat «allowlist».
ARB_ALLOW_SAME = {
    "appTitle", "moduleAi", "tierStudentPro", "tierProfessionalPro",
    "offerPriceLine", "languageOptionSemantics", "sourcePmid",
    "sourceSectionRef", "adminAndroid", "adminAdminBadge", "rdGlanceMolarMass",
    "fileSizeKb", "tech_hplc", "citeStyleGost", "citeStyleVancouver",
    "calcFormula", "detailBiomarker", "metKindMarker", "tpl_marker",
    "calcStatsMin",
}
ARB_CATEGORY_OVERRIDE = {"calcLodReference": "E"}

# O‘zbekcha sanoq tuzilishi «{total} tadan {n}-…» (egasi: noqulay).
AWKWARD_COUNTER = re.compile(r"\{\w+\}\s+tadan\s+\{\w+\}")


# --------------------------------------------------------------------------
# Ma’lumot tuzilmalari
# --------------------------------------------------------------------------
@dataclass
class Unit:
    """Bitta foydalanuvchiga ko‘rinadigan matn birligi (3 tilda)."""

    source: str  # arb | content.db | guidelines | court_prep | dart
    container: str  # fayl / jadval
    id: str
    field: str
    category: str  # A–G
    section: str
    values: dict  # lang → str | None
    status: dict = field(default_factory=dict)  # lang → status
    original_lang: str | None = None  # D/E/F: asl til
    note: str = ""
    missing_severity: str = "error"
    # Ataylab bitta tilda yoziladigan birlik (milliy yo‘riqnomadan olingan
    # mavzular, egasining qarori — docs/DECISIONS.md, 2026-10-10). Ilova uni
    # boshqa tilda umuman ko‘rsatmaydi (LocaleFilteredKnowledgeRepository),
    # shuning uchun u tillarda «tarjimasi yo‘q» degan xato bo‘lmaydi.
    locale_only: str | None = None


@dataclass
class Finding:
    severity: str  # error | warn | info
    rule: str
    lang: str
    unit: Unit
    excerpt: str
    detail: str = ""

    def to_json(self) -> dict:
        u = self.unit
        return {
            "severity": self.severity,
            "rule": self.rule,
            "lang": self.lang,
            "source": u.source,
            "container": u.container,
            "id": u.id,
            "field": u.field,
            "category": u.category,
            "section": u.section,
            "excerpt": self.excerpt,
            "detail": self.detail,
        }


# --------------------------------------------------------------------------
# Detektor (sof funksiyalar)
# --------------------------------------------------------------------------
def _strip_allowed(text: str) -> str:
    """Tekshiruvdan oldin ruxsat etilgan qismlarni olib tashlaydi:
    {placeholder}, URL, DOI, qavs ichidagi asl atama, «» ichidagi asl iqtibos,
    [manba_kaliti], lotin iboralari."""
    # ICU plural/select: «{count, plural, =0{…} other{…}}» — faqat matn qoladi.
    t = re.sub(r"\{\w+,\s*(?:plural|select)\s*,", " ", text)
    t = re.sub(r"(?:=\d+|zero|one|two|few|many|other)\s*\{", " ", t)
    t = re.sub(r"\{[^{}]*\}", " ", t)
    t = re.sub(r"https?://\S+|www\.\S+|10\.\d{4,}/\S+", " ", t)
    t = re.sub(r"\[[a-z0-9_,\s]+\]", " ", t)  # [court_uz_cpc, swgdrug2024]
    for p in LATIN_PHRASES:
        t = re.sub(p, " ", t, flags=re.I)
    return t


def _outside_quotes(text: str) -> str:
    """«…», "…", (…) ichidagini olib tashlaydi (asl atama / iqtibos)."""
    t = re.sub(r"«[^»]*»", " ", text)
    t = re.sub(r"“[^”]*”|\"[^\"]*\"", " ", t)
    prev = None
    while prev != t:
        prev = t
        t = re.sub(r"\([^()]*\)", " ", t)
    return t


def english_hits(text: str) -> list[str]:
    """Kichik harfli inglizcha signal so‘zlari (qavs/qo‘shtirnoq tashqarisida).
    Bosh harfli so‘zlar (atoqli ot, muallif, brend), KATTA harfli qisqartma va
    raqamli tokenlar hisobga olinmaydi."""
    t = _outside_quotes(_strip_allowed(text))
    hits = []
    for w in LAT_WORD.findall(t):
        lw = w.lower()
        if w != lw:  # Capitalised / ABBR → atoqli ot yoki qisqartma
            # Gap boshidagi funksional so‘z (The, For, With…) — signal.
            if w[0].isupper() and w[1:] == w[1:].lower() and lw in {
                "the", "this", "these", "for", "with", "from", "when", "which",
                "what", "how", "not", "please", "your", "you", "and", "are",
                "all", "each", "some", "see", "use", "using", "based",
            }:
                hits.append(lw)
            continue
        if lw in EN_WORDS:
            hits.append(lw)
    return hits


def english_shaped(text: str) -> list[str]:
    """Kichik harfli, inglizcha ko‘rinishdagi so‘zlar (-tion, -ing, th, w, ph,
    ck, ee, oo, ou) — o‘zbek lotin yozuvida deyarli uchramaydi."""
    t = _outside_quotes(_strip_allowed(text))
    out = []
    for w in LAT_WORD.findall(t):
        if w != w.lower() or len(w) < 4:
            continue
        if re.search(r"[‘ʻ’'`]", w):
            continue  # o‘/g‘/tutuq belgili so‘z — o‘zbekcha
        if re.search(r"(tion|tions|ness|ous)$|th|w|ph|ck|ee|oo|ou", w):
            out.append(w)
    return out


def uzbek_hits(text: str) -> list[str]:
    t = _strip_allowed(text)
    hits = [m.group(0) for m in UZ_OG.finditer(t)]
    for w in re.findall(r"[a-z‘ʻ’']+", t):
        if w in UZ_WORDS:
            hits.append(w)
    return hits


def check_text(text: str, lang: str) -> list[tuple[str, str, str]]:
    """Bitta qiymat uchun (severity, rule, detail) ro‘yxati."""
    if not text or not text.strip():
        return []
    out = []
    if lang in ("uz", "en"):
        cyr = CYR.findall(_strip_allowed(text))
        if cyr:
            outside = CYR.findall(_outside_quotes(_strip_allowed(text)))
            if outside:
                out.append(("error", f"CYRILLIC_IN_{lang.upper()}", "".join(cyr[:12])))
            else:
                out.append(("info", f"CYRILLIC_QUOTED_IN_{lang.upper()}", "".join(cyr[:12])))
    if lang in ("uz", "ru"):
        hits = english_hits(text)
        words = len(LAT_WORD.findall(text)) + len(re.findall(r"[А-Яа-яЁё]+", text))
        if len(hits) >= 2 or (hits and words <= 3):
            sev = "error" if len(hits) >= 3 or (len(hits) >= 2 and len(hits) / max(words, 1) >= 0.3) else "warn"
            out.append((sev, f"ENGLISH_IN_{lang.upper()}", " ".join(sorted(set(hits)))))
        elif lang == "uz":
            shaped = english_shaped(text)
            if len(shaped) >= 2:
                out.append(("warn", "ENGLISH_SHAPED_IN_UZ", " ".join(sorted(set(shaped))[:8])))
    if lang in ("ru", "en"):
        uz = uzbek_hits(text)
        if len(uz) >= 2 or any(UZ_OG.match(h) for h in uz):
            out.append(("error", f"UZBEK_IN_{lang.upper()}", " ".join(sorted(set(uz))[:8])))
    if lang == "uz" and AWKWARD_COUNTER.search(text):
        out.append(("warn", "UZ_AWKWARD_COUNTER", AWKWARD_COUNTER.search(text).group(0)))
    return out


def _clip(s: str, n: int = 110) -> str:
    s = re.sub(r"\s+", " ", s or "").strip()
    return s if len(s) <= n else s[: n - 1] + "…"


def _latin_words(s: str) -> int:
    """Kichik harfli (atoqli ot / qisqartma / formula emas) lotin so‘zlari soni.
    «GC-MS», «4HNO3 + 3CH2O», «ADB-BUTINACA», «Timor-Leste» → 0."""
    t = _outside_quotes(_strip_allowed(s or ""))
    return len([w for w in re.findall(r"(?<![\w-])[a-z]{3,}(?![\w-])", t)])


def detect(units: list[Unit]) -> list[Finding]:
    findings: list[Finding] = []
    for u in units:
        en = (u.values.get("en") or "").strip()
        for lang in LANGS:
            if u.locale_only and lang != u.locale_only:
                continue
            v = u.values.get(lang)
            st = u.status.get(lang, "")
            if u.category in CHECKED_CATEGORIES:
                if v is None or not str(v).strip():
                    if lang != (u.original_lang or "en") or u.category in CHECKED_CATEGORIES:
                        findings.append(Finding(
                            u.missing_severity, "MISSING_TRANSLATION", lang, u,
                            _clip(en or next((x for x in u.values.values() if x), "")),
                            "ilova boshqa tilga qaytadi (fallback)"))
                    continue
                v = str(v)
                if (lang in ("uz", "ru") and en and v.strip() == en
                        and _latin_words(en) >= 1
                        and not (u.source == "arb" and u.id in ARB_ALLOW_SAME)):
                    findings.append(Finding("error", "UNTRANSLATED_SAME_AS_EN", lang, u, _clip(v)))
                    continue
                for sev, rule, detail in check_text(v, lang):
                    findings.append(Finding(sev, rule, lang, u, _clip(v), detail))
            elif u.category in ("D", "F"):
                # Asl matn tekshirilmaydi; tarjima qatlami (bo‘lsa) tekshiriladi.
                if lang == (u.original_lang or "en"):
                    continue
                if v is None:
                    continue
                for sev, rule, detail in check_text(str(v), lang):
                    findings.append(Finding(sev, rule + "_TRANSLATION", lang, u, _clip(str(v)), detail))
            # E, G — til tekshiruvi yo‘q (asl bibliografiya / formula).
            _ = st
    return findings


# --------------------------------------------------------------------------
# Yuklovchilar
# --------------------------------------------------------------------------
def arb_section(key: str) -> str:
    for pat, sec in ARB_SECTION_RULES:
        if re.match(pat, key):
            return sec
    return "01_home"


def load_arb(app: Path) -> list[Unit]:
    d = {l: json.loads((app / f"lib/core/l10n/arb/app_{l}.arb").read_text()) for l in LANGS}
    keys = sorted(k for k in d["en"] if not k.startswith("@"))
    units = []
    for k in keys:
        units.append(Unit(
            "arb", "lib/core/l10n/arb/app_<lang>.arb", k, "value",
            ARB_CATEGORY_OVERRIDE.get(k, "A"), arb_section(k),
            {l: d[l].get(k) for l in LANGS},
            {l: ("present" if d[l].get(k) else "missing") for l in LANGS},
        ))
    return units


def _tri(obj) -> dict:
    if isinstance(obj, str):
        try:
            obj = json.loads(obj)
        except ValueError:
            return {"en": obj}
    return {l: (obj or {}).get(l) for l in LANGS}


def _status_from(obj, default: str) -> dict:
    if isinstance(obj, dict):
        return {l: str(obj.get(l) or "missing").lower() for l in LANGS}
    return {l: default for l in LANGS}


def _norm_ws(s: str) -> str:
    return re.sub(r"\s+", " ", (s or "").strip().lower())


def _guess_lang(text: str) -> str:
    if CYR.search(text or ""):
        return "ru"
    if UZ_OG.search(text or ""):
        return "uz"
    return "en"


def load_content_db(app: Path) -> tuple[list[Unit], dict]:
    db = sqlite3.connect(str(app / "assets/content/pilot/content.db"))
    db.row_factory = sqlite3.Row
    q = lambda sql: list(db.execute(sql))  # noqa: E731
    C = "assets/content/pilot/content.db"
    units: list[Unit] = []
    meta = {r["meta_key"]: r["meta_value"] for r in q("SELECT * FROM content_meta")}

    tt = collections.defaultdict(dict)
    for r in q("SELECT * FROM text_translations"):
        tt[(r["target_type"], r["target_id"])][r["lang"]] = (r["translated_text"], r["status"])

    # Moddalar: nomlar (B) — substance_i18n.
    groups = {r["substance_id"]: r["substance_group"] for r in q("SELECT substance_id, substance_group FROM substances")}
    by_sub = collections.defaultdict(dict)
    for r in q("SELECT * FROM substance_i18n"):
        by_sub[r["substance_id"]][r["lang"]] = (r["name"], r["translation_status"], r["description_md"])
    for sid in sorted(groups):
        rows = by_sub.get(sid, {})
        sec = "07_narcotics" if (groups[sid] or "") in NARCOTIC_GROUPS else "03_library"
        units.append(Unit("content.db", f"{C}#substance_i18n", sid, "name", "B", sec,
                          {l: rows.get(l, (None,))[0] for l in LANGS},
                          {l: rows.get(l, (None, "missing"))[1] for l in LANGS}))

    # Ilmiy da’volar: asl iqtibos (D) + tarjima (machine_draft).
    for r in q("SELECT claim_id, entity_type, entity_id, field, value_json FROM claims ORDER BY claim_id"):
        v = json.loads(r["value_json"])
        et = r["entity_type"]
        sec = {"substance": "03_library", "topic": "09_forensic_medicine", "method": "08_toxicology",
               "reagent": "06_reagents", "screeningTest": "08_toxicology", "specimen": "08_toxicology",
               "emergingIssue": "07_narcotics"}.get(et, "08_toxicology")
        if et == "topic":
            sec = "08_toxicology" if r["entity_id"].startswith("tox-") else (
                "11_biology" if r["entity_id"].startswith("bio-") else (
                    "10_histology" if r["entity_id"].startswith("hist") else "09_forensic_medicine"))
        if "excerpt" in v:
            tr = tt.get(("claim_excerpt", r["claim_id"]), {})
            units.append(Unit("content.db", f"{C}#claims", r["claim_id"], f"value_json.excerpt ({r['field']})",
                              "D", sec,
                              {"en": v["excerpt"], "uz": tr.get("uz", (None,))[0], "ru": tr.get("ru", (None,))[0]},
                              {"en": "original", "uz": tr.get("uz", (None, "missing"))[1], "ru": tr.get("ru", (None, "missing"))[1]},
                              original_lang="en"))
        if r["field"] == "identity":
            units.append(Unit("content.db", f"{C}#claims", r["claim_id"], "identity (formula/InChIKey/IUPAC)",
                              "G", sec, {l: v.get("molecular_formula") for l in LANGS},
                              {l: "invariant" for l in LANGS}))
        # Konsentratsiya konteksti: muharrir yozgan inglizcha erkin matn
        # (populyatsiya, holat turi, statistik ko‘rsatkich, cheklovlar) — B.
        cs = v.get("context_strict") or {}
        for f in ("population", "case_type", "co_intoxicants", "statistic"):
            val = cs.get(f)
            if isinstance(val, str) and val and not re.fullmatch(r"[a-z_]+", val):
                units.append(Unit("content.db", f"{C}#claims", r["claim_id"], f"context_strict.{f}", "B", sec,
                                  {"en": val, "uz": None, "ru": None}, {"en": "authored", "uz": "missing", "ru": "missing"}))
        for i, val in enumerate(cs.get("limitations") or []):
            units.append(Unit("content.db", f"{C}#claims", r["claim_id"], f"context_strict.limitations[{i}]", "B", sec,
                              {"en": val, "uz": None, "ru": None}, {"en": "authored", "uz": "missing", "ru": "missing"}))
        for item in v.get("items", []) or []:
            units.append(Unit("content.db", f"{C}#claims", r["claim_id"], "value_json.items[]", "B", sec,
                              {"en": item, "uz": None, "ru": None}, {"en": "original", "uz": "missing", "ru": "missing"},
                              note="ro‘yxat elementlari (metabolit/marker nomlari) — tarjimasiz",
                              # Kimyoviy nom (raqam/qisqartma) — G ga yaqin: warn; ibora — error.
                              missing_severity="error" if len(item.split()) >= 2 and not re.search(r"\d|\(", item) else "warn"))

    excerpt_claim = {}
    for r in q("SELECT claim_id, value_json FROM claims ORDER BY claim_id"):
        ex = json.loads(r["value_json"]).get("excerpt")
        if ex:
            excerpt_claim.setdefault(_norm_ws(ex), r["claim_id"])

    # Yozuvning tili: barcha da’volari bitta tilga belgilangan bo‘lsa
    # (`value.locale_only`), yozuvning o‘zi ham faqat shu tilda ko‘rsatiladi —
    # ilovadagi qoida bilan bir xil (LocaleFilteredKnowledgeRepository).
    entity_locale_only: dict[str, str] = {}
    _entity_langs: dict[str, set] = {}
    for r in q("SELECT entity_id, value_json FROM claims ORDER BY claim_id"):
        _entity_langs.setdefault(r["entity_id"], set()).add(
            json.loads(r["value_json"]).get("locale_only"))
    for eid, langs in _entity_langs.items():
        if len(langs) == 1 and (only := next(iter(langs))):
            entity_locale_only[eid] = only

    # Bilim yozuvlari (mavzu, metod, skrining, reaktiv, yangi muammo).
    for r in q("SELECT entity_id, entity_type, area, names_json, payload_json FROM knowledge_entities ORDER BY entity_id"):
        eid, et, area = r["entity_id"], r["entity_type"], r["area"]
        p = json.loads(r["payload_json"])
        sec = KNOWLEDGE_AREA_SECTION.get(area, "08_toxicology")
        if eid.startswith("hist"):
            sec = "10_histology"
        units.append(Unit("content.db", f"{C}#knowledge_entities", eid, "names_json", "B", sec,
                          _tri(r["names_json"]), {l: "no_status" for l in LANGS},
                          locale_only=entity_locale_only.get(eid)))
        if et == "screening_test":
            for f in ("analyte", "specimen", "principle"):
                if p.get(f):
                    units.append(Unit("content.db", f"{C}#knowledge_entities", eid, f"payload.{f}", "B", sec,
                                      {"en": p[f], "uz": None, "ru": None},
                                      {"en": "authored", "uz": "missing", "ru": "missing"},
                                      note="ekranda _Field orqali to‘g‘ridan-to‘g‘ri ko‘rsatiladi"))
            for f in ("limitations", "cross_reactivity", "false_positive"):
                for i, n in enumerate(p.get(f, []) or []):
                    txt = n.get("text", "")
                    # Da’vo iqtibosi bilan bir xil bo‘lsa — ekran uni da’vo sifatida
                    # (SourceQuote + machine_draft tarjima) ko‘rsatadi va bu nusxani
                    # yashiradi (knowledge_detail_screen: claimExcerpts dedup).
                    cid = excerpt_claim.get(_norm_ws(txt))
                    trc = tt.get(("claim_excerpt", cid), {}) if cid else {}
                    units.append(Unit("content.db", f"{C}#knowledge_entities", eid, f"payload.{f}[{i}].text", "D", sec,
                                      {"en": txt, "uz": trc.get("uz", (None,))[0], "ru": trc.get("ru", (None,))[0]},
                                      {"en": "original",
                                       "uz": "machine_draft (via claim)" if "uz" in trc else "missing",
                                       "ru": "machine_draft (via claim)" if "ru" in trc else "missing"},
                                      original_lang="en"))
        if et == "reagent":
            def tri_texts(o):
                # Tarjimasiz element (masalan PMC varianti) — faqat asl `text`/`name`
                # (inglizcha) bor: ilova uni barcha tillarda shundayligicha ko‘rsatadi.
                return (o.get("texts") or o.get("names") or o.get("labels")
                        or {"en": o.get("text") or o.get("name")})
            for i, ing in enumerate(p.get("ingredients", []) or []):
                t3 = tri_texts(ing)
                units.append(Unit("content.db", f"{C}#knowledge_entities", eid, f"payload.ingredients[{i}].name", "B", sec,
                                  {l: t3.get(l) for l in LANGS}, {l: p.get("translation_status") or "no_status" for l in LANGS}))
                if ing.get("quantity_note"):
                    units.append(Unit("content.db", f"{C}#knowledge_entities", eid, f"payload.ingredients[{i}].quantity_note", "B", sec,
                                      {l: ing["quantity_note"].get(l) for l in LANGS}, {l: p.get("translation_status") or "no_status" for l in LANGS}))
            for f in ("steps", "hazards", "notes", "variants"):
                for i, s in enumerate(p.get(f, []) or []):
                    t3 = tri_texts(s)
                    units.append(Unit("content.db", f"{C}#knowledge_entities", eid, f"payload.{f}[{i}]", "B", sec,
                                      {l: t3.get(l) for l in LANGS}, {l: p.get("translation_status") or "no_status" for l in LANGS}))
            for f in ("storage", "stability"):
                if isinstance(p.get(f), dict):
                    t3 = tri_texts(p[f])
                    units.append(Unit("content.db", f"{C}#knowledge_entities", eid, f"payload.{f}", "B", sec,
                                      {l: t3.get(l) for l in LANGS}, {l: p.get("translation_status") or "no_status" for l in LANGS}))
            if p.get("original_text"):
                ol = p.get("original_language") or _guess_lang(p["original_text"])
                units.append(Unit("content.db", f"{C}#knowledge_entities", eid, "payload.original_text", "D", sec,
                                  {l: (p["original_text"] if l == ol else None) for l in LANGS},
                                  {l: ("original" if l == ol else "n/a (strukturali tarjima bor)") for l in LANGS},
                                  original_lang=ol))

    # Tadqiqotlar: sarlavha (E) + tarjima qilingan sarlavha mazmuni (gloss).
    for r in q("SELECT research_id, title, language FROM research_records ORDER BY research_id"):
        tr = tt.get(("research_title", r["research_id"]), {})
        ol = r["language"] or _guess_lang(r["title"])
        units.append(Unit("content.db", f"{C}#research_records", r["research_id"], "title", "E", "04_research",
                          {l: (r["title"] if l == ol else (tr.get(l, (None,))[0])) for l in LANGS},
                          {l: ("original" if l == ol else tr.get(l, (None, "missing_gloss"))[1]) for l in LANGS},
                          original_lang=ol))

    # Manbalar sarlavhasi (E).
    for r in q("SELECT source_id, title FROM sources ORDER BY source_id"):
        ol = _guess_lang(r["title"])
        if r["source_id"].startswith("SRC-FE-"):
            # Ilova/egasi yozgan manba tavsifi — bibliografiya emas, tarjima qilinishi kerak.
            units.append(Unit("content.db", f"{C}#sources", r["source_id"], "title (app-authored)", "B", "28_sources_citation",
                              {l: (r["title"] if l == ol else None) for l in LANGS},
                              {l: ("authored" if l == ol else "missing") for l in LANGS}))
            continue
        units.append(Unit("content.db", f"{C}#sources", r["source_id"], "title", "E", "28_sources_citation",
                          {l: (r["title"] if l == ol else None) for l in LANGS},
                          {l: ("original" if l == ol else "missing_gloss") for l in LANGS}, original_lang=ol))

    # Rasmiy hujjatlar (F): nomlar (har til — rasmiy yoki tarjima).
    for r in q("SELECT instrument_id, official_reference FROM jurisdictional_instruments ORDER BY instrument_id"):
        ref = r["official_reference"] or ""
        if re.search(r"[a-z]{4,} [a-z]{3,}", ref):  # «consolidated text retrieved …» — muharrir izohi
            units.append(Unit("content.db", f"{C}#jurisdictional_instruments", r["instrument_id"], "official_reference (editorial)", "B",
                              "07_narcotics", {"en": ref, "uz": None, "ru": None}, {"en": "authored", "uz": "missing", "ru": "missing"},
                              note="rasmiy raqam + inglizcha muharrir izohi bitta maydonda"))
    for r in q("SELECT instrument_id, jurisdiction_id, titles_json, language, translation_status FROM jurisdictional_instruments ORDER BY instrument_id"):
        t3 = _tri(r["titles_json"])
        ol = r["language"] or "en"
        units.append(Unit("content.db", f"{C}#jurisdictional_instruments", r["instrument_id"], "titles_json", "F", "07_narcotics",
                          t3, {l: ("official/original" if l == ol else (r["translation_status"] or "missing") if t3.get(l) else "missing") for l in LANGS},
                          original_lang=ol,
                          note="legal_rule_card.dart har doim titles['en'] ni ko‘rsatadi"))
    for r in q("SELECT rule_id, value_json FROM jurisdictional_rules ORDER BY rule_id"):
        v = json.loads(r["value_json"])
        if "excerpt" in v:
            tr = tt.get(("rule_excerpt", r["rule_id"]), {})
            units.append(Unit("content.db", f"{C}#jurisdictional_rules", r["rule_id"], "value_json.excerpt", "F", "07_narcotics",
                              {"en": v["excerpt"], "uz": tr.get("uz", (None,))[0], "ru": tr.get("ru", (None,))[0]},
                              {"en": "official", "uz": tr.get("uz", (None, "missing"))[1], "ru": tr.get("ru", (None, "missing"))[1]},
                              original_lang="en"))
        if "convention" in v:
            units.append(Unit("content.db", f"{C}#jurisdictional_rules", r["rule_id"], "value_json.convention", "F", "07_narcotics",
                              {"en": v["convention"], "uz": None, "ru": None},
                              {"en": "official", "uz": "missing", "ru": "missing"}, original_lang="en",
                              note="l.legalSchedule(convention, …) — konvensiya nomi inglizcha"))

    # Ziddiyatlar (B, muharrir yozgan inglizcha savol/izoh).
    for r in q("SELECT conflict_id, entity_id, question, note FROM evidence_conflicts ORDER BY conflict_id"):
        for f in ("question", "note"):
            units.append(Unit("content.db", f"{C}#evidence_conflicts", r["conflict_id"], f, "B", "23_errors",
                              {"en": r[f], "uz": None, "ru": None}, {"en": "authored", "uz": "missing", "ru": "missing"}))
    # Standartlar: sarlavha (E), izoh (B).
    for r in q("SELECT standard_id, title, note FROM standards ORDER BY standard_id"):
        units.append(Unit("content.db", f"{C}#standards", r["standard_id"], "title", "E", "28_sources_citation",
                          {"en": r["title"], "uz": None, "ru": None}, {"en": "original", "uz": "missing_gloss", "ru": "missing_gloss"},
                          original_lang="en"))
        if r["note"]:
            units.append(Unit("content.db", f"{C}#standards", r["standard_id"], "note", "B", "28_sources_citation",
                              {"en": r["note"], "uz": None, "ru": None}, {"en": "authored", "uz": "missing", "ru": "missing"}))
    # Namuna turlari, yurisdiksiya, idoralar (B).
    for tbl, idc, sec in (("specimens", "specimen_id", "08_toxicology"), ("jurisdictions", "jurisdiction_id", "07_narcotics"),
                          ("authorities", "authority_id", "07_narcotics")):
        for r in q(f"SELECT {idc}, names_json FROM {tbl} ORDER BY {idc}"):
            units.append(Unit("content.db", f"{C}#{tbl}", r[idc], "names_json", "B", sec, _tri(r["names_json"]),
                              {l: "no_status" for l in LANGS}))
    # Rasmlar: sarlavha/alt (B), asl izoh (D).
    for r in q("SELECT image_id, title_json, alt_json, caption_original FROM images ORDER BY image_id"):
        units.append(Unit("content.db", f"{C}#images", r["image_id"], "title_json", "B", "03_library", _tri(r["title_json"]),
                          {l: "no_status" for l in LANGS}))
        units.append(Unit("content.db", f"{C}#images", r["image_id"], "alt_json", "B", "03_library", _tri(r["alt_json"]),
                          {l: "no_status" for l in LANGS}))
        if r["caption_original"]:
            units.append(Unit("content.db", f"{C}#images", r["image_id"], "caption_original", "D", "03_library",
                              {"en": r["caption_original"], "uz": None, "ru": None},
                              {"en": "original", "uz": "missing", "ru": "missing"}, original_lang="en"))
    # Glossariy (B) — term_translations.
    for r in q("SELECT term_id, kind, localized_json, status_json FROM term_translations ORDER BY term_id"):
        cat = "G" if r["kind"] in ("identifier", "formula") else "B"
        units.append(Unit("content.db", f"{C}#term_translations", r["term_id"], f"localized_json ({r['kind']})", cat, "14_glossary",
                          _tri(r["localized_json"]), _status_from(json.loads(r["status_json"]), "missing")))
    # Metabolit nomlari (G).
    for r in q("SELECT relation_id, metabolite_name FROM metabolite_relations ORDER BY relation_id"):
        units.append(Unit("content.db", f"{C}#metabolite_relations", r["relation_id"], "metabolite_name", "G", "03_library",
                          {l: r["metabolite_name"] for l in LANGS}, {l: "invariant" for l in LANGS}))
    db.close()
    return units, meta


def load_guidelines(app: Path) -> list[Unit]:
    G = "assets/content/guidelines/guidelines_v1.json"
    g = json.loads((app / G).read_text())
    units = []
    for c in g["cards"]:
        cid = c["id"]
        st = _status_from(c.get("translation_status"), "missing")
        sec = "07_narcotics" if ".gmt_" in cid else "05_guidelines"
        units.append(Unit("guidelines", G, cid, "title", "B", sec, _tri(c["title"]), st))
        units.append(Unit("guidelines", G, cid, "summary", "B", sec, _tri(c["summary"]), st))
        for s in c.get("sections", []):
            units.append(Unit("guidelines", G, cid, f"sections.{s['key']}.title", "B", sec, _tri(s.get("title")), st))
            units.append(Unit("guidelines", G, cid, f"sections.{s['key']}.body", "B", sec, _tri(s.get("body")), st))
        kw = c.get("keywords") or {}
        units.append(Unit("guidelines", G, cid, "keywords", "B", sec,
                          {l: (", ".join(kw.get(l, [])) or None) for l in LANGS}, st,
                          note="qidiruv kalitlari (ko‘rinmaydi) — faqat qamrov"))
        for qz in c.get("quiz", []) or []:
            qid = f"{cid}#{qz['id']}"
            units.append(Unit("guidelines", G, qid, "quiz.q", "C", "15_study", _tri(qz["q"]), st))
            units.append(Unit("guidelines", G, qid, "quiz.a", "C", "15_study", _tri(qz["a"]), st))
            for i in range(max(len(qz["d"].get(l, [])) for l in LANGS)):
                units.append(Unit("guidelines", G, qid, f"quiz.d[{i}]", "C", "15_study",
                                  {l: (qz["d"].get(l) or [None] * 9)[i] if i < len(qz["d"].get(l) or []) else None for l in LANGS}, st))
    for r in g["references"]:
        cat = "F" if r.get("type") in ("law", "legislation", "regulation", "decree") else "E"
        ol = _guess_lang(r.get("title", ""))
        units.append(Unit("guidelines", G, r["key"], f"references.title ({r.get('type')})", cat, "28_sources_citation",
                          {l: (r.get("title") if l == ol else r.get(f"title_{l}")) for l in LANGS},
                          {l: ("original" if l == ol else ("present" if r.get(f"title_{l}") else "missing_official_title" if cat == "F" else "missing_gloss")) for l in LANGS},
                          original_lang=ol))
    return units


def load_court(app: Path) -> list[Unit]:
    P = "assets/content/court_prep/court_prep_v1.json"
    g = json.loads((app / P).read_text())
    units = []
    sec = "16_court"
    for t in g["topics"]:
        for f in ("title", "summary"):
            if t.get(f):
                units.append(Unit("court_prep", P, t["id"], f, "B", sec, _tri(t[f]), {l: "no_status" for l in LANGS}))
    for qn in g["questions"]:
        st = _status_from(qn.get("translation_status"), "missing")
        for f in ("question", "tests", "short_answer"):
            if qn.get(f):
                units.append(Unit("court_prep", P, qn["id"], f, "C", sec, _tri(qn[f]), st))
        for k, items in (qn.get("prepare") or {}).items():
            for i, it in enumerate(items):
                units.append(Unit("court_prep", P, qn["id"], f"prepare.{k}[{i}]", "C", sec, _tri(it), st))
        for i, fu in enumerate(qn.get("followups") or []):
            units.append(Unit("court_prep", P, qn["id"], f"followups[{i}].q", "C", sec, _tri(fu["q"]), st))
            units.append(Unit("court_prep", P, qn["id"], f"followups[{i}].a", "C", sec, _tri(fu["a"]), st))
        for i, it in enumerate(qn.get("limitations") or []):
            units.append(Unit("court_prep", P, qn["id"], f"limitations[{i}]", "C", sec, _tri(it), st))
    for p in g["principles"]:
        units.append(Unit("court_prep", P, p["id"], "text", "C", sec, _tri(p["text"]), {l: "no_status" for l in LANGS}))
    for s in g["simulator"]["scenarios"]:
        for f in ("context", "prompt"):
            if s.get(f):
                units.append(Unit("court_prep", P, s["id"], f, "C", sec, _tri(s[f]), {l: "no_status" for l in LANGS}))
        for i, o in enumerate(s.get("options", [])):
            for f in ("text", "feedback"):
                if o.get(f):
                    units.append(Unit("court_prep", P, s["id"], f"options[{i}].{f}", "C", sec, _tri(o[f]), {l: "no_status" for l in LANGS}))
    for r in g["references"]:
        cat = "F" if r.get("type") in ("law", "legislation", "regulation", "decree") else "E"
        ol = _guess_lang(r.get("title", ""))
        units.append(Unit("court_prep", P, r["key"], f"references.title ({r.get('type')})", cat, "16_court" if cat == "F" else "28_sources_citation",
                          {l: (r.get("title") if l == ol else r.get(f"title_{l}")) for l in LANGS},
                          {l: ("original" if l == ol else ("present" if r.get(f"title_{l}") else "missing_official_title" if cat == "F" else "missing_gloss")) for l in LANGS},
                          original_lang=ol,
                          note=("UZ qonuni: rasmiy o‘zbekcha nom yo‘q" if cat == "F" and "uz" in r["key"] else "")))
    return units


DART_UI_LITERAL = re.compile(
    r"""(?:\b(?:Text|SelectableText|Tooltip|SnackBar)\(\s*|\b(?:title|label|tooltip|hintText|labelText|helperText|errorText|semanticLabel|message)\s*:\s*)'([^'$\\]*[A-Za-zА-яЁё‘][^'$\\]*\s[^'$\\]*)'"""
)
DART_TRI_MAP = re.compile(r"'en':\s*'([^']*)',\s*'ru':\s*'([^']*)',\s*'uz':\s*'([^']*)'", re.S)
DART_COUNTRY = re.compile(r"(?:CountryName|_country)\(\s*'([A-Z]{2})',\s*'([^']*)',\s*'([^']*)',\s*'([^']*)',?\s*\)", re.S)


# Faqat o‘zbek tilida ko‘rsatiladigan ekran (egasining qarori, 2026-10-10: «Manbalar va
# mualliflar»; ruscha/inglizcha interfeysda havolasi ham chiqmaydi, test bilan tekshiriladi).
# Matni hujjat nomlari va ismlardan iborat — tarjima qilinmaydi, shuning uchun «barcha tillarda
# bir xil» qoidasidan istisno.
UZ_ONLY_DART = {"lib/features/profile/presentation/sources_authors_screen.dart"}


def load_dart(app: Path) -> list[Unit]:
    units = []
    for path in sorted((app / "lib").rglob("*.dart")):
        rel = path.relative_to(app).as_posix()
        if "/generated/" in rel or "/fixtures/" in rel or rel in UZ_ONLY_DART:
            continue
        text = path.read_text()
        # Izohlarni olib tashlash (qator raqamlari saqlanadi).
        code = re.sub(r"(?m)^\s*///?.*$", "", text)
        for m in DART_UI_LITERAL.finditer(code):
            line = code.count("\n", 0, m.start()) + 1
            units.append(Unit("dart", rel, f"L{line}", "hard-coded UI literal", "A", "23_errors",
                              {l: m.group(1) for l in LANGS}, {l: "hardcoded" for l in LANGS},
                              note="ARB’da emas — barcha tillarda bir xil"))
        for m in DART_TRI_MAP.finditer(code):
            line = code.count("\n", 0, m.start()) + 1
            units.append(Unit("dart", rel, f"L{line}", "LocalizedText map", "B",
                              "15_study" if "learn" in rel else "02_disciplines",
                              {"en": m.group(1), "ru": m.group(2), "uz": m.group(3)}, {l: "present" for l in LANGS}))
        for m in DART_COUNTRY.finditer(code):
            line = code.count("\n", 0, m.start()) + 1
            units.append(Unit("dart", rel, f"{m.group(1)}@L{line}", "country name", "B", "20_auth_profile",
                              {"en": m.group(2), "ru": m.group(3), "uz": m.group(4)}, {l: "present" for l in LANGS}))
    return units


RENDER_SITE = re.compile(r"Locale\('en'\)|\[\s*'en'\s*\]")


def load_render_sites(app: Path) -> list[dict]:
    """Kontentni faqat inglizcha (yoki 'en' fallback bilan) chizadigan joylar —
    detektor matnni emas, chizish yo‘lini ko‘rsatadi (statik, deterministik)."""
    out = []
    for path in sorted((app / "lib/features").rglob("*.dart")) + [app / "lib/app/search_service.dart"]:
        rel = path.relative_to(app).as_posix()
        for i, line in enumerate(path.read_text().splitlines(), 1):
            s = line.strip()
            if s.startswith("//") or not RENDER_SITE.search(line):
                continue
            kind = "forced_en_locale" if "Locale('en')" in line else "en_fallback"
            out.append({"file": rel, "line": i, "kind": kind, "code": _clip(s, 120)})
    return out


# --------------------------------------------------------------------------
# O‘quv testi auditi (StudyCatalogBuilder’ning Python nusxasi, faqat o‘qish)
# --------------------------------------------------------------------------
_TOPIC_FIELDS = ["definition", "principle", "use", "marker"]
_BAD_STATUS = {"REJECTED", "OUTDATED"}
_BAD_LIFECYCLE = {"OUTDATED", "SUPERSEDED", "RETRACTED", "REJECTED"}
_AREA_DISC = {
    "forensicMedicine": "forensicMedicine", "toxicology": "forensicToxicology",
    "biochemistry": "forensicBiochemistry", "histology": "forensicHistology",
    "laboratory": "analyticalScience", "methods": "analyticalScience",
    "reagents": "forensicChemistry", "screening": "forensicChemistry",
    "emergingIssues": "forensicToxicology",
}
_FM_DISC = {
    "anthropology": "forensicAnthropology", "ageEstimation": "forensicAnthropology",
    "sexEstimation": "forensicAnthropology", "statureEstimation": "forensicAnthropology",
    "odontology": "forensicOdontology", "disasterVictimIdentification": "humanIdentification",
    "histology": "forensicHistology", "postmortemImaging": "forensicRadiology",
    "deathInvestigation": "forensicPathology", "causeMechanismManner": "forensicPathology",
}


def quiz_audit(app: Path) -> dict:
    db = sqlite3.connect(str(app / "assets/content/pilot/content.db"))
    db.row_factory = sqlite3.Row
    retracted = {r[0] for r in db.execute("SELECT source_id FROM source_provenance WHERE lifecycle <> 'current'")}
    cites = collections.defaultdict(list)
    for r in db.execute("SELECT claim_id, source_id, locator FROM citations"):
        if r["source_id"] not in retracted:
            cites[r["claim_id"]].append((r["source_id"], r["locator"]))
    life = {r[0]: r[1] for r in db.execute("SELECT claim_id, lifecycle FROM claim_lifecycle")}
    tr = {(r[0], r[1]) for r in db.execute("SELECT target_id, lang FROM text_translations WHERE target_type='claim_excerpt'")}
    claims = collections.defaultdict(list)
    for r in db.execute("SELECT claim_id, entity_id, field, value_json, review_status FROM claims ORDER BY claim_id"):
        claims[r["entity_id"]].append(r)

    def usable(c):
        return (c["review_status"] not in _BAD_STATUS and life.get(c["claim_id"], "CURRENT") not in _BAD_LIFECYCLE
                and cites.get(c["claim_id"]))

    items = []
    # 1. Bilim yozuvlari: asl jumla → nom.
    for r in db.execute("SELECT entity_id, area, names_json, payload_json, review_status, tier_access FROM knowledge_entities ORDER BY entity_id"):
        if r["review_status"] in _BAD_STATUS:
            continue
        p = json.loads(r["payload_json"])
        claim = None
        for f in _TOPIC_FIELDS:
            for c in claims.get(r["entity_id"], []):
                v = json.loads(c["value_json"])
                if c["field"] == f and (v.get("excerpt") or "").strip() and usable(c):
                    claim = (c, v)
                    break
            if claim:
                break
        if not claim:
            continue
        disc = p.get("discipline")
        disc = ({"forensic_toxicology": "forensicToxicology"}.get(disc, disc) if disc else
                _FM_DISC.get(p.get("forensic_medicine_topic"), "forensicMedicine") if p.get("forensic_medicine_topic") else
                _AREA_DISC.get(r["area"], r["area"]))
        c, v = claim
        items.append({
            "id": f"topic.{r['entity_id']}", "kind": "topicExcerpt", "deck": f"discipline.{disc}",
            "access": r["tier_access"], "stem_lang": "en (asl iqtibos)",
            "stem": _clip(v["excerpt"], 140), "claim_id": c["claim_id"],
            "uz_translation_in_pack": (c["claim_id"], "uz") in tr, "ru_translation_in_pack": (c["claim_id"], "ru") in tr,
            "sources": len(cites[c["claim_id"]]), "has_locator": any(l for _, l in cites[c["claim_id"]]),
            "has_pages": False, "authored_distractors": False, "explanation": False,
        })
    # 2. Moddalar: nom → formula.
    for r in db.execute("SELECT s.substance_id, s.substance_group, s.tier_access, s.review_status FROM substances s ORDER BY s.substance_id"):
        c = next((c for c in claims.get(r["substance_id"], []) if c["field"] == "identity"), None)
        if not c or not usable(c) or not json.loads(c["value_json"]).get("molecular_formula"):
            continue
        items.append({
            "id": f"substance.{r['substance_id']}", "kind": "substanceFormula", "deck": f"group.{r['substance_group'] or 'other'}",
            "access": r["tier_access"], "stem_lang": "ui", "stem": r["substance_id"], "claim_id": c["claim_id"],
            "sources": len(cites[c["claim_id"]]), "has_locator": any(l for _, l in cites[c["claim_id"]]),
            "has_pages": False, "authored_distractors": False, "explanation": False,
        })
    db.close()
    # 3–4. Yo‘riqnomalar: mazmun → sarlavha; biriktirilgan savollar.
    g = json.loads((app / "assets/content/guidelines/guidelines_v1.json").read_text())
    refs = {r["key"]: r for r in g["references"]}
    for card in g["cards"]:
        if card.get("status") in _BAD_STATUS or not card.get("reference_keys"):
            continue
        area = card["id"].split(".")[1]
        items.append({
            "id": f"guideline.{card['id']}", "kind": "guidelineSummary", "deck": f"guideline.{area}",
            "access": "free", "stem_lang": "ui", "stem": _clip(card["summary"].get("uz", ""), 140),
            "translation_status": card.get("translation_status"),
            "sources": len(card["reference_keys"]), "has_locator": False, "has_pages": False,
            "authored_distractors": False, "explanation": False,
        })
        teaching = [k for k in card["reference_keys"] if refs.get(k, {}).get("type") == "teaching_material"]
        for q in card.get("quiz", []) or []:
            if not q.get("d"):
                continue
            items.append({
                "id": f"gq.{card['id']}.{q['id']}", "kind": "guidelineQuestion",
                "deck": f"teaching.{'gmt' if any(k.startswith('gmt_') for k in teaching) else 'toks'}" if teaching else f"guideline.{area}",
                "access": "free", "stem_lang": "ui", "stem": _clip(q["q"].get("uz", ""), 140),
                "translation_status": card.get("translation_status"),
                "sources": len(q.get("cite") or teaching or card["reference_keys"]),
                "cite_explicit": bool(q.get("cite")), "has_locator": bool(q.get("pages")),
                "has_pages": bool(q.get("pages")), "pages": q.get("pages"),
                "authored_distractors": True, "distractor_count": min(len(q["d"].get(l, [])) for l in LANGS),
                "explanation": bool(q.get("explanation") or q.get("e")),
            })
    # Distraktor manbai: avtomatik turlarda bir xil to‘plamdagi boshqa yozuvlar
    # yetmasa, boshqa fan/guruhdan olinadi (mavzuga aloqasiz bo‘lishi aniq).
    by_deck_kind = collections.Counter((i["deck"], i["kind"]) for i in items)
    by_kind = collections.Counter(i["kind"] for i in items)
    for i in items:
        if i["authored_distractors"]:
            i["distractor_origin"] = "authored"
            i["cross_deck_distractors"] = 0
        else:
            same = by_deck_kind[(i["deck"], i["kind"])] - 1
            i["cross_deck_distractors"] = max(0, min(3, by_kind[i["kind"]] - 1) - same)
            i["distractor_origin"] = "other_entries_same_deck" if i["cross_deck_distractors"] == 0 else "other_entries_cross_deck"
        # Baholanadigan imtihon mezoni: muallif distraktorlari + aniq manba (+sahifa) + izoh.
        i["graded_ready"] = bool(i["authored_distractors"] and i["has_pages"] and i["explanation"])
        i["graded_after_explanation"] = bool(i["authored_distractors"] and (i["has_pages"] or i.get("cite_explicit")))
        i["mode_proposal"] = ("graded" if i["graded_ready"] else
                              "graded_after_explanation" if i["graded_after_explanation"] else "practice_only")
    summary = {
        "items_total": len(items),
        "by_kind": dict(by_kind),
        "auto_distractors_from_other_entries": sum(1 for i in items if not i["authored_distractors"]),
        "cross_deck_distractors_items": sum(1 for i in items if i["cross_deck_distractors"] > 0),
        "authored_distractors": sum(1 for i in items if i["authored_distractors"]),
        "english_quote_stem": sum(1 for i in items if i["kind"] == "topicExcerpt"),
        "english_quote_stem_with_uz_translation_unused": sum(1 for i in items if i["kind"] == "topicExcerpt" and i["uz_translation_in_pack"]),
        "without_page": sum(1 for i in items if not i["has_pages"]),
        "without_any_locator": sum(1 for i in items if not i["has_locator"]),
        "with_page": sum(1 for i in items if i["has_pages"]),
        "with_explanation": sum(1 for i in items if i["explanation"]),
        "mode_proposal": dict(collections.Counter(i["mode_proposal"] for i in items)),
        # «1 tadan 1-savol»: to‘plamda 1–3 ta kartochka bo‘lsa test juda qisqa.
        "decks": {d: n for d, n in sorted(collections.Counter(i["deck"] for i in items).items())},
        "decks_with_1_item": sorted(d for d, n in collections.Counter(i["deck"] for i in items).items() if n == 1),
        "decks_with_lt_4_items": sorted(d for d, n in collections.Counter(i["deck"] for i in items).items() if n < 4),
    }
    return {"summary": summary, "items": items}


# --------------------------------------------------------------------------
# Hisobot
# --------------------------------------------------------------------------
def coverage(units: list[Unit]) -> dict:
    """Bo‘lim × toifa × til → holat sanog‘i."""
    cov = collections.defaultdict(lambda: collections.defaultdict(collections.Counter))
    for u in units:
        for l in LANGS:
            st = u.status.get(l) or ("present" if u.values.get(l) else "missing")
            if not u.values.get(l) and not st.startswith(("missing", "n/a")):
                st = "missing"
            cov[u.section][f"{u.category}:{l}"][st] += 1
    return {s: {k: dict(v) for k, v in sorted(d.items())} for s, d in sorted(cov.items())}


def translation_layer(units: list[Unit]) -> dict:
    """Manba/jadval + maydon guruhi + toifa → til → holat sanog‘i."""
    agg = collections.defaultdict(lambda: {l: collections.Counter() for l in LANGS})
    for u in units:
        fld = re.sub(r"\[\d+\]", "[]", u.field)
        fld = re.sub(r"^sections\.\w+\.", "sections.*.", fld)
        fld = re.sub(r"^prepare\.\w+", "prepare.*", fld)
        fld = re.sub(r" \(.*\)$", "", fld)
        key = f"{u.source}:{u.container.split('#')[-1].split('/')[-1]}:{fld}:{u.category}"
        for l in LANGS:
            st = u.status.get(l) or ("present" if u.values.get(l) else "missing")
            if not u.values.get(l) and not st.startswith("missing") and not st.startswith("n/a"):
                st = "missing"
            agg[key][l][st] += 1
    return {k: {l: dict(sorted(c.items())) for l, c in v.items()} for k, v in sorted(agg.items())}


def apply_localized_asset(app: Path, units: list[Unit]) -> int:
    """`assets/content/translations/localized_texts.json` qatlamini hisobga olish.

    Paket sxemasi (v7) ayrim maydonlar uchun uch tilli ustunga ega emas, shuning
    uchun ularning tarjimasi yon fayl orqali keladi va ilova shu faylni o‘qiydi
    (docs/L10N_DATA_CONTRACT_D.md). Audit ham xuddi shu manbani ko‘rishi kerak,
    aks holda ekranda tarjima bo‘la turib «MISSING_TRANSLATION» chiqadi.
    Moslash kaliti — asl matnning sha256 xeshi (barqaror, ID sxemasiga bog‘liq emas).
    """
    path = app / "assets/content/translations/localized_texts.json"
    if not path.exists():
        return 0
    records = json.loads(path.read_text(encoding="utf-8")).get("records", [])
    by_sha = {r["source_sha256"]: r for r in records if r.get("source_sha256")}
    applied = 0
    for u in units:
        if u.source != "content.db" or u.category not in CHECKED_CATEGORIES:
            continue
        # Asl matn qaysi tilda saqlangani maydonga qarab farq qiladi (ingliz
        # iqtibos, o‘zbekcha tahririy izoh…), shuning uchun mavjud qiymatlarning
        # har biri bo‘yicha qidiriladi.
        candidates = [u.values.get(u.original_lang or "en")] + [u.values.get(l) for l in LANGS]
        rec = None
        for src in candidates:
            src = (src or "").strip()
            if not src:
                continue
            rec = by_sha.get(hashlib.sha256(src.encode()).hexdigest())
            if rec is not None:
                break
        if rec is None:
            continue
        # Yon faylda asl matnning tili aniq yozilgan — avtomatik taxminni
        # (`_guess_lang`) shu bilan to‘g‘rilaymiz.
        sl = rec.get("source_lang")
        if sl in LANGS and (u.values.get(sl) or "").strip() != src:
            for lang in LANGS:
                if (u.values.get(lang) or "").strip() == src and lang != sl:
                    u.values[lang] = None
                    u.status[lang] = "missing"
            u.values[sl] = src
            u.status[sl] = "authored"
            u.original_lang = sl
        hit = False
        for lang in LANGS:
            if u.values.get(lang):
                continue
            text = (rec.get("text") or {}).get(lang)
            if not text:
                continue
            u.values[lang] = text
            u.status[lang] = rec.get("status", "machine_draft")
            hit = True
        applied += 1 if hit else 0
    return applied


def build_report(app: Path) -> dict:
    units = load_arb(app)
    db_units, meta = load_content_db(app)
    units += db_units + load_guidelines(app) + load_court(app) + load_dart(app)
    apply_localized_asset(app, units)
    findings = detect(units)
    findings.sort(key=lambda f: ({"error": 0, "warn": 1, "info": 2}[f.severity], f.unit.source, f.unit.container, f.unit.id, f.unit.field, f.lang, f.rule))
    totals = collections.Counter((f.lang, f.severity) for f in findings)
    by_rule = collections.Counter((f.rule, f.lang) for f in findings)
    by_section = collections.defaultdict(collections.Counter)
    for f in findings:
        by_section[f.unit.section][f"{f.lang}:{f.severity}"] += 1
    by_source = collections.defaultdict(collections.Counter)
    for f in findings:
        by_source[f"{f.unit.source}:{f.unit.container.split('#')[-1]}"][f"{f.lang}:{f.severity}"] += 1
    cats = collections.Counter((u.category, u.source) for u in units)
    digest = hashlib.sha256("\n".join(json.dumps(f.to_json(), sort_keys=True, ensure_ascii=False) for f in findings).encode()).hexdigest()
    return {
        "tool": "apps/mobile/tool/lang_audit.py",
        "pack": {k: meta.get(k) for k in ("pack_version", "schema_version", "bundle_format")},
        "units_total": len(units),
        "units_by_category_source": {f"{c}:{s}": n for (c, s), n in sorted(cats.items())},
        "totals": {f"{l}:{s}": n for (l, s), n in sorted(totals.items())},
        "by_rule": {f"{r}:{l}": n for (r, l), n in sorted(by_rule.items())},
        "by_section": {s: dict(sorted(c.items())) for s, c in sorted(by_section.items())},
        "by_source": {s: dict(sorted(c.items())) for s, c in sorted(by_source.items())},
        "coverage": coverage(units),
        "translation_layer": translation_layer(units),
        "render_sites": load_render_sites(app),
        "quiz_audit": quiz_audit(app),
        "terminology_uz": terminology_audit(units),
        "findings_sha256": digest,
        "findings": [f.to_json() for f in findings],
    }


def write_markdown(rep: dict, path: Path, limit: int = 400) -> None:
    L = []
    L.append("# Til auditi — aralash-til detektori natijasi\n")
    L.append(f"Paket: `{rep['pack']}` · birliklar: **{rep['units_total']}** · findings sha256 `{rep['findings_sha256'][:16]}`\n")
    L.append("## Jami (til × daraja)\n")
    L.append("| til | error | warn | info |\n|---|---:|---:|---:|")
    for l in LANGS:
        L.append(f"| {l} | {rep['totals'].get(l + ':error', 0)} | {rep['totals'].get(l + ':warn', 0)} | {rep['totals'].get(l + ':info', 0)} |")
    L.append("\n## Qoida bo‘yicha\n")
    L.append("| qoida:til | soni |\n|---|---:|")
    for k, n in sorted(rep["by_rule"].items(), key=lambda x: -x[1]):
        L.append(f"| {k} | {n} |")
    L.append("\n## Bo‘lim bo‘yicha (error/warn)\n")
    L.append("| bo‘lim | uz err | uz warn | ru err | ru warn | en err | en warn |\n|---|---:|---:|---:|---:|---:|---:|")
    for s, title in SECTIONS.items():
        c = rep["by_section"].get(s, {})
        L.append(f"| {s} {title} | " + " | ".join(str(c.get(f"{l}:{v}", 0)) for l in LANGS for v in ("error", "warn")) + " |")
    L.append("\n## Manba bo‘yicha (error/warn)\n")
    L.append("| manba | uz err | uz warn | ru err | ru warn | en err | en warn |\n|---|---:|---:|---:|---:|---:|---:|")
    for s, c in rep["by_source"].items():
        L.append(f"| {s} | " + " | ".join(str(c.get(f"{l}:{v}", 0)) for l in LANGS for v in ("error", "warn")) + " |")
    L.append("\n## Tarjima qatlami (manba:maydon:toifa → til → holat)\n")
    L.append("| manba:maydon:toifa | uz | ru | en |\n|---|---|---|---|")
    for k, v in rep["translation_layer"].items():
        L.append(f"| `{k}` | " + " | ".join(", ".join(f"{a}={b}" for a, b in v[l].items()) for l in LANGS) + " |")
    L.append("\n## Faqat inglizcha chizadigan joylar (render sites)\n")
    L.append("| fayl:qator | tur | kod |\n|---|---|---|")
    for s in rep["render_sites"]:
        L.append(f"| `{s['file']}:{s['line']}` | {s['kind']} | `{s['code'].replace('|', '/')}` |")
    qa = rep["quiz_audit"]["summary"]
    L.append("\n## O‘quv testi auditi (qisqa)\n")
    L.append("```json\n" + json.dumps(qa, ensure_ascii=False, indent=1) + "\n```")
    L.append("\n## Terminologiya (uz): kanonik shakl va uchraydigan variantlar\n")
    L.append("| termin | kanonik (egasi) | variantlar (soni) |\n|---|---|---|")
    for k, t in rep["terminology_uz"].items():
        L.append(f"| {k} | {t['canonical_uz']} | " + "; ".join(f"`{a}`={b}" for a, b in t["variants"].items()) + " |")
    L.append("\n## Qamrov (bo‘lim → toifa:til → holat)\n")
    L.append("| bo‘lim | toifa:til | holatlar |\n|---|---|---|")
    for s, d in rep["coverage"].items():
        for k, v in d.items():
            L.append(f"| {s} | {k} | " + ", ".join(f"{a}={b}" for a, b in sorted(v.items())) + " |")
    L.append(f"\n## Topilmalar (birinchi {limit}; to‘liq ro‘yxat — JSON)\n")
    L.append("| # | daraja | qoida | til | manba | jadval/fayl | ID | maydon | toifa | parcha | izoh |\n|---:|---|---|---|---|---|---|---|---|---|---|")
    for i, f in enumerate(rep["findings"][:limit], 1):
        ex = f["excerpt"].replace("|", "\\|")
        L.append(f"| {i} | {f['severity']} | {f['rule']} | {f['lang']} | {f['source']} | `{f['container'].split('#')[-1]}` | `{f['id']}` | {f['field']} | {f['category']} | {ex} | {f['detail'].replace('|', '/')} |")
    path.write_text("\n".join(L) + "\n")


# --------------------------------------------------------------------------
# Birlik sinovlari (--self-test)
# --------------------------------------------------------------------------
def self_test() -> int:
    cases = [
        ("Qonda etanolni aniqlash", "uz", []),
        ("Bug‘ fazali (headspace) gaz xromatografiyasi", "uz", []),
        ("For example, basic lipophilic drugs with a volume of distribution", "uz", ["ENGLISH_IN_UZ"]),
        ("not specified in source", "uz", ["ENGLISH_IN_UZ"]),
        ("Определение этанола в крови", "uz", ["CYRILLIC_IN_UZ"]),
        ("Asl matnda «Вагиера» deb yozilgan", "uz", ["CYRILLIC_QUOTED_IN_UZ"]),
        ("Rigor mortis — murda qotishi", "uz", []),
        ("HS-GC-FID va GC-MS bilan tasdiqlash", "uz", []),
        ("{total} tadan {current}-savol", "uz", ["UZ_AWKWARD_COUNTER"]),
        ("Анализ крови методом GC-MS", "ru", []),
        ("Analysis of the blood samples", "ru", ["ENGLISH_IN_RU"]),
        ("Kirish va ro‘yxatdan o‘tish", "en", ["UZBEK_IN_EN"]),
        ("Ethanol in blood", "en", []),
        ("Кровь", "en", ["CYRILLIC_IN_EN"]),
        ("Smith J, Jones AW: Widmark formula", "uz", []),
    ]
    bad = 0
    for text, lang, want in cases:
        got = sorted({r for _, r, _ in check_text(text, lang)})
        if got != sorted(want):
            bad += 1
            print(f"FAIL [{lang}] {text!r}: got {got}, want {want}")
    # D toifa: asl iqtibos tekshirilmaydi, tarjimasi tekshiriladi.
    u = Unit("t", "t", "x", "excerpt", "D", "08_toxicology",
             {"en": "Blood is the specimen of choice.", "uz": "Qon — tanlov namunasi.", "ru": "Кровь — образец выбора."},
             original_lang="en")
    if detect([u]):
        bad += 1
        print("FAIL: D original flagged")
    u.values["uz"] = "Blood is the specimen of choice."
    if not any(f.rule == "ENGLISH_IN_UZ_TRANSLATION" for f in detect([u])):
        bad += 1
        print("FAIL: D translation not checked")
    e = Unit("t", "t", "y", "title", "E", "04_research", {"en": "Ethanol Forensic Toxicology", "uz": None, "ru": None}, original_lang="en")
    if detect([e]):
        bad += 1
        print("FAIL: E flagged")
    print(f"self-test: {len(cases) + 3 - bad}/{len(cases) + 3} OK")
    return 1 if bad else 0


# Terminologiya: egasi tasdiqlagan kanonik o‘zbekcha shakl va uchraydigan
# variantlar (uz matnlarida). Maqsad (Phase F): bitta shakl + glossariy havola.
TERMS_UZ = {
    "PMI": ("O‘limdan keyin o‘tgan vaqt oralig‘i (PMI)",
            r"o‘limdan keyin(?:gi)? o‘tgan (?:vaqt|muddat)(?: oralig‘i)?|o‘lim vaqti|post-?mortal interval|\bPMI\b"),
    "PMR": ("O‘limdan keyingi qayta taqsimlanish (PMR)",
            r"o‘limdan keyingi (?:qayta )?(?:taqsimlan|tarqal)\w*|post-?mortal (?:qayta )?taqsim\w*|\bPMR\b"),
    "LC-MS/MS": ("Suyuqlik xromatografiyasi — tandem mass-spektrometriya (LC-MS/MS)",
                 r"suyuqlik xromatografiyasi\s*[–—-]\s*(?:tandem )?mass-spektrometriya|\bLC[–-]MS(?:/MS|[–-]MS)?\b|\bSX[–-]MS\w*|\bYuSSX\w*|\bUPLC[–-]MS(?:/MS)?\b"),
    "GC-MS": ("Gaz xromatografiyasi — mass-spektrometriya (GC-MS)",
              r"gaz xromatografiyasi\s*[–—/-]\s*mass-spektrometriya|\bGC[–-]MS\b|\bGX[–-]MS\b|xromato-mass-spektrometriya"),
    "COHb": ("Karboksigemoglobin (COHb)", r"karboksigemoglobin\w*|\bCOHb\b|\bHbCO\b"),
    "Vd": ("Taqsimlanish hajmi (Vd)", r"taqsimlanish hajmi\w*|\bVd\b"),
    "Rf": ("Rf (ushlanish omili)", r"\bRf\b|\bR_f\b|ushlanish omili|harakatchanlik koeffitsienti"),
}


def terminology_audit(units: list[Unit]) -> dict:
    out = {}
    for key, (canon, pat) in TERMS_UZ.items():
        variants = collections.Counter()
        where = collections.defaultdict(collections.Counter)
        for u in units:
            v = u.values.get("uz")
            if not v or u.category in ("E", "G"):
                continue
            for m in re.finditer(pat, str(v), flags=re.I):
                form = re.sub(r"[–—]", "-", m.group(0)).strip()
                form = form if re.search(r"[A-Z]", form) and len(form) <= 12 else form.lower()
                variants[form] += 1
                where[form][u.source] += 1
        out[key] = {"canonical_uz": canon, "variants": dict(variants.most_common()),
                    "variant_count": len(variants),
                    "by_source": {k: dict(v) for k, v in sorted(where.items())}}
    return out


def screen_audit(paths: list[str]) -> dict:
    """Real-ilova harness’i yozgan `screen_texts_*.json` (qadam → ekrandagi
    matnlar) bo‘yicha detektor. Ekranda toifa noma’lum — asl iqtibos va
    bibliografiya ham shu yerda ko‘rinadi, shuning uchun natija qo‘lda ko‘rib
    chiqiladi (bu «ekranda foydalanuvchi aslida nimani ko‘radi» o‘lchovi)."""
    out = {}
    for p in paths:
        d = json.loads(Path(p).read_text())
        lang = d["lang"]
        rows = []
        for step, texts in d["steps"].items():
            for t in texts:
                for sev, rule, detail in check_text(t, lang):
                    rows.append({"step": step, "severity": sev, "rule": rule, "text": _clip(t, 140), "detail": detail})
        out[Path(p).name] = {
            "lang": lang,
            "steps": len(d["steps"]),
            "texts": sum(len(v) for v in d["steps"].values()),
            "by_step": dict(collections.Counter(r["step"] for r in rows if r["severity"] != "info")),
            "by_rule": dict(collections.Counter(r["rule"] for r in rows)),
            "findings": rows,
        }
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--app", default=str(Path(__file__).resolve().parent.parent), help="apps/mobile katalogi")
    ap.add_argument("--out", default=None, help="natija katalogi (standart: <app>/build/lang_audit)")
    ap.add_argument("--md-limit", type=int, default=400)
    ap.add_argument("--fail-on", choices=["error", "warn", "never"], default="never")
    ap.add_argument("--self-test", action="store_true")
    ap.add_argument("--screens", nargs="*", default=None,
                    help="real-ilova screen_texts_*.json fayllari (integration_test/qa_l10n_test.dart)")
    a = ap.parse_args()
    if a.self_test:
        return self_test()
    app = Path(a.app)
    out = Path(a.out) if a.out else app / "build/lang_audit"
    out.mkdir(parents=True, exist_ok=True)
    if a.screens is not None:
        sa = screen_audit(a.screens)
        (out / "screen_audit.json").write_text(json.dumps(sa, ensure_ascii=False, indent=1) + "\n")
        for name, r in sa.items():
            print(f"{name}: {r['texts']} matn, {r['steps']} qadam; " + ", ".join(f"{k}={v}" for k, v in sorted(r["by_rule"].items())))
        print(f"→ {out / 'screen_audit.json'}")
        return 0
    rep = build_report(app)
    (out / "lang_audit.json").write_text(json.dumps(rep, ensure_ascii=False, indent=1, sort_keys=False) + "\n")
    write_markdown(rep, out / "lang_audit.md", a.md_limit)
    t = rep["totals"]
    print(f"lang_audit: {rep['units_total']} birlik; " + "; ".join(
        f"{l}: {t.get(l + ':error', 0)} error / {t.get(l + ':warn', 0)} warn / {t.get(l + ':info', 0)} info" for l in LANGS))
    print(f"→ {out / 'lang_audit.json'}\n→ {out / 'lang_audit.md'}")
    if a.fail_on == "error" and any(k.endswith(":error") for k in t):
        return 1
    if a.fail_on == "warn" and any(k.endswith((":error", ":warn")) for k in t):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
