import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// PHASE 6 ekranlari — HAQIQIY pilot paket bilan (TEST fixture’siz).
/// Learn ekrani ilova ichidagi o‘quv kontentini ko‘rsatadi (fixture bo‘lsa —
/// TEST DATA belgisi bilan).
///
/// Light + Dark, 320 dp + katta shrift, Android va iOS platformasi.
/// Nusxa: `docs/screenshots/phase6/` (`tool/copy_phase5_screenshots.sh`).
void main() {
  const std = Size(390, 844);
  const small = Size(320, 640);
  const dark = ThemeMode.dark;

  AppSettings s(String lang, {ThemeMode theme = ThemeMode.light}) =>
      completedSettings(lang: lang, theme: theme);

  late PilotContent content;
  setUpAll(() async => content = await loadPilotContent());

  testWidgets('p6_01_language_first', (tester) async {
    await pumpApp(
      tester,
      size: std,
      pixelRatio: 1.5,
      testFixtures: false,
      overrides: content.overrides,
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/p6_01_language_first.png'),
    );
  });

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
          name: 'p6_02_home_en',
          settings: s('en'),
          route: Routes.home,
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_03_home_uz_dark',
          settings: s('uz', theme: dark),
          route: Routes.home,
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_04_home_ru',
          settings: s('ru'),
          route: Routes.home,
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 420,
        ),
        (
          name: 'p6_05_tools_en',
          settings: s('en'),
          route: Routes.tools,
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_06_tools_ru_dark',
          settings: s('ru', theme: dark),
          route: Routes.tools,
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_07_library_hub_uz',
          settings: s('uz'),
          route: Routes.library,
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_08_search_en',
          settings: s('en'),
          route: Routes.searchWith('Methamphetamine'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_09_search_ru_dark',
          settings: s('ru', theme: dark),
          route: Routes.searchWith('Метамфетамин'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_10_substance_en',
          settings: s('en'),
          route: Routes.libraryEntry('morphine'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 380,
        ),
        (
          name: 'p6_11_substance_uz_dark',
          settings: s('uz', theme: dark),
          route: Routes.libraryEntry('fentanyl'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 1600,
        ),
        (
          name: 'p6_12_method_en',
          settings: s('en'),
          route: Routes.knowledgeEntry('method-gcms'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_13_reagent_ru',
          settings: s('ru'),
          route: Routes.knowledgeEntry('reagent-dragendorff'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_14_rapid_test_uz_dark',
          settings: s('uz', theme: dark),
          route: Routes.knowledgeEntry('scr-fentanyl-test-strips'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_15_research_en',
          settings: s('en'),
          route: Routes.research,
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_16_article_ru',
          settings: s('ru'),
          route: Routes.researchEntry('RS-dc1842852526'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_17_jurisdiction_select_uz',
          settings: s('uz'),
          route: Routes.jurisdictionSelect,
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_18_jurisdiction_gb_en',
          settings: s('en'),
          route: Routes.jurisdiction('GB'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_19_jurisdiction_de_ru_dark',
          settings: s('ru', theme: dark),
          route: Routes.jurisdiction('DE'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_20_jurisdictions_hub_en',
          settings: s('en').copyWith(jurisdictionId: 'GB'),
          route: Routes.jurisdictions,
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_21_ai_en',
          settings: s('en'),
          route: Routes.ai,
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_22_learn_uz',
          settings: s('uz'),
          route: Routes.learn,
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_23_profile_ru_dark',
          settings: s('ru', theme: dark),
          route: Routes.profile,
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_24_disciplines_en',
          settings: s('en'),
          route: Routes.disciplines,
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_25_lod_loq_en',
          settings: s('en'),
          route: Routes.tool('tool.lab.lod_loq'),
          size: std,
          scale: 1,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_26_home_320_x13_ru',
          settings: s('ru'),
          route: Routes.home,
          size: small,
          scale: 1.3,
          owned: true,
          platform: null,
          scroll: 0,
        ),
        (
          name: 'p6_27_jurisdiction_320_x13_uz',
          settings: s('uz'),
          route: Routes.jurisdiction('GB'),
          size: small,
          scale: 1.3,
          owned: true,
          platform: null,
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
