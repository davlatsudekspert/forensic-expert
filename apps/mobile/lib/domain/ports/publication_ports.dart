import '../publications/publication_models.dart';

/// «Ekspert maqolalari» server porti. Vakolat va holat o‘tishlari faqat
/// serverda tekshiriladi; mijoz faqat so‘rov yuboradi.
abstract interface class PublicationService {
  bool get isConfigured;

  /// Nashr etilgan maqolalar (hamma uchun, bepul). Xato/oflayn — `null`.
  Future<List<Publication>?> listPublished();

  /// O‘z maqolalari (holat tarixi bilan). Kirmagan/xato — `null`.
  Future<List<Publication>?> myPublications();

  /// Qoralama yaratish yoki tahrirlash; yangi/eski `id` yoki `null` (xato).
  Future<String?> saveDraft(PublicationDraft draft);

  Future<SubmitResult> submit(String id);

  Future<ReportResult> report(String id, ReportReason reason, String details);

  /// identity_admin yoki publication_moderator.
  Future<bool> canModerate();

  /// Faqat moderator; aks holda `null`.
  Future<ModerationQueue?> moderationQueue();

  Future<ModerationResult> moderate(
    String id,
    PublicationStatus to,
    String? comment,
  );
}

class UnconfiguredPublicationService implements PublicationService {
  const UnconfiguredPublicationService();

  @override
  bool get isConfigured => false;

  @override
  Future<List<Publication>?> listPublished() async => const [];

  @override
  Future<List<Publication>?> myPublications() async => null;

  @override
  Future<String?> saveDraft(PublicationDraft draft) async => null;

  @override
  Future<SubmitResult> submit(String id) async => SubmitResult.failed;

  @override
  Future<ReportResult> report(
    String id,
    ReportReason reason,
    String details,
  ) async => ReportResult.failed;

  @override
  Future<bool> canModerate() async => false;

  @override
  Future<ModerationQueue?> moderationQueue() async => null;

  @override
  Future<ModerationResult> moderate(
    String id,
    PublicationStatus to,
    String? comment,
  ) async => ModerationResult.failed;
}
