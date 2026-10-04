import 'package:meta/meta.dart';

import '../calculator.dart';

/// σ qaysi usulda baholangan (ICH Q2(R1) 6.3.1 / 6.3.2).
enum SigmaBasis { blankSd, residualSd, interceptSd }

@immutable
class LodLoqInput {
  const LodLoqInput({
    required this.sigma,
    required this.slope,
    required this.sigmaBasis,
  });

  /// Javob (signal) standart og‘ishi σ.
  final double sigma;

  /// Kalibrlash egri chizig‘i qiyaligi S.
  final double slope;
  final SigmaBasis sigmaBasis;
}

@immutable
class LodLoqResult {
  const LodLoqResult(this.lod, this.loq);

  /// Konsentratsiya birligida (kalibrlash x o‘qi bilan bir xil).
  final double lod;
  final double loq;
}

/// DL = 3.3 σ / S, QL = 10 σ / S.
///
/// Manba: ICH Q2(R1) «Validation of Analytical Procedures: Text and
/// Methodology», 6.3 va 7.3-bo‘limlar (rasmiy PDF matni bilan solishtirildi,
/// `SRC-ICH-Q2R1`). Bu bir nechta qabul qilingan yondashuvdan **biri**
/// (vizual baho, signal/shovqin ham bor); hisoblangan qiymat mustaqil
/// tahlil bilan tasdiqlanishi kerak. Q2(R2) bilan moslik — reviewer
/// tasdig‘i kerak.
class LodLoqCalculator implements Calculator<LodLoqInput, LodLoqResult> {
  const LodLoqCalculator();

  /// ICH Q2(R1) koeffitsientlari (6.3, 7.3) — manbali.
  static const lodFactor = 3.3;
  static const loqFactor = 10.0;

  static const _descriptor = CalculatorDescriptor(
    id: 'stats.lod_loq.ich',
    engineVersion: '1.0.0',
    formulaLatex: r'DL = \tfrac{3.3\,\sigma}{S},\; QL = \tfrac{10\,\sigma}{S}',
    nameKey: 'calc.lodloq.name',
    assumptionKeys: [
      'calc.lodloq.assumption.sigma',
      'calc.lodloq.assumption.linear',
    ],
    limitationKeys: [
      'calc.lodloq.limitation.one_approach',
      'calc.lodloq.limitation.verify',
    ],
    referenceSourceIds: ['SRC-ICH-Q2R1'],
    reviewState: CalculatorReviewState.needsReview,
  );

  @override
  CalculatorDescriptor get descriptor => _descriptor;

  @override
  CalcResult<LodLoqResult> calculate(LodLoqInput input) {
    if (!input.sigma.isFinite || input.sigma <= 0) {
      throw CalcInputException('positive_required', 'sigma');
    }
    if (!input.slope.isFinite || input.slope == 0) {
      throw CalcInputException('nonzero_slope_required', 'slope');
    }
    final s = input.slope.abs();
    return CalcResult(
      LodLoqResult(lodFactor * input.sigma / s, loqFactor * input.sigma / s),
    );
  }
}
