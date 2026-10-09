import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/glossary/glossary.dart';
import '../domain/guidelines/guideline_models.dart';
import 'guidelines.dart';
import 'providers.dart';

/// Kanonik qisqartmalar izohi (ilovaga qo‘shilgan, ochiq kontent).
const abbreviationGlossaryAsset =
    'assets/content/terminology/abbreviation_glossary.json';

final abbreviationNotesLoaderProvider = Provider<Future<String> Function()>(
  (ref) =>
      () => rootBundle.loadString(abbreviationGlossaryAsset),
);

/// PMI, PMR, GC-MS, LC-MS/MS, HPLC, TLC, Rf, Vd, COHb — qisqa izohlar.
/// Fayl yo‘q yoki buzilgan bo‘lsa — bo‘sh (havolalar ko‘rsatilmaydi).
final abbreviationNotesProvider = FutureProvider<List<AbbreviationNote>>((
  ref,
) async {
  try {
    final text = await ref.watch(abbreviationNotesLoaderProvider)();
    return AbbreviationNote.listFromJson(jsonDecode(text));
  } on Object {
    return const [];
  }
});

/// «Ilmiy lug‘at»: paketdagi termin tarjimalari + yo‘riqnoma kartalaridagi
/// aniq `term_ids` bog‘lanishlari + qisqartmalar izohi. Paket yuklanmaguncha —
/// faqat qisqartmalar.
final glossaryProvider = Provider<Glossary>(
  (ref) => Glossary.build(
    ref.watch(provenanceIndexProvider).terms,
    ref.watch(guidelinesProvider).value ?? GuidelineBundle.empty,
    abbreviations: ref.watch(abbreviationNotesProvider).value ?? const [],
  ),
);
