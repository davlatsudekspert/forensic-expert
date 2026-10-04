import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/data/content/content_library_repository.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// PHASE 2 vizual regressiya to‘plami (CI’da ishlaydi).
///
/// To‘liq kombinatorika (10 ekran × 3 til × 3 mavzu × 2 o‘lcham = 180)
/// o‘rniga **reprezentativ matritsa**: har bir ekran kamida bir marta,
/// har bir til, har bir mavzu (Light / Dark / High contrast) va 320 dp +
/// katta shrift bir necha marta qamraladi.
///
/// Yangilash: `flutter test test/golden --update-goldens`
/// Ko‘rish uchun nusxa: `docs/screenshots/phase2/`.
void main() {
  const std = Size(390, 844);
  const small = Size(320, 640);

  AppSettings s(
    String lang, {
    ThemeMode theme = ThemeMode.light,
    bool hc = false,
    UserMode mode = UserMode.professional,
  }) => completedSettings(
    lang: lang,
    theme: theme,
    mode: mode,
  ).copyWith(contrast: hc ? ContrastPreference.high : null);

  const dark = ThemeMode.dark;
  final cases = <(String, AppSettings, String?, Size, double)>[
    // Til tanlash va onboarding.
    ('language_en_light', const AppSettings(), null, std, 1),
    (
      'language_dark_320_x2',
      const AppSettings(themeMode: ThemeMode.dark),
      null,
      small,
      2,
    ),
    (
      'onboarding_disclaimer_uz',
      const AppSettings(locale: Locale('uz')),
      null,
      std,
      1,
    ),
    (
      'onboarding_mode_ru_dark',
      const AppSettings(
        locale: Locale('ru'),
        themeMode: ThemeMode.dark,
        acceptedDisclaimerVersion: currentDisclaimerVersion,
      ),
      null,
      std,
      1,
    ),
    // Home: Professional va Student farqi.
    ('home_pro_en_light', s('en'), null, std, 1),
    ('home_pro_ru_dark', s('ru', theme: dark), null, std, 1),
    ('home_student_uz_light', s('uz', mode: UserMode.student), null, std, 1),
    ('home_pro_ru_320_x2', s('ru'), null, small, 2),
    // Tools.
    ('tools_en_light', s('en'), Routes.tools, std, 1),
    ('tools_uz_dark_hc', s('uz', theme: dark, hc: true), Routes.tools, std, 1),
    ('tool_dilution_en', s('en'), Routes.tool('tool.lab.dilution'), std, 1),
    // Library.
    ('library_ru_light', s('ru'), Routes.library, std, 1),
    (
      'entry_substance_en',
      s('en'),
      Routes.libraryEntry('TEST-SUB-ETOH'),
      std,
      1,
    ),
    (
      'entry_substance_uz_dark_320',
      s('uz', theme: dark),
      Routes.libraryEntry('TEST-SUB-ETOH'),
      small,
      1,
    ),
    // Search.
    ('search_results_en', s('en'), Routes.searchWith('Etanol'), std, 1),
    ('search_noresults_ru', s('ru'), Routes.searchWith('zzzzqqq'), std, 1),
    // AI.
    ('ai_en_light', s('en'), Routes.ai, std, 1),
    ('ai_uz_dark', s('uz', theme: dark), Routes.ai, std, 1),
    // Student.
    ('learn_en', s('en', mode: UserMode.student), Routes.learn, std, 1),
    (
      'quiz_ru_dark',
      s('ru', theme: dark, mode: UserMode.student),
      Routes.quiz,
      std,
      1,
    ),
    // Profile.
    ('profile_en_light', s('en'), Routes.profile, std, 1),
    ('profile_uz_hc', s('uz', hc: true), Routes.profile, std, 1),
    ('jurisdiction_en', s('en'), Routes.profileJurisdiction, std, 1),
    // Lifetime purchase (store ulanmagan → reference narx, tugma o‘chiq).
    ('purchase_en_light', s('en'), Routes.purchase, std, 1),
    ('purchase_uz_dark', s('uz', theme: dark), Routes.purchase, std, 1),
    (
      'purchase_ru_dark_320_x13',
      s('ru', theme: dark),
      Routes.purchase,
      small,
      1.3,
    ),
  ];

  for (final (name, settings, route, size, scale) in cases) {
    testWidgets(name, (tester) async {
      await pumpApp(
        tester,
        settings: settings,
        size: size,
        textScale: scale,
        initialLocation: route,
        pixelRatio: 1.5,
      );
      // Qidiruv debounce’i va animatsiyalar tugashi.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/$name.png'),
      );
    });
  }

  // PHASE 3: haqiqiy pilot paket (TEST fixture’siz).
  group('pilot kontent', () {
    late ContentLibraryRepository repo;
    setUpAll(() async => repo = await loadPilotLibrary());

    final pilot = <(String, AppSettings, String, bool, Size)>[
      (
        'pilot_entry_free_en',
        s('en'),
        Routes.libraryEntry('methanol'),
        false,
        std,
      ),
      (
        'pilot_entry_locked_ru_dark',
        s('ru', theme: dark),
        Routes.libraryEntry('morphine'),
        false,
        std,
      ),
      (
        'pilot_entry_lifetime_uz',
        s('uz'),
        Routes.libraryEntry('morphine'),
        true,
        std,
      ),
      ('pilot_library_en_320', s('en'), Routes.library, false, small),
    ];
    for (final (name, settings, route, owned, size) in pilot) {
      testWidgets(name, (tester) async {
        await pumpApp(
          tester,
          settings: settings,
          size: size,
          initialLocation: route,
          pixelRatio: 1.5,
          testFixtures: false,
          overrides: [
            libraryRepositoryProvider.overrideWithValue(repo),
            entitlementServiceProvider.overrideWithValue(
              FakeStore(owned: owned),
            ),
          ],
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/$name.png'),
        );
      });
    }
  });
}
