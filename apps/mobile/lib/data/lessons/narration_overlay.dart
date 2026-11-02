import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/lessons/lesson_models.dart';

/// Ilova ichidagi ovozli tushuntirishlar (`assets/content/narration/<deck>.json`).
///
/// Server dekida slayd `narration` bo‘sh bo‘lsa, shu yerdagi matn qo‘yiladi —
/// faqat slayd sarlavhasi aynan mos kelsa (server slaydi o‘zgargan bo‘lsa,
/// eski matn o‘qilmaydi). Fayl: `[{"t": "<sarlavha>", "n": "<matn>"}, …]`.
abstract interface class NarrationSource {
  Future<List<({String title, String text})>?> load(String deckId);
}

class AssetNarrationSource implements NarrationSource {
  const AssetNarrationSource();

  static final _safeId = RegExp(r'^[A-Za-z0-9_-]+$');

  @override
  Future<List<({String title, String text})>?> load(String deckId) async {
    if (!_safeId.hasMatch(deckId)) return null;
    try {
      final raw = await rootBundle.loadString(
        'assets/content/narration/$deckId.json',
      );
      final list = jsonDecode(raw);
      if (list is! List) return null;
      return [
        for (final e in list)
          if (e is Map)
            (
              title: e['t'] is String ? e['t'] as String : '',
              text: e['n'] is String ? e['n'] as String : '',
            ),
      ];
    } on Object {
      return null; // fayl yo‘q yoki buzuq — tushuntirishsiz.
    }
  }
}

/// Tushuntirishsiz manba (sinovlar va demo uchun).
class NoNarrationSource implements NarrationSource {
  const NoNarrationSource();

  @override
  Future<List<({String title, String text})>?> load(String deckId) async =>
      null;
}

/// Bo‘sh `narration`larni mos sarlavhali ilova matni bilan to‘ldiradi.
/// Faqat o‘zbekcha (asl tili `uz`) dekka qo‘llanadi.
LessonDeck applyNarration(
  LessonDeck deck,
  List<({String title, String text})>? items,
) {
  if (items == null || items.isEmpty || deck.sourceLang != 'uz') return deck;
  var changed = false;
  final slides = <LessonSlide>[];
  for (var i = 0; i < deck.slides.length; i++) {
    final s = deck.slides[i];
    if (s.narration.trim().isEmpty && i < items.length) {
      final it = items[i];
      if (it.text.trim().isNotEmpty && it.title.trim() == s.title.trim()) {
        slides.add(s.withNarration(it.text.trim()));
        changed = true;
        continue;
      }
    }
    slides.add(s);
  }
  return changed ? deck.withSlides(slides) : deck;
}
