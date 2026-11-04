// PROMO: Ustoz uchun «test + og‘zaki imtihon (QR) + o‘zi ustida ishlash» —
// haqiqiy ilova (teacher, mock akkaunt). Sahna ID lari narration_ustoz2.json
// bilan mos: desk, test, test2, results, oral, oral2, oral3, oral4, self.
// Talabalar ustoz bilan bir jarayonda, alohida Fake xizmatlar orqali qo‘shiladi.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/oral_group.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/class_quiz/class_quiz_bank.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/data/oral_group/fake_oral_group_service.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_rec.dart';

const _names = [
  'Dilnoza',
  'Jasur',
  'Madina',
  'Sardor',
  'Malika',
  'Bekzod',
  'Shahlo',
  'Otabek',
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo ustoz2', (tester) async {
    late FakeClassQuizBackend cb;
    final ob = FakeOralGroupBackend(teachers: {'demo-user'});
    final p = Promo(tester, 'ustoz2');
    await p.launch(
      mode: 'teacher',
      overrides: [
        classQuizDemoBackendProvider.overrideWith((ref) {
          final load = ref.watch(classQuizBankLoaderProvider);
          return cb = FakeClassQuizBackend(
            teachers: {'demo-user'},
            topics: classQuizLocalTopics(
              ClassQuizBank.empty,
              includeDemo: false,
            ),
            topicLoader: () async => ClassQuizBank.parse(await load()).variants,
          );
        }),
        oralGroupDemoBackendProvider.overrideWithValue(ob),
      ],
    );

    // ------------------------------------------------------------ desk
    await p.scene('desk', () async {
      await p.go(Routes.home, after: 1500);
      await p.reveal(p.byKeyStr('desk.teacher'), alignment: 0.04, after: 1800);
      p.screen('desk');
    });

    // ------------------------------------------------------------ test
    await p.scene('test', () async {
      await p.tapKey('workbench.teachRun', after: 1500);
      if (p.has('teacher.run')) await p.tapKey('teacher.run', after: 1500);
      await p.type(
        find.byKey(const Key('class.topicSearch')),
        'toksik',
        after: 700,
      );
      await p.tapKey('class.topic.4-kurs-davolash-10', after: 1200);
      p.screen('class setup');
      await p.tapKey('class.createSubmit', after: 3000);
      p.screen('class code');
    });

    // ----------------------------------------------------------- test2
    await p.scene('test2', () async {
      final teacher = FakeClassQuizService(cb, userId: 'demo-user');
      final sessions = (await teacher.mySessions()).value ?? const [];
      final s = sessions.first;
      for (var i = 0; i < 6; i++) {
        await FakeClassQuizService(
          cb,
          userId: 'st$i',
        ).join(code: s.code, nickname: _names[i]);
        await p.wait(900);
      }
      p.screen('class lobby');
      await p.wait(1500);
      if (p.has('class.startButton')) {
        await p.tapKey('class.startButton', after: 2500);
      }
      p.screen('class running');
    });

    // --------------------------------------------------------- results
    await p.scene('results', () async {
      await p.go(Routes.teacherResults, after: 2000);
      p.screen('results');
    });

    // ------------------------------------------------------------ oral
    await p.scene('oral', () async {
      await p.go(Routes.home, after: 900);
      await p.tapKey('workbench.teachOral', after: 1200);
      await p.waitKey('toral.search');
      await p.type(find.byKey(const Key('toral.search')), 'toksi', after: 500);
      await p.tapKey('toral.topic.4-kurs-davolash-10', after: 900);
      p.screen('oral picked');
      await p.tapKey('toral.group', after: 1800);
      p.screen('oral group setup');
      for (var i = 0; i < 4; i++) {
        if (p.has('oralgroup.inc')) {
          await p.tapKey('oralgroup.inc', after: 350);
        }
      }
      await p.wait(1200);
    });

    // ----------------------------------------------------------- oral2
    await p.scene('oral2', () async {
      await p.tapKey('oralgroup.start', after: 3000);
      p.screen('oral board');
      final teacher = FakeOralGroupService(ob, userId: 'demo-user');
      final session = ((await teacher.mySessions()).value ?? const []).first;
      for (var i = 0; i < 5; i++) {
        await FakeOralGroupService(
          ob,
          userId: 'os$i',
        ).join(code: session.code, name: _names[i]);
        await p.wait(1000);
      }
      for (var i = 0; i < 3; i++) {
        await FakeOralGroupService(ob, userId: 'os$i').ready(session.id);
      }
      p.screen('oral board joined');
      await p.wait(1500);
    });

    // ----------------------------------------------------------- oral3
    await p.scene('oral3', () async {
      await p.tapKey('oralgroup.queueButton', after: 2200);
      p.screen('oral queue');
      final first = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('oralgroup.queue.'),
      );
      if (first.evaluate().isNotEmpty) {
        await p.tap(first.first, after: 2200);
        p.screen('oral grade');
        for (final (i, f) in [0.9, 0.75, 0.95, 0.8, 0.85].indexed) {
          if (p.has('oral.slider.$i')) {
            await p.dragSlider('oral.slider.$i', f, ms: 700);
          }
        }
        await p.wait(1200);
        if (p.has('oralgroup.save')) {
          await p.tapKey('oralgroup.save', after: 2000);
        }
      }
    });

    // ----------------------------------------------------------- oral4
    await p.scene('oral4', () async {
      final teacher = FakeOralGroupService(ob, userId: 'demo-user');
      final session = ((await teacher.mySessions()).value ?? const []).first;
      await FakeOralGroupService(ob, userId: 'os1').reportLeave(session.id);
      await p.wait(3500);
      p.screen('oral queue after');
    });

    // ------------------------------------------------------------ self
    await p.scene('self', () async {
      await p.go(Routes.home, after: 900);
      await p.tapKey('workbench.teachLessons', after: 1400);
      await p.tapKey('lessons.course.Davolash ishi fakulteti', after: 900);
      await p.reveal(p.byKeyStr('lessons.row.4-kurs-davolash-10'));
      await p.tapKey('lessons.row.4-kurs-davolash-10', after: 2200);
      await p.tapKey('lesson.next', after: 1800);
      if (p.has('lesson.explain')) {
        await p.tapKey('lesson.explain', after: 2500);
      }
      await p.go(Routes.library, after: 2200);
    });
    p.finish();
  });
}
