import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../app/user_data.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/learn/learn_models.dart';
import '../../../domain/ports/billing_ports.dart';
import '../../placeholder/presentation/in_development_view.dart';

/// Student / Resident dashboard. Professional rejim bilan bir xil dizayn
/// tizimi (bitta ilova), lekin ta’limga yo‘naltirilgan tuzilma: darajalar,
/// kurslar, progress va tarix, xatcho‘plar, mashq va imtihon rejimi.
class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  StudyLevel? _level;

  String _levelName(AppLocalizations l, StudyLevel v) => switch (v) {
    StudyLevel.foundation => l.learnLevelFoundation,
    StudyLevel.intermediate => l.learnLevelIntermediate,
    StudyLevel.advanced => l.learnLevelAdvanced,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final repo = ref.watch(learnRepositoryProvider);
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final data = ref.watch(userDataProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final all = repo.courses();
    final courses = [
      for (final course in all)
        if (_level == null || course.level == _level) course,
    ];
    final lessons = [for (final course in all) ...course.lessons];
    final done = lessons
        .where((x) => data.completedLessons.contains(x.id))
        .length;
    final lessonById = {for (final x in lessons) x.id: x};
    final unlockedAll = AccessPolicy.unlocks(
      ProductFeature.learn,
      ref.watch(accessProvider),
    );
    final bookmarks = [for (final id in data.favorites) ?knowledge.byId(id)];

    return Scaffold(
      appBar: AppBar(title: Text(l.moduleLearn)),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FeSectionHeader(
                    l.learnProgress,
                    padding: const EdgeInsets.only(bottom: FeSpace.xs),
                  ),
                  if (lessons.isEmpty)
                    FeEmptyState(
                      icon: Icons.insights_outlined,
                      body: l.learnProgressEmpty,
                      compact: true,
                    )
                  else
                    FeCard(
                      key: const Key('learn.progress'),
                      padding: const EdgeInsets.all(FeSpace.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l.learnProgressValue(done, lessons.length),
                            style: t.bodyMedium,
                          ),
                          const SizedBox(height: FeSpace.xs),
                          LinearProgressIndicator(
                            value: done / lessons.length,
                            semanticsLabel: l.learnProgressValue(
                              done,
                              lessons.length,
                            ),
                          ),
                          if (data.recentLessons.isNotEmpty) ...[
                            const SizedBox(height: FeSpace.sm),
                            Text(l.learnHistory, style: t.labelLarge),
                            Wrap(
                              spacing: FeSpace.xs,
                              children: [
                                for (final id in data.recentLessons)
                                  if (lessonById[id] case final lesson?)
                                    ActionChip(
                                      label: Text(lesson.title.resolve(lang)),
                                      onPressed: () => _openLesson(lesson),
                                    ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  FeSectionHeader(l.learnCourses),
                  Wrap(
                    spacing: FeSpace.xs,
                    runSpacing: FeSpace.xxs,
                    children: [
                      ChoiceChip(
                        key: const Key('learn.level.all'),
                        label: Text(l.learnLevelAll),
                        selected: _level == null,
                        onSelected: (_) => setState(() => _level = null),
                      ),
                      for (final v in StudyLevel.values)
                        ChoiceChip(
                          key: Key('learn.level.${v.name}'),
                          label: Text(_levelName(l, v)),
                          selected: _level == v,
                          onSelected: (_) => setState(() => _level = v),
                        ),
                    ],
                  ),
                  const SizedBox(height: FeSpace.xs),
                  if (courses.any((x) => !x.isTestData))
                    Padding(
                      padding: const EdgeInsets.only(bottom: FeSpace.xs),
                      child: FeBanner(
                        icon: Icons.menu_book_outlined,
                        text: l.learnCourseSourceNote,
                      ),
                    ),
                  if (courses.isEmpty)
                    FeEmptyState(
                      key: const Key('learn.noCourses'),
                      icon: Icons.school_outlined,
                      body: l.learnEmptyCourses,
                    )
                  else
                    for (final course in courses)
                      () {
                        final i = all.indexOf(course);
                        final free =
                            i < AccessPolicy.freeCourses || unlockedAll;
                        final courseDone = course.lessons
                            .where((x) => data.completedLessons.contains(x.id))
                            .length;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: FeSpace.xs),
                          child: FeCard(
                            key: Key('learn.course.${course.id}'),
                            // Bepul demo: birinchi kurs(lar); qolganlari Lifetime.
                            onTap: free
                                ? () => _showLessons(context, course, lang)
                                : () => context.push(Routes.purchase),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.title.resolve(lang),
                                  style: t.titleSmall,
                                ),
                                const SizedBox(height: FeSpace.xxs),
                                Wrap(
                                  spacing: FeSpace.xs,
                                  runSpacing: FeSpace.xxs,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      l.learnLessonCount(course.lessons.length),
                                      style: t.bodySmall?.copyWith(
                                        color: c.textSecondary,
                                      ),
                                    ),
                                    StatusChip(
                                      icon: Icons.signal_cellular_alt,
                                      label: _levelName(l, course.level),
                                      color: c.textSecondary,
                                    ),
                                    ReviewStatusBadge(
                                      status: course.status,
                                      compact: true,
                                    ),
                                    if (!free)
                                      StatusChip(
                                        key: Key('learn.locked.${course.id}'),
                                        icon: Icons.lock_outline,
                                        label: l.lockedBadge,
                                        color: c.textSecondary,
                                      ),
                                    if (courseDone == 0)
                                      StatusChip(
                                        icon: Icons.radio_button_unchecked,
                                        label: l.learnNotStarted,
                                        color: c.textSecondary,
                                      )
                                    else
                                      StatusChip(
                                        icon: Icons.check_circle_outline,
                                        label:
                                            '$courseDone/${course.lessons.length}',
                                        color: c.accent,
                                      ),
                                    if (course.isTestData)
                                      const TestDataBadge(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }(),
                  FeSectionHeader(l.learnBookmarks),
                  if (bookmarks.isEmpty)
                    FeEmptyState(
                      key: const Key('learn.bookmarks.empty'),
                      icon: Icons.star_border,
                      body: l.learnBookmarksEmpty,
                      compact: true,
                    )
                  else
                    Wrap(
                      spacing: FeSpace.xs,
                      children: [
                        for (final e in bookmarks)
                          ActionChip(
                            avatar: const Icon(Icons.star, size: 18),
                            label: Text(e.name.resolve(lang)),
                            onPressed: () =>
                                context.push(Routes.knowledgeEntry(e.id)),
                          ),
                      ],
                    ),
                  FeSectionHeader(
                    '${l.learnQuiz} · ${l.learnFlashcards} · ${l.learnExam}',
                  ),
                  _PracticeGrid(
                    items: [
                      (
                        const Key('learn.quiz'),
                        Icons.quiz_outlined,
                        l.learnQuiz,
                        () => context.go(Routes.quiz),
                      ),
                      (
                        const Key('learn.flashcards'),
                        Icons.style_outlined,
                        l.learnFlashcards,
                        () => context.go(Routes.flashcards),
                      ),
                      (
                        const Key('learn.exam'),
                        Icons.timer_outlined,
                        l.learnExam,
                        () => context.go(Routes.exam),
                      ),
                    ],
                  ),
                  FeSectionHeader(l.learnCases),
                  for (final cs in repo.cases())
                    FeCard(
                      key: Key('learn.case.${cs.id}'),
                      child: Row(
                        children: [
                          Icon(Icons.folder_open_outlined, color: c.accent),
                          const SizedBox(width: FeSpace.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cs.title.resolve(lang),
                                  style: t.bodyMedium,
                                ),
                                const SizedBox(height: FeSpace.xxs),
                                Wrap(
                                  spacing: FeSpace.xs,
                                  runSpacing: FeSpace.xxs,
                                  children: [
                                    StatusChip(
                                      key: Key('learn.simulated.${cs.id}'),
                                      icon: Icons.theater_comedy_outlined,
                                      label: l.learnSimulatedCase,
                                      color: c.warning,
                                    ),
                                    if (cs.isTestData) const TestDataBadge(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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

  void _openLesson(Lesson lesson) {
    ref.read(userDataProvider.notifier).recordLessonOpened(lesson.id);
    if (lesson.entryId != null) {
      context.push(Routes.knowledgeEntry(lesson.entryId!));
    }
  }

  void _showLessons(BuildContext context, Course course, String lang) {
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final completed = ref.watch(
            userDataProvider.select((d) => d.completedLessons),
          );
          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final lesson in course.lessons)
                  ListTile(
                    key: Key('learn.lesson.${lesson.id}'),
                    leading: const Icon(Icons.article_outlined),
                    title: Text(lesson.title.resolve(lang)),
                    onTap: lesson.entryId == null
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            _openLesson(lesson);
                          },
                    trailing: Checkbox(
                      key: Key('learn.complete.${lesson.id}'),
                      value: completed.contains(lesson.id),
                      semanticLabel: l.learnMarkComplete,
                      onChanged: (_) => ref
                          .read(userDataProvider.notifier)
                          .toggleLessonCompleted(lesson.id),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Imtihon rejimi: barcha javoblar tanlanadi, natija va izoh faqat
/// topshirgandan keyin. Savollar faqat repozitoriydan (to‘qilmaydi).
class ExamScreen extends ConsumerStatefulWidget {
  const ExamScreen({super.key});

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> {
  final _answers = <String, int>{};
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final questions = ref.watch(learnRepositoryProvider).quiz();
    final correct = questions
        .where((q) => _answers[q.id] == q.correctIndex)
        .length;

    return Scaffold(
      appBar: AppBar(title: Text(l.learnExam)),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  if (questions.isEmpty)
                    FeEmptyState(
                      key: const Key('exam.empty'),
                      icon: Icons.timer_off_outlined,
                      body: l.learnExamEmpty,
                    )
                  else ...[
                    FeBanner(icon: Icons.info_outline, text: l.learnExamIntro),
                    if (_submitted) ...[
                      const SizedBox(height: FeSpace.sm),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          l.learnExamScore(correct, questions.length),
                          key: const Key('exam.score'),
                          style: t.titleMedium,
                        ),
                      ),
                    ],
                    for (final (n, q) in questions.indexed) ...[
                      FeSectionHeader('${n + 1}. ${q.stem.resolve(lang)}'),
                      if (q.isTestData)
                        const Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TestDataBadge(),
                        ),
                      RadioGroup<int>(
                        groupValue: _answers[q.id],
                        onChanged: (v) {
                          if (_submitted || v == null) return;
                          setState(() => _answers[q.id] = v);
                        },
                        child: Column(
                          children: [
                            for (final (i, o) in q.options.indexed)
                              RadioListTile<int>(
                                key: Key('exam.${q.id}.$i'),
                                value: i,
                                enabled: !_submitted,
                                title: Text(o.resolve(lang)),
                                secondary: _submitted && i == q.correctIndex
                                    ? Icon(
                                        Icons.check_circle_outline,
                                        color: c.verified,
                                      )
                                    : null,
                              ),
                          ],
                        ),
                      ),
                      if (_submitted)
                        Text(
                          q.explanation.resolve(lang),
                          style: t.bodySmall?.copyWith(color: c.textSecondary),
                        ),
                    ],
                    const SizedBox(height: FeSpace.md),
                    if (!_submitted)
                      FilledButton(
                        key: const Key('exam.submit'),
                        onPressed: _answers.length == questions.length
                            ? () => setState(() => _submitted = true)
                            : null,
                        child: Text(l.learnExamSubmit),
                      )
                    else
                      OutlinedButton(
                        key: const Key('exam.retry'),
                        onPressed: () => setState(() {
                          _answers.clear();
                          _submitted = false;
                        }),
                        child: Text(l.learnExamRetry),
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

class _PracticeGrid extends StatelessWidget {
  const _PracticeGrid({required this.items});

  final List<(Key, IconData, String, VoidCallback)> items;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final columns = constraints.maxWidth >= 300 && scale < 1.6 ? 2 : 1;
        const gap = FeSpace.sm;
        final w = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (key, icon, label, onTap) in items)
              SizedBox(
                width: w,
                child: FeCard(
                  key: key,
                  onTap: onTap,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: c.accent),
                      const SizedBox(height: FeSpace.sm),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Test prototipi: javob tanlash → tekshirish → izoh + manba joyi.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int? _selected;
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final questions = ref.watch(learnRepositoryProvider).quiz();

    return Scaffold(
      appBar: AppBar(title: Text(l.learnQuiz)),
      body: SafeArea(
        child: questions.isEmpty
            ? const AvailabilityStateView(kind: AvailabilityKind.noReviewedData)
            : ListView(
                children: [
                  FeContentFrame(
                    child: _question(context, l, t, lang, questions.first),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _question(
    BuildContext context,
    AppLocalizations l,
    TextTheme t,
    String lang,
    QuizQuestion q,
  ) {
    final colors = FeTheme.of(context);
    final correct = _selected == q.correctIndex;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: FeSpace.sm),
        if (q.isTestData)
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: TestDataBadge(),
          ),
        const SizedBox(height: FeSpace.sm),
        Semantics(
          header: true,
          child: Text(q.stem.resolve(lang), style: t.titleMedium),
        ),
        const SizedBox(height: FeSpace.md),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: Semantics(
              inMutuallyExclusiveGroup: true,
              selected: _selected == i,
              button: true,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FeRadius.md),
                  side: BorderSide(
                    color: _selected == i ? colors.accent : colors.border,
                    width: _selected == i ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  key: Key('quiz.option.$i'),
                  onTap: _checked ? null : () => setState(() => _selected = i),
                  child: Padding(
                    padding: const EdgeInsets.all(FeSpace.md),
                    child: Row(
                      children: [
                        Icon(
                          _selected == i
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: _selected == i
                              ? colors.accent
                              : colors.borderStrong,
                        ),
                        const SizedBox(width: FeSpace.sm),
                        Expanded(child: Text(q.options[i].resolve(lang))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: FeSpace.sm),
        FilledButton(
          key: const Key('quiz.check'),
          onPressed: _selected == null || _checked
              ? null
              : () => setState(() => _checked = true),
          child: Text(l.quizCheck),
        ),
        if (_checked) ...[
          const SizedBox(height: FeSpace.md),
          Semantics(
            liveRegion: true,
            child: StatusChip(
              icon: correct ? Icons.check_circle_outline : Icons.highlight_off,
              label: correct ? l.quizCorrect : l.quizIncorrect,
              color: correct ? colors.verified : colors.danger,
            ),
          ),
          FeSectionHeader(l.quizExplanation),
          Text(q.explanation.resolve(lang), style: t.bodyMedium),
          FeSectionHeader(l.sourcesButton),
          FeEmptyState(
            icon: Icons.format_quote_outlined,
            body: l.sourcesNone,
            compact: true,
          ),
        ],
        const SizedBox(height: FeSpace.xl),
      ],
    );
  }
}

/// Kartochka prototipi: savol → javob → baholash.
class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final cards = ref.watch(learnRepositoryProvider).flashcards();
    return Scaffold(
      appBar: AppBar(title: Text(l.learnFlashcards)),
      body: SafeArea(
        child: cards.isEmpty
            ? const AvailabilityStateView(kind: AvailabilityKind.noReviewedData)
            : FeScrollableFlashcard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.md),
                    if (cards.first.isTestData)
                      const Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TestDataBadge(),
                      ),
                    const SizedBox(height: FeSpace.sm),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: c.surfaceRaised,
                        borderRadius: BorderRadius.circular(FeRadius.lg),
                        border: Border.all(color: c.borderStrong),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(FeSpace.xl),
                        child: Column(
                          children: [
                            Text(
                              cards.first.front.resolve(lang),
                              style: t.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            if (_revealed) ...[
                              const Divider(height: FeSpace.xl),
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  cards.first.back.resolve(lang),
                                  style: t.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: FeSpace.md),
                    if (!_revealed)
                      FilledButton(
                        key: const Key('flashcard.reveal'),
                        onPressed: () => setState(() => _revealed = true),
                        child: Text(l.flashcardShowAnswer),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  setState(() => _revealed = false),
                              child: Text(l.flashcardAgain),
                            ),
                          ),
                          const SizedBox(width: FeSpace.sm),
                          Expanded(
                            child: FilledButton(
                              onPressed: () =>
                                  setState(() => _revealed = false),
                              child: Text(l.flashcardKnew),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Kartochka uchun skroll qilinadigan ramka.
class FeScrollableFlashcard extends StatelessWidget {
  const FeScrollableFlashcard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ListView(children: [FeContentFrame(child: child)]);
}
