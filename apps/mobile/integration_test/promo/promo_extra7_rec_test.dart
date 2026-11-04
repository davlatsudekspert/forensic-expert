// «O‘zim yechib ko‘rish» — qisqa, ovozsiz yozuv (talabalar uchun).
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_rec.dart';

const _deck = '4-kurs-davolash-10';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo extra7', (tester) async {
    final p = Promo(tester, 'extra7');
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
    await p.scene('selftest', () async {
      await p.go(Routes.home, after: 1500);
      await p.push(Routes.groupPractice(_deck), after: 2500);
      p.screen('q1');
      for (var q = 0; q < 3; q++) {
        await p.tapKey('grp.option.${q % 3}', after: 1800);
        await p.tapKey('grp.confirm', after: 3500);
        p.screen('answered $q');
        if (p.has('grp.next')) await p.tapKey('grp.next', after: 2000);
      }
      await p.wait(1500);
    });
    p.finish();
  });
}
