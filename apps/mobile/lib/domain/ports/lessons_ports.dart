import '../class_quiz/class_quiz_models.dart' show ClassFailure, ClassResult;
import '../lessons/lesson_models.dart';

/// «Darslar» xizmati (faqat ustoz). Rol tekshiruvi serverda (`forbidden`).
abstract interface class LessonsService {
  bool get isConfigured;

  /// Demo (Fake) — ma’lumot faqat shu qurilmada.
  bool get isDemo;

  /// Ro‘yxat; [query] — server qidiruvi (sarlavha va slayd matni).
  Future<ClassResult<List<LessonSummary>>> list({String? query});

  Future<ClassResult<LessonDeck>> get(String topicId);
}

/// Backend yo‘q — hech narsa soxtalashtirilmaydi.
class UnconfiguredLessonsService implements LessonsService {
  const UnconfiguredLessonsService();

  @override
  bool get isConfigured => false;
  @override
  bool get isDemo => false;

  @override
  Future<ClassResult<List<LessonSummary>>> list({String? query}) async =>
      const ClassResult.fail(ClassFailure.notConfigured);

  @override
  Future<ClassResult<LessonDeck>> get(String topicId) async =>
      const ClassResult.fail(ClassFailure.notConfigured);
}
