import 'package:meta/meta.dart';

import '../calculator.dart';
import '../units.dart';

/// C1V1 = C2V2 da qaysi o‘zgaruvchi topiladi.
enum DilutionUnknown { c1, v1, c2, v2 }

/// Kirish: to‘rtta qiymatdan aynan bittasi `null` (noma’lum).
@immutable
class DilutionInput {
  const DilutionInput({this.c1, this.v1, this.c2, this.v2});

  final Quantity? c1;
  final Quantity? v1;
  final Quantity? c2;
  final Quantity? v2;
}

@immutable
class DilutionOutput {
  const DilutionOutput(this.unknown, this.result);

  final DilutionUnknown unknown;
  final Quantity result;
}

/// Eritish tenglamasi C1V1 = C2V2.
///
/// Bu **ta’rifiy (definitional)** munosabat — modda miqdorining saqlanishi.
/// Shunga qaramay, laboratoriya reviewer’i tasdiqlamaguncha holati
/// `needsReview`. PHASE 1 skeleti: kontrakt va arxitekturani ko‘rsatish
/// uchun yagona namunaviy kalkulyator.
class DilutionCalculator implements Calculator<DilutionInput, DilutionOutput> {
  const DilutionCalculator();

  static const _descriptor = CalculatorDescriptor(
    id: 'lab.dilution.c1v1',
    engineVersion: '1.0.0',
    formulaLatex: r'C_1 V_1 = C_2 V_2',
    nameKey: 'calc.dilution.name',
    assumptionKeys: [
      'calc.dilution.assumption.conservation',
      'calc.dilution.assumption.ideal_mixing',
    ],
    limitationKeys: ['calc.dilution.limitation.not_for_volume_contraction'],
    referenceSourceIds: [],
    reviewState: CalculatorReviewState.needsReview,
    isDefinitional: true,
  );

  @override
  CalculatorDescriptor get descriptor => _descriptor;

  @override
  CalcResult<DilutionOutput> calculate(DilutionInput input) {
    final values = {
      DilutionUnknown.c1: input.c1,
      DilutionUnknown.v1: input.v1,
      DilutionUnknown.c2: input.c2,
      DilutionUnknown.v2: input.v2,
    };
    final unknowns = values.entries.where((e) => e.value == null).toList();
    if (unknowns.length != 1) {
      throw CalcInputException('exactly_one_unknown_required');
    }
    for (final e in values.entries) {
      final q = e.value;
      if (q == null) continue;
      final expected =
          e.key == DilutionUnknown.c1 || e.key == DilutionUnknown.c2
          ? null
          : Dimension.volume;
      if (expected != null && q.unit.dimension != expected) {
        throw CalcInputException('volume_unit_required', e.key.name);
      }
      if (expected == null && q.unit.dimension == Dimension.volume) {
        throw CalcInputException('concentration_unit_required', e.key.name);
      }
      if (!q.value.isFinite || q.value <= 0) {
        throw CalcInputException('must_be_positive', e.key.name);
      }
    }
    if (input.c1 != null &&
        input.c2 != null &&
        input.c1!.unit.dimension != input.c2!.unit.dimension) {
      throw CalcInputException('concentration_dimensions_differ');
    }

    final unknown = unknowns.single.key;
    late final Quantity result;
    switch (unknown) {
      case DilutionUnknown.c1:
        // C1 = C2·V2 / V1
        final v =
            input.c2!.value *
            input.v2!.canonicalValue /
            input.v1!.canonicalValue;
        result = Quantity(v, input.c2!.unit);
      case DilutionUnknown.c2:
        final v =
            input.c1!.value *
            input.v1!.canonicalValue /
            input.v2!.canonicalValue;
        result = Quantity(v, input.c1!.unit);
      case DilutionUnknown.v1:
        // V1 = C2·V2 / C1 — natija V2 birligida.
        final ratio = input.c2!.canonicalValue / input.c1!.canonicalValue;
        result = Quantity(input.v2!.value * ratio, input.v2!.unit);
      case DilutionUnknown.v2:
        final ratio = input.c1!.canonicalValue / input.c2!.canonicalValue;
        result = Quantity(input.v1!.value * ratio, input.v1!.unit);
    }

    final warnings = <CalcWarning>[];
    final c1 = unknown == DilutionUnknown.c1 ? result : input.c1!;
    final c2 = unknown == DilutionUnknown.c2 ? result : input.c2!;
    if (c2.canonicalValue > c1.canonicalValue) {
      // Eritishda yakuniy konsentratsiya boshlang‘ichdan katta bo‘lmaydi.
      warnings.add(const CalcWarning('final_concentration_exceeds_stock'));
    }
    return CalcResult(DilutionOutput(unknown, result), warnings: warnings);
  }
}
