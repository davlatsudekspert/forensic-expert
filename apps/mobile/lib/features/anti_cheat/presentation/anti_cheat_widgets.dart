import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/anti_cheat/anti_cheat_rules.dart';

/// Test yechilayotganda ilova fonga o‘tganini (`paused`/`hidden`) bir marta
/// xabar qiladi. `inactive` (tizim oynasi, bildirishnoma paneli) e’tiborsiz.
/// Qaytib kelgach (`resumed`) keyingi chiqish yana sanaladi.
///
/// Fire-and-forget: [onLeave] xatosi yutiladi, talabaga hech narsa
/// ko‘rsatilmaydi va ball o‘zgarmaydi. [enabled] `false` bo‘lsa (test
/// ketmayapti / ustoz sinovi) — hech narsa yuborilmaydi.
class LeaveReporter extends StatefulWidget {
  const LeaveReporter({
    super.key,
    required this.enabled,
    required this.onLeave,
    required this.child,
  });

  final bool enabled;
  final Future<void> Function() onLeave;
  final Widget child;

  @override
  State<LeaveReporter> createState() => _LeaveReporterState();
}

class _LeaveReporterState extends State<LeaveReporter>
    with WidgetsBindingObserver {
  bool _away = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        if (_away) return; // hidden → paused: bir chiqish — bir hisob
        _away = true;
        if (widget.enabled) unawaited(_report());
      case AppLifecycleState.resumed:
        _away = false;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _report() async {
    try {
      await widget.onLeave();
    } on Object {
      // Anti-cheat signali muhim emas: xato talabaga ta’sir qilmasin.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Ustoz sozlamalarida: variantlar tartibi har talabaga aralashishi haqida
/// doim ko‘rinadigan qisqa izoh; hovuz kichik bo‘lsa — ogohlantirish.
class AntiCheatCountNote extends StatelessWidget {
  const AntiCheatCountNote({
    super.key,
    required this.poolSize,
    required this.count,
    this.minCount = 1,
  });

  final int poolSize;
  final int count;

  /// Testdagi eng kam savol soni (tavsiya undan kichik bo‘lmasin).
  final int minCount;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final advice = questionCountAdvice(
      poolSize: poolSize,
      count: count,
      minCount: minCount,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (advice.warn)
          Padding(
            padding: const EdgeInsets.only(top: FeSpace.xs),
            child: FeBanner(
              key: const Key('ac.countWarning'),
              icon: Icons.warning_amber_outlined,
              tone: FeBannerTone.warning,
              text: l.acCountWarning(poolSize, count, advice.recommended),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: FeSpace.xxs),
          child: Text(
            l.acShuffleHint,
            key: const Key('ac.shuffleHint'),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: FeTheme.of(context).textSecondary),
          ),
        ),
      ],
    );
  }
}

/// Talabaga bir qatorli xotirjam eslatma: ustoz ilovadan chiqishni ko‘ra oladi.
class AntiCheatStudentNote extends StatelessWidget {
  const AntiCheatStudentNote({super.key});

  @override
  Widget build(BuildContext context) => Text(
    AppLocalizations.of(context).acStudentNote,
    key: const Key('ac.studentNote'),
    textAlign: TextAlign.center,
    style: Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: FeTheme.of(context).textSecondary),
  );
}

/// Ustoz qatori ostidagi ishoralar: «ilovadan chiqdi: N marta» va betaraf
/// «tez va to‘g‘ri javob — tekshirib ko‘ring». Ikkalasi ham yo‘q bo‘lsa —
/// bo‘sh joy egallamaydi. Ayblov emas, faqat ishora.
class AntiCheatFlags extends StatelessWidget {
  const AntiCheatFlags({
    super.key,
    required this.leaveCount,
    required this.tooFast,
    this.idSuffix = '',
  });

  final int leaveCount;
  final bool tooFast;

  /// Test kalitlari uchun (`ac.leave.<id>`, `ac.fast.<id>`).
  final String idSuffix;

  @override
  Widget build(BuildContext context) {
    if (leaveCount <= 0 && !tooFast) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final style = t.bodySmall?.copyWith(color: c.onWarningContainer);
    Widget chip(Key key, IconData icon, String text) => Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.warningContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c.onWarningContainer),
          const SizedBox(width: 4),
          Flexible(child: Text(text, style: style)),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Wrap(
        spacing: FeSpace.xs,
        runSpacing: 4,
        children: [
          if (leaveCount > 0)
            chip(
              Key('ac.leave$idSuffix'),
              Icons.exit_to_app,
              l.acLeftCount(leaveCount),
            ),
          if (tooFast)
            chip(Key('ac.fast$idSuffix'), Icons.bolt, l.acFastCorrect),
        ],
      ),
    );
  }
}
