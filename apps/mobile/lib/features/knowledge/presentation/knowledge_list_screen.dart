import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/catalog/tools_catalog.dart';
import '../../../domain/knowledge/knowledge_models.dart';
import '../../tools/presentation/tool_tile.dart';
import '../knowledge_strings.dart';
import 'knowledge_tile.dart';

/// Reagentlar, skrining testlari, metodlar yoki yangi muammolar ro‘yxati.
class KnowledgeListScreen extends ConsumerWidget {
  const KnowledgeListScreen({super.key, required this.kind});

  final KnowledgeKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final entries = ref.watch(knowledgeRepositoryProvider).byKind(kind);
    final lang = Localizations.localeOf(context).languageCode;

    List<Widget> body() {
      if (kind == KnowledgeKind.method) {
        // 4 tur alohida — hech qachon aralashtirilmaydi.
        return [
          FeBanner(
            key: const Key('methods.kindNote'),
            icon: Icons.rule_folder_outlined,
            text: l.methodKindNote,
          ),
          for (final mk in MethodKind.values) ...[
            FeSectionHeader(l.methodKindTitle(mk)),
            ...() {
              final group = [
                for (final e in entries)
                  if (e.method?.kind == mk) e,
              ];
              return group.isEmpty
                  ? [
                      FeEmptyState(
                        key: Key('methods.empty.${mk.name}'),
                        icon: Icons.inbox_outlined,
                        body: l.methodNoKindEntries,
                        compact: true,
                      ),
                    ]
                  : [
                      for (final e in group)
                        KnowledgeTile(
                          entry: e,
                          subtitle: e.method?.organization,
                        ),
                    ];
            }(),
          ],
        ];
      }
      return [
        if (kind == KnowledgeKind.screeningTest)
          FeBanner(
            key: const Key('screening.banner'),
            icon: Icons.report_gmailerrorred_outlined,
            text: l.screeningBanner,
            tone: FeBannerTone.critical,
          ),
        if (kind == KnowledgeKind.emergingIssue)
          FeBanner(icon: Icons.info_outline, text: l.emergingNote),
        const SizedBox(height: FeSpace.sm),
        if (entries.isEmpty)
          FeEmptyState(
            key: const Key('knowledge.empty'),
            icon: Icons.inbox_outlined,
            body: l.knowledgeEmpty,
          )
        else
          for (final e in entries)
            KnowledgeTile(
              entry: e,
              subtitle: switch (e.emerging) {
                final x? => l.emergingCategoryName(x.category),
                null => e.screening?.principle,
              },
            ),
      ];
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.knowledgeKindTitle(kind))),
      body: SafeArea(
        child: ListView(
          key: Key('knowledgeList.${kind.name}.$lang'),
          padding: const EdgeInsets.symmetric(vertical: FeSpace.sm),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...body(),
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

/// Sud tibbiyoti (25 mavzu taksonomiyasi) yoki biokimyo bo‘limi.
///
/// Manbali ma’lumoti yo‘q mavzu yashirilmaydi va to‘ldirilmaydi —
/// «hozircha manbali ma’lumot yo‘q» deb halol ko‘rsatiladi.
class AreaHubScreen extends ConsumerWidget {
  const AreaHubScreen({super.key, required this.area});

  final KnowledgeArea area;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final topics = ref.watch(knowledgeRepositoryProvider).topicsIn(area);
    final t = Theme.of(context).textTheme;

    final isFm = area == KnowledgeArea.forensicMedicine;
    final children = <Widget>[];
    if (isFm) {
      final covered = {for (final e in topics) e.forensicMedicineTopic};
      final total = ForensicMedicineTopic.values.length;
      children.addAll([
        Text(
          l.knowledgeTopicCount(
            ForensicMedicineTopic.values.where(covered.contains).length,
            total,
          ),
          key: const Key('fm.coverage'),
          style: t.bodySmall,
        ),
        FeSectionHeader(l.moduleHubTools),
        for (final tool in ToolsCatalog.inCategory(
          ToolCategory.forensicMedicine,
        ))
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: ToolTile(tool: tool),
          ),
        FeSectionHeader(l.knowledgeTaxonomy),
        for (final topic in ForensicMedicineTopic.values) ...[
          for (final e in topics)
            if (e.forensicMedicineTopic == topic) KnowledgeTile(entry: e),
          if (!covered.contains(topic))
            _EmptyTopicRow(
              key: Key('fm.topic.${topic.name}'),
              title: l.fmTopicName(topic),
              body: l.knowledgeNoSourcedContent,
            ),
        ],
      ]);
    } else {
      children.addAll([
        const SizedBox(height: FeSpace.sm),
        if (area == KnowledgeArea.histology) ...[
          FeBanner(
            key: const Key('histology.noDiagnosis'),
            icon: Icons.biotech_outlined,
            text: l.histologyNote,
          ),
          const SizedBox(height: FeSpace.sm),
        ],
        if (topics.isEmpty)
          FeEmptyState(icon: Icons.inbox_outlined, body: l.knowledgeEmpty)
        else
          for (final e in topics) KnowledgeTile(entry: e),
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(switch (area) {
          KnowledgeArea.forensicMedicine => l.moduleForensicMedicine,
          KnowledgeArea.histology => l.moduleHistology,
          _ => l.moduleBiochemistry,
        }),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: FeSpace.sm),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...children,
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

class _EmptyTopicRow extends StatelessWidget {
  const _EmptyTopicRow({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    return Semantics(
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FeSpace.sm,
          vertical: FeSpace.xs,
        ),
        child: Row(
          children: [
            Icon(Icons.radio_button_unchecked, size: 16, color: secondary),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.bodyMedium),
                  Text(body, style: t.bodySmall?.copyWith(color: secondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
