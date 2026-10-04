import 'dart:math' as math;

/// Typo-tolerantlik uchun o‘xshashlik o‘lchovlari.
abstract final class Similarity {
  /// Matn trigramlari (chegaralar bilan: `  ab`).
  static Set<String> trigrams(String s) {
    final padded = '  $s ';
    final result = <String>{};
    for (var i = 0; i + 3 <= padded.length; i++) {
      result.add(padded.substring(i, i + 3));
    }
    return result;
  }

  /// Dice koeffitsienti trigramlar bo‘yicha (0..1).
  static double trigramDice(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final ta = trigrams(a);
    final tb = trigrams(b);
    final common = ta.intersection(tb).length;
    return 2 * common / (ta.length + tb.length);
  }

  /// Damerau–Levenshtein (optimal string alignment) masofasi.
  static int editDistance(String a, String b) {
    final n = a.length;
    final m = b.length;
    if (n == 0) return m;
    if (m == 0) return n;
    final d = List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));
    for (var i = 0; i <= n; i++) {
      d[i][0] = i;
    }
    for (var j = 0; j <= m; j++) {
      d[0][j] = j;
    }
    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= m; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        var v = math.min(
          math.min(d[i - 1][j] + 1, d[i][j - 1] + 1),
          d[i - 1][j - 1] + cost,
        );
        if (i > 1 && j > 1 && a[i - 1] == b[j - 2] && a[i - 2] == b[j - 1]) {
          v = math.min(v, d[i - 2][j - 2] + 1);
        }
        d[i][j] = v;
      }
    }
    return d[n][m];
  }

  /// So‘rov uzunligiga qarab ruxsat etilgan xatolar soni.
  static int allowedEdits(int queryLength) {
    if (queryLength <= 3) return 0;
    if (queryLength <= 6) return 1;
    return 2;
  }
}
