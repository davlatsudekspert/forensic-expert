import 'package:flutter/material.dart';
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
import '../../../domain/lessons/lesson_oral.dart';
import '../../../domain/oral_group/oral_group_models.dart';
import '../../assessment/presentation/oral_ticket_card.dart';
import '../../class_quiz/presentation/class_quiz_widgets.dart'
    show ClassTeacherGate;
import '../../teacher_oral/presentation/teacher_oral_screens.dart'
    show OralSlideKey;
import 'oral_group_widgets.dart';

/// Baholash: talaba ismi, bilet raqami, 5 savol kartasi (javob kaliti
/// mahalliy havzadan savol id bo‘yicha), 0–20 slayderlar, jami va «Saqlash».
class OralGroupGradeScreen extends StatelessWidget {
  const OralGroupGradeScreen({
    super.key,
    required this.sessionId,
    required this.participantId,
  });

  final String sessionId;
  final String participantId;

  @override
  Widget build(BuildContext context) => ClassTeacherGate(
    child: _GradeBody(sessionId: sessionId, participantId: participantId),
  );
}

class _GradeBody extends ConsumerStatefulWidget {
  const _GradeBody({required this.sessionId, required this.participantId});

  final String sessionId;
  final String participantId;

  @override
  ConsumerState<_GradeBody> createState() => _GradeBodyState();
}

class _GradeBodyState extends ConsumerState<_GradeBody> {
  List<int?>? _scores;
  OralGroupParticipant? _participant;
  bool _busy = false;

  /// Savol id’laridan mavzular kaliti (`<topic>#<slayd>`): kalit mahalliy
  /// havzadan topiladi — ilova qayta ochilsa ham ishlaydi.
  static String _poolKey(Iterable<OralGroupQuestion> qs) => topicSelectionKey({
    for (final q in qs)
      if (q.id.lastIndexOf('#') > 0) q.id.substring(0, q.id.lastIndexOf('#')),
  });

  Future<void> _save(OralGroupTeacherState st) async {
    final sc = _scores;
    if (sc == null || sc.any((x) => x == null) || _busy) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final r = await ref.read(oralGroupServiceProvider).grade(
      widget.sessionId,
      widget.participantId,
      [for (final x in sc) x!],
    );
    if (!mounted) return;
    setState(() => _busy = false);
    final total = r.value;
    if (total == null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(oralFailureText(l, r.failure!))));
      return;
    }
    ref.invalidate(oralGroupTeacherStateProvider(widget.sessionId));
    ref.invalidate(oralGroupMySessionsProvider);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.oralGroupSaved(total))));
    _leave();
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.oralGroupQueue(widget.sessionId));
    }
  }

  Future<void> _kick(OralGroupParticipant p) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.oralGroupKickTitle(p.name)),
        content: Text(l.oralGroupKickBody),
        actions: [
          TextButton(
            onPressed: () => c.pop(false),
            child: Text(l.oralGroupCancel),
          ),
          FilledButton(
            key: const Key('oralgroup.kickConfirm'),
            onPressed: () => c.pop(true),
            child: Text(l.oralGroupKick),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final r = await ref
        .read(oralGroupServiceProvider)
        .kick(widget.sessionId, p.id);
    if (!mounted) return;
    if (!r.ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(oralFailureText(l, r.failure!))),
      );
      return;
    }
    ref.invalidate(oralGroupTeacherStateProvider(widget.sessionId));
    ref.invalidate(oralGroupMySessionsProvider);
    _leave();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final async = ref.watch(oralGroupTeacherStateProvider(widget.sessionId));
    final st = async.value?.value;
    final p = st?.participant(widget.participantId);
    final ticket = p == null ? null : st?.ticket(p.ticketNo);
    if (p != null) _participant = p;

    Widget frame(List<Widget> children) => ListView(
      key: const Key('oralgroup.gradeList'),
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

    final Widget body;
    if (st == null) {
      final f = async.value?.failure;
      body = Center(
        child: f != null
            ? Padding(
                padding: const EdgeInsets.all(FeSpace.lg),
                child: Text(oralFailureText(l, f), textAlign: TextAlign.center),
              )
            : const CircularProgressIndicator(),
      );
    } else if (p == null || ticket == null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(FeSpace.lg),
          child: FeEmptyState(
            key: const Key('oralgroup.gradeGone'),
            icon: Icons.person_off_outlined,
            body: l.oralErrNotFound,
          ),
        ),
      );
    } else {
      // Boshlang‘ich ballar: avval baholangan bo‘lsa — shular, aks holda bo‘sh.
      _scores ??= [
        for (var i = 0; i < ticket.questions.length; i++)
          (p.scores != null && i < p.scores!.length) ? p.scores![i] : null,
      ];
      final sc = _scores!;
      final poolKey = _poolKey(ticket.questions);
      final pool = poolKey.isEmpty
          ? null
          : ref.watch(teacherOralPoolProvider(poolKey)).value;
      final poolDone = poolKey.isEmpty
          ? true
          : ref.watch(teacherOralPoolProvider(poolKey)).hasValue;
      final total = sc.fold<int>(0, (a, b) => a + (b ?? 0));
      final all = sc.every((x) => x != null);
      body = frame([
        const SizedBox(height: FeSpace.sm),
        Text(
          p.name,
          key: const Key('oralgroup.gradeName'),
          style: t.headlineSmall,
        ),
        Text(
          l.oralExamTicketNo(p.ticketNo),
          key: const Key('oralgroup.gradeTicket'),
          style: t.titleMedium?.copyWith(color: c.textSecondary),
        ),
        OralLeaveFlag(participant: p),
        if (p.isGraded)
          Padding(
            padding: const EdgeInsets.only(top: FeSpace.xxs),
            child: Text(
              l.oralGroupGradedBefore,
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
        const SizedBox(height: FeSpace.sm),
        for (var i = 0; i < ticket.questions.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.sm),
            child: OralTicketQuestionCard(
              index: i,
              text: ticket.questions[i].text,
              score: sc[i],
              onScore: (v) => setState(() {
                final next = [...sc];
                next[i] = v.clamp(0, OralGroupRules.maxScore);
                _scores = next;
              }),
              answerKey: _keyFor(l, t, c, pool, poolDone, ticket.questions[i]),
            ),
          ),
        const Divider(),
        Text(
          l.oralExamTotal(total),
          key: const Key('oralgroup.gradeTotal'),
          style: t.titleLarge,
        ),
        const SizedBox(height: FeSpace.xs),
        FilledButton.icon(
          key: const Key('oralgroup.save'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: all && !_busy ? () => _save(st) : null,
          icon: const Icon(Icons.check),
          label: Text(l.oralGroupSave),
        ),
        if (!all)
          Padding(
            padding: const EdgeInsets.only(top: FeSpace.xxs),
            child: Text(
              l.oralExamSaveHint,
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
        const SizedBox(height: FeSpace.xl),
      ]);
    }
    final who = _participant;
    return Scaffold(
      appBar: AppBar(
        title: FeAppBarTitle(l.oralGroupGradeTitle),
        actions: [
          if (who != null)
            PopupMenuButton<String>(
              key: const Key('oralgroup.menu'),
              onSelected: (_) => _kick(who),
              itemBuilder: (c) => [
                PopupMenuItem<String>(
                  key: const Key('oralgroup.kick'),
                  value: 'kick',
                  child: Text(l.oralGroupKick),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }

  Widget _keyFor(
    AppLocalizations l,
    TextTheme t,
    FeColorTokens c,
    TeacherOralPool? pool,
    bool poolDone,
    OralGroupQuestion q,
  ) {
    final lq = pool?.questions[q.id];
    if (lq != null) return OralSlideKey(question: lq);
    if (!poolDone) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: Text(
        l.oralGroupKeyMissing,
        key: const Key('oralgroup.keyMissing'),
        style: t.bodySmall?.copyWith(color: c.textSecondary),
      ),
    );
  }
}
