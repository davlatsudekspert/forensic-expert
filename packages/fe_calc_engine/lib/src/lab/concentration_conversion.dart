import 'package:meta/meta.dart';

import '../calculator.dart';
import '../units.dart';

@immutable
class ConcentrationConversionInput {
  const ConcentrationConversionInput({
    required this.value,
    required this.target,
    this.molarMassGPerMol,
  });

  final Quantity value;
  final Unit target;

  /// Massa ↔ molyar o‘tishda majburiy. Foydalanuvchi kiritadi (sertifikat
  /// yoki tekshirilgan identifikatsiya ma’lumotidan) — taxmin qilinmaydi.
  final double? molarMassGPerMol;
}

/// Konsentratsiya birliklari (mg/L ↔ µg/mL ↔ ng/mL …) va massa ↔ molyar
/// konsentratsiya: ρ = c · M.
///
/// **Ta’rifiy** hisob: SI prefikslari va molyar massa ta’rifi. Hech qanday
/// ilmiy koeffitsient yo‘q.
class ConcentrationConversionCalculator
    implements Calculator<ConcentrationConversionInput, Quantity> {
  const ConcentrationConversionCalculator();

  static const _descriptor = CalculatorDescriptor(
    id: 'lab.concentration.convert',
    engineVersion: '1.0.0',
    formulaLatex: r'\rho = c \cdot M',
    nameKey: 'calc.convert.name',
    assumptionKeys: ['calc.convert.assumption.definition'],
    limitationKeys: ['calc.convert.limitation.molar_mass_user'],
    referenceSourceIds: [],
    reviewState: CalculatorReviewState.needsReview,
    isDefinitional: true,
  );

  @override
  CalculatorDescriptor get descriptor => _descriptor;

  static bool _isConc(Dimension d) =>
      d == Dimension.massConcentration || d == Dimension.molarConcentration;

  @override
  CalcResult<Quantity> calculate(ConcentrationConversionInput input) {
    final from = input.value.unit.dimension;
    final to = input.target.dimension;
    if (!_isConc(from) || !_isConc(to)) {
      throw CalcInputException('concentration_unit_required');
    }
    if (!input.value.value.isFinite || input.value.value < 0) {
      throw CalcInputException('non_negative_required', 'value');
    }
    if (from == to) {
      return CalcResult(input.value.to(input.target));
    }
    final m = input.molarMassGPerMol;
    if (m == null || !m.isFinite || m <= 0) {
      throw CalcInputException('molar_mass_required', 'molar_mass');
    }
    // Kanonik: g/L va mol/L.
    final canonical = from == Dimension.molarConcentration
        ? input.value.canonicalValue *
              m // mol/L → g/L
        : input.value.canonicalValue / m; // g/L → mol/L
    return CalcResult(
      Quantity(canonical / input.target.toCanonical, input.target),
    );
  }
}
