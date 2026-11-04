// PROMO yangilash: Talaba «join» sahnasi — maydon nomi «Ism» (egasi,
// 2026-11-03: «Laqab» o‘rniga). promo_talaba_rec_test.dart dagi bilan bir xil.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_rec.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo extra6', (tester) async {
    final p = Promo(tester, 'extra6');
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

    await p.scene('join', () async {
      await p.go(Routes.classJoin, after: 1200);
      p.screen('join');
      final f = find.byType(TextField);
      if (f.evaluate().length >= 2) {
        await p.type(f.at(0), '482916', after: 400);
        await p.type(f.at(1), 'Dilnoza', after: 600);
      }
    });
    p.finish();
  });
}
