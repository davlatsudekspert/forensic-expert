import 'package:fe_calc_engine/fe_calc_engine.dart';
import 'package:test/test.dart';

/// 2026-10-09 «polish tools» auditida topilgan hisob xatolari.
void main() {
  group('parseValues: o‘nlik vergul', () {
    test('bo‘shliq bilan ajratilgan «0,5 0,7 0,9» — uchta qiymat', () {
      // Avval: [0, 5, 0, 7, 0, 9] (n = 6, o‘rtacha 3,5 — noto‘g‘ri).
      expect(parseValues('0,5 0,7 0,9'), [0.5, 0.7, 0.9]);
      final r = const DescriptiveStatsCalculator().calculate(
        parseValues('0,5 0,7 0,9'),
      );
      expect(r.value.n, 3);
      expect(r.value.mean, closeTo(0.7, 1e-12));
      expect(r.value.sd, closeTo(0.2, 1e-12));
    });
    test('vergul + bo‘shliq — ajratuvchi (eski xatti-harakat)', () {
      expect(parseValues('1.5, 2 3'), [1.5, 2, 3]);
      expect(parseValues('1, 2, 3'), [1, 2, 3]);
    });
    test('bo‘shliqsiz «1,2,3» — ajratuvchi', () {
      expect(parseValues('1,2,3'), [1, 2, 3]);
    });
    test('tab va «;»', () {
      expect(parseValues('0,5\t0,7'), [0.5, 0.7]);
      expect(parseValues('1,5; 2,5'), [1.5, 2.5]);
    });
  });

  group('parsePoints: kalibrlash juftliklari', () {
    test('o‘nlik vergulli «x y» qatorlari', () {
      // Avval: «0 0,1» → [0, 0, 1] → format xatosi (vergulli kiritish
      // umuman ishlamasdi).
      expect(parsePoints('0 0,1\n1 2,0\n2 4,1'), [
        (0, 0.1),
        (1, 2.0),
        (2, 4.1),
      ]);
    });
    test('«x; y» va tab', () {
      expect(parsePoints('1; 0,5\n2;1,5'), [(1, 0.5), (2, 1.5)]);
      expect(parsePoints('1\t0,5'), [(1, 0.5)]);
    });
    test('«x, y» (vergul + bo‘shliq) va nuqtali o‘nlik', () {
      expect(parsePoints('1, 0.5\n2, 1.5'), [(1, 0.5), (2, 1.5)]);
      expect(parsePoints('1.5 0.25'), [(1.5, 0.25)]);
    });
    test('bo‘sh qatorlar o‘tkaziladi; noto‘g‘ri qator — FormatException', () {
      expect(parsePoints('\n1 2\n\n3 4\n'), [(1, 2), (3, 4)]);
      expect(() => parsePoints('1 2 3'), throwsFormatException);
      expect(() => parsePoints('1 abc'), throwsFormatException);
    });
    test('regressiya vergulli ma’lumotda', () {
      final r = const LinearRegressionCalculator().calculate(
        parsePoints('0 0,1\n1 2,0\n2 4,1\n3 5,9\n4 8,1'),
      );
      // Σ(x−x̄)(y−ȳ) = 19,9; Σ(x−x̄)² = 10 → b = 1,99; a = 4,04 − 3,98.
      expect(r.value.slope, closeTo(1.99, 1e-12));
      expect(r.value.intercept, closeTo(0.06, 1e-12));
    });
  });

  group('teskari hisob: β birligi (g/L/soat) va ‰', () {
    const b = BackCalculationCalculator();
    test('‰ kiritilganda β qon zichligi bilan ‰/soat ga o‘tkaziladi', () {
      // Jones (2010): β = 10–25 mg/100 mL/soat = 0,10–0,25 g/L/soat.
      // ‰ = g/kg; g/L = ‰ · 1,055 → β‰ = β / 1,055.
      // Avval: 1 + 0,10·3 = 1,30 ‰ (birlik aralashgan).
      final r = b.calculate(
        const BackCalculationInput(
          measured: 1.0,
          hoursBetweenEventAndSampling: 3,
        ),
      );
      expect(r.value.min, closeTo(1 + 0.30 / 1.055, 1e-9));
      expect(r.value.max, closeTo(1 + 0.75 / 1.055, 1e-9));
      expect(r.value.unit, EthanolUnit.promille);
    });
    test('g/L kiritilganda β to‘g‘ridan-to‘g‘ri', () {
      final r = b.calculate(
        const BackCalculationInput(
          measured: 1.0,
          unit: EthanolUnit.gramPerLiter,
          hoursBetweenEventAndSampling: 3,
        ),
      );
      expect(r.value.min, closeTo(1.30, 1e-9));
      expect(r.value.max, closeTo(1.75, 1e-9));
      expect(r.value.unit, EthanolUnit.gramPerLiter);
    });
    test('faqat ‰ va g/L qabul qilinadi; diapazon ‰ ekvivalentida', () {
      expect(
        () => b.calculate(
          const BackCalculationInput(
            measured: 100,
            unit: EthanolUnit.milligramPerDeciliter,
            hoursBetweenEventAndSampling: 1,
          ),
        ),
        throwsA(isA<CalcInputException>()),
      );
      // 8,5 g/L = 8,06 ‰ > 8 ‰.
      expect(
        () => b.calculate(
          const BackCalculationInput(
            measured: 8.5,
            unit: EthanolUnit.gramPerLiter,
            hoursBetweenEventAndSampling: 1,
          ),
        ),
        throwsA(isA<CalcInputException>()),
      );
    });
  });

  group('Henssge: formula varianti', () {
    test('Ta ≤ 23 va > 23 °C uchun koeffitsientlar', () {
      expect(HenssgeCalculator.usesHighAmbientFormula(23), isFalse);
      expect(HenssgeCalculator.usesHighAmbientFormula(23.1), isTrue);
    });
    test('qo‘lda hisob: Tr 30, Ta 15, 70 kg → ≈ 9,7 soat', () {
      final r = const HenssgeCalculator().calculate(
        const HenssgeInput(rectalTempC: 30, ambientTempC: 15, bodyWeightKg: 70),
      );
      expect(r.value.q, closeTo(15 / 22.2, 1e-12));
      expect(r.value.hours, closeTo(9.7, 0.1));
    });
  });
}
