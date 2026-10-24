import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/lessons.dart' show lessonListProvider;
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/settings/app_settings.dart' show UserMode;
import '../../../core/settings/settings_controller.dart'
    show settingsControllerProvider;
import '../../../core/widgets/fe_components.dart';
import '../../../domain/knowledge/knowledge_models.dart';
import '../../../domain/lessons/lesson_models.dart';
import '../../../domain/library/library_models.dart';
import '../../class_quiz/presentation/teacher_panel_screen.dart'
    show watchIsTeacher;
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
      appBar: AppBar(title: FeAppBarTitle(l.disciplinesTitle)),
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
      appBar: AppBar(title: FeAppBarTitle(l.disciplineName(d))),
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
                    for (final (i, m) in modules.indexed) ...[
                      if (i > 0) const SizedBox(height: FeSpace.sm),
                      _NextStepTile(
                        key: Key('discipline.module.${m.name}'),
                        icon: m.icon,
                        title: m.label(l),
                        onTap: () => context.push(m.route),
                      ),
                    ],
                  ],
                  ..._lessonsSection(context, ref, d),
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
                  // Keyingi qadam: fan nomi bilan qidiruv va AI — sahifa
                  // qisqa bo‘lsa ham «boshi berk» emas.
                  FeSectionHeader(l.disciplineNextTitle),
                  _NextStepTile(
                    key: const Key('discipline.search'),
                    icon: Icons.search,
                    title: l.disciplineSearchCta,
                    body: l.disciplineSearchBody,
                    onTap: () =>
                        context.push(Routes.searchWith(l.disciplineName(d))),
                  ),
                  const SizedBox(height: FeSpace.sm),
                  _NextStepTile(
                    key: const Key('discipline.ai'),
                    icon: Icons.auto_awesome_outlined,
                    title: l.moduleAi,
                    body: l.homeActAiBody,
                    onTap: () => context.go(Routes.ai),
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

/// Fan sahifasidagi «keyingi qadam» plitasi.
class _NextStepTile extends StatelessWidget {
  const _NextStepTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.body,
  });

  final IconData icon;
  final String title;
  final String? body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      onTap: onTap,
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: c.accentContainer,
              borderRadius: BorderRadius.circular(FeRadius.md),
            ),
            child: SizedBox.square(
              dimension: 44,
              child: Icon(icon, color: c.accent, size: 22),
            ),
          ),
          const SizedBox(width: FeSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleSmall),
                if (body case final b?) ...[
                  const SizedBox(height: 2),
                  Text(b, style: t.bodySmall?.copyWith(color: c.textSecondary)),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: c.textSecondary),
        ],
      ),
    );
  }
}

/// Fan → «Darslar» kurslari (egasi topshirig‘i, 2026-10-24): ustoz fanni
/// tanlaganda shu fan prezentatsiyalari va har dars ostida «Guruh testi».
/// Kurs nomlari — server seed’idagi (tools/lessons/build_lessons_seed.py)
/// o‘zbekcha nomlar; toksikologiya kurslari ro‘yxati, qolgani — sud tibbiyoti.
const _toxicologyCourses = {'Toksikologik kimyo', 'Apparatlar bilan ishlash'};

bool lessonCourseInDiscipline(String course, ForensicDiscipline d) {
  final tox = _toxicologyCourses.contains(course);
  return switch (d) {
    ForensicDiscipline.forensicToxicology ||
    ForensicDiscipline.forensicChemistry => tox,
    ForensicDiscipline.forensicMedicine => !tox,
    _ => false,
  };
}

/// Fan sahifasidagi «Darslar: prezentatsiya va guruh testi» bo‘limi.
/// Darslar serverda faqat ustoz roliga ochiq (`lesson_list`); «Ustoz» rejimi
/// bo‘lib rol bo‘lmasa — rolni olish tartibiga havola.
List<Widget> _lessonsSection(
  BuildContext context,
  WidgetRef ref,
  ForensicDiscipline d,
) {
  if (!lessonCourseInDiscipline('Toksikologik kimyo', d) &&
      !lessonCourseInDiscipline('Davolash ishi fakulteti', d)) {
    return const [];
  }
  final l = AppLocalizations.of(context);
  final c = FeTheme.of(context);
  final t = Theme.of(context).textTheme;
  final teacher = watchIsTeacher(ref);
  final mode = ref.watch(settingsControllerProvider.select((s) => s.userMode));
  // Server: ustoz — hamma dars; boshqa kirgan foydalanuvchi — faqat ochiq
  // kurslar (audience = 'all', masalan «Apparatlar bilan ishlash»).
  final res = ref.watch(lessonListProvider(''));
  final all = res.value?.value;
  if (all == null && res.isLoading) {
    return [
      FeSectionHeader(l.disciplineLessonsTitle),
      const LinearProgressIndicator(minHeight: 2),
    ];
  }
  final items = [
    for (final s in all ?? const <LessonSummary>[])
      if (lessonCourseInDiscipline(s.course, d)) s,
  ];
  if (items.isEmpty) {
    if (teacher || mode != UserMode.teacher) return const [];
    return [
      FeSectionHeader(l.disciplineLessonsTitle),
      _NextStepTile(
        key: const Key('discipline.lessonsTeacherOnly'),
        icon: Icons.co_present_outlined,
        title: l.disciplineLessonsTeacherOnly,
        onTap: () => context.push(Routes.teacher),
      ),
    ];
  }
  final groups = LessonGrouping.group(items);
  return [
    FeSectionHeader(l.disciplineLessonsTitle),
    Text(
      l.disciplineLessonsBody(items.length),
      key: const Key('discipline.lessonsBody'),
      style: t.bodySmall?.copyWith(color: c.textSecondary),
    ),
    for (final g in groups)
      _CourseLessons(
        key: Key('discipline.course.${g.course}'),
        group: g,
        teacher: teacher,
      ),
    const SizedBox(height: FeSpace.xs),
    Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        key: const Key('discipline.lessonsAll'),
        onPressed: () => context.push(Routes.lessons),
        icon: const Icon(Icons.arrow_forward_rounded),
        label: Text(l.disciplineLessonsAll),
      ),
    ),
  ];
}

/// Bitta kurs darslari: avval 5 ta, «Yana N ta dars» bilan to‘liq ro‘yxat —
/// fan sahifasi 80+ qatorli bo‘lib ketmasin.
class _CourseLessons extends StatefulWidget {
  const _CourseLessons({super.key, required this.group, required this.teacher});

  final LessonGroup group;
  final bool teacher;

  static const preview = 5;

  @override
  State<_CourseLessons> createState() => _CourseLessonsState();
}

class _CourseLessonsState extends State<_CourseLessons> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final all = widget.group.items;
    final shown = _expanded ? all : all.take(_CourseLessons.preview).toList();
    final rest = all.length - shown.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: FeSpace.md, bottom: FeSpace.xs),
          child: Semantics(
            header: true,
            child: Text(
              '${widget.group.course} · ${all.length}',
              style: t.titleSmall?.copyWith(color: c.accent),
            ),
          ),
        ),
        for (final s in shown)
          ListTile(
            key: Key('discipline.lesson.${s.topicId}'),
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(Icons.slideshow_rounded, color: c.accent),
            title: Text(s.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(l.lessonsSlideCount(s.slides)),
            trailing: widget.teacher
                ? IconButton(
                    key: Key('discipline.lessonTest.${s.topicId}'),
                    tooltip: l.disciplineLessonGroupTest,
                    icon: const Icon(Icons.quiz_outlined),
                    onPressed: () =>
                        context.push(Routes.groupLessonTest(s.topicId)),
                  )
                : const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.lesson(s.topicId)),
          ),
        if (rest > 0)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: Key('discipline.lessonsMore.${widget.group.course}'),
              onPressed: () => setState(() => _expanded = true),
              icon: const Icon(Icons.expand_more_rounded),
              label: Text(l.disciplineLessonsMore(rest)),
            ),
          ),
      ],
    );
  }
}
