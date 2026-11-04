// «O‘zim yechib ko‘rish» — haqiqiy yo‘l: Bosh sahifa → Barcha mavzular →
// mavzu → dars → test tugmasi → savollar. Ovozsiz (talabalar uchun).
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_rec.dart';

const _deck = '4-kurs-davolash-10';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo extra8', (tester) async {
    final p = Promo(tester, 'extra8');
    await p.launch(
      mode: 'student',
      overrides: [
        // Haqiqiy ilovada mavzular serverdan keladi; yozuv muhitida dars testi
        // yoqilishi uchun shu mavzu ro‘yxatda bo‘ladi.
        classPracticeTopicsProvider.overrideWith(
          (ref) async => const ClassResult.ok([
            ClassTopic(id: _deck, title: 'Sinov', count: 20),
          ]),
        ),
        classQuizServiceProvider.overrideWith(
          (ref) => FakeClassQuizService(
            ref.watch(classQuizDemoBackendProvider),
            userId: 'talaba-1',
          ),
        ),
      ],
    );
    await p.scene('selftest', () async {
      await p.go(Routes.home, after: 1800);
      await p.reveal(
        p.byKeyStr('workbench.deskLessons'),
        alignment: 0.4,
        after: 1800,
      );
      await p.tapKey('workbench.deskLessons', after: 2200);
      await p.reveal(p.byKeyStr('lessons.row.$_deck'));
      await p.wait(1200);
      await p.tapKey('lessons.row.$_deck', after: 2500);
      await p.tapKey('lesson.next', after: 1800);
      // O‘qiydi: slaydlarni varaqlaydi, oxirida test tugmasi chiqadi.
      for (var i = 0; i < 80 && !p.has('lesson.quizStart'); i++) {
        await p.tapKey('lesson.next', after: i < 3 ? 1200 : 90);
      }
      await p.wait(1500);
      await p.tapKey('lesson.quizStart', after: 2800);
      p.screen('q1');
      for (var q = 0; q < 3; q++) {
        await p.tapKey('grp.option.${q % 3}', after: 1600);
        await p.tapKey('grp.confirm', after: 3200);
        if (p.has('grp.next')) await p.tapKey('grp.next', after: 1800);
      }
      await p.wait(1200);
    });
    p.finish();
  });
}
