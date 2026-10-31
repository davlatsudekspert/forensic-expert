/// Guruh testi natijalari CSV (ustoz reestri): har talaba — laqab, holat,
/// to‘g‘ri soni, jami, «Ball (100)», «Baho», sarflangan vaqt.
///
/// Faqat laqab (ism/email yo‘q). Formula in’yeksiyasidan himoya —
/// [ClassResultsCsv.cell]. Ball/baho faqat testni tugatganlar uchun.
library;

import '../class_quiz/class_quiz_models.dart' show ClassResultsCsv;
import '../grading/grade_scale.dart';
import 'class_groups_models.dart';

abstract final class GroupResultsCsv {
  static const header =
      'laqab,holat,togri_soni,jami,${GradeScaleCsv.scoreHeader},'
      '${GradeScaleCsv.gradeHeader},sarflangan_vaqt_s';

  static String _state(BoardState s) => switch (s) {
    BoardState.finished => 'tugatdi',
    BoardState.solving => 'yechmoqda',
    BoardState.joined => 'qoshildi',
  };

  /// [rows] — odatda `GroupBoard.ranked` tartibida (tugatganlar reyting
  /// bo‘yicha, so‘ng qolganlar).
  static String build(
    Iterable<GroupBoardRow> rows, {
    required String belowMinLabel,
  }) {
    final b = StringBuffer('$header\r\n');
    for (final r in rows) {
      final done = r.state == BoardState.finished && r.total != null;
      final g = done ? GradeScale.of(r.score ?? 0, r.total!) : null;
      final secs = r.spent == null
          ? ''
          : (r.spent!.inMilliseconds / 1000).toStringAsFixed(1);
      b.write(
        '${ClassResultsCsv.cell(r.nickname)},${_state(r.state)},'
        '${done ? r.score ?? 0 : ''},${r.total ?? ''},'
        '${g?.text ?? ''},'
        '${g == null ? '' : ClassResultsCsv.cell(GradeScaleCsv.gradeCell(g.grade, belowMinLabel))},'
        '$secs\r\n',
      );
    }
    return b.toString();
  }

  /// `guruh_test_natija_2026-10-31.csv` — faqat ASCII.
  static String fileName(DateTime date) =>
      'guruh_test_natija_${date.toIso8601String().substring(0, 10)}.csv';
}
