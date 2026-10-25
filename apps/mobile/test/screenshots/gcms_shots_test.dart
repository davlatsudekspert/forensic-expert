@Tags(['screenshots'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/instruments.dart';

import '../helpers/pump_app.dart';

/// «Bilim va malakani baholash» ekranlari — haqiqiy shriftlar, PNG.
/// flutter test --tags screenshots test/screenshots/assessment_shots_test.dart
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
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter';
  await load('MaterialIcons', [
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

final _dirG = 'assets/content/instruments/gc_ms';
final _parts = File('$_dirG/gc_ms_parts_3lang.json').readAsStringSync();
final _card = File('$_dirG/gc_ms_catalog_card_and_sources.json')
    .readAsStringSync();

void main() {
  setUpAll(_loadFonts);
  final dir = Platform.environment['GCMS_SHOT_DIR'] ?? '/tmp/gcms_shots';

  Future<void> shot(WidgetTester tester, String name) async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find
          .descendant(
            of: find.byType(MaterialApp),
            matching: find.byType(RepaintBoundary),
          )
          .first,
    );
    await tester.runAsync(() async {
      final img = await boundary.toImage(pixelRatio: 1);
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      Directory(dir).createSync(recursive: true);
      File('$dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  for (final w in [390.0, 320.0]) {
    for (final dark in [false, true]) {
      for (final lang in ['uz', 'ru', 'en']) {
        testWidgets('gcms $w $dark $lang', (tester) async {
          await pumpApp(
            tester,
            settings: completedSettings(
              lang: lang,
              theme: dark ? ThemeMode.dark : ThemeMode.light,
            ),
            size: Size(w, 1500),
            pixelRatio: 1,
            platformBrightness: dark ? Brightness.dark : Brightness.light,
            initialLocation: '/tools/gc-ms',
            overrides: [
              gcMsLoaderProvider.overrideWithValue(() async => (_parts, _card)),
            ],
          );
          await tester.tap(find.byType(ExpansionTile));
          await tester.pumpAndSettle();
          await shot(tester, '${lang}_${dark ? 'dark' : 'light'}_${w.toInt()}');
        });
      }
    }
  }
}
