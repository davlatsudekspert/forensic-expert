import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/assessment.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/assessment/assessment_models.dart';

String assessmentSpecTitle(AppLocalizations l, String id) => switch (id) {
  'sud_tib' => l.assessmentSpecSudTib,
  'pat_anat' => l.assessmentSpecPatAnat,
  'sud_kimyo' => l.assessmentSpecSudKimyo,
  _ => id,
};

String assessmentCatTitle(AppLocalizations l, String id) => switch (id) {
  'c23' => l.assessmentCatC23,
  'c1' => l.assessmentCatC1,
  'c0' => l.assessmentCatC0,
  _ => id,
};

String _keySourceText(AppLocalizations l, AssessmentKeySource s) {
  if (s.kind == 'teacher') return l.assessmentKeyTeacher;
  if (s.kind == 'web') {
    return [s.title, s.url].where((x) => x.isNotEmpty).join(' — ');
  }
  return s.page > 0 ? l.assessmentBookPage(s.title, s.page) : s.title;
}

/// Boshqa ekranlarda ham ishlatiladigan umumiy ramka.
class _Frame extends StatelessWidget {
  const _Frame({
    required this.title,
    required this.children,
    this.listKey,
    this.actions,
  });

  final String title;
  final List<Widget>? actions;
  final List<Widget> children;
  final Key? listKey;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: FeAppBarTitle(title), actions: actions),
    body: SafeArea(
      child: ListView(
        key: listKey,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          FeContentFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: FeSpace.sm),
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

class _SourceNote extends StatelessWidget {
  const _SourceNote();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.assessmentSourceLine(l.assessmentSourceName),
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          l.assessmentUzOnly,
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
      ],
    );
  }
}

/// Bo‘lim bosh sahifasi: uchta mutaxassislik.
class AssessmentHubScreen extends ConsumerWidget {
  const AssessmentHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final bundle = ref.watch(assessmentProvider);
    final ready = ref.watch(assessmentProgressProvider);
    return _Frame(
      title: l.assessmentTitle,
      listKey: const Key('assessment.hub'),
      children: bundle.when(
        loading: () => [FeListSkeleton(semanticLabel: l.assessmentTitle)],
        error: (_, _) => [
          FeEmptyState(icon: Icons.quiz_outlined, body: l.assessmentEmpty),
        ],
        data: (b) {
          if (b.specialties.isEmpty) {
            return [
              FeEmptyState(icon: Icons.quiz_outlined, body: l.assessmentEmpty),
            ];
          }
          return [
            Text(
              l.assessmentIntro,
              style: t.bodyMedium?.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: FeSpace.md),
            for (final s in b.specialties) ...[
              _SpecialtyCard(spec: s, ready: ready),
              const SizedBox(height: FeSpace.sm),
            ],
            FeCard(
              key: const Key('assessment.sourcesEntry'),
              onTap: () => context.push(Routes.assessmentSources),
              child: Row(
                children: [
                  Icon(Icons.menu_book_outlined, color: c.accent),
                  const SizedBox(width: FeSpace.sm),
                  Expanded(
                    child: Text(l.assessmentSourcesTitle, style: t.titleSmall),
                  ),
                  Icon(Icons.chevron_right, color: c.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: FeSpace.sm),
            const _SourceNote(),
          ];
        },
      ),
    );
  }
}

class _SpecialtyCard extends StatelessWidget {
  const _SpecialtyCard({required this.spec, required this.ready});

  final AssessmentSpecialty spec;
  final Set<String> ready;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final done = [
      for (final cat in spec.categories)
        for (final q in cat.questions)
          if (ready.contains(q.id)) q,
    ].length;
    final total = spec.total;
    return FeCard(
      key: Key('assessment.spec.${spec.id}'),
      onTap: () => context.push(Routes.assessmentSpecialty(spec.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  assessmentSpecTitle(l, spec.id),
                  style: t.titleMedium,
                ),
              ),
              Icon(Icons.chevron_right, color: c.textSecondary),
            ],
          ),
          const SizedBox(height: FeSpace.xs),
          Text(
            '${l.assessmentCountQuestions(total)} · '
            '${l.assessmentCountTests(spec.tests.length)}',
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: FeSpace.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(FeRadius.pill),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 6,
              color: c.accent,
              backgroundColor: c.accentContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.assessmentReadyProgress(done, total),
            style: t.labelSmall?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

String _fold(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[‘’ʻʼ`´\']'), '')
    .replaceAll(RegExp(r'\s+'), ' ');

/// Mutaxassislik: toifa bo‘yicha og‘zaki savollar va testlar.
class AssessmentSpecialtyScreen extends ConsumerStatefulWidget {
  const AssessmentSpecialtyScreen({super.key, required this.specialtyId});

  final String specialtyId;

  @override
  ConsumerState<AssessmentSpecialtyScreen> createState() =>
      _AssessmentSpecialtyScreenState();
}

class _AssessmentSpecialtyScreenState
    extends ConsumerState<AssessmentSpecialtyScreen> {
  bool _tests = false;
  String? _cat;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final bundle = ref.watch(assessmentProvider).value;
    final spec = bundle?.specialty(widget.specialtyId);
    final title = assessmentSpecTitle(l, widget.specialtyId);
    if (spec == null) {
      return _Frame(
        title: title,
        children: [
          FeEmptyState(icon: Icons.quiz_outlined, body: l.assessmentEmpty),
        ],
      );
    }
    final ready = ref.watch(assessmentProgressProvider);
    final answered = ref.watch(oralAnswersProvider(spec.id)).value;
    final q = _fold(_query.trim());
    final cat =
        spec.category(_cat ?? spec.categories.first.id) ??
        spec.categories.first;
    final oral = [
      for (final x in cat.questions)
        if (q.isEmpty || _fold(x.text).contains(q)) x,
    ];
    final tests = [
      for (final x in spec.tests)
        if (q.isEmpty || _fold(x.text).contains(q)) x,
    ];
    final graded = spec.gradedTests.length;
    final shown = _tests ? tests.length : oral.length;
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(title)),
      body: SafeArea(
        child: ListView.builder(
          key: Key('assessment.list.${spec.id}'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: shown + 2,
          itemBuilder: (context, i) {
            if (i == 0) {
              return FeContentFrame(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: FeSpace.sm),
                    SegmentedButton<bool>(
                      key: const Key('assessment.tabs'),
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: Text(l.assessmentTabOral),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text(l.assessmentTabTests),
                        ),
                      ],
                      selected: {_tests},
                      onSelectionChanged: (v) =>
                          setState(() => _tests = v.first),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    if (!_tests)
                      Wrap(
                        spacing: FeSpace.xs,
                        runSpacing: FeSpace.xs,
                        children: [
                          for (final k in spec.categories)
                            ChoiceChip(
                              key: Key('assessment.cat.${k.id}'),
                              label: Text(assessmentCatTitle(l, k.id)),
                              selected: k.id == cat.id,
                              onSelected: (_) => setState(() => _cat = k.id),
                            ),
                        ],
                      ),
                    if (!_tests)
                      Padding(
                        padding: const EdgeInsets.only(top: FeSpace.sm),
                        child: FeCard(
                          key: const Key('assessment.oralExam'),
                          padding: const EdgeInsets.all(FeSpace.sm),
                          onTap: () => context.push(
                            Routes.assessmentExam(spec.id, cat.id),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.confirmation_number_outlined,
                                color: c.brand,
                              ),
                              const SizedBox(width: FeSpace.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l.oralExamStart, style: t.titleSmall),
                                    Text(
                                      l.oralExamStartDesc,
                                      style: t.bodySmall?.copyWith(
                                        color: c.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    if (_tests) _TestsHeader(spec: spec, graded: graded),
                    const SizedBox(height: FeSpace.sm),
                    TextField(
                      key: const Key('assessment.search'),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: l.assessmentSearchHint,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    if (!_tests)
                      Text(
                        '${l.assessmentCountQuestions(oral.length)} · '
                        '${l.assessmentReadyProgress(cat.questions.where((x) => ready.contains(x.id)).length, cat.questions.length)}',
                        style: t.labelMedium?.copyWith(color: c.textSecondary),
                      ),
                    if (shown == 0) ...[
                      const SizedBox(height: FeSpace.md),
                      FeEmptyState(
                        icon: Icons.search_off,
                        body: l.assessmentNoResults,
                        compact: true,
                      ),
                    ],
                  ],
                ),
              );
            }
            if (i == shown + 1) {
              return const FeContentFrame(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: FeSpace.lg),
                  child: _SourceNote(),
                ),
              );
            }
            final idx = i - 1;
            return FeContentFrame(
              child: Padding(
                padding: const EdgeInsets.only(bottom: FeSpace.xs),
                child: _tests
                    ? _TestTile(question: tests[idx])
                    : _OralTile(
                        spec: spec,
                        question: oral[idx],
                        isReady: ready.contains(oral[idx].id),
                        hasAnswer:
                            answered?.answers.containsKey(oral[idx].id) ??
                            false,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge(this.n);

  final int n;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.accentContainer,
        borderRadius: BorderRadius.circular(FeRadius.sm),
      ),
      child: SizedBox(
        width: 40,
        height: 32,
        child: Center(
          child: Text(
            '$n',
            style: t.labelLarge?.copyWith(color: c.onAccentContainer),
          ),
        ),
      ),
    );
  }
}

class _OralTile extends StatelessWidget {
  const _OralTile({
    required this.spec,
    required this.question,
    required this.isReady,
    required this.hasAnswer,
  });

  final AssessmentSpecialty spec;
  final AssessmentQuestion question;
  final bool isReady;
  final bool hasAnswer;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: Key('assessment.q.${question.id}'),
      padding: const EdgeInsets.all(FeSpace.sm),
      onTap: () =>
          context.push(Routes.assessmentQuestion(spec.id, question.id)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NumberBadge(question.number),
          const SizedBox(width: FeSpace.sm),
          Expanded(
            child: Text(
              question.text,
              style: t.bodyMedium,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasAnswer) ...[
            const SizedBox(width: FeSpace.xs),
            Icon(Icons.menu_book_outlined, color: c.textSecondary, size: 20),
          ],
          if (isReady) ...[
            const SizedBox(width: FeSpace.xs),
            Icon(Icons.check_circle, color: c.verified, size: 22),
          ],
        ],
      ),
    );
  }
}

class _TestsHeader extends ConsumerWidget {
  const _TestsHeader({required this.spec, required this.graded});

  final AssessmentSpecialty spec;
  final int graded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final unkeyed = spec.tests.length - graded;
    final stats = ref.watch(assessmentTestStatsProvider);
    final mistakes = stats.mistakeCount(spec.id);
    final mastered = stats.masteredCount(spec.id, [
      for (final q in spec.gradedTests) q.id,
    ]);
    return FeCard(
      key: const Key('assessment.testsHeader'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            graded == 0 ? l.assessmentTestNone : l.assessmentTestPool(graded),
            style: t.bodyMedium,
          ),
          if (unkeyed > 0 && graded > 0) ...[
            const SizedBox(height: 4),
            Text(
              l.assessmentTestUnkeyed(unkeyed),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ],
          if (graded > 0) ...[
            const SizedBox(height: FeSpace.xs),
            Text(
              l.assessmentMasteredLine(mastered, graded),
              key: const Key('assessment.mastered'),
              style: t.labelLarge?.copyWith(color: c.verified),
            ),
            const SizedBox(height: FeSpace.sm),
            Text(l.assessmentModesTitle, style: t.titleSmall),
            const SizedBox(height: FeSpace.xs),
            FilledButton.icon(
              key: const Key('assessment.testStart'),
              onPressed: () => context.push(Routes.assessmentTest(spec.id)),
              icon: const Icon(Icons.shuffle),
              label: Text(l.assessmentModeRandom),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, FeSpace.xs),
              child: Text(
                l.assessmentModeRandomDesc,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ),
            _ModeTile(
              tileKey: const Key('assessment.mode.blocks'),
              icon: Icons.view_list_outlined,
              title: l.assessmentModeBlocks,
              body: l.assessmentModeBlocksDesc,
              onTap: () =>
                  context.push(Routes.assessmentTest(spec.id, mode: 'blocks')),
            ),
            _ModeTile(
              tileKey: const Key('assessment.mode.mistakes'),
              icon: Icons.replay,
              title: l.assessmentModeMistakes(mistakes),
              body: mistakes == 0
                  ? l.assessmentModeMistakesEmpty
                  : l.assessmentModeMistakesDesc,
              onTap: mistakes == 0
                  ? null
                  : () => context.push(
                      Routes.assessmentTest(spec.id, mode: 'mistakes'),
                    ),
            ),
            _ModeTile(
              tileKey: const Key('assessment.mode.exam'),
              icon: Icons.timer_outlined,
              title: l.assessmentModeExam,
              body: l.assessmentModeExamDesc,
              onTap: () =>
                  context.push(Routes.assessmentTest(spec.id, mode: 'exam')),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.tileKey,
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final Key tileKey;
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final on = onTap != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: tileKey,
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: on ? c.accent : c.textSecondary),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: t.titleSmall?.copyWith(
                      color: on ? null : c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            if (on) Icon(Icons.chevron_right, color: c.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _TestTile extends StatelessWidget {
  const _TestTile({required this.question});

  final AssessmentTestQuestion question;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: Key('assessment.t.${question.id}'),
      padding: const EdgeInsets.all(FeSpace.sm),
      onTap: () => _showTestSheet(context, question),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NumberBadge(question.number),
          const SizedBox(width: FeSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.text,
                  style: t.bodyMedium,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!question.graded) ...[
                  const SizedBox(height: 4),
                  Text(
                    l.assessmentKeyPending,
                    style: t.labelSmall?.copyWith(color: c.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showTestSheet(BuildContext context, AssessmentTestQuestion q) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (ctx, controller) => ListView(
        key: const Key('assessment.testSheet'),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        controller: controller,
        padding: const EdgeInsets.all(FeSpace.md),
        children: [
          _TestBody(question: q, reveal: true, selected: null, inSheet: true),
        ],
      ),
    ),
  );
}

/// Savol matni, variantlar va (kalit bo‘lsa) to‘g‘ri javob + manba.
class _TestBody extends StatelessWidget {
  const _TestBody({
    required this.question,
    required this.reveal,
    required this.selected,
    this.onSelect,
    this.inSheet = false,
    this.showAi = true,
  });

  final AssessmentTestQuestion question;
  final bool reveal;
  final int? selected;
  final ValueChanged<int>? onSelect;

  /// Pastki varaqda ochilgan: AI’ga o‘tishdan oldin varaq yopiladi.
  final bool inSheet;

  /// Mashq ekranida AI tugmasi «Keyingisi»dan keyin alohida qo‘yiladi.
  final bool showAi;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final key = question.key;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.assessmentQuestionNo(question.number), style: t.labelMedium),
        const SizedBox(height: FeSpace.xs),
        Text(question.text, style: t.titleMedium),
        const SizedBox(height: FeSpace.md),
        for (var i = 0; i < question.options.length; i++) ...[
          _OptionTile(
            index: i,
            text: question.options[i],
            state: !reveal || key == null
                ? (selected == i ? _OptState.picked : _OptState.idle)
                : i == key
                ? _OptState.correct
                : (selected == i ? _OptState.wrong : _OptState.idle),
            onTap: onSelect == null ? null : () => onSelect!(i),
          ),
          const SizedBox(height: FeSpace.xs),
        ],
        if (key == null) ...[
          const SizedBox(height: FeSpace.xs),
          Text(
            l.assessmentKeyPending,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ] else if (reveal && question.keySource != null) ...[
          const SizedBox(height: FeSpace.xs),
          Text(
            l.assessmentAnswerSource(_keySourceText(l, question.keySource!)),
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
          if (question.keySource!.quote.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              l.assessmentBasis(question.keySource!.quote),
              key: const Key('assessment.basis'),
              style: t.bodySmall?.copyWith(
                color: c.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
        if (showAi) ...[
          const SizedBox(height: FeSpace.sm),
          _AskAiButton(question: question, inSheet: inSheet),
        ],
      ],
    );
  }
}

class _AskAiButton extends StatelessWidget {
  const _AskAiButton({required this.question, this.inSheet = false});

  final AssessmentTestQuestion question;
  final bool inSheet;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return OutlinedButton.icon(
      key: const Key('assessment.testAskAi'),
      onPressed: () {
        final router = GoRouter.of(context);
        if (inSheet) Navigator.of(context).pop();
        router.go(Routes.aiAsk(question.text));
      },
      icon: const Icon(Icons.auto_awesome_outlined),
      label: Text(l.assessmentAskAi),
    );
  }
}

enum _OptState { idle, picked, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.index,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final int index;
  final String text;
  final _OptState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final (Color? bg, IconData? icon, Color? ic) = switch (state) {
      _OptState.correct => (
        c.verified.withValues(alpha: 0.12),
        Icons.check_circle,
        c.verified,
      ),
      _OptState.wrong => (
        c.danger.withValues(alpha: 0.10),
        Icons.cancel,
        c.danger,
      ),
      _OptState.picked => (c.accentContainer, null, null),
      _OptState.idle => (null, null, null),
    };
    return FeCard(
      key: Key('assessment.opt.$index'),
      color: bg,
      padding: const EdgeInsets.all(FeSpace.sm),
      onTap: onTap,
      child: Row(
        children: [
          Text(
            String.fromCharCode(0x41 + index),
            style: t.labelLarge?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(width: FeSpace.sm),
          Expanded(child: Text(text, style: t.bodyMedium)),
          if (icon != null) ...[
            const SizedBox(width: FeSpace.xs),
            Icon(icon, color: ic, size: 22),
          ],
        ],
      ),
    );
  }
}

/// Og‘zaki savol: to‘liq matn, «tayyor» belgisi, Forensic AI.
class AssessmentQuestionScreen extends ConsumerWidget {
  const AssessmentQuestionScreen({
    super.key,
    required this.specialtyId,
    required this.questionId,
  });

  final String specialtyId;
  final String questionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final spec = ref.watch(assessmentProvider).value?.specialty(specialtyId);
    AssessmentQuestion? q;
    AssessmentCategory? cat;
    if (spec != null) {
      for (final k in spec.categories) {
        for (final x in k.questions) {
          if (x.id == questionId) {
            q = x;
            cat = k;
          }
        }
      }
    }
    final title = assessmentSpecTitle(l, specialtyId);
    if (q == null || cat == null) {
      return _Frame(
        title: title,
        children: [
          FeEmptyState(icon: Icons.quiz_outlined, body: l.assessmentEmpty),
        ],
      );
    }
    final isReady = ref.watch(assessmentProgressProvider).contains(q.id);
    return _Frame(
      title: title,
      listKey: Key('assessment.detail.${q.id}'),
      children: [
        Text(
          '${l.assessmentQuestionNo(q.number)} · '
          '${assessmentCatTitle(l, cat.id)}',
          style: t.labelMedium?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: FeSpace.xs),
        Text(q.text, style: t.titleMedium),
        const SizedBox(height: FeSpace.md),
        OralAnswerView(
          answer: ref
              .watch(oralAnswersProvider(specialtyId))
              .value
              ?.answers[q.id],
        ),
        const SizedBox(height: FeSpace.lg),
        FilledButton.icon(
          key: const Key('assessment.markReady'),
          onPressed: () =>
              ref.read(assessmentProgressProvider.notifier).toggle(q!.id),
          icon: Icon(isReady ? Icons.check_circle : Icons.check_circle_outline),
          label: Text(
            isReady ? l.assessmentUnmarkReady : l.assessmentMarkReady,
          ),
        ),
        const SizedBox(height: FeSpace.xs),
        OutlinedButton.icon(
          key: const Key('assessment.askAi'),
          onPressed: () => context.go(Routes.aiAsk(q!.text)),
          icon: const Icon(Icons.auto_awesome_outlined),
          label: Text(l.assessmentAskAi),
        ),
        const SizedBox(height: FeSpace.lg),
        const _SourceNote(),
      ],
    );
  }
}

/// Adabiyot asosida yozilgan javob: bandlar, har birining manbasi (bet,
/// iqtibos) va yoritilmagan jihatlar. Javob yo‘q bo‘lsa — «tez kunda».
class OralAnswerView extends StatelessWidget {
  const OralAnswerView({super.key, required this.answer});

  final OralAnswer? answer;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final a = answer;
    if (a == null || a.points.isEmpty) {
      return FeCard(
        key: const Key('assessment.answerSoon'),
        padding: const EdgeInsets.all(FeSpace.sm),
        child: Row(
          children: [
            Icon(Icons.hourglass_empty, color: c.textSecondary, size: 20),
            const SizedBox(width: FeSpace.xs),
            Expanded(
              child: Text(
                l.assessmentAnswerSoon,
                style: t.bodyMedium?.copyWith(color: c.textSecondary),
              ),
            ),
          ],
        ),
      );
    }
    final uzOnly = Localizations.localeOf(context).languageCode != 'uz';
    return Column(
      key: const Key('assessment.answer'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.assessmentAnswerTitle),
        if (uzOnly)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: Text(
              l.assessmentAnswerUzOnly,
              style: t.labelMedium?.copyWith(color: c.textSecondary),
            ),
          ),
        for (var i = 0; i < a.points.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: _OralPointTile(number: i + 1, point: a.points[i]),
          ),
        const SizedBox(height: FeSpace.xs),
        Text(
          l.assessmentAnswerNote,
          key: const Key('assessment.answerNote'),
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        if (a.gaps.isNotEmpty) ...[
          const SizedBox(height: FeSpace.xs),
          Text(
            l.assessmentAnswerGaps,
            style: t.labelLarge?.copyWith(color: c.textSecondary),
          ),
          for (final g in a.gaps)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '• $g',
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ),
        ],
      ],
    );
  }
}

class _OralPointTile extends StatelessWidget {
  const _OralPointTile({required this.number, required this.point});

  final int number;
  final OralPoint point;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final src = point.source;
    final cite = src == null
        ? ''
        : (point.page > 0
              ? l.assessmentBookPage(src.title, point.page)
              : src.title);
    return FeCard(
      padding: const EdgeInsets.all(FeSpace.sm),
      onTap: src == null ? null : () => _showSource(context, point, cite),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NumberBadge(number),
          const SizedBox(width: FeSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(point.text, style: t.bodyMedium),
                if (cite.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 14,
                        color: c.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          cite,
                          style: t.labelSmall?.copyWith(color: c.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showSource(BuildContext context, OralPoint point, String cite) {
  final l = AppLocalizations.of(context);
  final c = FeTheme.of(context);
  final t = Theme.of(context).textTheme;
  final url = point.url.isNotEmpty ? point.url : (point.source?.url ?? '');
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        key: const Key('assessment.sourceSheet'),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          FeSpace.md,
          0,
          FeSpace.md,
          FeSpace.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.assessmentAnswerSourceLabel, style: t.titleSmall),
            const SizedBox(height: FeSpace.xs),
            Text(cite, style: t.bodyMedium),
            if (url.isNotEmpty) ...[
              const SizedBox(height: 2),
              SelectableText(
                url,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
            const SizedBox(height: FeSpace.md),
            Text(l.assessmentAnswerOriginal, style: t.titleSmall),
            const SizedBox(height: FeSpace.xs),
            SelectableText(l.assessmentBasis(point.quote), style: t.bodyMedium),
          ],
        ),
      ),
    ),
  );
}

/// Test mashqi usuli (marshrutdagi `?mode=`; noma’lum — aralash).
enum AssessmentTestMode {
  random,
  blocks,
  block,
  mistakes,
  exam;

  static AssessmentTestMode parse(String? v) => switch (v) {
    'blocks' => blocks,
    'block' => block,
    'mistakes' => mistakes,
    'exam' => exam,
    _ => random,
  };
}

/// Bir mashqda 50 ta savol (egasi, 2026-11-02); imtihon — 60 daqiqa.
const assessmentRunSize = 50;
const assessmentExamSeconds = 60 * 60;

/// Savollar asl tartibda (raqami bo‘yicha), 50 tadan bloklarga bo‘lingan.
List<List<AssessmentTestQuestion>> assessmentBlocks(AssessmentSpecialty spec) {
  final all = spec.gradedTests.toList()
    ..sort((a, b) => a.number.compareTo(b.number));
  return [
    for (var i = 0; i < all.length; i += assessmentRunSize)
      all.sublist(i, math.min(i + assessmentRunSize, all.length)),
  ];
}

String _clock(int s) =>
    '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

/// Test mashqi: faqat javob kaliti tasdiqlangan savollar.
class AssessmentTestScreen extends ConsumerStatefulWidget {
  const AssessmentTestScreen({
    super.key,
    required this.specialtyId,
    this.mode = AssessmentTestMode.random,
    this.block = 0,
  });

  final String specialtyId;
  final AssessmentTestMode mode;
  final int block;

  @override
  ConsumerState<AssessmentTestScreen> createState() =>
      _AssessmentTestScreenState();
}

class _AssessmentTestScreenState extends ConsumerState<AssessmentTestScreen>
    with WidgetsBindingObserver {
  List<AssessmentTestQuestion>? _run;
  final _answers = <int?>[];
  int _i = 0;
  bool _done = false;
  bool _timeUp = false;
  Timer? _timer;
  final _left = ValueNotifier<int>(assessmentExamSeconds);

  bool get _exam => widget.mode == AssessmentTestMode.exam;

  /// Ilova fonga o‘tgan vaqt: qaytganda o‘tgan soniyalar taymerdan ayiriladi
  /// (fonda Timer to‘xtashi mumkin — imtihon vaqti baribir o‘tadi).
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_exam || _timer == null || _done) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _pausedAt ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed && _pausedAt != null) {
      final gone = DateTime.now().difference(_pausedAt!).inSeconds;
      _pausedAt = null;
      if (gone > 0) {
        _left.value = (_left.value - gone).clamp(0, assessmentExamSeconds);
        final spec = ref
            .read(assessmentProvider)
            .value
            ?.specialty(widget.specialtyId);
        if (_left.value <= 0 && spec != null) _finish(spec, timeUp: true);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _left.dispose();
    super.dispose();
  }

  List<AssessmentTestQuestion> _pick(AssessmentSpecialty spec) {
    switch (widget.mode) {
      case AssessmentTestMode.block:
        final blocks = assessmentBlocks(spec);
        return widget.block >= 0 && widget.block < blocks.length
            ? blocks[widget.block]
            : const [];
      case AssessmentTestMode.mistakes:
        final ids = ref.read(assessmentTestStatsProvider).mistakeIds(spec.id);
        final pool = [
          for (final q in spec.gradedTests)
            if (ids.contains(q.id)) q,
        ]..shuffle(math.Random());
        return pool.take(assessmentRunSize).toList();
      case AssessmentTestMode.random:
      case AssessmentTestMode.blocks:
      case AssessmentTestMode.exam:
        final pool = spec.gradedTests.toList()..shuffle(math.Random());
        return pool.take(assessmentRunSize).toList();
    }
  }

  void _start(AssessmentSpecialty spec) {
    final run = _pick(spec);
    _timer?.cancel();
    setState(() {
      _run = run;
      _answers
        ..clear()
        ..addAll(List<int?>.filled(run.length, null));
      _i = 0;
      _done = false;
      _timeUp = false;
    });
    if (_exam && run.isNotEmpty) {
      _left.value = assessmentExamSeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || _done) return;
        _left.value = _left.value - 1;
        if (_left.value <= 0) _finish(spec, timeUp: true);
      });
    }
  }

  void _select(AssessmentSpecialty spec, int v) {
    final q = _run![_i];
    setState(() => _answers[_i] = v);
    if (_exam) return; // imtihonda hisob oxirida yuritiladi
    ref
        .read(assessmentTestStatsProvider.notifier)
        .recordAnswer(
          spec.id,
          q.id,
          isCorrect: v == q.key,
          inMistakesMode: widget.mode == AssessmentTestMode.mistakes,
        );
  }

  void _finish(AssessmentSpecialty spec, {bool timeUp = false}) {
    if (_done) return;
    _timer?.cancel();
    final run = _run!;
    final stats = ref.read(assessmentTestStatsProvider.notifier);
    if (_exam) {
      for (var k = 0; k < run.length; k++) {
        stats.recordAnswer(
          spec.id,
          run[k].id,
          isCorrect: _answers[k] == run[k].key,
        );
      }
    }
    if (widget.mode == AssessmentTestMode.block) {
      final score = [
        for (var k = 0; k < run.length; k++)
          if (_answers[k] == run[k].key) k,
      ].length;
      stats.recordBlock(spec.id, widget.block, score);
    }
    setState(() {
      _done = true;
      _timeUp = timeUp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final spec = ref
        .watch(assessmentProvider)
        .value
        ?.specialty(widget.specialtyId);
    final title = assessmentSpecTitle(l, widget.specialtyId);
    if (spec == null || spec.gradedTests.isEmpty) {
      return _Frame(
        title: title,
        children: [
          FeEmptyState(icon: Icons.quiz_outlined, body: l.assessmentTestNone),
        ],
      );
    }
    if (widget.mode == AssessmentTestMode.blocks) {
      return _BlockPicker(spec: spec, title: title);
    }
    if (_run == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _run == null) _start(spec);
      });
      return _Frame(
        title: title,
        children: [FeListSkeleton(semanticLabel: title)],
      );
    }
    final run = _run!;
    if (run.isEmpty) {
      return _Frame(
        title: title,
        children: [
          FeEmptyState(
            icon: Icons.quiz_outlined,
            body: widget.mode == AssessmentTestMode.mistakes
                ? l.assessmentModeMistakesEmpty
                : l.assessmentTestNone,
          ),
        ],
      );
    }
    if (_done) {
      final correct = [
        for (var k = 0; k < run.length; k++)
          if (_answers[k] == run[k].key) k,
      ];
      final wrong = [
        for (var k = 0; k < run.length; k++)
          if (_answers[k] != run[k].key) k,
      ];
      return _Frame(
        title: l.assessmentResultTitle,
        listKey: const Key('assessment.result'),
        children: [
          FeCard(
            child: Column(
              children: [
                if (_timeUp) ...[
                  Text(
                    l.assessmentExamTimeUp,
                    key: const Key('assessment.timeUp'),
                    style: t.titleSmall?.copyWith(color: c.danger),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  l.assessmentResultScore(correct.length, run.length),
                  key: const Key('assessment.score'),
                  style: t.headlineSmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: FeSpace.sm),
          FilledButton.icon(
            key: const Key('assessment.retry'),
            onPressed: () => _start(spec),
            icon: const Icon(Icons.refresh),
            label: Text(l.assessmentRetry),
          ),
          if (wrong.isNotEmpty) ...[
            FeSectionHeader(l.assessmentMistakes),
            for (final k in wrong) ...[
              FeCard(
                onTap: () => _showTestSheet(context, run[k]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(run[k].text, style: t.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      l.assessmentCorrectAnswer(run[k].options[run[k].key!]),
                      style: t.bodySmall?.copyWith(color: c.verified),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FeSpace.xs),
            ],
          ],
        ],
      );
    }
    final q = run[_i];
    final picked = _answers[_i];
    final answered = picked != null;
    final reveal = answered && !_exam;
    return _Frame(
      title: title,
      listKey: Key('assessment.run.${spec.id}'),
      actions: _exam
          ? [
              ValueListenableBuilder<int>(
                valueListenable: _left,
                builder: (context, s, _) => Padding(
                  padding: const EdgeInsets.only(right: FeSpace.md),
                  child: Center(
                    child: Semantics(
                      label: l.assessmentExamTimer(_clock(s)),
                      excludeSemantics: true,
                      child: Text(
                        _clock(s),
                        key: const Key('assessment.timer'),
                        style: t.titleMedium?.copyWith(
                          color: s <= 300 ? c.danger : null,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]
          : null,
      children: [
        Row(
          children: [
            Text(
              '${_i + 1} / ${run.length}',
              key: const Key('assessment.progress'),
              style: t.labelLarge,
            ),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(FeRadius.pill),
                child: LinearProgressIndicator(
                  value: (_i + (answered ? 1 : 0)) / run.length,
                  minHeight: 6,
                  color: c.accent,
                  backgroundColor: c.accentContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: FeSpace.md),
        _TestBody(
          question: q,
          reveal: reveal,
          selected: picked,
          showAi: false,
          onSelect: reveal ? null : (v) => _select(spec, v),
        ),
        if (_exam) ...[
          const SizedBox(height: FeSpace.xs),
          Text(
            l.assessmentExamHint,
            key: const Key('assessment.examHint'),
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ],
        if (reveal) ...[
          const SizedBox(height: FeSpace.sm),
          Text(
            picked == q.key ? l.assessmentCorrect : l.assessmentWrong,
            key: const Key('assessment.verdict'),
            style: t.titleSmall?.copyWith(
              color: picked == q.key ? c.verified : c.danger,
            ),
          ),
        ],
        if (answered) ...[
          const SizedBox(height: FeSpace.sm),
          FilledButton(
            key: const Key('assessment.next'),
            onPressed: () {
              if (_i + 1 >= run.length) {
                _finish(spec);
              } else {
                setState(() => _i++);
              }
            },
            child: Text(
              _i + 1 >= run.length ? l.assessmentFinish : l.assessmentNext,
            ),
          ),
          if (!_exam) ...[
            const SizedBox(height: FeSpace.xs),
            _AskAiButton(question: q),
          ],
        ],
      ],
    );
  }
}

/// «Bloklab yechish»: bloklar ro‘yxati va har birining eng yaxshi natijasi.
class _BlockPicker extends ConsumerWidget {
  const _BlockPicker({required this.spec, required this.title});

  final AssessmentSpecialty spec;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final stats = ref.watch(assessmentTestStatsProvider);
    final blocks = assessmentBlocks(spec);
    var from = 1;
    return _Frame(
      title: title,
      listKey: Key('assessment.blocks.${spec.id}'),
      children: [
        FeSectionHeader(l.assessmentBlocksPick),
        for (var b = 0; b < blocks.length; b++)
          Builder(
            builder: (context) {
              final a = from;
              final z = from + blocks[b].length - 1;
              from = z + 1;
              final best = stats.bestScore(spec.id, b);
              return Padding(
                padding: const EdgeInsets.only(bottom: FeSpace.xs),
                child: FeCard(
                  key: Key('assessment.block.$b'),
                  onTap: () => context.push(
                    Routes.assessmentTest(spec.id, mode: 'block', block: b),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.assessmentBlockRange(a, z),
                          style: t.titleSmall,
                        ),
                      ),
                      Text(
                        best == null
                            ? l.assessmentBlockUnsolved
                            : l.assessmentBlockBest(best, blocks[b].length),
                        key: Key('assessment.block.$b.best'),
                        style: t.bodySmall?.copyWith(
                          color: best == null ? c.textSecondary : c.verified,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: c.textSecondary),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// «Foydalanilgan adabiyotlar»: javob kalitlari asoslangan barcha manbalar.
class AssessmentSourcesScreen extends ConsumerWidget {
  const AssessmentSourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final bundle = ref.watch(assessmentProvider).value;
    // (tur, nom, havola) -> savollar soni
    final counts = <(String, String, String), int>{};
    for (final s in bundle?.specialties ?? const <AssessmentSpecialty>[]) {
      for (final q in s.tests) {
        final k = q.keySource;
        if (k == null) continue;
        final id = (k.kind, k.kind == 'teacher' ? '' : k.title, k.url);
        counts[id] = (counts[id] ?? 0) + 1;
      }
    }
    for (final id in oralSpecialties) {
      final oral = ref.watch(oralAnswersProvider(id)).value;
      if (oral == null) continue;
      // Har bir manba uchun javob berilgan savollar soni.
      final perSource = <int, Set<String>>{};
      for (final e in oral.answers.entries) {
        for (final p in e.value.points) {
          final i = p.source == null ? -1 : oral.sources.indexOf(p.source!);
          if (i >= 0) (perSource[i] ??= <String>{}).add(e.key);
        }
      }
      for (final e in perSource.entries) {
        final src = oral.sources[e.key];
        final key = (src.kind, src.title, src.url);
        counts[key] = (counts[key] ?? 0) + e.value.length;
      }
    }
    List<Widget> group(String kind, String heading) {
      final rows = [
        for (final e in counts.entries)
          if (e.key.$1 == kind) e,
      ]..sort((a, b) => b.value.compareTo(a.value));
      if (rows.isEmpty) return const [];
      return [
        FeSectionHeader(heading),
        for (final e in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: FeCard(
              padding: const EdgeInsets.all(FeSpace.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kind == 'teacher' ? l.assessmentKeyTeacher : e.key.$2,
                    style: t.bodyMedium,
                  ),
                  if (e.key.$3.isNotEmpty)
                    SelectableText(
                      e.key.$3,
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    l.assessmentCountQuestions(e.value),
                    style: t.labelSmall?.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
          ),
      ];
    }

    return _Frame(
      title: l.assessmentSourcesTitle,
      listKey: const Key('assessment.sources'),
      children: [
        Text(
          l.assessmentSourcesIntro,
          style: t.bodyMedium?.copyWith(color: c.textSecondary),
        ),
        ...group('book', l.assessmentSourcesBooks),
        ...group('teacher', l.assessmentSourcesTeacher),
        ...group('web', l.assessmentSourcesWeb),
      ],
    );
  }
}
