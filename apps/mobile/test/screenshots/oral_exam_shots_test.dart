@Tags(['screenshots'])
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/assessment.dart';
import 'package:forensic_expert/app/routes.dart';

import 'package:forensic_expert/core/settings/app_settings.dart';

import '../helpers/pump_app.dart';

/// Og‘zaki imtihon ekranlari — haqiqiy shriftlar, PNG.
/// flutter test --tags screenshots test/screenshots/oral_exam_shots_test.dart
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

final _oral = File('assets/content/assessment/oral_sud_kimyo.json')
    .readAsStringSync();

void main() {
  setUpAll(_loadFonts);
  final dir = Platform.environment['ASSESS_SHOT_DIR'] ?? '/tmp/oral_shots';

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
    testWidgets('oral exam $w', (tester) async {
      final c = await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz', mode: UserMode.professional),
        size: Size(w, 1100),
        pixelRatio: 1,
        initialLocation: Routes.assessmentExam('sud_kimyo', 'c23'),
        overrides: [
          assessmentLoaderProvider.overrideWithValue(() async => _pack),
          oralLoaderProvider.overrideWithValue((id) async => _oral),
          oralExamRandomProvider.overrideWithValue(math.Random(3)),
        ],
      );
      await tester.pumpAndSettle();
      await shot(tester, 'start_${w.toInt()}');
      await tester.tap(find.byKey(const Key('oral.draw')));
      await tester.pumpAndSettle();
      final n = c.read(oralExamProvider.notifier);
      n.setScore(0, 18);
      n.setScore(1, 12);
      await tester.pumpAndSettle();
      await shot(tester, 'ticket_${w.toInt()}');
    });
  }
}
