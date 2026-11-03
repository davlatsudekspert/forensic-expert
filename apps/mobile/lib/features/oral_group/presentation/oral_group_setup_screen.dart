import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/oral_group.dart';
import '../../../app/routes.dart';
import '../../../app/teacher_oral.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_quiz/class_quiz_models.dart';
import '../../../domain/lessons/lesson_oral.dart';
import '../../../domain/oral_group/oral_group_models.dart';
import '../../../domain/oral_group/oral_group_tickets.dart';
import '../../class_quiz/presentation/class_quiz_widgets.dart'
    show ClassTeacherGate;
import '../../lessons/presentation/lesson_viewer_screen.dart'
    show LessonFailureView;
import '../../professional/presentation/professional_widgets.dart' show FeNote;
import 'oral_group_widgets.dart';

/// Guruh imtihoni: talabalar soni, tayyorlanish vaqti, «Boshlash» va faol
/// imtihonlar ro‘yxati. [selectionKey] bo‘sh bo‘lsa — faqat ro‘yxat.
class OralGroupSetupScreen extends StatelessWidget {
  const OralGroupSetupScreen({super.key, required this.selectionKey});

  final String selectionKey;

  @override
  Widget build(BuildContext context) =>
      ClassTeacherGate(child: _SetupBody(selectionKey: selectionKey));
}

class _SetupBody extends ConsumerStatefulWidget {
  const _SetupBody({required this.selectionKey});

  final String selectionKey;

  @override
  ConsumerState<_SetupBody> createState() => _SetupBodyState();
}

class _SetupBodyState extends ConsumerState<_SetupBody> {
  final _count = TextEditingController(
    text: '${OralGroupRules.defaultStudents}',
  );
  int _prepMin = 0;
  bool _busy = false;
  String? _error;
  String? _countError;

  String get _key => topicSelectionKey(
    widget.selectionKey.split(',').where((x) => x.trim().isNotEmpty),
  );

  @override
  void dispose() {
    _count.dispose();
    super.dispose();
  }

  int? get _n {
    final v = int.tryParse(_count.text.trim());
    if (v == null ||
        v < OralGroupRules.minStudents ||
        v > OralGroupRules.maxStudents) {
      return null;
    }
    return v;
  }

  void _step(int d) {
    final cur =
        int.tryParse(_count.text.trim()) ?? OralGroupRules.defaultStudents;
    final next = (cur + d).clamp(
      OralGroupRules.minStudents,
      OralGroupRules.maxStudents,
    );
    setState(() {
      _count.text = '$next';
      _countError = null;
    });
  }

  Future<void> _start(TeacherOralPool pool) async {
    final l = AppLocalizations.of(context);
    final n = _n;
    if (n == null) {
      setState(() => _countError = l.oralErrInvalidSettings);
      return;
    }
    final plan = buildOralGroupTickets(
      pools: pool.perTopic,
      count: n,
      rng: ref.read(teacherOralRandomProvider),
    );
    if (plan.tickets.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
      _countError = null;
    });
    final r = await ref
        .read(oralGroupServiceProvider)
        .createSession(
          title: pool.title.runes.length <= 300
              ? pool.title
              : String.fromCharCodes(pool.title.runes.take(300)),
          tickets: [
            for (final t in plan.tickets)
              [
                for (final id in t)
                  OralGroupQuestion(id: id, text: pool.questions[id]!.text),
              ],
          ],
          prepSeconds: _prepMin * 60,
        );
    if (!mounted) return;
    final s = r.value;
    if (s == null) {
      setState(() {
        _busy = false;
        _error = oralFailureText(l, r.failure!);
      });
      return;
    }
    ref.invalidate(oralGroupMySessionsProvider);
    context.pushReplacement(Routes.oralGroupHost(s.id));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final hasTopics = _key.isNotEmpty;
    final poolAsync = hasTopics
        ? ref.watch(teacherOralPoolProvider(_key))
        : null;
    final sessions =
        ref.watch(oralGroupMySessionsProvider).value?.value ??
        const <OralGroupSession>[];
    final open = [
      for (final s in sessions)
        if (s.isOpen) s,
    ];
    final done = [
      for (final s in sessions)
        if (!s.isOpen) s,
    ];

    final children = <Widget>[
      const SizedBox(height: FeSpace.sm),
      const OralGroupDemoBanner(),
      Text(
        l.oralGroupSetupIntro,
        key: const Key('oralgroup.intro'),
        style: t.bodyMedium?.copyWith(color: c.textSecondary),
      ),
      if (!hasTopics) ...[
        const SizedBox(height: FeSpace.sm),
        FeNote(
          key: const Key('oralgroup.noTopics'),
          icon: Icons.info_outline,
          text: l.oralGroupNoTopics,
        ),
      ] else
        ..._form(context, poolAsync!),
      if (open.isNotEmpty) ...[
        FeSectionHeader(l.oralGroupActiveSection),
        for (final s in open) _SessionCard(session: s),
      ],
      if (done.isNotEmpty) ...[
        FeSectionHeader(l.oralGroupFinishedSection),
        for (final s in done) _SessionCard(session: s),
      ],
      const SizedBox(height: FeSpace.xl),
    ];
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.oralGroupSetupTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('oralgroup.setupList'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _form(BuildContext context, AsyncValue<TeacherOralPool> async) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final pool = async.value;
    if (pool == null) {
      return [
        const SizedBox(height: FeSpace.md),
        if (async.hasError)
          LessonFailureView(
            failure: null,
            onRetry: () => ref.invalidate(teacherOralPoolProvider(_key)),
          )
        else
          FeListSkeleton(rows: 3, semanticLabel: l.oralGroupSetupTitle),
      ];
    }
    if (pool.failure != null) {
      return [
        const SizedBox(height: FeSpace.md),
        LessonFailureView(
          failure: pool.failure,
          onRetry: () => ref.invalidate(teacherOralPoolProvider(_key)),
        ),
      ];
    }
    if (pool.questions.isEmpty) {
      return [
        const SizedBox(height: FeSpace.md),
        FeEmptyState(
          key: const Key('oralgroup.noQuestions'),
          icon: Icons.quiz_outlined,
          body: l.teacherOralNoQuestions,
        ),
      ];
    }
    final available = pool.questions.length;
    final n = _n;
    final repeats =
        n != null && oralTicketsWillRepeat(available: available, count: n);
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
                  d.title,
                  style: t.labelLarge?.copyWith(color: c.textSecondary),
                ),
              ),
            ],
          ),
        ),
      Text(
        l.oralGroupAvailable(available),
        key: const Key('oralgroup.available'),
        style: t.labelMedium?.copyWith(color: c.textSecondary),
      ),
      const SizedBox(height: FeSpace.md),
      Text(l.oralGroupStudentsLabel, style: t.titleSmall),
      const SizedBox(height: FeSpace.xs),
      Row(
        children: [
          IconButton.filledTonal(
            key: const Key('oralgroup.dec'),
            tooltip: l.oralGroupStudentsDec,
            onPressed: () => _step(-1),
            icon: const Icon(Icons.remove),
          ),
          const SizedBox(width: FeSpace.xs),
          Expanded(
            child: TextField(
              key: const Key('oralgroup.count'),
              controller: _count,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 3,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() => _countError = null),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                counterText: '',
                helperText: l.oralGroupStudentsHelper,
                helperMaxLines: 3,
                errorText: _countError,
                errorMaxLines: 3,
              ),
            ),
          ),
          const SizedBox(width: FeSpace.xs),
          IconButton.filledTonal(
            key: const Key('oralgroup.inc'),
            tooltip: l.oralGroupStudentsInc,
            onPressed: () => _step(1),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      const SizedBox(height: FeSpace.md),
      Text(l.oralGroupPrepLabel, style: t.titleSmall),
      const SizedBox(height: FeSpace.xs),
      Wrap(
        key: const Key('oralgroup.prep'),
        alignment: WrapAlignment.start,
        spacing: FeSpace.xs,
        runSpacing: FeSpace.xs,
        children: [
          for (final m in OralGroupRules.prepChoicesMinutes)
            ChoiceChip(
              key: Key('oralgroup.prep.$m'),
              label: Text(m == 0 ? l.oralGroupPrepNone : l.oralGroupPrepMin(m)),
              selected: _prepMin == m,
              onSelected: (_) => setState(() => _prepMin = m),
            ),
        ],
      ),
      const SizedBox(height: FeSpace.xxs),
      Text(
        l.oralGroupPrepHint,
        style: t.bodySmall?.copyWith(color: c.textSecondary),
      ),
      if (repeats) ...[
        const SizedBox(height: FeSpace.sm),
        FeBanner(
          key: const Key('oralgroup.repeatNotice'),
          icon: Icons.info_outline,
          text: l.oralGroupRepeatNotice,
          tone: FeBannerTone.warning,
        ),
      ],
      if (_error != null) ...[
        const SizedBox(height: FeSpace.sm),
        Semantics(
          liveRegion: true,
          child: Text(
            _error!,
            key: const Key('oralgroup.error'),
            style: t.bodyMedium?.copyWith(color: c.danger),
          ),
        ),
      ],
      const SizedBox(height: FeSpace.md),
      FilledButton.icon(
        key: const Key('oralgroup.start'),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        onPressed: _busy ? null : () => _start(pool),
        icon: _busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.qr_code_2_rounded),
        label: Text(l.oralGroupStart),
      ),
    ];
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final OralGroupSession session;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: Key('oralgroup.session.${session.id}'),
        onTap: () => context.push(
          session.isOpen
              ? Routes.oralGroupHost(session.id)
              : Routes.oralGroupResults(session.id),
        ),
        child: Row(
          children: [
            Icon(
              session.isOpen ? Icons.podcasts : Icons.check_circle_outline,
              color: c.accent,
            ),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title.isEmpty ? l.oralGroupNoTitle : session.title,
                    style: t.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    l.oralGroupSessionLine(
                      ClassCode.display(session.code),
                      session.joined,
                      session.graded,
                    ),
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
