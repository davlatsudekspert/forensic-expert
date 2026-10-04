/// Kutubxona domen modeli (Library ekrani va substance kartochkasi).
library;

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/foundation.dart';

enum LibrarySection { substances, methods, specimens, references, glossary }

/// Ko‘p tilli nom: `en`, `ru`, `uz`.
@immutable
class LocalizedText {
  const LocalizedText(this.values);

  final Map<String, String> values;

  String resolve(String languageCode) =>
      values[languageCode] ?? values['en'] ?? values.values.first;
}

@immutable
class LibraryEntry {
  const LibraryEntry({
    required this.id,
    required this.section,
    required this.name,
    required this.status,
    required this.isTestData,
    this.synonyms = const [],
    this.lastReviewed,
  });

  final String id;
  final LibrarySection section;
  final LocalizedText name;
  final List<String> synonyms;
  final ScientificStatus status;

  /// TEST DATA — UI buni har doim aniq belgilaydi.
  final bool isTestData;
  final DateTime? lastReviewed;
}

/// Kutubxona manbasi. PHASE 2: faqat TEST fixture’lar
/// (`FixtureLibraryRepository`). PHASE 3+: imzolangan kontent paketi.
abstract interface class LibraryRepository {
  List<LibraryEntry> entries(LibrarySection section);

  LibraryEntry? byId(String id);
}
