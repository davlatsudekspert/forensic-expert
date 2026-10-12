import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo 06 sud kimyogar', (tester) async {
    final p = Promo(tester, 'promo_06_sud_kimyogar');
    await p.launch(mode: 'professional', pro: true);

    p.screen('Asosiy (Mutaxassis rejimi)');
    await p.caption(
      'Sud kimyogar uchun: usullar, reagentlar, TLC, GC-MS, LC-MS/MS',
      () async {
        await p.wait(2400);
        await p.scroll(700, ms: 2200);
        await p.wait(1200);
        await p.scrollTop();
      },
    );

    await p.go('/home/knowledge/method', after: 2000);
    p.screen('Usullar ro‘yxati');
    await p.caption(
      'Usullar: GC-MS, LC-MS/MS, TLC, UB-spektrofotometriya va boshqalar',
      () async {
        await p.wait(1500);
        await p.scroll(520, ms: 2000);
        await p.wait(1800);
        await p.scrollTop();
      },
    );
    await p.caption('GC-MS usuli: manbali tavsif va cheklovlar', () async {
      await p.tapText(
        'Gaz xromatografiyasi — mass-spektrometriya (GC-MS)',
        after: 2400,
      );
      p.screen('GC-MS');
      await p.scroll(520, ms: 2000);
      await p.wait(1600);
    });
    await p.back(after: 800);
    await p.caption('LC-MS/MS usuli', () async {
      await p.tapText(
        'LC-MS/MS (suyuqlik xromatografiyasi — tandem mass-spektrometriya)',
        after: 2400,
      );
      p.screen('LC-MS/MS');
      await p.scroll(520, ms: 2000);
      await p.wait(1400);
    });
    await p.back(after: 800);
    await p.caption('Yupqa qatlamli xromatografiya (TLC)', () async {
      await p.tapText('Yupqa qatlamli xromatografiya (TLC)', after: 2400);
      p.screen('TLC');
      await p.scroll(520, ms: 2000);
      await p.wait(1400);
    });

    // Reagentlar
    await p.go('/home/knowledge/reagent', after: 2000);
    p.screen('Reagentlar ro‘yxati');
    await p.caption('Reagentlar va eritmalar: 76 ta yozuv', () async {
      await p.wait(1000);
      await p.scroll(450, ms: 1800);
      await p.wait(1000);
    });
    await p.caption('Reagent: tarkib, xavf belgilari va tayyorlash', () async {
      await p.go(Routes.knowledgeEntry('reagent-dragendorff'), after: 2400);
      p.screen('Dragendorf reaktivi');
      await p.scroll(480, ms: 2000);
      await p.wait(2000);
      await p.scroll(480, ms: 2000);
      await p.wait(1800);
    });

    // Rangli testlar
    await p.go('/home/knowledge/screeningTest', after: 2000);
    p.screen('Ekspress va skrining testlari');
    await p.caption(
      'Ekspress va rangli testlar: skrining ≠ tasdiqlangan identifikatsiya',
      () async {
        await p.wait(2800);
        await p.tapText('Rangli (tomchi) testlar', after: 2400);
        p.screen('Rangli testlar');
        await p.scroll(480, ms: 2000);
        await p.wait(2000);
      },
    );

    // ABY + darslik
    await p.go(Routes.knowledgeEntry('aby-tox-opiates'), after: 2200);
    p.screen('ABY mavzusi: opiatlar');
    await p.caption(
      'ABY bo‘yicha usul matni — manba va aniq joyi bilan',
      () async {
        await p.wait(2000);
        await p.scroll(520, ms: 2000);
        await p.wait(2000);
        await p.scroll(520, ms: 2000);
        await p.wait(1800);
      },
    );
    await p.go(Routes.guideline('guideline.chem.gmt_opioids'), after: 2200);
    p.screen('Darslik: opiatlar');
    await p.caption('Darslik asosida: rangli reaksiyalar, TLC tizimlari, instrumental tasdiqlash', () async {
      await p.wait(1800);
      await p.reveal(
        find.text('Rangli, cho‘ktiruvchi va mikrokristall reaksiyalar').last,
        alignment: 0.1,
        after: 3000,
      );
      await p.reveal(
        find.text('TLC: tizimlar va aniqlash').last,
        alignment: 0.1,
        after: 3000,
      );
      p.screen('Darslik: TLC');
    });

    // Laboratoriya kalkulyatorlari
    await p.go(Routes.tool('tool.lab.dilution'), after: 1500);
    p.screen('Suyultirish kalkulyatori');
    await p.caption(
      'Laboratoriya kalkulyatori: suyultirish (C₁V₁ = C₂V₂)',
      () async {
        await p.type(
          find.descendant(
            of: find.byKey(const Key('calc.field.c1')),
            matching: find.byType(TextField),
          ),
          '10',
          after: 400,
        );
        await p.type(
          find.descendant(
            of: find.byKey(const Key('calc.field.c2')),
            matching: find.byType(TextField),
          ),
          '1',
          after: 400,
        );
        await p.type(
          find.descendant(
            of: find.byKey(const Key('calc.field.v2')),
            matching: find.byType(TextField),
          ),
          '100',
          after: 600,
        );
        await p.calc(after: 2600);
        p.screen('Suyultirish natijasi');
      },
    );
    p.finish();
  });
}
