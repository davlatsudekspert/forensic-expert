import 'package:meta/meta.dart';

import 'enums.dart';
import 'jurisdiction.dart';
import 'source.dart';

/// PHASE 10: huquqiy domenlar. Har bir yurisdiksion qoida shu domenlardan
/// biriga tegishli; domen — navigatsiya, huquqiy xulosa emas.
enum LegalDomain {
  expertStatus,
  evidenceHandling,
  chainOfCustody,
  specimenCollection,
  deathInvestigation,
  autopsy,
  toxicology,
  alcoholDriving,
  controlledSubstances,
  reporting,
  laboratoryStandards,
  retentionStorage,
  testimony,
  qualityAccreditation,
}

/// Qoidaning domeni: aniq `topicKey` prefiksi yoki qoida turidan.
LegalDomain legalDomainOf(JurisdictionalRule r) {
  final k = r.topicKey ?? '';
  if (k.startsWith('drink_drive')) return LegalDomain.alcoholDriving;
  if (k.startsWith('controlled_substance')) {
    return LegalDomain.controlledSubstances;
  }
  return switch (r.ruleType) {
    JurisdictionalRuleType.controlStatus => LegalDomain.controlledSubstances,
    JurisdictionalRuleType.legalThreshold => LegalDomain.alcoholDriving,
    JurisdictionalRuleType.procedureRequirement => LegalDomain.evidenceHandling,
  };
}

/// Real huquqiy yozuv uchun majburiy metadata maydonlari.
enum LegalRecordField {
  officialTitle,
  originalTitle,
  authority,
  documentNumber,
  articleSection,
  officialUrl,
  publicationDate,
  effectiveDate,
  version,
  status,
  lastChecked,
  language,
  translationStatus,
  reviewStatus,
}

/// Yozuv to‘liqligi — yetishmayotgan maydonlar ochiq ko‘rsatiladi
/// (to‘ldirilmaydi, taxmin qilinmaydi).
abstract final class LegalRecordCompleteness {
  static List<LegalRecordField> missing(
    JurisdictionalInstrument i, {
    Source? source,
    JurisdictionalRule? rule,
  }) => [
    if ((i.titles['en'] ?? '').isEmpty) LegalRecordField.officialTitle,
    if (i.language == null || (i.titles[i.language] ?? '').isEmpty)
      LegalRecordField.originalTitle,
    if (i.authorityId == null) LegalRecordField.authority,
    if ((i.officialReference ?? '').isEmpty) LegalRecordField.documentNumber,
    if (rule != null && (rule.articleSection ?? '').isEmpty)
      LegalRecordField.articleSection,
    if ((source?.officialUrl ?? '').isEmpty) LegalRecordField.officialUrl,
    if (i.publicationDate == null) LegalRecordField.publicationDate,
    // effective_from majburiy (sxema); lekin konsolidatsiya sanasi
    // bo‘lsa — kuchga kirish sanasi yozilmagan deb hisoblanadi.
    if ((i.officialReference ?? '').contains(
      'date of entry into force not '
      'recorded',
    ))
      LegalRecordField.effectiveDate,
    if (i.version.isEmpty) LegalRecordField.version,
    if (i.lastVerifiedAt == null) LegalRecordField.lastChecked,
    if (i.language == null) LegalRecordField.language,
    if (i.language != 'en' && i.translationStatus == null)
      LegalRecordField.translationStatus,
  ];
}

enum LegalChangeStatus { noChangeDetected, needsLegalReview }

/// Rasmiy manbadagi o‘zgarish — faqat **taklif**. Qoida avtomatik
/// o‘zgartirilmaydi: legal reviewer ko‘rib chiqib, yangi versiyani
/// tasdiqlaguncha eski versiya o‘z statusi bilan qoladi.
@immutable
class LegalChangeProposal {
  const LegalChangeProposal({
    required this.instrumentId,
    required this.checkedAt,
    required this.previousFingerprint,
    required this.currentFingerprint,
  });

  final String instrumentId;
  final DateTime checkedAt;
  final String previousFingerprint;
  final String currentFingerprint;

  LegalChangeStatus get status => previousFingerprint == currentFingerprint
      ? LegalChangeStatus.noChangeDetected
      : LegalChangeStatus.needsLegalReview;

  /// O‘zgarish topilganda qoidaning ilovadagi holati: avtomatik nashr yo‘q.
  /// Eski qoida REVIEWED/VERIFIED bo‘lsa ham, OUTDATED belgisi faqat
  /// reviewer qarori bilan qo‘yiladi (FE027 jimgina almashtirishni rad
  /// etadi).
  bool get autoPublish => false;

  ScientificStatus proposedStatusForNewVersion() =>
      ScientificStatus.needsReview;
}
