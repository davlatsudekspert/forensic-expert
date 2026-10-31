import '../class_groups/class_groups_models.dart';
import '../class_quiz/class_quiz_models.dart' show ClassHardDetail;

/// «Ustoz–talaba testi» xizmati. Barcha qarorlar (rol, a’zolik, ball, vaqt,
/// variant, javoblarni ochish, chegaralar) serverda; mijoz faqat so‘raydi.
abstract interface class ClassGroupsService {
  bool get isConfigured;

  /// Demo (xotiradagi) adapter — ma’lumot faqat shu qurilmada.
  bool get isDemo;

  /// Hozirgi foydalanuvchi id si (ustoz sinovida variantni hisoblash uchun).
  String? get userId;

  // ---- umumiy
  Future<GroupCall<GroupList>> list();

  Future<GroupCall<GroupDetail>> detail(String groupId);

  // ---- ustoz
  Future<GroupCall<GroupInfo>> create(String name);

  Future<GroupCall<void>> removeMember(String groupId, String memberId);

  Future<GroupCall<GroupAssignment>> createAssignment(
    String groupId,
    AssignmentDraft draft,
  );

  Future<GroupCall<void>> closeAssignment(String assignmentId);

  Future<GroupCall<GroupBoard>> board(String assignmentId);

  /// «Talaba ko‘rinishida sinash» uchun hovuz (faqat o‘qish).
  Future<GroupCall<GroupPreview>> preview(String assignmentId);

  /// «Qiyin savollar» muhokamasi: eng past to‘g‘ri % dan; faqat ustoz va
  /// faqat test yopilgach / muddati o‘tgach ([GroupFailure.notFinished]).
  /// Talaba ismlari yo‘q.
  Future<GroupCall<List<ClassHardDetail>>> hardestDetail(
    String assignmentId, {
    int limit = 5,
  });

  // ---- talaba
  /// Kod bilan qo‘shilish. Taxallus birinchi marta kerak
  /// ([GroupFailure.nicknameRequired] — `extra['group_name']` bilan).
  Future<GroupCall<GroupJoinInfo>> join({
    required String code,
    String? nickname,
    String? assignmentId,
  });

  Future<GroupCall<void>> leave(String groupId);

  /// Testni ochadi (birinchi marta — server boshlanish vaqtini yozadi).
  Future<GroupCall<GroupAttempt>> open(String assignmentId);

  /// Javoblarni saqlash (har savoldan keyin).
  Future<GroupCall<void>> save(String assignmentId, Map<String, int> answers);

  Future<GroupCall<GroupSubmitInfo>> submit(
    String assignmentId,
    Map<String, int> answers,
  );

  Future<GroupCall<GroupTestResult>> result(String assignmentId);

  /// Anti-cheat: talaba test paytida ilovadan chiqdi (fonga o‘tdi). Server
  /// sanaydi, faqat ustoz ko‘radi; ball/jazo yo‘q. Mijoz xatoni e’tiborsiz
  /// qoldiradi (fire-and-forget).
  Future<GroupCall<void>> reportLeave(String assignmentId);
}

/// Backend yo‘q — hech narsa soxtalashtirilmaydi.
class UnconfiguredClassGroupsService implements ClassGroupsService {
  const UnconfiguredClassGroupsService();

  static const _f = GroupFailure.notConfigured;

  @override
  bool get isConfigured => false;
  @override
  bool get isDemo => false;
  @override
  String? get userId => null;

  @override
  Future<GroupCall<GroupList>> list() async => const GroupCall.fail(_f);
  @override
  Future<GroupCall<GroupDetail>> detail(String groupId) async =>
      const GroupCall.fail(_f);
  @override
  Future<GroupCall<GroupInfo>> create(String name) async =>
      const GroupCall.fail(_f);
  @override
  Future<GroupCall<void>> removeMember(String groupId, String memberId) async =>
      const GroupCall.fail(_f);
  @override
  Future<GroupCall<GroupAssignment>> createAssignment(
    String groupId,
    AssignmentDraft draft,
  ) async => const GroupCall.fail(_f);
  @override
  Future<GroupCall<void>> closeAssignment(String assignmentId) async =>
      const GroupCall.fail(_f);
  @override
  Future<GroupCall<GroupBoard>> board(String assignmentId) async =>
      const GroupCall.fail(_f);
  @override
  Future<GroupCall<GroupPreview>> preview(String assignmentId) async =>
      const GroupCall.fail(_f);
  @override
  Future<GroupCall<List<ClassHardDetail>>> hardestDetail(
    String assignmentId, {
    int limit = 5,
  }) async => const GroupCall.fail(_f);
  @override
  Future<GroupCall<GroupJoinInfo>> join({
    required String code,
    String? nickname,
    String? assignmentId,
  }) async => const GroupCall.fail(_f);
  @override
  Future<GroupCall<void>> leave(String groupId) async =>
      const GroupCall.fail(_f);
  @override
  Future<GroupCall<GroupAttempt>> open(String assignmentId) async =>
      const GroupCall.fail(_f);
  @override
  Future<GroupCall<void>> save(
    String assignmentId,
    Map<String, int> answers,
  ) async => const GroupCall.fail(_f);
  @override
  Future<GroupCall<GroupSubmitInfo>> submit(
    String assignmentId,
    Map<String, int> answers,
  ) async => const GroupCall.fail(_f);
  @override
  Future<GroupCall<GroupTestResult>> result(String assignmentId) async =>
      const GroupCall.fail(_f);
  @override
  Future<GroupCall<void>> reportLeave(String assignmentId) async =>
      const GroupCall.fail(_f);
}

/// Kutilayotgan taklif (QR → ro‘yxatdan o‘tish davomida yo‘qolmasin).
abstract interface class PendingGroupInviteStore {
  GroupInvite? read();
  Future<void> write(GroupInvite? invite);
}

class InMemoryPendingGroupInviteStore implements PendingGroupInviteStore {
  InMemoryPendingGroupInviteStore([this._v]);

  GroupInvite? _v;

  @override
  GroupInvite? read() => _v;

  @override
  Future<void> write(GroupInvite? invite) async => _v = invite;
}
