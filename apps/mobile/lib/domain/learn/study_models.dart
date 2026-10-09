/// O‘quv rejimi (study mode): kartochkalar, mashq testi va baholanadigan
/// imtihon.
///
/// Hech qanday yangi ilmiy matn yozilmaydi: har bir kartochka va savol
/// ilovada **allaqachon mavjud**, manbasi biriktirilgan yozuvdan
/// deterministik tarzda quriladi:
///
/// * bilim yozuvi (mavzu, metod…) ↔ unga biriktirilgan manbadagi asl jumla
///   (`definition` / `principle` / `use` / `marker` claim’lari);
/// * modda ↔ molekulyar formula (`identity` claim’i, manbasi bilan);
/// * yo‘riqnoma sarlavhasi ↔ uning qisqa mazmuni (karta manbalari bilan);
/// * yo‘riqnomaga biriktirilgan muallif savoli (aniq distraktorlar, izoh,
///   sahifa yoki bo‘lim bilan).
///
/// Distraktorlar faqat **bir xil ma’no sohasidan** olinadi ([StudyItem.domain]:
/// bir fan oilasi, bir modda guruhi yoki bir yo‘riqnoma yo‘nalishi) va
/// semantik cheklovlarga mos bo‘lishi kerak (birlik, formula sinfi). 3 tadan
/// kam mos distraktor bo‘lsa — savol «To‘g‘ri / Noto‘g‘ri» ko‘rinishiga
/// o‘tadi, umuman bo‘lmasa — faqat kartochka.
///
/// Baholanadigan imtihonga faqat [StudyEligibility.examEligible] dagi
/// elementlar kiradi; qolganlari — faqat mashq (aniq belgilangan).
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
    this.section,
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
    );
  }

  /// Yo‘riqnoma adabiyoti (to‘liq iqtibos matni), kerak bo‘lsa sahifalar va
  /// karta bo‘limi bilan.
  factory StudyCitation.fromReference(
    GuidelineReference r, {
    String? pages,
    LocalizedText? section,
  }) => StudyCitation(title: r.citation, pages: pages, section: section);

  final String title;
  final String? detail;

  /// `null` — manba alohida sahifaga ega emas (yo‘riqnoma adabiyoti).
  final String? sourceId;

  /// Manba ichidagi joy (bo‘lim), bo‘lsa.
  final String? locator;

  /// Manbadagi sahifa(lar) — o‘quv-uslubiy majmua savollari uchun.
  final String? pages;

  /// Karta bo‘limi (manba shu bo‘limda keltirilgan), bo‘lsa.
  final LocalizedText? section;

  /// Aniq joy ko‘rsatilgan: sahifa, manba ichidagi bo‘lim yoki karta bo‘limi.
  bool get hasLocator =>
      (pages?.trim().isNotEmpty ?? false) ||
      (locator?.trim().isNotEmpty ?? false) ||
      (section?.values.values.any((v) => v.trim().isNotEmpty) ?? false);
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
    this.domain = '',
    this.answerIsQuote = false,
    this.draftLanguages = const {},
    this.group,
    this.distractors = const [],
    this.explanation,
    this.claimId,
  });

  final String id;
  final StudyItemKind kind;
  final String deckId;

  /// Ma’no sohasi: distraktorlar faqat shu sohadan (masalan,
  /// `topic:forensic_medicine`, `substance:opioids`,
  /// `guideline:forensicChemistry`). Bo‘sh — distraktor olinmaydi.
  final String domain;

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

  /// Javob — manbadagi asl jumla (asl tilda; tarjimasi bo‘lsa UI uni
  /// birinchi ko‘rsatadi, holat belgisi bilan).
  final bool answerIsQuote;

  /// Tarjimasi hali qoralama bo‘lgan tillar (yo‘riqnomalar).
  final Set<String> draftLanguages;

  /// Tahririy guruh (moddalar uchun), bo‘lsa.
  final String? group;

  /// Aniq (muallif yozgan) noto‘g‘ri variantlar. Bo‘sh bo‘lsa —
  /// distraktorlar shu [domain] dagi boshqa kartochkalardan olinadi.
  final List<LocalizedText> distractors;

  /// Muallif yozgan izoh (nega to‘g‘ri / nega boshqalari noto‘g‘ri).
  /// Avtomatik elementlarda `null` — izoh manbali claim matni va manba
  /// qatoridan quriladi ([StudyExplanationKind]).
  final LocalizedText? explanation;

  /// Mavzu kartochkasi tayangan claim (tarjima qidirish uchun).
  final String? claimId;

  StudyItem copyWith({String? deckId}) => StudyItem(
    id: id,
    kind: kind,
    deckId: deckId ?? this.deckId,
    domain: domain,
    prompt: prompt,
    answer: answer,
    status: status,
    isTestData: isTestData,
    citations: citations,
    origin: origin,
    originId: originId,
    answerIsQuote: answerIsQuote,
    draftLanguages: draftLanguages,
    group: group,
    distractors: distractors,
    explanation: explanation,
    claimId: claimId,
  );

  /// Izoh qanday quriladi.
  StudyExplanationKind get explanationKind => switch (kind) {
    StudyItemKind.guidelineQuestion => StudyExplanationKind.authored,
    StudyItemKind.topicExcerpt => StudyExplanationKind.sourcedClaim,
    StudyItemKind.substanceFormula => StudyExplanationKind.substanceIdentity,
    StudyItemKind.guidelineSummary => StudyExplanationKind.guidelineSummary,
  };

  /// Tanlangan tilda izoh bor: muallif izohi shu tilda, yoki avtomatik
  /// elementda manbali javob matni + kamida bitta manba.
  bool hasExplanation(String lang) {
    if (explanationKind == StudyExplanationKind.authored) {
      final t = explanation?.values[lang]?.trim();
      return t != null && t.isNotEmpty && citations.isNotEmpty;
    }
    return answer.values.values.any((v) => v.trim().isNotEmpty) &&
        citations.isNotEmpty;
  }
}

/// Javobdan keyingi izoh manbai.
enum StudyExplanationKind {
  /// Muallif yozgan uch tilli izoh (karta matnidan, sahifa bilan).
  authored,

  /// Manbadagi claim matni (UI tilidagi tarjima birinchi) + manba qatori.
  sourcedClaim,

  /// Modda identifikatsiya yozuvidagi formula + manba qatori.
  substanceIdentity,

  /// Yo‘riqnoma kartasining qisqa mazmuni + adabiyot.
  guidelineSummary,
}

/// Savolning test ko‘rinishi.
enum StudyQuizFormat {
  /// 4 variantli test (bitta to‘g‘ri javob).
  multipleChoice,

  /// Taklif etilgan javob — «To‘g‘ri» yoki «Noto‘g‘ri» (mos distraktor
  /// 3 tadan kam).
  trueFalse,

  /// Faqat kartochka (mos distraktor yo‘q).
  flashcardOnly,
}

/// Test rejimi.
enum StudyQuizMode {
  /// Mashq: barcha savollar, javobdan so‘ng darhol izoh. Baholanmaydi.
  practice,

  /// Imtihon: faqat [StudyEligibility.examEligible] savollar; natija
  /// oxirida.
  exam,
}

/// Baholanadigan imtihonga kirish qoidalari.
abstract final class StudyEligibility {
  /// Imtihonda kamida shuncha savol bo‘lishi kerak.
  static const examMinItems = 5;

  /// Element imtihonga kiradimi ([lang] — UI tili):
  /// * muallif yozgan javob kaliti va 3 ta mantiqan bog‘liq distraktor;
  /// * har bir manbada aniq joy (sahifa yoki karta bo‘limi);
  /// * shu tilda izoh;
  /// * shu tildagi matn qoralama emas (`AUTHORED` / tekshirilgan);
  /// * test ma’lumoti emas, rad etilgan/eskirgan emas.
  static bool examEligible(StudyItem i, String lang) =>
      i.kind == StudyItemKind.guidelineQuestion &&
      i.distractors.length >= StudyQuizBuilder.distractorCount &&
      i.citations.isNotEmpty &&
      i.citations.every((c) => c.hasLocator) &&
      i.hasExplanation(lang) &&
      !i.draftLanguages.contains(lang) &&
      !i.isTestData &&
      i.status != ScientificStatus.rejected &&
      i.status != ScientificStatus.outdated;

  /// Nega imtihonga kirmaydi (UI va hisobot uchun), mos bo‘lsa `null`.
  static StudyIneligibility? reason(StudyItem i, String lang) {
    if (i.kind != StudyItemKind.guidelineQuestion ||
        i.distractors.length < StudyQuizBuilder.distractorCount) {
      return StudyIneligibility.autoGenerated;
    }
    if (i.citations.isEmpty || !i.citations.every((c) => c.hasLocator)) {
      return StudyIneligibility.noLocator;
    }
    if (!i.hasExplanation(lang)) return StudyIneligibility.noExplanation;
    if (i.draftLanguages.contains(lang)) {
      return StudyIneligibility.draftTranslation;
    }
    if (!examEligible(i, lang)) return StudyIneligibility.notUsable;
    return null;
  }
}

enum StudyIneligibility {
  autoGenerated,
  noLocator,
  noExplanation,
  draftTranslation,
  notUsable,
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

  /// `ForensicDiscipline.name`, modda guruhi, `GuidelineArea.name`,
  /// o‘quv-uslubiy majmua kaliti ([StudyCatalogBuilder.toksDeckKey]) yoki
  /// [StudyCatalogBuilder.mixedDeckKey] (kichik to‘plamlar birlashmasi).
  final String key;
  final List<StudyItem> items;

  bool get isMixed => key == StudyCatalogBuilder.mixedDeckKey;

  /// Eng zaif status (hech qachon ko‘tarilmaydi).
  ScientificStatus get status =>
      aggregateStatus([for (final i in items) i.status]);

  bool get isTestData => items.any((i) => i.isTestData);
}

class StudyCatalog {
  StudyCatalog(this.decks);

  static final empty = StudyCatalog(const []);

  final List<StudyDeck> decks;

  bool get isEmpty => decks.isEmpty;

  StudyDeck? deck(String id) {
    for (final d in decks) {
      if (d.id == id) return d;
    }
    return null;
  }

  /// Bir xil turdagi barcha kartochkalar.
  List<StudyItem> itemsOfKind(StudyItemKind kind) => [
    for (final d in decks)
      for (final i in d.items)
        if (i.kind == kind) i,
  ];

  late final Map<String, List<StudyItem>> _pools = _buildPools();

  Map<String, List<StudyItem>> _buildPools() {
    final out = <String, List<StudyItem>>{};
    for (final kind in StudyItemKind.values) {
      final all = itemsOfKind(kind);
      for (final i in all) {
        if (i.distractors.isNotEmpty) continue;
        out[i.id] = StudyQuizBuilder.plausible(i, all);
      }
    }
    return out;
  }

  /// [item] uchun mantiqan mos distraktorlar (o‘xshashlik bo‘yicha
  /// saralangan). Muallif distraktorlari bo‘lsa — bo‘sh.
  List<StudyItem> plausibleDistractors(StudyItem item) =>
      _pools[item.id] ?? const [];

  /// Element test ko‘rinishi.
  StudyQuizFormat formatOf(StudyItem item) {
    if (item.distractors.length >= StudyQuizBuilder.distractorCount) {
      return StudyQuizFormat.multipleChoice;
    }
    final n = plausibleDistractors(item).length;
    if (n >= StudyQuizBuilder.distractorCount) {
      return StudyQuizFormat.multipleChoice;
    }
    return n > 0 ? StudyQuizFormat.trueFalse : StudyQuizFormat.flashcardOnly;
  }
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

  /// Kichik to‘plamlar ([minDeckSize] dan kam) shu kalitli bitta aralash
  /// to‘plamga birlashtiriladi (bo‘lim ichida).
  static const mixedDeckKey = 'mixed';
  static const minDeckSize = 4;

  /// Manba kaliti prefiksi bo‘yicha o‘quv-uslubiy majmua to‘plami.
  static String teachingDeckKey(List<GuidelineReference> source) =>
      source.any((r) => r.key.startsWith('gmt_')) ? gmtDeckKey : toksDeckKey;

  /// Bilim yozuvi uchun claim maydonlari — ustuvorlik tartibida.
  static const topicFields = ['definition', 'principle', 'use', 'marker'];

  /// Mavzu distraktorlari uchun fan oilasi: bir oiladagi fanlar bir ma’no
  /// sohasi hisoblanadi (masalan, sud-tibbiyot va sud patologiyasi), boshqa
  /// fanlar aralashtirilmaydi.
  static const disciplineFamily = {
    'forensicMedicine': 'forensic_medicine',
    'forensicPathology': 'forensic_medicine',
    'clinicalForensicMedicine': 'forensic_medicine',
    'forensicRadiology': 'forensic_medicine',
    'forensicAnthropology': 'identification',
    'forensicOdontology': 'identification',
    'humanIdentification': 'identification',
    'forensicEntomology': 'postmortem_biology',
    'forensicMicrobiology': 'postmortem_biology',
  };

  static String topicDomain(ForensicDiscipline d) =>
      'topic:${disciplineFamily[d.name] ?? d.name}';

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

  /// Karta bo‘limi, unda [key] manbasi keltirilgan (birinchisi).
  static LocalizedText? _sectionCiting(GuidelineCard card, String key) {
    for (final s in card.sections) {
      if (s.citations.contains(key)) return LocalizedText(s.title.values);
    }
    return null;
  }

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
        final discipline = e.effectiveDiscipline;
        add(
          StudyDeckKind.discipline,
          discipline.name,
          StudyItem(
            id: 'topic.${e.id}',
            kind: StudyItemKind.topicExcerpt,
            deckId: 'discipline.${discipline.name}',
            domain: topicDomain(discipline),
            prompt: e.name,
            // Asl jumla (manba tili — inglizcha); tarjima UI’da birinchi.
            answer: LocalizedText({'en': claim.excerpt!.trim()}),
            answerIsQuote: true,
            claimId: claim.claimId,
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
          // «other» — tahririy guruhi yo‘q: bir sohaga kiritilmaydi.
          domain: e.group == null ? '' : 'substance:$group',
          prompt: e.name,
          answer: LocalizedText({'en': formula}),
          claimId: claim.claimId,
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
      final drafts = {
        for (final lang in const ['uz', 'ru', 'en'])
          if (card.translationFor(lang) == GuidelineTranslationStatus.draft)
            lang,
      };
      add(
        StudyDeckKind.guidelineArea,
        area,
        StudyItem(
          id: 'guideline.${card.id}',
          kind: StudyItemKind.guidelineSummary,
          deckId: 'guideline.$area',
          domain: area == GuidelineArea.other.name ? '' : 'guideline:$area',
          prompt: LocalizedText(card.title.values),
          answer: LocalizedText(card.summary.values),
          status: card.status,
          isTestData: false,
          citations: [for (final r in refs) StudyCitation.fromReference(r)],
          origin: StudyOrigin.guideline,
          originId: card.id,
          draftLanguages: drafts,
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
        StudyCitation cite(GuidelineReference r, {required bool paged}) =>
            StudyCitation.fromReference(
              r,
              pages: paged ? q.pages : null,
              section: _sectionCiting(card, r.key),
            );
        add(
          toks ? StudyDeckKind.teachingMaterial : StudyDeckKind.guidelineArea,
          toks ? teachingKey : area,
          StudyItem(
            id: 'gq.${card.id}.${q.id}',
            kind: StudyItemKind.guidelineQuestion,
            deckId: toks ? 'teaching.$teachingKey' : 'guideline.$area',
            domain: 'gq:${card.id}',
            prompt: LocalizedText(q.question.values),
            answer: LocalizedText(q.answer.values),
            status: card.status,
            isTestData: false,
            citations: [
              if (cited != null)
                for (final r in cited) cite(r, paged: r.isYuldashevMaterial)
              else
                for (final r in toks ? source : refs) cite(r, paged: toks),
            ],
            origin: StudyOrigin.guideline,
            originId: card.id,
            draftLanguages: drafts,
            distractors: [
              for (final d in q.distractors) LocalizedText(d.values),
            ],
            explanation: q.explanation.values.isEmpty
                ? null
                : LocalizedText(q.explanation.values),
          ),
        );
      }
    }

    // Kichik to‘plamlar (1–3 element) — bo‘lim ichida bitta aralash
    // to‘plamga. Distraktor sohasi ([StudyItem.domain]) o‘zgarmaydi, ya’ni
    // aralash to‘plamda ham fanlar bir-biriga distraktor bo‘lmaydi.
    final merged = <String, (StudyDeckKind, String, List<StudyItem>)>{};
    for (final MapEntry(key: id, value: (kind, key, items)) in byDeck.entries) {
      if (kind == StudyDeckKind.teachingMaterial ||
          items.length >= minDeckSize) {
        merged[id] = (kind, key, items);
        continue;
      }
      final mixedId = '${id.split('.').first}.$mixedDeckKey';
      merged.putIfAbsent(mixedId, () => (kind, mixedDeckKey, [])).$3.addAll([
        for (final i in items) i.copyWith(deckId: mixedId),
      ]);
    }

    final decks =
        [
          for (final MapEntry(key: id, value: (kind, key, items))
              in merged.entries)
            StudyDeck(
              id: id,
              kind: kind,
              key: key,
              items: [...items]..sort((a, b) => a.id.compareTo(b.id)),
            ),
        ]..sort((a, b) {
          final k = a.kind.index.compareTo(b.kind.index);
          if (k != 0) return k;
          // Aralash to‘plam bo‘lim oxirida.
          final m = (a.isMixed ? 1 : 0).compareTo(b.isMixed ? 1 : 0);
          return m != 0 ? m : a.key.compareTo(b.key);
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
// Test (mashq va imtihon)
// ---------------------------------------------------------------------------

@immutable
class StudyQuestion {
  const StudyQuestion({
    required this.item,
    required this.options,
    required this.correctIndex,
    this.format = StudyQuizFormat.multipleChoice,
  });

  final StudyItem item;

  /// [StudyQuizFormat.multipleChoice]: variantlar — to‘g‘risi [correctIndex]
  /// da. [StudyQuizFormat.trueFalse]: bitta taklif etilgan javob
  /// (o‘zi yoki shu sohadagi distraktor).
  final List<StudyItem> options;

  /// Ko‘p variantli: to‘g‘ri variant indeksi. To‘g‘ri/Noto‘g‘ri:
  /// 0 — «To‘g‘ri», 1 — «Noto‘g‘ri».
  final int correctIndex;
  final StudyQuizFormat format;

  bool get isTrueFalse => format == StudyQuizFormat.trueFalse;

  /// Tanlov tugmalari soni.
  int get choiceCount => isTrueFalse ? 2 : options.length;

  bool isCorrect(int choice) => choice == correctIndex;

  /// `true` — savol javob matnini ko‘rsatib, yozuv nomini so‘raydi
  /// (asl jumla / mazmun → nom). Formulada — nom → formula.
  bool get asksForPrompt => askForPrompt(item.kind);

  static bool askForPrompt(StudyItemKind k) =>
      k != StudyItemKind.substanceFormula &&
      k != StudyItemKind.guidelineQuestion;

  LocalizedText get stem => asksForPrompt ? item.answer : item.prompt;

  LocalizedText optionText(int i) =>
      asksForPrompt ? options[i].prompt : options[i].answer;

  /// To‘g‘ri/Noto‘g‘ri savolidagi taklif etilgan javob.
  LocalizedText get proposed => optionText(0);

  /// To‘g‘ri javob matni (ikkala ko‘rinishda ham).
  LocalizedText get correctText => asksForPrompt ? item.prompt : item.answer;
}

abstract final class StudyQuizBuilder {
  static const distractorCount = 3;
  static const defaultLength = 10;
  static const examLength = 20;

  /// Eng o‘xshash nomzodlardan shuncha tasi orasidan tanlanadi.
  static const _window = 6;

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

  static final _unit = RegExp(
    r'(?<=\d)\s?(mg/L|mg/kg|µg/mL|μg/mL|ng/mL|g/L|mmol/L|L/kg|°C|nm|%|h|min)'
    r'(?![A-Za-z])',
  );

  /// Javobdagi o‘lchov birliklari (raqamli javoblar uchun: variantlar
  /// bir xil birlikda bo‘lishi shart).
  static Set<String> unitSignature(String text) => {
    for (final m in _unit.allMatches(text)) m[1]!,
    if (RegExp(r'\bpH\b').hasMatch(text)) 'pH',
  };

  static final _element = RegExp(r'([A-Z][a-z]?)(\d*)');

  /// Formula → element: atomlar soni.
  static Map<String, int> parseFormula(String f) => {
    for (final m in _element.allMatches(f))
      m[1]!: (m[2]!.isEmpty ? 1 : int.parse(m[2]!)),
  };

  /// Organik molekula: C va H bor va 3 atomdan katta (HCN, CO kabi kichik
  /// molekulalar noorganik gazlar bilan bir sinfda).
  static bool _organic(Map<String, int> f) =>
      f.containsKey('C') &&
      f.containsKey('H') &&
      f.values.fold<int>(0, (a, b) => a + b) > 3;

  /// [candidate] — [item] uchun ilmiy jihatdan o‘rinli distraktormi:
  /// bir xil tur, bir xil ma’no sohasi, bir xil birliklar; formulada —
  /// bir xil sinf (organik / noorganik). Hech qachon boshqa fan emas.
  static bool compatible(StudyItem item, StudyItem candidate) {
    if (candidate.kind != item.kind || candidate.id == item.id) return false;
    if (item.domain.isEmpty || candidate.domain != item.domain) return false;
    if (candidate.isTestData != item.isTestData) return false;
    if (_clash(_shown(candidate), _shown(item))) return false;
    // Birlik variant sifatida ko‘rsatiladigan matndan olinadi.
    final a = _shown(item).resolve('en'), b = _shown(candidate).resolve('en');
    if (!setEquals(unitSignature(a), unitSignature(b))) return false;
    if (item.kind == StudyItemKind.substanceFormula &&
        _organic(parseFormula(a)) != _organic(parseFormula(b))) {
      return false;
    }
    return true;
  }

  /// O‘xshashlik (katta — yaqinroq): formulada umumiy elementlar va uglerod
  /// soni yaqinligi; boshqalarda 0 (faqat soha).
  static double similarity(StudyItem item, StudyItem c) {
    if (item.kind != StudyItemKind.substanceFormula) return 0;
    final x = parseFormula(item.answer.resolve('en'));
    final y = parseFormula(c.answer.resolve('en'));
    final keys = {...x.keys, ...y.keys};
    final shared = x.keys.where(y.containsKey).length;
    final jaccard = keys.isEmpty ? 0.0 : shared / keys.length;
    final cx = x['C'] ?? 0, cy = y['C'] ?? 0;
    final near = 1 / (1 + (cx - cy).abs() / max(1, max(cx, cy)) * 4);
    return jaccard + near;
  }

  /// [pool] dagi mos distraktorlar — o‘xshashlik bo‘yicha, so‘ng ID.
  static List<StudyItem> plausible(StudyItem item, Iterable<StudyItem> pool) {
    final out = [
      for (final p in pool)
        if (compatible(item, p)) p,
    ];
    out.sort((a, b) {
      final s = similarity(item, b).compareTo(similarity(item, a));
      return s != 0 ? s : a.id.compareTo(b.id);
    });
    // Bir-biriga to‘qnashadiganlar (bir xil formula) — faqat birinchisi.
    final unique = <StudyItem>[];
    for (final c in out) {
      if (unique.any((u) => _clash(_shown(u), _shown(c)))) continue;
      unique.add(c);
    }
    return unique;
  }

  /// Distraktorlar: faqat [compatible] nomzodlardan; eng o‘xshash
  /// [_window] tasi orasidan tasodifiy (seed bo‘yicha) [count] ta.
  static List<StudyItem> distractors(
    StudyItem item,
    Iterable<StudyItem> pool,
    Random random, {
    int count = distractorCount,
  }) {
    final ranked = plausible(item, pool);
    final window = ranked.take(max(_window, count)).toList()..shuffle(random);
    return window.take(count).toList();
  }

  /// Rejimga mos elementlar ([lang] — UI tili, imtihon uchun).
  static List<StudyItem> quizItems(
    StudyDeck deck,
    StudyCatalog catalog, {
    StudyQuizMode mode = StudyQuizMode.practice,
    String lang = 'uz',
  }) => [
    for (final i in deck.items)
      if (mode == StudyQuizMode.exam
          ? StudyEligibility.examEligible(i, lang)
          : catalog.formatOf(i) != StudyQuizFormat.flashcardOnly)
        i,
  ];

  /// To‘plam bo‘yicha test. Bir xil [seed] — bir xil test.
  static List<StudyQuestion> build(
    StudyDeck deck,
    StudyCatalog catalog, {
    required int seed,
    int? length,
    StudyQuizMode mode = StudyQuizMode.practice,
    String lang = 'uz',
  }) {
    final random = Random(seed);
    final limit =
        length ?? (mode == StudyQuizMode.exam ? examLength : defaultLength);
    final items = quizItems(deck, catalog, mode: mode, lang: lang)
      ..sort((a, b) => a.id.compareTo(b.id))
      ..shuffle(random);
    final questions = <StudyQuestion>[];
    for (final item in items) {
      if (questions.length >= limit) break;
      final q = _question(item, catalog, random);
      if (q != null) questions.add(q);
    }
    return questions;
  }

  static StudyQuestion? _question(
    StudyItem item,
    StudyCatalog catalog,
    Random random,
  ) {
    switch (catalog.formatOf(item)) {
      case StudyQuizFormat.flashcardOnly:
        return null;
      case StudyQuizFormat.multipleChoice:
        final wrong = item.distractors.isNotEmpty
            ? _explicit(item)
            : distractors(item, catalog.plausibleDistractors(item), random);
        final options = [item, ...wrong]..shuffle(random);
        return StudyQuestion(
          item: item,
          options: options,
          correctIndex: options.indexOf(item),
        );
      case StudyQuizFormat.trueFalse:
        final pool = catalog.plausibleDistractors(item);
        final truthful = random.nextBool();
        final shown = truthful ? item : pool[random.nextInt(pool.length)];
        return StudyQuestion(
          item: item,
          options: [shown],
          correctIndex: truthful ? 0 : 1,
          format: StudyQuizFormat.trueFalse,
        );
    }
  }

  /// Aniq distraktorlar — faqat variant matni uchun ishlatiladigan
  /// yordamchi kartochkalar (katalogga qo‘shilmaydi).
  static List<StudyItem> _explicit(StudyItem item) => [
    for (final (i, d) in item.distractors.indexed)
      StudyItem(
        id: '${item.id}#d$i',
        kind: item.kind,
        deckId: item.deckId,
        domain: item.domain,
        prompt: item.prompt,
        answer: d,
        status: item.status,
        isTestData: item.isTestData,
        citations: const [],
        origin: item.origin,
        originId: item.originId,
      ),
  ];

  /// To‘plamdan mashq testi tuzish mumkinmi.
  static bool canQuiz(StudyDeck deck, StudyCatalog catalog) =>
      quizItems(deck, catalog).isNotEmpty;

  /// Imtihonga mos savollar soni ([lang] — UI tili).
  static int examCount(StudyDeck deck, StudyCatalog catalog, String lang) =>
      quizItems(deck, catalog, mode: StudyQuizMode.exam, lang: lang).length;

  /// Imtihon tuzish mumkinmi (kamida [StudyEligibility.examMinItems]).
  static bool canExam(StudyDeck deck, StudyCatalog catalog, String lang) =>
      examCount(deck, catalog, lang) >= StudyEligibility.examMinItems;
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
