import 'package:meta/meta.dart';

import '../calculator.dart';
import '../units.dart';

/// Eritma tayyorlash uchun kerakli modda massasi.
@immutable
class SolutionPreparationInput {
  const SolutionPreparationInput({
    required this.targetConcentration,
    required this.finalVolume,
    this.molarMassGPerMol,
    this.purityFraction = 1,
  });

  /// Massa (g/L…) yoki molyar (mol/L…) konsentratsiya.
  final Quantity targetConcentration;
  final Quantity finalVolume;

  /// Faqat molyar konsentratsiya uchun. **Foydalanuvchi kiritadi** (yoki
  /// sertifikat/yorliqdan) — kalkulyator hech qachon taxmin qilmaydi.
  final double? molarMassGPerMol;

  /// Moddaning tozaligi (0 < p ≤ 1), sertifikatdan. Standart — 1.
  final double purityFraction;
}

@immutable
class SolutionPreparationOutput {
  const SolutionPreparationOutput(this.mass);

  final Quantity mass;
}

/// m = C·V / p (massa konsentratsiyasi) yoki m = C·V·M / p (molyar).
///
/// Bu **ta’rifiy** hisob (konsentratsiya ta’rifi). U reagent retsepti
/// emas: qaysi moddani, qanday tozalikda, qanday tartibda va qanday
/// saqlash shartlarida tayyorlash — faqat tasdiqlangan manba yoki
/// institut SOP’dan. Natija laboratoriya validatsiyasi o‘rnini bosmaydi.
class SolutionPreparationCalculator
    implements Calculator<SolutionPreparationInput, SolutionPreparationOutput> {
  const SolutionPreparationCalculator();

  static const _descriptor = CalculatorDescriptor(
    id: 'lab.solution.mass_required',
    engineVersion: '1.0.0',
    formulaLatex: r'm = \frac{C \cdot V \,(\cdot M)}{p}',
    nameKey: 'calc.solution.name',
    assumptionKeys: [
      'calc.solution.assumption.definition',
      'calc.solution.assumption.user_supplied_molar_mass_and_purity',
    ],
    limitationKeys: [
      'calc.solution.limitation.not_a_recipe',
      'calc.solution.limitation.no_volume_change_on_dissolution',
    ],
    referenceSourceIds: [],
    reviewState: CalculatorReviewState.needsReview,
    isDefinitional: true,
  );

  @override
  CalculatorDescriptor get descriptor => _descriptor;

  @override
  CalcResult<SolutionPreparationOutput> calculate(
    SolutionPreparationInput input,
  ) {
    final c = input.targetConcentration;
    final v = input.finalVolume;
    if (v.unit.dimension != Dimension.volume) {
      throw CalcInputException('volume_unit_required', 'finalVolume');
    }
    if (c.unit.dimension != Dimension.massConcentration &&
        c.unit.dimension != Dimension.molarConcentration) {
      throw CalcInputException(
        'concentration_unit_required',
        'targetConcentration',
      );
    }
    for (final (name, value) in [
      ('targetConcentration', c.value),
      ('finalVolume', v.value),
      ('purityFraction', input.purityFraction),
    ]) {
      if (!value.isFinite || value <= 0) {
        throw CalcInputException('must_be_positive', name);
      }
    }
    if (input.purityFraction > 1) {
      throw CalcInputException('purity_out_of_range', 'purityFraction');
    }

    // Kanonik: g/L yoki mol/L × L.
    var grams = c.canonicalValue * v.canonicalValue;
    if (c.unit.dimension == Dimension.molarConcentration) {
      final m = input.molarMassGPerMol;
      if (m == null) {
        throw CalcInputException('molar_mass_required', 'molarMassGPerMol');
      }
      if (!m.isFinite || m <= 0) {
        throw CalcInputException('must_be_positive', 'molarMassGPerMol');
      }
      grams *= m;
    }
    grams /= input.purityFraction;

    final unit = grams >= 1
        ? Unit.gram
        : grams >= 1e-3
        ? Unit.milligram
        : Unit.microgram;
    final warnings = <CalcWarning>[
      if (input.purityFraction < 1)
        const CalcWarning('purity_correction_applied'),
    ];
    return CalcResult(
      SolutionPreparationOutput(Quantity(grams / unit.toCanonical, unit)),
      warnings: warnings,
    );
  }
}
