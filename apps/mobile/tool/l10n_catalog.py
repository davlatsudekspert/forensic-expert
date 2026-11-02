"""«Ustozlar va mutaxassislar» katalogi + yulduzcha (egasi so‘rovi,
2026-11-02). Tartib: `l10n_admin_tests_profile.py` dan keyin. Idempotent."""
import json, pathlib
D = pathlib.Path(__file__).resolve().parent.parent / 'lib/core/l10n/arb'
K = {
 'catTitle': ('Ustozlar va mutaxassislar', 'Преподаватели и эксперты', 'Teachers and experts'),
 'catHomeHint': ('Eng yaxshilarini toping va yulduzcha bosing', 'Найдите лучших и поставьте звёздочку', 'Find the best and give them a star'),
 'catTabTeachers': ('Ustozlar', 'Преподаватели', 'Teachers'),
 'catTabExperts': ('Mutaxassislar', 'Эксперты', 'Experts'),
 'catSearch': ('Ism yoki ish joyi bo‘yicha qidirish', 'Поиск по имени или месту работы', 'Search by name or workplace'),
 'catSignIn': ('Katalogni ko‘rish va yulduzcha bosish uchun hisobga kiring.', 'Войдите, чтобы смотреть каталог и ставить звёздочки.', 'Sign in to browse the catalogue and give stars.'),
 'catEmptyTeachers': ('Hozircha katalogda ustoz yo‘q. Ustozlar profilida «Katalogda ko‘rsatish»ni yoqishi bilan shu yerda chiqadi.', 'В каталоге пока нет преподавателей. Они появятся, когда включат «Показывать в каталоге» в профиле.', 'No teachers in the catalogue yet. They appear once they turn on “Show in catalogue” in their profile.'),
 'catEmptyExperts': ('Hozircha katalogda mutaxassis yo‘q. Bu yerda faqat tasdiqlangan mutaxassislar chiqadi.', 'В каталоге пока нет экспертов. Здесь показываются только подтверждённые эксперты.', 'No experts in the catalogue yet. Only verified experts appear here.'),
 'catLoadFailed': ('Katalog yuklanmadi. Internetni tekshirib, qayta urining.', 'Каталог не загрузился. Проверьте интернет и повторите.', 'The catalogue did not load. Check your connection and try again.'),
 'catStarFailed': ('Yulduzcha saqlanmadi. Qayta urining.', 'Звёздочка не сохранилась. Повторите.', 'The star was not saved. Try again.'),
 'catStar': ('Yulduzcha bosish', 'Поставить звёздочку', 'Give a star'),
 'catUnstar': ('Yulduzchani olib tashlash', 'Убрать звёздочку', 'Remove star'),
 'catShowMe': ('Katalogda ko‘rsatish', 'Показывать в каталоге', 'Show in catalogue'),
 'catShowMeHint': ('Yoqilsa, hisobga kirgan barcha foydalanuvchilar profilingizni katalogda ko‘radi va yulduzcha bosa oladi. Standart holatda o‘chiq.', 'Если включить, все вошедшие пользователи увидят ваш профиль в каталоге и смогут ставить звёздочки. По умолчанию выключено.', 'When on, all signed-in users can see your profile in the catalogue and give you stars. Off by default.'),
 'catVisibleFailed': ('Sozlama saqlanmadi. Qayta urining.', 'Настройка не сохранилась. Повторите.', 'The setting was not saved. Try again.'),
}
P = {
 'catStarsCount': (('{n} ta yulduzcha', 'Звёздочек: {n}', '{n} stars'), {'n': 'int'}),
}
for i, lang in enumerate(('uz', 'ru', 'en')):
    f = D / f'app_{lang}.arb'
    b = json.loads(f.read_text(encoding='utf-8'))
    for k, v in K.items():
        b[k] = v[i]
        if lang == 'en':
            b['@' + k] = {'description': 'Teachers and experts catalogue with stars.'}
    for k, (v, ph) in P.items():
        b[k] = v[i]
        if lang == 'en':
            b['@' + k] = {'description': 'Catalogue star count.',
                          'placeholders': {n: {'type': t} for n, t in ph.items()}}
    f.write_text(json.dumps(b, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('l10n_catalog:', len(K) + len(P), 'keys')
