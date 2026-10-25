@Tags(['screenshots'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/assessment.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';

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

final _pack = File('assets/content/assessment/assessment_v1.json')
    .readAsStringSync();

void main() {
  setUpAll(_loadFonts);
  final dir = Platform.environment['ASSESS_SHOT_DIR'] ?? '/tmp/assess_shots';

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
    for (final lang in ['uz', 'ru']) {
      testWidgets('assessment $w $lang', (tester) async {
        await pumpApp(
          tester,
          settings: completedSettings(lang: lang, mode: UserMode.professional),
          size: Size(w, 844),
          pixelRatio: 1,
          initialLocation: '/library/assessment',
          overrides: [
            assessmentLoaderProvider.overrideWithValue(() async => _pack),
          ],
        );
        await shot(tester, 'hub_${lang}_${w.toInt()}');
        await tester.tap(find.byKey(const Key('assessment.spec.sud_tib')));
        await tester.pumpAndSettle();
        await shot(tester, 'spec_oral_${lang}_${w.toInt()}');
        await tester.tap(find.byKey(const Key('assessment.q.sud_tib.c23.001')));
        await tester.pumpAndSettle();
        await shot(tester, 'detail_${lang}_${w.toInt()}');
        await tester.tap(find.byIcon(Icons.arrow_back).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(lang == 'uz' ? 'Testlar' : 'Тесты'));
        await tester.pumpAndSettle();
        await shot(tester, 'spec_tab_${lang}_${w.toInt()}');
      });
    }
  }

  testWidgets('assessment test run + dark', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: UserMode.professional),
      size: const Size(390, 844),
      pixelRatio: 1,
      platformBrightness: Brightness.dark,
      initialLocation: '/library/assessment/sud_kimyo/test',
      overrides: [
        assessmentLoaderProvider.overrideWithValue(() async => _pack),
      ],
    );
    await tester.pumpAndSettle();
    await shot(tester, 'run_q');
    await tester.tap(find.byKey(const Key('assessment.opt.1')));
    await tester.pumpAndSettle();
    await shot(tester, 'run_answered');
  });
}
