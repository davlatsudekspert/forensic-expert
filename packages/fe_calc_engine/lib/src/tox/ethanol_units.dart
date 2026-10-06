import 'package:meta/meta.dart';

import '../calculator.dart';

/// Etanol konsentratsiyasi birliklari.
enum EthanolUnit {
  /// ‰ — g/kg (Germaniya, MDH, O‘zbekiston amaliyoti).
  promille('‰'),
  gramPerLiter('g/L'),
  milligramPerDeciliter('mg/dL'),

  /// % BAC — g/100 mL (AQSh).
  percentBac('% BAC'),
  millimolePerLiter('mmol/L');

  const EthanolUnit(this.symbol);
  final String symbol;
}

enum EthanolMatrix { wholeBlood, serum }

@immutable
class EthanolUnitsInput {
  const EthanolUnitsInput({
    required this.value,
    required this.unit,
    this.matrix = EthanolMatrix.wholeBlood,
    this.serumBloodRatio = EthanolUnitsCalculator.defaultSerumBloodRatio,
    this.bloodDensity = EthanolUnitsCalculator.defaultBloodDensity,
  });

  final double value;
  final EthanolUnit unit;
  final EthanolMatrix matrix;
  final double serumBloodRatio;
  final double bloodDensity;
}

@immutable
class EthanolUnitsResult {
  const EthanolUnitsResult({required this.wholeBlood, this.serum});

  /// To‘liq qon uchun barcha birliklarda.
  final Map<EthanolUnit, double> wholeBlood;

  /// Kirish zardob bo‘lsa — zardobdagi qiymat (g/L).
  final double? serum;
}

/// ‰ ↔ g/L ↔ mg/dL ↔ % BAC ↔ mmol/L; zardob → to‘liq qon.
/// g/L = ‰ · ρ(qon); mmol/L = g/L / 46,07 · 1000.
class EthanolUnitsCalculator
    implements Calculator<EthanolUnitsInput, EthanolUnitsResult> {
  const EthanolUnitsCalculator();

  static const molarMass = 46.07;
  static const defaultBloodDensity = 1.055;
  static const defaultSerumBloodRatio = 1.2;

  static const _descriptor = CalculatorDescriptor(
    id: 'tox.ethanol.units',
    engineVersion: '1.0.0',
    formulaLatex:
        r'\rho_{g/L} = c_{‰} \cdot \rho_{blood};\ c_{blood} = c_{serum} / Q',
    nameKey: 'calc.ethanolunits.name',
    assumptionKeys: [
      'calc.ethanolunits.assumption.density',
      'calc.ethanolunits.assumption.ratio',
    ],
    limitationKeys: ['calc.ethanolunits.limitation.ratio'],
    referenceSourceIds: ['rainey-1993-clinchem'],
    reviewState: CalculatorReviewState.needsReview,
  );

  @override
  CalculatorDescriptor get descriptor => _descriptor;

  static double toGramPerLiter(double v, EthanolUnit u, double density) =>
      switch (u) {
        EthanolUnit.promille => v * density,
        EthanolUnit.gramPerLiter => v,
        EthanolUnit.milligramPerDeciliter => v / 100,
        EthanolUnit.percentBac => v * 10,
        EthanolUnit.millimolePerLiter => v * molarMass / 1000,
      };

  static double fromGramPerLiter(double gL, EthanolUnit u, double density) =>
      switch (u) {
        EthanolUnit.promille => gL / density,
        EthanolUnit.gramPerLiter => gL,
        EthanolUnit.milligramPerDeciliter => gL * 100,
        EthanolUnit.percentBac => gL / 10,
        EthanolUnit.millimolePerLiter => gL / molarMass * 1000,
      };

  @override
  CalcResult<EthanolUnitsResult> calculate(EthanolUnitsInput input) {
    if (!input.value.isFinite || input.value < 0) {
      throw CalcInputException('positive_required', 'value');
    }
    final q = input.serumBloodRatio;
    if (!q.isFinite || q < 1.0 || q > 1.5) {
      throw CalcInputException('ratio_out_of_range', 'ratio');
    }
    final rho = input.bloodDensity;
    if (!rho.isFinite || rho < 1.0 || rho > 1.1) {
      throw CalcInputException('density_out_of_range', 'density');
    }
    // Zardob uchun ‰ ishlatilmaydi — kirish g/L ekvivalenti sifatida olinadi
    // (zardob zichligi ≈ 1,0 g/mL ga yaqin, ‰ ≈ g/L).
    final inputDensity = input.matrix == EthanolMatrix.serum ? 1.0 : rho;
    final gL = toGramPerLiter(input.value, input.unit, inputDensity);
    final bloodGL = input.matrix == EthanolMatrix.serum ? gL / q : gL;
    return CalcResult(
      EthanolUnitsResult(
        wholeBlood: {
          for (final u in EthanolUnit.values)
            u: fromGramPerLiter(bloodGL, u, rho),
        },
        serum: input.matrix == EthanolMatrix.serum ? gL : null,
      ),
    );
  }
}
