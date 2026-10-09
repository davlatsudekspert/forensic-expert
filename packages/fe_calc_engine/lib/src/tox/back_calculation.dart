import 'package:meta/meta.dart';

import '../calculator.dart';
import 'ethanol_units.dart';

@immutable
class BackCalculationInput {
  const BackCalculationInput({
    required this.measured,
    required this.hoursBetweenEventAndSampling,
    this.hoursFromDrinkingEndToEvent,
    this.unit = EthanolUnit.promille,
    this.bloodDensity = EthanolUnitsCalculator.defaultBloodDensity,
  });

  /// Qonda o‘lchangan konsentratsiya, [unit] birligida.
  final double measured;

  /// Faqat [EthanolUnit.promille] (g/kg) yoki [EthanolUnit.gramPerLiter].
  final EthanolUnit unit;

  /// ‰ ↔ g/L o‘tishi uchun qon zichligi, g/mL (etanol birliklari
  /// kalkulyatori bilan bir xil standart).
  final double bloodDensity;

  /// Hodisa → qon olish orasidagi vaqt, soat.
  final double hoursBetweenEventAndSampling;

  /// Ichish tugashi → hodisa, soat (ma’lum bo‘lsa).
  final double? hoursFromDrinkingEndToEvent;
}

@immutable
class BackCalculationResult {
  const BackCalculationResult({
    required this.min,
    required this.max,
    required this.unit,
    required this.absorptionPhaseRisk,
  });

  /// Kirish bilan bir xil birlikda.
  final double min;
  final double max;
  final EthanolUnit unit;

  /// Hodisa ichish tugaganidan 2 soat ichida — rezorbsiya tugamagan
  /// bo‘lishi mumkin, minimum qo‘shimchasiz olinadi.
  final bool absorptionPhaseRisk;
}

/// Teskari hisob: c₀ = c + β · Δt, β = 0,10…0,25 g/L/soat (Jones 2010:
/// 10–25 mg/100 mL/soat — massa/**hajm** birligi).
///
/// v1.1.0: kirish ‰ (g/kg) bo‘lsa, β qon zichligi ρ bilan ‰/soat ga
/// o‘tkaziladi (β‰ = β / ρ). v1.0.0 β ni ‰ ga to‘g‘ridan-to‘g‘ri qo‘shardi
/// (birlik aralashuvi, ~5 % ortiqcha).
class BackCalculationCalculator
    implements Calculator<BackCalculationInput, BackCalculationResult> {
  const BackCalculationCalculator();

  static const betaMin = 0.10;
  static const betaMax = 0.25;
  static const absorptionHours = 2.0;

  static const _descriptor = CalculatorDescriptor(
    id: 'tox.ethanol.back_calculation',
    engineVersion: '1.1.0',
    formulaLatex:
        r'c_0 = c_t + \beta \cdot \Delta t\ (\beta_{‰} = \beta / \rho)',
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
    final u = input.unit;
    if (u != EthanolUnit.promille && u != EthanolUnit.gramPerLiter) {
      throw CalcInputException('unit_not_supported', 'unit');
    }
    final rho = input.bloodDensity;
    if (!rho.isFinite || rho < 1.0 || rho > 1.1) {
      throw CalcInputException('density_out_of_range', 'density');
    }
    final c = input.measured;
    final promille = u == EthanolUnit.promille ? c : c / rho;
    if (!c.isFinite || c < 0 || promille > 8) {
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
    // β (g/L/soat) → kirish birligi.
    final k = u == EthanolUnit.promille ? 1 / rho : 1.0;
    final minC = risk ? c : c + betaMin * k * dt;
    final maxC = c + betaMax * k * dt;
    return CalcResult(
      BackCalculationResult(
        min: minC,
        max: maxC,
        unit: u,
        absorptionPhaseRisk: risk,
      ),
      warnings: [
        if (risk) const CalcWarning('absorption_phase'),
        if (c == 0) const CalcWarning('zero_measured'),
      ],
    );
  }
}
