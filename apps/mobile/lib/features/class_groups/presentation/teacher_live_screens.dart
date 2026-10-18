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
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final r = await ref
        .read(classGroupsServiceProvider)
        .closeAssignment(widget.assignmentId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!r.ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(groupFailureText(l, r.failure!))),
      );
    }
    ref.invalidate(groupBoardProvider(widget.assignmentId));
    ref.invalidate(groupDetailProvider(widget.groupId));
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
        for (final (i, r) in d.rows.indexed)
          _LiveRow(key: Key('grp.row.${r.memberId}'), rank: i + 1, row: r),
        const SizedBox(height: FeSpace.md),
        FeNote(
          icon: Icons.lock_clock_outlined,
          text: groupRevealText(context, l, a),
        ),
        const SizedBox(height: FeSpace.md),
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
      appBar: AppBar(title: FeAppBarTitle(l.grpLiveTitle)),
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
  const _LiveRow({super.key, required this.rank, required this.row});

  final int rank;
  final GroupBoardRow row;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final finished = row.state == BoardState.finished;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: FeSpace.xs),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              finished ? '$rank' : FeGlyphs.emDash,
              style: t.labelLarge?.copyWith(color: c.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              row.nickname,
              style: t.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GroupStatePill(state: row.state),
          SizedBox(
            width: 64,
            child: Text(
              finished ? '${row.score}/${row.total}' : '',
              textAlign: TextAlign.end,
              style: t.titleSmall?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
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
        final side = SizedBox(
          width: 300 * scale,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClassQr(data: link, size: 220 * scale),
              SizedBox(height: 12 * scale),
              GroupCodeText(
                code: code,
                fontSize: 40 * scale,
                color: FeBrand.ivory,
              ),
              SizedBox(height: 8 * scale),
              Text(
                l.grpBoardHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 15 * scale),
              ),
              SizedBox(height: 16 * scale),
              Text(
                l.grpCounts(
                  d.count(BoardState.joined),
                  d.count(BoardState.solving),
                  d.count(BoardState.finished),
                ),
                key: const Key('grp.boardCounts'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: FeBrand.goldOnDark,
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
        final rowH = 44 * scale;
        final header = portrait ? 200 * scale : 0.0;
        final available = box.maxHeight - 32 - header;
        final perCol = max(1, (available / rowH).floor());
        final cols = portrait
            ? 1
            : max(1, min(4, (d.rows.length / perCol).ceil()));
        final shown = d.rows.take(perCol * cols).toList();
        Widget cell(int i, GroupBoardRow r) => SizedBox(
          height: rowH,
          child: Row(
            key: Key('grp.bigRow.${r.memberId}'),
            children: [
              SizedBox(
                width: 36 * scale,
                child: Text(
                  r.state == BoardState.finished ? '${i + 1}' : '',
                  style: TextStyle(color: Colors.white54, fontSize: 18 * scale),
                ),
              ),
              Expanded(
                child: Text(
                  r.nickname,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Transform.scale(
                scale: scale.clamp(0.8, 1.4),
                child: GroupStatePill(state: r.state, onDark: true),
              ),
              SizedBox(
                width: 80 * scale,
                child: Text(
                  r.state == BoardState.finished ? '${r.score}/${r.total}' : '',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: FeBrand.goldOnDark,
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        );
        final columns = [
          for (var c = 0; c < cols; c++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                child: Column(
                  children: [
                    for (
                      var i = c * perCol;
                      i < min(shown.length, (c + 1) * perCol);
                      i++
                    )
                      cell(i, shown[i]),
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
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            Text(
                              l.grpCounts(
                                d.count(BoardState.joined),
                                d.count(BoardState.solving),
                                d.count(BoardState.finished),
                              ),
                              key: const Key('grp.boardCounts'),
                              style: TextStyle(
                                color: FeBrand.goldOnDark,
                                fontSize: 15 * scale,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: d.rows.isEmpty
                      ? waiting
                      : Column(
                          children: [
                            for (var i = 0; i < shown.length; i++)
                              cell(i, shown[i]),
                          ],
                        ),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              side,
              SizedBox(width: 24 * scale),
              Expanded(
                child: d.rows.isEmpty
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
