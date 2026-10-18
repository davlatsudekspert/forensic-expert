@Tags(['screenshots'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../widget/class_quiz_bigscreen_test.dart' show openRunningClassHost;

/// «Sinfda test» proyektor ko‘rinishi (ishlayotgan savol) — haqiqiy shriftlar.
/// `CLASS_SHOT_DIR` ko‘rsatilgan papkaga PNG yozadi.
/// Ishga tushirish: flutter test --tags screenshots --run-skipped \
///   test/screenshots/class_host_bigscreen_test.dart
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
  final dir = Platform.environment['CLASS_SHOT_DIR'] ?? '/tmp/class_shots';

  for (final (name, size) in [
    ('phone_390x844', const Size(390, 844)),
    ('hd_1280x720', const Size(1280, 720)),
    ('fullhd_1920x1080', const Size(1920, 1080)),
  ]) {
    testWidgets('class host $name', (tester) async {
      await openRunningClassHost(tester, size: size);
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
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  }
}
