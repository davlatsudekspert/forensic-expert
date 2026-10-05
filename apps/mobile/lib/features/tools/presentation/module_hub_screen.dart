import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/catalog/tools_catalog.dart';
import '../../../domain/knowledge/knowledge_models.dart';
import '../../../domain/library/library_models.dart';
import '../../knowledge/knowledge_strings.dart';
import '../../placeholder/presentation/in_development_view.dart';
import '../../professional/presentation/professional_widgets.dart';
import 'tool_tile.dart';

/// Modul sahifasi (Toksikologiya, Laboratoriya): shu bo‘lim vositalari va
/// o‘rnatilgan paketdagi **manbali yozuvlar** (tekshiruv holati bilan).
///
/// «Tekshiruv kerak» — mavjud manbali ma’lumot; u yashirilmaydi. Bo‘sh
/// holat faqat haqiqatan yozuv bo‘lmaganda ko‘rsatiladi.
class ModuleHubScreen extends ConsumerWidget {
  const ModuleHubScreen({
    super.key,
    required this.title,
    required this.category,
  });

  final String title;
  final ToolCategory? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final tools = category == null
        ? const <ToolEntry>[]
        : ToolsCatalog.inCategory(category!);
    final library = ref.watch(libraryRepositoryProvider);
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final index = ref.watch(provenanceIndexProvider);
    final evidence = ref.watch(evidenceDataProvider);

    final links = <(String, IconData, String, int, String)>[
      if (category == ToolCategory.toxicology) ...[
        (
          'substances',
          Icons.hub_outlined,
          l.moduleSubstances,
          library.entries(LibrarySection.substances).length,
          Routes.librarySection(LibrarySection.substances.name),
        ),
        (
          'specimens',
          Icons.water_drop_outlined,
          l.specimensTitle,
          index.specimens.length,
          Routes.specimens,
        ),
        (
          'screening',
          Icons.fact_check_outlined,
          l.knowledgeKindTitle(KnowledgeKind.screeningTest),
          knowledge.byKind(KnowledgeKind.screeningTest).length,
          Routes.knowledge(KnowledgeKind.screeningTest.name),
        ),
        (
          'conflicts',
          Icons.compare_arrows,
          l.conflictsTitle,
          index.conflicts.length,
          Routes.conflicts,
        ),
      ],
      if (category == ToolCategory.laboratory) ...[
        (
          'methods',
          Icons.rule_folder_outlined,
          l.knowledgeKindTitle(KnowledgeKind.method),
          knowledge.byKind(KnowledgeKind.method).length,
          Routes.knowledge(KnowledgeKind.method.name),
        ),
        (
          'reagents',
          Icons.colorize_outlined,
          l.knowledgeKindTitle(KnowledgeKind.reagent),
          knowledge.byKind(KnowledgeKind.reagent).length,
          Routes.knowledge(KnowledgeKind.reagent.name),
        ),
        (
          'standards',
          Icons.gavel_outlined,
          l.libraryStandards,
          index.standards.length,
          Routes.libraryStandards,
        ),
      ],
      (
        'research',
        Icons.library_books_outlined,
        l.moduleResearch,
        evidence.research.length,
        Routes.research,
      ),
    ];
    final available = links.where((x) => x.$4 > 0).toList();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (tools.isNotEmpty) ...[
                    FeSectionHeader(
                      l.moduleHubTools,
                      padding: const EdgeInsets.only(bottom: FeSpace.xs),
                    ),
                    for (final t in tools)
                      Padding(
                        padding: const EdgeInsets.only(bottom: FeSpace.xs),
                        child: ToolTile(tool: t),
                      ),
                  ],
                  FeSectionHeader(l.moduleHubReference),
                  if (available.isEmpty)
                    const AvailabilityStateView(
                      kind: AvailabilityKind.noData,
                      icon: Icons.menu_book_outlined,
                      embedded: true,
                    )
                  else ...[
                    FeNote(
                      key: const Key('moduleHub.sourcedNote'),
                      icon: Icons.fact_check_outlined,
                      text: l.moduleHubSourcedNote,
                    ),
                    const SizedBox(height: FeSpace.xs),
                    for (final (id, icon, label, count, route) in available)
                      _HubLink(
                        key: Key('moduleHub.$id'),
                        icon: icon,
                        label: label,
                        count: count,
                        onTap: () => context.push(route),
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

class _HubLink extends StatelessWidget {
  const _HubLink({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: FeSpace.xs),
      child: ListTile(
        leading: Icon(icon, color: c.accent),
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: FeThemeBuilder.numeric(
                t.titleSmall!.copyWith(color: c.textSecondary),
              ),
            ),
            const SizedBox(width: FeSpace.xs),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
