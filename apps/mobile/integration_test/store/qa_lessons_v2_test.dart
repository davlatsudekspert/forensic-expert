// Haqiqiy ilova + prod backend: «Darslar» v2 (boy diagrammalar) va dars testi
// oqimini demo ustoz akkaunti bilan ko‘zdan kechirish. Faqat o‘qiydi, sessiya
// yaratmaydi. PNG → QA_OUT.
//
//   STORE_EMAIL=... STORE_PASSWORD=... QA_OUT=/tmp/x QA_DECK=toks-05-toks-suv-bugi-sianid \
//   xvfb-run -a dbus-run-session -- flutter test integration_test/store/qa_lessons_v2_test.dart \
//     -d linux --dart-define-from-file=config/backend.json
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/bootstrap.dart';
import 'package:forensic_expert/app/lessons.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final env = Platform.environment;
  final out = env['QA_OUT'] ?? 'build/qa_lessons_v2';
  final deckId = env['QA_DECK'] ?? 'toks-05-toks-suv-bugi-sianid';

  testWidgets('lessons v2 real', (tester) async {
    Future<void> settle([int ms = 1500]) async {
      final end = DateTime.now().millisecondsSinceEpoch + ms;
      while (DateTime.now().millisecondsSinceEpoch < end) {
        await tester.pump(const Duration(milliseconds: 50));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)),
        );
      }
    }

    Future<void> shot(String name) async {
      await settle(600);
      final view = tester.binding.renderViews.first;
      final layer = view.debugLayer! as OffsetLayer;
      await tester.runAsync(() async {
        final dpr = tester.view.devicePixelRatio;
        final img = await layer.toImage(
          Offset.zero & (view.size * dpr),
          pixelRatio: 1 / dpr,
        );
        final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
        File('$out/$name.png')
          ..parent.createSync(recursive: true)
          ..writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    }

    final kinds = <String, int>{};
    void countKinds() {
      for (final k in [
        'table',
        'flow',
        'steps',
        'compare',
        'tree',
        'facts',
        'reaction',
        'cycle',
      ]) {
        if (find.byKey(Key('lesson.diagram.$k')).evaluate().isNotEmpty) {
          kinds[k] = (kinds[k] ?? 0) + 1;
        }
      }
    }

    SharedPreferences.setMockInitialValues({
      'fe.settings.locale': 'uz',
      'fe.settings.theme': 'light',
      'fe.settings.mode': 'professional',
      'fe.settings.disclaimer_version': 1,
    });
    await bootstrap();
    await settle(3000);
    final c = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    final r = await c
        .read(authRepositoryProvider)
        .signIn(email: env['STORE_EMAIL']!, password: env['STORE_PASSWORD']!);
    // ignore: avoid_print
    print('QA sign-in ok=${r.ok} failure=${r.failure}');
    await settle(2500);

    // Proyektor o‘lchami.
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1920, 1080);
    await settle(1000);

    c.read(routerProvider).go('${Routes.lessons}/$deckId');
    await settle(6000);
    await shot('lesson_00_open');
    // ignore: avoid_print
    print('QA quiz available: ${c.read(lessonQuizAvailableProvider(deckId))}');
    countKinds();
    for (var i = 1; i <= 48; i++) {
      final next = find.byKey(const Key('lesson.next'));
      if (next.evaluate().isEmpty) {
        // ignore: avoid_print
        print('QA no next at $i');
        break;
      }
      await tester.tap(next);
      await settle(400);
      countKinds();
      if (i % 3 == 0 || i < 4)
        await shot('lesson_${i.toString().padLeft(2, '0')}');
    }
    // ignore: avoid_print
    print('QA diagram kinds seen: $kinds');
    final counter = find.byKey(const Key('lesson.counter'));
    if (counter.evaluate().isNotEmpty) {
      // ignore: avoid_print
      print('QA counter: ${(counter.evaluate().first.widget as dynamic)}');
    }
    await shot('lesson_last');
    final proj = find.byKey(const Key('lesson.projectorButton'));
    if (proj.evaluate().isNotEmpty) {
      await tester.tap(proj);
      await settle(1500);
      await shot('lesson_projector');
    }

    // Telefon o‘lchami: dars oxiridan test → tanlov.
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    await settle(1000);
    c.read(routerProvider).go('${Routes.lessons}/$deckId');
    await settle(4000);
    await shot('phone_lesson');
    c.read(routerProvider).go(Routes.classQuiz);
    await settle(4000);
    await shot('phone_class_hub');
    final run = find.byKey(const Key('class.runQuiz'));
    // ignore: avoid_print
    print('QA runQuiz key: ${run.evaluate().length}');
    c.read(routerProvider).go('${Routes.classQuiz}/new');
    await settle(5000);
    await shot('phone_create_1');
    final search = find.byType(TextField).first;
    await tester.enterText(search, 'Haydash');
    await settle(2500);
    await shot('phone_create_search');
    final card = find.textContaining('Uchuvchi zaharlarni');
    // ignore: avoid_print
    print('QA topic cards: ${card.evaluate().length}');
    if (card.evaluate().isNotEmpty) {
      await tester.tap(card.first);
      await settle(2000);
      await shot('phone_create_selected');
      final cnt = find.byKey(const Key('class.questionCount'));
      if (cnt.evaluate().isNotEmpty) {
        await tester.ensureVisible(cnt.first);
        await settle(800);
        await shot('phone_create_chips');
      }
    }
    // ignore: avoid_print
    print(
      'QA chips: 10=${find.text('10').evaluate().length} 15=${find.text('15').evaluate().length} 20=${find.text('20').evaluate().length}',
    );
    c.read(routerProvider).go(Routes.groups);
    await settle(4000);
    await shot('phone_groups');
  });
}
