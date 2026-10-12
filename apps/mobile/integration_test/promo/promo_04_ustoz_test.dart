import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo 04 ustoz', (tester) async {
    final p = Promo(tester, 'promo_04_ustoz');
    await p.launch(mode: 'professional', pro: true);

    p.screen('Asosiy (Mutaxassis rejimi)');
    await p.caption(
      'Ustoz uchun: manbali materiallar, o‘quv rejimi, sud simulyatori',
      () async {
        await p.wait(2400);
        await p.scroll(700, ms: 2200);
        await p.wait(1200);
        await p.scrollTop();
      },
    );

    await p.go(Routes.library, after: 1800);
    p.screen('Kutubxona markazi');
    await p.caption(
      'Kutubxona: har bir yozuvda manba va tekshiruv holati ko‘rsatiladi',
      () async {
        await p.wait(1500);
        await p.scroll(380, ms: 1800);
        await p.wait(2200);
      },
    );

    await p.go(Routes.guideline('guideline.chem.toks_isolation'), after: 2200);
    p.screen('Yo‘riqnoma');
    await p.caption(
      'Yo‘riqnoma: manba, muallif ruxsati va ilmiy asos bir joyda',
      () async {
        await p.wait(2600);
        await p.scroll(600, ms: 2200);
        await p.wait(2000);
      },
    );
    await p.caption(
      'Atamalar va manbalar ro‘yxati — har bir manbaga havola',
      () async {
        await p.reveal(find.text('Atamalar').last, alignment: 0.1, after: 2400);
        await p.scroll(520, ms: 2000);
        await p.wait(2000);
        p.screen('Yo‘riqnoma: atamalar va manbalar');
      },
    );

    await p.go(Routes.study, after: 2000);
    p.screen('O‘quv rejimi: to‘plamlar');
    await p.caption(
      'O‘quv rejimi: kartochka, mashq va imtihon to‘plamlari',
      () async {
        await p.wait(1500);
        await p.reveal(
          find.byKey(const Key('study.deck.teaching.gmt')),
          alignment: 0.15,
          after: 3200,
        );
        p.screen('O‘quv rejimi: o‘quv qo‘llanma to‘plami');
      },
    );
    await p.go(Routes.studyQuiz('teaching.gmt', exam: true), after: 2400);
    p.screen('Imtihon rejimi');
    await p.caption('Imtihon rejimi: baholanadigan savollar', () async {
      await p.wait(1500);
      await p.tapKey('study.quiz.option.1', after: 1300);
      await p.tapKey('study.quiz.next', after: 1800);
      await p.tapKey('study.quiz.option.2', after: 1300);
      await p.tapKey('study.quiz.next', after: 2000);
      p.screen('Imtihon rejimi: keyingi savol');
    });

    await p.go(Routes.courtPrepSimulator, after: 2000);
    p.screen('Sud simulyatori');
    await p.caption(
      'Sud simulyatori: ssenariylar — prokuror, sudya, advokat savollari',
      () async {
        await p.wait(2000);
        await p.scroll(520, ms: 2000);
        await p.wait(2000);
      },
    );
    await p.go(Routes.courtPrepScenario('court.sim.colour_test'), after: 2200);
    p.screen('Simulyator: ssenariy');
    await p.caption('Javobni tanlang va baholashni ko‘ring', () async {
      await p.scroll(420, ms: 1800);
      await p.tapKey('court.sim.option.1', after: 1500);
      await p.tapKey('court.sim.check', after: 1500);
      await p.reveal(
        find.byKey(const Key('court.sim.result')),
        alignment: 0.05,
        after: 3000,
      );
      p.screen('Simulyator: natija');
    });

    await p.go(Routes.glossary, after: 2000);
    p.screen('Ilmiy lug‘at');
    await p.caption(
      'Ilmiy lug‘at: atamalar o‘zbek, rus va ingliz tillarida',
      () async {
        await p.scroll(500, ms: 2000);
        await p.wait(1800);
        await p.scrollTop();
        await p.tapText('ajratib olish', after: 3000);
        p.screen('Atama sahifasi');
      },
    );
    p.finish();
  });
}
