import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:integration_test/integration_test.dart';

import 'promo_env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('promo 03 sud tibbiy', (tester) async {
    final p = Promo(tester, 'promo_03_sud_tibbiy');
    await p.launch(mode: 'professional', pro: true);

    p.screen('Asosiy (Mutaxassis rejimi)');
    await p.caption(
      'Sud-tibbiy ekspert uchun: mavzular, kalkulyatorlar, sudga tayyorgarlik',
      () async {
        await p.wait(2400);
        await p.scroll(900, ms: 2400);
        await p.wait(1200);
        await p.scrollTop();
      },
    );

    await p.go(Routes.forensicMedicine, after: 1800);
    p.screen('Sud tibbiyoti bo‘limi');
    await p.caption(
      'Sud tibbiyoti: 25 mavzudan 19 tasida manbali ma’lumot bor',
      () async {
        await p.wait(2000);
        await p.scroll(480, ms: 1800);
        await p.wait(1600);
      },
    );
    await p.caption(
      'O‘limdan keyingi o‘zgarishlar: sovish, qotish, murda dog‘lari',
      () async {
        await p.reveal(
          find.text('O‘limdan keyingi o‘zgarishlar'),
          alignment: 0.15,
          after: 2200,
        );
        p.screen('Sud tibbiyoti: o‘limdan keyingi o‘zgarishlar');
      },
    );
    await p.caption(
      'Mavzu sahifasi: manba va tekshiruv holati bilan',
      () async {
        await p.tapText('Murda dog‘lari (livor mortis)', after: 2500);
        p.screen('Mavzu: murda dog‘lari');
        await p.scroll(520, ms: 2000);
        await p.wait(2200);
      },
    );

    // Henssge
    await p.go(Routes.tool('tool.fm.pmi_henssge'), after: 1500);
    p.screen('Henssge kalkulyatori');
    await p.caption(
      'PMI — Henssge: rektal va muhit harorati, tana vazni kiritiladi',
      () async {
        await p.type(find.byKey(const Key('calc.rectal')), '30', after: 500);
        await p.type(find.byKey(const Key('calc.ambient')), '15', after: 500);
        await p.type(find.byKey(const Key('calc.weight')), '70', after: 800);
      },
    );
    await p.caption(
      'Natija formula va cheklovlari bilan birga ko‘rsatiladi',
      () async {
        await p.calc(after: 2800);
        p.screen('Henssge natijasi');
      },
    );

    // Widmark
    await p.go(Routes.tool('tool.tox.widmark'), after: 1200);
    p.screen('Widmark kalkulyatori');
    await p.caption('Qondagi alkogol (Widmark): diapazonli baho', () async {
      await p.type(find.byKey(const Key('calc.weight')), '80', after: 400);
      await p.type(
        find.byKey(const Key('calc.drink.0.volume')),
        '500',
        after: 400,
      );
      await p.type(find.byKey(const Key('calc.drink.0.abv')), '40', after: 400);
      await p.type(find.byKey(const Key('calc.hours')), '2', after: 600);
      await p.calc(after: 2500);
      p.screen('Widmark natijasi');
    });

    // Ish daftari
    await p.go(Routes.casebook, after: 1800);
    p.screen('Ekspert ish daftari');
    await p.caption(
      'Ekspert ish daftari: yozuvlar faqat shu qurilmada saqlanadi',
      () async {
        await p.wait(3000);
      },
    );
    await p.caption('Yangi yozuv: sarlavha va izoh', () async {
      await p.tapKey('casebook.new', after: 1800);
      p.screen('Yangi yozuv');
      await p.type(
        find.byKey(const Key('casebook.field.title')),
        'Namuna yozuv',
        after: 700,
      );
      await p.type(
        find.byKey(const Key('casebook.field.body')),
        'Mavzu bo‘yicha qisqa eslatma.',
        after: 1500,
      );
    });
    await p.caption(
      'Yo‘riqnoma kartalaridagi manbali cheklovlarni yozuvga qo‘shish mumkin',
      () async {
        await p.tapKey('casebook.addBlock', after: 2200);
        p.screen('Blok tanlash');
        await p.wait(1800);
      },
    );
    await p.back(after: 800);

    // Sudga tayyorgarlik
    await p.go(Routes.courtPrep, after: 2000);
    p.screen('Sudda so‘roq: tayyorgarlik');
    await p.caption(
      'Sudda so‘roq: tayyorgarlik — yuridik maslahat emas, o‘quv materiali',
      () async {
        await p.wait(2500);
        await p.scroll(450, ms: 1800);
        await p.wait(1500);
      },
    );
    await p.go(Routes.courtPrepPrinciples, after: 2000);
    p.screen('Halollik tamoyillari');
    await p.caption('Tamoyillar: har biri manba va aniq joyi bilan', () async {
      await p.wait(1500);
      await p.scroll(480, ms: 1800);
      await p.wait(1500);
    });
    await p.go(Routes.courtPrepScenario('court.sim.colour_test'), after: 2000);
    p.screen('Simulyator: ssenariy');
    await p.caption(
      'Sud simulyatori: savolga javob variantini tanlang',
      () async {
        await p.wait(1800);
        await p.scroll(420, ms: 1800);
        await p.tapKey('court.sim.option.1', after: 1500);
        await p.tapKey('court.sim.check', after: 1500);
        await p.reveal(
          find.byKey(const Key('court.sim.result')),
          alignment: 0.05,
          after: 2800,
        );
        p.screen('Simulyator: natija');
      },
    );
    p.finish();
  });
}
