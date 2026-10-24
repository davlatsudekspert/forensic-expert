@Tags(['screenshots'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/professional.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';

import '../features/class_quiz/class_lesson_quiz_test.dart'
    show World, closeApp, frames, lessonTopic, openAt, reveal;
import '../helpers/class_groups_world.dart' show TestAuth, signedInAs;

/// «Har darsdan keyin test» ekranlari — haqiqiy shriftlar bilan PNG.
/// `CLASS_SHOT_DIR` papkasiga yozadi. Ishga tushirish:
///   flutter test --tags screenshots --run-skipped \
///     test/screenshots/class_lesson_quiz_shots_test.dart
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

Future<void> _shot(WidgetTester tester, String dir, String name) async {
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

void main() {
  setUpAll(_loadFonts);
  final dir = Platform.environment['CLASS_SHOT_DIR'] ?? '/tmp/quiz_ui_shots';
  const sizes = [
    ('390x844', Size(390, 844)),
    ('320x568', Size(320, 568)),
    ('1920x1080', Size(1920, 1080)),
  ];

  for (final (tag, size) in sizes) {
    testWidgets('savol soni chiplari (11 ta savol) $tag', (tester) async {
      final w = World(topics: [lessonTopic('lesson-a', 11)]);
      await openAt(
        tester,
        svc: w.teacher,
        location: Routes.classNewFor('lesson-a'),
        size: size,
      );
      await reveal(tester, const Key('class.questionCount'));
      await _shot(tester, dir, 'create_chips_11q_$tag');
      await closeApp(tester);
    });

    testWidgets('muhokama varaqasi $tag', (tester) async {
      final w = World();
      final s = await w.finishedSession();
      await openAt(
        tester,
        svc: w.teacher,
        location: Routes.classHost(s.id),
        size: size,
      );
      await _shot(tester, dir, 'results_$tag');
      final d = (await w.teacher.dashboard(s.id)).value!;
      final key = Key('class.hardest.${d.hardest.first.index}');
      await reveal(tester, key);
      await tester.tap(find.byKey(key));
      await frames(tester);
      await _shot(tester, dir, 'discussion_$tag');
      await closeApp(tester);
    });
  }

  testWidgets('kirgan talaba: laqab avtomatik 390x844', (tester) async {
    final w = World();
    await openAt(
      tester,
      svc: FakeClassQuizService(w.backend, userId: 'stu', demo: false),
      location: Routes.classJoin,
      extra: [
        authStateProvider.overrideWith(() => TestAuth(signedInAs('stu'))),
        initialProfileProvider.overrideWithValue(
          const LocalUserProfile(
            student: StudentProfile(
              fullName: 'Dilnoza Karimova',
              country: 'UZ',
            ),
          ),
        ),
      ],
    );
    await _shot(tester, dir, 'join_autonick_390x844');
    await closeApp(tester);
  });
}
