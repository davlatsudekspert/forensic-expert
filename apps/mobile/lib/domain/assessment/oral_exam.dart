import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Og‘zaki imtihon: har talabaga takrorlanmaydigan 5 savollik bilet,
/// har savolga 0–20 ball, jami 100 ball. Faqat qurilmada saqlanadi.
const oralExamTicketSize = 5;
const oralExamMaxPerQuestion = 20;
const oralExamMaxTotal = oralExamTicketSize * oralExamMaxPerQuestion;
const oralExamHistoryLimit = 200;

String oralPoolKey(String spec, String cat) => '$spec.$cat';

/// Bilet: havzadan hali ishlatilmagan [oralExamTicketSize] ta savol.
/// Ishlatilmagani yetmasa, aylanish qaytadan boshlanadi (`reset`).
/// Havza 5 tadan kichik bo‘lsa — hammasi.
({List<String> ids, bool reset}) drawOralTicket({
  required List<String> pool,
  required Set<String> used,
  required math.Random rng,
  int size = oralExamTicketSize,
}) {
  if (pool.isEmpty) return (ids: const [], reset: false);
  var fresh = [
    for (final id in pool)
      if (!used.contains(id)) id,
  ];
  var reset = false;
  if (fresh.length < size && pool.length >= size) {
    fresh = [...pool];
    reset = true;
  }
  fresh.shuffle(rng);
  return (ids: fresh.take(size).toList(), reset: reset);
}

@immutable
class OralExamResult {
  const OralExamResult({
    required this.atMs,
    required this.spec,
    required this.cat,
    required this.name,
    required this.questionIds,
    required this.scores,
  });

  factory OralExamResult.fromJson(Map<Object?, Object?> j) {
    List<T> list<T>(Object? v, T Function(Object?) f) => [
      if (v is List)
        for (final x in v) f(x),
    ];
    return OralExamResult(
      atMs: j['at'] is num ? (j['at']! as num).toInt() : 0,
      spec: '${j['spec'] ?? ''}',
      cat: '${j['cat'] ?? ''}',
      name: '${j['name'] ?? ''}',
      questionIds: list<String>(j['q'], (x) => '$x'),
      scores: list<int>(
        j['s'],
        (x) => x is num ? x.toInt().clamp(0, oralExamMaxPerQuestion) : 0,
      ),
    );
  }

  final int atMs;
  final String spec;
  final String cat;
  final String name;
  final List<String> questionIds;
  final List<int> scores;

  int get total => scores.fold(0, (a, b) => a + b);

  Map<String, Object?> toJson() => {
    'at': atMs,
    'spec': spec,
    'cat': cat,
    'name': name,
    'q': questionIds,
    's': scores,
  };
}

/// Saqlanadigan qism: ishlatilgan savollar (havza kaliti → id'lar) va tarix.
@immutable
class OralExamData {
  const OralExamData({this.used = const {}, this.history = const []});

  factory OralExamData.fromJson(Object? raw) {
    if (raw is! Map) return empty;
    final u = raw['used'];
    final h = raw['history'];
    return OralExamData(
      used: {
        if (u is Map)
          for (final e in u.entries)
            if (e.value is List)
              '${e.key}': {for (final x in e.value! as List) '$x'},
      },
      history: [
        if (h is List)
          for (final x in h)
            if (x is Map) OralExamResult.fromJson(x),
      ],
    );
  }

  static const empty = OralExamData();

  final Map<String, Set<String>> used;

  /// Yangisi birinchi.
  final List<OralExamResult> history;

  Set<String> usedFor(String spec, String cat) =>
      used[oralPoolKey(spec, cat)] ?? const {};

  OralExamData withUsed(String spec, String cat, Set<String> ids) =>
      OralExamData(
        used: {...used, oralPoolKey(spec, cat): ids},
        history: history,
      );

  OralExamData withResult(OralExamResult r) => OralExamData(
    used: used,
    history: [r, ...history].take(oralExamHistoryLimit).toList(),
  );

  OralExamData withoutHistory() => OralExamData(used: used);

  String encode() => jsonEncode({
    'used': {for (final e in used.entries) e.key: e.value.toList()},
    'history': [for (final r in history) r.toJson()],
  });
}

abstract interface class OralExamStore {
  OralExamData load();
  Future<void> save(OralExamData data);
}

class InMemoryOralExamStore implements OralExamStore {
  OralExamData _d = OralExamData.empty;

  @override
  OralExamData load() => _d;

  @override
  Future<void> save(OralExamData data) async => _d = data;
}
