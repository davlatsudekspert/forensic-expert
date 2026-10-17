"""Mavzu bo'yicha MUSTAQIL test banki: 30 savol, UZ (asl) + RU + EN (avtomatik tarjima).

Prezentatsiyadan ajratilgan mahsulot: ustoz sinfda yechtiradi (class-quiz).
Mavjud mexanizmlar generate.py dan olinadi: _json_call (streaming, prompt caching, 1 marta qayta urinish),
load_sources, canonicalize_sources, clean_text, narx baholash.
"""
import argparse, json, os, re, sys
from difflib import SequenceMatcher
from pathlib import Path

import generate as g
from topics import get_topic

LANGS = ("uz", "ru", "en")
N_QUESTIONS = 30
N_EASY = 15            # oson-o'rta
N_HARD = 15            # qiyin / amaliy-vaziyat
TRANSLATE_CHUNK = 10   # bir tarjima chaqiruvida savollar soni
# uz batchlari: (oson-o'rta soni, qiyin soni) -- jami 6 tadan, 5 batch
UZ_BATCHES = [(6, 0), (6, 0), (3, 3), (0, 6), (0, 6)]
UZ_MAX_TOKENS = 16000
TR_MAX_TOKENS = 16000
QUIZ_OUT_TOK_EST = 60000   # 30 uz + 2x30 tarjima, eng yomon holat
STATUS = {"uz": "source", "ru": "auto_unreviewed", "en": "auto_unreviewed"}
SIM_LIMIT = 0.88           # dublikat deb hisoblanadigan matn o'xshashligi

QUIZ_SYSTEM = """Siz sud-tibbiyot fani o'qituvchisi uchun SINF TESTI savollarini tayyorlaysiz (talabalar sinfda yechadi).
QOIDALAR:
1. Faqat o'zbek tili (lotin). Faqat quyida berilgan MANBA MATNLARIDAN foydalaning; raqam, bet, foiz, cutoff, sana, modda nomini TO'QIMANG.
2. Har savol: bitta aniq to'g'ri javob; 4 ta variant; chalg'ituvchi variantlar mantiqan yaqin, ishonarli (mavzuga oid), lekin aniq xato; variantlar uzunligi bir-biriga yaqin; "hammasi to'g'ri"/"hech biri" variantlaridan qoching; har savolda FAQAT bitta narsa so'ralsin.
3. correct_index o'rni 0..3 bo'ylab teng taqsimlansin.
4. difficulty: "easy" (ta'rif/fakt), "medium" (tushunish/farqlash), "hard" (amaliy vaziyat, hisob, ikki bosqichli fikrlash).
5. Har savolga tushuntirish (nima uchun to'g'ri, chalg'ituvchilar nega xato; 1-3 jumla, o'z so'zingiz bilan, kitobdan so'zma-so'z ko'chirmang) va source:{author,title,page} (author/title manbalar ro'yxatidagi bilan bir xil, page - kitob/PDF beti).
6. Savol ichida [muallif, bet] iqtibos YOZMANG; qisqartmalar birinchi uchrashganda ochilsin; apostrof o' va g' uchun ‘, boshqa o'rinda ’ ishlating.
7. Faqat JSON qaytaring, boshqa matn yo'q."""

TR_SYSTEM = """Siz sud-tibbiyot atamalari bo'yicha ehtiyotkor tarjimonsiz. O'zbek (lotin) test savollarini berilgan tilga tarjima qilasiz.
QOIDALAR:
1. Raqamlar, birliklar, formulalar, modda nomlari (lotincha/kimyoviy), qisqartmalar (COHb, PMI, GC-MS...), foizlar, cutoff qiymatlari, sanalar AYNAN o'zgarishsiz qolsin. Yangi raqam qo'shmang, mavjudini tushirmang.
2. Variantlar tartibi va soni (4) o'zgarmasin; correct_index ga tegmang (u siz qaytaradigan natijada bo'lmaydi).
3. Ma'noni o'zgartirmang, tushuntirish va javobni qo'shib/kamaytirib yozmang. Tibbiy atamalar uchun qabul qilingan standart atamani ishlating.
4. Faqat JSON qaytaring, boshqa matn yo'q."""

LANG_NAME = {"ru": "RUS", "en": "INGLIZ"}

NUM_RE = re.compile(r"\d+(?:[.,]\d+)?")
TOKEN_RE = re.compile(r"[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*")


def numbers(text):
    """Matndagi raqamlar to'plami (1,5 va 1.5 bir xil)."""
    return {n.replace(",", ".") for n in NUM_RE.findall(text or "")}


def abbrevs(text):
    """Aralash registrli/defisli lotin belgilar (COHb, GC-MS, LC-MS/MS, HbCO): tarjimada aynan saqlanishi kerak.
    Faqat KATTA HARFLI so'zlar (DNK/DNA kabi tilga qarab o'zgaradiganlar) tekshirilmaydi."""
    out = set()
    for t in TOKEN_RE.findall(text or ""):
        if sum(c.isupper() for c in t) >= 2 and (not t.isupper() or "-" in t):
            out.add(t)
    return out


def _norm(s):
    return re.sub(r"\W+", " ", (s or "").lower()).strip()


# ---------------------------------------------------------------- validatsiya

def _src_ok(src, allowed):
    return (isinstance(src, dict) and src.get("author") and src.get("title") and str(src.get("page") or "").strip()
            and (src["author"].strip().lower(), src["title"].strip().lower()) in allowed)


def validate_uz_batch(qs, sources, prior_texts, want_easy, want_hard, n_total):
    """Bitta uz batch: tuzilma, manba, dublikat, qiyinlik soni."""
    allowed = {(s["author"].strip().lower(), s["title"].strip().lower()) for s in sources}
    if len(qs) != n_total:
        raise ValueError(f"Batchda {n_total} ta savol kerak, hozir {len(qs)}")
    seen = list(prior_texts)
    easy = hard = 0
    for i, q in enumerate(qs, 1):
        opts = q.get("options")
        if not q.get("question") or not isinstance(opts, list) or len(opts) != 4 or not all(isinstance(o, str) and o.strip() for o in opts):
            raise ValueError(f"Savol {i}: 4 ta matnli variant kerak")
        if len({_norm(o) for o in opts}) != 4:
            raise ValueError(f"Savol {i}: variantlar takrorlanmoqda")
        ci = q.get("correct_index")
        if not isinstance(ci, int) or isinstance(ci, bool) or not 0 <= ci < 4:
            raise ValueError(f"Savol {i}: correct_index 0..3 bo'lishi kerak")
        if not q.get("explanation") or not _src_ok(q.get("source"), allowed):
            raise ValueError(f"Savol {i}: tushuntirishsiz yoki manbasiz (ruxsat etilgan ro'yxatdan emas)")
        d = q.get("difficulty")
        if d not in ("easy", "medium", "hard"):
            raise ValueError(f"Savol {i}: difficulty easy|medium|hard bo'lishi kerak")
        if d == "hard":
            hard += 1
        else:
            easy += 1
        nq = _norm(q["question"])
        for t in seen:
            if nq == t or SequenceMatcher(None, nq, t).ratio() >= SIM_LIMIT:
                raise ValueError(f"Savol {i}: dublikat (oldingi/mavjud savolga juda o'xshash): {q['question'][:60]}")
        seen.append(nq)
    if (easy, hard) != (want_easy, want_hard):
        raise ValueError(f"Qiyinlik taqsimoti {want_easy} oson-o'rta + {want_hard} qiyin bo'lishi kerak, hozir {easy}+{hard}")
    return True


def check_translation(uz, tr, lang):
    """Bitta savol: 4 variant, raqamlar to'plami va lotin qisqartmalar uz bilan mos."""
    qid = uz.get("id", "?")
    if not isinstance(tr.get("options"), list) or len(tr["options"]) != 4:
        raise ValueError(f"{qid}/{lang}: 4 ta variant kerak")
    for f in ("question", "explanation"):
        if not isinstance(tr.get(f), str) or not tr[f].strip():
            raise ValueError(f"{qid}/{lang}: {f} bo'sh")
    pairs = [("question", uz["question"], tr["question"]), ("explanation", uz["explanation"], tr["explanation"])]
    pairs += [(f"option {k}", a, b) for k, (a, b) in enumerate(zip(uz["options"], tr["options"]))]
    for name, a, b in pairs:
        if not isinstance(b, str) or not b.strip():
            raise ValueError(f"{qid}/{lang}: {name} bo'sh")
        if numbers(a) != numbers(b):
            raise ValueError(f"{qid}/{lang}: {name} raqamlari mos emas: uz={sorted(numbers(a))} {lang}={sorted(numbers(b))}")
        miss = abbrevs(a) - abbrevs(b)
        if miss:
            raise ValueError(f"{qid}/{lang}: {name} da qisqartma/formula tushib qolgan yoki o'zgargan: {sorted(miss)}")


def validate_bank(bank, sources):
    """Tayyor bank: 30 savol, 15 oson-o'rta + 15 qiyin, 3 til, correct_index bir xil, manba ruxsat etilgan."""
    allowed = {(s["author"].strip().lower(), s["title"].strip().lower()) for s in sources}
    qs = bank.get("questions", [])
    if len(qs) != N_QUESTIONS:
        raise ValueError(f"{N_QUESTIONS} ta savol kerak, hozir {len(qs)}")
    if set(bank.get("title_i18n", {})) != set(LANGS) or not all(bank["title_i18n"].values()):
        raise ValueError("title_i18n uz/ru/en bo'lishi kerak")
    hard = sum(1 for q in qs if q["difficulty"] == "hard")
    if hard != N_HARD or len(qs) - hard != N_EASY:
        raise ValueError(f"{N_EASY} oson-o'rta + {N_HARD} qiyin kerak, hozir {len(qs) - hard}+{hard}")
    ids = [q["id"] for q in qs]
    if len(set(ids)) != len(ids):
        raise ValueError("savol id lari takrorlanmoqda")
    for q in qs:
        if not isinstance(q["correct_index"], int) or not 0 <= q["correct_index"] < 4:
            raise ValueError(f"{q['id']}: correct_index noto'g'ri")
        if not _src_ok(q.get("source"), allowed):
            raise ValueError(f"{q['id']}: manba ruxsat etilgan ro'yxatda emas")
        for fld in ("question_i18n", "explanation_i18n"):
            if set(q[fld]) != set(LANGS) or not all(str(v).strip() for v in q[fld].values()):
                raise ValueError(f"{q['id']}: {fld} uz/ru/en to'liq emas")
        if set(q["options_i18n"]) != set(LANGS) or any(len(q["options_i18n"][l]) != 4 for l in LANGS):
            raise ValueError(f"{q['id']}: options_i18n har tilda 4 ta bo'lishi kerak")
        uz = {"id": q["id"], "question": q["question_i18n"]["uz"], "options": q["options_i18n"]["uz"], "explanation": q["explanation_i18n"]["uz"]}
        for l in ("ru", "en"):
            check_translation(uz, {"question": q["question_i18n"][l], "options": q["options_i18n"][l], "explanation": q["explanation_i18n"][l]}, l)
        if q.get("translation_status") != STATUS:
            raise ValueError(f"{q['id']}: translation_status noto'g'ri")
    return True


# ---------------------------------------------------------------- API bosqichlari

def existing_mcq(topic_id, existing_dir):
    """slides-out/out/<id>.json dagi mavjud MCQ lar (asos va dublikat nazorati uchun)."""
    if not existing_dir:
        return []
    p = Path(existing_dir) / f"{topic_id}.json"
    if not p.exists():
        return []
    try:
        return [q for q in json.loads(p.read_text(encoding="utf-8")).get("mcq", []) if q.get("question")]
    except (OSError, json.JSONDecodeError):
        return []


def _q_schema():
    return ('{"questions":[{"question":str,"options":[str,str,str,str],"correct_index":int,"explanation":str,'
            '"difficulty":"easy"|"medium"|"hard","source":{"author":str,"title":str,"page":str}}]}')


def gen_uz(client, user, sources, existing, raw_dir):
    """(a) uz savollar 6 tadan batchlarda. Manba matni keshlanadi; oldingi savollar dublikat nazorati uchun beriladi."""
    src = {"type": "text", "text": user, "cache_control": {"type": "ephemeral"}}
    done, prior = [], [_norm(q["question"]) for q in existing]
    for b, (ne, nh) in enumerate(UZ_BATCHES, 1):
        total = ne + nh
        avoid = [q["question"] for q in existing] + [q["question"] for q in done]
        err = ""
        for attempt in (1, 2):
            task = (f"UZ BATCH {b}/{len(UZ_BATCHES)}. Aynan {total} ta savol yozing: {ne} ta oson-o'rta (difficulty easy yoki medium) "
                    f"va {nh} ta qiyin/amaliy-vaziyat (difficulty hard). Bu batchda ketma-ket mavzularni qamrang; "
                    f"quyidagi savollarni TAKRORLAMANG va ularga o'xshash qilmang: {json.dumps(avoid, ensure_ascii=False)}. "
                    f"{err}Sxema: {_q_schema()}")
            r = g._json_call(client, QUIZ_SYSTEM, [src, {"type": "text", "text": task}], UZ_MAX_TOKENS, f"uz{b}_{attempt}", raw_dir)
            qs = g.clean_text({"mcq": r.get("questions", [])})["mcq"]
            fixed = {"mcq": qs}
            g.canonicalize_sources(fixed, sources)
            try:
                validate_uz_batch(qs, sources, prior + [_norm(q["question"]) for q in done], ne, nh, total)
                break
            except ValueError as e:
                if attempt == 2:
                    raise
                err = f"OLDINGI URINISH RAD ETILDI: {e}. Tuzating. "
        done += qs
    return done


def _tr_task(lang, chunk, title):
    payload = {"questions": [{"id": q["id"], "question": q["question"], "options": q["options"], "explanation": q["explanation"]} for q in chunk]}
    if title:
        payload["title"] = title
    extra = ',"title":str' if title else ""
    return (f"TARJIMA {lang}. Quyidagi o'zbekcha savollarni {LANG_NAME[lang]} tiliga tarjima qiling. "
            f'Faqat JSON: {{"questions":[{{"id":str,"question":str,"options":[4 ta],"explanation":str}}]{extra}}}. '
            f"id lar o'zgarmasin.\nINPUT_JSON:\n{json.dumps(payload, ensure_ascii=False)}")


def translate(client, uz_qs, title, lang, raw_dir):
    """(b) uz -> lang. Raqam/qisqartma mosligi avtomatik tekshiriladi; xato bo'lsa 1 marta xato matni bilan qayta uriniladi."""
    out, out_title = {}, None
    for c in range(0, len(uz_qs), TRANSLATE_CHUNK):
        chunk = uz_qs[c:c + TRANSLATE_CHUNK]
        first = c == 0
        err = ""
        for attempt in (1, 2):
            task = err + _tr_task(lang, chunk, title if first else None)
            r = g._json_call(client, TR_SYSTEM, [{"type": "text", "text": task}], TR_MAX_TOKENS, f"{lang}{c // TRANSLATE_CHUNK + 1}_{attempt}", raw_dir)
            try:
                got = {t.get("id"): t for t in r.get("questions", []) if isinstance(t, dict)}
                if set(got) != {q["id"] for q in chunk}:
                    raise ValueError(f"{lang}: id lar mos emas")
                for q in chunk:
                    check_translation(q, got[q["id"]], lang)
                if first and not str(r.get("title") or "").strip():
                    raise ValueError(f"{lang}: title tarjimasi yo'q")
                break
            except ValueError as e:
                if attempt == 2:
                    raise
                err = f"OLDINGI URINISH RAD ETILDI: {e}. Raqam/qisqartmalarni uz bilan aynan bir xil qoldirib qayta tarjima qiling.\n"
        out.update(got)
        if first:
            out_title = r["title"].strip()
    return out, out_title


def assemble(topic_id, topic, uz_qs, tr, titles, sources):
    qs = []
    for q in uz_qs:
        qs.append({
            "id": q["id"],
            "question_i18n": {"uz": q["question"], "ru": tr["ru"][q["id"]]["question"], "en": tr["en"][q["id"]]["question"]},
            "options_i18n": {"uz": q["options"], "ru": tr["ru"][q["id"]]["options"], "en": tr["en"][q["id"]]["options"]},
            "correct_index": q["correct_index"],
            "explanation_i18n": {"uz": q["explanation"], "ru": tr["ru"][q["id"]]["explanation"], "en": tr["en"][q["id"]]["explanation"]},
            "source": {k: q["source"][k] for k in ("author", "title", "page")},
            "difficulty": q["difficulty"],
            "translation_status": dict(STATUS),
        })
    return {"topic_id": topic_id, "source_lang": "uz",
            "title_i18n": {"uz": topic["title"], "ru": titles["ru"], "en": titles["en"]},
            "translation_status": dict(STATUS),
            "questions": qs,
            "sources": [{k: s.get(k) for k in ("author", "title", "year", "pages")} for s in sources]}


def est_quiz_cost(in_tok):
    """Eng yomon holat: manba 1 marta kesh yoziladi (1.25x), 4 marta kesh o'qiladi (0.1x); chiqish ~60k token."""
    cached = in_tok * (1.25 + 4 * 0.10)
    return (cached / 1e6 * g.PRICE_IN_PER_MTOK_USD + QUIZ_OUT_TOK_EST / 1e6 * g.PRICE_OUT_PER_MTOK_USD
            + 0.05)  # tarjima chaqiruvlari kirishi (kichik) uchun zaxira


def run(topic_id, sources_path, max_usd, dry_run, out_dir, existing_dir=None, client=None):
    topic = get_topic(topic_id)
    sources = g.load_sources(topic_id, sources_path)
    if not sources:
        print(f"{g.PENDING}: {topic['title']} -- API chaqirilmadi.")
        return {"status": "pending", "message": g.PENDING}
    user = g.build_user_prompt(topic, sources)
    ex = existing_mcq(topic_id, existing_dir)
    in_tok = g.est_tokens(QUIZ_SYSTEM) + g.est_tokens(user) + sum(g.est_tokens(q["question"]) for q in ex)
    cost = est_quiz_cost(in_tok)
    print(f"[{topic_id}] kirish ~{in_tok} token; mavjud MCQ: {len(ex)}; eng yomon narx ~ ${cost:.4f} "
          f"(narx konstantalari TEKSHIRILMAGAN, rasmiy sahifada tekshiring)")
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
    out = Path(out_dir)
    raw_dir = out / "raw"
    uz = gen_uz(client, user, sources, ex, raw_dir)
    for i, q in enumerate(uz, 1):
        q["id"] = f"{topic_id}-q{i:02d}"
    # (b) tarjima: ru va en
    tr, titles = {}, {}
    for lang in ("ru", "en"):
        tr[lang], titles[lang] = translate(client, uz, topic["title"], lang, raw_dir)
    bank = assemble(topic_id, topic, uz, tr, titles, sources)
    out.mkdir(parents=True, exist_ok=True)
    (out / f"{topic_id}.unvalidated.json").write_text(json.dumps(bank, ensure_ascii=False, indent=2), encoding="utf-8")
    validate_bank(bank, sources)
    dist = [sum(1 for q in bank["questions"] if q["correct_index"] == k) for k in range(4)]
    if max(dist) > 0.5 * N_QUESTIONS:
        print(f"OGOHLANTIRISH: correct_index taqsimoti notekis {dist} -- ustoz ko'zdan kechirsin.")
    path = out / f"{topic_id}.json"
    path.write_text(json.dumps(bank, ensure_ascii=False, indent=2), encoding="utf-8")
    (out / f"{topic_id}.unvalidated.json").unlink(missing_ok=True)
    return {"status": "ok", "path": str(path), "correct_dist": dist}


def main():
    ap = argparse.ArgumentParser(description="Mavzu bo'yicha 30 savolli 3 tilli test banki")
    ap.add_argument("topic_ids", help="mavzu id yoki vergul bilan ro'yxat")
    ap.add_argument("--sources", default=str(Path(__file__).parent / "sources.json"))
    ap.add_argument("--existing", default="slides-out/out", help="mavjud slayd JSON lari (ichidagi mcq asos/dublikat nazorati uchun)")
    ap.add_argument("--max-usd", type=float, default=1.50, help="HAR BIR mavzu uchun byudjet")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--out", default="out_quiz")
    a = ap.parse_args()
    bad = 0
    for t in [x.strip() for x in a.topic_ids.split(",") if x.strip()]:
        try:
            r = run(t, a.sources, a.max_usd, a.dry_run, a.out, a.existing)
            bad += r["status"] in ("over_budget",)
        except Exception as e:  # bitta mavzu xatosi qolganini to'xtatmasin
            print(f"FAIL {t}: {e}")
            bad += 1
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
