# AI ekrani: holat va xato xabarlari (BlueStacks YuQX muammosidan keyin).
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz, ph=None):
    K[key] = (desc, en, ru, uz, ph)
I = {"type": "int"}
k("aiWorking","Progress.","Preparing an answer from sources… This can take up to a minute.","Готовим ответ по источникам… Это может занять до минуты.","Manbalar asosida javob tayyorlanmoqda… Bu bir daqiqagacha cho‘zilishi mumkin.")
k("aiSearchingOffline","Progress.","Searching the offline database…","Поиск в офлайн-базе…","Oflayn bazadan qidirilmoqda…")
k("aiNotCovered","Banner.","The sources in the app do not cover this question well enough, so no sourced answer was produced.","Источники в приложении недостаточно освещают этот вопрос, поэтому ответ со ссылками не сформирован.","Ilovadagi manbalar bu savolni yetarli darajada qamrab olmaydi, shuning uchun manbali javob tuzilmadi.")
k("aiModelNoteTitle","Header.","AI note (no sources — do not rely on it)","Комментарий ИИ (без источников — не опирайтесь на него)","AI izohi (manbasiz — unga tayanmang)")
k("aiAnswerRejected","Banner.","The AI answer was not shown because it could not be verified against the app's sources.","Ответ ИИ не показан: его не удалось проверить по источникам приложения.","AI javobi ko‘rsatilmadi: uni ilovadagi manbalar bilan tasdiqlab bo‘lmadi.")
k("aiErrRateLimited","Banner.","The hourly limit of AI questions has been reached. Please try again later.","Достигнут часовой лимит вопросов к ИИ. Повторите попытку позже.","AI savollarining soatlik limiti tugadi. Birozdan keyin qayta urinib ko‘ring.")
k("aiErrSignIn","Banner.","Your session has expired. Please sign in again to use AI.","Сессия истекла. Войдите снова, чтобы пользоваться ИИ.","Sessiya muddati tugadi. AI’dan foydalanish uchun qayta kiring.")
k("aiErrOffline","Banner.","No connection to the AI service. Check the internet connection.","Нет связи с сервисом ИИ. Проверьте подключение к интернету.","AI xizmati bilan aloqa yo‘q. Internet aloqasini tekshiring.")
k("aiErrServer","Banner.","The AI service is temporarily unavailable. Please try again later.","Сервис ИИ временно недоступен. Повторите попытку позже.","AI xizmati vaqtincha ishlamayapti. Birozdan keyin qayta urinib ko‘ring.")
k("aiErrNotConfigured","Banner.","The AI service is not configured on the server yet.","Сервис ИИ на сервере ещё не настроен.","AI xizmati serverda hali sozlanmagan.")
k("aiQuotaUsed","Banner.","Your AI question allowance is used up for now.","Ваш лимит вопросов к ИИ пока исчерпан.","AI savollari bo‘yicha limitingiz hozircha tugagan.")
k("aiOfflineSourcesTitle","Header.","Sources found in the offline database","Источники из офлайн-базы","Oflayn bazadan topilgan manbalar")
k("aiOfflineSourcesCount","Expander.","Sources used ({count})","Использованные источники ({count})","Foydalanilgan manbalar ({count})",{"count":I})
k("aiRetry","Action.","Try again","Повторить","Qayta urinish")
for idx, code in enumerate(["en","ru","uz"]):
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key,(desc,en,ru,uz,ph) in K.items():
        data[key] = (en,ru,uz)[idx]
        if code == "en":
            meta = {"description": desc}
            if ph: meta["placeholders"] = ph
            data["@"+key] = meta
    json.dump(data, open(p,"w",encoding="utf-8"), ensure_ascii=False, indent=2)
    open(p,"a").write("\n")
print(len(K), "keys")
