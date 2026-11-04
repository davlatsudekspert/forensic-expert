// PROMO Talaba: desk sahnasi qayta yozuv (yangi ovoz uzunroq).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_rec.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo desk', (tester) async {
    final p = Promo(tester, 'talaba_desk');
    await p.launch(mode: 'student');
    await p.scene('desk', () async {
      await p.go(Routes.home, after: 1800);
      await p.reveal(p.byKeyStr('desk.student'), alignment: 0.04, after: 2200);
      p.screen('desk');
      await p.reveal(
        p.byKeyStr('desk.dailyQuestion'),
        alignment: 0.1,
        after: 1500,
      );
      await p.tapKey('desk.dailyQuestion.option.0', after: 2500);
      p.screen('daily question');
    });
    await p.wait(2500);
    p.finish();
  });
}
