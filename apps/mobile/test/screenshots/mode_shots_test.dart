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
  final dir = Platform.environment['MODE_SHOT_DIR'] ?? '/tmp/mode_shots';

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

  final screens = {
    'home': '/home',
    'learn': '/home/learn',
    'module_tox': '/home/module/toxicology',
    'discipline_tox': '/home/disciplines/forensic_toxicology',
    'lessons': '/home/teacher/lessons',
    'tools': '/tools',
    'profile': '/profile',
    'pro': '/profile/pro',
  };
  for (final mode in UserMode.values) {
    for (final e in screens.entries) {
      testWidgets('${mode.name} ${e.key}', (tester) async {
        final base = sampleLessonDecks.values.first;
        final baseDeck = base['deck']! as Map<String, Object?>;
        final baseSlides = (baseDeck['slides']! as List).first;
        Map<String, Object?> deck(String id, String course) => {
          ...base,
          'topic_id': id,
          'title': 'Dars $id: $course mavzusi',
          'course': course,
          'deck_id': '$id-deck',
          'deck': {
            ...baseDeck,
            'slides': [for (var i = 0; i < 42; i++) baseSlides],
          },
        };
        final decks = {
          for (var i = 1; i <= 5; i++)
            'toks-0$i': deck('toks-0$i', 'Toksikologik kimyo'),
          for (var i = 1; i <= 3; i++)
            'instr-0$i-x': deck('instr-0$i-x', 'Apparatlar bilan ishlash'),
          'bio-01': deck('bio-01', 'Bioetika'),
        };
        await pumpApp(
          tester,
          settings: completedSettings(lang: 'uz', mode: mode),
          size: const Size(390, 1900),
          pixelRatio: 1,
          initialLocation: e.value,
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
          ],
        );
        await tester.pumpAndSettle();
        await shot(tester, '${mode.name}_${e.key}');
      });
    }
  }
}
