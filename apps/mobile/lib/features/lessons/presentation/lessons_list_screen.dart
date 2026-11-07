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
import '../../../domain/lessons/lesson_taxonomy.dart';
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
  const LessonsListScreen({super.key, this.exam = false, this.initialCourse});

  /// Boshlang‘ich kurs (barqaror nom): ro‘yxat to‘g‘ridan-to‘g‘ri shu kursda
  /// ochiladi (Mutaxassis: «Apparatlar bilan ishlash», 1 bosish).
  final String? initialCourse;

  /// «Imtihon rejimi»: mavzuni bosganda dars emas, shu mavzuning testi
  /// (`Routes.groupPractice`) ochiladi. Talaba paneli kartasi shu yerga olib boradi.
  final bool exam;

  @override
  ConsumerState<LessonsListScreen> createState() => _LessonsListScreenState();
}

class _LessonsListScreenState extends ConsumerState<LessonsListScreen> {
  final _ctl = TextEditingController();
  Timer? _debounce;
  String _typed = '';
  String _server = '';

  /// Tanlangan fan (2-daraja: Sud tibbiyoti ichida) va kurs/fakultet.
  LessonSubjectId? _subject;
  String? _course;

  @override
  void initState() {
    super.initState();
    // Ro‘yxat xotirada bo‘lsa — darhol ko‘rsatiladi va fonda yangilanadi
    // (eski qiymat yangisi kelguncha qoladi).
    if (ref.read(lessonListProvider('')).hasValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.invalidate(lessonListProvider(''));
      });
    }
    final c = widget.initialCourse;
    if (c != null && c.isNotEmpty) {
      _course = c;
      final sub = LessonTaxonomy.subjectOf(c);
      if (sub != null && !sub.isLeaf) _subject = sub.id;
    }
  }

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
    final counts = {
      for (final g in LessonGrouping.group(all ?? const <LessonSummary>[]))
        g.course: g.items.length,
    };
    final course = counts.containsKey(_course) ? _course : null;
    // Qidiruv — butun bazadan (tuzilmadan qat’i nazar).
    final browse = _typed.isEmpty && course == null;
    if (items != null && course != null && _typed.isEmpty) {
      items = [
        for (final s in items)
          if (s.course == course) s,
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: FeAppBarTitle(widget.exam ? l.deskExamTitle : l.lessonsTitle),
      ),
      body: Column(
        children: [
          // Yuqori qism aylantiriladi (katta shrift + kichik ekranda sig‘adi).
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.4,
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: FeContentFrame(
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
                            style: t.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                      if (lang != 'uz')
                        Padding(
                          padding: const EdgeInsets.only(top: FeSpace.xs),
                          child: Text(
                            l.lessonsOriginalUzNote,
                            key: const Key('lessons.uzNote'),
                            style: t.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
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
            ),
          ),
          if (_typed.isEmpty && (course != null || _subject != null))
            _BackRow(
              label: _backLabel(l, course),
              onTap: () => setState(() {
                if (course != null) {
                  _course = null;
                  final sub = LessonTaxonomy.subjectOf(course);
                  if (sub == null || sub.isLeaf) _subject = null;
                } else {
                  _subject = null;
                }
              }),
            ),
          Expanded(child: _body(context, base, items, browse, counts)),
        ],
      ),
    );
  }

  String _backLabel(AppLocalizations l, String? course) {
    if (course != null && _subject != null) {
      return subjectTitle(l, _subject!);
    }
    return l.lessonsTitle;
  }

  /// 1–2-daraja: fanlar → (Sud tibbiyoti) fakultetlar va ichki bob.
  Widget _structure(BuildContext context, Map<String, int> counts) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final rows = <Widget>[];
    if (_subject == null) {
      for (final s in LessonTaxonomy.subjects) {
        final n = s.allCourses.fold<int>(0, (a, x) => a + (counts[x] ?? 0));
        if (n == 0) continue;
        rows.add(
          _StructureRow(
            key: Key('lessons.subject.${s.id.name}'),
            title: subjectTitle(l, s.id),
            subtitle: s.id == LessonSubjectId.forensic
                ? l.lessonSubjectFacultiesNote
                : null,
            count: n,
            onTap: () => setState(() {
              if (s.isLeaf) {
                _subject = null;
                _course = s.courses.first;
              } else {
                _subject = s.id;
              }
            }),
          ),
        );
      }
      final known = {for (final s in LessonTaxonomy.subjects) ...s.allCourses};
      for (final e in counts.entries) {
        if (known.contains(e.key)) continue;
        rows.add(
          _StructureRow(
            key: Key('lessons.course.${e.key}'),
            title: courseLabel(l, e.key),
            count: e.value,
            onTap: () => setState(() => _course = e.key),
          ),
        );
      }
    } else {
      final s = LessonTaxonomy.subjects.firstWhere((x) => x.id == _subject);
      for (final course in s.courses) {
        final n = counts[course] ?? 0;
        if (n == 0) continue;
        rows.add(
          _StructureRow(
            key: Key('lessons.faculty.$course'),
            title: courseLabel(l, course),
            count: n,
            onTap: () => setState(() => _course = course),
          ),
        );
      }
      final ch = s.chapter;
      if (ch != null && (counts[ch] ?? 0) > 0) {
        rows.add(const SizedBox(height: FeSpace.xs));
        rows.add(
          _StructureRow(
            key: const Key('lessons.chapter'),
            icon: Icons.menu_book_outlined,
            title: courseLabel(l, ch),
            subtitle: l.lessonChapterToxNote,
            count: counts[ch]!,
            onTap: () => setState(() => _course = ch),
          ),
        );
      }
    }
    if (rows.isEmpty) {
      return ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(vertical: FeSpace.xl),
        children: [
          FeEmptyState(
            key: const Key('lessons.empty'),
            icon: Icons.slideshow_rounded,
            body: l.lessonsEmpty,
          ),
        ],
      );
    }
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      key: const Key('lessons.structure'),
      padding: EdgeInsets.fromLTRB(
        0,
        FeSpace.xs,
        0,
        FeSpace.lg + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        FeContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_subject != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: FeSpace.sm),
                  child: Text(
                    subjectTitle(l, _subject!),
                    style: t.titleMedium?.copyWith(color: c.textPrimary),
                  ),
                ),
              ...rows,
            ],
          ),
        ),
      ],
    );
  }

  Widget _body(
    BuildContext context,
    AsyncValue<dynamic> base,
    List<LessonSummary>? items,
    bool browse,
    Map<String, int> counts,
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
    if (browse) return _structure(context, counts);
    if (items.isEmpty) {
      // Aylantiriladi: kichik ekran + katta shriftda yozuv sig‘ishi uchun.
      return ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(vertical: FeSpace.xl),
        children: [
          FeEmptyState(
            key: const Key('lessons.empty'),
            icon: Icons.slideshow_rounded,
            body: _typed.isEmpty ? l.lessonsEmpty : l.lessonsNoMatch(_typed),
          ),
        ],
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
                _CourseHeader(
                  courseLabel(AppLocalizations.of(context), g.course),
                ),
                for (final (i, s) in g.items.indexed)
                  _LessonRow(
                    summary: s,
                    number: i + 1,
                    lock: locks[s.topicId],
                    exam: widget.exam,
                  ),
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

/// «‹ Orqaga» qatori (2–3-darajadan yuqoriga).
class _BackRow extends StatelessWidget {
  const _BackRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: FeSpace.xs),
      child: TextButton.icon(
        key: const Key('lessons.back'),
        onPressed: onTap,
        icon: const Icon(Icons.chevron_left_rounded),
        label: Text(label),
      ),
    ),
  );
}

/// Fan / fakultet / bob qatori: nom, (izoh), mavzular soni.
class _StructureRow extends StatelessWidget {
  const _StructureRow({
    super.key,
    required this.title,
    required this.count,
    required this.onTap,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final int count;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        onTap: onTap,
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: c.accent),
              const SizedBox(width: FeSpace.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.titleSmall),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                ],
              ),
            ),
            const SizedBox(width: FeSpace.sm),
            DecoratedBox(
              decoration: BoxDecoration(
                color: c.surfaceSunken,
                borderRadius: BorderRadius.circular(FeRadius.pill),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FeSpace.sm,
                  vertical: 2,
                ),
                child: Text(count.toString(), style: t.labelMedium),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: c.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Fan nomi (tilga qarab).
String subjectTitle(AppLocalizations l, LessonSubjectId id) => switch (id) {
  LessonSubjectId.bioethics => l.lessonSubjectBioethics,
  LessonSubjectId.forensic => l.lessonSubjectForensic,
  LessonSubjectId.pharmacy => l.lessonSubjectPharmacy,
  LessonSubjectId.devices => l.lessonSubjectDevices,
};

/// Kurs (fakultet/bob) nomi: serverdagi barqaror nom → joriy til.
String courseLabel(AppLocalizations l, String course) => switch (course) {
  LessonTaxonomy.bioethics => l.lessonSubjectBioethics,
  LessonTaxonomy.medicine => l.lessonFacultyMed,
  LessonTaxonomy.pediatrics => l.lessonFacultyPeds,
  LessonTaxonomy.dentistry => l.lessonFacultyDent,
  LessonTaxonomy.prevention => l.lessonFacultyPrev,
  LessonTaxonomy.forensicToxChapter => l.lessonChapterTox,
  LessonTaxonomy.toxChem => l.lessonSubjectPharmacy,
  LessonTaxonomy.devices => l.lessonSubjectDevices,
  _ => course,
};

class _LessonRow extends StatelessWidget {
  const _LessonRow({
    required this.summary,
    this.number,
    this.lock,
    this.exam = false,
  });

  final LessonSummary summary;

  /// Kurs ichidagi tartib raqami.
  final int? number;

  /// Qulf sababi (`null` — ochiq).
  final ProFeature? lock;

  /// Imtihon rejimi: bosilganda shu mavzuning testi ochiladi.
  final bool exam;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final count = l.lessonsSlideCount(summary.slides);
    final parts = LessonGrouping.titleParts(summary.title);
    final kind = switch (parts.kind) {
      LessonKind.lecture => l.lessonKindLecture,
      LessonKind.practice => l.lessonKindPractice,
      null => null,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: Key('lessons.row.${summary.topicId}'),
        onTap: () => lock != null
            ? openPro(context, lock!.requiredPlan)
            : exam
            ? context.push(Routes.groupPractice(summary.topicId))
            : context.push(Routes.lesson(summary.topicId)),
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
                if (number != null && lock == null)
                  SizedBox(
                    width: 32,
                    child: Text(
                      '$number',
                      textAlign: TextAlign.center,
                      style: t.titleMedium?.copyWith(
                        color: c.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
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
                        parts.main,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: t.titleSmall,
                      ),
                      if (parts.points.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            parts.points,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: t.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        kind == null ? count : '$kind · $count',
                        style: t.labelSmall?.copyWith(color: c.accent),
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
