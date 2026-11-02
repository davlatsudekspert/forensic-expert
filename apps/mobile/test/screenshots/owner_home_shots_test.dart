@Tags(['screenshots'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forensic_expert/app/dna.dart';
import 'package:forensic_expert/app/equipment.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';

import '../helpers/pump_app.dart';

/// Rejimlar bo‘yicha asosiy ekranlar — haqiqiy shriftlar. `LESSON_SHOT_DIR` papkasiga PNG.
/// Ishga tushirish: flutter test --tags screenshots --run-skipped \
///   test/screenshots/lessons_shots_test.dart
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
  final dir = Platform.environment['OWNER_SHOT_DIR'] ?? '/dev/shm/owner42c';

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

  final dna = File('assets/content/dna/dna_v1.json').readAsStringSync();
  final equip = File('assets/content/equipment/equipment_v1.json')
      .readAsStringSync();
  final cases = <(String, UserMode, String, double)>[
    ('1_mutaxassis_asosiy', UserMode.professional, '/home', 1.0),
    ('2_talaba_asosiy', UserMode.student, '/home', 1.0),
    ('3_profil_shrift', UserMode.professional, '/profile', 1.0),
    ('4_asosiy_juda_katta_shrift', UserMode.professional, '/home', 1.3),
    (
      '5_spektrofotometr',
      UserMode.professional,
      '/home/equipment/item/uv_vis',
      1.0,
    ),
    ('6_gcms', UserMode.professional, '/home/equipment/item/gc_ms', 1.0),
    (
      '8_fenobarbital',
      UserMode.professional,
      '/home/equipment/example/phenobarbital_blood_uv',
      1.0,
    ),
    (
      '7_tropikamid',
      UserMode.professional,
      '/home/equipment/example/tropicamide_uv',
      1.0,
    ),
  ];
  for (final (name, mode, loc, scale) in cases) {
    testWidgets(name, (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(
          lang: 'uz',
          mode: mode,
        ).copyWith(textScale: scale),
        size: const Size(390, 5200),
        pixelRatio: 1,
        initialLocation: loc,
        proEnabled: false,
        overrides: [
          dnaLoaderProvider.overrideWithValue(() async => dna),
          equipmentLoaderProvider.overrideWithValue(() async => equip),
        ],
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        for (final e in find.byType(Image).evaluate()) {
          await precacheImage((e.widget as Image).image, e);
        }
      });
      await tester.pump();
      await shot(tester, name);
    });
  }
}
