import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/domain/pro/pro_search.dart';

import '../helpers/fake_store.dart';
import '../helpers/pilot_content.dart';
import '../helpers/pump_app.dart';

/// Pro vositalar: «Tahlil rejasi» ekrani (bepul ko‘rinish / Pro; uz/ru/en;
/// 320 dp; qorong‘i rejim) va kengaytirilgan qidiruv — HAQIQIY pilot paket.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  Future<ProviderContainer> open(
    WidgetTester tester,
    String location, {
    bool pro = true,
    String lang = 'uz',
    Size size = const Size(390, 844),
    ThemeMode theme = ThemeMode.light,
  }) => pumpApp(
    tester,
    settings: completedSettings(lang: lang, theme: theme),
    size: size,
    initialLocation: location,
    platformBrightness: theme == ThemeMode.dark
        ? Brightness.dark
        : Brightness.light,
    testFixtures: false,
    overrides: [
      ...pilot.overrides,
      entitlementServiceProvider.overrideWithValue(FakeStore(owned: pro)),
    ],
  );

  Future<void> see(WidgetTester tester, Finder f) async {
    // Lazy ListView: element hali qurilmagan bo‘lishi mumkin.
    for (var i = 0; i < 60 && f.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pump();
    }
    expect(f, findsWidgets);
    await tester.ensureVisible(f.first);
    await tester.pumpAndSettle();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final f = find.byKey(Key(key));
    await see(tester, f);
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  Finder block(String k) => find.byKey(Key('plan.block.$k'));

  group('Tahlil rejasi', () {
    testWidgets('bepul: qisqa ko‘rinish va tarif taklifi, to‘liq reja yo‘q', (
      tester,
    ) async {
      await open(tester, Routes.homePlan('cocaine'), pro: false);
      expect(find.byKey(const Key('plan.preview')), findsOneWidget);
      expect(find.byKey(const Key('plan.summary')), findsOneWidget);
      expect(find.byKey(const Key('plan.unlock')), findsOneWidget);
      // Namunalar nomi ko‘rinadi, tafsilot va nusxalash yo‘q.
      expect(find.byKey(const Key('plan.preview.specimens')), findsOneWidget);
      expect(block('presumptive'), findsNothing);
      expect(block('reminder'), findsNothing);
      expect(find.byKey(const Key('plan.copy')), findsNothing);
    });

    testWidgets('kirish kartasi modda sahifasida (bepulda ham) va ochadi', (
      tester,
    ) async {
      await open(tester, Routes.libraryEntry('ethanol'), pro: false);
      final entry = find.byKey(const Key('analysis.plan.entry.ethanol'));
      await see(tester, entry);
      await tester.tap(entry);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('plan.preview')), findsOneWidget);
    });

    testWidgets('Pro: kokain — 8 blok, har iqtibosda manba + joy + holat', (
      tester,
    ) async {
      await open(tester, Routes.homePlan('cocaine'));
      for (final k in [
        'specimens',
        'presumptive',
        'bench',
        'confirmation',
        'instrumental',
        'interferences',
        'limits',
        'reminder',
      ]) {
        expect(block(k), findsOneWidget, reason: k);
      }
      expect(find.byKey(const Key('plan.unlock')), findsNothing);
      // Skrining → tasdiqlash: GC-MS va LC-MS/MS «Tasdiqlash shart».
      await see(tester, find.byKey(const Key('plan.confirm.method-gcms')));
      await see(tester, find.byKey(const Key('plan.confirm.method-lcmsms')));
      expect(find.text('Tasdiqlash shart'), findsWidgets);
      // Manba va uning ichidagi joy — iqtibos ostida.
      expect(find.textContaining('Manba: '), findsWidgets);
      expect(find.textContaining('Manbadagi joyi: '), findsWidgets);
      // Hech narsa «Tasdiqlangan» emas; holat ko‘rinadi.
      expect(find.text('Tekshirilmagan'), findsWidgets);
      expect(find.text('Tasdiqlangan'), findsNothing);
      // Reagent juftligi paketda yo‘q — halol aytiladi (to‘qib chiqarilmaydi).
      expect(find.byKey(const Key('plan.noReagents')), findsWidgets);
      // Mahalliy sharoitdagi usullar qo‘shilgandan keyin kokain uchun stol
      // usti usullari (rang sinamasi, mikrokristall, TLC) paketda bor, shuning
      // uchun bo‘lim endi bo‘sh emas.
      expect(find.byKey(const Key('plan.empty.bench')), findsNothing);
      // Xulosa uchun eslatma: skrining aniq identifikatsiya emas.
      await see(tester, find.byKey(const Key('plan.reminder.presumptiveOnly')));
      expect(
        find.byKey(const Key('plan.reminder.confirmationDocumented')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('plan.reminder.nothingVerified')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Pro: morfin — metod namunaga bog‘lanmagan, skrining yo‘q', (
      tester,
    ) async {
      await open(tester, Routes.homePlan('morphine'));
      // Morfin uchun ham skrining sinamalari qo‘shildi (rang, mikrokristall,
      // immunoanaliz), shuning uchun «bo‘sh» holati endi kutilmaydi.
      expect(find.byKey(const Key('plan.empty.presumptive')), findsNothing);
      // Skrining qo‘shilgandan keyin LC-MS/MS morfin uchun «tasdiqlovchi»
      // bo‘limiga o‘tdi — alohida instrumental usul sifatida emas.
      await see(tester, find.byKey(const Key('plan.confirm.method-lcmsms')));
      // «Usullar namunaga bog‘lanmagan» ogohlantirishi instrumental bo‘lim
      // bilan birga chiqadi; morfinda LC-MS/MS tasdiqlovchi bo‘limga o‘tgani
      // uchun instrumental bo‘lim bo‘sh va ogohlantirish u yerda ko‘rinmaydi.
      expect(find.byKey(const Key('plan.notPaired')), findsNothing);
      expect(find.byKey(const Key('plan.empty.instrumental')), findsOneWidget);
      expect(
        find.byKey(const Key('plan.reminder.methodsNotPaired')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('plan.reminder.confirmationNotDocumented')),
        findsNothing,
      );
    });

    testWidgets('Pro: ma’lumoti yo‘q modda (GHB) — halol bo‘sh holat', (
      tester,
    ) async {
      await open(tester, Routes.homePlan('ghb'));
      expect(find.byKey(const Key('plan.noData')), findsOneWidget);
      expect(find.byKey(const Key('plan.copy')), findsNothing);
    });

    testWidgets('nusxalash: to‘liq iqtiboslar, raqamli manbalar ro‘yxati', (
      tester,
    ) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await open(tester, Routes.homePlan('cocaine'));
      await tapKey(tester, 'plan.copy');
      expect(find.text('Reja to‘liq iqtiboslari bilan nusxalandi'), findsOne);
      final text = copied!;
      expect(text, startsWith('TAHLIL REJASI — Kokain'));
      expect(text, contains('MANBALAR'));
      expect(text, contains('XULOSA UCHUN ESLATMA'));
      // Iqtibos raqamli havola va manbadagi joy bilan.
      expect(text, matches(RegExp(r'\[\d+, § ')));
      // Tarjima asl matn bilan birga, holat aytilgan.
      expect(text, contains('Asl matn:'));
      expect(text, contains('Avtomatik tarjima — tekshirilmagan'));
      // Manbalar ro‘yxati: GOST, DOI bilan.
      expect(text, contains('DOI: 10.'));
      expect(text, isNot(contains('holati: Tasdiqlangan')));
    });

    for (final lang in ['uz', 'ru', 'en']) {
      for (final dark in [false, true]) {
        testWidgets(
          'Pro, 320 dp, ${dark ? 'qorong‘i' : 'yorug‘'}, $lang: toshmaydi',
          (tester) async {
            await open(
              tester,
              Routes.homePlan('fentanyl'),
              lang: lang,
              size: const Size(320, 640),
              theme: dark ? ThemeMode.dark : ThemeMode.light,
            );
            expect(block('reminder'), findsOneWidget);
            await see(tester, block('limits'));
            await see(tester, block('reminder'));
            expect(tester.takeException(), isNull);
            // Til ustiga mos sarlavha.
            expect(
              find.textContaining(switch (lang) {
                'uz' => 'Xulosa uchun eslatma',
                'ru' => 'Памятка для заключения',
                _ => 'Note for the conclusion',
              }),
              findsWidgets,
            );
          },
        );
      }
    }

    testWidgets('bepul ko‘rinish 320 dp, ru: toshmaydi', (tester) async {
      await open(
        tester,
        Routes.homePlan('cocaine'),
        pro: false,
        lang: 'ru',
        size: const Size(320, 640),
      );
      expect(find.byKey(const Key('plan.unlock')), findsOneWidget);
      expect(find.textContaining('Полный план анализа'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Kengaytirilgan qidiruv', () {
    testWidgets('oddiy qidiruvda kirish bor; bepul: taklif, filtrlar yo‘q', (
      tester,
    ) async {
      await open(tester, Routes.searchWith('morfin'), pro: false);
      final entry = find.byKey(const Key('search.pro.entry'));
      expect(entry, findsOneWidget);
      // Oddiy qidiruv o‘zgarmagan.
      expect(find.byKey(const Key('search.hit.morphine')), findsWidgets);
      await tester.tap(entry);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pro.preview')), findsOneWidget);
      expect(find.byKey(const Key('pro.unlock')), findsOneWidget);
      expect(find.byKey(const Key('pro.field')), findsNothing);
    });

    testWidgets('Pro: matn + namuna filtri + bo‘sh natija + tozalash', (
      tester,
    ) async {
      await open(tester, Routes.proSearch);
      expect(find.byKey(const Key('pro.start')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('pro.field')), 'morfin');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pro.hit.morphine')), findsOneWidget);
      // Aniq moslik: «morfin» to‘liq nom — yana topiladi, «morf» — yo‘q.
      await tapKey(tester, 'pro.exact');
      expect(find.byKey(const Key('pro.hit.morphine')), findsOneWidget);
      await tester.enterText(find.byKey(const Key('pro.field')), 'morf');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pro.noResults')), findsOneWidget);
      await tapKey(tester, 'pro.exact');
      expect(find.byKey(const Key('pro.hit.morphine')), findsOneWidget);
      // Namuna filtri: faqat paketda qiymati bor namunalar tanlanadi (qon).
      await tapKey(tester, 'pro.facet.specimen');
      expect(find.byKey(const Key('pro.facet.specimen.urine')), findsNothing);
      await tapKey(tester, 'pro.facet.specimen.blood');
      expect(find.byKey(const Key('pro.hit.morphine')), findsOneWidget);
      // Namunasi yo‘q modda (etanol) bu filtr bilan topilmaydi.
      await tester.enterText(find.byKey(const Key('pro.field')), 'etanol');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pro.noResults')), findsOneWidget);
      // Tozalash.
      await tester.tap(find.text('Filtrlarni tozalash'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pro.hit.ethanol')), findsOneWidget);
    });

    testWidgets('Pro: teskari qidiruv — namuna → analitlar, metod → moddalar', (
      tester,
    ) async {
      await open(tester, Routes.proSearch);
      await tapKey(tester, 'pro.tab.reverse');
      await tapKey(tester, 'pro.reverse.target.blood');
      expect(find.byKey(const Key('pro.reverse.hit.morphine')), findsOneWidget);
      await tapKey(tester, 'pro.reverse.mode.method');
      await tapKey(tester, 'pro.reverse.target.method-lcmsms');
      expect(find.byKey(const Key('pro.reverse.hit.morphine')), findsOneWidget);
      // Reagent → moddalar: paketda bog‘lanish bo‘lmasa halol aytiladi.
      await tapKey(tester, 'pro.reverse.mode.reagent');
      final linked = ProSearchIndex.build(
        library: pilot.library,
        knowledge: pilot.knowledge,
        evidence: pilot.evidence,
        provenance: pilot.provenance,
      ).linkedReagentIds;
      if (linked.isEmpty) {
        expect(find.byKey(const Key('pro.reverse.none')), findsOneWidget);
      } else {
        expect(
          find.byKey(Key('pro.reverse.target.${linked.first}')),
          findsWidgets,
        );
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('Pro, 320 dp, qorong‘i, ru: toshmaydi', (tester) async {
      await open(
        tester,
        Routes.proSearch,
        lang: 'ru',
        size: const Size(320, 640),
        theme: ThemeMode.dark,
      );
      expect(find.text('Расширенный поиск'), findsOneWidget);
      await tapKey(tester, 'pro.facet.family');
      expect(tester.takeException(), isNull);
    });
  });
}
