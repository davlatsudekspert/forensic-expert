/// Ta’lim (Student Mode) domen modeli.
library;

import 'package:flutter/foundation.dart';

import '../library/library_models.dart';

@immutable
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.lessons,
    required this.isTestData,
  });

  final String id;
  final LocalizedText title;
  final List<Lesson> lessons;
  final bool isTestData;
}

@immutable
class Lesson {
  const Lesson({required this.id, required this.title});

  final String id;
  final LocalizedText title;
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

abstract interface class LearnRepository {
  List<Course> courses();

  List<QuizQuestion> quiz();

  List<Flashcard> flashcards();

  List<CaseStudy> cases();
}
