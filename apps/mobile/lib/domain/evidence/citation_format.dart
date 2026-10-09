/// Iqtibos eksporti: mavjud manba maydonlaridan bibliografik yozuv.
///
/// Uslublar: GOST R 7.0.100-2018 (O‘zbekiston/MDH ekspert xulosalari —
/// adabiyotlar ro‘yxatidagi qisqa shakl, GOST R 7.0.5 amaliyotiga mos),
/// Vancouver (ICMJE/NLM) va APA 7.
///
/// Qoida: faqat mavjud maydonlar ishlatiladi. Yo‘q maydon (muallif, tom,
/// sahifa, sana…) to‘qib chiqarilmaydi — yozuvdan tushirib qoldiriladi.
/// Ilova — ma’lumotnoma vosita; ro‘yxatni ekspert asl manba bilan
/// tekshiradi.
library;

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/foundation.dart';

import '../guidelines/guideline_models.dart';
import '../library/library_models.dart';
import 'evidence_models.dart';

enum CitationStyle { gost, vancouver, apa }

/// GOST’dagi belgilangan elementlar tili («[Elektron resurs]»,
/// «murojaat sanasi») — ro‘yxat (xulosa) tili.
enum CitationLang { uz, ru, en }

/// Bibliografik tur — yozuv shakli shunga qarab tanlanadi.
enum CitationKind {
  /// Jurnal maqolasi.
  article,

  /// To‘plam/kitob ichidagi bob (maqola shaklida, `//` bilan).
  chapter,

  /// Kitob, o‘quv qo‘llanma, monografiya, dissertatsiya.
  book,

  /// Veb-sahifa yoki ma’lumotlar bazasi yozuvi.
  web,

  /// Standart, yo‘riqnoma, me’yoriy hujjat, rasmiy hisobot.
  document,
}

CitationLang citationLangOf(String languageCode) => switch (languageCode) {
  'ru' => CitationLang.ru,
  'en' => CitationLang.en,
  _ => CitationLang.uz,
};

/// Interfeys tili bo‘yicha standart uslub: uz/ru — GOST, en — APA.
CitationStyle defaultCitationStyle(String languageCode) =>
    languageCode == 'en' ? CitationStyle.apa : CitationStyle.gost;

@immutable
class CitationData {
  const CitationData({
    required this.kind,
    required this.title,
    this.authors = const [],
    this.etAl = false,
    this.subtitle,
    this.container,
    this.publisher,
    this.place,
    this.year,
    this.edition,
    this.volume,
    this.issue,
    this.pages,
    this.doi,
    this.pmid,
    this.url,
    this.accessed,
    this.language,
  });

  /// Kontent paketidagi manba (`sources`).
  factory CitationData.fromSource(SourceView s) {
    final kind = _kindOf(s.sourceType);
    final authors = s.authors;
    final orgAsAuthor =
        _splitEtAl(authors).$1.isEmpty &&
        s.organization != null &&
        (kind == CitationKind.web || kind == CitationKind.document);
    return CitationData(
      kind: kind,
      title: s.title,
      authors: orgAsAuthor ? [s.organization!] : authors,
      container: s.journal,
      publisher: orgAsAuthor ? null : _publisherOf(kind, s.organization),
      year: s.year?.toString(),
      edition: s.edition,
      doi: s.doi,
      pmid: s.pmid,
      url: s.url,
      accessed: s.accessedDate,
      language: s.language,
    );
  }

  /// Research kutubxonasi yozuvi.
  factory CitationData.fromResearch(ResearchEntry r) {
    final kind = switch (r.kind) {
      ResearchKind.dissertation || ResearchKind.thesis => CitationKind.book,
      ResearchKind.standard ||
      ResearchKind.guideline ||
      ResearchKind.officialReport => CitationKind.document,
      _ => CitationKind.article,
    };
    final authors = r.authors;
    final orgAsAuthor =
        _splitEtAl(authors).$1.isEmpty &&
        r.organization != null &&
        kind == CitationKind.document;
    return CitationData(
      kind: kind,
      title: r.title,
      authors: orgAsAuthor ? [r.organization!] : authors,
      subtitle: kind == CitationKind.book ? r.degree : null,
      container: r.container,
      publisher: orgAsAuthor ? null : _publisherOf(kind, r.organization),
      year: r.year,
      doi: r.doi,
      pmid: r.pmid,
      url: r.url,
      accessed: r.accessedDate,
      language: r.language,
    );
  }

  /// Yo‘riqnoma kartasidagi adabiyot (`references.json`).
  factory CitationData.fromGuidelineReference(GuidelineReference g) {
    final kind = _kindOf(g.type ?? 'journal_article');
    final authors = g.authors;
    return CitationData(
      kind: kind,
      // Tuzilgan sarlavha bo‘lmasa — tayyor matn (eski format).
      title: g.title ?? g.citation,
      authors: g.title == null ? const [] : authors,
      container: g.journal,
      publisher: g.publisher,
      year: g.year,
      volume: g.volume,
      issue: g.issue,
      pages: g.pages,
      doi: g.doi,
      pmid: g.pmid,
      url: g.url,
      accessed: g.verifiedOn,
    );
  }

  final CitationKind kind;
  final String title;

  /// Mualliflar: PubMed shakli («Kugelberg FC»), nuqtali («Yuldashev Z.A.»)
  /// yoki tashkilot nomi (o‘zgarishsiz qoladi).
  final List<String> authors;

  /// Ro‘yxatdan keyin boshqa mualliflar ham bor («va boshq.»).
  final bool etAl;

  /// Nashr turi / sarlavhaga oid ma’lumot («O‘quv qo‘llanma»).
  final String? subtitle;

  /// Jurnal yoki to‘plam nomi.
  final String? container;
  final String? publisher;
  final String? place;
  final String? year;
  final String? edition;
  final String? volume;
  final String? issue;
  final String? pages;
  final String? doi;
  final String? pmid;
  final String? url;
  final DateTime? accessed;

  /// Manba tili (ISO 639-1) — «Т./Vol.», «[и др.]/[et al.]» shunga qarab.
  final String? language;
}

CitationKind _kindOf(String type) => switch (type) {
  'journal_article' || 'review' || 'case_report' => CitationKind.article,
  'book_chapter' => CitationKind.chapter,
  'book' || 'textbook' || 'monograph' => CitationKind.book,
  'database' || 'website' => CitationKind.web,
  _ => CitationKind.document,
};

String? _publisherOf(CitationKind kind, String? org) =>
    kind == CitationKind.article || kind == CitationKind.chapter ? null : org;

final _etAlMarker = RegExp(
  r'[,;]?\s*(\[?\s*(va boshq\.?|va b\.|et al\.?|и др\.?)\s*\]?)$',
  caseSensitive: false,
);

/// «… va boshq.» / «et al.» belgisini mualliflar ro‘yxatidan ajratadi.
(List<String>, bool) _splitEtAl(List<String> raw) {
  var etAl = false;
  final out = <String>[];
  for (final a in raw) {
    final m = _etAlMarker.firstMatch(a.trim());
    if (m != null) {
      etAl = true;
      final rest = a.trim().substring(0, m.start).trim();
      if (rest.isNotEmpty) out.add(rest);
    } else if (a.trim().isNotEmpty) {
      out.add(a.trim());
    }
  }
  return (out, etAl);
}

/// Mualliflar (tahlil qilingan) va «va boshq.» belgisi.
(List<_Name>, bool) _names(CitationData d) {
  final (list, marker) = _splitEtAl(d.authors);
  return ([for (final a in list) _Name.parse(a)], d.etAl || marker);
}

/// Shaxs nomi: familiya + initsiallar. Tashkilot — [corporate].
@immutable
class _Name {
  const _Name(this.family, this.initials) : corporate = null;
  const _Name.corporate(String this.corporate)
    : family = '',
      initials = const [];

  final String family;
  final List<String> initials;
  final String? corporate;

  static final _dotted = RegExp(
    r"^(.+?),?\s+((?:[A-ZА-ЯЁЎҚҒҲ][a-zа-яё‘ʻ']?\.\s?){1,3})$",
  );
  static final _plain = RegExp(r'^(.+?)\s+([A-ZА-ЯЁ]{1,3})$');
  static final _initial = RegExp(r"[A-ZА-ЯЁЎҚҒҲ][a-zа-яё‘ʻ']?");

  static _Name parse(String raw) {
    final s = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    final m = _dotted.firstMatch(s) ?? _plain.firstMatch(s);
    if (m != null) {
      final family = m[1]!.trim();
      // Familiya 1–3 so‘z, raqam va qavslarsiz — aks holda tashkilot.
      if (family.split(' ').length <= 3 &&
          !RegExp(r'[\d()&]').hasMatch(family)) {
        final ini = m[2]!.contains('.')
            ? [for (final x in _initial.allMatches(m[2]!)) x[0]!]
            : m[2]!.split('');
        return _Name(family, ini);
      }
    }
    return _Name.corporate(s);
  }

  bool get isPerson => corporate == null;

  /// GOST sarlavhasi: «Kugelberg F.C.».
  String get gostHeading =>
      corporate ?? '$family ${[for (final i in initials) '$i.'].join()}';

  /// GOST mas’uliyat qismi: «F.C. Kugelberg».
  String get gostStatement =>
      corporate ?? '${[for (final i in initials) '$i.'].join()} $family';

  /// Vancouver: «Kugelberg FC».
  String get vancouver => corporate ?? '$family ${initials.join()}';

  /// APA: «Kugelberg, F. C.».
  String get apa =>
      corporate ?? '$family, ${[for (final i in initials) '$i.'].join(' ')}';
}

String _end(String s) {
  final t = s.trimRight();
  return RegExp(r'[.?!]$').hasMatch(t) ? t : '$t.';
}

String _two(int n) => n.toString().padLeft(2, '0');

String _gostDate(DateTime d) => '${_two(d.day)}.${_two(d.month)}.${d.year}';

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _range(String pages, {required bool dash}) =>
    dash ? pages.replaceAll(RegExp(r'\s*[-–—]\s*'), '–') : pages;

bool _hasCyrillic(String s) => RegExp('[А-Яа-яЁё]').hasMatch(s);

/// Manba tili: aniq maydon → «va boshq./и др.» belgisi → kirillcha sarlavha.
String _sourceLang(CitationData d) {
  final l = d.language?.toLowerCase();
  if (l != null && l.isNotEmpty) return l.split(RegExp('[-_]')).first;
  final all = [...d.authors, d.title].join(' ');
  if (_hasCyrillic(all)) return 'ru';
  if (RegExp(r'va (boshq|b)\.').hasMatch(all) || RegExp('[‘ʻ]').hasMatch(all)) {
    return 'uz';
  }
  return 'en';
}

/// Bitta manba uchun bibliografik yozuv.
String formatCitation(
  CitationData d,
  CitationStyle style, {
  CitationLang lang = CitationLang.uz,
}) => switch (style) {
  CitationStyle.gost => _gost(d, lang),
  CitationStyle.vancouver => _vancouver(d),
  CitationStyle.apa => _apa(d),
};

/// Raqamlangan ro‘yxat («1. …\n2. …») — ekspert xulosasiga qo‘yish uchun.
String formatReferenceList(
  List<CitationData> items,
  CitationStyle style, {
  CitationLang lang = CitationLang.uz,
}) => [
  for (final (i, d) in items.indexed)
    '${i + 1}. ${formatCitation(d, style, lang: lang)}',
].join('\n');

// ------------------------------------------------------------------- GOST

String _gost(CitationData d, CitationLang lang) {
  final srcLang = _sourceLang(d);
  final (gmd, accessedLabel) = switch (lang) {
    CitationLang.uz => ('[Elektron resurs]', 'murojaat sanasi'),
    CitationLang.ru => ('[Электронный ресурс]', 'дата обращения'),
    CitationLang.en => ('[Electronic resource]', 'accessed'),
  };
  final etAlMark = switch (srcLang) {
    'ru' => '[и др.]',
    'uz' => '[va boshq.]',
    _ => '[et al.]',
  };
  final (volL, noL, pL) = switch (srcLang) {
    'ru' => ('Т.', '№', 'С.'),
    'uz' => ('J.', '№', 'B.'),
    _ => ('Vol.', 'No.', 'P.'),
  };

  final (names, etAl) = _names(d);
  final persons = [
    for (final n in names)
      if (n.isPerson) n,
  ];
  final corporate = [
    for (final n in names)
      if (!n.isPerson) n.gostHeading,
  ];
  final isSerial =
      d.kind == CitationKind.article || d.kind == CitationKind.chapter;
  // Onlayn manzil: veb/hujjat/kitobda — har doim; maqolada — faqat DOI ham,
  // PMID ham bo‘lmasa (aks holda identifikator yetarli).
  final withUrl =
      d.url != null && (!isSerial || (d.doi == null && d.pmid == null));

  String? heading;
  final statement = <String>[];
  if (persons.isNotEmpty) {
    if (persons.length <= 3 && !etAl) {
      heading = persons.map((n) => n.gostHeading).join(', ');
    } else if (persons.length <= 3) {
      heading = persons.first.gostHeading;
      statement.add(
        '${persons.map((n) => n.gostStatement).join(', ')} $etAlMark',
      );
    } else {
      statement.add(
        '${persons.take(3).map((n) => n.gostStatement).join(', ')} $etAlMark',
      );
    }
  }
  if (corporate.isNotEmpty) statement.add(corporate.join('; '));

  var title = d.title.trim().replaceFirst(RegExp(r'\.$'), '');
  if (withUrl) title = '$title $gmd';
  if (d.subtitle != null && d.subtitle!.trim().isNotEmpty) {
    final sub = d.subtitle!.trim();
    title = '$title : ${sub[0].toLowerCase()}${sub.substring(1)}';
  }
  final buf = StringBuffer();
  if (heading != null) buf.write('$heading ');
  buf.write(title);
  if (statement.isNotEmpty) buf.write(' / ${statement.join('; ')}');

  final parts = <String>[];
  if (isSerial) {
    if (d.container != null) buf.write(' // ${d.container!.trim()}');
    if (d.year != null) parts.add(d.year!);
    final vi = [
      if (d.volume != null) '$volL ${d.volume}',
      if (d.issue != null) '$noL ${d.issue}',
    ].join(', ');
    if (vi.isNotEmpty) parts.add(vi);
    if (d.pages != null) parts.add('$pL ${_range(d.pages!, dash: true)}');
  } else {
    if (d.edition != null) parts.add(d.edition!.trim());
    final pubPlace = [
      if (d.place != null && d.publisher != null)
        '${d.place} : ${d.publisher}'
      else if (d.place != null)
        d.place!
      else if (d.publisher != null)
        d.publisher!,
    ];
    final imprint = [...pubPlace, if (d.year != null) d.year!].join(', ');
    if (imprint.isNotEmpty) parts.add(imprint);
  }
  if (d.doi != null) parts.add('DOI: ${d.doi}');
  if (d.pmid != null) parts.add('PMID: ${d.pmid}');
  if (withUrl) {
    parts.add(
      d.accessed == null
          ? 'URL: ${d.url}'
          : 'URL: ${d.url} ($accessedLabel: ${_gostDate(d.accessed!)})',
    );
  }
  var out = buf.toString();
  for (final p in parts) {
    out = '${_end(out)} – $p';
  }
  return _end(out);
}

// -------------------------------------------------------------- Vancouver

String _vancouver(CitationData d) {
  final (names, etAl) = _names(d);
  final shown = names.length > 6 ? names.take(6).toList() : names;
  final authors = [
    ...shown.map((n) => n.vancouver),
    if (names.length > 6 || etAl) 'et al',
  ].join(', ');
  final isSerial =
      d.kind == CitationKind.article || d.kind == CitationKind.chapter;
  final withUrl =
      d.url != null && (!isSerial || (d.doi == null && d.pmid == null));
  final cited = d.accessed == null
      ? null
      : '[cited ${d.accessed!.year} ${_months[d.accessed!.month - 1].substring(0, 3)} ${d.accessed!.day}]';

  final out = <String>[];
  if (authors.isNotEmpty) out.add(_end(authors));
  var title = d.title.trim();
  if (d.subtitle != null) {
    title = '${title.replaceFirst(RegExp(r'\.$'), '')}: ${d.subtitle!.trim()}';
  }
  if (withUrl) {
    title = '${title.replaceFirst(RegExp(r'\.$'), '')} [Internet]';
  }
  out.add(_end(title));
  if (isSerial) {
    final src = StringBuffer();
    if (d.container != null) src.write(_end(d.container!.trim()));
    final date = [
      if (d.year != null) d.year!,
      if (withUrl && cited != null) cited,
    ].join(' ');
    final loc = StringBuffer();
    if (d.volume != null) loc.write(d.volume);
    if (d.issue != null) loc.write('(${d.issue})');
    if (d.pages != null) loc.write(':${_range(d.pages!, dash: false)}');
    final dateLoc = loc.isEmpty
        ? date
        : date.isEmpty
        ? '$loc'
        : '$date;$loc';
    if (dateLoc.isNotEmpty) {
      src.write(src.isEmpty ? dateLoc : ' $dateLoc');
    }
    if (src.isNotEmpty) out.add(_end(src.toString()));
  } else {
    if (d.edition != null) out.add(_end(d.edition!.trim()));
    final pub = [
      if (d.place != null && d.publisher != null)
        '${d.place}: ${d.publisher}'
      else if (d.place != null)
        d.place!
      else if (d.publisher != null)
        d.publisher!,
    ].join();
    final date = [
      if (d.year != null) d.year!,
      if (withUrl && cited != null) cited,
    ].join(' ');
    final imprint = [
      if (pub.isNotEmpty) pub,
      if (date.isNotEmpty) date,
    ].join('; ');
    if (imprint.isNotEmpty) out.add(_end(imprint));
  }
  if (d.doi != null) out.add('doi:${d.doi}.');
  if (d.pmid != null) out.add('PMID: ${d.pmid}.');
  if (withUrl) out.add('Available from: ${d.url}');
  return out.join(' ');
}

// -------------------------------------------------------------------- APA

String _apa(CitationData d) {
  final (names, etAl) = _names(d);
  final list = [for (final n in names) n.apa];
  final String authors;
  if (list.isEmpty) {
    authors = '';
  } else if (etAl) {
    authors = '${list.join(', ')}, et al.';
  } else if (list.length == 1) {
    authors = list.first;
  } else if (list.length <= 20) {
    authors = '${list.sublist(0, list.length - 1).join(', ')}, & ${list.last}';
  } else {
    authors = '${list.take(19).join(', ')}, . . . ${list.last}';
  }
  final year = '(${d.year ?? 'n.d.'}).';
  final isSerial =
      d.kind == CitationKind.article || d.kind == CitationKind.chapter;
  var title = d.title.trim();
  if (!isSerial) {
    final extra = [
      if (d.edition != null) '(${d.edition!.trim()})',
      if (d.subtitle != null) '[${d.subtitle!.trim()}]',
    ].join(' ');
    if (extra.isNotEmpty) {
      title = '${title.replaceFirst(RegExp(r'\.$'), '')} $extra';
    }
  }
  final out = <String>[];
  if (authors.isNotEmpty) {
    out
      ..add(_end(authors))
      ..add(year)
      ..add(_end(title));
  } else {
    // Muallifsiz: sarlavha muallif o‘rniga o‘tadi.
    out
      ..add(_end(title))
      ..add(year);
  }
  if (isSerial) {
    final src = StringBuffer();
    if (d.container != null) src.write(d.container!.trim());
    if (d.volume != null) {
      src.write(src.isEmpty ? d.volume : ', ${d.volume}');
      if (d.issue != null) src.write('(${d.issue})');
    } else if (d.issue != null) {
      src.write(src.isEmpty ? '(${d.issue})' : ', (${d.issue})');
    }
    if (d.pages != null) {
      final p = _range(d.pages!, dash: true);
      src.write(src.isEmpty ? p : ', $p');
    }
    if (src.isNotEmpty) out.add(_end(src.toString()));
  } else if (d.publisher != null &&
      !(names.length == 1 && names.first.corporate == d.publisher)) {
    out.add(_end(d.publisher!.trim()));
  }
  if (d.doi != null) {
    out.add('https://doi.org/${d.doi}');
  } else if (d.url != null) {
    out.add(
      d.accessed == null || isSerial
          ? d.url!
          : 'Retrieved ${_months[d.accessed!.month - 1]} ${d.accessed!.day}, '
                '${d.accessed!.year}, from ${d.url}',
    );
  }
  return out.join(' ');
}
