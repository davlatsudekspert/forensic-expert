import 'dart:async';

import 'package:fe_content_schema/fe_content_schema.dart'
    show ForensicDiscipline, ScientificStatus;
import 'package:fe_search_core/fe_search_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../app/search_service.dart';
import '../../../app/user_data.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/catalog/tools_catalog.dart';
import '../../../domain/ports/billing_ports.dart';
import '../../disciplines/discipline_strings.dart';
import '../../evidence/evidence_strings.dart';

/// Global Search.
///
/// * Lokal (offline) natijalar guruhlangan: MODDALAR · USULLAR · VOSITALAR
///   · TA’LIM · MANBALAR.
/// * Qidiruv tarixi faqat qurilmada; tozalash mumkin.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  Timer? _debounce;
  AppSearchResult? _result;
  String _query = '';

  /// Tanlangan fan filtri (`null` — barcha fanlar).
  ForensicDiscipline? _discipline;

  static const _debounceDuration = Duration(milliseconds: 150);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    if ((widget.initialQuery ?? '').isNotEmpty) {
      _query = widget.initialQuery!;
      Future.microtask(() => _run(_query));
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    setState(() => _query = q);
    _debounce = Timer(_debounceDuration, () => _run(q));
  }

  Future<void> _run(String q) async {
    if (q.trim().length < 2) {
      if (mounted) setState(() => _result = null);
      return;
    }
    final lang = Localizations.localeOf(context).languageCode;
    final r = await ref
        .read(searchServiceProvider)
        .search(q, lang: lang, discipline: _discipline);
    if (!mounted || q != _query) return;
    setState(() {
      _result = r;
      // Yangi so‘rovda bu fan natijasi bo‘lmasa, filtr o‘z-o‘zidan bekor.
      _discipline = r.discipline;
    });
  }

  void _selectDiscipline(ForensicDiscipline? d) {
    setState(() => _discipline = d);
    unawaited(_run(_query));
  }

  void _submit(String q) {
    _debounce?.cancel();
    ref.read(userDataProvider.notifier).recordSearch(q);
    _run(q);
  }

  /// Natija Home tabi ichida ochiladi (tab almashmaydi, «Back» shu
  /// natijalarga qaytaradi); aniq yozuvga — marshruti bo‘lsa.
  void _open(SearchGroup group, SearchHit hit) {
    ref.read(userDataProvider.notifier).recordSearch(_query);
    final id = hit.entityId;
    final library = ref.read(libraryRepositoryProvider);
    final knowledge = ref.read(knowledgeRepositoryProvider);
    String? instrumentJurisdiction() {
      for (final i in ref.read(jurisdictionResolverProvider).instruments) {
        if (i.id == id) return i.jurisdictionId;
      }
      return null;
    }

    final route = switch (group) {
      SearchGroup.guidelines => Routes.homeGuideline(id),
      SearchGroup.tools => Routes.homeTool(id),
      // Glossariy yozuvi — o‘z sahifasi; kurslar — Ta’lim bo‘limi.
      SearchGroup.learning when library.byId(id) != null =>
        Routes.homeSubstance(id),
      SearchGroup.learning when knowledge.byId(id) != null =>
        Routes.knowledgeEntry(id),
      SearchGroup.learning => Routes.learn,
      SearchGroup.standardsLaws
          when ref.read(provenanceIndexProvider).standard(id) != null =>
        Routes.homeStandards,
      SearchGroup.standardsLaws => switch (instrumentJurisdiction()) {
        final j? => Routes.jurisdiction(j),
        null => Routes.compare,
      },
      SearchGroup.methods when hit.category == SearchCategory.specimen =>
        Routes.homeSpecimen(id),
      SearchGroup.references
          when ref.read(evidenceDataProvider).researchById(id) != null =>
        Routes.researchEntry(id),
      _ when knowledge.byId(id) != null => Routes.knowledgeEntry(id),
      _ => Routes.homeSubstance(id),
    };
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final recent = ref.watch(userDataProvider.select((d) => d.recentSearches));
    final result = _result;
    final hasQuery = _query.trim().length >= 2;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: FeSpace.md),
          child: TextField(
            key: const Key('search.field'),
            controller: _controller,
            autofocus: widget.initialQuery == null,
            textInputAction: TextInputAction.search,
            onChanged: _onChanged,
            onSubmitted: _submit,
            decoration: InputDecoration(
              hintText: l.searchHint,
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l.searchClearQuery,
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _controller.clear();
                        _onChanged('');
                      },
                    ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!hasQuery) ...[
                    FeSectionHeader(
                      l.homeRecentSearches,
                      actionLabel: recent.isEmpty ? null : l.searchClearHistory,
                      onAction: recent.isEmpty
                          ? null
                          : () => ref
                                .read(userDataProvider.notifier)
                                .clearSearchHistory(),
                    ),
                    if (recent.isEmpty)
                      FeEmptyState(
                        icon: Icons.lock_outline,
                        body: l.homeEmptyRecentSearches,
                        compact: true,
                      )
                    else
                      Wrap(
                        key: const Key('search.recent'),
                        spacing: FeSpace.xs,
                        children: [
                          for (final q in recent)
                            ActionChip(
                              avatar: const Icon(Icons.history, size: 16),
                              label: Text(q),
                              onPressed: () {
                                _controller.text = q;
                                _onChanged(q);
                              },
                            ),
                        ],
                      ),
                    const SizedBox(height: FeSpace.sm),
                    Text(
                      l.searchTypeToStart,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: c.textSecondary),
                    ),
                  ] else if (result != null && result.isEmpty)
                    _NoResults(query: _query.trim())
                  else if (result != null)
                    _Results(
                      result: result,
                      onOpen: _open,
                      onDiscipline: _selectDiscipline,
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

class _Results extends ConsumerWidget {
  const _Results({
    required this.result,
    required this.onOpen,
    required this.onDiscipline,
  });

  final AppSearchResult result;
  final void Function(SearchGroup, SearchHit) onOpen;
  final ValueChanged<ForensicDiscipline?> onDiscipline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final library = ref.watch(libraryRepositoryProvider);
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final evidence = ref.watch(evidenceDataProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final unlocked = AccessPolicy.unlocks(
      ProductFeature.globalSearch,
      ref.watch(accessProvider),
    );
    const freeLimit = AccessPolicy.freeSearchResultsPerGroup;

    String groupTitle(SearchGroup g) => switch (g) {
      SearchGroup.substances => l.librarySubstances,
      SearchGroup.guidelines => l.guidelinesTitle,
      SearchGroup.topics => l.searchGroupTopics,
      SearchGroup.reagents => l.searchGroupReagents,
      SearchGroup.screening => l.searchGroupScreening,
      SearchGroup.standardsLaws => l.searchGroupStandardsLaws,
      SearchGroup.methods => l.libraryMethods,
      SearchGroup.tools => l.searchGroupTools,
      SearchGroup.learning => l.searchGroupLearning,
      SearchGroup.references => l.libraryReferences,
    };
    String statusLabel(ScientificStatus s) => switch (s) {
      ScientificStatus.verified => l.statusVerified,
      ScientificStatus.reviewed => l.statusReviewed,
      ScientificStatus.outdated => l.statusOutdated,
      _ => l.statusNeedsReview,
    };

    /// Natijaning tekshiruv holati (bo‘lsa).
    ScientificStatus? statusOf(SearchGroup g, SearchHit hit) {
      if (evidence.researchById(hit.entityId) case final r?) return r.status;
      if (library.byId(hit.entityId) case final e?) return e.status;
      if (knowledge.byId(hit.entityId) case final k?) return k.status;
      if (g == SearchGroup.tools || g == SearchGroup.guidelines) {
        return ScientificStatus.needsReview;
      }
      return null;
    }

    // Barcha ko‘rsatilgan natijalar holati bir xil bo‘lsa — har qatorda
    // takrorlanmaydi, ro‘yxat ustida bir marta aytiladi.
    final statuses = {
      for (final g in SearchGroup.values)
        for (final hit in result.groups[g]!.take(
          unlocked ? result.groups[g]!.length : freeLimit,
        ))
          statusOf(g, hit),
    };
    final sharedStatus = statuses.length == 1 ? statuses.single : null;
    String? rowStatus(ScientificStatus s) =>
        sharedStatus == null ? statusLabel(s) : null;

    /// Natija nima ekanini aniq ko‘rsatadi: kategoriya · (asosiy yozuv) ·
    /// manba turi / dalil darajasi · review holati.
    String metaOf(SearchGroup g, SearchHit hit) {
      final parts = <String>[];
      // Modda orqali bog‘langan metod (manbadagi «analysed_by»).
      if (result.linkedVia[hit.entityId] case final src?) {
        parts.add(
          l.searchLinkedVia(library.byId(src)?.name.resolve(lang) ?? src),
        );
      }
      if (evidence.researchById(hit.entityId) case final r?) {
        parts
          ..add(l.researchKindName(r.kind))
          ..add(l.researchEvidence(r.evidenceLevel));
        if (rowStatus(r.status) case final st?) parts.add(st);
      } else if (library.byId(hit.entityId) case final e?) {
        final name = e.name.resolve(lang);
        parts.add(
          hit.category == SearchCategory.metabolite
              ? l.searchMetaboliteOf(name)
              : (name.toLowerCase() != hit.matchedTerm.toLowerCase()
                    ? name
                    : groupTitle(g)),
        );
        if (rowStatus(e.status) case final st?) parts.add(st);
      } else if (knowledge.byId(hit.entityId) case final k?) {
        final name = k.name.resolve(lang);
        if (name.toLowerCase() != hit.matchedTerm.toLowerCase()) {
          parts.add(name);
        }
        parts.add(groupTitle(g));
        if (rowStatus(k.status) case final st?) parts.add(st);
      } else {
        parts.add(groupTitle(g));
        if (g == SearchGroup.tools || g == SearchGroup.guidelines) {
          if (rowStatus(ScientificStatus.needsReview) case final st?) {
            parts.add(st);
          }
        }
      }
      return parts.join(FeGlyphs.middleDot);
    }

    IconData groupIcon(SearchGroup g) => switch (g) {
      SearchGroup.substances => Icons.hub_outlined,
      SearchGroup.guidelines => Icons.assignment_outlined,
      SearchGroup.topics => Icons.personal_injury_outlined,
      SearchGroup.reagents => Icons.science_outlined,
      SearchGroup.screening => Icons.fact_check_outlined,
      SearchGroup.standardsLaws => Icons.gavel_outlined,
      SearchGroup.methods => Icons.biotech_outlined,
      SearchGroup.tools => Icons.calculate_outlined,
      SearchGroup.learning => Icons.school_outlined,
      SearchGroup.references => Icons.menu_book_outlined,
    };

    final seenHits = <String>{};
    Key hitKey(SearchGroup g, String id) => seenHits.add(id)
        ? Key('search.hit.$id')
        : Key('search.hit.${g.name}.$id.${seenHits.length}');
    return Semantics(
      label: l.searchResultsSemantics(result.total),
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: FeSpace.sm),
          Row(
            children: [
              Icon(Icons.offline_pin_outlined, size: 16, color: c.accent),
              const SizedBox(width: FeSpace.xxs),
              Text(
                l.searchOfflineLabel,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: c.textSecondary),
              ),
            ],
          ),
          if (sharedStatus case final st?)
            Padding(
              padding: const EdgeInsets.only(top: FeSpace.xxs),
              child: Text(
                l.searchAllStatus(statusLabel(st)),
                key: const Key('search.sharedStatus'),
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: c.textSecondary),
              ),
            ),
          if (result.disciplines.isNotEmpty)
            _DisciplineFilter(
              disciplines: result.disciplines,
              selected: result.discipline,
              onSelected: onDiscipline,
            ),
          for (final g in SearchGroup.values)
            if (result.groups[g]!.isNotEmpty) ...[
              FeSectionHeader(groupTitle(g)),
              for (final hit in result.groups[g]!.take(
                unlocked ? result.groups[g]!.length : freeLimit,
              ))
                _ResultTile(
                  // Bir yozuv bir nechta guruhda (yoki turli atama bilan)
                  // chiqishi mumkin — kalit takrorlanmasligi kerak.
                  key: hitKey(g, hit.entityId),
                  icon: groupIcon(g),
                  title: hit.matchedTerm,
                  meta: metaOf(g, hit),
                  isTestData:
                      hit.entityId.startsWith('TEST-') ||
                      (library.byId(hit.entityId)?.isTestData ?? false),
                  isPlannedTool:
                      g == SearchGroup.tools &&
                      !(ToolsCatalog.byId(hit.entityId)?.isAvailable ?? true),
                  onTap: () => onOpen(g, hit),
                ),
              // Bepul demo: har guruhda cheklangan natija; qolganlari
              // Lifetime bilan (yashirin emas — soni aniq ko‘rsatiladi).
              if (!unlocked && result.groups[g]!.length > freeLimit)
                ListTile(
                  key: Key('search.more.${g.name}'),
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.lock_outline, color: c.accent),
                  title: Text(
                    l.searchMoreLocked(result.groups[g]!.length - freeLimit),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.purchase),
                ),
            ],
        ],
      ),
    );
  }
}

/// Fan bo‘yicha filtr: faqat so‘rov natijasi bor fanlar.
class _DisciplineFilter extends StatelessWidget {
  const _DisciplineFilter({
    required this.disciplines,
    required this.selected,
    required this.onSelected,
  });

  final List<ForensicDiscipline> disciplines;
  final ForensicDiscipline? selected;
  final ValueChanged<ForensicDiscipline?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      label: l.searchDisciplineFilter,
      container: true,
      child: Padding(
        padding: const EdgeInsets.only(top: FeSpace.xs),
        child: SingleChildScrollView(
          key: const Key('search.disciplines'),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final d in <ForensicDiscipline?>[null, ...disciplines])
                Padding(
                  padding: const EdgeInsets.only(right: FeSpace.xs),
                  child: ChoiceChip(
                    key: Key('search.discipline.${d?.code ?? 'all'}'),
                    label: Text(
                      d == null ? l.searchDisciplineAll : l.disciplineName(d),
                    ),
                    selected: selected == d,
                    onSelected: (_) => onSelected(d),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    super.key,
    required this.icon,
    required this.title,
    required this.meta,
    required this.isTestData,
    required this.isPlannedTool,
    required this.onTap,
  });

  final IconData icon;
  final String title;

  /// Kategoriya / manba / review holati (foydalanuvchi nimani ochayotganini
  /// bilsin).
  final String meta;
  final bool isTestData;
  final bool isPlannedTool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: c.accent),
      title: Text(title),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: FeSpace.xxs),
        child: Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xxs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              meta,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: c.textSecondary),
            ),
            if (isTestData) const TestDataBadge(),
            if (isPlannedTool)
              StatusChip(
                icon: Icons.schedule_outlined,
                label: l.toolStatusPlanned,
                color: c.textSecondary,
              ),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      liveRegion: true,
      child: FeEmptyState(
        key: const Key('search.noResults'),
        icon: Icons.search_off,
        title: l.searchNoResultsTitle(query),
        body: l.searchNoResultsBody,
      ),
    );
  }
}
