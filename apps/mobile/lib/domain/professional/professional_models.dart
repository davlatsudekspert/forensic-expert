/// Foydalanuvchi profili, professional maqom va taqriz huquqlari domeni.
///
/// Beshta tushuncha **alohida** saqlanadi va bir-birini avtomatik
/// keltirib chiqarmaydi:
///
/// 1. **Foydalanish rejimi** (`UserMode`) — faqat UI tanlovi (qurilmada).
/// 2. **Identifikatsiya** — akkaunt (`AuthAccount`), ixtiyoriy.
/// 3. **Professional maqom** ([VerificationStatus]) — faqat vakolatli
///    inson (identity admin) server tomonida beradi.
/// 4. **Taqrizchi vakolati** ([ReviewerScope]) — maqomdan alohida, har bir
///    soha uchun alohida beriladi.
/// 5. **Ilmiy tasdiq** — [ReviewPolicy] bo‘yicha bir nechta mustaqil
///    malakali taqrizdan keyin hisoblanadi; bitta taqriz, AI, admin roli
///    yoki DOI tekshiruvi ilmiy tasdiq emas.
library;

import 'package:flutter/foundation.dart';

/// Talaba rejimidagi kichik rol.
enum StudentRole { student, residentTrainee, researcher }

/// Professional rejimda **e’lon qilingan** kasb (tasdiqlanmagan).
enum ProfessionalRole {
  forensicExpert,
  forensicPhysician,
  forensicToxicologist,
  forensicChemist,
  laboratorySpecialist,
  pathologist,
  geneticist,
  forensicBiochemist,
  anthropologist,
  odontologist,
  other,
}

/// Mutaxassislik (profil uchun). Taqriz vakolati emas — qarang
/// [ReviewerScope].
enum Specialty {
  forensicMedicine,
  forensicToxicology,
  forensicChemistry,
  analyticalLaboratory,
  forensicBiochemistry,
  pathologyHistology,
  geneticsDna,
  forensicAnthropology,
  forensicOdontology,
  forensicRadiology,
  forensicPsychology,
  forensicBiology,
  entomology,
  other,
}

enum StudyLevel { bachelor, master, residency, doctoral, other }

/// Taqrizchi vakolati sohasi. Har biri alohida beriladi; toksikologiya
/// vakolati DNK, gistologiya yoki huquqiy yozuvlarni qamramaydi.
enum ReviewerScope {
  forensicToxicology('FORENSIC_TOXICOLOGY'),
  forensicChemistry('FORENSIC_CHEMISTRY'),
  forensicMedicine('FORENSIC_MEDICINE'),
  labAnalytics('LAB_ANALYTICS'),
  forensicBiochemistry('FORENSIC_BIOCHEMISTRY'),
  pathologyHistology('PATHOLOGY_HISTOLOGY'),
  geneticsDna('GENETICS_DNA'),
  anthropology('ANTHROPOLOGY'),
  odontology('ODONTOLOGY'),
  legalJurisdiction('LEGAL_JURISDICTION'),
  translation('TRANSLATION');

  const ReviewerScope(this.code);

  final String code;

  static ReviewerScope? fromCode(String code) {
    for (final s in values) {
      if (s.code == code) return s;
    }
    return null;
  }
}

/// Professional maqom holati (server manbai; mijoz o‘zgartira olmaydi).
enum VerificationStatus {
  unverified('UNVERIFIED'),
  applicationPending('APPLICATION_PENDING'),
  verifiedProfessional('VERIFIED_PROFESSIONAL'),
  changesRequested('CHANGES_REQUESTED'),
  rejected('REJECTED'),
  suspended('SUSPENDED');

  const VerificationStatus(this.code);

  final String code;

  static VerificationStatus fromCode(String code) => values.firstWhere(
    (s) => s.code == code,
    orElse: () => VerificationStatus.unverified,
  );
}

/// Malaka hujjati turi.
enum CredentialKind {
  professionalCertificate,
  qualificationCertificate,
  diploma,
  employmentEvidence,
  registrationLicense,
  trainingCertificate,
}

/// Akkaunt rollari (server bergan). Identity admin ≠ ilmiy taqrizchi:
/// admin roli hech qanday [ReviewerScope] bermaydi.
enum AccountRole { user, identityAdmin, scopeGrantor }

/// Talaba profili (faqat qurilmada; bulutga yuborilmaydi).
@immutable
class StudentProfile {
  const StudentProfile({
    required this.fullName,
    required this.country,
    this.role = StudentRole.student,
    this.institution,
    this.faculty,
    this.studyLevel,
    this.interests = const [],
  });

  final String fullName;
  final String country;
  final StudentRole role;
  final String? institution;
  final String? faculty;
  final StudyLevel? studyLevel;
  final List<Specialty> interests;

  Map<String, Object?> toJson() => {
    'full_name': fullName,
    'country': country,
    'role': role.name,
    'institution': institution,
    'faculty': faculty,
    'study_level': studyLevel?.name,
    'interests': [for (final i in interests) i.name],
  };

  static StudentProfile fromJson(Map<String, Object?> j) => StudentProfile(
    fullName: j['full_name'] as String? ?? '',
    country: j['country'] as String? ?? '',
    role: StudentRole.values.asNameMap()[j['role']] ?? StudentRole.student,
    institution: j['institution'] as String?,
    faculty: j['faculty'] as String?,
    studyLevel: StudyLevel.values.asNameMap()[j['study_level']],
    interests: _specialties(j['interests']),
  );
}

/// Professional profil — **e’lon qilingan** ma’lumot. Uni to‘ldirish
/// professional maqomni tasdiqlamaydi.
@immutable
class ProfessionalProfile {
  const ProfessionalProfile({
    required this.fullName,
    required this.country,
    required this.organization,
    required this.position,
    required this.primarySpecialty,
    required this.education,
    this.role = ProfessionalRole.forensicExpert,
    this.city,
    this.additionalSpecialties = const [],
    this.yearsExperience,
    this.workEmail,
    this.licenseNumber,
    this.bio,
    this.languages = const [],
    this.interests,
    this.showOrganizationPublicly = false,
  });

  final String fullName;
  final String country;
  final String organization;
  final String position;
  final Specialty primarySpecialty;
  final String education;
  final ProfessionalRole role;
  final String? city;
  final List<Specialty> additionalSpecialties;
  final int? yearsExperience;

  /// Ixtiyoriy. Hech qachon ochiq profilda ko‘rsatilmaydi.
  final String? workEmail;

  /// Ixtiyoriy va yurisdiksiyaga bog‘liq (hamma davlatda mavjud emas).
  /// Hech qachon ochiq profilda ko‘rsatilmaydi.
  final String? licenseNumber;
  final String? bio;
  final List<String> languages;
  final String? interests;
  final bool showOrganizationPublicly;

  Map<String, Object?> toJson() => {
    'full_name': fullName,
    'country': country,
    'organization': organization,
    'position': position,
    'primary_specialty': primarySpecialty.name,
    'education': education,
    'role': role.name,
    'city': city,
    'additional_specialties': [for (final s in additionalSpecialties) s.name],
    'years_experience': yearsExperience,
    'work_email': workEmail,
    'license_number': licenseNumber,
    'bio': bio,
    'languages': languages,
    'interests': interests,
    'show_organization_publicly': showOrganizationPublicly,
  };

  static ProfessionalProfile fromJson(
    Map<String, Object?> j,
  ) => ProfessionalProfile(
    fullName: j['full_name'] as String? ?? '',
    country: j['country'] as String? ?? '',
    organization: j['organization'] as String? ?? '',
    position: j['position'] as String? ?? '',
    primarySpecialty:
        Specialty.values.asNameMap()[j['primary_specialty']] ?? Specialty.other,
    education: j['education'] as String? ?? '',
    role:
        ProfessionalRole.values.asNameMap()[j['role']] ??
        ProfessionalRole.other,
    city: j['city'] as String?,
    additionalSpecialties: _specialties(j['additional_specialties']),
    yearsExperience: (j['years_experience'] as num?)?.toInt(),
    workEmail: j['work_email'] as String?,
    licenseNumber: j['license_number'] as String?,
    bio: j['bio'] as String?,
    languages: [for (final x in (j['languages'] as List? ?? const [])) '$x'],
    interests: j['interests'] as String?,
    showOrganizationPublicly: j['show_organization_publicly'] == true,
  );

  /// Diagnostika/jurnal uchun — shaxsiy ma’lumot chiqmaydi.
  @override
  String toString() => 'ProfessionalProfile(<redacted>)';
}

List<Specialty> _specialties(Object? raw) => [
  for (final x in (raw as List? ?? const [])) ?Specialty.values.asNameMap()[x],
];

/// Qurilmadagi foydalanuvchi profili (ixtiyoriy).
@immutable
class LocalUserProfile {
  const LocalUserProfile({this.student, this.professional});

  final StudentProfile? student;
  final ProfessionalProfile? professional;

  bool get isEmpty => student == null && professional == null;

  Map<String, Object?> toJson() => {
    'v': 1,
    if (student != null) 'student': student!.toJson(),
    if (professional != null) 'professional': professional!.toJson(),
  };

  static LocalUserProfile fromJson(Map<String, Object?> j) => LocalUserProfile(
    student: switch (j['student']) {
      final Map<Object?, Object?> m => StudentProfile.fromJson(
        m.cast<String, Object?>(),
      ),
      _ => null,
    },
    professional: switch (j['professional']) {
      final Map<Object?, Object?> m => ProfessionalProfile.fromJson(
        m.cast<String, Object?>(),
      ),
      _ => null,
    },
  );

  LocalUserProfile withStudent(StudentProfile? s) =>
      LocalUserProfile(student: s, professional: professional);

  LocalUserProfile withProfessional(ProfessionalProfile? p) =>
      LocalUserProfile(student: student, professional: p);

  @override
  String toString() => 'LocalUserProfile(<redacted>)';
}

/// Formadagi maydon xatolari.
enum ProfileField {
  fullName,
  country,
  organization,
  position,
  education,
  yearsExperience,
  workEmail,
  bio,
}

enum ProfileFieldError { required, tooLong, invalid }

abstract final class ProfileValidation {
  static const maxName = 120;
  static const maxText = 160;
  static const maxBio = 600;
  static const maxYears = 70;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static Map<ProfileField, ProfileFieldError> student(StudentProfile p) => {
    ..._name(p.fullName),
    if (p.country.trim().isEmpty)
      ProfileField.country: ProfileFieldError.required,
  };

  static Map<ProfileField, ProfileFieldError> professional(
    ProfessionalProfile p,
  ) => {
    ..._name(p.fullName),
    if (p.country.trim().isEmpty)
      ProfileField.country: ProfileFieldError.required,
    ..._text(ProfileField.organization, p.organization),
    ..._text(ProfileField.position, p.position),
    ..._text(ProfileField.education, p.education),
    if (p.yearsExperience case final y? when y < 0 || y > maxYears)
      ProfileField.yearsExperience: ProfileFieldError.invalid,
    if (p.workEmail case final e? when e.trim().isNotEmpty)
      if (!_email.hasMatch(e.trim()))
        ProfileField.workEmail: ProfileFieldError.invalid,
    if ((p.bio ?? '').length > maxBio)
      ProfileField.bio: ProfileFieldError.tooLong,
  };

  static Map<ProfileField, ProfileFieldError> _name(String v) => {
    if (v.trim().isEmpty)
      ProfileField.fullName: ProfileFieldError.required
    else if (v.trim().length > maxName)
      ProfileField.fullName: ProfileFieldError.tooLong,
  };

  static Map<ProfileField, ProfileFieldError> _text(ProfileField f, String v) =>
      {
        if (v.trim().isEmpty)
          f: ProfileFieldError.required
        else if (v.trim().length > maxText)
          f: ProfileFieldError.tooLong,
      };
}

/// Ochiq professional profil — **faqat** ochiq maydonlar. Hujjatlar,
/// email, telefon, litsenziya raqami, ID va tekshiruv izohlari bu yerda
/// tuzilishiga ko‘ra yo‘q.
@immutable
class PublicProfessionalProfile {
  const PublicProfessionalProfile({
    required this.userId,
    required this.displayName,
    required this.status,
    required this.specialty,
    required this.country,
    this.organization,
    this.yearsExperience,
    this.reviewCount = 0,
    this.reviewScopes = const {},
  });

  final String userId;
  final String displayName;
  final VerificationStatus status;
  final Specialty specialty;
  final String country;

  /// Faqat foydalanuvchi ruxsat bergan bo‘lsa.
  final String? organization;
  final int? yearsExperience;
  final int reviewCount;
  final Set<ReviewerScope> reviewScopes;

  bool get isVerified => status == VerificationStatus.verifiedProfessional;
}

/// Server tomonidan qaytarilgan (va server tekshiradigan) identifikatsiya.
/// Mijoz bu obyektni o‘zi yaratmaydi — faqat xizmatdan oladi. Mijozdagi
/// qiymat faqat UI’ni yashirish/ko‘rsatish uchun; huquq har doim serverda
/// qayta tekshiriladi.
@immutable
class ProfessionalIdentity {
  const ProfessionalIdentity({
    required this.userId,
    required this.displayName,
    required this.status,
    this.isHuman = true,
    this.scopes = const {},
    this.verifierScopes = const {},
    this.roles = const {AccountRole.user},
    this.specialty,
    this.organization,
  });

  final String userId;
  final String displayName;
  final VerificationStatus status;

  /// AI agent yoki avtomatik jarayon — hech qachon taqrizchi emas.
  final bool isHuman;

  /// Ilmiy taqriz vakolati (soha bo‘yicha).
  final Set<ReviewerScope> scopes;

  /// `CAN_VERIFY_PROFESSIONALS` — boshqa mutaxassislarni tasdiqlash
  /// vakolati (soha bo‘yicha, alohida beriladi). Oddiy tasdiqlangan
  /// mutaxassisda yo‘q.
  final Set<ReviewerScope> verifierScopes;
  final Set<AccountRole> roles;
  final Specialty? specialty;
  final String? organization;

  bool get isVerifiedProfessional =>
      isHuman && status == VerificationStatus.verifiedProfessional;
}

/// Mijoz tanlagan, hali yuborilmagan hujjat. Baytlar faqat xotirada
/// turadi (diskka, jurnalga yoki analitikaga yozilmaydi).
@immutable
class CredentialFile {
  const CredentialFile({
    required this.fileName,
    required this.kind,
    required this.bytes,
  });

  final String fileName;
  final CredentialKind kind;
  final Uint8List bytes;

  int get sizeBytes => bytes.length;

  @override
  String toString() => 'CredentialFile(${kind.name}, $sizeBytes B)';
}

enum CredentialFileType { pdf, jpeg, png }

enum CredentialFileError { empty, tooLarge, unsupportedType }

/// Fayl turi kengaytma bo‘yicha emas, **ichidagi imzo** (magic bytes)
/// bo‘yicha aniqlanadi.
abstract final class CredentialFilePolicy {
  static const maxBytes = 10 * 1024 * 1024;
  static const maxFiles = 5;

  static CredentialFileType? detect(Uint8List b) {
    if (b.length >= 5 &&
        b[0] == 0x25 &&
        b[1] == 0x50 &&
        b[2] == 0x44 &&
        b[3] == 0x46 &&
        b[4] == 0x2D) {
      return CredentialFileType.pdf;
    }
    if (b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) {
      return CredentialFileType.jpeg;
    }
    if (b.length >= 8 &&
        b[0] == 0x89 &&
        b[1] == 0x50 &&
        b[2] == 0x4E &&
        b[3] == 0x47 &&
        b[4] == 0x0D &&
        b[5] == 0x0A &&
        b[6] == 0x1A &&
        b[7] == 0x0A) {
      return CredentialFileType.png;
    }
    return null;
  }

  static CredentialFileError? validate(Uint8List bytes) {
    if (bytes.isEmpty) return CredentialFileError.empty;
    if (bytes.length > maxBytes) return CredentialFileError.tooLarge;
    if (detect(bytes) == null) return CredentialFileError.unsupportedType;
    return null;
  }
}

/// Serverdagi hujjat metama’lumoti. **URL maydoni yo‘q**: hujjat faqat
/// xususiy omborda; ko‘rish faqat identity admin uchun qisqa muddatli
/// imzolangan havola orqali, server tomonida.
@immutable
class CredentialDocumentMeta {
  const CredentialDocumentMeta({
    required this.documentId,
    required this.kind,
    required this.type,
    required this.sizeBytes,
    required this.uploadedAt,
  });

  final String documentId;
  final CredentialKind kind;
  final CredentialFileType type;
  final int sizeBytes;
  final DateTime uploadedAt;
}

/// Professional ariza (server holati).
@immutable
class ProfessionalApplication {
  const ProfessionalApplication({
    required this.applicationId,
    required this.userId,
    required this.status,
    required this.declaredSpecialty,
    required this.submittedAt,
    this.documents = const [],
    this.applicantMessage,
  });

  final String applicationId;
  final String userId;
  final VerificationStatus status;
  final Specialty declaredSpecialty;
  final DateTime submittedAt;
  final List<CredentialDocumentMeta> documents;

  /// Admin foydalanuvchiga yuborgan xabar (masalan, qanday hujjat kerak).
  /// Ichki tekshiruv izohlari bu yerda yo‘q — ular faqat serverda.
  final String? applicantMessage;
}
