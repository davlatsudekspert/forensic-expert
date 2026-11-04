// PROMO 3: Yuldashev Z.A. ustozga rahmat (toksikologiya). Ilovaning o‘z
// kontenti + toks-* darslari (PROMO_DECKS). Sahna ID: narration_yuldashev.json.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_rec.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo yuldashev', (tester) async {
    final p = Promo(tester, 'yuldashev');
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

    await p.scene('toks', () async {
      await p.go(Routes.home, after: 800);
      await p.reveal(
        p.byKeyStr('home.module.toxicology'),
        alignment: 0.3,
        after: 700,
      );
      await p.tapKey('home.module.toxicology', after: 1500);
      p.screen('toks hub');
      await p.tapText('Mavzular', after: 1500);
      p.screen('toks mavzular');
      await p.scroll(500, ms: 2200);
    });

    await p.scene('slide', () async {
      await p.go(Routes.lessons, after: 900);
      await p.type(
        find.byKey(const Key('lessons.search')),
        'toksikologik',
        after: 500,
      );
      await p.reveal(
        p.byKeyStr('lessons.row.toks-01-toks-kirish'),
        alignment: 0.2,
        after: 500,
      );
      await p.tapKey('lessons.row.toks-01-toks-kirish', after: 2000);
      p.screen('toks slide0');
      await p.tapKey('lesson.next', after: 1800);
      p.screen('toks slide1');
    });

    await p.scene('gmt', () async {
      await p.go(Routes.guideline('guideline.chem.gmt_opioids'), after: 1800);
      await p.scrollTop();
      p.screen('gmt opioids');
      await p.scroll(900, ms: 2800);
      await p.scrollTo(p.text('Yuldashev'));
      await p.wait(1200);
      p.screen('gmt source');
      await p.go(Routes.guideline('guideline.chem.gmt_cannabis'), after: 1500);
      await p.scrollTop();
      await p.scroll(500, ms: 2000);
    });

    await p.scene('isolation', () async {
      await p.go(Routes.library, after: 300);
      await p.go(
        Routes.guideline('guideline.chem.toks_isolation'),
        after: 1800,
      );
      await p.scrollTop();
      p.screen('isolation');
      await p.scroll(700, ms: 2600);
    });

    await p.scene('equipment', () async {
      await p.go(Routes.equipmentItem('gc_ms'), after: 2000);
      p.screen('gc_ms');
      await p.scroll(500, ms: 1800);
      await p.go(Routes.equipmentItem('uv_vis'), after: 1800);
      p.screen('uv_vis');
      await p.go(Routes.equipmentItem('spe'), after: 1800);
      p.screen('spe');
    });

    await p.scene('tests', () async {
      await p.go(Routes.study, after: 1500);
      await p.reveal(
        p.byKeyStr('study.deck.teaching.gmt'),
        alignment: 0.15,
        after: 800,
      );
      p.screen('study decks');
      await p.go(Routes.studyQuiz('teaching.gmt'), after: 1800);
      await p.tapKey('study.quiz.option.1', after: 1500);
      p.screen('quiz answered');
    });

    await p.scene('calc', () async {
      await p.go(Routes.homeTool('tool.lab.dilution'), after: 1500);
      for (final (k, v) in [('c1', '10'), ('v1', '5'), ('c2', '2')]) {
        final f = find.descendant(
          of: find.byKey(Key('calc.field.$k')),
          matching: find.byType(TextField),
        );
        if (f.evaluate().isNotEmpty) await p.type(f.first, v, after: 200);
      }
      await p.calc(after: 1000);
      p.screen('dilution');
      await p.go(Routes.homeTool('tool.lab.lod_loq'), after: 1500);
      for (final (k, v) in [('sigma', '0.8'), ('slope', '2.5')]) {
        final f = find.byKey(Key('calc.$k'));
        if (f.evaluate().isNotEmpty) await p.type(f.first, v, after: 200);
      }
      await p.calc(after: 1000);
      p.screen('lodloq');
    });

    p.finish();
  });
}
