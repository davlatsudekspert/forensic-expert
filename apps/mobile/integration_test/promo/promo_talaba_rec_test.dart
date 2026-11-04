// PROMO 2: Talaba (student) — haqiqiy ilova, MOCK akkaunt, haqiqiy dars
// ma’lumotlari PROMO_DECKS dan. Sahna ID lari narration_talaba.json bilan mos.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_rec.dart';

const _deck = '4-kurs-davolash-10';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo talaba', (tester) async {
    final p = Promo(tester, 'talaba');
    await p.launch(
      mode: 'student',
      overrides: [
        // Talaba ustoz emas: Guruh testi tanlovi o‘rniga to‘g‘ridan-to‘g‘ri
        // «o‘zim yechib ko‘rish».
        classQuizServiceProvider.overrideWith(
          (ref) => FakeClassQuizService(
            ref.watch(classQuizDemoBackendProvider),
            userId: 'talaba-1',
          ),
        ),
      ],
    );

    await p.scene('desk', () async {
      await p.go(Routes.home, after: 1200);
      await p.reveal(p.byKeyStr('desk.student'), alignment: 0.04, after: 1200);
      p.screen('desk');
      await p.reveal(
        p.byKeyStr('desk.dailyQuestion'),
        alignment: 0.1,
        after: 800,
      );
      await p.tapKey('desk.dailyQuestion.option.0', after: 1500);
      p.screen('daily question');
    });

    await p.scene('lessons', () async {
      await p.go(Routes.home, after: 600);
      await p.tapKey('workbench.deskLessons', after: 1200);
      p.screen('lessons');
      await p.scroll(480, ms: 2200);
      await p.scrollTop();
      await p.type(
        find.byKey(const Key('lessons.search')),
        'toksikologiya',
        after: 600,
      );
    });

    await p.scene('slide', () async {
      await p.reveal(p.byKeyStr('lessons.row.$_deck'));
      await p.tapKey('lessons.row.$_deck', after: 2000);
      p.screen('slide0');
      await p.tapKey('lesson.next', after: 1500);
      p.screen('slide1');
    });

    await p.scene('explain', () async {
      await p.tapKey('lesson.explain', after: 2500);
      p.screen('explain');
    });

    await p.scene('selftest', () async {
      await p.push(Routes.groupPractice(_deck), after: 1800);
      p.screen('selftest');
      await p.tapKey('grp.option.1', after: 1000);
      await p.tapKey('grp.confirm', after: 1800);
      p.screen('selftest answered');
      if (p.has('grp.next')) await p.tapKey('grp.next', after: 1200);
      await p.tapKey('grp.option.0', after: 1000);
      await p.tapKey('grp.confirm', after: 1600);
    });

    await p.scene('join', () async {
      await p.go(Routes.classJoin, after: 1200);
      p.screen('join');
      final f = find.byType(TextField);
      if (f.evaluate().length >= 2) {
        await p.type(f.at(0), '482916', after: 400);
        await p.type(f.at(1), 'Dilnoza', after: 600);
      }
    });

    await p.scene('library', () async {
      await p.go(Routes.library, after: 1500);
      await p.scroll(260, ms: 1400);
      await p.scrollTop();
      await p.tapText('Moddalar', after: 1800);
      p.screen('library substances');
      await p.scroll(300, ms: 1500);
    });

    p.finish();
  });
}
