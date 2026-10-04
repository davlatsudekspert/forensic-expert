import 'package:fe_calc_engine/fe_calc_engine.dart';
import 'package:test/test.dart';

// Kutilgan qiymatlar qo‘lda, kalkulyatordan MUSTAQIL hisoblangan
// (C1V1 = C2V2 ta’rifidan) — har bir holat izohda ko‘rsatilgan.
void main() {
  const calc = DilutionCalculator();

  test('descriptor reviewer tasdig‘isiz verified emas', () {
    expect(calc.descriptor.reviewState, CalculatorReviewState.needsReview);
    expect(calc.descriptor.isDefinitional, isTrue);
    expect(CalculatorRegistry.descriptorById('lab.dilution.c1v1'), isNotNull);
  });

  test('V1 ni topish: 10 mg/mL → 1 mg/mL, 100 mL ⇒ V1 = 1·100/10 = 10 mL', () {
    final r = calc.calculate(
      const DilutionInput(
        c1: Quantity(10, Unit.milligramPerMilliliter),
        c2: Quantity(1, Unit.milligramPerMilliliter),
        v2: Quantity(100, Unit.milliliter),
      ),
    );
    expect(r.value.unknown, DilutionUnknown.v1);
    expect(r.value.result.unit, Unit.milliliter);
    expect(r.value.result.value, closeTo(10, 1e-12));
    expect(r.warnings, isEmpty);
  });

  test(
    'aralash birliklar: C1 = 1 g/L, C2 = 50 mg/L, V2 = 1 L ⇒ V1 = 50 mL',
    () {
      final r = calc.calculate(
        const DilutionInput(
          c1: Quantity(1, Unit.gramPerLiter),
          c2: Quantity(50, Unit.milligramPerLiter),
          v2: Quantity(1, Unit.liter),
        ),
      );
      expect(r.value.result.to(Unit.milliliter).value, closeTo(50, 1e-9));
    },
  );

  test(
    'C2 ni topish: C1 = 2 mmol/L, V1 = 250 µL, V2 = 1 mL ⇒ C2 = 0.5 mmol/L',
    () {
      final r = calc.calculate(
        const DilutionInput(
          c1: Quantity(2, Unit.millimolePerLiter),
          v1: Quantity(250, Unit.microliter),
          v2: Quantity(1, Unit.milliliter),
        ),
      );
      expect(r.value.result.unit, Unit.millimolePerLiter);
      expect(r.value.result.value, closeTo(0.5, 1e-12));
    },
  );

  test('C1 va V2 ni topish', () {
    final c1 = calc.calculate(
      const DilutionInput(
        v1: Quantity(5, Unit.milliliter),
        c2: Quantity(2, Unit.microgramPerMilliliter),
        v2: Quantity(50, Unit.milliliter),
      ),
    );
    expect(c1.value.result.value, closeTo(20, 1e-12)); // 2·50/5
    final v2 = calc.calculate(
      const DilutionInput(
        c1: Quantity(20, Unit.microgramPerMilliliter),
        v1: Quantity(5, Unit.milliliter),
        c2: Quantity(2, Unit.microgramPerMilliliter),
      ),
    );
    expect(v2.value.result.value, closeTo(50, 1e-12)); // 20·5/2
  });

  test('yakuniy konsentratsiya boshlang‘ichdan katta bo‘lsa ogohlantirish', () {
    final r = calc.calculate(
      const DilutionInput(
        c1: Quantity(1, Unit.milligramPerLiter),
        c2: Quantity(2, Unit.milligramPerLiter),
        v2: Quantity(1, Unit.liter),
      ),
    );
    expect(r.warnings.single.code, 'final_concentration_exceeds_stock');
  });

  group('kiritish xatolari', () {
    test('noma’lum soni 1 emas', () {
      expect(
        () => calc.calculate(const DilutionInput()),
        throwsA(isA<CalcInputException>()),
      );
    });
    test('hajm o‘rnida konsentratsiya birligi', () {
      expect(
        () => calc.calculate(
          const DilutionInput(
            c1: Quantity(1, Unit.gramPerLiter),
            c2: Quantity(1, Unit.gramPerLiter),
            v2: Quantity(1, Unit.gramPerLiter),
          ),
        ),
        throwsA(isA<CalcInputException>()),
      );
    });
    test('massa va molyar konsentratsiyani aralashtirish taqiqlangan', () {
      expect(
        () => calc.calculate(
          const DilutionInput(
            c1: Quantity(1, Unit.gramPerLiter),
            c2: Quantity(1, Unit.millimolePerLiter),
            v2: Quantity(1, Unit.liter),
          ),
        ),
        throwsA(isA<CalcInputException>()),
      );
    });
    test('nol va manfiy qiymat', () {
      expect(
        () => calc.calculate(
          const DilutionInput(
            c1: Quantity(0, Unit.gramPerLiter),
            c2: Quantity(1, Unit.gramPerLiter),
            v2: Quantity(1, Unit.liter),
          ),
        ),
        throwsA(isA<CalcInputException>()),
      );
    });
  });

  group('Quantity/Unit', () {
    test('ng/mL = µg/L (ta’rif bo‘yicha)', () {
      expect(
        const Quantity(
          7,
          Unit.nanogramPerMilliliter,
        ).to(Unit.microgramPerLiter).value,
        closeTo(7, 1e-12),
      );
    });
    test('har xil o‘lchamni konvertatsiya qilib bo‘lmaydi', () {
      expect(
        () => const Quantity(1, Unit.liter).to(Unit.gram),
        throwsA(isA<IncompatibleUnitsException>()),
      );
    });
  });
}
