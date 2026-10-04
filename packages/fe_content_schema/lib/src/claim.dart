import 'package:meta/meta.dart';

import 'enums.dart';

/// Fakt (claim) qaysi yozuvga tegishli.
enum EntityType {
  substance,
  metabolite,
  method,
  specimen,
  topic,
  calculator,
  glossaryTerm,
  quizQuestion,
  legalStatus,
}

/// Bitta ilmiy fakt yoki qiymat (6.3-bo‘lim).
///
/// `scientificStatus` — **e’lon qilingan** status. Validator uni review
/// yozuvlaridan hisoblangan status bilan solishtiradi va mos kelmasa
/// to‘plamni rad etadi.
@immutable
class Claim {
  const Claim({
    required this.claimId,
    required this.entityType,
    required this.entityId,
    required this.field,
    required this.value,
    required this.domain,
    required this.declaredStatus,
    required this.evidenceLevel,
    this.groupId,
    this.preferred = false,
    this.preferenceReason,
    this.isStructuredValue = false,
    this.isTestData = false,
    this.version = 1,
  });

  final String claimId;
  final EntityType entityType;
  final String entityId;

  /// Masalan: `metabolites`, `concentration`, `mechanism`.
  final String field;

  /// Strukturaviy qiymat yoki matn bloki (JSON’ga mos).
  final Map<String, Object?> value;

  /// Qaysi domen reviewer’i tekshiradi.
  final ContentDomain domain;
  final ScientificStatus declaredStatus;
  final EvidenceLevel evidenceLevel;

  /// Ziddiyat guruhi (23-bo‘lim).
  final String? groupId;
  final bool preferred;
  final String? preferenceReason;

  /// Raqam, jadval qatori kabi strukturaviy qiymatmi (litsenziya qoidasi uchun).
  final bool isStructuredValue;

  /// TEST DATA.
  final bool isTestData;
  final int version;
}

/// Fakt ↔ manba bog‘lanishi.
@immutable
class Citation {
  const Citation({required this.claimId, required this.sourceId, this.locator});

  final String claimId;
  final String sourceId;

  /// Sahifa, jadval yoki bo‘lim.
  final String? locator;
}

/// Ziddiyat holati.
enum ConflictState { consistent, minorDifference, conflict, unresolved }

/// Bir xil savolga tegishli turli manbalardagi claim’lar guruhi.
@immutable
class ClaimGroup {
  const ClaimGroup({
    required this.groupId,
    required this.contextKey,
    required this.conflictState,
    this.editorialNote,
  });

  final String groupId;

  /// Masalan: `matrix=femoral_blood;population=postmortem`.
  final String contextKey;
  final ConflictState conflictState;
  final String? editorialNote;
}
