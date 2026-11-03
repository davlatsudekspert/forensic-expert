/// Ustoz: mavzu bo‘yicha og‘zaki bilet (egasi kelishuvi, 2026-11-02/03).
///
/// Savollar ustozning o‘z darsi (prezentatsiya) slaydlaridan olinadi: slayd
/// sarlavhasi — savol, slayd bandlari va ularning manbasi (kitob, bet) —
/// javob kaliti. Hech narsa to‘qilmaydi: matn slayddagi kabi qoladi, faqat
/// «(davomi)» slaydlari oldingisiga qo‘shiladi va savol bo‘lmaydigan xizmat
/// slaydlari (kirish, reja, xulosa, tezkor savol, keys …) chiqarib tashlanadi.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'lesson_models.dart';

/// Biletdagi bitta savol.
@immutable
class LessonOralQuestion {
  const LessonOralQuestion({
    required this.id,
    required this.topicId,
    required this.text,
    required this.bullets,
  });

  /// `<topicId>#<slayd tartib raqami>` (deck o‘zgarmasa barqaror).
  final String id;
  final String topicId;
  final String text;

  /// Javob kaliti: slayd bandlari (manbasi bilan).
  final List<LessonBullet> bullets;
}

const _ap = '[’ʼʻ‘`\']?';

/// Savol bo‘lmaydigan slaydlar (sarlavha boshi, katta-kichik harf farqsiz).
final _service = RegExp(
  '^(?:'
  // «Kirish: …», «Xulosa va …» — xizmat slaydi; «Kirish yo‘llari»,
  // «Xulosani baholash» — haqiqiy savol (qoladi).
  'kirish(?:\\s*[:.—–-]|\$)|xulosa(?:\\s*[:.—–-]|\\s+va\\b|\$)|yakun|takrorlash|'
  'tezkor savol|nazorat savol|test savol|savol-javob|savollar|'
  'ma${_ap}ruza rejasi|dars rejasi|mavzu rejasi|reja\\b|'
  'mashg${_ap}ulot maqsadi|maqsad\\b|kutilayotgan natija|'
  'o${_ap}quv holat|vaziyatli masala|voqea tahlili|amaliy (?:keys|holat|mashq|ish)|'
  '\\d+-(?:keys|holat)|keys\\b|'
  'diqqat|eslatma|uyga vazifa|mustaqil (?:ish|ta${_ap}lim)|'
  '(?:foydalanilgan )?adabiyot|glossariy|trening|mashq\\b|«?charxpalak'
  ')',
  caseSensitive: false,
);

final _continued = RegExp(r'\s*\((?:davomi|davom)\)\s*$', caseSensitive: false);

/// «2-bo‘lim: …», «11-jadval: …» kabi raqamli boshlovchi.
final _numberedPrefix = RegExp(
  '^\\d+(?:[-–]\\s*| va \\d+-)(?:bo${_ap}lim|jadval(?:lar)?)\\s*[:.—–-]\\s*',
  caseSensitive: false,
);

/// Slayd sarlavhasidan savol matni; savol bo‘lmasa — bo‘sh.
String lessonOralQuestionText(String title) {
  var t = title.trim().replaceFirst(_continued, '').trim();
  t = t.replaceFirst(_numberedPrefix, '').trim();
  if (t.length < 4 || _service.hasMatch(t)) return '';
  return t;
}

/// Deck slaydlaridan savollar (tartib saqlanadi). «(davomi)» slaydi oldingi
/// shu nomli savolga qo‘shiladi; bandsiz slayd savol bo‘lmaydi; bir xil
/// savol takrorlanmaydi.
List<LessonOralQuestion> lessonOralQuestions(LessonDeck deck) {
  final topic = deck.topicId;
  final out = <LessonOralQuestion>[];
  final byText = <String, int>{};
  for (final (i, s) in deck.slides.indexed) {
    final text = lessonOralQuestionText(s.title);
    if (text.isEmpty || s.bullets.isEmpty) continue;
    final norm = text.toLowerCase();
    final prev = byText[norm];
    if (prev != null) {
      final p = out[prev];
      out[prev] = LessonOralQuestion(
        id: p.id,
        topicId: p.topicId,
        text: p.text,
        bullets: [...p.bullets, ...s.bullets],
      );
      continue;
    }
    byText[norm] = out.length;
    out.add(
      LessonOralQuestion(
        id: '$topic#$i',
        topicId: topic,
        text: text,
        bullets: s.bullets,
      ),
    );
  }
  return out;
}

/// Tanlangan mavzular uchun bilet: har mavzudan navbat bilan (savollar
/// mavzular bo‘yicha aralashadi), faqat hali ishlatilmaganlardan.
/// Ishlatilmagani [size] tadan kam qolsa — aylanish qaytadan boshlanadi
/// (`reset`); jami savol [size] dan kam bo‘lsa — hammasi.
({List<String> ids, bool reset}) drawTopicOralTicket({
  required Map<String, List<String>> pools,
  required Set<String> used,
  required math.Random rng,
  int size = 5,
}) {
  final all = [for (final p in pools.values) ...p];
  if (all.isEmpty) return (ids: const [], reset: false);
  var fresh = {
    for (final e in pools.entries)
      e.key: [
        for (final id in e.value)
          if (!used.contains(id)) id,
      ],
  };
  var reset = false;
  final freshCount = fresh.values.fold(0, (a, b) => a + b.length);
  if (freshCount < size && all.length >= size) {
    fresh = {
      for (final e in pools.entries) e.key: [...e.value],
    };
    reset = true;
  }
  final lists = [
    for (final k in fresh.keys.toList()..sort())
      if (fresh[k]!.isNotEmpty) [...fresh[k]!]..shuffle(rng),
  ]..shuffle(rng);
  final ids = <String>[];
  var round = 0;
  while (ids.length < size && lists.any((x) => round < x.length)) {
    for (final x in lists) {
      if (ids.length >= size) break;
      if (round < x.length) ids.add(x[round]);
    }
    round++;
  }
  return (ids: ids, reset: reset);
}

/// Tanlangan mavzular kaliti (tartibdan qat’i nazar bir xil).
String topicSelectionKey(Iterable<String> topicIds) =>
    (topicIds.toSet().toList()..sort()).join(',');
