import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/lessons.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/study.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/widgets/pro_lock_card.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/data/lessons/fake_lessons_service.dart';
import 'package:forensic_expert/domain/guidelines/guideline_models.dart';
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';
import 'package:forensic_expert/domain/learn/study_models.dart';
import 'package:forensic_expert/domain/library/library_models.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';

import '../helpers/plan_fakes.dart';
import '../helpers/pump_app.dart';
import '../helpers/study_fixtures.dart';

/// Pro (0.4.0) gate’lari. Egasi qarori (2026-10-24): har funksiya KO‘RINADI,
/// Pro bo‘lmasa qulf bilan; reja faqat o‘z rejimini ochadi (rejimni
/// almashtirish huquq bermaydi); xavfsizlik, manbalar va provenance
/// HECH QACHON qulf ortida emas. (Eski «hammasi bepul» testi shu haqiqatga
/// moslab qayta yozildi.)
void main() {
  Finder lockOn(String key) => find.descendant(
    of: find.byKey(Key(key), skipOffstage: false),
    matching: find.byIcon(Icons.lock_outline),
  );

  group('Doim bepul (reja yo‘q)', () {
    testWidgets('qidiruv: barcha natijalar ko‘rinadi, «yana N ta» qulfi yo‘q', (
      tester,
    ) async {
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.searchWith('testalpha'),
        testFixtures: false,
        overrides: [
          libraryRepositoryProvider.overrideWithValue(const _ManyEntries()),
        ],
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
      await tester.pumpAndSettle();
      for (var i = 1; i <= 6; i++) {
        expect(find.text('Testalpha $i'), findsWidgets, reason: 'natija $i');
      }
      expect(find.byKey(const Key('search.more.substances')), findsNothing);
      expect(find.byKey(const Key('search.hit.locked')), findsNothing);
      expect(find.byType(ProLockCard), findsNothing);
    });

    for (final (name, route) in [
      ('manbalar', Routes.sources),
      ('ma’lumot kelib chiqishi (provenance)', Routes.reviewStatus),
      ('ziddiyatlar', Routes.conflicts),
      ('AI ogohlantirishi', Routes.aiDisclaimer),
      ('maxfiylik', Routes.privacy),
    ]) {
      testWidgets('$name: qulfsiz ochiladi', (tester) async {
        await pumpApp(
          tester,
          settings: completedSettings(),
          initialLocation: route,
        );
        expect(find.byType(ProLockCard), findsNothing);
        expect(find.byIcon(Icons.lock_outline), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Ma’lumotnoma, oddiy kalkulyator va qidiruv ochiq', (
      tester,
    ) async {
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.tool('tool.lab.dilution'),
      );
      expect(find.byType(ProLockCard), findsNothing);
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.library,
      );
      expect(find.byType(ProLockCard), findsNothing);
    });

    testWidgets('/profile/purchase yo‘li yo‘q; Pro sahifasi /profile/pro', (
      tester,
    ) async {
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: '/profile/purchase',
      );
      expect(find.byKey(const Key('purchase.restore')), findsNothing);
      expect(find.byKey(const Key('pro.list')), findsNothing);
      await pumpApp(
        tester,
        settings: completedSettings(),
        initialLocation: Routes.pro,
      );
      expect(find.byKey(const Key('pro.list')), findsOneWidget);
    });
  });

  group('Mutaxassis (Expert Pro)', () {
    testWidgets('bepul: professional kalkulyator va ish daftari qulfli', (
      tester,
    ) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz'),
        initialLocation: Routes.tools,
      );
      // Funksiya ko‘rinadi, lekin qulf belgisi bilan.
      expect(lockOn('tool.tool.fm.pmi_henssge'), findsOneWidget);
      expect(lockOn('tool.tool.lab.lod_loq'), findsOneWidget);
      expect(lockOn('tools.casebook'), findsOneWidget);
      // Oddiy hisoblar bepul.
      expect(lockOn('tool.tool.lab.dilution'), findsNothing);
      expect(lockOn('tool.tool.lab.percent'), findsNothing);
    });

    testWidgets(
      'PMI kalkulyatori Pro kartasini ko‘rsatadi, tugma Pro sahifasiga',
      (tester) async {
        await pumpApp(
          tester,
          settings: completedSettings(lang: 'uz'),
          initialLocation: Routes.tool('tool.fm.pmi_henssge'),
        );
        expect(
          find.byKey(const Key('pro.lock.proCalculators')),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('pro.lock.unlock')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('pro.includes.expert')), findsOneWidget);
      },
    );

    testWidgets('ish daftari va sudda so‘roq — qulf kartasi', (tester) async {
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz'),
        initialLocation: Routes.casebook,
      );
      expect(find.byKey(const Key('pro.lock.caseNotebook')), findsOneWidget);
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz'),
        initialLocation: Routes.courtPrep,
      );
      expect(find.byKey(const Key('pro.lock.courtPrep')), findsOneWidget);
      // Xavfsizlik matni qulf sahifasida ham eslatiladi.
      expect(
        find.text(
          'Xavfsizlik ma’lumotlari, manbalar va ma’lumotning kelib chiqishi (provenance) doim bepul.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Expert Pro: kalkulyator, daftar, sudda so‘roq ochiq', (
      tester,
    ) async {
      for (final route in [
        Routes.tool('tool.fm.pmi_henssge'),
        Routes.casebook,
        Routes.courtPrep,
      ]) {
        await pumpApp(
          tester,
          settings: completedSettings(lang: 'uz'),
          initialLocation: route,
          overrides: planOverrides(Plan.expert),
        );
        expect(find.byType(ProLockCard), findsNothing, reason: route);
      }
    });

    testWidgets('Talaba Pro va Ustoz Pro Mutaxassis funksiyalarini ochmaydi', (
      tester,
    ) async {
      for (final plan in [Plan.student, Plan.teacher]) {
        await pumpApp(
          tester,
          settings: completedSettings(lang: 'uz'),
          initialLocation: Routes.casebook,
          overrides: planOverrides(plan),
        );
        expect(
          find.byKey(const Key('pro.lock.caseNotebook')),
          findsOneWidget,
          reason: '$plan',
        );
      }
    });

    testWidgets('rejimni almashtirish huquq bermaydi', (tester) async {
      // Mutaxassis Pro bor, lekin rejim «Talaba»: baribir ochiq (reja
      // tekshiriladi); Talaba Pro bor, rejim «Mutaxassis»: yopiq.
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz', mode: UserMode.student),
        initialLocation: Routes.casebook,
        overrides: planOverrides(Plan.student),
      );
      expect(find.byKey(const Key('pro.lock.caseNotebook')), findsOneWidget);
    });
  });

  group('Talaba (Student Pro)', () {
    final catalog = testStudyCatalog(quiz: true);
    const firstDeck = 'discipline.forensicMedicine';
    const otherDeck = 'group.test_group';
    const guidelineDeck = 'guideline.forensicChemistry';

    Future<void> openStudy(
      WidgetTester tester,
      String route, {
      Plan? plan,
      StudyCatalog? cat,
    }) => pumpApp(
      tester,
      settings: completedSettings(lang: 'uz', mode: UserMode.student),
      initialLocation: route,
      overrides: [
        studyCatalogProvider.overrideWithValue(cat ?? catalog),
        studySeedProvider.overrideWithValue(() => 7),
        ...planOverrides(plan),
      ],
    );

    testWidgets(
      'bepul: 1 fan kartochkasi ochiq, qolganlari va imtihon qulfli',
      (tester) async {
        await openStudy(tester, Routes.study);
        expect(lockOn('study.cards.$firstDeck'), findsNothing);
        expect(lockOn('study.cards.$otherDeck'), findsOneWidget);
        expect(lockOn('study.exam.$guidelineDeck'), findsOneWidget);
        // Xatolar statistikasi: qulf kartasi ko‘rinadi.
        expect(
          find.byKey(const Key('pro.lock.errorAnalytics')),
          findsOneWidget,
        );
      },
    );

    testWidgets('qulfli kartochka Pro sahifasiga olib boradi', (tester) async {
      await openStudy(tester, Routes.study);
      final f = find.byKey(const Key('study.cards.$otherDeck'));
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pro.includes.student')), findsOneWidget);
    });

    testWidgets('to‘g‘ridan-to‘g‘ri havolada ham qulfli (kartochka, imtihon)', (
      tester,
    ) async {
      await openStudy(tester, Routes.studyCards(otherDeck));
      expect(find.byKey(const Key('pro.lock.allFlashcards')), findsOneWidget);
      await openStudy(tester, Routes.studyQuiz(guidelineDeck, exam: true));
      expect(find.byKey(const Key('pro.lock.examMode')), findsOneWidget);
      // Bepul fan kartochkasi ochiq.
      await openStudy(tester, Routes.studyCards(firstDeck));
      expect(find.byType(ProLockCard), findsNothing);
    });

    testWidgets('Talaba Pro: hammasi ochiq', (tester) async {
      await openStudy(tester, Routes.study, plan: Plan.student);
      expect(lockOn('study.cards.$otherDeck'), findsNothing);
      expect(lockOn('study.exam.$guidelineDeck'), findsNothing);
      expect(find.byType(ProLockCard), findsNothing);
      expect(find.byKey(const Key('study.errorStats')), findsOneWidget);
      await openStudy(
        tester,
        Routes.studyQuiz(guidelineDeck, exam: true),
        plan: Plan.student,
      );
      expect(find.byType(ProLockCard), findsNothing);
    });

    testWidgets('mashq testi: bepulda butunlay qulfli', (tester) async {
      final big = StudyCatalogBuilder.build(
        knowledge: const ListKnowledgeRepository(<KnowledgeEntry>[]),
        library: TestLibrary([
          for (var i = 1; i <= 8; i++)
            testSubstance('s$i', formula: 'C${i}H${i * 2}-TEST'),
        ]),
        guidelines: GuidelineBundle.empty,
      );
      await openStudy(tester, Routes.studyQuiz(otherDeck), cat: big);
      expect(find.byKey(const Key('study.quiz.proLock')), findsOneWidget);
      expect(find.byKey(const Key('study.quiz.option.0')), findsNothing);
    });
  });

  group('Ustoz (Teacher Pro)', () {
    Map<String, Object?> deck(String id, String course) => {
      'ok': true,
      'topic_id': id,
      'title': 'Dars $id',
      'course': course,
      'deck_id': '$id-deck',
      'source_lang': 'uz',
      'deck': {
        'topic': 'Dars $id',
        'slides': [
          {
            'title': 'Slayd',
            'bullets': [
              {'text': 'Fikr'},
            ],
          },
        ],
        'sources': const <Object?>[],
      },
    };

    final decks = {
      'instr-01-kristallyuks': deck(
        'instr-01-kristallyuks',
        'Apparatlar bilan ishlash',
      ),
      'instr-02-uv': deck('instr-02-uv', 'Apparatlar bilan ishlash'),
      for (var i = 1; i <= 5; i++)
        'toks-0$i': deck('toks-0$i', 'Toksikologik kimyo'),
    };

    Future<void> openLessons(
      WidgetTester tester,
      String route, {
      Plan? plan,
      bool teacher = true,
    }) async {
      final backend = FakeClassQuizBackend(teachers: {if (teacher) 't1'});
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz', mode: UserMode.teacher),
        initialLocation: route,
        overrides: [
          classQuizServiceProvider.overrideWithValue(
            FakeClassQuizService(backend, userId: 't1', demo: false),
          ),
          lessonsServiceProvider.overrideWithValue(
            FakeLessonsService(isTeacher: teacher, demo: false, decks: decks),
          ),
          ...planOverrides(plan),
        ],
      );
    }

    testWidgets('bepul: hamma dars qulfli (Pro kerak)', (tester) async {
      await openLessons(tester, Routes.lessons);
      for (final id in [
        'toks-01',
        'toks-02',
        'toks-03',
        'toks-04',
        'toks-05',
        'instr-01-kristallyuks',
        'instr-02-uv',
      ]) {
        expect(lockOn('lessons.row.$id'), findsOneWidget, reason: id);
      }
    });

    testWidgets('qulfli dars to‘g‘ridan-to‘g‘ri havolada ham ochilmaydi', (
      tester,
    ) async {
      await openLessons(tester, Routes.lesson('toks-05'));
      expect(find.byKey(const Key('pro.lock.allLessons')), findsOneWidget);
      // Birinchi dars ham bepulda yopiq.
      await openLessons(tester, Routes.lesson('toks-01'));
      expect(find.byKey(const Key('pro.lock.allLessons')), findsOneWidget);
      // Ustoz Pro: mazmun ochiladi (oxirida faqat kontekstli taklif).
      await openLessons(tester, Routes.lesson('toks-01'), plan: Plan.teacher);
      expect(find.text('Slayd'), findsWidgets);
      expect(find.byKey(const Key('lesson.quizStart')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('Ustoz Pro barcha darslarni ochadi; apparatlar kursini emas', (
      tester,
    ) async {
      await openLessons(tester, Routes.lessons, plan: Plan.teacher);
      expect(lockOn('lessons.row.toks-05'), findsNothing);
      expect(lockOn('lessons.row.instr-02-uv'), findsOneWidget);
    });

    testWidgets('Talaba Pro Ustoz darslarini ochmaydi', (tester) async {
      await openLessons(tester, Routes.lessons, plan: Plan.student);
      expect(lockOn('lessons.row.toks-05'), findsOneWidget);
    });

    testWidgets(
      'Talaba Pro bilan Ustoz paneli ochilmaydi (server roli kerak)',
      (tester) async {
        // Ustoz roli YO‘Q + Talaba Pro: panelda darslar va «Test o‘tkazish» yopiq.
        final backend = FakeClassQuizBackend();
        await pumpApp(
          tester,
          settings: completedSettings(lang: 'uz', mode: UserMode.teacher),
          initialLocation: Routes.teacher,
          overrides: [
            classQuizServiceProvider.overrideWithValue(
              FakeClassQuizService(backend, userId: 'student-1'),
            ),
            ...planOverrides(Plan.student),
          ],
        );
        expect(find.byKey(const Key('teacher.panel')), findsOneWidget);
        expect(find.byKey(const Key('teacher.lessons')), findsNothing);
        final run = find.byKey(const Key('teacher.run'));
        final tile = find.descendant(of: run, matching: find.byType(InkWell));
        expect(tile, findsWidgets);
        await tester.tap(run);
        await tester.pumpAndSettle();
        // Ustoz paneli ichida «Test o‘tkazish» ochilmadi.
        expect(find.byKey(const Key('class.codeField')), findsNothing);
        expect(find.byKey(const Key('teacher.panel')), findsOneWidget);
      },
    );

    testWidgets('Ustoz Pro roli bermaydi: rolsiz panel yopiq qoladi', (
      tester,
    ) async {
      final backend = FakeClassQuizBackend();
      await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz', mode: UserMode.teacher),
        initialLocation: Routes.teacher,
        overrides: [
          classQuizServiceProvider.overrideWithValue(
            FakeClassQuizService(backend, userId: 'someone'),
          ),
          ...planOverrides(Plan.teacher),
        ],
      );
      expect(find.byKey(const Key('teacher.lessons')), findsNothing);
    });
  });
}

/// TEST: qidiruv natijalari to‘liq ko‘rinishini sinash uchun 6 ta sun’iy
/// yozuv (ilmiy emas).
class _ManyEntries implements LibraryRepository {
  const _ManyEntries();

  static final _all = [
    for (var i = 1; i <= 6; i++)
      LibraryEntry(
        id: 'TEST-ALPHA-$i',
        section: LibrarySection.substances,
        name: LocalizedText({'en': 'Testalpha $i'}),
        status: ScientificStatus.needsReview,
        isTestData: true,
      ),
  ];

  @override
  List<LibraryEntry> entries(LibrarySection section) =>
      section == LibrarySection.substances ? _all : const [];

  @override
  LibraryEntry? byId(String id) => _all.where((e) => e.id == id).firstOrNull;
}
