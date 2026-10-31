import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/class_groups.dart';
import '../../../app/class_quiz.dart';
import '../../../app/lessons.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_groups/class_groups_models.dart';
import '../../../domain/class_groups/variant_draw.dart';
import '../../professional/presentation/professional_widgets.dart' show FeNote;
import 'group_widgets.dart';

/// Talaba testi. [preview] — ustozning «Talaba ko‘rinishida sinash»i:
/// o‘sha savollar va vaqt, lekin sessiya faqat xotirada, **serverga hech
/// narsa yuborilmaydi** (faqat hovuz o‘qiladi).
/// Har talabaga savollar TARTIBI alohida (qo‘shnidan ko‘chirib bo‘lmasin):
/// server bir xil to‘plam bergan bo‘lsa ham tartib `drawVariant` bilan
/// talaba identifikatoriga ko‘ra aralashtiriladi (to‘plam o‘zgarmaydi).
/// Identifikator yo‘q bo‘lsa — serverdagi tartib.
@visibleForTesting
GroupAttempt? groupOrderForStudent(GroupAttempt? a, String? userId) {
  if (a == null || userId == null || a.questions.length < 2) return a;
  final byId = {for (final q in a.questions) q.id: q};
  final ids = drawVariant(
    assignmentId: a.assignment.id,
    userId: userId,
    pool: byId.keys.toList()..sort(),
    count: byId.length,
  );
  return GroupAttempt(
    assignment: a.assignment,
    finished: a.finished,
    questions: [for (final id in ids) byId[id]!],
    answers: a.answers,
    startedAt: a.startedAt,
    endsAt: a.endsAt,
    serverNow: a.serverNow,
    score: a.score,
    total: a.total,
  );
}

class GroupTestScreen extends ConsumerStatefulWidget {
  const GroupTestScreen({
    super.key,
    required this.groupId,
    required this.assignmentId,
    this.preview = false,
    this.practiceTopicId,
  });

  final String groupId;
  final String assignmentId;
  final bool preview;

  /// Ustoz «O‘zim yechib ko‘rish»: mavzu savollari yagona indeksdan
  /// (qurilmada), serverga hech narsa yuborilmaydi.
  final String? practiceTopicId;

  bool get local => preview || practiceTopicId != null;

  @override
  ConsumerState<GroupTestScreen> createState() => _GroupTestState();
}

class _GroupTestState extends ConsumerState<GroupTestScreen> {
  GroupAttempt? _attempt;
  GroupFailure? _failure;

  /// Sinov rejimi: to‘g‘ri javoblar (faqat xotirada).
  Map<String, int> _previewKey = const {};
  final _answers = <String, int>{};
  final _draftAnswers = <String, int>{};
  bool _saving = false;
  int _index = 0;
  bool _submitting = false;
  GroupClock? _clock;

  late final LessonScreenGuard _guard;

  @override
  void initState() {
    super.initState();
    // Test yechilayotganda skrinshot/yozib olish bloklanadi (Android FLAG_SECURE;
    // iOS’da ishonchli usul yo‘q). Ustozning ko‘rib chiqishi va mashq — yo‘q.
    _guard = ref.read(lessonScreenGuardProvider);
    if (!widget.local) unawaited(_guard.secure());
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_load()));
  }

  @override
  void dispose() {
    if (!widget.local) unawaited(_guard.release());
    super.dispose();
  }

  Future<void> _load() async {
    final svc = ref.read(classGroupsServiceProvider);
    final now = ref.read(groupNowProvider)();
    final practice = widget.practiceTopicId;
    if (practice != null) {
      final lang = Localizations.localeOf(context).languageCode;
      final bank = await ref.read(classQuizBankProvider.future);
      if (!mounted) return;
      final base = ClassQuizBank.baseId(practice);
      final topic =
          bank.variants
              .where((v) => v.id == ClassQuizBank.variantId(base, lang))
              .firstOrNull ??
          bank.variants.where((v) => v.id == base).firstOrNull;
      if (topic == null || topic.questions.isEmpty) {
        setState(() => _failure = GroupFailure.notEnoughQuestions);
        return;
      }
      final ids = drawVariant(
        assignmentId: topic.id,
        userId: 'self-${now.microsecondsSinceEpoch}',
        pool: [for (final q in topic.questions) q.id],
        count: 10,
      );
      final attempt = GroupAttempt(
        assignment: GroupAssignment(
          id: topic.id,
          groupId: '',
          topicId: topic.id,
          topicTitle: topic.title,
          questionCount: ids.length,
          variantMode: false,
          reveal: RevealPolicy.afterClose,
          closed: false,
          revealed: false,
        ),
        finished: false,
        questions: [
          for (final id in ids)
            if (bank.question(id) case final q?)
              GroupQuestion(id: id, text: q.question, options: q.options),
        ],
        answers: const {},
        serverNow: now.toUtc(),
      );
      setState(() {
        _previewKey = {
          for (final id in ids) id: bank.question(id)!.correctIndex,
        };
        _attempt = attempt;
        _clock = GroupClock.of(attempt, now);
      });
      return;
    }
    if (widget.preview) {
      final r = await svc.preview(widget.assignmentId);
      if (!mounted) return;
      final p = r.value;
      if (p == null) {
        setState(() => _failure = r.failure);
        return;
      }
      final a = p.assignment;
      final byId = {for (final q in p.pool) q.id: q};
      final ids = drawVariant(
        assignmentId: a.id,
        userId: a.variantMode ? (svc.userId ?? commonUser) : commonUser,
        pool: byId.keys.toList()..sort(),
        count: a.questionCount,
      );
      final limitEnd = a.timeLimitMin == null
          ? null
          : now.toUtc().add(Duration(minutes: a.timeLimitMin!));
      final due = a.dueAt;
      final ends = [?limitEnd, ?due]..sort();
      final attempt = GroupAttempt(
        assignment: a,
        finished: false,
        questions: [
          for (final id in ids)
            GroupQuestion(
              id: id,
              text: byId[id]!.text,
              options: byId[id]!.options,
            ),
        ],
        answers: const {},
        startedAt: now.toUtc(),
        endsAt: ends.firstOrNull,
        serverNow: now.toUtc(),
      );
      setState(() {
        _previewKey = {for (final id in ids) id: byId[id]!.correctIndex};
        _attempt = attempt;
        _clock = GroupClock.of(attempt, now);
      });
      return;
    }
    final r = await svc.open(widget.assignmentId);
    if (!mounted) return;
    final a = groupOrderForStudent(r.value, svc.userId);
    if (a == null) {
      setState(() => _failure = r.failure);
      return;
    }
    if (a.finished) {
      context.go(Routes.groupResult(widget.groupId, widget.assignmentId));
      return;
    }
    setState(() {
      _attempt = a;
      _answers.addAll(a.answers);
      _clock = GroupClock.of(a, now);
      final firstOpen = a.questions.indexWhere(
        (q) => !_answers.containsKey(q.id),
      );
      _index = firstOpen < 0 ? 0 : firstOpen;
    });
  }

  void _choose(GroupQuestion q, int option) {
    setState(() => _draftAnswers[q.id] = option);
  }

  Future<void> _confirm(GroupQuestion q) async {
    final option = _draftAnswers[q.id];
    if (option == null || _saving || _submitting) return;
    setState(() => _saving = true);
    if (!widget.local) {
      final r = await ref.read(classGroupsServiceProvider).save(
        widget.assignmentId,
        {q.id: option},
      );
      if (!mounted) return;
      if (r.failure != null) {
        setState(() => _saving = false);
        if (r.failure == GroupFailure.timeOver) {
          await _submit(force: true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                groupFailureText(
                  AppLocalizations.of(context),
                  r.failure!,
                  r.extra,
                ),
              ),
            ),
          );
        }
        return;
      }
    }
    setState(() {
      _answers[q.id] = option;
      _draftAnswers.remove(q.id);
      _saving = false;
    });
  }

  Future<void> _submit({bool force = false}) async {
    if (_submitting) return;
    final l = AppLocalizations.of(context);
    final a = _attempt!;
    final left = a.questions.where((q) => !_answers.containsKey(q.id)).length;
    if (!force) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(l.grpSubmitTitle),
          content: Text(
            left == 0 ? l.grpSubmitBodyAll : l.grpSubmitBodyLeft(left),
          ),
          actions: [
            TextButton(onPressed: () => c.pop(false), child: Text(l.grpCancel)),
            FilledButton(
              key: const Key('grp.submitYes'),
              onPressed: () => c.pop(true),
              child: Text(l.grpSubmitAction),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    setState(() => _submitting = true);
    if (widget.local) {
      final score = _previewKey.entries
          .where((e) => _answers[e.key] == e.value)
          .length;
      await showDialog<void>(
        context: context,
        builder: (c) => AlertDialog(
          key: const Key('grp.previewDone'),
          title: Text(l.grpPreviewDone(score, _previewKey.length)),
          content: Text(
            widget.practiceTopicId != null
                ? l.grpPracticeNothingSent
                : l.grpPreviewNothingSent,
          ),
          actions: [
            FilledButton(onPressed: () => c.pop(), child: Text(l.grpOk)),
          ],
        ),
      );
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else if (widget.practiceTopicId != null) {
        context.go(Routes.groups);
      } else {
        context.go(Routes.groupAssignment(widget.groupId, widget.assignmentId));
      }
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final r = await ref
        .read(classGroupsServiceProvider)
        .submit(widget.assignmentId, Map.of(_answers));
    if (!mounted) return;
    if (!r.ok && r.failure != GroupFailure.alreadySubmitted) {
      setState(() => _submitting = false);
      messenger.showSnackBar(
        SnackBar(content: Text(groupFailureText(l, r.failure!))),
      );
      return;
    }
    if (r.value?.late ?? false) {
      messenger.showSnackBar(SnackBar(content: Text(l.grpLateSubmitted)));
    }
    ref.invalidate(groupDetailProvider(widget.groupId));
    ref.invalidate(groupResultProvider(widget.assignmentId));
    // Test root navigatorda: `go` — natija sahifasi bir marta (orqaga —
    // guruh sahifasi).
    context.go(Routes.groupResult(widget.groupId, widget.assignmentId));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final a = _attempt;
    final f = _failure;

    if (a == null) {
      return Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.grpTestTitle)),
        body: Center(
          child: f == null
              ? const CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(FeSpace.lg),
                  child: FeEmptyState(
                    key: const Key('grp.testError'),
                    icon: Icons.lock_clock_outlined,
                    body: groupFailureText(l, f),
                    actionLabel: l.grpBackToGroup,
                    onAction: () => context.go(Routes.group(widget.groupId)),
                  ),
                ),
        ),
      );
    }
    if (a.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: FeAppBarTitle(a.assignment.topicTitle)),
        body: Center(child: Text(l.grpErrServer)),
      );
    }
    final q = a.questions[_index];
    final last = _index == a.questions.length - 1;
    final chosen = _draftAnswers[q.id] ?? _answers[q.id];
    final confirmed =
        _answers.containsKey(q.id) && !_draftAnswers.containsKey(q.id);

    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(a.assignment.topicTitle)),
      body: SafeArea(
        child: Column(
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.local)
                    Padding(
                      padding: const EdgeInsets.only(top: FeSpace.xs),
                      child: FeBanner(
                        key: const Key('grp.previewBanner'),
                        icon: Icons.visibility_outlined,
                        text: widget.practiceTopicId != null
                            ? l.grpPracticeBanner
                            : l.grpPreviewBanner,
                        tone: FeBannerTone.warning,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: FeSpace.xs),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.grpQuestionOf(_index + 1, a.questions.length),
                            key: const Key('grp.questionOf'),
                            style: t.labelLarge,
                          ),
                        ),
                        if (_clock != null)
                          GroupTimeChip(
                            clock: _clock!,
                            now: ref.read(groupNowProvider),
                            onExpired: () => _submit(force: true),
                          ),
                      ],
                    ),
                  ),
                  LinearProgressIndicator(
                    value: _answers.length / a.questions.length,
                    semanticsLabel: l.grpAnsweredOf(
                      _answers.length,
                      a.questions.length,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                key: const Key('grp.testList'),
                padding: const EdgeInsets.only(
                  top: FeSpace.md,
                  bottom: FeSpace.lg,
                ),
                children: [
                  FeContentFrame(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          q.text,
                          key: const Key('grp.questionText'),
                          style: t.titleMedium,
                        ),
                        const SizedBox(height: FeSpace.md),
                        for (final (i, o) in q.options.indexed)
                          Padding(
                            padding: const EdgeInsets.only(bottom: FeSpace.xs),
                            child: FeCard(
                              key: Key('grp.option.$i'),
                              color: chosen == i ? c.accentContainer : null,
                              onTap: _submitting || _saving
                                  ? null
                                  : () => _choose(q, i),
                              semanticLabel:
                                  '${String.fromCharCode(0x41 + i)}. $o',
                              child: ExcludeSemantics(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: chosen == i
                                          ? c.accent
                                          : c.surfaceSunken,
                                      foregroundColor: chosen == i
                                          ? c.onAccent
                                          : c.textPrimary,
                                      child: Text(
                                        String.fromCharCode(0x41 + i),
                                        style: t.labelLarge?.copyWith(
                                          color: chosen == i
                                              ? c.onAccent
                                              : c.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: FeSpace.sm),
                                    Expanded(
                                      child: Text(o, style: t.bodyLarge),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (!confirmed)
                          Padding(
                            padding: const EdgeInsets.only(top: FeSpace.xxs),
                            child: Text(
                              l.classAnswerFlowHint,
                              key: const Key('grp.flowHint'),
                              textAlign: TextAlign.center,
                              style: t.bodySmall?.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FeContentFrame(
              child: Padding(
                padding: const EdgeInsets.only(bottom: FeSpace.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!confirmed) ...[
                      FilledButton(
                        key: const Key('grp.confirm'),
                        onPressed: chosen == null || _saving || _submitting
                            ? null
                            : () => _confirm(q),
                        child: Text(l.verifySubmit),
                      ),
                      const SizedBox(height: FeSpace.xs),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('grp.prev'),
                            onPressed: _index == 0 || _saving || _submitting
                                ? null
                                : () => setState(() => _index--),
                            child: Text(l.grpPrev),
                          ),
                        ),
                        const SizedBox(width: FeSpace.xs),
                        Expanded(
                          child: last
                              ? FilledButton(
                                  key: const Key('grp.finish'),
                                  onPressed:
                                      _submitting || _saving || !confirmed
                                      ? null
                                      : _submit,
                                  child: Text(l.grpFinish),
                                )
                              : FilledButton(
                                  key: const Key('grp.next'),
                                  onPressed:
                                      _saving || _submitting || !confirmed
                                      ? null
                                      : () => setState(() => _index++),
                                  child: Text(l.grpNext),
                                ),
                        ),
                      ],
                    ),
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

/// Talaba natijasi. Ball darhol; to‘g‘ri javoblar, izoh va manba — faqat
/// muddat tugagach yoki ustoz testni yopgach (server qaror qiladi).
class GroupResultScreen extends ConsumerWidget {
  const GroupResultScreen({
    super.key,
    required this.groupId,
    required this.assignmentId,
  });

  final String groupId;
  final String assignmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final async = ref.watch(groupResultProvider(assignmentId));
    final r = async.value?.value;
    final f = async.value?.failure;

    final List<Widget> body;
    if (r != null) {
      body = [
        FeCard(
          key: const Key('grp.scoreCard'),
          color: c.accentContainer,
          child: Column(
            children: [
              Text(r.assignment.topicTitle, style: t.titleSmall),
              const SizedBox(height: FeSpace.xs),
              Text(
                '${r.score} / ${r.total}',
                key: const Key('grp.score'),
                style: t.displaySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(l.grpScoreCaption, style: t.bodySmall),
              if (r.expired) ...[
                const SizedBox(height: FeSpace.xs),
                Text(l.grpExpiredNote, style: t.bodySmall),
              ],
            ],
          ),
        ),
        const SizedBox(height: FeSpace.md),
        if (!r.revealed) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: Text(
              l.grpScoreReadyNote,
              key: const Key('grp.scoreReady'),
              textAlign: TextAlign.center,
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
          FeNote(
            key: const Key('grp.revealLocked'),
            icon: Icons.lock_clock_outlined,
            text: groupRevealText(context, l, r.assignment),
          ),
          const SizedBox(height: FeSpace.sm),
          OutlinedButton.icon(
            key: const Key('grp.refreshResult'),
            onPressed: () => ref.invalidate(groupResultProvider(assignmentId)),
            icon: const Icon(Icons.refresh),
            label: Text(l.grpRefresh),
          ),
        ] else ...[
          FeSectionHeader(l.grpAnswersSection),
          for (final (i, it) in r.items.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.sm),
              child: FeCard(
                key: Key('grp.item.$i'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          it.isCorrect == true
                              ? Icons.check_circle
                              : Icons.cancel_outlined,
                          color: it.isCorrect == true ? c.verified : c.danger,
                          size: 20,
                        ),
                        const SizedBox(width: FeSpace.xs),
                        Expanded(
                          child: Text(
                            '${i + 1}. ${it.text}',
                            style: t.titleSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: FeSpace.xs),
                    if (it.myAnswer != null && it.myAnswer! < it.options.length)
                      Text(
                        l.grpYourAnswer(it.options[it.myAnswer!]),
                        style: t.bodyMedium,
                      )
                    else
                      Text(l.grpNoAnswer, style: t.bodyMedium),
                    if (it.correctIndex != null &&
                        it.correctIndex! < it.options.length)
                      Text(
                        l.grpCorrectAnswer(it.options[it.correctIndex!]),
                        style: t.bodyMedium?.copyWith(
                          color: c.verified,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (it.explanation.isNotEmpty) ...[
                      const SizedBox(height: FeSpace.xxs),
                      Text(
                        it.explanation,
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                    if (it.source != null && !it.source!.isEmpty) ...[
                      const SizedBox(height: FeSpace.xxs),
                      Text(
                        [
                          it.source!.author,
                          it.source!.title,
                          if (it.source!.cleanPage != null)
                            it.source!.pageIsNumeric
                                ? l.grpPage(it.source!.cleanPage!)
                                : it.source!.cleanPage!,
                        ].where((s) => s.isNotEmpty).join(', '),
                        style: t.labelSmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
        const SizedBox(height: FeSpace.sm),
        TextButton(
          key: const Key('grp.backToGroup'),
          onPressed: () => context.go(Routes.group(groupId)),
          child: Text(l.grpBackToGroup),
        ),
      ];
    } else if (f != null) {
      body = [
        FeEmptyState(
          key: const Key('grp.resultError'),
          icon: Icons.cloud_off_outlined,
          body: groupFailureText(l, f),
          actionLabel: l.grpRetry,
          onAction: () => ref.invalidate(groupResultProvider(assignmentId)),
        ),
      ];
    } else {
      body = [FeListSkeleton(semanticLabel: l.grpResultTitle)];
    }

    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.grpResultTitle)),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.invalidate(groupResultProvider(assignmentId)),
        child: ListView(
          key: const Key('grp.resultList'),
          padding: EdgeInsets.only(
            top: FeSpace.sm,
            bottom: FeSpace.xl + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [const GroupDemoBanner(), ...body],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
