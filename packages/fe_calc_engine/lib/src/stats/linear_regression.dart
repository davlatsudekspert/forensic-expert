import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../calculator.dart';

@immutable
class RegressionResult {
  const RegressionResult({
    required this.n,
    required this.slope,
    required this.intercept,
    required this.rSquared,
    required this.residualSd,
    required this.slopeSe,
    required this.interceptSe,
  });

  final int n;
  final double slope;
  final double intercept;
  final double rSquared;

  /// s_y/x = √(Σ(yᵢ − ŷᵢ)² / (n − 2)).
  final double residualSd;
  final double slopeSe;
  final double interceptSe;
}

/// Eng kichik kvadratlar (OLS) chiziqli regressiyasi: y = a + b·x.
/// **Ta’rifiy** statistika — kalibrlash modeli tanlovi (vazn, chiziqlilik
/// diapazoni) laboratoriya validatsiyasiga tegishli.
class LinearRegressionCalculator
    implements Calculator<List<(double, double)>, RegressionResult> {
  const LinearRegressionCalculator();

  static const _descriptor = CalculatorDescriptor(
    id: 'stats.linear_regression',
    engineVersion: '1.0.0',
    formulaLatex: r'y = a + b x,\; b = \tfrac{\sum (x-\bar x)(y-\bar y)}{\sum (x-\bar x)^2}',
    nameKey: 'calc.regression.name',
    assumptionKeys: [
      'calc.regression.assumption.ols',
      'calc.regression.assumption.unweighted',
    ],
    limitationKeys: ['calc.regression.limitation.range'],
    referenceSourceIds: [],
    reviewState: CalculatorReviewState.needsReview,
    isDefinitional: true,
  );

  @override
  CalculatorDescriptor get descriptor => _descriptor;

  @override
  CalcResult<RegressionResult> calculate(List<(double, double)> pts) {
    if (pts.length < 3) throw CalcInputException('three_points_required');
    if (pts.any((p) => !p.$1.isFinite || !p.$2.isFinite)) {
      throw CalcInputException('finite_required');
    }
    final n = pts.length;
    final mx = pts.fold<double>(0, (a, p) => a + p.$1) / n;
    final my = pts.fold<double>(0, (a, p) => a + p.$2) / n;
    var sxx = 0.0, sxy = 0.0, syy = 0.0;
    for (final (x, y) in pts) {
      sxx += (x - mx) * (x - mx);
      sxy += (x - mx) * (y - my);
      syy += (y - my) * (y - my);
    }
    if (sxx == 0) throw CalcInputException('x_values_identical');
    final b = sxy / sxx;
    final a = my - b * mx;
    var sse = 0.0;
    for (final (x, y) in pts) {
      final r = y - (a + b * x);
      sse += r * r;
    }
    final syx = math.sqrt(sse / (n - 2));
    final r2 = syy == 0 ? 1.0 : 1 - sse / syy;
    final sumX2 = pts.fold<double>(0, (acc, p) => acc + p.$1 * p.$1);
    return CalcResult(
      RegressionResult(
        n: n,
        slope: b,
        intercept: a,
        rSquared: r2,
        residualSd: syx,
        slopeSe: syx / math.sqrt(sxx),
        interceptSe: syx * math.sqrt(sumX2 / (n * sxx)),
      ),
      warnings: [if (n < 5) const CalcWarning('few_calibration_points')],
    );
  }
}
