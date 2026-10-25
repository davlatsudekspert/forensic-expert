import 'package:flutter/foundation.dart';

/// «Bilim va malakani baholash»: malaka toifalari uchun rasmiy og‘zaki imtihon
/// savollari ro‘yxati. Faqat savollar — javoblar manbada yo‘q va to‘qilmaydi.
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
