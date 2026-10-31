// Bepul / Pro bo‘linishi (egasi qarori, 2026-10-31): darvoza matritsasi.
// Bo‘linish `kProStrict` bilan yoqiladi (standart — o‘chiq).
import 'package:fe_content_schema/fe_content_schema.dart' show KnowledgeArea;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/plan.dart';
import 'package:forensic_expert/app/support.dart' show isAdminProvider;
import 'package:forensic_expert/domain/knowledge/knowledge_models.dart';
import 'package:forensic_expert/domain/lessons/lesson_models.dart';
import 'package:forensic_expert/domain/library/library_models.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';
import 'package:forensic_expert/domain/plan/pro_split.dart';

import '../helpers/plan_fakes.dart';

const _strictFeatures = [
  ProFeature.proModules,
  ProFeature.proTools,
  ProFeature.proAi,
  ProFeature.listen,
  ProFeature.groupTestReview,
  ProFeature.teacherPanel,
];

Future<ProviderContainer> _c({
  required bool strict,
  Plan? plan,
  bool admin = false,
}) async {
  final c = ProviderContainer(
    overrides: [
      proStrictProvider.overrideWithValue(strict),
      isAdminProvider.overrideWithValue(admin),
      ...planOverrides(plan),
    ],
  );
  addTearDown(c.dispose);
  await c.read(entitlementsProvider.future);
  return c;
}

/// Gate natijasi: bo‘linish o‘chiq bo‘lsa [ProFeature.strictOnly] ochiq.
bool _open(ProviderContainer c, ProFeature f) =>
    (f.strictOnly && !c.read(proStrictProvider)) ||
    c.read(proAllowedProvider(f));

LessonSummary _lesson(String id, String course) => LessonSummary(
  topicId: id,
  deckId: '$id-deck',
  course: course,
  title: id,
  slides: 3,
);

void main() {
  test('kProStrict standarti — o‘chiq (masofadan yoqilmaydi)', () {
    expect(kProStrict, isFalse);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(proStrictProvider), isFalse);
  });

  group('bayroq o‘chiq: hammasi avvalgidek ochiq', () {
    test('bepul foydalanuvchi: yangi (strictOnly) funksiyalar ochiq', () async {
      final c = await _c(strict: false);
      for (final f in _strictFeatures) {
        expect(f.strictOnly, isTrue);
        expect(_open(c, f), isTrue, reason: f.name);
      }
    });

    test('mavjud funksiyalar o‘zgarmagan: bepulga yopiq', () async {
      final c = await _c(strict: false);
      for (final f in ProFeature.values.where((f) => !f.strictOnly)) {
        expect(_open(c, f), isFalse, reason: f.name);
      }
    });

    test('dars qulflari o‘zgarmagan (bepul dars yo‘q)', () {
      final all = [_lesson('fm-1', 'Davolash ishi fakulteti')];
      expect(computeLessonLocks(all, Entitlements.none), {
        'fm-1': ProFeature.allLessons,
      });
    });
  });

  group('bayroq yoqilgan', () {
    test('bepul foydalanuvchi: Pro ro‘yxati yopiq', () async {
      final c = await _c(strict: true);
      for (final f in _strictFeatures) {
        expect(_open(c, f), isFalse, reason: f.name);
      }
    });

    test('har qanday pullik reja bo‘lim o‘qishini ochadi', () async {
      for (final plan in [Plan.student, Plan.teacher, Plan.expert]) {
        final c = await _c(strict: true, plan: plan);
        for (final f in [
          ProFeature.proModules,
          ProFeature.proTools,
          ProFeature.proAi,
          ProFeature.listen,
          ProFeature.groupTestReview,
        ]) {
          expect(_open(c, f), isTrue, reason: '$plan / ${f.name}');
        }
      }
    });

    test('Ustoz paneli — faqat Ustoz Pro / Premium / admin', () async {
      expect(
        _open(
          await _c(strict: true, plan: Plan.student),
          ProFeature.teacherPanel,
        ),
        isFalse,
      );
      expect(
        _open(
          await _c(strict: true, plan: Plan.teacher),
          ProFeature.teacherPanel,
        ),
        isTrue,
      );
      expect(
        _open(
          await _c(strict: true, plan: Plan.premium),
          ProFeature.teacherPanel,
        ),
        isTrue,
      );
      expect(
        _open(await _c(strict: true, admin: true), ProFeature.teacherPanel),
        isTrue,
      );
    });

    test('Premium va admin: hammasi ochiq', () async {
      for (final c in [
        await _c(strict: true, plan: Plan.premium),
        await _c(strict: true, admin: true),
      ]) {
        for (final f in ProFeature.values) {
          expect(_open(c, f), isTrue, reason: f.name);
        }
      }
    });

    test('muddati tugagan reja — yana yopiq', () {
      final e = Entitlements(
        plan: Plan.student,
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(e.unlocks(ProFeature.proModules), isFalse);
    });

    test('dars qulflari: Sud tibbiyoti/Toksikologiya o‘qish bepul', () {
      final all = [
        _lesson('fm-1', 'Davolash ishi fakulteti'),
        _lesson('toks-1', 'Toksikologik kimyo'),
        _lesson('instr-1', 'Apparatlar bilan ishlash'),
      ];
      final locks = computeLessonLocks(all, Entitlements.none, strict: true);
      expect(locks.containsKey('fm-1'), isFalse);
      expect(locks.containsKey('toks-1'), isFalse);
      expect(locks['instr-1'], ProFeature.instrumentsCourseFull);
    });
  });

  group('bo‘lim matritsasi', () {
    test(
      'bepul: Sud tibbiyoti, Toksikologiya, Biokimyo, Laboratoriya, Learn',
      () {
        for (final m in [
          'forensicMedicine',
          'toxicology',
          'biochemistry',
          'laboratory',
          'learn',
        ]) {
          expect(ProSplit.featureForModule(m), isNull, reason: m);
        }
      },
    );

    test('Pro: qolgan bo‘limlar; AI — proAi', () {
      for (final m in [
        'reagents',
        'screening',
        'methods',
        'substances',
        'standardsLaws',
        'emerging',
        'histology',
        'research',
      ]) {
        expect(ProSplit.featureForModule(m), ProFeature.proModules, reason: m);
      }
      expect(ProSplit.featureForModule('ai'), ProFeature.proAi);
    });

    test('bilim yozuvi: faqat bepul sohaning mavzusi bepul', () {
      for (final a in [
        KnowledgeArea.forensicMedicine,
        KnowledgeArea.toxicology,
        KnowledgeArea.biochemistry,
        KnowledgeArea.laboratory,
      ]) {
        expect(ProSplit.isFreeKnowledge(KnowledgeKind.topic, a), isTrue);
        // Reagent/skrining/metod — soha qanday bo‘lmasin Pro.
        for (final k in [
          KnowledgeKind.reagent,
          KnowledgeKind.screeningTest,
          KnowledgeKind.method,
          KnowledgeKind.emergingIssue,
        ]) {
          expect(ProSplit.isFreeKnowledge(k, a), isFalse, reason: '$k/$a');
        }
      }
      expect(
        ProSplit.isFreeKnowledge(KnowledgeKind.topic, KnowledgeArea.histology),
        isFalse,
      );
    });

    test(
      'kutubxona: moddalar va usullar Pro; namunalar/manbalar/lug‘at bepul',
      () {
        expect(
          ProSplit.isFreeLibrarySection(LibrarySection.substances),
          isFalse,
        );
        expect(ProSplit.isFreeLibrarySection(LibrarySection.methods), isFalse);
        expect(ProSplit.isFreeLibrarySection(LibrarySection.specimens), isTrue);
        expect(
          ProSplit.isFreeLibrarySection(LibrarySection.references),
          isTrue,
        );
        expect(ProSplit.isFreeLibrarySection(LibrarySection.glossary), isTrue);
      },
    );

    test('har bir yangi funksiya uchun reja va foyda matni aniqlangan', () {
      for (final f in _strictFeatures) {
        expect(f.requiredPlan, isNotNull);
      }
      expect(ProFeature.teacherPanel.requiredPlan, Plan.teacher);
      expect(ProFeature.teacherPanel.anyPlan, isFalse);
    });
  });
}
