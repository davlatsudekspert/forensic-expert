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
  const _Frame({required this.title, required this.children, this.listKey});

  final String title;
  final List<Widget> children;
  final Key? listKey;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: FeAppBarTitle(title)),
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
            const SizedBox(height: FeSpace.xs),
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
  });

  final AssessmentSpecialty spec;
  final AssessmentQuestion question;
  final bool isReady;

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
          if (isReady) ...[
            const SizedBox(width: FeSpace.xs),
            Icon(Icons.check_circle, color: c.verified, size: 22),
          ],
        ],
      ),
    );
  }
}

class _TestsHeader extends StatelessWidget {
  const _TestsHeader({required this.spec, required this.graded});

  final AssessmentSpecialty spec;
  final int graded;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final unkeyed = spec.tests.length - graded;
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
            const SizedBox(height: FeSpace.sm),
            FilledButton.icon(
              key: const Key('assessment.testStart'),
              onPressed: () => context.push(Routes.assessmentTest(spec.id)),
              icon: const Icon(Icons.play_arrow),
              label: Text(l.assessmentTestStart),
            ),
          ],
        ],
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

/// Test mashqi: faqat javob kaliti tasdiqlangan savollar.
class AssessmentTestScreen extends ConsumerStatefulWidget {
  const AssessmentTestScreen({super.key, required this.specialtyId});

  final String specialtyId;

  @override
  ConsumerState<AssessmentTestScreen> createState() =>
      _AssessmentTestScreenState();
}

class _AssessmentTestScreenState extends ConsumerState<AssessmentTestScreen> {
  static const _size = 20;
  List<AssessmentTestQuestion>? _run;
  final _answers = <int?>[];
  int _i = 0;
  bool _done = false;

  void _start(AssessmentSpecialty spec) {
    final pool = spec.gradedTests.toList()..shuffle(math.Random());
    setState(() {
      _run = pool.take(_size).toList();
      _answers
        ..clear()
        ..addAll(List<int?>.filled(_run!.length, null));
      _i = 0;
      _done = false;
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
    return _Frame(
      title: title,
      listKey: Key('assessment.run.${spec.id}'),
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
          reveal: answered,
          selected: picked,
          showAi: false,
          onSelect: answered ? null : (v) => setState(() => _answers[_i] = v),
        ),
        if (answered) ...[
          const SizedBox(height: FeSpace.sm),
          Text(
            picked == q.key ? l.assessmentCorrect : l.assessmentWrong,
            key: const Key('assessment.verdict'),
            style: t.titleSmall?.copyWith(
              color: picked == q.key ? c.verified : c.danger,
            ),
          ),
          const SizedBox(height: FeSpace.sm),
          FilledButton(
            key: const Key('assessment.next'),
            onPressed: () => setState(() {
              if (_i + 1 >= run.length) {
                _done = true;
              } else {
                _i++;
              }
            }),
            child: Text(
              _i + 1 >= run.length ? l.assessmentFinish : l.assessmentNext,
            ),
          ),
          const SizedBox(height: FeSpace.xs),
          _AskAiButton(question: q),
        ],
      ],
    );
  }
}
