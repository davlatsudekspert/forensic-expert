import '../class_quiz/class_quiz_models.dart';

/// «Sinfda test» xizmati. Barcha qarorlar (rol, ball, vaqt, to‘g‘ri javobni
/// ochish, chegaralar) serverda; mijoz faqat so‘raydi.
abstract interface class ClassQuizService {
  /// Backend ulanganmi (aks holda UI halol «ulanmagan» holatini ko‘rsatadi).
  bool get isConfigured;

  /// Demo (Fake) adapter — ma’lumot faqat shu qurilmada; UI buni belgilaydi.
  bool get isDemo;

  /// Qo‘shilish uchun hisobga kirish shartmi (haqiqiy server: ha).
  bool get requiresSignIn;

  // ---- umumiy
  Future<ClassResult<ClassQuizMe>> me();

  // ---- ustoz
  Future<ClassResult<List<ClassTopic>>> topics();

  Future<ClassResult<ClassSessionInfo>> createSession({
    required String topicId,
    required ClassQuizSettings settings,
  });

  Future<ClassResult<List<ClassSessionInfo>>> mySessions();

  Future<ClassResult<ClassDashboard>> dashboard(String sessionId);

  Future<ClassResult<void>> start(String sessionId);

  /// Keyingi savol; oxirgisidan keyin sessiya tugaydi.
  Future<ClassResult<bool>> next(String sessionId);

  /// Hozirgi savolni muddatidan oldin yopadi.
  Future<ClassResult<void>> closeQuestion(String sessionId);

  Future<ClassResult<void>> finish(String sessionId);

  Future<ClassResult<void>> kick(String sessionId, String participantId);

  Future<ClassResult<ClassExport>> exportResults(String sessionId);

  /// «Qiyin savollar» muhokamasi: variantlar, to‘g‘ri javob, izoh, manba.
  /// Faqat ustoz, faqat sessiya tugagach (aks holda `notFinished`/`forbidden`).
  Future<ClassResult<List<ClassHardDetail>>> hardestDetail(
    String sessionId, {
    int limit = 5,
  });

  // ---- talaba
  Future<ClassResult<ClassJoinInfo>> join({
    required String code,
    required String nickname,
  });

  Future<ClassResult<ClassStudentState>> state(String sessionId);

  /// To‘g‘ri/noto‘g‘ri javob qaytarilmaydi — faqat qabul qilindimi.
  Future<ClassResult<void>> submitAnswer({
    required String sessionId,
    required int questionIndex,
    required String optionId,
  });

  Future<ClassResult<ClassMyResults>> myResults(String sessionId);

  /// Laqabga shikoyat (UGC, App Store 1.2).
  Future<ClassResult<void>> reportNickname({
    required String sessionId,
    required String participantId,
    required String reason,
  });
}

/// Backend yo‘q — hech narsa soxtalashtirilmaydi.
class UnconfiguredClassQuizService implements ClassQuizService {
  const UnconfiguredClassQuizService();

  static const _f = ClassFailure.notConfigured;

  @override
  bool get isConfigured => false;
  @override
  bool get isDemo => false;
  @override
  bool get requiresSignIn => true;

  @override
  Future<ClassResult<ClassQuizMe>> me() async => const ClassResult.fail(_f);
  @override
  Future<ClassResult<List<ClassTopic>>> topics() async =>
      const ClassResult.fail(_f);
  @override
  Future<ClassResult<ClassSessionInfo>> createSession({
    required String topicId,
    required ClassQuizSettings settings,
  }) async => const ClassResult.fail(_f);
  @override
  Future<ClassResult<List<ClassSessionInfo>>> mySessions() async =>
      const ClassResult.fail(_f);
  @override
  Future<ClassResult<ClassDashboard>> dashboard(String sessionId) async =>
      const ClassResult.fail(_f);
  @override
  Future<ClassResult<void>> start(String sessionId) async =>
      const ClassResult.fail(_f);
  @override
  Future<ClassResult<bool>> next(String sessionId) async =>
      const ClassResult.fail(_f);
  @override
  Future<ClassResult<void>> closeQuestion(String sessionId) async =>
      const ClassResult.fail(_f);
  @override
  Future<ClassResult<void>> finish(String sessionId) async =>
      const ClassResult.fail(_f);
  @override
  Future<ClassResult<void>> kick(
    String sessionId,
    String participantId,
  ) async => const ClassResult.fail(_f);
  @override
  Future<ClassResult<ClassExport>> exportResults(String sessionId) async =>
      const ClassResult.fail(_f);
  @override
  Future<ClassResult<List<ClassHardDetail>>> hardestDetail(
    String sessionId, {
    int limit = 5,
  }) async => const ClassResult.fail(_f);
  @override
  Future<ClassResult<ClassJoinInfo>> join({
    required String code,
    required String nickname,
  }) async => const ClassResult.fail(_f);
  @override
  Future<ClassResult<ClassStudentState>> state(String sessionId) async =>
      const ClassResult.fail(_f);
  @override
  Future<ClassResult<void>> submitAnswer({
    required String sessionId,
    required int questionIndex,
    required String optionId,
  }) async => const ClassResult.fail(_f);
  @override
  Future<ClassResult<ClassMyResults>> myResults(String sessionId) async =>
      const ClassResult.fail(_f);
  @override
  Future<ClassResult<void>> reportNickname({
    required String sessionId,
    required String participantId,
    required String reason,
  }) async => const ClassResult.fail(_f);
}
