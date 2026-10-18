/// «Darslar» — ustozlar uchun ma’ruza prezentatsiyalari (faqat ilova ichida
/// ko‘rish). Server: `supabase/migrations/20261018020000_lesson_decks.sql`
/// (`lesson_list`, `lesson_get`). Hamma maydon himoyalangan holda o‘qiladi:
/// ixtiyoriy maydon yo‘q bo‘lsa — bo‘sh qiymat, ilova yiqilmaydi.
library;

import 'package:flutter/foundation.dart';

String _s(Object? v) => v is String ? v.trim() : (v is num ? '$v' : '');
List<Object?> _l(Object? v) => v is List ? v : const [];
Map<String, Object?> _m(Object? v) =>
    v is Map ? v.cast<String, Object?>() : const {};

/// Ro‘yxat qatori.
@immutable
class LessonSummary {
  const LessonSummary({
    required this.topicId,
    required this.deckId,
    required this.course,
    required this.title,
    required this.slides,
  });

  factory LessonSummary.fromJson(Map<String, Object?> j) => LessonSummary(
    topicId: _s(j['topic_id']),
    deckId: _s(j['deck_id']),
    course: _s(j['course']),
    title: _s(j['title']),
    slides: j['slides'] is num ? (j['slides'] as num).toInt() : 0,
  );

  final String topicId;
  final String deckId;
  final String course;
  final String title;
  final int slides;
}

/// Kurs bo‘yicha guruh (tartib saqlanadi).
@immutable
class LessonGroup {
  const LessonGroup(this.course, this.items);

  final String course;
  final List<LessonSummary> items;
}

abstract final class LessonGrouping {
  /// Serverdan kelgan tartibni saqlab, kurs bo‘yicha guruhlaydi.
  static List<LessonGroup> group(Iterable<LessonSummary> all) {
    final order = <String>[];
    final map = <String, List<LessonSummary>>{};
    for (final s in all) {
      (map[s.course] ??= (() {
        order.add(s.course);
        return <LessonSummary>[];
      })()).add(s);
    }
    return [for (final c in order) LessonGroup(c, map[c]!)];
  }

  /// Tezkor mahalliy filtr (sarlavha va kurs bo‘yicha, registrsiz).
  static List<LessonSummary> filter(List<LessonSummary> all, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return [
      for (final s in all)
        if (s.title.toLowerCase().contains(q) ||
            s.course.toLowerCase().contains(q))
          s,
    ];
  }
}

@immutable
class LessonSource {
  const LessonSource({this.author = '', this.title = '', this.page = ''});

  factory LessonSource.fromJson(Object? raw) {
    final j = _m(raw);
    return LessonSource(
      author: _s(j['author']),
      title: _s(j['title']),
      page: _s(j['page']),
    );
  }

  final String author;
  final String title;
  final String page;

  bool get isEmpty => author.isEmpty && title.isEmpty;
}

@immutable
class LessonBullet {
  const LessonBullet({
    required this.text,
    this.source = const LessonSource(),
    this.uncertain = false,
  });

  factory LessonBullet.fromJson(Object? raw) {
    if (raw is String) return LessonBullet(text: raw.trim());
    final j = _m(raw);
    return LessonBullet(
      text: _s(j['text']),
      source: LessonSource.fromJson(j['source']),
      uncertain: j['uncertain'] == true,
    );
  }

  final String text;
  final LessonSource source;
  final bool uncertain;
}

enum LessonDiagramKind { table, flow }

/// Oddiy diagramma: jadval (`header` + `rows`) yoki ketma-ket tugunlar.
/// Noma’lum/bo‘sh shakl — `null` (o‘tkazib yuboriladi).
@immutable
class LessonDiagram {
  const LessonDiagram({
    required this.kind,
    this.caption = '',
    this.header = const [],
    this.rows = const [],
    this.nodes = const [],
  });

  static LessonDiagram? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final j = _m(raw);
    final caption = _s(j['caption']);
    final header = [for (final h in _l(j['header'])) _s(h)];
    if (header.isNotEmpty) {
      final rows = <List<String>>[];
      for (final r in _l(j['rows'])) {
        final cells = [for (final c in _l(r)) _s(c)];
        if (cells.isEmpty) continue;
        while (cells.length < header.length) {
          cells.add('');
        }
        rows.add(cells.take(header.length).toList());
      }
      return LessonDiagram(
        kind: LessonDiagramKind.table,
        caption: caption,
        header: header,
        rows: rows,
      );
    }
    final nodes = [
      for (final n in _l(j['nodes']))
        if (_s(n).isNotEmpty) _s(n),
    ];
    if (nodes.isEmpty) return null;
    return LessonDiagram(
      kind: LessonDiagramKind.flow,
      caption: caption,
      nodes: nodes,
    );
  }

  final LessonDiagramKind kind;
  final String caption;
  final List<String> header;
  final List<List<String>> rows;
  final List<String> nodes;
}

@immutable
class LessonSlide {
  const LessonSlide({
    required this.title,
    this.bullets = const [],
    this.teacherNotes = '',
    this.diagram,
  });

  factory LessonSlide.fromJson(Object? raw) {
    final j = _m(raw);
    return LessonSlide(
      title: _s(j['title']),
      bullets: [
        for (final b in _l(j['bullets']))
          if (LessonBullet.fromJson(b).text.isNotEmpty)
            LessonBullet.fromJson(b),
      ],
      teacherNotes: _s(j['teacher_notes']),
      diagram: LessonDiagram.tryParse(j['diagram']),
    );
  }

  final String title;
  final List<LessonBullet> bullets;
  final String teacherNotes;
  final LessonDiagram? diagram;

  /// Slayd manbalari (takrorlarsiz): «Muallif, Sarlavha, bet N».
  List<LessonSource> get sources {
    final seen = <String>{};
    final out = <LessonSource>[];
    for (final b in bullets) {
      if (b.source.isEmpty) continue;
      final k = '${b.source.author}|${b.source.title}|${b.source.page}';
      if (seen.add(k)) out.add(b.source);
    }
    return out;
  }
}

@immutable
class LessonExtra {
  const LessonExtra({required this.text, this.source = const LessonSource()});

  factory LessonExtra.fromJson(Object? raw) {
    if (raw is String) return LessonExtra(text: raw.trim());
    final j = _m(raw);
    return LessonExtra(
      text: _s(j['text']),
      source: LessonSource.fromJson(j['source']),
    );
  }

  final String text;
  final LessonSource source;
}

@immutable
class LessonReference {
  const LessonReference({
    this.author = '',
    this.title = '',
    this.year = '',
    this.pages = '',
  });

  factory LessonReference.fromJson(Object? raw) {
    final j = _m(raw);
    return LessonReference(
      author: _s(j['author']),
      title: _s(j['title']),
      year: _s(j['year']),
      pages: _s(j['pages']),
    );
  }

  final String author;
  final String title;
  final String year;
  final String pages;

  /// «Muallif. Sarlavha. Yil. Sahifalar». Sarlavhada yil bo‘lsa, takrorlanmaydi.
  String get line => [author, title, if (!title.contains(year)) year, pages]
      .where((e) => e.isNotEmpty)
      .map((e) => e.endsWith('.') ? e.substring(0, e.length - 1) : e)
      .join('. ');
}

/// To‘liq dars (prezentatsiya).
@immutable
class LessonDeck {
  const LessonDeck({
    required this.topicId,
    required this.title,
    required this.course,
    required this.deckId,
    required this.sourceLang,
    required this.slides,
    this.extras = const [],
    this.references = const [],
  });

  /// `lesson_get` javobi (`{ok, topic_id, title, course, deck_id, source_lang,
  /// deck:{topic, slides, extras, sources}}`).
  factory LessonDeck.fromJson(Map<String, Object?> j) {
    final d = _m(j['deck']);
    final title = _s(j['title']).isNotEmpty ? _s(j['title']) : _s(d['topic']);
    return LessonDeck(
      topicId: _s(j['topic_id']),
      title: title,
      course: _s(j['course']),
      deckId: _s(j['deck_id']),
      sourceLang: _s(j['source_lang']).isEmpty ? 'uz' : _s(j['source_lang']),
      slides: [for (final s in _l(d['slides'])) LessonSlide.fromJson(s)],
      extras: [
        for (final e in _l(d['extras']))
          if (LessonExtra.fromJson(e).text.isNotEmpty) LessonExtra.fromJson(e),
      ],
      references: [
        for (final r in _l(d['sources'])) LessonReference.fromJson(r),
      ],
    );
  }

  final String topicId;
  final String title;
  final String course;
  final String deckId;
  final String sourceLang;
  final List<LessonSlide> slides;
  final List<LessonExtra> extras;
  final List<LessonReference> references;
}
