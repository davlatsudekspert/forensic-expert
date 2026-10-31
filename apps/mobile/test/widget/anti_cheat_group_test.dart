import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/core/widgets/fe_components.dart';
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';
import 'package:forensic_expert/domain/class_groups/variant_draw.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/features/class_groups/presentation/test_screens.dart'
    show groupOrderForStudent;

import '../helpers/class_groups_world.dart';
import '../helpers/pump_app.dart' show testDefaultPlan;

void main() {
  setUp(() {
    floatingNavEnabled = true;
  });

  Future<({String gid, String aid})> setup(
    GroupsWorld w, {
    List<String> students = const ['stu1', 'stu2'],
  }) async {
    final g = w.backend.create('teacher', 'Guruh').value!;
    for (final (i, s) in students.indexed) {
      w.backend.join(s, code: g.code!, nickname: 'Talaba ${i + 1}');
    }
    final a = (await w.backend.createAssignment(
      'teacher',
      g.id,
      const AssignmentDraft(
        topicId: 'tox-co',
        questionCount: 4,
        timeLimitMin: 15,
        variantMode: true,
      ),
    )).value!;
    return (gid: g.id, aid: a.id);
  }

  /// Ekrandagi variant matnlari (A, B, C, D tartibida).
  List<String> shown(WidgetTester tester) => [
    for (var i = 0; i < 4; i++)
      (tester.widget<FeCard>(find.byKey(Key('grp.option.$i'))).semanticLabel ??
              '')
          .substring(3),
  ];

  /// Tanlangan (ajratilgan) variantning ekrandagi o‘rni.
  int? selectedPos(WidgetTester tester) {
    for (var i = 0; i < 4; i++) {
      if (tester.widget<FeCard>(find.byKey(Key('grp.option.$i'))).color !=
          null) {
        return i;
      }
    }
    return null;
  }

  testWidgets('variantlar har talabada boshqa tartibda, javob ASL indeksda, '
      'qayta ochilganda to‘g‘ri tiklanadi', (tester) async {
    final prev = testDefaultPlan;
    testDefaultPlan = Plan.student;
    addTearDown(() => testDefaultPlan = prev);
    final w = GroupsWorld();
    final s = await setup(w);

    final shownBy = <String, List<List<String>>>{};
    for (final uid in ['stu1', 'stu2']) {
      await w.open(tester, uid: uid, location: Routes.groupTest(s.gid, s.aid));
      final attempt = w.backend.open(uid, s.aid).value!;
      // Savollar tartibi talabaga xos; ekrandagi birinchi savol:
      final q = groupOrderForStudent(attempt, uid)!.questions.first;
      final order = optionDisplayOrder(
        assignmentId: s.aid,
        userId: uid,
        questionId: q.id,
        count: 4,
      );
      // Ekran aynan shu tartibda.
      final base = q.options; // serverdagi ASL tartib
      expect(shown(tester), [for (final o in order) base[o]]);
      // Harflar ekrandagi tartib bo‘yicha: A = birinchi ko‘rsatilgan matn.
      shownBy[uid] = [shown(tester)];
      // ASL 2-variantni ekranda matni bo‘yicha topib bosamiz → serverga ASL 2.
      final pos = shown(tester).indexOf(base[2]);
      expect(pos, order.indexOf(2));
      await tester.tap(find.byKey(Key('grp.option.$pos')));
      await frames(tester);
      expect(selectedPos(tester), pos);
      await tester.tap(find.byKey(const Key('grp.confirm')));
      await frames(tester);
      expect(w.backend.open(uid, s.aid).value!.answers[q.id], 2);
      expect(selectedPos(tester), pos);
      // Ilovani qayta ochamiz: tartib o‘zgarmaydi, tasdiqlangan javob
      // shu matnda ajratilgan.
      await closeApp(tester);
      await w.open(tester, uid: uid, location: Routes.groupTest(s.gid, s.aid));
      // Ochilganda birinchi javobsiz savol (2-savol) chiqadi; 1-savolga qaytamiz.
      await tester.tap(find.byKey(const Key('grp.prev')));
      await frames(tester);
      expect(shown(tester), shownBy[uid]!.single);
      final restored = selectedPos(tester);
      expect(restored, isNotNull);
      expect(shown(tester)[restored!], base[2]);
      await closeApp(tester);
    }
  });

  testWidgets(
    'ikki talabaning ekrani farq qiladi (bir xil savollar to‘plami)',
    (tester) async {
      final prev = testDefaultPlan;
      testDefaultPlan = Plan.student;
      addTearDown(() => testDefaultPlan = prev);
      final w = GroupsWorld();
      final g = w.backend.create('teacher', 'Guruh').value!;
      for (final (i, s) in ['stu1', 'stu2'].indexed) {
        w.backend.join(s, code: g.code!, nickname: 'Talaba ${i + 1}');
      }
      // Variantsiz: ikkala talabaga AYNAN bir xil savollar.
      final a = (await w.backend.createAssignment(
        'teacher',
        g.id,
        const AssignmentDraft(
          topicId: 'tox-co',
          questionCount: 4,
          timeLimitMin: 15,
          variantMode: false,
        ),
      )).value!;
      // savol id → ekrandagi tartib (ASL indekslar, masalan 2|0|3|1)
      final perms = <String, Map<String, String>>{};
      for (final uid in ['stu1', 'stu2']) {
        await w.open(tester, uid: uid, location: Routes.groupTest(g.id, a.id));
        final byText = {
          for (final q in w.backend.open(uid, a.id).value!.questions) q.text: q,
        };
        for (var i = 0; i < 4; i++) {
          final q =
              byText[tester
                  .widget<Text>(find.byKey(const Key('grp.questionText')))
                  .data]!;
          final sh = shown(tester);
          expect([...sh]..sort(), [...q.options]..sort());
          (perms[uid] ??= {})[q.id] = [for (final t in sh) q.options.indexOf(t)]
              .join('|');
          await tester.tap(find.byKey(const Key('grp.option.0')));
          await frames(tester);
          await tester.tap(find.byKey(const Key('grp.confirm')));
          await frames(tester);
          if (i < 3) {
            await tester.tap(find.byKey(const Key('grp.next')));
            await frames(tester);
          }
        }
        await closeApp(tester);
      }
      expect(perms['stu1']!.keys.toSet(), perms['stu2']!.keys.toSet());
      final differing = [
        for (final id in perms['stu1']!.keys)
          if (perms['stu1']![id] != perms['stu2']![id]) id,
      ];
      expect(differing, isNotEmpty);
    },
  );
}
