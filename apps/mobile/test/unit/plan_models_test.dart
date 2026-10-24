import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/plan.dart';
import 'package:forensic_expert/domain/lessons/lesson_models.dart';
import 'package:forensic_expert/domain/plan/plan_models.dart';

Entitlements _ent(Plan? p, {DateTime? exp}) => Entitlements(
  plan: p,
  source: PlanSource.admin,
  expiresAt: exp ?? DateTime.now().add(const Duration(days: 5)),
);

LessonSummary _l(String id, [String course = 'Kurs']) => LessonSummary(
  topicId: id,
  deckId: '$id-deck',
  course: course,
  title: id,
  slides: 3,
);

void main() {
  group('Entitlements.allows', () {
    test('reja faqat o‘z rejasi funksiyalarini ochadi', () {
      for (final plan in Plan.values.where((p) => p != Plan.premium)) {
        final e = _ent(plan);
        for (final f in ProFeature.values) {
          expect(e.allows(f), f.requiredPlan == plan, reason: '$plan / $f');
        }
      }
    });

    test('Student Pro Ustoz va Mutaxassis funksiyalarini ochmaydi', () {
      final e = _ent(Plan.student);
      expect(e.allows(ProFeature.fullQuizBank), isTrue);
      expect(e.allows(ProFeature.allLessons), isFalse);
      expect(e.allows(ProFeature.proCalculators), isFalse);
    });

    test('muddati tugagan reja faol emas', () {
      final e = _ent(
        Plan.expert,
        exp: DateTime.now().subtract(const Duration(seconds: 1)),
      );
      expect(e.isActive, isFalse);
      expect(e.allows(ProFeature.caseNotebook), isFalse);
    });

    test('muddatsiz reja faol', () {
      const e = Entitlements(plan: Plan.teacher, source: PlanSource.admin);
      expect(e.isActive, isTrue);
      expect(e.allows(ProFeature.resultsCsv), isTrue);
    });

    test('reja yo‘q — hech narsa ochilmaydi', () {
      for (final f in ProFeature.values) {
        expect(Entitlements.none.allows(f), isFalse);
      }
    });

    test('fromJson: server javobi', () {
      final e = Entitlements.fromJson({
        'plan': 'teacher',
        'source': 'trial',
        'expires_at': '2999-01-01T00:00:00Z',
        'auto_renew': false,
        'trial_available': false,
        'product_id': null,
      });
      expect(e.plan, Plan.teacher);
      expect(e.isTrial, isTrue);
      expect(e.isActive, isTrue);
      final none = Entitlements.fromJson({
        'plan': null,
        'trial_available': true,
      });
      expect(none.plan, isNull);
      expect(none.trialAvailable, isTrue);
      expect(none.isActive, isFalse);
    });
  });

  test('mahsulot identifikatorlari shartnomaga mos', () {
    expect(
      PlanProducts.idFor(Plan.student, PlanPeriod.monthly),
      'fe_student_monthly',
    );
    expect(
      PlanProducts.idFor(Plan.expert, PlanPeriod.yearly),
      'fe_expert_yearly',
    );
    expect(PlanProducts.allIds.length, 8);
    expect(PlanProducts.planOf('fe_teacher_yearly'), Plan.teacher);
    expect(PlanProducts.periodOf('fe_teacher_yearly'), PlanPeriod.yearly);
    expect(PlanProducts.planOf('boshqa'), isNull);
  });

  test('professional kalkulyatorlar ro‘yxati; oddiylari bepul', () {
    expect(ProCalculators.isPro('tool.fm.pmi_henssge'), isTrue);
    expect(ProCalculators.isPro('tool.lab.lod_loq'), isTrue);
    expect(ProCalculators.isPro('tool.lab.dilution'), isFalse);
    expect(ProCalculators.isPro('tool.lab.percent'), isFalse);
  });

  group('computeLessonLocks', () {
    final all = [
      _l('instr-01-kristallyuks', 'Apparatlar bilan ishlash'),
      _l('instr-02-uv', 'Apparatlar bilan ishlash'),
      _l('toks-01'),
      _l('toks-02'),
      _l('toks-03'),
      _l('toks-04'),
    ];

    test('bepul: hamma dars qulfli (bepul dars yo‘q)', () {
      final locks = computeLessonLocks(all, Entitlements.none);
      expect(locks.keys.toSet(), {
        'instr-01-kristallyuks',
        'instr-02-uv',
        'toks-01',
        'toks-02',
        'toks-03',
        'toks-04',
      });
      expect(locks['instr-02-uv'], ProFeature.instrumentsCourseFull);
      expect(locks['toks-01'], ProFeature.allLessons);
    });

    test('Ustoz Pro darslarni ochadi, apparatlar kursini emas', () {
      final locks = computeLessonLocks(all, _ent(Plan.teacher));
      expect(locks.keys.toSet(), {'instr-01-kristallyuks', 'instr-02-uv'});
    });

    test('Mutaxassis Pro apparatlar kursini ochadi, ustoz darslarini emas', () {
      final locks = computeLessonLocks(all, _ent(Plan.expert));
      expect(locks.keys.toSet(), {'toks-01', 'toks-02', 'toks-03', 'toks-04'});
    });
  });

  group('Premium', () {
    test('hamma funksiyani ochadi; oddiy reja — faqat o‘zinikini', () {
      final prem = _ent(Plan.premium);
      for (final f in ProFeature.values) {
        expect(prem.allows(f), isTrue, reason: f.name);
      }
      final stu = _ent(Plan.student);
      expect(stu.allows(ProFeature.examMode), isTrue);
      expect(stu.allows(ProFeature.allLessons), isFalse);
    });

    test('mahsulot identifikatorlari: fe_premium_*', () {
      expect(
        PlanProducts.idFor(Plan.premium, PlanPeriod.monthly),
        'fe_premium_monthly',
      );
      expect(PlanProducts.planOf('fe_premium_yearly'), Plan.premium);
      expect(Plan.fromWire('premium'), Plan.premium);
    });

    test('dars qulflari: Premium hammasini ochadi', () {
      final all = [
        _l('instr-02-uv', 'Apparatlar bilan ishlash'),
        _l('toks-01'),
      ];
      expect(computeLessonLocks(all, _ent(Plan.premium)), isEmpty);
    });
  });
}
