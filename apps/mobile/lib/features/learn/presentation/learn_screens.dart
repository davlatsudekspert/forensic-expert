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
import '../../../domain/learn/learn_models.dart';
import '../../../domain/ports/billing_ports.dart';
import '../../placeholder/presentation/in_development_view.dart';

/// Student / Resident dashboard. Professional rejim bilan bir xil dizayn
/// tizimi (bitta ilova), lekin ta’limga yo‘naltirilgan tuzilma.
class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final repo = ref.watch(learnRepositoryProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final courses = repo.courses();

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
                  FeEmptyState(
                    icon: Icons.insights_outlined,
                    body: l.learnProgressEmpty,
                    compact: true,
                  ),
                  FeSectionHeader(l.learnCourses),
                  if (courses.isEmpty)
                    FeEmptyState(
                      key: const Key('learn.noCourses'),
                      icon: Icons.school_outlined,
                      body: l.learnEmptyCourses,
                    )
                  else
                    for (final (i, course) in courses.indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: FeSpace.xs),
                        child: FeCard(
                          key: Key('learn.course.${course.id}'),
                          // Bepul demo: birinchi kurs(lar); qolganlari Lifetime.
                          onTap:
                              i < AccessPolicy.freeCourses ||
                                  ref.watch(accessProvider).hasFullAccess
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
                                  if (i >= AccessPolicy.freeCourses &&
                                      !ref.watch(accessProvider).hasFullAccess)
                                    StatusChip(
                                      key: Key('learn.locked.${course.id}'),
                                      icon: Icons.lock_outline,
                                      label: l.lockedBadge,
                                      color: c.textSecondary,
                                    ),
                                  StatusChip(
                                    icon: Icons.radio_button_unchecked,
                                    label: l.learnNotStarted,
                                    color: c.textSecondary,
                                  ),
                                  if (course.isTestData) const TestDataBadge(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  FeSectionHeader('${l.learnQuiz} · ${l.learnFlashcards}'),
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
                                if (cs.isTestData) ...[
                                  const SizedBox(height: FeSpace.xxs),
                                  const TestDataBadge(),
                                ],
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

  void _showLessons(BuildContext context, Course course, String lang) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final lesson in course.lessons)
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: Text(lesson.title.resolve(lang)),
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
            ? const InDevelopmentView()
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
            ? const InDevelopmentView()
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
