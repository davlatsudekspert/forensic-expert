import 'package:fe_content_schema/fe_content_schema.dart'
    show
        ForensicDiscipline,
        InstrumentType,
        JurisdictionalInstrument,
        KnowledgeArea,
        LinkRelation,
        TermTranslation,
        disciplineOfArea;
import 'package:fe_search_core/fe_search_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/generated/app_localizations.dart';
import '../core/settings/app_settings.dart';
import '../domain/catalog/tools_catalog.dart';
import '../domain/evidence/evidence_models.dart';
import '../domain/evidence/provenance_models.dart';
import '../domain/guidelines/guideline_models.dart';
import '../domain/knowledge/knowledge_models.dart';
import '../domain/learn/learn_models.dart';
import '../domain/library/library_models.dart';
import '../features/tools/tool_strings.dart';
import 'guidelines.dart';
import 'providers.dart';

/// Standart belgilanishining qidiriladigan qismlari: `ANSI/ASTM E2329-25`
/// → `ASTM E2329-25`, `E2329-25`, `E2329`; `ICH Q2(R2)` → `Q2(R2)`.
/// (Indeks terminni boshidan moslaydi — raqamli belgilanish o‘rtada qoladi.)
List<String> designationAliases(String designation) {
  final tokens = designation
      .split(RegExp(r'[\s/]+'))
      .where((t) => t.isNotEmpty)
      .toList();
  final out = <String>{
    for (var i = 1; i < tokens.length; i++) tokens.sublist(i).join(' '),
  };
  final last = tokens.isEmpty ? '' : tokens.last;
  final noYear = last.replaceFirst(RegExp(r'-\d{2}$'), '');
  if (noYear != last && noYear.length >= 3) out.add(noYear);
  return out.toList();
}

/// Global Search natija guruhlari (UI tartibi).
/// PHASE 4 global taksonomiyasi (UI tartibi). Ichki (offline) natijalar —
/// tashqi ilmiy qidiruvdan vizual ajratilgan.
enum SearchGroup {
  substances,
  guidelines,
  topics,
  methods,
  reagents,
  screening,
  tools,
  standardsLaws,
  learning,
  references,
}

class AppSearchResult {
  const AppSearchResult(
    this.groups,
    this.latency, {
    this.disciplines = const [],
    this.discipline,
    this.linkedVia = const {},
  });

  final Map<SearchGroup, List<SearchHit>> groups;

  /// So‘rov natijalari mavjud bo‘lgan fanlar (filtrsiz natijalardan,
  /// taksonomiya tartibida). Filtr chiplari faqat shular uchun.
  final List<ForensicDiscipline> disciplines;

  /// Qo‘llangan fan filtri (`null` — barcha fanlar).
  final ForensicDiscipline? discipline;

  /// Bog‘langan yozuv orqali kelgan natija: natija ID → asosiy yozuv ID
  /// (masalan, metod ← «analysed_by» bog‘lanishidagi modda).
  final Map<String, String> linkedVia;

  /// O‘lchangan qidiruv vaqti (qurilmada, lokal indeks).
  final Duration latency;

  bool get isEmpty => groups.values.every((g) => g.isEmpty);

  int get total => groups.values.fold(0, (a, g) => a + g.length);
}

/// Ilova darajasidagi qidiruv: lokal indeks (offline) — tashqi qidiruv
/// bilan hech qachon aralashtirilmaydi.
class AppSearchService {
  AppSearchService(
    this._index, {
    this._disciplines = const {},
    this._linked = const {},
  });

  factory AppSearchService.build({
    required LibraryRepository library,
    required LearnRepository learn,
    KnowledgeRepository knowledge = const EmptyKnowledgeRepository(),
    Iterable<JurisdictionalInstrument> instruments = const [],
    Iterable<ResearchEntry> research = const [],
    ProvenanceIndex? provenance,
    GuidelineBundle guidelines = GuidelineBundle.empty,
    Iterable<GraphLink> links = const [],
  }) {
    final terms = <SearchTerm>[];
    // Natijani fan bo‘yicha filtrlash uchun: yozuv → fanlar (faqat mavjud
    // aniq xaritalar; fani noma’lum yozuv filtr tanlanganda ko‘rinmaydi).
    final disciplines = <String, Set<ForensicDiscipline>>{};
    void disc(String id, ForensicDiscipline? d) {
      if (d != null) disciplines.putIfAbsent(id, () => {}).add(d);
    }

    ForensicDiscipline? libraryDiscipline(LibrarySection? s) => switch (s) {
      LibrarySection.substances => ForensicDiscipline.forensicToxicology,
      LibrarySection.methods => disciplineOfArea(KnowledgeArea.methods),
      _ => null,
    };
    final jurisdiction = disciplineOfArea(KnowledgeArea.jurisdiction);

    // Yo‘riqnomalar: sarlavha (3 til) va kalit so‘zlar (sinonimlar).
    for (final g in guidelines.cards) {
      for (final code in g.disciplineCodes) {
        disc(g.id, ForensicDiscipline.fromCode(code));
        // Kartadagi atamalar — karta fanlari bo‘yicha filtrlanadi.
        for (final tid in g.termIds) {
          disc(tid, ForensicDiscipline.fromCode(code));
        }
      }
      for (final entry in g.title.values.entries) {
        terms.add(
          SearchTerm(
            entityId: g.id,
            category: SearchCategory.guideline,
            term: entry.value,
            kind: TermKind.localized,
            lang: entry.key,
          ),
        );
      }
      for (final entry in g.keywords.entries) {
        for (final k in entry.value) {
          terms.add(
            SearchTerm(
              entityId: g.id,
              category: SearchCategory.guideline,
              term: k,
              kind: TermKind.synonym,
              lang: entry.key,
            ),
          );
        }
      }
    }
    // PHASE 7: namunalar (EN/RU/UZ + manbadagi variantlar) va standartlar
    // katalogi (belgilanishi va sarlavhasi).
    for (final s in provenance?.specimens ?? const <SpecimenView>[]) {
      for (final entry in s.names.values.entries) {
        terms.add(
          SearchTerm(
            entityId: s.id,
            category: SearchCategory.specimen,
            term: entry.value,
            kind: TermKind.localized,
            lang: entry.key,
          ),
        );
      }
      for (final a in s.aliases) {
        terms.add(
          SearchTerm(
            entityId: s.id,
            category: SearchCategory.specimen,
            term: a,
            kind: TermKind.synonym,
          ),
        );
      }
    }
    // «Ilmiy lug‘at»: atama uz/ru/en (va manbadagi asl ko‘rinishi) bo‘yicha
    // topiladi; natija lug‘at yozuvini ochadi.
    for (final g in provenance?.terms ?? const <TermTranslation>[]) {
      final seen = <String>{};
      for (final entry in g.localized.entries) {
        if (entry.value.trim().isEmpty || !seen.add(entry.value)) continue;
        terms.add(
          SearchTerm(
            entityId: g.id,
            category: SearchCategory.glossary,
            term: entry.value,
            kind: TermKind.localized,
            lang: entry.key,
          ),
        );
      }
      for (final extra in [g.canonical, g.original]) {
        if (extra.trim().isEmpty || !seen.add(extra)) continue;
        terms.add(
          SearchTerm(
            entityId: g.id,
            category: SearchCategory.glossary,
            term: extra,
            kind: TermKind.synonym,
          ),
        );
      }
    }
    for (final st in provenance?.standards ?? const <StandardView>[]) {
      disc(st.id, jurisdiction);
      terms
        ..add(
          SearchTerm(
            entityId: st.id,
            category: SearchCategory.standard,
            term: st.designation,
            kind: TermKind.canonical,
          ),
        )
        ..add(
          SearchTerm(
            entityId: st.id,
            category: SearchCategory.standard,
            term: st.title,
            kind: TermKind.synonym,
          ),
        );
      for (final a in designationAliases(st.designation)) {
        terms.add(
          SearchTerm(
            entityId: st.id,
            category: SearchCategory.standard,
            term: a,
            kind: TermKind.abbreviation,
          ),
        );
      }
    }
    // PHASE 5 Research / Evidence Library — faqat sarlavha (metadata).
    for (final r in research) {
      // Research fani — bog‘langan yozuvlar fanidan (taxmin yo‘q).
      for (final id in r.linkedEntityIds) {
        disc(r.id, knowledge.byId(id)?.effectiveDiscipline);
        disc(r.id, libraryDiscipline(library.byId(id)?.section));
      }
      terms.add(
        SearchTerm(
          entityId: r.id,
          category: SearchCategory.reference,
          term: r.title,
          kind: TermKind.canonical,
        ),
      );
    }
    // PHASE 4 bilim sohalari.
    for (final kind in KnowledgeKind.values) {
      for (final e in knowledge.byKind(kind)) {
        final cat = switch (kind) {
          KnowledgeKind.reagent => SearchCategory.reagent,
          KnowledgeKind.screeningTest => SearchCategory.screeningTest,
          KnowledgeKind.method => SearchCategory.method,
          KnowledgeKind.emergingIssue => SearchCategory.emergingIssue,
          KnowledgeKind.topic =>
            e.area == KnowledgeArea.biochemistry
                ? SearchCategory.biochemistryTopic
                : SearchCategory.forensicMedicineTopic,
        };
        disc(e.id, e.effectiveDiscipline);
        for (final entry in e.name.values.entries) {
          terms.add(
            SearchTerm(
              entityId: e.id,
              category: cat,
              term: entry.value,
              kind: TermKind.localized,
              lang: entry.key,
            ),
          );
        }
        // Reaktiv sinonimlari: boshqa yozilishlar («Dragendorf», «Марки»).
        for (final syn in e.recipe?.synonyms ?? const <String>[]) {
          terms.add(
            SearchTerm(
              entityId: e.id,
              category: cat,
              term: syn,
              kind: TermKind.synonym,
            ),
          );
        }
      }
    }
    // Rasmiy hujjatlar (qonun / standart) — sarlavha bo‘yicha.
    for (final i in instruments) {
      final cat =
          i.type == InstrumentType.standard ||
              i.type == InstrumentType.officialGuideline
          ? SearchCategory.standard
          : SearchCategory.law;
      disc(i.id, jurisdiction);
      for (final entry in i.titles.entries) {
        terms.add(
          SearchTerm(
            entityId: i.id,
            category: cat,
            term: entry.value,
            kind: TermKind.canonical,
            lang: entry.key,
          ),
        );
      }
    }
    for (final section in LibrarySection.values) {
      for (final e in library.entries(section)) {
        final cat = switch (section) {
          LibrarySection.substances => SearchCategory.substance,
          LibrarySection.methods => SearchCategory.method,
          LibrarySection.specimens => SearchCategory.topic,
          LibrarySection.references => SearchCategory.reference,
          LibrarySection.glossary => SearchCategory.glossary,
        };
        disc(e.id, libraryDiscipline(section));
        for (final entry in e.name.values.entries) {
          terms.add(
            SearchTerm(
              entityId: e.id,
              category: cat,
              term: entry.value,
              kind: TermKind.localized,
              lang: entry.key,
            ),
          );
        }
        // Metabolitlar — ota moddaga olib boradi (manbali claim’lardan).
        for (final c in e.details?.claims ?? const <ClaimView>[]) {
          if (c.field != 'metabolites') continue;
          for (final m in c.items) {
            terms.add(
              SearchTerm(
                entityId: e.id,
                category: SearchCategory.metabolite,
                term: m,
                kind: TermKind.synonym,
              ),
            );
          }
        }
        for (final s in e.synonyms) {
          terms.add(
            SearchTerm(
              entityId: e.id,
              category: cat,
              term: s,
              kind: TermKind.synonym,
            ),
          );
        }
      }
    }
    for (final code in SupportedLanguages.codes) {
      final l = lookupAppLocalizations(Locale(code));
      for (final t in ToolsCatalog.all) {
        disc(t.id, switch (t.category) {
          ToolCategory.forensicMedicine => ForensicDiscipline.forensicMedicine,
          ToolCategory.toxicology => ForensicDiscipline.forensicToxicology,
          ToolCategory.laboratory => disciplineOfArea(KnowledgeArea.laboratory),
          ToolCategory.conversions => null,
        });
        terms.add(
          SearchTerm(
            entityId: t.id,
            category: SearchCategory.calculator,
            term: l.toolName(t),
            kind: TermKind.localized,
            lang: code,
          ),
        );
      }
    }
    for (final c in learn.courses()) {
      disc(c.id, disciplineOfArea(KnowledgeArea.education));
      for (final entry in c.title.values.entries) {
        terms.add(
          SearchTerm(
            entityId: c.id,
            category: SearchCategory.learning,
            term: entry.value,
            kind: TermKind.localized,
            lang: entry.key,
          ),
        );
      }
    }
    // Modda → u bilan tahlil qilinadigan metod (manbali «analysed_by»
    // bog‘lanishi): «alkogol» so‘rovi etanol orqali bug‘ fazali GX metodini
    // ham ko‘rsatadi.
    final methodNames = <String, Map<String, String>>{};
    for (final t in terms) {
      if (t.category != SearchCategory.method || t.lang == null) continue;
      methodNames
          .putIfAbsent(t.entityId, () => {})
          .putIfAbsent(t.lang!, () => t.term);
    }
    final linked = <String, List<LinkedSearchTarget>>{};
    for (final link in links) {
      if (link.relation != LinkRelation.analysedBy) continue;
      final names = methodNames[link.toId];
      if (names == null) continue;
      linked
          .putIfAbsent(link.fromId, () => [])
          .add(LinkedSearchTarget(link.toId, SearchCategory.method, names));
    }
    return AppSearchService(
      MultiTokenSearchIndex(terms),
      disciplines: disciplines,
      linked: linked,
    );
  }

  final SearchIndex _index;
  final Map<String, Set<ForensicDiscipline>> _disciplines;
  final Map<String, List<LinkedSearchTarget>> _linked;

  /// Har bir toifada ko‘rsatiladigan natijalar soni.
  static const limitPerCategory = 8;

  /// Fan filtri va bog‘langan natijalar uchun indeksdan olinadigan
  /// nomzodlar (toifa bo‘yicha).
  static const _candidateLimit = 200;

  /// Bog‘langan (metod ← modda) natija balli asosiy natijaga nisbatan.
  static const linkedWeight = 0.6;

  /// Yozuvning fanlari (noma’lum bo‘lsa — bo‘sh).
  Set<ForensicDiscipline> disciplinesOf(String entityId) =>
      _disciplines[entityId] ?? const {};

  static SearchGroup groupOf(SearchCategory c) => switch (c) {
    SearchCategory.substance ||
    SearchCategory.metabolite => SearchGroup.substances,
    SearchCategory.forensicMedicineTopic ||
    SearchCategory.biochemistryTopic ||
    SearchCategory.emergingIssue => SearchGroup.topics,
    // `topic` — namunalar (specimens) va umumiy laboratoriya mavzulari.
    SearchCategory.method ||
    SearchCategory.topic ||
    SearchCategory.specimen => SearchGroup.methods,
    SearchCategory.reagent || SearchCategory.solution => SearchGroup.reagents,
    SearchCategory.screeningTest => SearchGroup.screening,
    SearchCategory.calculator => SearchGroup.tools,
    SearchCategory.standard || SearchCategory.law => SearchGroup.standardsLaws,
    SearchCategory.learning ||
    SearchCategory.glossary ||
    SearchCategory.caseStudy ||
    SearchCategory.lesson => SearchGroup.learning,
    SearchCategory.reference => SearchGroup.references,
    SearchCategory.guideline => SearchGroup.guidelines,
  };

  /// [discipline] — natijalarni shu fan bilan cheklash. So‘rov natijalarida
  /// bu fan bo‘lmasa, filtr qo‘llanmaydi ([AppSearchResult.discipline]
  /// `null`).
  Future<AppSearchResult> search(
    String query, {
    String? lang,
    ForensicDiscipline? discipline,
  }) async {
    final sw = Stopwatch()..start();
    final r = await _index.search(
      SearchQuery(
        query,
        preferredLang: lang,
        limitPerCategory: _candidateLimit,
      ),
    );
    final hits = <String, SearchHit>{
      for (final h in r.all) '${h.category.name}:${h.entityId}': h,
    };
    final via = <String, String>{};
    for (final h in r.all) {
      if (h.category != SearchCategory.substance ||
          h.matchType != MatchType.exact) {
        continue;
      }
      for (final t in _linked[h.entityId] ?? const <LinkedSearchTarget>[]) {
        final key = '${t.category.name}:${t.entityId}';
        final score = h.score * linkedWeight;
        if ((hits[key]?.score ?? -1) >= score) continue;
        hits[key] = SearchHit(
          entityId: t.entityId,
          category: t.category,
          matchedTerm: t.nameIn(lang),
          matchType: MatchType.fuzzy,
          score: score,
        );
        via[t.entityId] = h.entityId;
      }
    }
    final available = {
      for (final h in hits.values) ...disciplinesOf(h.entityId),
    }.toList()..sort((a, b) => a.index.compareTo(b.index));
    final applied = available.contains(discipline) ? discipline : null;
    final shown = applied == null
        ? hits.values
        : hits.values.where((h) => disciplinesOf(h.entityId).contains(applied));
    final capped = const SearchRanker().group(shown, limitPerCategory);
    final groups = <SearchGroup, List<SearchHit>>{
      for (final g in SearchGroup.values) g: <SearchHit>[],
    };
    for (final e in capped.byCategory.entries) {
      groups[groupOf(e.key)]!.addAll(e.value);
    }
    for (final g in groups.values) {
      g.sort((a, b) => b.score.compareTo(a.score));
    }
    sw.stop();
    return AppSearchResult(
      groups,
      sw.elapsed,
      disciplines: available,
      discipline: applied,
      linkedVia: via,
    );
  }
}

/// Bog‘lanish orqali ko‘rsatiladigan yozuv (masalan, modda → metod).
class LinkedSearchTarget {
  const LinkedSearchTarget(this.entityId, this.category, this.names);

  final String entityId;
  final SearchCategory category;

  /// Til kodi → nom.
  final Map<String, String> names;

  String nameIn(String? lang) =>
      names[lang] ?? names['en'] ?? names.values.first;
}

final searchServiceProvider = Provider<AppSearchService>(
  (ref) => AppSearchService.build(
    library: ref.watch(libraryRepositoryProvider),
    learn: ref.watch(learnRepositoryProvider),
    knowledge: ref.watch(knowledgeRepositoryProvider),
    instruments: ref.watch(jurisdictionResolverProvider).instruments,
    research: ref.watch(evidenceDataProvider).research,
    provenance: ref.watch(provenanceIndexProvider),
    guidelines: ref.watch(guidelinesProvider).value ?? GuidelineBundle.empty,
    links: ref.watch(evidenceDataProvider).links,
  ),
);
