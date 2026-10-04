import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// PHASE 5 ekranlari — HAQIQIY pilot paket bilan (TEST fixture’siz).
///
/// Light + Dark, 320 dp + katta shrift, Android va iOS platformasi.
/// Nusxa: `docs/screenshots/phase5/` (`tool/copy_phase5_screenshots.sh`).
void main() {
  const std = Size(390, 844);
  const small = Size(320, 640);
  const iphoneSe = Size(375, 667);
  const dark = ThemeMode.dark;

  AppSettings s(String lang, {ThemeMode theme = ThemeMode.light}) =>
      completedSettings(lang: lang, theme: theme);

  late PilotContent content;
  setUpAll(() async => content = await loadPilotContent());

  final cases =
      <
        ({
          String name,
          AppSettings settings,
          String route,
          Size size,
          double scale,
          bool owned,
          TargetPlatform? platform,
          double scroll,
        })
      >[
        (
          name: 'p5_01_home_en',
          settings: s('en'),
          route: Routes.home,
          size: std,
          scale: 1,
          owned: false,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p5_02_home_uz_dark',
          settings: s('uz', theme: dark),
          route: Routes.home,
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 500,
        ),
        (
          name: 'p5_03_library_groups_en',
          settings: s('en'),
          route: Routes.librarySection('substances'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p5_04_substance_structure_en',
          settings: s('en'),
          route: Routes.libraryEntry('morphine'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 330,
        ),
        (
          name: 'p5_05_substance_concentration_en',
          settings: s('en'),
          route: Routes.libraryEntry('morphine'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 1700,
        ),
        (
          name: 'p5_06_substance_related_uz_dark',
          settings: s('uz', theme: dark),
          route: Routes.libraryEntry('methanol'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 2400,
        ),
        (
          name: 'p5_07_research_library_en',
          settings: s('en'),
          route: Routes.research,
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p5_08_research_dissertation_en',
          settings: s('en'),
          route: Routes.researchEntry('RS-582d32d8a823'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p5_09_research_sr_ru_dark',
          settings: s('ru', theme: dark),
          route: Routes.researchEntry('RS-dc1842852526'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p5_10_image_chromatogram_en',
          settings: s('en'),
          route: Routes.image('IMG-EXT-pmc6445230-ienz_a_1333987_f0004_b'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p5_11_image_schematic_uz',
          settings: s('uz'),
          route: Routes.image('IMG-SCH-screen-confirm'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p5_12_histology_hub_en',
          settings: s('en'),
          route: Routes.histology,
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p5_13_histology_entry_en',
          settings: s('en'),
          route: Routes.knowledgeEntry('his-mi-early'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p5_14_method_lcmsms_en',
          settings: s('en'),
          route: Routes.knowledgeEntry('method-lcmsms'),
          size: std,
          scale: 1,
          owned: false,
          platform: null,
          scroll: 400,
        ),
        (
          name: 'p5_15_reagent_dragendorff_en',
          settings: s('en'),
          route: Routes.knowledgeEntry('reagent-dragendorff'),
          size: std,
          scale: 1,
          owned: false,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p5_16_screening_strips_ru_dark',
          settings: s('ru', theme: dark),
          route: Routes.knowledgeEntry('scr-fentanyl-test-strips'),
          size: std,
          scale: 1,
          owned: false,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p5_17_biochemistry_hub_ru',
          settings: s('ru'),
          route: Routes.biochemistry,
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p5_18_fm_entry_en',
          settings: s('en'),
          route: Routes.knowledgeEntry('fm-blunt-trauma'),
          size: std,
          scale: 1,
          owned: false,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p5_19_search_research_en',
          settings: s('en'),
          route: Routes.searchWith('postmortem redistribution'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p5_20_library_320_x13',
          settings: s('ru'),
          route: Routes.librarySection('substances'),
          size: small,
          scale: 1.3,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p5_21_substance_320_x13_dark',
          settings: s('uz', theme: dark),
          route: Routes.libraryEntry('fentanyl'),
          size: small,
          scale: 1.3,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p5_22_research_320_x13',
          settings: s('en'),
          route: Routes.research,
          size: small,
          scale: 1.3,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p5_23_ios_home_en',
          settings: s('en'),
          route: Routes.home,
          size: iphoneSe,
          scale: 1,
          owned: false,
          platform: TargetPlatform.iOS,
          scroll: 0,
        ),
        (
          name: 'p5_24_ios_substance_dark',
          settings: s('en', theme: dark),
          route: Routes.libraryEntry('cocaine'),
          size: iphoneSe,
          scale: 1,
          owned: true,
          platform: TargetPlatform.iOS,
          scroll: 0,
        ),
      ];

  for (final c in cases) {
    testWidgets(c.name, (tester) async {
      debugDefaultTargetPlatformOverride = c.platform;
      try {
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
            entitlementServiceProvider.overrideWithValue(
              FakeStore(owned: c.owned),
            ),
          ],
        );
        // Qidiruv debounce’i.
        await tester.pump(const Duration(milliseconds: 400));
        await settleImages(tester);
        if (c.scroll > 0) {
          await tester.drag(
            find.byType(Scrollable).first,
            Offset(0, -c.scroll),
          );
          await settleImages(tester);
        }
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/${c.name}.png'),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }
}
