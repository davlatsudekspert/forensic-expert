import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/keep_awake.dart';
import '../../../app/plan.dart';
import '../../../app/routes.dart';
import '../../../app/tts.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../data/audio/lesson_audio_remote.dart';
import '../../../domain/plan/plan_models.dart' show ProFeature;
import '../../../domain/ports/tts_ports.dart';

/// «Tinglash» tugmasi holati.
enum ListenState { idle, loading, playing, paused, finished }

/// Berilgan matnni ovozga aylantirib ijro etadigan ixcham tugma.
///
/// idle → loading (aylanma) → playing (pauza) → paused (davom) → finished
/// (qayta tinglash). Xatoda tushunarli SnackBar chiqadi, matn o‘qiladigan
/// bo‘lib qoladi. Vidjet olib tashlansa yoki [text] o‘zgarsa, ijro to‘xtaydi.
/// Server sozlanmagan bo‘lsa (yoki matn bo‘sh) — hech narsa ko‘rsatilmaydi.
class ListenButton extends ConsumerStatefulWidget {
  const ListenButton({
    super.key,
    required this.text,
    this.color,
    this.labeled = false,
    this.lang,
    this.remoteUrl,
    this.autoStart = false,
    this.onFinished,
    this.onStateChanged,
  });

  final String text;
  final Color? color;

  /// `true` — «🔊 Tinglash» yozuvli tugma (dars pastki paneli).
  final bool labeled;

  /// Matn tili — ovoz shu tilning sof talaffuzida o‘qiydi.
  final String? lang;

  /// Oldindan tayyorlangan ovoz (R2). Topilmasa — odatdagi ovoz xizmati.
  final String? remoteUrl;

  /// `true` — vidjet paydo bo‘lishi bilan o‘zi o‘qiy boshlaydi (dars
  /// «Ovoz tugagach» avto rejimi).
  final bool autoStart;

  /// Matn oxirigacha o‘qib bo‘linganda (pauza/xatoda chaqirilmaydi).
  final VoidCallback? onFinished;

  /// Holat o‘zgarganda (masalan, o‘qilayotgan matnni ekranda ko‘rsatish uchun).
  final ValueChanged<ListenState>? onStateChanged;

  @override
  ConsumerState<ListenButton> createState() => _ListenButtonState();
}

class _ListenButtonState extends ConsumerState<ListenButton>
    with WidgetsBindingObserver {
  ListenState _state = ListenState.idle;
  late final KeepAwake _keep;
  bool _foreground = true;

  /// Ovoz chalinayotganda (va ilova oldingi planda) ekran o‘chmaydi.
  void _syncAwake() {
    if (_state == ListenState.playing && _foreground) {
      _keep.acquire('listen', this);
    } else {
      _keep.release('listen', this);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncAwake();
  }

  void _setListen(ListenState v) {
    setState(() => _state = v);
    _syncAwake();
    widget.onStateChanged?.call(v);
  }

  TtsPlayer? _player;
  StreamSubscription<void>? _sub;
  List<String> _paths = const [];
  int _part = 0;

  /// Har yangi so‘rov/to‘xtatishda oshadi: kechikib kelgan natija tashlanadi.
  int _gen = 0;

  @override
  void initState() {
    super.initState();
    _keep = ref.read(keepAwakeProvider);
    WidgetsBinding.instance.addObserver(this);
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _state != ListenState.idle) return;
        if (widget.text.trim().isEmpty) {
          widget.onFinished?.call();
          return;
        }
        if (!ref.read(ttsServiceProvider).isConfigured) return;
        if (!proOpen(ref, ProFeature.listen)) return;
        unawaited(_start());
      });
    }
  }

  @override
  void didUpdateWidget(covariant ListenButton old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) {
      unawaited(_reset());
    } else if (old.autoStart && !widget.autoStart) {
      // Avto pauza/o‘chirildi — ovoz to‘xtaydi.
      unawaited(_reset());
    } else if (!old.autoStart &&
        widget.autoStart &&
        _state == ListenState.idle) {
      // Avto davom ettirildi — shu slayd qaytadan o‘qiladi (tugaganini
      // qayta o‘qimaymiz).
      unawaited(_start());
    } else if (!old.autoStart &&
        widget.autoStart &&
        _state == ListenState.finished) {
      // Avto yoqilganda bu slayd allaqachon o‘qilgan — keyingisiga.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => mounted ? widget.onFinished?.call() : null,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _keep.release('listen', this);
    _gen++;
    final player = _player;
    unawaited(_sub?.cancel());
    _sub = null;
    _player = null;
    if (player != null) {
      unawaited(
        // Ketma-ket: avval to‘xtatish, so‘ng bo‘shatish (xatolar yutiladi).
        () async {
          try {
            await player.stop();
            await player.dispose();
          } on Object {
            // Platforma xatosi dispose’ni to‘xtatmasin.
          }
        }(),
      );
    }
    super.dispose();
  }

  Future<void> _reset() async {
    _gen++;
    _paths = const [];
    _part = 0;
    try {
      await _player?.stop();
    } on Object {
      // e’tiborsiz
    }
    if (mounted) _setListen(ListenState.idle);
  }

  TtsPlayer _ensurePlayer() {
    final existing = _player;
    if (existing != null) return existing;
    final p = ref.read(ttsPlayerFactoryProvider)();
    _player = p;
    _sub = p.onComplete.listen((_) => unawaited(_onPartDone()));
    return p;
  }

  Future<void> _onPartDone() async {
    if (!mounted || _state != ListenState.playing) return;
    final next = _part + 1;
    if (next < _paths.length) {
      _part = next;
      await _playPart(_gen);
    } else {
      _setListen(ListenState.finished);
      widget.onFinished?.call();
    }
  }

  Future<void> _playPart(int gen) async {
    try {
      await _ensurePlayer().play(_paths[_part]);
    } on Object {
      if (!mounted || gen != _gen) return;
      _setListen(ListenState.idle);
      _snack(AppLocalizations.of(context).ttsErrGeneric);
    }
  }

  Future<void> _start() async {
    final gen = ++_gen;
    final l = AppLocalizations.of(context);
    _setListen(ListenState.loading);
    final remoteUrl = widget.remoteUrl;
    if (remoteUrl != null) {
      final local = await fetchLessonAudio(remoteUrl);
      if (!mounted || gen != _gen) return;
      if (local != null) {
        _paths = [local];
        _part = 0;
        _setListen(ListenState.playing);
        await _playPart(gen);
        return;
      }
    }
    final TtsAudio audio;
    try {
      audio = await ref
          .read(ttsServiceProvider)
          .synthesize(widget.text, lang: widget.lang);
    } on TtsException catch (e) {
      if (!mounted || gen != _gen) return;
      _setListen(ListenState.idle);
      _snack(_message(l, e.failure));
      return;
    } on Object {
      if (!mounted || gen != _gen) return;
      _setListen(ListenState.idle);
      _snack(l.ttsErrGeneric);
      return;
    }
    if (!mounted || gen != _gen) return;
    if (audio.paths.isEmpty) {
      _setListen(ListenState.idle);
      _snack(l.ttsErrGeneric);
      return;
    }
    _paths = audio.paths;
    _part = 0;
    _setListen(ListenState.playing);
    await _playPart(gen);
  }

  Future<void> _pause() async {
    _setListen(ListenState.paused);
    try {
      await _player?.pause();
    } on Object {
      // e’tiborsiz: holat UI’da pauza
    }
  }

  Future<void> _resume() async {
    _setListen(ListenState.playing);
    try {
      await _player?.resume();
    } on Object {
      if (!mounted) return;
      _setListen(ListenState.idle);
    }
  }

  Future<void> _replay() async {
    if (_paths.isEmpty) return _start();
    final gen = ++_gen;
    _part = 0;
    _setListen(ListenState.playing);
    await _playPart(gen);
  }

  String _message(AppLocalizations l, TtsFailure f) => switch (f) {
    TtsFailure.notSignedIn => l.ttsErrSignIn,
    TtsFailure.dailyLimit => l.ttsErrDailyLimit,
    TtsFailure.busy => l.ttsErrBusy,
    TtsFailure.offline => l.ttsErrOffline,
    TtsFailure.notConfigured => l.ttsErrNotConfigured,
    TtsFailure.tooLong => l.ttsErrTooLong,
    TtsFailure.empty => l.ttsErrGeneric,
  };

  void _snack(String message) {
    if (!mounted) return;
    final m = ScaffoldMessenger.maybeOf(context);
    m?.hideCurrentSnackBar();
    m?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final configured = ref.watch(
      ttsServiceProvider.select((s) => s.isConfigured),
    );
    if (!configured || widget.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    // Qat’iy Bepul/Pro bo‘linishida (2026-10-31) «Tinglash» Pro: tugma
    // ko‘rinadi, lekin qulf belgisi bilan Pro sahifasiga olib boradi.
    if (!proOpen(ref, ProFeature.listen)) {
      return IconButton(
        key: const Key('tts.locked'),
        tooltip: l.ttsListen,
        icon: Icon(Icons.lock_outline, color: widget.color),
        onPressed: () => context.push(Routes.pro),
      );
    }
    final (icon, tooltip, onTap) = switch (_state) {
      ListenState.idle => (Icons.volume_up_outlined, l.ttsListen, _start),
      ListenState.loading => (null, l.ttsLoading, null),
      ListenState.playing => (Icons.pause_rounded, l.ttsPause, _pause),
      ListenState.paused => (Icons.play_arrow_rounded, l.ttsResume, _resume),
      ListenState.finished => (Icons.replay_rounded, l.ttsReplay, _replay),
    };
    final iconW = icon == null
        ? const SizedBox(
            key: Key('tts.loading'),
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Icon(icon, key: Key('tts.icon.${_state.name}'));
    // Yozuvli tugma (egasi topa olmadi, 2026-11-02): «🔊 Tinglash».
    if (widget.labeled) {
      return Tooltip(
        message: tooltip,
        child: FilledButton.tonalIcon(
          key: const Key('tts.listen'),
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: FeSpace.sm),
          ),
          onPressed: onTap == null ? null : () => unawaited(onTap()),
          icon: iconW,
          label: Text(tooltip, maxLines: 1, overflow: TextOverflow.fade),
        ),
      );
    }
    return IconButton(
      key: const Key('tts.listen'),
      tooltip: tooltip,
      color: widget.color,
      onPressed: onTap == null ? null : () => unawaited(onTap()),
      icon: iconW,
    );
  }
}
