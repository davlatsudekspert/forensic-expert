import 'package:fe_content_schema/fe_content_schema.dart';
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
import '../../../domain/knowledge/knowledge_models.dart';
import '../../../domain/library/library_models.dart';
import '../../home/presentation/home_screen.dart' show HomeModule;
import '../../knowledge/knowledge_strings.dart';
import '../discipline_strings.dart';

/// Fan → mavjud ilova modullari (aniq xarita; bo‘sh bo‘lishi mumkin).
List<HomeModule> modulesOf(ForensicDiscipline d) => switch (d) {
  ForensicDiscipline.forensicMedicine ||
  ForensicDiscipline.forensicPathology ||
  ForensicDiscipline.forensicAnthropology ||
  ForensicDiscipline.forensicOdontology ||
  ForensicDiscipline.humanIdentification => const [HomeModule.forensicMedicine],
  ForensicDiscipline.forensicToxicology => const [
    HomeModule.toxicology,
    HomeModule.substances,
    HomeModule.screening,
    HomeModule.emerging,
  ],
  ForensicDiscipline.forensicChemistry => const [
    HomeModule.reagents,
    HomeModule.screening,
    HomeModule.methods,
  ],
  ForensicDiscipline.forensicBiochemistry => const [HomeModule.biochemistry],
  ForensicDiscipline.analyticalScience => const [
    HomeModule.methods,
    HomeModule.laboratory,
  ],
  ForensicDiscipline.forensicHistology => const [HomeModule.histology],
  ForensicDiscipline.laboratoryQuality => const [
    HomeModule.laboratory,
    HomeModule.methods,
  ],
  ForensicDiscipline.evidenceHandling => const [HomeModule.standardsLaws],
  ForensicDiscipline.educationResearch => const [
    HomeModule.learn,
    HomeModule.research,
  ],
  _ => const [],
};

/// Fanga tegishli manbali yozuvlar soni (sun’iy raqam emas — paketdan).
int recordCount(
  ForensicDiscipline d,
  KnowledgeRepository knowledge,
  LibraryRepository library,
) {
  var n = 0;
  for (final kind in KnowledgeKind.values) {
    for (final e in knowledge.byKind(kind)) {
      if (e.effectiveDiscipline == d) n++;
    }
  }
  if (d == ForensicDiscipline.forensicToxicology) {
    n += library.entries(LibrarySection.substances).length;
  }
  return n;
}

class DisciplinesScreen extends ConsumerWidget {
  const DisciplinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final library = ref.watch(libraryRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.disciplinesTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('disciplines.list'),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  FeBanner(
                    icon: Icons.account_tree_outlined,
                    text: l.disciplinesIntro,
                  ),
                  for (final g in DisciplineGroup.values) ...[
                    FeSectionHeader(l.disciplineGroupName(g)),
                    for (final d in ForensicDiscipline.values)
                      if (d.group == g)
                        Builder(
                          builder: (context) {
                            final count = recordCount(d, knowledge, library);
                            return ListTile(
                              key: Key('discipline.${d.code}'),
                              contentPadding: EdgeInsets.zero,
                              title: Text(l.disciplineName(d)),
                              subtitle: Text(
                                d.referenceOnly
                                    ? '${l.disciplineRecords(count)} · '
                                          '${l.disciplineReferenceOnly}'
                                    : l.disciplineRecords(count),
                                style: t.bodySmall?.copyWith(
                                  color: c.textSecondary,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () =>
                                  context.go(Routes.discipline(d.code)),
                            );
                          },
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

class DisciplineScreen extends ConsumerWidget {
  const DisciplineScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final d = ForensicDiscipline.fromCode(code);
    if (d == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final library = ref.watch(libraryRepositoryProvider);
    final count = recordCount(d, knowledge, library);
    final modules = modulesOf(d);
    final fmTopics = [
      for (final topic in ForensicMedicineTopic.values)
        if (disciplineOfFmTopic(topic) == d) topic,
    ];
    final covered = {
      for (final e in knowledge.byKind(KnowledgeKind.topic))
        if (e.forensicMedicineTopic != null) e.forensicMedicineTopic!,
    };
    // PHASE 8: fanga aniq biriktirilgan manbali mavzular.
    final lang = Localizations.localeOf(context).languageCode;
    final ownTopics = [
      for (final e in knowledge.byKind(KnowledgeKind.topic))
        if (e.discipline == d) e,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.disciplineName(d))),
      body: SafeArea(
        child: ListView(
          key: Key('disciplineDetail.${d.code}'),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  Text(
                    '${l.disciplineGroupName(d.group)} · '
                    '${l.disciplineRecords(count)}',
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                  if (d.referenceOnly) ...[
                    const SizedBox(height: FeSpace.sm),
                    FeBanner(
                      icon: Icons.menu_book_outlined,
                      text: l.disciplineReferenceOnly,
                      tone: FeBannerTone.warning,
                    ),
                  ],
                  if (modules.isNotEmpty) ...[
                    FeSectionHeader(l.disciplineModules),
                    for (final m in modules)
                      ListTile(
                        key: Key('discipline.module.${m.name}'),
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(m.icon, color: c.accent),
                        title: Text(m.label(l)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go(m.route),
                      ),
                  ],
                  if (ownTopics.isNotEmpty) ...[
                    FeSectionHeader(l.disciplineSourcedTopics),
                    for (final e in ownTopics)
                      ListTile(
                        key: Key('discipline.topic.${e.id}'),
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.article_outlined, color: c.accent),
                        title: Text(e.name.resolve(lang)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(Routes.knowledgeEntry(e.id)),
                      ),
                  ],
                  if (fmTopics.isNotEmpty) ...[
                    FeSectionHeader(l.disciplineTopics),
                    for (final topic in fmTopics)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: Icon(
                          covered.contains(topic)
                              ? Icons.check_circle_outline
                              : Icons.radio_button_unchecked,
                          color: covered.contains(topic)
                              ? c.accent
                              : c.textSecondary,
                          semanticLabel: covered.contains(topic)
                              ? l.disciplineRecords(1)
                              : l.disciplineRecords(0),
                        ),
                        title: Text(l.fmTopicName(topic)),
                      ),
                  ],
                  if (count == 0 && modules.isEmpty) ...[
                    const SizedBox(height: FeSpace.md),
                    FeEmptyState(
                      key: const Key('discipline.empty'),
                      icon: Icons.inventory_2_outlined,
                      body: l.disciplineEmpty,
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
