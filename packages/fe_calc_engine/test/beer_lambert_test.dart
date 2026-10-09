import 'package:fe_calc_engine/fe_calc_engine.dart';
import 'package:test/test.dart';

/// Ber–Lambert A = ε·l·c — qo‘lda hisoblangan qiymatlar bilan.
void main() {
  const calc = BeerLambertCalculator();

  group('molyar asos (ε, L·mol⁻¹·cm⁻¹)', () {
    test('A = 15000 × 1 sm × 2·10⁻⁵ mol/L = 0,3', () {
      final r = calc.calculate(
        const BeerLambertInput(
          basis: AbsorptivityBasis.molar,
          pathLength: 1,
          absorptivity: 15000,
          concentration: Quantity(20, Unit.micromolePerLiter),
        ),
      );
      expect(r.value.unknown, BeerLambertUnknown.absorbance);
      expect(r.value.value, closeTo(0.3, 1e-12));
    });

    test('c = 0,45 / (15000 × 1) = 3·10⁻⁵ mol/L = 30 µmol/L', () {
      final r = calc.calculate(
        const BeerLambertInput(
          basis: AbsorptivityBasis.molar,
          pathLength: 1,
          absorbance: 0.45,
          absorptivity: 15000,
          concentrationUnit: Unit.micromolePerLiter,
        ),
      );
      expect(r.value.unknown, BeerLambertUnknown.concentration);
      expect(r.value.concentration!.unit, Unit.micromolePerLiter);
      expect(r.value.concentration!.value, closeTo(30, 1e-9));
    });

    test('5 mm kyuveta: c = 0,3 / (15000 × 0,5) = 40 µmol/L', () {
      final r = calc.calculate(
        const BeerLambertInput(
          basis: AbsorptivityBasis.molar,
          pathLength: 5,
          pathLengthUnit: PathLengthUnit.millimeter,
          absorbance: 0.3,
          absorptivity: 15000,
          concentrationUnit: Unit.micromolePerLiter,
        ),
      );
      expect(r.value.concentration!.value, closeTo(40, 1e-9));
    });

    test('birlik berilmasa — mol/L', () {
      final r = calc.calculate(
        const BeerLambertInput(
          basis: AbsorptivityBasis.molar,
          pathLength: 1,
          absorbance: 0.45,
          absorptivity: 15000,
        ),
      );
      expect(r.value.concentration!.unit, Unit.molePerLiter);
      expect(r.value.concentration!.value, closeTo(3e-5, 1e-15));
    });

    test('ε = 0,6 / (2 sm × 1 mmol/L) = 300 L·mol⁻¹·cm⁻¹', () {
      final r = calc.calculate(
        const BeerLambertInput(
          basis: AbsorptivityBasis.molar,
          pathLength: 2,
          absorbance: 0.6,
          concentration: Quantity(1, Unit.millimolePerLiter),
        ),
      );
      expect(r.value.unknown, BeerLambertUnknown.absorptivity);
      expect(r.value.value, closeTo(300, 1e-9));
    });
  });

  group('massaviy asos (a, L·g⁻¹·cm⁻¹)', () {
    test('a = 0,5 / (1 sm × 20 mg/L) = 25 L·g⁻¹·cm⁻¹', () {
      final r = calc.calculate(
        const BeerLambertInput(
          basis: AbsorptivityBasis.mass,
          pathLength: 1,
          absorbance: 0.5,
          concentration: Quantity(20, Unit.milligramPerLiter),
        ),
      );
      expect(r.value.value, closeTo(25, 1e-9));
    });

    test('c = 0,25 / (25 × 1) = 0,01 g/L = 10 µg/mL', () {
      final r = calc.calculate(
        const BeerLambertInput(
          basis: AbsorptivityBasis.mass,
          pathLength: 1,
          absorbance: 0.25,
          absorptivity: 25,
          concentrationUnit: Unit.microgramPerMilliliter,
        ),
      );
      expect(r.value.concentration!.value, closeTo(10, 1e-9));
    });

    test('teskari tekshiruv: A → c → A', () {
      const a = 37.5, l = 1.0;
      final c = calc
          .calculate(
            const BeerLambertInput(
              basis: AbsorptivityBasis.mass,
              pathLength: l,
              absorbance: 0.75,
              absorptivity: a,
              concentrationUnit: Unit.milligramPerLiter,
            ),
          )
          .value
          .concentration!;
      expect(c.value, closeTo(20, 1e-9));
      final back = calc.calculate(
        BeerLambertInput(
          basis: AbsorptivityBasis.mass,
          pathLength: l,
          absorptivity: a,
          concentration: c,
        ),
      );
      expect(back.value.value, closeTo(0.75, 1e-12));
    });
  });

  group('kiritish xatolari', () {
    test('aynan bitta noma’lum bo‘lishi kerak', () {
      expect(
        () => calc.calculate(
          const BeerLambertInput(
            basis: AbsorptivityBasis.molar,
            pathLength: 1,
            absorbance: 0.3,
          ),
        ),
        throwsA(
          isA<CalcInputException>().having(
            (e) => e.code,
            'code',
            'exactly_one_unknown_required',
          ),
        ),
      );
      expect(
        () => calc.calculate(
          const BeerLambertInput(
            basis: AbsorptivityBasis.molar,
            pathLength: 1,
            absorbance: 0.3,
            absorptivity: 100,
            concentration: Quantity(1, Unit.molePerLiter),
          ),
        ),
        throwsA(isA<CalcInputException>()),
      );
    });

    test('nol, manfiy va cheksiz qiymatlar rad etiladi', () {
      for (final (l, a) in [(0.0, 0.3), (-1.0, 0.3), (1.0, -0.1), (1.0, 0.0)]) {
        expect(
          () => calc.calculate(
            BeerLambertInput(
              basis: AbsorptivityBasis.molar,
              pathLength: l,
              absorbance: a,
              absorptivity: 100,
            ),
          ),
          throwsA(
            isA<CalcInputException>().having(
              (e) => e.code,
              'code',
              'positive_required',
            ),
          ),
          reason: 'l=$l A=$a',
        );
      }
      expect(
        () => calc.calculate(
          const BeerLambertInput(
            basis: AbsorptivityBasis.molar,
            pathLength: double.infinity,
            absorbance: 0.3,
            absorptivity: 100,
          ),
        ),
        throwsA(isA<CalcInputException>()),
      );
    });

    test('molyar ε bilan massaviy konsentratsiya — birlik xatosi', () {
      expect(
        () => calc.calculate(
          const BeerLambertInput(
            basis: AbsorptivityBasis.molar,
            pathLength: 1,
            absorptivity: 100,
            concentration: Quantity(1, Unit.milligramPerLiter),
          ),
        ),
        throwsA(
          isA<CalcInputException>().having(
            (e) => e.code,
            'code',
            'concentration_basis_mismatch',
          ),
        ),
      );
      expect(
        () => calc.calculate(
          const BeerLambertInput(
            basis: AbsorptivityBasis.mass,
            pathLength: 1,
            absorbance: 0.2,
            absorptivity: 10,
            concentrationUnit: Unit.millimolePerLiter,
          ),
        ),
        throwsA(isA<CalcInputException>()),
      );
    });
  });

  test('deskriptor: ta’rifiy, NEEDS_REVIEW, reyestrda', () {
    final d = calc.descriptor;
    expect(d.id, 'lab.beer_lambert');
    expect(d.isDefinitional, isTrue);
    expect(d.reviewState, CalculatorReviewState.needsReview);
    expect(d.referenceSourceIds, isEmpty);
    expect(CalculatorRegistry.descriptorById('lab.beer_lambert'), same(d));
  });
}
