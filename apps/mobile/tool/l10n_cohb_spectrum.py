"""Spektrofotometr: COHb/Hb yutilish cho‘qqilari sxemasi; GC-MS: cho‘qqilarni
o‘qish kartasi (egasi talabi, 2026-11-02). Raqamlar: Baizoldanov 2021,
3-qism, 228–229-betlar. Tartib: `l10n_text_size.py` dan keyin. Idempotent."""
import json, pathlib
D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = {
 'cohbSpecTitle': ('Is gazi (COHb): yutilish cho‘qqilari', 'Угарный газ (COHb): максимумы поглощения', 'Carbon monoxide (COHb): absorption peaks'),
 'cohbSpecSemantics': ('Sxema: COHb 541 va 571 nm da ikki cho‘qqi, deoksigemoglobin 557 nm da bitta cho‘qqi; izobestik nuqtalar 550, 565 va 579 nm', 'Схема: COHb — два максимума при 541 и 571 нм, дезоксигемоглобин — один при 557 нм; изобестические точки 550, 565 и 579 нм', 'Diagram: COHb has two peaks at 541 and 571 nm, deoxyhaemoglobin one peak at 557 nm; isosbestic points 550, 565 and 579 nm'),
 'cohbSpecAxis': ('nm', 'нм', 'nm'),
 'cohbSpecIso': ('izobestik nuqtalar', 'изобестические точки', 'isosbestic points'),
 'cohbSpecCohb': ('COHb (karboksigemoglobin) — 540–541 va 570–571 nm da ikki maksimum', 'COHb (карбоксигемоглобин) — два максимума при 540–541 и 570–571 нм', 'COHb (carboxyhaemoglobin) — two maxima at 540–541 and 570–571 nm'),
 'cohbSpecHb': ('Hb (deoksigemoglobin) — 557 nm da bitta maksimum', 'Hb (дезоксигемоглобин) — один максимум при 557 нм', 'Hb (deoxyhaemoglobin) — one maximum at 557 nm'),
 'cohbSpecIsoLegend': ('Izobestik nuqtalar — 550, 565, 579 nm (hisobda 550 nm ishlatiladi)', 'Изобестические точки — 550, 565, 579 нм (в расчёте используется 550 нм)', 'Isosbestic points — 550, 565, 579 nm (550 nm is used in the calculation)'),
 'cohbSpecNote': ('Oksigemoglobin spektri COHbnikiga juda o‘xshaydi (cho‘qqilar 1–2 nm farq qiladi). Shuning uchun natriy ditionit qo‘shiladi: u oksigemoglobinni deoksigemoglobinga aylantiradi, COHb esa o‘zgarmaydi — ikki cho‘qqi saqlansa, COHb bor. Egri chiziqlar shakli — sxema, o‘lchov natijasi emas.', 'Спектр оксигемоглобина очень похож на спектр COHb (максимумы отличаются на 1–2 нм). Поэтому добавляют дитионит натрия: он восстанавливает оксигемоглобин до дезоксигемоглобина, а COHb не меняется — если два максимума сохраняются, COHb присутствует. Форма кривых — схема, а не результат измерения.', 'The oxyhaemoglobin spectrum is very similar to that of COHb (peaks differ by 1–2 nm). Sodium dithionite is therefore added: it reduces oxyhaemoglobin to deoxyhaemoglobin while COHb is unchanged — if two peaks remain, COHb is present. Curve shapes are schematic, not a measurement.'),
 'weHeader': ('Amaliy misol', 'Практический пример', 'Worked example'),
 'weTropicamideTitle': ('Tropikamidni miqdoriy aniqlash (UV-1900i)', 'Количественное определение тропикамида (UV-1900i)', 'Assay of tropicamide (UV-1900i)'),
 'weTropicamideBody': ('Ko‘z tomchisi: ion-juft, xloroform, 408 nm — sxema, kalibrlash chizig‘i va hisob', 'Глазные капли: ионная пара, хлороформ, 408 нм — схема, калибровочный график и расчёт', 'Eye drops: ion pair, chloroform, 408 nm — scheme, calibration line and calculation'),
 'gcmsPeaksTitle': ('Cho‘qqilarni o‘qish', 'Чтение пиков', 'Reading the peaks'),
}
for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'))
    for k, v in K.items():
        b[k] = v[i]
        if lang == 'en':
            b['@' + k] = {'description': 'Equipment page: COHb spectrum diagram / GC-MS peak reading.'}
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('l10n_cohb_spectrum:', len(K), 'keys')
