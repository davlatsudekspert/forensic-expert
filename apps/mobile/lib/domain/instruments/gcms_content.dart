import 'package:flutter/foundation.dart';

/// Uch tilli matn: tilga mos qiymat; yo‘q bo‘lsa inglizcha (to‘qima yo‘q).
@immutable
class LocalizedText {
  const LocalizedText(this._m);

  factory LocalizedText.from(Object? v) => LocalizedText({
    if (v is Map)
      for (final e in v.entries)
        if (e.key is String && e.value is String)
          e.key as String: e.value as String,
  });

  final Map<String, String> _m;

  String of(String lang) => _m[lang] ?? _m['en'] ?? '';

  bool hasAll(List<String> langs) =>
      langs.every((l) => (_m[l] ?? '').trim().isNotEmpty);
}

@immutable
class GcMsPart {
  const GcMsPart({
    required this.number,
    required this.name,
    required this.function,
  });

  final int number;
  final LocalizedText name;
  final LocalizedText function;
}

@immutable
class GcMsSource {
  const GcMsSource({
    required this.title,
    required this.publisher,
    required this.url,
  });

  final String title;
  final String publisher;
  final String url;
}

/// LabGuide’dan olingan «GC-MS» moduli: original sinf sxemasi + uch tilli
/// matnlar. Matnlar JSON’dan o‘zgartirilmasdan ko‘rsatiladi.
@immutable
class GcMsContent {
  const GcMsContent({
    required this.title,
    required this.alt,
    required this.caption,
    required this.note,
    required this.parts,
    required this.principle,
    required this.result,
    required this.tasks,
    required this.source,
  });

  factory GcMsContent.fromJson(
    Map<String, Object?> parts,
    Map<String, Object?> card,
  ) {
    final c = (card['card']! as Map).cast<String, Object?>();
    final tasks = (c['tasks'] as List?) ?? const [];
    final sources = (card['sources'] as List?) ?? const [];
    final s = sources.isEmpty
        ? const <String, Object?>{}
        : (sources.first as Map).cast<String, Object?>();
    return GcMsContent(
      title: LocalizedText.from(parts['title']),
      alt: LocalizedText.from(parts['alt_text']),
      caption: LocalizedText.from(parts['not_a_photo_caption']),
      note: LocalizedText.from(parts['not_a_photo_note']),
      parts: [
        for (final p in (parts['parts']! as List))
          GcMsPart(
            number: ((p as Map)['n']! as num).toInt(),
            name: LocalizedText.from(p['name']),
            function: LocalizedText.from(p['function']),
          ),
      ],
      principle: LocalizedText.from(parts['principle']),
      result: LocalizedText.from(parts['result']),
      tasks: [for (final t in tasks) LocalizedText.from((t as Map)['text'])],
      source: GcMsSource(
        title: (s['title'] as String?) ?? '',
        publisher: (s['publisher'] as String?) ?? '',
        url: (s['url'] as String?) ?? '',
      ),
    );
  }

  final LocalizedText title;
  final LocalizedText alt;
  final LocalizedText caption;
  final LocalizedText note;
  final List<GcMsPart> parts;
  final LocalizedText principle;
  final LocalizedText result;

  /// Katalog kartasidagi manbali «qo‘llanishi» jumlasi (sud toksikologiyasi).
  final List<LocalizedText> tasks;
  final GcMsSource source;
}
