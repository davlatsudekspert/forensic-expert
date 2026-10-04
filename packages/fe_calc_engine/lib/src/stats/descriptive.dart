import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../calculator.dart';

@immutable
class DescriptiveStats {
  const DescriptiveStats({
    required this.n,
    required this.mean,
    required this.median,
    required this.min,
    required this.max,
    this.sd,
    this.cvPercent,
  });

  final int n;
  final double mean;
  final double median;
  final double min;
  final double max;

  /// Tanlanma standart og‘ishi (n − 1). n < 2 bo‘lsa `null`.
  final double? sd;

  /// CV% = SD / |o‘rtacha| × 100. O‘rtacha 0 bo‘lsa `null`.
  final double? cvPercent;
}

/// O‘rtacha, mediana, SD (n − 1), CV%. **Ta’rifiy** statistika.
class DescriptiveStatsCalculator
    implements Calculator<List<double>, DescriptiveStats> {
  const DescriptiveStatsCalculator();

  static const _descriptor = CalculatorDescriptor(
    id: 'stats.descriptive',
    engineVersion: '1.0.0',
    formulaLatex: r's = \sqrt{\tfrac{\sum (x_i-\bar x)^2}{n-1}},\; CV = \tfrac{s}{\bar x}\cdot 100',
    nameKey: 'calc.stats.name',
    assumptionKeys: ['calc.stats.assumption.sample_sd'],
    limitationKeys: ['calc.stats.limitation.no_outlier_test'],
    referenceSourceIds: [],
    reviewState: CalculatorReviewState.needsReview,
    isDefinitional: true,
  );

  @override
  CalculatorDescriptor get descriptor => _descriptor;

  @override
  CalcResult<DescriptiveStats> calculate(List<double> xs) {
    if (xs.isEmpty) throw CalcInputException('values_required');
    if (xs.any((x) => !x.isFinite)) throw CalcInputException('finite_required');
    final n = xs.length;
    final mean = xs.reduce((a, b) => a + b) / n;
    final sorted = [...xs]..sort();
    final median = n.isOdd
        ? sorted[n ~/ 2]
        : (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2;
    double? sd;
    double? cv;
    final warnings = <CalcWarning>[];
    if (n >= 2) {
      final ss = xs.fold<double>(0, (a, x) => a + (x - mean) * (x - mean));
      sd = math.sqrt(ss / (n - 1));
      if (mean != 0) cv = sd / mean.abs() * 100;
    } else {
      warnings.add(const CalcWarning('sd_requires_two_values'));
    }
    return CalcResult(
      DescriptiveStats(
        n: n,
        mean: mean,
        median: median,
        min: sorted.first,
        max: sorted.last,
        sd: sd,
        cvPercent: cv,
      ),
      warnings: warnings,
    );
  }
}

/// Matndan qiymatlar ro‘yxati (vergul, nuqta-vergul, bo‘shliq yoki qator).
/// O‘nlik vergul (`1,5`) faqat ajratuvchi `;` yoki qator bo‘lsa.
List<double> parseValues(String text) {
  final normalized = text.contains(';') || text.contains('\n')
      ? text.replaceAll(',', '.')
      : text;
  return [
    for (final p in normalized.split(RegExp(r'[;\s,]+')))
      if (p.trim().isNotEmpty) double.parse(p.trim()),
  ];
}
