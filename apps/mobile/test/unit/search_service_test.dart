import 'package:fe_search_core/fe_search_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/search_service.dart';
import 'package:forensic_expert/data/fixtures/test_fixtures.dart';

// TEST DATA — faqat nomlar (fixture), ilmiy qiymat yo‘q.
void main() {
  final service = AppSearchService.build(
    library: const FixtureLibraryRepository(),
    learn: const FixtureLearnRepository(),
  );

  List<String> ids(AppSearchResult r, SearchGroup g) =>
      r.groups[g]!.map((h) => h.entityId).toList();

  test('EN / RU / UZ so‘rovlari bir xil moddani topadi', () async {
    for (final q in ['Ethanol', 'Этанол', 'Etanol', 'этиловый спирт']) {
      final r = await service.search(q);
      expect(
        ids(r, SearchGroup.substances),
        contains('TEST-SUB-ETOH'),
        reason: q,
      );
    }
  });

  test(
    'Methamphetamine / Метамфетамин / Metamfetamin / metamfetamín',
    () async {
      for (final q in [
        'Methamphetamine',
        'Метамфетамин',
        'Metamfetamin',
        'метамфетамин',
        'METAMFETAMIN',
      ]) {
        expect(
          ids(await service.search(q), SearchGroup.substances),
          contains('TEST-SUB-METH'),
          reason: q,
        );
      }
    },
  );

  test('typo-tolerant: «metamfetamn», «fentanly»', () async {
    expect(
      ids(await service.search('metamfetamn'), SearchGroup.substances),
      contains('TEST-SUB-METH'),
    );
    expect(
      ids(await service.search('fentanly'), SearchGroup.substances),
      contains('TEST-SUB-FENT'),
    );
  });

  test('natijalar SUBSTANCES / METHODS / TOOLS / LEARNING / REFERENCES '
      'guruhlariga ajraladi', () async {
    expect(
      ids(await service.search('GC-MS'), SearchGroup.methods),
      contains('TEST-METHOD-GCMS'),
    );
    expect(
      ids(await service.search('Dilution'), SearchGroup.tools),
      contains('tool.lab.dilution'),
    );
    expect(
      ids(await service.search('Разведение'), SearchGroup.tools),
      contains('tool.lab.dilution'),
    );
    expect(
      ids(await service.search('Suyultirish'), SearchGroup.tools),
      contains('tool.lab.dilution'),
    );
    expect(
      ids(await service.search('Chain of custody'), SearchGroup.learning),
      contains('TEST-GLOSS-COC'),
    );
    expect(
      ids(await service.search('TEST REFERENCE'), SearchGroup.references),
      isNotEmpty,
    );
  });

  test('guruh xaritasi: har bir qidiruv toifasi aniq guruhga tushadi', () {
    expect(SearchGroup.values.map((g) => g.name), [
      'substances',
      'topics',
      'methods',
      'reagents',
      'screening',
      'tools',
      'standardsLaws',
      'learning',
      'references',
    ]);
    // Har bir toifa (kelajakdagilar ham) xaritalangan — switch to‘liq.
    for (final c in SearchCategory.values) {
      expect(AppSearchService.groupOf(c), isA<SearchGroup>());
    }
    expect(
      AppSearchService.groupOf(SearchCategory.screeningTest),
      SearchGroup.screening,
    );
    expect(
      AppSearchService.groupOf(SearchCategory.law),
      SearchGroup.standardsLaws,
    );
    expect(
      AppSearchService.groupOf(SearchCategory.reagent),
      SearchGroup.reagents,
    );
  });

  test('natija yo‘q holati', () async {
    final r = await service.search('zzzzqqqxx');
    expect(r.isEmpty, isTrue);
    expect(r.total, 0);
  });

  test('qidiruv lokal va tez (host VM, 1000 so‘rov)', () async {
    final sw = Stopwatch()..start();
    for (var i = 0; i < 1000; i++) {
      await service.search(i.isEven ? 'метамфетамин' : 'paracet');
    }
    sw.stop();
    final perQueryUs = sw.elapsedMicroseconds / 1000;
    // Juda keng chegara: faqat regressiyani ushlaydi, benchmark emas.
    expect(perQueryUs, lessThan(20000));
  });

  test(
    'bo‘sh repozitoriylar bilan ham ishlaydi (production default)',
    () async {
      final empty = AppSearchService.build(
        library: const EmptyLibraryRepository(),
        learn: const EmptyLearnRepository(),
      );
      final r = await empty.search('ethanol');
      expect(ids(r, SearchGroup.substances), isEmpty);
      // Vositalar katalogi kontent paketiga bog‘liq emas.
      expect(
        ids(await empty.search('dilution'), SearchGroup.tools),
        contains('tool.lab.dilution'),
      );
    },
  );
}
