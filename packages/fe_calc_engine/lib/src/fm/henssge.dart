import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../calculator.dart';

@immutable
class HenssgeInput {
  const HenssgeInput({
    required this.rectalTempC,
    required this.ambientTempC,
    required this.bodyWeightKg,
    this.correctiveFactor = 1.0,
  });

  final double rectalTempC;
  final double ambientTempC;
  final double bodyWeightKg;

  /// Kiyim/qoplama va muhit uchun tuzatish koeffitsienti (Henssge
  /// jadvali). 1,0 — yalang‘och, quruq, havo harakatsiz.
  final double correctiveFactor;
}

@immutable
class HenssgeResult {
  const HenssgeResult({
    required this.hours,
    required this.ci95Hours,
    required this.q,
    required this.b,
  });

  /// Taxminiy o‘limdan keyingi vaqt, soat.
  final double hours;

  /// 95 % ishonch chegarasi, ± soat.
  final double ci95Hours;
  final double q;
  final double b;
}

/// Henssge (1988) rektal harorat nomogrammasi tenglamasi:
/// Q = (Tr − Ta)/(37,2 − Ta)
/// Ta ≤ 23 °C: Q = 1,25·e^(Bt) − 0,25·e^(5Bt)
/// Ta > 23 °C: Q = 1,11·e^(Bt) − 0,11·e^(10Bt)
/// B = −1,2815·(c·m)^(−0,625) + 0,0284.
class HenssgeCalculator implements Calculator<HenssgeInput, HenssgeResult> {
  const HenssgeCalculator();

  static const normalTemp = 37.2;

  static const _descriptor = CalculatorDescriptor(
    id: 'fm.pmi.henssge',
    engineVersion: '1.0.0',
    formulaLatex:
        r'\frac{T_r - T_a}{37.2 - T_a} = 1.25 e^{Bt} - 0.25 e^{5Bt},\ '
        r'B = -1.2815 (c m)^{-0.625} + 0.0284',
    nameKey: 'calc.henssge.name',
    assumptionKeys: [
      'calc.henssge.assumption.normal_temp',
      'calc.henssge.assumption.constant_ambient',
    ],
    limitationKeys: ['calc.henssge.limitation.conditions'],
    referenceSourceIds: ['henssge-1988-fsi', 'henssge-2000-fsi'],
    reviewState: CalculatorReviewState.needsReview,
  );

  @override
  CalculatorDescriptor get descriptor => _descriptor;

  static double b(double c, double m) =>
      -1.2815 * math.pow(c * m, -0.625) + 0.0284;

  /// Ta > 23 °C da ikkinchi (1,11 / 0,11 / 10Bt) tenglama ishlatiladi.
  static bool usesHighAmbientFormula(double ambient) => ambient > 23;

  static double qAt(double t, double b, double ambient) =>
      !usesHighAmbientFormula(ambient)
      ? 1.25 * math.exp(b * t) - 0.25 * math.exp(5 * b * t)
      : 1.11 * math.exp(b * t) - 0.11 * math.exp(10 * b * t);

  @override
  CalcResult<HenssgeResult> calculate(HenssgeInput input) {
    final tr = input.rectalTempC, ta = input.ambientTempC;
    final m = input.bodyWeightKg, c = input.correctiveFactor;
    if (!m.isFinite || m < 1 || m > 250) {
      throw CalcInputException('weight_out_of_range', 'weight');
    }
    if (!c.isFinite || c < 0.3 || c > 3.0) {
      throw CalcInputException('factor_out_of_range', 'factor');
    }
    if (!ta.isFinite || ta < -20 || ta > 35) {
      throw CalcInputException('ambient_out_of_range', 'ambient');
    }
    if (!tr.isFinite || tr > 42 || tr <= ta) {
      throw CalcInputException('rectal_out_of_range', 'rectal');
    }
    final q = (tr - ta) / (normalTemp - ta);
    final bb = b(c, m);
    final warnings = <CalcWarning>[];
    double hours;
    if (q >= 1) {
      hours = 0;
      warnings.add(const CalcWarning('no_cooling'));
    } else {
      // Q(t) monoton kamayadi — bisektsiya.
      var lo = 0.0, hi = 200.0;
      if (qAt(hi, bb, ta) > q) {
        throw CalcInputException('out_of_model_range', 'rectal');
      }
      for (var i = 0; i < 100; i++) {
        final mid = (lo + hi) / 2;
        if (qAt(mid, bb, ta) > q) {
          lo = mid;
        } else {
          hi = mid;
        }
      }
      hours = (lo + hi) / 2;
    }
    final corrected = c != 1.0;
    final ci = corrected ? 4.5 : (ta <= 23 ? 2.8 : 3.2);
    if (q < 0.2) warnings.add(const CalcWarning('late_phase'));
    return CalcResult(
      HenssgeResult(hours: hours, ci95Hours: ci, q: q, b: bb),
      warnings: warnings,
    );
  }
}
