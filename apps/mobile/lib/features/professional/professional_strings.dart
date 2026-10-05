import '../../core/l10n/generated/app_localizations.dart';
import '../../domain/ports/professional_ports.dart';
import '../../domain/professional/professional_models.dart';
import '../../domain/professional/review_models.dart';

/// Professional domen enum’larining lokalizatsiyasi.
extension ProfessionalStrings on AppLocalizations {
  String studentRoleLabel(StudentRole r) => switch (r) {
    StudentRole.student => roleStudent,
    StudentRole.residentTrainee => roleResident,
    StudentRole.researcher => roleResearcher,
  };

  String professionalRoleLabel(ProfessionalRole r) => switch (r) {
    ProfessionalRole.forensicExpert => roleForensicExpert,
    ProfessionalRole.forensicPhysician => roleForensicPhysician,
    ProfessionalRole.forensicToxicologist => roleForensicToxicologist,
    ProfessionalRole.forensicChemist => roleForensicChemist,
    ProfessionalRole.laboratorySpecialist => roleLaboratorySpecialist,
    ProfessionalRole.pathologist => rolePathologist,
    ProfessionalRole.geneticist => roleGeneticist,
    ProfessionalRole.forensicBiochemist => roleForensicBiochemist,
    ProfessionalRole.anthropologist => roleAnthropologist,
    ProfessionalRole.odontologist => roleOdontologist,
    ProfessionalRole.other => roleOtherProfessional,
  };

  String specialtyLabel(Specialty s) => switch (s) {
    Specialty.forensicMedicine => specForensicMedicine,
    Specialty.forensicToxicology => specForensicToxicology,
    Specialty.forensicChemistry => specForensicChemistry,
    Specialty.analyticalLaboratory => specAnalyticalLaboratory,
    Specialty.forensicBiochemistry => specForensicBiochemistry,
    Specialty.pathologyHistology => specPathologyHistology,
    Specialty.geneticsDna => specGeneticsDna,
    Specialty.forensicAnthropology => specForensicAnthropology,
    Specialty.forensicOdontology => specForensicOdontology,
    Specialty.forensicRadiology => specForensicRadiology,
    Specialty.forensicPsychology => specForensicPsychology,
    Specialty.forensicBiology => specForensicBiology,
    Specialty.entomology => specEntomology,
    Specialty.other => specOther,
  };

  String studyLevelLabel(StudyLevel s) => switch (s) {
    StudyLevel.bachelor => studyBachelor,
    StudyLevel.master => studyMaster,
    StudyLevel.residency => studyResidency,
    StudyLevel.doctoral => studyDoctoral,
    StudyLevel.other => studyOther,
  };

  String scopeLabel(ReviewerScope s) => switch (s) {
    ReviewerScope.forensicToxicology => specForensicToxicology,
    ReviewerScope.forensicChemistry => specForensicChemistry,
    ReviewerScope.forensicMedicine => specForensicMedicine,
    ReviewerScope.labAnalytics => specAnalyticalLaboratory,
    ReviewerScope.forensicBiochemistry => specForensicBiochemistry,
    ReviewerScope.pathologyHistology => specPathologyHistology,
    ReviewerScope.geneticsDna => specGeneticsDna,
    ReviewerScope.anthropology => specForensicAnthropology,
    ReviewerScope.odontology => specForensicOdontology,
    ReviewerScope.legalJurisdiction => scopeLegal,
    ReviewerScope.translation => scopeTranslation,
  };

  String verificationStatusLabel(VerificationStatus s) => switch (s) {
    VerificationStatus.unverified => verifUnverified,
    VerificationStatus.applicationPending => verifPending,
    VerificationStatus.verifiedProfessional => verifVerified,
    VerificationStatus.changesRequested => verifChangesRequested,
    VerificationStatus.rejected => verifRejected,
    VerificationStatus.suspended => verifSuspended,
  };

  String credentialKindLabel(CredentialKind k) => switch (k) {
    CredentialKind.professionalCertificate => credProfessionalCertificate,
    CredentialKind.qualificationCertificate => credQualificationCertificate,
    CredentialKind.diploma => credDiploma,
    CredentialKind.employmentEvidence => credEmployment,
    CredentialKind.registrationLicense => credRegistration,
    CredentialKind.trainingCertificate => credTraining,
  };

  String credentialFileErrorLabel(CredentialFileError e) => switch (e) {
    CredentialFileError.empty => credErrorEmpty,
    CredentialFileError.tooLarge => credErrorTooLarge,
    CredentialFileError.unsupportedType => credErrorType,
  };

  String reviewActionLabel(ReviewAction a) => switch (a) {
    ReviewAction.approve => reviewActApprove,
    ReviewAction.requestChange => reviewActRequestChange,
    ReviewAction.flagConflict => reviewActConflict,
    ReviewAction.flagOutdated => reviewActOutdated,
    ReviewAction.reject => reviewActReject,
  };

  String reviewDecisionLabel(ReviewAction a) => switch (a) {
    ReviewAction.approve => reviewDecApprove,
    ReviewAction.requestChange => reviewDecRequestChange,
    ReviewAction.flagConflict => reviewDecConflict,
    ReviewAction.flagOutdated => reviewDecOutdated,
    ReviewAction.reject => reviewDecReject,
  };

  String reviewStateLabel(ReviewState s) => switch (s) {
    ReviewState.needsReview => statusNeedsReview,
    ReviewState.reviewInProgress => reviewStateInProgress,
    ReviewState.professionalReviewed => reviewStateProfessional,
    ReviewState.humanVerified => reviewStateHumanVerified,
    ReviewState.changesRequested => reviewDecRequestChange,
    ReviewState.conflictFlagged => reviewDecConflict,
    ReviewState.outdatedFlagged => reviewDecOutdated,
    ReviewState.rejected => reviewDecReject,
    ReviewState.reReviewRequired => reviewStateReReview,
  };

  String reviewQueueLabel(ReviewQueue q) => switch (q) {
    ReviewQueue.needsReview => queueNeedsReview,
    ReviewQueue.assignedToMe => queueAssigned,
    ReviewQueue.reviewedByMe => queueReviewedByMe,
    ReviewQueue.conflicts => queueConflicts,
    ReviewQueue.reReview => queueReReview,
  };

  String reviewPermissionLabel(ReviewPermission p) => switch (p) {
    ReviewPermission.allowed => reviewPermAllowed,
    ReviewPermission.notSignedIn => reviewPermSignIn,
    ReviewPermission.notHuman => reviewPermNotVerified,
    ReviewPermission.notVerified => reviewPermNotVerified,
    ReviewPermission.suspended => reviewPermSuspended,
    ReviewPermission.scopeNotGranted => reviewPermScope,
    ReviewPermission.studentMode => reviewPermStudentMode,
  };

  String professionalFailureLabel(ProfessionalFailure f) => switch (f) {
    ProfessionalFailure.serviceNotConnected => proServiceNotConnected,
    ProfessionalFailure.notSignedIn => reviewPermSignIn,
    ProfessionalFailure.invalidInput => proInvalidInput,
    ProfessionalFailure.tooManyFiles => credErrorTooMany,
    ProfessionalFailure.invalidFile => credErrorType,
    ProfessionalFailure.forbidden => reviewPermNotVerified,
    ProfessionalFailure.offline => proOffline,
    ProfessionalFailure.server => proServerError,
  };

  String profileFieldErrorLabel(ProfileFieldError e) => switch (e) {
    ProfileFieldError.required => formRequired,
    ProfileFieldError.tooLong => formTooLong,
    ProfileFieldError.invalid => formInvalid,
  };
}
