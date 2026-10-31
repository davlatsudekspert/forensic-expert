# «Tinglash» (matnni ovozga aylantirish, Edge Function `tts`) — dars ko‘rgichi. Idempotent.
# CLAUDE.md tartibida l10n_pro_plans.py dan keyin («yangi skriptlar» qatori):
#   cd apps/mobile && python3 tool/l10n_tts.py && flutter gen-l10n
import json, collections, re
D = "lib/core/l10n/arb"
K = collections.OrderedDict()


def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph or {})


k('ttsListen', 'Tooltip of the button that reads the current text aloud.',
  'Listen', 'Слушать', 'Tinglash')
k('ttsPause', 'Tooltip of the button while audio is playing (pauses it).',
  'Pause', 'Пауза', 'Pauza')
k('ttsResume', 'Tooltip of the button while audio is paused (continues it).',
  'Resume', 'Продолжить', 'Davom etish')
k('ttsReplay', 'Tooltip of the button after the audio has finished (plays again).',
  'Listen again', 'Слушать снова', 'Qayta tinglash')
k('ttsLoading', 'Tooltip/status while the audio is being prepared on the server.',
  'Preparing audio…', 'Готовим озвучку…', 'Ovoz tayyorlanmoqda…')
k('ttsErrOffline', 'Snackbar: audio could not be fetched because there is no network.',
  'Audio could not be loaded. Check your internet connection.',
  'Не удалось загрузить озвучку. Проверьте интернет.',
  'Ovoz yuklanmadi. Internetni tekshiring.')
k('ttsErrDailyLimit', 'Snackbar: the daily audio limit is used up.',
  'Today’s audio limit is used up. Try again tomorrow.',
  'Дневной лимит озвучки исчерпан. Попробуйте завтра.',
  'Bugungi ovoz limiti tugadi, ertaga qayta urinib ko‘ring.')
k('ttsErrSignIn', 'Snackbar: listening needs a signed-in account.',
  'Sign in to listen.', 'Войдите в аккаунт, чтобы слушать.',
  'Tinglash uchun hisobingizga kiring.')
k('ttsErrBusy', 'Snackbar: the audio service is temporarily busy or timed out.',
  'The audio service is busy. Try again in a moment.',
  'Сервис озвучки занят. Повторите чуть позже.',
  'Ovoz xizmati band. Birozdan keyin qayta urinib ko‘ring.')
k('ttsErrNotConfigured', 'Snackbar: the audio service is not set up on the server.',
  'The audio service is not available yet.',
  'Сервис озвучки пока недоступен.',
  'Ovoz xizmati hozircha ulanmagan.')
k('ttsErrTooLong', 'Snackbar: the text is too long to be read aloud.',
  'This text is too long to listen to.',
  'Этот текст слишком длинный для озвучки.',
  'Bu matn tinglash uchun juda uzun.')
k('ttsErrGeneric', 'Snackbar: audio could not be played for another reason.',
  'Audio could not be played. Try again.',
  'Не удалось воспроизвести озвучку. Повторите.',
  'Ovoz ijro etilmadi. Qayta urinib ko‘ring.')

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
