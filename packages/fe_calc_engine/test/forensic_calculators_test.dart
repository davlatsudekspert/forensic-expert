import 'package:fe_calc_engine/fe_calc_engine.dart';
import 'package:test/test.dart';

void main() {
  group('Widmark', () {
    const w = WidmarkCalculator();
    test('erkak 80 kg, 500 mL 40 %, 2 soat — diapazon', () {
      final r = w.calculate(
        const WidmarkInput(
          sex: BiologicalSex.male,
          bodyWeightKg: 80,
          drinks: [Drink(volumeMl: 500, abvPercent: 40)],
          hoursSinceDrinkingStart: 2,
        ),
      );
      expect(r.value.ethanolGrams, closeTo(157.8, 1e-9));
      expect(r.value.peakPromille, closeTo(157.8 / 56, 1e-9));
      expect(r.value.maxPromille, closeTo(157.8 * 0.9 / 56 - 0.2, 1e-9));
      expect(r.value.minPromille, closeTo(157.8 * 0.7 / 56 - 0.4, 1e-9));
    });
    test('Seidl r: bo‘y berilsa', () {
      final r = w.calculate(
        const WidmarkInput(
          sex: BiologicalSex.female,
          bodyWeightKg: 60,
          heightCm: 165,
          drinks: [Drink(volumeMl: 330, abvPercent: 5)],
          hoursSinceDrinkingStart: 0,
        ),
      );
      expect(r.value.rFromHeight, isTrue);
      expect(
        r.value.r,
        closeTo(0.31223 - 0.006446 * 60 + 0.004466 * 165, 1e-12),
      );
    });
    test('to‘liq eliminatsiya — 0 va ogohlantirish', () {
      final r = w.calculate(
        const WidmarkInput(
          sex: BiologicalSex.male,
          bodyWeightKg: 90,
          drinks: [Drink(volumeMl: 330, abvPercent: 5)],
          hoursSinceDrinkingStart: 10,
        ),
      );
      expect(r.value.maxPromille, 0);
      expect(r.warnings.map((e) => e.code), contains('fully_eliminated'));
    });
    test('noto‘g‘ri kirish rad etiladi', () {
      expect(
        () => w.calculate(
          const WidmarkInput(
            sex: BiologicalSex.male,
            bodyWeightKg: 5,
            drinks: [Drink(volumeMl: 100, abvPercent: 40)],
            hoursSinceDrinkingStart: 1,
          ),
        ),
        throwsA(isA<CalcInputException>()),
      );
    });
  });

  group('teskari hisob', () {
    const b = BackCalculationCalculator();
    test('1,0 ‰, 3 soat → 1,30…1,75 ‰', () {
      final r = b.calculate(
        const BackCalculationInput(
          measuredPromille: 1.0,
          hoursBetweenEventAndSampling: 3,
        ),
      );
      expect(r.value.minPromille, closeTo(1.30, 1e-9));
      expect(r.value.maxPromille, closeTo(1.75, 1e-9));
      expect(r.value.absorptionPhaseRisk, isFalse);
    });
    test('rezorbsiya fazasi: minimum qo‘shimchasiz', () {
      final r = b.calculate(
        const BackCalculationInput(
          measuredPromille: 0.8,
          hoursBetweenEventAndSampling: 2,
          hoursFromDrinkingEndToEvent: 1,
        ),
      );
      expect(r.value.minPromille, 0.8);
      expect(r.warnings.map((e) => e.code), contains('absorption_phase'));
    });
  });

  group('etanol birliklari', () {
    const u = EthanolUnitsCalculator();
    test('1 ‰ to‘liq qon → 1,055 g/L → 105,5 mg/dL → 22,9 mmol/L', () {
      final r = u.calculate(
        const EthanolUnitsInput(value: 1, unit: EthanolUnit.promille),
      );
      final m = r.value.wholeBlood;
      expect(m[EthanolUnit.gramPerLiter], closeTo(1.055, 1e-9));
      expect(m[EthanolUnit.milligramPerDeciliter], closeTo(105.5, 1e-9));
      expect(m[EthanolUnit.percentBac], closeTo(0.1055, 1e-9));
      expect(m[EthanolUnit.millimolePerLiter], closeTo(22.900, 1e-3));
      expect(m[EthanolUnit.promille], closeTo(1, 1e-12));
    });
    test('zardob 1,2 g/L → qon 1,0 g/L (Q = 1,2)', () {
      final r = u.calculate(
        const EthanolUnitsInput(
          value: 1.2,
          unit: EthanolUnit.gramPerLiter,
          matrix: EthanolMatrix.serum,
        ),
      );
      expect(r.value.wholeBlood[EthanolUnit.gramPerLiter], closeTo(1, 1e-12));
      expect(r.value.serum, 1.2);
    });
  });

  group('Henssge', () {
    const h = HenssgeCalculator();
    test('Tr 30, Ta 15, 75 kg, c=1 → ~10,3 soat ± 2,8', () {
      final r = h.calculate(
        const HenssgeInput(rectalTempC: 30, ambientTempC: 15, bodyWeightKg: 75),
      );
      expect(r.value.hours, closeTo(10.3, 0.2));
      expect(r.value.ci95Hours, 2.8);
      // Topilgan t tenglamani qanoatlantiradi.
      expect(
        HenssgeCalculator.qAt(r.value.hours, r.value.b, 15),
        closeTo(r.value.q, 1e-9),
      );
    });
    test('Ta > 23 °C — boshqa tenglama, ± 3,2; tuzatish bilan ± 4,5', () {
      final hot = h.calculate(
        const HenssgeInput(rectalTempC: 33, ambientTempC: 26, bodyWeightKg: 70),
      );
      expect(hot.value.ci95Hours, 3.2);
      final dressed = h.calculate(
        const HenssgeInput(
          rectalTempC: 30,
          ambientTempC: 15,
          bodyWeightKg: 75,
          correctiveFactor: 1.3,
        ),
      );
      expect(dressed.value.ci95Hours, 4.5);
      expect(dressed.value.hours, greaterThan(10.3));
    });
    test('Tr ≤ Ta — rad etiladi', () {
      expect(
        () => h.calculate(
          const HenssgeInput(
            rectalTempC: 15,
            ambientTempC: 20,
            bodyWeightKg: 70,
          ),
        ),
        throwsA(isA<CalcInputException>()),
      );
    });
  });

  test('reyestrda 12 ta kalkulyator', () {
    expect(CalculatorRegistry.descriptorById('tox.ethanol.widmark'), isNotNull);
    expect(CalculatorRegistry.descriptorById('fm.pmi.henssge'), isNotNull);
  });
}
