import 'package:flutter/foundation.dart';

/// «Bilim va malakani baholash»: malaka toifalari uchun rasmiy og‘zaki imtihon
/// savollari ro‘yxati. Javoblar rasmiy manbada yo‘q: ular alohida, adabiyot
/// (kitob, bet, iqtibos) asosida yoziladi va to‘qilmaydi.
/// Savollar rasmiy hujjatning o‘zbekcha matni (tarjima qilinmaydi).
@immutable
class AssessmentSource {
  const AssessmentSource({
    required this.publisher,
    required this.title,
    required this.url,
    required this.retrieved,
  });

  factory AssessmentSource.fromJson(Map<String, Object?> j) => AssessmentSource(
    publisher: _s(j['publisher']),
    title: _s(j['title']),
    url: _s(j['url']),
    retrieved: _s(j['retrieved']),
  );

  final String publisher;
  final String title;
  final String url;
  final String retrieved;
}

@immutable
class AssessmentQuestion {
  const AssessmentQuestion({
    required this.id,
    required this.number,
    required this.text,
  });

  factory AssessmentQuestion.fromJson(Map<String, Object?> j) =>
      AssessmentQuestion(
        id: _s(j['id']),
        number: j['n'] is num ? (j['n']! as num).toInt() : 0,
        text: _s(j['text']),
      );

  final String id;
  final int number;
  final String text;
}

/// Malaka toifasi guruhi: `c23` — uchinchi va ikkinchi, `c1` — birinchi,
/// `c0` — oliy.
@immutable
class AssessmentCategory {
  const AssessmentCategory({required this.id, required this.questions});

  factory AssessmentCategory.fromJson(Map<String, Object?> j) =>
      AssessmentCategory(
        id: _s(j['id']),
        questions: [
          for (final q in _list(j['questions']))
            AssessmentQuestion.fromJson(_map(q)),
        ],
      );

  final String id;
  final List<AssessmentQuestion> questions;
}

/// Javob kaliti manbasi: kitob (nom, sahifa, iqtibos) yoki ustoz taqdim etgan
/// kalitli fayl. Kalit bo‘lmasa savol baholanmaydi.
@immutable
class AssessmentKeySource {
  const AssessmentKeySource({
    required this.kind,
    required this.title,
    required this.page,
    required this.quote,
    this.url = '',
  });

  factory AssessmentKeySource.fromJson(Map<String, Object?> j) =>
      AssessmentKeySource(
        kind: _s(j['kind']),
        title: _s(j['title']),
        page: j['page'] is num ? (j['page']! as num).toInt() : 0,
        quote: _s(j['quote']),
        url: _s(j['url']),
      );

  /// `book`, `teacher` yoki `web` (jahon adabiyoti: sarlavha + havola).
  final String kind;
  final String title;
  final int page;
  final String quote;
  final String url;
}

/// Test savoli: 4 variant; [key] — to‘g‘ri variant indeksi (tasdiqlanmagan
/// bo‘lsa `null` va savol baholanadigan mashqqa kirmaydi).
@immutable
class AssessmentTestQuestion {
  const AssessmentTestQuestion({
    required this.id,
    required this.number,
    required this.text,
    required this.options,
    required this.key,
    required this.keySource,
  });

  factory AssessmentTestQuestion.fromJson(Map<String, Object?> j) {
    final k = j['key'];
    final src = j['keySrc'];
    return AssessmentTestQuestion(
      id: _s(j['id']),
      number: j['n'] is num ? (j['n']! as num).toInt() : 0,
      text: _s(j['text']),
      options: [for (final o in _list(j['options'])) _s(o)],
      key: k is num && k >= 0 && k < 4 ? k.toInt() : null,
      keySource: src is Map
          ? AssessmentKeySource.fromJson(src.cast<String, Object?>())
          : null,
    );
  }

  final String id;
  final int number;
  final String text;
  final List<String> options;
  final int? key;
  final AssessmentKeySource? keySource;

  bool get graded => key != null && options.length == 4;
}

@immutable
class AssessmentSpecialty {
  const AssessmentSpecialty({
    required this.id,
    required this.title,
    required this.categories,
    this.tests = const [],
  });

  factory AssessmentSpecialty.fromJson(Map<String, Object?> j) =>
      AssessmentSpecialty(
        id: _s(j['id']),
        title: _s(j['title']),
        categories: [
          for (final c in _list(j['categories']))
            AssessmentCategory.fromJson(_map(c)),
        ],
        tests: [
          for (final t in _list(j['tests']))
            AssessmentTestQuestion.fromJson(_map(t)),
        ],
      );

  final String id;
  final String title;
  final List<AssessmentCategory> categories;
  final List<AssessmentTestQuestion> tests;

  Iterable<AssessmentTestQuestion> get gradedTests =>
      tests.where((t) => t.graded);

  int get total => categories.fold(0, (a, c) => a + c.questions.length);

  AssessmentCategory? category(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }
}

@immutable
class AssessmentBundle {
  const AssessmentBundle({required this.source, required this.specialties});

  factory AssessmentBundle.fromJson(Map<String, Object?> j) => AssessmentBundle(
    source: AssessmentSource.fromJson(_map(j['source'])),
    specialties: [
      for (final s in _list(j['specialties']))
        AssessmentSpecialty.fromJson(_map(s)),
    ],
  );

  static const empty = AssessmentBundle(
    source: AssessmentSource(publisher: '', title: '', url: '', retrieved: ''),
    specialties: [],
  );

  final AssessmentSource source;
  final List<AssessmentSpecialty> specialties;

  AssessmentSpecialty? specialty(String id) {
    for (final s in specialties) {
      if (s.id == id) return s;
    }
    return null;
  }
}

/// Og‘zaki javobda ishlatilgan adabiyot (kitob yoki veb-manba).
@immutable
class OralSource {
  const OralSource({required this.kind, required this.title, this.url = ''});

  factory OralSource.fromJson(Map<String, Object?> j) =>
      OralSource(kind: _s(j['k']), title: _s(j['t']), url: _s(j['u']));

  /// `book` yoki `web`.
  final String kind;
  final String title;
  final String url;
}

/// Javobning bitta bandi: o‘zbekcha matn + asos (adabiyot, bet, iqtibos).
@immutable
class OralPoint {
  const OralPoint({
    required this.text,
    required this.source,
    required this.quote,
    this.page = 0,
    this.url = '',
  });

  factory OralPoint.fromJson(Map<String, Object?> j, List<OralSource> sources) {
    final i = j['s'] is int ? j['s']! as int : -1;
    return OralPoint(
      text: _s(j['t']),
      source: i >= 0 && i < sources.length ? sources[i] : null,
      quote: _s(j['q']),
      page: j['p'] is int ? j['p']! as int : 0,
      url: _s(j['u']),
    );
  }

  final String text;
  final OralSource? source;
  final String quote;
  final int page;
  final String url;
}

/// Savolga adabiyot asosida yozilgan javob.
@immutable
class OralAnswer {
  const OralAnswer({
    required this.full,
    required this.points,
    this.gaps = const [],
  });

  factory OralAnswer.fromJson(
    Map<String, Object?> j,
    List<OralSource> sources,
  ) => OralAnswer(
    full: _s(j['c']) == 'full',
    points: [
      for (final p in _list(j['p'])) OralPoint.fromJson(_map(p), sources),
    ],
    gaps: [for (final g in _list(j['g'])) _s(g)],
  );

  /// `true` — savolning asosiy jihatlari yoritilgan.
  final bool full;
  final List<OralPoint> points;

  /// Adabiyotda yoritilmagan jihatlar (faqat qisman javobda).
  final List<String> gaps;
}

/// Bitta mutaxassislikning og‘zaki javoblari (`oral_<id>.json`).
@immutable
class OralAnswers {
  const OralAnswers({required this.sources, required this.answers});

  factory OralAnswers.fromJson(Map<String, Object?> j) {
    final sources = [
      for (final s in _list(j['sources'])) OralSource.fromJson(_map(s)),
    ];
    final raw = _map(j['answers']);
    return OralAnswers(
      sources: sources,
      answers: {
        for (final e in raw.entries)
          e.key: OralAnswer.fromJson(_map(e.value), sources),
      },
    );
  }

  static const empty = OralAnswers(sources: [], answers: {});

  final List<OralSource> sources;
  final Map<String, OralAnswer> answers;
}

/// Shaxsiy belgi: savolga tayyor («bilaman»). Faqat qurilmada saqlanadi.
abstract interface class AssessmentProgressStore {
  Set<String> load();
  Future<void> save(Set<String> ready);
}

class InMemoryAssessmentProgressStore implements AssessmentProgressStore {
  Set<String> _v = {};

  @override
  Set<String> load() => {..._v};

  @override
  Future<void> save(Set<String> ready) async => _v = {...ready};
}

String _s(Object? v) => v is String ? v : '';
List<Object?> _list(Object? v) => v is List ? v : const [];
Map<String, Object?> _map(Object? v) =>
    v is Map ? v.cast<String, Object?>() : const {};
