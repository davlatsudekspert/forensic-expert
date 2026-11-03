// «Guruh og‘zaki imtihoni» (QR): ustoz sozlash → doska → navbat → baholash →
// natijalar; talaba qo‘shilish → bilet → tayyor → chaqirildi → o‘z bali;
// server xatolari; rol himoyasi; 320 dp / 2× shrift (uz/ru/en).
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/keep_awake.dart';
import 'package:forensic_expert/app/lessons.dart';
import 'package:forensic_expert/app/oral_group.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/app/teacher_oral.dart';
import 'package:forensic_expert/core/settings/app_settings.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/data/lessons/fake_lessons_service.dart';
import 'package:forensic_expert/data/oral_group/fake_oral_group_service.dart';
import 'package:forensic_expert/domain/oral_group/oral_group_models.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/features/class_groups/presentation/groups_screens.dart'
    show GroupScanScreen;
import 'package:forensic_expert/features/class_quiz/presentation/class_quiz_hub_screen.dart'
    show ClassScanScreen;
import 'package:forensic_expert/features/oral_group/presentation/oral_group_grade_screen.dart';
import 'package:forensic_expert/features/oral_group/presentation/oral_group_host_screens.dart';
import 'package:forensic_expert/features/oral_group/presentation/oral_group_setup_screen.dart';
import 'package:forensic_expert/features/oral_group/presentation/oral_group_student_screens.dart';
import 'package:forensic_expert/features/oral_group/presentation/oral_group_widgets.dart'
    show routeOralScan;

import '../helpers/pump_app.dart';

Map<String, Object?> _deck(String id, String course, List<String> titles) => {
  'ok': true,
  'topic_id': id,
  'title': 'Mavzu $id',
  'course': course,
  'deck_id': '$id-deck',
  'source_lang': 'uz',
  'deck': {
    'topic': 'Mavzu $id',
    'slides': [
      for (final t in titles)
        {
          'title': t,
          'bullets': [
            {
              'text': '$t — asosiy fikr',
              'source': {'author': 'Aliyev', 'title': 'Kitob', 'page': '12'},
            },
          ],
        },
    ],
  },
};

final _decks = {
  'a1': _deck('a1', '4-kurs · Davolash', [
    'Kirish: mashg‘ulot maqsadi va rejasi',
    'Tan jarohatlarining yuridik tasnifi',
    'Hayot uchun xavf mezoni',
    'Sog‘liqning buzilish davomiyligi',
    'Sun’iy kasalliklar',
    'Xulosa',
  ]),
  'b1': _deck('b1', '5-kurs · Davolash', [
    'Kirish',
    'Jinsni aniqlash',
    'Jinsiy yetuklikni aniqlash',
    'Homiladorlik va tug‘ruqni aniqlash',
    'Nasl qoldirish qobiliyatini aniqlash',
    'Nazorat savollari',
  ]),
};

class _FakeShare implements ClassFileShare {
  final shared = <({String name, String content})>[];

  @override
  Future<void> shareCsv({
    required String fileName,
    required String content,
    String? subject,
  }) async => shared.add((name: fileName, content: content));
}

/// “Server”, ustoz (t1) va talabalar. Soat qo‘lda suriladi.
class _World {
  _World() {
    backend = FakeOralGroupBackend(
      clock: () => now,
      rng: math.Random(5),
      teachers: {'t1'},
    );
    teacher = FakeOralGroupService(backend, userId: 't1', demo: false);
  }

  var now = DateTime.utc(2026, 11, 3, 10);
  late final FakeOralGroupBackend backend;
  late final FakeOralGroupService teacher;
  final share = _FakeShare();

  FakeOralGroupService user(String id) =>
      FakeOralGroupService(backend, userId: id, demo: false);

  Future<OralGroupSession> create({int tickets = 3, int prep = 0}) async =>
      (await teacher.createSession(
        title: 'Mavzu a1',
        tickets: [
          for (var t = 0; t < tickets; t++)
            [
              for (var q = 0; q < 5; q++)
                OralGroupQuestion(
                  id: 'a1#${t * 5 + q + 1}',
                  text: 'Bilet ${t + 1} savol ${q + 1}',
                ),
            ],
        ],
        prepSeconds: prep,
      )).value!;
}

Future<void> _frames(WidgetTester tester, [int n = 6]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

/// Haqiqiy ketma-ketlik: resumed → inactive → hidden → paused (va teskari).
Future<void> _background(WidgetTester tester) async {
  for (final st in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(st);
  }
  await tester.pump();
}

Future<void> _foreground(WidgetTester tester) async {
  for (final st in [
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(st);
  }
  await tester.pump();
}

Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

Finder _key(String k) => find.byKey(Key(k));

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump(const Duration(milliseconds: 150));
  await tester.tap(f);
  await _frames(tester);
}

Future<ProviderContainer> _open(
  WidgetTester tester,
  _World w, {
  required String user,
  UserMode mode = UserMode.teacher,
  String lang = 'uz',
  String? location,
  Size size = const Size(390, 844),
  double textScale = 1,
  bool teacherRole = true,
  bool scanner = false,
}) async {
  final c = await pumpApp(
    tester,
    settings: completedSettings(lang: lang, mode: mode),
    size: size,
    textScale: textScale,
    overrides: <Override>[
      classQuizServiceProvider.overrideWithValue(
        FakeClassQuizService(
          FakeClassQuizBackend(teachers: {if (teacherRole) user}),
          userId: user,
          demo: false,
        ),
      ),
      lessonsServiceProvider.overrideWithValue(
        FakeLessonsService(isTeacher: teacherRole, demo: false, decks: _decks),
      ),
      oralGroupServiceProvider.overrideWithValue(w.user(user)),
      oralGroupPollIntervalProvider.overrideWithValue(
        const Duration(milliseconds: 150),
      ),
      oralGroupClockProvider.overrideWithValue(() => w.now),
      classFileShareProvider.overrideWithValue(w.share),
      classScreenAwakeProvider.overrideWithValue(_NoAwake()),
      classScannerAvailableProvider.overrideWithValue(scanner),
      teacherOralRandomProvider.overrideWithValue(math.Random(7)),
    ],
  );
  if (location != null) {
    c.read(routerProvider).go(location);
    await _frames(tester);
  }
  return c;
}

class _NoAwake implements ClassScreenAwake {
  @override
  Future<void> enable() async {}
  @override
  Future<void> disable() async {}
}

void main() {
  setUpAll(() => testDefaultPlan = Plan.teacher);
  tearDownAll(() => testDefaultPlan = null);

  testWidgets(
    'ustoz: mavzu → sozlash → doska (QR, ball yo‘q) → navbat → baholash → '
    'natijalar → yakunlash',
    (tester) async {
      final w = _World();
      await _open(tester, w, user: 't1', location: Routes.teacherOral);
      // Mavzu tanlanmaguncha «Guruhga (QR)» yopiq.
      expect(
        tester.widget<OutlinedButton>(_key('toral.group')).onPressed,
        isNull,
      );
      expect(find.text('Guruhga (QR)'), findsOne);
      expect(find.text('Bilet tuzish'), findsOne);
      await _tap(tester, _key('toral.topic.a1'));
      await _tap(tester, _key('toral.topic.b1'));
      await _tap(tester, _key('toral.group'));
      expect(find.byType(OralGroupSetupScreen), findsOne);
      // a1: 4 savol, b1: 4 savol.
      expect(find.text('Tanlangan mavzulardagi savollar: 8'), findsOne);
      expect(_key('oralgroup.count'), findsOne);
      expect(
        find.text('Savollar yetmaydi: ayrim biletlarda savollar takrorlanadi'),
        findsOne,
        reason: '25 talaba × 5 savol > 8',
      );
      await tester.enterText(_key('oralgroup.count'), '1');
      await _frames(tester);
      expect(
        find.text('Savollar yetmaydi: ayrim biletlarda savollar takrorlanadi'),
        findsNothing,
        reason: '1 bilet × 5 savol ≤ 8',
      );
      await tester.enterText(_key('oralgroup.count'), '3');
      await _tap(tester, _key('oralgroup.prep.10'));
      await _tap(tester, _key('oralgroup.start'));
      expect(find.byType(OralGroupHostScreen), findsOne);

      // Doska: QR + kod + hisob + biletlar.
      final session = (await w.teacher.mySessions()).value!.single;
      expect(session.ticketCount, 3);
      expect(session.prepSeconds, 600);
      expect(session.title, 'Mavzu a1 · Mavzu b1');
      expect(_key('class.qr'), findsOne);
      expect(
        find.text(
          '${session.code.substring(0, 3)} ${session.code.substring(3)}',
        ),
        findsOne,
      );
      expect(
        tester.widget<SelectableText>(_key('oralgroup.joinLink')).data,
        'forensicexpert://app/join/${session.code}?t=oral',
      );
      expect(find.text('Qo‘shildi: 0 / 3'), findsOne);
      expect(find.text('bo‘sh'), findsNWidgets(3));

      // Talaba qo‘shiladi → doskada ism; tayyor bo‘lsa → «tayyor».
      final ali =
          (await w.user('s1').join(code: session.code, name: 'Ali Valiyev'))
              .value!;
      await _frames(tester);
      expect(find.text('Qo‘shildi: 1 / 3'), findsOne);
      expect(find.text('Ali Valiyev'), findsOne);
      expect(find.text('qo‘shildi'), findsOne);
      await w.user('s1').ready(session.id);
      await _frames(tester);
      expect(find.text('tayyor'), findsOne);

      // Navbat.
      await _tap(tester, _key('oralgroup.queueButton'));
      expect(find.text('Tayyor (1)'), findsOne);
      await _tap(tester, _key('oralgroup.row.${ali.participantId}'));
      expect(find.byType(OralGroupGradeScreen), findsOne);
      // Chaqirildi (talaba ko‘radi).
      expect((await w.user('s1').myState(session.id)).value!.isCalled, isTrue);
      expect(find.text('Ali Valiyev'), findsOne);
      final myTicket = (await w.user('s1').myState(session.id)).value!.ticketNo;
      expect(find.text('Bilet № $myTicket'), findsOne);
      expect(find.text('Jami: 0 / 100'), findsOne);
      expect(
        tester.widget<FilledButton>(_key('oralgroup.save')).onPressed,
        isNull,
        reason: 'hamma savolga ball qo‘yilmaguncha saqlanmaydi',
      );
      // Javob kaliti mahalliy havzadan (slayd bandi + manba).
      final qid = (await w.teacher.teacherState(session.id)).value!
          .ticket(myTicket)!
          .questions
          .first
          .id;
      expect(qid, contains('#'));
      await _tap(tester, _key('oral.key.0'));
      expect(find.textContaining('— asosiy fikr'), findsWidgets);
      expect(find.textContaining('Aliyev, Kitob'), findsWidgets);

      final scores = [20, 20, 15, 10, 10];
      for (var i = 0; i < 5; i++) {
        await tester.ensureVisible(_key('oral.slider.$i'));
        tester.widget<Slider>(_key('oral.slider.$i')).onChanged!(
          scores[i].toDouble(),
        );
        await tester.pump();
      }
      await _frames(tester);
      expect(find.text('Jami: 75 / 100'), findsOne);
      await _tap(tester, _key('oralgroup.save'));
      expect(find.text('Baho saqlandi: 75 / 100'), findsOne);
      // Navbatga qaytdi: baholanganlar bo‘limida jami (faqat ustoz ekrani).
      expect(find.text('Baholanganlar (1)'), findsOne);
      expect(
        tester
            .widget<Text>(_key('oralgroup.rowTotal.${ali.participantId}'))
            .data,
        '75 / 100',
      );
      expect(
        (await w.teacher.teacherState(session.id))
            .value!
            .participants
            .single
            .scores,
        scores,
      );

      // Doskaga qaytsak: «baholandi», ball yo‘q (snackbar o‘tib ketgach).
      tester.state<NavigatorState>(find.byType(Navigator).last).pop();
      await tester.pump(const Duration(seconds: 6));
      await _frames(tester);
      expect(find.byType(OralGroupHostScreen), findsOne);
      expect(find.text('baholandi'), findsOne);
      expect(find.textContaining('75'), findsNothing);
      expect(find.textContaining('/ 100'), findsNothing);

      // Natijalar + CSV.
      await _tap(tester, _key('oralgroup.resultsButton'));
      expect(find.byType(OralGroupResultsScreen), findsOne);
      expect(find.text('Ali Valiyev'), findsOne);
      expect(find.text('75 / 100'), findsOne);
      await _tap(tester, _key('oralgroup.export'));
      expect(w.share.shared, hasLength(1));
      expect(w.share.shared.single.name, startsWith('og_zaki_imtihon_'));
      expect(
        w.share.shared.single.content.split('\r\n').first,
        'Ism,Bilet,1-savol,2-savol,3-savol,4-savol,5-savol,Jami',
      );
      expect(w.share.shared.single.content, contains('Ali Valiyev'));
      expect(w.share.shared.single.content, contains(',75'));
      tester.state<NavigatorState>(find.byType(Navigator).last).pop();
      await _frames(tester);

      // Yakunlash (tasdiq bilan): yangi talaba kira olmaydi.
      await _tap(tester, _key('oralgroup.finishButton'));
      expect(find.text('Imtihonni yakunlaymizmi?'), findsOne);
      await tester.tap(_key('oralgroup.finishConfirm'));
      await _frames(tester);
      expect(_key('oralgroup.finishedBanner'), findsOne);
      expect(_key('oralgroup.finishButton'), findsNothing);
      expect(
        (await w.user('s2').join(code: session.code, name: 'Vali')).failure,
        isNotNull,
      );
      await _close(tester);
    },
  );

  testWidgets(
    'ustoz: baholashda talabani chiqarish (tasdiq) — bilet bo‘shaydi',
    (tester) async {
      final w = _World();
      final s = await w.create(tickets: 1);
      final p = (await w.user('s1').join(code: s.code, name: 'Vali')).value!;
      await _open(
        tester,
        w,
        user: 't1',
        location: Routes.oralGroupGrade(s.id, p.participantId),
      );
      expect(find.text('Vali'), findsOne);
      await tester.tap(_key('oralgroup.menu'));
      await _frames(tester);
      await tester.tap(_key('oralgroup.kick'));
      await _frames(tester);
      expect(find.text('Vali imtihondan chiqarilsinmi?'), findsOne);
      await tester.tap(_key('oralgroup.kickConfirm'));
      await _frames(tester);
      expect((await w.teacher.teacherState(s.id)).value!.participants, isEmpty);
      expect(
        (await w.user('s1').join(code: s.code, name: 'Vali')).failure,
        isNotNull,
      );
      expect(
        (await w.user('s2').join(code: s.code, name: 'Boshqa')).ok,
        isTrue,
        reason: 'bilet bo‘shadi',
      );
      await _close(tester);
    },
  );

  testWidgets(
    'ustoz: faol imtihonlar ro‘yxati sozlash ekranida, qayta ochiladi',
    (tester) async {
      final w = _World();
      final s = await w.create(tickets: 2);
      await _open(tester, w, user: 't1', location: Routes.teacherOralGroup);
      expect(_key('oralgroup.noTopics'), findsOne);
      expect(_key('oralgroup.start'), findsNothing);
      expect(find.text('Faol imtihonlar'), findsOne);
      await _tap(tester, _key('oralgroup.session.${s.id}'));
      expect(find.byType(OralGroupHostScreen), findsOne);
      expect(find.text('Qo‘shildi: 0 / 2'), findsOne);
      await _close(tester);
    },
  );

  testWidgets(
    'talaba: QR → qo‘shilish → bilet → tayyor → chaqirildi → o‘z bali',
    (tester) async {
      final w = _World();
      final s = await w.create(prep: 600);
      final c = await _open(
        tester,
        w,
        user: 's1',
        mode: UserMode.student,
        teacherRole: false,
        location: '/join/${s.code}?t=oral',
      );
      expect(find.byType(OralGroupJoinScreen), findsOne);
      expect(
        tester.widget<TextField>(_key('oralgroup.joinCode')).controller!.text,
        s.code,
      );
      await tester.enterText(_key('oralgroup.joinName'), '  Vali   Karimov ');
      await _tap(tester, _key('oralgroup.joinSubmit'));
      expect(find.byType(OralGroupPlayScreen), findsOne);
      final my = (await w.user('s1').myState(s.id)).value!;
      expect(my.name, 'Vali Karimov');
      expect(find.text('Bilet № ${my.ticketNo}'), findsOne);
      expect(find.text('Ism: Vali Karimov'), findsOne);
      for (var i = 1; i <= 5; i++) {
        expect(
          find.text('Bilet ${my.ticketNo} savol $i'),
          findsOne,
          reason: 'savol $i',
        );
      }
      // Javob kaliti talabaga ko‘rinmaydi.
      expect(find.textContaining('asosiy fikr'), findsNothing);
      expect(_key('oral.key.0'), findsNothing);
      expect(find.text('Tayyorlanish vaqti: 10:00'), findsOne);
      w.now = w.now.add(const Duration(seconds: 90));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Tayyorlanish vaqti: 08:30'), findsOne);
      expect(_key('oralgroup.result'), findsNothing);

      await _tap(tester, _key('oralgroup.ready'));
      expect(
        find.text('Navbatdasiz. Ustoz sizni chaqirishini kuting.'),
        findsOne,
      );
      expect(_key('oralgroup.ready'), findsNothing);
      expect(
        (await w.teacher.teacherState(s.id)).value!.participants.single.isReady,
        isTrue,
      );
      // Ustoz chaqiradi.
      final pid = (await w.teacher.teacherState(s.id))
          .value!
          .participants
          .single
          .id;
      await w.teacher.call(s.id, pid);
      await _frames(tester);
      expect(_key('oralgroup.called'), findsOne);
      expect(find.textContaining('Ustoz sizni chaqirdi'), findsOne);
      // Baholaydi → o‘z natijasi.
      await w.teacher.grade(s.id, pid, [20, 20, 20, 10, 10]);
      await _frames(tester);
      expect(find.text('Jami: 80 / 100'), findsOne);
      expect(find.text('Savol 1: 20 / 20'), findsOne);
      expect(find.text('Savol 4: 10 / 20'), findsOne);
      expect(_key('oralgroup.called'), findsNothing);
      expect(c, isNotNull);
      await _close(tester);
    },
  );

  testWidgets('talaba: ilovani qayta ochgach shu bilet qaytadi', (
    tester,
  ) async {
    final w = _World();
    final s = await w.create();
    final first = (await w.user('s1').join(code: s.code, name: 'Vali')).value!;
    final ticket = (await w.user('s1').myState(s.id)).value!.ticketNo;
    await _open(
      tester,
      w,
      user: 's1',
      mode: UserMode.student,
      teacherRole: false,
      location: Routes.oralJoinWith(s.code),
    );
    // Ism qayta yozilmaydi: bo‘sh qoldirilsa ham server o‘sha biletni qaytaradi.
    await _tap(tester, _key('oralgroup.joinSubmit'));
    expect(find.byType(OralGroupPlayScreen), findsOne);
    expect(find.text('Bilet № $ticket'), findsOne);
    expect(find.text('Ism: Vali'), findsOne);
    expect(first.participantId, isNotEmpty);
    await _close(tester);
  });

  testWidgets('talaba: «Guruh testi» kod maydoni oral kodni ham qabul qiladi', (
    tester,
  ) async {
    final w = _World();
    final s = await w.create();
    await _open(
      tester,
      w,
      user: 's1',
      mode: UserMode.student,
      teacherRole: false,
      location: Routes.classQuiz,
    );
    await tester.enterText(_key('class.codeField'), s.code);
    await _tap(tester, _key('class.joinButton'));
    // Guruh testi ekrani: kod to‘ldirilgan, laqab so‘raladi.
    await tester.enterText(_key('class.nickField'), 'Vali');
    await _tap(tester, _key('class.joinSubmit'));
    // «Guruh testi»da topilmadi → og‘zaki imtihon ekrani, ism o‘tgan.
    expect(find.byType(OralGroupJoinScreen), findsOne);
    expect(
      tester.widget<TextField>(_key('oralgroup.joinName')).controller!.text,
      'Vali',
    );
    await _tap(tester, _key('oralgroup.joinSubmit'));
    expect(find.byType(OralGroupPlayScreen), findsOne);
    await _close(tester);
  });

  testWidgets(
    'talaba: laqab bo‘sh bo‘lsa ham oral kodga o‘tadi (bloklanmaydi)',
    (tester) async {
      final w = _World();
      final s = await w.create();
      await _open(
        tester,
        w,
        user: 's1',
        mode: UserMode.student,
        teacherRole: false,
        location: Routes.classQuiz,
      );
      await tester.enterText(_key('class.codeField'), s.code);
      await _tap(tester, _key('class.joinButton'));
      // Laqab yozilmadi (bo‘sh) → xato ko‘rsatilmaydi, oral ekran ochiladi.
      await _tap(tester, _key('class.joinSubmit'));
      expect(find.byType(OralGroupJoinScreen), findsOne);
      await tester.enterText(_key('oralgroup.joinName'), 'Abdurahmonov Vali');
      await _tap(tester, _key('oralgroup.joinSubmit'));
      expect(find.byType(OralGroupPlayScreen), findsOne);
      expect(find.text('Ism: Abdurahmonov Vali'), findsOne);
      await _close(tester);
    },
  );

  testWidgets('talaba: ism serverda rad etilsa — ism maydonida xato', (
    tester,
  ) async {
    final w = _World();
    final s = await w.create();
    await _open(
      tester,
      w,
      user: 's1',
      mode: UserMode.student,
      teacherRole: false,
      location: Routes.oralJoinWith(s.code),
    );
    await _tap(tester, _key('oralgroup.joinSubmit'));
    expect(find.text('Ism 2–40 belgidan iborat bo‘lsin.'), findsOne);
    expect(find.byType(OralGroupPlayScreen), findsNothing);
    await _close(tester);
  });

  testWidgets('talaba: «Davom etish: Bilet № X» kartasi, yakunda yashirinadi', (
    tester,
  ) async {
    final w = _World();
    final s = await w.create();
    await _open(
      tester,
      w,
      user: 's1',
      mode: UserMode.student,
      teacherRole: false,
      location: Routes.oralJoinWith(s.code),
    );
    expect(_key('oralgroup.resume'), findsNothing);
    await tester.enterText(_key('oralgroup.joinName'), 'Vali');
    await _tap(tester, _key('oralgroup.joinSubmit'));
    final ticket = (await w.user('s1').myState(s.id)).value!.ticketNo;
    // Hubga qaytganda karta ko‘rinadi va bilet ekraniga olib boradi.
    final c = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    expect(c.read(oralResumeProvider)!.sessionId, s.id);
    c.read(routerProvider).go(Routes.classQuiz);
    await _frames(tester, 8);
    expect(find.text('Davom etish: Bilet № $ticket'), findsOne);
    await _tap(tester, _key('oralgroup.resume'));
    expect(find.byType(OralGroupPlayScreen), findsOne);
    // Imtihon yakunlansa karta yo‘qoladi.
    c.read(routerProvider).go(Routes.classQuiz);
    await _frames(tester, 8);
    expect(_key('oralgroup.resume'), findsOne);
    await w.teacher.finish(s.id);
    await _frames(tester, 8);
    expect(_key('oralgroup.resume'), findsNothing);
    expect(c.read(oralResumeProvider), isNull);
    await _close(tester);
  });

  testWidgets('talaba: chiqarilgan bo‘lsa «Davom etish» kartasi yo‘q', (
    tester,
  ) async {
    final w = _World();
    final s = await w.create();
    final p = (await w.user('s1').join(code: s.code, name: 'Vali')).value!;
    final c = await _open(
      tester,
      w,
      user: 's1',
      mode: UserMode.student,
      teacherRole: false,
      location: Routes.classQuiz,
    );
    await c.read(oralResumeProvider.notifier).remember(s.code, s.id);
    await _frames(tester, 8);
    expect(_key('oralgroup.resume'), findsOne);
    await w.teacher.kick(s.id, p.participantId);
    await _frames(tester, 8);
    expect(_key('oralgroup.resume'), findsNothing);
    expect(c.read(oralResumeProvider), isNull);
    await _close(tester);
  });

  testWidgets('ilovadan chiqish: talaba ko‘radi, ustozga navbat/baholashda '
      'chiqadi, doskada yo‘q; ekran o‘chmaydi', (tester) async {
    final w = _World();
    final s = await w.create();
    final p = (await w.user('s1').join(code: s.code, name: 'Vali')).value!;
    final c = await _open(
      tester,
      w,
      user: 's1',
      mode: UserMode.student,
      teacherRole: false,
      location: Routes.oralPlay(s.id),
    );
    expect(_key('ac.studentNote'), findsOne);
    expect(c.read(keepAwakeProvider).held, isTrue);
    expect(_key('oralgroup.leaveCount'), findsNothing);
    for (var i = 0; i < 2; i++) {
      w.now = w.now.add(const Duration(minutes: 1));
      await _background(tester);
      await tester.pump();
      await _foreground(tester);
      await tester.pump();
    }
    await _frames(tester, 8);
    expect(find.text('Ilovadan chiqishlaringiz: 2'), findsOne);
    final st = (await w.teacher.teacherState(s.id)).value!.participants.single;
    expect(st.leaveCount, 2);
    expect(st.lastLeftAt, w.now);
    // Baholangach hisoblanmaydi, ekran qo‘yib yuboriladi.
    await w.teacher.grade(s.id, p.participantId, [1, 2, 3, 4, 5]);
    await _frames(tester, 8);
    expect(c.read(keepAwakeProvider).held, isFalse);
    expect(_key('ac.studentNote'), findsNothing);
    await _background(tester);
    await tester.pump();
    await _foreground(tester);
    await tester.pump();
    expect(
      (await w.teacher.teacherState(s.id))
          .value!
          .participants
          .single
          .leaveCount,
      2,
    );
    await _close(tester);

    // Ustoz: navbat va baholash ekranlarida belgi; doskada yo‘q.
    await w.teacher.finish(s.id);
    final s2 = await w.create();
    final p2 = (await w.user('s2').join(code: s2.code, name: 'Ali')).value!;
    await w.user('s2').reportLeave(s2.id);
    await _open(tester, w, user: 't1', location: Routes.oralGroupQueue(s2.id));
    expect(_key('ac.leave.${p2.participantId}'), findsOne);
    expect(find.text('ilovadan chiqdi: 1 marta'), findsOne);
    expect(_key('oralgroup.leftAt.${p2.participantId}'), findsOne);
    c.read(routerProvider);
    final c2 = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    c2.read(routerProvider).go(Routes.oralGroupGrade(s2.id, p2.participantId));
    await _frames(tester, 8);
    expect(_key('ac.leave.${p2.participantId}'), findsOne);
    c2.read(routerProvider).go(Routes.oralGroupHost(s2.id));
    await _frames(tester, 8);
    expect(find.byType(OralGroupHostScreen), findsOne);
    expect(_key('ac.leave.${p2.participantId}'), findsNothing);
    expect(find.textContaining('chiqdi'), findsNothing);
    await _close(tester);
  });

  group('QR skaner (kamerasiz: skanerlangan matn → yo‘naltirish)', () {
    const link = 'forensicexpert://app/join/%s?t=oral';

    testWidgets('«Guruh testi» skaneri oral havolani oral ekranga ochadi', (
      tester,
    ) async {
      final w = _World();
      final s = await w.create();
      await _open(
        tester,
        w,
        user: 's1',
        mode: UserMode.student,
        teacherRole: false,
        location: Routes.classScan,
      );
      expect(find.byType(ClassScanScreen), findsOne);
      // Oddiy 6 raqam oral emas: yo‘naltirilmaydi.
      expect(
        routeOralScan(tester.element(find.byType(ClassScanScreen)), s.code),
        isFalse,
      );
      expect(
        routeOralScan(
          tester.element(find.byType(ClassScanScreen)),
          link.replaceFirst('%s', s.code),
        ),
        isTrue,
      );
      await _frames(tester);
      expect(find.byType(OralGroupJoinScreen), findsOne);
      expect(find.byType(ClassScanScreen), findsNothing);
      expect(
        tester.widget<TextField>(_key('oralgroup.joinCode')).controller!.text,
        s.code,
      );
      await _close(tester);
    });

    testWidgets('«Guruhlar» skaneri ham oral havolani oral ekranga ochadi', (
      tester,
    ) async {
      final w = _World();
      final s = await w.create();
      await _open(
        tester,
        w,
        user: 's1',
        mode: UserMode.student,
        teacherRole: false,
        location: Routes.groupScan,
      );
      expect(find.byType(GroupScanScreen), findsOne);
      expect(
        routeOralScan(
          tester.element(find.byType(GroupScanScreen)),
          link.replaceFirst('%s', s.code),
        ),
        isTrue,
      );
      await _frames(tester);
      expect(find.byType(OralGroupJoinScreen), findsOne);
      await _close(tester);
    });

    testWidgets('oral qo‘shilish ekranida «QR skaner» tugmasi bor va natija '
        'ekranni takrorlamaydi', (tester) async {
      final w = _World();
      final s = await w.create();
      final c = await _open(
        tester,
        w,
        user: 's1',
        mode: UserMode.student,
        teacherRole: false,
        location: Routes.oralJoinWith(s.code),
        scanner: true,
      );
      expect(_key('oralgroup.scanButton'), findsOne);
      expect(find.text('QR skanerlash'), findsOne);
      await tester.enterText(_key('oralgroup.joinName'), 'Vali');
      await _tap(tester, _key('oralgroup.scanButton'));
      expect(find.byType(ClassScanScreen), findsOne);
      expect(
        routeOralScan(
          tester.element(find.byType(ClassScanScreen)),
          link.replaceFirst('%s', s.code),
          popResult: true,
        ),
        isTrue,
      );
      await _frames(tester, 10);
      // Natija kodni to‘ldirdi va qo‘shildi (ism maydonidagi 'Vali' bilan).
      expect(find.byType(OralGroupPlayScreen), findsOne);
      expect(find.text('Ism: Vali'), findsOne);
      expect(c.read(routerProvider), isNotNull);
      await _close(tester);
    });
  });

  group('xatolar (o‘zbekcha matn)', () {
    Future<void> submit(
      WidgetTester tester,
      _World w, {
      required String code,
      required String name,
      String user = 's9',
    }) async {
      await _open(
        tester,
        w,
        user: user,
        mode: UserMode.student,
        teacherRole: false,
        location: Routes.oralJoinWith(code),
      );
      await tester.enterText(_key('oralgroup.joinCode'), code);
      await tester.enterText(_key('oralgroup.joinName'), name);
      await _tap(tester, _key('oralgroup.joinSubmit'));
    }

    testWidgets('noto‘g‘ri kod va topilmadi', (tester) async {
      final w = _World();
      final s = await w.create();
      await submit(tester, w, code: '12', name: 'Vali');
      expect(find.text('6 xonali kodni kiriting.'), findsOne);
      await tester.enterText(
        _key('oralgroup.joinCode'),
        s.code == '111111' ? '222222' : '111111',
      );
      await _tap(tester, _key('oralgroup.joinSubmit'));
      expect(
        find.text(
          'Bu kod bo‘yicha test yoki imtihon topilmadi. Kodni tekshiring.',
        ),
        findsOne,
      );
      expect(find.byType(OralGroupPlayScreen), findsNothing);
      await _close(tester);
    });

    testWidgets('ism: juda qisqa, taqiqlangan', (tester) async {
      final w = _World();
      final s = await w.create();
      await submit(tester, w, code: s.code, name: 'V');
      expect(find.text('Ism 2–40 belgidan iborat bo‘lsin.'), findsOne);
      await tester.enterText(_key('oralgroup.joinName'), 'Sh1t Ali');
      await _tap(tester, _key('oralgroup.joinSubmit'));
      expect(find.text('Boshqa ism yozing.'), findsOne);
      expect(find.byType(OralGroupPlayScreen), findsNothing);
      await _close(tester);
    });

    testWidgets('joy qolmagan (full)', (tester) async {
      final w = _World();
      final s = await w.create(tickets: 1);
      await w.user('a').join(code: s.code, name: 'Birinchi');
      await submit(tester, w, code: s.code, name: 'Ikkinchi');
      expect(
        find.text('Barcha biletlar band: bu imtihonda joy qolmagan.'),
        findsOne,
      );
      await _close(tester);
    });

    testWidgets('imtihon yakunlangan', (tester) async {
      final w = _World();
      final s = await w.create();
      await w.teacher.finish(s.id);
      await submit(tester, w, code: s.code, name: 'Vali');
      expect(
        find.text('Bu imtihon yakunlangan, yangi talabalar qo‘shila olmaydi.'),
        findsOne,
      );
      await _close(tester);
    });

    testWidgets('ustoz chiqargan talaba qayta kira olmaydi', (tester) async {
      final w = _World();
      final s = await w.create();
      final p = (await w.user('s9').join(code: s.code, name: 'Vali')).value!;
      await w.teacher.kick(s.id, p.participantId);
      await submit(tester, w, code: s.code, name: 'Vali');
      expect(find.text('Ustoz sizni bu imtihondan chiqardi.'), findsOne);
      await _close(tester);
    });

    testWidgets('o‘z imtihoniga ustoz qo‘shila olmaydi', (tester) async {
      final w = _World();
      final s = await w.create();
      await submit(tester, w, code: s.code, name: 'Ustoz', user: 't1');
      expect(
        find.text(
          'Siz bu imtihonning ustozisiz, talaba sifatida qo‘shila olmaysiz.',
        ),
        findsOne,
      );
      await _close(tester);
    });

    testWidgets('chiqarilgach bilet ekrani tushunarli xato beradi', (
      tester,
    ) async {
      final w = _World();
      final s = await w.create();
      final p = (await w.user('s9').join(code: s.code, name: 'Vali')).value!;
      await _open(
        tester,
        w,
        user: 's9',
        mode: UserMode.student,
        teacherRole: false,
        location: Routes.oralPlay(s.id),
      );
      expect(find.byType(OralGroupPlayScreen), findsOne);
      expect(_key('oralgroup.ticketNo'), findsOne);
      await w.teacher.kick(s.id, p.participantId);
      // Oldingi bilet saqlanib turadi (bitta xato ekranni almashtirmaydi),
      // yangi sessiya id esa xato beradi.
      await _close(tester);
      await _open(
        tester,
        w,
        user: 's9',
        mode: UserMode.student,
        teacherRole: false,
        location: Routes.oralPlay(s.id),
      );
      expect(_key('oralgroup.playError'), findsOne);
      expect(
        find.text('Siz bu imtihonda emassiz yoki ustoz sizni chiqargan.'),
        findsOne,
      );
      await _close(tester);
    });
  });

  group('rol himoyasi', () {
    for (final mode in [UserMode.student, UserMode.professional]) {
      testWidgets('${mode.name}: ustoz marshrutlari ochilmaydi', (
        tester,
      ) async {
        final w = _World();
        final s = await w.create();
        for (final route in [
          Routes.teacherOralGroup,
          Routes.teacherOralGroupFor('a1'),
          Routes.oralGroupHost(s.id),
          Routes.oralGroupQueue(s.id),
          Routes.oralGroupResults(s.id),
          Routes.oralGroupGrade(s.id, 'p1'),
        ]) {
          await _open(
            tester,
            w,
            user: 's1',
            mode: mode,
            teacherRole: false,
            location: route,
          );
          expect(
            find.byType(OralGroupSetupScreen),
            findsNothing,
            reason: route,
          );
          expect(find.byType(OralGroupHostScreen), findsNothing, reason: route);
          expect(
            find.byType(OralGroupQueueScreen),
            findsNothing,
            reason: route,
          );
          expect(
            find.byType(OralGroupResultsScreen),
            findsNothing,
            reason: route,
          );
          expect(
            find.byType(OralGroupGradeScreen),
            findsNothing,
            reason: route,
          );
          expect(_key('oralgroup.start'), findsNothing, reason: route);
          await _close(tester);
        }
      });
    }

    testWidgets('Ustoz rejimi, lekin serverda ustoz roli yo‘q: ekran yopiq', (
      tester,
    ) async {
      final w = _World();
      final s = await w.create();
      await _open(
        tester,
        w,
        user: 's1',
        teacherRole: false,
        location: Routes.oralGroupHost(s.id),
      );
      expect(_key('class.forbidden'), findsOne);
      expect(_key('class.qr'), findsNothing);
      await _close(tester);
    });
  });

  group('320 dp, 2.0 shrift: to‘lib ketmaydi', () {
    for (final lang in ['uz', 'ru', 'en']) {
      testWidgets('ustoz, $lang', (tester) async {
        final w = _World();
        final s = await w.create(tickets: 14, prep: 300);
        final ids = <String>[];
        for (var i = 0; i < 6; i++) {
          final p =
              (await w
                      .user('s$i')
                      .join(
                        code: s.code,
                        name: i == 0
                            ? 'Abdurahmonov Muhammadjon Abdulla o‘g‘li'
                            : 'Talaba $i',
                      ))
                  .value!;
          ids.add(p.participantId);
        }
        await w.user('s1').ready(s.id);
        await w.teacher.grade(s.id, ids[2], [20, 20, 20, 20, 20]);
        const size = Size(320, 640);

        // Mavzu tanlash + sozlash.
        await _open(
          tester,
          w,
          user: 't1',
          lang: lang,
          size: size,
          textScale: 2,
          location: Routes.teacherOral,
        );
        expect(tester.takeException(), isNull, reason: '$lang: mavzular');
        await tester.scrollUntilVisible(
          _key('toral.topic.a1'),
          200,
          scrollable: find
              .descendant(
                of: _key('toral.list'),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await _tap(tester, _key('toral.topic.a1'));
        expect(tester.takeException(), isNull, reason: '$lang: tanlandi');
        await _tap(tester, _key('toral.group'));
        expect(find.byType(OralGroupSetupScreen), findsOne);
        await tester.scrollUntilVisible(
          _key('oralgroup.start'),
          200,
          scrollable: find
              .descendant(
                of: _key('oralgroup.setupList'),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        expect(tester.takeException(), isNull, reason: '$lang: sozlash');

        for (final route in [
          Routes.oralGroupHost(s.id),
          Routes.oralGroupQueue(s.id),
          Routes.oralGroupGrade(s.id, ids[1]),
          Routes.oralGroupResults(s.id),
        ]) {
          _c(tester).read(routerProvider).go(route);
          await _frames(tester, 8);
          expect(tester.takeException(), isNull, reason: '$lang: $route');
        }
        // Doskadagi tugmalargacha aylantirish ham xatosiz.
        _c(tester).read(routerProvider).go(Routes.oralGroupHost(s.id));
        await _frames(tester, 8);
        await tester.scrollUntilVisible(
          _key('oralgroup.finishButton'),
          300,
          scrollable: find
              .descendant(
                of: _key('oralgroup.hostList'),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        expect(tester.takeException(), isNull, reason: '$lang: doska past');
        await _close(tester);
      });

      testWidgets('talaba, $lang', (tester) async {
        final w = _World();
        final s = await w.create(prep: 900);
        final p =
            (await w
                    .user('s1')
                    .join(
                      code: s.code,
                      name: 'Abdurahmonov Muhammadjon Abdulla o‘g‘li',
                    ))
                .value!;
        const size = Size(320, 640);
        await _open(
          tester,
          w,
          user: 's1',
          mode: UserMode.student,
          lang: lang,
          teacherRole: false,
          size: size,
          textScale: 2,
          location: Routes.oralJoinWith(s.code),
        );
        expect(tester.takeException(), isNull, reason: '$lang: qo‘shilish');
        await tester.enterText(_key('oralgroup.joinName'), 'Vali');
        await _frames(tester);
        await _tap(tester, _key('oralgroup.joinSubmit'));
        expect(find.byType(OralGroupPlayScreen), findsOne);
        expect(tester.takeException(), isNull, reason: '$lang: bilet');
        await tester.scrollUntilVisible(
          _key('oralgroup.ready'),
          200,
          scrollable: find
              .descendant(
                of: _key('oralgroup.playList'),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await _tap(tester, _key('oralgroup.ready'));
        await w.teacher.call(s.id, p.participantId);
        await _frames(tester);
        expect(tester.takeException(), isNull, reason: '$lang: chaqirildi');
        await w.teacher.grade(s.id, p.participantId, [20, 20, 20, 20, 20]);
        await _frames(tester);
        expect(_key('oralgroup.result'), findsOne);
        expect(tester.takeException(), isNull, reason: '$lang: natija');
        await _close(tester);
      });
    }
  });
}

ProviderContainer _c(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
