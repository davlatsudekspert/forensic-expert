import 'package:meta/meta.dart';

/// Kalkulatorning ilmiy holati. Ilmiy statuslar content sxemasi bilan
/// mos: kalkulyator ham reviewer tasdig‘isiz `verified` bo‘lmaydi.
enum CalculatorReviewState { needsReview, reviewed, verified }

/// Kalkulyator tavsifi — UI uni INPUT · METHOD · FORMULA · RESULT ·
/// LIMITATIONS · REFERENCES tartibida ko‘rsatadi.
///
/// Matnlar bu yerda **lokalizatsiya kalitlari** sifatida saqlanadi;
/// tarjimalar ilovaning l10n qatlamida yoki kontent bazasida.
@immutable
class CalculatorDescriptor {
  const CalculatorDescriptor({
    required this.id,
    required this.engineVersion,
    required this.formulaLatex,
    required this.nameKey,
    required this.assumptionKeys,
    required this.limitationKeys,
    required this.referenceSourceIds,
    required this.reviewState,
    this.isDefinitional = false,
  });

  /// Barqaror ID (kontent bazasidagi `calc_methods.engine_key`).
  final String id;

  /// Implementatsiya o‘zgarsa oshiriladi — natijalar auditida ishlatiladi.
  final String engineVersion;
  final String formulaLatex;
  final String nameKey;
  final List<String> assumptionKeys;
  final List<String> limitationKeys;

  /// Manba ID’lari (`fe_content_schema` `Source.sourceId`).
  final List<String> referenceSourceIds;
  final CalculatorReviewState reviewState;

  /// Formula matematik ta’rif (masalan, C1V1 = C2V2) bo‘lib, ilmiy
  /// koeffitsientga tayanmaydimi.
  final bool isDefinitional;
}

/// Hisob ogohlantirishi (masalan, natija fizik jihatdan mumkin emas).
@immutable
class CalcWarning {
  const CalcWarning(this.code, [this.args = const {}]);

  final String code;
  final Map<String, Object> args;

  @override
  String toString() => 'CalcWarning($code, $args)';
}

/// Hisob natijasi.
@immutable
class CalcResult<T> {
  const CalcResult(this.value, {this.warnings = const []});

  final T value;
  final List<CalcWarning> warnings;
}

/// Kiritilgan ma’lumot xatosi — UI uni lokalizatsiya qilingan xabar bilan
/// ko‘rsatadi.
class CalcInputException implements Exception {
  CalcInputException(this.code, [this.field]);

  final String code;
  final String? field;

  @override
  String toString() => 'CalcInputException($code, $field)';
}

/// Barcha kalkulyatorlar uchun umumiy kontrakt. Hisob **sinxron va sof**
/// (side-effect yo‘q) — shuning uchun tez va to‘liq test qilinadi.
abstract interface class Calculator<I, O> {
  CalculatorDescriptor get descriptor;

  CalcResult<O> calculate(I input);
}
