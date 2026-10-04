import 'package:meta/meta.dart';

/// So‘rov turi.
enum QueryKind {
  /// Oddiy matn (nom, termin, mavzu).
  text,

  /// Kimyoviy formula ko‘rinishi, masalan `C10H15N`.
  formula,

  /// CAS Registry Number® shakli (nazorat raqami to‘g‘ri).
  ///
  /// Klassifikator faqat **shaklni** aniqlaydi. Bunday so‘rov bo‘yicha
  /// qidirish-qidirmaslikni ilovadagi `IdentifierPolicy` hal qiladi
  /// (hozircha o‘chirilgan — `docs/01_EVIDENCE_AUDIT.md`, B-05).
  casRegistryNumberShape,
}

@immutable
class ClassifiedQuery {
  const ClassifiedQuery(this.kind, this.raw);

  final QueryKind kind;
  final String raw;
}

class QueryClassifier {
  const QueryClassifier();

  static final _casShape = RegExp(r'^(\d{2,7})-(\d{2})-(\d)$');
  static final _formula = RegExp(
    r'^(?:[A-Z][a-z]?\d*)+$',
  ); // C10H15N, NaCl, H2S

  ClassifiedQuery classify(String input) {
    final q = input.trim();
    final cas = _casShape.firstMatch(q);
    if (cas != null &&
        _casChecksumValid(cas[1]!, cas[2]!, int.parse(cas[3]!))) {
      return ClassifiedQuery(QueryKind.casRegistryNumberShape, q);
    }
    if (q.length >= 2 &&
        _formula.hasMatch(q) &&
        RegExp(r'\d').hasMatch(q) &&
        RegExp(r'[A-Z]').allMatches(q).length >= 2) {
      return ClassifiedQuery(QueryKind.formula, q);
    }
    return ClassifiedQuery(QueryKind.text, q);
  }

  /// CAS nazorat raqami: o‘ngdan chapga raqamlar 1, 2, 3… ga ko‘paytiriladi,
  /// yig‘indi mod 10 nazorat raqamiga teng bo‘lishi kerak.
  static bool _casChecksumValid(String a, String b, int check) {
    final digits = (a + b).split('').reversed.map(int.parse).toList();
    var sum = 0;
    for (var i = 0; i < digits.length; i++) {
      sum += digits[i] * (i + 1);
    }
    return sum % 10 == check;
  }
}
