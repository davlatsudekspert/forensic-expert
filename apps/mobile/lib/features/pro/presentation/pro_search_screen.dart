import 'package:fe_content_schema/fe_content_schema.dart'
    show ForensicDiscipline, ScientificStatus;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/pro_tools.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/pro/pro_search.dart';
import '../../disciplines/discipline_strings.dart';
import '../../evidence/evidence_strings.dart';
import '../../evidence/presentation/provenance_widgets.dart';
import '../../library/presentation/content_entry_sections.dart' show ClaimMeta;
import '../pro_strings.dart';
import 'pro_widgets.dart';

enum _Tab { search, reverse }

enum _Reverse { reagent, specimen, method }

/// Kengaytirilgan qidiruv (Pro): faset filtrlar, aniq/ibora qidiruvi, turlar
/// bo‘yicha guruhlash va teskari qidiruvlar. Oddiy qidiruv o‘zgarmagan.
/// Bepul foydalanuvchi: tavsif, filtr ro‘yxati va tariflar taklifi.
class ProSearchScreen extends ConsumerStatefulWidget {
  const ProSearchScreen({super.key, this.initialText = ''});

  final String initialText;

  @override
  ConsumerState<ProSearchScreen> createState() => _ProSearchScreenState();
}

class _ProSearchScreenState extends ConsumerState<ProSearchScreen> {
  late final TextEditingController _controller;
  late ProFilter _filter;
  _Tab _tab = _Tab.search;
  _Reverse _reverse = _Reverse.specimen;
  String? _target;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _filter = ProFilter(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _set(ProFilter f) => setState(() => _filter = f);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final unlocked = ref.watch(proToolsUnlockedProvider);
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l.proSearchTitle)),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  Text(
                    l.proSearchIntro,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: FeSpace.sm),
                  if (!unlocked)
                    _LockedPreview(lang: lang)
                  else ...[
                    SegmentedButton<_Tab>(
                      key: const Key('pro.tabs'),
                      segments: [
                        ButtonSegment(
                          value: _Tab.search,
                          icon: const Icon(Icons.manage_search, size: 18),
                          label: Text(
                            l.proTabSearch,
                            key: const Key('pro.tab.search'),
                          ),
                        ),
                        ButtonSegment(
                          value: _Tab.reverse,
                          icon: const Icon(Icons.swap_horiz, size: 18),
                          label: Text(
                            l.proTabReverse,
                            key: const Key('pro.tab.reverse'),
                          ),
                        ),
                      ],
                      selected: {_tab},
                      onSelectionChanged: (s) => setState(() => _tab = s.first),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    if (_tab == _Tab.search)
                      _SearchTab(
                        controller: _controller,
                        filter: _filter,
                        onChanged: _set,
                        lang: lang,
                      )
                    else
                      _ReverseTab(
                        mode: _reverse,
                        target: _target,
                        lang: lang,
                        onMode: (m) => setState(() {
                          _reverse = m;
                          _target = null;
                        }),
                        onTarget: (id) => setState(() => _target = id),
                      ),
                  ],
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

/// Bepul ko‘rinish: nimalar kirishi (filtr nomlari) va tariflar taklifi.
class _LockedPreview extends StatelessWidget {
  const _LockedPreview({required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final titles = [
      l.proFacetDiscipline,
      l.proFacetClass,
      l.proFacetSpecimen,
      l.proFacetFamily,
      l.proFacetReagent,
      l.proFacetEvidence,
      l.proFacetStatus,
      l.proFacetJurisdiction,
      l.proFacetYear,
      l.proReverseReagent,
      l.proReverseSpecimen,
      l.proReverseMethod,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          key: const Key('pro.preview'),
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            for (final s in titles)
              Chip(
                avatar: const Icon(Icons.lock_outline, size: 14),
                label: Text(s),
              ),
          ],
        ),
        const SizedBox(height: FeSpace.md),
        ProLockedCard(
          title: l.proSearchLockedTitle(l.tierProfessionalPro),
          body: l.proSearchLockedBody,
          buttonKey: const Key('pro.unlock'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- QIDIRUV

class _SearchTab extends ConsumerWidget {
  const _SearchTab({
    required this.controller,
    required this.filter,
    required this.onChanged,
    required this.lang,
  });

  final TextEditingController controller;
  final ProFilter filter;
  final ValueChanged<ProFilter> onChanged;
  final String lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final index = ref.watch(proSearchIndexProvider);
    final nameOf = proNameResolver(ref, lang);
    final resolver = ref.watch(jurisdictionResolverProvider);
    final result = index.search(filter, lang: lang);

    String facetLabel(ProFacet f, String v) => switch (f) {
      ProFacet.discipline => l.disciplineName(ForensicDiscipline.fromCode(v)!),
      ProFacet.substanceClass => l.substanceGroupName(v),
      ProFacet.specimen || ProFacet.reagent => nameOf(v),
      ProFacet.family => l.familyName(MethodFamily.values.byName(v)),
      ProFacet.evidence => l.proEvidenceAtLeast(v),
      ProFacet.status => l.reviewStatusName(ScientificStatus.fromCode(v)),
      ProFacet.jurisdiction => resolver.byId(v)?.name(lang) ?? v,
      ProFacet.year => l.proYearSince(int.parse(v)),
    };
    String facetTitle(ProFacet f) => switch (f) {
      ProFacet.discipline => l.proFacetDiscipline,
      ProFacet.substanceClass => l.proFacetClass,
      ProFacet.specimen => l.proFacetSpecimen,
      ProFacet.family => l.proFacetFamily,
      ProFacet.reagent => l.proFacetReagent,
      ProFacet.evidence => l.proFacetEvidence,
      ProFacet.status => l.proFacetStatus,
      ProFacet.jurisdiction => l.proFacetJurisdiction,
      ProFacet.year => l.proFacetYear,
    };
    String? selected(ProFacet f) => switch (f) {
      ProFacet.discipline => filter.discipline?.code,
      ProFacet.substanceClass => filter.substanceClass,
      ProFacet.specimen => filter.specimenId,
      ProFacet.family => filter.family?.name,
      ProFacet.reagent => filter.reagentId,
      ProFacet.evidence => filter.evidenceAtLeast,
      ProFacet.status => filter.status?.code,
      ProFacet.jurisdiction => filter.jurisdictionId,
      ProFacet.year => filter.yearFrom?.toString(),
    };
    ProFilter apply(ProFacet f, String? v) => switch (f) {
      ProFacet.discipline => filter.copyWith(
        discipline: v == null ? null : ForensicDiscipline.fromCode(v),
      ),
      ProFacet.substanceClass => filter.copyWith(substanceClass: v),
      ProFacet.specimen => filter.copyWith(specimenId: v),
      ProFacet.family => filter.copyWith(
        family: v == null ? null : MethodFamily.values.byName(v),
      ),
      ProFacet.reagent => filter.copyWith(reagentId: v),
      ProFacet.evidence => filter.copyWith(evidenceAtLeast: v),
      ProFacet.status => filter.copyWith(
        status: v == null ? null : ScientificStatus.fromCode(v),
      ),
      ProFacet.jurisdiction => filter.copyWith(jurisdictionId: v),
      ProFacet.year => filter.copyWith(
        yearFrom: v == null ? null : int.parse(v),
      ),
    };

    Widget facetTile(ProFacet f) {
      final counts = index.facetCounts(f, filter);
      final sel = selected(f);
      var values = counts.keys.toList();
      if (sel != null && !values.contains(sel)) values.add(sel);
      values = switch (f) {
        ProFacet.evidence => values..sort(),
        ProFacet.year => values..sort((a, b) => b.compareTo(a)),
        _ =>
          values..sort(
            (a, b) => facetLabel(
              f,
              a,
            ).toLowerCase().compareTo(facetLabel(f, b).toLowerCase()),
          ),
      };
      // Paketda bu faset bo‘yicha qiymat yo‘q (masalan reagent bog‘lanishi) —
      // tanlanadigan narsa yo‘q, qator ko‘rsatilmaydi.
      if (values.isEmpty) return const SizedBox.shrink();
      return ExpansionTile(
        key: Key('pro.facet.${f.name}'),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: FeSpace.xs),
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(facetTitle(f), style: t.titleSmall),
        subtitle: Text(
          sel == null ? l.proFacetAny : facetLabel(f, sel),
          style: t.bodySmall?.copyWith(
            color: sel == null ? c.textSecondary : c.accent,
          ),
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        expandedAlignment: Alignment.centerLeft,
        children: [
          Wrap(
            spacing: FeSpace.xs,
            runSpacing: FeSpace.xs,
            children: [
              for (final v in values)
                ChoiceChip(
                  key: Key('pro.facet.${f.name}.$v'),
                  label: Text(
                    f == ProFacet.year || counts[v] == null
                        ? facetLabel(f, v)
                        : '${facetLabel(f, v)} (${counts[v]})',
                  ),
                  selected: sel == v,
                  onSelected: (on) => onChanged(apply(f, on ? v : null)),
                ),
            ],
          ),
        ],
      );
    }

    final active = filter.activeFacets.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('pro.field'),
          controller: controller,
          textInputAction: TextInputAction.search,
          onChanged: (v) => onChanged(filter.copyWith(text: v)),
          decoration: InputDecoration(
            hintText: l.proSearchHint,
            prefixIcon: const Icon(Icons.search),
            isDense: true,
            suffixIcon: filter.text.isEmpty
                ? null
                : IconButton(
                    tooltip: l.searchClearQuery,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.clear();
                      onChanged(filter.copyWith(text: ''));
                    },
                  ),
          ),
        ),
        SwitchListTile(
          key: const Key('pro.exact'),
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l.proSearchExact),
          value: filter.exact,
          onChanged: (v) => onChanged(filter.copyWith(exact: v)),
        ),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            for (final type in ProEntityType.values)
              FilterChip(
                key: Key('pro.type.${type.name}'),
                label: Text(l.entityTypeName(type)),
                selected: filter.types.contains(type),
                onSelected: (on) => onChanged(
                  filter.copyWith(
                    types: on
                        ? {...filter.types, type}
                        : ({...filter.types}..remove(type)),
                  ),
                ),
              ),
          ],
        ),
        FeSectionHeader(
          active == 0 ? l.proFilters : '${l.proFilters} ($active)',
          actionLabel: active == 0 ? null : l.proFiltersClear,
          onAction: active == 0 ? null : () => onChanged(filter.clearFacets()),
        ),
        for (final f in ProFacet.values) facetTile(f),
        const Divider(),
        if (filter.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: FeSpace.xs),
            child: Text(
              l.proResultsStart,
              key: const Key('pro.start'),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
        if (result.isEmpty)
          FeEmptyState(
            key: const Key('pro.noResults'),
            icon: Icons.search_off,
            title: l.proResultsNoneTitle,
            body: l.proResultsNoneBody,
          )
        else ...[
          Padding(
            padding: const EdgeInsets.only(top: FeSpace.xs),
            child: Semantics(
              liveRegion: true,
              child: Text(
                l.proResultCount(result.total),
                key: const Key('pro.count'),
                style: t.labelLarge,
              ),
            ),
          ),
          for (final type in ProEntityType.values)
            if (result.groups[type]!.isNotEmpty) ...[
              FeSectionHeader(l.entityTypeName(type)),
              for (final r in result.groups[type]!)
                _HitTile(record: r, lang: lang),
            ],
        ],
      ],
    );
  }
}

class _HitTile extends ConsumerWidget {
  const _HitTile({required this.record, required this.lang});

  final ProRecord record;
  final String lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final r = record;
    final meta = [
      if (r.substanceClass != null) l.substanceGroupName(r.substanceClass!),
      for (final f in r.families.take(2)) l.familyName(f),
      if (r.bestEvidence != null) l.detailEvidenceLevel(r.bestEvidence!),
      l.reviewStatusName(r.status),
    ].join(FeGlyphs.middleDot);
    return ListTile(
      key: Key('pro.hit.${r.id}'),
      contentPadding: EdgeInsets.zero,
      leading: Icon(switch (r.type) {
        ProEntityType.substance => Icons.hub_outlined,
        ProEntityType.method => Icons.biotech_outlined,
        ProEntityType.screening => Icons.fact_check_outlined,
        ProEntityType.reagent => Icons.science_outlined,
      }, color: c.accent),
      title: Text(r.name(lang)),
      subtitle: Text(
        meta,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: c.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(
        r.type == ProEntityType.substance
            ? Routes.homeSubstance(r.id)
            : Routes.knowledgeEntry(r.id),
      ),
    );
  }
}

// -------------------------------------------------------- TESKARI QIDIRUV

class _ReverseTab extends ConsumerWidget {
  const _ReverseTab({
    required this.mode,
    required this.target,
    required this.lang,
    required this.onMode,
    required this.onTarget,
  });

  final _Reverse mode;
  final String? target;
  final String lang;
  final ValueChanged<_Reverse> onMode;
  final ValueChanged<String?> onTarget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final index = ref.watch(proSearchIndexProvider);
    final nameOf = proNameResolver(ref, lang);
    final provenance = ref.watch(provenanceIndexProvider);

    final targets = switch (mode) {
      _Reverse.reagent => {
        for (final id in index.linkedReagentIds)
          if (index.substancesForReagent(id).isNotEmpty)
            id: index.substancesForReagent(id).length,
      },
      _Reverse.specimen => index.specimenCounts(),
      _Reverse.method => index.methodCounts(),
    };
    final hits = target == null
        ? const <ReverseHit>[]
        : switch (mode) {
            _Reverse.reagent => index.substancesForReagent(target!),
            _Reverse.specimen => index.analytesForSpecimen(target!),
            _Reverse.method => index.substancesForMethod(target!),
          };
    final ids = targets.keys.toList()
      ..sort((a, b) => nameOf(a).compareTo(nameOf(b)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            for (final (m, label) in [
              (_Reverse.specimen, l.proReverseSpecimen),
              (_Reverse.method, l.proReverseMethod),
              (_Reverse.reagent, l.proReverseReagent),
            ])
              ChoiceChip(
                key: Key('pro.reverse.mode.${m.name}'),
                label: Text(label),
                selected: mode == m,
                onSelected: (_) => onMode(m),
              ),
          ],
        ),
        const SizedBox(height: FeSpace.sm),
        Text(
          l.proReverseNote,
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: FeSpace.sm),
        if (targets.isEmpty)
          FeEmptyState(
            key: const Key('pro.reverse.none'),
            icon: Icons.link_off,
            body: mode == _Reverse.reagent
                ? l.proReverseNoReagents(index.reagentCount)
                : l.proReverseEmpty,
          )
        else ...[
          Text(l.proReversePick, style: t.labelLarge),
          const SizedBox(height: FeSpace.xs),
          Wrap(
            spacing: FeSpace.xs,
            runSpacing: FeSpace.xs,
            children: [
              for (final id in ids)
                ChoiceChip(
                  key: Key('pro.reverse.target.$id'),
                  // Nom tarjimadan keladi, qavs ichidagi son — ma'lumot.
                  label: Text(_chipLabel(nameOf(id), targets[id])),
                  selected: target == id,
                  onSelected: (on) => onTarget(on ? id : null),
                ),
            ],
          ),
        ],
        if (target != null) ...[
          FeSectionHeader(l.proReverseCount(hits.length)),
          if (hits.isEmpty)
            FeEmptyState(
              key: const Key('pro.reverse.empty'),
              icon: Icons.link_off,
              body: l.proReverseEmpty,
              compact: true,
            ),
          for (final h in hits)
            Builder(
              builder: (context) {
                final claim = h.basisIds
                    .map((b) => provenance.claimsById[b])
                    .nonNulls
                    .firstOrNull;
                return Padding(
                  padding: const EdgeInsets.only(bottom: FeSpace.xs),
                  child: FeCard(
                    key: Key('pro.reverse.hit.${h.substanceId}'),
                    padding: const EdgeInsets.fromLTRB(
                      FeSpace.sm,
                      FeSpace.xs,
                      FeSpace.xxs,
                      FeSpace.xs,
                    ),
                    onTap: () =>
                        context.push(Routes.homeSubstance(h.substanceId)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nameOf(h.substanceId),
                                style: t.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              for (final role in h.roles)
                                Text(
                                  l.reverseRole(role),
                                  style: t.bodySmall?.copyWith(
                                    color: c.textSecondary,
                                  ),
                                ),
                              if (h.viaIds.isNotEmpty)
                                Text(
                                  l.proViaLabel(
                                    h.viaIds
                                        .map(nameOf)
                                        .join(FeGlyphs.listSeparator),
                                  ),
                                  style: t.bodySmall?.copyWith(
                                    color: c.textSecondary,
                                  ),
                                ),
                              if (claim != null)
                                ClaimMeta(
                                  status: claim.status,
                                  level: claim.evidenceLevel,
                                ),
                            ],
                          ),
                        ),
                        if (claim != null)
                          IconButton(
                            key: Key('pro.reverse.source.${h.substanceId}'),
                            tooltip: l.analysisShowSource,
                            icon: const Icon(
                              Icons.format_quote_outlined,
                              size: 20,
                            ),
                            onPressed: () =>
                                showProvenanceSheet(context, claim),
                          ),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: c.textSecondary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ],
    );
  }
}

/// «Nom (soni)» — ikkala qism ham ma'lumot, alohida tarjima talab qilmaydi.
String _chipLabel(String name, Object? count) =>
    count == null ? name : '$name ($count)';
