// ============================================================================
// TEST DATA — FAQAT AVTOMATIK TESTLAR UCHUN.
//
// Bu fayldagi hech bir yozuv ilmiy fakt emas. Qiymatlar ataylab ma’nosiz
// (masalan, 1.0 "TEST-UNIT") va barcha ID’lar `TEST-` prefiksi bilan
// boshlanadi. Validator bunday yozuvlarni production to‘plamga o‘tkazmaydi.
// ============================================================================

import 'package:fe_content_schema/fe_content_schema.dart';

const testSourceOpen = Source(
  sourceId: 'TEST-SRC-OPEN',
  sourceType: SourceType.journalArticle,
  title: 'TEST DATA — open-licence placeholder source',
  tier: SourceTier.tier1,
  evidenceLevel: EvidenceLevel.b,
  licenseMode: SourceLicenseMode.openReuse,
  doi: '10.0000/TEST-NOT-A-REAL-DOI',
  identifierVerified: true,
  isTestData: true,
);

const testSourceUnverifiedDoi = Source(
  sourceId: 'TEST-SRC-UNVERIFIED',
  sourceType: SourceType.journalArticle,
  title: 'TEST DATA — source whose DOI was not API-verified',
  tier: SourceTier.tier1,
  evidenceLevel: EvidenceLevel.b,
  licenseMode: SourceLicenseMode.openReuse,
  doi: '10.0000/TEST-UNVERIFIED',
  isTestData: true,
);

const testSourceNonCommercial = Source(
  sourceId: 'TEST-SRC-NC',
  sourceType: SourceType.journalArticle,
  title: 'TEST DATA — non-commercial licence placeholder',
  tier: SourceTier.tier1,
  evidenceLevel: EvidenceLevel.b,
  licenseMode: SourceLicenseMode.nonCommercial,
  isTestData: true,
);

const toxReviewerSenior = Reviewer(
  reviewerId: 'TEST-REV-TOX-SENIOR',
  displayName: 'TEST reviewer (tox, senior)',
  grants: [ReviewerGrant(domain: ContentDomain.tox, canVerify: true)],
);

const toxReviewer = Reviewer(
  reviewerId: 'TEST-REV-TOX',
  displayName: 'TEST reviewer (tox)',
  grants: [ReviewerGrant(domain: ContentDomain.tox)],
);

const fmReviewer = Reviewer(
  reviewerId: 'TEST-REV-FM',
  displayName: 'TEST reviewer (forensic medicine)',
  grants: [ReviewerGrant(domain: ContentDomain.fm, canVerify: true)],
);

Claim testClaim({
  String id = 'TEST-CLAIM-1',
  ScientificStatus status = ScientificStatus.needsReview,
  String field = 'test_field',
  Map<String, Object?> value = const {'text': 'TEST DATA'},
  bool structured = false,
  bool isTestData = true,
  int version = 1,
  ContentDomain domain = ContentDomain.tox,
}) => Claim(
  claimId: id,
  entityType: EntityType.substance,
  entityId: 'TEST-SUBSTANCE-ALPHA',
  field: field,
  value: value,
  domain: domain,
  declaredStatus: status,
  evidenceLevel: EvidenceLevel.b,
  isStructuredValue: structured,
  isTestData: isTestData,
  version: version,
);

Review approve(
  String reviewerId, {
  String claimId = 'TEST-CLAIM-1',
  int version = 1,
  ContentDomain domain = ContentDomain.tox,
}) => Review(
  reviewId: 'TEST-REVIEW-$reviewerId-$claimId-$version',
  claimId: claimId,
  claimVersion: version,
  reviewerId: reviewerId,
  domain: domain,
  decision: ReviewDecision.approve,
  createdAt: DateTime.utc(2026),
);

/// TEST DATA konsentratsiya qiymati — ma’nosiz raqam va birlik.
const testConcentrationValue = <String, Object?>{
  'category': 'reported_postmortem',
  'matrix': 'TEST-MATRIX',
  'population': 'TEST-POPULATION',
  'value_type': 'single',
  'unit': 'TEST-UNIT',
  'value': 1.0,
};
