/// 100 ballik natija va taxminiy baho (PF-191, 2026-2027 o‘quv yili).
///
/// Chegaralar va hisob-kitob FAQAT shu yerda (egasi qarori, 2026-10-31):
/// ball = to‘g‘ri / jami × 100 (bir kasr xonagacha); 5 = 90.0–100,
/// 4 = 80.0–89.9, 3 = 70.0–79.9, 70.0 dan past — «Minimal o‘tish balidan
/// past». Bu ilova hisoblagan TAXMINIY baho, rasmiy baho emas. Tezlik ballari
/// (jonli sinf reytingi) bu hisobga kirmaydi.
library;

/// Taxminiy baho. [belowMin] — minimal o‘tish balidan past (qarzdorlik emas).
enum PfGrade {
  five(5),
  four(4),
  three(3),
  belowMin(null);

  const PfGrade(this.value);

  /// 5/4/3; [belowMin] uchun `null`.
  final int? value;

  bool get passed => this != belowMin;
}

/// 100 ballik natija: [score] (0–100, bir kasr xona) va [grade].
class Score100 {
  const Score100._(this.tenths);

  /// Ballning o‘ndan bir ulushlari (86.7 → 867): float xatosiz.
  final int tenths;

  double get score => tenths / 10;

  PfGrade get grade => GradeScale.gradeOfTenths(tenths);

  /// «86.7» (nuqta bilan; CSV va ekranda bir xil).
  String get text => GradeScale.format(tenths);
}

abstract final class GradeScale {
  /// Tartib amal qiladigan o‘quv yili.
  static const academicYear = '2026-2027';

  /// Minimal o‘tish bali (foiz).
  static const double minPass = 70.0;

  /// Baho chegaralari (ball, kiritilgan).
  static const double fiveFrom = 90.0;
  static const double fourFrom = 80.0;
  static const double threeFrom = minPass;

  /// To‘g‘ri/jami → 100 ballik natija; yaxlitlash — yarmidan yuqoriga,
  /// butun sonlarda (89.95 → 90.0 kabi float xatosi yo‘q). Jami 0 → 0.0.
  static Score100 of(int correct, int total) {
    if (total <= 0 || correct <= 0) return const Score100._(0);
    final c = correct > total ? total : correct;
    return Score100._((c * 1000 + total ~/ 2) ~/ total);
  }

  /// `correct / total × 100`, bir kasr xonagacha.
  static double score100(int correct, int total) => of(correct, total).score;

  static PfGrade gradeOfTenths(int tenths) {
    if (tenths >= (fiveFrom * 10).round()) return PfGrade.five;
    if (tenths >= (fourFrom * 10).round()) return PfGrade.four;
    if (tenths >= (threeFrom * 10).round()) return PfGrade.three;
    return PfGrade.belowMin;
  }

  /// Berilgan ball (bir kasr xonagacha yaxlitlanib) bo‘yicha baho.
  static PfGrade gradeOf(double score) => gradeOfTenths((score * 10).round());

  static PfGrade grade(int correct, int total) => of(correct, total).grade;

  /// «86.7», «100.0», «0.0».
  static String format(int tenths) => '${tenths ~/ 10}.${tenths % 10}';
}

/// CSV (ustoz reestri) uchun umumiy ustun nomlari va «Baho» katagi.
abstract final class GradeScaleCsv {
  static const scoreHeader = 'Ball (100)';
  static const gradeHeader = 'Baho';

  /// 5 / 4 / 3 yoki [belowMinLabel] («Minimal o‘tish balidan past»).
  static String gradeCell(PfGrade g, String belowMinLabel) =>
      g.value?.toString() ?? belowMinLabel;
}
