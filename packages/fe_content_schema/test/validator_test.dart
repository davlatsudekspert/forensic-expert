import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:test/test.dart';

import 'fixtures/test_data.dart';

void main() {
  const validator = ContentValidator();

  ContentBundle bundle({
    BundleChannel channel = BundleChannel.test,
    List<Claim>? claims,
    List<Citation>? citations,
    List<Review> reviews = const [],
    List<Source>? sources,
    List<ClaimGroup> groups = const [],
  }) => ContentBundle(
    channel: channel,
    sources:
        sources ??
        [testSourceOpen, testSourceUnverifiedDoi, testSourceNonCommercial],
    claims: claims ?? [testClaim()],
    citations:
        citations ??
        const [Citation(claimId: 'TEST-CLAIM-1', sourceId: 'TEST-SRC-OPEN')],
    reviewers: const [toxReviewerSenior, toxReviewer, fmReviewer],
    reviews: reviews,
    groups: groups,
  );

  test('valid test bundle with NEEDS_REVIEW claim passes', () {
    final report = validator.validate(bundle());
    expect(report.isValid, isTrue, reason: report.issues.join('\n'));
  });

  test('manually declared VERIFIED without reviews is rejected', () {
    final report = validator.validate(
      bundle(claims: [testClaim(status: ScientificStatus.verified)]),
    );
    expect(report.hasCode(RuleCodes.statusMismatch), isTrue);
    expect(report.isValid, isFalse);
  });

  test('VERIFIED backed by two qualified reviews passes', () {
    final report = validator.validate(
      bundle(
        claims: [testClaim(status: ScientificStatus.verified)],
        reviews: [approve('TEST-REV-TOX'), approve('TEST-REV-TOX-SENIOR')],
      ),
    );
    expect(report.isValid, isTrue, reason: report.issues.join('\n'));
  });

  test('TEST DATA can never enter a production bundle', () {
    final report = validator.validate(
      bundle(
        channel: BundleChannel.production,
        claims: [testClaim(status: ScientificStatus.verified)],
        reviews: [approve('TEST-REV-TOX'), approve('TEST-REV-TOX-SENIOR')],
      ),
    );
    expect(report.hasCode(RuleCodes.testDataInProduction), isTrue);
    expect(report.isValid, isFalse);
  });

  test('NEEDS_REVIEW content cannot enter a production bundle', () {
    final report = validator.validate(
      bundle(
        channel: BundleChannel.production,
        claims: [
          const Claim(
            claimId: 'PILOT-CLAIM-1',
            entityType: EntityType.substance,
            entityId: 'pilot-substance',
            field: 'description',
            value: {'text': 'placeholder'},
            domain: ContentDomain.tox,
            declaredStatus: ScientificStatus.needsReview,
            evidenceLevel: EvidenceLevel.c,
          ),
        ],
        sources: [],
        citations: const [],
      ),
    );
    expect(report.hasCode(RuleCodes.unpublishableStatus), isTrue);
    expect(report.hasCode(RuleCodes.missingCitation), isTrue);
  });

  test('test data must carry TEST- prefix and vice versa', () {
    final report = validator.validate(
      bundle(
        claims: [
          testClaim(id: 'CLAIM-WITHOUT-PREFIX'),
          testClaim(id: 'TEST-NOT-FLAGGED', isTestData: false),
        ],
        citations: const [
          Citation(claimId: 'CLAIM-WITHOUT-PREFIX', sourceId: 'TEST-SRC-OPEN'),
          Citation(claimId: 'TEST-NOT-FLAGGED', sourceId: 'TEST-SRC-OPEN'),
        ],
      ),
    );
    expect(
      report.errors.where((e) => e.code == RuleCodes.testDataIdPrefix).length,
      2,
    );
  });

  test('claim without citation is rejected', () {
    final report = validator.validate(bundle(citations: const []));
    expect(report.hasCode(RuleCodes.missingCitation), isTrue);
  });

  test('structured value from non-commercial source is rejected', () {
    final report = validator.validate(
      bundle(
        claims: [testClaim(structured: true)],
        citations: const [
          Citation(claimId: 'TEST-CLAIM-1', sourceId: 'TEST-SRC-NC'),
        ],
      ),
    );
    expect(report.hasCode(RuleCodes.licenseViolation), isTrue);
  });

  test('concentration claim requires full context', () {
    final report = validator.validate(
      bundle(
        claims: [
          testClaim(
            field: ConcentrationContract.field,
            value: const {'category': 'reported_postmortem', 'value': 1.0},
          ),
        ],
      ),
    );
    expect(report.hasCode(RuleCodes.concentrationContext), isTrue);
  });

  test('concentration with full context passes', () {
    final report = validator.validate(
      bundle(
        claims: [
          testClaim(
            field: ConcentrationContract.field,
            value: testConcentrationValue,
          ),
        ],
      ),
    );
    expect(report.isValid, isTrue, reason: report.issues.join('\n'));
  });

  test('"fatal threshold" category is forbidden', () {
    final report = validator.validate(
      bundle(
        claims: [
          testClaim(
            field: ConcentrationContract.field,
            value: {...testConcentrationValue, 'category': 'fatal_threshold'},
          ),
        ],
      ),
    );
    expect(report.hasCode(RuleCodes.forbiddenCategory), isTrue);
  });

  test('conflict without editorial note blocks production', () {
    final report = validator.validate(
      bundle(
        channel: BundleChannel.production,
        claims: const [],
        citations: const [],
        sources: const [],
        groups: const [
          ClaimGroup(
            groupId: 'G1',
            contextKey: 'k',
            conflictState: ConflictState.conflict,
          ),
        ],
      ),
    );
    expect(report.hasCode(RuleCodes.unresolvedConflict), isTrue);
    expect(report.isValid, isFalse);
  });

  group('IdentifierPolicy', () {
    test('conservative default disables CAS entirely', () {
      final p = IdentifierPolicy.conservativeDefault();
      final cas = p.usageOf(IdentifierScheme.cas);
      expect(cas.store || cas.display || cas.search, isFalse);
      expect(p.usageOf(IdentifierScheme.pubchemCid).display, isTrue);
    });

    test(
      'policy is configuration — CAS can be enabled without code change',
      () {
        final p = IdentifierPolicy.fromJson(const {
          'cas_rn': {'store': true, 'display': true, 'search': false},
        });
        expect(p.usageOf(IdentifierScheme.cas).display, isTrue);
        expect(p.usageOf(IdentifierScheme.cas).search, isFalse);
      },
    );
  });
}
