import 'dart:async';

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

/// Global Search.
///
/// * Lokal (offline) natijalar guruhlangan: MODDALAR · USULLAR · VOSITALAR
///   · TA’LIM · MANBALAR.
/// * Tashqi ilmiy qidiruv (PubMed/PubChem/Crossref) — **alohida**, vizual
///   ajratilgan blok; hozir ulanmagan. Natijalar hech qachon aralashmaydi.
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
    final r = await ref.read(searchServiceProvider).search(q, lang: lang);
    if (!mounted || q != _query) return;
    setState(() => _result = r);
  }

  void _submit(String q) {
    _debounce?.cancel();
    ref.read(userDataProvider.notifier).recordSearch(q);
    _run(q);
  }

  void _open(SearchGroup group, SearchHit hit) {
    ref.read(userDataProvider.notifier).recordSearch(_query);
    switch (group) {
      case SearchGroup.tools:
        context.go(Routes.tool(hit.entityId));
      case SearchGroup.learning:
        context.go(Routes.learn);
      default:
        context.go(Routes.libraryEntry(hit.entityId));
    }
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
                    _Results(result: result, onOpen: _open),
                  const SizedBox(height: FeSpace.lg),
                  const _ExternalSearchBlock(),
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
  const _Results({required this.result, required this.onOpen});

  final AppSearchResult result;
  final void Function(SearchGroup, SearchHit) onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final library = ref.watch(libraryRepositoryProvider);
    String groupTitle(SearchGroup g) => switch (g) {
      SearchGroup.substances => l.librarySubstances,
      SearchGroup.methods => l.libraryMethods,
      SearchGroup.tools => l.searchGroupTools,
      SearchGroup.learning => l.searchGroupLearning,
      SearchGroup.references => l.libraryReferences,
    };
    IconData groupIcon(SearchGroup g) => switch (g) {
      SearchGroup.substances => Icons.hub_outlined,
      SearchGroup.methods => Icons.biotech_outlined,
      SearchGroup.tools => Icons.calculate_outlined,
      SearchGroup.learning => Icons.school_outlined,
      SearchGroup.references => Icons.menu_book_outlined,
    };

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
          for (final g in SearchGroup.values)
            if (result.groups[g]!.isNotEmpty) ...[
              FeSectionHeader(groupTitle(g)),
              for (final hit in result.groups[g]!)
                _ResultTile(
                  key: Key('search.hit.${hit.entityId}'),
                  icon: groupIcon(g),
                  title: hit.matchedTerm,
                  isTestData:
                      hit.entityId.startsWith('TEST-') ||
                      (library.byId(hit.entityId)?.isTestData ?? false),
                  isPlannedTool:
                      g == SearchGroup.tools &&
                      !(ToolsCatalog.byId(hit.entityId)?.isAvailable ?? true),
                  onTap: () => onOpen(g, hit),
                ),
            ],
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    super.key,
    required this.icon,
    required this.title,
    required this.isTestData,
    required this.isPlannedTool,
    required this.onTap,
  });

  final IconData icon;
  final String title;
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
      subtitle: isTestData || isPlannedTool
          ? Padding(
              padding: const EdgeInsets.only(top: FeSpace.xxs),
              child: Wrap(
                spacing: FeSpace.xs,
                children: [
                  if (isTestData) const TestDataBadge(),
                  if (isPlannedTool)
                    StatusChip(
                      icon: Icons.schedule_outlined,
                      label: l.toolStatusPlanned,
                      color: c.textSecondary,
                    ),
                ],
              ),
            )
          : null,
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

/// Tashqi ilmiy qidiruv — vizual ajratilgan (chiziqli chegara, «online»
/// belgisi) va hozircha ulanmagan.
class _ExternalSearchBlock extends StatelessWidget {
  const _ExternalSearchBlock();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      child: DecoratedBox(
        key: const Key('search.external'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FeRadius.md),
          border: Border.all(color: c.borderStrong),
        ),
        child: Padding(
          padding: const EdgeInsets.all(FeSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.public, color: c.textSecondary),
                  const SizedBox(width: FeSpace.xs),
                  Expanded(
                    child: Wrap(
                      spacing: FeSpace.xs,
                      runSpacing: FeSpace.xxs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            l.searchExternalTitle,
                            style: t.titleSmall,
                          ),
                        ),
                        StatusChip(
                          icon: Icons.schedule_outlined,
                          label: l.toolStatusPlanned,
                          color: c.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FeSpace.xs),
              Text(
                l.searchExternalBody,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
