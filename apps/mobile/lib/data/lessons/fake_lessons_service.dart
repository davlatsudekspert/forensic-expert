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
  }) : _decks = decks ?? sampleLessonDecks;

  final bool isTeacher;
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
    if (!isTeacher) return const ClassResult.fail(ClassFailure.forbidden);
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
    if (!isTeacher) return const ClassResult.fail(ClassFailure.forbidden);
    final j = _decks[topicId];
    if (j == null) return const ClassResult.fail(ClassFailure.notFound);
    return ClassResult.ok(LessonDeck.fromJson(j));
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
