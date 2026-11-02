@Tags(['screenshots'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/equipment.dart';
import 'package:forensic_expert/app/routes.dart';

import 'package:forensic_expert/core/settings/app_settings.dart';

import '../helpers/pump_app.dart';

/// SPE kartochkasi — haqiqiy shriftlar, PNG.
/// flutter test --tags screenshots test/screenshots/spe_shots_test.dart
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

final _pack = File('assets/content/equipment/equipment_v1.json')
    .readAsStringSync();

void main() {
  setUpAll(_loadFonts);
  final dir = Platform.environment['ASSESS_SHOT_DIR'] ?? '/tmp/spe_shots';

  testWidgets('spe card', (tester) async {
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: UserMode.professional),
      size: const Size(390, 2600),
      pixelRatio: 1,
      initialLocation:
          Platform.environment['SPE_ROUTE'] ?? Routes.equipmentItem('spe'),
      overrides: [equipmentLoaderProvider.overrideWithValue(() async => _pack)],
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(MaterialApp));
      await precacheImage(
        const AssetImage('assets/images/instruments/spe.webp'),
        ctx,
      );
    });
    await tester.pumpAndSettle();
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
      File('$dir/${Platform.environment['SPE_NAME'] ?? 'spe_card'}.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  });
}
