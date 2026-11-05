#!/usr/bin/env python3
"""O‘quv dasturlari («Toksikologik kimyo» ixtisoslashtirish kursi), Mutaxassis
«Ekspertiza yo‘nalishlari» va «Usullar va apparatlar» (egasi, 2026-11-05):
interfeys matnlari (uz/ru/en). Tartib: `l10n_disciplines_preparing.py` dan
keyin, `flutter gen-l10n` dan oldin. Idempotent. Kurs davomiyligi (oy, hafta,
soat, sana) hech qayerda yozilmaydi."""
import collections, json, pathlib

D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = collections.OrderedDict()


def k(key, desc, uz, ru, en, ph=None):
    K[key] = (desc, ph, uz, ru, en)


k('progListTitle', 'Learning programmes: screen and entry title.',
  'O‘quv dasturlari', 'Учебные программы', 'Learning programmes')
k('progListIntro', 'Learning programmes: intro line.',
  'Ixtisoslashtirish kurslari: mavzular katalogi va mavjud materiallar.',
  'Курсы специализации: каталог тем и имеющиеся материалы.',
  'Specialisation courses: topic catalogue and available materials.')
k('progTkTitle', 'Course title: Toxicological chemistry.',
  'Toksikologik kimyo', 'Токсикологическая химия', 'Toxicological chemistry')
k('progTkSubtitle', 'Course description (no duration).',
  'Sud-tibbiy ekspert-kimyogar mutaxassisligi bo‘yicha ixtisoslashtirish kursi',
  'Курс специализации по специальности «судебно-медицинский эксперт-химик»',
  'Specialisation course for forensic medical expert-chemists')
k('progSearchHint', 'Course topic search hint.',
  'Mavzu bo‘yicha qidiring', 'Поиск по темам', 'Search topics')
k('progViewGroups', 'Course view toggle: thematic groups.',
  'Guruhlar', 'Группы', 'Groups')
k('progViewOrder', 'Course view toggle: original programme order.',
  'Dastur tartibi', 'Порядок программы', 'Programme order')
k('progStatusAvailable', 'Topic status: material exists.',
  'Mavjud', 'Есть', 'Available')
k('progStatusPartial', 'Topic status: partial material exists.',
  'Qisman mavjud', 'Частично есть', 'Partly available')
k('progStatusPreparing', 'Topic status: not ready yet.',
  'Tayyorlanmoqda', 'Готовится', 'In preparation')
k('progTopicsCount', 'Number of course topics.',
  '{count} ta mavzu', '{count} тем',
  '{count, plural, =1{1 topic} other{{count} topics}}',
  {'count': 'int'})
k('progSummary', 'Course status summary.',
  'Mavjud: {available} · Qisman: {partial} · Tayyorlanmoqda: {preparing}',
  'Есть: {available} · Частично: {partial} · Готовится: {preparing}',
  'Available: {available} · Partial: {partial} · In preparation: {preparing}',
  {'available': 'int', 'partial': 'int', 'preparing': 'int'})
k('progTitlesUzOnly', 'Note: topic titles are in the original Uzbek programme.',
  'Mavzu nomlari asl dasturdagidek o‘zbek tilida; tarjimasi tayyorlanmoqda.',
  'Названия тем даны как в исходной программе (на узбекском); перевод готовится.',
  'Topic titles are shown as in the original programme (Uzbek); translation is in preparation.')
k('progMaterials', 'Sheet title: existing materials for a topic.',
  'Mavjud materiallar', 'Имеющиеся материалы', 'Available materials')
k('progPartialNote', 'Note: linked materials only partly cover the topic.',
  'Quyidagi materiallar mavzuni qisman qamraydi.',
  'Эти материалы лишь частично охватывают тему.',
  'These materials only partly cover the topic.')
k('progPreparingNote', 'Note: no material for this topic yet.',
  'Bu mavzu bo‘yicha material tayyorlanmoqda.',
  'Материал по этой теме готовится.',
  'Material for this topic is in preparation.')
k('progNoResults', 'Course search: nothing found.',
  'Mavzu topilmadi', 'Тема не найдена', 'No topics found')
k('progTests', 'Course: link to existing forensic chemistry tests.',
  'Mavjud testlar: Sud-kimyo', 'Имеющиеся тесты: судебная химия',
  'Existing tests: forensic chemistry')
k('progProfPrep', 'Section title in the forensic chemistry area.',
  'Kasbiy tayyorgarlik', 'Профессиональная подготовка', 'Professional training')
for i, (uz, ru, en) in enumerate([
    ('Sud-kimyo ekspertizasi va toksikologiya asoslari',
     'Основы судебно-химической экспертизы и токсикологии',
     'Foundations of forensic chemistry and toxicology'),
    ('Biologik namunalar va tahlilga tayyorlash',
     'Биологические образцы и подготовка к анализу',
     'Biological samples and sample preparation'),
    ('Ekstraksiya, ajratish va tozalash usullari',
     'Методы экстракции, выделения и очистки',
     'Extraction, isolation and clean-up methods'),
    ('Analitik tekshiruv usullari va validatsiya',
     'Аналитические методы и валидация',
     'Analytical methods and validation'),
    ('Giyohvandlik vositalari, psixotrop moddalar va dori preparatlari',
     'Наркотические средства, психотропные вещества и лекарственные препараты',
     'Narcotics, psychotropic substances and medicines'),
    ('Zaharli gazlar, metallar va biologik obyektlar',
     'Токсичные газы, металлы и биологические объекты',
     'Toxic gases, metals and biological objects'),
    ('Pestitsidlar, prekursorlar va boshqa maxsus tahlillar',
     'Пестициды, прекурсоры и другие специальные анализы',
     'Pesticides, precursors and other special analyses')], 1):
    k(f'progGroup{i}', f'Course thematic group {i}.', uz, ru, en)

k('areasTitle', 'Mutaxassis home: fields of expertise entry and screen title.',
  'Ekspertiza yo‘nalishlari', 'Направления экспертизы', 'Fields of expertise')
k('areasHomeBody', 'Mutaxassis home: fields of expertise card body.',
  'Sud tibbiyoti, sud-kimyo, sud-biologiya, gistologiya, kriminalistika va boshqalar',
  'Судебная медицина, судебная химия, биология, гистология, криминалистика и др.',
  'Forensic medicine, chemistry, biology, histology, criminalistics and more')
k('areasIntro', 'Fields of expertise screen: intro.',
  'Yo‘nalishni tanlang: mavjud materiallar, vositalar va kurslar shu yerda.',
  'Выберите направление: материалы, инструменты и курсы.',
  'Choose a field: materials, tools and courses are here.')
k('areaHasMaterials', 'Field of expertise: materials exist.',
  'Materiallar bor', 'Есть материалы', 'Materials available')
k('mdTitle', 'Mutaxassis home: methods and instruments entry title.',
  'Usullar va apparatlar', 'Методы и приборы', 'Methods and instruments')
k('mdHomeBody', 'Mutaxassis home: methods and instruments card body.',
  'Usullar va SOP, asbob-uskunalar, virtual autopsiya, GC-MS',
  'Методы и SOP, оборудование, виртуальная аутопсия, GC-MS',
  'Methods and SOPs, equipment, virtual autopsy, GC-MS')
k('mdIntro', 'Methods and instruments screen: intro.',
  'Tahlil usullari, apparatlar va ularning ish tartibi.',
  'Методы анализа, приборы и порядок работы с ними.',
  'Analytical methods, instruments and how to use them.')
k('refsTitle', 'Mutaxassis home: reference section title.',
  'Ma’lumotnomalar', 'Справочники', 'Reference')

for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'),
                   object_pairs_hook=collections.OrderedDict)
    for key, (desc, ph, *vals) in K.items():
        b[key] = vals[i]
        if lang == 'en':
            meta = collections.OrderedDict(description=desc)
            if ph:
                meta['placeholders'] = collections.OrderedDict(
                    (n, collections.OrderedDict(type=t)) for n, t in ph.items())
            b['@' + key] = meta
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n',
                 encoding='utf-8')
print('l10n_programs_areas:', len(K), 'keys')
