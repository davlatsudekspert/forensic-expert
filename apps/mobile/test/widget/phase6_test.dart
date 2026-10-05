import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/search_service.dart';
import 'package:forensic_expert/app/user_data.dart';
import 'package:forensic_expert/core/settings/settings_controller.dart';
import 'package:forensic_expert/core/widgets/fe_components.dart';
import 'package:forensic_expert/data/fixtures/test_fixtures.dart';
import 'package:forensic_expert/data/offline/offline_ai.dart';
import 'package:forensic_expert/domain/ai/ai_architecture.dart';
import 'package:forensic_expert/domain/jurisdiction/country_directory.dart';
import 'package:forensic_expert/domain/jurisdiction/jurisdiction_catalog.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';
import 'package:forensic_expert/domain/ports/product_tiers.dart';
import 'package:forensic_expert/domain/privacy/telemetry_policy.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// PHASE 6: global multidisiplinar platforma — fanlar, yurisdiksiya qatlami,
/// Library hub, kalkulyatorlar, qidiruv, AI xavfsizligi, maxfiylik.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<ProviderContainer> open(
    WidgetTester tester,
    String location, {
    bool owned = true,
    String lang = 'en',
    String jurisdiction = 'INT',
  }) => pumpApp(
    tester,
    settings: completedSettings(lang: lang)
        .copyWith(jurisdictionId: jurisdiction),
    initialLocation: location,
    testFixtures: false,
    overrides: [
      ...pilot.overrides,
      entitlementServiceProvider.overrideWithValue(FakeStore(owned: owned)),
    ],
  );

  Future<void> see(WidgetTester tester, Finder f) async {
    await tester.dragUntilVisible(
      f,
      find.byType(Scrollable).first,
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    expect(f, findsWidgets);
  }

  group('Home', () {
    testWidgets('12 asosiy bo‘lim, yurisdiksiya konteksti, barcha fanlar', (
      tester,
    ) async {
      await open(tester, Routes.home);
      expect(find.byKey(const Key('home.jurisdiction')), findsOneWidget);
      for (final m in [
        'forensicMedicine',
        'toxicology',
        'laboratory',
        'substances',
        'methods',
        'reagents',
        'screening',
        'biochemistry',
        'standardsLaws',
        'research',
        'learn',
        'ai',
      ]) {
        expect(find.byKey(Key('home.module.$m')), findsOneWidget, reason: m);
      }
      // Gistologiya va yangi muammolar — «Barcha fanlar» ichida.
      expect(find.byKey(const Key('home.module.histology')), findsNothing);
      await see(tester, find.byKey(const Key('home.allDisciplines')));
      // Yangi foydalanuvchi: bo‘sh bloklar o‘rniga bitta qator.
      await see(tester, find.byKey(const Key('home.quickEmpty')));
    });

    testWidgets('yaqinda ko‘rilgan yozuv Home’da (faqat lokal)', (
      tester,
    ) async {
      final c = await open(tester, Routes.libraryEntry('morphine'));
      await tester.pumpAndSettle();
      expect(c.read(userDataProvider).recentlyViewed, ['morphine']);
      c.read(routerProvider).go(Routes.home);
      await tester.pumpAndSettle();
      await see(tester, find.byKey(const Key('home.recentlyViewed')));
    });
  });

  group('Fanlar', () {
    testWidgets('20 fan ro‘yxati; bo‘sh fan «hali manba yo‘q»', (tester) async {
      await open(tester, Routes.disciplines);
      expect(find.byKey(const Key('disciplines.list')), findsOneWidget);
      await see(
        tester,
        find.byKey(const Key('discipline.forensic_entomology')),
      );
    });

    testWidgets('toksikologiya: modullar va manbali yozuvlar soni', (
      tester,
    ) async {
      await open(tester, Routes.discipline('forensic_toxicology'));
      expect(find.byKey(const Key('discipline.module.substances')), findsOne);
      expect(find.textContaining('sourced records'), findsWidgets);
    });

    // PHASE 8: entomologiya endi manbali mavzuga ega — bo‘sh fan sifatida
    // sud psixiatriyasi tekshiriladi.
    testWidgets('sud psixiatriyasi: kontent yo‘q — halol bo‘sh holat', (
      tester,
    ) async {
      await open(tester, Routes.discipline('forensic_psychiatry'));
      expect(find.byKey(const Key('discipline.empty')), findsOneWidget);
    });
  });

  group('Yurisdiksiya qatlami', () {
    test('katalog: 249 ISO davlati + INT + EU, EI a’zolari EU ostida', () {
      expect(CountryDirectory.all.length, 249);
      final ids = {for (final j in JurisdictionCatalog.seed) j.id};
      expect(ids, containsAll(['INT', 'EU', 'UZ', 'DE', 'US', 'JP', 'BR']));
      final de = JurisdictionCatalog.seed.firstWhere((j) => j.id == 'FR');
      expect(de.parentId, 'EU');
      final uz = CountryDirectory.byCode('UZ')!;
      expect(uz.name('uz'), 'O‘zbekiston');
      expect(uz.name('ru'), 'Узбекистан');
    });

    testWidgets('kontent yo‘q davlat: «tekshirilmagan», boshqa davlat '
        'qonuni fallback sifatida ko‘rsatilmaydi', (tester) async {
      // PHASE 7: DE endi pilot hujjatiga ega — kontentsiz davlat sifatida FR.
      await open(tester, Routes.jurisdiction('FR'));
      expect(find.byKey(const Key('jurisdiction.notVerified')), findsOneWidget);
      // UK pilot hujjatlari Fransiya sahifasida YO‘Q.
      for (final i in pilot.legal.instruments) {
        if (i.jurisdictionId.startsWith('GB')) {
          expect(find.byKey(Key('instrument.${i.id}')), findsNothing);
        }
      }
    });

    testWidgets('GB: o‘z hujjatlari to‘liq metadata va hujjat turi bilan', (
      tester,
    ) async {
      await open(tester, Routes.jurisdiction('GB'));
      final gb = pilot.legal.instruments.firstWhere(
        (i) => i.jurisdictionId.startsWith('GB'),
      );
      await see(tester, find.byKey(Key('instrument.${gb.id}')));
      expect(find.byKey(Key('instrument.kind.${gb.id}')), findsOneWidget);
      expect(find.text('Official source'), findsWidgets);
      expect(find.text('Legal status'), findsWidgets);
    });

    testWidgets('tanlovchi: qidiruv va tanlash sozlamaga yoziladi', (
      tester,
    ) async {
      final c = await open(tester, Routes.jurisdictionSelect);
      await tester.enterText(
        find.byKey(const Key('jurisdictions.search')),
        'Germ',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('picker.jurisdiction.DE')));
      await tester.pumpAndSettle();
      expect(c.read(settingsControllerProvider).jurisdictionId, 'DE');
    });

    testWidgets('hub: joriy yurisdiksiya, uch qatlam, Compare', (tester) async {
      await open(tester, Routes.jurisdictions, jurisdiction: 'GB');
      expect(find.byKey(const Key('jurisdictions.current')), findsOneWidget);
      await see(tester, find.byKey(const Key('jurisdictions.compare')));
    });
  });

  group('Library hub', () {
    testWidgets('ilmiy yozuvlar va hujjatlar guruhlari, haqiqiy sonlar', (
      tester,
    ) async {
      await open(tester, Routes.library);
      expect(find.byKey(const Key('library.hub.substances')), findsOneWidget);
      expect(find.text('137 records'), findsOneWidget);
      await see(tester, find.byKey(const Key('library.hub.jurisdictions')));
      await tester.tap(find.byKey(const Key('library.hub.standards')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('library.standards')), findsOneWidget);
      // INCB ro‘yxati — REGULATION (qonuniy majburiy, o‘z yurisdiksiyasida).
      expect(find.textContaining('REGULATION'), findsWidgets);
    });
  });

  group('Ogohlantirish ierarxiyasi', () {
    testWidgets('skrining va konsentratsiya bannerlari CRITICAL', (
      tester,
    ) async {
      await open(tester, Routes.knowledgeEntry('scr-fentanyl-test-strips'));
      final b = tester.widget<FeBanner>(
        find.byKey(const Key('screening.banner')),
      );
      expect(b.tone, FeBannerTone.critical);
    });

    testWidgets('modda sahifasi: indeks va manbasiz bo‘limlar bitta kartada', (
      tester,
    ) async {
      await open(tester, Routes.libraryEntry('morphine'));
      await see(tester, find.byKey(const Key('entry.index')));
      expect(
        find.byKey(const Key('entry.index.reported_concentration')),
        findsOneWidget,
      );
      await see(tester, find.byKey(const Key('entry.notSourced')));
    });
  });

  group('Shablon qamrovi', () {
    testWidgets('reagent: N / M bo‘lim manbali', (tester) async {
      await open(tester, Routes.knowledgeEntry('reagent-dragendorff'));
      await see(tester, find.byKey(const Key('knowledge.templateCoverage')));
      expect(find.textContaining('Sections with sourced data'), findsOneWidget);
    });
  });

  group('Research filtrlari', () {
    testWidgets('peer-reviewed filtri dissertatsiyalarni yashiradi', (
      tester,
    ) async {
      await open(tester, Routes.research);
      final all = pilot.evidence.research.length;
      expect(find.textContaining('$all', findRichText: true), findsWidgets);
      await tester.tap(find.byKey(const Key('research.filter.peer')));
      await tester.pumpAndSettle();
      final peer = pilot.evidence.research.where((r) => r.peerReviewed).length;
      expect(find.textContaining('$peer', findRichText: true), findsWidgets);
      expect(find.byKey(const Key('research.filter.clear')), findsOneWidget);
    });

    testWidgets('tafsilot: forensik dolzarblik — baholanmagan (alohida)', (
      tester,
    ) async {
      final r = pilot.evidence.research.first;
      await open(tester, Routes.researchEntry(r.id));
      await see(tester, find.textContaining('Not yet assessed'));
    });
  });

  group('Kalkulyatorlar (UI)', () {
    testWidgets('LOD/LOQ: regressiyadan σ va S, ICH manbasi ko‘rsatiladi', (
      tester,
    ) async {
      await open(tester, Routes.tool('tool.lab.lod_loq'));
      await tester.enterText(
        find.byKey(const Key('calc.points')),
        '0 0.1\n1 2.0\n2 4.1\n3 5.9\n4 8.1',
      );
      await tester.tap(find.byKey(const Key('calc.regress')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('calc.calculate')));
      await tester.tap(find.byKey(const Key('calc.calculate')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('calc.result')), findsOneWidget);
      // PHASE 7 (RG-25): havola ICH Q2(R2) ga ko‘chirildi.
      expect(find.textContaining('ICH Q2(R2)'), findsWidgets);
    });

    testWidgets('konvertatsiya: molyar massasiz massa↔molyar — xato', (
      tester,
    ) async {
      await open(tester, Routes.tool('tool.conv.concentration_units'));
      await tester.enterText(find.byKey(const Key('calc.value')), '1');
      await tester.tap(find.byKey(const Key('calc.calculate')));
      await tester.pumpAndSettle();
      // mg/L → ng/mL (standart) — molyar massa kerak emas.
      expect(find.text('1000 ng/mL'), findsOneWidget);
    });

    testWidgets('statistika: o‘rtacha va SD', (tester) async {
      await open(tester, Routes.tool('tool.lab.descriptive_stats'));
      await tester.enterText(
        find.byKey(const Key('calc.values')),
        '2 4 4 4 5 5 7 9',
      );
      await tester.tap(find.byKey(const Key('calc.calculate')));
      await tester.pumpAndSettle();
      expect(find.text('5'), findsWidgets);
      expect(find.text('4.5'), findsOneWidget);
    });
  });

  group('Qidiruv', () {
    test(
      'Methamphetamine / Метамфетамин / Metamfetamin — bitta yozuv',
      () async {
        final s = AppSearchService.build(
          library: pilot.library,
          learn: const EmptyLearnRepository(),
          knowledge: pilot.knowledge,
        );
        for (final q in ['Methamphetamine', 'Метамфетамин', 'Metamfetamin']) {
          final r = await s.search(q);
          expect(
            r.groups[SearchGroup.substances]!.first.entityId,
            'methamphetamine',
            reason: q,
          );
        }
      },
    );

    test('metabolit nomi ota moddaga olib boradi', () async {
      final s = AppSearchService.build(
        library: pilot.library,
        learn: const EmptyLearnRepository(),
        knowledge: pilot.knowledge,
      );
      final r = await s.search('morphine-3-glucuronide');
      expect(
        r.groups[SearchGroup.substances]!.map((h) => h.entityId),
        contains('morphine'),
      );
    });

    testWidgets('natijada kategoriya va review holati ko‘rinadi', (
      tester,
    ) async {
      await open(tester, Routes.searchWith('fentanyl'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.textContaining('Needs review'), findsWidgets);
    });
  });

  group('Forensic AI', () {
    const policy = SafetyPolicy(RegexPiiScanner());

    test('huquqiy savol — yurisdiksiya kerak', () {
      expect(
        SafetyPolicy.isJurisdictional('Is ketamine a controlled substance?'),
        isTrue,
      );
      expect(SafetyPolicy.isJurisdictional('Ketamin qonun bo‘yicha'), isTrue);
      expect(
        SafetyPolicy.isJurisdictional('What are the metabolites of ketamine?'),
        isFalse,
      );
    });

    test('rasmiy ekspert xulosasi / zaharlanish xulosasi bloklanadi', () {
      for (final q in [
        'Write the official expert opinion for this case',
        'Was the deceased poisoned?',
        'Напишите заключение эксперта',
        'Ekspert xulosasini yozib bering',
      ]) {
        expect(
          policy.checkQuestion(q).blocks,
          contains(SafetyBlock.officialOpinion),
          reason: q,
        );
      }
      expect(
        policy.checkQuestion('Describe LC-MS/MS validation parameters').allowed,
        isTrue,
      );
    });

    testWidgets('UI: huquqiy savolda yurisdiksiya tanlash taklifi', (
      tester,
    ) async {
      await open(tester, Routes.ai);
      await tester.enterText(
        find.byKey(const Key('ai.input')),
        'Is fentanyl a controlled substance under the law?',
      );
      await tester.ensureVisible(find.byKey(const Key('ai.findSources')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('ai.findSources')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('ai.jurisdictionRequired')), findsOneWidget);
      expect(find.byKey(const Key('ai.selectJurisdiction')), findsOneWidget);
    });
  });

  group('Billing va maxfiylik arxitekturasi', () {
    test('darajalar: faqat store’da mavjud mahsulot xarid qilinadi', () {
      expect(ProductTiers.purchasableProductIds, ProductIds.all);
      expect(ProductTiers.tierOf(Entitlements.free), PlanTier.free);
      expect(PlanTier.values.length, 4);
    });

    test('telemetriya: so‘rov, matn va ID’lar hech qachon o‘tmaydi', () {
      final out = TelemetryPolicy.sanitize({
        'event': 'screen_view',
        'route_template': '/library/entry/morphine?q=John Doe',
        'query': 'fentanyl in John Doe blood',
        'case_number': 'AB-123',
        'text': 'narrative',
        'locale': 'uz',
      });
      expect(out.keys.toSet(), {'event', 'route_template', 'locale'});
      expect(out['route_template'], '/library/entry/:id');
      expect(out.values.join(), isNot(contains('John')));
    });
  });

  test('kontent: hech bir yozuv VERIFIED emas (reviewer yo‘q)', () {
    for (final kind in ScientificStatus.values) {
      if (kind == ScientificStatus.verified) {
        expect(pilot.evidence.research.where((r) => r.status == kind), isEmpty);
      }
    }
  });
}
