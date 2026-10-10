import 'package:flutter/foundation.dart';

import 'professional_models.dart';

/// Ariza hujjati metama’lumoti (fayl mazmuni EMAS — faqat id, tur, xesh).
@immutable
class PendingDocument {
  const PendingDocument({
    required this.documentId,
    required this.kind,
    required this.mimeType,
    required this.sizeBytes,
    required this.sha256,
    required this.uploadedAt,
  });

  final String documentId;
  final CredentialKind? kind;
  final String mimeType;
  final int sizeBytes;
  final String sha256;
  final DateTime? uploadedAt;

  static PendingDocument? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['document_id'];
    if (id is! String || id.isEmpty) return null;
    return PendingDocument(
      documentId: id,
      kind: CredentialKind.values.asNameMap()['${raw['kind']}'],
      mimeType: '${raw['mime_type'] ?? ''}',
      sizeBytes: (raw['size_bytes'] as num?)?.toInt() ?? 0,
      sha256: '${raw['sha256'] ?? ''}',
      uploadedAt: DateTime.tryParse('${raw['uploaded_at'] ?? ''}'),
    );
  }
}

/// Kutayotgan ariza (server `admin_pending_verifications`).
@immutable
class PendingVerification {
  const PendingVerification({
    required this.applicantId,
    required this.displayName,
    required this.position,
    required this.organization,
    required this.country,
    required this.specialty,
    required this.education,
    required this.submittedAt,
    required this.isSelf,
    required this.documents,
    this.additionalSpecialties = const [],
    this.yearsExperience,
  });

  final String applicantId;
  final String displayName;
  final String position;
  final String organization;
  final String country;
  final Specialty? specialty;
  final List<Specialty> additionalSpecialties;
  final int? yearsExperience;
  final String education;
  final DateTime? submittedAt;

  /// Admin’ning o‘z arizasi — uni boshqa vakolatli admin hal qiladi.
  final bool isSelf;
  final List<PendingDocument> documents;

  /// Ariza sohasiga mos taqrizchi doirasi (aniq moslik bo‘lmasa — null,
  /// admin o‘zi tanlaydi).
  ReviewerScope? get suggestedScope => switch (specialty) {
    Specialty.forensicMedicine => ReviewerScope.forensicMedicine,
    Specialty.forensicToxicology => ReviewerScope.forensicToxicology,
    Specialty.forensicChemistry => ReviewerScope.forensicChemistry,
    Specialty.analyticalLaboratory => ReviewerScope.labAnalytics,
    Specialty.forensicBiochemistry => ReviewerScope.forensicBiochemistry,
    Specialty.pathologyHistology => ReviewerScope.pathologyHistology,
    Specialty.geneticsDna => ReviewerScope.geneticsDna,
    Specialty.forensicAnthropology => ReviewerScope.anthropology,
    Specialty.forensicOdontology => ReviewerScope.odontology,
    _ => null,
  };

  static PendingVerification? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['applicant_id'];
    if (id is! String || id.isEmpty) return null;
    final names = Specialty.values.asNameMap();
    return PendingVerification(
      applicantId: id,
      displayName: '${raw['display_name'] ?? ''}',
      position: '${raw['position'] ?? ''}',
      organization: '${raw['organization'] ?? ''}',
      country: '${raw['country_code'] ?? ''}',
      specialty: names['${raw['primary_specialty']}'],
      additionalSpecialties: [
        for (final s in (raw['additional_specialties'] as List? ?? const []))
          ?names['$s'],
      ],
      yearsExperience: (raw['years_experience'] as num?)?.toInt(),
      education: '${raw['education'] ?? ''}',
      submittedAt: DateTime.tryParse('${raw['submitted_at'] ?? ''}'),
      isSelf: raw['is_self'] == true,
      documents: [
        for (final d in (raw['credential_documents'] as List? ?? const []))
          ?PendingDocument.fromJson(d),
      ],
    );
  }
}

@immutable
class PendingVerificationPage {
  const PendingVerificationPage({required this.items, required this.total});

  final List<PendingVerification> items;
  final int total;
}

/// `decide_identity` rad etish sabablari (UI lokalizatsiya qiladi).
enum IdentityDecisionFailure {
  /// O‘z arizasini tasdiqlash — hech kimga ruxsat yo‘q.
  selfApproval,
  forbidden,
  noCredentialChecked,
  unknownCredential,
  invalidTransition,
  noApplication,
  mfaRequired,
  invalidInput,
  notSignedIn,
  notConnected,
  offline,
  server;

  /// Server (Postgres) xabari → sabab. Noma’lum — [server].
  static IdentityDecisionFailure fromServerMessage(String? message) {
    final m = (message ?? '').toLowerCase();
    if (m.contains('self approval')) return selfApproval;
    if (m.contains('no credential checked')) return noCredentialChecked;
    if (m.contains('unknown credential')) return unknownCredential;
    if (m.contains('invalid transition')) return invalidTransition;
    if (m.contains('no application')) return noApplication;
    if (m.contains('mfa required')) return mfaRequired;
    if (m.contains('not signed in')) return notSignedIn;
    if (m.contains('forbidden')) return forbidden;
    return server;
  }
}

/// Qaror shartlari (server bilan bir xil; UI oldindan tekshiradi).
abstract final class IdentityDecisionRules {
  static const minReasonLength = 5;

  static bool reasonOk(String reason) =>
      reason.trim().length >= minReasonLength;
}
