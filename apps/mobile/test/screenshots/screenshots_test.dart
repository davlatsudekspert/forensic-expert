@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';

import '../helpers/pump_app.dart';

/// PREVIEW skrinshotlari (haqiqiy Inter shrifti bilan).
///
/// CI’da o‘tkazib yuboriladi (platformaga bog‘liq rasterlash farqlari).
/// Yaratish:
///   flutter test --tags screenshots --run-skipped --update-goldens
/// Natija: `test/screenshots/goldens/*.png` → `docs/screenshots/phase1/`.
Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File(f).readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  await load('SourceSerif4', [
    'assets/fonts/source_serif_4/SourceSerif4-Regular.ttf',
    'assets/fonts/source_serif_4/SourceSerif4-SemiBold.ttf',
    'assets/fonts/source_serif_4/SourceSerif4-Bold.ttf',
  ]);
  await load('Inter', [
    'assets/fonts/inter/Inter-Regular.ttf',
    'assets/fonts/inter/Inter-Medium.ttf',
    'assets/fonts/inter/Inter-SemiBold.ttf',
    'assets/fonts/inter/Inter-Bold.ttf',
  ]);
  await load('JetBrainsMono', [
    'assets/fonts/jetbrains_mono/JetBrainsMono-Regular.ttf',
  ]);
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter';
  await load('MaterialIcons', [
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

void main() {
  setUpAll(_loadFonts);

  final cases = <(String, AppSettings, String?, Size, double)>[
    ('01_language_light', const AppSettings(), null, const Size(390, 844), 1),
    (
      '02_language_dark',
      const AppSettings(themeMode: ThemeMode.dark),
      null,
      const Size(390, 844),
      1,
    ),
    (
      '03_language_320dp_text2x',
      const AppSettings(),
      null,
      const Size(320, 568),
      2,
    ),
    (
      '04_disclaimer_uz',
      const AppSettings(locale: Locale('uz')),
      null,
      const Size(390, 844),
      1,
    ),
    (
      '05_mode_ru',
      const AppSettings(
        locale: Locale('ru'),
        acceptedDisclaimerVersion: currentDisclaimerVersion,
      ),
      null,
      const Size(390, 844),
      1,
    ),
    (
      '06_home_professional_en',
      completedSettings(),
      null,
      const Size(390, 844),
      1,
    ),
    (
      '07_home_dark_uz',
      completedSettings(lang: 'uz', theme: ThemeMode.dark),
      null,
      const Size(390, 844),
      1,
    ),
    (
      '08_home_320dp_text2x_ru',
      completedSettings(lang: 'ru'),
      null,
      const Size(320, 568),
      2,
    ),
    ('09_ai_uz', completedSettings(lang: 'uz'), '/ai', const Size(390, 844), 1),
    ('10_profile_en', completedSettings(), '/profile', const Size(390, 844), 1),
  ];

  for (final (name, settings, route, size, scale) in cases) {
    testWidgets(name, (tester) async {
      await pumpApp(
        tester,
        settings: settings,
        size: size,
        textScale: scale,
        initialLocation: route,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/$name.png'),
      );
    });
  }
}
