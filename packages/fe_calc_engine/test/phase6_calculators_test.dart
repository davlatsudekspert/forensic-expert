import 'package:fe_calc_engine/fe_calc_engine.dart';
import 'package:test/test.dart';

void main() {
  group('konsentratsiya konvertatsiyasi', () {
    const c = ConcentrationConversionCalculator();
    test('mg/L → µg/mL → ng/mL (SI prefikslari)', () {
      final r = c.calculate(
        const ConcentrationConversionInput(
          value: Quantity(1, Unit.milligramPerLiter),
          target: Unit.nanogramPerMilliliter,
        ),
      );
      expect(r.value.value, closeTo(1000, 1e-9));
    });
    test('mol/L ↔ g/L: ρ = c·M', () {
      final r = c.calculate(
        const ConcentrationConversionInput(
          value: Quantity(0.5, Unit.molePerLiter),
          target: Unit.gramPerLiter,
          molarMassGPerMol: 58.44,
        ),
      );
      expect(r.value.value, closeTo(29.22, 1e-9));
    });
    test('massa ↔ molyar: molyar massasiz — xato (taxmin yo‘q)', () {
      expect(
        () => c.calculate(
          const ConcentrationConversionInput(
            value: Quantity(1, Unit.gramPerLiter),
            target: Unit.millimolePerLiter,
          ),
        ),
        throwsA(isA<CalcInputException>()),
      );
    });
    test('hajm birligi — rad etiladi', () {
      expect(
        () => c.calculate(
          const ConcentrationConversionInput(
            value: Quantity(1, Unit.milliliter),
            target: Unit.gramPerLiter,
          ),
        ),
        throwsA(isA<CalcInputException>()),
      );
    });
  });

  test('molyarlik: 5.844 g NaCl (M 58.44), 1 L → 0.1 mol/L', () {
    final r = const MolarityCalculator().calculate(
      const MolarityInput(
        mass: Quantity(5.844, Unit.gram),
        molarMassGPerMol: 58.44,
        volume: Quantity(1000, Unit.milliliter),
      ),
    );
    expect(r.value.value, closeTo(0.1, 1e-12));
    expect(
      () => const MolarityCalculator().calculate(
        const MolarityInput(
          mass: Quantity(1, Unit.gram),
          molarMassGPerMol: 1,
          volume: Quantity(1, Unit.liter),
          purityFraction: 1.2,
        ),
      ),
      throwsA(isA<CalcInputException>()),
    );
  });

  test('foizli eritma: 5 % (w/v), 200 mL → 10 g; v/v → mL', () {
    const c = PercentSolutionCalculator();
    final w = c.calculate(
      const PercentSolutionInput(
        basis: PercentBasis.weightPerVolume,
        percent: 5,
        totalAmount: 200,
      ),
    );
    expect(w.value.soluteAmount, closeTo(10, 1e-12));
    expect(w.value.soluteUnit, 'g');
    final v = c.calculate(
      const PercentSolutionInput(
        basis: PercentBasis.volumePerVolume,
        percent: 70,
        totalAmount: 100,
      ),
    );
    expect(v.value.soluteUnit, 'mL');
    expect(
      () => c.calculate(
        const PercentSolutionInput(
          basis: PercentBasis.weightPerWeight,
          percent: 120,
          totalAmount: 1,
        ),
      ),
      throwsA(isA<CalcInputException>()),
    );
  });

  group('tavsifiy statistika', () {
    const c = DescriptiveStatsCalculator();
    test('ma’lum qiymatlar: 2,4,4,4,5,5,7,9', () {
      final r = c.calculate([2, 4, 4, 4, 5, 5, 7, 9]).value;
      expect(r.mean, 5);
      expect(r.median, 4.5);
      // Tanlanma SD (n−1) = √(32/7).
      expect(r.sd, closeTo(2.138089935, 1e-9));
      expect(r.cvPercent, closeTo(42.7617987, 1e-6));
    });
    test('bitta qiymat: SD yo‘q, ogohlantirish', () {
      final r = c.calculate([3]);
      expect(r.value.sd, isNull);
      expect(r.warnings.single.code, 'sd_requires_two_values');
    });
    test('matnni ajratish', () {
      expect(parseValues('1.5, 2 3'), [1.5, 2, 3]);
      expect(parseValues('1,5; 2,5'), [1.5, 2.5]);
      expect(parseValues('1,5\n2,5'), [1.5, 2.5]);
    });
  });

  group('chiziqli regressiya', () {
    const c = LinearRegressionCalculator();
    test('aniq chiziq y = 2 + 3x', () {
      final r = c.calculate([(0, 2), (1, 5), (2, 8), (3, 11), (4, 14)]).value;
      expect(r.slope, closeTo(3, 1e-12));
      expect(r.intercept, closeTo(2, 1e-12));
      expect(r.rSquared, closeTo(1, 1e-12));
      expect(r.residualSd, closeTo(0, 1e-12));
    });
    test('shovqinli ma’lumot — qo‘lda tekshirilgan qiymatlar', () {
      final r = c.calculate([(1, 2.1), (2, 3.9), (3, 6.2), (4, 7.8)]).value;
      // Sxx = 5, Sxy = 9.7 → b = 1.94; a = 5 − 1.94·2.5 = 0.15.
      expect(r.slope, closeTo(1.94, 1e-12));
      expect(r.intercept, closeTo(0.15, 1e-12));
      // SSE = 0.082 → s_y/x = √(0.082/2).
      expect(r.residualSd, closeTo(0.2024846, 1e-6));
    });
    test('kamida 3 nuqta; bir xil x — xato', () {
      expect(
        () => c.calculate([(1, 1), (2, 2)]),
        throwsA(isA<CalcInputException>()),
      );
      expect(
        () => c.calculate([(1, 1), (1, 2), (1, 3)]),
        throwsA(isA<CalcInputException>()),
      );
    });
  });

  test('LOD/LOQ (ICH Q2(R1) 6.3/7.3): 3.3σ/S va 10σ/S, manba bog‘langan', () {
    const c = LodLoqCalculator();
    final r = c.calculate(
      const LodLoqInput(
        sigma: 0.2,
        slope: 2,
        sigmaBasis: SigmaBasis.residualSd,
      ),
    );
    expect(r.value.lod, closeTo(0.33, 1e-12));
    expect(r.value.loq, closeTo(1.0, 1e-12));
    expect(c.descriptor.referenceSourceIds, ['SRC-ICH-Q2R1']);
    expect(c.descriptor.isDefinitional, isFalse);
    expect(
      () => c.calculate(
        const LodLoqInput(sigma: 1, slope: 0, sigmaBasis: SigmaBasis.blankSd),
      ),
      throwsA(isA<CalcInputException>()),
    );
  });

  test('reyestr: ID’lar noyob; hech biri reviewersiz verified emas', () {
    final ds = CalculatorRegistry.descriptors;
    expect({for (final d in ds) d.id}.length, ds.length);
    for (final d in ds) {
      expect(d.reviewState, CalculatorReviewState.needsReview, reason: d.id);
      // Ta’rifiy bo‘lmagan formula manbasiz bo‘lishi mumkin emas.
      if (!d.isDefinitional) {
        expect(d.referenceSourceIds, isNotEmpty, reason: d.id);
      }
    }
  });
}
