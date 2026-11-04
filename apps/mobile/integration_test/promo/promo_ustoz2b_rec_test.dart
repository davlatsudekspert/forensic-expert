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
import 'package:forensic_expert/domain/oral_group/oral_group_models.dart';
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
  testWidgets('promo ustoz2b', (tester) async {
    late FakeClassQuizBackend cb;
    final ob = FakeOralGroupBackend(teachers: {'demo-user'});
    final p = Promo(tester, 'ustoz2b');
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

    // ----------------------------------------------------------- oral4
    // Navbat ekrani: ba’zi talabalar tayyor, biri ilovadan chiqqan.
    final teacher = FakeOralGroupService(ob, userId: 'demo-user');
    final created = await teacher.createSession(
      title: 'Toksikologiya',
      tickets: [
        for (var t = 1; t <= 8; t++)
          [
            for (var i = 1; i <= 5; i++)
              OralGroupQuestion(id: 'q$t.$i', text: 'Savol $t.$i'),
          ],
      ],
      prepSeconds: 0,
    );
    final session = created.value!;
    for (var i = 0; i < 5; i++) {
      await FakeOralGroupService(
        ob,
        userId: 'os$i',
      ).join(code: session.code, name: _names[i]);
    }
    for (var i = 0; i < 3; i++) {
      await FakeOralGroupService(ob, userId: 'os$i').ready(session.id);
    }
    await FakeOralGroupService(ob, userId: 'os1').reportLeave(session.id);
    await p.scene('oral4', () async {
      await p.go(Routes.home, after: 800);
      await p.go(Routes.oralGroupQueue(session.id), after: 2500);
      p.screen('oral queue leave');
      await p.wait(2500);
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
      await p.go(Routes.home, after: 1200);
      await p.go(Routes.library, after: 2500);
      p.screen('library');
      await p.scroll(700, ms: 3000);
    });
    p.finish();
  });
}
