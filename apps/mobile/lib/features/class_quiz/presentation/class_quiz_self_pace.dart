import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_quiz/class_quiz_models.dart';

/// «Test rejimi» tanlovi (yangi test ekrani): ikki aniq variant, har birining
/// tagida bir qatorli izoh. Standart — ustoz boshqaradi (o‘zgarmagan xulq).
class ClassPacePicker extends StatelessWidget {
  const ClassPacePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ClassPace value;
  final ValueChanged<ClassPace> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      key: const Key('class.pace'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PaceOption(
          optionKey: const Key('class.pace.host'),
          selected: value == ClassPace.host,
          title: l.classPaceHost,
          hint: l.classPaceHostHint,
          onTap: () => onChanged(ClassPace.host),
        ),
        const SizedBox(height: FeSpace.xs),
        _PaceOption(
          optionKey: const Key('class.pace.self'),
          selected: value == ClassPace.self,
          title: l.classPaceSelf,
          hint: l.classPaceSelfHint,
          onTap: () => onChanged(ClassPace.self),
        ),
        const SizedBox(height: FeSpace.xs),
      ],
    );
  }
}

class _PaceOption extends StatelessWidget {
  const _PaceOption({
    required this.optionKey,
    required this.selected,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final Key optionKey;
  final bool selected;
  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return FeCard(
      key: optionKey,
      color: selected ? c.accentContainer : null,
      onTap: onTap,
      semanticLabel: '$title. $hint',
      child: ExcludeSemantics(
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: c.accent,
            ),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.titleSmall),
                  Text(
                    hint,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ustoz doskasi («har kim o‘z tezligida» rejimi, test ketayotganda): har
/// talabaning progressi (nechanchi savolda, nechta to‘g‘ri, tugatdimi) va jonli
/// reyting. «Keyingi savol» yo‘q — ustoz testni o‘zi tugatadi.
class ClassSelfBoard extends StatelessWidget {
  const ClassSelfBoard({
    super.key,
    required this.d,
    required this.busy,
    required this.onFinish,
  });

  final ClassDashboard d;
  final bool busy;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final total = d.session.total;
    final allDone = d.joined > 0 && d.selfDone >= d.joined;
    const muted = Color(0xFFC9D2E0);
    return ListView(
      key: const Key('class.selfBoard'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(FeSpace.md),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.classBoardTitle,
                  style: t.titleLarge?.copyWith(color: FeBrand.goldOnDark),
                ),
                const SizedBox(height: FeSpace.xxs),
                Text(
                  l.classBoardSummary(d.selfOpened, d.selfDone, d.joined),
                  key: const Key('class.boardSummary'),
                  style: t.titleSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: FeSpace.xs),
                if (allDone)
                  FeBanner(
                    key: const Key('class.boardAllDone'),
                    icon: Icons.verified_outlined,
                    text: l.classBoardAllDone,
                    tone: FeBannerTone.review,
                  )
                else
                  Text(
                    l.classBoardHint,
                    style: t.bodyMedium?.copyWith(color: muted),
                  ),
                const SizedBox(height: FeSpace.sm),
                FeCard(
                  key: const Key('class.boardProgress'),
                  child: Column(
                    children: [
                      for (final p in d.participants)
                        _ProgressRow(p: p, total: total),
                    ],
                  ),
                ),
                const SizedBox(height: FeSpace.sm),
                Text(
                  l.classLeaderboard,
                  style: t.titleMedium?.copyWith(color: FeBrand.goldOnDark),
                ),
                const SizedBox(height: FeSpace.xxs),
                FeCard(
                  key: const Key('class.boardLeaders'),
                  child: Column(
                    children: [
                      for (final r in d.leaderboard)
                        _LeaderLine(row: r, total: total),
                    ],
                  ),
                ),
                const SizedBox(height: FeSpace.md),
                FilledButton.icon(
                  key: const Key('class.endSelfButton'),
                  onPressed: busy ? null : onFinish,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: Text(l.classEndAction),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
                const SizedBox(height: FeSpace.lg),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.p, required this.total});

  final ClassParticipant p;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final pr = p.progress;
    final done = pr?.done ?? false;
    final started = pr?.started ?? false;
    final status = done
        ? l.classBoardDone
        : started
        ? l.classQuestionOf(pr!.position, total)
        : l.classBoardNotStarted;
    final tone = done ? c.verified : c.textSecondary;
    return Padding(
      key: Key('class.progress.${p.id}'),
      padding: const EdgeInsets.symmetric(vertical: FeSpace.xxs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: FeSpace.xs),
              Flexible(
                child: Text(
                  status,
                  key: Key('class.progressStatus.${p.id}'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelMedium?.copyWith(
                    color: tone,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          LinearProgressIndicator(
            value: total == 0 ? 0 : (pr?.answered ?? 0) / total,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
            color: done ? c.verified : c.accent,
            backgroundColor: c.surfaceSunken,
          ),
          if (pr != null && pr.answered > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                l.classBoardAnsweredCorrect(pr.correct, pr.answered),
                key: Key('class.progressDetail.${p.id}'),
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

class _LeaderLine extends StatelessWidget {
  const _LeaderLine({required this.row, required this.total});

  final ClassLeaderRow row;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              row.rank.toString(),
              key: Key('class.boardRank.${row.participantId}'),
              style: t.titleSmall?.copyWith(color: c.textSecondary),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.titleSmall,
                ),
                Text(
                  l.classLeaderCorrect(row.correct, total),
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            row.score.toString(),
            style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
