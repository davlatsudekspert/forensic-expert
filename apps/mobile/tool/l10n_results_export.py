#!/usr/bin/env python3
"""Natijalarni Excel/PDF/CSV ga saqlash varag‘i matnlari (uz/ru/en). Idempotent."""
import collections, json, pathlib
D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = collections.OrderedDict()
def k(key, desc, uz, ru, en): K[key] = (desc, uz, ru, en)
k('resultsExportExcel', 'Results export: Excel option.', 'Excel (.xlsx)', 'Excel (.xlsx)', 'Excel (.xlsx)')
k('resultsExportExcelBody', 'Results export: Excel hint.', 'Jadval: saralash va tahrirlash uchun', 'Таблица: для сортировки и редактирования', 'Spreadsheet: for sorting and editing')
k('resultsExportPdf', 'Results export: PDF option.', 'PDF', 'PDF', 'PDF')
k('resultsExportPdfBody', 'Results export: PDF hint.', 'Chop etish va yuborish uchun', 'Для печати и отправки', 'For printing and sending')
k('resultsExportCsv', 'Results export: CSV option.', 'CSV', 'CSV', 'CSV')
k('resultsExportCsvBody', 'Results export: CSV hint.', 'Oddiy matnli jadval', 'Простая текстовая таблица', 'Plain-text table')
for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'), object_pairs_hook=collections.OrderedDict)
    for key, (desc, *vals) in K.items():
        b[key] = vals[i]
        if lang == 'en': b['@' + key] = collections.OrderedDict(description=desc)
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('l10n_results_export:', len(K), 'keys')
