// PROMO «Mutaxassis»: sud kimyogari/toksikolog uchun ilova sayohati
// (professional rejim, mock akkaunt, oflayn). Sahna ID lari
// narration_mutaxassis.json bilan mos.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_rec.dart';

Finder _field(String k) =>
    find.descendant(of: find.byKey(Key(k)), matching: find.byType(TextField));

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo mutaxassis fix', (tester) async {
    final p = Promo(tester, 'mutaxassis_fix');
    await p.launch(mode: 'professional');

    await p.scene('assess', () async {
      await p.go(Routes.assessment, after: 1800);
      await p.tapKey('assessment.spec.sud_kimyo', after: 2000);
      p.screen('assessment specialty');
      await p.tapText('Testlar', after: 1800);
      p.screen('assessment tests');
      await p.scroll(300, ms: 1400);
      await p.wait(800);
    });

    await p.scene('court', () async {
      await p.go(Routes.courtPrep, after: 1800);
      await p.scroll(350, ms: 1500);
      await p.go(Routes.courtPrepSimulator, after: 1500);
      p.screen('court simulator');
      await p.tapKey('court.scenario.court.sim.certainty', after: 2200);
      p.screen('court scenario');
      await p.wait(1200);
    });
    p.finish();
  });
}
