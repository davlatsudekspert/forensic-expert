import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:test/test.dart';

JurisdictionalInstrument _i({
  Map<String, String> titles = const {'en': 'Act', 'de': 'Gesetz'},
  String? lang = 'de',
  String? authority = 'A',
  String? ref = '§ 1',
  DateTime? published,
  TranslationStatus? tr,
}) => JurisdictionalInstrument(
  id: 'I',
  jurisdictionId: 'DE',
  type: InstrumentType.law,
  titles: titles,
  officialSourceId: 'S',
  officialReference: ref,
  effectiveFrom: DateTime.utc(2020),
  version: 'v1',
  status: ScientificStatus.needsReview,
  authorityId: authority,
  publicationDate: published,
  language: lang,
  translationStatus: tr,
  lastVerifiedAt: DateTime.utc(2026, 10, 4),
);

void main() {
  test('to‘liqlik: yetishmayotgan maydonlar ochiq ro‘yxatlanadi', () {
    final m = LegalRecordCompleteness.missing(_i());
    expect(m, contains(LegalRecordField.publicationDate));
    expect(m, contains(LegalRecordField.translationStatus));
    expect(m, contains(LegalRecordField.officialUrl));
    expect(
      LegalRecordCompleteness.missing(
        _i(published: DateTime.utc(2019), tr: TranslationStatus.machineDraft),
        source: const Source(
          sourceId: 'S',
          sourceType: SourceType.legislation,
          title: 't',
          tier: SourceTier.tier1,
          evidenceLevel: EvidenceLevel.a,
          licenseMode: SourceLicenseMode.citeOnly,
          officialUrl: 'https://example.org/law',
        ),
      ),
      isEmpty,
    );
    expect(
      LegalRecordCompleteness.missing(
        _i(
          ref: 'BtMG — date of entry into force not recorded (NEEDS LEGAL REVIEW)',
        ),
      ),
      contains(LegalRecordField.effectiveDate),
    );
  });

  test('o‘zgarish taklifi hech qachon avtomatik nashr etilmaydi', () {
    final p = LegalChangeProposal(
      instrumentId: 'I',
      checkedAt: DateTime.utc(2026, 10, 4),
      previousFingerprint: 'a',
      currentFingerprint: 'b',
    );
    expect(p.status, LegalChangeStatus.needsLegalReview);
    expect(p.autoPublish, isFalse);
    expect(p.proposedStatusForNewVersion(), ScientificStatus.needsReview);
    expect(
      LegalChangeProposal(
        instrumentId: 'I',
        checkedAt: DateTime.utc(2026, 10, 4),
        previousFingerprint: 'a',
        currentFingerprint: 'a',
      ).status,
      LegalChangeStatus.noChangeDetected,
    );
  });

  test('domen: nazorat ro‘yxati va alkogol chegarasi', () {
    JurisdictionalRule r(JurisdictionalRuleType t, String? key) =>
        JurisdictionalRule(
          id: 'R',
          instrumentId: 'I',
          ruleType: t,
          subjectType: 'substance',
          subjectId: 'x',
          value: const {},
          effectiveFrom: DateTime.utc(2020),
          status: ScientificStatus.needsReview,
          topicKey: key,
        );
    expect(
      legalDomainOf(r(JurisdictionalRuleType.controlStatus, null)),
      LegalDomain.controlledSubstances,
    );
    expect(
      legalDomainOf(
        r(
          JurisdictionalRuleType.legalThreshold,
          'drink_drive.prescribed_limit',
        ),
      ),
      LegalDomain.alcoholDriving,
    );
    expect(LegalDomain.values, hasLength(14));
  });
}
