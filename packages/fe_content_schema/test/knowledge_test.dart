// TEST DATA — barcha yozuvlar sun’iy (TEST-), yurisdiksiyalar ISO 3166
// «user-assigned» kodlari (XA, XB). Hech biri ilmiy yoki huquqiy fakt emas.
import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:test/test.dart';

import 'fixtures/test_data.dart';

const _srcOpen = testSourceOpen; // journal article → peerReviewed
const _srcWeb = Source(
  sourceId: 'TEST-SRC-WEB',
  sourceType: SourceType.website,
  title: 'TEST DATA — random web page',
  tier: SourceTier.tier3,
  evidenceLevel: EvidenceLevel.e,
  licenseMode: SourceLicenseMode.unknown,
  isTestData: true,
);
const _srcStandard = Source(
  sourceId: 'TEST-SRC-STD',
  sourceType: SourceType.standard,
  title: 'TEST DATA — standard placeholder',
  tier: SourceTier.tier1,
  evidenceLevel: EvidenceLevel.a,
  licenseMode: SourceLicenseMode.citeOnly,
  isTestData: true,
);

const _legalReviewer = Reviewer(
  reviewerId: 'TEST-REV-LEGAL',
  displayName: 'TEST legal',
  grants: [ReviewerGrant(domain: ContentDomain.legal, canVerify: true)],
);
const _legalReviewer2 = Reviewer(
  reviewerId: 'TEST-REV-LEGAL-2',
  displayName: 'TEST legal 2',
  grants: [ReviewerGrant(domain: ContentDomain.legal)],
);
const _i18nReviewer = Reviewer(
  reviewerId: 'TEST-REV-I18N',
  displayName: 'TEST translation',
  grants: [ReviewerGrant(domain: ContentDomain.i18n, canVerify: true)],
);

Review _rev(String reviewer, String subject, ContentDomain d) => Review(
  reviewId: 'TEST-R-$reviewer-$subject',
  claimId: subject,
  claimVersion: 1,
  reviewerId: reviewer,
  domain: d,
  decision: ReviewDecision.approve,
  createdAt: DateTime.utc(2026),
);

void main() {
  const validator = ContentValidator();

  ContentBundle bundle({
    List<Claim> claims = const [],
    List<Citation> citations = const [],
    List<Review> reviews = const [],
    List<SolutionRecipe> recipes = const [],
    List<ScreeningTest> screening = const [],
    List<MethodRecord> methods = const [],
    List<EmergingIssue> emerging = const [],
    BundleChannel channel = BundleChannel.test,
  }) => ContentBundle(
    channel: channel,
    sources: const [_srcOpen, _srcWeb, _srcStandard],
    claims: claims,
    citations: citations,
    reviewers: const [
      toxReviewerSenior,
      toxReviewer,
      fmReviewer,
      _legalReviewer,
      _legalReviewer2,
      _i18nReviewer,
    ],
    reviews: reviews,
    recipes: recipes,
    screeningTests: screening,
    methods: methods,
    emergingIssues: emerging,
  );

  group('statuslar va reviewer chegaralari', () {
    test('DRAFT — review’siz ruxsat, production’ga kirmaydi', () {
      final c = testClaim(status: ScientificStatus.draft);
      final cit = [
        const Citation(claimId: 'TEST-CLAIM-1', sourceId: 'TEST-SRC-OPEN'),
      ];
      expect(
        validator.validate(bundle(claims: [c], citations: cit)).isValid,
        isTrue,
      );
      final prod = validator.validate(
        bundle(claims: [c], citations: cit, channel: BundleChannel.production),
      );
      expect(prod.hasCode(RuleCodes.unpublishableStatus), isTrue);
    });

    test('legal va tarjima reviewer’lari ilmiy (tox) claim’ni '
        'tasdiqlay olmaydi', () {
      final c = testClaim(status: ScientificStatus.verified);
      final r = validator.validate(
        bundle(
          claims: [c],
          citations: const [
            Citation(claimId: 'TEST-CLAIM-1', sourceId: 'TEST-SRC-OPEN'),
          ],
          reviews: [
            _rev('TEST-REV-LEGAL', 'TEST-CLAIM-1', ContentDomain.tox),
            _rev('TEST-REV-I18N', 'TEST-CLAIM-1', ContentDomain.tox),
          ],
        ),
      );
      expect(r.hasCode(RuleCodes.statusMismatch), isTrue);
    });

    test('tox reviewer davlat qonuni qoidasini tasdiqlay olmaydi; '
        'legal reviewer’lar — tasdiqlaydi', () {
      StatusResolver resolver(List<Review> reviews) => StatusResolver(
        reviewers: const [
          toxReviewerSenior,
          toxReviewer,
          _legalReviewer,
          _legalReviewer2,
        ],
        reviews: reviews,
        authorships: const [],
      );
      ScientificStatus statusWith(List<Review> rs) => resolver(rs)
          .resolveSubject(
            subjectId: 'TEST-RULE',
            version: 1,
            domain: ContentDomain.legal,
            sources: const [_srcOpen],
          );
      expect(
        statusWith([
          _rev('TEST-REV-TOX-SENIOR', 'TEST-RULE', ContentDomain.legal),
          _rev('TEST-REV-TOX', 'TEST-RULE', ContentDomain.legal),
        ]),
        ScientificStatus.needsReview,
      );
      expect(
        statusWith([
          _rev('TEST-REV-LEGAL', 'TEST-RULE', ContentDomain.legal),
          _rev('TEST-REV-LEGAL-2', 'TEST-RULE', ContentDomain.legal),
        ]),
        ScientificStatus.verified,
      );
    });
  });

  group('manba ierarxiyasi', () {
    test('SourceType → SourceClass', () {
      expect(_srcOpen.sourceClass, SourceClass.peerReviewed);
      expect(_srcWeb.sourceClass, SourceClass.other);
      expect(_srcStandard.sourceClass, SourceClass.standardGuideline);
      expect(
        SourceClass.fromType(SourceType.legislation),
        SourceClass.primaryOfficial,
      );
    });

    test('FE017: faqat blog/AI/veb manbali claim — rad etiladi', () {
      final r = validator.validate(
        bundle(
          claims: [testClaim()],
          citations: const [
            Citation(claimId: 'TEST-CLAIM-1', sourceId: 'TEST-SRC-WEB'),
          ],
        ),
      );
      expect(r.hasCode(RuleCodes.sourceNotEvidence), isTrue);
    });
  });

  group('Reagents & Solutions', () {
    SolutionRecipe recipe({
      List<String> sources = const ['TEST-SRC-OPEN'],
      bool explicitOrder = false,
      List<PreparationStep> steps = const [],
      ScientificStatus status = ScientificStatus.needsReview,
      SourcedNote? stability,
    }) => SolutionRecipe(
      id: 'TEST-RECIPE-1',
      reagentId: 'TEST-REAGENT-1',
      names: const {'en': 'TEST solution'},
      domain: ContentDomain.lab,
      status: status,
      ingredients: const [Ingredient(name: 'TEST-A', amount: 1, unit: 'g')],
      steps: steps,
      orderExplicitInSource: explicitOrder,
      stability: stability,
      sourceIds: sources,
      isTestData: true,
    );

    test('manbali retsept (NEEDS_REVIEW) — xatosiz', () {
      expect(validator.validate(bundle(recipes: [recipe()])).isValid, isTrue);
    });

    test('FE018: manbasiz retsept rad etiladi', () {
      final r = validator.validate(bundle(recipes: [recipe(sources: [])]));
      expect(r.hasCode(RuleCodes.recipeWithoutSource), isTrue);
    });

    test('FE019: manba aytmagan qo‘shish tartibi rad etiladi', () {
      const steps = [
        PreparationStep(text: 'TEST step A', order: 1),
        PreparationStep(text: 'TEST step B', order: 2),
      ];
      expect(
        validator
            .validate(bundle(recipes: [recipe(steps: steps)]))
            .hasCode(RuleCodes.unsourcedStepOrder),
        isTrue,
      );
      expect(
        validator
            .validate(
              bundle(recipes: [recipe(steps: steps, explicitOrder: true)]),
            )
            .isValid,
        isTrue,
      );
    });

    test('FE022: barqarorlik/yaroqlilik manbasiz — rad etiladi', () {
      final r = validator.validate(
        bundle(
          recipes: [
            recipe(
              stability: const SourcedNote(text: 'TEST', sourceId: 'NOPE'),
            ),
          ],
        ),
      );
      expect(r.hasCode(RuleCodes.unsourcedValue), isTrue);
    });

    test('FE020: review’siz VERIFIED retsept — rad etiladi', () {
      final r = validator.validate(
        bundle(recipes: [recipe(status: ScientificStatus.verified)]),
      );
      expect(r.hasCode(RuleCodes.subjectStatusNotBacked), isTrue);
    });
  });

  group('Screening & Express Tests', () {
    ScreeningTest scr({
      List<String> confirm = const ['TEST-METHOD-GCMS'],
      List<SourcedNote> limitations = const [
        SourcedNote(text: 'TEST limitation', sourceId: 'TEST-SRC-OPEN'),
      ],
      SourcedValue? cutoff,
      bool definitive = false,
      String? definitiveSource,
    }) => ScreeningTest(
      id: 'TEST-SCR-1',
      names: const {'en': 'TEST screening'},
      analyte: 'TEST analyte',
      specimen: 'TEST specimen',
      principle: 'TEST principle',
      confirmatoryMethodIds: confirm,
      limitations: limitations,
      cutoff: cutoff,
      supportsDefinitiveIdentification: definitive,
      definitiveIdentificationSourceId: definitiveSource,
      status: ScientificStatus.needsReview,
      sourceIds: const ['TEST-SRC-OPEN'],
      isTestData: true,
    );

    test('to‘g‘ri skrining yozuvi — xatosiz', () {
      expect(validator.validate(bundle(screening: [scr()])).isValid, isTrue);
    });

    test('FE021: tasdiqlovchi metod yoki cheklovsiz — rad etiladi', () {
      expect(
        validator
            .validate(bundle(screening: [scr(confirm: [])]))
            .hasCode(RuleCodes.screeningWithoutConfirmation),
        isTrue,
      );
      expect(
        validator
            .validate(bundle(screening: [scr(limitations: [])]))
            .hasCode(RuleCodes.screeningWithoutConfirmation),
        isTrue,
      );
    });

    test('FE022: manbasiz cutoff — rad etiladi', () {
      final r = validator.validate(
        bundle(
          screening: [
            scr(
              cutoff: const SourcedValue(
                value: 1,
                unit: 'TEST-UNIT',
                sourceId: 'TEST-NO-SOURCE',
              ),
            ),
          ],
        ),
      );
      expect(r.hasCode(RuleCodes.unsourcedValue), isTrue);
    });

    test('FE023: aniq identifikatsiya faqat avtoritet metod bilan', () {
      expect(
        validator
            .validate(
              bundle(
                screening: [
                  scr(definitive: true, definitiveSource: 'TEST-SRC-OPEN'),
                ],
              ),
            )
            .hasCode(RuleCodes.definitiveIdWithoutAuthority),
        isTrue,
      );
      expect(
        validator
            .validate(
              bundle(
                screening: [
                  scr(definitive: true, definitiveSource: 'TEST-SRC-STD'),
                ],
              ),
            )
            .hasCode(RuleCodes.definitiveIdWithoutAuthority),
        isFalse,
      );
    });
  });

  group('Methods & SOP — turlar aralashmaydi', () {
    MethodRecord m(
      MethodKind kind, {
      String? org,
      String? juris,
      TextOrigin origin = TextOrigin.originalSummary,
      List<String> sources = const ['TEST-SRC-OPEN'],
    }) => MethodRecord(
      id: 'TEST-M-${kind.name}',
      kind: kind,
      titles: const {'en': 'TEST method'},
      organization: org,
      jurisdictionId: juris,
      textOrigin: origin,
      sections: const {MethodSection.principle: 'TEST principle summary'},
      status: ScientificStatus.needsReview,
      sourceIds: sources,
      isTestData: true,
    );

    bool mixing(MethodRecord r) => validator
        .validate(bundle(methods: [r]))
        .hasCode(RuleCodes.methodKindMixing);

    test('ilmiy metod yurisdiksiyaga bog‘lanmaydi', () {
      expect(mixing(m(MethodKind.scientificMethod)), isFalse);
      expect(mixing(m(MethodKind.scientificMethod, juris: 'XA')), isTrue);
    });

    test('xalqaro standart — tashkilot majburiy, davlatga bog‘lanmaydi', () {
      expect(
        mixing(m(MethodKind.internationalStandard, org: 'TEST-ORG')),
        isFalse,
      );
      expect(mixing(m(MethodKind.internationalStandard)), isTrue);
      expect(
        mixing(
          m(MethodKind.internationalStandard, org: 'TEST-ORG', juris: 'XA'),
        ),
        isTrue,
      );
    });

    test('milliy metod — davlat va tashkilot majburiy', () {
      expect(
        mixing(m(MethodKind.nationalMethod, org: 'TEST-ORG', juris: 'XA')),
        isFalse,
      );
      expect(mixing(m(MethodKind.nationalMethod, org: 'TEST-ORG')), isTrue);
      expect(
        mixing(m(MethodKind.nationalMethod, org: 'TEST-ORG', juris: 'INT')),
        isTrue,
      );
    });

    test('institut SOP — tashkilot majburiy', () {
      expect(mixing(m(MethodKind.institutionalSop, org: 'TEST-LAB')), isFalse);
      expect(mixing(m(MethodKind.institutionalSop)), isTrue);
    });

    test('FE025: litsenziya ruxsat bermagan manbadan iqtibos', () {
      final r = validator.validate(
        bundle(
          methods: [
            m(
              MethodKind.internationalStandard,
              org: 'TEST-ORG',
              origin: TextOrigin.openLicenseExcerpt,
              sources: const ['TEST-SRC-STD'],
            ),
          ],
        ),
      );
      expect(r.hasCode(RuleCodes.textLicense), isTrue);
    });
  });

  test('FE026: dolzarb muammo manba va sanasiz — rad etiladi', () {
    final r = validator.validate(
      bundle(
        emerging: [
          const EmergingIssue(
            id: 'TEST-EMG-1',
            category: EmergingCategory.newPsychoactiveSubstances,
            titles: {'en': 'TEST issue'},
            sourceIds: [],
            evidenceType: EvidenceType.peerReviewed,
            status: ScientificStatus.needsReview,
            isTestData: true,
          ),
        ],
      ),
    );
    expect(r.hasCode(RuleCodes.emergingWithoutProvenance), isTrue);
  });

  group('yurisdiksiya: hudud ustunligi, qamrov, solishtirish', () {
    const xa = Jurisdiction(
      id: 'XA',
      level: JurisdictionLevel.country,
      names: {'en': 'TEST A'},
      parentId: 'INT',
    );
    const int_ = Jurisdiction(
      id: 'INT',
      level: JurisdictionLevel.international,
      names: {'en': 'International'},
    );
    Jurisdiction sub(String id) => Jurisdiction(
      id: id,
      level: JurisdictionLevel.subdivision,
      names: {'en': id},
      parentId: 'XA',
    );
    JurisdictionalInstrument inst(String id, String j) =>
        JurisdictionalInstrument(
          id: id,
          jurisdictionId: j,
          type: InstrumentType.law,
          titles: const {'en': 'TEST law'},
          officialSourceId: 'TEST-SRC-OPEN',
          effectiveFrom: DateTime.utc(2020),
          version: 'TEST',
          status: ScientificStatus.needsReview,
          isTestData: true,
        );
    JurisdictionalRule rule(
      String id,
      String instId,
      int v, {
      Set<String>? applies,
    }) => JurisdictionalRule(
      id: id,
      instrumentId: instId,
      ruleType: JurisdictionalRuleType.legalThreshold,
      subjectType: 'topic',
      subjectId: 'TEST-TOPIC',
      value: {'TEST-value': v},
      effectiveFrom: DateTime.utc(2020),
      status: ScientificStatus.needsReview,
      topicKey: 'TEST.threshold',
      appliesTo: applies,
      isTestData: true,
    );

    final resolver = JurisdictionResolver(
      jurisdictions: [int_, xa, sub('XA-01'), sub('XA-02'), sub('XA-03')],
      instruments: [inst('TEST-I-XA', 'XA'), inst('TEST-I-XA02', 'XA-02')],
      rules: [
        rule('TEST-R-XA', 'TEST-I-XA', 80, applies: {'XA-01', 'XA-02'}),
        rule('TEST-R-XA02', 'TEST-I-XA02', 50),
      ],
    );
    final at = DateTime.utc(2026);
    List<String> ids(String j) => resolver
        .view(
          jurisdictionId: j,
          subjectType: 'topic',
          subjectId: 'TEST-TOPIC',
          at: at,
          includeUnreviewed: true,
        )!
        .rules
        .map((e) => e.$1.id)
        .toList();

    test('hudud qoidasi davlat qoidasini almashtiradi (override)', () {
      expect(ids('XA-02'), ['TEST-R-XA02']);
      final v = resolver.view(
        jurisdictionId: 'XA-02',
        subjectType: 'topic',
        subjectId: 'TEST-TOPIC',
        at: at,
        includeUnreviewed: true,
      )!;
      expect(v.overridden.single.$1.id, 'TEST-R-XA');
    });

    test('hududiy qamrov: qamrovdan tashqari hudud meros olmaydi', () {
      expect(ids('XA-01'), ['TEST-R-XA']);
      expect(ids('XA-03'), isEmpty);
      // Davlat darajasida — qoida qamrov izohi bilan ko‘rinadi.
      expect(ids('XA'), ['TEST-R-XA']);
    });

    test('tekshirilmagan qoidalar faqat aniq ruxsat bilan', () {
      expect(
        resolver
            .view(
              jurisdictionId: 'XA-01',
              subjectType: 'topic',
              subjectId: 'TEST-TOPIC',
              at: at,
            )!
            .rules,
        isEmpty,
      );
    });

    test('solishtirish: ma’lumot yo‘q — noData (xulosa yo‘q)', () {
      final cells = resolver.compareCells(
        jurisdictionIds: const ['XA-01', 'XA-02', 'XA-03', 'UNKNOWN'],
        subjectType: 'topic',
        subjectId: 'TEST-TOPIC',
        at: at,
        includeUnreviewed: true,
      );
      expect(cells.map((c) => c.jurisdiction.id), ['XA-01', 'XA-02', 'XA-03']);
      expect(cells.map((c) => c.hasData), [true, true, false]);
    });

    test('qatlam turi aniq: xalqaro nazorat / milliy / hududiy / metod', () {
      expect(
        legalLayerOf(inst('a', 'XA'), JurisdictionLevel.country),
        LegalLayerKind.nationalLaw,
      );
      expect(
        legalLayerOf(inst('a', 'XA-01'), JurisdictionLevel.subdivision),
        LegalLayerKind.regionalLaw,
      );
      expect(
        legalLayerOf(inst('a', 'INT'), JurisdictionLevel.international),
        LegalLayerKind.internationalControl,
      );
    });

    test('bekor qilingan hujjat amalda emas', () {
      final repealed = JurisdictionalInstrument(
        id: 'TEST-OLD',
        jurisdictionId: 'XA',
        type: InstrumentType.law,
        titles: const {'en': 'TEST'},
        officialSourceId: 'TEST-SRC-OPEN',
        effectiveFrom: DateTime.utc(2000),
        version: 'TEST',
        status: ScientificStatus.reviewed,
        legalStatus: InstrumentLegalStatus.repealed,
      );
      expect(repealed.isInForceAt(at), isFalse);
    });
  });
}
