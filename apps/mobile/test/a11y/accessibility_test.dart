import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';

import '../helpers/pump_app.dart';
import '../helpers/screens.dart';

/// Flutter accessibility guideline’lari: tap target (Android 48dp, iOS 44pt),
/// tugmalarda label, matn kontrasti — light va dark mavzuda.
void main() {
  Future<void> checkGuidelines(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    group('${theme.name} mavzu', () {
      for (final route in onboardingScreens) {
        testWidgets('onboarding $route', (tester) async {
          final handle = tester.ensureSemantics();
          final settings = switch (route) {
            '/onboarding/language' => AppSettings(themeMode: theme),
            '/onboarding/disclaimer' => AppSettings(
              locale: const Locale('en'),
              themeMode: theme,
            ),
            _ => AppSettings(
              locale: const Locale('en'),
              themeMode: theme,
              acceptedDisclaimerVersion: currentDisclaimerVersion,
            ),
          };
          await pumpApp(tester, settings: settings);
          await checkGuidelines(tester);
          handle.dispose();
        });
      }
      for (final route in shellScreens) {
        testWidgets(route, (tester) async {
          final handle = tester.ensureSemantics();
          await pumpApp(
            tester,
            settings: completedSettings(theme: theme),
            initialLocation: route,
          );
          await checkGuidelines(tester);
          handle.dispose();
        });
      }
    });
  }

  // PHASE 5 ekranlari — haqiqiy pilot paket (rasm, research, gistologiya).
  group('PHASE 5 · pilot kontent', () {
    late PilotContent pilot;
    setUpAll(() async => pilot = await loadPilotContent());
    final routes = [
      Routes.libraryEntry('morphine'),
      Routes.library,
      Routes.research,
      Routes.researchEntry('RS-582d32d8a823'),
      Routes.image('IMG-EXT-pmc6445230-ienz_a_1333987_f0004_b'),
      Routes.histology,
      Routes.knowledgeEntry('his-mi-early'),
      Routes.knowledgeEntry('reagent-dragendorff'),
      Routes.knowledgeEntry('scr-fentanyl-test-strips'),
    ];
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      for (final route in routes) {
        testWidgets('${theme.name} $route', (tester) async {
          final handle = tester.ensureSemantics();
          await pumpApp(
            tester,
            settings: completedSettings(theme: theme),
            initialLocation: route,
            testFixtures: false,
            overrides: [
              ...pilot.overrides,
              entitlementServiceProvider.overrideWithValue(
                FakeStore(owned: true),
              ),
            ],
          );
          await settleImages(tester);
          await checkGuidelines(tester);
          handle.dispose();
        });
      }
    }
  });

  // Yuqori kontrast (light va dark): tap target, label va kontrast.
  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    group('${theme.name} · high contrast', () {
      for (final route in shellScreens) {
        testWidgets(route, (tester) async {
          final handle = tester.ensureSemantics();
          await pumpApp(
            tester,
            settings: completedSettings(theme: theme)
                .copyWith(contrast: ContrastPreference.high),
            initialLocation: route,
          );
          await checkGuidelines(tester);
          handle.dispose();
        });
      }
    });
  }

  testWidgets(
    'til variantlari ekran o‘quvchisi uchun tanlangan holatni beradi',
    (tester) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('language.option.ru')));
      await tester.pumpAndSettle();
      final ru = tester.getSemantics(
        find.byKey(const Key('language.option.ru')),
      );
      final en = tester.getSemantics(
        find.byKey(const Key('language.option.en')),
      );
      expect(ru.flagsCollection.isSelected.toBoolOrNull(), isTrue);
      expect(en.flagsCollection.isSelected.toBoolOrNull(), isFalse);
      expect(ru.label, 'Русский');
      handle.dispose();
    },
  );

  testWidgets('brend sarlavhasi header sifatida belgilangan', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester);
    expect(find.bySemanticsLabel(RegExp('FORENSIC EXPERT')), findsWidgets);
    handle.dispose();
  });
}
