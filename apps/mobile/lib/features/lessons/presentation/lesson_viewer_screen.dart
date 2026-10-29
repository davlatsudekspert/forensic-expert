import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/class_quiz.dart';
import '../../../app/lessons.dart';
import '../../../app/plan.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/settings/app_settings.dart' show UserMode;
import '../../../core/settings/settings_controller.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_quiz/class_quiz_models.dart' show ClassFailure;
import '../../../domain/lessons/lesson_models.dart';
import '../../../domain/plan/plan_models.dart';
import '../../class_groups/presentation/topic_test_choice.dart';
import '../../class_quiz/presentation/class_quiz_widgets.dart';
import '../../pro/presentation/pro_gate.dart';
import 'lesson_slide_view.dart';

/// Dars ko‘rish oynasi (faqat ilova ichida). Yuklash, xato holatlari va
/// [LessonViewer].
class LessonViewerScreen extends ConsumerWidget {
  const LessonViewerScreen({super.key, required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(lessonDeckProvider(topicId));
    final r = async.value;
    final deck = r?.value;
    // Pro qulfi (ustoz: dastlabki 3 dars; apparatlar: 1-dars) — to‘g‘ridan
    // to‘g‘ri havolada ham ochilmaydi.
    final locks = ref.watch(lessonLocksProvider);
    final lock = locks?[topicId];
    if (lock != null) {
      return Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.lessonsTitle)),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(FeSpace.md),
            children: [
              ProFeatureLock(feature: lock),
              const SizedBox(height: FeSpace.sm),
              FeBanner(
                icon: Icons.health_and_safety_outlined,
                text: l.proFreeAlways,
              ),
            ],
          ),
        ),
      );
    }
    if (locks == null && ref.watch(lessonListProvider('')).isLoading) {
      return Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.lessonsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (deck != null) return LessonViewer(deck: deck);
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.lessonsTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(FeSpace.lg),
          child: async.isLoading && r == null
              ? const CircularProgressIndicator()
              : LessonFailureView(
                  failure: r?.failure,
                  onRetry: () => ref.invalidate(lessonDeckProvider(topicId)),
                ),
        ),
      ),
    );
  }
}

/// Xato holati (ro‘yxat va ko‘rish oynasi uchun umumiy).
class LessonFailureView extends StatelessWidget {
  const LessonFailureView({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  final ClassFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final forbidden = failure == ClassFailure.forbidden;
    return FeEmptyState(
      key: Key(forbidden ? 'lessons.forbidden' : 'lessons.error'),
      icon: forbidden
          ? Icons.lock_outline
          : failure == ClassFailure.offline
          ? Icons.wifi_off_rounded
          : Icons.cloud_off_outlined,
      body: forbidden
          ? l.lessonsForbidden
          : classFailureText(l, failure ?? ClassFailure.server),
      actionLabel: forbidden ? null : l.lessonsRetry,
      actionIcon: Icons.refresh_rounded,
      onAction: forbidden ? null : onRetry,
    );
  }
}

/// Ko‘rish oynasi: oddiy rejim (slayd, eslatmalar, ro‘yxat) va proyektor
/// rejimi (butun ekran, gorizontal, katta matn, eslatmasiz).
class LessonViewer extends ConsumerStatefulWidget {
  const LessonViewer({super.key, required this.deck});

  final LessonDeck deck;

  @override
  ConsumerState<LessonViewer> createState() => _LessonViewerState();
}

class _LessonViewerState extends ConsumerState<LessonViewer>
    with WidgetsBindingObserver {
  late PageController _pc = PageController();
  final _focus = FocusNode();
  int _index = 0;
  bool _notes = false;
  bool _projector = false;
  bool _forcedLandscape = false;
  late final LessonScreenGuard _guard;
  late final ClassScreenAwake _awake;
  late final ClassOrientationControl _orientation;
  List<LessonPage>? _pages;
  Locale? _pagesLocale;

  /// Proyektor boshqaruvlari (chiqish, oldingi/keyingi): ~3 s dan keyin
  /// yashiriladi, ekranga bosilganda qayta ko‘rinadi.
  bool _controls = true;
  Timer? _hideTimer;
  static const _hideAfter = Duration(seconds: 3);

  // Avto-varaqlash: rejim, tezlik, pauza. Taymer faqat ekran ochiq, ilova
  // oldingi planda va pauza bo‘lmaganda ishlaydi.
  bool _auto = false;
  bool _autoPaused = false;
  int _autoSeconds = 30;
  bool _selfNav = false;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadAuto());
    _guard = ref.read(lessonScreenGuardProvider);
    _awake = ref.read(classScreenAwakeProvider);
    _orientation = ref.read(classOrientationControlProvider);
    // Skrinshot/yozib olish himoyasi (FLAG_SECURE) YOQILMAYDI: ustozlar darsni
    // televizorga uzatadi (Cast/Miracast/HDMI), himoya esa ekranni qora qiladi.
    // `release()` — oldingi holatdan qolgan bayroqni olib tashlash uchun.
    unawaited(_guard.release());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoTimer?.cancel();
    _guard.release();
    _hideTimer?.cancel();
    if (_projector || _auto) _awake.disable();
    if (_forcedLandscape) _orientation.restore();
    _pc.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleAuto();
    } else {
      _autoTimer?.cancel();
    }
  }

  Future<void> _loadAuto() async {
    final p = await ref.read(lessonAutoStoreProvider).load();
    if (!mounted) return;
    setState(() {
      _auto = p.auto;
      _autoSeconds = p.seconds;
    });
    if (_auto) {
      unawaited(_awake.enable());
      _scheduleAuto();
    }
  }

  void _saveAuto() => unawaited(
    ref
        .read(lessonAutoStoreProvider)
        .save(LessonAutoPrefs(auto: _auto, seconds: _autoSeconds)),
  );

  /// Keyingi o‘tishni rejalashtiradi (faqat Avto yoniq va pauzada emas).
  void _scheduleAuto() {
    _autoTimer?.cancel();
    if (!_auto || _autoPaused || !mounted) return;
    _autoTimer = Timer(Duration(seconds: _autoSeconds), _autoTick);
  }

  void _autoTick() {
    if (!mounted || !_auto || _autoPaused) return;
    final total = _pages?.length ?? 0;
    if (total == 0 || _index >= total - 1) {
      _setAuto(false); // oxirgi slayd: to‘xtaydi, boshiga qaytmaydi
      return;
    }
    _go(_index + 1, total, auto: true);
  }

  void _setAuto(bool on) {
    _autoTimer?.cancel();
    setState(() {
      _auto = on;
      _autoPaused = false;
    });
    if (on) {
      unawaited(_awake.enable());
      _scheduleAuto();
    } else if (!_projector) {
      unawaited(_awake.disable());
    }
    _saveAuto();
  }

  void _setAutoSeconds(int seconds) {
    setState(() => _autoSeconds = seconds);
    _scheduleAuto();
    _saveAuto();
  }

  void _toggleAutoPause() {
    if (!_auto) return;
    setState(() => _autoPaused = !_autoPaused);
    if (_autoPaused) {
      _autoTimer?.cancel();
    } else {
      _scheduleAuto();
    }
  }

  /// Foydalanuvchi o‘zi varaqlasa — avto vaqtincha to‘xtaydi.
  void _pauseByUser() {
    if (_auto && !_autoPaused) {
      _autoTimer?.cancel();
      setState(() => _autoPaused = true);
    }
  }

  Future<void> _openAutoSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (c) => StatefulBuilder(
        builder: (c, setSheet) {
          final l = AppLocalizations.of(c);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                FeSpace.md,
                0,
                FeSpace.md,
                FeSpace.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l.lessonAutoTooltip,
                      style: Theme.of(c).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: FeSpace.sm),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<bool>(
                      key: const Key('lesson.autoMode'),
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: Text(l.lessonAutoManual),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text(l.lessonAutoAuto),
                        ),
                      ],
                      selected: {_auto},
                      onSelectionChanged: (v) {
                        _setAuto(v.first);
                        setSheet(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: FeSpace.md),
                  Text(
                    l.lessonAutoSpeed,
                    style: Theme.of(c).textTheme.labelLarge,
                  ),
                  const SizedBox(height: FeSpace.xs),
                  Wrap(
                    spacing: FeSpace.xs,
                    runSpacing: FeSpace.xs,
                    children: [
                      for (final n in LessonAutoPrefs.options)
                        ChoiceChip(
                          key: Key('lesson.autoSeconds.$n'),
                          label: Text(l.lessonAutoSeconds(n)),
                          selected: _autoSeconds == n,
                          onSelected: (_) {
                            _setAutoSeconds(n);
                            setSheet(() {});
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<LessonPage> _pageList(BuildContext context) {
    final loc = Localizations.localeOf(context);
    if (_pages == null || _pagesLocale != loc) {
      _pages = buildLessonPages(widget.deck, AppLocalizations.of(context));
      _pagesLocale = loc;
    }
    return _pages!;
  }

  void _go(int i, int total, {bool auto = false}) {
    final t = i.clamp(0, total - 1);
    if (t == _index) return;
    _selfNav = auto;
    if (MediaQuery.disableAnimationsOf(context)) {
      _pc.jumpToPage(t);
      return;
    }
    _pc.animateToPage(
      t,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _resetController() {
    final old = _pc;
    _pc = PageController(initialPage: _index);
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  void _showControls() {
    _hideTimer?.cancel();
    if (!_controls) setState(() => _controls = true);
    _hideTimer = Timer(_hideAfter, () {
      if (mounted) setState(() => _controls = false);
    });
  }

  void _enterProjector() {
    _resetController();
    setState(() => _projector = true);
    _showControls();
    unawaited(_awake.enable());
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(_askLandscape()),
    );
  }

  void _exitProjector() {
    _hideTimer?.cancel();
    _controls = true;
    if (!_auto) _awake.disable();
    if (_forcedLandscape) {
      _forcedLandscape = false;
      _orientation.restore();
    }
    _resetController();
    setState(() => _projector = false);
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
        key: const Key('class.landscapeDialog'),
        title: Text(l.classLandscapePrompt),
        actions: [
          TextButton(
            key: const Key('class.landscapeNo'),
            onPressed: () => c.pop(false),
            child: Text(l.classLandscapeNo),
          ),
          FilledButton(
            key: const Key('class.landscapeYes'),
            onPressed: () => c.pop(true),
            child: Text(l.classLandscapeYes),
          ),
        ],
      ),
    );
    if (yes == true) {
      _forcedLandscape = true;
      await _orientation.landscape();
    }
  }

  Future<void> _openOutline(List<LessonPage> pages) async {
    final l = AppLocalizations.of(context);
    // Bo‘lingan slayd ro‘yxatda bir marta (birinchi sahifasi).
    final entries = [
      for (var i = 0; i < pages.length; i++)
        if (pages[i].part == 1) i,
    ];
    final current = pages[_index].group;
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(c).height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  FeSpace.md,
                  0,
                  FeSpace.md,
                  FeSpace.xs,
                ),
                child: Semantics(
                  header: true,
                  child: Text(
                    l.lessonViewerOutline,
                    style: Theme.of(c).textTheme.titleMedium,
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  key: const Key('lesson.outline'),
                  shrinkWrap: true,
                  itemCount: entries.length,
                  itemBuilder: (c, e) {
                    final i = entries[e];
                    return ListTile(
                      key: Key('lesson.outline.$e'),
                      selected: pages[i].group == current,
                      leading: Text((i + 1).toString()),
                      title: Text(
                        pages[i].baseTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => c.pop(i),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null && mounted) {
      _pc.jumpToPage(picked);
    }
  }

  /// Mavzu testini boshlash: sinf testi yaratish oqimi, mavzu tanlangan holda
  /// (`deck_id` == test mavzusi id).
  /// «Mavzu testi»: tanlov — guruhga topshirish / o‘zim yechib ko‘rish /
  /// jonli sinf testi (darhol o‘ziga test ochilmaydi).
  void _startQuiz() => showTopicTestChoice(context, ref, widget.deck.deckId);

  KeyEventResult _onKey(KeyEvent e, int total) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.arrowRight ||
        k == LogicalKeyboardKey.arrowDown ||
        k == LogicalKeyboardKey.pageDown ||
        k == LogicalKeyboardKey.space) {
      _go(_index + 1, total);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowLeft ||
        k == LogicalKeyboardKey.arrowUp ||
        k == LogicalKeyboardKey.pageUp) {
      _go(_index - 1, total);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.escape && _projector) {
      _exitProjector();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  PageView _pageView(
    List<LessonPage> pages, {
    required bool projector,
    Widget? lastAction,
  }) => PageView.builder(
    key: Key(projector ? 'lesson.pages.projector' : 'lesson.pages'),
    controller: _pc,
    itemCount: pages.length,
    onPageChanged: (i) {
      setState(() => _index = i);
      if (_selfNav) {
        _selfNav = false;
        _scheduleAuto();
      } else {
        _pauseByUser();
      }
    },
    itemBuilder: (c, i) {
      final l = AppLocalizations.of(c);
      return Semantics(
        label: l.lessonViewerSlideLabel(i + 1),
        child: LessonSlideView(
          page: pages[i],
          projector: projector,
          counter: projector
              ? l.lessonViewerCounter(i + 1, pages.length)
              : null,
          action: i == pages.length - 1 ? lastAction : null,
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final pages = _pageList(context);
    if (_index >= pages.length) _index = pages.length - 1;
    final body = _projector
        ? _projectorBody(context, pages)
        : _normalBody(context, pages);
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: (n, e) => _onKey(e, pages.length),
      child: PopScope(
        canPop: !_projector,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _projector) _exitProjector();
        },
        child: body,
      ),
    );
  }

  Widget _normalBody(BuildContext context, List<LessonPage> pages) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final page = pages[_index];
    final lang = Localizations.localeOf(context).languageCode;
    final pending = lang != widget.deck.sourceLang;
    // «Ustoz eslatmalari» (vaqt, muhokama savollari, tipik xatolar) faqat
    // «Ustoz» rejimida — Mutaxassis/Talabaga bu panel ko‘rinmaydi.
    final canNotes =
        ref.watch(settingsControllerProvider.select((s) => s.userMode)) ==
        UserMode.teacher;
    final wideNotes = MediaQuery.sizeOf(context).width >= 900;
    final quizReady = ref.watch(
      lessonQuizAvailableProvider(widget.deck.deckId),
    );
    final notesPanel = _NotesPanel(
      key: const Key('lesson.notes'),
      text: page.notes,
    );
    final slide = _auto
        ? GestureDetector(
            key: const Key('lesson.autoTap'),
            behavior: HitTestBehavior.translucent,
            onTap: _toggleAutoPause,
            child: _pageView(pages, projector: false),
          )
        : _pageView(pages, projector: false);
    return Scaffold(
      appBar: AppBar(
        title: FeAppBarTitle(widget.deck.title),
        actions: [
          // Tor telefonda sarlavhaga joy qoladi: test tugmasi oxirgi slaydda bor.
          if (MediaQuery.sizeOf(context).width >= 420)
            IconButton(
              key: const Key('lesson.quizAppBar'),
              tooltip: quizReady ? l.lessonQuizStart : l.lessonQuizSoon,
              icon: const Icon(Icons.quiz_outlined),
              onPressed: quizReady ? _startQuiz : null,
            ),
          if (canNotes)
            IconButton(
              key: const Key('lesson.notesToggle'),
              tooltip: l.lessonViewerNotes,
              isSelected: _notes,
              icon: const Icon(Icons.sticky_note_2_outlined),
              selectedIcon: const Icon(Icons.sticky_note_2),
              onPressed: () => setState(() => _notes = !_notes),
            ),
          IconButton(
            key: const Key('lesson.outlineButton'),
            tooltip: l.lessonViewerOutline,
            icon: const Icon(Icons.view_list_outlined),
            onPressed: () => _openOutline(pages),
          ),
          IconButton(
            key: const Key('lesson.autoButton'),
            tooltip: l.lessonAutoTooltip,
            isSelected: _auto,
            icon: const Icon(Icons.slideshow_outlined),
            selectedIcon: const Icon(Icons.slideshow),
            onPressed: _openAutoSheet,
          ),
          IconButton(
            key: const Key('lesson.projectorButton'),
            tooltip: l.lessonViewerProjector,
            icon: const Icon(Icons.cast_outlined),
            onPressed: _enterProjector,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (pending)
              Padding(
                padding: const EdgeInsets.only(top: FeSpace.xxs),
                child: Text(
                  l.lessonsTranslationPending,
                  key: const Key('lesson.translationPending'),
                  style: t.labelSmall?.copyWith(color: c.textSecondary),
                ),
              ),
            Expanded(
              child: canNotes && _notes && wideNotes
                  ? Row(
                      children: [
                        Expanded(flex: 3, child: slide),
                        VerticalDivider(width: 1, color: c.border),
                        Expanded(
                          flex: 2,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(FeSpace.md),
                            child: notesPanel,
                          ),
                        ),
                      ],
                    )
                  : slide,
            ),
            if (canNotes && _notes && !wideNotes)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.3,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.surfaceSunken,
                    border: Border(top: BorderSide(color: c.border)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(FeSpace.md),
                    child: SizedBox(width: double.infinity, child: notesPanel),
                  ),
                ),
              ),
            if (_index == pages.length - 1) ...[
              _QuizCta(ready: quizReady, onStart: _startQuiz),
              // Dars oxiri: bitta kontekstli taklif (popup emas).
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: FeSpace.md),
                child: LessonAccess.isInstrument(widget.deck.topicId)
                    ? ProContextOffer(
                        feature: ProFeature.instrumentsCourseFull,
                        benefit: l.proCtxInstrumentsRest,
                      )
                    : ProContextOffer(
                        feature: ProFeature.allLessons,
                        benefit: l.proCtxAllLessons,
                      ),
              ),
            ],
            if (_auto)
              _AutoBar(
                seconds: _autoSeconds,
                paused: _autoPaused,
                onToggle: _toggleAutoPause,
              ),
            _ControlBar(
              index: _index,
              total: pages.length,
              onPrev: _index > 0 ? () => _go(_index - 1, pages.length) : null,
              onNext: _index < pages.length - 1
                  ? () => _go(_index + 1, pages.length)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _projectorBody(BuildContext context, List<LessonPage> pages) {
    final l = AppLocalizations.of(context);
    final quizReady = ref.watch(
      lessonQuizAvailableProvider(widget.deck.deckId),
    );
    return Theme(
      data: FeThemeBuilder.dark(),
      child: Builder(
        builder: (context) {
          final c = FeTheme.of(context);
          final last = pages.length - 1;
          Widget control(Widget child) => IgnorePointer(
            ignoring: !_controls,
            child: AnimatedOpacity(
              opacity: _controls ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: child,
            ),
          );
          return Scaffold(
            key: const Key('lesson.projector'),
            backgroundColor: c.background,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, box) => Stack(
                  children: [
                    Positioned.fill(
                      // Chap yarmi — oldingi, o‘ng yarmi — keyingi sahifa;
                      // har bosish boshqaruvlarni qayta ko‘rsatadi.
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapUp: (d) {
                          _showControls();
                          if (d.localPosition.dx < box.maxWidth / 2) {
                            _go(_index - 1, pages.length);
                          } else {
                            _go(_index + 1, pages.length);
                          }
                        },
                        child: _pageView(
                          pages,
                          projector: true,
                          lastAction: _ProjectorQuiz(
                            ready: quizReady,
                            onStart: _startQuiz,
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 4,
                      end: 4,
                      child: control(
                        IconButton(
                          key: const Key('lesson.projectorExit'),
                          tooltip: l.lessonViewerProjectorExit,
                          icon: const Icon(Icons.close_rounded),
                          color: c.textSecondary,
                          onPressed: _exitProjector,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 8,
                      child: Center(
                        child: control(
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: c.surfaceRaised.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(FeRadius.md),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  key: const Key('lesson.projectorPrev'),
                                  tooltip: l.lessonViewerPrev,
                                  icon: const Icon(Icons.chevron_left_rounded),
                                  color: c.textSecondary,
                                  onPressed: _index > 0
                                      ? () {
                                          _showControls();
                                          _go(_index - 1, pages.length);
                                        }
                                      : null,
                                ),
                                IconButton(
                                  key: const Key('lesson.projectorAuto'),
                                  tooltip: !_auto
                                      ? l.lessonAutoAuto
                                      : _autoPaused
                                      ? l.lessonAutoResume
                                      : l.lessonAutoPause,
                                  icon: Icon(
                                    !_auto || _autoPaused
                                        ? Icons.play_arrow_rounded
                                        : Icons.pause_rounded,
                                  ),
                                  color: c.textSecondary,
                                  onPressed: () {
                                    _showControls();
                                    if (!_auto) {
                                      _setAuto(true);
                                    } else {
                                      _toggleAutoPause();
                                    }
                                  },
                                ),
                                IconButton(
                                  key: const Key('lesson.projectorNext'),
                                  tooltip: l.lessonViewerNext,
                                  icon: const Icon(Icons.chevron_right_rounded),
                                  color: c.textSecondary,
                                  onPressed: _index < last
                                      ? () {
                                          _showControls();
                                          _go(_index + 1, pages.length);
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Proyektor kanvasidagi (oxirgi sahifa, pastki o‘ng) test tugmasi —
/// kanvas dizayn o‘lchamlarida (1280×720 ga nisbatan).
class _ProjectorQuiz extends StatelessWidget {
  const _ProjectorQuiz({required this.ready, required this.onStart});

  final bool ready;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FilledButton.icon(
          key: const Key('lesson.quizStart'),
          onPressed: ready ? onStart : null,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 60),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            textStyle: const TextStyle(
              fontFamily: FeFonts.sans,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: const Icon(Icons.quiz_outlined, size: 26),
          label: Text(l.lessonQuizStart),
        ),
        if (!ready)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l.lessonQuizSoon,
              key: const Key('lesson.quizSoon'),
              style: TextStyle(fontSize: 18, color: c.textSecondary),
            ),
          ),
      ],
    );
  }
}

class _QuizCta extends StatelessWidget {
  const _QuizCta({required this.ready, required this.onStart});

  final bool ready;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        FeSpace.md,
        FeSpace.xs,
        FeSpace.md,
        FeSpace.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            key: const Key('lesson.quizStart'),
            onPressed: ready ? onStart : null,
            icon: const Icon(Icons.quiz_outlined),
            label: Text(l.lessonQuizStart, textAlign: TextAlign.center),
          ),
          if (!ready)
            Padding(
              padding: const EdgeInsets.only(top: FeSpace.xxs),
              child: Text(
                l.lessonQuizSoon,
                key: const Key('lesson.quizSoon'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: c.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotesPanel extends StatelessWidget {
  const _NotesPanel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(l.lessonViewerNotes, style: t.titleSmall),
        ),
        const SizedBox(height: FeSpace.xs),
        Text(
          text.isEmpty ? l.lessonViewerNotesEmpty : text,
          style: t.bodyMedium?.copyWith(
            color: text.isEmpty ? c.textSecondary : c.textPrimary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Avto-varaqlash holati: tezlik yoki «Pauza» va pauza/davom tugmasi.
class _AutoBar extends StatelessWidget {
  const _AutoBar({
    required this.seconds,
    required this.paused,
    required this.onToggle,
  });

  final int seconds;
  final bool paused;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('lesson.autoToggle'),
            tooltip: paused ? l.lessonAutoResume : l.lessonAutoPause,
            icon: Icon(paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
            onPressed: onToggle,
          ),
          Expanded(
            child: Text(
              paused ? l.lessonAutoPaused : l.lessonAutoRunning(seconds),
              key: const Key('lesson.autoStatus'),
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.index,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  final int index;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: FeSpace.xs),
        child: Row(
          children: [
            IconButton(
              key: const Key('lesson.prev'),
              tooltip: l.lessonViewerPrev,
              icon: const Icon(Icons.chevron_left_rounded, size: 32),
              onPressed: onPrev,
            ),
            Expanded(
              child: Text(
                l.lessonViewerCounter(index + 1, total),
                key: const Key('lesson.counter'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            IconButton(
              key: const Key('lesson.next'),
              tooltip: l.lessonViewerNext,
              icon: const Icon(Icons.chevron_right_rounded, size: 32),
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}
