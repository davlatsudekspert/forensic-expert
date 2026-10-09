/// O‘quv rejimi (study mode): kartochkalar va o‘z-o‘zini tekshirish testi.
///
/// Hech qanday yangi ilmiy matn yozilmaydi: har bir kartochka va savol
/// ilovada **allaqachon mavjud**, manbasi biriktirilgan yozuvdan
/// deterministik tarzda quriladi:
///
/// * bilim yozuvi (mavzu, metod…) ↔ unga biriktirilgan manbadagi asl jumla
///   (`definition` / `principle` / `use` / `marker` claim’lari);
/// * modda ↔ molekulyar formula (`identity` claim’i, manbasi bilan);
/// * yo‘riqnoma sarlavhasi ↔ uning qisqa mazmuni (karta manbalari bilan).
///
/// Manbasiz yozuv o‘quv materialiga kirmaydi. Status yozuvdan olinadi va
/// hech qachon ko‘tarilmaydi. Tasodifiylik faqat berilgan `seed` orqali.
library;

import 'dart:convert';
import 'dart:math';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/foundation.dart';

import '../guidelines/guideline_models.dart';
import '../knowledge/knowledge_models.dart';
import '../library/library_models.dart';

/// Kartochka turi (savol yo‘nalishi shunga bog‘liq).
enum StudyItemKind {
  /// Bilim yozuvi nomi ↔ manbadagi asl jumla.
  topicExcerpt,

  /// Modda nomi ↔ molekulyar formula.
  substanceFormula,

  /// Yo‘riqnoma sarlavhasi ↔ qisqa mazmuni.
  guidelineSummary,

  /// Yo‘riqnomaga biriktirilgan savol ↔ to‘g‘ri javob (aniq distraktorlar
  /// bilan; o‘quv-uslubiy majmua faktlaridan mustaqil yozilgan).
  guidelineQuestion,
}

/// Kartochka qayerdan olingani (UI shu yozuvga havola beradi).
enum StudyOrigin { knowledgeEntry, libraryEntry, guideline }

/// Kartochkaga biriktirilgan manba.
@immutable
class StudyCitation {
  const StudyCitation({
    required this.title,
    this.detail,
    this.sourceId,
    this.locator,
    this.pages,
    this.language,
  });

  /// Kontent paketidagi manba (manba sahifasiga havola bilan).
  factory StudyCitation.fromSource(SourceView s) {
    final detail = [
      if (s.organization != null) s.organization!,
      if (s.journal != null) s.journal!,
      if (s.year != null) '${s.year}',
    ].join(' · ');
    return StudyCitation(
      title: s.title,
      detail: detail.isEmpty ? null : detail,
      sourceId: s.sourceId,
      locator: s.locator,
      language: s.language,
    );
  }

  /// Yo‘riqnoma adabiyoti (to‘liq iqtibos matni), kerak bo‘lsa sahifalar bilan.
  factory StudyCitation.fromReference(GuidelineReference r, {String? pages}) =>
      StudyCitation(title: r.citation, pages: pages);

  final String title;
  final String? detail;

  /// `null` — manba alohida sahifaga ega emas (yo‘riqnoma adabiyoti).
  final String? sourceId;

  /// Manba ichidagi joy (bo‘lim), bo‘lsa.
  final String? locator;

  /// Manbadagi sahifa(lar) — o‘quv-uslubiy majmua savollari uchun.
  final String? pages;

  /// Manba (asl sarlavha) tili, ma’lum bo‘lsa.
  final String? language;
}

/// Bitta o‘quv kartochkasi.
@immutable
class StudyItem {
  const StudyItem({
    required this.id,
    required this.kind,
    required this.deckId,
    required this.prompt,
    required this.answer,
    required this.status,
    required this.isTestData,
    required this.citations,
    required this.origin,
    required this.originId,
    this.answerIsQuote = false,
    this.answerQuoteId,
    this.draftLanguages = const {},
    this.group,
    this.distractors = const [],
  });

  final String id;
  final StudyItemKind kind;
  final String deckId;

  /// Kartochka old tomoni (yozuv nomi).
  final LocalizedText prompt;

  /// Orqa tomoni (manbadagi jumla, formula yoki mazmun).
  final LocalizedText answer;

  /// Yozuvning review statusi (o‘zgartirilmaydi).
  final ScientificStatus status;
  final bool isTestData;
  final List<StudyCitation> citations;
  final StudyOrigin origin;
  final String originId;

  /// Javob — manbadagi asl jumla (asl tilda, tarjima qilinmagan).
  final bool answerIsQuote;

  /// Asl iqtibosning manba yozuvi (claim ID) — tarjima qatlami
  /// (`text_translations` `claim_excerpt`) shu ID bo‘yicha qidiriladi.
  final String? answerQuoteId;

  /// Tarjimasi hali qoralama bo‘lgan tillar (yo‘riqnomalar).
  final Set<String> draftLanguages;

  /// Tahririy guruh (moddalar uchun), bo‘lsa.
  final String? group;

  /// Aniq (muallif yozgan) noto‘g‘ri variantlar. Bo‘sh bo‘lsa —
  /// distraktorlar bir xil turdagi boshqa kartochkalardan olinadi.
  final List<LocalizedText> distractors;
}

enum StudyDeckKind {
  discipline,
  substanceGroup,
  guidelineArea,

  /// O‘quv-uslubiy majmua bo‘yicha savollar (masalan, «Toksikologik kimyo»).
  teachingMaterial,
}

/// Fan / mavzu bo‘yicha kartochkalar to‘plami.
@immutable
class StudyDeck {
  const StudyDeck({
    required this.id,
    required this.kind,
    required this.key,
    required this.items,
  });

  final String id;
  final StudyDeckKind kind;

  /// `ForensicDiscipline.name`, modda guruhi, `GuidelineArea.name` yoki
  /// o‘quv-uslubiy majmua kaliti ([StudyCatalogBuilder.toksDeckKey]).
  final String key;
  final List<StudyItem> items;

  /// Eng zaif status (hech qachon ko‘tarilmaydi).
  ScientificStatus get status =>
      aggregateStatus([for (final i in items) i.status]);

  bool get isTestData => items.any((i) => i.isTestData);
}

@immutable
class StudyCatalog {
  const StudyCatalog(this.decks);

  static const empty = StudyCatalog([]);

  final List<StudyDeck> decks;

  bool get isEmpty => decks.isEmpty;

  StudyDeck? deck(String id) {
    for (final d in decks) {
      if (d.id == id) return d;
    }
    return null;
  }

  /// Bir xil turdagi barcha kartochkalar (distraktorlar manbai).
  List<StudyItem> itemsOfKind(StudyItemKind kind) => [
    for (final d in decks)
      for (final i in d.items)
        if (i.kind == kind) i,
  ];
}

/// Mavjud yozuvlardan katalog quradi (sof funksiya).
abstract final class StudyCatalogBuilder {
  /// «Toksikologik kimyo» majmuasi savollari to‘plami (bepul, egasi qarori).
  static const toksDeckKey = 'toks';
  static const toksDeckId = 'teaching.$toksDeckKey';

  /// «Giyohvand moddalar tahlili» (Yuldashev Z.A. va boshq., 2024) savollari
  /// to‘plami (bepul, egasi qarori).
  static const gmtDeckKey = 'gmt';
  static const gmtDeckId = 'teaching.$gmtDeckKey';

  /// Manba kaliti prefiksi bo‘yicha o‘quv-uslubiy majmua to‘plami.
  static String teachingDeckKey(List<GuidelineReference> source) =>
      source.any((r) => r.key.startsWith('gmt_')) ? gmtDeckKey : toksDeckKey;

  /// Bilim yozuvi uchun claim maydonlari — ustuvorlik tartibida.
  static const topicFields = ['definition', 'principle', 'use', 'marker'];

  static const _unusableLifecycles = {
    ClaimLifecycle.outdated,
    ClaimLifecycle.superseded,
    ClaimLifecycle.retracted,
    ClaimLifecycle.rejected,
  };

  static bool _usableStatus(ScientificStatus s) =>
      s != ScientificStatus.rejected && s != ScientificStatus.outdated;

  static List<SourceView> _usableSources(ClaimView c) => [
    for (final s in c.sources)
      if (!s.isRetracted) s,
  ];

  static bool _usableClaim(ClaimView c) =>
      _usableStatus(c.status) &&
      !_unusableLifecycles.contains(c.lifecycle) &&
      _usableSources(c).isNotEmpty;

  static bool _hasText(Map<String, String> v) =>
      v.values.any((x) => x.trim().isNotEmpty);

  /// [substancesUnlocked] / [referencesUnlocked] — pullik yozuvlar
  /// (`EntryAccess.lifetime`) faqat ruxsat bo‘lsa kiritiladi.
  static StudyCatalog build({
    KnowledgeRepository knowledge = const EmptyKnowledgeRepository(),
    LibraryRepository? library,
    GuidelineBundle guidelines = GuidelineBundle.empty,
    bool substancesUnlocked = false,
    bool referencesUnlocked = false,
  }) {
    final byDeck = <String, (StudyDeckKind, String, List<StudyItem>)>{};
    void add(StudyDeckKind kind, String key, StudyItem item) =>
        byDeck.putIfAbsent(item.deckId, () => (kind, key, [])).$3.add(item);

    // 1. Bilim yozuvlari: nom ↔ manbadagi asl jumla.
    for (final kind in KnowledgeKind.values) {
      for (final e in knowledge.byKind(kind)) {
        if (e.access != EntryAccess.free && !referencesUnlocked) continue;
        if (!_usableStatus(e.status)) continue;
        if (!_hasText(e.name.values)) continue;
        final claim = _topicClaim(e);
        if (claim == null) continue;
        final discipline = e.effectiveDiscipline.name;
        final deckId = 'discipline.$discipline';
        add(
          StudyDeckKind.discipline,
          discipline,
          StudyItem(
            id: 'topic.${e.id}',
            kind: StudyItemKind.topicExcerpt,
            deckId: deckId,
            prompt: e.name,
            // Asl jumla (manba tili — inglizcha) — dalil, o‘zgarmaydi; UI
            // tarjimani `answerQuoteId` bo‘yicha birinchi ko‘rsatadi.
            answer: LocalizedText({'en': claim.excerpt!.trim()}),
            answerIsQuote: true,
            answerQuoteId: claim.claimId,
            status: aggregateStatus([e.status, claim.status]),
            isTestData: e.isTestData,
            citations: [
              for (final s in _usableSources(claim))
                StudyCitation.fromSource(s),
            ],
            origin: StudyOrigin.knowledgeEntry,
            originId: e.id,
          ),
        );
      }
    }

    // 2. Moddalar: nom ↔ molekulyar formula (identity claim).
    for (final e
        in library?.entries(LibrarySection.substances) ??
            const <LibraryEntry>[]) {
      if (e.access != EntryAccess.free && !substancesUnlocked) continue;
      if (!_hasText(e.name.values)) continue;
      final claim = e.details?.claim('identity');
      if (claim == null || !_usableClaim(claim)) continue;
      final formula = '${claim.value['molecular_formula'] ?? ''}'.trim();
      if (formula.isEmpty) continue;
      final group = e.group ?? 'other';
      add(
        StudyDeckKind.substanceGroup,
        group,
        StudyItem(
          id: 'substance.${e.id}',
          kind: StudyItemKind.substanceFormula,
          deckId: 'group.$group',
          prompt: e.name,
          answer: LocalizedText({'en': formula}),
          status: aggregateStatus([e.status, claim.status]),
          isTestData: e.isTestData,
          citations: [
            for (final s in _usableSources(claim)) StudyCitation.fromSource(s),
          ],
          origin: StudyOrigin.libraryEntry,
          originId: e.id,
          group: e.group,
        ),
      );
    }

    // 3. Yo‘riqnomalar: sarlavha ↔ qisqa mazmun (karta manbalari bilan).
    for (final card in guidelines.cards) {
      if (!_usableStatus(card.status)) continue;
      if (!_hasText(card.title.values) || !_hasText(card.summary.values)) {
        continue;
      }
      final refs = guidelines.referencesOf(card);
      if (refs.isEmpty) continue;
      final area = card.area.name;
      add(
        StudyDeckKind.guidelineArea,
        area,
        StudyItem(
          id: 'guideline.${card.id}',
          kind: StudyItemKind.guidelineSummary,
          deckId: 'guideline.$area',
          prompt: LocalizedText(card.title.values),
          answer: LocalizedText(card.summary.values),
          status: card.status,
          isTestData: false,
          citations: [for (final r in refs) StudyCitation.fromReference(r)],
          origin: StudyOrigin.guideline,
          originId: card.id,
          draftLanguages: {
            for (final lang in const ['uz', 'ru', 'en'])
              if (card.translationFor(lang) == GuidelineTranslationStatus.draft)
                lang,
          },
        ),
      );

      // 4. Kartaga biriktirilgan savollar (aniq distraktorlar bilan). Prof.
      // Yuldashev materiallariga tayangan savollar — alohida bepul to‘plam.
      if (card.quiz.isEmpty) continue;
      final source = [
        for (final r in refs)
          if (r.isYuldashevMaterial) r,
      ];
      final toks = source.isNotEmpty;
      final teachingKey = teachingDeckKey(source);
      for (final q in card.quiz) {
        if (q.distractors.isEmpty) continue;
        // Savol aniq manbalarni ko‘rsatgan bo‘lsa — faqat o‘shalar
        // (sahifa faqat o‘quv-uslubiy materialga tegishli).
        final cited = q.cite.isEmpty
            ? null
            : [
                for (final r in refs)
                  if (q.cite.contains(r.key)) r,
              ];
        add(
          toks ? StudyDeckKind.teachingMaterial : StudyDeckKind.guidelineArea,
          toks ? teachingKey : area,
          StudyItem(
            id: 'gq.${card.id}.${q.id}',
            kind: StudyItemKind.guidelineQuestion,
            deckId: toks ? 'teaching.$teachingKey' : 'guideline.$area',
            prompt: LocalizedText(q.question.values),
            answer: LocalizedText(q.answer.values),
            status: card.status,
            isTestData: false,
            citations: [
              if (cited != null)
                for (final r in cited)
                  StudyCitation.fromReference(
                    r,
                    pages: r.isYuldashevMaterial ? q.pages : null,
                  )
              else
                for (final r in toks ? source : refs)
                  StudyCitation.fromReference(r, pages: toks ? q.pages : null),
            ],
            origin: StudyOrigin.guideline,
            originId: card.id,
            draftLanguages: {
              for (final lang in const ['uz', 'ru', 'en'])
                if (card.translationFor(lang) ==
                    GuidelineTranslationStatus.draft)
                  lang,
            },
            distractors: [
              for (final d in q.distractors) LocalizedText(d.values),
            ],
          ),
        );
      }
    }

    final decks =
        [
          for (final MapEntry(key: id, value: (kind, key, items))
              in byDeck.entries)
            StudyDeck(
              id: id,
              kind: kind,
              key: key,
              items: [...items]..sort((a, b) => a.id.compareTo(b.id)),
            ),
        ]..sort((a, b) {
          final k = a.kind.index.compareTo(b.kind.index);
          return k != 0 ? k : a.key.compareTo(b.key);
        });
    return StudyCatalog(decks);
  }

  static ClaimView? _topicClaim(KnowledgeEntry e) {
    for (final field in topicFields) {
      for (final c in e.claims) {
        if (c.field != field) continue;
        final excerpt = c.excerpt?.trim();
        if (excerpt == null || excerpt.isEmpty) continue;
        if (_usableClaim(c)) return c;
      }
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Test (multiple choice)
// ---------------------------------------------------------------------------

@immutable
class StudyQuestion {
  const StudyQuestion({
    required this.item,
    required this.options,
    required this.correctIndex,
  });

  final StudyItem item;

  /// Variantlar — bir xil turdagi yozuvlar (to‘g‘risi [correctIndex] da).
  final List<StudyItem> options;
  final int correctIndex;

  /// `true` — savol javob matnini ko‘rsatib, yozuv nomini so‘raydi
  /// (asl jumla / mazmun → nom). Formulada — nom → formula.
  bool get asksForPrompt => askForPrompt(item.kind);

  static bool askForPrompt(StudyItemKind k) =>
      k != StudyItemKind.substanceFormula &&
      k != StudyItemKind.guidelineQuestion;

  LocalizedText get stem => asksForPrompt ? item.answer : item.prompt;

  LocalizedText optionText(int i) =>
      asksForPrompt ? options[i].prompt : options[i].answer;
}

abstract final class StudyQuizBuilder {
  static const distractorCount = 3;
  static const defaultLength = 10;

  static LocalizedText _shown(StudyItem i) =>
      StudyQuestion.askForPrompt(i.kind) ? i.prompt : i.answer;

  static String _norm(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Ikki variant biror tilda bir xil ko‘rinsa — ular «to‘qnashadi».
  static bool _clash(LocalizedText a, LocalizedText b) {
    for (final e in a.values.entries) {
      final o = b.values[e.key];
      if (o != null && _norm(o) == _norm(e.value)) return true;
    }
    return false;
  }

  /// Distraktorlar: faqat **bir xil turdagi boshqa** yozuvlardan; avval
  /// shu to‘plamdan, keyin qolganlaridan. Ko‘rinishi to‘g‘ri javobga yoki
  /// bir-biriga mos keladiganlari tashlanadi.
  static List<StudyItem> distractors(
    StudyItem item,
    Iterable<StudyItem> pool,
    Random random, {
    int count = distractorCount,
  }) {
    final shown = _shown(item);
    final candidates = [
      for (final p in pool)
        if (p.kind == item.kind && p.id != item.id && !_clash(_shown(p), shown))
          p,
    ]..sort((a, b) => a.id.compareTo(b.id));
    final same = [
      for (final c in candidates)
        if (c.deckId == item.deckId) c,
    ]..shuffle(random);
    final other = [
      for (final c in candidates)
        if (c.deckId != item.deckId) c,
    ]..shuffle(random);
    final picked = <StudyItem>[];
    for (final c in [...same, ...other]) {
      if (picked.length >= count) break;
      if (picked.any((p) => _clash(_shown(p), _shown(c)))) continue;
      picked.add(c);
    }
    return picked;
  }

  /// To‘plam bo‘yicha test. Bir xil [seed] — bir xil test.
  static List<StudyQuestion> build(
    StudyDeck deck,
    StudyCatalog catalog, {
    required int seed,
    int length = defaultLength,
  }) {
    final random = Random(seed);
    final items = [...deck.items]..shuffle(random);
    final questions = <StudyQuestion>[];
    for (final item in items) {
      if (questions.length >= length) break;
      final wrong = item.distractors.isNotEmpty
          ? _explicit(item)
          : distractors(item, catalog.itemsOfKind(item.kind), random);
      if (wrong.isEmpty) continue;
      final options = [item, ...wrong]..shuffle(random);
      questions.add(
        StudyQuestion(
          item: item,
          options: options,
          correctIndex: options.indexOf(item),
        ),
      );
    }
    return questions;
  }

  /// Aniq distraktorlar — faqat variant matni uchun ishlatiladigan
  /// yordamchi kartochkalar (katalogga qo‘shilmaydi).
  static List<StudyItem> _explicit(StudyItem item) => [
    for (final (i, d) in item.distractors.indexed)
      StudyItem(
        id: '${item.id}#d$i',
        kind: item.kind,
        deckId: item.deckId,
        prompt: item.prompt,
        answer: d,
        status: item.status,
        isTestData: item.isTestData,
        citations: const [],
        origin: item.origin,
        originId: item.originId,
      ),
  ];

  /// To‘plamdan test tuzish mumkinmi (kamida bitta distraktor bor).
  static bool canQuiz(StudyDeck deck, StudyCatalog catalog) =>
      build(deck, catalog, seed: 0, length: 1).isNotEmpty;
}

// ---------------------------------------------------------------------------
// Leitner (oddiy spaced repetition)
// ---------------------------------------------------------------------------

@immutable
class LeitnerCard {
  const LeitnerCard({required this.box, required this.reviewedAt});

  /// 1…[LeitnerScheduler.maxBox].
  final int box;
  final DateTime reviewedAt;

  DateTime get dueAt => reviewedAt.add(LeitnerScheduler.intervalFor(box));

  Map<String, Object?> toJson() => {
    'b': box,
    't': reviewedAt.toUtc().toIso8601String(),
  };

  static LeitnerCard? fromJson(Object? j) {
    if (j is! Map) return null;
    final box = j['b'];
    final at = DateTime.tryParse('${j['t']}');
    if (box is! int || at == null) return null;
    return LeitnerCard(
      box: box.clamp(1, LeitnerScheduler.maxBox),
      reviewedAt: at,
    );
  }
}

abstract final class LeitnerScheduler {
  static const maxBox = 5;

  /// Quti → keyingi takrorlashgacha oraliq. 1-quti har sessiyada.
  static const intervals = [
    Duration.zero,
    Duration(days: 1),
    Duration(days: 3),
    Duration(days: 7),
    Duration(days: 14),
  ];

  static Duration intervalFor(int box) => intervals[box.clamp(1, maxBox) - 1];

  /// «Bilaman» — keyingi quti; «Bilmadim» — 1-quti.
  static LeitnerCard review(
    LeitnerCard? current, {
    required bool knew,
    required DateTime now,
  }) => LeitnerCard(
    // Yangi kartochka 1-qutida hisoblanadi.
    box: knew ? min((current?.box ?? 1) + 1, maxBox) : 1,
    reviewedAt: now,
  );

  static bool isDue(LeitnerCard? card, DateTime now) =>
      card == null || !now.isBefore(card.dueAt);

  /// Sessiya navbati: muddati kelgan takrorlashlar (past quti, eski muddat
  /// birinchi), so‘ng yangi kartochkalar (to‘plam tartibida).
  static List<StudyItem> dueQueue(
    List<StudyItem> items,
    Map<String, LeitnerCard> progress,
    DateTime now,
  ) {
    final due = [
      for (final i in items)
        if (progress[i.id] case final c? when isDue(c, now)) i,
    ];
    due.sort((a, b) {
      final x = progress[a.id]!, y = progress[b.id]!;
      final box = x.box.compareTo(y.box);
      if (box != 0) return box;
      final at = x.dueAt.compareTo(y.dueAt);
      return at != 0 ? at : a.id.compareTo(b.id);
    });
    return [
      ...due,
      for (final i in items)
        if (!progress.containsKey(i.id)) i,
    ];
  }

  /// Barcha kartochkalar (muddatidan qat’i nazar): past quti birinchi.
  static List<StudyItem> allByBox(
    List<StudyItem> items,
    Map<String, LeitnerCard> progress,
  ) {
    int box(StudyItem i) => progress[i.id]?.box ?? 0;
    return [...items]..sort((a, b) {
      final x = box(a).compareTo(box(b));
      return x != 0 ? x : a.id.compareTo(b.id);
    });
  }

  static int dueCount(
    List<StudyItem> items,
    Map<String, LeitnerCard> progress,
    DateTime now,
  ) => items.where((i) => isDue(progress[i.id], now)).length;
}

/// Leitner holati — faqat qurilmada.
abstract interface class StudyProgressStore {
  Map<String, LeitnerCard> load();

  Future<void> save(Map<String, LeitnerCard> progress);
}

class InMemoryStudyProgressStore implements StudyProgressStore {
  InMemoryStudyProgressStore([Map<String, LeitnerCard>? initial])
    : _data = {...?initial};

  Map<String, LeitnerCard> _data;

  @override
  Map<String, LeitnerCard> load() => {..._data};

  @override
  Future<void> save(Map<String, LeitnerCard> progress) async =>
      _data = {...progress};
}

/// JSON kodek (buzilgan qiymat — bo‘sh holat, xato emas).
abstract final class StudyProgressCodec {
  static String encode(Map<String, LeitnerCard> progress) =>
      jsonEncode({for (final e in progress.entries) e.key: e.value.toJson()});

  static Map<String, LeitnerCard> decode(String? text) {
    if (text == null || text.isEmpty) return {};
    try {
      final j = jsonDecode(text);
      if (j is! Map) return {};
      return {
        for (final e in j.entries) '${e.key}': ?LeitnerCard.fromJson(e.value),
      };
    } on FormatException {
      return {};
    }
  }
}
