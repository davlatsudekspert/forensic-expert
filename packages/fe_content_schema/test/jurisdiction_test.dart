// TEST DATA — yurisdiksiyalar ISO 3166 «user-assigned» kodlari (XA, XB)
// bilan; hech qaysi real davlat qonuni yoki qoidasi emas.
import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:test/test.dart';

import 'fixtures/test_data.dart';

const _int = Jurisdiction(
  id: 'INT',
  level: JurisdictionLevel.international,
  names: {'en': 'International'},
);
const _xa = Jurisdiction(
  id: 'XA',
  level: JurisdictionLevel.country,
  names: {'en': 'TEST country A', 'ru': 'TEST страна A'},
  parentId: 'INT',
);
const _xa1 = Jurisdiction(
  id: 'XA-01',
  level: JurisdictionLevel.subdivision,
  names: {'en': 'TEST region A-01'},
  parentId: 'XA',
);
const _xb = Jurisdiction(
  id: 'XB',
  level: JurisdictionLevel.country,
  names: {'en': 'TEST country B'},
  parentId: 'INT',
);

JurisdictionalInstrument _inst({
  String id = 'TEST-INST-XA',
  String jurisdictionId = 'XA',
  String sourceId = 'TEST-SRC-OPEN',
  DateTime? from,
  DateTime? to,
  ScientificStatus status = ScientificStatus.reviewed,
  String version = 'TEST-v1',
}) => JurisdictionalInstrument(
  id: id,
  jurisdictionId: jurisdictionId,
  type: InstrumentType.controlledSubstanceSchedule,
  titles: const {'en': 'TEST instrument'},
  officialSourceId: sourceId,
  effectiveFrom: from ?? DateTime.utc(2020),
  effectiveTo: to,
  version: version,
  status: status,
  isTestData: true,
);

JurisdictionalRule _rule({
  String id = 'TEST-RULE-XA',
  String instrumentId = 'TEST-INST-XA',
  DateTime? from,
  DateTime? to,
  ScientificStatus status = ScientificStatus.reviewed,
  String subjectId = 'TEST-SUBSTANCE-ALPHA',
}) => JurisdictionalRule(
  id: id,
  instrumentId: instrumentId,
  ruleType: JurisdictionalRuleType.controlStatus,
  subjectType: 'substance',
  subjectId: subjectId,
  value: const {'schedule': 'TEST-SCHEDULE'},
  effectiveFrom: from ?? DateTime.utc(2020),
  effectiveTo: to,
  status: status,
  isTestData: true,
);

void main() {
  final now = DateTime.utc(2026, 6);

  group('JurisdictionResolver', () {
    test('chainOf walks subdivision → country → international', () {
      final r = JurisdictionResolver(
        jurisdictions: const [_int, _xa, _xa1],
        instruments: const [],
        rules: const [],
      );
      expect(r.chainOf('XA-01').map((j) => j.id), ['XA-01', 'XA', 'INT']);
      expect(r.chainOf('UNKNOWN'), isEmpty);
    });

    test('chainOf is cycle-safe', () {
      final r = JurisdictionResolver(
        jurisdictions: const [
          Jurisdiction(
            id: 'XA',
            level: JurisdictionLevel.country,
            names: {},
            parentId: 'XB',
          ),
          Jurisdiction(
            id: 'XB',
            level: JurisdictionLevel.country,
            names: {},
            parentId: 'XA',
          ),
        ],
        instruments: const [],
        rules: const [],
      );
      expect(r.chainOf('XA').map((j) => j.id), ['XA', 'XB']);
    });

    test('subdivision inherits country rules; other country does not', () {
      final r = JurisdictionResolver(
        jurisdictions: const [_int, _xa, _xa1, _xb],
        instruments: [_inst()],
        rules: [_rule()],
      );
      final region = r.view(
        jurisdictionId: 'XA-01',
        subjectType: 'substance',
        subjectId: 'TEST-SUBSTANCE-ALPHA',
        at: now,
      )!;
      expect(region.rules.single.$1.id, 'TEST-RULE-XA');
      final other = r.view(
        jurisdictionId: 'XB',
        subjectType: 'substance',
        subjectId: 'TEST-SUBSTANCE-ALPHA',
        at: now,
      )!;
      expect(other.rules, isEmpty);
    });

    test('only rules in force at the given date are returned', () {
      final r = JurisdictionResolver(
        jurisdictions: const [_int, _xa],
        instruments: [_inst()],
        rules: [
          _rule(id: 'TEST-OLD', to: DateTime.utc(2022)),
          _rule(id: 'TEST-NEW', from: DateTime.utc(2022)),
        ],
      );
      List<String> at(DateTime d) => r
          .view(
            jurisdictionId: 'XA',
            subjectType: 'substance',
            subjectId: 'TEST-SUBSTANCE-ALPHA',
            at: d,
          )!
          .rules
          .map((e) => e.$1.id)
          .toList();
      expect(at(DateTime.utc(2021)), ['TEST-OLD']);
      expect(at(now), ['TEST-NEW']);
      expect(at(DateTime.utc(2019)), isEmpty);
    });

    test('unreviewed rules or instruments are never shown', () {
      final r = JurisdictionResolver(
        jurisdictions: const [_int, _xa],
        instruments: [
          _inst(),
          _inst(id: 'TEST-INST-DRAFT', status: ScientificStatus.needsReview),
        ],
        rules: [
          _rule(id: 'TEST-R1', status: ScientificStatus.needsReview),
          _rule(id: 'TEST-R2', instrumentId: 'TEST-INST-DRAFT'),
        ],
      );
      final v = r.view(
        jurisdictionId: 'XA',
        subjectType: 'substance',
        subjectId: 'TEST-SUBSTANCE-ALPHA',
        at: now,
      )!;
      expect(v.rules, isEmpty);
    });

    test('compare returns one view per known jurisdiction', () {
      final r = JurisdictionResolver(
        jurisdictions: const [_int, _xa, _xb],
        instruments: [_inst()],
        rules: [_rule()],
      );
      final rows = r.compare(
        jurisdictionIds: const ['XA', 'XB', 'UNKNOWN'],
        subjectType: 'substance',
        subjectId: 'TEST-SUBSTANCE-ALPHA',
        at: now,
      );
      expect(rows.map((v) => v.jurisdiction.id), ['XA', 'XB']);
      expect(rows.first.rules, hasLength(1));
      expect(rows.last.rules, isEmpty);
    });

    test('name falls back to English, then id', () {
      expect(_xa.name('ru'), 'TEST страна A');
      expect(_xa.name('uz'), 'TEST country A');
      expect(
        const Jurisdiction(
          id: 'XZ',
          level: JurisdictionLevel.country,
          names: {},
        ).name('uz'),
        'XZ',
      );
    });
  });

  group('ContentValidator — knowledge layers', () {
    const validator = ContentValidator();

    ContentBundle bundle({
      List<Claim>? claims,
      List<JurisdictionalInstrument>? instruments,
      List<JurisdictionalRule> rules = const [],
      List<Jurisdiction> jurisdictions = const [_int, _xa, _xa1, _xb],
      BundleChannel channel = BundleChannel.test,
    }) => ContentBundle(
      channel: channel,
      sources: const [testSourceOpen],
      claims: claims ?? [testClaim()],
      citations: [
        for (final c in claims ?? [testClaim()])
          Citation(claimId: c.claimId, sourceId: 'TEST-SRC-OPEN'),
      ],
      reviewers: const [toxReviewerSenior, toxReviewer, fmReviewer],
      jurisdictions: jurisdictions,
      instruments: instruments ?? [_inst(status: ScientificStatus.needsReview)],
      jurisdictionalRules: rules,
    );

    Claim legalClaim({
      String? jurisdictionId = 'XA',
      String? instrumentId = 'TEST-INST-XA',
      KnowledgeLayer layer = KnowledgeLayer.jurisdictional,
    }) => Claim(
      claimId: 'TEST-CLAIM-LEGAL',
      entityType: EntityType.substance,
      entityId: 'TEST-SUBSTANCE-ALPHA',
      field: 'legal_status',
      value: const {'text': 'TEST DATA'},
      domain: ContentDomain.legal,
      declaredStatus: ScientificStatus.needsReview,
      evidenceLevel: EvidenceLevel.c,
      isTestData: true,
      layer: layer,
      jurisdictionId: jurisdictionId,
      instrumentId: instrumentId,
    );

    test('default claim is international scientific and valid', () {
      expect(testClaim().layer, KnowledgeLayer.internationalScientific);
      final report = validator.validate(
        bundle(rules: [_rule(status: ScientificStatus.needsReview)]),
      );
      expect(report.isValid, isTrue, reason: report.issues.join('\n'));
    });

    test('anchored jurisdictional claim is valid', () {
      final report = validator.validate(bundle(claims: [legalClaim()]));
      expect(report.isValid, isTrue, reason: report.issues.join('\n'));
    });

    test('FE012: jurisdictional claim without jurisdiction/instrument', () {
      final report = validator.validate(
        bundle(claims: [legalClaim(jurisdictionId: null)]),
      );
      expect(report.hasCode(RuleCodes.jurisdictionalClaimUnanchored), isTrue);
    });

    test('FE013: scientific claim tagged with a jurisdiction', () {
      final report = validator.validate(
        bundle(
          claims: [legalClaim(layer: KnowledgeLayer.internationalScientific)],
        ),
      );
      expect(report.hasCode(RuleCodes.layerMixing), isTrue);
    });

    test('FE013: legal-domain content in the scientific layer', () {
      final report = validator.validate(
        bundle(
          claims: [
            legalClaim(
              layer: KnowledgeLayer.internationalScientific,
              jurisdictionId: null,
              instrumentId: null,
            ),
          ],
        ),
      );
      expect(report.hasCode(RuleCodes.layerMixing), isTrue);
    });

    test('FE013: instrument belongs to another jurisdiction', () {
      final report = validator.validate(
        bundle(claims: [legalClaim(jurisdictionId: 'XB')]),
      );
      expect(report.hasCode(RuleCodes.layerMixing), isTrue);
    });

    test('FE014: instrument without a known official source', () {
      final report = validator.validate(
        bundle(
          instruments: [
            _inst(
              status: ScientificStatus.needsReview,
              sourceId: 'TEST-SRC-MISSING',
            ),
          ],
        ),
      );
      expect(report.hasCode(RuleCodes.instrumentWithoutOfficialSource), isTrue);
    });

    test('FE014: instrument without a version', () {
      final report = validator.validate(
        bundle(
          instruments: [
            _inst(status: ScientificStatus.needsReview, version: ''),
          ],
        ),
      );
      expect(report.hasCode(RuleCodes.instrumentWithoutOfficialSource), isTrue);
    });

    test('FE015: effectiveTo before effectiveFrom', () {
      final report = validator.validate(
        bundle(
          instruments: [
            _inst(
              status: ScientificStatus.needsReview,
              from: DateTime.utc(2024),
              to: DateTime.utc(2023),
            ),
          ],
        ),
      );
      expect(report.hasCode(RuleCodes.invalidEffectivePeriod), isTrue);
    });

    test('FE015: rule starts before its instrument', () {
      final report = validator.validate(
        bundle(
          rules: [
            _rule(
              status: ScientificStatus.needsReview,
              from: DateTime.utc(2019),
            ),
          ],
        ),
      );
      expect(report.hasCode(RuleCodes.invalidEffectivePeriod), isTrue);
    });

    test('FE016: unknown jurisdiction, parent, instrument and cycles', () {
      final report = validator.validate(
        bundle(
          claims: [legalClaim(jurisdictionId: 'XQ')],
          instruments: [
            _inst(status: ScientificStatus.needsReview, jurisdictionId: 'XQ'),
          ],
          rules: [
            _rule(
              status: ScientificStatus.needsReview,
              instrumentId: 'TEST-INST-NONE',
            ),
          ],
          jurisdictions: const [
            _int,
            _xa,
            Jurisdiction(
              id: 'XC',
              level: JurisdictionLevel.country,
              names: {},
              parentId: 'XD',
            ),
            Jurisdiction(
              id: 'XD',
              level: JurisdictionLevel.country,
              names: {},
              parentId: 'XC',
            ),
            Jurisdiction(
              id: 'XE',
              level: JurisdictionLevel.country,
              names: {},
              parentId: 'XNOPE',
            ),
          ],
        ),
      );
      final ids = report.issues
          .where((i) => i.code == RuleCodes.unknownJurisdictionReference)
          .map((i) => i.subjectId)
          .toSet();
      expect(
        ids,
        containsAll([
          'TEST-CLAIM-LEGAL',
          'TEST-INST-XA',
          'TEST-RULE-XA',
          'XC',
          'XD',
          'XE',
        ]),
      );
    });

    test('production rejects unreviewed and TEST jurisdictional data', () {
      final report = validator.validate(
        bundle(
          channel: BundleChannel.production,
          instruments: [_inst(status: ScientificStatus.needsReview)],
          rules: [_rule(status: ScientificStatus.needsReview)],
        ),
      );
      final ids = report.issues
          .where((i) => i.code == RuleCodes.unpublishableStatus)
          .map((i) => i.subjectId);
      expect(ids, containsAll(['TEST-INST-XA', 'TEST-RULE-XA']));
      expect(report.hasCode(RuleCodes.testDataInProduction), isTrue);
    });

    test('rule codes are stable', () {
      expect(RuleCodes.jurisdictionalClaimUnanchored, startsWith('FE012_'));
      expect(RuleCodes.layerMixing, startsWith('FE013_'));
      expect(RuleCodes.instrumentWithoutOfficialSource, startsWith('FE014_'));
      expect(RuleCodes.invalidEffectivePeriod, startsWith('FE015_'));
      expect(RuleCodes.unknownJurisdictionReference, startsWith('FE016_'));
      expect(KnowledgeLayer.values.map((l) => l.code), [
        'international_scientific',
        'international_standard',
        'jurisdictional',
      ]);
    });
  });
}
