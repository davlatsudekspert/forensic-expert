import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/lessons.dart';
import '../../../app/plan.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/lessons/lesson_models.dart';
import '../../../domain/plan/plan_models.dart';
import '../../class_quiz/presentation/class_quiz_widgets.dart'
    show ClassDemoBanner;
import '../../class_quiz/presentation/teacher_panel_screen.dart'
    show watchIsTeacher;
import '../../pro/presentation/pro_gate.dart';
import 'lesson_viewer_screen.dart' show LessonFailureView;

/// «Darslar» ro‘yxati: qidiruv (server + tezkor mahalliy filtr), kurs
/// bo‘yicha guruhlar. Ustoz bo‘lmasa server 403 beradi — do‘stona xabar.
class LessonsListScreen extends ConsumerStatefulWidget {
  const LessonsListScreen({super.key});

  @override
  ConsumerState<LessonsListScreen> createState() => _LessonsListScreenState();
}

class _LessonsListScreenState extends ConsumerState<LessonsListScreen> {
  final _ctl = TextEditingController();
  Timer? _debounce;
  String _typed = '';
  String _server = '';

  /// Qidiruv kechikishi (testlarda ham shu qiymat).
  static const debounceDelay = Duration(milliseconds: 350);

  @override
  void dispose() {
    _debounce?.cancel();
    _ctl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    setState(() => _typed = v.trim());
    _debounce?.cancel();
    _debounce = Timer(debounceDelay, () {
      if (mounted) setState(() => _server = _typed);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _ctl.clear();
    setState(() {
      _typed = '';
      _server = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final base = ref.watch(lessonListProvider(''));
    final baseRes = base.value;
    final all = baseRes?.value;

    List<LessonSummary>? items;
    var searching = false;
    if (all != null) {
      if (_typed.isEmpty) {
        items = all;
      } else {
        final srv = _server == _typed
            ? ref.watch(lessonListProvider(_server))
            : null;
        final sv = srv?.value?.value;
        searching = _server != _typed || (srv?.isLoading ?? false);
        // Server natijasi tayyor bo‘lsa — shu; aks holda tezkor mahalliy filtr.
        items = sv ?? LessonGrouping.filter(all, _typed);
      }
    }
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.lessonsTitle)),
      body: Column(
        children: [
          FeContentFrame(
            child: Padding(
              padding: const EdgeInsets.only(
                top: FeSpace.xs,
                bottom: FeSpace.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ClassDemoBanner(),
                  TextField(
                    key: const Key('lessons.search'),
                    controller: _ctl,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    onChanged: _onChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l.lessonsSearchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _typed.isEmpty
                          ? null
                          : IconButton(
                              key: const Key('lessons.searchClear'),
                              tooltip: l.lessonsSearchClear,
                              icon: const Icon(Icons.close_rounded),
                              onPressed: _clear,
                            ),
                    ),
                  ),
                  if (!watchIsTeacher(ref))
                    Padding(
                      padding: const EdgeInsets.only(top: FeSpace.xs),
                      child: Text(
                        l.lessonsOpenNote,
                        key: const Key('lessons.openNote'),
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ),
                  if (lang != 'uz')
                    Padding(
                      padding: const EdgeInsets.only(top: FeSpace.xs),
                      child: Text(
                        l.lessonsOriginalUzNote,
                        key: const Key('lessons.uzNote'),
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ),
                  if (searching)
                    const Padding(
                      padding: EdgeInsets.only(top: FeSpace.xs),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                ],
              ),
            ),
          ),
          Expanded(child: _body(context, base, items)),
        ],
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AsyncValue<dynamic> base,
    List<LessonSummary>? items,
  ) {
    final l = AppLocalizations.of(context);
    final failure = ref.watch(lessonListProvider('')).value?.failure;
    if (items == null) {
      if (failure != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(FeSpace.lg),
            child: LessonFailureView(
              failure: failure,
              onRetry: () {
                ref.invalidate(lessonListProvider(''));
                ref.invalidate(lessonListProvider(_server));
              },
            ),
          ),
        );
      }
      return ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(FeSpace.md),
        children: [FeListSkeleton(rows: 4, semanticLabel: l.lessonsTitle)],
      );
    }
    if (items.isEmpty) {
      return Center(
        child: FeEmptyState(
          key: const Key('lessons.empty'),
          icon: Icons.slideshow_rounded,
          body: _typed.isEmpty ? l.lessonsEmpty : l.lessonsNoMatch(_typed),
        ),
      );
    }
    final groups = LessonGrouping.group(items);
    final locks = ref.watch(lessonLocksProvider) ?? const {};
    return ListView(
      key: const Key('lessons.list'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(
        bottom: FeSpace.lg + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        FeContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Qulfli darslar bor: har sababga bitta qulf kartasi (yashirin
              // dars yo‘q — hammasi ro‘yxatda, qulf belgisi bilan).
              for (final f in {...locks.values})
                Padding(
                  padding: const EdgeInsets.only(top: FeSpace.xs),
                  child: ProFeatureLock(feature: f),
                ),
              for (final g in groups) ...[
                _CourseHeader(g.course),
                for (final s in g.items)
                  _LessonRow(summary: s, lock: locks[s.topicId]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CourseHeader extends StatelessWidget {
  const _CourseHeader(this.course);

  final String course;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: FeSpace.md, bottom: FeSpace.xs),
      child: Semantics(
        header: true,
        child: Text(course, style: t.titleSmall?.copyWith(color: c.accent)),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.summary, this.lock});

  final LessonSummary summary;

  /// Qulf sababi (`null` — ochiq).
  final ProFeature? lock;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final count = l.lessonsSlideCount(summary.slides);
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: Key('lessons.row.${summary.topicId}'),
        onTap: () => lock == null
            ? context.push(Routes.lesson(summary.topicId))
            : openPro(context, lock!.requiredPlan),
        semanticLabel: '${summary.title}. $count',
        padding: const EdgeInsets.symmetric(
          horizontal: FeSpace.md,
          vertical: FeSpace.sm,
        ),
        child: ExcludeSemantics(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                Icon(
                  lock == null ? Icons.slideshow_rounded : Icons.lock_outline,
                  color: c.accent,
                ),
                const SizedBox(width: FeSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        count,
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: c.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
