#!/usr/bin/env python3
"""Ilova egasi to‘plamidagi reaktiv retseptlarini bundle’ga qo‘shadi.

Kirish (commit qilingan):
  pilot/reagents/recipes_01_37.yaml, recipes_38_74.yaml — tuzilgan retseptlar
      (ingrediyent, qadam uz/ru/en, saqlash, izohlar). Raqamlar manbadan.
  pilot/reagents/chemicals.json        — ingrediyent nomlari (uz/ru/en)
  pilot/reagents/original_ru.json      — har bandning asl ruscha matni
  pilot/reagents/pubchem_ghs.generated.json — fetch_ghs.py (PubChem GHS)
  pilot/reagents/h_statements_i18n.json     — H-bayonotlar uz/ru (machine_draft)
  pilot/reagents/general_safety.json        — umumiy ehtiyot izohlari (tahririy)

Chiqish: pilot/bundle.json ichida `sources` va `recipes` yangilanadi.

Qoidalar:
* Status har doim NEEDS_REVIEW; uz/en matnlar `machine_draft`.
* Raqamlar o‘zgartirilmaydi: har bir ingrediyent miqdori va ruscha qadamdagi
  har bir raqam asl matnda borligi tekshiriladi (aks holda — xato).
* Xavf izohlari: PubChem GHS (manba: SRC-PUBCHEM-<CID>) yoki umumiy
  tahririy tavsiya (SRC-FE-EDITORIAL, kind=general). H-kod to‘qilmaydi.
* Idempotent: oldingi qo‘shilganlar olib tashlanib, qayta yig‘iladi.

Ishga tushirish (content/ ichidan): python3 tools/reagents/assemble_reagents.py
"""
import json
import os
import re
import sys

import yaml

HERE = "pilot/reagents"
BUNDLE = "pilot/bundle.json"
OWNER = "SRC-OWNER-REAGENTS"
EDITORIAL = "SRC-FE-EDITORIAL"
PERMISSION = "OWNER-PERMISSION-2026-10-09"
GHS_LOCATOR = "Safety and Hazards › GHS Classification"
GHS_NOTE = ("GHS tasnifi PubChem PUG View orqali avtomatik olingan "
            "(reaktiv retseptlari xavfi uchun; birinchi «GHS Hazard "
            "Statements» yozuvi, ≥50 % xabarnoma).")
LANGS = ("uz", "ru", "en")

OWNER_SOURCE = {
    "source_id": OWNER,
    "source_type": "report",
    "source_class": "secondary",
    "title": "«Приготовление реактивов» — reagent preparation compilation "
             "(toxicological chemistry), 74 entries",
    "organization": "FORENSIC EXPERT ilovasi egasi — shaxsiy to‘plam "
                    "(internet manbalari: xumuk.ru kimyo ensiklopediyasi / "
                    "darslik materiallari)",
    "accessed_date": "2026-10-09",
    "tier": "tier3",
    "evidence_level": "C",
    "license_mode": "licenseRequired",
    "license_agreement_id": PERMISSION,
    "identifier_verified": False,
    "language": "ru",
    "notes": "Egasi ruxsati bilan, 2026-10-09. Ilova egasi internet "
             "manbalaridan (xumuk.ru / darslik materiallari) to‘plagan "
             "hujjat; asl fayl repoga kiritilmagan. Raqamlar o‘zgarishsiz; "
             "uz/en tarjimalar machine_draft; ilmiy review kutilmoqda.",
}
EDITORIAL_SOURCE = {
    "source_id": EDITORIAL,
    "source_type": "report",
    "source_class": "other",
    "title": "FORENSIC EXPERT — tahririy izohlar (umumiy xavfsizlik "
             "tavsiyalari, manba noaniqliklari); ilmiy manba emas",
    "organization": "FORENSIC EXPERT",
    "accessed_date": "2026-10-09",
    "tier": "tier3",
    "evidence_level": "E",
    "license_mode": "openReuse",
    "identifier_verified": False,
    "notes": "Ilovaning o‘z izohlari: GHS ma’lumotiga asoslangan umumiy "
             "ehtiyot choralari va asl matndagi OCR/noaniqlik belgilari. "
             "Dalil sifatida ishlatilmaydi (FE017).",
}

SPEC = {
    # token -> (uz, ru, en) shablon; {x} — raqam (lokal ko‘rinishda).
    "%": ("{x} % li eritma", "{x} %-й раствор", "{x} % solution"),
    "pct": ("{x} %", "{x} %", "{x} %"),
    "aq%": ("{x} % li suvli eritma", "{x} %-й водный раствор", "{x} % aqueous solution"),
    "etoh%": ("{x} % li spirtli eritma", "{x} %-й спиртовой раствор", "{x} % ethanolic solution"),
    "acetone%": ("asetondagi {x} % li eritma", "{x} %-й раствор в ацетоне", "{x} % solution in acetone"),
    "ac30%": ("30 % li sirka kislotadagi {x} % li eritma",
              "{x} %-й раствор в 30 %-м растворе уксусной кислоты",
              "{x} % solution in 30 % acetic acid"),
    "N": ("{x} n. eritma", "{x} н. раствор", "{x} N solution"),
    "d": ("zichligi {x}", "пл. {x}", "density {x}"),
    "sat": ("to‘yingan eritma", "насыщенный раствор", "saturated solution"),
}
QTY = {
    "as_needed": ("jarayon bo‘yicha (miqdor ko‘rsatilmagan)", "по ходу приготовления (количество не указано)", "as required (amount not stated)"),
    "small": ("oz miqdor", "небольшое количество", "a small amount"),
    "little": ("ozgina", "немного", "a little"),
    "small_volume": ("oz hajm", "небольшой объём", "a small volume"),
    "dissolve": ("eriguncha", "до растворения", "until dissolved"),
    "double_vol": ("ikki baravar hajm", "двойной объём", "twice the volume"),
    "equal_vol": ("teng hajm", "равный объём", "equal volume"),
    "dropwise_clear": ("tiniq (yoki biroz opalestsensiyalanuvchi) eritma hosil bo‘lguncha tomchilab", "по каплям до прозрачного или слегка опалесцирующего раствора", "dropwise until clear or slightly opalescent"),
    "dropwise_dissolve": ("cho‘kma eriguncha tomchilab", "по каплям до растворения осадка", "dropwise until the precipitate dissolves"),
    "dropwise_dissolve_white": ("oq cho‘kma eriguncha tomchilab", "по каплям до растворения белого осадка", "dropwise until the white precipitate dissolves"),
    "until_ppt_dissolves": ("cho‘kma eriguncha", "до растворения осадка", "until the precipitate dissolves"),
    "until_persistent_ppt": ("turg‘un cho‘kma paydo bo‘lguncha", "до появления устойчивого осадка", "until a persistent precipitate appears"),
    "until_decolourised": ("rangsizlanguncha", "до обесцвечивания", "until decolourised"),
    "sat_gas": ("to‘yinguncha (gaz o‘tkaziladi)", "до насыщения (пропускают газ)", "until saturated (gas passed through)"),
    "stream": ("gaz oqimi", "ток газа", "gas stream"),
    "stream_15_20": ("15–20 daqiqa gaz oqimi", "ток газа 15–20 мин", "gas stream for 15–20 min"),
    "so2_generation": ("SO₂ olish uchun (maxsus apparatda)", "для получения SO₂ (в специальном аппарате)", "for generating SO₂ (in a special apparatus)"),
    "dilute_5_10": ("5–10 marta suyultirish uchun", "для разбавления в 5–10 раз", "for 5–10-fold dilution"),
    "several_drops": ("bir necha tomchi", "несколько капель", "a few drops"),
    "drops_5_8_per_10": ("har 10 ml eritmaga 5–8 tomchi", "5–8 капель на каждые 10 мл раствора", "5–8 drops per 10 mL of solution"),
    "few_crystals": ("bir necha kristall", "несколько кристаллов", "a few crystals"),
    "layer05": ("0,5 sm qalinlikdagi qatlam", "слой толщиной 0,5 см", "a 0.5 cm layer"),
    "per_portion_repeat": ("har bir ulush; takroriy", "на каждую порцию; повторно", "per portion; repeated"),
    "portions_until_yellow": ("suvli qatlam rangi o‘zgarmas sariq bo‘lguncha ulushlab", "порциями, пока водный слой не станет устойчиво жёлтым", "in portions until the aqueous layer stays yellow"),
    "to_ph34": ("pH 3–4 gacha", "до pH 3–4", "to pH 3–4"),
    "to_05pct": ("cho‘kmadan 0,5 % li eritma olish uchun", "для 0,5 %-го раствора осадка", "to make a 0.5 % solution of the precipitate"),
    "tenfold": ("qoldiqqa nisbatan o‘n baravar", "десятикратное количество", "tenfold amount"),
    "washing": ("yuvish uchun (miqdor ko‘rsatilmagan)", "для промывания (количество не указано)", "for washing (amount not stated)"),
    "not_stated": ("manbada ko‘rsatilmagan", "в источнике не указано", "not stated in the source"),
    "or_next": ("yoki quyidagi", "или следующий", "or the next one"),
}
PICTO = {
    "Explosive": ("Portlovchi", "Взрывчатое", "Explosive"),
    "Flammable": ("Alangalanuvchi", "Огнеопасно", "Flammable"),
    "Oxidizer": ("Oksidlovchi", "Окислитель", "Oxidizer"),
    "Compressed Gas": ("Bosim ostidagi gaz", "Газ под давлением", "Compressed gas"),
    "Corrosive": ("Yemiruvchi (korroziv)", "Коррозионное", "Corrosive"),
    "Acute Toxic": ("O‘tkir zaharli", "Острая токсичность", "Acute toxic"),
    "Irritant": ("Ta’sirlantiruvchi / zararli", "Раздражающее / вредное", "Irritant / harmful"),
    "Health Hazard": ("Sog‘liq uchun xavfli", "Опасность для здоровья", "Health hazard"),
    "Environmental Hazard": ("Atrof-muhit uchun xavfli", "Опасно для окружающей среды", "Environmental hazard"),
}
PICTO_LABEL = ("GHS piktogrammalari", "Пиктограммы СГС", "GHS pictograms")
PCODE_LABEL = ("Ehtiyot choralari (P-kodlar)", "Меры предосторожности (P-коды)", "Precautionary statements (P-codes)")
SIGNAL = {"Danger": ("Xavfli", "Опасно", "Danger"),
          "Warning": ("Ehtiyot bo‘ling", "Осторожно", "Warning")}


def load_json(name):
    return json.load(open(os.path.join(HERE, name), encoding="utf-8"))


def fmt_num(x, lang):
    s = ("%f" % x).rstrip("0").rstrip(".") if isinstance(x, float) else str(x)
    return s.replace(".", ",") if lang in ("uz", "ru") else s


def tri(t):
    return dict(zip(LANGS, t))


def spec_text(spec):
    if spec is None:
        return None
    if isinstance(spec, dict):
        return spec
    tok, _, val = spec.partition(":")
    tpl = SPEC[tok]
    return {lang: tpl[i].format(x=fmt_num(float(val) if "." in val else int(val), lang)
                                if val else "")
            for i, lang in enumerate(LANGS)}


def qty_text(q):
    if q is None:
        return {}
    if isinstance(q, dict):
        return q
    return tri(QTY[q])


def ingredient(row, chem):
    key, amount, unit = row[0], row[1], row[2]
    opts = row[3] if len(row) > 3 else {}
    c = chem[key]
    spec = spec_text(opts.get("spec"))
    role = opts.get("role")
    names = {}
    for lang in LANGS:
        n = c[lang]
        if spec:
            n = f"{n}, {spec[lang]}"
        if role:
            n = f"{role[lang]}: {n}"
        names[lang] = n
    out = {"name": names["en"], "amount": amount, "unit": unit, "names": names}
    if opts.get("max") is not None:
        out["amount_max"] = opts["max"]
    if opts.get("to"):
        out["make_up_to"] = True
    q = qty_text(opts.get("q"))
    if q:
        out["quantity_note"] = q
    if opts.get("v"):
        out["variant"] = opts["v"]
    return out


def note(d, source_id, kind=None, locator=None):
    texts = {lang: d[lang] for lang in LANGS}
    n = {"text": texts["ru"] if source_id == OWNER else texts["en"],
         "source_id": source_id, "texts": texts}
    if locator:
        n["locator"] = locator
    if kind:
        n["kind"] = kind
    return n


# --- raqamlar nazorati -------------------------------------------------------

NUM_RE = re.compile(r"\d+(?:[.,]\d+)?")


def norm_numbers(text):
    return {m.replace(",", ".").lstrip("0") or "0"
            for m in NUM_RE.findall(text)}


def check_numbers(no, rec, original, errors):
    have = norm_numbers(original)
    # So‘z bilan yozilgan sonlar («в литре», «каплю») va OCR: «Ю мл» = 10
    # (№ 57, bayroq bilan belgilangan).
    for word, n in (("литре", "1"), ("каплю", "1")):
        if word in original:
            have.add(n)
    if no == 57:
        have.add("10")
    for i in rec["ingredients"]:
        for v in (i.get("amount"), i.get("amount_max")):
            if v is None:
                continue
            s = fmt_num(v, "en").lstrip("0") or "0"
            if s not in have:
                errors.append(f"#{no}: amount {v} not in original")
    for s in rec["steps"]:
        for n in norm_numbers(s["texts"]["ru"]) - {"2", "1"} - have:
            # ₂ kabi indekslar va «(1:3)» — asl matnda ham bor; qolgani xato.
            errors.append(f"#{no}: step number {n} not in original")


# --- xavf izohlari ---------------------------------------------------------

# Kimyoviy xavf bahosi talab qilinmaydigan narsalar (suv, filtr qog‘oz…).
NON_HAZARD_ITEMS = {"water", "water_dist", "water_boiled", "water_hot",
                    "water_boiling", "water_cold", "filter_paper",
                    "filter_paper_pieces", "cotton", "solution_a", "solution_b"}
UNVERIFIED_HEAD = {
    "uz": "Xavflilik ma’lumotlari to‘liq tekshirilmagan: ",
    "ru": "Данные об опасности не проверены полностью: ",
    "en": "Hazard data not fully verified: ",
}
UNVERIFIED_TAIL = {
    "uz": ". PubChem’da GHS tasnifi topilmadi — bu modda xavfsiz degani emas; "
          "ishlatishdan oldin yetkazib beruvchining SDS’ini tekshiring.",
    "ru": ". В PubChem классификация GHS не найдена — это не значит, что "
          "вещество безопасно; перед работой сверьтесь с SDS поставщика.",
    "en": ". No GHS classification was found in PubChem — this does not mean "
          "the substance is safe; check the supplier's SDS before use.",
}


def hazard_notes(entry, ingredient_keys, chem, ghs, hcodes, general, used_src):
    notes = []
    for g in entry.get("general_hazards", []):
        notes.append(note(general[g], EDITORIAL, kind="general"))
    if entry.get("restricted"):
        notes.append(note(general["restricted_" + entry["restricted"]],
                          EDITORIAL, kind="general"))
    keys = list(dict.fromkeys(list(ingredient_keys)
                              + list(entry.get("extra_hazards", []))))
    for gname, members in general["_groups"].items():
        if any(k in members for k in keys):
            notes.append(note(general[gname], EDITORIAL, kind="general"))
    seen_cid = set()
    ghs_notes = []
    for k in keys:
        c = chem[k]
        q = c.get("pubchem")
        if not q or q not in ghs["compounds"]:
            continue
        g = ghs["compounds"][q]
        if g["cid"] in seen_cid:
            continue
        seen_cid.add(g["cid"])
        label = c.get("ghs_label") or {lang: c[lang] for lang in LANGS}
        sig = SIGNAL.get(g.get("signal") or "", None)
        texts = {}
        for i, lang in enumerate(LANGS):
            parts = []
            for st in g["statements"]:
                code = st["code"]
                if lang == "en":
                    t = st["text"]
                else:
                    t = "; ".join(hcodes[cc][lang] for cc in code.split("+"))
                parts.append(f"{code}: {t}")
            head = f"{label[lang][:1].upper()}{label[lang][1:]} (PubChem CID {g['cid']})"
            if sig:
                head += f" — {sig[i]}"
            text = f"{head}. " + "; ".join(parts) + "."
            if g.get("pictograms"):
                pics = ", ".join(PICTO[p][i] for p in g["pictograms"])
                text += f" {PICTO_LABEL[i]}: {pics}."
            if g.get("p_codes"):
                text += f" {PCODE_LABEL[i]}: {', '.join(g['p_codes'])}."
            texts[lang] = text
        sid = f"SRC-PUBCHEM-{g['cid']}"
        used_src[sid] = g
        rank = 0 if g.get("signal") == "Danger" else 1
        ghs_notes.append((rank, {"text": texts["en"], "source_id": sid,
                                 "locator": GHS_LOCATOR, "texts": texts,
                                 "kind": "ghs"}))
    # GHS ma’lumoti topilmagan ingrediyentlar — «xavfsiz» deb talqin
    # qilinmasligi uchun ochiq ogohlantirish (egasi talabi, 2026-10-09).
    unverified = []
    for k in keys:
        c = chem.get(k)
        if not c or k in NON_HAZARD_ITEMS:
            continue
        q = c.get("pubchem")
        if q and q in ghs["compounds"] and ghs["compounds"][q].get("statements"):
            continue
        if all(c[lang] != u[lang] for u in unverified for lang in ("en",)):
            unverified.append(c)
    if unverified:
        texts = {lang: UNVERIFIED_HEAD[lang] + ", ".join(u[lang] for u in unverified)
                 + UNVERIFIED_TAIL[lang] for lang in LANGS}
        notes.append({"text": texts["en"], "source_id": EDITORIAL,
                      "texts": texts, "kind": "general"})
    # Yagona umumiy qator: «laboratoriyangiz SDS’ini o‘qing» (tahririy).
    sds = note(general["sds"], EDITORIAL, kind="general")
    return notes + [n for _, n in sorted(ghs_notes, key=lambda x: x[0])] + [sds]


def pubchem_source(cid, g, fetched):
    return {
        "source_id": f"SRC-PUBCHEM-{cid}",
        "source_type": "database",
        "title": f"PubChem Compound Summary for CID {cid} ({g['title']})",
        "organization": "National Center for Biotechnology Information "
                        "(NCBI), U.S. National Library of Medicine",
        "official_url": f"https://pubchem.ncbi.nlm.nih.gov/compound/{cid}",
        "accessed_date": fetched,
        "tier": "tier2",
        "evidence_level": "C",
        "license_mode": "openReuse",
        "identifier_verified": True,
        "notes": GHS_NOTE + (
            " Olish yo‘li: relay (pubchem_ghs_relay.txt — to‘g‘ridan-to‘g‘ri "
            "so‘rov HTTP 429 bilan cheklangan)." if g.get("retrieved_via") == "relay"
            else ""),
    }


def build(entry, chem, original, ghs, hcodes, general, used_src, errors):
    no = entry["num"]
    loc = f"№ {no}"
    ings = [ingredient(r, chem) for r in entry["ing"]]
    variants = [{"variant_id": v["id"],
                 "labels": {lang: v[lang] for lang in LANGS},
                 "source_id": OWNER} for v in entry.get("variants", [])]
    steps, counters = [], {}
    for s in entry["steps"]:
        v = s.get("v")
        counters[v] = counters.get(v, 0) + 1
        st = {"text": s["en"], "order": counters[v],
              "texts": {lang: s[lang] for lang in LANGS}}
        if v:
            st["variant"] = v
        steps.append(st)
    hz = hazard_notes(entry, [r[0] for r in entry["ing"]], chem, ghs, hcodes,
                      general, used_src)
    notes = [note(n, OWNER, kind=n.get("kind", "info"), locator=loc)
             for n in entry.get("notes", [])]
    notes += [note(n, EDITORIAL, kind=n.get("kind", "ambiguity"), locator=loc)
              for n in entry.get("flags", [])]
    pubchem_ids = list(dict.fromkeys(h["source_id"] for h in hz
                                     if h["source_id"].startswith("SRC-PUBCHEM-")))
    rec = {
        "recipe_id": "recipe-" + entry["slug"],
        "reagent_id": entry.get("merge") or "reagent-" + entry["slug"],
        "names": {lang: entry["names"][lang] for lang in LANGS},
        "domain": "lab",
        # Egasi qarori (2026-10-09): egasi to‘plamidagi barcha retseptlar
        # bepul (kontent huquqi: OWNER-PERMISSION-2026-10-09).
        "tier_access": "free",
        "status": "NEEDS_REVIEW",
        "ingredients": ings,
        "steps": steps,
        "order_explicit_in_source": True,
        "hazards": hz,
        "source_ids": [OWNER] + pubchem_ids,
        "synonyms": entry.get("synonyms", []),
        "notes": notes,
        "original_text": original,
        "original_language": "ru",
        "original_source_id": OWNER,
        "translation_status": "machine_draft",
        "version": 1,
    }
    if variants:
        rec["variants"] = variants
    for field in ("storage", "stability"):
        if entry.get(field):
            rec[field] = note(entry[field], OWNER, locator=loc)
    check_numbers(no, rec, original, errors)
    return rec


def merge(base, own):
    """Mavjud (PMC) retsept ustiga egasi retseptini variant sifatida qo‘shadi."""
    # Asl (PMC) qismlar — tilga moslanmagan (names/texts yo‘q); egasi
    # to‘plamidan qo‘shilganlar qayta yig‘ishda tashlanadi (idempotent).
    base_ings = [i for i in base.get("ingredients", []) if not i.get("names")]
    base_steps = [s for s in base.get("steps", []) if not s.get("texts")]
    base_srcs = [s for s in base.get("source_ids", [])
                 if s != OWNER and not s.startswith("SRC-PUBCHEM-")]
    out = dict(own)
    out["recipe_id"] = base["recipe_id"]
    out["reagent_id"] = base["reagent_id"]
    out["tier_access"] = "free"
    out["source_ids"] = [OWNER] + base_srcs + [
        s for s in own["source_ids"] if s.startswith("SRC-PUBCHEM-")]
    if base_ings or base_steps:
        pmc_src = next((s for s in base_srcs if s.startswith("SRC-PMC")), None)
        out["variants"] = [
            {"variant_id": "own", "labels": {
                "uz": "Ilova egasi to‘plami", "ru": "Сборник владельца приложения",
                "en": "App owner's compilation"}, "source_id": OWNER},
            {"variant_id": "pmc", "labels": {
                "uz": "Ilmiy maqoladagi retsept (inglizcha asl iqtibos)",
                "ru": "Рецепт из научной статьи (английская цитата)",
                "en": "Recipe from a research article (verbatim quote)"},
             "source_id": pmc_src},
        ]
        for i in out["ingredients"]:
            i["variant"] = "own"
        for s in out["steps"]:
            s["variant"] = "own"
        out["ingredients"] = out["ingredients"] + [
            dict(i, variant="pmc") for i in base_ings]
        out["steps"] = out["steps"] + [
            {k: v for k, v in dict(s, variant="pmc").items() if k != "order"}
            for s in base_steps]
    return out


def apply(bundle):
    chem = load_json("chemicals.json")["chemicals"]
    original = load_json("original_ru.json")["entries"]
    ghs = (json.load(open(os.environ["FE_GHS_FILE"], encoding="utf-8"))
           if os.environ.get("FE_GHS_FILE")  # faqat sinov uchun
           else load_json("pubchem_ghs.generated.json"))
    hcodes = load_json("h_statements_i18n.json")["statements"]
    general = load_json("general_safety.json")
    entries = []
    for f in ("recipes_01_37.yaml", "recipes_38_74.yaml"):
        entries += yaml.safe_load(open(os.path.join(HERE, f), encoding="utf-8"))
    nums = [e["num"] for e in entries]
    assert sorted(nums) == list(range(1, 75)), "1–74 bandlar to‘liq emas"

    # Idempotentlik: oldingi qo‘shilganlarni olib tashlash.
    bundle["sources"] = [s for s in bundle["sources"]
                         if not s.get("notes", "").startswith(GHS_NOTE[:40])
                         and s["source_id"] not in (OWNER, EDITORIAL)]
    own_ids = {"recipe-" + e["slug"] for e in entries if not e.get("merge")}
    base = {r["reagent_id"]: r for r in bundle["recipes"]}
    bundle["recipes"] = [r for r in bundle["recipes"]
                         if r["recipe_id"] not in own_ids]

    used_src, errors, built = {}, [], []
    for e in sorted(entries, key=lambda x: x["num"]):
        rec = build(e, chem, original[str(e["num"])]["text"], ghs, hcodes,
                    general, used_src, errors)
        if e.get("merge"):
            b = base.get(e["merge"])
            if b is None:
                errors.append(f"#{e['no']}: merge target {e['merge']} missing")
                continue
            merged = merge(b, rec)
            bundle["recipes"] = [merged if r["reagent_id"] == e["merge"] else r
                                 for r in bundle["recipes"]]
        else:
            built.append(rec)
    if errors:
        sys.exit("XATO:\n" + "\n".join(errors))
    bundle["recipes"] += built

    have = {s["source_id"] for s in bundle["sources"]}
    bundle["sources"] += [OWNER_SOURCE, EDITORIAL_SOURCE]
    for sid, g in sorted(used_src.items()):
        if sid not in have:
            bundle["sources"].append(pubchem_source(g["cid"], g, ghs["fetched_at"]))
    return {"recipes_added": len(built), "merged": len(entries) - len(built),
            "pubchem_sources": len(used_src),
            "hazard_notes": sum(len(r["hazards"]) for r in bundle["recipes"])}


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else BUNDLE
    b = json.load(open(path, encoding="utf-8"))
    stats = apply(b)
    json.dump(b, open(path, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
    print(json.dumps(stats, ensure_ascii=False))


if __name__ == "__main__":
    main()
