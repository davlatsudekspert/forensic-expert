#!/usr/bin/env python3
"""«Tasdiqlangan manba» yozuvlari (uz/ru/en): ABY va ustoz kitoblari uchun.

Egasi qarori (2026-10-12): u bergan manbalar — milliy yo'riqnoma (ABY) va
ustoz kitoblari — ekranda tasdiqlangan manba deb ko'rsatiladi; xorijiy
maqola va tezislar «tasdiqlash kerak» bo'lib qoladi. Bu manba haqida; da'voning
ichki taqriz holatiga tegmaydi.
"""
import json, pathlib
ARB = pathlib.Path(__file__).resolve().parent.parent / "lib/core/l10n/arb"
K = {
 "confirmedSourceBanner": {
  "uz": "Tasdiqlangan manba asosida: milliy yo‘riqnoma (ABY) yoki ustoz kitobi. Aniq joyi ko‘rsatilgan.",
  "ru": "На основе подтверждённого источника: национальное руководство (ABY) или учебник преподавателя. Точное место указано.",
  "en": "Based on a confirmed source: the national guide (ABY) or the teacher's textbook. The exact place is given."},
 "confirmedSourceChip": {
  "uz": "Tasdiqlangan manba", "ru": "Подтверждённый источник", "en": "Confirmed source"},
 "needsConfirmationChip": {
  "uz": "Tasdiqlash kerak", "ru": "Требует подтверждения", "en": "Needs confirmation"},
 "needsConfirmationBanner": {
  "uz": "Xalqaro adabiyotdan (maqola, tezis): tasdiqlash kerak.",
  "ru": "Из международной литературы (статья, тезис): требует подтверждения.",
  "en": "From international literature (article, thesis): needs confirmation."},
}
D = {"confirmedSourceBanner":"Banner for claims resting on an owner-confirmed source.",
     "confirmedSourceChip":"Chip: the claim's source is confirmed.",
     "needsConfirmationChip":"Chip: a claim from international literature still needs confirmation.",
     "needsConfirmationBanner":"Banner for claims from international literature."}
for lang in ("uz","ru","en"):
    p=ARB/f"app_{lang}.arb"; d=json.loads(p.read_text(encoding="utf-8"))
    for k,v in K.items():
        d.setdefault(k,v[lang])
        if lang=="en": d.setdefault("@"+k,{"description":D[k]})
    p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
print("ok")
