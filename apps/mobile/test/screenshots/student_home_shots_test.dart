@Tags(['screenshots'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forensic_expert/app/dna.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';

import '../helpers/home_desk_world.dart';

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

/// Talaba bosh sahifasi «Mening akademiyam» — haqiqiy shrift va rasmlar.
/// Papka: `STUDENT_SHOT_DIR`. Ishga tushirish:
///   flutter test --tags screenshots --run-skipped \
///     test/screenshots/student_home_shots_test.dart
void main() {
  setUpAll(_loadFonts);
  final dir = Platform.environment['STUDENT_SHOT_DIR'] ?? '/dev/shm/student';

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
      final img = await boundary.toImage(pixelRatio: 2);
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      Directory(dir).createSync(recursive: true);
      File('$dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  final dna = File('assets/content/dna/dna_v1.json').readAsStringSync();
  final catalog = deskCatalog([
    for (var i = 1; i <= 4; i++) deskQuestionItem(i),
  ]);

  for (final (name, w, theme) in [
    ('TALABA_LIGHT_390', 390.0, ThemeMode.light),
    ('TALABA_DARK_390', 390.0, ThemeMode.dark),
    ('TALABA_LIGHT_360', 360.0, ThemeMode.light),
    ('TALABA_DARK_360', 360.0, ThemeMode.dark),
  ]) {
    testWidgets(name, (tester) async {
      await pumpHome(
        tester,
        mode: UserMode.student,
        size: Size(w, 2300),
        theme: theme,
        catalog: catalog,
        extra: [dnaLoaderProvider.overrideWithValue(() async => dna)],
      );
      await tester.runAsync(() async {
        for (final e in find.byType(Image).evaluate()) {
          await precacheImage((e.widget as Image).image, e);
        }
      });
      await tester.pumpAndSettle();
      await shot(tester, name);
    });
  }
}
