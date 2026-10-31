import 'package:fe_content_schema/fe_content_schema.dart' show SourceLifecycle;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';
import 'package:forensic_expert/domain/learn/study_models.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';
import 'package:forensic_expert/features/home/daily_fact.dart';
import 'package:forensic_expert/features/home/daily_question.dart';
import 'package:forensic_expert/features/home/workbench.dart';

import '../helpers/home_desk_world.dart';
import '../helpers/study_fixtures.dart' show TestLibrary;

/// Ekspert «Ish stolim» + «Bugungi ma’lumot» va talaba «O‘qish stolim» +
/// «Bugungi savol» (egasi talabi, 2026-10-31).
void main() {
  Finder k(String key) => find.byKey(Key(key));

  String path(ProviderContainer c) => c
      .read(routerProvider)
      .routerDelegate
      .currentConfiguration
      .last
      .matchedLocation;

  Future<void> reveal(WidgetTester t, String key) async {
    await t.scrollUntilVisible(
      k(key),
      200,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 80,
    );
    await t.pumpAndSettle();
  }

  Future<void> tapCard(WidgetTester t, String key) async {
    await reveal(t, key);
    await t.tap(k(key));
    await t.pumpAndSettle();
  }

  group('mutaxassislik aniqlash', () {
    test('asosiy mutaxassislik hal qiladi', () {
      WorkbenchSpecialty of(Specialty s, [List<Specialty> a = const []]) =>
          workbenchSpecialtyOf(primary: s, additional: a);
      expect(of(Specialty.forensicMedicine), WorkbenchSpecialty.medicine);
      expect(of(Specialty.pathologyHistology), WorkbenchSpecialty.medicine);
      expect(of(Specialty.forensicToxicology), WorkbenchSpecialty.chemistry);
      expect(of(Specialty.forensicChemistry), WorkbenchSpecialty.chemistry);
      expect(of(Specialty.analyticalLaboratory), WorkbenchSpecialty.chemistry);
      expect(of(Specialty.other), WorkbenchSpecialty.mixed);
      expect(
        of(Specialty.other, [Specialty.forensicToxicology]),
        WorkbenchSpecialty.chemistry,
      );
      expect(
        of(Specialty.forensicMedicine, [Specialty.forensicChemistry]),
        WorkbenchSpecialty.medicine,
      );
      expect(workbenchSpecialtyOf(), WorkbenchSpecialty.mixed);
    });

    test('hozir hech bir band Pro bilan yopilmaydi', () {
      for (final id in WorkbenchItemId.values) {
        expect(workbenchProFeature(id), isNull, reason: id.name);
      }
    });
  });

  group('rol bo‘yicha ko‘rinish', () {
    testWidgets('sud-tibbiy ekspert: 4 karta', (t) async {
      await pumpHome(t, specialty: Specialty.forensicMedicine);
      expect(k('workbench.medicine'), findsOneWidget);
      expect(find.text('Ish stolim'), findsOneWidget);
      for (final id in ['casebook', 'courtPrep', 'calculators', 'ai']) {
        expect(k('workbench.$id'), findsOneWidget, reason: id);
      }
      expect(k('workbench.labMethods'), findsNothing);
      expect(find.text('Ish daftari'), findsOneWidget);
      expect(find.text('Sudda so‘roq'), findsOneWidget);
    });

    testWidgets('sud-kimyo/toksikologiya: keng karta + 4 band + 2 karta', (
      t,
    ) async {
      await pumpHome(t, specialty: Specialty.forensicToxicology);
      expect(k('workbench.chemistry'), findsOneWidget);
      expect(k('workbench.labMethods'), findsOneWidget);
      expect(find.text('Laboratoriya usullari'), findsOneWidget);
      // Tartib: Reaktivlar → Ekspress → Spektrofotometriya → GC-MS/LC-MS.
      final ys = [
        for (final id in ['labReagents', 'labExpress', 'labSpectro', 'labMs'])
          t.getTopLeft(k('workbench.$id')).dy,
      ];
      expect(ys, orderedEquals([...ys]..sort()));
      expect(find.text('Reaktivlar'), findsWidgets);
      expect(find.text('Ekspress test tahlillari'), findsOneWidget);
      expect(find.text('Spektrofotometriya usullari'), findsOneWidget);
      expect(find.text('GC-MS / LC-MS'), findsOneWidget);
      expect(k('workbench.solutionCalc'), findsOneWidget);
      expect(k('workbench.lodLoq'), findsOneWidget);
      // Takror yo‘q: kimyogarda daftar/sud kartalari yo‘q.
      expect(k('workbench.casebook'), findsNothing);
      expect(k('workbench.ai'), findsNothing);
    });

    testWidgets('noma’lum mutaxassislik (profil yo‘q): aralash 4 karta', (
      t,
    ) async {
      await pumpHome(t);
      expect(k('workbench.mixed'), findsOneWidget);
      for (final id in ['casebook', 'labMs', 'calculators', 'ai']) {
        expect(k('workbench.$id'), findsOneWidget, reason: id);
      }
      expect(k('workbench.labMethods'), findsNothing);
    });

    testWidgets('«Boshqa» mutaxassislik ham aralash', (t) async {
      await pumpHome(t, specialty: Specialty.other);
      expect(k('workbench.mixed'), findsOneWidget);
    });

    testWidgets('talaba va ustoz Home’ida Ish stolim yo‘q', (t) async {
      await pumpHome(t, mode: UserMode.student);
      expect(find.text('Ish stolim'), findsNothing);
      expect(k('workbench.mixed'), findsNothing);
      expect(k('desk.student'), findsOneWidget);
    });

    testWidgets('ustoz Home’i o‘zgarmagan: ish/o‘qish stoli yo‘q', (t) async {
      await pumpHome(t, mode: UserMode.teacher);
      expect(find.text('Ish stolim'), findsNothing);
      expect(find.text('O‘qish stolim'), findsNothing);
      expect(k('desk.student'), findsNothing);
      expect(k('workbench.mixed'), findsNothing);
      expect(k('home.teacher'), findsOneWidget);
    });

    testWidgets('ekspertda O‘qish stolim yo‘q', (t) async {
      await pumpHome(t);
      expect(find.text('O‘qish stolim'), findsNothing);
      expect(k('desk.student'), findsNothing);
    });

    for (final spec in [
      Specialty.forensicChemistry,
      Specialty.forensicMedicine,
    ]) {
      testWidgets('«Pro» / «tez orada» matni yo‘q: ${spec.name}', (t) async {
        await pumpHome(t, specialty: spec, lang: 'en');
        expect(find.textContaining(RegExp(r'\bPro\b')), findsNothing);
        expect(
          find.textContaining(RegExp('soon', caseSensitive: false)),
          findsNothing,
        );
      });
    }
  });

  group('har bir karta MAVJUD ekranni ochadi', () {
    final cases = <(String, Specialty?, String, String)>[
      (
        'casebook',
        Specialty.forensicMedicine,
        'workbench.casebook',
        '/tools/casebook',
      ),
      (
        'courtPrep',
        Specialty.forensicMedicine,
        'workbench.courtPrep',
        '/library/court-prep',
      ),
      (
        'calculators',
        Specialty.forensicMedicine,
        'workbench.calculators',
        '/tools',
      ),
      ('ai', Specialty.forensicMedicine, 'workbench.ai', '/ai'),
      (
        'labReagents',
        Specialty.forensicChemistry,
        'workbench.labReagents',
        '/home/knowledge/reagent',
      ),
      (
        'labExpress',
        Specialty.forensicChemistry,
        'workbench.labExpress',
        '/home/knowledge/screeningTest',
      ),
      (
        'labSpectro',
        Specialty.forensicChemistry,
        'workbench.labSpectro',
        '/home/tool/tool.lab.beer_lambert',
      ),
      (
        'labMs',
        Specialty.forensicChemistry,
        'workbench.labMs',
        '/home/knowledge/method',
      ),
      (
        'solutionCalc',
        Specialty.forensicChemistry,
        'workbench.solutionCalc',
        '/home/tool/tool.lab.solution',
      ),
      (
        'lodLoq',
        Specialty.forensicChemistry,
        'workbench.lodLoq',
        '/home/tool/tool.lab.lod_loq',
      ),
      ('mixed.labMs', null, 'workbench.labMs', '/home/knowledge/method'),
    ];
    for (final (name, spec, key, expected) in cases) {
      testWidgets(name, (t) async {
        final c = await pumpHome(t, specialty: spec);
        await tapCard(t, key);
        expect(path(c), expected);
        expect(find.byType(ErrorWidget), findsNothing);
        expect(t.takeException(), isNull);
      });
    }
  });

  group('bugungi ma’lumot', () {
    final pool = TestLibrary([
      deskSubstance('alpha', [
        deskClaim(
          'C-a1',
          locator: {
            'uz': 'Yuldashev Z.A., «Toksikologik kimyo» (2025), 32-bet',
          },
        ),
      ]),
      deskSubstance('beta', [deskClaim('C-b1')]),
      // Chiqmaydigan yozuvlar:
      deskSubstance('testdata', [deskClaim('C-t1')], testData: true),
      deskSubstance('nosrc', [deskClaim('C-n1', sources: const [])]),
      deskSubstance('retracted', [
        deskClaim(
          'C-r1',
          sources: [deskSource('S-r', lifecycle: SourceLifecycle.retracted)],
        ),
      ]),
    ]);
    final knowledge = ListKnowledgeRepository([
      deskTopic('fm-1', [deskClaim('C-f1')]),
    ]);

    DailyFact? pick(DateTime d, WorkbenchSpecialty s, [String lang = 'uz']) =>
        pickDailyFact(
          library: pool,
          knowledge: knowledge,
          specialty: s,
          lang: lang,
          today: d,
        );

    test('bir kunda bir xil, ertasi kuni boshqa', () {
      final d = DateTime(2026, 10, 31);
      final a = pick(d, WorkbenchSpecialty.mixed)!;
      expect(
        pick(DateTime(2026, 10, 31, 23, 59), WorkbenchSpecialty.mixed)!.claimId,
        a.claimId,
      );
      expect(
        pick(DateTime(2026, 11, 1), WorkbenchSpecialty.mixed)!.claimId,
        isNot(a.claimId),
      );
    });

    test('faqat manbali va yaroqli da’volar tanlanadi', () {
      final seen = <String>{};
      for (var i = 0; i < 12; i++) {
        final f = pick(DateTime(2026, 10, 1 + i), WorkbenchSpecialty.mixed)!;
        seen.add(f.claimId);
        expect(f.source.trim(), isNotEmpty);
      }
      expect(seen, {'C-a1', 'C-b1', 'C-f1'});
    });

    test('mutaxassislikka mos: tibbiyot — mavzu, kimyo — modda', () {
      for (var i = 0; i < 6; i++) {
        final d = DateTime(2026, 10, 1 + i);
        expect(pick(d, WorkbenchSpecialty.medicine)!.claimId, 'C-f1');
        expect(pick(d, WorkbenchSpecialty.chemistry)!.claimId, isNot('C-f1'));
      }
    });

    test('mos yozuv bo‘lmasa ham manbali yozuvdan biri (zaxira)', () {
      final only = pickDailyFact(
        library: pool,
        knowledge: const EmptyKnowledgeRepository(),
        specialty: WorkbenchSpecialty.medicine,
        lang: 'uz',
        today: DateTime(2026, 10, 31),
      );
      expect(only, isNotNull);
    });

    test('manba satri paketdagi locator_i18n aynan', () {
      final f = pickDailyFact(
        library: TestLibrary([pool.byId('alpha')!]),
        knowledge: const EmptyKnowledgeRepository(),
        specialty: WorkbenchSpecialty.chemistry,
        lang: 'uz',
        today: DateTime(2026, 10, 31),
      )!;
      expect(f.source, 'Yuldashev Z.A., «Toksikologik kimyo» (2025), 32-bet');
      expect(f.route, '/home/substance/alpha');
      // locator yo‘q: birinchi manbaning saqlangan maydonlari.
      final g = pickDailyFact(
        library: TestLibrary([pool.byId('beta')!]),
        knowledge: const EmptyKnowledgeRepository(),
        specialty: WorkbenchSpecialty.chemistry,
        lang: 'uz',
        today: DateTime(2026, 10, 31),
      )!;
      expect(g.source, 'Source book S-C-b1 · Series X · 2024 · p. 32');
    });

    test('yaroqli yozuv yo‘q bo‘lsa — null', () {
      expect(
        pickDailyFact(
          library: TestLibrary([pool.byId('testdata')!, pool.byId('nosrc')!]),
          knowledge: const EmptyKnowledgeRepository(),
          specialty: WorkbenchSpecialty.mixed,
          lang: 'uz',
          today: DateTime(2026, 10, 31),
        ),
        isNull,
      );
    });

    test('faqat o‘zbekcha yozuv: ru da asl matn + tarjima kutilmoqda', () {
      final f = pick(
        DateTime(2026, 10, 31),
        WorkbenchSpecialty.chemistry,
        'ru',
      )!;
      expect(f.translationPending, isTrue);
      expect(f.excerpt, contains('Statement text'));
    });

    testWidgets('karta: sarlavha, 2 qator, manba; bosilsa — to‘liq yozuv', (
      t,
    ) async {
      final c = await pumpHome(
        t,
        specialty: Specialty.forensicChemistry,
        library: TestLibrary([pool.byId('alpha')!]),
        knowledge: const EmptyKnowledgeRepository(),
      );
      expect(find.text('Bugungi ma’lumot'), findsOneWidget);
      expect(k('workbench.dailyFact.title'), findsOneWidget);
      final excerpt = t.widget<Text>(k('workbench.dailyFact.excerpt'));
      expect(excerpt.maxLines, 2);
      final source = t.widget<Text>(k('workbench.dailyFact.source'));
      expect(
        source.data,
        'Manba: Yuldashev Z.A., «Toksikologik kimyo» (2025), 32-bet',
      );
      await tapCard(t, 'workbench.dailyFact');
      expect(path(c), '/home/substance/alpha');
    });

    testWidgets('yaroqli yozuv yo‘q: karta yashirin', (t) async {
      await pumpHome(t, specialty: Specialty.forensicChemistry);
      expect(k('workbench.dailyFact'), findsNothing);
      expect(find.text('Bugungi ma’lumot'), findsNothing);
      // Ish stoli esa bor.
      expect(k('workbench.chemistry'), findsOneWidget);
    });

    test('provayder: soat qotirilgan — bir xil, ertasi kuni boshqa', () {
      String titleAt(DateTime d) {
        final c = ProviderContainer(
          overrides: [
            libraryRepositoryProvider.overrideWithValue(pool),
            knowledgeRepositoryProvider.overrideWithValue(knowledge),
            workbenchClockProvider.overrideWithValue(() => d),
          ],
        );
        addTearDown(c.dispose);
        return c.read(dailyFactProvider('uz'))!.claimId;
      }

      final a = titleAt(DateTime(2026, 10, 31, 8));
      expect(titleAt(DateTime(2026, 10, 31, 22)), a);
      expect(titleAt(DateTime(2026, 11, 1, 8)), isNot(a));
    });
  });

  group('o‘lcham va til', () {
    for (final spec in [
      Specialty.forensicMedicine,
      Specialty.forensicChemistry,
      null,
    ]) {
      testWidgets('320 dp va 2x matn: ${spec?.name ?? 'mixed'} overflow yo‘q', (
        t,
      ) async {
        await pumpHome(
          t,
          specialty: spec,
          size: const Size(320, 640),
          textScale: 2,
          library: pool0,
          knowledge: deskKnowledge,
        );
        expect(t.takeException(), isNull);
        await reveal(t, 'workbench.dailyFact');
        expect(k('workbench.dailyFact'), findsOneWidget);
        expect(t.takeException(), isNull);
      });
    }

    testWidgets('390 dp, 1.3x: kimyo bloki overflow yo‘q', (t) async {
      await pumpHome(
        t,
        specialty: Specialty.forensicToxicology,
        textScale: 1.3,
      );
      expect(t.takeException(), isNull);
    });

    for (final (lang, title, lab) in [
      ('uz', 'Ish stolim', 'Laboratoriya usullari'),
      ('ru', 'Мой рабочий стол', 'Лабораторные методы'),
      ('en', 'My workbench', 'Laboratory methods'),
    ]) {
      testWidgets('til: $lang', (t) async {
        await pumpHome(t, lang: lang, specialty: Specialty.forensicChemistry);
        expect(find.text(title), findsOneWidget);
        expect(find.text(lab), findsOneWidget);
        expect(t.takeException(), isNull);
      });
    }

    testWidgets('qorong‘i mavzu: overflow yo‘q', (t) async {
      await pumpHome(
        t,
        specialty: Specialty.forensicChemistry,
        theme: ThemeMode.dark,
      );
      expect(t.takeException(), isNull);
    });
  });

  group('talaba: O‘qish stolim', () {
    final items = [for (var i = 1; i <= 4; i++) deskQuestionItem(i)];
    final catalog = deskCatalog(items);

    test('bugungi savol aniq, manbali va betli', () {
      final d = DateTime(2026, 10, 31);
      final a = pickDailyQuestion(catalog: catalog, lang: 'uz', today: d)!;
      final a2 = pickDailyQuestion(
        catalog: catalog,
        lang: 'uz',
        today: DateTime(2026, 10, 31, 23),
      )!;
      expect(a2.item.id, a.item.id);
      expect(
        [for (var i = 0; i < 4; i++) a2.optionText(i).values['uz']],
        [for (var i = 0; i < 4; i++) a.optionText(i).values['uz']],
      );
      expect(
        pickDailyQuestion(
          catalog: catalog,
          lang: 'uz',
          today: DateTime(2026, 11, 1),
        )!.item.id,
        isNot(a.item.id),
      );
      expect(a.item.citations.single.pages, '45-46');
    });

    test('manbasiz/betsiz/test ma’lumoti savol tanlanmaydi', () {
      final bad = deskCatalog([
        deskQuestionItem(1, pages: null),
        deskQuestionItem(2, pages: null),
      ]);
      expect(
        pickDailyQuestion(
          catalog: bad,
          lang: 'uz',
          today: DateTime(2026, 10, 31),
        ),
        isNull,
      );
      expect(
        pickDailyQuestion(
          catalog: StudyCatalog.empty,
          lang: 'uz',
          today: DateTime(2026, 10, 31),
        ),
        isNull,
      );
    });

    for (final (key, expected) in [
      ('deskLessons', '/home/learn'),
      ('deskTests', '/home/learn/study'),
      ('deskExam', '/home/learn/exam'),
      ('deskGroup', '/home/learn/groups'),
    ]) {
      testWidgets('karta $key mavjud ekranni ochadi', (t) async {
        final c = await pumpHome(t, mode: UserMode.student, catalog: catalog);
        expect(find.text('O‘qish stolim'), findsOneWidget);
        await tapCard(t, 'workbench.$key');
        expect(path(c), expected);
        expect(t.takeException(), isNull);
      });
    }

    testWidgets('savolga karta ustida javob beriladi, manba ko‘rinadi', (
      t,
    ) async {
      final c = await pumpHome(t, mode: UserMode.student, catalog: catalog);
      await reveal(t, 'desk.dailyQuestion');
      expect(find.text('Bugungi savol'), findsOneWidget);
      final src = t.widget<Text>(k('desk.dailyQuestion.source')).data!;
      expect(src, contains('Toksikologik kimyo (kitob)'));
      expect(src, contains('45-46'));
      expect(k('desk.dailyQuestion.feedback'), findsNothing);
      expect(k('desk.dailyQuestion.explain'), findsNothing);
      await t.tap(k('desk.dailyQuestion.option.0'));
      await t.pumpAndSettle();
      expect(k('desk.dailyQuestion.feedback'), findsOneWidget);
      await reveal(t, 'desk.dailyQuestion.explain');
      await t.tap(k('desk.dailyQuestion.explain'));
      await t.pumpAndSettle();
      expect(path(c), '/home/learn/study/teaching.test/quiz');
    });

    testWidgets('yaroqli savol yo‘q: karta yashirin', (t) async {
      await pumpHome(t, mode: UserMode.student);
      expect(k('desk.dailyQuestion'), findsNothing);
      expect(k('desk.student'), findsOneWidget);
    });

    for (final lang in ['uz', 'ru', 'en']) {
      testWidgets('320 dp, 2x matn, $lang: overflow yo‘q', (t) async {
        await pumpHome(
          t,
          mode: UserMode.student,
          lang: lang,
          catalog: catalog,
          size: const Size(320, 640),
          textScale: 2,
        );
        final title = const {
          'uz': 'O‘qish stolim',
          'ru': 'Мой учебный стол',
          'en': 'My study desk',
        }[lang]!;
        await t.scrollUntilVisible(
          find.text(title),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(title), findsOneWidget);
        await reveal(t, 'desk.dailyQuestion');
        await t.tap(k('desk.dailyQuestion.option.1'));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull, reason: lang);
      });
    }
  });
}

final pool0 = TestLibrary([
  deskSubstance('alpha', [
    deskClaim(
      'C-a1',
      locator: {'uz': 'Yuldashev Z.A., «Toksikologik kimyo» (2025), 32-bet'},
    ),
  ]),
]);
