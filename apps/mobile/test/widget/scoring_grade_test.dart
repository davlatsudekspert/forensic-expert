import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart';
import 'package:forensic_expert/app/routes.dart';
import 'package:forensic_expert/core/floating_nav_flag.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';
import 'package:forensic_expert/domain/grading/grade_scale.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/features/class_groups/presentation/midterm_preset.dart';

import '../helpers/class_groups_world.dart';
import '../helpers/pump_app.dart' show testDefaultPlan;

class _FakeShare implements ClassFileShare {
  final shared = <({String name, String content})>[];

  @override
  Future<void> shareCsv({
    required String fileName,
    required String content,
    String? subject,
  }) async => shared.add((name: fileName, content: content));
}

AppLocalizations _l(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).first));

/// Test mavzusidagi to‘g‘ri variant matni (variantlar savol bo‘yicha aralashadi,
/// shuning uchun to‘g‘ri javob matn bo‘yicha topiladi).
const _correctText = '50% va undan yuqori';

/// Talaba [right] ta savolga to‘g‘ri, qolganiga noto‘g‘ri javob berib topshiradi.
void _solve(GroupsWorld w, String uid, String aid, {required int right}) {
  final qs = w.backend.open(uid, aid).value!.questions;
  final answers = <String, int>{};
  for (final (i, q) in qs.indexed) {
    final good = q.options.indexOf(_correctText);
    answers[q.id] = i < right ? good : (good + 1) % q.options.length;
  }
  final r = w.backend.submit(uid, aid, answers).value!;
  expect(r.score, right, reason: 'test yordamchisi to‘g‘ri hisoblashi kerak');
}

Future<({String gid, String aid})> _setup(GroupsWorld w) async {
  final g = w.backend.create('teacher', '4-kurs, 2-guruh').value!;
  for (final (i, s) in ['s100', 's75', 's50', 'slow'].indexed) {
    w.backend.join(s, code: g.code!, nickname: 'Talaba ${i + 1}');
  }
  final a = (await w.backend.createAssignment(
    'teacher',
    g.id,
    const AssignmentDraft(
      topicId: 'tox-co',
      questionCount: 4,
      timeLimitMin: 15,
    ),
  )).value!;
  return (gid: g.id, aid: a.id);
}

void main() {
  setUpAll(() => testDefaultPlan = Plan.teacher);
  tearDownAll(() => testDefaultPlan = null);
  setUp(() {
    floatingNavEnabled = true;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  group('talaba natija ekrani (Guruhga test berish)', () {
    for (final c in [
      (uid: 's100', right: 4, score: '100.0', grade: '5'),
      (uid: 's75', right: 3, score: '75.0', grade: '3'),
      (uid: 's50', right: 2, score: '50.0', grade: null),
    ]) {
      testWidgets('${c.right}/4 → ${c.score}', (tester) async {
        final w = GroupsWorld();
        final s = await _setup(w);
        _solve(w, c.uid, s.aid, right: c.right);
        await w.open(
          tester,
          uid: c.uid,
          location: Routes.groupResult(s.gid, s.aid),
        );
        final l = _l(tester);
        expect(find.byKey(const Key('grp.score')), findsOneWidget);
        expect(
          tester.widget<Text>(find.byKey(const Key('score100.value'))).data,
          c.score,
        );
        expect(
          tester.widget<Text>(find.byKey(const Key('score100.grade'))).data,
          c.grade ?? l.scoringGradeBelowMin,
        );
        expect(find.text(l.scoringScore100Label), findsOneWidget);
        expect(
          find.text(l.scoringGradeApproxTitle(GradeScale.academicYear)),
          findsOneWidget,
        );
        expect(
          find.text(l.scoringGradeApproxTitle('2026-2027')),
          findsOneWidget,
          reason: 'Taxminiy baho (2026-2027 tartibi bo‘yicha)',
        );
        // «Taxminiy» izohi ekranda bir marta.
        expect(find.byKey(const Key('score100.note')), findsOneWidget);
        expect(
          find.text('Minimal o‘tish balidan past'),
          c.grade == null ? findsOneWidget : findsNothing,
        );
        // Taqiqlangan so‘zlar yo‘q.
        for (final bad in ['qarzdor', 'yiqil', 'muvaffaqiyatsiz']) {
          expect(find.textContaining(bad), findsNothing);
        }
        expect(tester.takeException(), isNull);
        await closeApp(tester);
      });
    }

    testWidgets('320 dp, shrift 1.3x — taşmasiz', (tester) async {
      final w = GroupsWorld();
      final s = await _setup(w);
      _solve(w, 's50', s.aid, right: 2);
      await w.open(
        tester,
        uid: 's50',
        size: const Size(320, 640),
        textScale: 1.3,
        location: Routes.groupResult(s.gid, s.aid),
      );
      expect(find.byKey(const Key('score100.block')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });
  });

  testWidgets('ustoz natijalari: «Ball (100)» + «Baho» qatorlari va CSV', (
    tester,
  ) async {
    final w = GroupsWorld();
    final s = await _setup(w);
    _solve(w, 's100', s.aid, right: 4);
    _solve(w, 's75', s.aid, right: 3);
    _solve(w, 's50', s.aid, right: 2);
    final share = _FakeShare();
    await w.open(
      tester,
      uid: 'teacher',
      location: Routes.groupAssignment(s.gid, s.aid),
      extra: [classFileShareProvider.overrideWithValue(share)],
    );
    final l = _l(tester);
    expect(find.text(l.scoringRowLine('100.0', '5')), findsOneWidget);
    expect(find.text(l.scoringRowLine('75.0', '3')), findsOneWidget);
    expect(
      find.text(l.scoringRowLine('50.0', l.scoringGradeBelowMin)),
      findsOneWidget,
    );
    // Reyting (to‘g‘ri soni/vaqt) ham joyida; taxminiy baho izohi bir marta.
    expect(find.byKey(const Key('grp.score.s100')), findsNothing);
    expect(find.byKey(const Key('grp.scoreApproxNote')), findsOneWidget);
    expect(find.textContaining('qarzdor'), findsNothing);
    expect(tester.takeException(), isNull);

    final csvBtn = find.byKey(const Key('grp.exportCsv'));
    await tester.ensureVisible(csvBtn);
    await tester.pumpAndSettle();
    // Suzuvchi menyu ostida qolmaydi.
    expect(
      tester.getRect(csvBtn).bottom,
      lessThan(tester.getRect(find.byKey(const Key('nav.floating'))).top),
    );
    await tester.tap(csvBtn);
    await frames(tester);
    final f = share.shared.single;
    expect(
      f.name,
      matches(RegExp(r'^guruh_test_natija_\d{4}-\d{2}-\d{2}\.csv$')),
    );
    final lines = f.content.trim().split('\r\n');
    expect(
      lines.first,
      'laqab,holat,togri_soni,jami,Ball (100),Baho,sarflangan_vaqt_s',
    );
    expect(lines.where((x) => x.contains(',100.0,5,')), hasLength(1));
    expect(lines.where((x) => x.contains(',75.0,3,')), hasLength(1));
    expect(
      lines.where((x) => x.contains(',50.0,${l.scoringGradeBelowMin},')),
      hasLength(1),
    );
    expect(lines.where((x) => x.contains(',qoshildi,,,,,')), hasLength(1));
    await closeApp(tester);
  });

  group('Oraliq nazorat (bir bosishli andoza)', () {
    test('midtermSettings: standartlar va server chegaralari', () {
      final big = midtermSettings(300);
      expect(big.count, 30);
      expect(big.timeLimit, 40);
      expect(big.openDays, 1);
      expect(big.openUntil, isNull);
      expect(big.variant, isTrue);
      // Hovuz ≥ 2 × savollar bo‘lmasa — variant o‘chiq.
      expect(midtermSettings(59).variant, isFalse);
      expect(midtermSettings(60).variant, isTrue);
      // Hovuz 30 dan kichik — savollar soni hovuzgacha.
      expect(midtermSettings(12).count, 12);
      expect(midtermSettings(12).variant, isFalse);
      expect(midtermSettings(1).count, 1);
      // Server chegaralari (1–200 savol, 1–180 daqiqa) ichida.
      expect(big.count, inInclusiveRange(1, GroupRules.maxQuestions));
      expect(
        big.timeLimit,
        inInclusiveRange(GroupRules.minTimeLimit, GroupRules.maxTimeLimit),
      );
      expect(
        midtermTitle('Oraliq nazorat', ' Bioetika · 2-kurs '),
        'Oraliq nazorat: Bioetika · 2-kurs',
      );
      expect(midtermTitle('Oraliq nazorat', 'x' * 300).length, 120);
    });

    testWidgets('kurs → barcha mavzular, nom, 30/40/1 kun, variant yoqiq → '
        'yaratish', (tester) async {
      final w = GroupsWorld.real();
      final g = w.backend.create('teacher', '4-kurs, 2-guruh').value!;
      await w.open(tester, uid: 'teacher', location: Routes.groupMixed(g.id));
      final l = _l(tester);
      expect(find.byKey(const Key('grp.midtermCard')), findsOneWidget);
      expect(find.text(l.scoringMidtermTitle), findsWidgets);
      // Kurs ro‘yxati: savoli bor kurslar (bo‘sh va «boshqa» yo‘q).
      const course = 'sud-tibbiyoti-4-davolash';
      final btn = find.byKey(const Key('grp.midterm.$course'));
      expect(btn, findsOneWidget);
      await tester.tap(btn);
      await frames(tester);
      // Barcha mavzular tanlangan, nom — «Oraliq nazorat: <kurs>».
      final title = tester.widget<TextField>(
        find.byKey(const Key('grp.mixedTitle')),
      );
      expect(title.controller!.text, startsWith('${l.scoringMidtermTitle}: '));
      expect(find.byKey(const Key('grp.midtermApplied')), findsOneWidget);
      expect(find.byKey(const Key('grp.midtermVariantOn')), findsOneWidget);
      expect(find.byKey(const Key('grp.midtermVariantOff')), findsNothing);
      // Yaratish (tahrirlamasdan).
      final submit = find.byKey(const Key('grp.mixedSubmit'));
      await tester.scrollUntilVisible(
        submit,
        150,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('grp.mixedList')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await frames(tester);
      final a = w.backend.detail('teacher', g.id).value!.assignments.single;
      expect(a.questionCount, 30);
      expect(a.timeLimitMin, 40);
      expect(a.variantMode, isTrue);
      expect(a.topics.length, 10, reason: 'kursning barcha mavzulari');
      expect(a.topicTitle, startsWith('Oraliq nazorat: '));
      expect(a.dueAt, w.now.add(const Duration(days: 1)));
      expect(a.poolSize, 60, reason: 'variant: 2N');
      expect(tester.takeException(), isNull);
      await closeApp(tester);
    });

    testWidgets('hovuz < 2×savol: variant o‘chiq, ogohlantirish va taklif', (
      tester,
    ) async {
      final w = GroupsWorld.real();
      final g = w.backend.create('teacher', 'Guruh B').value!;
      await w.open(tester, uid: 'teacher', location: Routes.groupMixed(g.id));
      // Tibbiy profilaktika: 30 ta savol (30 < 2×30).
      const course = 'sud-tibbiyoti-5-tibbiy-profilaktika';
      final btn = find.byKey(const Key('grp.midterm.$course'));
      expect(btn, findsOneWidget);
      await tester.tap(btn);
      await frames(tester);
      expect(find.byKey(const Key('grp.midtermVariantOff')), findsOneWidget);
      expect(find.byKey(const Key('grp.midtermVariantOn')), findsNothing);
      final sw = find.byKey(const Key('grp.variantSwitch'));
      await tester.scrollUntilVisible(
        sw,
        150,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('grp.mixedList')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(tester.widget<SwitchListTile>(sw).value, isFalse);
      // Mavjud hovuz ogohlantirishi ham ko‘rinadi.
      expect(find.byKey(const Key('grp.variantNote')), findsOneWidget);
      final submit = find.byKey(const Key('grp.mixedSubmit'));
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await frames(tester);
      final a = w.backend.detail('teacher', g.id).value!.assignments.single;
      expect(a.questionCount, 30);
      expect(a.variantMode, isFalse);
      expect(a.timeLimitMin, 40);
      await closeApp(tester);
    });
  });
}
