import 'package:fe_content_schema/fe_content_schema.dart'
    show InstrumentType, JurisdictionalInstrument, KnowledgeArea;
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
  const AppSearchResult(this.groups, this.latency);

  final Map<SearchGroup, List<SearchHit>> groups;

  /// O‘lchangan qidiruv vaqti (qurilmada, lokal indeks).
  final Duration latency;

  bool get isEmpty => groups.values.every((g) => g.isEmpty);

  int get total => groups.values.fold(0, (a, g) => a + g.length);
}

/// Ilova darajasidagi qidiruv: lokal indeks (offline) — tashqi qidiruv
/// bilan hech qachon aralashtirilmaydi.
class AppSearchService {
  AppSearchService(this._index);

  factory AppSearchService.build({
    required LibraryRepository library,
    required LearnRepository learn,
    KnowledgeRepository knowledge = const EmptyKnowledgeRepository(),
    Iterable<JurisdictionalInstrument> instruments = const [],
    Iterable<ResearchEntry> research = const [],
    ProvenanceIndex? provenance,
    GuidelineBundle guidelines = GuidelineBundle.empty,
  }) {
    final terms = <SearchTerm>[];
    // Yo‘riqnomalar: sarlavha (3 til) va kalit so‘zlar (sinonimlar).
    for (final g in guidelines.cards) {
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
    for (final st in provenance?.standards ?? const <StandardView>[]) {
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
      }
    }
    // Rasmiy hujjatlar (qonun / standart) — sarlavha bo‘yicha.
    for (final i in instruments) {
      final cat =
          i.type == InstrumentType.standard ||
              i.type == InstrumentType.officialGuideline
          ? SearchCategory.standard
          : SearchCategory.law;
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
    return AppSearchService(InMemorySearchIndex(terms));
  }

  final SearchIndex _index;

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

  Future<AppSearchResult> search(String query, {String? lang}) async {
    final sw = Stopwatch()..start();
    final r = await _index.search(
      SearchQuery(query, preferredLang: lang, limitPerCategory: 8),
    );
    final groups = <SearchGroup, List<SearchHit>>{
      for (final g in SearchGroup.values) g: <SearchHit>[],
    };
    for (final e in r.byCategory.entries) {
      groups[groupOf(e.key)]!.addAll(e.value);
    }
    for (final g in groups.values) {
      g.sort((a, b) => b.score.compareTo(a.score));
    }
    sw.stop();
    return AppSearchResult(groups, sw.elapsed);
  }
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
  ),
);
