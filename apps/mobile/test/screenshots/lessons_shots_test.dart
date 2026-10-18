@Tags(['screenshots'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/lessons.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/data/lessons/fake_lessons_service.dart';

import '../helpers/pump_app.dart';

/// «Darslar» skrinshotlari — haqiqiy shriftlar. `LESSON_SHOT_DIR` papkasiga PNG.
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

class _G implements LessonScreenGuard {
  @override
  Future<void> secure() async {}
  @override
  Future<void> release() async {}
}

class _A implements ClassScreenAwake {
  @override
  Future<void> enable() async {}
  @override
  Future<void> disable() async {}
}

void main() {
  setUpAll(_loadFonts);
  final dir = Platform.environment['LESSON_SHOT_DIR'] ?? '/tmp/lesson_shots';

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

  Future<void> open(WidgetTester tester, Size size, String path) async {
    final decks = {
      for (final e in sampleLessonDecks.entries)
        e.key: {
          ...e.value,
          'deck_id': e.key == 'demo-toks' ? 'demo-topic' : e.value['deck_id'],
        },
    };
    await pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: UserMode.professional),
      size: size,
      pixelRatio: 1,
      initialLocation: path,
      overrides: [
        classQuizServiceProvider.overrideWithValue(
          FakeClassQuizService(
            FakeClassQuizBackend(teachers: {'t1'}),
            userId: 't1',
            demo: false,
          ),
        ),
        lessonsServiceProvider.overrideWithValue(
          FakeLessonsService(demo: false, decks: decks),
        ),
        lessonScreenGuardProvider.overrideWithValue(_G()),
        classScreenAwakeProvider.overrideWithValue(_A()),
        classLandscapePromptEnabledProvider.overrideWithValue(false),
      ],
    );
  }

  testWidgets('list', (tester) async {
    await open(tester, const Size(390, 844), '/home/teacher/lessons');
    await shot(tester, '1_list_390x844');
  });

  testWidgets('viewer phone', (tester) async {
    await open(tester, const Size(390, 844), '/home/teacher/lessons/demo-toks');
    await tester.tap(find.byKey(const Key('lesson.next')));
    await tester.pumpAndSettle();
    await shot(tester, '2_viewer_phone_390x844');
  });

  testWidgets('projector', (tester) async {
    await open(
      tester,
      const Size(1920, 1080),
      '/home/teacher/lessons/demo-toks',
    );
    await tester.tap(find.byKey(const Key('lesson.projectorButton')));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await shot(tester, '3_projector_1920x1080');
  });

  testWidgets('last slide with quiz', (tester) async {
    await open(tester, const Size(390, 844), '/home/teacher/lessons/demo-toks');
    await tester.tap(find.byKey(const Key('lesson.outlineButton')));
    await tester.pumpAndSettle();
    final n = tester
        .widgetList(
          find.byWidgetPredicate(
            (w) =>
                w.key is ValueKey<String> &&
                (w.key! as ValueKey<String>).value.startsWith(
                  'lesson.outline.',
                ),
          ),
        )
        .length;
    await tester.tap(find.byKey(Key('lesson.outline.${n - 1}')));
    await tester.pumpAndSettle();
    await shot(tester, '4_last_slide_quiz_390x844');
  });
}
