import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// PHASE 7 ekranlari — HAQIQIY pilot paket (2026.10.5) bilan.
/// Nusxa: `docs/screenshots/phase7/`.
void main() {
  const std = Size(390, 844);
  const small = Size(320, 640);
  const dark = ThemeMode.dark;

  AppSettings s(String lang, {ThemeMode theme = ThemeMode.light}) =>
      completedSettings(lang: lang, theme: theme);

  late PilotContent content;
  setUpAll(() async => content = await loadPilotContent());

  const conc = Key('claim.context.C-MORPHINE-REPORTED_CONCENTRATION-P5');
  const prov = Key('claim.provenance.C-MORPHINE-REPORTED_CONCENTRATION-P5');

  final cases =
      <
        ({
          String name,
          AppSettings settings,
          String route,
          Size size,
          double scale,
          Key? scrollTo,
          Key? tap,
        })
      >[
        (
          name: 'p7_01_substance_context_en',
          settings: s('en'),
          route: Routes.libraryEntry('morphine'),
          size: std,
          scale: 1,
          scrollTo: conc,
          tap: null,
        ),
        (
          name: 'p7_02_provenance_sheet_en',
          settings: s('en'),
          route: Routes.libraryEntry('morphine'),
          size: std,
          scale: 1,
          scrollTo: prov,
          tap: prov,
        ),
        (
          name: 'p7_03_provenance_sheet_uz_dark',
          settings: s('uz', theme: dark),
          route: Routes.libraryEntry('morphine'),
          size: std,
          scale: 1,
          scrollTo: prov,
          tap: prov,
        ),
        (
          name: 'p7_04_retracted_algor_en',
          settings: s('en'),
          route: Routes.knowledgeEntry('fm-algor-mortis'),
          size: std,
          scale: 1,
          scrollTo: const Key('claim.retracted.C-FM-ALGOR-MORTIS-DEFINITION'),
          tap: null,
        ),
        (
          name: 'p7_05_conflict_methadone_en',
          settings: s('en'),
          route: Routes.conflict('CF-METHADONE-PM-VS-LIVING'),
          size: std,
          scale: 1,
          scrollTo: null,
          tap: null,
        ),
        (
          name: 'p7_06_conflicts_ru',
          settings: s('ru'),
          route: Routes.conflicts,
          size: std,
          scale: 1,
          scrollTo: null,
          tap: null,
        ),
        (
          name: 'p7_07_context_ru_dark',
          settings: s('ru', theme: dark),
          route: Routes.libraryEntry('morphine'),
          size: std,
          scale: 1,
          scrollTo: conc,
          tap: null,
        ),
        (
          name: 'p7_08_metabolites_thc_en',
          settings: s('en'),
          route: Routes.libraryEntry('thc'),
          size: std,
          scale: 1,
          scrollTo: const Key('substance.p7.thc'),
          tap: null,
        ),
        (
          name: 'p7_09_specimens_uz',
          settings: s('uz'),
          route: Routes.specimens,
          size: std,
          scale: 1,
          scrollTo: null,
          tap: null,
        ),
        (
          name: 'p7_10_specimen_vitreous_en',
          settings: s('en'),
          route: Routes.specimen('vitreous'),
          size: std,
          scale: 1,
          scrollTo: null,
          tap: null,
        ),
        (
          name: 'p7_11_specimen_blood_ru_dark',
          settings: s('ru', theme: dark),
          route: Routes.specimen('blood'),
          size: std,
          scale: 1,
          scrollTo: null,
          tap: null,
        ),
        (
          name: 'p7_12_chain_cocaine_en',
          settings: s('en'),
          route: Routes.chain('cocaine'),
          size: std,
          scale: 1,
          scrollTo: null,
          tap: null,
        ),
        (
          name: 'p7_13_chain_heroin_uz_dark',
          settings: s('uz', theme: dark),
          route: Routes.chain('heroin'),
          size: std,
          scale: 1,
          scrollTo: null,
          tap: null,
        ),
        (
          name: 'p7_14_standards_en',
          settings: s('en'),
          route: Routes.libraryStandards,
          size: std,
          scale: 1,
          scrollTo: const Key('standards.catalogue.STD-ICH-Q2R1'),
          tap: null,
        ),
        (
          name: 'p7_15_standards_ru',
          settings: s('ru'),
          route: Routes.libraryStandards,
          size: std,
          scale: 1,
          scrollTo: const Key('standards.catalogue.STD-ASTM-E2329-25'),
          tap: null,
        ),
        (
          name: 'p7_16_review_status_en',
          settings: s('en'),
          route: Routes.reviewStatus,
          size: std,
          scale: 1,
          scrollTo: null,
          tap: null,
        ),
        (
          name: 'p7_17_review_status_uz_dark',
          settings: s('uz', theme: dark),
          route: Routes.reviewStatus,
          size: std,
          scale: 1,
          scrollTo: null,
          tap: null,
        ),
        (
          name: 'p7_18_jurisdiction_de_en',
          settings: s('en'),
          route: Routes.jurisdiction('DE'),
          size: std,
          scale: 1,
          scrollTo: null,
          tap: null,
        ),
        (
          name: 'p7_19_jurisdiction_us_ru',
          settings: s('ru'),
          route: Routes.jurisdiction('US'),
          size: std,
          scale: 1,
          scrollTo: null,
          tap: null,
        ),
        (
          name: 'p7_20_jurisdiction_uz_uz',
          settings: s('uz'),
          route: Routes.jurisdiction('UZ'),
          size: std,
          scale: 1,
          scrollTo: null,
          tap: null,
        ),
        (
          name: 'p7_21_search_specimen_uz',
          settings: s('uz'),
          route: Routes.searchWith('shishasimon'),
          size: std,
          scale: 1,
          scrollTo: null,
          tap: null,
        ),
        (
          name: 'p7_22_lod_loq_q2r2_en',
          settings: s('en'),
          route: Routes.tool('tool.lab.lod_loq'),
          size: std,
          scale: 1,
          scrollTo: null,
          tap: null,
        ),
        (
          name: 'p7_23_method_published_ru',
          settings: s('ru'),
          route: Routes.knowledgeEntry('method-gcms'),
          size: std,
          scale: 1,
          scrollTo: const Key('method.publishedNote'),
          tap: null,
        ),
        (
          name: 'p7_24_library_hub_320_x13_uz',
          settings: s('uz'),
          route: Routes.library,
          size: small,
          scale: 1.3,
          scrollTo: const Key('library.hub.conflicts'),
          tap: null,
        ),
      ];

  for (final c in cases) {
    testWidgets(c.name, (tester) async {
      await pumpApp(
        tester,
        settings: c.settings,
        size: c.size,
        textScale: c.scale,
        initialLocation: c.route,
        pixelRatio: 1.5,
        testFixtures: false,
        overrides: [
          ...content.overrides,
          entitlementServiceProvider.overrideWithValue(FakeStore(owned: true)),
        ],
      );
      await tester.pump(const Duration(milliseconds: 400));
      await settleImages(tester);
      if (c.scrollTo != null) {
        await tester.dragUntilVisible(
          find.byKey(c.scrollTo!),
          find.byType(Scrollable).first,
          const Offset(0, -200),
        );
        await settleImages(tester);
      }
      if (c.tap != null) {
        await tester.tap(find.byKey(c.tap!));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/${c.name}.png'),
      );
    });
  }
}
