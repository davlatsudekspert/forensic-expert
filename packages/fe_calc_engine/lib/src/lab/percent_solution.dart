import 'package:meta/meta.dart';

import '../calculator.dart';

/// Foiz ifodasi turi (ta’rif bo‘yicha).
enum PercentBasis {
  /// % (w/v): 100 mL eritmadagi erigan modda grammlari.
  weightPerVolume,

  /// % (v/v): 100 mL eritmadagi erigan modda millilitrlari.
  volumePerVolume,

  /// % (w/w): 100 g eritmadagi erigan modda grammlari.
  weightPerWeight,
}

@immutable
class PercentSolutionInput {
  const PercentSolutionInput({
    required this.basis,
    required this.percent,
    required this.totalAmount,
  });

  final PercentBasis basis;

  /// 0 < % ≤ 100.
  final double percent;

  /// Jami eritma: w/v va v/v — mL; w/w — g.
  final double totalAmount;
}

@immutable
class PercentSolutionOutput {
  const PercentSolutionOutput(this.soluteAmount, this.soluteUnit);

  final double soluteAmount;

  /// `g` yoki `mL`.
  final String soluteUnit;
}

/// Erigan modda miqdori = % × jami / 100. **Ta’rifiy** hisob; qaysi foiz
/// turi ishlatilishi va tayyorlash tartibi — faqat manba yoki SOP’dan.
class PercentSolutionCalculator
    implements Calculator<PercentSolutionInput, PercentSolutionOutput> {
  const PercentSolutionCalculator();

  static const _descriptor = CalculatorDescriptor(
    id: 'lab.percent.solute_amount',
    engineVersion: '1.0.0',
    formulaLatex: r'x = \frac{\% \cdot total}{100}',
    nameKey: 'calc.percent.name',
    assumptionKeys: ['calc.percent.assumption.definition'],
    limitationKeys: [
      'calc.percent.limitation.basis',
      'calc.solution.limitation.not_a_recipe',
    ],
    referenceSourceIds: [],
    reviewState: CalculatorReviewState.needsReview,
    isDefinitional: true,
  );

  @override
  CalculatorDescriptor get descriptor => _descriptor;

  @override
  CalcResult<PercentSolutionOutput> calculate(PercentSolutionInput input) {
    if (!input.percent.isFinite || input.percent <= 0 || input.percent > 100) {
      throw CalcInputException('percent_out_of_range', 'percent');
    }
    if (!input.totalAmount.isFinite || input.totalAmount <= 0) {
      throw CalcInputException('positive_required', 'total');
    }
    final x = input.percent * input.totalAmount / 100;
    return CalcResult(
      PercentSolutionOutput(
        x,
        input.basis == PercentBasis.volumePerVolume ? 'mL' : 'g',
      ),
    );
  }
}
