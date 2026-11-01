"""Murda o‘zgarishlari sxemalari (2026-11-01) — uz/ru/en UI yorliqlari.
Raqamlar manbadan (G‘iyosov 2018, 224–228-betlar); tarjimada o‘zgarmaydi.
Tartib: `l10n_dna.py` dan keyin, `l10n_ux_audit.py` dan oldin. Idempotent."""
import json, pathlib
D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = {
 'pmdTitle': ('Sxema', 'Схема', 'Diagram'),
 'pmdSourceLabel': ('Manba', 'Источник', 'Source'),
 'pmdHoursShort': ('soat', 'ч', 'h'),
 'pmdDaysShort': ('kun', 'сут', 'd'),
 'pmdLivorHypostasis': ('Gipostaz', 'Гипостаз', 'Hypostasis'),
 'pmdLivorStasis': ('Staz', 'Стаз', 'Stasis'),
 'pmdLivorImbibition': ('Imbibitsiya', 'Имбибиция', 'Imbibition'),
 'pmdPressVanish': ('Bosilsa yo‘qoladi, tez tiklanadi', 'При надавливании исчезает и быстро восстанавливается', 'Disappears on pressure, returns quickly'),
 'pmdPressPale': ('Bosilsa oqaradi, sekin tiklanadi', 'При надавливании бледнеет, медленно восстанавливается', 'Blanches on pressure, returns slowly'),
 'pmdPressFixed': ('Bosilsa rangi o‘zgarmaydi', 'При надавливании цвет не меняется', 'Colour does not change on pressure'),
 'pmdLivorNote': ('Bosqichlar orasida aniq chegara yo‘q — ular asta-sekin almashadi.', 'Чёткой границы между стадиями нет — они сменяются постепенно.', 'There is no sharp boundary between the stages; they change gradually.'),
 'pmdLivorColors': ('Rangi o‘lim sababiga bog‘liq', 'Цвет зависит от причины смерти', 'Colour depends on the cause of death'),
 'pmdLivorCo': ('Is gazi — pushti-qizil', 'Угарный газ — розово-красные', 'Carbon monoxide — pink-red'),
 'pmdLivorCn': ('Sianidlar — olcha rang', 'Цианиды — вишнёвые', 'Cyanides — cherry'),
 'pmdLivorMethb': ('Metgemoglobin hosil qiluvchi moddalar — qo‘ng‘ir-jigarrang', 'Метгемоглобинообразователи — буро-коричневые', 'Methaemoglobin formers — brown'),
 'pmdRigorGrowth': ('Rivojlanadi', 'Развивается', 'Develops'),
 'pmdRigorMax': ('Maksimal', 'Максимум', 'Maximum'),
 'pmdRigorResolve': ('Yo‘qoladi', 'Разрешается', 'Resolves'),
 'pmdRigorFacts': ('1–3 soatda aniqlana boshlaydi · 12–16 soatda barcha mushaklarda · 24 soatda maksimal · ikkinchi kunning o‘rtasidan yo‘qola boshlaydi · 3–7 kunda to‘liq yo‘qoladi', 'Выявляется через 1–3 ч · во всех мышцах через 12–16 ч · максимум к 24 ч · с середины вторых суток начинает разрешаться · полностью разрешается за 3–7 сут', 'Detectable at 1–3 h · all muscles by 12–16 h · maximal at 24 h · begins to resolve from mid-day 2 · fully resolved by 3–7 days'),
 'pmdRigorOrder': ('Tartib: chaynash mushaklari → bo‘yin → tana → qo‘llar → oyoqlar (Nisten bo‘yicha pastga yo‘nalgan tip)', 'Порядок: жевательные мышцы → шея → туловище → руки → ноги (нисходящий тип по Нистену)', 'Order: masseters → neck → trunk → arms → legs (Nysten’s descending type)'),
 'pmdAlgorRate': ('Xona sharoitida tana harorati taxminan soatiga 1 °C pasayadi', 'В комнатных условиях температура тела снижается примерно на 1 °C в час', 'In room conditions body temperature falls by about 1 °C per hour'),
 'pmdAlgorEquals': ('Muhit harorati bilan tenglashadi', 'Сравнивается с температурой среды', 'Equals the ambient temperature'),
 'pmdAlgorAxilla': ('Qo‘ltiq osti', 'Подмышечная впадина', 'Axilla'),
 'pmdAlgorRectum': ('To‘g‘ri ichak', 'Прямая кишка', 'Rectum'),
 'pmdAlgorLiver': ('Jigar', 'Печень', 'Liver'),
 'pmdAlgorNote': ('Sovish tezligi havo harorati va namligi, shamol, kiyim, yosh, oziqlanish darajasi va o‘lim sababiga bog‘liq.', 'Скорость охлаждения зависит от температуры и влажности воздуха, ветра, одежды, возраста, упитанности и причины смерти.', 'The cooling rate depends on air temperature and humidity, wind, clothing, age, body build and cause of death.'),
}
for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'))
    for k, v in K.items():
        b[k] = v[i]
        if lang == 'en':
            b['@' + k] = {'description': 'Postmortem change diagram label (source: Giyosov 2018).'}
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('l10n_pm_diagrams:', len(K), 'keys')
