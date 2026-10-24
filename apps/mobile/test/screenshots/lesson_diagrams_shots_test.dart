@Tags(['screenshots'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forensic_expert/core/design/theme.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/data/lessons/fake_lessons_service.dart';
import 'package:forensic_expert/domain/lessons/lesson_models.dart';
import 'package:forensic_expert/features/lessons/presentation/lesson_slide_view.dart';

import '../helpers/lesson_diagram_fixtures.dart';

/// «Darslar» v2 diagramma skrinshotlari (har tur: proyektor 1920×1080 va
/// telefon 390×844; demo va limitdagi eng uzun matn). Haqiqiy shriftlar.
/// `LESSON_DIAGRAM_SHOT_DIR` papkasiga PNG.
///   flutter test --tags screenshots --run-skipped \
///     test/screenshots/lesson_diagrams_shots_test.dart
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

void main() {
  setUpAll(_loadFonts);
  final l = lookupAppLocalizations(const Locale('uz'));
  final dir =
      Platform.environment['LESSON_DIAGRAM_SHOT_DIR'] ??
      '/tmp/claude-0/-home-user-forensic-expert/'
          '06d2c950-1e58-56ea-9182-1c3fb48b561e/scratchpad/diagram_shots';

  Future<void> shot(
    WidgetTester tester,
    LessonPage page,
    Size size,
    String name, {
    required bool projector,
    Brightness mode = Brightness.light,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: mode == Brightness.dark
            ? FeThemeBuilder.dark()
            : FeThemeBuilder.light(),
        locale: const Locale('uz'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RepaintBoundary(
          key: key,
          child: Scaffold(
            body: LessonSlideView(
              page: page,
              projector: projector,
              counter: projector ? '5 / 12' : null,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull, reason: name);
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(key),
    );
    await tester.runAsync(() async {
      final img = await boundary.toImage(pixelRatio: 1);
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      Directory(dir).createSync(recursive: true);
      File('$dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  LessonPage pageOf(LessonDeck d, String kind) =>
      buildLessonPages(d, l).firstWhere((p) => p.diagram?.kind.name == kind);

  final demo = LessonDeck.fromJson(sampleLessonDecks['demo-toks']!);
  final max = maxDiagrams();
  LessonDeck maxDeck(String k) => LessonDeck.fromJson({
    'title': 'Max',
    'deck': {
      'slides': [slideWith('Eng uzun matn sinovi', max[k]!)],
    },
  });

  for (final k in diagramKinds) {
    testWidgets('$k demo', (tester) async {
      final p = pageOf(demo, k);
      await shot(
        tester,
        p,
        const Size(1920, 1080),
        '${k}_demo_1920x1080',
        projector: true,
      );
      await shot(
        tester,
        p,
        const Size(390, 844),
        '${k}_demo_390x844',
        projector: false,
      );
      await shot(
        tester,
        p,
        const Size(390, 844),
        '${k}_demo_390x844_dark',
        projector: false,
        mode: Brightness.dark,
      );
    });
    testWidgets('$k max', (tester) async {
      final p = pageOf(maxDeck(k), k);
      await shot(
        tester,
        p,
        const Size(1920, 1080),
        '${k}_max_1920x1080',
        projector: true,
      );
      await shot(
        tester,
        p,
        const Size(390, 844),
        '${k}_max_390x844',
        projector: false,
      );
      await shot(
        tester,
        p,
        const Size(320, 568),
        '${k}_max_320x568',
        projector: false,
      );
    });
  }
}
