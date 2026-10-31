import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/plan.dart';
import '../../../app/routes.dart';
import '../../../app/tts.dart';
import '../../../core/l10n/generated/app_localizations.dart';
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
  const ListenButton({super.key, required this.text, this.color});

  final String text;
  final Color? color;

  @override
  ConsumerState<ListenButton> createState() => _ListenButtonState();
}

class _ListenButtonState extends ConsumerState<ListenButton> {
  ListenState _state = ListenState.idle;
  TtsPlayer? _player;
  StreamSubscription<void>? _sub;
  List<String> _paths = const [];
  int _part = 0;

  /// Har yangi so‘rov/to‘xtatishda oshadi: kechikib kelgan natija tashlanadi.
  int _gen = 0;

  @override
  void didUpdateWidget(covariant ListenButton old) {
    super.didUpdateWidget(old);
    if (old.text != widget.text) unawaited(_reset());
  }

  @override
  void dispose() {
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
    if (mounted) setState(() => _state = ListenState.idle);
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
      setState(() => _state = ListenState.finished);
    }
  }

  Future<void> _playPart(int gen) async {
    try {
      await _ensurePlayer().play(_paths[_part]);
    } on Object {
      if (!mounted || gen != _gen) return;
      setState(() => _state = ListenState.idle);
      _snack(AppLocalizations.of(context).ttsErrGeneric);
    }
  }

  Future<void> _start() async {
    final gen = ++_gen;
    final l = AppLocalizations.of(context);
    setState(() => _state = ListenState.loading);
    final TtsAudio audio;
    try {
      audio = await ref.read(ttsServiceProvider).synthesize(widget.text);
    } on TtsException catch (e) {
      if (!mounted || gen != _gen) return;
      setState(() => _state = ListenState.idle);
      _snack(_message(l, e.failure));
      return;
    } on Object {
      if (!mounted || gen != _gen) return;
      setState(() => _state = ListenState.idle);
      _snack(l.ttsErrGeneric);
      return;
    }
    if (!mounted || gen != _gen) return;
    if (audio.paths.isEmpty) {
      setState(() => _state = ListenState.idle);
      _snack(l.ttsErrGeneric);
      return;
    }
    _paths = audio.paths;
    _part = 0;
    setState(() => _state = ListenState.playing);
    await _playPart(gen);
  }

  Future<void> _pause() async {
    setState(() => _state = ListenState.paused);
    try {
      await _player?.pause();
    } on Object {
      // e’tiborsiz: holat UI’da pauza
    }
  }

  Future<void> _resume() async {
    setState(() => _state = ListenState.playing);
    try {
      await _player?.resume();
    } on Object {
      if (!mounted) return;
      setState(() => _state = ListenState.idle);
    }
  }

  Future<void> _replay() async {
    if (_paths.isEmpty) return _start();
    final gen = ++_gen;
    _part = 0;
    setState(() => _state = ListenState.playing);
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
    return IconButton(
      key: const Key('tts.listen'),
      tooltip: tooltip,
      color: widget.color,
      onPressed: onTap == null ? null : () => unawaited(onTap()),
      icon: icon == null
          ? const SizedBox(
              key: Key('tts.loading'),
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Icon(icon, key: Key('tts.icon.${_state.name}')),
    );
  }
}
