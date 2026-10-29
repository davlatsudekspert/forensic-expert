import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/lessons.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/data/class_quiz/class_quiz_demo_bank.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/data/lessons/fake_lessons_service.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/features/lessons/presentation/lesson_viewer_screen.dart';
import 'package:forensic_expert/features/lessons/presentation/lessons_list_screen.dart';
import 'package:go_router/go_router.dart';

import '../helpers/pump_app.dart';

class _Awake implements ClassScreenAwake {
  int enabled = 0;
  int disabled = 0;
  @override
  Future<void> enable() async => enabled++;
  @override
  Future<void> disable() async => disabled++;
}

class _Orient implements ClassOrientationControl {
  final calls = <String>[];
  @override
  Future<void> landscape() async => calls.add('landscape');
  @override
  Future<void> restore() async => calls.add('restore');
}

class _AutoStore implements LessonAutoStore {
  _AutoStore([this.prefs = const LessonAutoPrefs()]);
  LessonAutoPrefs prefs;
  @override
  Future<LessonAutoPrefs> load() async => prefs;
  @override
  Future<void> save(LessonAutoPrefs p) async => prefs = p;
}

class _Guard implements LessonScreenGuard {
  int secured = 0;
  int released = 0;
  @override
  Future<void> secure() async => secured++;
  @override
  Future<void> release() async => released++;
}

Map<String, Object?> _deck(String id, String deckId, {String lang = 'uz'}) => {
  'ok': true,
  'topic_id': id,
  'title': 'Sinov mavzusi $id',
  'course': '4-kurs · Davolash',
  'deck_id': deckId,
  'source_lang': lang,
  'deck': {
    'topic': 'Sinov mavzusi',
    'slides': [
      {
        'title': 'Birinchi slayd',
        'bullets': [
          {
            'text': 'Asosiy fikr',
            'source': {'author': 'Aliyev', 'title': 'Kitob', 'page': '12'},
          },
          {'text': 'Shubhali fikr', 'uncertain': true},
        ],
        'teacher_notes': 'MAXFIY ESLATMA 1',
      },
      {
        'title': 'Ikkinchi slayd',
        'bullets': [
          {'text': 'Jadvaldan keyin'},
        ],
        'teacher_notes': 'MAXFIY ESLATMA 2',
        'diagram': {
          'header': ['A', 'B'],
          'rows': [
            ['1', '2'],
          ],
        },
      },
      {
        'title': 'Uchinchi slayd',
        'bullets': [
          {'text': 'Oqim'},
        ],
        'diagram': {
          'nodes': ['x', 'y', 'z'],
        },
      },
    ],
    'extras': [
      {'text': 'Qiziqarli fakt'},
    ],
    'sources': [
      {'author': 'Aliyev', 'title': 'Kitob', 'year': '2020'},
    ],
  },
};

final _questions = classQuizDemoTopic;

void main() {
  setUpAll(() => testDefaultPlan = Plan.teacher);
  tearDownAll(() => testDefaultPlan = null);
  late _Awake awake;
  late _Orient orient;
  late _Guard guard;
  late FakeClassQuizBackend backend;
  late _AutoStore autoStore;

  Future<void> open(
    WidgetTester tester, {
    String lang = 'uz',
    Size size = const Size(390, 844),
    bool teacher = true,
    String path = '/home/teacher/lessons',
    String deckId = 'demo-topic',
    FakeLessonsService? lessons,
    bool prompt = false,
    LessonAutoPrefs? autoPrefs,
  }) async {
    autoStore = _AutoStore(autoPrefs ?? const LessonAutoPrefs());
    awake = _Awake();
    orient = _Orient();
    guard = _Guard();
    backend = FakeClassQuizBackend(teachers: {if (teacher) 't1'});
    await pumpApp(
      tester,
      settings: completedSettings(
        lang: lang,
        mode: teacher ? UserMode.teacher : UserMode.professional,
      ),
      size: size,
      initialLocation: path,
      overrides: [
        classQuizServiceProvider.overrideWithValue(
          FakeClassQuizService(backend, userId: 't1', demo: false),
        ),
        lessonsServiceProvider.overrideWithValue(
          lessons ??
              FakeLessonsService(
                isTeacher: teacher,
                demo: false,
                decks: {
                  'a1': _deck('a1', deckId, lang: 'uz'),
                  'b1': _deck('b1', 'b1-deck')..['course'] = '5-kurs',
                },
              ),
        ),
        classScreenAwakeProvider.overrideWithValue(awake),
        classOrientationControlProvider.overrideWithValue(orient),
        lessonScreenGuardProvider.overrideWithValue(guard),
        lessonAutoStoreProvider.overrideWithValue(autoStore),
        classLandscapePromptEnabledProvider.overrideWithValue(prompt),
      ],
    );
  }

  testWidgets('ro‘yxat: kurs sarlavhalari, qidiruv (mahalliy + server)', (
    tester,
  ) async {
    final svc = FakeLessonsService(
      demo: false,
      decks: {
        'a1': _deck('a1', 'demo-topic'),
        'b1': {..._deck('b1', 'b1-deck'), 'course': '5-kurs'},
      },
    );
    await open(tester, lessons: svc);
    expect(find.byType(LessonsListScreen), findsOneWidget);
    expect(find.text('4-kurs · Davolash'), findsOneWidget);
    expect(find.text('5-kurs'), findsOneWidget);
    expect(find.byKey(const Key('lessons.row.a1')), findsOneWidget);
    expect(find.text('3 ta slayd'), findsNWidgets(2));

    // Slayd matni bo‘yicha: sarlavhada yo‘q, serverda bor.
    await tester.enterText(find.byKey(const Key('lessons.search')), 'Oqim');
    await tester.pump();
    // Debounce o‘tmaguncha server so‘rovi yo‘q, mahalliy filtr (sarlavha).
    expect(svc.queries.where((q) => q == 'Oqim'), isEmpty);
    expect(find.byKey(const Key('lessons.empty')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(svc.queries, contains('Oqim'));
    expect(find.byKey(const Key('lessons.row.a1')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('lessons.search')), 'zzzz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lessons.empty')), findsOneWidget);
    await tester.tap(find.byKey(const Key('lessons.searchClear')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lessons.row.b1')), findsOneWidget);
  });

  testWidgets('ro‘yxat: ustoz emas — faqat ochiq kurslar va izoh', (
    tester,
  ) async {
    await open(tester, teacher: false);
    // Namunaviy decklar ochiq kursda emas — ro‘yxat bo‘sh, izoh bor.
    expect(find.byKey(const Key('lessons.empty')), findsOneWidget);
    expect(find.byKey(const Key('lessons.openNote')), findsOneWidget);
    expect(find.byKey(const Key('lessons.forbidden')), findsNothing);
  });

  testWidgets('ustoz emas: ochiq kurs darsi ochiladi, yopig‘i — forbidden', (
    tester,
  ) async {
    final svc = FakeLessonsService(
      isTeacher: false,
      demo: false,
      decks: {
        'instr-01': {
          ..._deck('instr-01', 'instr-deck'),
          'course': 'Apparatlar bilan ishlash',
        },
        'a1': _deck('a1', 'demo-topic'),
      },
    );
    await open(tester, lessons: svc, teacher: false);
    expect(find.byKey(const Key('lessons.row.instr-01')), findsOneWidget);
    expect(find.byKey(const Key('lessons.row.a1')), findsNothing);
  });

  testWidgets('ustoz emas: yopiq kurs darsi — forbidden', (tester) async {
    await open(
      tester,
      lessons: FakeLessonsService(
        isTeacher: false,
        demo: false,
        decks: {'a1': _deck('a1', 'demo-topic')},
      ),
      teacher: false,
      path: Routes.lesson('a1'),
    );
    expect(find.byKey(const Key('lessons.forbidden')), findsOneWidget);
  });

  testWidgets('ro‘yxat: offline xato va qayta urinish', (tester) async {
    await open(
      tester,
      lessons: FakeLessonsService(failure: ClassFailure.offline),
    );
    expect(find.byKey(const Key('lessons.error')), findsOneWidget);
    expect(find.text('Qayta urinish'), findsOneWidget);
  });

  testWidgets('ustoz paneli: «Darslar» faqat ustozga ko‘rinadi', (
    tester,
  ) async {
    await open(tester, path: Routes.teacher);
    expect(find.byKey(const Key('teacher.lessons')), findsOneWidget);
    await tester.tap(find.byKey(const Key('teacher.lessons')));
    await tester.pumpAndSettle();
    expect(find.byType(LessonsListScreen), findsOneWidget);
  });

  testWidgets('ustoz emas: panelda «Darslar» yo‘q', (tester) async {
    await open(tester, path: Routes.teacher, teacher: false);
    expect(find.byKey(const Key('teacher.lessons')), findsNothing);
  });

  testWidgets('ko‘rish oynasi: slaydlar, navigatsiya, manba, eslatma', (
    tester,
  ) async {
    await open(tester, path: Routes.lesson('a1'));
    expect(guard.secured, 1);
    expect(find.byType(LessonViewer), findsOneWidget);
    expect(find.text('Birinchi slayd'), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget); // 3 + qiziqarli + adabiyotlar
    expect(find.byKey(const Key('lesson.uncertain')), findsOneWidget);
    expect(find.text('Manba: Aliyev, Kitob, bet 12'), findsOneWidget);
    expect(find.text('MAXFIY ESLATMA 1'), findsNothing);

    await tester.tap(find.byKey(const Key('lesson.notesToggle')));
    await tester.pumpAndSettle();
    expect(find.text('MAXFIY ESLATMA 1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('lesson.next')));
    await tester.pumpAndSettle();
    expect(find.text('2 / 5'), findsOneWidget);
    expect(find.byKey(const Key('lesson.diagram.table')), findsOneWidget);
    expect(find.text('MAXFIY ESLATMA 2'), findsOneWidget);

    await tester.tap(find.byKey(const Key('lesson.next')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lesson.diagram.flow')), findsOneWidget);
    await tester.tap(find.byKey(const Key('lesson.prev')));
    await tester.pumpAndSettle();
    expect(find.text('2 / 5'), findsOneWidget);

    // Ro‘yxatdan sakrash.
    await tester.tap(find.byKey(const Key('lesson.outlineButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lesson.outline.4')));
    await tester.pumpAndSettle();
    expect(find.text('5 / 5'), findsOneWidget);
    expect(find.text('Adabiyotlar'), findsWidgets);
    expect(find.text('Aliyev. Kitob. 2020'), findsOneWidget);

    // Klaviatura.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('4 / 5'), findsOneWidget);
    expect(find.text('Qiziqarli fakt'), findsOneWidget);

    GoRouter.of(tester.element(find.byType(LessonViewer))).go(Routes.teacher);
    await tester.pumpAndSettle();
    expect(guard.released, 1);
  });

  testWidgets('proyektor (televizor): himoya o‘chadi, chiqqach qaytadi', (
    tester,
  ) async {
    await open(tester, path: Routes.lesson('a1'));
    expect(guard.secured, 1);
    expect(guard.released, 0);

    await tester.tap(find.byKey(const Key('lesson.projectorButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lesson.projector')), findsOneWidget);
    expect(guard.released, 1);

    await tester.tap(find.byKey(const Key('lesson.projectorExit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lesson.projector')), findsNothing);
    expect(guard.secured, 2);
  });

  testWidgets(
    'ko‘rish oynasi: matn tanlanmaydi, ulashish/yuklash tugmasi yo‘q',
    (tester) async {
      await open(tester, path: Routes.lesson('a1'));
      expect(find.byType(SelectableText), findsNothing);
      expect(find.byIcon(Icons.share), findsNothing);
      expect(find.byIcon(Icons.download), findsNothing);
      expect(find.byIcon(Icons.copy), findsNothing);
    },
  );

  testWidgets('proyektor: eslatma yo‘q, wakelock, gorizontal, tap/klaviatura', (
    tester,
  ) async {
    await open(
      tester,
      path: Routes.lesson('a1'),
      size: const Size(390, 844),
      prompt: true,
    );
    await tester.tap(find.byKey(const Key('lesson.notesToggle')));
    await tester.pumpAndSettle();
    expect(find.text('MAXFIY ESLATMA 1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('lesson.projectorButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lesson.projector')), findsOneWidget);
    expect(awake.enabled, 1);
    expect(find.byKey(const Key('class.landscapeDialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('class.landscapeYes')));
    await tester.pumpAndSettle();
    expect(orient.calls, ['landscape']);

    expect(find.text('MAXFIY ESLATMA 1'), findsNothing);
    expect(find.byKey(const Key('lesson.notes')), findsNothing);
    expect(find.text('Birinchi slayd'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Ikkinchi slayd'), findsOneWidget);
    expect(find.text('MAXFIY ESLATMA 2'), findsNothing);
    // O‘ng tomonga bosish — keyingisi.
    await tester.tapAt(const Offset(350, 400));
    await tester.pumpAndSettle();
    expect(find.text('Uchinchi slayd'), findsOneWidget);
    // Chap uchdan biri — oldingisi.
    await tester.tapAt(const Offset(20, 400));
    await tester.pumpAndSettle();
    expect(find.text('Ikkinchi slayd'), findsOneWidget);

    await tester.tap(find.byKey(const Key('lesson.projectorExit')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lesson.projector')), findsNothing);
    expect(awake.disabled, 1);
    expect(orient.calls, ['landscape', 'restore']);
    expect(find.text('Ikkinchi slayd'), findsOneWidget);
  });

  testWidgets(
    'proyektor: oxirgi sahifada test tugmasi, boshqaruvlar yashirinadi, '
    'chap/o‘ng yarmi',
    (tester) async {
      await open(
        tester,
        path: Routes.lesson('a1'),
        size: const Size(1280, 720),
        deckId: 'demo-topic',
      );
      await tester.tap(find.byKey(const Key('lesson.projectorButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lesson.quizStart')), findsNothing);
      expect(find.text('1 / 5'), findsOneWidget); // kanvas burchagida

      // Boshqaruvlar ~3 s dan keyin yashirinadi, bosilganda qaytadi.
      bool visible() => !tester
          .widget<IgnorePointer>(
            find
                .ancestor(
                  of: find.byKey(const Key('lesson.projectorExit')),
                  matching: find.byType(IgnorePointer),
                )
                .first,
          )
          .ignoring;
      expect(visible(), isTrue);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(visible(), isFalse);

      // O‘ng yarmi — keyingi, chap yarmi — oldingi.
      await tester.tapAt(const Offset(700, 360));
      await tester.pumpAndSettle();
      expect(find.text('Ikkinchi slayd'), findsOneWidget);
      expect(visible(), isTrue);
      await tester.tapAt(const Offset(600, 360));
      await tester.pumpAndSettle();
      expect(find.text('Birinchi slayd'), findsOneWidget);

      // Klaviatura: Space/PgDn — keyingi; oxirgi sahifa — test tugmasi.
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
        await tester.pumpAndSettle();
      }
      // Oxirgi sahifa: hisoblagich o‘rnida test tugmasi.
      expect(find.text('Adabiyotlar'), findsOneWidget);
      expect(find.text('5 / 5'), findsNothing);
      final btn = find.byKey(const Key('lesson.quizStart'));
      expect(btn, findsOneWidget);
      expect(tester.widget<FilledButton>(btn).onPressed, isNotNull);
      final r = tester.getRect(btn);
      expect(r.center.dx, greaterThan(640));
      expect(r.center.dy, greaterThan(360));
      expect(r.bottom, lessThanOrEqualTo(720));
      expect(tester.takeException(), isNull);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pumpAndSettle();
      expect(find.text('4 / 5'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('lesson.projector')), findsNothing);
    },
  );

  testWidgets('proyektor: mavzu testi yo‘q — tugma o‘chirilgan, izohli', (
    tester,
  ) async {
    await open(
      tester,
      path: Routes.lesson('a1'),
      size: const Size(1280, 720),
      deckId: 'hali-yoq',
    );
    await tester.tap(find.byKey(const Key('lesson.projectorButton')));
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
    }
    final btn = find.byKey(const Key('lesson.quizStart'));
    expect(tester.widget<FilledButton>(btn).onPressed, isNull);
    expect(find.byKey(const Key('lesson.quizSoon')), findsOneWidget);
  });

  testWidgets('ru: o‘zbekcha dars + «перевод ожидается» belgisi', (
    tester,
  ) async {
    await open(tester, lang: 'ru', path: Routes.lesson('a1'));
    expect(find.text('Birinchi slayd'), findsOneWidget);
    expect(find.byKey(const Key('lesson.translationPending')), findsOneWidget);
    expect(find.text('перевод ожидается'), findsOneWidget);
    expect(find.text('Начать тест по этой теме'), findsNothing); // 1-slayd
  });

  group('test tugmasi', () {
    Future<void> toLast(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('lesson.outlineButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('lesson.outline.4')));
      await tester.pumpAndSettle();
    }

    testWidgets('mavzu bor: yoqilgan, test yaratish oqimida tanlangan', (
      tester,
    ) async {
      await open(
        tester,
        path: Routes.lesson('a1'),
        deckId: 'demo-topic',
        // Ilova panelidagi test tugmasi faqat keng ekranda (>= 420 dp).
        size: const Size(820, 1180),
      );
      // Ilova panelidagi tugma ham yoqilgan.
      final bar = tester.widget<IconButton>(
        find.byKey(const Key('lesson.quizAppBar')),
      );
      expect(bar.onPressed, isNotNull);
      expect(find.byKey(const Key('lesson.quizStart')), findsNothing);
      await toLast(tester);
      final btn = tester.widget<FilledButton>(
        find.byKey(const Key('lesson.quizStart')),
      );
      expect(btn.onPressed, isNotNull);
      expect(find.byKey(const Key('lesson.quizSoon')), findsNothing);
      await tester.tap(find.byKey(const Key('lesson.quizStart')));
      await tester.pumpAndSettle();
      // Ustoz tanlaydi: guruhga test berish (asosiy) / o‘zim yechib ko‘rish.
      // Jonli «Sinfda test» dars tugmasidan olib tashlangan.
      expect(find.byKey(const Key('grp.choice.group')), findsOneWidget);
      expect(find.byKey(const Key('grp.choice.self')), findsOneWidget);
      expect(find.byKey(const Key('grp.choice.live')), findsNothing);
      await tester.tap(find.byKey(const Key('grp.choice.group')));
      await tester.pumpAndSettle();
      // Mavzu avtomatik: shu darsning test mavzusi.
      expect(find.byKey(const Key('grp.lesson.topic')), findsOneWidget);
      expect(find.text(_questions.title), findsWidgets);
    });

    testWidgets('telefonda ilova panelida test tugmasi yo‘q (sarlavhaga joy)', (
      tester,
    ) async {
      await open(tester, path: Routes.lesson('a1'), deckId: 'demo-topic');
      expect(find.byKey(const Key('lesson.quizAppBar')), findsNothing);
      await toLast(tester);
      expect(find.byKey(const Key('lesson.quizStart')), findsOneWidget);
    });

    testWidgets('mavzu yo‘q: o‘chirilgan va izohli', (tester) async {
      await open(
        tester,
        path: Routes.lesson('a1'),
        deckId: 'hali-yoq',
        // Ilova panelidagi test tugmasi faqat keng ekranda (>= 420 dp).
        size: const Size(820, 1180),
      );
      final bar = tester.widget<IconButton>(
        find.byKey(const Key('lesson.quizAppBar')),
      );
      expect(bar.onPressed, isNull);
      await toLast(tester);
      final btn = tester.widget<FilledButton>(
        find.byKey(const Key('lesson.quizStart')),
      );
      expect(btn.onPressed, isNull);
      expect(
        find.text('Bu mavzu uchun test savollari tez orada qo‘shiladi'),
        findsOneWidget,
      );
    });

    testWidgets('en: matnlar', (tester) async {
      await open(tester, lang: 'en', path: Routes.lesson('a1'));
      await toLast(tester);
      expect(find.text('Start a quiz on this topic'), findsOneWidget);
    });
  });

  group('o‘lchamlar', () {
    for (final size in const [
      Size(320, 568),
      Size(390, 844),
      Size(1280, 720),
      Size(1920, 1080),
    ]) {
      testWidgets('ro‘yxat va ko‘rish oynasi ${size.width.toInt()}', (
        tester,
      ) async {
        await open(tester, size: size, deckId: 'hali-yoq');
        expect(find.byKey(const Key('lessons.row.a1')), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byKey(const Key('lessons.row.a1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('lesson.notesToggle')));
        await tester.pumpAndSettle();
        for (var i = 0; i < 4; i++) {
          await tester.tap(find.byKey(const Key('lesson.next')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        expect(find.byKey(const Key('lesson.quizSoon')), findsOneWidget);
        await tester.tap(find.byKey(const Key('lesson.projectorButton')));
        await tester.pumpAndSettle();
        for (var i = 0; i < 4; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  });
  group('avto-varaqlash', () {
    String counter(WidgetTester t) =>
        t.widget<Text>(find.byKey(const Key('lesson.counter'))).data!;

    Future<void> chooseAuto(WidgetTester tester, {int seconds = 15}) async {
      await tester.tap(find.byKey(const Key('lesson.autoButton')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('lesson.autoMode')),
          matching: find.text('Avto'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('lesson.autoSeconds.$seconds')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(195, 30)); // varaqni yopish
      await tester.pumpAndSettle();
    }

    testWidgets('standart — «Qo‘lda»: slayd o‘zi almashmaydi', (tester) async {
      await open(tester, path: Routes.lesson('a1'));
      expect(find.byKey(const Key('lesson.autoStatus')), findsNothing);
      await tester.pump(const Duration(seconds: 90));
      expect(counter(tester), '1 / 5');
    });

    testWidgets('Avto: tanlangan soniyada o‘tadi, oxirgida to‘xtaydi', (
      tester,
    ) async {
      await open(tester, path: Routes.lesson('a1'));
      await chooseAuto(tester);
      expect(find.byKey(const Key('lesson.autoStatus')), findsOneWidget);
      expect(awake.enabled, greaterThan(0));
      expect(autoStore.prefs.auto, isTrue);
      expect(autoStore.prefs.seconds, 15);

      await tester.pump(const Duration(seconds: 14));
      expect(counter(tester), '1 / 5');
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(counter(tester), '2 / 5');
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(seconds: 15));
        await tester.pump(const Duration(milliseconds: 400));
      }
      expect(counter(tester), '5 / 5');
      // Oxirgi slayd: keyingi tikda avto o‘chadi, boshiga qaytmaydi.
      await tester.pump(const Duration(seconds: 15));
      await tester.pump(const Duration(milliseconds: 400));
      expect(counter(tester), '5 / 5');
      expect(find.byKey(const Key('lesson.autoStatus')), findsNothing);
      expect(autoStore.prefs.auto, isFalse);
    });

    testWidgets('pauza: slaydga bosilsa to‘xtaydi, qayta bosilsa davom etadi', (
      tester,
    ) async {
      await open(tester, path: Routes.lesson('a1'));
      await chooseAuto(tester);
      await tester.tap(find.byKey(const Key('lesson.autoToggle')));
      await tester.pump();
      expect(find.text('Pauza'), findsWidgets);
      await tester.pump(const Duration(seconds: 60));
      expect(counter(tester), '1 / 5');
      await tester.tap(find.byKey(const Key('lesson.autoToggle')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 15));
      await tester.pump(const Duration(milliseconds: 400));
      expect(counter(tester), '2 / 5');
    });

    testWidgets('qo‘lda varaqlansa avto pauzaga o‘tadi', (tester) async {
      await open(tester, path: Routes.lesson('a1'));
      await chooseAuto(tester);
      await tester.tap(find.byKey(const Key('lesson.next')));
      await tester.pumpAndSettle();
      expect(counter(tester), '2 / 5');
      expect(find.text('Pauza'), findsWidgets);
      await tester.pump(const Duration(seconds: 60));
      expect(counter(tester), '2 / 5');
    });

    testWidgets('saqlangan tanlov: Avto o‘zi boshlanadi, tezlik 60 s', (
      tester,
    ) async {
      await open(
        tester,
        path: Routes.lesson('a1'),
        autoPrefs: const LessonAutoPrefs(auto: true, seconds: 60),
      );
      await tester.pump();
      expect(find.byKey(const Key('lesson.autoStatus')), findsOneWidget);
      await tester.pump(const Duration(seconds: 59));
      expect(counter(tester), '1 / 5');
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(counter(tester), '2 / 5');
    });

    testWidgets('ekrandan chiqilganda taymer ham, wake-lock ham tozalanadi', (
      tester,
    ) async {
      await open(
        tester,
        path: Routes.lesson('a1'),
        autoPrefs: const LessonAutoPrefs(auto: true, seconds: 15),
      );
      await tester.pump();
      final before = awake.disabled;
      await tester.pumpWidget(const SizedBox());
      expect(awake.disabled, greaterThan(before));
      await tester.pump(const Duration(seconds: 60)); // kutilmagan taymer yo‘q
    });

    testWidgets('proyektor: o‘ynatish/pauza tugmasi bor', (tester) async {
      await open(tester, path: Routes.lesson('a1'));
      await tester.tap(find.byKey(const Key('lesson.projectorButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('lesson.projectorAuto')));
      await tester.pump();
      expect(autoStore.prefs.auto, isTrue);
    });

    for (final lang in ['uz', 'ru', 'en']) {
      testWidgets('320 dp, 2.0 shrift, $lang: toshmaydi', (tester) async {
        await open(
          tester,
          lang: lang,
          size: const Size(320, 640),
          path: Routes.lesson('a1'),
          autoPrefs: const LessonAutoPrefs(auto: true, seconds: 30),
        );
        await tester.pump();
        expect(find.byKey(const Key('lesson.autoStatus')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
