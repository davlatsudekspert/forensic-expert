import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/class_quiz.dart';
import '../../../app/plan.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_quiz/class_quiz_models.dart';
import '../../../domain/plan/plan_models.dart';
import '../../pro/presentation/pro_gate.dart';

/// Xato kodini foydalanuvchiga tushunarli o‘zbekcha (yoki tanlangan til)
/// matniga aylantiradi. Texnik kod ko‘rsatilmaydi.
String classFailureText(AppLocalizations l, ClassFailure f) => switch (f) {
  ClassFailure.notConfigured => l.classErrNotConfigured,
  ClassFailure.notSignedIn => l.classErrNotSignedIn,
  ClassFailure.offline => l.classErrOffline,
  ClassFailure.server => l.classErrServer,
  ClassFailure.forbidden => l.classErrForbidden,
  ClassFailure.badCode => l.classErrBadCode,
  ClassFailure.notFound => l.classErrNotFound,
  ClassFailure.rateLimited => l.classErrRateLimited,
  ClassFailure.ownSession => l.classErrOwnSession,
  ClassFailure.finished => l.classErrFinished,
  ClassFailure.kicked => l.classErrKicked,
  ClassFailure.alreadyStarted => l.classErrAlreadyStarted,
  ClassFailure.full => l.classErrFull,
  ClassFailure.nickLength => l.classErrNickLength,
  ClassFailure.nickChars => l.classErrNickChars,
  ClassFailure.nickBlocked => l.classErrNickBlocked,
  ClassFailure.invalidSettings => l.classErrInvalidSettings,
  ClassFailure.tooManySessions => l.classErrTooManySessions,
  ClassFailure.notEnoughQuestions => l.classErrNotEnoughQuestions,
  ClassFailure.badState => l.classErrBadState,
  ClassFailure.noParticipants => l.classErrNoParticipants,
  ClassFailure.notCurrent => l.classErrNotCurrent,
  ClassFailure.timeOver => l.classErrTimeOver,
  ClassFailure.alreadyAnswered => l.classErrAlreadyAnswered,
  ClassFailure.badOption => l.classErrServer,
  ClassFailure.notFinished => l.classErrNotFinished,
  ClassFailure.notClosed => l.classErrNotClosed,
  ClassFailure.badReason => l.classErrBadReason,
};

/// Sinf natijasini CSV fayl sifatida saqlash/ulashish (ustoz paneli va
/// yakuniy ekran uchun bitta yo‘l). Xato bo‘lsa — tushunarli snackbar.
Future<void> exportClassResultsCsv(
  BuildContext context,
  WidgetRef ref,
  ClassSessionInfo s,
) async {
  // Natijalar CSV — Ustoz Pro (tugma ko‘rinadi, qulfli).
  if (!ref.read(proAllowedProvider(ProFeature.resultsCsv))) {
    openPro(context, Plan.teacher);
    return;
  }
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final share = ref.read(classFileShareProvider);
  final r = await ref.read(classQuizServiceProvider).exportResults(s.id);
  final ex = r.value;
  if (ex == null) {
    messenger.showSnackBar(
      SnackBar(content: Text(classFailureText(l, r.failure!))),
    );
    return;
  }
  await share.shareCsv(
    fileName: ClassResultsCsv.fileName(s.code, DateTime.now()),
    content: ClassResultsCsv.build(
      ex.rows,
      total: ex.session.total,
      belowMinLabel: l.scoringGradeBelowMin,
    ),
    subject: l.classCsvSubject,
  );
}

/// Manba satri: «Manba: muallif, sarlavha, 263-bet» (bet yo‘q — betsiz;
/// «I bob, 1.4» kabi joy — «-bet» qo‘shilmaydi).
String classSourceCitation(AppLocalizations l, ClassSource src) {
  final page = src.cleanPage;
  return page == null
      ? l.classSourceLineNoPage(src.author, src.title)
      : src.pageIsNumeric
      ? l.classSourceLine(src.author, src.title, page)
      : l.classSourceLineLocator(src.author, src.title, page);
}

/// Variant belgisi: A, B, C, D (tartib raqami bo‘yicha).
String classOptionLetter(int i) => String.fromCharCode(0x41 + i);

/// Demo (Fake) adapter belgisi: ma’lumot faqat shu qurilmada.
class ClassDemoBanner extends ConsumerWidget {
  const ClassDemoBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(classQuizServiceProvider).isDemo) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: FeBanner(
        key: const Key('class.demoBanner'),
        icon: Icons.science_outlined,
        text: l.classDemoBanner,
        tone: FeBannerTone.warning,
      ),
    );
  }
}

/// Ustoz bo‘lmagan foydalanuvchi ustoz ekranini ko‘rmaydi. Bu faqat UI
/// qulayligi: xavfsizlik chegarasi — serverdagi 403.
class ClassTeacherGate extends ConsumerWidget {
  const ClassTeacherGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final me = ref.watch(classQuizMeProvider);
    return switch (me) {
      AsyncData(:final value) when value.value?.isTeacher ?? false => child,
      AsyncData() => Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.classQuizTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(FeSpace.lg),
            child: FeEmptyState(
              key: const Key('class.forbidden'),
              icon: Icons.lock_outline,
              title: l.classTeacherOnlyTitle,
              body: l.classTeacherOnlyBody,
            ),
          ),
        ),
      ),
      AsyncError() => Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.classQuizTitle)),
        body: Center(child: Text(l.classErrServer)),
      ),
      _ => Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.classQuizTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

/// Teskari sanoq: server `remainingMs` beradi; oraliqda mahalliy taymer
/// (har 250 ms) sanaydi va yangi qiymat sezilarli farq qilsa tuzatadi.
/// Savol almashganda chaqiruvchi `ValueKey(index)` beradi.
class ClassCountdown extends StatefulWidget {
  const ClassCountdown({
    super.key,
    required this.remainingMs,
    required this.totalMs,
    this.size = 64,
    this.onDark = false,
  });

  final int remainingMs;
  final int totalMs;
  final double size;
  final bool onDark;

  @override
  State<ClassCountdown> createState() => _ClassCountdownState();
}

class _ClassCountdownState extends State<ClassCountdown> {
  late int _ms = widget.remainingMs;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;
      if (_ms > 0) setState(() => _ms = max(0, _ms - 250));
    });
  }

  @override
  void didUpdateWidget(ClassCountdown old) {
    super.didUpdateWidget(old);
    if ((widget.remainingMs - _ms).abs() > 600 ||
        widget.remainingMs == 0 && _ms > 0) {
      _ms = widget.remainingMs;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final l = AppLocalizations.of(context);
    final secs = (_ms / 1000).ceil();
    final fg = widget.onDark ? Colors.white : c.textPrimary;
    final frac = widget.totalMs <= 0
        ? 0.0
        : (_ms / widget.totalMs).clamp(0.0, 1.0);
    final urgent = secs <= 5 && secs > 0;
    return Semantics(
      label: l.classSecondsLeft(secs),
      liveRegion: false,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: frac,
                strokeWidth: max(4, widget.size / 14),
                backgroundColor: (widget.onDark ? Colors.white : c.border)
                    .withValues(alpha: 0.25),
                color: urgent
                    ? c.danger
                    : (widget.onDark ? FeBrand.goldOnDark : c.accent),
              ),
            ),
            ExcludeSemantics(
              child: Text(
                secs.toString(),
                key: const Key('class.countdown'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: widget.size * 0.4,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// QR kodi (oq fon, qora modullar — proyektorda ham skanerlanadi).
class ClassQr extends StatelessWidget {
  const ClassQr({super.key, required this.data, required this.size});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      label: l.classQrSemantics,
      image: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(FeRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(FeSpace.sm),
          child: QrImageView(
            key: const Key('class.qr'),
            data: data,
            size: size,
            backgroundColor: Colors.white,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.black,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

/// Proyektor uchun katta, yuqori kontrastli (to‘q ko‘k fonda ivory/oltin)
/// kod bloki.
class ClassCodeBanner extends StatelessWidget {
  const ClassCodeBanner({super.key, required this.code, this.fontSize = 64});

  final String code;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final spoken = code.split('').join(' ');
    return Semantics(
      label: l.classCodeSpoken(spoken),
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            ClassCode.display(code),
            key: const Key('class.code'),
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
              letterSpacing: fontSize * 0.08,
              color: FeBrand.ivory,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Ranglangan variant plitkasi (A/B/C/D).
class ClassOptionTile extends StatelessWidget {
  const ClassOptionTile({
    super.key,
    required this.letter,
    required this.text,
    this.onTap,
    this.state = ClassOptionState.neutral,
    this.count,
    this.fraction,
    this.big = false,
    this.dense = false,
    this.maxLines,
  });

  final String letter;
  final String text;
  final VoidCallback? onTap;
  final ClassOptionState state;

  /// Ustoz paneli: shu variantni tanlaganlar.
  final int? count;
  final double? fraction;
  final bool big;

  /// Past ekranlarda (proyektor, landshaft telefon) ixcham plitka: kichik
  /// bo‘shliq va shrift. Balandlikni chaqiruvchi belgilaydi.
  final bool dense;

  /// Variant matni uchun qator chegarasi (oshsa «…»); `null` — cheklovsiz.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context);
    final (bg, border, icon, tag) = switch (state) {
      ClassOptionState.correct => (
        c.verified.withValues(alpha: 0.16),
        c.verified,
        Icons.check_circle,
        l.classOptionCorrect,
      ),
      ClassOptionState.wrong => (
        c.danger.withValues(alpha: 0.14),
        c.danger,
        Icons.cancel,
        l.classOptionWrong,
      ),
      ClassOptionState.chosen => (
        c.accentContainer,
        c.accent,
        Icons.radio_button_checked,
        l.classOptionChosen,
      ),
      ClassOptionState.neutral => (c.surfaceRaised, c.borderStrong, null, null),
    };
    // Variant matni — sans (savol sarlavhasi serif), o‘qilishi oson.
    final style =
        (big ? t.headlineSmall : (dense ? t.titleSmall : t.titleMedium))
            ?.copyWith(
              fontFamily: FeFonts.sans,
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            );
    final spoken = tag == null ? '$letter. $text' : '$letter. $text, $tag';
    return Semantics(
      button: onTap != null,
      selected: state == ClassOptionState.chosen,
      label: spoken,
      excludeSemantics: true,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FeRadius.md),
          side: BorderSide(
            color: border,
            width: state == ClassOptionState.neutral ? 1 : 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: dense ? 0 : FeTouch.minTarget + 8,
            ),
            child: Stack(
              children: [
                if (fraction != null)
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: fraction!.clamp(0.0, 1.0),
                      child: ColoredBox(color: border.withValues(alpha: 0.18)),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: dense
                        ? const EdgeInsets.symmetric(
                            horizontal: FeSpace.sm,
                            vertical: 4,
                          )
                        : EdgeInsets.all(big ? FeSpace.md : FeSpace.sm),
                    child: Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.surface,
                            border: Border.all(color: border),
                          ),
                          child: SizedBox(
                            width: big ? 44 : (dense ? 28 : 32),
                            height: big ? 44 : (dense ? 28 : 32),
                            child: Center(
                              child: Text(
                                letter,
                                style: style?.copyWith(
                                  fontSize: big ? 22 : (dense ? 14 : 16),
                                  color: c.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: FeSpace.sm),
                        Expanded(
                          child: Text(
                            text,
                            style: style,
                            maxLines: maxLines,
                            overflow: maxLines == null
                                ? null
                                : TextOverflow.ellipsis,
                          ),
                        ),
                        if (count != null) ...[
                          const SizedBox(width: FeSpace.xs),
                          Text(count.toString(), style: style),
                        ],
                        if (icon != null) ...[
                          const SizedBox(width: FeSpace.xs),
                          Icon(icon, color: border),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum ClassOptionState { neutral, chosen, correct, wrong }

/// “Kirish kerak” kartasi: hisobsiz qo‘shilib bo‘lmaydi (server user_id bilan
/// bog‘laydi). Kirgandan so‘ng chaqiruvchi ekran o‘zi davom etadi.
class ClassSignInCard extends StatelessWidget {
  const ClassSignInCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: const Key('class.signInCard'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.classSignInTitle, style: t.titleMedium),
          const SizedBox(height: FeSpace.xxs),
          Text(l.classSignInBody, style: t.bodyMedium),
          const SizedBox(height: FeSpace.sm),
          FilledButton.icon(
            key: const Key('class.signInButton'),
            onPressed: () => context.push(Routes.accountEmailCode),
            icon: const Icon(Icons.login),
            label: Text(l.classSignInAction),
          ),
        ],
      ),
    );
  }
}

/// Kichik, ekranni to‘smaydigan «Aloqa tiklanmoqda…» belgisi: polling bir
/// marta xato bersa, oxirgi holat ko‘rinib turadi, bu belgi esa ustida.
class ClassReconnectingBar extends StatelessWidget {
  const ClassReconnectingBar({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final fg = onDark ? Colors.white : c.textSecondary;
    return Semantics(
      liveRegion: true,
      child: Padding(
        key: const Key('class.reconnecting'),
        padding: const EdgeInsets.symmetric(
          horizontal: FeSpace.md,
          vertical: FeSpace.xxs,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: fg),
            ),
            const SizedBox(width: FeSpace.xs),
            Flexible(
              child: Text(
                l.classReconnecting,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
