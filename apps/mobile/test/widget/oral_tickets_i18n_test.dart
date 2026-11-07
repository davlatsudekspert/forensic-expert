// Og‘zaki bilet savollari ilova tilida (ru/en): rasmiy malaka bileti,
// ustoz mavzu bileti va guruh og‘zaki imtihoni (QR) — talaba o‘z tilida.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/assessment.dart';
import 'package:forensic_expert/app/class_quiz.dart';
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
import 'package:forensic_expert/features/oral_group/presentation/oral_group_student_screens.dart';

import '../helpers/pump_app.dart';

final _pack = File('assets/content/assessment/assessment_v1.json')
    .readAsStringSync();
final _oral = {
  for (final id in ['sud_tib', 'pat_anat', 'sud_kimyo'])
    id: File('assets/content/assessment/oral_$id.json').readAsStringSync(),
};

Map<String, Object?> _deck(String id, List<String> titles) => {
  'ok': true,
  'topic_id': id,
  'title': id == 'a1' ? 'Mavzu a1' : 'Тема $id',
  'course': '4-kurs · Davolash',
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

const _uzTitles = [
  'Kirish: mashg‘ulot maqsadi va rejasi',
  'Tan jarohatlarining yuridik tasnifi',
  'Hayot uchun xavf mezoni',
  'Sog‘liqning buzilish davomiyligi',
  'Sun’iy kasalliklar',
  'Sun’iy kasalliklar (davomi)',
  'Mehnat qobiliyatini yo‘qotish',
  'Xulosa',
];
const _ruTitles = [
  'Введение: цель и план занятия',
  'Юридическая классификация телесных повреждений',
  'Критерий опасности для жизни',
  'Длительность расстройства здоровья',
  'Искусственные болезни',
  'Искусственные болезни (продолжение)',
  'Утрата трудоспособности',
  'Заключение',
];

final _uzDecks = {'a1': _deck('a1', _uzTitles)};
final _ruDecks = {
  'ru': {'a1': _deck('a1', _ruTitles)},
};

Finder _key(String k) => find.byKey(Key(k));

Future<void> _tap(WidgetTester tester, Finder f) async {
  await Scrollable.ensureVisible(tester.element(f), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

String _qText(WidgetTester tester, int i) {
  final card = _key('oral.q.$i');
  final texts = tester
      .widgetList<Text>(find.descendant(of: card, matching: find.byType(Text)))
      .map((t) => t.data ?? '')
      .toList();
  // 0 — «Savol N», 1 — savol matni.
  return texts[1];
}

final _cyr = RegExp('[а-яА-Я]');

void main() {
  group('rasmiy malaka bileti', () {
    setUpAll(() => testDefaultPlan = Plan.expert);
    tearDownAll(() => testDefaultPlan = null);

    for (final lang in ['ru', 'en']) {
      testWidgets('$lang: bilet savollari $lang tilida, manba belgisi bilan', (
        tester,
      ) async {
        final c = await pumpApp(
          tester,
          settings: completedSettings(lang: lang),
          overrides: <Override>[
            assessmentLoaderProvider.overrideWithValue(() async => _pack),
            oralLoaderProvider.overrideWithValue((id) async => _oral[id]!),
            oralExamRandomProvider.overrideWithValue(math.Random(42)),
          ],
          initialLocation: Routes.assessmentExam('pat_anat', 'c0'),
        );
        await tester.pump();
        await tester.pump();
        await _tap(tester, _key('oral.draw'));
        final ids = c.read(oralExamProvider).questionIds;
        expect(ids, hasLength(5));
        final raw = jsonDecode(_pack) as Map<String, Object?>;
        final byId = <String, Map<String, Object?>>{
          for (final s
              in (raw['specialties']! as List).cast<Map<String, Object?>>())
            for (final cat
                in (s['categories']! as List).cast<Map<String, Object?>>())
              for (final q
                  in (cat['questions']! as List).cast<Map<String, Object?>>())
                q['id']! as String: q.cast<String, Object?>(),
        };
        for (var i = 0; i < 5; i++) {
          final q = byId[ids[i]]!;
          expect(_qText(tester, i), q['text_$lang'], reason: ids[i]);
          expect(_qText(tester, i), isNot(q['text']));
          expect(_cyr.hasMatch(_qText(tester, i)), lang == 'ru');
          expect(_key('oral.q.$i.source'), findsOne);
        }
      });
    }

    testWidgets('uz: asl matn, manba belgisi yo‘q', (tester) async {
      final c = await pumpApp(
        tester,
        settings: completedSettings(lang: 'uz'),
        overrides: <Override>[
          assessmentLoaderProvider.overrideWithValue(() async => _pack),
          oralLoaderProvider.overrideWithValue((id) async => _oral[id]!),
          oralExamRandomProvider.overrideWithValue(math.Random(42)),
        ],
        initialLocation: Routes.assessmentExam('pat_anat', 'c0'),
      );
      await tester.pump();
      await tester.pump();
      await _tap(tester, _key('oral.draw'));
      final id = c.read(oralExamProvider).questionIds.first;
      final cat =
          ((jsonDecode(_pack) as Map<String, Object?>)['specialties'] as List)
                  .cast<Map<String, Object?>>()
                  .firstWhere((x) => x['id'] == 'pat_anat')['categories']
              as List;
      final q = (cat[2] as Map<String, Object?>)['questions'] as List;
      final text = (q.cast<Map<String, Object?>>().firstWhere(
        (x) => x['id'] == id,
      ))['text'];
      expect(_qText(tester, 0), text);
      expect(_key('oral.q.0.source'), findsNothing);
    });
  });

  group('ustoz mavzu bileti (dars slaydlaridan)', () {
    setUpAll(() => testDefaultPlan = Plan.expert);
    tearDownAll(() => testDefaultPlan = null);

    testWidgets(
      'ru: savollar ruscha deck’dan, id’lar o‘zbekcha bilan bir xil',
      (tester) async {
        final c = await pumpApp(
          tester,
          settings: completedSettings(lang: 'ru', mode: UserMode.teacher),
          overrides: <Override>[
            classQuizServiceProvider.overrideWithValue(
              FakeClassQuizService(
                FakeClassQuizBackend(teachers: {'t1'}),
                userId: 't1',
                demo: false,
              ),
            ),
            lessonsServiceProvider.overrideWithValue(
              FakeLessonsService(
                demo: false,
                decks: _uzDecks,
                localizedDecks: _ruDecks,
              ),
            ),
            teacherOralRandomProvider.overrideWithValue(math.Random(7)),
          ],
          initialLocation: Routes.teacherOral,
        );
        await tester.pumpAndSettle();
        await _tap(tester, _key('toral.topic.a1'));
        await _tap(tester, _key('toral.build'));
        // Xizmat slaydlari (Введение/Заключение) savol emas: 5 ta savol.
        final pool = c.read(teacherOralPoolProvider('a1')).value!;
        expect(pool.questions.keys, ['a1#1', 'a1#2', 'a1#3', 'a1#4', 'a1#6']);
        await _tap(tester, _key('oral.draw'));
        final ids = c.read(teacherOralProvider).questionIds;
        expect(ids, hasLength(5));
        for (var i = 0; i < 5; i++) {
          final slide = int.parse(ids[i].split('#').last);
          expect(
            _qText(tester, i),
            _ruTitles[slide].replaceAll(' (продолжение)', ''),
          );
        }
        expect(find.text('Sun’iy kasalliklar'), findsNothing);
        // Javob kaliti ham ruscha slayd bandlaridan.
        await _tap(tester, _key('oral.key.0'));
        expect(find.textContaining(_cyr), findsWidgets);
      },
    );
  });

  group('guruh og‘zaki imtihoni (QR)', () {
    setUpAll(() => testDefaultPlan = Plan.teacher);
    tearDownAll(() => testDefaultPlan = null);

    testWidgets(
      'ustoz o‘zbekcha bilet tuzgan; ruscha talaba savollarni ruscha ko‘radi',
      (tester) async {
        final backend = FakeOralGroupBackend(
          clock: () => DateTime.utc(2026, 11, 3, 10),
          rng: math.Random(5),
          teachers: {'t1'},
        );
        final teacher = FakeOralGroupService(
          backend,
          userId: 't1',
          demo: false,
        );
        // Serverda: [{id, text}] — matn ustoz tilida (o‘zbekcha); bitta
        // savol darsda yo‘q (eski/yopiq) — serverdagi matn qoladi.
        final s = (await teacher.createSession(
          title: 'Mavzu a1',
          tickets: [
            [
              for (final i in [1, 2, 3, 6])
                OralGroupQuestion(id: 'a1#$i', text: _uzTitles[i]),
              const OralGroupQuestion(id: 'zz#9', text: 'Eski savol'),
            ],
          ],
          prepSeconds: 0,
        )).value!;
        final c = await pumpApp(
          tester,
          settings: completedSettings(lang: 'ru', mode: UserMode.student),
          overrides: <Override>[
            classQuizServiceProvider.overrideWithValue(
              FakeClassQuizService(
                FakeClassQuizBackend(),
                userId: 's1',
                demo: false,
              ),
            ),
            lessonsServiceProvider.overrideWithValue(
              FakeLessonsService(
                isTeacher: false,
                demo: false,
                decks: _uzDecks,
                localizedDecks: _ruDecks,
              ),
            ),
            oralGroupServiceProvider.overrideWithValue(
              FakeOralGroupService(backend, userId: 's1', demo: false),
            ),
            oralGroupPollIntervalProvider.overrideWithValue(
              const Duration(milliseconds: 150),
            ),
            oralGroupClockProvider.overrideWithValue(
              () => DateTime.utc(2026, 11, 3, 10),
            ),
          ],
        );
        c.read(routerProvider).go('/join/${s.code}?t=oral');
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 150));
        }
        await tester.enterText(_key('oralgroup.joinName'), 'Иван Петров');
        await tester.ensureVisible(_key('oralgroup.joinSubmit'));
        await tester.tap(_key('oralgroup.joinSubmit'));
        for (var i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 150));
        }
        expect(find.byType(OralGroupPlayScreen), findsOne);
        String q(int i) =>
            tester.widget<Text>(_key('oralgroup.qtext.$i')).data ?? '';
        expect(q(0), 'Юридическая классификация телесных повреждений');
        expect(q(1), 'Критерий опасности для жизни');
        expect(q(2), 'Длительность расстройства здоровья');
        expect(q(3), 'Утрата трудоспособности');
        expect(q(4), 'Eski savol');
        expect(find.text('Tan jarohatlarining yuridik tasnifi'), findsNothing);
        // Javob kaliti (slayd bandlari) talabaga ko‘rinmaydi.
        expect(find.textContaining('asosiy fikr'), findsNothing);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
        expect(c, isA<ProviderContainer>());
      },
    );
  });
}
