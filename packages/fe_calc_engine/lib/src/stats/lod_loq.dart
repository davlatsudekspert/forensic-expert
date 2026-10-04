import 'package:meta/meta.dart';

import '../calculator.dart';

/// σ qaysi usulda baholangan (ICH Q2(R2) §3.2.3.3; Q2(R1) 6.3.2 bilan bir xil).
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
/// Manba: ICH Q2(R2) «Validation of Analytical Procedures» (2023-11-01
/// qabul qilingan), §3.2.3.3 «Based on the Standard Deviation of a Linear
/// Response and a Slope» — rasmiy PDF matni bilan solishtirildi
/// (`STD-ICH-Q2R2`). Koeffitsientlar Q2(R1) 6.3/7.3 bilan bir xil; Q2(R1)
/// endi almashtirilgan (`STD-ICH-Q2R1`, superseded). Tahlil: `docs/28`.
///
/// Bu bir nechta qabul qilingan yondashuvdan **biri** (vizual baho,
/// signal/shovqin, QL ni aniqlik va pretsizlik bilan bevosita tasdiqlash —
/// Q2(R2) §3.2.3.4 ham bor); hisoblangan qiymat mustaqil tahlil bilan
/// tasdiqlanishi kerak. Q2(R2) farmatsevtik doirada — forensik metodga
/// qo‘llash laboratoriya qarori. RG-25: lab reviewer tasdig‘i kerak.
class LodLoqCalculator implements Calculator<LodLoqInput, LodLoqResult> {
  const LodLoqCalculator();

  /// ICH Q2(R2) §3.2.3.3 koeffitsientlari (Q2(R1) 6.3/7.3 bilan bir xil).
  static const lodFactor = 3.3;
  static const loqFactor = 10.0;

  static const _descriptor = CalculatorDescriptor(
    id: 'stats.lod_loq.ich',
    engineVersion: '1.1.0',
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
    referenceSourceIds: ['STD-ICH-Q2R2'],
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
