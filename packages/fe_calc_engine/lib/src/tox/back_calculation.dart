import 'package:meta/meta.dart';

import '../calculator.dart';

@immutable
class BackCalculationInput {
  const BackCalculationInput({
    required this.measuredPromille,
    required this.hoursBetweenEventAndSampling,
    this.hoursFromDrinkingEndToEvent,
  });

  /// Qonda o‘lchangan konsentratsiya, ‰ (g/kg).
  final double measuredPromille;

  /// Hodisa → qon olish orasidagi vaqt, soat.
  final double hoursBetweenEventAndSampling;

  /// Ichish tugashi → hodisa, soat (ma’lum bo‘lsa).
  final double? hoursFromDrinkingEndToEvent;
}

@immutable
class BackCalculationResult {
  const BackCalculationResult({
    required this.minPromille,
    required this.maxPromille,
    required this.absorptionPhaseRisk,
  });

  final double minPromille;
  final double maxPromille;

  /// Hodisa ichish tugaganidan 2 soat ichida — rezorbsiya tugamagan
  /// bo‘lishi mumkin, minimum qo‘shimchasiz olinadi.
  final bool absorptionPhaseRisk;
}

/// Teskari hisob: c₀ = c + β · Δt, β = 0,10…0,25 g/L/soat (Jones 2010).
class BackCalculationCalculator
    implements Calculator<BackCalculationInput, BackCalculationResult> {
  const BackCalculationCalculator();

  static const betaMin = 0.10;
  static const betaMax = 0.25;
  static const absorptionHours = 2.0;

  static const _descriptor = CalculatorDescriptor(
    id: 'tox.ethanol.back_calculation',
    engineVersion: '1.0.0',
    formulaLatex: r'c_0 = c_t + \beta \cdot \Delta t',
    nameKey: 'calc.backcalc.name',
    assumptionKeys: [
      'calc.backcalc.assumption.linear',
      'calc.backcalc.assumption.beta',
    ],
    limitationKeys: ['calc.backcalc.limitation.absorption'],
    referenceSourceIds: ['jones-2010-fsi', 'widmark-1932'],
    reviewState: CalculatorReviewState.needsReview,
  );

  @override
  CalculatorDescriptor get descriptor => _descriptor;

  @override
  CalcResult<BackCalculationResult> calculate(BackCalculationInput input) {
    final c = input.measuredPromille;
    if (!c.isFinite || c < 0 || c > 8) {
      throw CalcInputException('bac_out_of_range', 'bac');
    }
    final dt = input.hoursBetweenEventAndSampling;
    if (!dt.isFinite || dt < 0 || dt > 24) {
      throw CalcInputException('time_out_of_range', 'time');
    }
    final de = input.hoursFromDrinkingEndToEvent;
    if (de != null && (!de.isFinite || de < 0 || de > 72)) {
      throw CalcInputException('time_out_of_range', 'drinking_end');
    }
    final risk = de != null && de < absorptionHours;
    final minC = risk ? c : c + betaMin * dt;
    final maxC = c + betaMax * dt;
    return CalcResult(
      BackCalculationResult(
        minPromille: minC,
        maxPromille: maxC,
        absorptionPhaseRisk: risk,
      ),
      warnings: [
        if (risk) const CalcWarning('absorption_phase'),
        if (c == 0) const CalcWarning('zero_measured'),
      ],
    );
  }
}
