import 'package:meta/meta.dart';

import '../calculator.dart';
import '../units.dart';

@immutable
class MolarityInput {
  const MolarityInput({
    required this.mass,
    required this.molarMassGPerMol,
    required this.volume,
    this.purityFraction = 1,
  });

  final Quantity mass;
  final double molarMassGPerMol;
  final Quantity volume;

  /// 0 < p ≤ 1, sertifikatdan.
  final double purityFraction;
}

/// c = m · p / (M · V) — tortilgan massadan molyar konsentratsiya.
/// **Ta’rifiy** hisob; retsept emas.
class MolarityCalculator implements Calculator<MolarityInput, Quantity> {
  const MolarityCalculator();

  static const _descriptor = CalculatorDescriptor(
    id: 'lab.molarity.from_mass',
    engineVersion: '1.0.0',
    formulaLatex: r'c = \frac{m \cdot p}{M \cdot V}',
    nameKey: 'calc.molarity.name',
    assumptionKeys: ['calc.molarity.assumption.definition'],
    limitationKeys: ['calc.solution.limitation.not_a_recipe'],
    referenceSourceIds: [],
    reviewState: CalculatorReviewState.needsReview,
    isDefinitional: true,
  );

  @override
  CalculatorDescriptor get descriptor => _descriptor;

  @override
  CalcResult<Quantity> calculate(MolarityInput input) {
    if (input.mass.unit.dimension != Dimension.mass) {
      throw CalcInputException('mass_unit_required', 'mass');
    }
    if (input.volume.unit.dimension != Dimension.volume) {
      throw CalcInputException('volume_unit_required', 'volume');
    }
    for (final (name, v) in [
      ('mass', input.mass.value),
      ('molar_mass', input.molarMassGPerMol),
      ('volume', input.volume.value),
    ]) {
      if (!v.isFinite || v <= 0) {
        throw CalcInputException('positive_required', name);
      }
    }
    final p = input.purityFraction;
    if (!p.isFinite || p <= 0 || p > 1) {
      throw CalcInputException('purity_out_of_range', 'purity');
    }
    final molPerL =
        input.mass.canonicalValue *
        p /
        (input.molarMassGPerMol * input.volume.canonicalValue);
    return CalcResult(Quantity(molPerL, Unit.molePerLiter));
  }
}
