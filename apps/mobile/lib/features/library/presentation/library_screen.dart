import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:fe_search_core/fe_search_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/account.dart';
import '../../../app/guidelines.dart';
import '../../../app/providers.dart';
import '../../../app/publications.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/knowledge/knowledge_models.dart';
import '../../../domain/library/library_models.dart';
import '../../evidence/evidence_strings.dart';
import '../../evidence/presentation/provenance_screens.dart';
import '../../legal/presentation/jurisdiction_screens.dart';
import '../../placeholder/presentation/in_development_view.dart';
import 'content_entry_sections.dart';
import 'source_detail_screen.dart';

extension LibrarySectionL10n on LibrarySection {
  String label(AppLocalizations l) => switch (this) {
    LibrarySection.substances => l.librarySubstances,
    LibrarySection.methods => l.libraryMethods,
    LibrarySection.specimens => l.librarySpecimens,
    LibrarySection.references => l.libraryReferences,
    LibrarySection.glossary => l.libraryGlossary,
  };

  IconData get icon => switch (this) {
    LibrarySection.substances => Icons.hub_outlined,
    LibrarySection.methods => Icons.biotech_outlined,
    LibrarySection.specimens => Icons.water_drop_outlined,
    LibrarySection.references => Icons.menu_book_outlined,
    LibrarySection.glossary => Icons.translate,
  };
}

/// Bo‘lim ro‘yxati: filtr, tahririy guruhlar va bo‘lim ichida qidiruv.
/// (PHASE 6: Library hub’dan ochiladi — `/library/section/:section`.)
class LibrarySectionScreen extends ConsumerStatefulWidget {
  const LibrarySectionScreen({
    super.key,
    this.section = LibrarySection.substances,
  });

  final LibrarySection section;

  @override
  ConsumerState<LibrarySectionScreen> createState() =>
      _LibrarySectionScreenState();
}

class _LibrarySectionScreenState extends ConsumerState<LibrarySectionScreen> {
  late LibrarySection _section = widget.section;
  final _filterController = TextEditingController();
  String _filter = '';

  /// Tahririy modda guruhi filtri (null — barchasi).
  String? _group;
  static const _normalizer = SearchNormalizer();

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  /// «Filtrlarni tozalash»: guruh va matn filtri (maydon ham) bekor.
  void _clearFilters() => setState(() {
    _group = null;
    _filter = '';
    _filterController.clear();
  });

  bool _matches(LibraryEntry e) {
    if (_section == LibrarySection.substances &&
        _group != null &&
        e.group != _group) {
      return false;
    }
    final key = _normalizer.searchKey(_filter);
    if (key.isEmpty) return true;
    return [
      ...e.name.values.values,
      ...e.synonyms,
    ].any((n) => _normalizer.searchKey(n).contains(key));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final repo = ref.watch(libraryRepositoryProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final all = repo.entries(_section);
    final entries = all.where(_matches).toList();
    final groups = _section == LibrarySection.substances
        ? ({for (final e in all) ?e.group}.toList()..sort(
            (a, b) =>
                l.substanceGroupName(a).compareTo(l.substanceGroupName(b)),
          ))
        : const <String>[];

    // Faqat yozuvi bor bo‘limlar (bo‘sh sahifaga olib boruvchi chip yo‘q);
    // bittadan kam bo‘lsa — qator umuman ko‘rsatilmaydi.
    final sections = [
      for (final s in LibrarySection.values)
        if (s == _section || repo.entries(s).isNotEmpty) s,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_section.label(l))),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (sections.length > 1)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final s in sections)
                            Padding(
                              padding: const EdgeInsets.only(right: FeSpace.xs),
                              child: ChoiceChip(
                                key: Key('library.section.${s.name}'),
                                avatar: Icon(s.icon, size: 18),
                                label: Text(s.label(l)),
                                selected: _section == s,
                                onSelected: (_) => setState(() {
                                  _section = s;
                                  _group = null;
                                }),
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: FeSpace.sm),
                  TextField(
                    key: const Key('library.filter'),
                    controller: _filterController,
                    onChanged: (v) => setState(() => _filter = v),
                    decoration: InputDecoration(
                      hintText: l.libraryFilterHint,
                      prefixIcon: const Icon(Icons.filter_list),
                      isDense: true,
                    ),
                  ),
                  if (groups.isNotEmpty) ...[
                    const SizedBox(height: FeSpace.xs),
                    SingleChildScrollView(
                      key: const Key('library.groups'),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final g in [null, ...groups])
                            Padding(
                              padding: const EdgeInsets.only(right: FeSpace.xs),
                              child: ChoiceChip(
                                key: Key('library.group.${g ?? 'all'}'),
                                label: Text(
                                  g == null
                                      ? l.groupAll
                                      : l.substanceGroupName(g),
                                ),
                                selected: _group == g,
                                onSelected: (_) => setState(() => _group = g),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: FeSpace.xxs),
                    Text(
                      l.groupEditorialNote,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: c.textSecondary),
                    ),
                  ],
                  FeSectionHeader(
                    _group == null
                        ? _section.label(l)
                        : '${_section.label(l)} · ${l.substanceGroupName(_group!)}',
                  ),
                  if (all.isEmpty)
                    switch (ref.watch(contentLibraryProvider)) {
                      AsyncLoading() => FeEmptyState(
                        key: const Key('library.loading'),
                        icon: Icons.hourglass_top,
                        body: l.contentLoading,
                      ),
                      AsyncData(value: null)
                          when _section == LibrarySection.substances =>
                        FeEmptyState(
                          key: const Key('library.notInstalled'),
                          icon: Icons.storage_outlined,
                          body: l.libraryNotInstalled,
                        ),
                      _ => AvailabilityStateView(
                        kind: AvailabilityKind.noReviewedData,
                        embedded: true,
                        actions: [
                          (
                            label: l.availSearch,
                            icon: Icons.search,
                            onTap: () => context.push(Routes.search),
                          ),
                          (
                            label: l.availBrowseAll,
                            icon: Icons.local_library_outlined,
                            onTap: () => setState(() {
                              _section = LibrarySection.substances;
                              _group = null;
                              _filter = '';
                              _filterController.clear();
                            }),
                          ),
                        ],
                      ),
                    }
                  else if (entries.isEmpty)
                    AvailabilityStateView(
                      kind: AvailabilityKind.filterEmpty,
                      embedded: true,
                      actions: [
                        (
                          label: l.availClearFilters,
                          icon: Icons.filter_alt_off_outlined,
                          onTap: _clearFilters,
                        ),
                        (
                          label: l.availSearch,
                          icon: Icons.search,
                          onTap: () => context.push(Routes.search),
                        ),
                      ],
                    )
                  else
                    for (final e in entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: FeSpace.xs),
                        child: FeCard(
                          key: Key('library.entry.${e.id}'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: FeSpace.md,
                            vertical: FeSpace.sm,
                          ),
                          onTap: () => context.push(Routes.libraryEntry(e.id)),
                          child: Row(
                            children: [
                              Icon(_section.icon, color: c.accent),
                              const SizedBox(width: FeSpace.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1) nom (uzun nomlar o‘raladi),
                                    // 2) guruh, 3) ixcham holat va kirish.
                                    Text(
                                      e.name.resolve(lang),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                      softWrap: true,
                                    ),
                                    if (e.group case final g?) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        l.substanceGroupName(g),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: c.textSecondary),
                                      ),
                                    ],
                                    const SizedBox(height: FeSpace.xxs),
                                    Wrap(
                                      spacing: FeSpace.sm,
                                      runSpacing: FeSpace.xxs,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        ReviewStatusBadge(
                                          status: e.status,
                                          compact: true,
                                        ),
                                        if (e.isTestData) const TestDataBadge(),
                                        if (e.details != null)
                                          AccessBadge(
                                            access: e.access,
                                            compact: true,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ExcludeSemantics(
                                child: Icon(
                                  Icons.chevron_right,
                                  color: c.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: FeSpace.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Library — ilmiy yozuvlar uchun yagona hub (PHASE 6). Bitta tekis ro‘yxat
/// o‘rniga: ilmiy yozuvlar va hujjatlar/dalillar guruhlari. Sonlar —
/// paketdagi haqiqiy yozuvlar (sun’iy statistika emas).
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final library = ref.watch(libraryRepositoryProvider);
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final evidence = ref.watch(evidenceDataProvider);
    final resolver = ref.watch(jurisdictionResolverProvider);
    final provenance = ref.watch(provenanceIndexProvider);
    final isAdmin = ref.watch(serverAccessProvider).value?.isAdmin ?? false;
    final sourceCount = ref.watch(sourceIndexProvider).length;
    int lib(LibrarySection s) => library.entries(s).length;
    int kn(KnowledgeKind k) => knowledge.byKind(k).length;
    // Standartlar ekrani bilan bir xil: ilmiy bo‘lmagan metodlar + rasmiy
    // hujjatlar (qonun, regulation, standart).
    final standards =
        [
          for (final m in knowledge.byKind(KnowledgeKind.method))
            if (m.method != null &&
                m.method!.kind != MethodKind.scientificMethod)
              m,
        ].length +
        resolver.instruments.length +
        provenance.standards.length;

    final science = <(String, IconData, String, int)>[
      (
        'substances',
        Icons.hub_outlined,
        l.librarySubstances,
        lib(LibrarySection.substances),
      ),
      (
        'methods',
        Icons.biotech_outlined,
        l.moduleMethods,
        kn(KnowledgeKind.method),
      ),
      (
        'reagents',
        Icons.colorize_outlined,
        l.moduleReagents,
        kn(KnowledgeKind.reagent),
      ),
      (
        'rapid',
        Icons.fact_check_outlined,
        l.moduleScreening,
        kn(KnowledgeKind.screeningTest),
      ),
      (
        'specimens',
        Icons.water_drop_outlined,
        l.librarySpecimens,
        provenance.specimens.length,
      ),
      (
        'glossary',
        Icons.translate,
        l.libraryGlossary,
        lib(LibrarySection.glossary),
      ),
    ];
    final guidelineCount =
        ref.watch(guidelinesProvider).value?.cards.length ?? 0;
    final docs = <(String, IconData, String, int)>[
      (
        'guidelines',
        Icons.assignment_outlined,
        l.guidelinesTitle,
        guidelineCount,
      ),
      // «Ekspert maqolalari»: FE_PUBLICATIONS yoki admin uchun.
      if (ref.watch(publicationsVisibleProvider))
        (
          'publications',
          Icons.article_outlined,
          l.pubTitle,
          ref.watch(publishedPublicationsProvider).value?.length ?? 0,
        ),
      ('standards', Icons.rule_folder_outlined, l.libraryStandards, standards),
      (
        'research',
        Icons.library_books_outlined,
        l.moduleResearch,
        evidence.research.length,
      ),
      // Manbalar — yozuvlar keltirgan haqiqiy manbalar ro‘yxati.
      (
        'references',
        Icons.menu_book_outlined,
        l.libraryReferences,
        sourceCount,
      ),
      (
        'jurisdictions',
        Icons.account_balance_outlined,
        l.jurisdictionsTitle,
        resolver.instruments.length,
      ),
      (
        'conflicts',
        Icons.compare_arrows,
        l.libraryConflicts,
        provenance.conflicts.length,
      ),
      // Tekshiruv holati (QA paneli) — faqat admin uchun.
      if (isAdmin)
        (
          'review',
          Icons.fact_check_outlined,
          l.libraryReview,
          provenance.review.total,
        ),
    ];

    String route(String id) => switch (id) {
      'substances' => Routes.librarySection(LibrarySection.substances.name),
      'specimens' => Routes.specimens,
      'conflicts' => Routes.conflicts,
      'review' => Routes.reviewStatus,
      'glossary' => Routes.librarySection(LibrarySection.glossary.name),
      'references' => Routes.sources,
      'methods' => Routes.knowledge(KnowledgeKind.method.name),
      'reagents' => Routes.knowledge(KnowledgeKind.reagent.name),
      'rapid' => Routes.knowledge(KnowledgeKind.screeningTest.name),
      'standards' => Routes.libraryStandards,
      'guidelines' => Routes.guidelines,
      'publications' => Routes.publications,
      'research' => Routes.research,
      _ => Routes.jurisdictions,
    };

    Widget tile((String, IconData, String, int) x) {
      final (id, icon, title, count) = x;
      final c = FeTheme.of(context);
      return Padding(
        padding: const EdgeInsets.only(bottom: FeSpace.xs),
        child: FeCard(
          key: Key('library.hub.$id'),
          padding: const EdgeInsets.symmetric(
            horizontal: FeSpace.md,
            vertical: FeSpace.sm,
          ),
          onTap: () => context.push(route(id)),
          child: Row(
            children: [
              Icon(icon, color: c.accent),
              const SizedBox(width: FeSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      l.libraryCount(count),
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              ExcludeSemantics(
                child: Icon(Icons.chevron_right, color: c.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.libraryTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('library.hub'),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  Text(
                    l.libraryHubIntro,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: FeTheme.of(context).textSecondary),
                  ),
                  // Bo‘sh bo‘limlar ko‘rsatilmaydi (bo‘sh sahifa yo‘q).
                  FeSectionHeader(l.libraryGroupScience),
                  for (final x in science)
                    if (x.$4 > 0) tile(x),
                  FeSectionHeader(l.libraryGroupDocs),
                  for (final x in docs)
                    if (x.$4 > 0) tile(x),
                  const SizedBox(height: FeSpace.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standartlar va rasmiy hujjatlar — har biri turi (STANDARD / GUIDELINE /
/// METHOD / SOP / LAW / REGULATION) va majburiylik darajasi bilan.
class StandardsScreen extends ConsumerWidget {
  const StandardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final resolver = ref.watch(jurisdictionResolverProvider);
    final methods = [
      for (final m in knowledge.byKind(KnowledgeKind.method))
        if (m.method != null && m.method!.kind != MethodKind.scientificMethod)
          m,
    ];
    final instruments = resolver.instruments.toList();
    final catalogue = ref.watch(provenanceIndexProvider).standards;
    Widget kindLine(DocumentKind k) => Text(
      '${l.documentKindLabel(k)} · ${l.bindingLabel(k.binding)}',
      style: t.labelSmall?.copyWith(color: c.textSecondary),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l.libraryStandards)),
      body: SafeArea(
        child: ListView(
          key: const Key('library.standards'),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  FeBanner(icon: Icons.gavel_outlined, text: l.standardsIntro),
                  const SizedBox(height: FeSpace.sm),
                  if (catalogue.isNotEmpty) ...[
                    FeSectionHeader(l.stdCatalogue),
                    for (final st in catalogue)
                      StandardCatalogueTile(standard: st),
                  ],
                  if (methods.isEmpty && instruments.isEmpty)
                    FeEmptyState(
                      icon: Icons.inventory_2_outlined,
                      body: l.knowledgeEmpty,
                    ),
                  for (final m in methods)
                    ListTile(
                      key: Key('standards.${m.id}'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(m.name.resolve(lang)),
                      subtitle: kindLine(documentKindOfMethod(m.method!.kind)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(Routes.knowledgeEntry(m.id)),
                    ),
                  for (final i in instruments)
                    ListTile(
                      key: Key('standards.${i.id}'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(i.titles[lang] ?? i.titles['en'] ?? i.id),
                      subtitle: kindLine(documentKindOfInstrument(i.type)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          context.push(Routes.jurisdiction(i.jurisdictionId)),
                    ),
                  const SizedBox(height: FeSpace.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
