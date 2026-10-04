import 'package:fe_calc_engine/fe_calc_engine.dart';
import 'package:test/test.dart';

/// Faqat ta’rifiy arifmetika sinovlari (hech qanday reagent retsepti yo‘q).
void main() {
  const calc = SolutionPreparationCalculator();

  test('massa konsentratsiyasi: m = C·V', () {
    final r = calc.calculate(
      const SolutionPreparationInput(
        targetConcentration: Quantity(2, Unit.gramPerLiter),
        finalVolume: Quantity(250, Unit.milliliter),
      ),
    );
    expect(r.value.mass.unit, Unit.milligram);
    expect(r.value.mass.value, closeTo(500, 1e-9));
    expect(r.warnings, isEmpty);
  });

  test('molyar: m = C·V·M (M foydalanuvchi kiritadi)', () {
    final r = calc.calculate(
      const SolutionPreparationInput(
        targetConcentration: Quantity(0.1, Unit.molePerLiter),
        finalVolume: Quantity(1, Unit.liter),
        molarMassGPerMol: 100,
      ),
    );
    expect(r.value.mass.unit, Unit.gram);
    expect(r.value.mass.value, closeTo(10, 1e-9));
  });

  test('tozalik tuzatishi va ogohlantirish', () {
    final r = calc.calculate(
      const SolutionPreparationInput(
        targetConcentration: Quantity(1, Unit.gramPerLiter),
        finalVolume: Quantity(1, Unit.liter),
        purityFraction: 0.5,
      ),
    );
    expect(r.value.mass.value, closeTo(2, 1e-9));
    expect(r.warnings.single.code, 'purity_correction_applied');
  });

  test('molyar massa bo‘lmasa — xato (taxmin yo‘q)', () {
    expect(
      () => calc.calculate(
        const SolutionPreparationInput(
          targetConcentration: Quantity(1, Unit.millimolePerLiter),
          finalVolume: Quantity(1, Unit.liter),
        ),
      ),
      throwsA(
        isA<CalcInputException>().having(
          (e) => e.code,
          'code',
          'molar_mass_required',
        ),
      ),
    );
  });

  test('noto‘g‘ri kiritish', () {
    for (final input in [
      const SolutionPreparationInput(
        targetConcentration: Quantity(1, Unit.liter),
        finalVolume: Quantity(1, Unit.liter),
      ),
      const SolutionPreparationInput(
        targetConcentration: Quantity(1, Unit.gramPerLiter),
        finalVolume: Quantity(1, Unit.gram),
      ),
      const SolutionPreparationInput(
        targetConcentration: Quantity(-1, Unit.gramPerLiter),
        finalVolume: Quantity(1, Unit.liter),
      ),
      const SolutionPreparationInput(
        targetConcentration: Quantity(1, Unit.gramPerLiter),
        finalVolume: Quantity(1, Unit.liter),
        purityFraction: 1.2,
      ),
    ]) {
      expect(() => calc.calculate(input), throwsA(isA<CalcInputException>()));
    }
  });

  test('reyestrda; ta’rifiy va review kutmoqda', () {
    final d = CalculatorRegistry.descriptorById('lab.solution.mass_required')!;
    expect(d.isDefinitional, isTrue);
    expect(d.reviewState, CalculatorReviewState.needsReview);
  });
}
