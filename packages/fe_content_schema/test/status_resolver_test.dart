import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:test/test.dart';

import 'fixtures/test_data.dart';

void main() {
  StatusResolver resolver(
    List<Review> reviews, {
    List<Authorship> authorships = const [],
  }) => StatusResolver(
    reviewers: const [toxReviewerSenior, toxReviewer, fmReviewer],
    reviews: reviews,
    authorships: authorships,
  );

  group('StatusResolver', () {
    test('no reviews → NEEDS_REVIEW', () {
      expect(
        resolver([]).resolve(testClaim(), [testSourceOpen]),
        ScientificStatus.needsReview,
      );
    });

    test('one qualified approval → REVIEWED', () {
      expect(
        resolver([approve('TEST-REV-TOX')])
            .resolve(testClaim(), [testSourceOpen]),
        ScientificStatus.reviewed,
      );
    });

    test('two approvals incl. senior + verified identifiers → VERIFIED', () {
      expect(
        resolver([approve('TEST-REV-TOX'), approve('TEST-REV-TOX-SENIOR')])
            .resolve(testClaim(), [testSourceOpen]),
        ScientificStatus.verified,
      );
    });

    test('two approvals without senior → only REVIEWED', () {
      const second = Reviewer(
        reviewerId: 'TEST-REV-TOX-2',
        displayName: 'TEST',
        grants: [ReviewerGrant(domain: ContentDomain.tox)],
      );
      final r = StatusResolver(
        reviewers: const [toxReviewer, second],
        reviews: [approve('TEST-REV-TOX'), approve('TEST-REV-TOX-2')],
        authorships: const [],
      );
      expect(
        r.resolve(testClaim(), [testSourceOpen]),
        ScientificStatus.reviewed,
      );
    });

    test('unverified DOI blocks VERIFIED', () {
      expect(
        resolver([approve('TEST-REV-TOX'), approve('TEST-REV-TOX-SENIOR')])
            .resolve(testClaim(), [testSourceUnverifiedDoi]),
        ScientificStatus.reviewed,
      );
    });

    test('reviewer from another domain does not count', () {
      expect(
        resolver([approve('TEST-REV-FM', domain: ContentDomain.tox)])
            .resolve(testClaim(), [testSourceOpen]),
        ScientificStatus.needsReview,
      );
    });

    test('author cannot review own claim (four-eyes)', () {
      expect(
        resolver(
          [approve('TEST-REV-TOX')],
          authorships: const [
            Authorship(claimId: 'TEST-CLAIM-1', authorId: 'TEST-REV-TOX'),
          ],
        ).resolve(testClaim(), [testSourceOpen]),
        ScientificStatus.needsReview,
      );
    });

    test('reviews of an older claim version do not count', () {
      expect(
        resolver([approve('TEST-REV-TOX'), approve('TEST-REV-TOX-SENIOR')])
            .resolve(testClaim(version: 2), [testSourceOpen]),
        ScientificStatus.needsReview,
      );
    });

    test('a reject → REJECTED', () {
      final reject = Review(
        reviewId: 'TEST-R',
        claimId: 'TEST-CLAIM-1',
        claimVersion: 1,
        reviewerId: 'TEST-REV-TOX',
        domain: ContentDomain.tox,
        decision: ReviewDecision.reject,
        createdAt: DateTime.utc(2026),
      );
      expect(
        resolver([reject, approve('TEST-REV-TOX-SENIOR')])
            .resolve(testClaim(), [testSourceOpen]),
        ScientificStatus.rejected,
      );
    });
  });
}
