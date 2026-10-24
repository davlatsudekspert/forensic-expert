@Tags(['screenshots'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/lessons.dart';
import 'package:forensic_expert/app/professional.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/data/lessons/fake_lessons_service.dart';
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';

import '../helpers/class_groups_world.dart';

/// «Dars oxirida Guruh testi» kadrlari: tanlov oynasi, guruh/mavzu/sozlama,
/// QR + kod, jonli doska (o‘rinlar), qiyin savollar, talaba ismi.
///   GROUP_SHOT_DIR=/tmp/shots flutter test --tags screenshots --run-skipped \
///     test/screenshots/group_lesson_shots_test.dart
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

class _Guard implements LessonScreenGuard {
  @override
  Future<void> secure() async {}
  @override
  Future<void> release() async {}
}

void main() {
  setUpAll(_loadFonts);
  setUp(() {
    floatingNavEnabled = true;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });
  tearDown(() => debugDefaultTargetPlatformOverride = null);
  final dir =
      Platform.environment['GROUP_SHOT_DIR'] ?? '/tmp/group_lesson_shots';

  Future<void> shot(WidgetTester tester, String name) async {
    await frames(tester, 4);
    final view = tester.binding.renderViews.first;
    final layer = view.debugLayer! as OffsetLayer;
    await tester.runAsync(() async {
      final dpr = tester.view.devicePixelRatio;
      final img = await layer.toImage(
        Offset.zero & (view.size * dpr),
        pixelRatio: 1 / dpr * (view.size.width > 1000 ? 1 : 2),
      );
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      Directory(dir).createSync(recursive: true);
      File('$dir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  Future<void> go(WidgetTester tester, ProviderContainer c, String loc) async {
    c.read(routerProvider).go(loc);
    await frames(tester);
  }

  Future<void> scrollTo(WidgetTester tester, Key target) async {
    await tester.scrollUntilVisible(
      find.byKey(target),
      150,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('grp.lesson.list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(find.byKey(target));
    await tester.pumpAndSettle();
  }

  String realTopic(GroupsWorld w) => w.topics
      .firstWhere(
        (t) => t.id.startsWith('4-kurs-davolash') && !t.id.contains('~'),
        orElse: () => w.topics.firstWhere((t) => !t.id.contains('~')),
      )
      .id;

  Future<ProviderContainer> openLesson(
    WidgetTester tester,
    GroupsWorld w, {
    required Size size,
    double textScale = 1.0,
  }) {
    final topic = realTopic(w);
    final decks = {
      for (final e in sampleLessonDecks.entries)
        e.key: {...e.value, 'deck_id': topic},
    };
    return w.open(
      tester,
      uid: 'teacher',
      size: size,
      textScale: textScale,
      location: Routes.lesson(sampleLessonDecks.keys.first),
      extra: [
        lessonsServiceProvider.overrideWithValue(
          FakeLessonsService(demo: false, decks: decks),
        ),
        lessonScreenGuardProvider.overrideWithValue(_Guard()),
      ],
    );
  }

  for (final (size, scale, tag) in [
    (const Size(390, 844), 1.0, '390x844'),
    (const Size(320, 568), 1.0, '320x568'),
  ]) {
    testWidgets('dars → guruh testi $tag', (tester) async {
      final w = GroupsWorld.real();
      final c = await openLesson(tester, w, size: size, textScale: scale);
      await tester.tap(find.byKey(const Key('lesson.outlineButton')));
      await tester.pumpAndSettle();
      // Oxirgi slayd: eng katta raqamli bo‘lim.
      var last = 0;
      while (find
          .byKey(Key('lesson.outline.${last + 1}'))
          .evaluate()
          .isNotEmpty) {
        last++;
      }
      await tester.tap(find.byKey(Key('lesson.outline.$last')));
      await tester.pumpAndSettle();
      if (find.byKey(const Key('lesson.quizStart')).evaluate().isNotEmpty) {
        await tester.ensureVisible(find.byKey(const Key('lesson.quizStart')));
        await tester.tap(find.byKey(const Key('lesson.quizStart')));
        await frames(tester);
        await shot(tester, 'l01_tanlov_$tag');
        await tester.tap(find.byKey(const Key('grp.choice.group')));
        await frames(tester);
      } else {
        // Juda past ekranda oxirgi slayddagi tugma ko‘rinmasa — to‘g‘ridan-to‘g‘ri.
        await go(tester, c, Routes.groupLessonTest(realTopic(w)));
      }
      await shot(tester, 'l02_guruh_yoq_yaratish_$tag');
      await tester.enterText(
        find.byKey(const Key('grp.lesson.nameField')),
        '4-kurs, 2-guruh',
      );
      await tester.tap(find.byKey(const Key('grp.lesson.createGroup')));
      await frames(tester);
      await shot(tester, 'l03_guruh_tanlandi_mavzu_avto_$tag');
      await scrollTo(tester, const Key('grp.count.20'));
      await shot(tester, 'l04_soni_vaqt_$tag');
      await scrollTo(tester, const Key('grp.lesson.start'));
      await shot(tester, 'l05_muddat_boshlash_$tag');
      await tester.tap(find.byKey(const Key('grp.lesson.start')));
      await frames(tester);
      await shot(tester, 'l06_qr_va_kod_$tag');
      expect(tester.takeException(), isNull);
      c.read(routerProvider);
      await closeApp(tester);
    });
  }

  testWidgets('kichik mavzu: «Hammasi · N» chipi', (tester) async {
    final w = GroupsWorld();
    w.backend.create('teacher', 'Guruh');
    final decks = {
      for (final e in sampleLessonDecks.entries)
        e.key: {...e.value, 'deck_id': 'tox-small'},
    };
    final c = await w.open(
      tester,
      uid: 'teacher',
      location: Routes.lesson(sampleLessonDecks.keys.first),
      extra: [
        lessonsServiceProvider.overrideWithValue(
          FakeLessonsService(demo: false, decks: decks),
        ),
        lessonScreenGuardProvider.overrideWithValue(_Guard()),
      ],
    );
    await go(tester, c, Routes.groupLessonTest('tox-small'));
    await scrollTo(tester, const Key('grp.count.all'));
    await shot(tester, 'l07_kichik_mavzu_hammasi_390x844');
    await closeApp(tester);
  });

  testWidgets('talaba: QR → ism profildan avtomatik', (tester) async {
    final w = GroupsWorld.real();
    final g = w.backend.create('teacher', '4-kurs, 2-guruh').value!;
    final a = (await w.backend.createAssignment(
      'teacher',
      g.id,
      AssignmentDraft(
        topicId: realTopic(w),
        questionCount: 10,
        timeLimitMin: 15,
        dueAt: w.now.add(const Duration(days: 1)),
      ),
    )).value!;
    final c = await w.open(
      tester,
      uid: 'stu',
      extra: [
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
    await go(tester, c, '/g/${g.code}?a=${a.id}');
    await shot(tester, 'j01_ism_avtomatik_390x844');
    await closeApp(tester);
  });

  for (final (size, tag) in [
    (const Size(1920, 1080), '1920x1080'),
    (const Size(390, 844), '390x844'),
    (const Size(320, 568), '320x568'),
  ]) {
    testWidgets('jonli doska va qiyin savollar $tag', (tester) async {
      final w = GroupsWorld.real();
      final g = w.backend.create('teacher', '4-kurs, 2-guruh').value!;
      const names = [
        'Aziza',
        'Bobur',
        'Charos',
        'Dilshod',
        'Eldor',
        'Feruza',
        'G‘ayrat',
        'Hilola',
        'Ibrohim',
        'Jasur',
        'Kamola',
        'Lola',
      ];
      for (final (i, n) in names.indexed) {
        w.backend.join('u$i', code: g.code!, nickname: n);
      }
      final a = (await w.backend.createAssignment(
        'teacher',
        g.id,
        AssignmentDraft(
          topicId: realTopic(w),
          questionCount: 15,
          timeLimitMin: 15,
          dueAt: w.now.add(const Duration(days: 1)),
          variantMode: true,
        ),
      )).value!;
      final key = {
        for (final p in w.backend.preview('teacher', a.id).value!.pool)
          p.id: p.correctIndex,
      };
      final t0 = w.now;
      final opened = {
        for (var i = 0; i < 10; i++) i: w.backend.open('u$i', a.id).value!,
      };
      // To‘g‘ri soni va sarflangan daqiqa (har xil).
      const right = [14, 12, 15, 9, 12, 13, 7, 11, 10, 8];
      const mins = [9, 7, 12, 14, 11, 8, 13, 10, 6, 14];
      final order = List.generate(10, (i) => i)
        ..sort((x, y) => mins[x].compareTo(mins[y]));
      for (final i in order) {
        w.now = t0.add(Duration(minutes: mins[i], seconds: i * 7));
        final qs = opened[i]!.questions;
        w.backend.submit('u$i', a.id, {
          for (final (k, q) in qs.indexed)
            q.id: k < 15 - right[i] ? (key[q.id]! + 1) % 4 : key[q.id]!,
        });
      }
      w.now = t0.add(const Duration(minutes: 15));
      w.backend.open('u10', a.id);
      final c = await w.open(
        tester,
        uid: 'teacher',
        size: size,
        iphone: size.width < 600,
        location: Routes.groupBoard(g.id, a.id),
      );
      await frames(tester, 6);
      await shot(tester, 'b01_doska_ochiq_$tag');
      await tester.tap(find.byKey(const Key('grp.board.close')));
      await frames(tester);
      await shot(tester, 'b02_yopish_tasdiq_$tag');
      await tester.tap(find.byKey(const Key('grp.closeYes')));
      await frames(tester, 10);
      await shot(tester, 'b03_doska_yopilgan_qiyin_savollar_$tag');
      await tester.ensureVisible(find.byKey(const Key('grp.hardest.open')));
      await tester.tap(find.byKey(const Key('grp.hardest.open')));
      await frames(tester, 8);
      await shot(tester, 'd01_muhokama_$tag');
      expect(tester.takeException(), isNull);
      if (size.width < 600) {
        await go(tester, c, Routes.groupAssignment(g.id, a.id));
        await shot(tester, 'p01_ustoz_paneli_$tag');
      }
      await closeApp(tester);
    });
  }
}
