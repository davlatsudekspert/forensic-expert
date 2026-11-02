import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/assessment/assessment_test_stats.dart';

void main() {
  const s = 'sud_tib';

  test('xato javob «Xatolarim»ga tushadi, to‘g‘ri — o‘zlashtiriladi', () {
    var st = AssessmentTestStats.empty
        .recordAnswer(s, 'a', isCorrect: true)
        .recordAnswer(s, 'b', isCorrect: false);
    expect(st.mistakeIds(s), {'b'});
    expect(st.masteredCount(s, ['a', 'b', 'c']), 1);
    // Xato qilingan o‘zlashtirilgan savol qayta ro‘yxatga tushadi.
    st = st.recordAnswer(s, 'a', isCorrect: false);
    expect(st.mistakeIds(s), {'a', 'b'});
    expect(st.masteredCount(s, ['a', 'b']), 0);
  });

  test(
    'xato savol ketma-ket 2 to‘g‘ridan keyin chiqadi; xato seriyani 0 qiladi',
    () {
      var st = AssessmentTestStats.empty.recordAnswer(s, 'x', isCorrect: false);
      st = st.recordAnswer(s, 'x', isCorrect: true, inMistakesMode: true);
      expect(st.mistakes[s]!['x'], 1);
      st = st.recordAnswer(s, 'x', isCorrect: false, inMistakesMode: true);
      expect(st.mistakes[s]!['x'], 0);
      st = st.recordAnswer(s, 'x', isCorrect: true, inMistakesMode: true);
      expect(st.mistakeIds(s), {'x'});
      st = st.recordAnswer(s, 'x', isCorrect: true, inMistakesMode: true);
      expect(st.mistakeIds(s), isEmpty);
      expect(st.masteredCount(s, ['x']), 1);
    },
  );

  test('boshqa rejimdagi to‘g‘ri javob seriyani oshirmaydi', () {
    final st = AssessmentTestStats.empty
        .recordAnswer(s, 'x', isCorrect: false)
        .recordAnswer(s, 'x', isCorrect: true);
    expect(st.mistakes[s]!['x'], 0);
    expect(st.masteredCount(s, ['x']), 0);
  });

  test('blok: faqat eng yaxshi ball saqlanadi; mutaxassislik alohida', () {
    var st = AssessmentTestStats.empty.recordBlock(s, 0, 30);
    st = st.recordBlock(s, 0, 20).recordBlock('pat_anat', 0, 5);
    expect(st.bestScore(s, 0), 30);
    expect(st.bestScore(s, 1), isNull);
    st = st.recordBlock(s, 0, 38);
    expect(st.bestScore(s, 0), 38);
    expect(st.bestScore('pat_anat', 0), 5);
  });

  test('JSON aylanishi va buzilgan ma’lumot', () {
    final st = AssessmentTestStats.empty
        .recordAnswer(s, 'a', isCorrect: true)
        .recordAnswer(s, 'b', isCorrect: false)
        .recordBlock(s, 2, 41);
    final back = AssessmentTestStats.fromJson(st.toJson());
    expect(back.bestScore(s, 2), 41);
    expect(back.mistakeIds(s), {'b'});
    expect(back.masteredCount(s, ['a']), 1);
    expect(AssessmentTestStats.fromJson('xx').mistakeCount(s), 0);
    expect(AssessmentTestStats.fromJson(null).bestScore(s, 0), isNull);
  });
}
