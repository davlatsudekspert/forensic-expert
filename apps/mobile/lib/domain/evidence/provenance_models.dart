import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/foundation.dart';

import '../library/library_models.dart';

/// PHASE 7: «EVIDENCE CONFLICT» yozuvi (ilova ko‘rinishi).
@immutable
class ConflictView {
  const ConflictView({
    required this.id,
    required this.entityId,
    required this.question,
    required this.kind,
    required this.note,
    required this.state,
    required this.claimIds,
    this.detectedAt,
  });

  final String id;
  final String entityId;
  final String question;
  final ConflictKind kind;
  final String note;
  final EvidenceConflictState state;
  final List<String> claimIds;
  final DateTime? detectedAt;
}

@immutable
class SpecimenView {
  const SpecimenView({
    required this.id,
    required this.category,
    required this.names,
    this.aliases = const [],
  });

  final String id;
  final String category;
  final LocalizedText names;
  final List<String> aliases;
}

@immutable
class StandardView {
  const StandardView({
    required this.id,
    required this.designation,
    required this.title,
    required this.publisher,
    required this.documentKind,
    required this.status,
    required this.reuse,
    required this.verifiedFrom,
    required this.verifiedAt,
    this.year,
    this.edition,
    this.supersededBy,
    this.url,
    this.sha256,
    this.note,
  });

  final String id;
  final String designation;
  final String title;
  final String publisher;
  final DocumentKind documentKind;
  final StandardStatus status;
  final ReuseStatus reuse;
  final String verifiedFrom;
  final DateTime verifiedAt;
  final String? year;
  final String? edition;
  final String? supersededBy;
  final String? url;
  final String? sha256;
  final String? note;
}

/// Review holati — bazadagi haqiqiy yozuvlardan hisoblanadi (hech narsa
/// qo‘lda yozilmaydi).
@immutable
class ReviewSummary {
  const ReviewSummary({
    required this.claimsByStatus,
    required this.claimsByLifecycle,
    required this.reviewers,
    required this.reviewActions,
    required this.openConflicts,
  });

  static const empty = ReviewSummary(
    claimsByStatus: {},
    claimsByLifecycle: {},
    reviewers: 0,
    reviewActions: 0,
    openConflicts: 0,
  );

  final Map<ScientificStatus, int> claimsByStatus;
  final Map<ClaimLifecycle, int> claimsByLifecycle;
  final int reviewers;
  final int reviewActions;
  final int openConflicts;

  /// Haqiqiy reviewer tomonidan VERIFIED qilingan claim’lar.
  int get humanVerified => claimsByStatus[ScientificStatus.verified] ?? 0;
  int get reviewed => claimsByStatus[ScientificStatus.reviewed] ?? 0;
  int get total => claimsByStatus.values.fold(0, (a, b) => a + b);
}

/// PHASE 7 provenance qatlami: ziddiyatlar, metabolit munosabatlari,
/// namunalar, standartlar, termin tarjimalari va review holati.
@immutable
class ProvenanceIndex {
  ProvenanceIndex({
    this.conflicts = const [],
    this.metabolites = const [],
    this.specimens = const [],
    this.standards = const [],
    this.terms = const [],
    this.claimsById = const {},
    this.review = ReviewSummary.empty,
  });

  static final empty = ProvenanceIndex();

  final List<ConflictView> conflicts;
  final List<MetaboliteRelation> metabolites;
  final List<SpecimenView> specimens;
  final List<StandardView> standards;
  final List<TermTranslation> terms;
  final Map<String, ClaimView> claimsById;
  final ReviewSummary review;

  late final Map<String, ConflictView> _conflictById = {
    for (final c in conflicts) c.id: c,
  };
  late final Map<String, SpecimenView> _specimenById = {
    for (final s in specimens) s.id: s,
  };

  ConflictView? conflict(String id) => _conflictById[id];
  SpecimenView? specimen(String id) => _specimenById[id];
  StandardView? standard(String id) {
    for (final s in standards) {
      if (s.id == id) return s;
    }
    return null;
  }

  List<MetaboliteRelation> metabolitesOf(String parentId) => [
    for (final m in metabolites)
      if (m.parentId == parentId) m,
  ];

  List<MetaboliteRelation> parentsOf(String metaboliteId) => [
    for (final m in metabolites)
      if (m.metaboliteId == metaboliteId) m,
  ];

  List<ConflictView> conflictsFor(String entityId) => [
    for (final c in conflicts)
      if (c.entityId == entityId) c,
  ];

  /// Namuna bo‘yicha konsentratsiya claim’lari (qat’iy kontekstdan).
  List<ClaimView> claimsMeasuredIn(String specimenId) => [
    for (final c in claimsById.values)
      if (c.field == 'reported_concentration' &&
          ((c.strictContext?['specimen'] as List?) ?? const []).contains(
            specimenId,
          ))
        c,
  ]..sort((a, b) => a.claimId.compareTo(b.claimId));

  /// Namunaning o‘z claim’lari (qo‘llanilishi, cheklovlari).
  List<ClaimView> claimsAbout(String specimenId) => [
    for (final c in claimsById.values)
      if (c.entityId == specimenId) c,
  ];

  /// Retraksiya/almashtirish sabab joriy bo‘lmagan claim’lar.
  List<ClaimView> get notCurrentBySource => [
    for (final c in claimsById.values)
      if (c.lifecycle == ClaimLifecycle.retracted ||
          c.lifecycle == ClaimLifecycle.superseded)
        c,
  ];
}
