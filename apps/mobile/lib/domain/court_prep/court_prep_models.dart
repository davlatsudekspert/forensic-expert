/// «Sudda so‘roq: tayyorgarlik» — ekspertga sud yoki tergovda
/// xulosasi bo‘yicha beriladigan odatiy savollar, ilmiy va huquqiy asosli
/// javob tayyorlash va so‘roq simulyatori (`content/court_prep/`, sxema
/// `fe-court-prep/2`).
///
/// Bu tayyorgarlik materiali: yuridik maslahat emas va ekspertga qanday
/// xulosa berishni aytmaydi. Barcha kartalar ekspert ko‘rigidan o‘tmaguncha
/// `NEEDS_REVIEW` — fayl nima desa ham, kod hech qachon tasdiqlangan holat
/// bermaydi.
library;

import 'dart:convert';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/foundation.dart';

import '../evidence/content_translations.dart';
import '../guidelines/guideline_models.dart';

/// Tayyorgarlik bloklari: hujjatlar, ilmiy/huquqiy asos, odatiy xatolar.
enum CourtPrepBlock {
  documents,
  explain,
  pitfalls;

  static CourtPrepBlock? parse(String v) => switch (v) {
    'documents' => documents,
    'explain' => explain,
    'pitfalls' => pitfalls,
    _ => null,
  };
}

/// Savol qaysi yurisdiksiyaga tegishli.
enum CourtJurisdiction {
  all,
  uz,
  intl;

  static CourtJurisdiction parse(Object? v) => switch ('$v'.toUpperCase()) {
    'UZ' => uz,
    'INTL' => intl,
    _ => all,
  };

  /// Tanlangan yurisdiksiya O‘zbekiston bo‘lsa — UZ savollar, aks holda
  /// umumiy xalqaro savollar ko‘rsatiladi.
  bool visibleFor({required bool uzbekistan}) => switch (this) {
    all => true,
    uz => uzbekistan,
    intl => !uzbekistan,
  };
}

/// Fayl nima desa ham — ekspert ko‘rigisiz tasdiqlangan holat yo‘q.
ScientificStatus _neverVerified(Object? v) {
  try {
    final s = ScientificStatus.fromCode('$v'.toUpperCase());
    return s.isPublishable ? ScientificStatus.needsReview : s;
  } on FormatException {
    return ScientificStatus.needsReview;
  }
}

List<Tri> _triList(Object? v) => [
  for (final it in (v as List? ?? const [])) Tri.fromJson(it),
];

/// Manbadagi aniq joy (modda, bo‘lim, bet …). `null` — joy asl matndan
/// tasdiqlanmagan: UI bibliografiya o‘rniga «Manba tekshirilmagan» deydi.
@immutable
class CourtLocator {
  const CourtLocator(this.kind, [this.value = '', this.part = '']);

  /// `art:68:1`, `sec:4.8.1`, `pdfp:12`, `pp:29-30`, `rec:7`, `gn:1`,
  /// `abstract`, `scope`, `title`, `glossary`.
  factory CourtLocator.parse(String raw) {
    final p = raw.split(':');
    return switch (p.first) {
      'art' => CourtLocator(
        'art',
        p.length > 1 ? p[1] : '',
        p.length > 2 ? p[2] : '',
      ),
      'sec' => CourtLocator('sec', raw.substring(4)),
      'pdfp' ||
      'pp' ||
      'rec' ||
      'gn' => CourtLocator(p.first, p.length > 1 ? p[1] : ''),
      _ => CourtLocator(p.first),
    };
  }

  final String kind;
  final String value;
  final String part;
}

@immutable
class CourtLink {
  const CourtLink(this.kind, this.id);

  factory CourtLink.parse(String raw) {
    final i = raw.indexOf(':');
    return i < 0
        ? CourtLink(raw, '')
        : CourtLink(raw.substring(0, i), raw.substring(i + 1));
  }

  final String kind;
  final String id;
}

/// Bibliografik yozuv (bibliografik eksport uchun xom maydonlar bilan).
@immutable
class CourtReference {
  const CourtReference({
    required this.key,
    required this.type,
    required this.authors,
    required this.title,
    this.container,
    this.year,
    this.volume,
    this.issue,
    this.pages,
    this.doi,
    this.pmid,
    this.url,
    this.verifiedVia,
    this.verifiedOn,
    this.localizedTitles = ReferenceTitles.empty,
  });

  factory CourtReference.fromJson(Map<String, Object?> j) {
    String? s(String k) {
      final v = j[k];
      return v == null || '$v'.trim().isEmpty ? null : '$v'.trim();
    }

    return CourtReference(
      key: s('key') ?? '',
      type: s('type') ?? 'misc',
      authors: switch (j['authors']) {
        final List<Object?> a => [for (final x in a) '$x'],
        final String a => [a],
        _ => const [],
      },
      title: s('title') ?? '',
      container: s('journal') ?? s('publisher'),
      year: s('year'),
      volume: s('volume'),
      issue: s('issue'),
      pages: s('pages'),
      doi: s('doi'),
      pmid: s('pmid'),
      url: s('url'),
      verifiedVia: s('verified_via'),
      verifiedOn: s('verified_on'),
      localizedTitles: ReferenceTitles.fromJson(j),
    );
  }

  final String key;

  /// `journal_article`, `book`, `law`, `standard`, `guideline`, `report`.
  final String type;
  final List<String> authors;

  /// Asl tildagi sarlavha (tarjima qilinmaydi).
  final String title;
  final String? container;
  final String? year;
  final String? volume;
  final String? issue;
  final String? pages;
  final String? doi;
  final String? pmid;
  final String? url;
  final String? verifiedVia;
  final String? verifiedOn;

  /// Ixtiyoriy tilga bog‘liq nom (masalan, UZ qonunining rasmiy o‘zbekcha
  /// nomi) — UI uni asl iqtibos ustida ko‘rsatadi.
  final ReferenceTitles localizedTitles;

  bool get isLaw => type == 'law';
  bool get isTeacherBook => type == 'book';

  /// Bir qatorli iqtibos (Vancouver uslubiga yaqin).
  String get citation {
    final vol = [?volume, if (issue != null) '($issue)'].join();
    final parts = <String>[
      if (authors.isNotEmpty) authors.join(', '),
      if (year != null) '($year)',
      '$title.',
      ?container,
      vol,
      ?pages,
    ];
    return parts.where((p) => p.trim().isNotEmpty).join(' ').trim();
  }

  Uri? get link {
    if (doi != null) return Uri.parse('https://doi.org/$doi');
    if (pmid != null) {
      return Uri.parse('https://pubmed.ncbi.nlm.nih.gov/$pmid/');
    }
    if (url != null) return Uri.tryParse(url!);
    return null;
  }

  /// BibTeX yozuvi (bibliografik dasturlar uchun).
  String toBibtex() {
    final kind = switch (type) {
      'journal_article' => 'article',
      'book' => 'book',
      'report' => 'techreport',
      _ => 'misc',
    };
    String esc(String v) => v.replaceAll('{', r'\{').replaceAll('}', r'\}');
    final fields = <String, String?>{
      'author': authors.isEmpty ? null : authors.join(' and '),
      'title': title,
      if (kind == 'article') 'journal': container else 'publisher': container,
      'year': year,
      'volume': volume,
      'number': issue,
      'pages': pages,
      'doi': doi,
      'pmid': pmid,
      'url': url,
    };
    final body = [
      for (final e in fields.entries)
        if (e.value != null) '  ${e.key} = {${esc(e.value!)}}',
    ].join(',\n');
    return '@$kind{$key,\n$body\n}';
  }
}

@immutable
class CourtPrepTopic {
  const CourtPrepTopic({
    required this.id,
    required this.title,
    required this.summary,
    required this.icon,
    this.pending = false,
  });

  factory CourtPrepTopic.fromJson(Map<String, Object?> j) => CourtPrepTopic(
    id: '${j['id']}',
    title: Tri.fromJson(j['title']),
    summary: Tri.fromJson(j['summary']),
    icon: '${j['icon'] ?? ''}',
    pending: j['pending'] == true,
  );

  final String id;
  final Tri title;
  final Tri summary;
  final String icon;

  /// Tekshirilgan manbalar hali yo‘q — savolsiz, ko‘rinadigan belgi bilan.
  final bool pending;
}

@immutable
class CourtFollowup {
  const CourtFollowup(this.question, this.answer);

  final Tri question;
  final Tri answer;
}

/// Iqtibos keltirilgan manba kalitlari va ularning aniq joylari.
mixin CourtSourced {
  List<String> get citations;

  /// Kalit → joylar; `null` yoki yo‘q — tasdiqlanmagan joy.
  Map<String, List<CourtLocator>?> get locators;

  List<CourtLocator>? locatorsOf(String key) => locators[key];
}

Map<String, List<CourtLocator>?> _locators(Object? v) => {
  if (v is Map)
    for (final e in v.entries)
      '${e.key}': e.value is List
          ? [for (final t in e.value as List) CourtLocator.parse('$t')]
          : null,
};

@immutable
class CourtPrepQuestion with CourtSourced {
  const CourtPrepQuestion({
    required this.id,
    required this.topicId,
    required this.question,
    required this.tests,
    required this.shortAnswer,
    required this.prepare,
    required this.status,
    this.jurisdiction = CourtJurisdiction.all,
    this.isSample = false,
    this.followups = const [],
    this.limitations = const [],
    this.citations = const [],
    this.locators = const {},
    this.links = const [],
    this.translationStatus = const {},
  });

  factory CourtPrepQuestion.fromJson(Map<String, Object?> j) {
    final prep = <CourtPrepBlock, List<Tri>>{};
    if (j['prepare'] case final Map<Object?, Object?> m) {
      for (final e in m.entries) {
        final b = CourtPrepBlock.parse('${e.key}');
        if (b != null) prep[b] = _triList(e.value);
      }
    }
    final ts = <String, GuidelineTranslationStatus>{};
    if (j['translation_status'] case final Map<Object?, Object?> m) {
      for (final e in m.entries) {
        ts['${e.key}'] = GuidelineTranslationStatus.parse(e.value);
      }
    }
    return CourtPrepQuestion(
      id: '${j['id']}',
      topicId: '${j['topic']}',
      question: Tri.fromJson(j['question']),
      tests: Tri.fromJson(j['tests']),
      shortAnswer: Tri.fromJson(j['short_answer']),
      prepare: prep,
      status: _neverVerified(j['status']),
      jurisdiction: CourtJurisdiction.parse(j['jurisdiction']),
      isSample: j['sample'] == true,
      followups: [
        for (final f in (j['followups'] as List? ?? const []))
          if (f is Map)
            CourtFollowup(Tri.fromJson(f['q']), Tri.fromJson(f['a'])),
      ],
      limitations: _triList(j['limitations']),
      citations: [for (final c in (j['citations'] as List? ?? const [])) '$c'],
      locators: _locators(j['locators']),
      links: [
        for (final l in (j['links'] as List? ?? const []))
          CourtLink.parse('$l'),
      ],
      translationStatus: ts,
    );
  }

  final String id;
  final String topicId;

  /// A. Savol.
  final Tri question;

  /// «Sud nimani tekshiradi».
  final Tri tests;

  /// B. Qisqa javob.
  final Tri shortAnswer;

  /// C (explain) va tayyorgarlik ro‘yxatlari.
  final Map<CourtPrepBlock, List<Tri>> prepare;

  /// I. Holat — har doim NEEDS_REVIEW (ekspert ko‘rigisiz).
  final ScientificStatus status;
  final CourtJurisdiction jurisdiction;

  /// Bepul demoda ochiq namunaviy savol.
  final bool isSample;

  /// E/F. Qo‘shimcha savollar va ularga dalilli javoblar.
  final List<CourtFollowup> followups;

  /// G. Cheklovlar, istisnolar, noaniqliklar.
  final List<Tri> limitations;
  @override
  final List<String> citations;
  @override
  final Map<String, List<CourtLocator>?> locators;
  final List<CourtLink> links;
  final Map<String, GuidelineTranslationStatus> translationStatus;

  List<Tri> block(CourtPrepBlock b) => prepare[b] ?? const [];

  GuidelineTranslationStatus translationFor(String lang) =>
      translationStatus[lang] ?? GuidelineTranslationStatus.draft;

  Iterable<String> get searchTerms => [
    ...question.all,
    ...tests.all,
    ...shortAnswer.all,
    for (final items in prepare.values)
      for (final it in items) ...it.all,
    for (final f in followups) ...[...f.question.all, ...f.answer.all],
  ];
}

@immutable
class CourtPrinciple with CourtSourced {
  const CourtPrinciple({
    required this.id,
    required this.text,
    this.citations = const [],
    this.locators = const {},
  });

  factory CourtPrinciple.fromJson(Map<String, Object?> j) => CourtPrinciple(
    id: '${j['id']}',
    text: Tri.fromJson(j['text']),
    citations: [for (final c in (j['citations'] as List? ?? const [])) '$c'],
    locators: _locators(j['locators']),
  );

  final String id;
  final Tri text;
  @override
  final List<String> citations;
  @override
  final Map<String, List<CourtLocator>?> locators;
}

/// Simulyatordagi so‘roq qiluvchi.
enum CourtRole {
  judge,
  prosecutor,
  defense,
  expert;

  static CourtRole parse(Object? v) => switch ('$v') {
    'prosecutor' => prosecutor,
    'defense' => defense,
    'expert' => expert,
    _ => judge,
  };
}

/// Baholash mezonlari (har biri 0–2 ball).
enum CourtCriterion { accuracy, sources, limitations, impartiality }

@immutable
class CourtScore {
  const CourtScore(this.values);

  factory CourtScore.fromJson(Object? j) => CourtScore({
    for (final c in CourtCriterion.values)
      c: j is Map ? ((j[c.name] as num?)?.toInt() ?? 0).clamp(0, 2) : 0,
  });

  final Map<CourtCriterion, int> values;

  static const max = 8;

  int of(CourtCriterion c) => values[c] ?? 0;
  int get total => values.values.fold(0, (a, b) => a + b);
  bool get isBest => total == max;
}

@immutable
class CourtOption {
  const CourtOption(this.text, this.score, this.feedback);

  final Tri text;
  final CourtScore score;
  final Tri feedback;
}

@immutable
class CourtScenario with CourtSourced {
  const CourtScenario({
    required this.id,
    required this.role,
    required this.context,
    required this.prompt,
    required this.options,
    this.questionId,
    this.isSample = false,
    this.citations = const [],
    this.locators = const {},
  });

  factory CourtScenario.fromJson(Map<String, Object?> j) => CourtScenario(
    id: '${j['id']}',
    role: CourtRole.parse(j['role']),
    context: Tri.fromJson(j['context']),
    prompt: Tri.fromJson(j['prompt']),
    options: [
      for (final o in (j['options'] as List? ?? const []))
        if (o is Map)
          CourtOption(
            Tri.fromJson(o['text']),
            CourtScore.fromJson(o['scores']),
            Tri.fromJson(o['feedback']),
          ),
    ],
    questionId: j['question_id'] == null ? null : '${j['question_id']}',
    isSample: j['sample'] == true,
    citations: [for (final c in (j['citations'] as List? ?? const [])) '$c'],
    locators: _locators(j['locators']),
  );

  final String id;
  final CourtRole role;
  final Tri context;
  final Tri prompt;
  final List<CourtOption> options;
  final String? questionId;
  final bool isSample;
  @override
  final List<String> citations;
  @override
  final Map<String, List<CourtLocator>?> locators;

  CourtOption? get best {
    for (final o in options) {
      if (o.score.isBest) return o;
    }
    return null;
  }
}

/// Erkin matnli javob uchun oflayn, qoidaga asoslangan baho.
@immutable
class CourtRubric {
  const CourtRubric({
    this.sources = const [],
    this.limitations = const [],
    this.impartiality = const [],
    this.overstatement = const [],
    this.evasion = const [],
  });

  factory CourtRubric.fromJson(Object? j) {
    List<String> l(String k) => [
      if (j is Map)
        for (final x in (j[k] as List? ?? const [])) '$x'.toLowerCase(),
    ];
    return CourtRubric(
      sources: l('sources'),
      limitations: l('limitations'),
      impartiality: l('impartiality'),
      overstatement: l('overstatement'),
      evasion: l('evasion'),
    );
  }

  final List<String> sources;
  final List<String> limitations;
  final List<String> impartiality;
  final List<String> overstatement;
  final List<String> evasion;

  /// Kalit so‘zlar bo‘yicha signal. Ilmiy aniqlikni avtomatik baholab
  /// bo‘lmaydi: u 1 dan boshlanadi, mutlaq yoki qochuvchi iboralar 0 ga
  /// tushiradi; to‘liq baho faqat namunaviy javob bilan solishtirib olinadi.
  CourtFreeTextResult evaluate(String text) {
    final t = text.toLowerCase();
    int hits(List<String> words) => words.where(t.contains).length;
    int band(int n) => n >= 2 ? 2 : n;
    final over = hits(overstatement) > 0;
    final evade = hits(evasion) > 0;
    if (t.trim().length < 15) {
      return CourtFreeTextResult(
        const CourtScore({
          CourtCriterion.accuracy: 0,
          CourtCriterion.sources: 0,
          CourtCriterion.limitations: 0,
          CourtCriterion.impartiality: 0,
        }),
        overstatement: over,
        evasion: evade,
        tooShort: true,
      );
    }
    return CourtFreeTextResult(
      CourtScore({
        CourtCriterion.accuracy: over || evade ? 0 : 1,
        CourtCriterion.sources: band(hits(sources)),
        CourtCriterion.limitations: over ? 0 : band(hits(limitations)),
        CourtCriterion.impartiality: evade ? 0 : band(hits(impartiality)),
      }),
      overstatement: over,
      evasion: evade,
    );
  }
}

@immutable
class CourtFreeTextResult {
  const CourtFreeTextResult(
    this.score, {
    this.overstatement = false,
    this.evasion = false,
    this.tooShort = false,
  });

  final CourtScore score;
  final bool overstatement;
  final bool evasion;
  final bool tooShort;
}

@immutable
class CourtPrepBundle {
  const CourtPrepBundle({
    this.topics = const [],
    this.questions = const [],
    this.principles = const [],
    this.scenarios = const [],
    this.rubric = const CourtRubric(),
    this.references = const {},
  });

  factory CourtPrepBundle.fromJson(Map<String, Object?> j) {
    if (j['schema'] != 'fe-court-prep/2') {
      throw const FormatException('fe-court-prep/2 expected');
    }
    final sim = j['simulator'] is Map
        ? j['simulator']! as Map
        : const <String, Object?>{};
    return CourtPrepBundle(
      topics: [
        for (final t in (j['topics'] as List? ?? const []))
          if (t is Map<String, Object?>) CourtPrepTopic.fromJson(t),
      ],
      questions: [
        for (final q in (j['questions'] as List? ?? const []))
          if (q is Map<String, Object?>) CourtPrepQuestion.fromJson(q),
      ],
      principles: [
        for (final p in (j['principles'] as List? ?? const []))
          if (p is Map<String, Object?>) CourtPrinciple.fromJson(p),
      ],
      scenarios: [
        for (final s in (sim['scenarios'] as List? ?? const []))
          if (s is Map<String, Object?>) CourtScenario.fromJson(s),
      ],
      rubric: CourtRubric.fromJson(sim['free_text_rubric']),
      references: {
        for (final r in (j['references'] as List? ?? const []))
          if (r is Map<String, Object?>)
            '${r['key']}': CourtReference.fromJson(r),
      },
    );
  }

  static const empty = CourtPrepBundle();

  final List<CourtPrepTopic> topics;
  final List<CourtPrepQuestion> questions;
  final List<CourtPrinciple> principles;
  final List<CourtScenario> scenarios;
  final CourtRubric rubric;
  final Map<String, CourtReference> references;

  bool get isEmpty => questions.isEmpty;

  CourtPrepTopic? topic(String id) {
    for (final t in topics) {
      if (t.id == id) return t;
    }
    return null;
  }

  CourtPrepQuestion? question(String id) {
    for (final q in questions) {
      if (q.id == id) return q;
    }
    return null;
  }

  CourtScenario? scenario(String id) {
    for (final s in scenarios) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Tanlangan yurisdiksiyada ko‘rinadigan savollar.
  List<CourtPrepQuestion> visible({required bool uzbekistan}) => [
    for (final q in questions)
      if (q.jurisdiction.visibleFor(uzbekistan: uzbekistan)) q,
  ];

  List<CourtPrepQuestion> questionsOf(
    String topicId, {
    required bool uzbekistan,
  }) => [
    for (final q in visible(uzbekistan: uzbekistan))
      if (q.topicId == topicId) q,
  ];

  List<CourtPrepQuestion> get samples => [
    for (final q in questions)
      if (q.isSample) q,
  ];

  /// Manbalar — iqtiboslar tartibida raqamlanadi ([1], [2] …).
  List<CourtReference> referencesOf(CourtSourced item) => [
    for (final k in item.citations) ?references[k],
  ];
}

/// Ssenariy bo‘yicha manba ishonchliligi: joyi tasdiqlanmagan manbaga
/// tayangan javob hech qachon to‘liq ball olmaydi.
extension CourtScenarioVerification on CourtScenario {
  static final _inline = RegExp(r'\[([a-z0-9_]+(?:,\s*[a-z0-9_]+)*)\]');

  Set<String> get unverifiedKeys => {
    for (final e in locators.entries)
      if (e.value == null) e.key,
  };

  /// Variant izohi joyi tasdiqlanmagan manbaga tayanadimi.
  bool reliesOnUnverified(CourtOption o) {
    final keys = <String>{};
    for (final text in o.feedback.all) {
      for (final m in _inline.allMatches(text)) {
        keys.addAll(m[1]!.split(',').map((e) => e.trim()));
      }
    }
    return keys.intersection(unverifiedKeys).isNotEmpty;
  }

  /// Ko‘rsatiladigan baho: tasdiqlanmagan manbaga tayansa — har mezon
  /// ko‘pi bilan 1 («qisman / tekshirilmagan manba»).
  CourtScore effectiveScore(CourtOption o) => reliesOnUnverified(o)
      ? CourtScore({
          for (final c in CourtCriterion.values)
            c: o.score.of(c) > 1 ? 1 : o.score.of(c),
        })
      : o.score;
}

/// Simulyatordagi bitta urinish (faqat qurilmada saqlanadi).
@immutable
class CourtAttempt {
  const CourtAttempt({
    required this.scenarioId,
    required this.score,
    required this.at,
    this.drill = false,
  });

  factory CourtAttempt.fromJson(Map<String, Object?> j) => CourtAttempt(
    scenarioId: '${j['s']}',
    score: CourtScore.fromJson(j['score']),
    at:
        DateTime.tryParse('${j['at']}') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    drill: j['drill'] == true,
  );

  final String scenarioId;
  final CourtScore score;
  final DateTime at;

  /// Rol mashqi (ketma-ket sudya → prokuror → advokat → ekspert) ichidami.
  final bool drill;

  Map<String, Object?> toJson() => {
    's': scenarioId,
    'score': {for (final c in CourtCriterion.values) c.name: score.of(c)},
    'at': at.toIso8601String(),
    if (drill) 'drill': true,
  };
}

/// Shaxsiy tayyorgarlik statistikasi (urinishlar tarixidan).
@immutable
class CourtStats {
  const CourtStats(this.attempts);

  final List<CourtAttempt> attempts;

  int get count => attempts.length;

  /// Mezon bo‘yicha o‘rtacha ball (0–2); urinish bo‘lmasa — 0.
  double average(CourtCriterion c) => attempts.isEmpty
      ? 0
      : attempts.map((a) => a.score.of(c)).reduce((a, b) => a + b) /
            attempts.length;

  int bestTotal(String scenarioId) => attempts
      .where((a) => a.scenarioId == scenarioId)
      .fold(0, (m, a) => a.score.total > m ? a.score.total : m);
}

/// Urinishlar tarixini JSON’ga o‘girish (eng ko‘pi bilan [limit] ta).
abstract final class CourtHistoryCodec {
  static const limit = 200;

  static List<CourtAttempt> decode(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return const [];
      return [
        for (final x in list)
          if (x is Map<String, Object?>) CourtAttempt.fromJson(x),
      ];
    } on FormatException {
      return const [];
    }
  }

  static String encode(List<CourtAttempt> attempts) => jsonEncode([
    for (final a
        in attempts.length > limit
            ? attempts.sublist(attempts.length - limit)
            : attempts)
      a.toJson(),
  ]);
}

/// Simulyator tarixi ombori (faqat qurilmada).
abstract interface class CourtHistoryStore {
  List<CourtAttempt> load();
  Future<void> save(List<CourtAttempt> attempts);
}

class InMemoryCourtHistoryStore implements CourtHistoryStore {
  InMemoryCourtHistoryStore([List<CourtAttempt> initial = const []])
    : _items = [...initial];

  List<CourtAttempt> _items;

  @override
  List<CourtAttempt> load() => List.unmodifiable(_items);

  @override
  Future<void> save(List<CourtAttempt> attempts) async =>
      _items = [...attempts];
}
