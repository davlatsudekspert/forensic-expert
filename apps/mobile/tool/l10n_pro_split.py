# Bepul / Pro bo‘linishi (egasi qarori, 2026-10-31): qulf kartalari foydasi, namuna sarlavhasi,
# qulf belgisi. Bu matnlar FAQAT `FE_PRO_STRICT=true` yig‘ilishda ko‘rinadi (standart o‘chiq);
# o‘chiqda ilovada «Pro / tez orada» yozuvi yo‘q (CLAUDE.md, 2026-10-17 qoidasi).
# Idempotent: faqat shu fayldagi kalitlarni yozadi.
# CLAUDE.md tartibida l10n_toxicology_label.py dan keyin:
#   cd apps/mobile && python3 tool/l10n_pro_split.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph or {})


k('proBenefitModules', 'Lock card benefit: all sections beyond the free three.',
  'All sections: reagents, substances, methods, screening, law and research',
  'Все разделы: реагенты, вещества, методы, скрининг, право и исследования',
  'Barcha bo‘limlar: reagentlar, moddalar, usullar, skrining, huquq va tadqiqotlar')
k('proBenefitTools', 'Lock card benefit: calculators and tools.',
  'Calculators and analysis tools (GC-MS, spectrophotometry)',
  'Калькуляторы и аналитические инструменты (GC-MS, спектрофотометрия)',
  'Kalkulyatorlar va tahlil vositalari (GC-MS, spektrofotometriya)')
k('proBenefitAi', 'Lock card benefit: Forensic AI.',
  'Forensic AI: answers with sources',
  'Forensic AI: ответы с источниками',
  'Forensic AI: manbali javoblar')
k('proBenefitListen', 'Lock card benefit: listen (text to speech).',
  'Listen to the text read aloud',
  'Прослушивание текста вслух',
  'Matnni ovozli tinglash')
k('proBenefitGroupReview', 'Lock card benefit: group test review for the student.',
  'Correct answers, explanations and error analysis of this test',
  'Правильные ответы, пояснения и разбор ошибок этого теста',
  'Bu testning to‘g‘ri javoblari, izohlari va xatolar tahlili')
k('proBenefitTeacherPanel', 'Lock card benefit: full teacher panel (live tests).',
  'Run live tests and use the full teacher panel',
  'Проведение живых тестов и полная панель учителя',
  'Jonli test o‘tkazish va to‘liq ustoz paneli')
k('proSampleTitle', 'Section header above a short sample inside a locked section.',
  'Sample', 'Образец', 'Namuna')
k('proSampleNote', 'Note under a sample: the full section needs Pro.',
  'A short sample. The full section opens with Pro.',
  'Короткий образец. Полный раздел открывается с Pro.',
  'Qisqa namuna. To‘liq bo‘lim Pro bilan ochiladi.')
k('proLockedBadge', 'Accessibility label of the small lock badge on a Pro section card.',
  'Unlocked with Pro', 'Открывается с Pro', 'Pro bilan ochiladi')

for idx, code in enumerate(["en", "ru", "uz"]):
    p = f"{D}/app_{code}.arb"
    text = open(p, encoding="utf-8").read()
    data = json.loads(text)
    for key, (desc, en, ru, uz, ph) in K.items():
        val = (en, ru, uz)[idx]
        entries = [(key, val)]
        if code == "en":
            meta = {"description": desc}
            if ph:
                meta["placeholders"] = {n: {"type": t} for n, t in ph.items()}
            entries.append(("@" + key, meta))
        for kk, vv in entries:
            line = f"  {json.dumps(kk, ensure_ascii=False)}: {json.dumps(vv, ensure_ascii=False)}"
            if kk in data:
                text = re.sub(r"(?ms)^  " + re.escape(json.dumps(kk, ensure_ascii=False)) + r": .*?(,?)\n(?=  \"|\}$)",
                              lambda m: line + m.group(1) + "\n", text, count=1)
            else:
                body = text.rstrip()
                assert body.endswith("}")
                text = body[:-1].rstrip() + ",\n" + line + "\n}\n"
        data = json.loads(text)
    json.loads(text)
    open(p, "w", encoding="utf-8").write(text)
print(len(K), "keys")
