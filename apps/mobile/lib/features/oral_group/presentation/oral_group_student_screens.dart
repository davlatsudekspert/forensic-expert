import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/class_quiz.dart'
    show classScannerAvailableProvider, pendingClassCodeProvider;
import '../../../app/keep_awake.dart';
import '../../../app/oral_group.dart';
import '../../../app/oral_i18n.dart';
import '../../../app/professional.dart' show localProfileProvider;
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_quiz/class_quiz_models.dart';
import '../../../domain/oral_group/oral_group_models.dart';
import '../../anti_cheat/presentation/anti_cheat_widgets.dart'
    show AntiCheatStudentNote, LeaveReporter;
import '../../class_quiz/presentation/class_quiz_hub_screen.dart'
    show ClassCodeInputFormatter;
import '../../class_quiz/presentation/class_quiz_widgets.dart'
    show ClassSignInCard;
import '../../professional/presentation/professional_widgets.dart' show FeNote;
import 'oral_group_widgets.dart';

// =========================================================== QO‘SHILISH

/// Kod + ism bilan qo‘shilish. QR yoki «Guruh testi» kod maydonidan keladi.
/// Hisobsiz qo‘shilib bo‘lmaydi: avval kirish (server talabi).
class OralGroupJoinScreen extends ConsumerStatefulWidget {
  const OralGroupJoinScreen({super.key, this.initialCode, this.initialName});

  final String? initialCode;
  final String? initialName;

  @override
  ConsumerState<OralGroupJoinScreen> createState() => _OralJoinState();
}

class _OralJoinState extends ConsumerState<OralGroupJoinScreen> {
  late final TextEditingController _code;
  late final TextEditingController _name;
  bool _busy = false;
  String? _codeError;
  String? _nameError;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial =
        ClassCode.normalize(widget.initialCode) ??
        ref.read(pendingClassCodeProvider);
    _code = TextEditingController(text: initial ?? '');
    final given = OralName.clean(widget.initialName ?? '');
    _name = TextEditingController(text: given.isNotEmpty ? given : _profile());
  }

  /// Akkauntga kirgan talaba: profil ismi (o‘zgartirsa bo‘ladi).
  String _profile() {
    if (!ref.read(authStateProvider).signedIn) return '';
    final p = ref.read(localProfileProvider);
    return OralName.fromProfile(
      p.student?.fullName ?? p.professional?.fullName,
    );
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

  /// «Guruh testi» bilan bir xil QR skaner. Oral havola kodni to‘ldirib
  /// qo‘shiladi; «Guruh testi» havolasi bo‘lsa — o‘sha qo‘shilish ekraniga.
  Future<void> _scan() async {
    final r = await context.push<String>(Routes.classScanBack);
    if (!mounted || r == null) return;
    final oral = OralGroupLink.codeFromScanResult(r);
    if (oral != null) {
      setState(() {
        _code.text = oral;
        _codeError = null;
      });
      await _submit();
      return;
    }
    final cls = ClassCode.normalize(r);
    if (cls != null) context.pushReplacement(Routes.classJoinWith(cls));
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final code = ClassCode.normalize(_code.text);
    final name = OralName.clean(_name.text);
    // Ism mijozda tekshirilmaydi: qayta kirishda server ismni umuman
    // tekshirmaydi (avval ishtirokchini topadi), xatolarni server qaytaradi.
    setState(() {
      _codeError = code == null ? l.classErrBadCode : null;
      _nameError = null;
      _error = null;
    });
    if (code == null) return;
    setState(() => _busy = true);
    final r = await ref
        .read(oralGroupServiceProvider)
        .join(code: code, name: name);
    if (!mounted) return;
    final info = r.value;
    if (info == null) {
      setState(() {
        _busy = false;
        final f = r.failure!;
        switch (f) {
          case ClassFailure.nickLength ||
              ClassFailure.nickChars ||
              ClassFailure.nickBlocked:
            _nameError = oralFailureText(l, f);
          case ClassFailure.badCode || ClassFailure.notFound:
            _codeError = oralFailureText(l, f);
          default:
            _error = oralFailureText(l, f);
        }
      });
      return;
    }
    ref.read(pendingClassCodeProvider.notifier).clear();
    await ref.read(oralResumeProvider.notifier).remember(code, info.session.id);
    if (!mounted) return;
    context.pushReplacement(Routes.oralPlay(info.session.id));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final svc = ref.watch(oralGroupServiceProvider);
    final signedIn = ref.watch(authStateProvider.select((s) => s.signedIn));
    final needSignIn = svc.requiresSignIn && !signedIn;
    final scanner = ref.watch(classScannerAvailableProvider);
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.oralJoinTitle)),
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
                  const OralGroupDemoBanner(),
                  const OralResumeCard(),
                  if (needSignIn)
                    const ClassSignInCard()
                  else ...[
                    TextField(
                      key: const Key('oralgroup.joinCode'),
                      controller: _code,
                      keyboardType: TextInputType.number,
                      maxLength: 7,
                      inputFormatters: [ClassCodeInputFormatter()],
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
                        errorMaxLines: 3,
                      ),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    TextField(
                      key: const Key('oralgroup.joinName'),
                      controller: _name,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.words,
                      maxLength: OralGroupRules.nameMax,
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: l.oralJoinNameLabel,
                        helperText: l.oralJoinNameHelper,
                        helperMaxLines: 3,
                        errorText: _nameError,
                        errorMaxLines: 3,
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: FeSpace.xs),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _error!,
                          key: const Key('oralgroup.joinError'),
                          style: t.bodyMedium?.copyWith(
                            color: FeTheme.of(context).danger,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: FeSpace.sm),
                    FilledButton(
                      key: const Key('oralgroup.joinSubmit'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l.classJoinAction),
                    ),
                    if (scanner) ...[
                      const SizedBox(height: FeSpace.xs),
                      OutlinedButton.icon(
                        key: const Key('oralgroup.scanButton'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: _busy ? null : _scan,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: Text(l.classScanAction),
                      ),
                    ],
                    const SizedBox(height: FeSpace.md),
                    FeNote(
                      icon: Icons.privacy_tip_outlined,
                      text: l.oralJoinNote,
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

// =========================================================== BILET

/// Talaba ekrani: bilet, savollar (javob kalitisiz), tayyorlanish sanog‘i,
/// «Javobga tayyorman», «Ustoz sizni chaqirdi» va baholangach — o‘z balli.
class OralGroupPlayScreen extends ConsumerStatefulWidget {
  const OralGroupPlayScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<OralGroupPlayScreen> createState() => _OralPlayState();
}

class _OralPlayState extends ConsumerState<OralGroupPlayScreen> {
  OralGroupSnap? _last;
  bool _busy = false;
  late final KeepAwake _keep;

  @override
  void initState() {
    super.initState();
    _keep = ref.read(keepAwakeProvider);
  }

  @override
  void dispose() {
    _keep.release('oralplay', this);
    super.dispose();
  }

  Future<void> _ready() async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final r = await ref.read(oralGroupServiceProvider).ready(widget.sessionId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!r.ok) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(oralFailureText(l, r.failure!))));
    }
    ref.invalidate(oralGroupMyStateProvider(widget.sessionId));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(oralGroupMyStateProvider(widget.sessionId));
    final fresh = async.value?.value;
    if (fresh != null) _last = fresh;
    final snap = _last;
    final watched =
        snap != null && snap.state.session.isOpen && !snap.state.isGraded;
    final Widget body;
    if (snap == null) {
      final f = async.value?.failure;
      body = Center(
        child: f != null
            ? Padding(
                padding: const EdgeInsets.all(FeSpace.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      oralFailureText(l, f),
                      key: const Key('oralgroup.playError'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: FeSpace.sm),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(
                        oralGroupMyStateProvider(widget.sessionId),
                      ),
                      child: Text(l.classRetry),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      );
    } else {
      body = _Ticket(
        snap: snap,
        busy: _busy,
        onReady: _ready,
        watched: watched,
      );
    }
    // Imtihon ochiq va baholanmagan: ilovadan chiqish ustozga ko‘rinadi;
    // ekran qulfi «chiqish» deb sanalmasligi uchun ekran o‘chmaydi.
    if (watched) {
      _keep.acquire('oralplay', this);
    } else {
      _keep.release('oralplay', this);
    }
    return LeaveReporter(
      enabled: watched,
      onLeave: () =>
          ref.read(oralGroupServiceProvider).reportLeave(widget.sessionId),
      child: Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.oralPlayTitle)),
        body: SafeArea(child: body),
      ),
    );
  }
}

class _Ticket extends ConsumerWidget {
  const _Ticket({
    required this.snap,
    required this.busy,
    required this.onReady,
    required this.watched,
  });

  final bool watched;
  final OralGroupSnap snap;
  final bool busy;
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final s = snap.state;
    final clock = ref.watch(oralGroupClockProvider);
    return ListView(
      key: const Key('oralgroup.playList'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        FeContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: FeSpace.sm),
              const OralGroupDemoBanner(),
              Text(
                l.oralExamTicketNo(s.ticketNo),
                key: const Key('oralgroup.ticketNo'),
                style: t.headlineSmall,
              ),
              Text(
                l.oralPlayName(s.name),
                style: t.bodyMedium?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: FeSpace.sm),
              if (s.isGraded)
                _ResultCard(state: s)
              else ...[
                if (s.isCalled)
                  FeBanner(
                    key: const Key('oralgroup.called'),
                    icon: Icons.record_voice_over_outlined,
                    text: '${l.oralPlayCalled}. ${l.oralPlayCalledHint}',
                    tone: FeBannerTone.warning,
                  )
                else if (s.isReady)
                  FeBanner(
                    key: const Key('oralgroup.waiting'),
                    icon: Icons.hourglass_top_rounded,
                    text: l.oralPlayWaiting,
                  )
                else if (!s.session.isOpen)
                  FeBanner(
                    key: const Key('oralgroup.finishedNote'),
                    icon: Icons.flag_outlined,
                    text: l.oralPlayFinished,
                  ),
                if (s.session.prepSeconds > 0 && !s.isReady)
                  Padding(
                    padding: const EdgeInsets.only(top: FeSpace.xs),
                    child: _PrepCountdown(snap: snap, clock: clock),
                  ),
              ],
              if (watched) ...[
                const SizedBox(height: FeSpace.xs),
                const AntiCheatStudentNote(),
              ],
              if (s.leaveCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: FeSpace.xxs),
                  child: Text(
                    l.oralPlayLeaveCount(s.leaveCount),
                    key: const Key('oralgroup.leaveCount'),
                    textAlign: TextAlign.center,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ),
              const SizedBox(height: FeSpace.sm),
              for (var i = 0; i < s.questions.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: FeSpace.xs),
                  child: FeCard(
                    key: Key('oralgroup.q.$i'),
                    padding: const EdgeInsets.all(FeSpace.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l.oralExamQuestionN(i + 1),
                          style: t.labelMedium?.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                        const SizedBox(height: FeSpace.xxs),
                        Text(
                          ref.watch(
                            oralGroupQuestionTextProvider(s.questions[i]),
                          ),
                          key: Key('oralgroup.qtext.$i'),
                          style: t.titleMedium,
                        ),
                        if (s.isGraded &&
                            s.scores != null &&
                            i < s.scores!.length) ...[
                          const SizedBox(height: FeSpace.xxs),
                          Text(
                            l.oralPlayScoreLine(i + 1, s.scores![i]),
                            key: Key('oralgroup.score.$i'),
                            style: t.titleSmall?.copyWith(color: c.accent),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              if (!s.isGraded && !s.isReady && s.session.isOpen) ...[
                const SizedBox(height: FeSpace.xs),
                FilledButton.icon(
                  key: const Key('oralgroup.ready'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: busy ? null : onReady,
                  icon: const Icon(Icons.pan_tool_alt_outlined),
                  label: Text(l.oralPlayReady),
                ),
              ],
              const SizedBox(height: FeSpace.xl),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.state});

  final OralGroupMyState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return FeCard(
      key: const Key('oralgroup.result'),
      color: c.accentContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.oralPlayResultTitle, style: t.titleSmall),
          const SizedBox(height: FeSpace.xxs),
          Text(
            l.oralExamTotal(state.total ?? 0),
            key: const Key('oralgroup.total'),
            style: t.headlineSmall,
          ),
        ],
      ),
    );
  }
}

/// Tayyorlanish sanog‘i: `joined_at + prep_seconds`, soat farqi
/// `server_now` bilan tuzatiladi. Faqat o‘zini qayta chizadi (1 s).
class _PrepCountdown extends StatefulWidget {
  const _PrepCountdown({required this.snap, required this.clock});

  final OralGroupSnap snap;
  final DateTime Function() clock;

  @override
  State<_PrepCountdown> createState() => _PrepCountdownState();
}

class _PrepCountdownState extends State<_PrepCountdown> {
  Timer? _timer;

  Duration get _left => widget.snap.state.prepRemaining(
    localNow: widget.clock(),
    fetchedLocalAt: widget.snap.fetchedAt,
  );

  @override
  void initState() {
    super.initState();
    _arm();
  }

  @override
  void didUpdateWidget(_PrepCountdown old) {
    super.didUpdateWidget(old);
    _arm();
  }

  void _arm() {
    _timer?.cancel();
    _timer = null;
    if (_left > Duration.zero) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {});
        if (_left <= Duration.zero) {
          _timer?.cancel();
          _timer = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final left = _left;
    final text = left > Duration.zero
        ? l.oralPlayPrepLeft(oralClock(left))
        : l.oralPlayPrepDone;
    return Semantics(
      liveRegion: false,
      child: Text(
        text,
        key: const Key('oralgroup.prep'),
        style: t.titleMedium?.copyWith(
          color: left > Duration.zero ? c.accent : c.textSecondary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
