import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/class_groups.dart';
import '../../../app/class_quiz.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_groups/class_groups_models.dart';
import '../../../domain/class_groups/variant_draw.dart';
import '../../../domain/class_quiz/class_quiz_models.dart' show ClassTopic;
import '../../class_quiz/presentation/class_quiz_widgets.dart'
    show classFailureText;
import '../../professional/presentation/professional_widgets.dart' show FeNote;
import 'group_widgets.dart';

/// «Mavzu testi berish»: mavzu, savollar soni, vaqt chegarasi (1–180 daqiqa
/// yoki chegarasiz), muddat, variant rejimi, javoblar qachon ochilishi.
class AssignTestScreen extends ConsumerStatefulWidget {
  const AssignTestScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<AssignTestScreen> createState() => _AssignTestState();
}

class _AssignTestState extends ConsumerState<AssignTestScreen> {
  String? _topicId;
  String _query = '';
  int _count = 10;
  bool _limitOn = true;
  int _limit = 20;
  DateTime? _due;
  bool _variant = true;
  RevealPolicy _reveal = RevealPolicy.afterClose;
  bool _busy = false;
  String? _error;

  Future<void> _pickDue() async {
    final now = ref.read(groupNowProvider)();
    final base = _due ?? now.add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null || !mounted) return;
    setState(
      () => _due = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _submit(ClassTopic topic) async {
    final l = AppLocalizations.of(context);
    final variant = _variant && variantAllowed(topic.count, _count);
    final draft = AssignmentDraft(
      topicId: topic.id,
      questionCount: _count,
      timeLimitMin: _limitOn ? _limit : null,
      dueAt: _due,
      variantMode: variant,
      reveal: _due == null ? RevealPolicy.afterClose : _reveal,
    );
    final err = draft.validate(
      poolSize: topic.count,
      now: ref.read(groupNowProvider)(),
    );
    if (err != null) {
      setState(
        () => _error = groupFailureText(l, err, {
          'available': topic.count,
          'needed': _count * 2,
        }),
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final r = await ref
        .read(classGroupsServiceProvider)
        .createAssignment(widget.groupId, draft);
    if (!mounted) return;
    final a = r.value;
    if (a == null) {
      setState(() {
        _busy = false;
        _error = groupFailureText(l, r.failure!, r.extra);
      });
      return;
    }
    ref.invalidate(groupDetailProvider(widget.groupId));
    // Bu sahifa root navigatorda, jonli panel — shell ichida: `go` stekni
    // «Guruhlar → guruh → test paneli» qilib quradi (duplicate key yo‘q).
    context.go(Routes.groupAssignment(widget.groupId, a.id));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final topics = ref.watch(classTopicsProvider);
    final all = topics.value?.value ?? const <ClassTopic>[];
    final inLang = [
      for (final x in all)
        if (ClassQuizBank.variantLang(x.id) == lang) x,
    ];
    final list = (inLang.isEmpty ? all : inLang)
        .where(
          (x) =>
              _query.isEmpty ||
              x.title.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
    final selected = all.where((x) => x.id == _topicId).firstOrNull;
    final maxQ = selected == null
        ? GroupRules.maxQuestions
        : min(GroupRules.maxQuestions, selected.count);
    final count = _count.clamp(GroupRules.minQuestions, max(1, maxQ)).toInt();
    if (count != _count) _count = count;
    final canVariant =
        selected != null && variantAllowed(selected.count, _count);

    Widget topicList;
    if (topics.isLoading) {
      topicList = FeListSkeleton(semanticLabel: l.grpTopicSection);
    } else if (topics.value?.ok != true) {
      topicList = FeNote(
        icon: Icons.error_outline,
        text: classFailureText(l, topics.value!.failure!),
      );
    } else if (all.isEmpty) {
      topicList = FeEmptyState(
        key: const Key('grp.noTopics'),
        icon: Icons.quiz_outlined,
        body: l.classNoTopics,
      );
    } else {
      topicList = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('grp.topicSearch'),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            onChanged: (v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l.classTopicSearchHint,
              prefixIcon: const Icon(Icons.search),
              isDense: true,
            ),
          ),
          const SizedBox(height: FeSpace.xs),
          for (final x in list.take(selected == null ? 40 : 0))
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xxs),
              child: FeCard(
                key: Key('grp.topic.${x.id}'),
                padding: const EdgeInsets.symmetric(
                  horizontal: FeSpace.md,
                  vertical: FeSpace.sm,
                ),
                onTap: () => setState(() => _topicId = x.id),
                child: Row(
                  children: [
                    Expanded(child: Text(x.title, style: t.bodyLarge)),
                    Text(
                      l.classQuestionsAvailable(x.count),
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.grpAssignTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('grp.assignList'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: FeSpace.xl),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.xs),
                  const GroupDemoBanner(),
                  FeSectionHeader(l.grpTopicSection),
                  if (selected != null)
                    FeCard(
                      key: const Key('grp.selectedTopic'),
                      color: c.accentContainer,
                      onTap: () => setState(() => _topicId = null),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: c.accent),
                          const SizedBox(width: FeSpace.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(selected.title, style: t.titleSmall),
                                Text(
                                  l.classQuestionsAvailable(selected.count),
                                  style: t.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(l.grpChangeTopic, style: t.labelLarge),
                        ],
                      ),
                    )
                  else
                    topicList,
                  if (selected != null) ...[
                    FeSectionHeader(l.grpSettingsSection),
                    Text(
                      l.grpCountLabel(_count),
                      key: const Key('grp.countLabel'),
                      style: t.titleSmall,
                    ),
                    Slider(
                      key: const Key('grp.countSlider'),
                      value: _count.toDouble(),
                      min: GroupRules.minQuestions.toDouble(),
                      max: max(2, maxQ).toDouble(),
                      divisions: max(1, maxQ - 1),
                      label: _count.toString(),
                      onChanged: maxQ <= 1
                          ? null
                          : (v) => setState(() => _count = v.round()),
                    ),
                    SwitchListTile(
                      key: const Key('grp.limitSwitch'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(l.grpTimeLimitLabel),
                      subtitle: Text(
                        _limitOn ? l.grpMinutesN(_limit) : l.grpNoTimeLimit,
                      ),
                      value: _limitOn,
                      onChanged: (v) => setState(() => _limitOn = v),
                    ),
                    if (_limitOn)
                      Slider(
                        key: const Key('grp.limitSlider'),
                        value: _limit.toDouble(),
                        min: GroupRules.minTimeLimit.toDouble(),
                        max: GroupRules.maxTimeLimit.toDouble(),
                        divisions:
                            GroupRules.maxTimeLimit - GroupRules.minTimeLimit,
                        label: l.grpMinutesN(_limit),
                        onChanged: (v) => setState(() => _limit = v.round()),
                      ),
                    ListTile(
                      key: const Key('grp.dueTile'),
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_outlined),
                      title: Text(l.grpDueTitle),
                      subtitle: Text(
                        _due == null
                            ? l.grpNoDue
                            : l.grpDueLabel(feDueShort(context, _due!)),
                      ),
                      trailing: _due == null
                          ? null
                          : IconButton(
                              tooltip: l.grpClearDue,
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() => _due = null),
                            ),
                      onTap: _pickDue,
                    ),
                    SwitchListTile(
                      key: const Key('grp.variantSwitch'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(l.grpVariantLabel),
                      subtitle: Text(
                        canVariant
                            ? l.grpVariantHelp
                            : l.grpVariantTooFew(selected.count, _count * 2),
                        key: const Key('grp.variantNote'),
                      ),
                      value: canVariant && _variant,
                      onChanged: canVariant
                          ? (v) => setState(() => _variant = v)
                          : null,
                    ),
                    FeSectionHeader(l.grpRevealSection),
                    RadioGroup<RevealPolicy>(
                      groupValue: _due == null
                          ? RevealPolicy.afterClose
                          : _reveal,
                      onChanged: (v) => setState(() => _reveal = v!),
                      child: Column(
                        children: [
                          RadioListTile<RevealPolicy>(
                            key: const Key('grp.revealDue'),
                            contentPadding: EdgeInsets.zero,
                            value: RevealPolicy.afterDue,
                            enabled: _due != null,
                            title: Text(l.grpRevealAfterDue),
                            subtitle: _due == null
                                ? Text(l.grpRevealNeedsDue)
                                : null,
                          ),
                          RadioListTile<RevealPolicy>(
                            key: const Key('grp.revealClose'),
                            contentPadding: EdgeInsets.zero,
                            value: RevealPolicy.afterClose,
                            title: Text(l.grpRevealAfterClose),
                          ),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: FeSpace.xs),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _error!,
                          key: const Key('grp.assignError'),
                          style: t.bodyMedium?.copyWith(color: c.danger),
                        ),
                      ),
                    ],
                    const SizedBox(height: FeSpace.sm),
                    FilledButton.icon(
                      key: const Key('grp.assignSubmit'),
                      onPressed: _busy ? null : () => _submit(selected),
                      icon: const Icon(Icons.send),
                      label: Text(l.grpAssignSubmit),
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
