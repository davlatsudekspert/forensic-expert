# «GC-MS apparat sxemasi» (LabGuide paketi, egasi so‘rovi 2026-10-25): faqat interfeys
# yorliqlari; sxema matnlari (qismlar, tamoyil, natija) JSON’dan, uch tilda, o‘zgartirilmasdan.
# Idempotent. CLAUDE.md tartibida l10n_assessment.py dan keyin:
#   cd apps/mobile && python3 tool/l10n_gcms.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph or {})


k('gcmsTitle', 'Tools entry and screen title: GC-MS schematic.',
  'GC-MS instrument schematic',
  'Схема GC-MS',
  'GC-MS apparat sxemasi')
k('gcmsEntryHint', 'Tools entry hint.',
  'Gas chromatograph–mass spectrometer: parts and working principle',
  'Газовый хромато-масс-спектрометр: узлы и принцип работы',
  'Gaz xromatografi-mass-spektrometr: qismlar va ishlash tamoyili')
k('gcmsReviewPending', 'Status chip: expert review pending.',
  'Expert review pending',
  'Ожидает экспертной проверки',
  'Ekspert tekshiruvi kutilmoqda')
k('gcmsPanelTitle', 'Collapsible panel title.',
  'Parts and working principle',
  'Узлы и принцип работы',
  'Qismlar va ishlash tamoyili')
k('gcmsPrinciple', 'Heading: working principle.',
  'Working principle',
  'Принцип работы',
  'Ishlash tamoyili')
k('gcmsResult', 'Heading: result.',
  'Result',
  'Результат',
  'Natija')
k('gcmsUsedFor', 'Heading: where the instrument is used (sourced sentence).',
  'Use',
  'Применение',
  'Qo‘llanilishi')
k('gcmsSourceLine', 'Source line under the sourced sentence.',
  'Source: {source}',
  'Источник: {source}',
  'Manba: {source}', {'source': 'String'})
k('gcmsZoomHint', 'Hint on the picture.',
  'Tap to enlarge',
  'Нажмите, чтобы увеличить',
  'Kattalashtirish uchun bosing')
k('gcmsClose', 'Close the full-screen picture.',
  'Close',
  'Закрыть',
  'Yopish')
k('gcmsUnavailable', 'Shown when the module data cannot be loaded.',
  'The GC-MS module could not be loaded.',
  'Не удалось загрузить модуль GC-MS.',
  'GC-MS modulini yuklab bo‘lmadi.')

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
