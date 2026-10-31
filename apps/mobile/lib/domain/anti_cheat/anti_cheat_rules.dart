/// Testda ko‘chirish (boshqa telefonda rasmga olib sun’iy intellektdan
/// foydalanish) xavfini kamaytirish qoidalari. Faqat TOMONLAMA ISHORA:
/// ustozga ko‘rsatiladi, talabaga hech qanday jazo/ball o‘zgarishi yo‘q.
///
/// Server tomoni: `docs/ANTI_CHEAT_SERVER_20261031.md` (`class_report_leave`,
/// `group_report_leave`, `leave_count`, `last_left_at`).
library;

import '../class_groups/class_groups_models.dart';
import '../class_groups/variant_draw.dart' show variantMaxCount;
import '../class_quiz/class_quiz_models.dart';

abstract final class AntiCheatRules {
  /// «Tez va to‘g‘ri» belgisi: to‘g‘ri javoblar ulushi shundan kam emas…
  static const double highScoreFraction = 0.8;

  /// …va bitta savolga o‘rtacha sarflangan vaqt (soniya) shundan KAM.
  static const double minAvgSecondsPerQuestion = 2.5;

  /// Juda kam savolli testda o‘rtacha vaqt ma’nosiz (bitta savol 2 s da
  /// javoblanishi tabiiy) — belgi faqat shu sondan boshlab.
  static const int minQuestionsForSpeedHint = 5;

  /// Variantlar talabaga qarab farq qila olmaganda tavsiya etiladigan
  /// savollar soni (ko‘pi bilan).
  static const int recommendedMaxQuestions = 15;
}

/// «Tez va to‘g‘ri javob» qoidasi — YAGONA joy (guruh testi ham, jonli sinf
/// ham shuni chaqiradi): ball >= [AntiCheatRules.highScoreFraction] **va**
/// savolga o‘rtacha vaqt < [AntiCheatRules.minAvgSecondsPerQuestion] (savollar
/// soni kamida [AntiCheatRules.minQuestionsForSpeedHint]).
/// Bu ISBOT EMAS — ustoz uchun ishora; matni betaraf bo‘lishi shart.
bool looksTooFastAndCorrect({
  required int correct,
  required int total,
  required Duration avgPerQuestion,
}) {
  if (total < AntiCheatRules.minQuestionsForSpeedHint) return false;
  if (avgPerQuestion <= Duration.zero) return false; // vaqt noma’lum/xato
  if (correct / total < AntiCheatRules.highScoreFraction) return false;
  return avgPerQuestion.inMilliseconds <
      (AntiCheatRules.minAvgSecondsPerQuestion * 1000).round();
}

/// Guruh testi: yakunlagan talaba, jami sarflangan vaqt / savollar soni.
bool groupRowLooksTooFast(GroupBoardRow r) {
  final spent = r.spent;
  final total = r.total;
  final score = r.score;
  if (spent == null || total == null || total <= 0 || score == null) {
    return false;
  }
  return looksTooFastAndCorrect(
    correct: score,
    total: total,
    avgPerQuestion: Duration(microseconds: spent.inMicroseconds ~/ total),
  );
}

/// Jonli sinf: reyting qatori. Server `avg_ms` ni TO‘G‘RI javoblar bo‘yicha
/// beradi (yo‘q bo‘lsa `null` — belgi qo‘yilmaydi).
bool classLeaderLooksTooFast(ClassLeaderRow r, int total) {
  final ms = r.avgMs;
  if (ms == null) return false;
  return looksTooFastAndCorrect(
    correct: r.correct,
    total: total,
    avgPerQuestion: Duration(milliseconds: ms),
  );
}

/// Savol soni maslahati: har talabaga boshqa savollar tushishi uchun hovuz
/// savol sonidan kamida 2 baravar katta bo‘lishi kerak.
class QuestionCountAdvice {
  const QuestionCountAdvice({required this.warn, required this.recommended});

  /// Hovuz < 2 × savol soni: variantlar talabaga qarab farq qila olmaydi.
  final bool warn;

  /// Tavsiya etilgan eng ko‘p savol soni (ko‘pi bilan 15).
  final int recommended;
}

/// [minCount] — testning eng kam ruxsat etilgan savol soni (jonli sinfda 5):
/// tavsiya undan kichik bo‘lmaydi (hovuzdan katta ham emas).
QuestionCountAdvice questionCountAdvice({
  required int poolSize,
  required int count,
  int minCount = 1,
}) {
  final warn = count >= 1 && poolSize < count * 2;
  final cap = variantMaxCount(poolSize);
  var rec = cap >= 1 ? cap : poolSize;
  if (rec > AntiCheatRules.recommendedMaxQuestions) {
    rec = AntiCheatRules.recommendedMaxQuestions;
  }
  if (rec < minCount) rec = minCount;
  if (rec > poolSize && poolSize >= 1) rec = poolSize;
  return QuestionCountAdvice(warn: warn, recommended: rec < 1 ? 1 : rec);
}
