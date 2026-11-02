/// «Sud-tibbiy molekulyar-genetik ekspertiza (DNK)» bo‘limi (egasi talabi,
/// 2026-11-01): mavzular, sudda so‘roq savollari va manbalar.
///
/// Matn asli o‘zbekcha (`source_lang: uz`). Har gap manbaga tayanadi:
/// manbasi (yoki manbadagi joyi) yo‘q gap paketga kiritilmaydi, gapsiz
/// mavzu ko‘rsatilmaydi — to‘qilgan matn yo‘q.
library;

class DnaSource {
  const DnaSource({
    required this.id,
    required this.authors,
    required this.title,
    this.year,
    this.doi = '',
    this.url = '',
  });

  static DnaSource? fromJson(Map<String, Object?> j) {
    final id = _s(j['id']);
    final title = _s(j['title']);
    if (id.isEmpty || title.isEmpty) return null;
    return DnaSource(
      id: id,
      authors: _s(j['authors']),
      title: title,
      year: switch (j['year']) {
        final int y => y,
        final String y => int.tryParse(y),
        _ => null,
      },
      doi: _s(j['doi']),
      url: _s(j['url']),
    );
  }

  final String id;
  final String authors;
  final String title;
  final int? year;
  final String doi;
  final String url;

  /// «Muallif. Sarlavha, 2019» — bibliografiya o‘zgarmaydi.
  String get citation => [
    if (authors.isNotEmpty) authors,
    year == null ? title : '$title, $year',
  ].join('. ');
}

/// Bitta manbali gap: o‘zbekcha bayon + asl iqtibos + manbadagi joyi.
class DnaStatement {
  const DnaStatement({
    required this.uz,
    required this.quote,
    required this.source,
    required this.locator,
  });

  final String uz;
  final String quote;
  final DnaSource source;
  final String locator;
}

class DnaTopic {
  const DnaTopic({
    required this.id,
    required this.title,
    required this.statements,
    this.images = const [],
  });

  final String id;
  final String title;
  final List<DnaStatement> statements;

  /// Illyustratsiyalar (AI yordamida chizilgan; izoh bilan).
  final List<({String image, String caption})> images;
}

/// Sudda so‘roq: savol, to‘g‘ri javob va ekspert vakolati chegarasi.
class DnaCourtQuestion {
  const DnaCourtQuestion({
    required this.q,
    required this.answer,
    required this.boundary,
    required this.source,
    required this.locator,
  });

  final String q;
  final String answer;
  final String boundary;
  final DnaSource source;
  final String locator;
}

class DnaBundle {
  const DnaBundle({
    this.topics = const [],
    this.court = const [],
    this.sources = const {},
  });

  factory DnaBundle.fromJson(Map<String, Object?> j) {
    final sources = <String, DnaSource>{};
    for (final x in _l(j['sources'])) {
      if (x is! Map) continue;
      final s = DnaSource.fromJson(x.cast<String, Object?>());
      if (s != null) sources[s.id] = s;
    }
    DnaSource? src(Object? id) => sources[_s(id)];
    final topics = <DnaTopic>[];
    for (final t in _l(j['topics'])) {
      if (t is! Map) continue;
      final m = t.cast<String, Object?>();
      final statements = <DnaStatement>[
        for (final st in _l(m['statements']))
          if (st is Map)
            if ((_s(st['uz']), src(st['source_id']), _s(st['locator']))
                case (final uz, final s?, final loc)
                when uz.isNotEmpty && loc.isNotEmpty)
              DnaStatement(
                uz: uz,
                quote: _s(st['quote']),
                source: s,
                locator: loc,
              ),
      ];
      final id = _s(m['id']);
      final title = _s(m['title']);
      if (id.isEmpty || title.isEmpty || statements.isEmpty) continue;
      topics.add(
        DnaTopic(
          id: id,
          title: title,
          statements: statements,
          images: [
            for (final g in _l(m['images']))
              if (g is Map &&
                  _s(g['image']).isNotEmpty &&
                  _s(g['caption']).isNotEmpty)
                (
                  image: 'assets/images/instruments/${_s(g['image'])}.webp',
                  caption: _s(g['caption']),
                ),
          ],
        ),
      );
    }
    final court = <DnaCourtQuestion>[
      for (final c in _l(j['court_questions']))
        if (c is Map)
          if ((
                _s(c['q']),
                _s(c['good_answer_uz']),
                src(c['source_id']),
                _s(c['locator']),
              )
              case (final q, final a, final s?, final loc)
              when q.isNotEmpty && a.isNotEmpty && loc.isNotEmpty)
            DnaCourtQuestion(
              q: q,
              answer: a,
              boundary: _s(c['boundary_uz']),
              source: s,
              locator: loc,
            ),
    ];
    return DnaBundle(topics: topics, court: court, sources: sources);
  }

  static const empty = DnaBundle();

  final List<DnaTopic> topics;
  final List<DnaCourtQuestion> court;
  final Map<String, DnaSource> sources;

  bool get isEmpty => topics.isEmpty && court.isEmpty;

  DnaTopic? topic(String id) => topics.where((t) => t.id == id).firstOrNull;
}

String _s(Object? v) => v is String ? v.trim() : '';
List<Object?> _l(Object? v) => v is List ? v : const [];
