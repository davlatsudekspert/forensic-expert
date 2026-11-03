import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/lessons.dart';
import '../../../app/routes.dart';
import '../../../app/teacher_oral.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/assessment/oral_exam.dart';
import '../../../domain/lessons/lesson_models.dart';
import '../../../domain/lessons/lesson_oral.dart';
import '../../assessment/presentation/oral_ticket_card.dart';
import '../../lessons/presentation/lesson_slide_view.dart'
    show lessonSourceGroups, lessonSourceLine;
import '../../lessons/presentation/lesson_viewer_screen.dart'
    show LessonFailureView;

/// Ustoz stolim → «Og‘zaki imtihon (bilet)»: 1) mavzu(lar)ni tanlash
/// (kurs bo‘yicha, darslar tartibida), 2) «Bilet tuzish».
class TeacherOralTopicsScreen extends ConsumerStatefulWidget {
  const TeacherOralTopicsScreen({super.key});

  @override
  ConsumerState<TeacherOralTopicsScreen> createState() =>
      _TeacherOralTopicsScreenState();
}

class _TeacherOralTopicsScreenState
    extends ConsumerState<TeacherOralTopicsScreen> {
  final _search = TextEditingController();
  final _selected = <String>{};
  String _query = '';
  String? _course;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final res = ref.watch(lessonListProvider('')).value;
    final all = res?.value;
    final groups = LessonGrouping.group(all ?? const <LessonSummary>[]);
    final course = groups.any((g) => g.course == _course) ? _course : null;
    final visible = [
      for (final g in groups)
        if (course == null || g.course == course)
          LessonGroup(g.course, LessonGrouping.filter(g.items, _query)),
    ].where((g) => g.items.isNotEmpty).toList();
    final Widget list;
    if (all == null) {
      list = res?.failure != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(FeSpace.lg),
                child: LessonFailureView(
                  failure: res!.failure,
                  onRetry: () => ref.invalidate(lessonListProvider('')),
                ),
              ),
            )
          : ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(FeSpace.md),
              children: [
                FeListSkeleton(rows: 4, semanticLabel: l.lessonsTitle),
              ],
            );
    } else {
      // Hamma narsa bitta aylanadigan ro‘yxatda (tor ekran, katta shrift):
      // izoh → qidiruv → kurslar → kurs bo‘yicha mavzular (darslar tartibida).
      list = ListView(
        key: const Key('toral.list'),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: FeSpace.lg),
        children: [
          FeContentFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: FeSpace.sm),
                Text(
                  l.teacherOralIntro,
                  key: const Key('toral.intro'),
                  style: t.bodyMedium?.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: FeSpace.sm),
                TextField(
                  key: const Key('toral.search'),
                  controller: _search,
                  onChanged: (v) => setState(() => _query = v.trim()),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l.lessonsSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                ),
              ],
            ),
          ),
          if (groups.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: FeSpace.xs),
              child: FeContentFrame(
                child: Wrap(
                  key: const Key('toral.courses'),
                  spacing: FeSpace.xs,
                  runSpacing: FeSpace.xs,
                  children: [
                    _Chip(
                      key: const Key('toral.course.all'),
                      label: l.lessonsAllCourses,
                      selected: course == null,
                      onTap: () => setState(() => _course = null),
                    ),
                    for (final g in groups)
                      _Chip(
                        key: Key('toral.course.${g.course}'),
                        label: _courseLabel(g),
                        selected: course == g.course,
                        onTap: () => setState(() => _course = g.course),
                      ),
                  ],
                ),
              ),
            ),
          FeContentFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: FeSpace.lg),
                    child: FeEmptyState(
                      icon: Icons.slideshow_rounded,
                      body: _query.isEmpty
                          ? l.lessonsEmpty
                          : l.lessonsNoMatch(_query),
                    ),
                  ),
                for (final g in visible) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      top: FeSpace.md,
                      bottom: FeSpace.xxs,
                    ),
                    child: Semantics(
                      header: true,
                      child: Text(
                        g.course,
                        style: t.titleSmall?.copyWith(color: c.accent),
                      ),
                    ),
                  ),
                  for (final (i, s) in g.items.indexed)
                    CheckboxListTile(
                      key: Key('toral.topic.${s.topicId}'),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _selected.contains(s.topicId),
                      onChanged: (v) => setState(
                        () => v == true
                            ? _selected.add(s.topicId)
                            : _selected.remove(s.topicId),
                      ),
                      title: Text(
                        '${i + 1}. ${LessonGrouping.titleParts(s.title).main}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.oralExamStart)),
      body: list,
      // Tanlov va «Bilet tuzish» — doim ko‘rinadigan pastki panelda.
      bottomNavigationBar: Material(
        elevation: 3,
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          top: false,
          // Column(min): FeContentFrame ichidagi Align panelni butun ekran
          // balandligiga cho‘zmasin.
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FeContentFrame(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: FeSpace.xs),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selected.isEmpty
                                  ? l.teacherOralPickHint
                                  : l.teacherOralSelected(_selected.length),
                              key: const Key('toral.selected'),
                              style: t.labelLarge?.copyWith(
                                color: _selected.isEmpty
                                    ? c.textSecondary
                                    : c.textPrimary,
                              ),
                            ),
                          ),
                          if (_selected.isNotEmpty)
                            IconButton(
                              key: const Key('toral.clear'),
                              tooltip: l.teacherOralClearSelection,
                              onPressed: () => setState(_selected.clear),
                              icon: const Icon(Icons.close_rounded),
                            ),
                        ],
                      ),
                      const SizedBox(height: FeSpace.xxs),
                      FilledButton.icon(
                        key: const Key('toral.build'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: _selected.isEmpty
                            ? null
                            : () => context.push(
                                Routes.teacherOralTicket(
                                  topicSelectionKey(_selected),
                                ),
                              ),
                        icon: const Icon(Icons.confirmation_number_outlined),
                        label: Text(l.teacherOralBuild),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _courseLabel(LessonGroup g) => '${g.course} · ${g.items.length}';

String _bulletText(LessonBullet b) => '• ${b.text}';

class _Chip extends StatelessWidget {
  const _Chip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
  );
}

/// Bilet: tanlangan mavzulardan 5 savol, ustoz har biriga 0–20 ball qo‘yadi.
class TeacherOralExamScreen extends ConsumerStatefulWidget {
  const TeacherOralExamScreen({super.key, required this.selectionKey});

  /// [topicSelectionKey] — vergul bilan ajratilgan mavzu id’lari.
  final String selectionKey;

  @override
  ConsumerState<TeacherOralExamScreen> createState() =>
      _TeacherOralExamScreenState();
}

class _TeacherOralExamScreenState extends ConsumerState<TeacherOralExamScreen> {
  final _name = TextEditingController();

  String get _key => topicSelectionKey(
    widget.selectionKey.split(',').where((x) => x.trim().isNotEmpty),
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _draw(TeacherOralPool pool) async {
    _name.clear();
    await ref.read(teacherOralProvider.notifier).draw(_key, pool.perTopic);
  }

  Future<void> _save(TeacherOralPool pool) async {
    final l = AppLocalizations.of(context);
    final total = await ref
        .read(teacherOralProvider.notifier)
        .finish(pool.title);
    if (!mounted || total == null) return;
    _name.clear();
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.oralExamSaved(total))));
  }

  Future<void> _clearHistory() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.oralExamHistoryClear),
        content: Text(l.oralExamHistoryClearBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l.oralExamCancel),
          ),
          FilledButton(
            key: const Key('oral.clearConfirm'),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l.oralExamHistoryClear),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(teacherOralProvider.notifier).clearHistory();
    }
  }

  Widget _frame(List<Widget> children) => ListView(
    key: const Key('toral.ticketList'),
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    children: [
      FeContentFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(teacherOralPoolProvider(_key));
    final pool = async.value;
    final Widget body;
    if (pool == null) {
      body = async.hasError
          ? _frame([
              const SizedBox(height: FeSpace.lg),
              LessonFailureView(
                failure: null,
                onRetry: () => ref.invalidate(teacherOralPoolProvider(_key)),
              ),
            ])
          : _frame([
              const SizedBox(height: FeSpace.md),
              FeListSkeleton(rows: 4, semanticLabel: l.oralExamTitle),
            ]);
    } else if (pool.failure != null) {
      body = _frame([
        const SizedBox(height: FeSpace.lg),
        LessonFailureView(
          failure: pool.failure,
          onRetry: () => ref.invalidate(teacherOralPoolProvider(_key)),
        ),
      ]);
    } else if (pool.questions.isEmpty) {
      body = _frame([
        const SizedBox(height: FeSpace.lg),
        FeEmptyState(
          key: const Key('toral.noQuestions'),
          icon: Icons.quiz_outlined,
          body: l.teacherOralNoQuestions,
        ),
      ]);
    } else {
      body = _frame(_ticket(context, pool));
    }
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.oralExamTitle)),
      body: SafeArea(child: body),
    );
  }

  List<Widget> _ticket(BuildContext context, TeacherOralPool pool) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final st = ref.watch(teacherOralProvider);
    final ctl = ref.read(teacherOralProvider.notifier);
    final here = st.spec == teacherOralSpec && st.cat == _key;
    final ticket = here && st.hasTicket;
    final topicIds = [for (final d in pool.topics) d.topicId];
    final used = {
      for (final id in topicIds)
        for (final x in st.data.usedFor(teacherOralSpec, id))
          if (pool.questions.containsKey(x)) x,
    };
    final history = [
      for (final r in st.data.history)
        if (r.spec == teacherOralSpec && r.cat == _key) r,
    ];
    final titleOf = {for (final d in pool.topics) d.topicId: d.title};
    final many = pool.topics.length > 1;
    return [
      const SizedBox(height: FeSpace.sm),
      for (final d in pool.topics)
        Padding(
          padding: const EdgeInsets.only(bottom: FeSpace.xxs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.slideshow_rounded, size: 18, color: c.accent),
              const SizedBox(width: FeSpace.xs),
              Expanded(
                child: Text(
                  '${d.course} · ${LessonGrouping.titleParts(d.title).main}',
                  style: t.labelLarge?.copyWith(color: c.textSecondary),
                ),
              ),
            ],
          ),
        ),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          key: const Key('toral.changeTopics'),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.teacherOral),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text(l.teacherOralChangeTopics),
        ),
      ),
      Text(
        l.oralExamPool(used.length, pool.questions.length),
        key: const Key('oral.pool'),
        style: t.labelMedium?.copyWith(color: c.textSecondary),
      ),
      const SizedBox(height: FeSpace.sm),
      if (!ticket)
        FilledButton.icon(
          key: const Key('oral.draw'),
          onPressed: () => _draw(pool),
          icon: const Icon(Icons.confirmation_number_outlined),
          label: Text(l.oralExamNext),
        )
      else ...[
        Text(l.oralExamTicketNo(history.length + 1), style: t.titleLarge),
        if (st.poolReset)
          Padding(
            padding: const EdgeInsets.only(top: FeSpace.xxs),
            child: Text(
              l.oralExamPoolReset,
              key: const Key('oral.poolReset'),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
        const SizedBox(height: FeSpace.xs),
        TextField(
          key: const Key('oral.name'),
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person_outline),
            hintText: l.oralExamName,
          ),
          onChanged: ctl.setName,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
        ),
        const SizedBox(height: FeSpace.sm),
        for (var i = 0; i < st.questionIds.length; i++)
          if (pool.questions[st.questionIds[i]] case final q?)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.sm),
              child: OralTicketQuestionCard(
                index: i,
                text: q.text,
                caption: many
                    ? LessonGrouping.titleParts(titleOf[q.topicId] ?? '').main
                    : null,
                score: st.scores[i],
                onScore: (v) => ctl.setScore(i, v),
                answerKey: _SlideKey(question: q),
              ),
            ),
        const Divider(),
        Text(
          l.oralExamTotal(st.total),
          key: const Key('oral.total'),
          style: t.titleLarge,
        ),
        const SizedBox(height: FeSpace.xs),
        FilledButton.icon(
          key: const Key('oral.save'),
          onPressed: st.allScored ? () => _save(pool) : null,
          icon: const Icon(Icons.check),
          label: Text(l.oralExamSave),
        ),
        if (!st.allScored)
          Padding(
            padding: const EdgeInsets.only(top: FeSpace.xxs),
            child: Text(
              l.oralExamSaveHint,
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
      ],
      FeSectionHeader(l.oralExamHistory),
      if (history.isEmpty)
        Text(
          l.oralExamHistoryEmpty,
          key: const Key('oral.historyEmpty'),
          style: t.bodyMedium?.copyWith(color: c.textSecondary),
        ),
      for (final r in history.take(20))
        ListTile(
          key: Key('oral.history.${r.atMs}'),
          contentPadding: EdgeInsets.zero,
          title: Text(r.name.isEmpty ? l.oralExamNoName : r.name),
          subtitle: Text(_date(r.atMs)),
          trailing: Text(
            '${r.total} / $oralExamMaxTotal',
            style: t.titleMedium,
          ),
        ),
      const SizedBox(height: FeSpace.sm),
      Wrap(
        spacing: FeSpace.xs,
        runSpacing: FeSpace.xs,
        children: [
          OutlinedButton(
            key: const Key('oral.resetPool'),
            onPressed: used.isEmpty ? null : () => ctl.resetPool(topicIds),
            child: Text(l.oralExamResetPool),
          ),
          if (history.isNotEmpty)
            OutlinedButton(
              key: const Key('oral.clearHistory'),
              onPressed: _clearHistory,
              child: Text(l.oralExamHistoryClear),
            ),
        ],
      ),
      const SizedBox(height: FeSpace.sm),
      Text(
        l.oralExamDeviceNote,
        style: t.bodySmall?.copyWith(color: c.textSecondary),
      ),
      const SizedBox(height: FeSpace.xl),
    ];
  }

  static String _date(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year} '
        '${two(d.hour)}:${two(d.minute)}';
  }
}

/// Javob kaliti: slayd bandlari (asl matn) va manbasi.
class _SlideKey extends StatelessWidget {
  const _SlideKey({required this.question});

  final LessonOralQuestion question;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final src = lessonSourceLine(l, lessonSourceGroups(question.bullets));
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final b in question.bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xxs),
              child: Text(_bulletText(b), style: t.bodyMedium),
            ),
          if (src.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: FeSpace.xxs),
              child: Text(
                src,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ),
          Text(
            l.teacherOralKeyNote,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}
