import '../../domain/ports/professional_ports.dart';
import '../../domain/professional/professional_models.dart';
import '../../domain/professional/review_models.dart';
import '../../domain/professional/verification_inbox_models.dart';

/// Production server ulanmagan holat. Hech narsa «yuborildi» deb
/// ko‘rsatilmaydi, hech kim tasdiqlanmaydi, taqriz soxta yaratilmaydi.
class OfflineProfessionalVerificationService
    implements ProfessionalVerificationService {
  const OfflineProfessionalVerificationService();

  @override
  bool get isConfigured => false;

  @override
  Future<ProfessionalSnapshot> fetch() async => ProfessionalSnapshot.empty;

  @override
  Future<ProfessionalResult<ProfessionalApplication>> submit({
    required ProfessionalProfile profile,
    required List<CredentialFile> documents,
  }) async =>
      const ProfessionalResult.fail(ProfessionalFailure.serviceNotConnected);
}

class OfflineProfessionalReviewService implements ProfessionalReviewService {
  const OfflineProfessionalReviewService();

  @override
  bool get isConfigured => false;

  @override
  Future<ProfessionalResult<List<ProfessionalReview>>> reviewsFor(
    String recordId,
  ) async => const ProfessionalResult.ok(<ProfessionalReview>[]);

  @override
  Future<ProfessionalResult<ProfessionalReview>> submit({
    required ReviewSubject subject,
    required ReviewAction action,
    required String note,
    String? sourceReference,
  }) async =>
      const ProfessionalResult.fail(ProfessionalFailure.serviceNotConnected);

  @override
  Future<ProfessionalResult<List<ReviewQueueItem>>> queue(
    ReviewQueue q,
  ) async =>
      const ProfessionalResult.fail(ProfessionalFailure.serviceNotConnected);
}

/// Server ulanmagan: halol «ulanmagan» xatosi (soxta ro‘yxat yo‘q).
class OfflineIdentityAdminService implements IdentityAdminService {
  const OfflineIdentityAdminService();

  @override
  bool get isConfigured => false;

  @override
  Future<ProfessionalResult<PendingVerificationPage>> pending({
    int limit = 50,
    int offset = 0,
  }) async =>
      const ProfessionalResult.fail(ProfessionalFailure.serviceNotConnected);

  @override
  Future<IdentityDecisionFailure?> decide({
    required String applicantId,
    required IdentityDecision decision,
    required ReviewerScope scope,
    required List<String> checkedDocumentIds,
    required String reason,
    String? applicantMessage,
  }) async => IdentityDecisionFailure.notConnected;
}
