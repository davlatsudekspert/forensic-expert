import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:test/test.dart';

// TEST DATA — sintetik metadata; real nashrlar emas.
void main() {
  ResearchRecord r(
    String id, {
    ResearchKind kind = ResearchKind.journalArticle,
    EvidenceLevel level = EvidenceLevel.b,
    String? doi = '10.0000/test.1',
    String? pmid,
    String title = 'TEST title',
    List<String> authors = const ['Test A'],
    ScientificStatus status = ScientificStatus.needsReview,
  }) => ResearchRecord(
    id: id,
    kind: kind,
    title: title,
    authors: authors,
    doi: doi,
    pmid: pmid,
    evidenceLevel: level,
    status: status,
  );

  ValidationReport v(ContentBundle b) => const ContentValidator().validate(b);
  ContentBundle b({
    List<ResearchRecord> research = const [],
    List<EntityLink> links = const [],
    List<ScientificImage> images = const [],
    List<Claim> claims = const [],
    Set<String> known = const {'TEST-SUB'},
  }) => ContentBundle(
    channel: BundleChannel.development,
    research: research,
    links: links,
    images: images,
    claims: claims,
    knownEntityIds: known,
  );

  group('ResearchRecord', () {
    test(
      'dissertatsiya / tezis peer-reviewed darajada bo‘lolmaydi (FE028)',
      () {
        expect(
          v(
            b(
              research: [
                r(
                  'R1',
                  kind: ResearchKind.dissertation,
                  level: EvidenceLevel.b,
                ),
              ],
            ),
          ).hasCode(RuleCodes.researchRecordInvalid),
          isTrue,
        );
        expect(
          v(
            b(
              research: [
                r(
                  'R1',
                  kind: ResearchKind.dissertation,
                  level: EvidenceLevel.e,
                ),
              ],
            ),
          ).isValid,
          isTrue,
        );
        expect(
          ResearchKind.conferenceAbstract.isPeerReviewedFullArticle,
          isFalse,
        );
        expect(ResearchKind.thesis.maxEvidence, EvidenceLevel.e);
      },
    );

    test('identifikatorsiz yozuv — xato', () {
      expect(
        v(b(research: [r('R1', doi: null)]))
            .hasCode(RuleCodes.researchRecordInvalid),
        isTrue,
      );
    });

    test('DOI (registrsiz) bo‘yicha dublikat — FE029', () {
      expect(
        v(
          b(
            research: [
              r('R1', doi: '10.1/ABC'),
              r('R2', doi: '10.1/abc'),
            ],
          ),
        ).hasCode(RuleCodes.researchDuplicate),
        isTrue,
      );
    });

    test('identifikatorsiz bo‘lsa sarlavha + 1-muallif bo‘yicha dublikat', () {
      final a = r(
        'R1',
        doi: null,
        title: 'TEST: A Study!',
        authors: ['Smith J'],
      );
      final c = r(
        'R2',
        doi: null,
        title: 'test a study',
        authors: ['Smith, J.'],
      );
      expect(a.dedupKey, c.dedupKey);
      expect(r('R3', doi: null, pmid: '1').dedupKey, 'pmid:1');
    });

    test('reviewer’siz REVIEWED research — xato', () {
      expect(
        v(b(research: [r('R1', status: ScientificStatus.reviewed)])).isValid,
        isFalse,
      );
    });
  });

  test('bog‘lanish noma’lum yozuvga — FE030', () {
    const l = EntityLink(
      fromId: 'TEST-SUB',
      toId: 'MISSING',
      relation: LinkRelation.analysedBy,
      basis: 'C-1',
    );
    expect(v(b(links: [l])).hasCode(RuleCodes.brokenLink), isTrue);
  });

  group('rasm litsenziyasi (FE031)', () {
    ScientificImage im({
      String license = 'CC BY',
      bool graphic = false,
      bool original = false,
      bool real = true,
      String? url = 'https://example.org/test',
      String alt = 'TEST alt',
    }) => ScientificImage(
      id: 'IMG-1',
      kind: ImageKind.micrograph,
      entityId: 'TEST-SUB',
      title: const {'en': 'TEST'},
      alt: {'en': alt},
      license: license,
      attribution: 'TEST attribution',
      isOriginalDiagram: original,
      representsRealData: real,
      sourceUrl: url,
      graphic: graphic,
    );
    test('to‘g‘ri CC BY rasm — o‘tadi', () {
      expect(v(b(images: [im()])).isValid, isTrue);
    });
    for (final (name, bad) in [
      ('noaniq litsenziya', im(license: 'unknown')),
      ('graphic rasm', im(graphic: true)),
      ('alt-text yo‘q', im(alt: '')),
      ('tashqi rasm manba havolasisiz', im(url: null)),
      ('sxema real natija sifatida', im(original: true)),
    ]) {
      test('$name — xato', () {
        expect(v(b(images: [bad])).hasCode(RuleCodes.imageLicense), isTrue);
      });
    }
  });

  test('xabar qilingan konsentratsiya kontekstsiz — FE032', () {
    Claim c(Map<String, Object?> value) => Claim(
      claimId: 'C-1',
      entityType: EntityType.substance,
      entityId: 'TEST-SUB',
      field: 'reported_concentration',
      value: value,
      domain: ContentDomain.tox,
      declaredStatus: ScientificStatus.needsReview,
      evidenceLevel: EvidenceLevel.b,
    );
    expect(
      v(
        b(
          claims: [
            c({'excerpt': 'x'}),
          ],
        ),
      ).hasCode(RuleCodes.reportedConcentrationContext),
      isTrue,
    );
    expect(
      v(
        b(
          claims: [
            c({
              'excerpt': 'x',
              'specimen': ['blood'],
              'context': 'postmortem',
              'not_a_threshold': true,
            }),
          ],
        ),
      ).hasCode(RuleCodes.reportedConcentrationContext),
      isFalse,
    );
  });
}
