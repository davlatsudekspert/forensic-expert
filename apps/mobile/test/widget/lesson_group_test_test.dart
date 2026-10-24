import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/lessons.dart';
import 'package:forensic_expert/app/professional.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/data/lessons/fake_lessons_service.dart';
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';
import 'package:forensic_expert/features/class_groups/presentation/teacher_live_screens.dart';

import '../helpers/class_groups_world.dart';

/// Dars oxiridagi «Guruh testi» (egasi qarori, 2026-10-24): guruhga test
/// berish, ism bilan qo‘shilish, jonli doska o‘rinlari, qiyin savollar.

AppLocalizations _l(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).first));

class _Guard implements LessonScreenGuard {
  @override
  Future<void> secure() async {}
  @override
  Future<void> release() async {}
}

String _realTopic(GroupsWorld w) =>
    w.topics.firstWhere((t) => !t.id.contains('~')).id;

Future<void> _openLesson(
  WidgetTester tester,
  GroupsWorld w,
  String topic, {
  String uid = 'teacher',
}) async {
  final decks = {
    for (final e in sampleLessonDecks.entries)
      e.key: {...e.value, 'deck_id': topic},
  };
  await w.open(
    tester,
    uid: uid,
    // Keng ekran: AppBar’dagi test tugmasi (telefonda — oxirgi slaydda).
    size: const Size(820, 1180),
    iphone: false,
    location: Routes.lesson(sampleLessonDecks.keys.first),
    extra: [
      lessonsServiceProvider.overrideWithValue(
        FakeLessonsService(demo: false, decks: decks),
      ),
      lessonScreenGuardProvider.overrideWithValue(_Guard()),
    ],
  );
}

Future<void> _openGroupTest(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('lesson.quizAppBar')));
  await frames(tester);
  await tester.tap(find.byKey(const Key('grp.choice.group')));
  await frames(tester);
}

Future<void> _scrollTo(WidgetTester tester, Key target) async {
  await tester.scrollUntilVisible(
    find.byKey(target),
    150,
    scrollable: find
        .descendant(
          of: find.byKey(const Key('grp.lesson.list')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.ensureVisible(find.byKey(target));
  await tester.pumpAndSettle();
}

bool _selected(WidgetTester tester, String key) =>
    tester.widget<ChoiceChip>(find.byKey(Key(key))).selected;

void main() {
  setUp(() {
    floatingNavEnabled = true;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  testWidgets('tanlov: «Guruhga test berish» birinchi va ajratilgan; '
      '«Sinfda test» yo‘q; «O‘zim yechib ko‘rish» serverga yubormaydi', (
    tester,
  ) async {
    final w = GroupsWorld.real();
    final g = w.backend.create('teacher', '4-kurs, 2-guruh').value!;
    await _openLesson(tester, w, _realTopic(w));
    await tester.tap(find.byKey(const Key('lesson.quizAppBar')));
    await frames(tester);
    final l = _l(tester);
    final group = tester.getRect(find.byKey(const Key('grp.choice.group')));
    final self = tester.getRect(find.byKey(const Key('grp.choice.self')));
    expect(group.top, lessThan(self.top));
    expect(find.byType(FilledButton), findsOneWidget, reason: 'ajratilgan');
    expect(find.text(l.grpLessonGroupTest), findsOneWidget);
    expect(find.byKey(const Key('grp.choice.live')), findsNothing);
    expect(find.byKey(const Key('grp.choice.assign')), findsNothing);
    await tester.tap(find.byKey(const Key('grp.choice.self')));
    await frames(tester);
    expect(find.text(l.grpPracticeBanner), findsOneWidget);
    expect(w.backend.detail('teacher', g.id).value!.assignments, isEmpty);
    await closeApp(tester);
  });

  testWidgets('guruh yo‘q: shu yerda yaratiladi → mavzu avtomatik → 20 savol, '
      '15 daqiqa, 1 kun → QR + kod → jonli natijalar', (tester) async {
    final w = GroupsWorld.real();
    final topic = _realTopic(w);
    await _openLesson(tester, w, topic);
    await _openGroupTest(tester);
    final l = _l(tester);
    expect(find.byKey(const Key('grp.lesson.noGroups')), findsOneWidget);
    // Guruh yaratilmaguncha boshlab bo‘lmaydi.
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('grp.lesson.start')))
          .onPressed,
      isNull,
    );
    await tester.enterText(
      find.byKey(const Key('grp.lesson.nameField')),
      'Yangi guruh',
    );
    await tester.tap(find.byKey(const Key('grp.lesson.createGroup')));
    await frames(tester);
    final g = w.backend.list('teacher').value!.teaching.single;
    expect(g.name, 'Yangi guruh');
    expect(find.byKey(Key('grp.lesson.group.${g.id}')), findsOneWidget);
    // Mavzu avtomatik: dars mavzusi, almashtirib bo‘lmaydi (tanlov ro‘yxati yo‘q).
    expect(find.byKey(const Key('grp.lesson.topic')), findsOneWidget);
    expect(find.byKey(const Key('grp.topicSearch')), findsNothing);
    expect(find.text(l.grpLessonTopicFixed), findsOneWidget);
    // Chiplar: 10 / 15 / 20 (maxsus «Boshqa…» yo‘q), standart 10 savol.
    await _scrollTo(tester, const Key('grp.count.20'));
    for (final n in [10, 15, 20]) {
      expect(find.byKey(Key('grp.count.$n')), findsOneWidget);
    }
    expect(find.byKey(const Key('grp.count.custom')), findsNothing);
    expect(find.byKey(const Key('grp.variantSwitch')), findsNothing);
    expect(_selected(tester, 'grp.count.10'), isTrue);
    expect(_selected(tester, 'grp.time.15'), isTrue, reason: 'standart 15');
    await _scrollTo(tester, const Key('grp.open.1'));
    expect(_selected(tester, 'grp.open.1'), isTrue, reason: 'standart 1 kun');
    await _scrollTo(tester, const Key('grp.count.20'));
    await tester.tap(find.byKey(const Key('grp.count.20')));
    await frames(tester, 2);
    await _scrollTo(tester, const Key('grp.lesson.start'));
    await tester.tap(find.byKey(const Key('grp.lesson.start')));
    await frames(tester);
    final a = w.backend.detail('teacher', g.id).value!.assignments.single;
    expect(a.questionCount, 20);
    expect(a.timeLimitMin, 15);
    expect(a.dueAt, w.now.add(const Duration(days: 1)));
    expect(a.topicId, topic);
    // Guruh QR + kod ekranda.
    expect(find.byKey(const Key('grp.lesson.started')), findsOneWidget);
    expect(find.byKey(const Key('grp.lesson.qr')), findsOneWidget);
    expect(find.byKey(const Key('class.qr')), findsOneWidget);
    expect(find.textContaining(GroupCode.display(g.code!)), findsWidgets);
    await tester.tap(find.byKey(const Key('grp.lesson.live')));
    await frames(tester);
    expect(find.byType(GroupBoardScreen), findsOneWidget);
    expect(find.byKey(const Key('grp.board.close')), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('bir nechta guruh: tanlanmaguncha boshlab bo‘lmaydi; tanlangan '
      'guruhga test beriladi', (tester) async {
    final w = GroupsWorld.real();
    final g1 = w.backend.create('teacher', 'Guruh A').value!;
    final g2 = w.backend.create('teacher', 'Guruh B').value!;
    await _openLesson(tester, w, _realTopic(w));
    await _openGroupTest(tester);
    await _scrollTo(tester, const Key('grp.lesson.start'));
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('grp.lesson.start')))
          .onPressed,
      isNull,
    );
    await tester.ensureVisible(find.byKey(Key('grp.lesson.group.${g2.id}')));
    await tester.tap(find.byKey(Key('grp.lesson.group.${g2.id}')));
    await frames(tester, 2);
    await _scrollTo(tester, const Key('grp.lesson.start'));
    await tester.tap(find.byKey(const Key('grp.lesson.start')));
    await frames(tester);
    expect(w.backend.detail('teacher', g1.id).value!.assignments, isEmpty);
    expect(w.backend.detail('teacher', g2.id).value!.assignments, hasLength(1));
    await closeApp(tester);
  });

  testWidgets('mavzuda 10 dan kam savol: faqat «Hammasi · N»', (tester) async {
    final w = GroupsWorld();
    final g = w.backend.create('teacher', 'Guruh').value!;
    await _openLesson(tester, w, 'tox-small');
    await _openGroupTest(tester);
    final l = _l(tester);
    await _scrollTo(tester, const Key('grp.count.all'));
    for (final n in [10, 15, 20]) {
      expect(find.byKey(Key('grp.count.$n')), findsNothing);
    }
    expect(find.text(l.classQuestionCountAll(6)), findsOneWidget);
    expect(_selected(tester, 'grp.count.all'), isTrue);
    await _scrollTo(tester, const Key('grp.lesson.start'));
    await tester.tap(find.byKey(const Key('grp.lesson.start')));
    await frames(tester);
    expect(
      w.backend.detail('teacher', g.id).value!.assignments.single.questionCount,
      6,
    );
    await closeApp(tester);
  });

  testWidgets('mavzuda 12 savol: 10 va «Hammasi · 12»', (tester) async {
    final w = GroupsWorld(topics: [groupTestTopic('mid', 'O‘rta mavzu', 12)]);
    w.backend.create('teacher', 'Guruh');
    await _openLesson(tester, w, 'mid');
    await _openGroupTest(tester);
    final l = _l(tester);
    await _scrollTo(tester, const Key('grp.count.all'));
    expect(find.byKey(const Key('grp.count.10')), findsOneWidget);
    expect(find.byKey(const Key('grp.count.15')), findsNothing);
    expect(find.text(l.classQuestionCountAll(12)), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('talaba: profil ismi taxallus maydonida avtomatik; o‘zgartirsa '
      'bo‘ladi; a’zo bo‘lgach qayta ism so‘ralmaydi', (tester) async {
    final w = GroupsWorld.real();
    final g = w.backend.create('teacher', 'Guruh').value!;
    final a = (await w.backend.createAssignment(
      'teacher',
      g.id,
      AssignmentDraft(
        topicId: _realTopic(w),
        questionCount: 5,
        timeLimitMin: 15,
        dueAt: w.now.add(const Duration(days: 1)),
      ),
    )).value!;
    final c = await w.open(
      tester,
      uid: 'stu',
      location: '/g/${g.code}?a=${a.id}',
      extra: [
        initialProfileProvider.overrideWithValue(
          const LocalUserProfile(
            student: StudentProfile(
              fullName: 'Dilnoza Karimova',
              country: 'UZ',
            ),
          ),
        ),
      ],
    );
    final field = find.byKey(const Key('grp.nickField'));
    expect(field, findsOneWidget);
    expect(
      tester.widget<TextField>(field).controller!.text,
      'Dilnoza Karimova',
    );
    await tester.enterText(field, 'Dilnoza K.');
    await tester.tap(find.byKey(const Key('grp.joinSubmit')));
    await frames(tester);
    final me = w.backend.detail('stu', g.id).value!;
    expect(me.nickname, 'Dilnoza K.');
    expect(find.byKey(const Key('grp.nickField')), findsNothing);
    // A’zo qayta QR ochsa — ism so‘ralmaydi, test darhol ochiladi.
    c.read(routerProvider).go('/g/${g.code}?a=${a.id}');
    await frames(tester);
    expect(find.byKey(const Key('grp.nickField')), findsNothing);
    await closeApp(tester);
  });
}
