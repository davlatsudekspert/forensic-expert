import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/knowledge/knowledge_models.dart';
import '../../../domain/library/library_models.dart';
import '../../../domain/referral/share_text.dart';
import '../../common/share_button.dart';
import 'content_entry_sections.dart';

/// Manbaga bog‘langan yozuv (kutubxona yoki bilim bazasi).
@immutable
class SourceLink {
  const SourceLink({
    required this.entityId,
    required this.name,
    required this.status,
    required this.knowledge,
  });

  final String entityId;
  final LocalizedText name;
  final ScientificStatus status;
  final bool knowledge;
}

@immutable
class SourceIndexEntry {
  const SourceIndexEntry(this.source, this.links);

  final SourceView source;
  final List<SourceLink> links;
}

/// Manba → bog‘langan yozuvlar indeksi (offline bazadan; hech narsa
/// o‘ylab topilmaydi — faqat mavjud havolalar).
final sourceIndexProvider = Provider<Map<String, SourceIndexEntry>>((ref) {
  final library = ref.watch(libraryRepositoryProvider);
  final knowledge = ref.watch(knowledgeRepositoryProvider);
  final sources = <String, SourceView>{};
  final links = <String, List<SourceLink>>{};
  void add(SourceView s, SourceLink link) {
    sources.putIfAbsent(s.sourceId, () => s);
    final list = links.putIfAbsent(s.sourceId, () => []);
    if (!list.any((x) => x.entityId == link.entityId)) list.add(link);
  }

  for (final section in LibrarySection.values) {
    for (final e in library.entries(section)) {
      final d = e.details;
      if (d == null) continue;
      for (final s in d.allSources) {
        add(
          s,
          SourceLink(
            entityId: e.id,
            name: e.name,
            status: e.status,
            knowledge: false,
          ),
        );
      }
    }
  }
  for (final kind in KnowledgeKind.values) {
    for (final e in knowledge.byKind(kind)) {
      for (final s in e.allSources) {
        add(
          s,
          SourceLink(
            entityId: e.id,
            name: e.name,
            status: e.status,
            knowledge: true,
          ),
        );
      }
    }
  }
  return {
    for (final id in sources.keys)
      id: SourceIndexEntry(sources[id]!, links[id] ?? const []),
  };
});

/// Manba sahifasi: to‘liq bibliografiya + shu manbaga tayangan yozuvlar
/// (ikki tomonlama navigatsiya: yozuv → manba → yozuv).
class SourceDetailScreen extends ConsumerWidget {
  const SourceDetailScreen({super.key, required this.sourceId});

  final String sourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final entry = ref.watch(sourceIndexProvider)[sourceId];
    return Scaffold(
      appBar: AppBar(
        title: Text(l.sourceDetailTitle),
        actions: [
          if (entry != null)
            ShareButton(
              text: (l) => sourceShareText(entry.source, footer: l.shareFooter),
            ),
        ],
      ),
      body: SafeArea(
        child: entry == null
            ? FeEmptyState(icon: Icons.link_off, body: l.sourceNotFound)
            : ListView(
                padding: const EdgeInsets.all(FeSpace.md),
                children: [
                  SourceTile(source: entry.source, linkToDetail: false),
                  FeSectionHeader(l.sourceLinkedRecords(entry.links.length)),
                  if (entry.links.isEmpty)
                    Text(
                      l.sourceNoLinkedRecords,
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  for (final link in entry.links)
                    Padding(
                      padding: const EdgeInsets.only(bottom: FeSpace.xs),
                      child: FeCard(
                        key: Key('sourceLink.${link.entityId}'),
                        padding: const EdgeInsets.all(FeSpace.sm),
                        onTap: () => context.push(
                          link.knowledge
                              ? Routes.knowledgeEntry(link.entityId)
                              : Routes.libraryEntry(link.entityId),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    link.name.resolve(lang),
                                    style: t.titleSmall,
                                  ),
                                  const SizedBox(height: FeSpace.xxs),
                                  ReviewStatusBadge(
                                    status: link.status,
                                    compact: true,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: c.textSecondary),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
