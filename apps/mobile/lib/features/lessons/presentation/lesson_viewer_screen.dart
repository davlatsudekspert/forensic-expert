import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/class_quiz.dart';
import '../../../app/lessons.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_quiz/class_quiz_models.dart' show ClassFailure;
import '../../../domain/lessons/lesson_models.dart';
import '../../class_quiz/presentation/class_quiz_widgets.dart';
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

class _LessonViewerState extends ConsumerState<LessonViewer> {
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

  @override
  void initState() {
    super.initState();
    _guard = ref.read(lessonScreenGuardProvider);
    _awake = ref.read(classScreenAwakeProvider);
    _orientation = ref.read(classOrientationControlProvider);
    _guard.secure();
  }

  @override
  void dispose() {
    _guard.release();
    if (_projector) _awake.disable();
    if (_forcedLandscape) _orientation.restore();
    _pc.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<LessonPage> _pageList(BuildContext context) {
    final loc = Localizations.localeOf(context);
    if (_pages == null || _pagesLocale != loc) {
      _pages = buildLessonPages(widget.deck, AppLocalizations.of(context));
      _pagesLocale = loc;
    }
    return _pages!;
  }

  void _go(int i, int total) {
    final t = i.clamp(0, total - 1);
    if (t == _index) return;
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

  void _enterProjector() {
    _resetController();
    setState(() => _projector = true);
    unawaited(_awake.enable());
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(_askLandscape()),
    );
  }

  void _exitProjector() {
    _awake.disable();
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
                  itemCount: pages.length,
                  itemBuilder: (c, i) => ListTile(
                    key: Key('lesson.outline.$i'),
                    selected: i == _index,
                    leading: Text('${i + 1}'),
                    title: Text(
                      pages[i].title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => c.pop(i),
                  ),
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

  PageView _pageView(List<LessonPage> pages, {required bool projector}) =>
      PageView.builder(
        key: Key(projector ? 'lesson.pages.projector' : 'lesson.pages'),
        controller: _pc,
        itemCount: pages.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (c, i) => Semantics(
          label: AppLocalizations.of(c).lessonViewerSlideLabel(i + 1),
          child: LessonSlideView(page: pages[i], projector: projector),
        ),
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
    final wideNotes = MediaQuery.sizeOf(context).width >= 900;
    final notesPanel = _NotesPanel(
      key: const Key('lesson.notes'),
      text: page.notes,
    );
    final slide = _pageView(pages, projector: false);
    return Scaffold(
      appBar: AppBar(
        title: FeAppBarTitle(widget.deck.title),
        actions: [
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
              child: _notes && wideNotes
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
            if (_notes && !wideNotes)
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
    return Theme(
      data: FeThemeBuilder.dark(),
      child: Builder(
        builder: (context) {
          final c = FeTheme.of(context);
          final last = pages.length - 1;
          return Scaffold(
            key: const Key('lesson.projector'),
            backgroundColor: c.background,
            body: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapUp: (d) {
                        final w = MediaQuery.sizeOf(context).width;
                        if (d.localPosition.dx < w / 3) {
                          _go(_index - 1, pages.length);
                        } else {
                          _go(_index + 1, pages.length);
                        }
                      },
                      child: _pageView(pages, projector: true),
                    ),
                  ),
                  PositionedDirectional(
                    top: 4,
                    end: 4,
                    child: IconButton(
                      key: const Key('lesson.projectorExit'),
                      tooltip: l.lessonViewerProjectorExit,
                      icon: const Icon(Icons.close_rounded),
                      color: c.textSecondary,
                      onPressed: _exitProjector,
                    ),
                  ),
                  PositionedDirectional(
                    bottom: 8,
                    end: 16,
                    child: Text(
                      l.lessonViewerCounter(_index + 1, last + 1),
                      key: const Key('lesson.counter'),
                      style: TextStyle(color: c.textSecondary, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
