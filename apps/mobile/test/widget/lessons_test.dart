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
import 'package:forensic_expert/features/class_quiz/presentation/class_quiz_host_screen.dart';
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
  late _Awake awake;
  late _Orient orient;
  late _Guard guard;
  late FakeClassQuizBackend backend;

  Future<void> open(
    WidgetTester tester, {
    String lang = 'uz',
    Size size = const Size(390, 844),
    bool teacher = true,
    String path = '/home/teacher/lessons',
    String deckId = 'demo-topic',
    FakeLessonsService? lessons,
    bool prompt = false,
  }) async {
    awake = _Awake();
    orient = _Orient();
    guard = _Guard();
    backend = FakeClassQuizBackend(teachers: {if (teacher) 't1'});
    await pumpApp(
      tester,
      settings: completedSettings(lang: lang, mode: UserMode.professional),
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

  testWidgets('ro‘yxat: ustoz emas — forbidden holat', (tester) async {
    await open(tester, teacher: false);
    expect(find.byKey(const Key('lessons.forbidden')), findsOneWidget);
    expect(find.text('Bu bo‘lim faqat ustozlar uchun'), findsOneWidget);
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
      await open(tester, path: Routes.lesson('a1'), deckId: 'demo-topic');
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
      expect(find.byType(ClassCreateScreen), findsOneWidget);
      expect(find.byKey(const Key('class.selectedTopic')), findsOneWidget);
      expect(find.text(_questions.title), findsWidgets);
    });

    testWidgets('mavzu yo‘q: o‘chirilgan va izohli', (tester) async {
      await open(tester, path: Routes.lesson('a1'), deckId: 'hali-yoq');
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
}
