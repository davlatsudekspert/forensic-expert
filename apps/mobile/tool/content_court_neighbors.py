"""«Sudda so‘roq» → «Qo‘shni davlatlarda» (KZ, KG, TJ). Faqat egasi bergan
rasmiy matn PDF’lari bilan so‘zma-so‘z tasdiqlangan bandlar
(tools/content_pending/neighbors_laws.json, verified_law_pdf=true).
Matn asli o‘zbekcha (ru/en — «tarjima kutilmoqda»). Idempotent."""
import json, pathlib
R = pathlib.Path(__file__).resolve().parents[3]
P = R / 'apps/mobile/assets/content/court_prep/court_prep_v1.json'
d = json.loads(P.read_text(encoding='utf-8'))
U = lambda s: {'uz': s}
REFS = [
 {'key': 'court_kz_expertise_law', 'type': 'law', 'authors': ['Republic of Kazakhstan'],
  'title': 'Закон Республики Казахстан «О судебно-экспертной деятельности» № 44-VI (10.02.2017), ст. 5, 8, 9, 10, 23, 24, 40, 41, 46, 47',
  'publisher': 'adilet.zan.kz', 'year': 2017, 'doi': None, 'pmid': None, 'url': 'https://adilet.zan.kz/rus/docs/Z1700000044',
  'note': 'Russian text with amendments to 14.07.2026 (Law № 350-VIII).', 'used_for': 'KZ comparison',
  'verified_via': 'Owner-supplied PDF of the official full text, verbatim match', 'verified_on': '2026-11-01'},
 {'key': 'court_kg_cpc', 'type': 'law', 'authors': ['Kyrgyz Republic'],
  'title': 'Уголовно-процессуальный кодекс Кыргызской Республики № 129 (28.10.2021), ст. 56, 72, 178, 193',
  'publisher': 'cbd.minjust.gov.kg', 'year': 2021, 'doi': None, 'pmid': None, 'url': 'https://cbd.minjust.gov.kg/',
  'note': 'Edition with amendments of 22.11.2024 № 186 (in force 01.07.2025).', 'used_for': 'KG comparison',
  'verified_via': 'Owner-supplied PDF of the official text, verbatim match', 'verified_on': '2026-11-01'},
 {'key': 'court_kg_cc', 'type': 'law', 'authors': ['Kyrgyz Republic'],
  'title': 'Уголовный кодекс Кыргызской Республики № 127 (28.10.2021), ст. 130, 131, 364',
  'publisher': 'cbd.minjust.gov.kg', 'year': 2021, 'doi': None, 'pmid': None, 'url': 'https://cbd.minjust.gov.kg/',
  'note': 'Edition with amendments of 22.11.2024 № 186.', 'used_for': 'KG comparison',
  'verified_via': 'Owner-supplied PDF of the official text, verbatim match', 'verified_on': '2026-11-01'},
 {'key': 'court_tj_cpc', 'type': 'law', 'authors': ['Republic of Tajikistan'],
  'title': 'Уголовно-процессуальный кодекс Республики Таджикистан (2009), ст. 58, 69, 208, 209, 217',
  'publisher': 'Ахбори Маджлиси Оли Республики Таджикистан', 'year': 2009, 'doi': None, 'pmid': None, 'url': 'https://www.adlia.tj/',
  'note': 'Russian text with amendments (owner-supplied PDF, 2024 edition).', 'used_for': 'TJ comparison',
  'verified_via': 'Owner-supplied PDF of the official text, verbatim match', 'verified_on': '2026-11-01'},
 {'key': 'court_tj_cc', 'type': 'law', 'authors': ['Republic of Tajikistan'],
  'title': 'Уголовный кодекс Республики Таджикистан (1998), ст. 110–112, 351, 352',
  'publisher': 'Ахбори Маджлиси Оли Республики Таджикистан', 'year': 1998, 'doi': None, 'pmid': None, 'url': 'https://www.adlia.tj/',
  'note': 'Russian text (owner-supplied PDF, WIPO Lex copy).', 'used_for': 'TJ comparison',
  'verified_via': 'Owner-supplied PDF of the official text, verbatim match', 'verified_on': '2026-11-01'},
]
def q(id_, country, short, tests, docs, explain, pit, fu, lim, cits, locs):
    return {'id': id_, 'jurisdiction': 'ALL', 'status': 'NEEDS_REVIEW',
     'question': U(f'{country}da sud eksperti qanday qoidalarga bo‘ysunadi va bu O‘zbekistondan nimasi bilan farq qiladi?'),
     'tests': U(tests), 'short_answer': U(short),
     'prepare': {'documents': [U(x) for x in docs], 'explain': [U(x) for x in explain], 'pitfalls': [U(x) for x in pit]},
     'followups': [{'q': U(a), 'a': U(b)} for a, b in fu],
     'limitations': [U(x) for x in lim], 'links': [], 'citations': cits, 'locators': locs,
     'topic': 'court.topic.neighbors', 'sample': False, 'updated': '2026-11-01',
     'translation_status': {'uz': 'AUTHORED'},
     'claims': [{'id': f'{id_}.short_answer', 'sources': [{'key': k, 'locator': locs[k], 'support': 'full'} for k in cits]}]}
Q = [
 q('court.q.neighbors_kz', 'Qozog‘iston',
   'Qozog‘istonda sud-ekspertlik faoliyati alohida qonun bilan tartibga solinadi (№ 44-VI, 2017). Asosiy tamoyillar: qonuniylik, ekspert mustaqilligi, tadqiqotning har tomonlama, to‘liq, xolis va ilmiy asoslanganligi [court_kz_expertise_law]. Ekspert ekspertizani tayinlagan organdan mustaqil; xulosa tekshirib ko‘rish mumkin bo‘lgan qoidalarga asoslanishi va davlat reestriga kiritilgan metodikalar bilan bajarilishi kerak [court_kz_expertise_law]. Xulosa berilguncha ekspertni so‘roq qilish taqiqlanadi [court_kz_expertise_law].',
   'Ekspert qo‘shni davlat qonunidagi asosiy talablarni bilib, o‘z amaliyotini ular bilan solishtira oladimi [court_kz_expertise_law].',
   ['Agar savollar bilimingizdan tashqarida bo‘lsa — xulosa berish imkonsizligi haqidagi xabar (40-modda) [court_kz_expertise_law].'],
   ['Ekspert ish materiallari bilan tanishish va qo‘shimcha material so‘rash huquqiga ega (23-modda) [court_kz_expertise_law].',
    'Tirik shaxs sud-tibbiy ekspertizasida bilib qolgan, xulosaga aloqasi yo‘q holatlar bo‘yicha ekspert so‘roq qilinmaydi (41-modda 3-band) [court_kz_expertise_law].'],
   ['Ekspertning o‘zi tadqiqot uchun material yig‘ishi taqiqlanadi (23-modda 2-band) [court_kz_expertise_law].'],
   [('Shaxsni statsionar ekspertizaga majburan joylash mumkinmi?', 'Qamoqda bo‘lmagan shaxsni sud-tibbiy yoki sud-psixiatrik ekspertiza uchun majburan joylash faqat sud qarori bilan; muddat — odatda 30 sutkagacha (46–47-moddalar) [court_kz_expertise_law].'),
    ('Ekspert savol bilimidan tashqarida bo‘lsa nima qiladi?', 'Tadqiqotdan oldin buni aniqlasa, xulosa berish imkonsizligi haqida yozma xabar beradi (40-modda) [court_kz_expertise_law].')],
   ['Karta Qozog‘istonning «Sud-ekspertlik faoliyati to‘g‘risida»gi qonuni (№ 44-VI) rasmiy matni asosida; qonunga keyingi o‘zgartishlar adilet.zan.kz da kuzatiladi.'],
   ['court_kz_expertise_law'], {'court_kz_expertise_law': ['art:5', 'art:8', 'art:9', 'art:10', 'art:23', 'art:40', 'art:41', 'art:46', 'art:47']}),
 q('court.q.neighbors_kg', 'Qirg‘iziston',
   'Qirg‘izistonda ekspert maqomi Jinoyat-protsessual kodeksida (№ 129, 2021) belgilangan: ekspert fan, texnika yoki san’at sohasida maxsus bilimga ega bo‘lishi, ishda manfaatdor bo‘lmasligi kerak (56-modda) [court_kg_cpc]. Ekspert ish materiallari bilan tanishadi, qo‘shimcha material so‘raydi va savollar bilimidan tashqarida bo‘lsa xulosa berishdan bosh tortishi mumkin; u xolis xulosa berishga majbur [court_kg_cpc]. Zarar og‘irligini aniqlash uchun ekspertiza majburiy (178-modda) [court_kg_cpc]; og‘ir zarar mezoni — hayot uchun xavfli shikast yoki mehnat qobiliyatining kamida 1/3 qismi doimiy yo‘qolishi (UK 130-modda) [court_kg_cc].',
   'Ekspert qo‘shni davlatdagi huquq, majburiyat va javobgarlik qoidalarini O‘zbekiston bilan solishtira oladimi [court_kg_cpc].',
   ['Jinoiy javobgarlik haqida ogohlantirilganlik to‘g‘risidagi tilxat (UPK 193-modda) [court_kg_cpc].'],
   ['Ekspertiza davlat va nodavlat ekspert tashkilotlarida o‘tkazilishi mumkin (178–185-moddalar) [court_kg_cpc].',
    'Ekspert ish ishtirokchilari bilan ekspertiza bo‘yicha muzokara olib bormasligi kerak (56-modda) [court_kg_cpc].'],
   ['Ekspertiza savollari kompetensiyangizga kirmasa — rad etish asosi (72-modda) [court_kg_cpc].'],
   [('Yolg‘on xulosa uchun javobgarlik qayerda?', 'UPK 56-moddasiga ko‘ra ekspert Jinoyat kodeksining 364-moddasi bo‘yicha javob beradi [court_kg_cpc].'),
    ('Menga hamma narsa aniq bo‘lmasa-chi?', 'Savollar maxsus bilimingizdan tashqarida bo‘lsa, xulosa berishdan bosh tortish huquqingiz bor (56-modda) [court_kg_cpc].')],
   ['Karta Qirg‘iziston JPK (№ 129) va JK (№ 127) rasmiy matni asosida; keyingi o‘zgartishlar cbd.minjust.gov.kg da kuzatiladi.'],
   ['court_kg_cpc', 'court_kg_cc'], {'court_kg_cpc': ['art:56', 'art:72', 'art:178', 'art:193'], 'court_kg_cc': ['art:130', 'art:364']}),
 q('court.q.neighbors_tj', 'Tojikiston',
   'Tojikistonda ekspert dastlabki tergov va sudda maxsus bilim kerak bo‘lganda chaqiriladi (UPK 58-modda) [court_tj_cpc]. Ekspert ish materiallari bilan tanishadi, savollar bilimidan tashqarida bo‘lsa xulosa berishdan bosh tortishi mumkin va asoslangan, xolis yozma xulosa berishga majbur [court_tj_cpc]. Tan jarohatlarining xususiyati va og‘irligini aniqlash uchun ekspertiza majburiy (209-modda) [court_tj_cpc]; yolg‘on xulosa uchun javobgarlik — Jinoyat kodeksining 351–352-moddalari [court_tj_cc].',
   'Ekspert qo‘shni davlatdagi asosiy protsessual qoidalarni O‘zbekiston bilan solishtira oladimi [court_tj_cpc].',
   ['Ekspertiza tayinlash to‘g‘risidagi qaror: asoslar, savollar va beriladigan materiallar ko‘rsatilgan bo‘lishi kerak (208-modda) [court_tj_cpc].'],
   ['Ekspertiza ekspert muassasalari, boshqa davlat yoki nodavlat muassasalar mutaxassislari tomonidan o‘tkazilishi mumkin (208-modda 3-qism) [court_tj_cpc].',
    'Xulosada ekspertga qo‘yilgan savollar va ularga asoslangan javoblar bo‘lishi shart (217-modda) [court_tj_cpc].'],
   ['Ekspert noma’lum qilmasdan ishtirokchilar bilan ekspertiza bo‘yicha muloqot qilmasligi kerak (58-modda 5-qism) [court_tj_cpc].'],
   [('Ekspert qachon rad etiladi?', 'Uning nokompetentligi aniqlanganda ham ekspert rad etiladi (69-modda) [court_tj_cpc].'),
    ('Zarar og‘irligi qaysi moddada?', 'Og‘ir, o‘rtacha va yengil zarar — Jinoyat kodeksining 110–112-moddalari [court_tj_cc].')],
   ['Karta Tojikiston JPK va JK rasmiy matni asosida; keyingi o‘zgartishlar adlia.tj da kuzatiladi.'],
   ['court_tj_cpc', 'court_tj_cc'], {'court_tj_cpc': ['art:58', 'art:69', 'art:208', 'art:209', 'art:217'], 'court_tj_cc': ['art:110', 'art:351', 'art:352']}),
]
d['questions'] = [x for x in d['questions'] if not x['id'].startswith('court.q.neighbors_')] + Q
keys = {r['key'] for r in REFS}
d['references'] = [r for r in d['references'] if r['key'] not in keys] + REFS
d['topics'] = [t for t in d['topics'] if t['id'] != 'court.topic.neighbors'] + [{
  'id': 'court.topic.neighbors', 'order': max(t['order'] for t in d['topics']) + 1, 'icon': 'public',
  'title': U('Qo‘shni davlatlarda (Qozog‘iston, Qirg‘iziston, Tojikiston)'),
  'summary': U('Ekspert huquqlari, majburiyatlari va javobgarligi — faqat rasmiy matn bilan tasdiqlangan moddalar.'),
  'pending': False, 'question_ids': [x['id'] for x in Q]}]
P.write_text(json.dumps(d, ensure_ascii=False, indent=1) + '\n', encoding='utf-8')
print('neighbors added:', len(Q))
