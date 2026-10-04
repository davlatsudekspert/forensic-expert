import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:test/test.dart';

const _src = Source(
  sourceId: 'S1',
  sourceType: SourceType.journalArticle,
  title: 't',
  tier: SourceTier.tier2,
  evidenceLevel: EvidenceLevel.b,
  licenseMode: SourceLicenseMode.openReuse,
);

Claim _claim(
  String id, {
  String field = 'definition',
  Map<String, Object?> value = const {'excerpt': 'x'},
  ScientificStatus status = ScientificStatus.needsReview,
  String entityId = 'e1',
}) => Claim(
  claimId: id,
  entityType: EntityType.substance,
  entityId: entityId,
  field: field,
  value: value,
  domain: ContentDomain.tox,
  declaredStatus: status,
  evidenceLevel: EvidenceLevel.b,
);

Map<String, Object?> _ctx({List<String> specimen = const ['blood']}) => {
  for (final k in StrictConcentrationContext.requiredKeys)
    k: StrictConcentrationContext.notStated,
  'specimen': specimen,
  'reporting': 'primary',
  'limitations': <String>[],
};

ContentBundle _bundle({
  List<Claim> claims = const [],
  List<SourceProvenance> prov = const [],
  List<EvidenceConflict> conflicts = const [],
  List<ReviewAction> actions = const [],
  List<Reviewer> reviewers = const [],
  List<MetaboliteRelation> metabolites = const [],
  List<StandardRecord> standards = const [],
  List<TermTranslation> terms = const [],
  List<EntityLink> links = const [],
}) => ContentBundle(
  channel: BundleChannel.development,
  sources: const [_src],
  claims: claims,
  citations: [
    for (final c in claims) Citation(claimId: c.claimId, sourceId: 'S1'),
  ],
  sourceProvenance: prov,
  conflicts: conflicts,
  reviewActions: actions,
  reviewers: reviewers,
  metaboliteRelations: metabolites,
  standards: standards,
  termTranslations: terms,
  links: links,
  specimens: const [
    SpecimenRecord(id: 'blood', names: {'en': 'Blood'}, category: 'fluid'),
  ],
  knownEntityIds: const {'e1', 'm1'},
);

Set<String> _codes(ContentBundle b) => {
  for (final i in const ContentValidator().validate(b).issues) i.code,
};

ReviewAction _action({
  ReviewerRole role = ReviewerRole.forensicToxicology,
  ReviewActionType action = ReviewActionType.approve,
  String reviewer = 'R1',
  int version = 1,
  String note = '',
  ContentDomain domain = ContentDomain.tox,
}) => ReviewAction(
  id: 'A-$reviewer-${action.code}',
  subjectId: 'C1',
  subjectVersion: version,
  contentVersion: '2026.10.5',
  domain: domain,
  reviewerId: reviewer,
  role: role,
  action: action,
  at: DateTime.utc(2026, 10, 4),
  note: note,
);

const _reviewers = {
  'R1': Reviewer(
    reviewerId: 'R1',
    displayName: 'R1',
    grants: [ReviewerGrant(domain: ContentDomain.tox, canVerify: true)],
  ),
  'R2': Reviewer(
    reviewerId: 'R2',
    displayName: 'R2',
    grants: [ReviewerGrant(domain: ContentDomain.tox)],
  ),
};

void main() {
  group('ClaimLifecycleResolver', () {
    test('retraksiya qilingan manba — RETRACTED, sababi bilan', () {
      final v = ClaimLifecycleResolver.resolve(
        status: ScientificStatus.verified,
        sources: const [
          SourceProvenance(
            sourceId: 'S1',
            lifecycle: SourceLifecycle.retracted,
          ),
        ],
      );
      expect(v.lifecycle, ClaimLifecycle.retracted);
      expect(v.sourceIds, ['S1']);
    });

    test('barcha manbalar almashtirilgan — SUPERSEDED; biri joriy — yo‘q', () {
      const sup = SourceProvenance(
        sourceId: 'S1',
        lifecycle: SourceLifecycle.superseded,
        supersededBy: 'S2',
      );
      expect(
        ClaimLifecycleResolver.resolve(
          status: ScientificStatus.reviewed,
          sources: const [sup],
        ).lifecycle,
        ClaimLifecycle.superseded,
      );
      expect(
        ClaimLifecycleResolver.resolve(
          status: ScientificStatus.reviewed,
          sources: const [
            sup,
            SourceProvenance(sourceId: 'S3'),
          ],
        ).lifecycle,
        ClaimLifecycle.current,
      );
    });

    test('review’siz claim hech qachon CURRENT emas', () {
      expect(
        ClaimLifecycleResolver.resolve(
          status: ScientificStatus.needsReview,
          sources: const [SourceProvenance(sourceId: 'S1')],
        ).lifecycle,
        ClaimLifecycle.needsReview,
      );
    });

    test('REJECTED ustun; FLAG_OUTDATED → OUTDATED', () {
      expect(
        ClaimLifecycleResolver.resolve(
          status: ScientificStatus.rejected,
          sources: const [
            SourceProvenance(
              sourceId: 'S1',
              lifecycle: SourceLifecycle.retracted,
            ),
          ],
        ).lifecycle,
        ClaimLifecycle.rejected,
      );
      expect(
        ClaimLifecycleResolver.resolve(
          status: ScientificStatus.reviewed,
          sources: const [],
          flaggedOutdated: true,
        ).lifecycle,
        ClaimLifecycle.outdated,
      );
    });

    test('bog‘liq claim’lar aniqlanadi', () {
      expect(
        ClaimLifecycleResolver.dependentClaims('S1', const [
          (claimId: 'C2', sourceId: 'S1'),
          (claimId: 'C1', sourceId: 'S1'),
          (claimId: 'C3', sourceId: 'S9'),
        ]),
        ['C1', 'C2'],
      );
    });
  });

  group('Reviewer rollari va workflow', () {
    test('ruxsat matritsasi: ixtisoslik chegarasi', () {
      expect(
        ReviewPermissions.allows(
          ReviewerRole.forensicToxicology,
          ContentDomain.tox,
          ReviewActionType.approve,
        ),
        isTrue,
      );
      expect(
        ReviewPermissions.allows(
          ReviewerRole.translation,
          ContentDomain.tox,
          ReviewActionType.approve,
        ),
        isFalse,
      );
      expect(
        ReviewPermissions.allows(
          ReviewerRole.legalJurisdiction,
          ContentDomain.fm,
          ReviewActionType.approve,
        ),
        isFalse,
      );
      // Muharrir belgilaydi, lekin tasdiqlay olmaydi.
      expect(
        ReviewPermissions.allows(
          ReviewerRole.scientificEditor,
          ContentDomain.tox,
          ReviewActionType.flagConflict,
        ),
        isTrue,
      );
      expect(
        ReviewPermissions.allows(
          ReviewerRole.scientificEditor,
          ContentDomain.tox,
          ReviewActionType.approve,
        ),
        isFalse,
      );
    });

    ActionCheck check(ReviewAction a, {String? author}) => ReviewWorkflow.check(
      action: a,
      currentVersion: 1,
      subjectDomain: ContentDomain.tox,
      reviewers: _reviewers,
      authorId: author,
    );

    test(
      'soxta reviewer, eski versiya, izohsiz rad, muallif — rad etiladi',
      () {
        expect(
          check(_action(reviewer: 'GHOST')).reason,
          'unknown_or_inactive_reviewer',
        );
        expect(check(_action(version: 0)).reason, 'stale_version');
        expect(
          check(_action(action: ReviewActionType.reject)).reason,
          'note_required',
        );
        expect(
          check(_action(), author: 'R1').reason,
          'author_cannot_review_own_claim',
        );
        expect(check(_action()).ok, isTrue);
      },
    );

    test('holatlar: kutilmoqda → qisman → tasdiqlangan; rad ustun', () {
      expect(
        ReviewWorkflow.state(const []),
        ReviewWorkflowState.awaitingReview,
      );
      final a1 = _action();
      final a2 = _action(reviewer: 'R2');
      expect(ReviewWorkflow.state([a1]), ReviewWorkflowState.partiallyApproved);
      expect(ReviewWorkflow.state([a1, a2]), ReviewWorkflowState.approved);
      expect(
        ReviewWorkflow.state([
          a1,
          _action(reviewer: 'R2', action: ReviewActionType.reject, note: 'n'),
        ]),
        ReviewWorkflowState.rejected,
      );
    });

    test(
      'status faqat StatusResolver orqali: 2 ta haqiqiy approve → VERIFIED',
      () {
        final reviews = ReviewWorkflow.toReviews([
          _action(),
          _action(reviewer: 'R2'),
          _action(action: ReviewActionType.flagConflict, note: 'n'),
        ]);
        expect(reviews, hasLength(2));
        final status = StatusResolver(
          reviewers: _reviewers.values,
          reviews: reviews,
          authorships: const [],
        ).resolve(_claim('C1'), const [_src]);
        expect(status, ScientificStatus.verified);
      },
    );
  });

  group('Validator FE033–FE041', () {
    test('FE033: qat’iy kontekstsiz konsentratsiya rad etiladi', () {
      final bad = _claim(
        'C1',
        field: 'reported_concentration',
        value: const {
          'excerpt': 'x',
          'specimen': ['blood'],
          'context': 'c',
          'not_a_threshold': true,
        },
      );
      expect(
        _codes(_bundle(claims: [bad])),
        contains(RuleCodes.strictConcentrationContext),
      );
      final good = _claim(
        'C1',
        field: 'reported_concentration',
        value: {
          'excerpt': 'x',
          'specimen': ['blood'],
          'context': 'c',
          'not_a_threshold': true,
          'context_strict': _ctx(),
        },
      );
      expect(
        _codes(_bundle(claims: [good])),
        isNot(contains(RuleCodes.strictConcentrationContext)),
      );
      final unknownSpecimen = _claim(
        'C1',
        field: 'reported_concentration',
        value: {
          'specimen': ['blood'],
          'context': 'c',
          'not_a_threshold': true,
          'context_strict': _ctx(specimen: ['saliva-x']),
        },
      );
      expect(
        _codes(_bundle(claims: [unknownSpecimen])),
        contains(RuleCodes.strictConcentrationContext),
      );
    });

    test(
      'FE034: retraksiya qilingan manbali claim joriy deb e’lon qilinmaydi',
      () {
        final b = _bundle(
          claims: [_claim('C1', status: ScientificStatus.reviewed)],
          prov: const [
            SourceProvenance(
              sourceId: 'S1',
              lifecycle: SourceLifecycle.retracted,
              lifecycleBasis: 'PubMed',
            ),
          ],
        );
        expect(_codes(b), contains(RuleCodes.sourceLifecycle));
        final noBasis = _bundle(
          claims: [_claim('C1')],
          prov: const [
            SourceProvenance(
              sourceId: 'S1',
              lifecycle: SourceLifecycle.retracted,
            ),
          ],
        );
        expect(_codes(noBasis), contains(RuleCodes.sourceLifecycle));
      },
    );

    test('FE035: ziddiyat — ma’lum claim’lar, minimal soni, reviewer’siz hal '
        'qilinmaydi', () {
      EvidenceConflict k(List<String> ids, {EvidenceConflictState? state}) =>
          EvidenceConflict(
            id: 'K1',
            entityId: 'e1',
            question: 'q',
            kind: ConflictKind.contextDependent,
            claimIds: ids,
            note: 'n',
            state: state ?? EvidenceConflictState.open,
          );
      final claims = [_claim('C1'), _claim('C2')];
      expect(
        _codes(
          _bundle(
            claims: claims,
            conflicts: [
              k(['C1', 'C2']),
            ],
          ),
        ),
        isNot(contains(RuleCodes.conflictInvalid)),
      );
      expect(
        _codes(
          _bundle(
            claims: claims,
            conflicts: [
              k(['C1']),
            ],
          ),
        ),
        contains(RuleCodes.conflictInvalid),
      );
      expect(
        _codes(
          _bundle(
            claims: claims,
            conflicts: [
              k(['C1', 'C2'], state: EvidenceConflictState.resolvedByReviewer),
            ],
          ),
        ),
        contains(RuleCodes.conflictInvalid),
      );
    });

    test('FE036: metabolit roli iqtibosda aytilmagan bo‘lsa — xato', () {
      final c = _claim(
        'C1',
        value: const {'excerpt': 'Drug X is metabolised to M1.'},
      );
      MetaboliteRelation rel(MetaboliteRelationKind kind) => MetaboliteRelation(
        id: 'MR1',
        parentId: 'e1',
        metaboliteId: 'm1',
        metaboliteName: 'M1',
        kind: kind,
        basisClaimId: 'C1',
      );
      expect(
        _codes(
          _bundle(
            claims: [c],
            metabolites: [rel(MetaboliteRelationKind.metabolite)],
          ),
        ),
        isNot(contains(RuleCodes.metaboliteRelationInvalid)),
      );
      expect(
        _codes(
          _bundle(
            claims: [c],
            metabolites: [rel(MetaboliteRelationKind.activeMetabolite)],
          ),
        ),
        contains(RuleCodes.metaboliteRelationInvalid),
      );
    });

    test('FE037: PHASE 7 qirrasi kuzatiladigan asos talab qiladi', () {
      final claims = [_claim('C1')];
      expect(
        _codes(
          _bundle(
            claims: claims,
            links: const [
              EntityLink(
                fromId: 'e1',
                toId: 'blood',
                relation: LinkRelation.measuredIn,
                basis: 'C1',
              ),
            ],
          ),
        ),
        isNot(contains(RuleCodes.untraceableEdge)),
      );
      expect(
        _codes(
          _bundle(
            claims: claims,
            links: const [
              EntityLink(
                fromId: 'e1',
                toId: 'blood',
                relation: LinkRelation.measuredIn,
                basis: 'editorial:guess',
              ),
            ],
          ),
        ),
        contains(RuleCodes.untraceableEdge),
      );
    });

    test(
      'FE038: litsenziyali standart arxivlanmaydi; superseded — voris bilan',
      () {
        StandardRecord s({
          String id = 'STD1',
          StandardStatus status = StandardStatus.current,
          ReuseStatus reuse = ReuseStatus.citeOnly,
          String? sha,
          String? by,
        }) => StandardRecord(
          id: id,
          designation: id,
          title: 't',
          publisher: 'p',
          documentKind: DocumentKind.standard,
          status: status,
          reuse: reuse,
          verifiedFrom: 'https://example.org/registry',
          verifiedAt: DateTime.utc(2026, 10, 4),
          sha256: sha,
          supersededBy: by,
        );
        expect(
          _codes(
            _bundle(
              standards: [s(reuse: ReuseStatus.licenseRequired, sha: 'x')],
            ),
          ),
          contains(RuleCodes.standardInvalid),
        );
        expect(
          _codes(_bundle(standards: [s(status: StandardStatus.superseded)])),
          contains(RuleCodes.standardInvalid),
        );
        expect(
          _codes(
            _bundle(
              standards: [
                s(id: 'OLD', status: StandardStatus.superseded, by: 'NEW'),
                s(id: 'NEW'),
              ],
            ),
          ),
          isNot(contains(RuleCodes.standardInvalid)),
        );
      },
    );

    test(
      'FE039: tarjimon ilmiy claim’ni tasdiqlay olmaydi; soxta reviewer yo‘q',
      () {
        final claims = [_claim('C1')];
        expect(
          _codes(
            _bundle(
              claims: claims,
              reviewers: _reviewers.values.toList(),
              actions: [_action(role: ReviewerRole.translation)],
            ),
          ),
          contains(RuleCodes.reviewActionInvalid),
        );
        expect(
          _codes(
            _bundle(
              claims: claims,
              actions: [_action(reviewer: 'GHOST')],
            ),
          ),
          contains(RuleCodes.reviewActionInvalid),
        );
      },
    );

    test('FE040: DOI/formula/qisqartma tarjima qilinmaydi', () {
      TermTranslation t(ScientificTermKind kind, String ru) => TermTranslation(
        id: 'T1',
        kind: kind,
        original: 'C17H19NO3',
        originalLang: 'en',
        canonical: 'C17H19NO3',
        localized: {'ru': ru},
        status: const {'ru': TranslationStatus.machineDraft},
      );
      expect(
        _codes(_bundle(terms: [t(ScientificTermKind.formula, 'С17Н19NО3')])),
        contains(RuleCodes.termTranslationInvalid),
      );
      expect(
        _codes(_bundle(terms: [t(ScientificTermKind.formula, 'C17H19NO3')])),
        isNot(contains(RuleCodes.termTranslationInvalid)),
      );
    });

    test('SourceHierarchy va ReuseStatus xaritasi', () {
      expect(
        SourceHierarchy.of(SourceClass.primaryOfficial),
        SourceHierarchy.a,
      );
      expect(SourceHierarchy.of(SourceClass.peerReviewed), SourceHierarchy.b);
      expect(SourceHierarchy.of(SourceClass.secondary), SourceHierarchy.c);
      expect(SourceHierarchy.of(SourceClass.other), isNull);
      expect(
        ReuseStatus.of(SourceLicenseMode.licenseRequired).code,
        'LICENSE_REQUIRED',
      );
      expect(ReuseStatus.licenseRequired.allowsExcerpt, isFalse);
    });
  });
}
