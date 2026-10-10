/// «Ekspert ish daftari» — mutaxassisning shaxsiy yozuvlari.
///
/// MAXFIYLIK: yozuvlar **faqat qurilmada** saqlanadi (SharedPreferences).
/// Serverga, telemetriyaga yoki AI’ga yuborilmaydi; ulashish faqat
/// foydalanuvchi o‘zi «Ulashish/Nusxa olish»ni bossa.
///
/// Daftar ilmiy xulosa emas: «manbali cheklov bayonlari» ilovadagi
/// yo‘riqnoma kartalaridan ko‘chiriladi (manba va joyi bilan), AI matni esa
/// faqat foydalanuvchi o‘zi qo‘shsa va doim «tekshirilmagan» deb belgilanadi.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Ilova obyekti turi (havola qaysi sahifaga olib borishini belgilaydi).
enum CasebookLinkKind {
  substance,
  knowledge,
  guideline,
  tool,
  research;

  static CasebookLinkKind? parse(Object? v) {
    for (final k in values) {
      if (k.name == '$v') return k;
    }
    return null;
  }
}

/// Ilova obyektiga havola (modda, usul, qo‘llanma kartasi, vosita, manba).
@immutable
class CasebookLink {
  const CasebookLink({
    required this.kind,
    required this.id,
    required this.label,
  });

  final CasebookLinkKind kind;
  final String id;

  /// Qo‘shilgan paytdagi nom (obyekt keyin o‘zgarsa ham daftarda o‘qiladi).
  final String label;

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'id': id,
    'label': label,
  };

  static CasebookLink? fromJson(Object? j) {
    if (j is! Map) return null;
    final kind = CasebookLinkKind.parse(j['kind']);
    final id = '${j['id'] ?? ''}'.trim();
    if (kind == null || id.isEmpty) return null;
    return CasebookLink(kind: kind, id: id, label: '${j['label'] ?? id}');
  }

  @override
  bool operator ==(Object other) =>
      other is CasebookLink && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);
}

/// Blok turi: `limitation`/`caution` — yo‘riqnoma kartasining manbali
/// bo‘limi; `ai` — foydalanuvchi o‘zi qo‘shgan AI javobi.
enum CasebookBlockKind {
  limitation,
  caution,
  ai;

  static CasebookBlockKind parse(Object? v) {
    for (final k in values) {
      if (k.name == '$v') return k;
    }
    return limitation;
  }
}

/// Blokka ko‘chirilgan manba (to‘liq iqtibos matni, sahifalari bilan).
@immutable
class CasebookCitation {
  const CasebookCitation({required this.text, this.pages, this.link});

  /// Bibliografik iqtibos (muallif, yil, sarlavha, jurnal…) — o‘zgarmaydi.
  final String text;

  /// Manbadagi sahifalar (bet), masalan `10-29`.
  final String? pages;

  /// DOI/PMID/URL (bo‘lsa).
  final String? link;

  Map<String, Object?> toJson() => {
    'text': text,
    'pages': ?pages,
    'link': ?link,
  };

  static CasebookCitation? fromJson(Object? j) {
    if (j is! Map) return null;
    final text = '${j['text'] ?? ''}'.trim();
    if (text.isEmpty) return null;
    String? s(String k) {
      final v = '${j[k] ?? ''}'.trim();
      return v.isEmpty ? null : v;
    }

    return CasebookCitation(text: text, pages: s('pages'), link: s('link'));
  }
}

@immutable
class CasebookBlock {
  const CasebookBlock({
    required this.id,
    required this.kind,
    required this.text,
    required this.lang,
    required this.addedAt,
    this.originId,
    this.originTitle,
    this.sectionTitle,
    this.citations = const [],
  });

  final String id;
  final CasebookBlockKind kind;

  /// Ko‘chirilgan matn (qo‘shilgan paytdagi tilda).
  final String text;
  final String lang;
  final DateTime addedAt;

  /// Manba yozuvi (yo‘riqnoma kartasi ID) va uning nomi.
  final String? originId;
  final String? originTitle;

  /// Aniq joyi: manbadagi bo‘lim sarlavhasi.
  final String? sectionTitle;
  final List<CasebookCitation> citations;

  /// AI matni har doim tekshirilmagan.
  bool get isAiUnverified => kind == CasebookBlockKind.ai;

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'text': text,
    'lang': lang,
    'added_at': addedAt.toUtc().toIso8601String(),
    'origin_id': ?originId,
    'origin_title': ?originTitle,
    'section_title': ?sectionTitle,
    'citations': [for (final c in citations) c.toJson()],
  };

  static CasebookBlock? fromJson(Object? j) {
    if (j is! Map) return null;
    final id = '${j['id'] ?? ''}'.trim();
    final text = '${j['text'] ?? ''}'.trim();
    if (id.isEmpty || text.isEmpty) return null;
    String? s(String k) {
      final v = '${j[k] ?? ''}'.trim();
      return v.isEmpty ? null : v;
    }

    return CasebookBlock(
      id: id,
      kind: CasebookBlockKind.parse(j['kind']),
      text: text,
      lang: s('lang') ?? 'uz',
      addedAt:
          DateTime.tryParse('${j['added_at'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      originId: s('origin_id'),
      originTitle: s('origin_title'),
      sectionTitle: s('section_title'),
      citations: [
        for (final c in (j['citations'] as List? ?? const []))
          ?CasebookCitation.fromJson(c),
      ],
    );
  }
}

@immutable
class CasebookEntry {
  const CasebookEntry({
    required this.id,
    required this.title,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.caseRef = '',
    this.body = '',
    this.links = const [],
    this.blocks = const [],
  });

  final String id;
  final String title;

  /// Ish belgisi (ixtiyoriy; foydalanuvchi o‘zi yozadi).
  final String caseRef;
  final DateTime date;
  final String body;
  final List<CasebookLink> links;
  final List<CasebookBlock> blocks;
  final DateTime createdAt;
  final DateTime updatedAt;

  CasebookEntry copyWith({
    String? title,
    String? caseRef,
    DateTime? date,
    String? body,
    List<CasebookLink>? links,
    List<CasebookBlock>? blocks,
    DateTime? updatedAt,
  }) => CasebookEntry(
    id: id,
    title: title ?? this.title,
    caseRef: caseRef ?? this.caseRef,
    date: date ?? this.date,
    body: body ?? this.body,
    links: links ?? this.links,
    blocks: blocks ?? this.blocks,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'case_ref': caseRef,
    'date': date.toIso8601String(),
    'body': body,
    'links': [for (final l in links) l.toJson()],
    'blocks': [for (final b in blocks) b.toJson()],
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  static CasebookEntry? fromJson(Object? j) {
    if (j is! Map) return null;
    final id = '${j['id'] ?? ''}'.trim();
    if (id.isEmpty) return null;
    final epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    return CasebookEntry(
      id: id,
      title: '${j['title'] ?? ''}',
      caseRef: '${j['case_ref'] ?? ''}',
      date: DateTime.tryParse('${j['date'] ?? ''}') ?? epoch,
      body: '${j['body'] ?? ''}',
      links: [
        for (final l in (j['links'] as List? ?? const []))
          ?CasebookLink.fromJson(l),
      ],
      blocks: [
        for (final b in (j['blocks'] as List? ?? const []))
          ?CasebookBlock.fromJson(b),
      ],
      createdAt: DateTime.tryParse('${j['created_at'] ?? ''}') ?? epoch,
      updatedAt: DateTime.tryParse('${j['updated_at'] ?? ''}') ?? epoch,
    );
  }
}

/// Saqlash formati: `{"v":1,"entries":[…]}`. Buzilgan matn — bo‘sh daftar.
abstract final class CasebookCodec {
  static String encode(List<CasebookEntry> entries) => jsonEncode({
    'v': 1,
    'entries': [for (final e in entries) e.toJson()],
  });

  static List<CasebookEntry> decode(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final j = jsonDecode(raw);
      if (j is! Map) return const [];
      return [
        for (final e in (j['entries'] as List? ?? const []))
          ?CasebookEntry.fromJson(e),
      ];
    } on Object {
      return const [];
    }
  }
}

/// Daftar ombori — faqat qurilmada.
abstract interface class CasebookStore {
  List<CasebookEntry> load();
  Future<void> save(List<CasebookEntry> entries);
  Future<void> clear();
}

class InMemoryCasebookStore implements CasebookStore {
  InMemoryCasebookStore([List<CasebookEntry> initial = const []])
    : _items = [...initial];

  List<CasebookEntry> _items;

  @override
  List<CasebookEntry> load() => List.unmodifiable(_items);

  @override
  Future<void> save(List<CasebookEntry> entries) async => _items = [...entries];

  @override
  Future<void> clear() async => _items = [];
}

/// Eksport matnidagi (tilga bog‘liq) yorliqlar — UI l10n’dan beradi.
@immutable
class CasebookExportLabels {
  const CasebookExportLabels({
    required this.disclaimer,
    required this.caseRef,
    required this.date,
    required this.linksTitle,
    required this.blocksTitle,
    required this.sourceLabel,
    required this.locationLabel,
    required this.pagesLabel,
    required this.sourcesTitle,
    required this.aiUnverified,
    required this.untitled,
    required this.footer,
    required this.dateText,
  });

  /// «Bu ekspert xulosasi emas» ogohlantirishi (har eksportda).
  final String disclaimer;
  final String caseRef;
  final String date;
  final String linksTitle;
  final String blocksTitle;
  final String sourceLabel;
  final String locationLabel;
  final String pagesLabel;
  final String sourcesTitle;
  final String aiUnverified;
  final String untitled;
  final String footer;

  /// Sanani tilga mos formatlash.
  final String Function(DateTime) dateText;
}

/// Yozuvni oddiy matnga aylantiradi (ulashish/nusxa olish uchun).
abstract final class CasebookExporter {
  static String text(CasebookEntry e, CasebookExportLabels l) {
    final b = StringBuffer();
    b.writeln(e.title.trim().isEmpty ? l.untitled : e.title.trim());
    b.writeln(
      [
        if (e.caseRef.trim().isNotEmpty) '${l.caseRef}: ${e.caseRef.trim()}',
        '${l.date}: ${l.dateText(e.date)}',
      ].join(' · '),
    );
    b.writeln();
    b.writeln(l.disclaimer);
    if (e.body.trim().isNotEmpty) {
      b.writeln();
      b.writeln(e.body.trim());
    }
    if (e.links.isNotEmpty) {
      b.writeln();
      b.writeln('${l.linksTitle}:');
      for (final k in e.links) {
        b.writeln('• ${k.label}');
      }
    }
    // Iqtiboslar blok ichida raqamlanadi: matndagi [n] shu blokning
    // «Manbalar» ro‘yxatiga mos keladi.
    if (e.blocks.isNotEmpty) {
      b.writeln();
      b.writeln('${l.blocksTitle}:');
      for (var i = 0; i < e.blocks.length; i++) {
        final k = e.blocks[i];
        b.writeln();
        b.writeln('${i + 1}. ${k.text.trim()}');
        if (k.isAiUnverified) b.writeln('   ⚠ ${l.aiUnverified}');
        final origin = [
          if (k.originTitle != null) '${l.sourceLabel}: ${k.originTitle}',
          if (k.sectionTitle != null) '${l.locationLabel}: ${k.sectionTitle}',
        ];
        if (origin.isNotEmpty) b.writeln('   ${origin.join('; ')}');
        if (k.citations.isNotEmpty) {
          b.writeln('   ${l.sourcesTitle}:');
          for (var n = 0; n < k.citations.length; n++) {
            b.writeln('   [${n + 1}] ${_citationLine(k.citations[n], l)}');
          }
        }
      }
    }
    b.writeln();
    b.writeln(l.footer);
    return b.toString().trimRight();
  }

  static String _citationLine(CasebookCitation c, CasebookExportLabels l) {
    final parts = <String>[
      c.text,
      if (c.pages != null && !c.text.contains(c.pages!))
        '${l.pagesLabel}: ${c.pages}',
      ?c.link,
    ];
    return parts.join(' ');
  }
}
