import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/class_quiz.dart'
    show ClassScreenAwake, classFileShareProvider, classScreenAwakeProvider;
import '../../../app/oral_group.dart';
import '../../../app/plan.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_quiz/class_quiz_models.dart';
import '../../../domain/oral_group/oral_group_models.dart';
import '../../../domain/plan/plan_models.dart';
import '../../class_quiz/presentation/class_quiz_widgets.dart'
    show ClassCodeBanner, ClassQr, ClassTeacherGate;
import '../../pro/presentation/pro_gate.dart' show openPro;
import 'oral_group_widgets.dart';

/// Stream natijasidan oxirgi yaxshi qiymatni saqlaydi: bitta polling xatosi
/// ekranni xato holatiga almashtirmasin.
typedef _TeacherAsync = AsyncValue<ClassResult<OralGroupTeacherState>>;

OralGroupTeacherState? _stateOf(_TeacherAsync a) => a.value?.value;

// =========================================================== DOSKA

/// Doska (proyektor): katta QR + 6 xonali kod, «Qo‘shildi: x / N» va biletlar
/// panjarasi. BALL KO‘RSATILMAYDI.
class OralGroupHostScreen extends StatelessWidget {
  const OralGroupHostScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) => ClassTeacherGate(
    child: Theme(
      data: FeThemeBuilder.dark(),
      child: _HostBody(sessionId: sessionId),
    ),
  );
}

class _HostBody extends ConsumerStatefulWidget {
  const _HostBody({required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<_HostBody> createState() => _HostBodyState();
}

class _HostBodyState extends ConsumerState<_HostBody> {
  OralGroupTeacherState? _last;
  bool _busy = false;
  late final ClassScreenAwake _awake;

  @override
  void initState() {
    super.initState();
    _awake = ref.read(classScreenAwakeProvider);
    _awake.enable();
  }

  @override
  void dispose() {
    _awake.disable();
    super.dispose();
  }

  Future<void> _finish() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.oralGroupFinishTitle),
        content: Text(l.oralGroupFinishBody),
        actions: [
          TextButton(
            onPressed: () => c.pop(false),
            child: Text(l.oralGroupCancel),
          ),
          FilledButton(
            key: const Key('oralgroup.finishConfirm'),
            onPressed: () => c.pop(true),
            child: Text(l.oralGroupFinish),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final r = await ref.read(oralGroupServiceProvider).finish(widget.sessionId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!r.ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(oralFailureText(l, r.failure!))));
    }
    ref.invalidate(oralGroupTeacherStateProvider(widget.sessionId));
    ref.invalidate(oralGroupMySessionsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(oralGroupTeacherStateProvider(widget.sessionId));
    final fresh = _stateOf(async);
    if (fresh != null) _last = fresh;
    final st = _last;
    final Widget body;
    if (st == null) {
      final f = async.value?.failure;
      body = f != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(FeSpace.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      oralFailureText(l, f),
                      key: const Key('oralgroup.hostError'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: FeSpace.sm),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(
                        oralGroupTeacherStateProvider(widget.sessionId),
                      ),
                      child: Text(l.classRetry),
                    ),
                  ],
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator());
    } else {
      body = _Board(
        state: st,
        busy: _busy,
        onQueue: () => context.push(Routes.oralGroupQueue(widget.sessionId)),
        onResults: () =>
            context.push(Routes.oralGroupResults(widget.sessionId)),
        onFinish: _finish,
      );
    }
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.oralGroupSetupTitle)),
      body: SafeArea(child: body),
    );
  }
}

class _Board extends ConsumerWidget {
  const _Board({
    required this.state,
    required this.busy,
    required this.onQueue,
    required this.onResults,
    required this.onFinish,
  });

  final OralGroupTeacherState state;
  final bool busy;
  final VoidCallback onQueue;
  final VoidCallback onResults;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final s = state.session;
    final link = OralGroupLink.joinLink(s.code);
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 720;
    final qr = min(wide ? 260.0 : 220.0, size.shortestSide * 0.6);

    final join = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.oralGroupHostJoinHint,
          textAlign: TextAlign.center,
          style: t.titleMedium?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: FeSpace.sm),
        ClassCodeBanner(code: s.code, fontSize: 56),
        const SizedBox(height: FeSpace.sm),
        ClassQr(data: link.toString(), size: qr),
        const SizedBox(height: FeSpace.xs),
        SelectableText(
          link.toString(),
          key: const Key('oralgroup.joinLink'),
          textAlign: TextAlign.center,
          maxLines: 2,
          style: t.bodySmall?.copyWith(color: const Color(0xFFC9D2E0)),
        ),
      ],
    );

    final people = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.oralGroupJoinedCount(state.participants.length, s.ticketCount),
          key: const Key('oralgroup.joinedCount'),
          style: t.headlineSmall?.copyWith(
            color: FeBrand.goldOnDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!s.isOpen) ...[
          const SizedBox(height: FeSpace.xs),
          FeBanner(
            key: const Key('oralgroup.finishedBanner'),
            icon: Icons.check_circle_outline,
            text: l.oralGroupFinishedBanner,
          ),
        ],
        const SizedBox(height: FeSpace.sm),
        _TicketGrid(state: state),
        const SizedBox(height: FeSpace.md),
        FilledButton.icon(
          key: const Key('oralgroup.queueButton'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: onQueue,
          icon: const Icon(Icons.format_list_numbered_rounded),
          label: Text(l.oralGroupQueue),
        ),
        const SizedBox(height: FeSpace.xs),
        OutlinedButton.icon(
          key: const Key('oralgroup.resultsButton'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: onResults,
          icon: const Icon(Icons.fact_check_outlined),
          label: Text(l.oralGroupResults),
        ),
        if (s.isOpen) ...[
          const SizedBox(height: FeSpace.xs),
          OutlinedButton.icon(
            key: const Key('oralgroup.finishButton'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: busy ? null : onFinish,
            icon: const Icon(Icons.flag_outlined),
            label: Text(l.oralGroupFinish),
          ),
        ],
        const SizedBox(height: FeSpace.xl),
      ],
    );

    if (wide) {
      return Padding(
        padding: const EdgeInsets.all(FeSpace.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 340,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: join,
              ),
            ),
            const SizedBox(width: FeSpace.md),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: people,
              ),
            ),
          ],
        ),
      );
    }
    return ListView(
      key: const Key('oralgroup.hostList'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(FeSpace.md),
      children: [
        join,
        const SizedBox(height: FeSpace.md),
        people,
      ],
    );
  }
}

/// Biletlar panjarasi: bo‘sh / ism / tayyor / baholandi. Ball yo‘q.
class _TicketGrid extends StatelessWidget {
  const _TicketGrid({required this.state});

  final OralGroupTeacherState state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final cols = w < 380 ? 2 : (w < 560 ? 3 : 4);
        const gap = FeSpace.xs;
        final tile = (w - gap * (cols - 1)) / cols;
        return Wrap(
          key: const Key('oralgroup.grid'),
          alignment: WrapAlignment.start,
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var no = 1; no <= state.session.ticketCount; no++)
              SizedBox(
                width: tile,
                child: _TicketTile(
                  no: no,
                  participant: state.participantByTicket(no),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TicketTile extends StatelessWidget {
  const _TicketTile({required this.no, required this.participant});

  final int no;
  final OralGroupParticipant? participant;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final p = participant;
    final (label, color) = switch (p) {
      null => (l.oralGroupStatusFree, c.textSecondary),
      OralGroupParticipant(isGraded: true) => (
        l.oralGroupStatusGraded,
        c.verified,
      ),
      OralGroupParticipant(isReady: true) => (l.oralGroupStatusReady, c.accent),
      _ => (l.oralGroupStatusJoined, c.textPrimary),
    };
    return Semantics(
      container: true,
      label: [l.oralGroupTile(no), if (p != null) p.name, label].join(', '),
      child: ExcludeSemantics(
        child: Container(
          key: Key('oralgroup.tile.$no'),
          padding: const EdgeInsets.symmetric(
            horizontal: FeSpace.xs,
            vertical: FeSpace.xs,
          ),
          decoration: BoxDecoration(
            color: p == null
                ? Colors.transparent
                : color.withValues(alpha: 0.14),
            border: Border.all(
              color: p == null ? c.border : color.withValues(alpha: 0.7),
            ),
            borderRadius: BorderRadius.circular(FeRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.oralGroupTile(no),
                style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                p?.name ?? '—',
                key: Key('oralgroup.tileName.$no'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.bodyMedium,
              ),
              Text(
                label,
                key: Key('oralgroup.tileStatus.$no'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.labelMedium?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================== NAVBAT

/// Navbat (faqat ustoz): tayyorlar (tayyor bo‘lgan vaqt bilan), keyin
/// qo‘shilganlar, oxirida baholanganlar (jami bilan).
class OralGroupQueueScreen extends StatelessWidget {
  const OralGroupQueueScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) =>
      ClassTeacherGate(child: _QueueBody(sessionId: sessionId));
}

class _QueueBody extends ConsumerStatefulWidget {
  const _QueueBody({required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<_QueueBody> createState() => _QueueBodyState();
}

class _QueueBodyState extends ConsumerState<_QueueBody> {
  OralGroupTeacherState? _last;
  bool _busy = false;

  Future<void> _open(OralGroupParticipant p) async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!p.isCalled && !p.isGraded) {
      setState(() => _busy = true);
      final r = await ref
          .read(oralGroupServiceProvider)
          .call(widget.sessionId, p.id);
      if (!mounted) return;
      setState(() => _busy = false);
      if (!r.ok) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(oralFailureText(l, r.failure!))),
          );
        ref.invalidate(oralGroupTeacherStateProvider(widget.sessionId));
        return;
      }
      ref.invalidate(oralGroupTeacherStateProvider(widget.sessionId));
    }
    if (!mounted) return;
    await context.push(Routes.oralGroupGrade(widget.sessionId, p.id));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final async = ref.watch(oralGroupTeacherStateProvider(widget.sessionId));
    final fresh = _stateOf(async);
    if (fresh != null) _last = fresh;
    final st = _last;
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
    } else {
      final ps = st.participants;
      final ready = [
        for (final p in ps)
          if (!p.isGraded && p.isReady) p,
      ];
      final joined = [
        for (final p in ps)
          if (!p.isGraded && !p.isReady) p,
      ];
      final graded = [
        for (final p in ps)
          if (p.isGraded) p,
      ];
      body = ListView(
        key: const Key('oralgroup.queueList'),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          FeContentFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (ps.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: FeSpace.lg),
                    child: FeEmptyState(
                      key: const Key('oralgroup.queueEmpty'),
                      icon: Icons.people_outline,
                      body: l.oralGroupQueueEmpty,
                    ),
                  ),
                if (ready.isNotEmpty) ...[
                  FeSectionHeader(l.oralGroupSectionReady(ready.length)),
                  for (final p in ready) _row(p, t, c, l),
                ],
                if (joined.isNotEmpty) ...[
                  FeSectionHeader(l.oralGroupSectionJoined(joined.length)),
                  for (final p in joined) _row(p, t, c, l),
                ],
                if (graded.isNotEmpty) ...[
                  FeSectionHeader(l.oralGroupSectionGraded(graded.length)),
                  for (final p in graded) _row(p, t, c, l),
                ],
                const SizedBox(height: FeSpace.xl),
              ],
            ),
          ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.oralGroupQueueTitle)),
      body: SafeArea(child: body),
    );
  }

  Widget _row(
    OralGroupParticipant p,
    TextTheme t,
    FeColorTokens c,
    AppLocalizations l,
  ) {
    final sub = [
      l.oralExamTicketNo(p.ticketNo),
      if (p.readyAt != null && !p.isGraded)
        l.oralGroupReadyAt(oralHm(p.readyAt!)),
      if (p.isCalled && !p.isGraded) l.oralGroupCalledMark,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: Key('oralgroup.row.${p.id}'),
        onTap: () => _open(p),
        child: Row(
          children: [
            Icon(
              p.isGraded
                  ? Icons.check_circle_outline
                  : (p.isReady
                        ? Icons.record_voice_over_outlined
                        : Icons.hourglass_empty_rounded),
              color: p.isGraded ? c.verified : c.accent,
            ),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: t.titleSmall),
                  Text(
                    sub,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                  if (p.isGraded)
                    Text(
                      '${p.total} / $_max',
                      key: Key('oralgroup.rowTotal.${p.id}'),
                      style: t.titleSmall,
                    ),
                  OralLeaveFlag(participant: p),
                ],
              ),
            ),
            const SizedBox(width: FeSpace.xs),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

const _max = OralGroupRules.questionsPerTicket * OralGroupRules.maxScore;

// =========================================================== NATIJALAR

/// Natijalar (faqat ustoz): talabalar jami ballari va CSV.
class OralGroupResultsScreen extends StatelessWidget {
  const OralGroupResultsScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) =>
      ClassTeacherGate(child: _ResultsBody(sessionId: sessionId));
}

class _ResultsBody extends ConsumerWidget {
  const _ResultsBody({required this.sessionId});

  final String sessionId;

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    OralGroupTeacherState st,
  ) async {
    // Natijalar CSV — «Guruh testi» natijalari bilan bir xil Pro qoidasi.
    if (!ref.read(proAllowedProvider(ProFeature.resultsCsv))) {
      openPro(context, Plan.teacher);
      return;
    }
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(classFileShareProvider)
          .shareCsv(
            fileName: OralGroupCsv.fileName(st.session.code, DateTime.now()),
            content: OralGroupCsv.build(
              st.participants,
              nameLabel: l.oralGroupCsvName,
              ticketLabel: l.oralGroupCsvTicket,
              totalLabel: l.oralGroupCsvTotal,
              questionLabel: l.oralGroupCsvQuestion,
            ),
            subject: l.oralGroupResultsTitle,
          );
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l.classErrServer)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final async = ref.watch(oralGroupTeacherStateProvider(sessionId));
    final st = _stateOf(async);
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
    } else {
      final rows = [...st.participants]
        ..sort((a, b) => a.ticketNo.compareTo(b.ticketNo));
      body = ListView(
        key: const Key('oralgroup.resultsList'),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          FeContentFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: FeSpace.sm),
                if (rows.isEmpty)
                  FeEmptyState(
                    key: const Key('oralgroup.resultsEmpty'),
                    icon: Icons.people_outline,
                    body: l.oralGroupResultsEmpty,
                  ),
                for (final p in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: FeSpace.xs),
                    child: FeCard(
                      key: Key('oralgroup.result.${p.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: t.titleSmall),
                          Text(
                            l.oralExamTicketNo(p.ticketNo),
                            style: t.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                          Text(
                            p.isGraded
                                ? '${p.total} / $_max'
                                : l.oralGroupNotGraded,
                            key: Key('oralgroup.resultTotal.${p.id}'),
                            style: p.isGraded
                                ? t.titleSmall
                                : t.bodySmall?.copyWith(color: c.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: FeSpace.sm),
                OutlinedButton.icon(
                  key: const Key('oralgroup.export'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: rows.isEmpty
                      ? null
                      : () => _export(context, ref, st),
                  icon: const Icon(Icons.ios_share_rounded),
                  label: Text(l.oralGroupExport),
                ),
                const SizedBox(height: FeSpace.xl),
              ],
            ),
          ),
        ],
      );
    }
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.oralGroupResultsTitle)),
      body: SafeArea(child: body),
    );
  }
}
