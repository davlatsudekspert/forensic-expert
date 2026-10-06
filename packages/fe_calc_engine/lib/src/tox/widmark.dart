import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../calculator.dart';

enum BiologicalSex { male, female }

/// Etanol zichligi, g/mL (20 °C).
const double ethanolDensityGPerMl = 0.789;

/// Ichimlik: hajm (mL) va spirt ulushi (% v/v).
@immutable
class Drink {
  const Drink({required this.volumeMl, required this.abvPercent});

  final double volumeMl;
  final double abvPercent;

  double get ethanolGrams => volumeMl * abvPercent / 100 * ethanolDensityGPerMl;
}

@immutable
class WidmarkInput {
  const WidmarkInput({
    required this.sex,
    required this.bodyWeightKg,
    required this.drinks,
    required this.hoursSinceDrinkingStart,
    this.heightCm,
  });

  final BiologicalSex sex;
  final double bodyWeightKg;
  final List<Drink> drinks;
  final double hoursSinceDrinkingStart;

  /// Berilsa — r Seidl (2000) bo‘yicha; aks holda Widmark o‘rtacha qiymati.
  final double? heightCm;
}

@immutable
class WidmarkResult {
  const WidmarkResult({
    required this.ethanolGrams,
    required this.r,
    required this.rFromHeight,
    required this.minPromille,
    required this.maxPromille,
    required this.peakPromille,
  });

  final double ethanolGrams;
  final double r;
  final bool rFromHeight;

  /// 30 % rezorbsiya defitsiti, β = 0,20 ‰/soat.
  final double minPromille;

  /// 10 % rezorbsiya defitsiti, β = 0,10 ‰/soat.
  final double maxPromille;

  /// Defitsitsiz, eliminatsiyasiz nazariy cho‘qqi: A / (m · r).
  final double peakPromille;
}

/// Widmark: c = A·(1 − d) / (m · r) − β · t.
///
/// Diapazon sud-tibbiy amaliyotdagi chegaraviy qiymatlar bilan:
/// minimum — d = 30 %, β = 0,20 ‰/soat; maksimum — d = 10 %,
/// β = 0,10 ‰/soat. r: Widmark (erkak 0,7; ayol 0,6) yoki bo‘y berilsa
/// Seidl va boshq. (2000).
class WidmarkCalculator implements Calculator<WidmarkInput, WidmarkResult> {
  const WidmarkCalculator();

  static const rMale = 0.7;
  static const rFemale = 0.6;
  static const deficitMin = 0.10;
  static const deficitMax = 0.30;
  static const betaLow = 0.10;
  static const betaHigh = 0.20;

  static const _descriptor = CalculatorDescriptor(
    id: 'tox.ethanol.widmark',
    engineVersion: '1.0.0',
    formulaLatex: r'c = \frac{A (1 - d)}{m \cdot r} - \beta t',
    nameKey: 'calc.widmark.name',
    assumptionKeys: [
      'calc.widmark.assumption.deficit',
      'calc.widmark.assumption.beta',
    ],
    limitationKeys: ['calc.widmark.limitation.estimate'],
    referenceSourceIds: ['widmark-1932', 'seidl-2000-ijlm', 'jones-2010-fsi'],
    reviewState: CalculatorReviewState.needsReview,
  );

  @override
  CalculatorDescriptor get descriptor => _descriptor;

  /// Seidl S., Jensen U., Alt A. (2000) Int J Legal Med 114:71–77.
  static double seidlR(
    BiologicalSex sex,
    double weightKg,
    double heightCm,
  ) => switch (sex) {
    BiologicalSex.male => 0.31608 - 0.004821 * weightKg + 0.004632 * heightCm,
    BiologicalSex.female => 0.31223 - 0.006446 * weightKg + 0.004466 * heightCm,
  };

  @override
  CalcResult<WidmarkResult> calculate(WidmarkInput input) {
    final m = input.bodyWeightKg;
    if (!m.isFinite || m < 20 || m > 300) {
      throw CalcInputException('weight_out_of_range', 'weight');
    }
    final t = input.hoursSinceDrinkingStart;
    if (!t.isFinite || t < 0 || t > 72) {
      throw CalcInputException('time_out_of_range', 'time');
    }
    if (input.drinks.isEmpty) {
      throw CalcInputException('positive_required', 'volume');
    }
    for (final d in input.drinks) {
      if (!d.volumeMl.isFinite || d.volumeMl <= 0) {
        throw CalcInputException('positive_required', 'volume');
      }
      if (!d.abvPercent.isFinite || d.abvPercent <= 0 || d.abvPercent > 100) {
        throw CalcInputException('abv_out_of_range', 'abv');
      }
    }
    final h = input.heightCm;
    double r;
    var fromHeight = false;
    if (h != null) {
      if (!h.isFinite || h < 120 || h > 230) {
        throw CalcInputException('height_out_of_range', 'height');
      }
      r = seidlR(input.sex, m, h);
      fromHeight = true;
    } else {
      r = input.sex == BiologicalSex.male ? rMale : rFemale;
    }
    final a = input.drinks.fold<double>(0, (s, d) => s + d.ethanolGrams);
    final peak = a / (m * r);
    final minC = math.max(0.0, a * (1 - deficitMax) / (m * r) - betaHigh * t);
    final maxC = math.max(0.0, a * (1 - deficitMin) / (m * r) - betaLow * t);
    final warnings = <CalcWarning>[
      if (fromHeight && (r < 0.45 || r > 0.85))
        CalcWarning('r_unusual', {'r': r}),
      if (maxC == 0) const CalcWarning('fully_eliminated'),
    ];
    return CalcResult(
      WidmarkResult(
        ethanolGrams: a,
        r: r,
        rFromHeight: fromHeight,
        minPromille: minC,
        maxPromille: maxC,
        peakPromille: peak,
      ),
      warnings: warnings,
    );
  }
}
