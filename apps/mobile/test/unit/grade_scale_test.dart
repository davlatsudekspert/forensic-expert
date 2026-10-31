import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';
import 'package:forensic_expert/domain/class_groups/group_results_csv.dart';
import 'package:forensic_expert/domain/grading/grade_scale.dart';

void main() {
  group('GradeScale.score100', () {
    test('to‘g‘ri / jami × 100, bir kasr xonagacha', () {
      expect(GradeScale.score100(26, 30), 86.7);
      expect(GradeScale.score100(1, 3), 33.3);
      expect(GradeScale.score100(2, 3), 66.7);
      expect(GradeScale.score100(30, 30), 100.0);
      expect(GradeScale.score100(0, 30), 0.0);
      expect(GradeScale.of(26, 30).text, '86.7');
      expect(GradeScale.of(30, 30).text, '100.0');
      expect(GradeScale.of(0, 5).text, '0.0');
    });

    test('0 savol — 0.0 (nolga bo‘lish yo‘q), jami > to‘g‘ri qisiladi', () {
      expect(GradeScale.score100(0, 0), 0.0);
      expect(GradeScale.score100(3, 0), 0.0);
      expect(GradeScale.score100(-1, 10), 0.0);
      expect(GradeScale.score100(12, 10), 100.0);
      expect(GradeScale.grade(0, 0), PfGrade.belowMin);
    });

    test('yaxlitlash: yarmidan yuqoriga, float xatosiz', () {
      // 1/8 = 12.5 aniq; 1/16 = 6.25 → 6.3; 3/16 = 18.75 → 18.8.
      expect(GradeScale.of(1, 8).text, '12.5');
      expect(GradeScale.of(1, 16).text, '6.3');
      expect(GradeScale.of(3, 16).text, '18.8');
      // 899/1000 = 89.9 aniq, 8995/10000 = 89.95 → 90.0.
      expect(GradeScale.of(899, 1000).text, '89.9');
      expect(GradeScale.of(8995, 10000).text, '90.0');
    });
  });

  group('GradeScale.grade — PF-191 (2026-2027) chegaralari', () {
    test('5 = 90.0–100', () {
      expect(GradeScale.gradeOf(100), PfGrade.five);
      expect(GradeScale.gradeOf(90.0), PfGrade.five);
      expect(GradeScale.gradeOf(89.9), PfGrade.four);
    });

    test('4 = 80.0–89.9', () {
      expect(GradeScale.gradeOf(89.9), PfGrade.four);
      expect(GradeScale.gradeOf(80.0), PfGrade.four);
      expect(GradeScale.gradeOf(79.9), PfGrade.three);
    });

    test('3 = 70.0–79.9; 70.0 dan past — minimal o‘tish balidan past', () {
      expect(GradeScale.gradeOf(79.9), PfGrade.three);
      expect(GradeScale.gradeOf(70.0), PfGrade.three);
      expect(GradeScale.gradeOf(69.9), PfGrade.belowMin);
      expect(GradeScale.gradeOf(0), PfGrade.belowMin);
      expect(PfGrade.belowMin.passed, isFalse);
      expect(PfGrade.three.passed, isTrue);
      expect(GradeScale.minPass, 70.0);
    });

    test('savol soni bo‘yicha: chegaraviy to‘g‘ri javoblar', () {
      // 30 ta savol: 27 → 90.0 (5), 26 → 86.7 (4), 24 → 80.0 (4),
      // 23 → 76.7 (3), 21 → 70.0 (3), 20 → 66.7 (past).
      expect(GradeScale.grade(27, 30), PfGrade.five);
      expect(GradeScale.grade(26, 30), PfGrade.four);
      expect(GradeScale.grade(24, 30), PfGrade.four);
      expect(GradeScale.grade(23, 30), PfGrade.three);
      expect(GradeScale.grade(21, 30), PfGrade.three);
      expect(GradeScale.grade(20, 30), PfGrade.belowMin);
      // 10 ta: 9 → 90.0 (5), 8 → 80.0 (4), 7 → 70.0 (3), 6 → 60.0 (past).
      expect(GradeScale.grade(9, 10), PfGrade.five);
      expect(GradeScale.grade(8, 10), PfGrade.four);
      expect(GradeScale.grade(7, 10), PfGrade.three);
      expect(GradeScale.grade(6, 10), PfGrade.belowMin);
      expect(GradeScale.grade(10, 10).value, 5);
      expect(PfGrade.belowMin.value, isNull);
    });

    test(
      '1-xonaga yaxlitlangan ball bo‘yicha baho (ekrandagi ball bilan mos)',
      () {
        // 8995/10000 = 89.95 → 90.0 ko‘rsatiladi → baho ham 5.
        expect(GradeScale.grade(8995, 10000), PfGrade.five);
        // 6995/10000 = 69.95 → 70.0 → 3.
        expect(GradeScale.grade(6995, 10000), PfGrade.three);
        // 6994/10000 = 69.94 → 69.9 → past.
        expect(GradeScale.grade(6994, 10000), PfGrade.belowMin);
      },
    );
  });

  group('GroupResultsCsv', () {
    const below = 'Minimal o‘tish balidan past';

    GroupBoardRow row(
      String nick,
      BoardState st, {
      int? score,
      int? total,
      int? secs,
    }) => GroupBoardRow(
      memberId: nick,
      nickname: nick,
      state: st,
      score: score,
      total: total,
      startedAt: secs == null ? null : DateTime(2026, 10, 31, 10),
      submittedAt: secs == null
          ? null
          : DateTime(2026, 10, 31, 10).add(Duration(seconds: secs)),
    );

    test('ustunlar: «Ball (100)» va «Baho», tugatmaganlarda bo‘sh', () {
      final csv = GroupResultsCsv.build([
        row('Ali', BoardState.finished, score: 28, total: 30, secs: 754),
        row('Vali', BoardState.finished, score: 21, total: 30, secs: 600),
        row('Gul', BoardState.finished, score: 12, total: 30, secs: 300),
        row('Sher', BoardState.solving),
        row('Nur', BoardState.joined),
      ], belowMinLabel: below);
      final lines = csv.trim().split('\r\n');
      expect(
        lines.first,
        'laqab,holat,togri_soni,jami,Ball (100),Baho,sarflangan_vaqt_s',
      );
      expect(lines[1], 'Ali,tugatdi,28,30,93.3,5,754.0');
      expect(lines[2], 'Vali,tugatdi,21,30,70.0,3,600.0');
      expect(lines[3], 'Gul,tugatdi,12,30,40.0,$below,300.0');
      expect(lines[4], 'Sher,yechmoqda,,,,,');
      expect(lines[5], 'Nur,qoshildi,,,,,');
    });

    test('formula in’yeksiyasidan himoya va ASCII fayl nomi', () {
      final csv = GroupResultsCsv.build([
        row('=1+1', BoardState.finished, score: 3, total: 4, secs: 5),
      ], belowMinLabel: below);
      expect(csv, contains("'=1+1,tugatdi,3,4,75.0,3,5.0"));
      final n = GroupResultsCsv.fileName(DateTime(2026, 10, 31));
      expect(n, 'guruh_test_natija_2026-10-31.csv');
      expect(n.codeUnits.every((c) => c < 128), isTrue);
    });
  });
}
