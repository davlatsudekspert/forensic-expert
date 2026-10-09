/// «Yo‘riqnomalar» — mustaqil yozilgan ilmiy-amaliy kartalar
/// (`content/guidelines/`, sxema `fe-guidelines/1`).
///
/// Bu kartalar rasmiy metodika emas: har biri tekshirilgan adabiyotga
/// tayangan mustaqil ilmiy sintez va ekspert ko‘rigidan o‘tmaguncha
/// `NEEDS_REVIEW` bo‘lib qoladi. Yopiq (cheklangan) manbalar matni bu
/// paketga kirmaydi — ular faqat admin qurilmasidagi alohida katalogda.
library;

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/foundation.dart';

/// Uch tilli matn. Tanlangan tilda bo‘lmasa — boshqa tildagi asl matn
/// qaytariladi va [LocalizedPick.isFallback] bilan belgilanadi (soxta
/// tarjima yo‘q).
@immutable
class Tri {
  const Tri(this.values);

  factory Tri.fromJson(Object? j) => Tri({
    if (j is Map)
      for (final e in j.entries)
        if (e.value is String && (e.value as String).trim().isNotEmpty)
          e.key as String: (e.value as String).trim(),
  });

  final Map<String, String> values;

  static const _order = ['uz', 'ru', 'en'];

  LocalizedPick pick(String lang) {
    final v = values[lang];
    if (v != null) return LocalizedPick(v, lang, false);
    for (final l in _order) {
      final x = values[l];
      if (x != null) return LocalizedPick(x, l, true);
    }
    return const LocalizedPick('', 'uz', true);
  }

  String of(String lang) => pick(lang).text;

  Iterable<String> get all => values.values;
}

@immutable
class LocalizedPick {
  const LocalizedPick(this.text, this.lang, this.isFallback);

  final String text;
  final String lang;
  final bool isFallback;
}

/// Tarjima holati: `AUTHORED` (asl matn), `DRAFT` (mashina yordamida,
/// tekshirilmagan), `REVIEWED` (terminologiya va ekspert ko‘rigidan o‘tgan).
enum GuidelineTranslationStatus {
  authored,
  draft,
  reviewed;

  static GuidelineTranslationStatus parse(Object? v) =>
      switch ('$v'.toUpperCase()) {
        'AUTHORED' => authored,
        'REVIEWED' => reviewed,
        _ => draft,
      };
}

@immutable
class GuidelineSection {
  const GuidelineSection({
    required this.key,
    required this.title,
    required this.body,
    this.citations = const [],
  });

  factory GuidelineSection.fromJson(Map<String, Object?> j) => GuidelineSection(
    key: '${j['key'] ?? ''}',
    title: Tri.fromJson(j['title']),
    body: Tri.fromJson(j['body']),
    citations: [for (final c in (j['citations'] as List? ?? const [])) '$c'],
  );

  final String key;
  final Tri title;
  final Tri body;
  final List<String> citations;
}

@immutable
class GuidelineReference {
  const GuidelineReference({
    required this.key,
    required this.citation,
    this.doi,
    this.pmid,
    this.url,
    this.verifiedVia,
    this.type,
    this.authors = const [],
    this.title,
    this.journal,
    this.publisher,
    this.place,
    this.year,
    this.volume,
    this.issue,
    this.pages,
    this.verifiedOn,
  });

  factory GuidelineReference.fromJson(Map<String, Object?> j) {
    String? s(String k) {
      final v = j[k];
      return v == null || '$v'.trim().isEmpty ? null : '$v'.trim();
    }

    final authors = switch (j['authors']) {
      final List<Object?> a => a.map((e) => '$e').join(', '),
      final String a => a,
      _ => '',
    };
    final publisher = s('publisher');
    final venue =
        s('journal') ??
        (publisher != null && s('place') != null
            ? '${s('place')}: $publisher'
            : publisher) ??
        '';
    final parts = <String>[
      if (authors.isNotEmpty) authors,
      if (s('year') != null) '(${s('year')})',
      if (s('title') != null) '${s('title')}.',
      if (venue.isNotEmpty) venue,
      if (s('volume') != null) s('volume')!,
      if (s('pages') != null) s('pages')!,
    ];
    return GuidelineReference(
      key: s('key') ?? '',
      citation: parts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim(),
      doi: s('doi'),
      pmid: s('pmid'),
      url: s('url'),
      verifiedVia: s('verified_via'),
      type: s('type'),
      authors: switch (j['authors']) {
        final List<Object?> a => [
          for (final e in a)
            if ('$e'.trim().isNotEmpty) '$e'.trim(),
        ],
        final String a when a.trim().isNotEmpty => [a.trim()],
        _ => const [],
      },
      title: s('title'),
      journal: s('journal'),
      publisher: s('publisher'),
      place: s('place'),
      year: s('year'),
      volume: s('volume'),
      issue: s('issue'),
      pages: s('pages'),
      verifiedOn: DateTime.tryParse(s('verified_on') ?? ''),
    );
  }

  final String key;
  final String citation;
  final String? doi;
  final String? pmid;
  final String? url;
  final String? verifiedVia;

  // Tuzilgan bibliografik maydonlar (iqtibos eksporti uchun; yo‘q bo‘lsa
  // null — hech narsa to‘qib chiqarilmaydi).
  final String? type;
  final List<String> authors;
  final String? title;
  final String? journal;
  final String? publisher;

  /// Nashr joyi (masalan, «Toshkent»).
  final String? place;
  final String? year;
  final String? volume;
  final String? issue;
  final String? pages;

  /// Havola onlayn tekshirilgan sana (`verified_on`) — murojaat sanasi.
  final DateTime? verifiedOn;

  /// Prof. Yuldashev Z.A. o‘quv-uslubiy majmualari (muallif ruxsati bilan,
  /// egasi qarori: barcha uchun bepul).
  bool get isYuldashevMaterial =>
      yuldashevReferencePrefixes.any(key.startsWith);

  Uri? get link {
    if (doi != null) return Uri.parse('https://doi.org/$doi');
    if (pmid != null) {
      return Uri.parse('https://pubmed.ncbi.nlm.nih.gov/$pmid/');
    }
    if (url != null) return Uri.tryParse(url!);
    return null;
  }
}

/// Prof. Yuldashev Z.A. materiallari kalit prefikslari (`references.json`).
const yuldashevReferencePrefixes = ['toks_', 'dvssm_', 'gmt_'];

/// Kartaga biriktirilgan o‘z-o‘zini tekshirish savoli (o‘quv rejimi uchun).
///
/// Savol va variantlar kartadagi faktlardan mustaqil yozilgan; manba —
/// kartaning adabiyoti va [pages] (manbadagi sahifalar).
@immutable
class GuidelineQuizItem {
  const GuidelineQuizItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.distractors,
    this.pages,
    this.cite = const [],
  });

  static GuidelineQuizItem? fromJson(Object? j) {
    if (j is! Map) return null;
    final id = '${j['id'] ?? ''}'.trim();
    final q = Tri.fromJson(j['q']);
    final a = Tri.fromJson(j['a']);
    if (id.isEmpty || q.values.isEmpty || a.values.isEmpty) return null;
    final d = j['d'];
    final perLang = <String, List<String>>{
      if (d is Map)
        for (final e in d.entries)
          '${e.key}': [
            for (final x in (e.value as List? ?? const []))
              if ('$x'.trim().isNotEmpty) '$x'.trim(),
          ],
    };
    final n = perLang.values.fold<int>(
      0,
      (m, l) => l.length > m ? l.length : m,
    );
    final distractors = <Tri>[
      for (var i = 0; i < n; i++)
        Tri({
          for (final e in perLang.entries)
            if (i < e.value.length) e.key: e.value[i],
        }),
    ];
    final pages = '${j['pages'] ?? ''}'.trim();
    return GuidelineQuizItem(
      id: id,
      question: q,
      answer: a,
      distractors: distractors,
      pages: pages.isEmpty ? null : pages,
      cite: [
        for (final k in (j['cite'] as List? ?? const []))
          if ('$k'.trim().isNotEmpty) '$k'.trim(),
      ],
    );
  }

  final String id;
  final Tri question;
  final Tri answer;
  final List<Tri> distractors;

  /// Manbadagi sahifa(lar), masalan `25, 172`.
  final String? pages;

  /// Savol aniq tayangan manba kalitlari (bo‘sh bo‘lsa — kartadagi
  /// o‘quv-uslubiy material). [pages] o‘quv-uslubiy materialga tegishli.
  final List<String> cite;
}

/// Yo‘riqnomalar bo‘limidagi fan guruhlari (egasi belgilagan tartibda).
enum GuidelineArea {
  forensicMedicine,
  forensicChemistry,
  forensicHistology,
  forensicBiology,
  medicalCriminalistics,
  other;

  static GuidelineArea forCodes(List<String> codes) {
    for (final c in codes) {
      final a = switch (c) {
        'forensic_medicine' ||
        'forensic_pathology' ||
        'clinical_forensic_medicine' => forensicMedicine,
        'forensic_chemistry' ||
        'forensic_toxicology' ||
        'forensic_biochemistry' => forensicChemistry,
        'forensic_histology' => forensicHistology,
        'forensic_biology' || 'forensic_genetics' => forensicBiology,
        'human_identification' ||
        'forensic_anthropology' ||
        'forensic_odontology' ||
        'forensic_radiology' => medicalCriminalistics,
        _ => null,
      };
      if (a != null) return a;
    }
    return other;
  }
}

/// Karta kirish darajasi (`access`). Belgilanmagan — bepul.
enum GuidelineAccess {
  free,
  pro;

  static GuidelineAccess parse(Object? v) =>
      '$v'.toLowerCase() == 'pro' ? pro : free;
}

@immutable
class GuidelineCard {
  const GuidelineCard({
    required this.id,
    required this.title,
    required this.disciplineCodes,
    required this.status,
    required this.sections,
    this.summary = const Tri({}),
    this.updated,
    this.keywords = const {},
    this.translationStatus = const {},
    this.relatedToolIds = const [],
    this.access = GuidelineAccess.free,
    this.quiz = const [],
    this.termIds = const [],
  });

  factory GuidelineCard.fromJson(Map<String, Object?> j) {
    final kw = <String, List<String>>{};
    if (j['keywords'] case final Map<Object?, Object?> m) {
      for (final e in m.entries) {
        kw['${e.key}'] = [for (final v in (e.value as List? ?? const [])) '$v'];
      }
    }
    final ts = <String, GuidelineTranslationStatus>{};
    if (j['translation_status'] case final Map<Object?, Object?> m) {
      for (final e in m.entries) {
        ts['${e.key}'] = GuidelineTranslationStatus.parse(e.value);
      }
    }
    return GuidelineCard(
      id: '${j['id']}',
      title: Tri.fromJson(j['title']),
      disciplineCodes: [
        for (final d in (j['discipline_codes'] as List? ?? const [])) '$d',
      ],
      // Fayl nima desa ham — ekspert ko‘rigisiz VERIFIED/REVIEWED bo‘lmaydi.
      status: _status(j['status']),
      sections: [
        for (final s in (j['sections'] as List? ?? const []))
          if (s is Map<String, Object?>) GuidelineSection.fromJson(s),
      ],
      summary: Tri.fromJson(j['summary']),
      updated: DateTime.tryParse('${j['updated'] ?? ''}'),
      keywords: kw,
      translationStatus: ts,
      relatedToolIds: [
        for (final t in (j['related_tool_ids'] as List? ?? const [])) '$t',
      ],
      access: GuidelineAccess.parse(j['access']),
      quiz: [
        for (final q in (j['quiz'] as List? ?? const []))
          ?GuidelineQuizItem.fromJson(q),
      ],
      termIds: [
        for (final t in (j['term_ids'] as List? ?? const []))
          if ('$t'.trim().isNotEmpty) '$t'.trim(),
      ],
    );
  }

  static ScientificStatus _status(Object? v) {
    try {
      final s = ScientificStatus.fromCode('$v'.toUpperCase());
      return s.isPublishable ? ScientificStatus.needsReview : s;
    } on FormatException {
      return ScientificStatus.needsReview;
    }
  }

  final String id;
  final Tri title;
  final List<String> disciplineCodes;
  final ScientificStatus status;
  final List<GuidelineSection> sections;

  /// Kartaning qisqa mazmuni (bo‘limlardagi manbalarga tayanadi).
  final Tri summary;
  final DateTime? updated;
  final Map<String, List<String>> keywords;
  final Map<String, GuidelineTranslationStatus> translationStatus;
  final List<String> relatedToolIds;

  /// Kirish darajasi. Yo‘riqnomalar bepul; `pro` faqat aniq belgilansa.
  final GuidelineAccess access;

  /// O‘quv rejimi uchun savollar (bo‘lmasa — bo‘sh).
  final List<GuidelineQuizItem> quiz;

  /// «Ilmiy lug‘at» atamalari (`term_translations.term_id`) — kartada
  /// ishlatilgan atamalarning aniq ro‘yxati (`content/tools/toks_terms.py`).
  final List<String> termIds;

  bool get isFree => access == GuidelineAccess.free;

  GuidelineArea get area => GuidelineArea.forCodes(disciplineCodes);

  GuidelineTranslationStatus translationFor(String lang) =>
      translationStatus[lang] ?? GuidelineTranslationStatus.draft;

  /// Qidiruv uchun barcha tillardagi sarlavha va kalit so‘zlar.
  Iterable<String> get searchTerms => [
    ...title.all,
    for (final k in keywords.values) ...k,
    for (final s in sections) ...s.title.all,
  ];
}

@immutable
class GuidelineBundle {
  const GuidelineBundle({this.cards = const [], this.references = const {}});

  factory GuidelineBundle.fromJson(Map<String, Object?> j) {
    if (j['schema'] != 'fe-guidelines/1') {
      throw const FormatException('fe-guidelines/1 expected');
    }
    return GuidelineBundle(
      cards: [
        for (final c in (j['cards'] as List? ?? const []))
          if (c is Map<String, Object?>) GuidelineCard.fromJson(c),
      ],
      references: {
        for (final r in (j['references'] as List? ?? const []))
          if (r is Map<String, Object?>)
            '${r['key']}': GuidelineReference.fromJson(r),
      },
    );
  }

  static const empty = GuidelineBundle();

  final List<GuidelineCard> cards;
  final Map<String, GuidelineReference> references;

  GuidelineCard? byId(String id) {
    for (final c in cards) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Karta Prof. Yuldashev Z.A. materiallariga tayanadimi (manba qatori
  /// ko‘rsatiladi; egasi qarori bo‘yicha bunday kontent har doim bepul).
  bool citesYuldashevMaterial(GuidelineCard card) =>
      referencesOf(card).any((r) => r.isYuldashevMaterial);

  /// Karta bo‘yicha ishlatilgan manbalar — birinchi uchrash tartibida
  /// raqamlanadi ([1], [2], …).
  List<GuidelineReference> referencesOf(GuidelineCard card) {
    final seen = <String>{};
    return [
      for (final s in card.sections)
        for (final k in s.citations)
          if (seen.add(k) && references[k] != null) references[k]!,
    ];
  }
}
