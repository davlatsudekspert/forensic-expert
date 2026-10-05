import 'package:forensic_expert/domain/ports/professional_ports.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';
import 'package:forensic_expert/domain/professional/review_models.dart';

/// FIXTURE — faqat testlar va skrinshotlar uchun. Ilovaga (lib/) hech
/// qachon kirmaydi; haqiqiy tasdiqlangan foydalanuvchi emas.
const fixtureToxReviewer = ProfessionalIdentity(
  userId: 'fixture-reviewer-tox',
  displayName: 'FIXTURE Reviewer (toxicology)',
  status: VerificationStatus.verifiedProfessional,
  scopes: {ReviewerScope.forensicToxicology, ReviewerScope.forensicChemistry},
  specialty: Specialty.forensicToxicology,
  organization: 'FIXTURE Laboratory',
);

const fixtureDnaReviewer = ProfessionalIdentity(
  userId: 'fixture-reviewer-dna',
  displayName: 'FIXTURE Reviewer (DNA)',
  status: VerificationStatus.verifiedProfessional,
  scopes: {ReviewerScope.geneticsDna},
  specialty: Specialty.geneticsDna,
);

ProfessionalReview fixtureReview({
  required String recordId,
  required String version,
  ReviewAction action = ReviewAction.requestChange,
  String id = 'fixture-review-1',
}) => ProfessionalReview(
  reviewId: id,
  recordId: recordId,
  contentVersion: version,
  reviewerUserId: fixtureToxReviewer.userId,
  reviewerDisplayName: fixtureToxReviewer.displayName,
  reviewerSpecialty: Specialty.forensicToxicology,
  reviewerScope: ReviewerScope.forensicToxicology,
  reviewerVerificationStatus: VerificationStatus.verifiedProfessional,
  reviewerOrganization: 'FIXTURE Laboratory',
  action: action,
  text:
      'FIXTURE review text for interface testing only — not a real '
      'professional opinion.',
  createdAt: DateTime.utc(2026, 10, 1),
);

/// Server xatti-harakatini taqlid qiladi: vakolatni o‘zi qayta tekshiradi
/// (mijoz bayrog‘iga ishonmaydi).
class FixtureReviewService implements ProfessionalReviewService {
  FixtureReviewService({
    this.reviews = const [],
    this.identity,
    this.queueItems = const [],
  });

  final List<ProfessionalReview> reviews;
  final ProfessionalIdentity? identity;
  final List<ReviewQueueItem> queueItems;
  final submitted = <ProfessionalReview>[];

  @override
  bool get isConfigured => true;

  @override
  Future<ProfessionalResult<List<ProfessionalReview>>> reviewsFor(
    String recordId,
  ) async => ProfessionalResult.ok([
    for (final r in [...reviews, ...submitted])
      if (r.recordId == recordId) r,
  ]);

  @override
  Future<ProfessionalResult<ProfessionalReview>> submit({
    required ReviewSubject subject,
    required ReviewAction action,
    required String note,
    String? sourceReference,
  }) async {
    final who = identity;
    if (ReviewAuthority.canReview(who, subject) != ReviewPermission.allowed) {
      return const ProfessionalResult.fail(ProfessionalFailure.forbidden);
    }
    final r = ProfessionalReview(
      reviewId: 'fixture-submitted-${submitted.length}',
      recordId: subject.recordId,
      contentVersion: subject.contentVersion,
      reviewerUserId: who!.userId,
      reviewerDisplayName: who.displayName,
      reviewerSpecialty: who.specialty ?? Specialty.other,
      reviewerScope: ReviewAuthority.scopeFor(who, subject)!,
      reviewerVerificationStatus: who.status,
      action: action,
      text: note,
      sourceReference: sourceReference,
      createdAt: DateTime.utc(2026, 10, 5),
    );
    submitted.add(r);
    return ProfessionalResult.ok(r);
  }

  @override
  Future<ProfessionalResult<List<ReviewQueueItem>>> queue(
    ReviewQueue q,
  ) async => ProfessionalResult.ok(
    q == ReviewQueue.needsReview ? queueItems : const [],
  );
}

class FixtureVerificationService implements ProfessionalVerificationService {
  FixtureVerificationService(this.snapshot);

  ProfessionalSnapshot snapshot;
  final submissions = <(ProfessionalProfile, List<CredentialFile>)>[];

  @override
  bool get isConfigured => true;

  @override
  Future<ProfessionalSnapshot> fetch() async => snapshot;

  @override
  Future<ProfessionalResult<ProfessionalApplication>> submit({
    required ProfessionalProfile profile,
    required List<CredentialFile> documents,
  }) async {
    submissions.add((profile, documents));
    final app = ProfessionalApplication(
      applicationId: 'fixture-app',
      userId: 'fixture-user',
      status: VerificationStatus.applicationPending,
      declaredSpecialty: profile.primarySpecialty,
      submittedAt: DateTime.utc(2026, 10, 5),
    );
    snapshot = ProfessionalSnapshot(application: app);
    return ProfessionalResult.ok(app);
  }
}

class FakeFilePicker implements CredentialFilePicker {
  FakeFilePicker(this.next);

  PickedFile? next;

  @override
  Future<PickedFile?> pick() async => next;
}

const pdfBytes = [0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x37, 0x0A];
