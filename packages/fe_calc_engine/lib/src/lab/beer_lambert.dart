import 'package:meta/meta.dart';

import '../calculator.dart';
import '../units.dart';

/// A = ε·l·c da qaysi kattalik topiladi.
enum BeerLambertUnknown { absorbance, concentration, absorptivity }

/// Yutilish koeffitsientining asosi: molyar (ε, L·mol⁻¹·cm⁻¹) yoki
/// massaviy (a, L·g⁻¹·cm⁻¹). Konsentratsiya birligi shu asosga mos
/// bo‘lishi shart — aks holda birliklar aralashib ketadi.
enum AbsorptivityBasis {
  molar('L·mol⁻¹·cm⁻¹', Dimension.molarConcentration),
  mass('L·g⁻¹·cm⁻¹', Dimension.massConcentration);

  const AbsorptivityBasis(this.symbol, this.concentrationDimension);

  final String symbol;
  final Dimension concentrationDimension;
}

/// Kyuveta qalinligi (optik yo‘l uzunligi) birligi.
enum PathLengthUnit {
  centimeter('cm', 1),
  millimeter('mm', 0.1);

  const PathLengthUnit(this.symbol, this.toCentimeter);

  final String symbol;
  final double toCentimeter;
}

/// Kirish: [absorbance], [absorptivity], [concentration] dan aynan bittasi
/// `null` (noma’lum). Optik yo‘l uzunligi har doim beriladi.
@immutable
class BeerLambertInput {
  const BeerLambertInput({
    required this.basis,
    required this.pathLength,
    this.pathLengthUnit = PathLengthUnit.centimeter,
    this.absorbance,
    this.absorptivity,
    this.concentration,
    this.concentrationUnit,
  });

  final AbsorptivityBasis basis;
  final double pathLength;
  final PathLengthUnit pathLengthUnit;

  /// O‘lchamsiz yutilish (A = lg(I₀/I)).
  final double? absorbance;

  /// ε yoki a — [basis] birligida (sm asosida).
  final double? absorptivity;
  final Quantity? concentration;

  /// Konsentratsiya noma’lum bo‘lsa — natija qaysi birlikda chiqsin.
  /// Berilmasa — asosning kanonik birligi (mol/L yoki g/L).
  final Unit? concentrationUnit;
}

@immutable
class BeerLambertOutput {
  const BeerLambertOutput(this.unknown, {this.value, this.concentration});

  final BeerLambertUnknown unknown;

  /// A (o‘lchamsiz) yoki ε/a ([AbsorptivityBasis.symbol] birligida).
  final double? value;

  /// Noma’lum konsentratsiya bo‘lsa — so‘ralgan birlikda.
  final Quantity? concentration;
}

/// Ber–Lambert–Buger qonuni A = ε·l·c.
///
/// **Ta’rifiy** munosabat: yutilish optik yo‘l uzunligi va konsentratsiyaga
/// proporsional (IUPAC Gold Book «Beer–Lambert law»,
/// doi:10.1351/goldbook.B00626; Swinehart 1962, doi:10.1021/ed039p333).
/// Kalkulyator hech qanday adabiyot koeffitsienti (ε qiymati, chiziqlilik
/// chegarasi) ishlatmaydi: ε/a — foydalanuvchining o‘z kalibrlashidan yoki
/// tekshirilgan manbadan. Chiziqlilik ishchi oraliqda kalibrlash bilan
/// ko‘rsatilishi kerak (ICH Q2(R2) §3.2.2.1).
class BeerLambertCalculator
    implements Calculator<BeerLambertInput, BeerLambertOutput> {
  const BeerLambertCalculator();

  static const _descriptor = CalculatorDescriptor(
    id: 'lab.beer_lambert',
    engineVersion: '1.0.0',
    formulaLatex: r'A = \varepsilon \cdot l \cdot c',
    nameKey: 'calc.beer_lambert.name',
    assumptionKeys: [
      'calc.beer_lambert.assumption.definition',
      'calc.beer_lambert.assumption.blank_corrected',
    ],
    limitationKeys: [
      'calc.beer_lambert.limitation.linear_range',
      'calc.beer_lambert.limitation.not_identification',
    ],
    referenceSourceIds: [],
    reviewState: CalculatorReviewState.needsReview,
    isDefinitional: true,
  );

  @override
  CalculatorDescriptor get descriptor => _descriptor;

  @override
  CalcResult<BeerLambertOutput> calculate(BeerLambertInput input) {
    final missing = [
      if (input.absorbance == null) BeerLambertUnknown.absorbance,
      if (input.absorptivity == null) BeerLambertUnknown.absorptivity,
      if (input.concentration == null) BeerLambertUnknown.concentration,
    ];
    if (missing.length != 1) {
      throw CalcInputException('exactly_one_unknown_required');
    }
    final unknown = missing.single;

    void positive(double? v, String field) {
      if (v == null) return;
      if (!v.isFinite || v <= 0) {
        throw CalcInputException('positive_required', field);
      }
    }

    positive(input.pathLength, 'path_length');
    positive(input.absorbance, 'absorbance');
    positive(input.absorptivity, 'absorptivity');
    positive(input.concentration?.value, 'concentration');

    final dim = input.basis.concentrationDimension;
    final c = input.concentration;
    if (c != null && c.unit.dimension != dim) {
      throw CalcInputException('concentration_basis_mismatch', 'concentration');
    }
    final outUnit = input.concentrationUnit;
    if (outUnit != null && outUnit.dimension != dim) {
      throw CalcInputException('concentration_basis_mismatch', 'unit');
    }

    final l = input.pathLength * input.pathLengthUnit.toCentimeter;
    // Kanonik konsentratsiya: mol/L yoki g/L (Unit.toCanonical ta’rifi).
    final cCanon = c?.canonicalValue;

    switch (unknown) {
      case BeerLambertUnknown.absorbance:
        return CalcResult(
          BeerLambertOutput(unknown, value: input.absorptivity! * l * cCanon!),
        );
      case BeerLambertUnknown.absorptivity:
        return CalcResult(
          BeerLambertOutput(unknown, value: input.absorbance! / (l * cCanon!)),
        );
      case BeerLambertUnknown.concentration:
        final canon = input.absorbance! / (input.absorptivity! * l);
        final unit =
            outUnit ??
            (dim == Dimension.molarConcentration
                ? Unit.molePerLiter
                : Unit.gramPerLiter);
        return CalcResult(
          BeerLambertOutput(
            unknown,
            concentration: Quantity(canon / unit.toCanonical, unit),
          ),
        );
    }
  }
}
