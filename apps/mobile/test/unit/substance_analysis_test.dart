import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/evidence/substance_analysis.dart';
import 'package:forensic_expert/domain/library/library_models.dart';

import '../helpers/pilot_content.dart';

/// «Tahlil» agregatsiyasi — HAQIQIY pilot paket bo‘yicha. Hech narsa
/// taxmin qilinmaydi: faqat paketdagi manbali graf bog‘lanishlari.
void main() {
  late PilotContent pilot;
  setUpAll(() async => pilot = await loadPilotContent());

  SubstanceAnalysis of(String id) => SubstanceAnalysis.build(
    entityId: id,
    evidence: pilot.evidence,
    provenance: pilot.provenance,
  );

  test('morfin: qon (manbali), SX-MS/MS, metod namunaga bog‘lanmagan', () {
    final a = of('morphine');
    expect(a.isEmpty, isFalse);
    expect(a.specimens.map((s) => s.specimenId), ['blood']);
    final blood = a.specimens.single;
    expect(blood.specimen?.names.resolve('uz'), 'Qon');
    expect(blood.basisIds, ['C-MORPHINE-REPORTED_CONCENTRATION-P5']);
    expect(blood.basisClaims.single.field, 'reported_concentration');
    expect(blood.methodIds, isEmpty);
    expect(a.methodsLinkedToSpecimens, isFalse);
    expect(a.analyticalMethods.map((m) => m.methodId), ['method-lcmsms']);
    expect(
      a.analyticalMethods.single.basisClaims.single.field,
      'analytical_method',
    );
    expect(a.screenings, isEmpty);
    expect(a.confirmationMethods, isEmpty);
    expect(a.metabolites.map((m) => m.relation.metaboliteName), [
      'morphine-3-glucuronide (M3G)',
      'morphine-6-glucuronide (M6G)',
    ]);
  });

  test('etanol: paketda namuna yo‘q — faqat manbadagi metodlar', () {
    final a = of('ethanol');
    expect(a.specimens, isEmpty);
    expect(a.analyticalMethods.map((m) => m.methodId), [
      'method-gc-fid',
      'method-headspace-gc',
      'method-lcmsms',
    ]);
    expect(
      a.metabolites.map((m) => m.relation.metaboliteName),
      containsAll(['acetaldehyde', 'acetate']),
    );
  });

  test('etilenglikol: qon → zardob/plazma → siydik tartibida', () {
    final a = of('ethylene-glycol');
    expect(a.specimens.map((s) => s.specimenId), [
      'blood',
      'serum-plasma',
      'urine',
    ]);
    expect(a.specimens.last.specimen?.names.resolve('uz'), 'Siydik');
  });

  test('kokain: skrining → tasdiqlash (GX-MS, SX-MS/MS), metabolit', () {
    final a = of('cocaine');
    expect(a.screenings.map((s) => s.screeningId), ['scr-immunoassay-drugs']);
    expect(a.screenings.single.confirmationMethodIds, [
      'method-gcms',
      'method-lcmsms',
    ]);
    expect(a.confirmationMethods.map((m) => m.methodId), [
      'method-gcms',
      'method-lcmsms',
    ]);
    for (final m in a.confirmationMethods) {
      expect(m.role, AnalysisMethodRole.confirmation);
      expect(m.afterScreeningIds, ['scr-immunoassay-drugs']);
    }
    final be = a.metabolites.singleWhere(
      (m) => m.relation.metaboliteId == 'benzoylecgonine',
    );
    // Metabolitning o‘z namunalari — uning o‘z `measured_in` bog‘lanishlari.
    final own = {
      for (final l in pilot.evidence.linksFrom('benzoylecgonine'))
        if (l.relation == LinkRelation.measuredIn) l.toId,
    };
    expect(be.specimenIds.toSet(), own);
  });

  test('geroin: metabolit morfin — qonda (morfinning o‘z bog‘lanishi)', () {
    final a = of('heroin');
    final m = a.metabolites.singleWhere(
      (m) => m.relation.metaboliteId == 'morphine',
    );
    expect(m.specimenIds, ['blood']);
  });

  test('GHB: paketda tahlil ma’lumoti yo‘q — bo‘sh', () {
    expect(of('ghb').isEmpty, isTrue);
  });

  test('har bir element asosi paketdagi claim; hech biri VERIFIED emas', () {
    var withData = 0;
    for (final e in pilot.library.entries(LibrarySection.substances)) {
      final a = of(e.id);
      if (!a.isEmpty) withData++;
      final groups = <(List<String>, List<ClaimView>)>[
        for (final s in a.specimens) (s.basisIds, s.basisClaims),
        for (final s in a.screenings) (s.basisIds, s.basisClaims),
        for (final m in a.analyticalMethods) (m.basisIds, m.basisClaims),
        for (final m in a.confirmationMethods) (m.basisIds, m.basisClaims),
      ];
      for (final (ids, claims) in groups) {
        expect(ids, isNotEmpty, reason: e.id);
        expect(claims.length, ids.length, reason: '${e.id}: $ids');
        for (final c in claims) {
          expect(c.status, isNot(ScientificStatus.verified), reason: e.id);
        }
      }
    }
    expect(withData, greaterThan(100));
  });

  test('teskari ro‘yxat: qonda o‘lchangan moddalar', () {
    final blood = substancesMeasuredIn(pilot.evidence, 'blood');
    expect(blood, containsAll(['morphine', 'cocaine', 'ethylene-glycol']));
    expect(blood, isNot(contains('ethanol')));
    expect(
      substancesMeasuredIn(pilot.evidence, 'urine'),
      [
        'ethylene-glycol',
        ...substancesMeasuredIn(
          pilot.evidence,
          'urine',
        ).where((id) => id != 'ethylene-glycol'),
      ]..sort(),
    );
  });
}
