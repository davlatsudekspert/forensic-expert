import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/class_quiz.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';

import '../../../domain/class_quiz/class_quiz_models.dart';
import '../../professional/presentation/professional_widgets.dart' show FeNote;
import 'class_quiz_widgets.dart';

/// Yangi sinf testi: mavzu, savollar soni, talaba chegarasi, har savolga vaqt.
class ClassCreateScreen extends StatelessWidget {
  const ClassCreateScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const ClassTeacherGate(child: _CreateBody());
}

class _CreateBody extends ConsumerStatefulWidget {
  const _CreateBody();

  @override
  ConsumerState<_CreateBody> createState() => _CreateBodyState();
}

class _CreateBodyState extends ConsumerState<_CreateBody> {
  String? _topicId;
  String _query = '';
  var _settings = const ClassQuizSettings();
  bool _busy = false;
  String? _error;

  Future<void> _create() async {
    final l = AppLocalizations.of(context);
    final topic = _topicId;
    if (topic == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref
        .read(classQuizServiceProvider)
        .createSession(topicId: topic, settings: _settings);
    if (!mounted) return;
    final s = r.value;
    if (s == null) {
      setState(() {
        _busy = false;
        _error = classFailureText(l, r.failure!);
      });
      return;
    }
    ref.invalidate(classMySessionsProvider);
    context.pushReplacement(Routes.classHost(s.id));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final topics = ref.watch(classTopicsProvider);
    final list = topics.value?.value ?? const <ClassTopic>[];
    final lang = Localizations.localeOf(context).languageCode;
    final bank = ref.watch(classQuizBankProvider).value ?? ClassQuizBank.empty;
    final selected = list.where((x) => x.id == _topicId).firstOrNull;
    final maxQ = selected == null
        ? ClassQuizRules.maxQuestions
        : min(ClassQuizRules.maxQuestions, selected.count);
    final qCount = _settings.questionCount
        .clamp(
          ClassQuizRules.minQuestions,
          max(ClassQuizRules.minQuestions, maxQ),
        )
        .toInt();

    Widget body;
    if (topics.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (topics.value?.ok != true) {
      body = FeNote(
        icon: Icons.error_outline,
        text: classFailureText(l, topics.value?.failure ?? ClassFailure.server),
      );
    } else if (list.isEmpty) {
      body = FeEmptyState(
        key: const Key('class.noTopics'),
        icon: Icons.quiz_outlined,
        body: l.classNoTopics,
      );
    } else {
      final enough =
          selected != null && selected.count >= ClassQuizRules.minQuestions;
      final groups = _groupTopics(list, bank, lang, l, _query);
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FeSectionHeader(l.classTopicSection),
          TextField(
            key: const Key('class.topicSearch'),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            onChanged: (v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l.classTopicSearchHint,
              prefixIcon: const Icon(Icons.search),
              isDense: true,
            ),
          ),
          const SizedBox(height: FeSpace.sm),
          if (groups.isEmpty)
            FeEmptyState(
              key: const Key('class.topicNoMatch'),
              icon: Icons.search_off,
              body: l.classTopicNoMatch,
              compact: true,
            ),
          for (final g in groups)
            _TopicGroup(
              // Qidiruv boshlanganda/tozalanganda ochiq-yopiq holati qayta
              // o‘rnatiladi.
              key: Key('class.group.${g.id}.${_query.trim().isEmpty ? 0 : 1}'),
              title: g.title,
              count: g.items.length,
              initiallyExpanded:
                  _query.trim().isNotEmpty ||
                  groups.length == 1 ||
                  g.items.any((x) => x.topic.id == _topicId),
              children: [
                for (final item in g.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: FeSpace.xs),
                    child: _TopicCard(
                      item: item,
                      selected: item.topic.id == _topicId,
                      onTap: () => setState(() {
                        _topicId = item.topic.id;
                        _settings = _settings.copyWith(
                          questionCount: min(
                            _settings.questionCount,
                            item.topic.count,
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          if (selected != null) ...[
            const SizedBox(height: FeSpace.sm),
            Text(
              l.classTopicSelected,
              style: t.labelMedium?.copyWith(color: c.textSecondary),
            ),
            Text(
              _choiceTitle(selected, bank, lang),
              key: const Key('class.selectedTopic'),
              style: t.titleSmall,
            ),
          ],
          if (selected != null && !enough)
            FeNote(
              icon: Icons.info_outline,
              text: l.classErrNotEnoughQuestions,
            ),
          if (selected != null && enough) ...[
            FeSectionHeader(l.classSettingsSection),
            _LabeledSlider(
              key: const Key('class.sliderQuestions'),
              label: l.classQuestionCount,
              value: qCount,
              min: ClassQuizRules.minQuestions,
              max: max(ClassQuizRules.minQuestions + 1, maxQ).toInt(),
              step: 1,
              onChanged: (v) => setState(
                () => _settings = _settings.copyWith(questionCount: v),
              ),
            ),
            _LabeledSlider(
              key: const Key('class.sliderStudents'),
              label: l.classStudentLimit,
              value: _settings.studentLimit,
              min: ClassQuizRules.minStudents,
              max: ClassQuizRules.maxStudents,
              step: 5,
              onChanged: (v) => setState(
                () => _settings = _settings.copyWith(studentLimit: v),
              ),
            ),
            const SizedBox(height: FeSpace.xs),
            Text(l.classSecondsPerQuestion, style: t.titleSmall),
            const SizedBox(height: FeSpace.xs),
            SegmentedButton<int>(
              key: const Key('class.seconds'),
              showSelectedIcon: false,
              segments: [
                for (final s in ClassQuizRules.secondsChoices)
                  ButtonSegment(value: s, label: Text(l.classSecondsShort(s))),
              ],
              selected: {_settings.seconds},
              onSelectionChanged: (v) => setState(
                () => _settings = _settings.copyWith(seconds: v.first),
              ),
            ),
            const SizedBox(height: FeSpace.md),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: FeSpace.xs),
                child: Text(
                  _error!,
                  key: const Key('class.createError'),
                  style: t.bodyMedium?.copyWith(color: c.danger),
                ),
              ),
            FilledButton.icon(
              key: const Key('class.createSubmit'),
              onPressed: _busy
                  ? null
                  : () {
                      _settings = _settings.copyWith(questionCount: qCount);
                      _create();
                    },
              icon: const Icon(Icons.play_circle_outline),
              label: Text(l.classCreateAction),
            ),
          ],
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.classNewTitle)),
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
                  body,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ro‘yxatdagi bitta mavzu: server/qurilma mavzusi (tanlangan til varianti)
/// va bankdagi metama’lumoti.
class _TopicChoice {
  const _TopicChoice({required this.topic, required this.title, this.meta});

  final ClassTopic topic;
  final String title;
  final ClassQuizBankTopicMeta? meta;

  /// Savollar avtomatik tarjima (ru/en, tekshirilmagan) bo‘lsa — belgi.
  bool get machineTranslated {
    final vl = ClassQuizBank.variantLang(topic.id);
    return meta?.isMachineTranslation(vl) ?? (vl != 'uz');
  }
}

class _TopicGroupData {
  _TopicGroupData(this.id, this.title, this.order);

  final String id;
  final String title;
  final int order;
  final items = <_TopicChoice>[];
}

String _choiceTitle(ClassTopic t, ClassQuizBank bank, String lang) =>
    bank.meta(t.id)?.title(ClassQuizBank.variantLang(t.id)) ?? t.title;

/// Mavzularni kurs/fan bo‘yicha guruhlaydi. Bir mavzuning til variantlari
/// (`<id>`, `<id>~ru`, `<id>~en`) bitta qatorga yig‘iladi — ilova tilidagi
/// variant tanlanadi (bo‘lmasa — asl o‘zbekcha).
List<_TopicGroupData> _groupTopics(
  List<ClassTopic> topics,
  ClassQuizBank bank,
  String lang,
  AppLocalizations l,
  String query,
) {
  final byBase = <String, Map<String, ClassTopic>>{};
  for (final t in topics) {
    final variants = byBase.putIfAbsent(ClassQuizBank.baseId(t.id), () => {});
    variants[ClassQuizBank.variantLang(t.id)] = t;
  }
  final q = query.trim().toLowerCase();
  final groups = <String, _TopicGroupData>{};
  for (final e in byBase.entries) {
    final v = e.value;
    final topic = v[lang] ?? v['uz'] ?? v.values.first;
    final meta = bank.meta(e.key);
    final g = meta == null ? null : bank.group(meta.groupId);
    final gid = g?.id ?? '_other';
    final group = groups.putIfAbsent(
      gid,
      () => _TopicGroupData(
        gid,
        g?.title(lang) ?? l.classTopicGroupOther,
        g?.order ?? 1 << 20,
      ),
    );
    final title = _choiceTitle(topic, bank, lang);
    if (q.isNotEmpty &&
        !title.toLowerCase().contains(q) &&
        !group.title.toLowerCase().contains(q)) {
      continue;
    }
    group.items.add(_TopicChoice(topic: topic, title: title, meta: meta));
  }
  final out = [
    for (final g in groups.values)
      if (g.items.isNotEmpty) g,
  ]..sort((a, b) => a.order.compareTo(b.order));
  for (final g in out) {
    g.items.sort((a, b) {
      final c = (a.meta?.number ?? 0).compareTo(b.meta?.number ?? 0);
      return c != 0 ? c : a.title.compareTo(b.title);
    });
  }
  return out;
}

class _TopicGroup extends StatelessWidget {
  const _TopicGroup({
    super.key,
    required this.title,
    required this.count,
    required this.initiallyExpanded,
    required this.children,
  });

  final String title;
  final int count;
  final bool initiallyExpanded;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text(title, style: t.titleSmall),
        subtitle: Text(
          l.classTopicGroupCount(count),
          style: t.bodySmall?.copyWith(color: c.textSecondary),
        ),
        children: children,
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _TopicChoice item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final topic = item.topic;
    return FeCard(
      key: Key('class.topic.${topic.id}'),
      color: selected ? c.accentContainer : null,
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: c.accent,
          ),
          const SizedBox(width: FeSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: t.titleSmall),
                Text(
                  l.classQuestionsAvailable(topic.count),
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
                if (item.machineTranslated)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.translate, size: 14, color: c.textSecondary),
                        const SizedBox(width: FeSpace.xxs),
                        Flexible(
                          child: Text(
                            l.trStatusMachineDraft,
                            style: t.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (topic.isDemo)
            StatusChip(
              icon: Icons.science_outlined,
              label: l.classDemoChip,
              color: c.warning,
            ),
        ],
      ),
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final divisions = ((max - min) / step).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: t.titleSmall)),
            Text(value.toString(), style: t.titleMedium),
          ],
        ),
        Slider(
          value: value.clamp(min, max).toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: divisions < 1 ? 1 : divisions,
          label: value.toString(),
          semanticFormatterCallback: (v) => v.round().toString(),
          onChanged: (v) =>
              onChanged(((v / step).round() * step).clamp(min, max)),
        ),
      ],
    );
  }
}

/// Ustoz boshqaruvi (proyektorga mos: to‘q fon, yirik matn, landshaft).
class ClassHostScreen extends StatelessWidget {
  const ClassHostScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) => ClassTeacherGate(
    child: Theme(
      data: FeThemeBuilder.dark(),
      child: _HostBody(sessionId: sessionId),
    ),
  );
}

class _HostBody extends ConsumerStatefulWidget {
  const _HostBody({required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<_HostBody> createState() => _HostBodyState();
}

class _HostBodyState extends ConsumerState<_HostBody> {
  bool _busy = false;
  late final ClassScreenAwake _awake;
  late final ClassOrientationControl _orientation;
  bool _forcedLandscape = false;

  @override
  void initState() {
    super.initState();
    _awake = ref.read(classScreenAwakeProvider);
    _orientation = ref.read(classOrientationControlProvider);
    _awake.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) => _askLandscape());
  }

  @override
  void dispose() {
    _awake.disable();
    if (_forcedLandscape) _orientation.restore();
    super.dispose();
  }

  /// Telefonda, tik holatda — bir marta gorizontal holatga o‘tishni taklif qiladi.
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

  Future<void> _run(Future<ClassResult<Object?>> Function() action) async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final r = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    if (!r.ok) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(classFailureText(l, r.failure!))),
        );
    }
    ref.invalidate(classDashboardProvider(widget.sessionId));
    ref.invalidate(classMySessionsProvider);
  }

  Future<bool> _confirm(String title, String body, String action) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => c.pop(false), child: Text(l.classCancel)),
          FilledButton(
            key: const Key('class.confirmYes'),
            onPressed: () => c.pop(true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _export(ClassSessionInfo s) =>
      exportClassResultsCsv(context, ref, s);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final svc = ref.watch(classQuizServiceProvider);
    final dash = ref.watch(classDashboardProvider(widget.sessionId));
    final d = dash.value?.value;
    final failure = dash.value?.failure;

    final Widget body;
    if (d != null) {
      body = _HostView(
        d: d,
        busy: _busy,
        onStart: () => _run(() => svc.start(d.session.id)),
        onNext: () => _run(() => svc.next(d.session.id)),
        onClose: () => _run(() => svc.closeQuestion(d.session.id)),
        onKick: (p) async {
          if (await _confirm(
            l.classKickTitle,
            l.classKickBody(p.nickname),
            l.classKickAction,
          )) {
            await _run(() => svc.kick(d.session.id, p.id));
          }
        },
        onExport: () => _export(d.session),
        onDone: () =>
            context.canPop() ? context.pop() : context.go(Routes.classQuiz),
      );
    } else if (failure != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(FeSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                classFailureText(l, failure),
                key: const Key('class.hostError'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FeSpace.sm),
              OutlinedButton(
                onPressed: () =>
                    ref.invalidate(classDashboardProvider(widget.sessionId)),
                child: Text(l.classRetry),
              ),
            ],
          ),
        ),
      );
    } else {
      body = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: FeBrand.navy,
      appBar: AppBar(
        backgroundColor: FeBrand.navy,
        foregroundColor: Colors.white,
        title: Text(d?.session.topicTitle ?? l.classQuizTitle),
        actions: [
          if (d != null && d.session.status != ClassSessionStatus.finished)
            IconButton(
              key: const Key('class.endButton'),
              tooltip: l.classEndAction,
              icon: const Icon(Icons.stop_circle_outlined),
              onPressed: () async {
                if (await _confirm(
                  l.classEndTitle,
                  l.classEndBody,
                  l.classEndAction,
                )) {
                  await _run(() => svc.finish(d.session.id));
                }
              },
            ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }
}

class _HostView extends ConsumerWidget {
  const _HostView({
    required this.d,
    required this.busy,
    required this.onStart,
    required this.onNext,
    required this.onClose,
    required this.onKick,
    required this.onExport,
    required this.onDone,
  });

  final ClassDashboard d;
  final bool busy;
  final VoidCallback onStart;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final void Function(ClassParticipant) onKick;
  final VoidCallback onExport;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = MediaQuery.sizeOf(context).width >= 720;
    return switch (d.session.status) {
      ClassSessionStatus.lobby => _Lobby(
        d: d,
        wide: wide,
        busy: busy,
        onStart: onStart,
        onKick: onKick,
      ),
      ClassSessionStatus.running => _Running(
        d: d,
        wide: wide,
        busy: busy,
        onNext: onNext,
        onClose: onClose,
      ),
      ClassSessionStatus.finished => _Finished(
        d: d,
        onExport: onExport,
        onDone: onDone,
      ),
    };
  }
}

class _Lobby extends ConsumerWidget {
  const _Lobby({
    required this.d,
    required this.wide,
    required this.busy,
    required this.onStart,
    required this.onKick,
  });

  final ClassDashboard d;
  final bool wide;
  final bool busy;
  final VoidCallback onStart;
  final void Function(ClassParticipant) onKick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final link = ref.watch(classJoinLinkProvider(d.session.code));
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final qr = wide ? min(300.0, shortest * 0.55) : min(220.0, shortest * 0.6);

    final join = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.classHostJoinHint,
          textAlign: TextAlign.center,
          style: t.titleMedium?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: FeSpace.sm),
        ClassCodeBanner(code: d.session.code, fontSize: wide ? 96 : 56),
        const SizedBox(height: FeSpace.md),
        ClassQr(data: link.toString(), size: qr),
        const SizedBox(height: FeSpace.xs),
        SelectableText(
          link.toString(),
          key: const Key('class.joinLink'),
          textAlign: TextAlign.center,
          style: t.bodySmall?.copyWith(color: const Color(0xFFC9D2E0)),
        ),
      ],
    );

    final people = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.classJoinedCount(d.joined, d.session.studentLimit),
          key: const Key('class.joinedCount'),
          style: t.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: FeSpace.xs),
        if (d.reports > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: Text(
              l.classReportsCount(d.reports),
              style: t.bodyMedium?.copyWith(color: FeBrand.goldOnDark),
            ),
          ),
        if (d.participants.isEmpty)
          Text(
            l.classWaitingForStudents,
            style: t.bodyLarge?.copyWith(color: const Color(0xFFC9D2E0)),
          )
        else
          Wrap(
            spacing: FeSpace.xs,
            runSpacing: FeSpace.xs,
            children: [
              for (final p in d.participants)
                InputChip(
                  key: Key('class.participant.${p.id}'),
                  label: Text(p.nickname),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  deleteButtonTooltipMessage: l.classKickAction,
                  onDeleted: () => onKick(p),
                ),
            ],
          ),
      ],
    );

    final start = FilledButton.icon(
      key: const Key('class.startButton'),
      onPressed: busy || d.joined == 0 ? null : onStart,
      icon: const Icon(Icons.play_arrow),
      label: Text(l.classStartAction),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        textStyle: t.titleMedium?.copyWith(
          fontFamily: FeFonts.sans,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (wide) {
      return Padding(
        padding: const EdgeInsets.all(FeSpace.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Center(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: join,
                ),
              ),
            ),
            const SizedBox(width: FeSpace.lg),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: people,
                    ),
                  ),
                  const SizedBox(height: FeSpace.sm),
                  start,
                ],
              ),
            ),
          ],
        ),
      );
    }
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(FeSpace.md),
      children: [
        join,
        const SizedBox(height: FeSpace.lg),
        people,
        const SizedBox(height: FeSpace.md),
        start,
      ],
    );
  }
}

class _Running extends StatelessWidget {
  const _Running({
    required this.d,
    required this.wide,
    required this.busy,
    required this.onNext,
    required this.onClose,
  });

  final ClassDashboard d;
  final bool wide;
  final bool busy;
  final VoidCallback onNext;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final cur = d.current;
    if (cur == null) return const Center(child: CircularProgressIndicator());
    final closed = d.phase != ClassPhase.open;
    final last = d.session.currentIndex + 1 >= d.session.total;
    final maxCount = cur.options.fold<int>(1, (m, o) => max(m, o.count ?? 0));

    final header = Row(
      children: [
        Expanded(
          child: Text(
            l.classQuestionOf(d.session.currentIndex + 1, d.session.total),
            style: t.titleLarge?.copyWith(color: FeBrand.goldOnDark),
          ),
        ),
        ClassCountdown(
          key: ValueKey('q${cur.index}'),
          remainingMs: d.remainingMs,
          totalMs: d.session.seconds * 1000,
          size: wide ? 96 : 64,
          onDark: true,
        ),
      ],
    );

    final question = Text(
      cur.text,
      key: const Key('class.hostQuestion'),
      style: (wide ? t.headlineMedium : t.titleLarge)?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
    );

    final tiles = [
      for (var i = 0; i < cur.options.length; i++)
        ClassOptionTile(
          key: Key('class.hostOption.${cur.options[i].id}'),
          letter: classOptionLetter(i),
          text: cur.options[i].text,
          big: wide,
          // Proyektorda ko‘rinadi: to‘g‘ri javob va sonlar faqat vaqt
          // tugagach (talabalar ko‘rib qolmasin).
          state: closed
              ? (cur.options[i].id == cur.correctOption
                    ? ClassOptionState.correct
                    : ClassOptionState.neutral)
              : ClassOptionState.neutral,
          count: closed ? cur.options[i].count : null,
          fraction: closed ? (cur.options[i].count ?? 0) / maxCount : null,
        ),
    ];

    final options = wide
        ? GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: FeSpace.sm,
            crossAxisSpacing: FeSpace.sm,
            childAspectRatio: 4.2,
            children: tiles,
          )
        : Column(
            children: [
              for (final tile in tiles)
                Padding(
                  padding: const EdgeInsets.only(bottom: FeSpace.xs),
                  child: tile,
                ),
            ],
          );

    final live = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeCard(
          key: const Key('class.liveStats'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.classAnswered(cur.answered, d.joined),
                key: const Key('class.answeredCount'),
                style: t.titleMedium?.copyWith(
                  fontFamily: FeFonts.sans,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: FeSpace.xs),
              LinearProgressIndicator(
                value: d.joined == 0 ? 0 : cur.answered / d.joined,
                minHeight: 8,
              ),
              if (d.participants.isNotEmpty) ...[
                const SizedBox(height: FeSpace.sm),
                _ParticipantStatusGrid(participants: d.participants, big: wide),
              ],
              if (closed && cur.correctPct != null) ...[
                const SizedBox(height: FeSpace.xs),
                Text(
                  l.classCorrectPct(cur.correctPct!),
                  key: const Key('class.correctPct'),
                  style: t.titleSmall?.copyWith(color: c.verified),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: FeSpace.sm),
        FeCard(
          key: const Key('class.leaderboard'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.classLeaderboard, style: t.titleSmall),
              const SizedBox(height: FeSpace.xs),
              if (d.leaderboard.isEmpty)
                Text(l.classNoScoresYet, style: t.bodySmall)
              else
                for (final r in d.leaderboard.take(5))
                  _LeaderRowView(row: r, compact: true),
            ],
          ),
        ),
      ],
    );

    final controls = Row(
      children: [
        if (!closed)
          Expanded(
            child: OutlinedButton.icon(
              key: const Key('class.closeButton'),
              onPressed: busy ? null : onClose,
              icon: const Icon(Icons.timer_off_outlined),
              label: Text(l.classCloseQuestion),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ),
        if (!closed) const SizedBox(width: FeSpace.sm),
        Expanded(
          child: FilledButton.icon(
            key: const Key('class.nextButton'),
            onPressed: busy ? null : onNext,
            icon: Icon(last ? Icons.flag_outlined : Icons.skip_next),
            label: Text(last ? l.classFinishAction : l.classNextQuestion),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ),
      ],
    );

    final explanation = closed && cur.explanation.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: FeSpace.sm),
            child: FeBanner(
              key: const Key('class.hostExplanation'),
              icon: Icons.lightbulb_outline,
              text: cur.explanation,
              tone: FeBannerTone.review,
            ),
          )
        : const SizedBox.shrink();

    if (wide) {
      return Padding(
        padding: const EdgeInsets.all(FeSpace.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const SizedBox(height: FeSpace.md),
                    question,
                    const SizedBox(height: FeSpace.md),
                    options,
                    explanation,
                    const SizedBox(height: FeSpace.md),
                    controls,
                  ],
                ),
              ),
            ),
            const SizedBox(width: FeSpace.lg),
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: live,
              ),
            ),
          ],
        ),
      );
    }
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(FeSpace.md),
      children: [
        header,
        const SizedBox(height: FeSpace.sm),
        question,
        const SizedBox(height: FeSpace.sm),
        options,
        explanation,
        const SizedBox(height: FeSpace.sm),
        controls,
        const SizedBox(height: FeSpace.md),
        live,
      ],
    );
  }
}

/// Har bir ishtirokchi: taxallus + «Javob berdi» / «Kutilmoqda». Faqat holat —
/// qaysi variant tanlangani ko‘rsatilmaydi; email hech qachon ko‘rsatilmaydi.
class _ParticipantStatusGrid extends StatelessWidget {
  const _ParticipantStatusGrid({required this.participants, required this.big});

  final List<ClassParticipant> participants;
  final bool big;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final minW = big ? 250.0 : 200.0;
        final cols = max(1, (box.maxWidth / minW).floor());
        final w = (box.maxWidth - (cols - 1) * FeSpace.xs) / cols;
        return Wrap(
          key: const Key('class.participantStatus'),
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            for (final p in participants)
              SizedBox(
                width: w,
                child: Row(
                  key: Key('class.participant.${p.id}'),
                  children: [
                    Expanded(
                      child: Text(
                        p.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: (big ? t.bodyLarge : t.bodyMedium)?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: FeSpace.xs),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (p.answered ? c.verified : c.textSecondary)
                              .withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          p.answered
                              ? l.classParticipantAnswered
                              : l.classParticipantWaiting,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: (big ? t.labelLarge : t.labelSmall)?.copyWith(
                            color: p.answered ? c.verified : c.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LeaderRowView extends StatelessWidget {
  const _LeaderRowView({required this.row, this.compact = false});

  final ClassLeaderRow row;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    // Ism va ball — sans (jadval o‘qilishi); sarlavhalar serif.
    final style = (compact ? t.bodyMedium : t.titleMedium)?.copyWith(
      fontFamily: FeFonts.sans,
      fontWeight: compact ? null : FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              row.rank.toString(),
              style: style?.copyWith(
                color: row.rank == 1 ? FeBrand.goldOnDark : c.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              row.nickname,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          Text(
            row.score.toString(),
            style: style?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _Finished extends StatelessWidget {
  const _Finished({
    required this.d,
    required this.onExport,
    required this.onDone,
  });

  final ClassDashboard d;
  final VoidCallback onExport;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(FeSpace.md),
      children: [
        FeContentFrame(
          maxWidth: 900,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.classFinishedTitle,
                key: const Key('class.finishedTitle'),
                style: t.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: FeSpace.xs),
              Text(
                l.classFinishedSummary(d.joined, d.session.total),
                style: t.bodyLarge?.copyWith(color: const Color(0xFFC9D2E0)),
              ),
              const SizedBox(height: FeSpace.md),
              FeCard(
                key: const Key('class.finalBoard'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.classLeaderboard, style: t.titleMedium),
                    const SizedBox(height: FeSpace.xs),
                    if (d.leaderboard.isEmpty)
                      Text(l.classNoScoresYet)
                    else
                      for (final r in d.leaderboard) _LeaderRowView(row: r),
                  ],
                ),
              ),
              const SizedBox(height: FeSpace.sm),
              FeCard(
                key: const Key('class.hardest'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.classHardestTitle, style: t.titleMedium),
                    const SizedBox(height: FeSpace.xs),
                    if (d.hardest.isEmpty)
                      Text(l.classNoAnswersYet, style: t.bodySmall)
                    else
                      for (final h in d.hardest)
                        Padding(
                          padding: const EdgeInsets.only(bottom: FeSpace.xs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: Text(h.text)),
                              const SizedBox(width: FeSpace.xs),
                              Text(
                                l.classCorrectPct(h.correctPct),
                                style: t.titleSmall?.copyWith(
                                  color: h.correctPct < 50
                                      ? c.danger
                                      : c.verified,
                                ),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: FeSpace.md),
              FilledButton.icon(
                key: const Key('class.exportButton'),
                onPressed: onExport,
                icon: const Icon(Icons.ios_share),
                label: Text(l.classExportCsv),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: FeSpace.xs),
              OutlinedButton(
                key: const Key('class.doneButton'),
                onPressed: onDone,
                child: Text(l.classDone),
              ),
              const SizedBox(height: FeSpace.xs),
              Text(
                l.classRetentionNote(ClassQuizRules.retentionDays),
                style: t.bodySmall?.copyWith(color: const Color(0xFFC9D2E0)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
