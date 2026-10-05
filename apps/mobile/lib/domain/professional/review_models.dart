/// Mutaxassis taqrizi (ijtimoiy izoh emas), vakolat qoidalari, ilmiy
/// tasdiq siyosati va audit izi.
///
/// Bu qoidalar **server tomonida** majburiy bajariladi (mijozdagi rol
/// bayroqlariga ishonilmaydi). Mijozda xuddi shu sof funksiyalar faqat
/// UI’da tugmalarni ko‘rsatish/yashirish va testlar uchun ishlatiladi.
library;

import 'package:flutter/foundation.dart';

import 'professional_models.dart';

/// Taqrizchi qarori.
enum ReviewAction {
  approve('APPROVE'),
  requestChange('REQUEST_CHANGE'),
  flagConflict('FLAG_CONFLICT'),
  flagOutdated('FLAG_OUTDATED'),
  reject('REJECT');

  const ReviewAction(this.code);

  final String code;
}

/// Taqriz qilinadigan material turi.
enum ReviewSubjectKind {
  substance,
  method,
  reference,
  reagent,
  screeningTest,
  forensicMedicine,
  biochemistry,
  histology,
  research,
  claim,
  standard,
  legal,
}

/// Xatar darajasi — ilmiy tasdiq uchun kerakli mustaqil taqrizlar soni.
enum RiskLevel { standard, high }

/// Taqriz qatlami holati (ilmiy statusdan alohida ko‘rsatiladi).
enum ReviewState {
  needsReview('NEEDS_REVIEW'),
  reviewInProgress('REVIEW_IN_PROGRESS'),
  professionalReviewed('PROFESSIONAL_REVIEWED'),
  humanVerified('HUMAN_VERIFIED'),
  changesRequested('CHANGES_REQUESTED'),
  conflictFlagged('CONFLICT_FLAGGED'),
  outdatedFlagged('OUTDATED_FLAGGED'),
  rejected('REJECTED'),
  reReviewRequired('RE_REVIEW_REQUIRED');

  const ReviewState(this.code);

  final String code;
}

/// Taqriz qilinadigan obyekt: aniq kontent versiyasi va soha bilan.
@immutable
class ReviewSubject {
  const ReviewSubject({
    required this.recordId,
    required this.kind,
    required this.contentVersion,
    required this.scopes,
    this.claimId,
    this.risk = RiskLevel.standard,
  });

  final String recordId;
  final ReviewSubjectKind kind;
  final String? claimId;

  /// Kontentning aniq versiyasi (masalan, paket versiyasi yoki claim
  /// versiyasi). Taqriz faqat shu versiyaga taalluqli.
  final String contentVersion;

  /// Bu materialni taqriz qila oladigan sohalar (kamida bittasi kerak).
  final Set<ReviewerScope> scopes;
  final RiskLevel risk;
}

/// Bitta saqlangan taqriz yozuvi (server ma’lumot modeli).
@immutable
class ProfessionalReview {
  const ProfessionalReview({
    required this.reviewId,
    required this.recordId,
    required this.contentVersion,
    required this.reviewerUserId,
    required this.reviewerDisplayName,
    required this.reviewerSpecialty,
    required this.reviewerScope,
    required this.reviewerVerificationStatus,
    required this.action,
    required this.text,
    required this.createdAt,
    this.claimId,
    this.reviewerOrganization,
    this.sourceReference,
    this.updatedAt,
    this.withdrawn = false,
  });

  final String reviewId;
  final String recordId;
  final String? claimId;
  final String contentVersion;
  final String reviewerUserId;
  final String reviewerDisplayName;
  final Specialty reviewerSpecialty;
  final ReviewerScope reviewerScope;

  /// Taqriz yozilgan paytdagi maqom (tarix uchun).
  final VerificationStatus reviewerVerificationStatus;

  /// Faqat taqrizchi ruxsat bergan bo‘lsa ochiq ko‘rsatiladi.
  final String? reviewerOrganization;
  final ReviewAction action;
  final String text;
  final String? sourceReference;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Taqriz o‘chirilmaydi — faqat «qaytarib olingan» deb belgilanadi.
  final bool withdrawn;
}

/// Taqriz yuborishga ruxsat natijasi.
enum ReviewPermission {
  allowed,
  notSignedIn,
  notHuman,
  notVerified,
  suspended,
  scopeNotGranted,

  /// Tasdiqlangan mutaxassis UI’ni vaqtincha talaba rejimiga o‘tkazgan.
  /// Vakolat saqlanadi, faqat taqriz amallari yashiriladi.
  studentMode,
}

enum ReviewDraftError { noteTooShort, noteTooLong, invalidSourceReference }

abstract final class ReviewDraftValidation {
  static const minNote = 20;
  static const maxNote = 4000;

  static final _doi = RegExp(r'^(https://doi\.org/)?10\.\d{4,9}/\S+$');
  static final _pmid = RegExp(r'^(PMID:?\s*)?\d{1,9}$', caseSensitive: false);
  static final _url = RegExp(r'^https://[^\s]+\.[^\s]+$');

  static Set<ReviewDraftError> validate({
    required String note,
    String? sourceReference,
  }) {
    final n = note.trim();
    final ref = sourceReference?.trim() ?? '';
    return {
      if (n.length < minNote) ReviewDraftError.noteTooShort,
      if (n.length > maxNote) ReviewDraftError.noteTooLong,
      if (ref.isNotEmpty &&
          !_doi.hasMatch(ref) &&
          !_pmid.hasMatch(ref) &&
          !_url.hasMatch(ref))
        ReviewDraftError.invalidSourceReference,
    };
  }
}

/// Vakolat qoidalari (server bilan bir xil kontrakt).
abstract final class ReviewAuthority {
  /// Malakali taqriz yuborish mumkinmi. Foydalanish rejimi, kasb nomi,
  /// yuklangan hujjat yoki admin roli **hisobga olinmaydi** — faqat inson
  /// ekanligi, server bergan maqom va aniq soha vakolati.
  static ReviewPermission canReview(
    ProfessionalIdentity? who,
    ReviewSubject subject, {
    bool studentModeUi = false,
  }) {
    if (who == null) return ReviewPermission.notSignedIn;
    if (!who.isHuman) return ReviewPermission.notHuman;
    if (who.status == VerificationStatus.suspended) {
      return ReviewPermission.suspended;
    }
    if (who.status != VerificationStatus.verifiedProfessional) {
      return ReviewPermission.notVerified;
    }
    if (who.scopes.intersection(subject.scopes).isEmpty) {
      return ReviewPermission.scopeNotGranted;
    }
    if (studentModeUi) return ReviewPermission.studentMode;
    return ReviewPermission.allowed;
  }

  /// Taqrizchi qaysi soha nomidan yozadi (birinchi mos soha).
  static ReviewerScope? scopeFor(
    ProfessionalIdentity who,
    ReviewSubject subject,
  ) {
    for (final s in ReviewerScope.values) {
      if (who.scopes.contains(s) && subject.scopes.contains(s)) return s;
    }
    return null;
  }

  /// Professional maqom bo‘yicha qaror kim chiqara oladi:
  /// * **identity admin** (inson), yoki
  /// * shu **soha vakolatiga ega, allaqachon tasdiqlangan mutaxassis**.
  ///
  /// O‘zini tasdiqlash, talaba, tasdiqlanmagan / to‘xtatilgan mutaxassis,
  /// AI — hech qachon. Bu qaror ilmiy taqriz huquqini **bermaydi**.
  static bool canDecideIdentity(
    ProfessionalIdentity actor,
    String applicantId, {
    ReviewerScope? scope,
  }) => IdentityVerification.approverKind(actor, applicantId, scope) != null;

  /// Soha vakolatini berish — alohida rol; o‘ziga berish mumkin emas va
  /// faqat tasdiqlangan mutaxassisga beriladi.
  static bool canGrantScope(
    ProfessionalIdentity actor,
    ProfessionalIdentity target,
  ) =>
      actor.isHuman &&
      actor.roles.contains(AccountRole.scopeGrantor) &&
      actor.userId != target.userId &&
      target.isVerifiedProfessional;
}

/// Maqom bo‘yicha qarorlar.
enum IdentityDecision { verify, requestMoreInformation, reject, suspend }

/// Qarorni kim chiqargan.
enum ApproverKind { identityAdmin, verifiedPeer }

enum IdentityDecisionError {
  notHuman,
  selfApproval,
  notAuthorized,
  scopeRequired,
  invalidTransition,

  /// Tasdiqlash uchun kamida bitta malaka hujjati tekshirilgan bo‘lishi
  /// kerak (hujjat — dalil, avtomatik tasdiq emas).
  noCredentialChecked,
  unknownCredential,
}

/// Maqom qarori yozuvi (audit): kim, qachon, qaysi hujjat, qaysi soha.
@immutable
class IdentityDecisionRecord {
  const IdentityDecisionRecord({
    required this.applicantId,
    required this.approverId,
    required this.approverKind,
    required this.decision,
    required this.scope,
    required this.from,
    required this.to,
    required this.checkedCredentialIds,
    required this.at,
    this.note,
  });

  final String applicantId;
  final String approverId;
  final ApproverKind approverKind;
  final IdentityDecision decision;

  /// Qaysi mutaxassislik sohasi bo‘yicha tasdiqlandi / ko‘rib chiqildi.
  final ReviewerScope scope;
  final VerificationStatus from;
  final VerificationStatus to;
  final List<String> checkedCredentialIds;
  final DateTime at;
  final String? note;
}

/// Maqom qarori qoidalari (server bilan bir xil; mijoz bayrog‘iga
/// ishonilmaydi — `decide_identity()` serverda xuddi shuni tekshiradi).
abstract final class IdentityVerification {
  static ApproverKind? approverKind(
    ProfessionalIdentity actor,
    String applicantId,
    ReviewerScope? scope,
  ) {
    if (!actor.isHuman || actor.userId == applicantId) return null;
    if (actor.roles.contains(AccountRole.identityAdmin)) {
      return ApproverKind.identityAdmin;
    }
    if (scope != null &&
        actor.isVerifiedProfessional &&
        actor.scopes.contains(scope)) {
      return ApproverKind.verifiedPeer;
    }
    return null;
  }

  static (IdentityDecisionRecord?, IdentityDecisionError?) decide({
    required ProfessionalIdentity actor,
    required ProfessionalApplication application,
    required IdentityDecision decision,
    required ReviewerScope? scope,
    required DateTime at,
    List<String> checkedCredentialIds = const [],
    String? note,
  }) {
    if (!actor.isHuman) return (null, IdentityDecisionError.notHuman);
    if (actor.userId == application.userId) {
      return (null, IdentityDecisionError.selfApproval);
    }
    if (scope == null) return (null, IdentityDecisionError.scopeRequired);
    final kind = approverKind(actor, application.userId, scope);
    if (kind == null) return (null, IdentityDecisionError.notAuthorized);
    // To‘xtatish — faqat identity admin.
    if (decision == IdentityDecision.suspend &&
        kind != ApproverKind.identityAdmin) {
      return (null, IdentityDecisionError.notAuthorized);
    }
    final to = VerificationStateMachine.apply(application.status, decision);
    if (to == null) return (null, IdentityDecisionError.invalidTransition);
    if (decision == IdentityDecision.verify) {
      if (checkedCredentialIds.isEmpty) {
        return (null, IdentityDecisionError.noCredentialChecked);
      }
      final known = {for (final d in application.documents) d.documentId};
      if (!checkedCredentialIds.every(known.contains)) {
        return (null, IdentityDecisionError.unknownCredential);
      }
    }
    return (
      IdentityDecisionRecord(
        applicantId: application.userId,
        approverId: actor.userId,
        approverKind: kind,
        decision: decision,
        scope: scope,
        from: application.status,
        to: to,
        checkedCredentialIds: List.unmodifiable(checkedCredentialIds),
        at: at,
        note: note,
      ),
      null,
    );
  }
}

abstract final class VerificationStateMachine {
  /// Ruxsat etilgan o‘tishlar. Boshqa o‘tish — `null` (rad etiladi).
  static VerificationStatus? apply(
    VerificationStatus from,
    IdentityDecision d,
  ) => switch ((from, d)) {
    (VerificationStatus.applicationPending, IdentityDecision.verify) =>
      VerificationStatus.verifiedProfessional,
    (
      VerificationStatus.applicationPending,
      IdentityDecision.requestMoreInformation,
    ) =>
      VerificationStatus.changesRequested,
    (VerificationStatus.applicationPending, IdentityDecision.reject) =>
      VerificationStatus.rejected,
    (VerificationStatus.verifiedProfessional, IdentityDecision.suspend) =>
      VerificationStatus.suspended,
    (VerificationStatus.suspended, IdentityDecision.verify) =>
      VerificationStatus.verifiedProfessional,
    _ => null,
  };

  /// Foydalanuvchining o‘zi faqat ariza yubora oladi (yoki qayta
  /// yuboradi). Boshqa hech qaysi holatga o‘zi o‘ta olmaydi.
  static VerificationStatus? submit(VerificationStatus from) => switch (from) {
    VerificationStatus.unverified ||
    VerificationStatus.changesRequested ||
    VerificationStatus.rejected => VerificationStatus.applicationPending,
    _ => null,
  };

  static bool canSubmit(VerificationStatus from) => submit(from) != null;
}

/// Ilmiy tasdiq siyosati (konfiguratsiya qilinadi).
@immutable
class ReviewPolicy {
  const ReviewPolicy({
    this.approvalsForHumanVerified = const {
      RiskLevel.standard: 2,
      RiskLevel.high: 2,
    },
    this.highRiskRequiresDistinctOrganizations = true,
  });

  /// HUMAN VERIFIED uchun kerakli **mustaqil** malakali ma’qullashlar.
  final Map<RiskLevel, int> approvalsForHumanVerified;

  /// Yuqori xatarli material: ma’qullagan taqrizchilar turli
  /// tashkilotlardan bo‘lishi kerak.
  final bool highRiskRequiresDistinctOrganizations;

  int requiredFor(RiskLevel r) => approvalsForHumanVerified[r] ?? 2;
}

/// Taqriz qatlamining hisoblangan holati.
@immutable
class ReviewOutcome {
  const ReviewOutcome({
    required this.state,
    required this.current,
    required this.stale,
    required this.countedApprovals,
  });

  final ReviewState state;

  /// Joriy versiyaga tegishli, hisobga olingan malakali taqrizlar.
  final List<ProfessionalReview> current;

  /// Oldingi versiyalarga yozilgan taqrizlar (tarixda saqlanadi).
  final List<ProfessionalReview> stale;
  final int countedApprovals;

  bool get isHumanVerified => state == ReviewState.humanVerified;
}

/// Holatni deterministik hisoblaydi. Faqat quyidagilar hisobga olinadi:
/// inson, hozir ham tasdiqlangan mutaxassis, mos soha vakolati bor,
/// qaytarib olinmagan, **joriy versiyaga** yozilgan taqriz. Har bir
/// taqrizchining eng so‘nggi qarori olinadi.
abstract final class ReviewEvaluator {
  static ReviewOutcome evaluate({
    required ReviewSubject subject,
    required Iterable<ProfessionalReview> reviews,
    required ProfessionalIdentity? Function(String userId) identityOf,
    ReviewPolicy policy = const ReviewPolicy(),
    Set<String> assignedReviewers = const {},
  }) {
    bool qualified(ProfessionalReview r) {
      if (r.withdrawn || r.recordId != subject.recordId) return false;
      if (subject.claimId != null && r.claimId != subject.claimId) {
        return false;
      }
      final who = identityOf(r.reviewerUserId);
      if (who == null || !who.isVerifiedProfessional) return false;
      return who.scopes.contains(r.reviewerScope) &&
          subject.scopes.contains(r.reviewerScope);
    }

    final all = reviews.where(qualified).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final latest = <String, ProfessionalReview>{};
    final stale = <ProfessionalReview>[];
    for (final r in all) {
      if (r.contentVersion == subject.contentVersion) {
        latest[r.reviewerUserId] = r;
      } else {
        stale.add(r);
      }
    }
    final current = latest.values.toList();

    ReviewState state;
    var approvals = 0;
    if (current.isEmpty) {
      state = stale.isNotEmpty
          ? ReviewState.reReviewRequired
          : assignedReviewers.isNotEmpty
          ? ReviewState.reviewInProgress
          : ReviewState.needsReview;
    } else if (current.any((r) => r.action == ReviewAction.reject)) {
      state = ReviewState.rejected;
    } else if (current.any((r) => r.action == ReviewAction.flagConflict)) {
      state = ReviewState.conflictFlagged;
    } else if (current.any((r) => r.action == ReviewAction.flagOutdated)) {
      state = ReviewState.outdatedFlagged;
    } else if (current.any((r) => r.action == ReviewAction.requestChange)) {
      state = ReviewState.changesRequested;
    } else {
      final approvers = [
        for (final r in current)
          if (r.action == ReviewAction.approve) r,
      ];
      approvals = approvers.length;
      final orgs = {
        for (final r in approvers)
          (identityOf(r.reviewerUserId)?.organization ?? r.reviewerUserId)
              .trim()
              .toLowerCase(),
      };
      final independent =
          subject.risk == RiskLevel.high &&
              policy.highRiskRequiresDistinctOrganizations
          ? orgs.length
          : approvals;
      state = independent >= policy.requiredFor(subject.risk)
          ? ReviewState.humanVerified
          : ReviewState.professionalReviewed;
    }
    return ReviewOutcome(
      state: state,
      current: current,
      stale: stale,
      countedApprovals: approvals,
    );
  }

  /// Ilovadagi jami HUMAN VERIFIED soni.
  static int humanVerifiedCount(Iterable<ReviewOutcome> outcomes) =>
      outcomes.where((o) => o.isHumanVerified).length;
}

/// Audit izi yozuvi (o‘chirilmaydi, faqat qo‘shiladi).
@immutable
class ReviewAuditEntry {
  const ReviewAuditEntry({
    required this.entryId,
    required this.recordId,
    required this.contentVersion,
    required this.actorUserId,
    required this.previousState,
    required this.newState,
    required this.at,
    this.claimId,
    this.actorScope,
    this.action,
    this.note,
    this.reviewId,
  });

  final String entryId;
  final String recordId;
  final String? claimId;
  final String contentVersion;
  final String actorUserId;
  final ReviewerScope? actorScope;
  final ReviewAction? action;
  final String? note;
  final String? reviewId;
  final ReviewState previousState;
  final ReviewState newState;
  final DateTime at;
}

/// Faqat qo‘shiladigan audit jurnali (server modelining mijozdagi aksi).
class ReviewAuditLog {
  final List<ReviewAuditEntry> _entries = [];

  List<ReviewAuditEntry> get entries => List.unmodifiable(_entries);

  void append(ReviewAuditEntry e) => _entries.add(e);

  List<ReviewAuditEntry> forRecord(String recordId) => [
    for (final e in _entries)
      if (e.recordId == recordId) e,
  ];
}

/// Material turi/sohasidan taqriz vakolati sohalari. Bo‘sh to‘plam —
/// soha hali tayinlanmagan (hech kim taqriz qila olmaydi).
abstract final class ReviewScopes {
  static Set<ReviewerScope> forKind(ReviewSubjectKind k) => switch (k) {
    ReviewSubjectKind.substance || ReviewSubjectKind.claim => const {
      ReviewerScope.forensicToxicology,
      ReviewerScope.forensicChemistry,
    },
    ReviewSubjectKind.method || ReviewSubjectKind.standard => const {
      ReviewerScope.labAnalytics,
      ReviewerScope.forensicChemistry,
      ReviewerScope.forensicToxicology,
    },
    ReviewSubjectKind.reagent => const {
      ReviewerScope.forensicChemistry,
      ReviewerScope.labAnalytics,
    },
    ReviewSubjectKind.screeningTest => const {
      ReviewerScope.forensicToxicology,
      ReviewerScope.labAnalytics,
    },
    ReviewSubjectKind.forensicMedicine => const {
      ReviewerScope.forensicMedicine,
    },
    ReviewSubjectKind.biochemistry => const {
      ReviewerScope.forensicBiochemistry,
    },
    ReviewSubjectKind.histology => const {ReviewerScope.pathologyHistology},
    ReviewSubjectKind.legal => const {ReviewerScope.legalJurisdiction},
    ReviewSubjectKind.reference || ReviewSubjectKind.research => const {},
  };
}
