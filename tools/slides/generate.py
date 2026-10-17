"""Bitta mavzu uchun slayd rejasi + 10 MCQ (faqat berilgan manbalardan)."""
import argparse, json, os, re, sys
from pathlib import Path

from topics import get_topic

MODEL = "claude-sonnet-5-5"
# DIQQAT: narxlar taxminiy. Egasi rasmiy Anthropic narxlar sahifasida tekshirishi SHART.
PRICE_IN_PER_MTOK_USD = 3.00    # TEKSHIRILMAGAN taxmin
PRICE_OUT_PER_MTOK_USD = 15.00  # TEKSHIRILMAGAN taxmin
CHARS_PER_TOKEN = 3.0           # o'zbek lotin uchun konservativ taxmin
MAX_TOKENS = 9000  # bosqich uchun eng katta chegara
TEMPERATURE = 0.2
MAX_SOURCE_CHARS = 150000
TOTAL_SOURCE_CHARS = 330000  # barcha manbalar yig'indisi (kontekst oynasiga sig'ishi uchun)
PENDING = "ADABIYOT KUTILMOQDA"

SYSTEM_PROMPT = """Siz sud-tibbiyot fani o'qituvchisi uchun ma'ruza materiali tayyorlaysiz.
QOIDALAR:
1. Faqat o'zbek tili (lotin). Faqat quyida berilgan MANBA MATNLARIDAN foydalaning.
2. KAMIDA 30 ta slayd (30-40). Mavzuning barcha bo'limlarini qamrang. Slaydlarning kamida 6 tasida "diagram" bo'lsin (o'zingiz chizgan sodda sxema: kind="flow" nodes=[matn...] yoki kind="table" header=[...] rows=[[...]]; jadvalni manbadan o'z so'zingiz bilan qayta tuzing, rasmni ko'chirmang, haqiqiy foto deb ko'rsatmang). Oxirida "extras": 3-5 ta qiziqarli fakt/hodisa tahlili/eslab qolish usuli (manbali). Matn sodda, tushunarli.
USLUB QOIDALARI: har band 220 belgidan oshmasin (1-2 qisqa jumla, kitob jumlasini so'zma-so'z ko'chirma — o'z so'zingiz bilan); slaydda 3-4 band, ~60 so'z; bandlar matni ichiga [muallif, bet] iqtibos YOZMANG (u source maydonida); qisqartmalar (MNT, AUF...) birinchi uchrashganda ochilsin; apostrof o' va g' uchun ‘, boshqa o'rinda ’ ishlating.
DIAGRAMMA: slaydlarning kamida yarmida diagram bo'lsin; diagrammali slaydda band soni 3 tadan oshmasin va har band <=110 belgi (diagramma matnni takrorlamasin); flow <=5 tugun, har tugun <=32 belgi; table <=4 qator (sarlavhadan tashqari), <=3 ustun, katak <=45 belgi, sarlavha <=14 belgi, 4 ustunli jadval YARATMANG; slayd sarlavhasi <=55 belgi; servis maydonlarini (_note va h.k.) yozmang; vaqt chizig'i, solishtirish (A vs B), jarayon zanjiri, hisoblash misoli uchun jadval/flow ishlating; diagram sarlavhasi (caption) qisqa.
TALABANI USHLAB TURISH: har bo'limdan keyin 1 ta "Voqea tahlili" slaydi (manbadagi ma'lumotlardan tuzilgan qisqa vaziyat + savol), har 6-8 slaydda "Tezkor savol" slaydi, "Diqqat: xato qilish xavfi" bandi (manbada bor farqlash: masalan A ≠ B), "Eslab qoling" mnemonikasi (manbada bo'lsa). teacher_notes: vaqt (daq), 1-2 muhokama savoli, doskada chizish topshirig'i, tipik xato. Har slaydning har bir bandi oxirida [muallif, kitob, bet] ko'rsatilsin; manba va bet faqat berilgan ro'yxatdan.
3. Raqam, bet, foiz, sana TO'QIMANG. Manbada bo'lmasa yozmang.
4. Ishonchsiz yoki manbada aniq bo'lmagan bandni "uncertain": true bilan belgilang.
5. 10 ta MCQ: bitta to'g'ri javob, mantiqan yaqin chalg'ituvchi variantlar, tushuntirish, manba+bet.
6. Faqat JSON qaytaring, boshqa matn yo'q. Sxema:
{"topic":str,"slides":[{"title":str,"bullets":[{"text":str,"source":{"author":str,"title":str,"page":str},"uncertain":bool}],"diagram":null|{"kind":"flow"|"table","caption":str,"nodes":[str],"header":[str],"rows":[[str]]},"teacher_notes":str}],
"extras":[{"text":str,"source":{"author":str,"title":str,"page":str}}],
"mcq":[{"question":str,"options":[str,str,str,str],"correct_index":int,"explanation":str,"source":{"author":str,"title":str,"page":str}}]}"""


SYSTEM_PROMPT_EN = """You prepare lecture material in FORENSIC MEDICINE for an English-language international student group.
RULES:
1. Write ONLY in clear academic English with standard international medical/forensic terminology (e.g. post-mortem interval, rigor mortis, livor mortis, ligature strangulation, sudden infant death syndrome). Use ONLY the SOURCE TEXTS given below. The topic title may be given in Uzbek: translate it into a standard English title.
2. SOURCE PRIORITY: if internationally recognised sources (e.g. Simpson's Forensic Medicine, PubMed Central articles) are provided together with Uzbek/Russian textbooks, build the content primarily on the international sources; use the local textbooks only to supplement, and render their content in English. Never copy sentences verbatim: paraphrase in your own words.
3. At least 30 slides (30-40), covering all sections of the topic. At least 6 slides carry a "diagram" (a simple scheme you draw yourself: kind="flow" nodes=[text...] or kind="table" header=[...] rows=[[...]]; re-build tables from the source in your own words; never copy figures or present them as real photographs). At the end "extras": 3-5 interesting facts / case analyses / memory aids (with source). Keep the text simple and clear.
STYLE: each bullet <= 220 characters (1-2 short sentences, own words); 3-4 bullets per slide, ~60 words; do NOT write [author, page] citations inside bullet text (they belong in the source field); spell out abbreviations at first use (PMI = post-mortem interval, SIDS ...); use the normal apostrophe '.
DIAGRAMS: at least half of the slides carry a diagram; on a slide with a diagram use at most 3 bullets, each <= 110 characters (the diagram must not repeat the text); flow <= 5 nodes, each node <= 32 characters; table <= 4 rows (excluding header), <= 3 columns, cell <= 45 characters, header <= 14 characters; NEVER a 4-column table; slide title <= 55 characters; do not write service fields (_note etc.); use a table/flow for timelines, comparisons (A vs B), process chains and calculation examples; keep captions short.
ENGAGEMENT: after each section one "Case analysis" slide (a short scenario built from the source facts + a question); a "Quick question" slide every 6-8 slides; a "Caution: common error" bullet where the source distinguishes similar things (e.g. A is not B); a "Remember" mnemonic where the source supports one. teacher_notes (in English): time (min), 1-2 discussion questions, a whiteboard task, a typical mistake. Every bullet carries a source (author, title, page) taken ONLY from the given list.
CITING PAGES: the source text contains page markers like "[p. 45]" = printed page of the book. Use the number of the marker preceding the passage as "page" (e.g. "45"). If a source has no markers, use the chapter/section given in its header.
3b. NEVER invent numbers, pages, percentages or dates. If it is not in the sources, do not write it.
4. Mark any doubtful bullet or one not clearly stated in the sources with "uncertain": true.
5. 10 MCQs: exactly one correct answer, plausible distractors that are logically close, an explanation, source + page. Options of similar length; correct answer position spread evenly over A/B/C/D.
6. Return JSON only, no other text. Schema:
{"topic":str,"slides":[{"title":str,"bullets":[{"text":str,"source":{"author":str,"title":str,"page":str},"uncertain":bool}],"diagram":null|{"kind":"flow"|"table","caption":str,"nodes":[str],"header":[str],"rows":[[str]]},"teacher_notes":str}],
"extras":[{"text":str,"source":{"author":str,"title":str,"page":str}}],
"mcq":[{"question":str,"options":[str,str,str,str],"correct_index":int,"explanation":str,"source":{"author":str,"title":str,"page":str}}]}"""

PENDING_EN = "LITERATURE PENDING"
TOPIC_EN = "TOPIC (given in Uzbek; translate to a standard English title): "
LANGS = ("uz", "en")
INTL_TITLES = ("simpson", "knight", "dolinak", "dimaio", "payne-james", "saukko", "pubmed", "pmc")


def is_international(src):
    """Xalqaro (inglizcha) manba: sources.json da "lang": "en" yoki ma'lum nomlar."""
    if (src.get("lang") or "").lower() == "en":
        return True
    blob = f"{src.get('author','')} {src.get('title','')}".lower()
    return any(k in blob for k in INTL_TITLES)


def stage_prompts(lang):
    """Bosqich ko'rsatmalari. Mock testlar `BOSQICH`/`STAGE` belgilari bilan ajratadi."""
    if lang == "en":
        return {
            "plan": 'STAGE 1. Return only the plan: {"topic":str,"plan":[{"title":str,"focus":str,"diagram":bool}]}. '
                    '32-36 slides covering the topic sections in order; at least 6 with diagram:true; an introduction first and a conclusion last. '
                    'Titles and "topic" in English.',
            "slides": 'STAGE 2. Write the following {n} slides in full (keep the order), in English: {part}. '
                      'JSON only: {{"slides":[{{"title":str,"bullets":[{{"text":str,"source":{{"author":str,"title":str,"page":str}},"uncertain":bool}}],'
                      '"diagram":null|{{"kind":"flow"|"table","caption":str,"nodes":[str],"header":[str],"rows":[[str]]}},"teacher_notes":str}}]}}. '
                      '3-4 bullets per slide (<=220 characters); if diagram:true fill in the diagram.',
            "mcq": 'STAGE 3.{k}. JSON only: {{"mcq":[5 questions, ONLY on the topics of these slides: {titles}; '
                   'at least 3 are scenario (application) questions; ask only ONE thing per question; options of equal length; correct answer position spread evenly over A/B/C/D; '
                   'each: {{"question","options":[4],"correct_index","explanation","source":{{"author","title","page"}}}}]}}',
            "extras": 'STAGE 3.9. JSON only: {"extras":[3-5 interesting facts / case analyses / memory aids, with source: {"text","source":{"author","title","page"}}]}',
        }
    return None


def est_tokens(text):
    return int(len(text) / CHARS_PER_TOKEN) + 1


def est_cost(in_tok, out_tok):
    return in_tok / 1e6 * PRICE_IN_PER_MTOK_USD + out_tok / 1e6 * PRICE_OUT_PER_MTOK_USD


def _fit_budget(items, budget=None):
    """Manbalar yig'indisi budjetdan oshsa, har manbaga adolatli ulush (water-filling): kichiklari to'liq, kattalari kesiladi."""
    budget = budget or TOTAL_SOURCE_CHARS
    if sum(len(e["text"]) for e in items) <= budget:
        return items
    remaining, left = budget, sorted(items, key=lambda e: len(e["text"]))
    caps = {}
    for i, e in enumerate(left):
        share = remaining // (len(left) - i)
        caps[id(e)] = min(len(e["text"]), share)
        remaining -= caps[id(e)]
    for e in items:
        e["text"] = e["text"][:caps[id(e)]]
    return items


def load_sources(topic_id, path, lang="uz", intl_only=False):
    p = Path(path)
    if not p.exists():
        return []
    entries = json.loads(p.read_text(encoding="utf-8")).get(topic_id, [])
    out = []
    for e in entries:
        if not (e.get("author") and e.get("title") and e.get("pages")):
            raise ValueError(f"Manba to'liq emas (author+title+pages kerak): {e}")
        lp = e.get("local_text_path")
        if not lp:
            continue  # drive_id: avval matnni yuklab oling (README)
        f = Path(lp)
        if f.exists() and f.read_text(encoding="utf-8").strip():
            out.append({**e, "text": f.read_text(encoding="utf-8")[:MAX_SOURCE_CHARS]})
    _fit_budget(out)
    if lang == "en":
        out.sort(key=lambda e: 0 if is_international(e) else 1)  # xalqaro manba oldinda (barqaror)
        if intl_only and any(is_international(e) for e in out):
            out = [e for e in out if is_international(e)]
    return out


def build_user_prompt(topic, sources, lang="uz"):
    if lang == "en":
        parts = [f"{TOPIC_EN}{topic['title']} ({topic['course']})\n"]
        for i, s in enumerate(sources, 1):
            kind = "INTERNATIONAL" if is_international(s) else "LOCAL (supplementary)"
            parts.append(f"=== SOURCE {i} [{kind}]: {s['author']}, {s['title']}, {s.get('year','')}, pages {s['pages']} ===\n{s['text']}\n")
        return "\n".join(parts)
    parts = [f"MAVZU: {topic['title']} ({topic['course']})\n"]
    for i, s in enumerate(sources, 1):
        parts.append(f"=== MANBA {i}: {s['author']}, {s['title']}, {s.get('year','')}, betlar {s['pages']} ===\n{s['text']}\n")
    return "\n".join(parts)


def _apos(s):
    s = re.sub(r"([oOgG])'", lambda m: m.group(1) + "\u2018", s)
    return s.replace("'", "\u2019")


def clean_text(data, lang="uz"):
    """Iqtibos oqishi, apostrof, begona kalitlar."""
    if lang == "en":
        cite = re.compile(r"\s*\[[^\]]*(pp?\.|Simpson|Payne|Sud tibbiyoti|G.iyosov)[^\]]*\]")
        fixq = lambda t: t  # inglizcha apostrof o'zgarmaydi (Simpson's)
    else:
        cite = re.compile(r"\s*\[[^\]]*(bet|Sud tibbiyoti|G.iyosov)[^\]]*\]")
        fixq = _apos
    def walk(o, key=None):
        if isinstance(o, str):
            o = fixq(cite.sub("", o)) if key in ("text", "title", "caption", "focus", "teacher_notes", "question", "explanation") or key is None else o
            return o
        if isinstance(o, list):
            return [walk(x, key) for x in o]
        if isinstance(o, dict):
            return {k: walk(v, k) for k, v in o.items() if k not in ("}", "]", "") and not str(k).startswith("_") }
        return o
    return walk(data)


def canonicalize_sources(data, sources):
    """Model manbani qisqartirib yozishi mumkin: yagona manba bo'lsa, author/title ni aniq nomga almashtiradi (bet saqlanadi)."""
    def fix(src):
        if not isinstance(src, dict) or not src.get("page"):
            return
        for s in sources:
            a, t = (src.get("author") or "").strip().lower(), (src.get("title") or "").strip().lower()
            sa, st = s["author"].strip().lower(), s["title"].strip().lower()
            if len(sources) == 1 or a in sa or sa in a or t in st or st in t:
                src["author"], src["title"] = s["author"], s["title"]
                return
    for sl in data.get("slides", []):
        for b in sl.get("bullets", []):
            fix(b.get("source"))
    for e in data.get("extras", []) or []:
        fix(e.get("source"))
    for q in data.get("mcq", []):
        fix(q.get("source"))


def _cyrillic_share(text):
    letters = [c for c in text if c.isalpha()]
    return sum("\u0400" <= c <= "\u04ff" for c in letters) / len(letters) if letters else 0.0


def validate_output(data, sources, lang="uz"):
    """Manbasiz band/savol rad etiladi; manba ro'yxatda bo'lishi shart."""
    allowed = {(s["author"].strip().lower(), s["title"].strip().lower()) for s in sources}

    def ok(src):
        return (isinstance(src, dict) and src.get("author") and src.get("title") and src.get("page")
                and (src["author"].strip().lower(), src["title"].strip().lower()) in allowed)

    slides = data.get("slides", [])
    if not 30 <= len(slides) <= 45:
        raise ValueError(f"Slaydlar soni 30-45 bo'lishi kerak, hozir {len(slides)}")
    for i, sl in enumerate(slides, 1):
        for b in sl.get("bullets", []):
            if not ok(b.get("source")):
                raise ValueError(f"Slayd {i}: manbasiz band rad etildi: {b.get('text','')[:60]}")
    if lang == "en":  # inglizcha rejimda ruscha/kirill matn chiqmasligi kerak
        blob = " ".join([sl.get("title", "") + " " + " ".join(b.get("text", "") for b in sl.get("bullets", [])) for sl in slides])
        if _cyrillic_share(blob) > 0.05:
            raise ValueError("English mode: slayd matni inglizcha emas (kirill harflar ko'p)")
    mcq = data.get("mcq", [])
    if len(mcq) < 10:
        raise ValueError(f"Kamida 10 ta MCQ kerak, hozir {len(mcq)}")
    for i, q in enumerate(mcq, 1):
        if len(q.get("options", [])) < 4 or not isinstance(q.get("correct_index"), int) \
           or not 0 <= q["correct_index"] < len(q["options"]) or not q.get("explanation") or not ok(q.get("source")):
            raise ValueError(f"MCQ {i}: noto'g'ri tuzilma yoki manbasiz")
    return True


def _json_call(client, system, blocks, max_tokens, tag, raw_dir="out"):
    """Bitta bosqich: JSON qaytaradi; buzuq bo'lsa 1 marta qayta uriniladi."""
    kw = dict(model=MODEL, max_tokens=max_tokens,
              system=[{"type": "text", "text": system, "cache_control": {"type": "ephemeral"}}],
              messages=[{"role": "user", "content": blocks}])
    last = None
    for attempt in (1, 2):
        if hasattr(client.messages, "stream"):
            with client.messages.stream(**kw) as s:
                resp = s.get_final_message()
        else:
            resp = client.messages.create(**kw)
        text = "".join(b.text for b in resp.content if getattr(b, "type", "") == "text").strip()
        Path(raw_dir).mkdir(parents=True, exist_ok=True)
        Path(raw_dir, f"raw_{tag}_{attempt}.txt").write_text(text, encoding="utf-8")
        print(f"[{tag}#{attempt}] stop={getattr(resp,'stop_reason','?')} out_tok={getattr(getattr(resp,'usage',None),'output_tokens','?')}")
        if text.startswith("```"):
            text = text.split("\n", 1)[1].rsplit("```", 1)[0]
        try:
            return json.loads(text)
        except json.JSONDecodeError as e:
            last = e
    raise last


def call_api(client, system, user, lang="uz"):
    """3 bosqich: reja -> slaydlar (6 tadan) -> test+qiziqarli. Manba matni keshlanadi."""
    src = {"type": "text", "text": user, "cache_control": {"type": "ephemeral"}}
    if lang == "en":
        return _call_api_en(client, system, src)
    plan = _json_call(client, system, [src, {"type": "text", "text":
        'BOSQICH 1. Faqat reja qaytaring: {"topic":str,"plan":[{"title":str,"focus":str,"diagram":bool}]}. '
        '32-36 ta slayd, mavzu bo\'limlari tartibida to\'liq qamralsin; kamida 6 tasida diagram:true; boshida kirish, oxirida xulosa.'}],
        10000, "plan")
    items = plan["plan"]
    slides = []
    for i in range(0, len(items), 3):
        part = items[i:i + 3]
        r = _json_call(client, system, [src, {"type": "text", "text":
            f'BOSQICH 2. Quyidagi {len(part)} ta slaydni to\'liq yozing (tartib saqlansin): {json.dumps(part, ensure_ascii=False)}. '
            'Faqat JSON: {"slides":[{"title":str,"bullets":[{"text":str,"source":{"author":str,"title":str,"page":str},"uncertain":bool}],'
            '"diagram":null|{"kind":"flow"|"table","caption":str,"nodes":[str],"header":[str],"rows":[[str]]},"teacher_notes":str}]}. '
            'Har slaydda 3-4 band (<=220 belgi); diagram:true bo\'lsa diagram to\'ldirilsin.'}],
            12000, f"slides{i // 3 + 1}")
        slides += r["slides"]
    n = len(slides)
    mcq = []
    q = n // 4
    for k, (lo, hi) in enumerate([(0, q), (q, 2 * q), (2 * q, 3 * q), (3 * q, n)], 1):
        titles = [s.get("title", "") for s in slides[lo:hi]]
        r = _json_call(client, system, [src, {"type": "text", "text":
            f'BOSQICH 3.{k}. Faqat JSON: {{"mcq":[5 ta savol, FAQAT quyidagi slaydlar mavzulari bo\'yicha: {json.dumps(titles, ensure_ascii=False)}; '
            'kamida 3 tasi vaziyatli (qo\'llash) savol; har savolda FAQAT bitta narsa so\'ralsin; variantlar uzunligi teng; to\'g\'ri javob o\'rni A/B/C/D bo\'ylab teng taqsimlansin; '
            'har biri: {"question","options":[4 ta],"correct_index","explanation","source":{"author","title","page"}}]}}'}],
            8000, f"mcq{k}")
        mcq += r["mcq"]
    ex = _json_call(client, system, [src, {"type": "text", "text":
        'BOSQICH 3.9. Faqat JSON: {"extras":[3-5 ta qiziqarli fakt/hodisa tahlili/eslab qolish usuli, manbali: {"text","source":{"author","title","page"}}]}'}],
        3000, "extras")
    tail = {"mcq": mcq, "extras": ex.get("extras", [])}
    return {"topic": plan.get("topic", ""), "slides": slides, "mcq": tail["mcq"], "extras": tail.get("extras", [])}


def _call_api_en(client, system, src):
    sp = stage_prompts("en")
    plan = _json_call(client, system, [src, {"type": "text", "text": sp["plan"]}], 10000, "plan.en")
    items = plan["plan"]
    slides = []
    for i in range(0, len(items), 3):
        part = items[i:i + 3]
        r = _json_call(client, system, [src, {"type": "text", "text":
            sp["slides"].format(n=len(part), part=json.dumps(part, ensure_ascii=False))}], 12000, f"slides{i // 3 + 1}.en")
        slides += r["slides"]
    n = len(slides)
    mcq = []
    q = n // 4
    for k, (lo, hi) in enumerate([(0, q), (q, 2 * q), (2 * q, 3 * q), (3 * q, n)], 1):
        titles = json.dumps([s.get("title", "") for s in slides[lo:hi]], ensure_ascii=False)
        r = _json_call(client, system, [src, {"type": "text", "text": sp["mcq"].format(k=k, titles=titles)}], 8000, f"mcq{k}.en")
        mcq += r["mcq"]
    ex = _json_call(client, system, [src, {"type": "text", "text": sp["extras"]}], 3000, "extras.en")
    return {"topic": plan.get("topic", ""), "slides": slides, "mcq": mcq, "extras": ex.get("extras", [])}


def run(topic_id, sources_path, max_usd, dry_run, out_dir, client=None, lang="uz", intl_only=False):
    if lang not in LANGS:
        raise ValueError(f"lang {LANGS} dan biri bo'lishi kerak: {lang}")
    topic = get_topic(topic_id)
    sources = load_sources(topic_id, sources_path, lang, intl_only)
    if not sources:
        pend = PENDING_EN if lang == "en" else PENDING
        print(f"{pend}: {topic['title']} -- API chaqirilmadi.")
        return {"status": "pending", "message": pend}
    system = SYSTEM_PROMPT_EN if lang == "en" else SYSTEM_PROMPT
    suffix = ".en" if lang == "en" else ""
    user = build_user_prompt(topic, sources, lang)
    in_tok = est_tokens(system) + est_tokens(user)
    cost = est_cost(in_tok * 1.3, 80000)  # keshlangan kirish + ~80k chiqish (eng yomon holat)
    print(f"Taxminiy kirish tokenlari: {in_tok}; chiqish (maks): {MAX_TOKENS}; "
          f"eng yomon narx ~ ${cost:.4f} (narx konstantalari TEKSHIRILMAGAN, rasmiy sahifada tekshiring)")
    if cost > max_usd:
        print(f"RAD: taxminiy narx ${cost:.4f} > --max-usd ${max_usd}. API chaqirilmadi.")
        return {"status": "over_budget", "cost": cost}
    if dry_run:
        print("DRY-RUN: API chaqirilmadi.")
        return {"status": "dry_run", "cost": cost, "input_tokens": in_tok}
    if client is None:
        key = os.environ.get("ANTHROPIC_API_KEY")
        if not key:
            sys.exit("ANTHROPIC_API_KEY o'rnatilmagan.")
        import anthropic
        client = anthropic.Anthropic(api_key=key)
    data = call_api(client, system, user, lang) if lang == "en" else call_api(client, system, user)
    data.update(clean_text({k: data[k] for k in ('slides', 'mcq', 'extras') if k in data}, lang))
    canonicalize_sources(data, sources)
    Path(out_dir).mkdir(parents=True, exist_ok=True)
    (Path(out_dir) / f"{topic_id}{suffix}.unvalidated.json").write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    validate_output(data, sources, lang)
    if lang == "en":
        data["topic_uz"] = topic["title"]
        data["topic"] = data.get("topic") or topic["title"]
        data["lang"] = "en"
    else:
        data["topic"] = topic["title"]
    data["sources"] = [{k: s.get(k) for k in ("author", "title", "year", "pages")} for s in sources]
    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    (out / f"{topic_id}{suffix}.json").write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    return {"status": "ok", "path": str(out / f"{topic_id}{suffix}.json")}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("topic_id")
    ap.add_argument("--sources", default=str(Path(__file__).parent / "sources.json"))
    ap.add_argument("--max-usd", type=float, default=1.50)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--out", default="out")
    ap.add_argument("--lang", choices=LANGS, default=None, help="uz (standart) yoki en (xalqaro guruhlar); topic_id oxiriga ':en' ham bo'ladi")
    ap.add_argument("--intl-only", action="store_true", help="en rejimda faqat xalqaro manbalar (Simpson, PMC) ishlatilsin")
    a = ap.parse_args()
    tid, _, suf = a.topic_id.partition(":")
    lang = a.lang or (suf if suf in LANGS else "uz")
    run(tid, a.sources, a.max_usd, a.dry_run, a.out, lang=lang, intl_only=a.intl_only)


if __name__ == "__main__":
    main()
