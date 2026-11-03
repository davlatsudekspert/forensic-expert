import '../class_quiz/class_quiz_models.dart' show ClassResult;
import '../oral_group/oral_group_models.dart';

/// «Guruh og‘zaki imtihoni» xizmati. Qarorlar (rol, bilet berish, ball
/// tekshiruvi) serverda; mijoz faqat so‘raydi. Javob kaliti serverga
/// yuborilmaydi.
abstract interface class OralGroupService {
  bool get isConfigured;

  /// Demo (Fake) adapter — ma’lumot faqat shu qurilmada.
  bool get isDemo;

  /// Qo‘shilish uchun hisobga kirish shartmi (haqiqiy server: ha).
  bool get requiresSignIn;

  // ---- ustoz
  Future<ClassResult<OralGroupSession>> createSession({
    required String title,
    required List<List<OralGroupQuestion>> tickets,
    required int prepSeconds,
  });

  Future<ClassResult<List<OralGroupSession>>> mySessions();

  Future<ClassResult<OralGroupTeacherState>> teacherState(String sessionId);

  Future<ClassResult<void>> call(String sessionId, String participantId);

  /// `scores` — har savolga 0..20; qayta baholash mumkin. Jami qaytadi.
  Future<ClassResult<int>> grade(
    String sessionId,
    String participantId,
    List<int> scores,
  );

  Future<ClassResult<void>> kick(String sessionId, String participantId);

  Future<ClassResult<void>> finish(String sessionId);

  // ---- talaba
  Future<ClassResult<OralGroupJoinInfo>> join({
    required String code,
    required String name,
  });

  Future<ClassResult<OralGroupMyState>> myState(String sessionId);

  Future<ClassResult<void>> ready(String sessionId);

  /// Talaba ilovadan chiqdi (fonga o‘tdi); yangi hisob qaytadi. Baholangan,
  /// chetlatilgan yoki yakunlangan bo‘lsa — [ClassFailure.notAllowed].
  Future<ClassResult<int>> reportLeave(String sessionId);
}

/// Oxirgi imtihonni eslab qolish (sinxron o‘qish, bootstrap’da diskka ulanadi).
abstract interface class OralResumeStore {
  OralResume? load();
  Future<void> save(OralResume? value);
}

class InMemoryOralResumeStore implements OralResumeStore {
  OralResume? _value;

  @override
  OralResume? load() => _value;

  @override
  Future<void> save(OralResume? value) async => _value = value;
}
