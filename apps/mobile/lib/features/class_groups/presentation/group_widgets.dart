import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/class_groups.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_groups/class_groups_models.dart';

/// Xato kodini tushunarli matnga aylantiradi (uz/ru/en). Texnik kod
/// ko‘rsatilmaydi. [extra] — server qo‘shimchasi (`available`, `needed`).
String groupFailureText(
  AppLocalizations l,
  GroupFailure f, [
  Map<String, Object?> extra = const {},
]) {
  int n(String k) => (extra[k] as num?)?.toInt() ?? 0;
  return switch (f) {
    GroupFailure.notConfigured => l.grpErrNotConfigured,
    GroupFailure.notSignedIn => l.grpErrSessionExpired,
    GroupFailure.offline => l.grpErrOffline,
    GroupFailure.server => l.grpErrServer,
    GroupFailure.forbidden => l.grpErrForbidden,
    GroupFailure.rateLimited => l.grpErrRateLimited,
    GroupFailure.badCode => l.grpErrBadCode,
    GroupFailure.codeAmbiguous => l.grpErrCodeAmbiguous,
    GroupFailure.notFound => l.grpErrNotFound,
    GroupFailure.nicknameRequired => l.grpNickNeeded,
    GroupFailure.groupFull => l.grpErrGroupFull,
    GroupFailure.nickLength => l.grpErrNickLength,
    GroupFailure.nickChars => l.grpErrNickChars,
    GroupFailure.nickBlocked => l.grpErrNickBlocked,
    GroupFailure.nickTaken => l.grpErrNickTaken,
    GroupFailure.badName => l.grpErrBadName,
    GroupFailure.tooManyGroups => l.grpErrTooManyGroups,
    GroupFailure.invalidSettings => l.grpErrInvalidSettings,
    GroupFailure.badDue => l.grpErrBadDue,
    GroupFailure.revealNeedsDue => l.grpErrRevealNeedsDue,
    GroupFailure.notEnoughQuestions => l.grpErrNotEnoughQuestions(
      n('available'),
    ),
    GroupFailure.variantPoolSmall => l.grpVariantTooFew(
      n('available'),
      n('needed'),
    ),
    GroupFailure.tooManyAssignments => l.grpErrTooManyAssignments,
    GroupFailure.closed => l.grpErrClosed,
    GroupFailure.pastDue => l.grpErrPastDue,
    GroupFailure.notStarted => l.grpErrServer,
    GroupFailure.alreadySubmitted => l.grpErrAlreadySubmitted,
    GroupFailure.timeOver => l.grpErrTimeOver,
    GroupFailure.notSubmitted => l.grpErrNotSubmitted,
    GroupFailure.notFinished => l.grpErrNotFinished,
  };
}

/// Sarflangan vaqt: `7:05` (1 soatdan ko‘p bo‘lsa `1:02:09`).
String groupSpentText(Duration d) {
  final s = d.inSeconds;
  String two(int n) => n.toString().padLeft(2, '0');
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  return h > 0 ? '$h:${two(m)}:${two(s % 60)}' : '$m:${two(s % 60)}';
}

/// Demo adapter belgisi: ma’lumot faqat shu qurilmada.
class GroupDemoBanner extends ConsumerWidget {
  const GroupDemoBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(classGroupsServiceProvider).isDemo) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: FeBanner(
        key: const Key('grp.demoBanner'),
        icon: Icons.science_outlined,
        text: AppLocalizations.of(context).grpDemoBanner,
        tone: FeBannerTone.warning,
      ),
    );
  }
}

/// Test sozlamalari bir qatorda: «10 savol · 20 daqiqa · Muddat: 20-okt, 18:00».
String groupAssignmentLine(
  BuildContext context,
  AppLocalizations l,
  GroupAssignment a,
) {
  final parts = <String>[
    l.grpQuestionsN(a.questionCount),
    if (a.timeLimitMin != null)
      l.grpMinutesN(a.timeLimitMin!)
    else
      l.grpNoTimeLimit,
    if (a.dueAt != null) l.grpDueLabel(feDueShort(context, a.dueAt!)),
    if (a.variantMode) l.grpVariantShort,
  ];
  return parts.join(FeGlyphs.middleDot);
}

/// Javoblar qachon ochilishi (talabaga va ustozga bir xil matn).
String groupRevealText(
  BuildContext context,
  AppLocalizations l,
  GroupAssignment a,
) => switch (a.reveal) {
  RevealPolicy.afterDue when a.dueAt != null => l.grpRevealAfterDueNote(
    feDueShort(context, a.dueAt!),
  ),
  _ => l.grpRevealAfterCloseNote,
};

/// Vaqt ko‘rsatkichi: vaqt chegarasi bo‘lsa — teskari sanoq; faqat muddat
/// bo‘lsa — sana («Muddat: 20-okt, 18:00»), teskari sanoq faqat oxirgi soatda.
/// Hisob server soati bo‘yicha ([GroupClock]).
class GroupTimeChip extends StatefulWidget {
  const GroupTimeChip({
    super.key,
    required this.clock,
    required this.now,
    this.onExpired,
  });

  final GroupClock clock;
  final DateTime Function() now;
  final VoidCallback? onExpired;

  @override
  State<GroupTimeChip> createState() => _GroupTimeChipState();
}

class _GroupTimeChipState extends State<GroupTimeChip> {
  Timer? _t;
  bool _fired = false;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      if (!_fired && widget.clock.expired(widget.now())) {
        _fired = true;
        widget.onExpired?.call();
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  static String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final now = widget.now();
    final rem = widget.clock.remaining(now);
    if (rem == null) {
      return Text(
        l.grpNoTimeLimit,
        key: const Key('grp.time.none'),
        style: t.bodySmall?.copyWith(color: c.textSecondary),
      );
    }
    if (!widget.clock.showCountdown(now)) {
      return Text(
        l.grpDueLabel(feDueShort(context, widget.clock.endsAt!)),
        key: const Key('grp.time.due'),
        style: t.labelLarge?.copyWith(color: c.textSecondary),
      );
    }
    final low = rem.inSeconds <= 60;
    return Semantics(
      label: l.grpTimeLeftSemantics(_fmt(rem)),
      child: ExcludeSemantics(
        child: Row(
          key: const Key('grp.time.countdown'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 18,
              color: low ? c.danger : c.accent,
            ),
            const SizedBox(width: FeSpace.xxs),
            Text(
              _fmt(rem),
              style: t.titleMedium?.copyWith(
                fontFamily: 'JetBrainsMono',
                color: low ? c.danger : c.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kod maydoni: kichik harf → katta, joylangan havola/taklif matnidan kodni
/// ajratadi (QR havolasi ham).
class GroupCodeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final t = newValue.text;
    if (RegExp(r'^[A-Za-z0-9 \-]{0,10}$').hasMatch(t)) {
      final up = t.toUpperCase();
      return newValue.copyWith(text: up);
    }
    final inv = GroupCode.fromText(t);
    if (inv == null) return oldValue;
    return TextEditingValue(
      text: inv.code,
      selection: TextSelection.collapsed(offset: inv.code.length),
    );
  }
}

/// Guruh kodi — katta, o‘qish oson (4+4), ekran o‘quvchisiga harfma-harf.
class GroupCodeText extends StatelessWidget {
  const GroupCodeText({
    super.key,
    required this.code,
    this.fontSize = 28,
    this.color,
  });

  final String code;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      label: l.grpCodeSpoken(code.split('').join(' ')),
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            GroupCode.display(code),
            key: const Key('grp.code'),
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
              letterSpacing: fontSize * 0.08,
              color: color ?? FeTheme.of(context).textPrimary,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Kichik holat belgisi (qo‘shildi / yechmoqda / tugatdi).
class GroupStatePill extends StatelessWidget {
  const GroupStatePill({
    super.key,
    required this.state,
    this.onDark = false,
    this.scale = 1,
  });

  final BoardState state;
  final bool onDark;

  /// Katta ekran uchun kattalashtirish.
  final double scale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final (label, color, icon) = switch (state) {
      BoardState.joined => (
        l.grpStateJoined,
        onDark ? Colors.white70 : c.textSecondary,
        Icons.person_outline,
      ),
      BoardState.solving => (
        l.grpStateSolving,
        onDark ? FeBrand.goldOnDark : c.accent,
        Icons.edit_note,
      ),
      BoardState.finished => (
        l.grpStateFinished,
        onDark ? const Color(0xFF7FD3A1) : c.verified,
        Icons.check_circle_outline,
      ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16 * scale, color: color),
        SizedBox(width: FeSpace.xxs * scale),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontSize:
                (Theme.of(context).textTheme.labelMedium?.fontSize ?? 12) *
                scale,
          ),
        ),
      ],
    );
  }
}
