import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Ketma-ket nechta to‘g‘ri javobdan keyin xato savol «Xatolarim»dan chiqadi.
const assessmentMistakeClearStreak = 2;

/// Test mashqlari statistikasi (mutaxassislik bo‘yicha): blok rekordlari,
/// «Xatolarim» (savol → ketma-ket to‘g‘ri javoblar) va o‘zlashtirilganlar.
/// Faqat qurilmada saqlanadi.
@immutable
class AssessmentTestStats {
  const AssessmentTestStats({
    this.best = const {},
    this.mistakes = const {},
    this.correct = const {},
  });

  factory AssessmentTestStats.fromJson(Object? raw) {
    if (raw is! Map) return empty;
    Map<String, Map<String, int>> ints(Object? v) => {
      if (v is Map)
        for (final e in v.entries)
          if (e.value is Map)
            '${e.key}': {
              for (final x in (e.value! as Map).entries)
                if (x.value is num) '${x.key}': (x.value! as num).toInt(),
            },
    };
    final c = raw['correct'];
    return AssessmentTestStats(
      best: ints(raw['best']),
      mistakes: ints(raw['mistakes']),
      correct: {
        if (c is Map)
          for (final e in c.entries)
            if (e.value is List)
              '${e.key}': {for (final x in e.value! as List) '$x'},
      },
    );
  }

  static const empty = AssessmentTestStats();

  /// mutaxassislik → (blok indeksi → eng yaxshi ball).
  final Map<String, Map<String, int>> best;

  /// mutaxassislik → (savol id → ketma-ket to‘g‘ri javoblar soni).
  final Map<String, Map<String, int>> mistakes;

  /// mutaxassislik → hech bo‘lmasa bir marta to‘g‘ri javob berilgan savollar.
  final Map<String, Set<String>> correct;

  int? bestScore(String spec, int block) => best[spec]?['$block'];

  Set<String> mistakeIds(String spec) => {...?mistakes[spec]?.keys};

  int mistakeCount(String spec) => mistakes[spec]?.length ?? 0;

  /// O‘zlashtirilgan: to‘g‘ri javob berilgan va hozir xatolar ro‘yxatida yo‘q.
  int masteredCount(String spec, Iterable<String> gradedIds) {
    final ok = correct[spec] ?? const <String>{};
    final bad = mistakes[spec] ?? const <String, int>{};
    return gradedIds
        .where((id) => ok.contains(id) && !bad.containsKey(id))
        .length;
  }

  /// Bitta javobni hisobga oladi. Noto‘g‘ri — «Xatolarim»ga (seriya 0).
  /// To‘g‘ri — o‘zlashtirilganlarga; xato savolning seriyasi esa faqat
  /// [inMistakesMode]da oshadi va [assessmentMistakeClearStreak]ga yetganda
  /// ro‘yxatdan chiqadi.
  AssessmentTestStats recordAnswer(
    String spec,
    String id, {
    required bool isCorrect,
    bool inMistakesMode = false,
  }) {
    final m = {...?mistakes[spec]};
    final ok = {...?correct[spec]};
    if (!isCorrect) {
      m[id] = 0;
      ok.remove(id);
    } else {
      ok.add(id);
      if (m.containsKey(id) && inMistakesMode) {
        final s = m[id]! + 1;
        if (s >= assessmentMistakeClearStreak) {
          m.remove(id);
        } else {
          m[id] = s;
        }
      }
    }
    return AssessmentTestStats(
      best: best,
      mistakes: {...mistakes, spec: m},
      correct: {...correct, spec: ok},
    );
  }

  /// Blok natijasi: faqat oldingisidan yaxshi bo‘lsa saqlanadi.
  AssessmentTestStats recordBlock(String spec, int block, int score) {
    final cur = bestScore(spec, block);
    if (cur != null && cur >= score) return this;
    return AssessmentTestStats(
      best: {
        ...best,
        spec: {...?best[spec], '$block': score},
      },
      mistakes: mistakes,
      correct: correct,
    );
  }

  Map<String, Object?> toJson() => {
    'v': 1,
    'best': best,
    'mistakes': mistakes,
    'correct': {
      for (final e in correct.entries) e.key: (e.value.toList()..sort()),
    },
  };

  String encode() => jsonEncode(toJson());
}

/// Qurilmadagi test statistikasi (serverga yuborilmaydi).
abstract interface class AssessmentTestStatsStore {
  AssessmentTestStats load();
  Future<void> save(AssessmentTestStats stats);
}

class InMemoryAssessmentTestStatsStore implements AssessmentTestStatsStore {
  AssessmentTestStats _v = AssessmentTestStats.empty;

  @override
  AssessmentTestStats load() => _v;

  @override
  Future<void> save(AssessmentTestStats stats) async => _v = stats;
}
