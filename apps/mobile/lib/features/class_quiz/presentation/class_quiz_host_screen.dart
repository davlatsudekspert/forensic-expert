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
import '../../../core/widgets/score_grade.dart';

import '../../../domain/anti_cheat/anti_cheat_rules.dart';
import '../../../domain/class_quiz/class_quiz_models.dart';
import '../../../domain/plan/plan_models.dart';
import '../../anti_cheat/presentation/anti_cheat_widgets.dart';
import '../../pro/presentation/pro_gate.dart';
import '../../professional/presentation/professional_widgets.dart' show FeNote;
import 'class_hardest_screen.dart';
import 'class_quiz_self_pace.dart';
import 'class_quiz_widgets.dart';
import 'class_seconds_picker.dart';

/// Yangi sinf testi: mavzu, savollar soni, talaba chegarasi, har savolga vaqt.
class ClassCreateScreen extends StatelessWidget {
  const ClassCreateScreen({super.key, this.initialTopicId});

  /// Oldindan tanlangan mavzu (asosiy id; masalan «Darslar» dan). Ilova
  /// tilidagi variant (`~ru`/`~en`) bo‘lsa — shu, aks holda asl o‘zbekcha.
  final String? initialTopicId;

  @override
  Widget build(BuildContext context) =>
      ClassTeacherGate(child: _CreateBody(initialTopicId: initialTopicId));
}

class _CreateBody extends ConsumerStatefulWidget {
  const _CreateBody({this.initialTopicId});

  final String? initialTopicId;

  @override
  ConsumerState<_CreateBody> createState() => _CreateBodyState();
}

class _CreateBodyState extends ConsumerState<_CreateBody> {
  String? _topicId;
  bool _initialApplied = false;
  String _query = '';
  var _settings = const ClassQuizSettings();
  bool _customCount = false;
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
    final initial = widget.initialTopicId;
    if (!_initialApplied && initial != null && list.isNotEmpty) {
      _initialApplied = true;
      final base = ClassQuizBank.baseId(initial);
      final variants = {
        for (final x in list)
          if (ClassQuizBank.baseId(x.id) == base)
            ClassQuizBank.variantLang(x.id): x,
      };
      final pick =
          variants[lang] ?? variants['uz'] ?? variants.values.firstOrNull;
      if (pick != null) _topicId = pick.id;
    }
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
                        _customCount = false;
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
            _QuestionCountPicker(
              value: qCount,
              maxAvailable: maxQ,
              custom: _customCount,
              onPick: (v) => setState(() {
                _customCount = false;
                _settings = _settings.copyWith(questionCount: v);
              }),
              onCustom: () => setState(() => _customCount = true),
              onSlide: (v) => setState(
                () => _settings = _settings.copyWith(questionCount: v),
              ),
            ),
            AntiCheatCountNote(
              poolSize: selected.count,
              count: qCount,
              minCount: ClassQuizRules.minQuestions,
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
            ClassSecondsPicker(
              value: _settings.seconds,
              onChanged: (v) =>
                  setState(() => _settings = _settings.copyWith(seconds: v)),
            ),
            const SizedBox(height: FeSpace.xs),
            FeSectionHeader(l.classPaceSection),
            ClassPacePicker(
              value: _settings.pace,
              onChanged: (v) =>
                  setState(() => _settings = _settings.copyWith(pace: v)),
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
              onPressed:
                  _busy || !ClassQuizRules.validSeconds(_settings.seconds)
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
  const _TopicChoice({
    required this.topic,
    required this.title,
    this.meta,
    this.untranslatedTitle = false,
  });

  final ClassTopic topic;
  final String title;
  final ClassQuizBankTopicMeta? meta;

  /// Til varianti sarlavhasi asl o‘zbekcha sarlavha bilan aynan bir xil
  /// (bank metama’lumoti yo‘q mavzular uchun: tarjima qilinmagan belgisi).
  final bool untranslatedTitle;

  /// Tarjimasi hali yo‘q: boshqa tilda asl o‘zbekcha matn ko‘rsatiladi.
  bool get translationPending {
    final vl = ClassQuizBank.variantLang(topic.id);
    if (vl == 'uz') return false;
    return meta?.isTranslationPending(vl) ?? untranslatedTitle;
  }

  /// Savollar avtomatik tarjima (ru/en, tekshirilmagan) bo‘lsa — belgi.
  bool get machineTranslated {
    final vl = ClassQuizBank.variantLang(topic.id);
    if (translationPending) return false;
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
    // Bank meta’si yo‘q mavzular: dars kursi bo‘yicha (bo‘lmasa — «Boshqa»).
    final course = g == null ? topic.course.trim() : '';
    final gid = g?.id ?? (course.isEmpty ? '_other' : 'course:$course');
    final group = groups.putIfAbsent(
      gid,
      () => _TopicGroupData(
        gid,
        g?.title(lang) ?? (course.isEmpty ? l.classTopicGroupOther : course),
        g?.order ??
            (course.isEmpty ? 1 << 20 : (1 << 19) + course.hashCode % 1000),
      ),
    );
    final title = _choiceTitle(topic, bank, lang);
    if (q.isNotEmpty &&
        !title.toLowerCase().contains(q) &&
        !group.title.toLowerCase().contains(q)) {
      continue;
    }
    group.items.add(
      _TopicChoice(
        topic: topic,
        title: title,
        meta: meta,
        untranslatedTitle:
            meta == null &&
            ClassQuizBank.variantLang(topic.id) != 'uz' &&
            v['uz'] != null &&
            v['uz']!.title == topic.title,
      ),
    );
  }
  final out =
      [
        for (final g in groups.values)
          if (g.items.isNotEmpty) g,
      ]..sort((a, b) {
        final c = a.order.compareTo(b.order);
        return c != 0 ? c : a.title.compareTo(b.title);
      });
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
                if (item.translationPending)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      key: Key('class.translationPending.${topic.id}'),
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 14,
                          color: c.textSecondary,
                        ),
                        const SizedBox(width: FeSpace.xxs),
                        Flexible(
                          child: Text(
                            l.classTranslationPending,
                            style: t.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
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

/// Savol soni: 10 / 15 / 20 chiplari (+ «Boshqa» — min..mavjud maksimum).
/// Mavzuda savol yetmasa, ortiqcha chiplar o‘chiriladi va mavjud maksimum
/// «Hammasi · N» chipi bilan taklif qilinadi.
class _QuestionCountPicker extends StatelessWidget {
  const _QuestionCountPicker({
    required this.value,
    required this.maxAvailable,
    required this.custom,
    required this.onPick,
    required this.onCustom,
    required this.onSlide,
  });

  final int value;
  final int maxAvailable;
  final bool custom;
  final ValueChanged<int> onPick;
  final VoidCallback onCustom;
  final ValueChanged<int> onSlide;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    const presets = ClassQuizRules.questionPresets;
    final all = maxAvailable;
    final showAll =
        !presets.contains(all) && all >= ClassQuizRules.minQuestions;
    final canCustom = all > ClassQuizRules.minQuestions;
    final limited = all < presets.last;
    return Column(
      key: const Key('class.questionCount'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(l.classQuestionCount, style: t.titleSmall)),
            Text(
              value.toString(),
              key: const Key('class.questionCountValue'),
              style: t.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: FeSpace.xs),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            for (final n in presets)
              ChoiceChip(
                key: Key('class.count.$n'),
                label: Text(n.toString()),
                selected: !custom && value == n,
                onSelected: n <= all ? (_) => onPick(n) : null,
              ),
            if (showAll)
              ChoiceChip(
                key: const Key('class.count.all'),
                label: Text(l.classQuestionCountAll(all)),
                selected: !custom && value == all,
                onSelected: (_) => onPick(all),
              ),
            if (canCustom)
              ChoiceChip(
                key: const Key('class.count.custom'),
                label: Text(l.classQuestionCountOther),
                selected: custom,
                onSelected: (_) => onCustom(),
              ),
          ],
        ),
        if (limited)
          Padding(
            padding: const EdgeInsets.only(top: FeSpace.xs),
            child: Text(
              l.classQuestionCountLimited(all),
              key: const Key('class.countLimited'),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
        if (custom && canCustom)
          Slider(
            key: const Key('class.sliderQuestions'),
            value: value.clamp(ClassQuizRules.minQuestions, all).toDouble(),
            min: ClassQuizRules.minQuestions.toDouble(),
            max: all.toDouble(),
            divisions: all - ClassQuizRules.minQuestions,
            label: value.toString(),
            semanticFormatterCallback: (v) => v.round().toString(),
            onChanged: (v) => onSlide(v.round()),
          ),
        const SizedBox(height: FeSpace.xs),
      ],
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

  /// Oxirgi yaxshi panel holati: bitta polling xatosi proyektorni xato
  /// ekraniga almashtirmaydi.
  ClassDashboard? _last;
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

  /// Testni tasdiq bilan tugatish (AppBar tugmasi va self doskasi uchun bitta yo‘l).
  Future<void> _endSession(String sessionId) async {
    final l = AppLocalizations.of(context);
    final svc = ref.read(classQuizServiceProvider);
    if (await _confirm(l.classEndTitle, l.classEndBody, l.classEndAction)) {
      await _run(() => svc.finish(sessionId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final svc = ref.watch(classQuizServiceProvider);
    final dash = ref.watch(classDashboardProvider(widget.sessionId));
    final fresh = dash.value?.value;
    final failure = dash.value?.failure;
    if (fresh != null) _last = fresh;
    final fatal =
        failure == ClassFailure.forbidden ||
        failure == ClassFailure.notSignedIn;
    final last = _last?.session.id == widget.sessionId ? _last : null;
    final d = fresh ?? (fatal ? null : last);
    final reconnecting = fresh == null && d != null && failure != null;

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
        onFinish: () => _endSession(d.session.id),
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
              onPressed: () => _endSession(d.session.id),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (reconnecting) const ClassReconnectingBar(onDark: true),
            Expanded(child: body),
          ],
        ),
      ),
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
    required this.onFinish,
  });

  final ClassDashboard d;
  final bool busy;
  final VoidCallback onStart;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final void Function(ClassParticipant) onKick;
  final VoidCallback onExport;
  final VoidCallback onDone;

  /// «Testni tugatish» (tasdiqlash bilan) — o‘z tezligida rejimining asosiy amali.
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = MediaQuery.sizeOf(context).width >= 600;
    return switch (d.session.status) {
      ClassSessionStatus.lobby => _Lobby(
        d: d,
        wide: wide,
        busy: busy,
        onStart: onStart,
        onKick: onKick,
      ),
      ClassSessionStatus.running =>
        d.session.isSelfPaced
            ? ClassSelfBoard(d: d, busy: busy, onFinish: onFinish)
            : _Running(
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

    /// Kod, QR va havola; keng ekranda QR mavjud balandlikka moslanadi
    /// ([qrSize], [codeSize]) — aylantirish kerak bo‘lmasin.
    Widget joinColumn(double qrSize, double codeSize, double gap) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.classHostJoinHint,
          textAlign: TextAlign.center,
          style: t.titleMedium?.copyWith(color: Colors.white),
        ),
        SizedBox(height: gap),
        ClassCodeBanner(code: d.session.code, fontSize: codeSize),
        SizedBox(height: gap),
        ClassQr(data: link.toString(), size: qrSize),
        const SizedBox(height: FeSpace.xs),
        SelectableText(
          link.toString(),
          key: const Key('class.joinLink'),
          textAlign: TextAlign.center,
          maxLines: 2,
          style: t.bodySmall?.copyWith(color: const Color(0xFFC9D2E0)),
        ),
      ],
    );
    final join = joinColumn(min(220.0, shortest * 0.6), 56, FeSpace.sm);

    final people = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (d.session.isSelfPaced)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: Text(
              l.classPaceLine(l.classPaceSelf),
              key: const Key('class.paceLine'),
              style: t.titleSmall?.copyWith(color: FeBrand.goldOnDark),
            ),
          ),
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
      // Keng ekran (proyektor): bir ekranga sig‘adi. Kod va QR balandlikka
      // moslanadi, ishtirokchilar o‘z qutisida aylanadi, «Boshlash» tugmasi
      // doim pastda ko‘rinadi.
      return LayoutBuilder(
        builder: (context, box) {
          final dense = box.maxHeight < 440;
          final pad = dense ? FeSpace.sm : FeSpace.lg;
          final codeSize = dense ? 56.0 : 96.0;
          final gap = dense ? FeSpace.xs : FeSpace.md;
          // Matn qismlari egallaydigan balandlik (sarlavha, kod, havola,
          // QR ramkasi) — qolgani QR’ga.
          final reserved =
              (dense ? 76 : 52) +
              codeSize * 1.1 +
              2 * gap +
              16 +
              FeSpace.xs +
              36;
          final qr = (box.maxHeight - 2 * pad - reserved).clamp(80.0, 300.0);
          return Padding(
            padding: EdgeInsets.all(pad),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Center(child: joinColumn(qr, codeSize, gap)),
                ),
                SizedBox(width: pad),
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
                      SizedBox(height: dense ? FeSpace.xs : FeSpace.sm),
                      start,
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
    // To‘g‘ri javob, sonlar va izoh — faqat server `revealed` deganda (vaqt
    // tugagach ham javob qabul qilish imtiyozi bor; proyektor oldinroq
    // ochsa, kechikkan talaba ko‘rib qolardi).
    final revealed = d.revealed;
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

    List<ClassOptionTile> makeTiles({
      required bool big,
      bool dense = false,
      int? maxLines,
    }) => [
      for (var i = 0; i < cur.options.length; i++)
        ClassOptionTile(
          key: Key('class.hostOption.${cur.options[i].id}'),
          letter: classOptionLetter(i),
          text: cur.options[i].text,
          big: big,
          dense: dense,
          maxLines: maxLines,
          // Proyektorda ko‘rinadi: to‘g‘ri javob va sonlar faqat vaqt
          // tugagach (talabalar ko‘rib qolmasin).
          state: revealed
              ? (cur.options[i].id == cur.correctOption
                    ? ClassOptionState.correct
                    : ClassOptionState.neutral)
              : ClassOptionState.neutral,
          count: revealed ? cur.options[i].count : null,
          fraction: revealed ? (cur.options[i].count ?? 0) / maxCount : null,
        ),
    ];

    final options = Column(
      children: [
        for (final tile in makeTiles(big: false))
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
              if (revealed && cur.correctPct != null) ...[
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
                  _LeaderRowView(row: r, compact: true, total: d.session.total),
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

    final explanation = revealed && cur.explanation.isNotEmpty
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
      return _BigRunning(
        d: d,
        busy: busy,
        last: last,
        revealed: revealed,
        closed: closed,
        makeTiles: makeTiles,
        onNext: onNext,
        onClose: onClose,
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

/// Keng ekran (proyektor/TV, landshaft ≥ 600 dp) uchun «ishlayotgan savol»:
/// har bosqich (ochiq, yopilgan, javob ochilgan) bir ekranga sig‘adi.
/// Chap: savol + variantlar (+ ixcham izoh); o‘ng: holat va reyting; pastda
/// doim ko‘rinadigan tugmalar paneli. Balandlikka qarab uch daraja:
/// 0 — past (landshaft telefon, <440 dp), 1 — o‘rta (1280×720, 1024×600),
/// 2 — to‘liq (1920×1080).
class _BigRunning extends StatelessWidget {
  const _BigRunning({
    required this.d,
    required this.busy,
    required this.last,
    required this.revealed,
    required this.closed,
    required this.makeTiles,
    required this.onNext,
    required this.onClose,
  });

  final ClassDashboard d;
  final bool busy;
  final bool last;
  final bool revealed;
  final bool closed;
  final List<ClassOptionTile> Function({
    required bool big,
    bool dense,
    int? maxLines,
  })
  makeTiles;
  final VoidCallback onNext;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cur = d.current!;
    return LayoutBuilder(
      builder: (context, box) {
        final h = box.maxHeight;
        final tier = h < 440 ? 0 : (h < 760 ? 1 : 2);
        final pad = const [FeSpace.sm, FeSpace.md, FeSpace.lg][tier];
        final gap = const [6.0, 12.0, 16.0][tier];
        final tileH = const [48.0, 66.0, 92.0][tier];
        final btnH = const [44.0, 52.0, 60.0][tier];
        final cdSize = const [44.0, 72.0, 96.0][tier];

        final header = Row(
          children: [
            Expanded(
              child: Text(
                l.classQuestionOf(d.session.currentIndex + 1, d.session.total),
                style: (tier == 0 ? t.titleMedium : t.titleLarge)?.copyWith(
                  color: FeBrand.goldOnDark,
                ),
              ),
            ),
            ClassCountdown(
              key: ValueKey('q${cur.index}'),
              remainingMs: d.remainingMs,
              totalMs: d.session.seconds * 1000,
              size: cdSize,
              onDark: true,
            ),
          ],
        );

        final qStyle = switch (tier) {
          0 => t.titleMedium?.copyWith(fontSize: 18),
          1 => t.headlineSmall,
          _ => t.headlineMedium,
        };
        final question = SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Text(
            cur.text,
            key: const Key('class.hostQuestion'),
            style: qStyle?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        );

        final tiles = makeTiles(big: tier == 2, dense: tier == 0, maxLines: 2);
        final rows = <Widget>[];
        for (var i = 0; i < tiles.length; i += 2) {
          rows.add(
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : gap / 2),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(height: tileH, child: tiles[i]),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: i + 1 < tiles.length
                        ? SizedBox(height: tileH, child: tiles[i + 1])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        }

        final explanation = revealed && cur.explanation.isNotEmpty
            ? Padding(
                padding: EdgeInsets.only(top: gap),
                child: _HostExplanation(
                  key: const Key('class.hostExplanation'),
                  text: cur.explanation,
                  maxLines: const [2, 3, 4][tier],
                ),
              )
            : const SizedBox.shrink();

        final left = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (tier > 0) ...[header, SizedBox(height: gap)],
            Flexible(fit: FlexFit.loose, child: question),
            SizedBox(height: gap),
            ...rows,
            explanation,
          ],
        );

        final right = _HostSidePanel(
          d: d,
          tier: tier,
          revealed: revealed,
          header: tier == 0 ? header : null,
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
                    minimumSize: Size.fromHeight(btnH),
                  ),
                ),
              ),
            if (!closed) SizedBox(width: gap),
            Expanded(
              child: FilledButton.icon(
                key: const Key('class.nextButton'),
                onPressed: busy ? null : onNext,
                icon: Icon(last ? Icons.flag_outlined : Icons.skip_next),
                label: Text(last ? l.classFinishAction : l.classNextQuestion),
                style: FilledButton.styleFrom(
                  minimumSize: Size.fromHeight(btnH),
                ),
              ),
            ),
          ],
        );

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 6, child: left),
                    SizedBox(width: pad),
                    Expanded(flex: 3, child: right),
                  ],
                ),
              ),
            ),
            // Asosiy amal doim ko‘rinadi: pastga mahkamlangan panel.
            Padding(padding: EdgeInsets.all(pad), child: controls),
          ],
        );
      },
    );
  }
}

/// O‘ng panel: javob berganlar, to‘g‘ri foiz, reyting (sig‘adigan top N) va
/// ishtirokchilar holati (o‘z qutisida aylanadi).
class _HostSidePanel extends StatelessWidget {
  const _HostSidePanel({
    required this.d,
    required this.tier,
    required this.revealed,
    this.header,
  });

  final ClassDashboard d;
  final int tier;
  final bool revealed;

  /// Past darajada savol raqami va taymer shu yerda (chap ustun savolga qoladi).
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final cur = d.current!;
    final gap = tier == 0 ? 6.0 : FeSpace.sm;
    final cardPad = tier == 0 ? FeSpace.sm : FeSpace.md;
    final showPct = revealed && cur.correctPct != null;

    final stats = FeCard(
      key: const Key('class.liveStats'),
      padding: EdgeInsets.all(cardPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.classAnswered(cur.answered, d.joined),
            key: const Key('class.answeredCount'),
            style: (tier == 0 ? t.titleSmall : t.titleMedium)?.copyWith(
              fontFamily: FeFonts.sans,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: tier == 0 ? 4 : FeSpace.xs),
          LinearProgressIndicator(
            value: d.joined == 0 ? 0 : cur.answered / d.joined,
            minHeight: tier == 0 ? 6 : 8,
          ),
          if (showPct) ...[
            SizedBox(height: tier == 0 ? 4 : FeSpace.xs),
            Text(
              l.classCorrectPct(cur.correctPct!),
              key: const Key('class.correctPct'),
              style: t.titleSmall?.copyWith(color: c.verified),
            ),
          ],
        ],
      ),
    );

    // Reyting: balandlikka sig‘adigan eng yuqori N qator.
    final board = FeCard(
      key: const Key('class.leaderboard'),
      padding: EdgeInsets.all(cardPad),
      child: LayoutBuilder(
        builder: (context, box) {
          final rowH = tier == 0 ? 24.0 : 30.0;
          final titleH = tier == 0 ? 22.0 : 28.0;
          final n = ((box.maxHeight - titleH) / rowH).floor().clamp(1, 10);
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.classLeaderboard, style: t.titleSmall),
                SizedBox(height: tier == 0 ? 2 : FeSpace.xs),
                if (d.leaderboard.isEmpty)
                  Text(l.classNoScoresYet, style: t.bodySmall)
                else
                  for (final r in d.leaderboard.take(n))
                    SizedBox(
                      height: rowH,
                      child: _LeaderRowView(row: r, compact: true),
                    ),
              ],
            ),
          );
        },
      ),
    );

    final status = d.participants.isEmpty
        ? null
        : FeCard(
            padding: EdgeInsets.all(cardPad),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: _ParticipantStatusGrid(
                participants: d.participants,
                big: tier == 2,
              ),
            ),
          );

    // Past ekranda ikkalasi sig‘maydi: ochiq savolda — kim javob berdi,
    // javob ochilgach — reyting. Balandroq ekranda ikkalasi ham ko‘rinadi.
    final showBoard = tier > 0 || revealed || status == null;
    final statusCard = status;
    final showStatus = statusCard != null && (tier > 0 || !revealed);
    final boardFlex = revealed ? 3 : 2;
    final statusFlex = revealed ? 2 : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) ...[header!, SizedBox(height: gap)],
        stats,
        SizedBox(height: gap),
        if (showBoard) Expanded(flex: boardFlex, child: board),
        if (showBoard && showStatus) SizedBox(height: gap),
        if (showStatus) Expanded(flex: statusFlex, child: statusCard),
      ],
    );
  }
}

/// Ixcham izoh: ko‘pi bilan [maxLines] qator va «…»; bosilsa — to‘liq matn
/// pastki oynada (o‘z ichida aylanadi). Proyektorda ekranni itarmaydi.
class _HostExplanation extends StatelessWidget {
  const _HostExplanation({
    super.key,
    required this.text,
    required this.maxLines,
  });

  final String text;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final style = (maxLines >= 4 ? t.bodyLarge : t.bodyMedium)?.copyWith(
      color: c.textPrimary,
      height: 1.35,
    );
    return Material(
      color: c.surface,
      borderRadius: BorderRadius.circular(FeRadius.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (sheet) => SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheet).height * 0.7,
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  FeSpace.lg,
                  0,
                  FeSpace.lg,
                  FeSpace.lg,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: c.reviewed),
                    const SizedBox(width: FeSpace.sm),
                    Expanded(
                      child: Text(
                        text,
                        style: t.titleMedium?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: FeSpace.sm,
            vertical: FeSpace.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline, size: 20, color: c.reviewed),
              const SizedBox(width: FeSpace.sm),
              Expanded(
                child: Text(
                  text,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
              ),
            ],
          ),
        ),
      ),
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

/// «Qiyin savol» qatori: bosilsa muhokama sahifasi ochiladi. Faqat savol
/// matni va to‘g‘ri javoblar foizi (talaba ismlari yo‘q).
class _HardestRow extends StatelessWidget {
  const _HardestRow({required this.h, required this.onTap});

  final ClassHardQuestion h;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    // Proyektor/katta ekranda o‘qiladigan shrift.
    final big = MediaQuery.sizeOf(context).width >= 900;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: InkWell(
        key: Key('class.hardest.${h.index}'),
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(h.text, style: big ? t.titleMedium : null),
                ),
                const SizedBox(width: FeSpace.xs),
                Text(
                  l.classCorrectPct(h.correctPct),
                  style: (big ? t.titleMedium : t.titleSmall)?.copyWith(
                    color: h.correctPct < 50 ? c.danger : c.verified,
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

class _LeaderRowView extends StatelessWidget {
  const _LeaderRowView({
    required this.row,
    this.compact = false,
    this.total,
    this.showGrade = false,
    this.leaveCount = 0,
    this.tooFast = false,
  });

  final ClassLeaderRow row;
  final bool compact;

  /// Anti-cheat ishoralari (faqat ustoz natijalarida; ayblov emas).
  final int leaveCount;
  final bool tooFast;

  /// Sessiyadagi savollar soni («7/10 to‘g‘ri» uchun); bilinmasa — ko‘rsatilmaydi.
  final int? total;

  /// Yakuniy natija: «Ball (100) · Baho» qatori (tezlik ballari reytingi
  /// o‘zgarmaydi).
  final bool showGrade;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    // Ism va ball — sans (jadval o‘qilishi); sarlavhalar serif.
    final style = (compact ? t.bodyMedium : t.titleMedium)?.copyWith(
      fontFamily: FeFonts.sans,
      fontWeight: compact ? null : FontWeight.w600,
    );
    final parts = <String>[
      if (total != null && total! > 0)
        l.classLeaderCorrect(row.correct, total!),
      if (row.avgMs != null)
        l.classLeaderAvgTime((row.avgMs! / 1000).toStringAsFixed(1)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              row.rank.toString(),
              key: Key('class.rank.${row.participantId}'),
              style: style?.copyWith(
                color: row.rank == 1 ? FeBrand.goldOnDark : c.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.nickname,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
                if (parts.isNotEmpty)
                  Text(
                    parts.join(' · '),
                    key: Key('class.rankDetail.${row.participantId}'),
                    style: t.bodySmall?.copyWith(
                      fontFamily: FeFonts.sans,
                      color: c.textSecondary,
                    ),
                  ),
                if (showGrade && total != null && total! > 0)
                  ScoreGradeLine(
                    key: Key('class.grade.${row.participantId}'),
                    correct: row.correct,
                    total: total!,
                    style: t.bodySmall?.copyWith(
                      fontFamily: FeFonts.sans,
                      color: c.textSecondary,
                    ),
                  ),
                AntiCheatFlags(
                  leaveCount: leaveCount,
                  tooFast: tooFast,
                  idSuffix: '.${row.participantId}',
                ),
              ],
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
    if (MediaQuery.sizeOf(context).width >= 600) return _bigLayout(context);
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
                    const SizedBox(height: FeSpace.xxs),
                    Text(
                      scoreApproxNote(l),
                      key: const Key('class.scoreApproxNote'),
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                    const SizedBox(height: FeSpace.xs),
                    if (d.leaderboard.isEmpty)
                      Text(l.classNoScoresYet)
                    else
                      for (final r in d.leaderboard)
                        _LeaderRowView(
                          row: r,
                          total: d.session.total,
                          showGrade: true,
                          leaveCount: d.leaveCountOf(r.participantId),
                          tooFast: classLeaderLooksTooFast(r, d.session.total),
                        ),
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
                        _HardestRow(
                          h: h,
                          onTap: () => openClassHardestDiscussion(
                            context,
                            sessionId: d.session.id,
                            hardest: d.hardest,
                            questionIndex: h.index,
                          ),
                        ),
                    if (d.hardest.isNotEmpty)
                      Text(
                        l.classHardestOpenHint,
                        key: const Key('class.hardest.hint'),
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: FeSpace.md),
              FilledButton.icon(
                key: const Key('class.exportButton'),
                onPressed: onExport,
                icon: const ProIcon(
                  feature: ProFeature.resultsCsv,
                  icon: Icons.ios_share,
                ),
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

  /// Keng ekran: reyting va eng qiyin savollar yonma-yon, har biri o‘z
  /// qutisida aylanadi; «CSV» va «Tayyor» tugmalari pastda doim ko‘rinadi.
  Widget _bigLayout(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final dense = box.maxHeight < 440;
        final pad = dense ? FeSpace.sm : FeSpace.lg;
        final gap = dense ? FeSpace.xs : FeSpace.sm;
        final btnH = dense ? 44.0 : 52.0;
        final muted = t.bodySmall?.copyWith(color: const Color(0xFFC9D2E0));
        final board = FeCard(
          key: const Key('class.finalBoard'),
          padding: EdgeInsets.all(dense ? FeSpace.sm : FeSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.classLeaderboard, style: t.titleMedium),
              Text(
                scoreApproxNote(l),
                key: const Key('class.scoreApproxNote'),
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
              SizedBox(height: gap),
              Expanded(
                child: d.leaderboard.isEmpty
                    ? Text(l.classNoScoresYet)
                    : ListView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        children: [
                          for (final r in d.leaderboard)
                            _LeaderRowView(
                              row: r,
                              total: d.session.total,
                              showGrade: true,
                              leaveCount: d.leaveCountOf(r.participantId),
                              tooFast: classLeaderLooksTooFast(
                                r,
                                d.session.total,
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        );
        final hardest = FeCard(
          key: const Key('class.hardest'),
          padding: EdgeInsets.all(dense ? FeSpace.sm : FeSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.classHardestTitle, style: t.titleMedium),
              SizedBox(height: gap),
              Expanded(
                child: d.hardest.isEmpty
                    ? Text(l.classNoAnswersYet, style: t.bodySmall)
                    : ListView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        children: [
                          for (final h in d.hardest)
                            _HardestRow(
                              h: h,
                              onTap: () => openClassHardestDiscussion(
                                context,
                                sessionId: d.session.id,
                                hardest: d.hardest,
                                questionIndex: h.index,
                              ),
                            ),
                        ],
                      ),
              ),
              if (d.hardest.isNotEmpty)
                Text(
                  l.classHardestOpenHint,
                  key: const Key('class.hardest.hint'),
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
            ],
          ),
        );
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l.classFinishedTitle,
                      key: const Key('class.finishedTitle'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: (dense ? t.titleLarge : t.headlineMedium)
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      l.classFinishedSummary(d.joined, d.session.total),
                      style: (dense ? t.bodyMedium : t.bodyLarge)?.copyWith(
                        color: const Color(0xFFC9D2E0),
                      ),
                    ),
                    SizedBox(height: gap),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 5, child: board),
                          SizedBox(width: pad),
                          Expanded(flex: 4, child: hardest),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(pad, gap, pad, gap),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          key: const Key('class.exportButton'),
                          onPressed: onExport,
                          icon: const ProIcon(
                            feature: ProFeature.resultsCsv,
                            icon: Icons.ios_share,
                          ),
                          label: Text(l.classExportCsv),
                          style: FilledButton.styleFrom(
                            minimumSize: Size.fromHeight(btnH),
                          ),
                        ),
                      ),
                      SizedBox(width: gap),
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('class.doneButton'),
                          onPressed: onDone,
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.fromHeight(btnH),
                          ),
                          child: Text(l.classDone),
                        ),
                      ),
                    ],
                  ),
                  if (!dense) ...[
                    const SizedBox(height: 4),
                    Text(
                      l.classRetentionNote(ClassQuizRules.retentionDays),
                      style: muted,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
