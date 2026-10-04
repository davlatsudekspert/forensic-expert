/// Ta’lim (Student Mode) domen modeli.
library;

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/foundation.dart';

import '../knowledge/knowledge_models.dart';
import '../library/library_models.dart';

/// O‘quv darajasi.
enum StudyLevel { foundation, intermediate, advanced }

@immutable
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.lessons,
    required this.isTestData,
    this.level = StudyLevel.foundation,
    this.status = ScientificStatus.needsReview,
  });

  final String id;
  final LocalizedText title;
  final List<Lesson> lessons;
  final bool isTestData;
  final StudyLevel level;

  /// Kurs mazmunining eng zaif statusi (reviewer tasdig‘isiz — NEEDS_REVIEW).
  final ScientificStatus status;
}

@immutable
class Lesson {
  const Lesson({required this.id, required this.title, this.entryId});

  final String id;
  final LocalizedText title;

  /// Dars mazmuni — kontent paketidagi bilim yozuvi (manbali).
  final String? entryId;
}

@immutable
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.stem,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.isTestData,
  });

  final String id;
  final LocalizedText stem;
  final List<LocalizedText> options;
  final int correctIndex;
  final LocalizedText explanation;
  final bool isTestData;
}

@immutable
class Flashcard {
  const Flashcard({
    required this.id,
    required this.front,
    required this.back,
    required this.isTestData,
  });

  final String id;
  final LocalizedText front;
  final LocalizedText back;
  final bool isTestData;
}

@immutable
class CaseStudy {
  const CaseStudy({
    required this.id,
    required this.title,
    required this.isTestData,
  });

  final String id;
  final LocalizedText title;
  final bool isTestData;
}

/// Kontent paketidagi manbali mavzulardan quriladigan o‘quv kursi.
///
/// Yangi ilmiy matn yozilmaydi: har bir dars — mavjud bilim yozuvi
/// (manbadagi asl jumla bilan). Test savollari ham to‘qilmaydi — savollar
/// reviewer tasdiqlagan ta’lim kontenti kelguncha bo‘sh.
class ContentLearnRepository implements LearnRepository {
  ContentLearnRepository(KnowledgeRepository knowledge)
    : _courses = _build(knowledge);

  final List<Course> _courses;

  static List<Course> _build(KnowledgeRepository k) {
    final fm = k.topicsIn(KnowledgeArea.forensicMedicine);
    final bio = k.topicsIn(KnowledgeArea.biochemistry);
    final screening = k.byKind(KnowledgeKind.screeningTest);
    final methods = k.byKind(KnowledgeKind.method);
    Lesson lesson(KnowledgeEntry e) =>
        Lesson(id: 'lesson.${e.id}', title: e.name, entryId: e.id);
    ScientificStatus status(List<KnowledgeEntry> es) =>
        aggregateStatus([for (final e in es) e.status]);
    return [
      if (fm.isNotEmpty || bio.isNotEmpty)
        Course(
          id: 'course.postmortem',
          title: const LocalizedText({
            'en': 'Postmortem changes and PMI — source reading',
            'ru': 'Посмертные изменения и давность смерти — чтение источников',
            'uz': 'O‘limdan keyingi o‘zgarishlar va PMI — manbalarni o‘qish',
          }),
          lessons: [
            for (final e in [...fm, ...bio]) lesson(e),
          ],
          isTestData: [...fm, ...bio].any((e) => e.isTestData),
          status: status([...fm, ...bio]),
        ),
      if (screening.isNotEmpty || methods.isNotEmpty)
        Course(
          id: 'course.screening_confirmation',
          title: const LocalizedText({
            'en': 'Screening vs confirmation — source reading',
            'ru': 'Скрининг и подтверждение — чтение источников',
            'uz': 'Skrining va tasdiqlash — manbalarni o‘qish',
          }),
          level: StudyLevel.intermediate,
          lessons: [
            for (final e in [...screening, ...methods]) lesson(e),
          ],
          isTestData: [...screening, ...methods].any((e) => e.isTestData),
          status: status([...screening, ...methods]),
        ),
    ];
  }

  @override
  List<Course> courses() => _courses;

  @override
  List<QuizQuestion> quiz() => const [];

  @override
  List<Flashcard> flashcards() => const [];

  @override
  List<CaseStudy> cases() => const [];
}

abstract interface class LearnRepository {
  List<Course> courses();

  List<QuizQuestion> quiz();

  List<Flashcard> flashcards();

  List<CaseStudy> cases();
}
