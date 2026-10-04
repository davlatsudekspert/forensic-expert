import 'package:meta/meta.dart';

/// Fizik o‘lcham. Faqat bir xil o‘lchamdagi birliklar o‘zaro konvertatsiya
/// qilinadi — birlik chalkashligidan kelib chiqadigan xatoga qarshi.
enum Dimension { volume, massConcentration, molarConcentration, mass }

/// Birlik: kanonik SI-ga yaqin birlikka nisbatan koeffitsient bilan.
///
/// Kanonik birliklar: hajm — L; massa konsentratsiyasi — g/L;
/// molyar konsentratsiya — mol/L; massa — g.
/// Koeffitsientlar SI prefikslarining ta’rifidan (10ⁿ) kelib chiqadi —
/// ilmiy da’vo emas, ta’rif.
enum Unit {
  liter('L', Dimension.volume, 1),
  milliliter('mL', Dimension.volume, 1e-3),
  microliter('µL', Dimension.volume, 1e-6),

  gramPerLiter('g/L', Dimension.massConcentration, 1),
  milligramPerLiter('mg/L', Dimension.massConcentration, 1e-3),
  microgramPerLiter('µg/L', Dimension.massConcentration, 1e-6),
  nanogramPerMilliliter('ng/mL', Dimension.massConcentration, 1e-6),
  milligramPerMilliliter('mg/mL', Dimension.massConcentration, 1),
  microgramPerMilliliter('µg/mL', Dimension.massConcentration, 1e-3),

  molePerLiter('mol/L', Dimension.molarConcentration, 1),
  millimolePerLiter('mmol/L', Dimension.molarConcentration, 1e-3),
  micromolePerLiter('µmol/L', Dimension.molarConcentration, 1e-6),

  gram('g', Dimension.mass, 1),
  milligram('mg', Dimension.mass, 1e-3),
  microgram('µg', Dimension.mass, 1e-6);

  const Unit(this.symbol, this.dimension, this.toCanonical);

  final String symbol;
  final Dimension dimension;

  /// Shu birlikdagi 1 qiymat kanonik birlikda nechaga teng.
  final double toCanonical;
}

class IncompatibleUnitsException implements Exception {
  IncompatibleUnitsException(this.from, this.to);

  final Unit from;
  final Unit to;

  @override
  String toString() =>
      'IncompatibleUnitsException: ${from.symbol} (${from.dimension.name}) → '
      '${to.symbol} (${to.dimension.name})';
}

@immutable
class Quantity {
  const Quantity(this.value, this.unit);

  final double value;
  final Unit unit;

  double get canonicalValue => value * unit.toCanonical;

  Quantity to(Unit target) {
    if (target.dimension != unit.dimension) {
      throw IncompatibleUnitsException(unit, target);
    }
    return Quantity(canonicalValue / target.toCanonical, target);
  }

  @override
  String toString() => '$value ${unit.symbol}';
}
