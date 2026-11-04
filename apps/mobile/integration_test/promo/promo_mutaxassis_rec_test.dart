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
  testWidgets('promo mutaxassis', (tester) async {
    final p = Promo(tester, 'mutaxassis');
    await p.launch(mode: 'professional');

    await p.scene('subst', () async {
      await p.go(Routes.home, after: 1800);
      await p.go(Routes.librarySection('substances'), after: 1500);
      await p.scroll(400, ms: 1400);
      await p.go(Routes.search, after: 800);
      await p.type(find.byKey(const Key('search.field')), 'etanol', after: 1000);
      p.screen('search etanol');
      await p.go(Routes.homeSubstance('ethanol'), after: 2600);
      p.screen('ethanol card');
      await p.scroll(520, ms: 1800);
      await p.wait(1200);
    });

    await p.scene('plan', () async {
      await p.go(Routes.homePlan('ethanol'), after: 2200);
      p.screen('ethanol plan');
      await p.scroll(560, ms: 2000);
      await p.wait(1200);
      await p.scroll(560, ms: 2000);
      await p.wait(1200);
    });

    await p.scene('methods', () async {
      await p.go('/home/knowledge/method', after: 1800);
      await p.wait(600);
      for (final k in ['gcms', 'lcmsms', 'tlc', 'uvvis']) {
        await p.tapKey('knowledge.method-$k', after: 1500);
        p.screen('method $k');
        await p.scroll(380, ms: 1200);
        await p.wait(300);
        await p.back(after: 500);
      }
    });

    await p.scene('cohb', () async {
      await p.go(
        Routes.guideline('guideline.chem.co_cohb_determination'),
        after: 2400,
      );
      p.screen('cohb guideline');
      await p.reveal(p.byKeyStr('guideline.body.2'), alignment: 0.1, after: 2200);
      await p.reveal(p.byKeyStr('guideline.body.5'), alignment: 0.1, after: 2200);
    });

    await p.scene('cohb2', () async {
      await p.go(Routes.equipmentItem('uv_vis'), after: 2200);
      await p.reveal(
        p.byKeyStr('equipment.cohbSpectrum'),
        alignment: 0.15,
        after: 3500,
      );
      p.screen('cohb spectrum');
    });

    await p.scene('gcms', () async {
      await p.go(Routes.gcmsReading, after: 2200);
      p.screen('gcms reading');
      await p.scroll(520, ms: 1800);
      await p.wait(800);
      await p.scroll(520, ms: 1800);
      await p.wait(800);
      await p.go(Routes.gcms, after: 2200);
      p.screen('gcms scheme');
      await p.scroll(420, ms: 1600);
      await p.wait(800);
    });

    await p.scene('equip', () async {
      await p.go(Routes.equipment, after: 2000);
      await p.scroll(300, ms: 1400);
      await p.tapKey('equipment.tile.lc_msms', after: 2200);
      p.screen('lc-msms item');
      await p.scroll(480, ms: 1800);
      await p.wait(800);
    });

    await p.scene('calc', () async {
      await p.go(Routes.tools, after: 1500);
      await p.scroll(380, ms: 1200);
      await p.go(Routes.tool('tool.lab.dilution'), after: 1500);
      await p.type(_field('calc.field.c1'), '10', after: 300);
      await p.type(_field('calc.field.c2'), '1', after: 300);
      await p.type(_field('calc.field.v2'), '100', after: 500);
      await p.calc(after: 2200);
      p.screen('dilution result');
    });

    await p.scene('assess', () async {
      await p.go(Routes.assessment, after: 1800);
      await p.tapKey('assessment.spec.sud_kimyo', after: 2000);
      p.screen('assessment specialty');
      await p.scroll(400, ms: 1600);
      await p.wait(800);
      if (p.has('assessment.testStart')) {
        await p.tapKey('assessment.testStart', after: 1800);
        p.screen('assessment test');
      }
    });

    await p.scene('court', () async {
      await p.go(Routes.courtPrep, after: 1800);
      await p.scroll(350, ms: 1500);
      await p.go(Routes.courtPrepSimulator, after: 1500);
      p.screen('court simulator');
      await p.tapKey('court.scenario.court.sim.colour_test', after: 2200);
      p.screen('court scenario');
      await p.wait(1200);
    });
    p.finish();
  });
}
