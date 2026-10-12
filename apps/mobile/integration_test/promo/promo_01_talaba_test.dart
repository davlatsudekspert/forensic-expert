import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo 01 talaba', (tester) async {
    final p = Promo(tester, 'promo_01_talaba');
    await p.launch(mode: 'student');

    // 1. Asosiy
    p.screen('Asosiy ekran (Talaba rejimi)');
    await p.caption(
      'Talaba uchun sud-ekspert fanlari — bitta ilovada',
      () async {
        await p.wait(2500);
        await p.scroll(420, ms: 1800);
        await p.wait(1200);
        await p.scrollTop();
      },
    );

    // 2. Qidiruv
    await p.caption('Moddani qidiring', () async {
      await p.tapKey('home.search', after: 1200);
      p.screen('Qidiruv');
      await p.type(
        find.byKey(const Key('search.field')),
        'etanol',
        after: 2200,
      );
    });
    p.screen('Qidiruv natijasi: etanol');
    await p.caption(
      'Natijalar qurilmaning o‘zida, internetsiz topiladi',
      () async {
        await p.wait(2500);
      },
    );

    // 3. Etanol sahifasi
    await p.tap(find.byKey(const Key('search.hit.ethanol')), after: 2000);
    if (!p.shows('Qisqacha')) await p.tapText('Etanol', after: 2000);
    p.screen('Etanol: qisqacha');
    await p.caption(
      'Formula, usullar va metabolitlar — bir sahifada',
      () async {
        await p.wait(2800);
      },
    );
    await p.caption('Nomlar o‘zbek, rus va ingliz tillarida', () async {
      await p.scroll(500, ms: 1800);
      p.screen('Etanol: nomlar');
      await p.wait(2000);
    });
    await p.caption(
      'Har bir ma’lumotning manbasi va holati ko‘rsatiladi',
      () async {
        await p.scroll(420, ms: 1800);
        p.screen('Etanol: kelib chiqishi');
        await p.wait(2600);
      },
    );
    await p.caption('«Bu ma’lumot qayerdan?» — manbaga bir bosishda', () async {
      await p.tapText('Bu ma’lumot qayerdan?', after: 3200);
      p.screen('Kelib chiqish oynasi');
    });
    await p.back(after: 800);

    // 4. Lug‘at
    await p.go(Routes.library, after: 1800);
    p.screen('Kutubxona markazi');
    await p.caption(
      'Kutubxona: moddalar, usullar, yo‘riqnomalar, lug‘at',
      () async {
        await p.scroll(300, ms: 1600);
        await p.wait(1500);
        await p.scrollTop();
      },
    );
    await p.caption('Ilmiy lug‘at: atamalar uchta tilda', () async {
      await p.tapKey('library.hub.terms', after: 2200);
      p.screen('Ilmiy lug‘at');
      await p.scroll(300, ms: 1500);
      await p.wait(800);
    });
    await p.caption(
      'Atama sahifasida o‘zbekcha, ruscha va inglizcha shakl',
      () async {
        await p.tapText('ajratib olish', after: 3200);
        p.screen('Atama sahifasi');
      },
    );
    await p.back(after: 600);

    // 5. O‘quv rejimi
    await p.go(Routes.learn, after: 2000);
    p.screen('Ta’lim: O‘zlashtirish');
    await p.caption('Ta’lim bo‘limi: kurslar va darslar', () async {
      await p.scroll(350, ms: 1500);
      await p.wait(1200);
    });
    await p.go(Routes.study, after: 1800);
    p.screen('O‘quv rejimi: to‘plamlar');
    await p.caption('O‘quv rejimi: kartochkalar, mashq va imtihon', () async {
      await p.scroll(900, ms: 2500);
      await p.wait(1500);
    });
    await p.go(Routes.studyCards('teaching.gmt'), after: 1800);
    p.screen('Kartochka');
    await p.caption(
      'Kartochkani aylantiring va o‘zingizni tekshiring',
      () async {
        await p.tapKey('study.reveal', after: 2200);
        p.screen('Kartochka: javob');
        await p.tapKey('study.knew', after: 1800);
      },
    );
    await p.go(Routes.studyQuiz('teaching.gmt'), after: 2200);
    p.screen('Test: savol');
    await p.caption('Test: javobni tanlang', () async {
      await p.tapKey('study.quiz.option.0', after: 1500);
      await p.tapKey('study.quiz.check', after: 2500);
      p.screen('Test: natija');
    });
    await p.caption(
      'Tekshiruvdan keyin tushuntirish va manba ko‘rsatiladi',
      () async {
        await p.scroll(450, ms: 1800);
        await p.wait(2000);
      },
    );
    p.finish();
  });
}
