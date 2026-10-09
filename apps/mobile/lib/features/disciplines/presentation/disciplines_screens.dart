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
    // «Bo‘sh» — na manbali yozuv, na ilova moduli (fan sahifasi bilan bir xil).
    bool isEmpty(ForensicDiscipline d) =>
        modulesOf(d).isEmpty && recordCount(d, knowledge, library) == 0;
    final empty = [
      for (final d in ForensicDiscipline.values)
        if (isEmpty(d)) d,
    ];
    Widget tile(ForensicDiscipline d) {
      final count = recordCount(d, knowledge, library);
      return ListTile(
        key: Key('discipline.${d.code}'),
        contentPadding: EdgeInsets.zero,
        title: Text(l.disciplineName(d)),
        subtitle: Text(
          d.referenceOnly
              ? '${l.disciplineRecords(count)} · ${l.disciplineReferenceOnly}'
              : l.disciplineRecords(count),
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.discipline(d.code)),
      );
    }

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
                  for (final g in DisciplineGroup.values)
                    if (ForensicDiscipline.values.any(
                      (d) => d.group == g && !isEmpty(d),
                    )) ...[
                      FeSectionHeader(l.disciplineGroupName(g)),
                      for (final d in ForensicDiscipline.values)
                        if (d.group == g && !isEmpty(d)) tile(d),
                    ],
                  // Hali yozuvi yo‘q fanlar — oxirida, yig‘ilgan guruhda.
                  if (empty.isNotEmpty)
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        key: const Key('disciplines.comingSoon'),
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          l.disciplinesComingSoon(empty.length),
                          style: t.titleSmall,
                        ),
                        children: [for (final d in empty) tile(d)],
                      ),
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
    // Mavzu → uni yorituvchi birinchi yozuv.
    final covered = <ForensicMedicineTopic, String>{};
    for (final e in knowledge.byKind(KnowledgeKind.topic)) {
      if (e.forensicMedicineTopic case final topic?) {
        covered.putIfAbsent(topic, () => e.id);
      }
    }
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
                        onTap: () => context.push(m.route),
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
                    // Yoritilgan mavzu — yozuvga havola; yoritilmagani —
                    // oddiy (bosilmaydigan) matn.
                    for (final topic in fmTopics)
                      if (covered[topic] case final entryId?)
                        ListTile(
                          key: Key('discipline.fmTopic.${topic.name}'),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          leading: Icon(
                            Icons.check_circle_outline,
                            color: c.accent,
                            semanticLabel: l.disciplineRecords(1),
                          ),
                          title: Text(l.fmTopicName(topic)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () =>
                              context.push(Routes.knowledgeEntry(entryId)),
                        )
                      else
                        Padding(
                          key: Key('discipline.fmTopic.${topic.name}'),
                          padding: const EdgeInsets.symmetric(
                            vertical: FeSpace.xs,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.radio_button_unchecked,
                                size: 20,
                                color: c.textSecondary,
                                semanticLabel: l.disciplineRecords(0),
                              ),
                              const SizedBox(width: FeSpace.md),
                              Expanded(
                                child: Text(
                                  l.fmTopicName(topic),
                                  style: t.bodyMedium?.copyWith(
                                    color: c.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
