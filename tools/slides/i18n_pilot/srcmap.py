"""Manba (bibliografiya) lokalizatsiyasi: joylashuv iboralari, sarlavha tarjimasi, mualliflar."""
import copy
LOC = {
 '7-bob (bet 89, 99-101), 8-bob (bet 147, 158-160)': {'ru': 'гл. 7 (с. 89, 99-101), гл. 8 (с. 147, 158-160)', 'en': 'ch. 7 (pp. 89, 99-101), ch. 8 (pp. 147, 158-160)'},
 'Bob 2. Sud-tibbiy travmatologiya (qisman mos)': {'ru': 'Гл. 2. Судебно-медицинская травматология (частично соответствует)', 'en': 'Ch. 2. Forensic traumatology (partly relevant)'},
 'XV-bob (bet 474-476), fizik omillar (bet 237)': {'ru': 'гл. XV (с. 474-476), физические факторы (с. 237)', 'en': 'ch. XV (pp. 474-476), physical factors (p. 237)'},
 'ma’ruza matni': {'ru': 'текст лекции', 'en': 'lecture text'},
 'qo‘shimcha ma’lumot (kitobda bo‘lmagan joylar uchun)': {'ru': 'дополнительные сведения (для мест, отсутствующих в книге)', 'en': 'additional information (for points not covered in the book)'},
 'b. 89, 93, 96, 101, 103-106, 108': {'ru': 'с. 89, 93, 96, 101, 103-106, 108', 'en': 'pp. 89, 93, 96, 101, 103-106, 108'},
 'b. 106-107': {'ru': 'с. 106-107', 'en': 'pp. 106-107'},
}
TITLE = {
 'Sud tibbiyoti: darslik, Toshkent: Global Books nashriyoti': {'ru': 'Судебная медицина: учебник, Ташкент: Global Books', 'en': 'Forensic Medicine: textbook, Tashkent: Global Books Publishing'},
 'Sud tibbiyoti (tibbiyot instituti talabalari uchun), Toshkent (egasi taqdim etgan; yopiq foydalanish)': {'ru': 'Судебная медицина (для студентов медицинского института), Ташкент', 'en': 'Forensic Medicine (for medical institute students), Tashkent'},
 'Судебная медицина: учебник для вузов, М.: ГЭОТАР-МЕД (egasi taqdim etgan; yopiq foydalanish)': {'ru': 'Судебная медицина: учебник для вузов, М.: ГЭОТАР-МЕД', 'en': 'Forensic Medicine: textbook for universities, Moscow: GEOTAR-MED'},
 'Toksikologik kimyo modulidan o‘quv-uslubiy majmua (Farmatsiya). Toshkent farmatsevtika instituti, 2025': {'ru': 'Учебно-методический комплекс по модулю «Токсикологическая химия» (Фармация). Ташкентский фармацевтический институт, 2025', 'en': 'Teaching and methodological package for the module “Toxicological Chemistry” (Pharmacy). Tashkent Pharmaceutical Institute, 2025'},
 'Toksikologik kimyo modulidan o‘quv-uslubiy majmua (DVSSM). Toshkent farmatsevtika instituti, 2025': {'ru': 'Учебно-методический комплекс по модулю «Токсикологическая химия» (ДВССМ). Ташкентский фармацевтический институт, 2025', 'en': 'Teaching and methodological package for the module “Toxicological Chemistry” (DVSSM). Tashkent Pharmaceutical Institute, 2025'},
 '3-ma’ruza: Ksantin hosilalari (ma’ruza)': {'ru': 'Лекция 3: Производные ксантина (лекция)', 'en': 'Lecture 3: Xanthine derivatives (lecture)'},
}
AUTH = {
 'G‘iyosov Z.A.': {'ru': 'Гиёсов З.А.', 'en': 'Giyosov Z.A.'},
 'Iskandarov A.I., Qo‘ldoshev D.R.': {'ru': 'Искандаров А.И., Кулдошев Д.Р.', 'en': 'Iskandarov A.I., Qoldoshev D.R.'},
 'Пиголкин Ю.И., Баринов Е.Х., Богомолов Д.В., Богомолова И.Н.': {'en': 'Pigolkin Yu.I., Barinov E.Kh., Bogomolov D.V., Bogomolova I.N.'},
 'Yuldashev Z.A., Umarova G.Q.': {'ru': 'Юлдашев З.А., Умарова Г.К.', 'en': 'Yuldashev Z.A., Umarova G.Q.'},
 'Yuldashev Z.A., Nurmatova M.I.': {'ru': 'Юлдашев З.А., Нурматова М.И.', 'en': 'Yuldashev Z.A., Nurmatova M.I.'},
 'Malaka materiali №058 (TFI Toksikologik kimyo kafedrasi)': {'ru': 'Квалификационный материал № 058 (кафедра токсикологической химии ТФИ)', 'en': 'Qualification material No. 058 (TPI Department of Toxicological Chemistry)'},
}
def localize(deck, lang):
    d = copy.deepcopy(deck)
    def fix(src):
        if not isinstance(src, dict): return
        a = src.get('author')
        if a in AUTH and lang in AUTH[a]: src['author'] = AUTH[a][lang]
        t = src.get('title')
        if t in TITLE and lang in TITLE[t]: src['title'] = TITLE[t][lang]
        pg = src.get('page')
        if isinstance(pg, str) and pg in LOC: src['page'] = LOC[pg][lang]
    for sl in d['slides']:
        for b in sl['bullets']: fix(b.get('source'))
    for e in d.get('extras', []): fix(e.get('source'))
    for s in d['sources']:
        t = s.get('title')
        if t in TITLE and lang in TITLE[t]: s['title_tr'] = TITLE[t][lang]
        a = s.get('author')
        if a in AUTH and lang in AUTH[a]: s['author'] = AUTH[a][lang]
        if s.get('pages') in LOC: s['pages'] = LOC[s['pages']][lang]
    return d
