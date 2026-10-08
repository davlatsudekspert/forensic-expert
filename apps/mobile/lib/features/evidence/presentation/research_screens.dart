import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../core/widgets/fe_data_components.dart';
import '../../../domain/evidence/evidence_models.dart';
import '../../../domain/knowledge/knowledge_models.dart';
import '../../../domain/library/library_models.dart';
import '../../../domain/professional/professional_models.dart';
import '../../../domain/professional/review_models.dart';
import '../../common/view_recorder.dart';
import '../../disciplines/discipline_strings.dart';
import '../../legal/presentation/jurisdiction_screens.dart';
import '../../professional/presentation/professional_widgets.dart';
import '../../professional/presentation/review_section.dart';
import '../evidence_strings.dart';

/// Ro‘yxatdagi research yozuvi.
class ResearchTile extends StatelessWidget {
  const ResearchTile({super.key, required this.entry});

  final ResearchEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final meta = [
      if (entry.authors.isNotEmpty)
        entry.authors.first + (entry.authors.length > 1 ? ' et al.' : ''),
      if (entry.container != null) entry.container!,
      if (entry.organization != null) entry.organization!,
      if (entry.year != null) entry.year!,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: Key('research.${entry.id}'),
        padding: const EdgeInsets.all(FeSpace.sm),
        onTap: () => context.push(Routes.researchEntry(entry.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: FeSpace.xs,
              runSpacing: FeSpace.xxs,
              children: [
                StatusChip(
                  icon: Icons.description_outlined,
                  label: l.researchKindName(entry.kind),
                  color: c.textSecondary,
                ),
                EvidenceLevelBadge(
                  level: entry.evidenceLevel,
                  label: l.researchEvidence(entry.evidenceLevel),
                ),
                if (!entry.peerReviewed)
                  StatusChip(
                    icon: Icons.info_outline,
                    label: l.researchNotPeerReviewed,
                    color: c.warning,
                  ),
              ],
            ),
            const SizedBox(height: FeSpace.xxs),
            Text(
              entry.title,
              locale: const Locale('en'),
              style: t.titleSmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (meta.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                meta,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Research / Evidence kutubxonasi — tur bo‘yicha filtr (va ixtiyoriy
/// yozuv bo‘yicha: `?entity=`).
class ResearchLibraryScreen extends ConsumerStatefulWidget {
  const ResearchLibraryScreen({super.key, this.entityId});

  final String? entityId;

  @override
  ConsumerState<ResearchLibraryScreen> createState() =>
      _ResearchLibraryScreenState();
}

enum _Period { all, recent, y2010, older }

class _ResearchLibraryScreenState extends ConsumerState<ResearchLibraryScreen> {
  ResearchKind? _kind;
  ForensicDiscipline? _discipline;
  bool _peerOnly = false;
  bool _openOnly = false;
  _Period _period = _Period.all;

  bool _inPeriod(ResearchEntry r) {
    final y = int.tryParse(r.year ?? '');
    return switch (_period) {
      _Period.all => true,
      _Period.recent => y != null && y >= 2020,
      _Period.y2010 => y != null && y >= 2010 && y <= 2019,
      _Period.older => y != null && y < 2010,
    };
  }

  /// Research fani — bog‘langan yozuvlar fanidan (aniq xarita, taxmin yo‘q).
  Set<ForensicDiscipline> _disciplinesOf(
    ResearchEntry r,
    KnowledgeRepository knowledge,
    LibraryRepository library,
  ) => {
    for (final id in r.linkedEntityIds)
      if (knowledge.byId(id) case final k?)
        k.forensicMedicineTopic != null
            ? disciplineOfFmTopic(k.forensicMedicineTopic!)
            : disciplineOfArea(k.area)
      else if (library.byId(id) != null)
        ForensicDiscipline.forensicToxicology,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ev = ref.watch(evidenceDataProvider);
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final library = ref.watch(libraryRepositoryProvider);
    final base = widget.entityId == null
        ? ev.research
        : ev.researchFor(widget.entityId!);
    final kinds = {for (final r in base) r.kind}.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final discOf = {
      for (final r in base) r.id: _disciplinesOf(r, knowledge, library),
    };
    final disciplines = {for (final d in discOf.values) ...d}.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final shown = [
      for (final r in base)
        if ((_kind == null || r.kind == _kind) &&
            (!_peerOnly || r.peerReviewed) &&
            (!_openOnly || r.isOpenAccess) &&
            _inPeriod(r) &&
            (_discipline == null || discOf[r.id]!.contains(_discipline)))
          r,
    ];
    final anyFilter =
        _kind != null ||
        _discipline != null ||
        _peerOnly ||
        _openOnly ||
        _period != _Period.all;
    String periodLabel(_Period p) => switch (p) {
      _Period.all => l.researchPeriodAll,
      _Period.recent => l.researchPeriodRecent,
      _Period.y2010 => l.researchPeriod2010,
      _Period.older => l.researchPeriodOlder,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l.researchTitle)),
      body: SafeArea(
        child: CustomScrollView(
          key: const Key('research.list'),
          slivers: [
            SliverToBoxAdapter(
              child: FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    FeBanner(
                      icon: Icons.menu_book_outlined,
                      text: l.researchNote,
                    ),
                    const SizedBox(height: FeSpace.sm),
                    SingleChildScrollView(
                      key: const Key('research.kinds'),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final k in <ResearchKind?>[null, ...kinds])
                            Padding(
                              padding: const EdgeInsets.only(right: FeSpace.xs),
                              child: ChoiceChip(
                                key: Key('research.kind.${k?.code ?? 'all'}'),
                                label: Text(
                                  k == null
                                      ? l.researchAll
                                      : l.researchKindName(k),
                                ),
                                selected: _kind == k,
                                onSelected: (_) => setState(() => _kind = k),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: FeSpace.xs),
                    Wrap(
                      key: const Key('research.filters'),
                      spacing: FeSpace.xs,
                      runSpacing: FeSpace.xxs,
                      children: [
                        FilterChip(
                          key: const Key('research.filter.peer'),
                          label: Text(l.researchFilterPeer),
                          selected: _peerOnly,
                          onSelected: (v) => setState(() => _peerOnly = v),
                        ),
                        FilterChip(
                          key: const Key('research.filter.open'),
                          label: Text(l.researchFilterOpen),
                          selected: _openOnly,
                          onSelected: (v) => setState(() => _openOnly = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: FeSpace.xs),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<_Period>(
                            key: const Key('research.filter.period'),
                            initialValue: _period,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l.researchPeriod,
                              isDense: true,
                            ),
                            items: [
                              for (final p in _Period.values)
                                DropdownMenuItem(
                                  value: p,
                                  child: Text(periodLabel(p)),
                                ),
                            ],
                            onChanged: (p) =>
                                setState(() => _period = p ?? _Period.all),
                          ),
                        ),
                        if (disciplines.isNotEmpty) ...[
                          const SizedBox(width: FeSpace.xs),
                          Expanded(
                            child: DropdownButtonFormField<ForensicDiscipline?>(
                              key: const Key('research.filter.discipline'),
                              initialValue: _discipline,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l.researchDiscipline,
                                isDense: true,
                              ),
                              items: [
                                DropdownMenuItem(
                                  child: Text(l.researchDisciplineAll),
                                ),
                                for (final d in disciplines)
                                  DropdownMenuItem(
                                    value: d,
                                    child: Text(
                                      l.disciplineName(d),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                              onChanged: (d) => setState(() => _discipline = d),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (anyFilter)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton(
                          key: const Key('research.filter.clear'),
                          onPressed: () => setState(() {
                            _kind = null;
                            _discipline = null;
                            _peerOnly = false;
                            _openOnly = false;
                            _period = _Period.all;
                          }),
                          child: Text(l.researchClear),
                        ),
                      ),
                    FeSectionHeader(l.researchCount(shown.length)),
                    if (shown.isEmpty)
                      FeEmptyState(
                        icon: Icons.inbox_outlined,
                        body: l.knowledgeEmpty,
                      ),
                  ],
                ),
              ),
            ),
            // Uzun ro‘yxat — lazy (yuzlab / minglab yozuvga tayyor).
            SliverList.builder(
              itemCount: shown.length,
              itemBuilder: (context, i) =>
                  FeContentFrame(child: ResearchTile(entry: shown[i])),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: FeSpace.xl)),
          ],
        ),
      ),
    );
  }
}

class ResearchDetailScreen extends ConsumerWidget {
  const ResearchDetailScreen({super.key, required this.researchId});

  final String researchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final r = ref.watch(evidenceDataProvider).researchById(researchId);
    if (r == null) {
      return Scaffold(
        appBar: AppBar(),
        body: FeEmptyState(icon: Icons.inbox_outlined, body: l.knowledgeEmpty),
      );
    }
    final library = ref.watch(libraryRepositoryProvider);
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final rows = <(String, String)>[
      if (r.authors.isNotEmpty) (l.metaAuthors, r.authors.join(', ')),
      if (r.container != null) (l.metaContainer, r.container!),
      if (r.organization != null) (l.metaInstitution, r.organization!),
      if (r.degree != null) (l.metaDegree, r.degree!),
      if (r.year != null) (l.metaYear, r.year!),
      if (r.doi != null) ('DOI', r.doi!),
      if (r.pmid != null) ('PMID', r.pmid!),
      if (r.pmcid != null) ('PMCID', r.pmcid!),
      if (r.handle != null) (l.metaHandle, r.handle!),
      (l.researchDocKind, l.documentKindLabel(documentKindOfResearch(r.kind))),
      (
        l.researchOpenAccess,
        switch (r.openAccess) {
          'pmc' => l.researchOpenPmc,
          'free_link' => l.researchOpenLink,
          _ => l.researchOpenUnknown,
        },
      ),
      (
        l.researchRelevance,
        switch (r.forensicRelevance) {
          ForensicRelevance.unassessed => l.relevanceUnassessed,
          ForensicRelevance.direct => l.relevanceDirect,
          ForensicRelevance.supporting => l.relevanceSupporting,
          ForensicRelevance.background => l.relevanceBackground,
        },
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.researchKindName(r.kind))),
      body: SafeArea(
        child: ListView(
          key: Key('researchDetail.${r.id}'),
          children: [
            ViewRecorder(id: r.id),
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  Wrap(
                    spacing: FeSpace.xs,
                    runSpacing: FeSpace.xxs,
                    children: [
                      ReviewStatusBadge(status: r.status),
                      EvidenceLevelBadge(
                        level: r.evidenceLevel,
                        label: l.researchEvidence(r.evidenceLevel),
                      ),
                      StatusChip(
                        icon: r.peerReviewed
                            ? Icons.verified_outlined
                            : Icons.info_outline,
                        label: r.peerReviewed
                            ? l.researchPeerReviewed
                            : l.researchNotPeerReviewed,
                        color: r.peerReviewed ? c.textSecondary : c.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: FeSpace.sm),
                  SelectableText(r.title, style: t.titleMedium),
                  const SizedBox(height: FeSpace.sm),
                  FeMetaList(rows: rows),
                  if (r.sourceApi != null) ...[
                    const SizedBox(height: FeSpace.xs),
                    Text(
                      l.researchSourceApi(r.sourceApi!),
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ],
                  if (r.primaryLink case final link?)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        key: const Key('research.copyLink'),
                        icon: const Icon(Icons.link),
                        label: Text(l.researchCopyLink),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: link));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l.researchLinkCopied)),
                            );
                          }
                        },
                      ),
                    ),
                  if (r.linkedEntityIds.isNotEmpty) ...[
                    FeSectionHeader(l.researchLinked),
                    Wrap(
                      spacing: FeSpace.xs,
                      runSpacing: FeSpace.xxs,
                      children: [
                        for (final id in r.linkedEntityIds)
                          ActionChip(
                            label: Text(
                              library.byId(id)?.name.resolve(lang) ??
                                  knowledge.byId(id)?.name.resolve(lang) ??
                                  id,
                            ),
                            onPressed: () => context.push(
                              library.byId(id) != null
                                  ? Routes.libraryEntry(id)
                                  : Routes.knowledgeEntry(id),
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: FeSpace.md),
                  FeNote(
                    key: const Key('research.limitations'),
                    icon: Icons.menu_book_outlined,
                    text: l.researchLimitationsNote,
                  ),
                  ProfessionalReviewSection(
                    recordId: r.id,
                    kind: ReviewSubjectKind.research,
                    scopes: _researchScopes(r, library, knowledge),
                    sourceCount: 1,
                    identifiersVerified: r.doi == null && r.pmid == null
                        ? null
                        // Metama’lumot identifikator bo‘yicha API’dan olingan.
                        : r.sourceApi != null,
                  ),
                  const SizedBox(height: FeSpace.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tadqiqot yozuvining taqriz sohalari — bog‘langan yozuvlardan. Bog‘lanish
/// bo‘lmasa soha tayinlanmagan (hech kim avtomatik taqriz qila olmaydi).
Set<ReviewerScope> _researchScopes(
  ResearchEntry r,
  LibraryRepository library,
  KnowledgeRepository knowledge,
) => {
  for (final id in r.linkedEntityIds)
    ...switch ((library.byId(id), knowledge.byId(id))) {
      (final _?, _) => ReviewScopes.forKind(ReviewSubjectKind.substance),
      (_, final k?) => ReviewScopes.forKind(
        reviewKindForKnowledge(k.kind, k.area),
      ),
      _ => const <ReviewerScope>{},
    },
};

/// Bilim grafigi: yozuvdan bog‘liq professional materiallar (asosi bilan).
class RelatedSection extends ConsumerWidget {
  const RelatedSection({super.key, required this.entityId});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final ev = ref.watch(evidenceDataProvider);
    final library = ref.watch(libraryRepositoryProvider);
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final out = ev.linksFrom(entityId);
    final into = ev.linksTo(entityId);
    String nameOf(String id) =>
        library.byId(id)?.name.resolve(lang) ??
        knowledge.byId(id)?.name.resolve(lang) ??
        id;
    String routeOf(String id) => library.byId(id) != null
        ? Routes.libraryEntry(id)
        : Routes.knowledgeEntry(id);

    final groups = <(LinkRelation, String, List<String>)>[
      (
        LinkRelation.analysedBy,
        l.relationAnalysedBy,
        [
          for (final x in out)
            if (x.relation == LinkRelation.analysedBy) x.toId,
        ],
      ),
      (
        LinkRelation.confirmedBy,
        l.relationConfirmedBy,
        [
          for (final x in out)
            if (x.relation == LinkRelation.confirmedBy) x.toId,
        ],
      ),
      (
        LinkRelation.metabolismCoMention,
        l.relationMetabolism,
        {
          for (final x in [...out, ...into])
            if (x.relation == LinkRelation.metabolismCoMention)
              x.fromId == entityId ? x.toId : x.fromId,
        }.toList(),
      ),
      (
        LinkRelation.relatedTopic,
        l.relationRelatedTopic,
        {
          for (final x in [...out, ...into])
            if (x.relation == LinkRelation.relatedTopic)
              x.fromId == entityId ? x.toId : x.fromId,
        }.toList(),
      ),
    ];
    // Metoddan teskari yo‘nalish: shu metod bilan tahlil qilingan moddalar.
    final analysedSubstances = [
      for (final x in into)
        if (x.relation == LinkRelation.analysedBy) x.fromId,
    ];
    final research = ev.researchFor(entityId);
    final any =
        groups.any((g) {
          final (_, _, ids) = g;
          return ids.isNotEmpty;
        }) ||
        analysedSubstances.isNotEmpty ||
        research.isNotEmpty;
    if (!any) return const SizedBox.shrink();

    Widget chips(List<String> ids) => Wrap(
      spacing: FeSpace.xs,
      runSpacing: FeSpace.xxs,
      children: [
        for (final id in ids)
          ActionChip(
            key: Key('related.$entityId.$id'),
            label: Text(nameOf(id)),
            onPressed: () => context.push(routeOf(id)),
          ),
      ],
    );

    return Column(
      key: Key('related.$entityId'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.detailRelated),
        for (final (rel, title, ids) in groups)
          if (ids.isNotEmpty) ...[
            Text(title, style: t.labelLarge),
            const SizedBox(height: FeSpace.xxs),
            chips(ids),
            if (rel == LinkRelation.metabolismCoMention)
              Text(
                l.relationBasis(l.relationBasisSourceExcerpt),
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            const SizedBox(height: FeSpace.sm),
          ],
        if (analysedSubstances.isNotEmpty) ...[
          Text(l.moduleSubstances, style: t.labelLarge),
          const SizedBox(height: FeSpace.xxs),
          chips(analysedSubstances.take(24).toList()),
          const SizedBox(height: FeSpace.sm),
        ],
        if (research.isNotEmpty) ...[
          Text(l.relationResearch, style: t.labelLarge),
          const SizedBox(height: FeSpace.xxs),
          for (final r in research.take(3)) ResearchTile(entry: r),
          if (research.length > 3)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                key: Key('related.$entityId.allResearch'),
                onPressed: () => context.push(Routes.researchFor(entityId)),
                child: Text(l.researchMore(research.length)),
              ),
            ),
        ],
      ],
    );
  }
}
