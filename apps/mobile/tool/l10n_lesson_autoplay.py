# Dars ko‘rgich: «Avto / Qo‘lda» varaqlash (egasi so‘rovi, 2026-10-26). Idempotent.
#   cd apps/mobile && python3 tool/l10n_lesson_autoplay.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph or {})


k('lessonAutoTooltip', 'Lesson viewer: button that opens the auto-advance settings.',
  'Auto-advance', 'Автолистание', 'Avto varaqlash')
k('lessonAutoManual', 'Lesson viewer: manual paging mode.', 'Manual', 'Вручную', 'Qo‘lda')
k('lessonAutoAuto', 'Lesson viewer: automatic paging mode.', 'Auto', 'Авто', 'Avto')
k('lessonAutoSpeed', 'Lesson viewer: heading of the auto-advance interval choice.',
  'Time per slide', 'Время на слайд', 'Har bir slayd vaqti')
k('lessonAutoSeconds', 'Lesson viewer: interval in seconds.',
  '{n} s', '{n} с', '{n} soniya', {'n': 'int'})
k('lessonAutoRunning', 'Lesson viewer: status line while auto-advance runs.',
  'Auto: {n} s per slide', 'Авто: {n} с на слайд', 'Avto: har slayd {n} soniya', {'n': 'int'})
k('lessonAutoPaused', 'Lesson viewer: status line while auto-advance is paused.',
  'Paused', 'Пауза', 'Pauza')
k('lessonAutoPause', 'Lesson viewer: pause button.', 'Pause', 'Пауза', 'Pauza')
k('lessonAutoResume', 'Lesson viewer: resume button.', 'Resume', 'Продолжить', 'Davom etish')

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
