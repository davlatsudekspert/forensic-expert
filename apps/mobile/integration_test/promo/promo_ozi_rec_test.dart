// PROMO: «Talaba o‘zi tayyorlanishi» — haqiqiy ilova (student, mock akkaunt).
// Sahna ID lari narration_ozi.json bilan mos: path, read, explain, test, cards, outro.
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_rec.dart';

const _deck = '4-kurs-davolash-10';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo ozi', (tester) async {
    final p = Promo(tester, 'ozi');
    await p.launch(
      mode: 'student',
      overrides: [
        classQuizServiceProvider.overrideWith(
          (ref) => FakeClassQuizService(
            ref.watch(classQuizDemoBackendProvider),
            userId: 'talaba-1',
          ),
        ),
      ],
    );

    await p.scene('path', () async {
      await p.go(Routes.home, after: 1500);
      await p.reveal(
        p.byKeyStr('workbench.deskLessons'),
        alignment: 0.4,
        after: 1800,
      );
      await p.tapKey('workbench.deskLessons', after: 2200);
      await p.reveal(p.byKeyStr('lessons.row.$_deck'));
      await p.wait(1500);
    });

    await p.scene('read', () async {
      await p.tapKey('lessons.row.$_deck', after: 2500);
      p.screen('slide0');
      await p.tapKey('lesson.next', after: 2500);
      await p.tapKey('lesson.next', after: 2500);
      p.screen('slide2');
    });

    await p.scene('explain', () async {
      await p.tapKey('lesson.explain', after: 3500);
      p.screen('explain');
    });

    await p.scene('test', () async {
      // Oxirgi slaydga tez o‘tadi (telefonda test tugmasi oxirgi slaydda).
      for (var i = 0; i < 80 && !p.has('lesson.quizStart'); i++) {
        await p.tapKey('lesson.next', after: 90);
      }
      await p.wait(1500);
      await p.tapKey('lesson.quizStart', after: 2800);
      p.screen('q1');
      for (var q = 0; q < 3; q++) {
        await p.tapKey('grp.option.${q % 3}', after: 1600);
        await p.tapKey('grp.confirm', after: 3000);
        if (p.has('grp.next')) await p.tapKey('grp.next', after: 1800);
      }
      await p.wait(1200);
    });

    await p.scene('cards', () async {
      await p.go(Routes.study, after: 2500);
      p.screen('study');
      await p.scroll(300, ms: 1500);
      await p.wait(1500);
    });

    await p.scene('outro', () async {
      await p.go(Routes.home, after: 1500);
    });
    p.finish();
  });
}
