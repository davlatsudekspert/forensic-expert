# AI ekrani: server AI ulangan, lekin foydalanuvchi hisobga kirmagan (BACKLOG 4).
import json, collections
D = "lib/core/l10n/arb"
K = collections.OrderedDict()
def k(key, desc, en, ru, uz):
    K[key] = (desc, en, ru, uz)
k("aiSignInTitle","Card title.","Sign in to ask the AI","Войдите, чтобы задать вопрос ИИ","AI’ga savol berish uchun hisobga kiring")
k("aiSignInBody","Card body.","The AI service is connected and answers only from the app's sources, with citations. Asking questions requires a signed-in account; offline source search works without it.","Сервис ИИ подключён и отвечает только по источникам приложения со ссылками. Для вопросов нужен вход в аккаунт; офлайн-поиск источников работает и без него.","AI xizmati ulangan va faqat ilovadagi manbalar asosida, iqtiboslar bilan javob beradi. Savol berish uchun hisobga kirish kerak; manbalarni oflayn qidirish kirmasdan ham ishlaydi.")
k("aiSendSignIn","Hint under the send button.","Sign in to send questions to the AI.","Войдите, чтобы отправлять вопросы ИИ.","Savol yuborish uchun hisobga kiring.")
k("aiStatusSignIn","Header status chip.","Sign-in required","Нужен вход","Hisobga kirish kerak")
for idx, code in enumerate(["en","ru","uz"]):
    p = f"{D}/app_{code}.arb"
    data = json.load(open(p, encoding="utf-8"), object_pairs_hook=collections.OrderedDict)
    for key,(desc,en,ru,uz) in K.items():
        data[key] = (en,ru,uz)[idx]
        if code == "en":
            data["@"+key] = {"description": desc}
    json.dump(data, open(p,"w",encoding="utf-8"), ensure_ascii=False, indent=2)
    open(p,"a").write("\n")
print(len(K), "keys")
