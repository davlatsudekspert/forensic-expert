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

class _ResearchLibraryScreenState extends ConsumerState<ResearchLibraryScreen> {
  ResearchKind? _kind;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ev = ref.watch(evidenceDataProvider);
    final base = widget.entityId == null
        ? ev.research
        : ev.researchFor(widget.entityId!);
    final kinds = {for (final r in base) r.kind}.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final shown = [
      for (final r in base)
        if (_kind == null || r.kind == _kind) r,
    ];
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
                    Wrap(
                      spacing: FeSpace.xs,
                      runSpacing: FeSpace.xxs,
                      children: [
                        ChoiceChip(
                          key: const Key('research.kind.all'),
                          label: Text(l.researchAll),
                          selected: _kind == null,
                          onSelected: (_) => setState(() => _kind = null),
                        ),
                        for (final k in kinds)
                          ChoiceChip(
                            key: Key('research.kind.${k.code}'),
                            label: Text(l.researchKindName(k)),
                            selected: _kind == k,
                            onSelected: (_) => setState(() => _kind = k),
                          ),
                      ],
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
      if (r.authors.isNotEmpty) ('Authors', r.authors.join(', ')),
      if (r.container != null) ('Journal / conference', r.container!),
      if (r.organization != null) ('Institution', r.organization!),
      if (r.degree != null) ('Degree', r.degree!),
      if (r.year != null) ('Year', r.year!),
      if (r.doi != null) ('DOI', r.doi!),
      if (r.pmid != null) ('PMID', r.pmid!),
      if (r.pmcid != null) ('PMCID', r.pmcid!),
      if (r.handle != null) ('Handle', r.handle!),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.researchKindName(r.kind))),
      body: SafeArea(
        child: ListView(
          key: Key('researchDetail.${r.id}'),
          children: [
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
                  FeDataTable(rows: rows),
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
        groups.any((g) => g.$3.isNotEmpty) ||
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
                l.relationBasis('source excerpt'),
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
