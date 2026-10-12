import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo 05 imtihon', (tester) async {
    final p = Promo(tester, 'promo_05_imtihon');
    await p.launch(mode: 'student');

    await p.go(Routes.learn, after: 2000);
    p.screen('Ta’lim: O‘zlashtirish');
    await p.caption(
      'Imtihonga tayyorlaning: kurslar, kartochkalar, testlar',
      () async {
        await p.wait(2400);
        await p.scroll(420, ms: 1800);
        await p.wait(1600);
      },
    );

    await p.go(Routes.study, after: 2000);
    p.screen('O‘quv rejimi: to‘plamlar');
    await p.caption(
      'O‘quv rejimi: har bir to‘plamda takrorlash navbati',
      () async {
        await p.wait(1800);
        await p.scroll(700, ms: 2200);
        await p.wait(1500);
      },
    );
    await p.caption(
      'Manba ko‘rsatilgan o‘quv qo‘llanma to‘plami: kartochka va imtihon',
      () async {
        await p.reveal(
          find.byKey(const Key('study.deck.teaching.gmt')),
          alignment: 0.1,
          after: 3200,
        );
        p.screen('O‘quv qo‘llanma to‘plami');
      },
    );

    // Kartochkalar
    await p.go(Routes.studyCards('teaching.gmt'), after: 2000);
    p.screen('Kartochka: savol');
    await p.caption(
      'Kartochkalar: avval o‘zingiz javob bering, keyin tekshiring',
      () async {
        await p.wait(1800);
        await p.tapKey('study.reveal', after: 2600);
        p.screen('Kartochka: javob');
      },
    );
    await p.caption(
      'Bilaman / Bilmadim — takrorlash navbati shunga qarab tuziladi',
      () async {
        await p.tapKey('study.knew', after: 2000);
        await p.tapKey('study.reveal', after: 2000);
        await p.tapKey('study.didntKnow', after: 2000);
        p.screen('Kartochka: keyingisi');
      },
    );

    // Mashq
    await p.go(Routes.studyQuiz('teaching.gmt'), after: 2200);
    p.screen('Mashq: savol');
    await p.caption('Mashq testi: javobni tanlang va tekshiring', () async {
      await p.wait(1500);
      await p.tapKey('study.quiz.option.0', after: 1300);
      await p.tapKey('study.quiz.check', after: 2200);
      p.screen('Mashq: natija');
    });
    await p.caption('Tushuntirish va manbadagi sahifa ko‘rsatiladi', () async {
      await p.scroll(480, ms: 1900);
      await p.wait(2400);
    });

    // Imtihon
    await p.go(Routes.studyQuiz('teaching.gmt', exam: true), after: 2400);
    p.screen('Imtihon: savol');
    await p.caption('Imtihon rejimi: baholanadigan savollar', () async {
      await p.wait(1800);
      for (final o in [1, 2]) {
        await p.tapKey('study.quiz.option.$o', after: 1100);
        await p.tapKey('study.quiz.next', after: 1500);
      }
      p.screen('Imtihon: keyingi savol');
    });
    await p.caption('Savollar manbali o‘quv materialidan tuzilgan', () async {
      for (final o in [0, 1]) {
        await p.tapKey('study.quiz.option.$o', after: 1100);
        await p.tapKey('study.quiz.next', after: 1500);
      }
      p.screen('Imtihon: davomi');
    });

    // Atamalar
    await p.go(Routes.guideline('guideline.chem.toks_isolation'), after: 2000);
    p.screen('Yo‘riqnoma: atamalar');
    await p.caption(
      'Atamani bosing — o‘zbek, rus va ingliz tilidagi izoh',
      () async {
        await p.reveal(find.text('dializ').last, alignment: 0.3, after: 1500);
        await p.tap(find.text('dializ').last, after: 3200);
        p.screen('Atama oynasi');
      },
    );
    p.finish();
  });
}
