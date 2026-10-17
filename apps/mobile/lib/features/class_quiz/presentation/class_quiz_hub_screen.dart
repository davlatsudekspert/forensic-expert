import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app/class_quiz.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_quiz/class_quiz_models.dart';
import '../../professional/presentation/professional_widgets.dart' show FeNote;
import 'class_quiz_widgets.dart';

/// «Sinfda test» bosh sahifasi: talaba uchun kod bilan qo‘shilish (QR yoki
/// qo‘lda), ustoz uchun yangi test yaratish va oxirgi sinflar.
class ClassQuizHubScreen extends ConsumerStatefulWidget {
  const ClassQuizHubScreen({super.key});

  @override
  ConsumerState<ClassQuizHubScreen> createState() => _ClassQuizHubState();
}

class _ClassQuizHubState extends ConsumerState<ClassQuizHubScreen> {
  final _code = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    final pending = ref.read(pendingClassCodeProvider);
    if (pending != null) _code.text = pending;
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _join() {
    final l = AppLocalizations.of(context);
    final code = ClassCode.normalize(_code.text);
    if (code == null) {
      setState(() => _error = l.classErrBadCode);
      return;
    }
    setState(() => _error = null);
    ref.read(pendingClassCodeProvider.notifier).clear();
    context.push(Routes.classJoinWith(code));
  }

  Future<void> _scan() async {
    final code = await context.push<String>(Routes.classScan);
    if (!mounted || code == null) return;
    setState(() {
      _code.text = code;
      _error = null;
    });
    _join();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final svc = ref.watch(classQuizServiceProvider);
    final me = ref.watch(classQuizMeProvider).value?.value;
    final active = ref.watch(classActiveJoinProvider);
    final scanner = ref.watch(classScannerAvailableProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.classQuizTitle)),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: FeSpace.xl),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  const ClassDemoBanner(),
                  FeBanner(
                    icon: Icons.groups_2_outlined,
                    text: l.classQuizIntro,
                    tone: FeBannerTone.review,
                  ),
                  if (!svc.isConfigured) ...[
                    const SizedBox(height: FeSpace.md),
                    FeNote(
                      key: const Key('class.notConfigured'),
                      icon: Icons.cloud_off_outlined,
                      text: l.classErrNotConfigured,
                    ),
                  ] else ...[
                    FeSectionHeader(l.classJoinSection),
                    FeCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(l.classJoinHint, style: t.bodyMedium),
                          const SizedBox(height: FeSpace.sm),
                          TextField(
                            key: const Key('class.codeField'),
                            controller: _code,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.go,
                            maxLength: 7,
                            autofillHints: const [AutofillHints.oneTimeCode],
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9 ]'),
                              ),
                            ],
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            onSubmitted: (_) => _join(),
                            style: t.headlineSmall?.copyWith(
                              fontFamily: 'JetBrainsMono',
                              letterSpacing: 4,
                            ),
                            decoration: InputDecoration(
                              labelText: l.classCodeLabel,
                              hintText: '000 000',
                              counterText: '',
                              errorText: _error,
                            ),
                          ),
                          const SizedBox(height: FeSpace.xs),
                          FilledButton.icon(
                            key: const Key('class.joinButton'),
                            onPressed: _join,
                            icon: const Icon(Icons.login),
                            label: Text(l.classJoinAction),
                          ),
                          if (scanner) ...[
                            const SizedBox(height: FeSpace.xs),
                            OutlinedButton.icon(
                              key: const Key('class.scanButton'),
                              onPressed: _scan,
                              icon: const Icon(Icons.qr_code_scanner),
                              label: Text(l.classScanAction),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (active != null) ...[
                      const SizedBox(height: FeSpace.sm),
                      FeCard(
                        key: const Key('class.resume'),
                        onTap: () =>
                            context.push(Routes.classPlay(active.sessionId)),
                        child: Row(
                          children: [
                            Icon(Icons.play_circle_outline, color: c.accent),
                            const SizedBox(width: FeSpace.sm),
                            Expanded(
                              child: Text(
                                l.classResume(active.session.topicTitle),
                                style: t.titleSmall,
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ],
                    FeSectionHeader(l.classTeacherSection),
                    if (me?.isTeacher ?? false)
                      const _TeacherPanel()
                    else
                      FeNote(
                        key: const Key('class.notTeacherNote'),
                        icon: Icons.school_outlined,
                        text: l.classNotTeacherNote,
                      ),
                    const SizedBox(height: FeSpace.md),
                    FeNote(
                      icon: Icons.privacy_tip_outlined,
                      text: l.classPrivacyNote,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherPanel extends ConsumerWidget {
  const _TeacherPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final sessions =
        ref.watch(classMySessionsProvider).value?.value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          key: const Key('class.newButton'),
          onPressed: () => context.push(Routes.classNew),
          icon: const Icon(Icons.add),
          label: Text(l.classNewAction),
        ),
        if (sessions.isNotEmpty) ...[
          FeSectionHeader(l.classRecentSection),
          for (final s in sessions)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xs),
              child: FeCard(
                key: Key('class.session.${s.id}'),
                onTap: () => context.push(Routes.classHost(s.id)),
                child: Row(
                  children: [
                    Icon(
                      s.status == ClassSessionStatus.finished
                          ? Icons.check_circle_outline
                          : Icons.podcasts,
                      color: c.accent,
                    ),
                    const SizedBox(width: FeSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.topicTitle, style: t.titleSmall),
                          Text(
                            l.classSessionLine(
                              ClassCode.display(s.code),
                              switch (s.status) {
                                ClassSessionStatus.lobby => l.classStatusLobby,
                                ClassSessionStatus.running =>
                                  l.classStatusRunning,
                                ClassSessionStatus.finished =>
                                  l.classStatusFinished,
                              },
                            ),
                            style: t.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

/// Kod + laqab bilan qo‘shilish. Hisobsiz qo‘shilib bo‘lmaydi: avval kirish.
class ClassJoinScreen extends ConsumerStatefulWidget {
  const ClassJoinScreen({super.key, this.initialCode});

  final String? initialCode;

  @override
  ConsumerState<ClassJoinScreen> createState() => _ClassJoinState();
}

class _ClassJoinState extends ConsumerState<ClassJoinScreen> {
  late final TextEditingController _code;
  final _nick = TextEditingController();
  bool _busy = false;
  String? _codeError;
  String? _nickError;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial =
        ClassCode.normalize(widget.initialCode) ??
        ref.read(pendingClassCodeProvider);
    _code = TextEditingController(text: initial ?? '');
    if (initial != null) {
      // Kirish ekraniga o‘tilsa kod yo‘qolmasin.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(pendingClassCodeProvider.notifier).remember(initial);
        }
      });
    }
  }

  @override
  void dispose() {
    _code.dispose();
    _nick.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final code = ClassCode.normalize(_code.text);
    final nick = ClassNickname.clean(_nick.text);
    final nickCheck = ClassNickname.check(nick);
    setState(() {
      _codeError = code == null ? l.classErrBadCode : null;
      _nickError = switch (nickCheck) {
        NicknameCheck.ok => null,
        NicknameCheck.length => l.classErrNickLength,
        NicknameCheck.chars => l.classErrNickChars,
        NicknameCheck.blocked => l.classErrNickBlocked,
      };
      _error = null;
    });
    if (code == null || nickCheck != NicknameCheck.ok) return;
    setState(() => _busy = true);
    final r = await ref
        .read(classQuizServiceProvider)
        .join(code: code, nickname: nick);
    if (!mounted) return;
    final info = r.value;
    if (info == null) {
      setState(() {
        _busy = false;
        final f = r.failure!;
        switch (f) {
          case ClassFailure.nickLength:
          case ClassFailure.nickChars:
          case ClassFailure.nickBlocked:
            _nickError = classFailureText(l, f);
          case ClassFailure.badCode || ClassFailure.notFound:
            _codeError = classFailureText(l, f);
          default:
            _error = classFailureText(l, f);
        }
      });
      return;
    }
    ref.read(pendingClassCodeProvider.notifier).clear();
    ref.read(classActiveJoinProvider.notifier).set(info);
    context.pushReplacement(Routes.classPlay(info.sessionId));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final svc = ref.watch(classQuizServiceProvider);
    final signedIn = ref.watch(authStateProvider.select((s) => s.signedIn));
    final needSignIn = svc.requiresSignIn && !signedIn;

    return Scaffold(
      appBar: AppBar(title: Text(l.classJoinTitle)),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: FeSpace.xl),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  const ClassDemoBanner(),
                  if (needSignIn)
                    const ClassSignInCard()
                  else ...[
                    TextField(
                      key: const Key('class.joinCode'),
                      controller: _code,
                      keyboardType: TextInputType.number,
                      maxLength: 7,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                      ],
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      style: t.titleLarge?.copyWith(
                        fontFamily: 'JetBrainsMono',
                        letterSpacing: 3,
                      ),
                      decoration: InputDecoration(
                        labelText: l.classCodeLabel,
                        counterText: '',
                        errorText: _codeError,
                      ),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    TextField(
                      key: const Key('class.nickField'),
                      controller: _nick,
                      textInputAction: TextInputAction.done,
                      maxLength: ClassQuizRules.nickMax,
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: l.classNickLabel,
                        helperText: l.classNickHelper,
                        helperMaxLines: 3,
                        errorText: _nickError,
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: FeSpace.xs),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _error!,
                          key: const Key('class.joinError'),
                          style: t.bodyMedium?.copyWith(
                            color: FeTheme.of(context).danger,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: FeSpace.sm),
                    FilledButton(
                      key: const Key('class.joinSubmit'),
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l.classJoinAction),
                    ),
                    const SizedBox(height: FeSpace.md),
                    FeNote(
                      icon: Icons.privacy_tip_outlined,
                      text: l.classPrivacyNote,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// QR skaner. Kamera ruxsati rad etilsa — tushunarli matn va qo‘lda kiritish.
class ClassScanScreen extends StatefulWidget {
  const ClassScanScreen({super.key});

  @override
  State<ClassScanScreen> createState() => _ClassScanState();
}

class _ClassScanState extends State<ClassScanScreen> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final b in capture.barcodes) {
      final code = ClassCode.fromScanned(b.rawValue);
      if (code != null) {
        _done = true;
        context.pop(code);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.classScanTitle)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(FeSpace.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.no_photography_outlined, size: 40),
                    const SizedBox(height: FeSpace.sm),
                    Text(
                      error.errorCode == MobileScannerErrorCode.permissionDenied
                          ? l.classScanPermission
                          : l.classScanUnavailable,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: FeSpace.sm),
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      child: Text(l.classScanManual),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(FeSpace.md),
                padding: const EdgeInsets.all(FeSpace.sm),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(FeRadius.md),
                ),
                child: Text(
                  l.classScanHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
