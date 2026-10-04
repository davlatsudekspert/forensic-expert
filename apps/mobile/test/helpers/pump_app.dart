import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/app.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/settings/settings_controller.dart';
import 'package:forensic_expert/core/settings/settings_repository.dart';
import 'package:forensic_expert/data/local/content_store.dart';

/// Onboarding tugagan foydalanuvchi sozlamalari.
AppSettings completedSettings({
  String lang = 'en',
  ThemeMode theme = ThemeMode.light,
  UserMode mode = UserMode.professional,
}) => AppSettings(
  locale: Locale(lang),
  themeMode: theme,
  userMode: mode,
  acceptedDisclaimerVersion: currentDisclaimerVersion,
);

/// Ekran o‘lchami (dp) va matn masshtabi bilan ilovani ishga tushiradi.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  AppSettings settings = const AppSettings(),
  InMemorySettingsRepository? repository,
  Size size = const Size(390, 844),
  double textScale = 1.0,
  Brightness platformBrightness = Brightness.light,
  String? initialLocation,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  tester.platformDispatcher.platformBrightnessTestValue = platformBrightness;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);

  final repo = repository ?? InMemorySettingsRepository(settings);
  final container = ProviderContainer(
    overrides: [
      initialSettingsProvider.overrideWithValue(settings),
      settingsRepositoryProvider.overrideWithValue(repo),
      contentStoreProvider.overrideWithValue(const FakeContentStore()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const ForensicExpertApp(),
    ),
  );
  await tester.pumpAndSettle();
  if (initialLocation != null) {
    container.read(routerProvider).go(initialLocation);
    await tester.pumpAndSettle();
  }
  return container;
}
