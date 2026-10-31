import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_groups.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/core/settings/settings_controller.dart';
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';
import 'package:forensic_expert/domain/class_groups/variant_draw.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';

import '../helpers/class_groups_world.dart';
import '../helpers/pump_app.dart' show testDefaultPlan;

AppLocalizations _l(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).first));

/// Ustoz guruh va variantli test yaratadi; talabalarni qo‘shadi.
Future<({String gid, String code, String aid})> _setup(
  GroupsWorld w, {
  List<String> students = const [],
  int count = 4,
  int? limit = 15,
  bool variant = true,
}) async {
  final g = w.backend.create('teacher', '4-kurs, 2-guruh').value!;
  for (final (i, s) in students.indexed) {
    w.backend.join(s, code: g.code!, nickname: 'Talaba ${i + 1}');
  }
  final a = (await w.backend.createAssignment(
    'teacher',
    g.id,
    AssignmentDraft(
      topicId: 'tox-co',
      questionCount: count,
      timeLimitMin: limit,
      variantMode: variant,
    ),
  )).value!;
  return (gid: g.id, code: g.code!, aid: a.id);
}

Future<void> _answerAll(WidgetTester tester, int n) async {
  for (var i = 0; i < n; i++) {
    await tester.tap(find.byKey(Key('grp.option.${i % 4}')));
    await frames(tester, 2);
    await tester.tap(find.byKey(const Key('grp.confirm')));
    await frames(tester, 2);
    if (i < n - 1) {
      await tester.tap(find.byKey(const Key('grp.next')));
      await frames(tester, 2);
    }
  }
}

void main() {
  setUp(() {
    floatingNavEnabled = true;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  testWidgets(
    'selection is editable, confirmed separately, and private per student',
    (tester) async {
      final prevPlan = testDefaultPlan;
      testDefaultPlan = Plan.student;
      addTearDown(() => testDefaultPlan = prevPlan);
      final w = GroupsWorld();
      final s = await _setup(w, students: ['stu1', 'stu2']);
      await w.open(
        tester,
        uid: 'stu1',
        location: Routes.groupTest(s.gid, s.aid),
      );
      final attempt = w.backend.open('stu1', s.aid).value!;
      final qid = attempt.questions.first.id;
      await tester.tap(find.byKey(const Key('grp.option.0')));
      await frames(tester);
      expect(w.backend.open('stu1', s.aid).value!.answers, isEmpty);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('grp.next')))
            .onPressed,
        isNull,
      );
      // Variantlar har talabaga boshqa tartibda; serverga ASL indeks (1) ketadi.
      final order = optionDisplayOrder(
        assignmentId: s.aid,
        userId: 'stu1',
        questionId: qid,
        count: attempt.questions.first.options.length,
      );
      await tester.tap(find.byKey(Key('grp.option.${order.indexOf(1)}')));
      await frames(tester);
      await tester.tap(find.byKey(const Key('grp.confirm')));
      await frames(tester);
      expect(w.backend.open('stu1', s.aid).value!.answers[qid], 1);
      expect(w.backend.open('stu2', s.aid).value!.answers, isEmpty);
      // Confirmation does not move to the following question.
      expect(find.text(attempt.questions.first.text), findsOneWidget);
      await tester.tap(find.byKey(const Key('grp.next')));
      await frames(tester);
      expect(find.text(attempt.questions[1].text), findsOneWidget);
      await closeApp(tester);
    },
  );

  testWidgets('iPhone: QR havola → taxallus (’) → test → natija, javoblar '
      'yopilgach ochiladi', (tester) async {
    final prevPlan = testDefaultPlan;
    testDefaultPlan = Plan.student;
    addTearDown(() => testDefaultPlan = prevPlan);
    final w = GroupsWorld();
    final s = await _setup(w);
    await w.open(
      tester,
      uid: 'stu1',
      location: Uri(
        path: '/g/${s.code}',
        queryParameters: {'a': s.aid},
      ).toString(),
    );
    final l = _l(tester);
    // Birinchi marta — taxallus so‘raladi, guruh nomi ko‘rinadi.
    expect(find.byKey(const Key('grp.nickField')), findsOneWidget);
    expect(find.text(l.grpJoinGroupName('4-kurs, 2-guruh')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('grp.nickField')), 'G’ayrat');
    await tester.tap(find.byKey(const Key('grp.joinSubmit')));
    await frames(tester);
    // Test darhol ochildi (vaqt chegarasi — teskari sanoq).
    expect(find.byKey(const Key('grp.questionText')), findsOneWidget);
    expect(find.text(l.grpQuestionOf(1, 4)), findsOneWidget);
    expect(find.byKey(const Key('grp.time.countdown')), findsOneWidget);
    expect(tester.takeException(), isNull);
    // Variantlar tagida ish tartibi izohi (tugmasiz, qisqa).
    expect(find.byKey(const Key('grp.flowHint')), findsOneWidget);
    expect(find.text(_l(tester).classAnswerFlowHint), findsOneWidget);
    await _answerAll(tester, 4);
    await tester.tap(find.byKey(const Key('grp.finish')));
    await frames(tester, 3);
    await tester.tap(find.byKey(const Key('grp.submitYes')));
    await frames(tester);
    // Natija: ball server hisobidan; to‘g‘ri javoblar hali yopiq.
    expect(find.byKey(const Key('grp.score')), findsOneWidget);
    expect(find.byKey(const Key('grp.revealLocked')), findsOneWidget);
    expect(find.byKey(const Key('grp.scoreReady')), findsOneWidget);
    expect(find.text(l.grpRevealAfterCloseNote), findsOneWidget);
    final board = w.backend.board('teacher', s.aid).value!;
    expect(board.rows.single.nickname, "G'ayrat");
    expect(board.rows.single.state, BoardState.finished);
    // Ustoz yopadi → «Yangilash» → javoblar va izohlar.
    w.backend.closeAssignment('teacher', s.aid);
    await tester.tap(find.byKey(const Key('grp.refreshResult')));
    await frames(tester);
    expect(find.byKey(const Key('grp.revealLocked')), findsNothing);
    expect(find.byKey(const Key('grp.item.0')), findsOneWidget);
    expect(find.textContaining(l.grpCorrectAnswer('')), findsWidgets);
    await closeApp(tester);
  });

  testWidgets('faqat muddat (vaqt chegarasi yo‘q): «Muddat: …» sana, '
      'teskari sanoq yo‘q', (tester) async {
    final prevPlan = testDefaultPlan;
    testDefaultPlan = Plan.student;
    addTearDown(() => testDefaultPlan = prevPlan);
    final w = GroupsWorld();
    final g = w.backend.create('teacher', 'Muddatli guruh').value!;
    w.backend.join('stu1', code: g.code!, nickname: 'Lola');
    final a = (await w.backend.createAssignment(
      'teacher',
      g.id,
      AssignmentDraft(
        topicId: 'tox-co',
        questionCount: 3,
        dueAt: w.now.add(const Duration(days: 2, hours: 8)),
        reveal: RevealPolicy.afterDue,
      ),
    )).value!;
    await w.open(tester, uid: 'stu1', location: Routes.groupTest(g.id, a.id));
    expect(find.byKey(const Key('grp.time.due')), findsOneWidget);
    expect(find.textContaining('Muddat: 20-okt, 18:00'), findsOneWidget);
    expect(find.byKey(const Key('grp.time.countdown')), findsNothing);
    await closeApp(tester);
  });

  testWidgets('ustoz o‘z kodini ochadi: «Siz bu guruhning ustozisiz» va '
      'talaba ko‘rinishida sinash — serverga hech narsa yuborilmaydi', (
    tester,
  ) async {
    final prevPlan = testDefaultPlan;
    testDefaultPlan = Plan.student;
    addTearDown(() => testDefaultPlan = prevPlan);
    final w = GroupsWorld();
    final s = await _setup(w);
    await w.open(
      tester,
      uid: 'teacher',
      location: Routes.groupJoinWith(s.code, assignmentId: s.aid),
    );
    final l = _l(tester);
    expect(find.byKey(const Key('grp.ownerPanel')), findsOneWidget);
    expect(find.text(l.grpOwnerTitle), findsOneWidget);
    await tester.tap(find.byKey(const Key('grp.ownerPreview')));
    await frames(tester);
    expect(find.byKey(const Key('grp.previewBanner')), findsOneWidget);
    await _answerAll(tester, 4);
    await tester.tap(find.byKey(const Key('grp.finish')));
    await frames(tester, 3);
    await tester.tap(find.byKey(const Key('grp.submitYes')));
    await frames(tester);
    expect(find.byKey(const Key('grp.previewDone')), findsOneWidget);
    // Hech narsa yuborilmagan: ustoz a’zo emas, urinish yo‘q.
    final board = w.backend.board('teacher', s.aid).value!;
    expect(board.rows, isEmpty);
    expect(board.assignment.started, 0);
    expect(w.backend.detail('teacher', s.gid).value!.members, isEmpty);
    await closeApp(tester);
  });

  testWidgets('yangi o‘rnatilgan ilova: QR → onboarding → kirish — taklif '
      'yo‘qolmaydi, oxirida qo‘shilish sahifasi ochiladi', (tester) async {
    final prevPlan = testDefaultPlan;
    testDefaultPlan = Plan.student;
    addTearDown(() => testDefaultPlan = prevPlan);
    final w = GroupsWorld();
    final s = await _setup(w);
    final c = await w.open(tester, settings: const AppSettings());
    c.read(routerProvider).go('/g/${s.code}?a=${s.aid}');
    await frames(tester);
    // Onboarding (til tanlash) ochildi, taklif saqlandi.
    expect(
      c.read(pendingGroupInviteProvider),
      GroupInvite(code: s.code, assignmentId: s.aid),
    );
    expect(c.read(routerProvider).state.uri.path, Routes.language);
    final settings = c.read(settingsControllerProvider.notifier);
    await settings.setLocale(const Locale('uz'));
    await tester.pumpAndSettle();
    await settings.acceptDisclaimer();
    await tester.pumpAndSettle();
    // Oxirgi onboarding qadami → Asosiy → kutilayotgan taklif (bir marta).
    await settings.setUserMode(UserMode.student);
    await frames(tester);
    // Onboarding tugagach — qo‘shilish sahifasi (kirish taklifi bilan).
    expect(c.read(routerProvider).state.uri.path, Routes.groupJoin);
    expect(find.byKey(const Key('grp.signInCard')), findsOneWidget);
    // Kirdi → taklif davom etadi: taxallus so‘raladi.
    (c.read(authStateProvider.notifier) as TestAuth).set(signedInAs('stu9'));
    await frames(tester);
    expect(find.byKey(const Key('grp.nickField')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('grp.nickField')), 'Oʻtkir');
    await tester.tap(find.byKey(const Key('grp.joinSubmit')));
    await frames(tester);
    expect(find.byKey(const Key('grp.questionText')), findsOneWidget);
    expect(c.read(pendingGroupInviteProvider), isNull);
    await closeApp(tester);
  });

  testWidgets('aniq xatolar: 0/O/1/I kod, band taxallus, guruh to‘lgan', (
    tester,
  ) async {
    final prevPlan = testDefaultPlan;
    testDefaultPlan = Plan.student;
    addTearDown(() => testDefaultPlan = prevPlan);
    final w = GroupsWorld();
    final s = await _setup(w, students: ['a1']);
    await w.open(tester, uid: 'stu1', location: Routes.groupJoin);
    final l = _l(tester);
    await tester.enterText(find.byKey(const Key('grp.codeField')), 'abco2345');
    await tester.tap(find.byKey(const Key('grp.joinSubmit')));
    await frames(tester);
    expect(find.text(l.grpErrCodeAmbiguous), findsOneWidget);
    await tester.enterText(find.byKey(const Key('grp.codeField')), s.code);
    await tester.tap(find.byKey(const Key('grp.joinSubmit')));
    await frames(tester);
    await tester.enterText(find.byKey(const Key('grp.nickField')), 'talaba 1');
    await tester.tap(find.byKey(const Key('grp.joinSubmit')));
    await frames(tester);
    expect(find.text(l.grpErrNickTaken), findsOneWidget);
    await closeApp(tester);
  });

  testWidgets('iOS scroll: oxirida overscroll — kontent qaytib tushmaydi, '
      'sarlavha va pastki menyu bounce bilan o‘zgarmaydi', (tester) async {
    final w = GroupsWorld();
    final s = await _setup(w, students: [for (var i = 0; i < 40; i++) 's$i']);
    await w.open(tester, uid: 'teacher', location: Routes.group(s.gid));
    final list = find.byKey(const Key('grp.detailList'));
    final title = find.byKey(const Key('grp.appBarTitle'));
    final nav = find.byKey(const Key('nav.floating'));
    double opacity() => tester.widget<AnimatedOpacity>(title).opacity;
    ScrollPosition pos() => tester
        .state<ScrollableState>(
          find.descendant(of: list, matching: find.byType(Scrollable)),
        )
        .position;
    expect(
      Theme.of(tester.element(list)).platform,
      TargetPlatform.iOS,
      reason: 'BouncingScrollPhysics',
    );
    expect(opacity(), 0);
    final fullNav = tester.getSize(nav).height;

    // Ostona atrofida sekin tortish — qo‘yilgan joy saqlanadi.
    await tester.drag(list, const Offset(0, -70));
    await tester.pumpAndSettle();
    final held = pos().pixels;
    expect(held, greaterThan(40));
    await tester.pump(const Duration(seconds: 1));
    expect(pos().pixels, held);

    // Oxirigacha.
    await tester.fling(list, const Offset(0, -3000), 4000);
    await tester.pumpAndSettle();
    final max = pos().maxScrollExtent;
    expect(pos().pixels, max);
    expect(opacity(), 1);
    final compactNav = tester.getSize(nav).height;
    expect(compactNav, lessThan(fullNav));
    final viewport = pos().viewportDimension;

    // 4 marta oxirida yuqoriga cho‘zib qo‘yib yuborish (bounce).
    for (var i = 0; i < 4; i++) {
      await tester.drag(list, const Offset(0, -260));
      await tester.pumpAndSettle();
      expect(pos().pixels, max, reason: 'overscroll $i: offset = oxiri');
      expect(pos().maxScrollExtent, max);
      expect(pos().viewportDimension, viewport);
      expect(opacity(), 1, reason: 'sarlavha bounce bilan o‘zgarmaydi');
      expect(tester.getSize(nav).height, compactNav);
    }
    // Haqiqiy yuqoriga surish — menyu to‘liq qaytadi.
    await tester.drag(list, const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(tester.getSize(nav).height, fullNav);
    await closeApp(tester);
  });

  testWidgets('ustoz paneli jonli: qo‘shildi → yechmoqda → tugatdi; katta '
      'ekran 1280×720', (tester) async {
    final w = GroupsWorld();
    final s = await _setup(w, students: ['a1', 'a2', 'a3']);
    await w.open(
      tester,
      uid: 'teacher',
      location: Routes.groupAssignment(s.gid, s.aid),
    );
    final l = _l(tester);
    expect(find.text(l.grpCounts(3, 0, 0)), findsOneWidget);
    w.backend.open('a1', s.aid);
    final q = w.backend.open('a2', s.aid).value!.questions;
    final key = {
      for (final p in w.backend.preview('teacher', s.aid).value!.pool)
        p.id: p.correctIndex,
    };
    w.backend.submit('a2', s.aid, {for (final x in q) x.id: key[x.id]!});
    await frames(tester, 6);
    expect(find.text(l.grpCounts(1, 1, 1)), findsOneWidget);
    expect(find.text('4/4'), findsOneWidget);
    await closeApp(tester);

    final w2 = GroupsWorld();
    final s2 = await _setup(w2, students: ['b1', 'b2']);
    await w2.open(
      tester,
      uid: 'teacher',
      size: const Size(1280, 720),
      iphone: false,
      location: Routes.groupBoard(s2.gid, s2.aid),
    );
    expect(find.byKey(const Key('grp.code')), findsOneWidget);
    expect(find.byKey(const Key('class.qr')), findsOneWidget);
    expect(find.text('Talaba 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await closeApp(tester);
  });

  testWidgets('ustoz: kichik mavzuda variant o‘chiq va sababi yozilgan', (
    tester,
  ) async {
    final w = GroupsWorld();
    final g = w.backend.create('teacher', 'Guruh A').value!;
    await w.open(tester, uid: 'teacher', location: Routes.groupAssign(g.id));
    final l = _l(tester);
    await tester.tap(find.byKey(const Key('grp.topic.tox-small')));
    await frames(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('grp.variantSwitch')),
      200,
      scrollable: find.descendant(
        of: find.byKey(const Key('grp.assignList')),
        matching: find.byType(Scrollable),
      ),
    );
    final sw = tester.widget<SwitchListTile>(
      find.byKey(const Key('grp.variantSwitch')),
    );
    expect(sw.onChanged, isNull);
    expect(sw.value, isFalse);
    expect(find.text(l.grpVariantTooFew(6, 12)), findsOneWidget);
    await closeApp(tester);
  });
}
