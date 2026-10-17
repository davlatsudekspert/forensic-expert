"""Bitta mavzu uchun slayd rejasi + 10 MCQ (faqat berilgan manbalardan)."""
import argparse, json, os, sys
from pathlib import Path

from topics import get_topic

MODEL = "claude-sonnet-5-5"
# DIQQAT: narxlar taxminiy. Egasi rasmiy Anthropic narxlar sahifasida tekshirishi SHART.
PRICE_IN_PER_MTOK_USD = 3.00    # TEKSHIRILMAGAN taxmin
PRICE_OUT_PER_MTOK_USD = 15.00  # TEKSHIRILMAGAN taxmin
CHARS_PER_TOKEN = 3.0           # o'zbek lotin uchun konservativ taxmin
MAX_TOKENS = 16000
TEMPERATURE = 0.2
MAX_SOURCE_CHARS = 60000
PENDING = "ADABIYOT KUTILMOQDA"

SYSTEM_PROMPT = """Siz sud-tibbiyot fani o'qituvchisi uchun ma'ruza materiali tayyorlaysiz.
QOIDALAR:
1. Faqat o'zbek tili (lotin). Faqat quyida berilgan MANBA MATNLARIDAN foydalaning.
2. KAMIDA 30 ta slayd (30-40). Mavzuning barcha bo'limlarini qamrang. Slaydlarning kamida 6 tasida "diagram" bo'lsin (o'zingiz chizgan sodda sxema: kind="flow" nodes=[matn...] yoki kind="table" header=[...] rows=[[...]]; jadvalni manbadan o'z so'zingiz bilan qayta tuzing, rasmni ko'chirmang, haqiqiy foto deb ko'rsatmang). Oxirida "extras": 3-5 ta qiziqarli fakt/hodisa tahlili/eslab qolish usuli (manbali). Matn sodda, tushunarli. Har slaydning har bir bandi oxirida [muallif, kitob, bet] ko'rsatilsin; manba va bet faqat berilgan ro'yxatdan.
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
    if len(mcq) != 10:
        raise ValueError(f"10 ta MCQ kerak, hozir {len(mcq)}")
    for i, q in enumerate(mcq, 1):
        if len(q.get("options", [])) < 4 or not isinstance(q.get("correct_index"), int) \
           or not 0 <= q["correct_index"] < len(q["options"]) or not q.get("explanation") or not ok(q.get("source")):
            raise ValueError(f"MCQ {i}: noto'g'ri tuzilma yoki manbasiz")
    return True


def call_api(client, system, user):
    resp = client.messages.create(
        model=MODEL, max_tokens=MAX_TOKENS,
        system=[{"type": "text", "text": system, "cache_control": {"type": "ephemeral"}}],
        messages=[{"role": "user", "content": user}])
    text = "".join(b.text for b in resp.content if getattr(b, "type", "") == "text")
    text = text.strip()
    if text.startswith("```"):
        text = text.split("\n", 1)[1].rsplit("```", 1)[0]
    return json.loads(text)


def run(topic_id, sources_path, max_usd, dry_run, out_dir, client=None):
    topic = get_topic(topic_id)
    sources = load_sources(topic_id, sources_path)
    if not sources:
        print(f"{PENDING}: {topic['title']} -- API chaqirilmadi.")
        return {"status": "pending", "message": PENDING}
    user = build_user_prompt(topic, sources)
    in_tok = est_tokens(SYSTEM_PROMPT) + est_tokens(user)
    cost = est_cost(in_tok, MAX_TOKENS)  # eng yomon holat: to'liq max_tokens
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
    ap.add_argument("--max-usd", type=float, default=0.50)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--out", default="out")
    a = ap.parse_args()
    run(a.topic_id, a.sources, a.max_usd, a.dry_run, a.out)


if __name__ == "__main__":
    main()
