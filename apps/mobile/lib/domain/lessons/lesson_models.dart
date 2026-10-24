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

enum LessonDiagramKind {
  table,
  flow,
  steps,
  compare,
  tree,
  facts,
  reaction,
  cycle,
}

/// Diagramma limitlari (`docs/lessons/DECK_SPEC_V2.md`, 2-bo‘lim;
/// `tools/lessons/validate_deck.py` bilan bir xil).
abstract final class LessonDiagramLimits {
  static const caption = 80;
  static const stepsMax = 6;
  static const stepTitle = 30;
  static const stepText = 80;
  static const compareColsMin = 2;
  static const compareColsMax = 3;
  static const compareTitle = 24;
  static const compareItemsMax = 5;
  static const compareItem = 60;
  static const treeRoot = 30;
  static const treeChildrenMax = 6;
  static const treeLabel = 26;
  static const treeItemsMax = 3;
  static const treeItem = 40;
  static const factsMax = 6;
  static const factLabel = 24;
  static const factValue = 20;
  static const factUnit = 12;
  static const reactionSideMax = 3;
  static const reactionItem = 40;
  static const reactionConditions = 40;
  static const reactionObservation = 60;
  static const cycleMin = 3;
  static const cycleMax = 6;
  static const cycleNode = 28;
}

@immutable
class LessonStep {
  const LessonStep({required this.title, required this.text});
  final String title;
  final String text;
}

@immutable
class LessonCompareColumn {
  const LessonCompareColumn({required this.title, required this.items});
  final String title;
  final List<String> items;
}

@immutable
class LessonTreeNode {
  const LessonTreeNode({required this.label, this.items = const []});
  final String label;
  final List<String> items;
}

@immutable
class LessonFact {
  const LessonFact({required this.label, required this.value, this.unit = ''});
  final String label;
  final String value;
  final String unit;
}

/// Diagramma: `table`/`flow` (eski, bardoshli) va v2 turlari (`steps`,
/// `compare`, `tree`, `facts`, `reaction`, `cycle` — qat’iy limitlar bilan).
/// Noma’lum tur, limitdan oshgan yoki buzuq maydon — `null` (slayd
/// diagrammasiz ko‘rinadi, crash yo‘q).
@immutable
class LessonDiagram {
  const LessonDiagram({
    required this.kind,
    this.caption = '',
    this.header = const [],
    this.rows = const [],
    this.nodes = const [],
    this.steps = const [],
    this.columns = const [],
    this.root = '',
    this.children = const [],
    this.facts = const [],
    this.reagents = const [],
    this.conditions = '',
    this.products = const [],
    this.observation = '',
  });

  static LessonDiagram? tryParse(Object? raw) {
    if (raw is! Map) return null;
    try {
      final j = _m(raw);
      final k = j['kind'];
      if (k == null) return _legacy(j);
      if (k is! String) return null;
      switch (k.trim()) {
        case 'table':
        case 'flow':
          return _legacy(j, forced: k.trim());
        case 'steps':
          return _steps(j);
        case 'compare':
          return _compare(j);
        case 'tree':
          return _tree(j);
        case 'facts':
          return _facts(j);
        case 'reaction':
          return _reaction(j);
        case 'cycle':
          return _cycle(j);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Eski (v1) shakl: `header`+`rows` yoki `nodes`; bardoshli.
  static LessonDiagram? _legacy(Map<String, Object?> j, {String? forced}) {
    final caption = _s(j['caption']);
    final header = [for (final h in _l(j['header'])) _s(h)];
    if (header.isNotEmpty && forced != 'flow') {
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
    if (forced == 'table') return null;
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

  /// Matn majburiy emas, lekin bo‘lsa — limitdan oshmasligi kerak.
  static String? _opt(Object? v, int max) {
    if (v == null) return '';
    if (v is! String && v is! num) return null;
    final t = _s(v);
    return t.length > max ? null : t;
  }

  /// Majburiy matn: bo‘sh emas, limitdan oshmaydi.
  static String? _req(Object? v, int max) {
    if (v is! String && v is! num) return null;
    final t = _s(v);
    return t.isEmpty || t.length > max ? null : t;
  }

  /// Matnlar ro‘yxati; `lo..hi` soni, har biri `1..max` belgi; aks holda null.
  static List<String>? _strs(Object? v, int lo, int hi, int max) {
    if (v is! List || v.length < lo || v.length > hi) return null;
    final out = <String>[];
    for (final e in v) {
      final t = _req(e, max);
      if (t == null) return null;
      out.add(t);
    }
    return out;
  }

  static List<Map<String, Object?>>? _maps(Object? v, int lo, int hi) {
    if (v is! List || v.length < lo || v.length > hi) return null;
    final out = <Map<String, Object?>>[];
    for (final e in v) {
      if (e is! Map) return null;
      out.add(_m(e));
    }
    return out;
  }

  static LessonDiagram? _steps(Map<String, Object?> j) {
    final cap = _opt(j['caption'], LessonDiagramLimits.caption);
    final raw = _maps(j['items'], 2, LessonDiagramLimits.stepsMax);
    if (cap == null || raw == null) return null;
    final steps = <LessonStep>[];
    for (final e in raw) {
      final t = _req(e['title'], LessonDiagramLimits.stepTitle);
      final x = _opt(e['text'], LessonDiagramLimits.stepText);
      if (t == null || x == null) return null;
      steps.add(LessonStep(title: t, text: x));
    }
    return LessonDiagram(
      kind: LessonDiagramKind.steps,
      caption: cap,
      steps: steps,
    );
  }

  static LessonDiagram? _compare(Map<String, Object?> j) {
    final cap = _opt(j['caption'], LessonDiagramLimits.caption);
    final raw = _maps(
      j['columns'],
      LessonDiagramLimits.compareColsMin,
      LessonDiagramLimits.compareColsMax,
    );
    if (cap == null || raw == null) return null;
    final cols = <LessonCompareColumn>[];
    for (final e in raw) {
      final t = _req(e['title'], LessonDiagramLimits.compareTitle);
      final items = _strs(
        e['items'],
        1,
        LessonDiagramLimits.compareItemsMax,
        LessonDiagramLimits.compareItem,
      );
      if (t == null || items == null) return null;
      cols.add(LessonCompareColumn(title: t, items: items));
    }
    return LessonDiagram(
      kind: LessonDiagramKind.compare,
      caption: cap,
      columns: cols,
    );
  }

  static LessonDiagram? _tree(Map<String, Object?> j) {
    final cap = _opt(j['caption'], LessonDiagramLimits.caption);
    final root = _req(j['root'], LessonDiagramLimits.treeRoot);
    final raw = _maps(j['children'], 1, LessonDiagramLimits.treeChildrenMax);
    if (cap == null || root == null || raw == null) return null;
    final kids = <LessonTreeNode>[];
    for (final e in raw) {
      final label = _req(e['label'], LessonDiagramLimits.treeLabel);
      if (label == null) return null;
      var items = const <String>[];
      if (e['items'] != null) {
        final it = _strs(
          e['items'],
          0,
          LessonDiagramLimits.treeItemsMax,
          LessonDiagramLimits.treeItem,
        );
        if (it == null) return null;
        items = it;
      }
      kids.add(LessonTreeNode(label: label, items: items));
    }
    return LessonDiagram(
      kind: LessonDiagramKind.tree,
      caption: cap,
      root: root,
      children: kids,
    );
  }

  static LessonDiagram? _facts(Map<String, Object?> j) {
    final cap = _opt(j['caption'], LessonDiagramLimits.caption);
    final raw = _maps(j['items'], 1, LessonDiagramLimits.factsMax);
    if (cap == null || raw == null) return null;
    final facts = <LessonFact>[];
    for (final e in raw) {
      final label = _req(e['label'], LessonDiagramLimits.factLabel);
      final value = _req(e['value'], LessonDiagramLimits.factValue);
      final unit = _opt(e['unit'], LessonDiagramLimits.factUnit);
      if (label == null || value == null || unit == null) return null;
      facts.add(LessonFact(label: label, value: value, unit: unit));
    }
    return LessonDiagram(
      kind: LessonDiagramKind.facts,
      caption: cap,
      facts: facts,
    );
  }

  static LessonDiagram? _reaction(Map<String, Object?> j) {
    final cap = _opt(j['caption'], LessonDiagramLimits.caption);
    final cond = _opt(j['conditions'], LessonDiagramLimits.reactionConditions);
    final obs = _opt(j['observation'], LessonDiagramLimits.reactionObservation);
    final reagents = _strs(
      j['reagents'],
      1,
      LessonDiagramLimits.reactionSideMax,
      LessonDiagramLimits.reactionItem,
    );
    final products = _strs(
      j['products'],
      1,
      LessonDiagramLimits.reactionSideMax,
      LessonDiagramLimits.reactionItem,
    );
    if (cap == null ||
        cond == null ||
        obs == null ||
        reagents == null ||
        products == null) {
      return null;
    }
    return LessonDiagram(
      kind: LessonDiagramKind.reaction,
      caption: cap,
      reagents: reagents,
      conditions: cond,
      products: products,
      observation: obs,
    );
  }

  static LessonDiagram? _cycle(Map<String, Object?> j) {
    final cap = _opt(j['caption'], LessonDiagramLimits.caption);
    final nodes = _strs(
      j['nodes'],
      LessonDiagramLimits.cycleMin,
      LessonDiagramLimits.cycleMax,
      LessonDiagramLimits.cycleNode,
    );
    if (cap == null || nodes == null) return null;
    return LessonDiagram(
      kind: LessonDiagramKind.cycle,
      caption: cap,
      nodes: nodes,
    );
  }

  final LessonDiagramKind kind;
  final String caption;
  final List<String> header;
  final List<List<String>> rows;

  /// `flow` va `cycle` tugunlari.
  final List<String> nodes;
  final List<LessonStep> steps;
  final List<LessonCompareColumn> columns;
  final String root;
  final List<LessonTreeNode> children;
  final List<LessonFact> facts;
  final List<String> reagents;
  final String conditions;
  final List<String> products;
  final String observation;
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
