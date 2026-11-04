// PROMO yangilash: Talaba toks_source (Yuldashev manbasi) va Yuldashev calc
// (qiymatlar kiritilgan, natija ko‘rinadi). Student rejimi.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_rec.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo extra5', (tester) async {
    final p = Promo(tester, 'extra5');
    await p.launch(mode: 'student');

    await p.scene('toks_source', () async {
      await p.go(Routes.lesson('toks-01-toks-kirish'), after: 2000);
      p.screen('toks slide0');
      await p.tapKey('lesson.next', after: 1800);
      p.screen('toks slide1');
      await p.wait(1500);
    });

    Future<void> fill(String key, String v) async {
      final f = find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byType(TextField),
      );
      if (f.evaluate().isNotEmpty) await p.type(f.first, v, after: 200);
    }

    await p.scene('calc', () async {
      await p.go(Routes.homeTool('tool.lab.dilution'), after: 1500);
      // Noma’lum: V1 (standart). C1=10, C2=1, V2=100 mL → V1=10 mL.
      await fill('calc.field.c1', '10');
      await fill('calc.field.c2', '1');
      await fill('calc.field.v2', '100');
      await p.calc(after: 1800);
      p.screen('dilution result');
      await p.go(Routes.homeTool('tool.lab.lod_loq'), after: 1500);
      for (final (k, v) in [('sigma', '0.8'), ('slope', '2.5')]) {
        final f = find.byKey(Key('calc.$k'));
        if (f.evaluate().isNotEmpty) await p.type(f.first, v, after: 200);
      }
      await p.calc(after: 2000);
      p.screen('lodloq result');
    });
    await p.wait(2500);
    p.finish();
  });
}
