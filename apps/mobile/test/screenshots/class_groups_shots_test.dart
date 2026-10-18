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
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/data/lessons/fake_lessons_service.dart';
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';

import '../helpers/class_groups_world.dart';
import '../helpers/pump_app.dart' show completedSettings;

/// «Ustoz–talaba testi» kadrlari — ilovadagi HAQIQIY savollar banki,
/// haqiqiy shriftlar, iPhone 390×844 (notch), kichik ekran 360×640 (1.3x)
/// va katta ekran 1280×720. Papka: `GROUP_SHOT_DIR`.
///   GROUP_SHOT_DIR=/tmp/shots flutter test --tags screenshots --run-skipped \
///     test/screenshots/class_groups_shots_test.dart
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
  final dir = Platform.environment['GROUP_SHOT_DIR'] ?? '/tmp/group_shots';

  Future<void> shot(WidgetTester tester, String name) async {
    await frames(tester, 4);
    // Butun ekran (dialog va pastki oynalar ham): ildiz qatlami.
    final view = tester.binding.renderViews.first;
    final layer = view.debugLayer! as OffsetLayer;
    await tester.runAsync(() async {
      final dpr = tester.view.devicePixelRatio;
      // Ildiz qatlami fizik piksellarda: logik o‘lcham × 2.
      final img = await layer.toImage(
        Offset.zero & (view.size * dpr),
        pixelRatio: 2 / dpr,
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

  Future<void> scrollTo(WidgetTester tester, Key list, Key target) async {
    await tester.scrollUntilVisible(
      find.byKey(target),
      150,
      scrollable: find
          .descendant(of: find.byKey(list), matching: find.byType(Scrollable))
          .first,
    );
    await tester.ensureVisible(find.byKey(target));
    await tester.pumpAndSettle();
  }

  // Haqiqiy bankdagi «Sud tibbiyoti · 4-kurs, davolash ishi» birinchi mavzusi.
  String realTopic(GroupsWorld w) => w.topics
      .firstWhere(
        (t) => t.id.startsWith('4-kurs-davolash') && !t.id.contains('~'),
        orElse: () => w.topics.firstWhere((t) => !t.id.contains('~')),
      )
      .id;

  testWidgets('ustoz: guruh → mavzu testi → QR → jonli → yopish', (
    tester,
  ) async {
    final w = GroupsWorld.real();
    var c = await w.open(tester, uid: 'teacher', location: Routes.groups);
    await shot(tester, 't01_guruhlar_bosh');
    await tester.tap(find.byKey(const Key('grp.createButton')));
    await frames(tester);
    await tester.enterText(
      find.byKey(const Key('grp.nameField')),
      '4-kurs, 2-guruh',
    );
    await shot(tester, 't02_guruh_yaratish');
    await tester.tap(find.byKey(const Key('grp.createSubmit')));
    await frames(tester);
    final g = w.backend.list('teacher').value!.teaching.first;
    for (final n in ['G’ayrat', 'Oʻtkir', 'Lola', 'Bobur', 'Dilnoza']) {
      w.backend.join('u-$n', code: g.code!, nickname: n);
    }
    await go(tester, c, Routes.groups);
    await go(tester, c, Routes.group(g.id));
    await shot(tester, 't03_guruh_sahifasi_qr_kod');
    await tester.tap(find.byKey(const Key('grp.assignButton')));
    await frames(tester);
    await shot(tester, 't04_mavzu_tanlash');
    final topic = realTopic(w);
    await scrollTo(
      tester,
      const Key('grp.assignList'),
      Key('grp.topic.$topic'),
    );
    await tester.tap(find.byKey(Key('grp.topic.$topic')));
    await frames(tester);
    await shot(tester, 't05_soni_va_vaqt_chegarasi');
    await scrollTo(
      tester,
      const Key('grp.assignList'),
      const Key('grp.count.20'),
    );
    await tester.tap(find.byKey(const Key('grp.count.20')));
    await frames(tester);
    await scrollTo(
      tester,
      const Key('grp.assignList'),
      const Key('grp.variantNote'),
    );
    await shot(tester, 't06_ochiq_turish_variant_ochiq_sababi');
    await scrollTo(
      tester,
      const Key('grp.assignList'),
      const Key('grp.count.custom'),
    );
    await tester.tap(find.byKey(const Key('grp.count.custom')));
    await frames(tester);
    await tester.enterText(find.byKey(const Key('grp.customField')), '12');
    await shot(tester, 't07_boshqa_son');
    await tester.tap(find.byKey(const Key('grp.customOk')));
    await frames(tester);
    await scrollTo(
      tester,
      const Key('grp.assignList'),
      const Key('grp.assignSubmit'),
    );
    await shot(tester, 't08_javoblar_qachon_yuborish');
    await tester.tap(find.byKey(const Key('grp.assignSubmit')));
    await frames(tester);
    final a = w.backend.detail('teacher', g.id).value!.assignments.first;
    await shot(tester, 't09_test_qr_jonli_qoshildi');
    final key = {
      for (final p in w.backend.preview('teacher', a.id).value!.pool)
        p.id: p.correctIndex,
    };
    void solve(String u, int right) {
      final qs = w.backend.open(u, a.id).value!.questions;
      w.backend.submit(u, a.id, {
        for (final (i, q) in qs.indexed)
          q.id: i < right ? key[q.id]! : (key[q.id]! + 1) % 4,
      });
    }

    solve('u-G’ayrat', 11);
    solve('u-Lola', 8);
    w.backend.open('u-Oʻtkir', a.id);
    w.backend.open('u-Bobur', a.id);
    await frames(tester, 8);
    await shot(tester, 't10_jonli_yechmoqda_tugatdi');
    await tester.tap(find.byKey(const Key('grp.bigScreen')));
    await frames(tester);
    await shot(tester, 't11_katta_ekran_telefonda');
    await closeApp(tester);

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    c = await w.open(
      tester,
      uid: 'teacher',
      size: const Size(1280, 720),
      iphone: false,
      location: Routes.groupBoard(g.id, a.id),
    );
    await shot(tester, 't12_katta_ekran_1280x720');
    await closeApp(tester);

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    c = await w.open(
      tester,
      uid: 'teacher',
      location: Routes.groupAssignment(g.id, a.id),
    );
    await tester.tap(find.byKey(const Key('grp.closeTestBar')));
    await frames(tester);
    await shot(tester, 't13_yopish_tasdiq');
    await tester.tap(find.byKey(const Key('grp.closeYes')));
    await frames(tester, 10);
    await shot(tester, 't14_yopildi_natijalar');
    await go(tester, c, Routes.groupJoinWith(g.code!, assignmentId: a.id));
    await shot(tester, 't15_ustoz_oz_kodi');
    await tester.tap(find.byKey(const Key('grp.ownerPreview')));
    await frames(tester);
    await shot(tester, 't16_talaba_korinishida_sinash');
    await closeApp(tester);
  });

  testWidgets('ustoz «Mavzu testi» tanlovi (Darslar) va o‘zim yechib ko‘rish', (
    tester,
  ) async {
    final w = GroupsWorld.real();
    w.backend.create('teacher', '4-kurs, 2-guruh');
    final topic = realTopic(w);
    final decks = {
      for (final e in sampleLessonDecks.entries)
        e.key: {...e.value, 'deck_id': topic},
    };
    await w.open(
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
    await tester.tap(find.byKey(const Key('lesson.outlineButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson.outline.4')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson.quizStart')));
    await frames(tester);
    await shot(tester, 'u01_mavzu_testi_tanlov');
    await tester.tap(find.byKey(const Key('grp.choice.self')));
    await frames(tester);
    await shot(tester, 'u02_ozim_yechib_korish');
    await closeApp(tester);
  });

  for (final (size, scale, tag) in [
    (const Size(390, 844), 1.0, '390x844'),
    (const Size(360, 640), 1.3, '360x640_1.3x'),
  ]) {
    testWidgets('«Umumiy test» $tag', (tester) async {
      final w = GroupsWorld.real();
      final g = w.backend.create('teacher', '4-kurs, 2-guruh').value!;
      for (final n in ['G’ayrat', 'Lola', 'Bobur']) {
        w.backend.join('u-$n', code: g.code!, nickname: n);
      }
      await w.open(
        tester,
        uid: 'teacher',
        size: size,
        textScale: scale,
        location: Routes.group(g.id),
      );
      await tester.tap(find.byKey(const Key('grp.mixedButton')));
      await frames(tester);
      await shot(tester, 'm01_manbalar_$tag');
      const list = Key('grp.mixedList');
      const src = 'sud-tibbiyoti-4-davolash';
      await scrollTo(tester, list, const Key('grp.source.$src'));
      await tester.tap(
        find
            .descendant(
              of: find.byKey(const Key('grp.source.$src')),
              matching: find.byType(ListTile),
            )
            .first,
      );
      await frames(tester);
      await scrollTo(tester, list, const Key('grp.sourceAll.$src'));
      await tester.tap(find.byKey(const Key('grp.sourceAll.$src')));
      await frames(tester);
      await shot(tester, 'm02_hammasini_tanlash_$tag');
      await scrollTo(tester, list, const Key('grp.count.50'));
      await tester.tap(find.byKey(const Key('grp.count.50')));
      await frames(tester);
      await scrollTo(tester, list, const Key('grp.time.20'));
      await tester.tap(find.byKey(const Key('grp.time.20')));
      await frames(tester);
      await scrollTo(tester, list, const Key('grp.mixedTitle'));
      await shot(tester, 'm03_nom_soni_vaqt_$tag');
      await scrollTo(tester, list, const Key('grp.variantSwitch'));
      await shot(tester, 'm04_ochiq_turish_variant_$tag');
      await scrollTo(tester, list, const Key('grp.mixedPreviewButton'));
      await tester.tap(find.byKey(const Key('grp.mixedPreviewButton')));
      await frames(tester);
      await shot(tester, 'm05_oldindan_korish_$tag');
      await tester.tapAt(const Offset(20, 40));
      await frames(tester);
      await scrollTo(tester, list, const Key('grp.mixedSubmit'));
      await tester.tap(find.byKey(const Key('grp.mixedSubmit')));
      await frames(tester);
      final a = w.backend.detail('teacher', g.id).value!.assignments.single;
      final key = {
        for (final p in w.backend.preview('teacher', a.id).value!.pool)
          p.id: p.correctIndex,
      };
      final qs = w.backend.open('u-G’ayrat', a.id).value!.questions;
      w.backend.submit('u-G’ayrat', a.id, {
        for (final (i, q) in qs.indexed)
          q.id: i < 41 ? key[q.id]! : (key[q.id]! + 1) % 4,
      });
      w.backend.open('u-Lola', a.id);
      await frames(tester, 8);
      await shot(tester, 'm06_natija_ustozda_$tag');
      await closeApp(tester);
    });
  }

  testWidgets('talaba: QR → taxallus → test → natija → javoblar', (
    tester,
  ) async {
    final w = GroupsWorld.real();
    final g = w.backend.create('teacher', '4-kurs, 2-guruh').value!;
    w.backend.join('other', code: g.code!, nickname: 'Lola');
    final a = (await w.backend.createAssignment(
      'teacher',
      g.id,
      AssignmentDraft(
        topicId: realTopic(w),
        questionCount: 5,
        timeLimitMin: 10,
        dueAt: w.now.add(const Duration(days: 1)),
        variantMode: true,
        reveal: RevealPolicy.afterDue,
      ),
    )).value!;
    final key = {
      for (final p in w.backend.preview('teacher', a.id).value!.pool)
        p.id: p.correctIndex,
    };
    final c = await w.open(tester, uid: 'stu');
    await go(tester, c, '/g/${g.code}?a=${a.id}');
    await shot(tester, 's01_qr_dan_keyin_taxallus');
    await tester.enterText(find.byKey(const Key('grp.nickField')), 'G’ayrat');
    await shot(tester, 's02_taxallus_iphone_apostrof');
    await tester.tap(find.byKey(const Key('grp.joinSubmit')));
    await frames(tester);
    await shot(tester, 's03_test_1_savol_taymer');
    final ids = [
      for (final q in w.backend.open('stu', a.id).value!.questions) q.id,
    ];
    for (var i = 0; i < 5; i++) {
      final k = key[ids[i]]!;
      await tester.tap(
        find.byKey(Key('grp.option.${i < 3 ? k : (k + 1) % 4}')),
      );
      await frames(tester, 2);
      if (i == 1) await shot(tester, 's04_test_javob_tanlandi');
      if (i < 4) {
        await tester.tap(find.byKey(const Key('grp.next')));
        await frames(tester, 2);
      }
    }
    await tester.tap(find.byKey(const Key('grp.finish')));
    await frames(tester, 3);
    await shot(tester, 's05_yuborish_tasdiq');
    await tester.tap(find.byKey(const Key('grp.submitYes')));
    await frames(tester);
    await shot(tester, 's06_natija_javoblar_yopiq');
    w.backend.closeAssignment('teacher', a.id);
    await tester.tap(find.byKey(const Key('grp.refreshResult')));
    await frames(tester);
    await shot(tester, 's07_natija_javoblar_ochildi');
    await go(tester, c, Routes.group(g.id));
    await shot(tester, 's08_talaba_guruh_sahifasi');
    await closeApp(tester);
  });

  testWidgets('talaba: muddat sanasi, xatolar, yangi o‘rnatish', (
    tester,
  ) async {
    final w = GroupsWorld.real();
    final g = w.backend.create('teacher', 'Muddatli guruh').value!;
    w.backend.join('stu', code: g.code!, nickname: 'Lola');
    final a = (await w.backend.createAssignment(
      'teacher',
      g.id,
      AssignmentDraft(
        topicId: realTopic(w),
        questionCount: 5,
        dueAt: w.now.add(const Duration(days: 2, hours: 8)),
        reveal: RevealPolicy.afterDue,
      ),
    )).value!;
    var c = await w.open(
      tester,
      uid: 'stu',
      location: Routes.groupTest(g.id, a.id),
    );
    await shot(tester, 's09_vaqtsiz_faqat_muddat_sana');
    await go(tester, c, Routes.groupJoin);
    await tester.enterText(find.byKey(const Key('grp.codeField')), 'abco2345');
    await tester.tap(find.byKey(const Key('grp.joinSubmit')));
    await frames(tester);
    await shot(tester, 's10_xato_0_O_1_I');
    await closeApp(tester);

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    c = await w.open(tester, settings: completedSettings(lang: 'uz'));
    await go(tester, c, '/g/${g.code}?a=${a.id}');
    await shot(tester, 's11_yangi_ornatish_kirish_taklifi');
    (c.read(authStateProvider.notifier) as TestAuth).set(signedInAs('new'));
    await frames(tester);
    await shot(tester, 's12_kirgach_taxallus');
    await closeApp(tester);
  });
}
