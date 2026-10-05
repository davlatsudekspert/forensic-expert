import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';
import 'package:forensic_expert/domain/professional/review_models.dart';

/// Professional maqom, soha vakolati va ilmiy tasdiq qoidalari.
void main() {
  const toxSubject = ReviewSubject(
    recordId: 'morphine',
    kind: ReviewSubjectKind.substance,
    contentVersion: '2026.10.7',
    scopes: {ReviewerScope.forensicToxicology, ReviewerScope.forensicChemistry},
  );
  const dnaSubject = ReviewSubject(
    recordId: 'str-profile',
    kind: ReviewSubjectKind.claim,
    contentVersion: '2026.10.7',
    scopes: {ReviewerScope.geneticsDna},
  );

  ProfessionalIdentity who(
    String id, {
    VerificationStatus status = VerificationStatus.verifiedProfessional,
    Set<ReviewerScope> scopes = const {ReviewerScope.forensicToxicology},
    Set<AccountRole> roles = const {AccountRole.user},
    bool human = true,
    String? org,
  }) => ProfessionalIdentity(
    userId: id,
    displayName: id,
    status: status,
    scopes: scopes,
    roles: roles,
    isHuman: human,
    organization: org,
  );

  ProfessionalReview review(
    String reviewer,
    ReviewAction action, {
    String version = '2026.10.7',
    ReviewerScope scope = ReviewerScope.forensicToxicology,
    DateTime? at,
    String record = 'morphine',
  }) => ProfessionalReview(
    reviewId: '$reviewer-${action.name}-$version',
    recordId: record,
    contentVersion: version,
    reviewerUserId: reviewer,
    reviewerDisplayName: reviewer,
    reviewerSpecialty: Specialty.forensicToxicology,
    reviewerScope: scope,
    reviewerVerificationStatus: VerificationStatus.verifiedProfessional,
    action: action,
    text: 'Reviewed against the cited primary literature.',
    createdAt: at ?? DateTime.utc(2026, 10, 1),
  );

  group('foydalanish rejimi ≠ maqom', () {
    test('professional profil to‘ldirilsa ham maqom yo‘q (hech kim '
        'tasdiqlanmagan)', () {
      const p = ProfessionalProfile(
        fullName: 'A. Expert',
        country: 'UZ',
        organization: 'Lab',
        position: 'Senior forensic expert',
        primarySpecialty: Specialty.forensicToxicology,
        education: 'MD',
      );
      expect(ProfileValidation.professional(p), isEmpty);
      // Profilda maqom maydoni yo‘q — tuzilishiga ko‘ra.
      expect(p.toJson().keys, isNot(contains('status')));
      expect(p.toJson().keys, isNot(contains('verified')));
    });

    test('professional, lekin tasdiqlanmagan — taqriz yo‘q', () {
      for (final s in [
        VerificationStatus.unverified,
        VerificationStatus.applicationPending,
        VerificationStatus.changesRequested,
        VerificationStatus.rejected,
      ]) {
        expect(
          ReviewAuthority.canReview(who('u', status: s), toxSubject),
          ReviewPermission.notVerified,
          reason: s.name,
        );
      }
      expect(
        ReviewAuthority.canReview(
          who('u', status: VerificationStatus.suspended),
          toxSubject,
        ),
        ReviewPermission.suspended,
      );
    });

    test('akkauntsiz oddiy foydalanuvchi va talaba taqriz yoza olmaydi', () {
      expect(
        ReviewAuthority.canReview(null, toxSubject),
        ReviewPermission.notSignedIn,
      );
      // Talaba — tasdiqlanmagan va vakolatsiz.
      expect(
        ReviewAuthority.canReview(
          who('student', status: VerificationStatus.unverified, scopes: {}),
          toxSubject,
        ),
        ReviewPermission.notVerified,
      );
    });

    test('tasdiqlangan mutaxassis talaba UI rejimida — vakolat saqlanadi, '
        'faqat amallar yashiriladi', () {
      final v = who('v');
      expect(
        ReviewAuthority.canReview(v, toxSubject, studentModeUi: true),
        ReviewPermission.studentMode,
      );
      expect(
        ReviewAuthority.canReview(v, toxSubject),
        ReviewPermission.allowed,
      );
      expect(v.isVerifiedProfessional, isTrue);
    });
  });

  group('soha vakolati', () {
    test('toksikolog toksikologiyani taqriz qila oladi, DNKni — yo‘q', () {
      final tox = who('tox');
      expect(
        ReviewAuthority.canReview(tox, toxSubject),
        ReviewPermission.allowed,
      );
      expect(
        ReviewAuthority.canReview(tox, dnaSubject),
        ReviewPermission.scopeNotGranted,
      );
    });

    test('soha tayinlanmagan material — hech kim taqriz qila olmaydi', () {
      const research = ReviewSubject(
        recordId: 'r1',
        kind: ReviewSubjectKind.research,
        contentVersion: '1',
        scopes: {},
      );
      expect(
        ReviewAuthority.canReview(
          who('all', scopes: ReviewerScope.values.toSet()),
          research,
        ),
        ReviewPermission.scopeNotGranted,
      );
    });

    test('soha xaritasi: sud tibbiyoti va huquq alohida', () {
      expect(ReviewScopes.forKind(ReviewSubjectKind.forensicMedicine), {
        ReviewerScope.forensicMedicine,
      });
      expect(
        ReviewScopes.forKind(ReviewSubjectKind.substance),
        isNot(contains(ReviewerScope.geneticsDna)),
      );
      expect(ReviewScopes.forKind(ReviewSubjectKind.legal), {
        ReviewerScope.legalJurisdiction,
      });
    });
  });

  group('admin ≠ ilmiy taqrizchi', () {
    test('identity admin maqom bo‘yicha qaror qiladi, lekin ilmiy taqriz '
        'yoza olmaydi', () {
      final admin = who(
        'admin',
        status: VerificationStatus.unverified,
        scopes: {},
        roles: {AccountRole.identityAdmin},
      );
      expect(ReviewAuthority.canDecideIdentity(admin, 'applicant'), isTrue);
      expect(
        ReviewAuthority.canReview(admin, toxSubject),
        isNot(ReviewPermission.allowed),
      );
    });

    test('admin o‘zini tasdiqlay olmaydi; oddiy foydalanuvchi qaror '
        'qila olmaydi', () {
      final admin = who('admin', roles: {AccountRole.identityAdmin});
      expect(ReviewAuthority.canDecideIdentity(admin, 'admin'), isFalse);
      // Soha ko‘rsatilmasa oddiy mutaxassis qaror qila olmaydi.
      expect(ReviewAuthority.canDecideIdentity(who('u'), 'x'), isFalse);
      expect(
        ReviewAuthority.canDecideIdentity(
          who('u'),
          'x',
          scope: ReviewerScope.forensicToxicology,
        ),
        isTrue,
      );
    });

    test('soha vakolati alohida rol bilan va faqat tasdiqlanganlarga', () {
      final grantor = who('g', roles: {AccountRole.scopeGrantor});
      final admin = who('a', roles: {AccountRole.identityAdmin});
      final verified = who('v');
      final pending = who('p', status: VerificationStatus.applicationPending);
      expect(ReviewAuthority.canGrantScope(grantor, verified), isTrue);
      expect(ReviewAuthority.canGrantScope(grantor, pending), isFalse);
      expect(ReviewAuthority.canGrantScope(admin, verified), isFalse);
      expect(ReviewAuthority.canGrantScope(grantor, grantor), isFalse);
    });

    test('AI/avtomatik identifikatsiya hech qachon taqrizchi emas', () {
      final ai = who('ai-agent', human: false);
      expect(ai.isVerifiedProfessional, isFalse);
      expect(
        ReviewAuthority.canReview(ai, toxSubject),
        ReviewPermission.notHuman,
      );
      expect(
        ReviewAuthority.canDecideIdentity(
          who('ai', human: false, roles: {AccountRole.identityAdmin}),
          'x',
        ),
        isFalse,
      );
    });
  });

  group('maqom holatlari', () {
    test('foydalanuvchi faqat ariza yubora oladi', () {
      expect(
        VerificationStateMachine.submit(VerificationStatus.unverified),
        VerificationStatus.applicationPending,
      );
      expect(
        VerificationStateMachine.submit(VerificationStatus.applicationPending),
        isNull,
      );
      expect(
        VerificationStateMachine.submit(VerificationStatus.suspended),
        isNull,
      );
    });

    test('admin qarorlari faqat ruxsat etilgan o‘tishlar', () {
      const p = VerificationStatus.applicationPending;
      expect(
        VerificationStateMachine.apply(p, IdentityDecision.verify),
        VerificationStatus.verifiedProfessional,
      );
      expect(
        VerificationStateMachine.apply(
          p,
          IdentityDecision.requestMoreInformation,
        ),
        VerificationStatus.changesRequested,
      );
      expect(
        VerificationStateMachine.apply(p, IdentityDecision.reject),
        VerificationStatus.rejected,
      );
      // Arizasiz to‘g‘ridan-to‘g‘ri tasdiqlash yo‘q.
      expect(
        VerificationStateMachine.apply(
          VerificationStatus.unverified,
          IdentityDecision.verify,
        ),
        isNull,
      );
      expect(
        VerificationStateMachine.apply(
          VerificationStatus.verifiedProfessional,
          IdentityDecision.suspend,
        ),
        VerificationStatus.suspended,
      );
    });

    test('server kodlari', () {
      for (final s in VerificationStatus.values) {
        expect(VerificationStatus.fromCode(s.code), s);
      }
      expect(VerificationStatus.fromCode('???'), VerificationStatus.unverified);
    });
  });

  group('malaka hujjati', () {
    Uint8List bytes(List<int> head, [int size = 64]) =>
        Uint8List.fromList([...head, ...List.filled(size, 0)]);

    test('tur kengaytma emas, imzo bo‘yicha aniqlanadi', () {
      expect(
        CredentialFilePolicy.detect(bytes([0x25, 0x50, 0x44, 0x46, 0x2D])),
        CredentialFileType.pdf,
      );
      expect(
        CredentialFilePolicy.detect(bytes([0xFF, 0xD8, 0xFF])),
        CredentialFileType.jpeg,
      );
      expect(
        CredentialFilePolicy.detect(
          bytes([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]),
        ),
        CredentialFileType.png,
      );
      expect(
        CredentialFilePolicy.validate(bytes([0x4D, 0x5A])),
        CredentialFileError.unsupportedType,
      );
      expect(
        CredentialFilePolicy.validate(Uint8List(0)),
        CredentialFileError.empty,
      );
      expect(
        CredentialFilePolicy.validate(
          bytes([0x25, 0x50, 0x44, 0x46, 0x2D], CredentialFilePolicy.maxBytes),
        ),
        CredentialFileError.tooLarge,
      );
    });

    test('hujjat va profil jurnalga shaxsiy ma’lumot chiqarmaydi', () {
      final f = CredentialFile(
        fileName: 'diploma-John-Smith.pdf',
        kind: CredentialKind.diploma,
        bytes: bytes([0x25, 0x50, 0x44, 0x46, 0x2D]),
      );
      expect('$f', isNot(contains('John')));
      const p = ProfessionalProfile(
        fullName: 'John Smith',
        country: 'GB',
        organization: 'Lab',
        position: 'Chemist',
        primarySpecialty: Specialty.forensicChemistry,
        education: 'PhD',
        workEmail: 'john@lab.example',
      );
      expect('$p', isNot(contains('John')));
      expect('$p', isNot(contains('@')));
    });

    test('ochiq profilda xususiy maydonlar tuzilishiga ko‘ra yo‘q', () {
      const pub = PublicProfessionalProfile(
        userId: 'u1',
        displayName: 'Dr X',
        status: VerificationStatus.verifiedProfessional,
        specialty: Specialty.forensicToxicology,
        country: 'UZ',
      );
      expect(pub.isVerified, isTrue);
      // Hujjat metamaʼlumotida ochiq URL maydoni yo‘q.
      final meta = CredentialDocumentMeta(
        documentId: 'd1',
        kind: CredentialKind.diploma,
        type: CredentialFileType.pdf,
        sizeBytes: 10,
        uploadedAt: DateTime.utc(2026),
      );
      expect(meta.documentId, 'd1');
    });

    test('profil validatsiyasi: majburiy maydonlar, email, tajriba', () {
      const bad = ProfessionalProfile(
        fullName: ' ',
        country: '',
        organization: '',
        position: '',
        primarySpecialty: Specialty.other,
        education: '',
        workEmail: 'not-an-email',
        yearsExperience: 120,
      );
      final e = ProfileValidation.professional(bad);
      expect(e[ProfileField.fullName], ProfileFieldError.required);
      expect(e[ProfileField.country], ProfileFieldError.required);
      expect(e[ProfileField.organization], ProfileFieldError.required);
      expect(e[ProfileField.workEmail], ProfileFieldError.invalid);
      expect(e[ProfileField.yearsExperience], ProfileFieldError.invalid);
      expect(
        ProfileValidation.student(
          const StudentProfile(fullName: 'S', country: 'UZ'),
        ),
        isEmpty,
      );
    });

    test('profil JSON aylanma yo‘l', () {
      const p = LocalUserProfile(
        student: StudentProfile(
          fullName: 'S',
          country: 'UZ',
          role: StudentRole.residentTrainee,
          studyLevel: StudyLevel.residency,
          interests: [Specialty.forensicToxicology],
        ),
      );
      final back = LocalUserProfile.fromJson(p.toJson());
      expect(back.student!.role, StudentRole.residentTrainee);
      expect(back.student!.interests, [Specialty.forensicToxicology]);
      expect(back.professional, isNull);
    });
  });

  group('taqriz siyosati va HUMAN VERIFIED', () {
    final identities = {
      'a': who('a', org: 'Lab A'),
      'b': who('b', org: 'Lab B'),
      'b2': who('b2', org: 'Lab A'),
      'dna': who('dna', scopes: {ReviewerScope.geneticsDna}, org: 'Lab C'),
      'ai': who('ai', human: false),
      'pending': who('pending', status: VerificationStatus.applicationPending),
    };
    ProfessionalIdentity? lookup(String id) => identities[id];

    test('taqriz yo‘q — NEEDS_REVIEW; biriktirilgan — REVIEW_IN_PROGRESS', () {
      expect(
        ReviewEvaluator.evaluate(
          subject: toxSubject,
          reviews: const [],
          identityOf: lookup,
        ).state,
        ReviewState.needsReview,
      );
      expect(
        ReviewEvaluator.evaluate(
          subject: toxSubject,
          reviews: const [],
          identityOf: lookup,
          assignedReviewers: {'a'},
        ).state,
        ReviewState.reviewInProgress,
      );
    });

    test('bitta malakali taqriz HUMAN VERIFIED emas', () {
      final o = ReviewEvaluator.evaluate(
        subject: toxSubject,
        reviews: [review('a', ReviewAction.approve)],
        identityOf: lookup,
      );
      expect(o.state, ReviewState.professionalReviewed);
      expect(o.isHumanVerified, isFalse);
    });

    test('ikki mustaqil malakali ma’qullash — HUMAN VERIFIED', () {
      final o = ReviewEvaluator.evaluate(
        subject: toxSubject,
        reviews: [
          review('a', ReviewAction.approve),
          review('b', ReviewAction.approve),
        ],
        identityOf: lookup,
      );
      expect(o.state, ReviewState.humanVerified);
      expect(ReviewEvaluator.humanVerifiedCount([o]), 1);
    });

    test('yuqori xatar: bir tashkilotdan ikki taqrizchi yetmaydi', () {
      const high = ReviewSubject(
        recordId: 'morphine',
        kind: ReviewSubjectKind.substance,
        contentVersion: '2026.10.7',
        scopes: {ReviewerScope.forensicToxicology},
        risk: RiskLevel.high,
      );
      final o = ReviewEvaluator.evaluate(
        subject: high,
        reviews: [
          review('a', ReviewAction.approve),
          review('b2', ReviewAction.approve),
        ],
        identityOf: lookup,
      );
      expect(o.state, ReviewState.professionalReviewed);
    });

    test('AI, tasdiqlanmagan va boshqa soha taqrizlari hisoblanmaydi', () {
      final o = ReviewEvaluator.evaluate(
        subject: toxSubject,
        reviews: [
          review('ai', ReviewAction.approve),
          review('pending', ReviewAction.approve),
          review('dna', ReviewAction.approve, scope: ReviewerScope.geneticsDna),
          review('a', ReviewAction.approve),
        ],
        identityOf: lookup,
      );
      expect(o.countedApprovals, 1);
      expect(o.isHumanVerified, isFalse);
    });

    test('bir taqrizchining takroriy ma’qullashi ikki marta sanalmaydi', () {
      final o = ReviewEvaluator.evaluate(
        subject: toxSubject,
        reviews: [
          review('a', ReviewAction.approve, at: DateTime.utc(2026, 1)),
          review('a', ReviewAction.approve, at: DateTime.utc(2026, 2)),
        ],
        identityOf: lookup,
      );
      expect(o.state, ReviewState.professionalReviewed);
    });

    test('kontent o‘zgarsa — RE_REVIEW_REQUIRED, eski taqriz tarixda', () {
      const changed = ReviewSubject(
        recordId: 'morphine',
        kind: ReviewSubjectKind.substance,
        contentVersion: '2026.11.1',
        scopes: {ReviewerScope.forensicToxicology},
      );
      final old = [
        review('a', ReviewAction.approve),
        review('b', ReviewAction.approve),
      ];
      final o = ReviewEvaluator.evaluate(
        subject: changed,
        reviews: old,
        identityOf: lookup,
      );
      expect(o.state, ReviewState.reReviewRequired);
      expect(o.stale, hasLength(2));
      expect(o.isHumanVerified, isFalse);
    });

    test('reject / ziddiyat / eskirgan / tuzatish ustun', () {
      ReviewState s(ReviewAction a) => ReviewEvaluator.evaluate(
        subject: toxSubject,
        reviews: [review('a', ReviewAction.approve), review('b', a)],
        identityOf: lookup,
      ).state;
      expect(s(ReviewAction.reject), ReviewState.rejected);
      expect(s(ReviewAction.flagConflict), ReviewState.conflictFlagged);
      expect(s(ReviewAction.flagOutdated), ReviewState.outdatedFlagged);
      expect(s(ReviewAction.requestChange), ReviewState.changesRequested);
    });

    test('maqomi to‘xtatilgan taqrizchi endi hisoblanmaydi', () {
      final suspended = {
        ...identities,
        'b': who('b', status: VerificationStatus.suspended, org: 'Lab B'),
      };
      final o = ReviewEvaluator.evaluate(
        subject: toxSubject,
        reviews: [
          review('a', ReviewAction.approve),
          review('b', ReviewAction.approve),
        ],
        identityOf: (id) => suspended[id],
      );
      expect(o.isHumanVerified, isFalse);
    });

    test('taqriz matni va manba havolasi validatsiyasi', () {
      expect(ReviewDraftValidation.validate(note: 'too short'), {
        ReviewDraftError.noteTooShort,
      });
      expect(
        ReviewDraftValidation.validate(
          note: 'A sufficiently long professional note.',
          sourceReference: '10.1093/jat/bkab012',
        ),
        isEmpty,
      );
      expect(
        ReviewDraftValidation.validate(
          note: 'A sufficiently long professional note.',
          sourceReference: 'PMID: 12345678',
        ),
        isEmpty,
      );
      expect(
        ReviewDraftValidation.validate(
          note: 'A sufficiently long professional note.',
          sourceReference: 'see my blog',
        ),
        {ReviewDraftError.invalidSourceReference},
      );
    });

    test('audit jurnali faqat qo‘shiladi', () {
      final log = ReviewAuditLog()
        ..append(
          ReviewAuditEntry(
            entryId: '1',
            recordId: 'morphine',
            contentVersion: '2026.10.7',
            actorUserId: 'a',
            actorScope: ReviewerScope.forensicToxicology,
            action: ReviewAction.approve,
            previousState: ReviewState.needsReview,
            newState: ReviewState.professionalReviewed,
            at: DateTime.utc(2026),
          ),
        )
        ..append(
          ReviewAuditEntry(
            entryId: '2',
            recordId: 'morphine',
            contentVersion: '2026.11.1',
            actorUserId: 'system',
            previousState: ReviewState.professionalReviewed,
            newState: ReviewState.reReviewRequired,
            at: DateTime.utc(2026, 11),
          ),
        );
      expect(log.forRecord('morphine'), hasLength(2));
      expect(() => (log.entries as List).clear(), throwsUnsupportedError);
    });
  });

  group('maqomni tasdiqlash qoidasi (server bilan bir xil)', () {
    final at = DateTime.utc(2026, 10, 5);
    ProfessionalApplication app({
      VerificationStatus status = VerificationStatus.applicationPending,
      List<String> docs = const ['doc-1'],
    }) => ProfessionalApplication(
      applicationId: 'a1',
      userId: 'applicant',
      status: status,
      declaredSpecialty: Specialty.forensicToxicology,
      submittedAt: at,
      documents: [
        for (final d in docs)
          CredentialDocumentMeta(
            documentId: d,
            kind: CredentialKind.qualificationCertificate,
            type: CredentialFileType.pdf,
            sizeBytes: 100,
            uploadedAt: at,
          ),
      ],
    );

    test('identity admin hujjatni tekshirib tasdiqlaydi — kim, qachon, '
        'qaysi hujjat, qaysi soha yoziladi', () {
      final admin = who(
        'admin',
        status: VerificationStatus.unverified,
        scopes: {},
        roles: {AccountRole.identityAdmin},
      );
      final (r, e) = IdentityVerification.decide(
        actor: admin,
        application: app(),
        decision: IdentityDecision.verify,
        scope: ReviewerScope.forensicToxicology,
        checkedCredentialIds: ['doc-1'],
        at: at,
      );
      expect(e, isNull);
      expect(r!.to, VerificationStatus.verifiedProfessional);
      expect(r.approverId, 'admin');
      expect(r.approverKind, ApproverKind.identityAdmin);
      expect(r.checkedCredentialIds, ['doc-1']);
      expect(r.scope, ReviewerScope.forensicToxicology);
      expect(r.at, at);
    });

    test('shu soha vakolatiga ega tasdiqlangan mutaxassis tasdiqlay oladi', () {
      final (r, e) = IdentityVerification.decide(
        actor: who('peer'),
        application: app(),
        decision: IdentityDecision.verify,
        scope: ReviewerScope.forensicToxicology,
        checkedCredentialIds: ['doc-1'],
        at: at,
      );
      expect(e, isNull);
      expect(r!.approverKind, ApproverKind.verifiedPeer);
    });

    test('boshqa soha mutaxassisi, talaba, tasdiqlanmagan, to‘xtatilgan va '
        'AI tasdiqlay olmaydi', () {
      for (final actor in [
        who('dna', scopes: {ReviewerScope.geneticsDna}),
        who('student', status: VerificationStatus.unverified, scopes: {}),
        who('pending', status: VerificationStatus.applicationPending),
        who('susp', status: VerificationStatus.suspended),
        who('ai', human: false, roles: {AccountRole.identityAdmin}),
      ]) {
        final (r, e) = IdentityVerification.decide(
          actor: actor,
          application: app(),
          decision: IdentityDecision.verify,
          scope: ReviewerScope.forensicToxicology,
          checkedCredentialIds: ['doc-1'],
          at: at,
        );
        expect(r, isNull, reason: actor.userId);
        expect(e, isNotNull, reason: actor.userId);
      }
    });

    test('o‘zini tasdiqlash taqiqlangan (admin bo‘lsa ham)', () {
      const self = ProfessionalIdentity(
        userId: 'applicant',
        displayName: 'x',
        status: VerificationStatus.verifiedProfessional,
        scopes: {ReviewerScope.forensicToxicology},
        roles: {AccountRole.identityAdmin},
      );
      final (_, e) = IdentityVerification.decide(
        actor: self,
        application: app(),
        decision: IdentityDecision.verify,
        scope: ReviewerScope.forensicToxicology,
        checkedCredentialIds: ['doc-1'],
        at: at,
      );
      expect(e, IdentityDecisionError.selfApproval);
    });

    test('hujjat — dalil: tekshirilgan hujjatsiz yoki begona hujjat bilan '
        'tasdiqlanmaydi; soha ko‘rsatilishi shart', () {
      final admin = who('admin', roles: {AccountRole.identityAdmin});
      (IdentityDecisionRecord?, IdentityDecisionError?) run({
        List<String> checked = const [],
        ReviewerScope? scope = ReviewerScope.forensicToxicology,
        List<String> docs = const ['doc-1'],
      }) => IdentityVerification.decide(
        actor: admin,
        application: app(docs: docs),
        decision: IdentityDecision.verify,
        scope: scope,
        checkedCredentialIds: checked,
        at: at,
      );
      expect(run().$2, IdentityDecisionError.noCredentialChecked);
      expect(run(docs: const []).$2, IdentityDecisionError.noCredentialChecked);
      expect(
        run(checked: ['other']).$2,
        IdentityDecisionError.unknownCredential,
      );
      expect(
        run(checked: ['doc-1'], scope: null).$2,
        IdentityDecisionError.scopeRequired,
      );
    });

    test('ariza yuborilmasdan tasdiqlanmaydi; to‘xtatish faqat admin', () {
      final (_, e1) = IdentityVerification.decide(
        actor: who('admin', roles: {AccountRole.identityAdmin}),
        application: app(status: VerificationStatus.unverified),
        decision: IdentityDecision.verify,
        scope: ReviewerScope.forensicToxicology,
        checkedCredentialIds: ['doc-1'],
        at: at,
      );
      expect(e1, IdentityDecisionError.invalidTransition);
      final (_, e2) = IdentityVerification.decide(
        actor: who('peer'),
        application: app(status: VerificationStatus.verifiedProfessional),
        decision: IdentityDecision.suspend,
        scope: ReviewerScope.forensicToxicology,
        at: at,
      );
      expect(e2, IdentityDecisionError.notAuthorized);
    });

    test('Mutaxassis rejimi / sertifikat yuklash maqomni o‘zgartirmaydi: '
        'foydalanuvchi faqat APPLICATION_PENDING ga o‘ta oladi', () {
      for (final s in VerificationStatus.values) {
        expect(
          VerificationStateMachine.submit(s),
          isNot(VerificationStatus.verifiedProfessional),
        );
      }
    });
  });
}
