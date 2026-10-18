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
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';

import '../helpers/class_groups_world.dart';
import '../helpers/pump_app.dart' show completedSettings;

/// «Ustoz–talaba testi» kadrlari — haqiqiy shriftlar, iPhone 390×844 (notch)
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

  Future<void> go(WidgetTester tester, ProviderContainer c, String loc) async {
    c.read(routerProvider).go(loc);
    await frames(tester);
  }

  testWidgets('ustoz: guruh → mavzu testi → QR → jonli → yopish', (
    tester,
  ) async {
    final w = GroupsWorld();
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
    await tester.tap(find.byKey(const Key('grp.topic.tox-small')));
    await frames(tester);
    await tester.drag(
      find.byKey(const Key('grp.assignList')),
      const Offset(0, -260),
    );
    await frames(tester);
    await shot(tester, 't05_variant_ochiq_sababi');
    await tester.drag(
      find.byKey(const Key('grp.assignList')),
      const Offset(0, 600),
    );
    await frames(tester);
    await tester.tap(find.byKey(const Key('grp.selectedTopic')));
    await frames(tester);
    await tester.tap(find.byKey(const Key('grp.topic.tox-co')));
    await frames(tester);
    await shot(tester, 't06_sozlamalar');
    await tester.drag(
      find.byKey(const Key('grp.assignList')),
      const Offset(0, -500),
    );
    await frames(tester);
    await shot(tester, 't07_sozlamalar_javoblar_qachon');
    await tester.tap(find.byKey(const Key('grp.assignSubmit')));
    await frames(tester);
    final a = w.backend.detail('teacher', g.id).value!.assignments.first;
    await shot(tester, 't08_test_qr_jonli_qoshildi');
    // Talabalar yechmoqda / tugatdi.
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

    solve('u-G’ayrat', 10);
    solve('u-Lola', 4);
    w.backend.open('u-Oʻtkir', a.id);
    w.backend.open('u-Bobur', a.id);
    await frames(tester, 8);
    await shot(tester, 't09_jonli_yechmoqda_tugatdi');
    await tester.tap(find.byKey(const Key('grp.bigScreen')));
    await frames(tester);
    await shot(tester, 't10_katta_ekran_telefonda');
    await closeApp(tester);

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    c = await w.open(
      tester,
      uid: 'teacher',
      size: const Size(1280, 720),
      iphone: false,
      location: Routes.groupBoard(g.id, a.id),
    );
    await shot(tester, 't11_katta_ekran_1280x720');
    await closeApp(tester);

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    c = await w.open(
      tester,
      uid: 'teacher',
      location: Routes.groupAssignment(g.id, a.id),
    );
    await tester.fling(
      find.byKey(const Key('grp.liveList')),
      const Offset(0, -2000),
      3000,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('grp.closeTest')));
    await frames(tester);
    await shot(tester, 't12_yopish_tasdiq');
    await tester.tap(find.byKey(const Key('grp.closeYes')));
    await frames(tester, 10);
    await shot(tester, 't13_yopildi_natijalar');
    // Ustoz o‘z QR kodini ochdi.
    await go(tester, c, Routes.groupJoinWith(g.code!, assignmentId: a.id));
    await shot(tester, 't14_ustoz_oz_kodi');
    await tester.tap(find.byKey(const Key('grp.ownerPreview')));
    await frames(tester);
    await shot(tester, 't15_talaba_korinishida_sinash');
    await closeApp(tester);
  });

  testWidgets('talaba: QR → taxallus → test → natija → javoblar', (
    tester,
  ) async {
    final w = GroupsWorld();
    final g = w.backend.create('teacher', '4-kurs, 2-guruh').value!;
    w.backend.join('other', code: g.code!, nickname: 'Lola');
    final a = (await w.backend.createAssignment(
      'teacher',
      g.id,
      const AssignmentDraft(
        topicId: 'tox-co',
        questionCount: 5,
        timeLimitMin: 15,
        variantMode: true,
      ),
    )).value!;
    final c = await w.open(tester, uid: 'stu');
    await go(tester, c, '/g/${g.code}?a=${a.id}');
    await shot(tester, 's01_qr_dan_keyin_taxallus');
    await tester.enterText(find.byKey(const Key('grp.nickField')), 'G’ayrat');
    await shot(tester, 's02_taxallus_iphone_apostrof');
    await tester.tap(find.byKey(const Key('grp.joinSubmit')));
    await frames(tester);
    await shot(tester, 's03_test_1_savol_taymer');
    for (var i = 0; i < 5; i++) {
      await tester.tap(
        i < 3
            ? find.text('50% va undan yuqori')
            : find.byKey(Key('grp.option.${(i + 2) % 4}')),
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
    final w = GroupsWorld();
    final g = w.backend.create('teacher', 'Muddatli guruh').value!;
    w.backend.join('stu', code: g.code!, nickname: 'Lola');
    final a = (await w.backend.createAssignment(
      'teacher',
      g.id,
      AssignmentDraft(
        topicId: 'tox-co',
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
    await shot(tester, 's09_faqat_muddat_sana');
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
