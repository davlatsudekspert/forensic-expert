import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/class_groups.dart';
import '../../../app/class_quiz.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_groups/class_groups_models.dart';
import '../../class_quiz/presentation/class_hardest_screen.dart'
    show openGroupHardestDiscussion;
import '../../class_quiz/presentation/class_quiz_widgets.dart'
    show ClassQr, ClassReconnectingBar;
import '../../professional/presentation/professional_widgets.dart' show FeNote;
import 'group_widgets.dart';

/// Oxirgi yaxshi holatni ushlab turadigan polling: bitta xato ekranni xato
/// sahifasiga almashtirmaydi — «Aloqa tiklanmoqda…» belgisi chiqadi.
class _BoardCache {
  GroupBoard? last;

  (GroupBoard?, GroupFailure?, bool) read(
    AsyncValue<GroupCall<GroupBoard>> async,
  ) {
    final fresh = async.value?.value;
    final failure = async.value?.failure;
    if (fresh != null) last = fresh;
    final fatal =
        failure == GroupFailure.forbidden ||
        failure == GroupFailure.notSignedIn;
    final d = fresh ?? (fatal ? null : last);
    return (d, failure, fresh == null && d != null && failure != null);
  }
}

/// «Testni yopish»: tasdiq → server → doska/guruh yangilanadi. Ikkala doskada
/// (telefon paneli va katta ekran) bir xil.
Future<void> confirmAndCloseGroupTest(
  BuildContext context,
  WidgetRef ref, {
  required String groupId,
  required String assignmentId,
}) async {
  final l = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(l.grpCloseTitle),
      content: Text(l.grpCloseBody),
      actions: [
        TextButton(onPressed: () => c.pop(false), child: Text(l.grpCancel)),
        FilledButton(
          key: const Key('grp.closeYes'),
          onPressed: () => c.pop(true),
          child: Text(l.grpCloseAction),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  final r = await ref
      .read(classGroupsServiceProvider)
      .closeAssignment(assignmentId);
  if (!r.ok && context.mounted) {
    messenger.showSnackBar(
      SnackBar(content: Text(groupFailureText(l, r.failure!))),
    );
  }
  ref.invalidate(groupBoardProvider(assignmentId));
  ref.invalidate(groupDetailProvider(groupId));
}

/// «Qiyin savollar» bloki: test yopilgach eng ko‘p xato qilingan savollar
/// muhokamasiga o‘tadi; yopilmaguncha izoh.
class GroupHardestBlock extends StatelessWidget {
  const GroupHardestBlock({
    super.key,
    required this.assignment,
    this.onDark = false,
  });

  final GroupAssignment assignment;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final over = assignment.isOver;
    final muted = onDark ? Colors.white70 : c.textSecondary;
    return Container(
      key: const Key('grp.hardest.block'),
      padding: const EdgeInsets.all(FeSpace.md),
      decoration: BoxDecoration(
        color: onDark ? Colors.white10 : c.accentContainer,
        borderRadius: BorderRadius.circular(FeRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_alt_outlined,
                color: onDark ? FeBrand.goldOnDark : c.accent,
              ),
              const SizedBox(width: FeSpace.xs),
              Expanded(
                child: Text(
                  l.grpHardestTitle,
                  style: t.titleSmall?.copyWith(
                    color: onDark ? Colors.white : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FeSpace.xxs),
          Text(
            over ? l.grpHardestBody : l.grpHardestLocked,
            key: const Key('grp.hardest.text'),
            style: t.bodySmall?.copyWith(color: muted),
          ),
          if (over) ...[
            const SizedBox(height: FeSpace.xs),
            FilledButton.icon(
              key: const Key('grp.hardest.open'),
              onPressed: () => openGroupHardestDiscussion(
                context,
                assignmentId: assignment.id,
              ),
              icon: const Icon(Icons.forum_outlined),
              label: Text(l.grpHardestOpen),
            ),
          ],
        ],
      ),
    );
  }
}

/// Ustozning jonli paneli (telefon): bitta QR (hammaga bir xil), har talaba
/// qatori «qo‘shildi → yechmoqda → tugatdi + ball», katta ekran, talaba
/// ko‘rinishida sinash va testni yopish.
class TeacherAssignmentScreen extends ConsumerStatefulWidget {
  const TeacherAssignmentScreen({
    super.key,
    required this.groupId,
    required this.assignmentId,
  });

  final String groupId;
  final String assignmentId;

  @override
  ConsumerState<TeacherAssignmentScreen> createState() =>
      _TeacherAssignmentState();
}

class _TeacherAssignmentState extends ConsumerState<TeacherAssignmentScreen> {
  final _board = _BoardCache();
  bool _busy = false;

  Future<void> _close() async {
    setState(() => _busy = true);
    await confirmAndCloseGroupTest(
      context,
      ref,
      groupId: widget.groupId,
      assignmentId: widget.assignmentId,
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final (d, failure, reconnecting) = _board.read(
      ref.watch(groupBoardProvider(widget.assignmentId)),
    );

    final List<Widget> body;
    if (d != null) {
      final a = d.assignment;
      final link = GroupCode.link(
        d.group.code ?? '',
        assignmentId: a.id,
      ).toString();
      body = [
        Text(
          a.topicTitle,
          style: t.titleLarge,
          key: const Key('grp.liveTitle'),
        ),
        const SizedBox(height: FeSpace.xxs),
        Text(
          groupAssignmentLine(context, l, a),
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: FeSpace.md),
        FeCard(
          key: const Key('grp.testQr'),
          child: Row(
            children: [
              ClassQr(data: link, size: 120),
              const SizedBox(width: FeSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.grpTestQrTitle, style: t.titleSmall),
                    const SizedBox(height: FeSpace.xxs),
                    GroupCodeText(code: d.group.code ?? '', fontSize: 22),
                    const SizedBox(height: FeSpace.xxs),
                    Text(
                      l.grpTestQrHint,
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: FeSpace.sm),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                key: const Key('grp.bigScreen'),
                onPressed: () =>
                    context.push(Routes.groupBoard(widget.groupId, a.id)),
                icon: const Icon(Icons.cast),
                label: Text(l.grpBigScreen),
              ),
            ),
            const SizedBox(width: FeSpace.xs),
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('grp.preview'),
                onPressed: () =>
                    context.push(Routes.groupPreview(widget.groupId, a.id)),
                icon: const Icon(Icons.visibility_outlined),
                label: Text(l.grpPreviewShort),
              ),
            ),
          ],
        ),
        const SizedBox(height: FeSpace.xs),
        // Yopish tugmasi tepada — ro‘yxat uzun bo‘lsa ham va suzuvchi menyu
        // ostida qolmaydi.
        if (!a.closed)
          OutlinedButton.icon(
            key: const Key('grp.closeTest'),
            onPressed: _busy ? null : _close,
            icon: const Icon(Icons.stop_circle_outlined),
            label: Text(l.grpCloseAction),
          )
        else
          FeBanner(
            key: const Key('grp.closedBanner'),
            icon: Icons.check_circle_outline,
            text: l.grpClosedBanner,
          ),
        const SizedBox(height: FeSpace.sm),
        GroupHardestBlock(assignment: a),
        const SizedBox(height: FeSpace.sm),
        Text(
          l.grpCounts(
            d.count(BoardState.joined),
            d.count(BoardState.solving),
            d.count(BoardState.finished),
          ),
          key: const Key('grp.counts'),
          style: t.titleSmall,
        ),
        const SizedBox(height: FeSpace.xs),
        if (d.rows.isEmpty)
          FeEmptyState(
            icon: Icons.groups_outlined,
            body: l.grpMembersEmpty,
            compact: true,
          ),
        for (final x in d.ranked)
          _LiveRow(key: Key('grp.row.${x.row.memberId}'), item: x),
        const SizedBox(height: FeSpace.md),
        FeNote(
          icon: Icons.lock_clock_outlined,
          text: groupRevealText(context, l, a),
        ),
      ];
    } else if (failure != null) {
      body = [
        FeEmptyState(
          key: const Key('grp.liveError'),
          icon: Icons.cloud_off_outlined,
          body: groupFailureText(l, failure),
          actionLabel: l.grpRetry,
          onAction: () =>
              ref.invalidate(groupBoardProvider(widget.assignmentId)),
        ),
      ];
    } else {
      body = [FeListSkeleton(semanticLabel: l.grpTitle)];
    }

    return Scaffold(
      appBar: AppBar(
        title: FeAppBarTitle(l.grpLiveTitle),
        actions: [
          // Har doim ko‘rinadi (kichik ekranda ham, suzuvchi menyu ostida emas).
          if (d != null && !d.assignment.closed)
            IconButton(
              key: const Key('grp.closeTestBar'),
              tooltip: l.grpCloseAction,
              icon: const Icon(Icons.stop_circle_outlined),
              onPressed: _busy ? null : _close,
            ),
        ],
      ),
      body: Column(
        children: [
          if (reconnecting) const ClassReconnectingBar(),
          Expanded(
            child: ListView(
              key: const Key('grp.liveList'),
              padding: EdgeInsets.only(
                top: FeSpace.xs,
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
        ],
      ),
    );
  }
}

class _LiveRow extends StatelessWidget {
  const _LiveRow({super.key, required this.item});

  final RankedBoardRow item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final row = item.row;
    final finished = row.state == BoardState.finished;
    final spent = row.spent;
    final tabular = t.titleSmall?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: FeSpace.xs),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Semantics(
              label: item.rank == null ? null : l.grpRankSpoken(item.rank!),
              excludeSemantics: item.rank != null,
              child: Text(
                item.rank?.toString() ?? FeGlyphs.emDash,
                key: Key('grp.rank.${row.memberId}'),
                style: t.titleSmall?.copyWith(
                  color: item.rank != null && item.rank! <= 3
                      ? c.accent
                      : c.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.nickname,
                  style: t.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                GroupStatePill(state: row.state),
              ],
            ),
          ),
          if (finished) ...[
            Text(
              '${row.score}/${row.total}',
              key: Key('grp.score.${row.memberId}'),
              style: tabular,
            ),
            SizedBox(
              width: 56,
              child: Text(
                spent == null ? '' : groupSpentText(spent),
                key: Key('grp.time.${row.memberId}'),
                textAlign: TextAlign.end,
                style: t.bodyMedium?.copyWith(
                  color: c.textSecondary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// «Katta ekran» (televizor/proyektor): to‘q fon, 16:9 ga moslangan; chapda
/// QR + kod, o‘ngda har talaba qatori. Ekran o‘chmaydi, telefonda gorizontal
/// holat taklif qilinadi. Faqat taxalluslar (email/ism yo‘q).
class GroupBoardScreen extends ConsumerStatefulWidget {
  const GroupBoardScreen({
    super.key,
    required this.groupId,
    required this.assignmentId,
  });

  final String groupId;
  final String assignmentId;

  @override
  ConsumerState<GroupBoardScreen> createState() => _GroupBoardScreenState();
}

class _GroupBoardScreenState extends ConsumerState<GroupBoardScreen> {
  final _board = _BoardCache();
  late final ClassScreenAwake _awake;
  late final ClassOrientationControl _orientation;
  bool _forced = false;

  @override
  void initState() {
    super.initState();
    _awake = ref.read(classScreenAwakeProvider);
    _orientation = ref.read(classOrientationControlProvider);
    _awake.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) => _askLandscape());
  }

  @override
  void dispose() {
    _awake.disable();
    if (_forced) _orientation.restore();
    super.dispose();
  }

  Future<void> _askLandscape() async {
    if (!mounted || !ref.read(classLandscapePromptEnabledProvider)) return;
    final mq = MediaQuery.of(context);
    if (mq.size.shortestSide >= 600 || mq.orientation != Orientation.portrait) {
      return;
    }
    final l = AppLocalizations.of(context);
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.classLandscapePrompt),
        actions: [
          TextButton(
            onPressed: () => c.pop(false),
            child: Text(l.classLandscapeNo),
          ),
          FilledButton(
            onPressed: () => c.pop(true),
            child: Text(l.classLandscapeYes),
          ),
        ],
      ),
    );
    if (yes == true) {
      _forced = true;
      await _orientation.landscape();
    }
  }

  Future<void> _close() => confirmAndCloseGroupTest(
    context,
    ref,
    groupId: widget.groupId,
    assignmentId: widget.assignmentId,
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (d, failure, reconnecting) = _board.read(
      ref.watch(groupBoardProvider(widget.assignmentId)),
    );
    final Widget body;
    if (d != null) {
      body = _BigBoard(d: d);
    } else if (failure != null) {
      body = Center(
        child: Text(
          groupFailureText(l, failure),
          style: const TextStyle(color: Colors.white),
        ),
      );
    } else {
      body = const Center(child: CircularProgressIndicator());
    }
    return Theme(
      data: FeThemeBuilder.dark(),
      child: Scaffold(
        backgroundColor: FeBrand.navy,
        appBar: AppBar(
          backgroundColor: FeBrand.navy,
          foregroundColor: Colors.white,
          toolbarHeight: 44,
          title: Text(d?.assignment.topicTitle ?? l.grpBigScreen),
          actions: [
            if (d != null && !d.assignment.closed)
              Padding(
                padding: const EdgeInsets.only(right: FeSpace.xs),
                child: OutlinedButton.icon(
                  key: const Key('grp.board.close'),
                  onPressed: _close,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: Text(l.grpCloseAction),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                ),
              )
            else if (d != null)
              Padding(
                padding: const EdgeInsets.only(right: FeSpace.sm),
                child: Center(
                  child: Text(
                    l.grpBoardClosed,
                    key: const Key('grp.board.closed'),
                    style: const TextStyle(color: FeBrand.goldOnDark),
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (reconnecting) const ClassReconnectingBar(onDark: true),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigBoard extends StatelessWidget {
  const _BigBoard({required this.d});

  final GroupBoard d;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        // Tik telefon: QR tepada, qatorlar to‘liq kenglikda.
        final portrait = box.maxWidth < box.maxHeight;
        // Shrift ekran o‘lchamiga qarab (telefon / 720p / 1080p proyektor).
        final scale = portrait
            ? (box.maxWidth / 440).clamp(0.6, 1.2)
            : (min(box.maxHeight / 620, box.maxWidth / 1100)).clamp(0.55, 1.8);
        final code = d.group.code ?? '';
        final link = GroupCode.link(
          code,
          assignmentId: d.assignment.id,
        ).toString();
        final over = d.assignment.isOver;
        final counts = Text(
          l.grpCounts(
            d.count(BoardState.joined),
            d.count(BoardState.solving),
            d.count(BoardState.finished),
          ),
          key: const Key('grp.boardCounts'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: FeBrand.goldOnDark,
            fontSize: (portrait ? 15 : 18) * scale,
            fontWeight: FontWeight.w600,
          ),
        );
        final side = SizedBox(
          width: 300 * scale,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClassQr(data: link, size: 200 * scale),
              SizedBox(height: 10 * scale),
              GroupCodeText(
                code: code,
                fontSize: 38 * scale,
                color: FeBrand.ivory,
              ),
              SizedBox(height: 6 * scale),
              Text(
                l.grpBoardHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14 * scale),
              ),
              SizedBox(height: 12 * scale),
              counts,
              if (over) ...[
                SizedBox(height: 12 * scale),
                GroupHardestBlock(assignment: d.assignment, onDark: true),
              ],
            ],
          ),
        );
        final ranked = d.ranked;
        // Qatorlar soniga qarab shrift/qator balandligi kichrayadi, ustunlar
        // 1-3 gacha ko‘payadi (30 ta talaba 1080p da bitta ekranga sig‘adi).
        final header = portrait ? 200 * scale : 0.0;
        final available = box.maxHeight - 32 - header - 24 * scale;
        final maxCols = portrait ? 1 : 3;
        var rs = 1.0;
        var perCol = 1;
        var cols = 1;
        for (final cand
            in portrait ? const [1.0] : const [1.0, 0.85, 0.72, 0.6]) {
          rs = cand;
          perCol = max(1, (available / (46 * scale * cand)).floor());
          cols = max(1, (ranked.length / perCol).ceil());
          if (cols <= (portrait ? 1 : (cand == 1.0 ? 2 : maxCols))) break;
        }
        cols = min(cols, maxCols);
        final fs = scale * rs;
        final rowH = 46 * fs;
        final shown = ranked.take(perCol * cols).toList();
        final compact = cols >= 3 || (portrait && box.maxWidth < 380);
        Widget head(String text, {double? width, TextAlign? align}) {
          final w = Text(
            text,
            textAlign: align,
            style: TextStyle(color: Colors.white54, fontSize: 13 * fs),
          );
          return width == null
              ? Expanded(child: w)
              : SizedBox(width: width, child: w);
        }

        Widget headerRow() => Padding(
          padding: EdgeInsets.only(bottom: 4 * fs),
          child: Row(
            children: [
              head(l.grpColRank, width: 46 * fs),
              head(l.grpColName),
              if (!compact) head(l.grpColState, width: 124 * fs),
              head(l.grpColCorrect, width: 92 * fs, align: TextAlign.end),
              head(l.grpColTime, width: 74 * fs, align: TextAlign.end),
            ],
          ),
        );
        Widget cell(RankedBoardRow x) {
          final r = x.row;
          final finished = r.state == BoardState.finished;
          final top = x.rank != null && x.rank! <= 3;
          return SizedBox(
            height: rowH,
            child: Row(
              key: Key('grp.bigRow.${r.memberId}'),
              children: [
                SizedBox(
                  width: 46 * fs,
                  child: Semantics(
                    label: x.rank == null ? null : l.grpRankSpoken(x.rank!),
                    excludeSemantics: x.rank != null,
                    child: Text(
                      x.rank?.toString() ?? '',
                      key: Key('grp.bigRank.${r.memberId}'),
                      style: TextStyle(
                        color: top ? FeBrand.goldOnDark : Colors.white54,
                        fontSize: 22 * fs,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    r.nickname,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24 * fs,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (compact)
                  Padding(
                    padding: EdgeInsets.only(right: 6 * fs),
                    child: Tooltip(
                      message: switch (r.state) {
                        BoardState.joined => l.grpStateJoined,
                        BoardState.solving => l.grpStateSolving,
                        BoardState.finished => l.grpStateFinished,
                      },
                      child: Icon(
                        switch (r.state) {
                          BoardState.joined => Icons.person_outline,
                          BoardState.solving => Icons.edit_note,
                          BoardState.finished => Icons.check_circle_outline,
                        },
                        size: 22 * fs,
                        color: switch (r.state) {
                          BoardState.joined => Colors.white70,
                          BoardState.solving => FeBrand.goldOnDark,
                          BoardState.finished => const Color(0xFF7FD3A1),
                        },
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: 124 * fs,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: GroupStatePill(
                        state: r.state,
                        onDark: true,
                        scale: 1.2 * fs,
                      ),
                    ),
                  ),
                SizedBox(
                  width: 92 * fs,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      finished ? '${r.score}/${r.total}' : '',
                      key: Key('grp.bigScore.${r.memberId}'),
                      softWrap: false,
                      style: TextStyle(
                        color: FeBrand.goldOnDark,
                        fontSize: 24 * fs,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 74 * fs,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      r.spent == null ? '' : groupSpentText(r.spent!),
                      key: Key('grp.bigTime.${r.memberId}'),
                      softWrap: false,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 20 * fs,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final columns = [
          for (var c = 0; c < cols; c++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                child: Column(
                  children: [
                    headerRow(),
                    for (
                      var i = c * perCol;
                      i < min(shown.length, (c + 1) * perCol);
                      i++
                    )
                      cell(shown[i]),
                  ],
                ),
              ),
            ),
        ];
        final waiting = Center(
          child: Text(
            l.grpBoardWaiting,
            style: TextStyle(color: Colors.white70, fontSize: 22 * scale),
          ),
        );
        if (portrait) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                height: header,
                child: Row(
                  children: [
                    ClassQr(data: link, size: 150 * scale),
                    SizedBox(width: 16 * scale),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GroupCodeText(
                            code: code,
                            fontSize: 30 * scale,
                            color: FeBrand.ivory,
                          ),
                          SizedBox(height: 6 * scale),
                          counts,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (over)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GroupHardestBlock(
                    assignment: d.assignment,
                    onDark: true,
                  ),
                ),
              if (ranked.isEmpty)
                SizedBox(height: 120, child: waiting)
              else ...[
                headerRow(),
                for (final x in ranked) cell(x),
              ],
            ],
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(child: side),
              SizedBox(width: 24 * scale),
              Expanded(
                child: ranked.isEmpty
                    ? waiting
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: columns,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
