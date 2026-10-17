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
PENDING = "ADABIYOT KUTILMOQDA"

SYSTEM_PROMPT = """Siz sud-tibbiyot fani o'qituvchisi uchun ma'ruza materiali tayyorlaysiz.
QOIDALAR:
1. Faqat o'zbek tili (lotin). Faqat quyida berilgan MANBA MATNLARIDAN foydalaning.
2. KAMIDA 30 ta slayd (30-40). Mavzuning barcha bo'limlarini qamrang. Slaydlarning kamida 6 tasida "diagram" bo'lsin (o'zingiz chizgan sodda sxema: kind="flow" nodes=[matn...] yoki kind="table" header=[...] rows=[[...]]; jadvalni manbadan o'z so'zingiz bilan qayta tuzing, rasmni ko'chirmang, haqiqiy foto deb ko'rsatmang). Oxirida "extras": 3-5 ta qiziqarli fakt/hodisa tahlili/eslab qolish usuli (manbali). Matn sodda, tushunarli.
USLUB QOIDALARI: har band 220 belgidan oshmasin (1-2 qisqa jumla, kitob jumlasini so'zma-so'z ko'chirma — o'z so'zingiz bilan); slaydda 3-4 band, ~60 so'z; bandlar matni ichiga [muallif, bet] iqtibos YOZMANG (u source maydonida); qisqartmalar (MNT, AUF...) birinchi uchrashganda ochilsin; apostrof o' va g' uchun ‘, boshqa o'rinda ’ ishlating.
DIAGRAMMA: slaydlarning kamida yarmida diagram bo'lsin; flow tugunlari <=40 belgi (muddat/belgi bilan), 3-6 tugun; table <=5 qator va <=4 ustun, katak <=80 belgi; vaqt chizig'i, solishtirish (A vs B), jarayon zanjiri, hisoblash misoli uchun jadval/flow ishlating; diagram sarlavhasi (caption) qisqa.
TALABANI USHLAB TURISH: har bo'limdan keyin 1 ta "Voqea tahlili" slaydi (manbadagi ma'lumotlardan tuzilgan qisqa vaziyat + savol), har 6-8 slaydda "Tezkor savol" slaydi, "Diqqat: xato qilish xavfi" bandi (manbada bor farqlash: masalan A ≠ B), "Eslab qoling" mnemonikasi (manbada bo'lsa). teacher_notes: vaqt (daq), 1-2 muhokama savoli, doskada chizish topshirig'i, tipik xato. Har slaydning har bir bandi oxirida [muallif, kitob, bet] ko'rsatilsin; manba va bet faqat berilgan ro'yxatdan.
3. Raqam, bet, foiz, sana TO'QIMANG. Manbada bo'lmasa yozmang.
4. Ishonchsiz yoki manbada aniq bo'lmagan bandni "uncertain": true bilan belgilang.
5. 10 ta MCQ: bitta to'g'ri javob, mantiqan yaqin chalg'ituvchi variantlar, tushuntirish, manba+bet.
6. Faqat JSON qaytaring, boshqa matn yo'q. Sxema:
{"topic":str,"slides":[{"title":str,"bullets":[{"text":str,"source":{"author":str,"title":str,"page":str},"uncertain":bool}],"diagram":null|{"kind":"flow"|"table","caption":str,"nodes":[str],"header":[str],"rows":[[str]]},"teacher_notes":str}],
"extras":[{"text":str,"source":{"author":str,"title":str,"page":str}}],
"mcq":[{"question":str,"options":[str,str,str,str],"correct_index":int,"explanation":str,"source":{"author":str,"title":str,"page":str}}]}"""


def est_tokens(text):
    return int(len(text) / CHARS_PER_TOKEN) + 1


def est_cost(in_tok, out_tok):
    return in_tok / 1e6 * PRICE_IN_PER_MTOK_USD + out_tok / 1e6 * PRICE_OUT_PER_MTOK_USD


def load_sources(topic_id, path):
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
    return out


def build_user_prompt(topic, sources):
    parts = [f"MAVZU: {topic['title']} ({topic['course']})\n"]
    for i, s in enumerate(sources, 1):
        parts.append(f"=== MANBA {i}: {s['author']}, {s['title']}, {s.get('year','')}, betlar {s['pages']} ===\n{s['text']}\n")
    return "\n".join(parts)


def _apos(s):
    s = re.sub(r"([oOgG])'", lambda m: m.group(1) + "\u2018", s)
    return s.replace("'", "\u2019")


def clean_text(data):
    """Iqtibos oqishi, apostrof, begona kalitlar."""
    cite = re.compile(r"\s*\[[^\]]*(bet|Sud tibbiyoti|G.iyosov)[^\]]*\]")
    def walk(o, key=None):
        if isinstance(o, str):
            o = _apos(cite.sub("", o)) if key in ("text", "title", "caption", "focus", "teacher_notes", "question", "explanation") or key is None else o
            return o
        if isinstance(o, list):
            return [walk(x, key) for x in o]
        if isinstance(o, dict):
            return {k: walk(v, k) for k, v in o.items() if k not in ("}", "]", "") }
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


def validate_output(data, sources):
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
    mcq = data.get("mcq", [])
    if len(mcq) < 10:
        raise ValueError(f"Kamida 10 ta MCQ kerak, hozir {len(mcq)}")
    for i, q in enumerate(mcq, 1):
        if len(q.get("options", [])) < 4 or not isinstance(q.get("correct_index"), int) \
           or not 0 <= q["correct_index"] < len(q["options"]) or not q.get("explanation") or not ok(q.get("source")):
            raise ValueError(f"MCQ {i}: noto'g'ri tuzilma yoki manbasiz")
    return True


def _json_call(client, system, blocks, max_tokens, tag):
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
        Path("out").mkdir(exist_ok=True)
        Path(f"out/raw_{tag}_{attempt}.txt").write_text(text, encoding="utf-8")
        print(f"[{tag}#{attempt}] stop={getattr(resp,'stop_reason','?')} out_tok={getattr(getattr(resp,'usage',None),'output_tokens','?')}")
        if text.startswith("```"):
            text = text.split("\n", 1)[1].rsplit("```", 1)[0]
        try:
            return json.loads(text)
        except json.JSONDecodeError as e:
            last = e
    raise last


def call_api(client, system, user):
    """3 bosqich: reja -> slaydlar (6 tadan) -> test+qiziqarli. Manba matni keshlanadi."""
    src = {"type": "text", "text": user, "cache_control": {"type": "ephemeral"}}
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


def run(topic_id, sources_path, max_usd, dry_run, out_dir, client=None):
    topic = get_topic(topic_id)
    sources = load_sources(topic_id, sources_path)
    if not sources:
        print(f"{PENDING}: {topic['title']} -- API chaqirilmadi.")
        return {"status": "pending", "message": PENDING}
    user = build_user_prompt(topic, sources)
    in_tok = est_tokens(SYSTEM_PROMPT) + est_tokens(user)
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
    data = call_api(client, SYSTEM_PROMPT, user)
    data.update(clean_text({k: data[k] for k in ('slides', 'mcq', 'extras') if k in data}))
    canonicalize_sources(data, sources)
    Path(out_dir).mkdir(parents=True, exist_ok=True)
    (Path(out_dir) / f"{topic_id}.unvalidated.json").write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    validate_output(data, sources)
    data["topic"] = topic["title"]
    data["sources"] = [{k: s.get(k) for k in ("author", "title", "year", "pages")} for s in sources]
    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    (out / f"{topic_id}.json").write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    return {"status": "ok", "path": str(out / f"{topic_id}.json")}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("topic_id")
    ap.add_argument("--sources", default=str(Path(__file__).parent / "sources.json"))
    ap.add_argument("--max-usd", type=float, default=1.50)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--out", default="out")
    a = ap.parse_args()
    run(a.topic_id, a.sources, a.max_usd, a.dry_run, a.out)


if __name__ == "__main__":
    main()
