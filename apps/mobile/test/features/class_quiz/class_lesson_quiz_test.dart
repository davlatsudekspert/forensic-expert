// «Har darsdan keyin test» (2026-10-24):
//  * savol soni chiplari 10 / 15 / 20 (+ Boshqa), yetarli bo‘lmasa maksimum;
//  * kirgan talabada profil ismi taxallusga avtomatik, kirmaganda bo‘sh;
//  * «Qiyin savollar» → muhokama varaqasi (variantlar, to‘g‘ri javob, xato %,
//    izoh, manba; ismlar yo‘q; oldingi/keyingi);
//  * reyting: o‘rin, to‘g‘ri soni; «tarjima kutilmoqda» belgisi.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/professional.dart';
import 'package:forensic_expert/app/providers.dart';
import 'package:forensic_expert/app/router.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/data/class_quiz/fake_class_quiz_service.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';
import 'package:forensic_expert/domain/ports/backend_ports.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';

import '../../helpers/class_groups_world.dart' show TestAuth, signedInAs;
import '../../helpers/pump_app.dart';

const _nicks = ['Ali', 'Vali', 'Gulnora', 'Sherzod'];

ClassBankTopic lessonTopic(
  String id,
  int n, {
  String translation = '',
  String? title,
}) => ClassBankTopic(
  id: id,
  title: title ?? 'Toksikologik kimyo: $id',
  questions: [
    for (var i = 1; i <= n; i++)
      ClassBankQuestion(
        question:
            'Savol $i. Qonda etil spirtini aniqlashda qaysi usul '
            'eng ishonchli hisoblanadi?',
        options: ['GX bo‘shliq usuli', 'Rangli reaksiya', 'Titrlash', 'PMR'],
        correctIndex: 0,
        explanation:
            'Bo‘shliq gaz xromatografiyasi ($i) etanolni aniq miqdoriy '
            'aniqlaydi, rangli reaksiya esa faqat dastlabki sinov.',
        source: ClassSource(
          author: 'Yuldashev A.',
          title: 'Toksikologik kimyo',
          page: '${100 + i}',
          translation: translation,
        ),
      ),
  ],
);

class World {
  World({List<ClassBankTopic>? topics}) {
    backend = FakeClassQuizBackend(
      clock: () => now,
      rng: Random(3),
      teachers: {'t1'},
      topics: topics ?? [lessonTopic('lesson-a', 12)],
    );
    teacher = FakeClassQuizService(backend, userId: 't1', demo: false);
  }

  var now = DateTime(2026, 10, 24, 10);
  late final FakeClassQuizBackend backend;
  late final FakeClassQuizService teacher;
  final students = <FakeClassQuizService>[];

  /// Sessiya: 4 talaba; Q0 hamma xato, Q1 bittasi to‘g‘ri, Q2 uchtasi to‘g‘ri;
  /// tugagan.
  Future<ClassSessionInfo> finishedSession({
    String topic = 'lesson-a',
    int questions = 5,
  }) async {
    final s = (await teacher.createSession(
      topicId: topic,
      settings: ClassQuizSettings(questionCount: questions, studentLimit: 30),
    )).value!;
    for (var i = 0; i < _nicks.length; i++) {
      final st = FakeClassQuizService(backend, userId: 'u$i', demo: false);
      expect((await st.join(code: s.code, nickname: _nicks[i])).ok, isTrue);
      students.add(st);
    }
    await teacher.start(s.id);
    const rightCount = [0, 1, 3];
    for (var q = 0; q < rightCount.length; q++) {
      final cur = (await teacher.dashboard(s.id)).value!.current!;
      final wrong = cur.options.firstWhere((o) => o.id != cur.correctOption);
      for (var i = 0; i < students.length; i++) {
        await students[i].submitAnswer(
          sessionId: s.id,
          questionIndex: q,
          optionId: i < rightCount[q] ? cur.correctOption : wrong.id,
        );
        now = now.add(const Duration(milliseconds: 1500));
      }
      now = now.add(const Duration(seconds: 40));
      await teacher.closeQuestion(s.id);
      await teacher.next(s.id);
    }
    await teacher.finish(s.id);
    return s;
  }
}

Future<void> frames(WidgetTester tester, [int n = 8]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Future<ProviderContainer> openAt(
  WidgetTester tester, {
  required FakeClassQuizService svc,
  required String location,
  Size size = const Size(390, 844),
  String lang = 'uz',
  List<dynamic> extra = const [],
}) async {
  final c = await pumpApp(
    tester,
    settings: completedSettings(lang: lang),
    size: size,
    overrides: [
      classQuizServiceProvider.overrideWithValue(svc),
      classQuizPollIntervalProvider.overrideWithValue(
        const Duration(milliseconds: 100),
      ),
      classScannerAvailableProvider.overrideWithValue(false),
      classLandscapePromptEnabledProvider.overrideWithValue(false),
      ...extra.cast(),
    ],
  );
  c.read(routerProvider).go(location);
  await frames(tester);
  return c;
}

AppLocalizations l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).first));

Future<void> reveal(WidgetTester tester, Key key) async {
  await tester.scrollUntilVisible(
    find.byKey(key),
    120,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
}

Future<void> closeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  group('domen', () {
    test(
      'laqab profil ismidan: qisqa — o‘zi, uzun — «Ism F.», filtr saqlanadi',
      () {
        expect(
          ClassNickname.fromProfileName('Dilnoza Karimova'),
          'Dilnoza Karimova',
        );
        expect(ClassNickname.fromProfileName('  Ali  Valiyev '), 'Ali Valiyev');
        expect(
          ClassNickname.fromProfileName(
            'Abdurahmonov Muhammadjon Shavkatovich',
          ),
          'Abdurahmonov M.',
        );
        expect(ClassNickname.fromProfileName(''), '');
        expect(ClassNickname.fromProfileName(null), '');
        expect(ClassNickname.fromProfileName('A'), '');
        expect(ClassNickname.fromProfileName('f.u.c.k'), '');
        expect(
          ClassNickname.check(
            ClassNickname.fromProfileName('G‘ayrat Ro‘ziyev'),
          ),
          NicknameCheck.ok,
        );
      },
    );

    test('savol soni: presetlar 10/15/20, standart 10', () {
      expect(ClassQuizRules.questionPresets, [10, 15, 20]);
      expect(const ClassQuizSettings().questionCount, 10);
    });

    test('ClassHardDetail server JSON’idan (variantlar matn ro‘yxati)', () {
      final d = ClassHardDetail.fromJson({
        'index': 2,
        'text': 'Savol?',
        'options': ['a', 'b', 'c', 'd'],
        'correct_index': 1,
        'explanation': 'Izoh',
        'source': {
          'author': 'X',
          'title': 'Y',
          'page': '12',
          'translation': 'pending',
        },
        'answered': 8,
        'correct_pct': 25,
        'option_counts': [1, 2, 3, 2],
      });
      expect(d.options, ['a', 'b', 'c', 'd']);
      expect(d.correctIndex, 1);
      expect(d.wrongPct, 75);
      expect(d.source.isTranslationPending, isTrue);
      expect(d.optionCounts, [1, 2, 3, 2]);
    });

    test('reyting qatori: avg_ms ixtiyoriy', () {
      final a = ClassLeaderRow.fromJson({
        'participant_id': 'p',
        'nickname': 'Ali',
        'score': 900,
        'correct': 2,
        'rank': 1,
      });
      expect(a.avgMs, isNull);
      final b = ClassLeaderRow.fromJson({
        'participant_id': 'p',
        'nickname': 'Ali',
        'score': 900,
        'correct': 2,
        'rank': 1,
        'avg_ms': 12300,
      });
      expect(b.avgMs, 12300);
    });

    test('bank: faqat o‘zbekcha yozuv — ru/en «pending» belgisi bilan', () {
      final bank = ClassQuizBank.parse('''
{"format":"fe.class_quiz_bank/1","groups":[],"topics":[{
 "id":"toks-01-x","group":"toksikologik-kimyo","number":1,"source_lang":"uz",
 "title_i18n":{"uz":"Kirish","ru":"Kirish","en":"Kirish"},
 "translation_status":{"uz":"source","ru":"pending","en":"pending"},
 "questions":[{"id":"toks-01-x-q01",
  "question_i18n":{"uz":"Birinchi savol matni?","ru":"Birinchi savol matni?","en":"Birinchi savol matni?"},
  "options_i18n":{"uz":["a","b","c","d"],"ru":["a","b","c","d"],"en":["a","b","c","d"]},
  "correct_index":0,
  "explanation_i18n":{"uz":"Izoh","ru":"Izoh","en":"Izoh"},
  "source":{"author":"A","title":"T","page":"5"},
  "translation_status":{"uz":"source","ru":"pending","en":"pending"}}]}]}
''');
      expect(bank.topics.single.isTranslationPending('ru'), isTrue);
      expect(bank.topics.single.isTranslationPending('uz'), isFalse);
      expect(bank.topics.single.isMachineTranslation('ru'), isFalse);
      expect(
        bank.question('toks-01-x-q01~ru')!.source.isTranslationPending,
        isTrue,
      );
      expect(
        bank.question('toks-01-x-q01')!.source.isTranslationPending,
        isFalse,
      );
      expect(bank.question('toks-01-x-q01')!.source.translation, isEmpty);
    });
  });

  group('savol soni chiplari', () {
    Future<void> openCreate(
      WidgetTester tester,
      World w, {
      Size size = const Size(390, 844),
    }) async {
      await openAt(
        tester,
        svc: w.teacher,
        location: Routes.classNewFor('lesson-a'),
        size: size,
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('class.questionCount')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
    }

    testWidgets('30 ta savol: 10/15/20 + Boshqa, standart 10', (tester) async {
      final w = World(topics: [lessonTopic('lesson-a', 30)]);
      await openCreate(tester, w);
      final l = l10n(tester);
      for (final n in [10, 15, 20]) {
        expect(find.byKey(Key('class.count.$n')), findsOneWidget);
      }
      expect(find.byKey(const Key('class.count.custom')), findsOneWidget);
      expect(find.text(l.classQuestionCountOther), findsOneWidget);
      expect(find.byKey(const Key('class.countLimited')), findsNothing);
      ChoiceChip chip(String k) =>
          tester.widget<ChoiceChip>(find.byKey(Key(k)));
      expect(chip('class.count.10').selected, isTrue);
      expect(chip('class.count.15').selected, isFalse);
      expect(
        tester
            .widget<Text>(find.byKey(const Key('class.questionCountValue')))
            .data,
        '10',
      );

      await tester.tap(find.byKey(const Key('class.count.15')));
      await tester.pump();
      expect(chip('class.count.15').selected, isTrue);
      expect(chip('class.count.10').selected, isFalse);

      // «Boshqa» — slayder 5..20 ichida.
      await tester.tap(find.byKey(const Key('class.count.custom')));
      await tester.pump();
      expect(find.byKey(const Key('class.sliderQuestions')), findsOneWidget);
      final slider = tester.widget<Slider>(
        find.byKey(const Key('class.sliderQuestions')),
      );
      expect((slider.min, slider.max), (5.0, 20.0));
      await closeApp(tester);
    });

    testWidgets('11 ta savol: 15/20 o‘chiq, «Hammasi · 11» taklif qilinadi', (
      tester,
    ) async {
      final w = World(topics: [lessonTopic('lesson-a', 11)]);
      await openCreate(tester, w);
      final l = l10n(tester);
      ChoiceChip chip(String k) =>
          tester.widget<ChoiceChip>(find.byKey(Key(k)));
      expect(chip('class.count.10').onSelected, isNotNull);
      expect(chip('class.count.15').onSelected, isNull);
      expect(chip('class.count.20').onSelected, isNull);
      expect(find.text(l.classQuestionCountAll(11)), findsOneWidget);
      expect(find.text(l.classQuestionCountLimited(11)), findsOneWidget);
      expect(chip('class.count.10').selected, isTrue);

      await tester.tap(find.byKey(const Key('class.count.all')));
      await tester.pump();
      expect(
        tester
            .widget<Text>(find.byKey(const Key('class.questionCountValue')))
            .data,
        '11',
      );
      // Sessiya shu son bilan yaratiladi.
      await tester.ensureVisible(find.byKey(const Key('class.createSubmit')));
      await tester.tap(find.byKey(const Key('class.createSubmit')));
      await frames(tester);
      final mine = (await w.teacher.mySessions()).value!;
      expect(mine.single.total, 11);
      await closeApp(tester);
    });

    testWidgets('7 ta savol: standart — barchasi (7), 10/15/20 o‘chiq', (
      tester,
    ) async {
      final w = World(topics: [lessonTopic('lesson-a', 7)]);
      await openCreate(tester, w, size: const Size(320, 568));
      final l = l10n(tester);
      ChoiceChip chip(String k) =>
          tester.widget<ChoiceChip>(find.byKey(Key(k)));
      expect(chip('class.count.10').onSelected, isNull);
      expect(find.text(l.classQuestionCountAll(7)), findsOneWidget);
      expect(chip('class.count.all').selected, isTrue);
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('boshqa mavzuga o‘tilganda «Boshqa» rejimi tiklanadi', (
      tester,
    ) async {
      final w = World(
        topics: [lessonTopic('lesson-a', 30), lessonTopic('lesson-b', 8)],
      );
      await openCreate(tester, w);
      await tester.tap(find.byKey(const Key('class.count.custom')));
      await tester.pump();
      expect(find.byKey(const Key('class.sliderQuestions')), findsOneWidget);
      await closeApp(tester);
    });
  });

  group('talaba laqabi', () {
    Future<void> openJoin(
      WidgetTester tester, {
      required bool signedIn,
      LocalUserProfile profile = const LocalUserProfile(),
    }) async {
      final w = World();
      await openAt(
        tester,
        svc: FakeClassQuizService(w.backend, userId: 'stu', demo: false),
        location: Routes.classJoin,
        extra: [
          authStateProvider.overrideWith(
            () => TestAuth(signedIn ? signedInAs('stu') : AuthState.signedOut),
          ),
          initialProfileProvider.overrideWithValue(profile),
        ],
      );
    }

    String nickText(WidgetTester tester) => tester
        .widget<TextField>(find.byKey(const Key('class.nickField')))
        .controller!
        .text;

    const stu = StudentProfile(fullName: 'Dilnoza Karimova', country: 'UZ');

    testWidgets('kirgan: profil ismi avtomatik, o‘zgartirsa bo‘ladi', (
      tester,
    ) async {
      await openJoin(
        tester,
        signedIn: true,
        profile: const LocalUserProfile(student: stu),
      );
      expect(nickText(tester), 'Dilnoza Karimova');
      await tester.enterText(find.byKey(const Key('class.nickField')), 'Dilya');
      await tester.pump();
      expect(nickText(tester), 'Dilya');
      await closeApp(tester);
    });

    testWidgets('kirgan, lekin profil ismi yo‘q: bo‘sh', (tester) async {
      await openJoin(tester, signedIn: true);
      expect(nickText(tester), '');
      await closeApp(tester);
    });

    testWidgets('kirmagan: profil bo‘lsa ham bo‘sh', (tester) async {
      await openJoin(
        tester,
        signedIn: false,
        profile: const LocalUserProfile(student: stu),
      );
      expect(nickText(tester), '');
      await closeApp(tester);
    });

    testWidgets('filtr saqlanadi: nomaqbul profil ismi qo‘yilmaydi', (
      tester,
    ) async {
      await openJoin(
        tester,
        signedIn: true,
        profile: const LocalUserProfile(
          student: StudentProfile(fullName: 'f.u.c.k', country: 'UZ'),
        ),
      );
      expect(nickText(tester), '');
      await closeApp(tester);
    });
  });

  group('qiyin savollar muhokamasi', () {
    Future<(World, ClassSessionInfo)> openFinished(
      WidgetTester tester, {
      Size size = const Size(390, 844),
      String lang = 'uz',
      List<ClassBankTopic>? topics,
    }) async {
      final w = World(topics: topics);
      final s = await w.finishedSession();
      await openAt(
        tester,
        svc: w.teacher,
        location: Routes.classHost(s.id),
        size: size,
        lang: lang,
      );
      return (w, s);
    }

    testWidgets('reyting: o‘rin raqami va to‘g‘ri soni', (tester) async {
      await openFinished(tester);
      final l = l10n(tester);
      expect(find.byKey(const Key('class.finalBoard')), findsOneWidget);
      // 1-o‘rin: eng ko‘p to‘g‘ri javob bergan Ali (2/5).
      final ranks = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('class.rank.'),
      );
      expect(ranks, findsNWidgets(4));
      expect(
        tester.widget<Text>(ranks.first).data,
        '1',
        reason: 'birinchi qator — 1-o‘rin',
      );
      expect(find.text(l.classLeaderCorrect(2, 5)), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('qiyin savol bosilsa muhokama sahifasi ochiladi', (
      tester,
    ) async {
      final (w, s) = await openFinished(tester);
      final l = l10n(tester);
      final d = (await w.teacher.dashboard(s.id)).value!;
      expect(d.hardest, isNotEmpty);
      final first = d.hardest.first; // 0% to‘g‘ri
      expect(first.correctPct, 0);
      expect(find.text(l.classHardestOpenHint), findsOneWidget);
      await reveal(tester, Key('class.hardest.${first.index}'));
      await tester.tap(find.byKey(Key('class.hardest.${first.index}')));
      await frames(tester);

      expect(find.byKey(const Key('class.discuss')), findsOneWidget);
      expect(find.text(l.classDiscussTitle), findsOneWidget);
      expect(find.byKey(const Key('class.discuss.question')), findsOneWidget);
      expect(find.text(first.text), findsOneWidget);
      // 4 variant, bittasi to‘g‘ri deb belgilangan.
      for (var i = 0; i < 4; i++) {
        expect(find.byKey(Key('class.discuss.option.$i')), findsOneWidget);
      }
      expect(find.text(l.classDiscussCorrectMark), findsOneWidget);
      // Xato foizi (0% to‘g‘ri = 100% xato), javoblar soni.
      expect(find.text(l.classDiscussWrongPct(100)), findsOneWidget);
      expect(find.text(l.classDiscussAnswered(4)), findsOneWidget);
      // Tushuntirish va manba (muallif, sarlavha, bet).
      expect(
        find.descendant(
          of: find.byKey(const Key('class.discuss.explanation')),
          matching: find.textContaining('Bo‘shliq gaz xromatografiyasi'),
        ),
        findsNothing,
        reason: 'matn Text.data da, descendant emas',
      );
      final expl = tester.widget<Text>(
        find.byKey(const Key('class.discuss.explanation')),
      );
      expect(expl.data, contains('Bo‘shliq gaz xromatografiyasi'));
      final src = tester.widget<Text>(
        find.byKey(const Key('class.discuss.source')),
      );
      expect(src.data, contains('Yuldashev A.'));
      expect(src.data, contains('Toksikologik kimyo'));
      expect(src.data, matches(RegExp(r'\d+-bet')));
      // Talaba ismlari ko‘rsatilmaydi.
      for (final n in _nicks) {
        expect(find.textContaining(n), findsNothing, reason: n);
      }
      await closeApp(tester);
    });

    testWidgets('keyingi / oldingi qiyin savolga o‘tish', (tester) async {
      final (w, s) = await openFinished(tester);
      final l = l10n(tester);
      final d = (await w.teacher.dashboard(s.id)).value!;
      expect(d.hardest.length, 3);
      await reveal(tester, Key('class.hardest.${d.hardest.first.index}'));
      await tester.tap(
        find.byKey(Key('class.hardest.${d.hardest.first.index}')),
      );
      await frames(tester);
      expect(
        tester
            .widget<Text>(find.byKey(const Key('class.discuss.position')))
            .data,
        l.classDiscussPosition(1, 3),
      );
      // Birinchida «Oldingi» o‘chiq.
      expect(
        tester
            .widget<OutlinedButton>(find.byKey(const Key('class.discuss.prev')))
            .onPressed,
        isNull,
      );
      await tester.tap(find.byKey(const Key('class.discuss.next')));
      await frames(tester, 3);
      expect(
        tester
            .widget<Text>(find.byKey(const Key('class.discuss.position')))
            .data,
        l.classDiscussPosition(2, 3),
      );
      expect(find.text(d.hardest[1].text), findsOneWidget);
      expect(
        find.text(l.classDiscussWrongPct(100 - d.hardest[1].correctPct)),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('class.discuss.next')));
      await frames(tester, 3);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('class.discuss.next')))
            .onPressed,
        isNull,
      );
      await tester.tap(find.byKey(const Key('class.discuss.prev')));
      await frames(tester, 3);
      expect(
        tester
            .widget<Text>(find.byKey(const Key('class.discuss.position')))
            .data,
        l.classDiscussPosition(2, 3),
      );
      // Yopish — natijalarga qaytadi.
      await tester.tap(find.byKey(const Key('class.discuss.close')));
      await frames(tester);
      expect(find.byKey(const Key('class.discuss')), findsNothing);
      expect(find.byKey(const Key('class.finalBoard')), findsOneWidget);
      await closeApp(tester);
    });

    testWidgets('proyektor (1920×1080): katta shrift, ismlarsiz, sig‘adi', (
      tester,
    ) async {
      final (w, s) = await openFinished(tester, size: const Size(1920, 1080));
      final d = (await w.teacher.dashboard(s.id)).value!;
      await tester.tap(
        find.byKey(Key('class.hardest.${d.hardest.first.index}')),
      );
      await frames(tester);
      final big = tester.widget<Text>(
        find.byKey(const Key('class.discuss.question')),
      );
      // Katta ekranda avtomatik yirik: headlineSmall (24) × 1.6.
      final base = Theme.of(
        tester.element(find.byKey(const Key('class.discuss'))),
      ).textTheme.headlineSmall!.fontSize!;
      expect(big.style!.fontSize!, greaterThan(base * 1.4));
      expect(find.byKey(const Key('class.discuss.big')), findsOneWidget);
      expect(tester.takeException(), isNull);
      // Kichik shriftga o‘tkazish mumkin.
      await tester.tap(find.byKey(const Key('class.discuss.big')));
      await tester.pump();
      final small = tester.widget<Text>(
        find.byKey(const Key('class.discuss.question')),
      );
      expect(small.style!.fontSize!, lessThan(big.style!.fontSize!));
      await closeApp(tester);
    });

    testWidgets('320×568: overflow yo‘q', (tester) async {
      final (w, s) = await openFinished(tester, size: const Size(320, 568));
      final d = (await w.teacher.dashboard(s.id)).value!;
      await reveal(tester, Key('class.hardest.${d.hardest.first.index}'));
      await tester.tap(
        find.byKey(Key('class.hardest.${d.hardest.first.index}')),
      );
      await frames(tester);
      expect(find.byKey(const Key('class.discuss.option.3')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('tafsilot kelmasa (eski server) — savol matni va xato %', (
      tester,
    ) async {
      final w = World();
      final s = await w.finishedSession();
      final svc = _NoDetail(w.backend);
      await openAt(tester, svc: svc, location: Routes.classHost(s.id));
      final d = (await w.teacher.dashboard(s.id)).value!;
      await reveal(tester, Key('class.hardest.${d.hardest.first.index}'));
      await tester.tap(
        find.byKey(Key('class.hardest.${d.hardest.first.index}')),
      );
      await frames(tester);
      final l = l10n(tester);
      expect(
        find.byKey(const Key('class.discuss.unavailable')),
        findsOneWidget,
      );
      expect(find.text(l.classDiscussUnavailable), findsOneWidget);
      expect(find.text(d.hardest.first.text), findsOneWidget);
      expect(find.byKey(const Key('class.discuss.option.0')), findsNothing);
      await closeApp(tester);
    });

    testWidgets('Fake server qoidasi: tugamagan sessiya tafsilot bermaydi', (
      tester,
    ) async {
      final w = World();
      final s = (await w.teacher.createSession(
        topicId: 'lesson-a',
        settings: const ClassQuizSettings(questionCount: 5, studentLimit: 5),
      )).value!;
      final r = await w.teacher.hardestDetail(s.id);
      expect(r.failure, ClassFailure.notFinished);
      final stranger = FakeClassQuizService(
        w.backend,
        userId: 'u9',
        demo: false,
      );
      expect(
        (await stranger.hardestDetail(s.id)).failure,
        ClassFailure.forbidden,
      );
    });

    testWidgets('tarjima kutilmoqda belgisi natijalarda (talaba)', (
      tester,
    ) async {
      final w = World(
        topics: [lessonTopic('lesson-a', 10, translation: 'pending')],
      );
      final s = await w.finishedSession();
      // Talaba ekrani: o‘z natijalari (xato javoblar manba bilan).
      final stu = w.students.first;
      await openAt(tester, svc: stu, location: Routes.classPlay(s.id));
      await frames(tester);
      final l = l10n(tester);
      expect(find.text(l.classTranslationPending), findsWidgets);
      await closeApp(tester);
    });
  });
}

class _NoDetail extends FakeClassQuizService {
  _NoDetail(super.backend) : super(userId: 't1', demo: false);

  @override
  Future<ClassResult<List<ClassHardDetail>>> hardestDetail(
    String sessionId, {
    int limit = 5,
  }) async => const ClassResult.fail(ClassFailure.notConfigured);
}
