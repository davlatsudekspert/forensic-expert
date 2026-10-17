import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo 02 sud toksikolog', (tester) async {
    final p = Promo(tester, 'promo_02_sud_toksikolog');
    await p.launch(mode: 'professional', pro: true);

    p.screen('Asosiy (Mutaxassis rejimi)');
    await p.caption('Sud toksikolog uchun: modda → tahlil → usul', () async {
      await p.wait(2500);
      await p.scroll(420, ms: 1800);
      await p.wait(1000);
      await p.scrollTop();
    });

    await p.go(Routes.module('toxicology'), after: 1500);
    p.screen('Sud toksikologiyasi bo‘limi');
    await p.caption(
      'Sud toksikologiyasi: vositalar va manbali mavzular',
      () async {
        await p.wait(1500);
        await p.scroll(500, ms: 1800);
        await p.wait(1500);
      },
    );

    // Modda sahifasi (etanol)
    await p.go(Routes.libraryEntry('ethanol'), after: 2200);
    p.screen('Etanol');
    await p.caption('Modda sahifasi: formula, usullar, metabolitlar', () async {
      await p.wait(2600);
    });
    await p.caption(
      'Tahlil bo‘limi: qaysi namuna va qaysi usul — manbalar asosida',
      () async {
        await p.tapText('Tahlil', after: 1000);
        await p.reveal(find.text('Tahlil').last, alignment: 0.05, after: 1800);
        p.screen('Etanol: Tahlil');
      },
    );
    await p.caption(
      'Analitik usullar va ularning cheklovlari — manbalardan',
      () async {
        await p.scroll(520, ms: 2000);
        await p.wait(2200);
        await p.scroll(450, ms: 1800);
        await p.wait(1800);
        p.screen('Etanol: usullar');
      },
    );

    // Tahlil rejasi (Pro)
    await p.go(Routes.homePlan('morphine'), after: 2200);
    p.screen('Morfin: tahlil rejasi');
    await p.caption(
      'Modda bo‘yicha tahlil rejasi: namuna, skrining, tasdiqlash',
      () async {
        await p.wait(2200);
        await p.scroll(520, ms: 2000);
        await p.wait(2200);
        p.screen('Morfin: tahlil rejasi, davomi');
      },
    );

    // Namunalar
    await p.go(Routes.specimens, after: 1800);
    p.screen('Namunalar');
    await p.caption(
      'Namunalar: qon, zardob, siydik, soch va boshqalar',
      () async {
        await p.wait(1800);
        await p.tapText('Qon', after: 2200);
        p.screen('Namuna: qon');
        await p.scroll(600, ms: 2000);
        await p.wait(1800);
      },
    );

    // Darslik usullari
    await p.go(Routes.guideline('guideline.chem.toks_isolation'), after: 2000);
    p.screen('Yo‘riqnoma: ajratib olish');
    await p.caption(
      'Darslik asosidagi usullar: ajratib olish — muallif ruxsati bilan',
      () async {
        await p.wait(2600);
        await p.scroll(520, ms: 2000);
        await p.wait(1800);
        await p.reveal(
          find.text('Usullar va bosqichlar'),
          alignment: 0.1,
          after: 2500,
        );
        p.screen('Yo‘riqnoma: usullar va bosqichlar');
      },
    );
    // Kalkulyatorlar
    await p.go(Routes.tools, after: 1800);
    p.screen('Vositalar');
    await p.caption(
      'Kalkulyatorlar: formula, taxmin va cheklovlar ko‘rsatiladi',
      () async {
        await p.scroll(400, ms: 1600);
        await p.wait(1500);
        await p.scrollTop();
      },
    );
    await p.go(Routes.tool('tool.tox.widmark'), after: 1500);
    p.screen('Widmark kalkulyatori');
    await p.caption(
      'Widmark: hisoblash namunasi uchun qiymatlar kiritiladi',
      () async {
        await p.type(find.byKey(const Key('calc.weight')), '80', after: 500);
        await p.type(
          find.byKey(const Key('calc.drink.0.volume')),
          '500',
          after: 500,
        );
        await p.type(
          find.byKey(const Key('calc.drink.0.abv')),
          '40',
          after: 500,
        );
        await p.type(find.byKey(const Key('calc.hours')), '2', after: 800);
      },
    );
    await p.caption(
      'Natija diapazon bilan, formula va cheklovlari yonida ko‘rsatiladi',
      () async {
        await p.calc(after: 2500);
        p.screen('Widmark natijasi');
        await p.scroll(420, ms: 1800);
        await p.wait(1800);
      },
    );
    p.finish();
  });
}
