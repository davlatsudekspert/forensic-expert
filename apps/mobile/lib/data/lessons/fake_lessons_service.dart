import '../../domain/class_quiz/class_quiz_models.dart'
    show ClassFailure, ClassResult;
import '../../domain/lessons/lesson_models.dart';
import '../../domain/ports/lessons_ports.dart';

/// Demo/test adapteri: 2–3 ta kichik namunaviy dars (haqiqiy kontent emas).
class FakeLessonsService implements LessonsService {
  FakeLessonsService({
    this.isTeacher = true,
    this.demo = true,
    Map<String, Map<String, Object?>>? decks,
    this.failure,
    this.openCourses = const {'Apparatlar bilan ishlash'},
  }) : _decks = decks ?? sampleLessonDecks;

  final bool isTeacher;

  /// Ustoz bo‘lmaganga ochiq kurslar (server: `lesson_topics.audience = 'all'`).
  final Set<String> openCourses;
  final bool demo;
  final Map<String, Map<String, Object?>> _decks;

  /// Berilsa — har chaqiruv shu xato bilan tugaydi (offline va h.k. sinovi).
  final ClassFailure? failure;

  /// Chaqiruvlar jurnali (testlar uchun).
  final queries = <String?>[];

  @override
  bool get isConfigured => true;
  @override
  bool get isDemo => demo;

  @override
  Future<ClassResult<List<LessonSummary>>> list({String? query}) async {
    queries.add(query);
    if (failure != null) return ClassResult.fail(failure!);
    final q = (query ?? '').trim().toLowerCase();
    final out = <LessonSummary>[];
    for (final e in _decks.entries) {
      final d = LessonDeck.fromJson(e.value);
      final hay = [
        d.title,
        for (final s in d.slides) ...[
          s.title,
          for (final b in s.bullets) b.text,
        ],
      ].join(' ').toLowerCase();
      if (!isTeacher && !openCourses.contains(d.course)) continue;
      if (q.isEmpty || hay.contains(q)) {
        out.add(
          LessonSummary(
            topicId: e.key,
            deckId: d.deckId,
            course: d.course,
            title: d.title,
            slides: d.slides.length,
          ),
        );
      }
    }
    return ClassResult.ok(out);
  }

  @override
  Future<ClassResult<LessonDeck>> get(String topicId) async {
    if (failure != null) return ClassResult.fail(failure!);
    final j = _decks[topicId];
    if (j == null) return const ClassResult.fail(ClassFailure.notFound);
    final deck = LessonDeck.fromJson(j);
    if (!isTeacher && !openCourses.contains(deck.course)) {
      return const ClassResult.fail(ClassFailure.forbidden);
    }
    return ClassResult.ok(deck);
  }
}

const _src = {'author': 'Namuna A.', 'title': 'Demo darslik', 'page': '12'};

/// Demo ma’lumot (haqiqiy ma’ruza emas): ilovada «DEMO» belgisi bilan ochiladi.
final Map<String, Map<String, Object?>> sampleLessonDecks = {
  'demo-toks': {
    'ok': true,
    'topic_id': 'demo-toks',
    'title': 'DEMO: Toksikologiyaga kirish',
    'course': '4-kurs · Davolash',
    'deck_id': 'demo-toks-1',
    'source_lang': 'uz',
    'deck': {
      'topic': 'DEMO: Toksikologiyaga kirish',
      'slides': [
        {
          'title': 'Zahar tushunchasi',
          'bullets': [
            {
              'text': 'Namuna matn: zahar — organizmga ta’sir etuvchi modda.',
              'source': _src,
              'uncertain': false,
            },
            {
              'text': 'Namuna: ta’sir miqdoriga bog‘liq.',
              'source': _src,
              'uncertain': true,
            },
          ],
          'teacher_notes': 'Vaqt: 5 daq. Savol: dori va zahar farqi nima?',
          'diagram': null,
        },
        {
          'title': 'Omillar guruhlari',
          'bullets': [
            {'text': 'Omillar quyidagi jadvalda.', 'source': _src},
          ],
          'teacher_notes': '',
          'diagram': {
            'kind': 'table',
            'caption': 'Namuna jadval',
            'nodes': <String>[],
            'header': ['Guruh', 'Nimaga bog‘liq'],
            'rows': [
              ['Modda', 'Tuzilishi, miqdori'],
              ['Organizm', 'Vazni, yoshi'],
            ],
          },
        },
        {
          'title': 'Toksikokinetika bosqichlari',
          'bullets': [
            {
              'text': 'Namuna: so‘rilish, tarqalish, almashinuv, chiqarilish.',
              'source': _src,
            },
          ],
          'teacher_notes': 'Doskada sxemani chizing.',
          'diagram': {
            'kind': 'flow',
            'nodes': ['So‘rilish', 'Tarqalish', 'Almashinuv', 'Chiqarilish'],
          },
        },
        {
          'title': 'Toksikologik tahlil bosqichlari',
          'bullets': [
            {
              'text': 'Namuna: tahlil izchil bosqichlardan iborat.',
              'source': _src,
            },
          ],
          'teacher_notes': 'Har bosqichni namuna bilan tushuntiring.',
          'diagram': {
            'kind': 'steps',
            'items': [
              {
                'title': 'Namuna olish',
                'text': 'Ob’ekt va hajm hujjatlashtiriladi.',
              },
              {
                'title': 'Ajratib olish',
                'text': 'Moddani matritsadan ekstraksiya qilish.',
              },
              {
                'title': 'Tozalash',
                'text': 'Halaqit beruvchi aralashmalarni ketkazish.',
              },
              {'title': 'Aniqlash', 'text': 'Skrining va tasdiqlovchi usul.'},
            ],
            'caption': 'Namuna sxema',
          },
        },
        {
          'title': 'Toksikokinetika va toksikodinamika',
          'bullets': [
            {'text': 'Namuna: ikki yondashuvni solishtiring.', 'source': _src},
          ],
          'teacher_notes': '',
          'diagram': {
            'kind': 'compare',
            'columns': [
              {
                'title': 'Toksikokinetika',
                'items': [
                  'Organizm moddaga nima qiladi',
                  'So‘rilish, tarqalish',
                  'Almashinuv, chiqarilish',
                ],
              },
              {
                'title': 'Toksikodinamika',
                'items': [
                  'Modda organizmga nima qiladi',
                  'Retseptor bilan ta’sir',
                  'Zaharli samara mexanizmi',
                ],
              },
            ],
          },
        },
        {
          'title': 'Zaharlarning tasnifi',
          'bullets': [
            {
              'text': 'Namuna: zaharlar ajratish usuli bo‘yicha guruhlanadi.',
              'source': _src,
            },
          ],
          'teacher_notes': '',
          'diagram': {
            'kind': 'tree',
            'root': 'Zaharlar',
            'children': [
              {
                'label': 'Uchuvchan',
                'items': ['Haydash bilan ajratiladi'],
              },
              {
                'label': 'Suvda eruvchan',
                'items': ['Suv ekstrakti'],
              },
              {
                'label': 'Organik erituvchida',
                'items': ['Ekstraksiya bilan'],
              },
              {
                'label': 'Metall birikmalari',
                'items': ['Mineralizatsiya'],
              },
            ],
          },
        },
        {
          'title': 'Namuna ko‘rsatkichlar',
          'bullets': [
            {
              'text': 'Namuna: muhim son ko‘rsatkichlari kartochkalarda.',
              'source': _src,
            },
          ],
          'teacher_notes': 'Bu qiymatlar demo uchun, haqiqiy emas.',
          'diagram': {
            'kind': 'facts',
            'items': [
              {'label': 'Namuna pH', 'value': '7,4'},
              {'label': 'Namuna Rf', 'value': '0,52'},
              {'label': 'Namuna cutoff', 'value': '50', 'unit': 'ng/ml'},
              {'label': 'Namuna hajmi', 'value': '10', 'unit': 'ml'},
            ],
            'caption': 'Demo qiymatlar',
          },
        },
        {
          'title': 'Rangli reaksiya namunasi',
          'bullets': [
            {
              'text': 'Namuna: reagent qo‘shilganda rang o‘zgaradi.',
              'source': _src,
            },
          ],
          'teacher_notes': '',
          'diagram': {
            'kind': 'reaction',
            'reagents': ['Namuna eritmasi', 'Reagent A'],
            'conditions': 'xona harorati, 2 daqiqa',
            'products': ['Rangli kompleks'],
            'observation': 'Eritma ko‘k rangga kiradi',
          },
        },
        {
          'title': 'Metabolizm bosqichlari sikli',
          'bullets': [
            {
              'text': 'Namuna: jarayon aylanma tarzda davom etadi.',
              'source': _src,
            },
          ],
          'teacher_notes': '',
          'diagram': {
            'kind': 'cycle',
            'nodes': [
              'Qabul qilish',
              'Biotransformatsiya',
              'Konyugatsiya',
              'Chiqarilish',
            ],
            'caption': 'Namuna sikl',
          },
        },
      ],
      'extras': [
        {'text': 'Namuna qiziqarli ma’lumot.', 'source': _src},
      ],
      'sources': [
        {
          'author': 'Namuna A.',
          'title': 'Demo darslik',
          'year': 2018,
          'pages': 'Bob 1',
        },
      ],
    },
  },
  'demo-trauma': {
    'ok': true,
    'topic_id': 'demo-trauma',
    'title': 'DEMO: Mexanik jarohatlar tasnifi',
    'course': '4-kurs · Davolash',
    'deck_id': 'demo-trauma-1',
    'source_lang': 'uz',
    'deck': {
      'topic': 'DEMO: Mexanik jarohatlar tasnifi',
      'slides': [
        {
          'title': 'Jarohat turlari',
          'bullets': [
            {
              'text': 'Namuna: shilingan, kesilgan, urilgan jarohatlar.',
              'source': _src,
            },
          ],
          'teacher_notes': 'Rasmlarni proyektorda ko‘rsating.',
        },
      ],
      'extras': <Object>[],
      'sources': [
        {
          'author': 'Namuna A.',
          'title': 'Demo darslik',
          'year': 2018,
          'pages': '12',
        },
      ],
    },
  },
  'demo-asfiksiya': {
    'ok': true,
    'topic_id': 'demo-asfiksiya',
    'title': 'DEMO: Mexanik asfiksiya',
    'course': '5-kurs · Tibbiy-profilaktika',
    'deck_id': 'demo-asf-1',
    'source_lang': 'uz',
    'deck': {
      'topic': 'DEMO: Mexanik asfiksiya',
      'slides': [
        {
          'title': 'Asfiksiya turlari',
          'bullets': [
            {'text': 'Namuna: osilish, bo‘g‘ish, bo‘g‘ilish.', 'source': _src},
          ],
        },
        {
          'title': 'Belgilar',
          'bullets': [
            {'text': 'Namuna: umumiy asfiksiya belgilari.', 'source': _src},
          ],
        },
      ],
    },
  },
};
