import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/evidence/evidence_models.dart';
import 'package:forensic_expert/domain/evidence/provenance_models.dart';
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';
import 'package:forensic_expert/domain/library/library_models.dart';
import 'package:forensic_expert/domain/pro/pro_search.dart';

import '../helpers/pilot_content.dart';
import '../helpers/study_fixtures.dart';

// TEST DATA — sintetik yozuvlar: faqat qidiruv mantiqini tekshiradi.

LibraryEntry _substance(
  String id, {
  required String group,
  List<String> synonyms = const [],
  int year = 2020,
}) {
  final base = testSubstance(
    id,
    group: group,
    sources: [
      SourceView(
        sourceId: 'SRC-$id',
        title: 'TEST source $id',
        sourceType: 'journal_article',
        evidenceLevel: 'B',
        licenseMode: 'metadata_only',
        identifierVerified: false,
        year: year,
      ),
    ],
  );
  return LibraryEntry(
    id: id,
    section: LibrarySection.substances,
    name: LocalizedText({'en': 'Test$id', 'uz': 'Sinov$id', 'ru': 'Тест$id'}),
    synonyms: synonyms,
    status: ScientificStatus.needsReview,
    isTestData: true,
    group: group,
    details: base.details,
  );
}

KnowledgeEntry _method(
  String id,
  String name,
  List<AnalyticalTechnique> techniques,
) => KnowledgeEntry(
  id: id,
  kind: KnowledgeKind.method,
  area: KnowledgeArea.methods,
  name: LocalizedText({'en': name}),
  status: ScientificStatus.needsReview,
  access: EntryAccess.free,
  isTestData: true,
  claims: const [],
  sources: const [],
  method: MethodRecord(
    id: id,
    kind: MethodKind.scientificMethod,
    titles: {'en': name},
    status: ScientificStatus.needsReview,
    sourceIds: const [],
    techniques: techniques,
  ),
);

KnowledgeEntry _screening(String id, String principle) => KnowledgeEntry(
  id: id,
  kind: KnowledgeKind.screeningTest,
  area: KnowledgeArea.screening,
  name: LocalizedText({'en': 'Screen $id'}),
  status: ScientificStatus.needsReview,
  access: EntryAccess.free,
  isTestData: true,
  claims: const [],
  sources: const [],
  screening: ScreeningTest(
    id: id,
    names: {'en': 'Screen $id'},
    analyte: 'x',
    specimen: 'x',
    principle: principle,
    confirmatoryMethodIds: const ['m-gcms'],
    limitations: const [],
    status: ScientificStatus.needsReview,
    sourceIds: const [],
  ),
);

KnowledgeEntry _reagent(String id) => KnowledgeEntry(
  id: id,
  kind: KnowledgeKind.reagent,
  area: KnowledgeArea.reagents,
  name: LocalizedText({'en': 'Reagent $id'}),
  status: ScientificStatus.needsReview,
  access: EntryAccess.free,
  isTestData: true,
  claims: const [],
  sources: const [],
);

GraphLink _link(String from, String to, LinkRelation r) =>
    GraphLink(fromId: from, toId: to, relation: r, basis: 'C-$from-$to');

ProSearchIndex _index({bool withReagentLink = true}) => ProSearchIndex.build(
  library: TestLibrary([
    _substance('alpha', group: 'opioids', synonyms: ['Alfa Street']),
    _substance('beta', group: 'stimulants', year: 2024),
    _substance('gamma', group: 'opioids'),
  ]),
  knowledge: ListKnowledgeRepository([
    _method('m-gcms', 'GC-MS test method', [AnalyticalTechnique.gcMs]),
    _method('m-tlc', 'TLC test method', [AnalyticalTechnique.tlc]),
    _screening('s-colour', 'colour (spot) reaction'),
    _reagent('r1'),
    _reagent('r-unlinked'),
  ]),
  evidence: EvidenceData(
    links: [
      _link('alpha', 'blood', LinkRelation.measuredIn),
      _link('alpha', 'urine', LinkRelation.measuredIn),
      _link('alpha', 'm-gcms', LinkRelation.analysedBy),
      _link('alpha', 's-colour', LinkRelation.screenedBy),
      _link('beta', 'blood', LinkRelation.measuredIn),
      _link('beta', 'm-tlc', LinkRelation.analysedBy),
      _link('gamma', 'urine', LinkRelation.measuredIn),
      _link('gamma', 'm-gcms', LinkRelation.analysedBy),
      _link('s-colour', 'm-gcms', LinkRelation.confirmedBy),
      if (withReagentLink) _link('r1', 's-colour', LinkRelation.usedIn),
    ],
  ),
  provenance: ProvenanceIndex(
    specimens: const [
      SpecimenView(
        id: 'blood',
        category: 'fluid',
        names: LocalizedText({'en': 'Blood'}),
      ),
      SpecimenView(
        id: 'urine',
        category: 'fluid',
        names: LocalizedText({'en': 'Urine'}),
      ),
    ],
  ),
);

List<String> _ids(ProSearchResult r, [ProEntityType? type]) => [
  for (final e in r.groups.entries)
    if (type == null || e.key == type) ...e.value.map((x) => x.id),
];

void main() {
  late ProSearchIndex idx;
  setUp(() => idx = _index());

  group('matn qidiruvi', () {
    test('bo‘sh filtr: hamma yozuv, turlar bo‘yicha guruhlangan', () {
      final r = idx.search(const ProFilter());
      expect(
        _ids(r, ProEntityType.substance),
        unorderedEquals(['alpha', 'beta', 'gamma']),
      );
      expect(
        _ids(r, ProEntityType.method),
        unorderedEquals(['m-gcms', 'm-tlc']),
      );
      expect(_ids(r, ProEntityType.screening), ['s-colour']);
      expect(
        _ids(r, ProEntityType.reagent),
        unorderedEquals(['r1', 'r-unlinked']),
      );
      expect(r.total, 8);
    });

    test('uch tildagi nom va sinonim (ko‘cha nomi) bo‘yicha topadi', () {
      expect(_ids(idx.search(const ProFilter(text: 'sinovalpha'))), ['alpha']);
      expect(_ids(idx.search(const ProFilter(text: 'тестalpha'))), ['alpha']);
      expect(_ids(idx.search(const ProFilter(text: 'alfa'))), ['alpha']);
      expect(_ids(idx.search(const ProFilter(text: 'ALFA street'))), ['alpha']);
    });

    test('aniq moslik: faqat to‘liq nom/sinonim', () {
      expect(
        _ids(idx.search(const ProFilter(text: 'testalpha', exact: true))),
        ['alpha'],
      );
      expect(
        _ids(idx.search(const ProFilter(text: 'testalph', exact: true))),
        isEmpty,
      );
      expect(_ids(idx.search(const ProFilter(text: 'testalph'))), ['alpha']);
    });

    test('ibora: ketma-ket so‘zlar, tartib muhim', () {
      expect(_ids(idx.search(const ProFilter(text: '"alfa street"'))), [
        'alpha',
      ]);
      expect(_ids(idx.search(const ProFilter(text: '«alfa street»'))), [
        'alpha',
      ]);
      expect(_ids(idx.search(const ProFilter(text: '"street alfa"'))), isEmpty);
      // Iborasiz: so‘z tartibi ahamiyatsiz.
      expect(_ids(idx.search(const ProFilter(text: 'street alfa'))), ['alpha']);
    });

    test('natija mosligi bo‘yicha tartiblanadi (to‘liq mos — birinchi)', () {
      final r = idx.search(const ProFilter(text: 'testalpha'));
      expect(r.groups[ProEntityType.substance]!.first.id, 'alpha');
    });
  });

  group('faset filtrlar', () {
    test('namuna', () {
      final r = idx.search(
        const ProFilter(specimenId: 'blood', types: {ProEntityType.substance}),
      );
      expect(_ids(r), unorderedEquals(['alpha', 'beta']));
    });

    test('bir nechta filtr birga: namuna + sinf', () {
      final r = idx.search(
        const ProFilter(
          specimenId: 'urine',
          substanceClass: 'opioids',
          types: {ProEntityType.substance},
        ),
      );
      expect(_ids(r), unorderedEquals(['alpha', 'gamma']));
      final r2 = idx.search(
        const ProFilter(
          specimenId: 'blood',
          substanceClass: 'opioids',
          types: {ProEntityType.substance},
        ),
      );
      expect(_ids(r2), ['alpha']);
    });

    test('mos kelmaydigan birikma — bo‘sh natija', () {
      final r = idx.search(
        const ProFilter(
          specimenId: 'blood',
          substanceClass: 'opioids',
          family: MethodFamily.tlc,
        ),
      );
      expect(r.isEmpty, isTrue);
      expect(r.total, 0);
    });

    test('matn + faset bir vaqtda', () {
      final r = idx.search(const ProFilter(text: 'sinov', specimenId: 'urine'));
      expect(_ids(r), unorderedEquals(['alpha', 'gamma']));
      expect(
        _ids(
          idx.search(const ProFilter(text: 'sinovbeta', specimenId: 'urine')),
        ),
        isEmpty,
      );
    });

    test(
      'metod oilasi: texnika kodidan, skriningdan keyingi tasdiqlash ham',
      () {
        final gcms = idx.search(
          const ProFilter(
            family: MethodFamily.gcMs,
            types: {ProEntityType.substance},
          ),
        );
        expect(_ids(gcms), unorderedEquals(['alpha', 'gamma']));
        final colour = idx.search(
          const ProFilter(
            family: MethodFamily.colourTest,
            types: {ProEntityType.substance, ProEntityType.screening},
          ),
        );
        expect(_ids(colour), unorderedEquals(['alpha', 's-colour']));
        final tlc = idx.search(const ProFilter(family: MethodFamily.tlc));
        expect(_ids(tlc), unorderedEquals(['beta', 'm-tlc']));
      },
    );

    test('reagent: skriningga bog‘langan reagent orqali modda', () {
      final r = idx.search(
        const ProFilter(reagentId: 'r1', types: {ProEntityType.substance}),
      );
      expect(_ids(r), ['alpha']);
      // Bog‘lanmagan reagent hech narsaga olib bormaydi.
      final none = idx.search(
        const ProFilter(
          reagentId: 'r-unlinked',
          types: {ProEntityType.substance},
        ),
      );
      expect(none.isEmpty, isTrue);
    });

    test('yil va dalil darajasi', () {
      final since = idx.search(
        const ProFilter(yearFrom: 2023, types: {ProEntityType.substance}),
      );
      expect(_ids(since), ['beta']);
      final range = idx.search(
        const ProFilter(
          yearFrom: 2019,
          yearTo: 2021,
          types: {ProEntityType.substance},
        ),
      );
      expect(_ids(range), unorderedEquals(['alpha', 'gamma']));
      final a = idx.search(const ProFilter(evidenceAtLeast: 'A'));
      expect(a.isEmpty, isTrue);
      final b = idx.search(
        const ProFilter(evidenceAtLeast: 'B', types: {ProEntityType.substance}),
      );
      expect(_ids(b), unorderedEquals(['alpha', 'beta', 'gamma']));
    });

    test('holat va yurisdiksiya', () {
      expect(
        idx.search(const ProFilter(status: ScientificStatus.verified)).isEmpty,
        isTrue,
      );
      expect(
        idx.search(const ProFilter(status: ScientificStatus.needsReview)).total,
        8,
      );
      expect(idx.search(const ProFilter(jurisdictionId: 'US')).isEmpty, isTrue);
    });

    test('faset sonlari o‘z filtrini hisobga olmaydi', () {
      const f = ProFilter(
        specimenId: 'blood',
        types: {ProEntityType.substance},
      );
      final counts = idx.facetCounts(ProFacet.specimen, f);
      // blood tanlangan, lekin urine soni ham ko‘rinadi (almashtirish uchun).
      expect(counts['blood'], 2);
      expect(counts['urine'], 2);
      final classes = idx.facetCounts(ProFacet.substanceClass, f);
      expect(classes, {'opioids': 1, 'stimulants': 1});
    });

    test('clearFacets: matn saqlanadi, filtrlar tozalanadi', () {
      const f = ProFilter(text: 'x', specimenId: 'blood', exact: true);
      final c = f.clearFacets();
      expect(c.text, 'x');
      expect(c.exact, isTrue);
      expect(c.activeFacets, isEmpty);
      expect(f.copyWith(specimenId: null).specimenId, isNull);
    });
  });

  group('teskari qidiruv', () {
    test('namuna → analitlar (asos bilan)', () {
      final blood = idx.analytesForSpecimen('blood');
      expect(blood.map((h) => h.substanceId), ['alpha', 'beta']);
      expect(blood.first.basisIds, ['C-alpha-blood']);
      expect(blood.first.roles, {'measured'});
      expect(idx.analytesForSpecimen('urine').map((h) => h.substanceId), [
        'alpha',
        'gamma',
      ]);
      // Paketda yo‘q namuna — bo‘sh.
      expect(idx.analytesForSpecimen('hair'), isEmpty);
      expect(idx.specimenCounts(), {'blood': 2, 'urine': 2});
    });

    test('metod → moddalar: tahlil va skriningdan keyingi tasdiqlash', () {
      final hits = idx.substancesForMethod('m-gcms');
      expect(hits.map((h) => h.substanceId), ['alpha', 'gamma']);
      final alpha = hits.first;
      expect(alpha.roles, {'analysed', 'confirmation'});
      expect(alpha.viaIds, ['s-colour']);
      expect(hits.last.roles, {'analysed'});
      expect(idx.substancesForMethod('m-tlc').map((h) => h.substanceId), [
        'beta',
      ]);
      expect(idx.substancesForMethod('unknown'), isEmpty);
      expect(idx.methodCounts(), {'m-gcms': 2, 'm-tlc': 1});
    });

    test('reagent → moddalar: faqat manbadagi bog‘lanish orqali', () {
      final hits = idx.substancesForReagent('r1');
      expect(hits.map((h) => h.substanceId), ['alpha']);
      expect(hits.single.viaIds, ['s-colour']);
      expect(hits.single.roles, {'screened'});
      expect(idx.substancesForReagent('r-unlinked'), isEmpty);
      expect(idx.linkedReagentIds, ['r1']);
      expect(idx.reagentCount, 2);
    });

    test('reagent bog‘lanishi yo‘q paket: teskari ro‘yxat bo‘sh', () {
      final none = _index(withReagentLink: false);
      expect(none.linkedReagentIds, isEmpty);
      expect(none.substancesForReagent('r1'), isEmpty);
    });
  });

  group('HAQIQIY pilot paket', () {
    late PilotContent pilot;
    late ProSearchIndex real;
    setUpAll(() async {
      pilot = await loadPilotContent();
      real = ProSearchIndex.build(
        library: pilot.library,
        knowledge: pilot.knowledge,
        evidence: pilot.evidence,
        provenance: pilot.provenance,
      );
    });

    test('uch tilda nom bo‘yicha topiladi', () {
      for (final q in ['morphine', 'morfin', 'морфин']) {
        expect(
          _ids(
            real.search(ProFilter(text: q), lang: 'uz'),
            ProEntityType.substance,
          ),
          contains('morphine'),
          reason: q,
        );
      }
    });

    test('qon namunasi → morfin; LC-MS/MS → morfin', () {
      expect(
        real.analytesForSpecimen('blood').map((h) => h.substanceId),
        contains('morphine'),
      );
      expect(
        real.substancesForMethod('method-lcmsms').map((h) => h.substanceId),
        contains('morphine'),
      );
    });

    test('kokain: immunoassay skrining → GC-MS tasdiqlash (roli)', () {
      final hit = real
          .substancesForMethod('method-gcms')
          .firstWhere((h) => h.substanceId == 'cocaine');
      expect(hit.roles, contains('confirmation'));
    });

    test('namuna + sinf + oila birikmasi; noto‘g‘ri birikma bo‘sh', () {
      final r = real.search(
        const ProFilter(
          specimenId: 'blood',
          substanceClass: 'opioids',
          family: MethodFamily.lcMs,
          types: {ProEntityType.substance},
        ),
      );
      expect(_ids(r), contains('morphine'));
      for (final rec in r.groups[ProEntityType.substance]!) {
        expect(rec.substanceClass, 'opioids');
        expect(rec.specimens, contains('blood'));
        expect(rec.families, contains(MethodFamily.lcMs));
      }
      final none = real.search(
        const ProFilter(
          substanceClass: 'toxic_gases',
          family: MethodFamily.tlc,
          specimenId: 'hair',
        ),
      );
      expect(none.isEmpty, isTrue);
    });

    test('hech bir yozuv VERIFIED sifatida ko‘rsatilmaydi', () {
      expect(
        real.search(const ProFilter(status: ScientificStatus.verified)).isEmpty,
        isTrue,
      );
    });
  });
}
