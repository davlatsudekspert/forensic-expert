import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/class_groups.dart';
import '../../../app/class_quiz.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_groups/class_groups_models.dart';
import '../../../domain/class_quiz/class_quiz_models.dart' show ClassTopic;
import '../../class_quiz/presentation/class_quiz_widgets.dart'
    show ClassQr, classFailureText;
import '../../professional/presentation/professional_widgets.dart' show FeNote;
import 'assign_test_screen.dart' show pickTopicVariant;
import 'group_widgets.dart';
import 'test_settings.dart';

/// Dars oxiridagi «Guruhga test berish» (egasi qarori, 2026-10-24).
///
/// Bitta sahifada: guruh (ro‘yxatdan tanlash yoki shu yerda yaratish) →
/// mavzu (dars mavzusi, o‘zgartirib bo‘lmaydi) → savol soni 10/15/20, vaqt
/// chegarasi (standart 15 daqiqa), ochiq turish muddati (standart 1 kun) →
/// «Testni boshlash» → guruh QR + kod va «Jonli natijalar» doskasi.
/// Talabalar guruhga QR/kod bilan o‘z ismi bilan qo‘shiladi.
class LessonGroupTestScreen extends ConsumerStatefulWidget {
  const LessonGroupTestScreen({super.key, required this.topicId});

  /// Dars (deck) id si == test banki mavzusi.
  final String topicId;

  @override
  ConsumerState<LessonGroupTestScreen> createState() => _LessonGroupState();
}

class _LessonGroupState extends ConsumerState<LessonGroupTestScreen> {
  static const _presets = [10, 15, 20];

  final _name = TextEditingController();
  String? _groupId;
  bool _creating = false;
  bool _busy = false;
  String? _nameError;
  String? _error;
  var _s = const TestSettings(timeLimit: 15);

  /// Test yaratilgach: QR/kod ekrani.
  GroupAssignment? _started;
  GroupInfo? _startedGroup;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final l = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.length < GroupRules.nameMin) {
      setState(() => _nameError = l.grpErrBadName);
      return;
    }
    setState(() {
      _busy = true;
      _nameError = null;
    });
    final r = await ref.read(classGroupsServiceProvider).create(name);
    if (!mounted) return;
    final g = r.value;
    if (g == null) {
      setState(() {
        _busy = false;
        _nameError = groupFailureText(l, r.failure!, r.extra);
      });
      return;
    }
    ref.invalidate(groupListProvider);
    await ref.read(groupListProvider.future);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _creating = false;
      _groupId = g.id;
      _name.clear();
    });
  }

  Future<void> _start(ClassTopic topic, GroupInfo group) async {
    final l = AppLocalizations.of(context);
    final now = ref.read(groupNowProvider)();
    final draft = _s.draft(topicId: topic.id, poolSize: topic.count, now: now);
    final err = draft.validate(poolSize: topic.count, now: now);
    if (err != null) {
      setState(
        () => _error = groupFailureText(l, err, {
          'available': topic.count,
          'needed': _s.count * 2,
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
        .createAssignment(group.id, draft);
    if (!mounted) return;
    final a = r.value;
    if (a == null) {
      setState(() {
        _busy = false;
        _error = groupFailureText(l, r.failure!, r.extra);
      });
      return;
    }
    ref.invalidate(groupDetailProvider(group.id));
    setState(() {
      _busy = false;
      _started = a;
      _startedGroup = group;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final started = _started;
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.grpLessonTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('grp.lesson.list'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: FeSpace.xl),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.xs),
                  const GroupDemoBanner(),
                  if (started != null && _startedGroup != null)
                    ..._startedBody(context, started, _startedGroup!)
                  else
                    ..._formBody(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------- sozlash

  List<Widget> _formBody(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final groups = ref.watch(groupListProvider);
    final topics = ref.watch(classTopicsProvider);
    final all = topics.value?.value ?? const <ClassTopic>[];
    final topicId = pickTopicVariant(all, widget.topicId, lang);
    final topic = all.where((x) => x.id == topicId).firstOrNull;
    if (topic != null && _s.count > topic.count) {
      _s = _s.copyWith(count: max(1, topic.count));
    }

    final teaching = groups.value?.value?.teaching ?? const <GroupInfo>[];
    // Bitta guruh bo‘lsa — oldindan tanlangan.
    final chosenId =
        _groupId ?? (teaching.length == 1 ? teaching.single.id : null);
    final group = teaching.where((g) => g.id == chosenId).firstOrNull;

    final Widget groupPart;
    if (groups.isLoading && groups.value == null) {
      groupPart = FeListSkeleton(semanticLabel: l.grpLessonGroupSection);
    } else if (groups.value?.ok != true) {
      groupPart = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FeNote(
            key: const Key('grp.lesson.groupsError'),
            icon: Icons.error_outline,
            text: groupFailureText(
              l,
              groups.value?.failure ?? GroupFailure.server,
            ),
          ),
          TextButton(
            onPressed: () => ref.invalidate(groupListProvider),
            child: Text(l.grpRetry),
          ),
        ],
      );
    } else if (teaching.isEmpty || _creating) {
      groupPart = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (teaching.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xs),
              child: Text(
                l.grpLessonNoGroups,
                key: const Key('grp.lesson.noGroups'),
                style: t.bodyMedium?.copyWith(color: c.textSecondary),
              ),
            ),
          TextField(
            key: const Key('grp.lesson.nameField'),
            controller: _name,
            maxLength: GroupRules.nameMax,
            textInputAction: TextInputAction.done,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            onSubmitted: (_) => _createGroup(),
            decoration: InputDecoration(
              labelText: l.grpNameLabel,
              helperText: l.grpNameHelper,
              helperMaxLines: 2,
              errorText: _nameError,
            ),
          ),
          const SizedBox(height: FeSpace.xs),
          FilledButton(
            key: const Key('grp.lesson.createGroup'),
            onPressed: _busy ? null : _createGroup,
            child: Text(l.grpLessonCreateGroup),
          ),
          if (teaching.isNotEmpty)
            TextButton(
              key: const Key('grp.lesson.cancelNew'),
              onPressed: () => setState(() {
                _creating = false;
                _nameError = null;
              }),
              child: Text(l.grpLessonCancelNew),
            ),
        ],
      );
    } else {
      groupPart = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final g in teaching)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xxs),
              child: FeCard(
                key: Key('grp.lesson.group.${g.id}'),
                color: g.id == chosenId ? c.accentContainer : null,
                padding: const EdgeInsets.symmetric(
                  horizontal: FeSpace.md,
                  vertical: FeSpace.sm,
                ),
                onTap: () => setState(() => _groupId = g.id),
                child: Row(
                  children: [
                    Icon(
                      g.id == chosenId
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: g.id == chosenId ? c.accent : c.textSecondary,
                    ),
                    const SizedBox(width: FeSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.name, style: t.titleSmall),
                          Text(
                            l.grpMembersCount(g.memberCount, g.memberLimit),
                            style: t.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: const Key('grp.lesson.newGroup'),
              onPressed: () => setState(() => _creating = true),
              icon: const Icon(Icons.add),
              label: Text(l.grpLessonNewGroup),
            ),
          ),
        ],
      );
    }

    final Widget topicPart;
    if (topics.isLoading && topics.value == null) {
      topicPart = FeListSkeleton(semanticLabel: l.grpLessonTopicSection);
    } else if (topics.value?.ok != true) {
      topicPart = FeNote(
        icon: Icons.error_outline,
        text: classFailureText(l, topics.value!.failure!),
      );
    } else if (topic == null) {
      topicPart = FeEmptyState(
        key: const Key('grp.lesson.noTopic'),
        icon: Icons.quiz_outlined,
        body: l.grpLessonNoTopic,
        compact: true,
      );
    } else {
      topicPart = FeCard(
        key: const Key('grp.lesson.topic'),
        color: c.accentContainer,
        child: Row(
          children: [
            Icon(Icons.menu_book_outlined, color: c.accent),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topic.title, style: t.titleSmall),
                  Text(
                    l.classQuestionsAvailable(topic.count),
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final canStart = topic != null && group != null && !_busy;
    return [
      FeSectionHeader(l.grpLessonGroupSection),
      groupPart,
      FeSectionHeader(l.grpLessonTopicSection),
      topicPart,
      if (topic != null)
        Padding(
          padding: const EdgeInsets.only(top: FeSpace.xxs),
          child: Text(
            l.grpLessonTopicFixed,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ),
      if (topic != null)
        TestSettingsSection(
          simple: true,
          value: _s,
          poolSize: topic.count,
          countPresets: _presets,
          now: ref.read(groupNowProvider),
          onChanged: (v) => setState(() => _s = v),
        ),
      if (_error != null) ...[
        const SizedBox(height: FeSpace.xs),
        Semantics(
          liveRegion: true,
          child: Text(
            _error!,
            key: const Key('grp.lesson.error'),
            style: t.bodyMedium?.copyWith(color: c.danger),
          ),
        ),
      ],
      const SizedBox(height: FeSpace.md),
      FilledButton.icon(
        key: const Key('grp.lesson.start'),
        onPressed: canStart ? () => _start(topic, group) : null,
        icon: const Icon(Icons.play_arrow),
        label: Text(l.grpLessonStart),
      ),
      if (topic != null && group == null && teaching.isNotEmpty && !_creating)
        Padding(
          padding: const EdgeInsets.only(top: FeSpace.xxs),
          child: Text(
            l.grpLessonPickGroup,
            key: const Key('grp.lesson.pickHint'),
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ),
    ];
  }

  // -------------------------------------------------------- QR + kod

  List<Widget> _startedBody(
    BuildContext context,
    GroupAssignment a,
    GroupInfo g,
  ) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final code = g.code ?? '';
    final link = GroupCode.link(code, assignmentId: a.id).toString();
    return [
      FeBanner(
        key: const Key('grp.lesson.started'),
        icon: Icons.check_circle_outline,
        text: l.grpLessonStartedTitle,
      ),
      const SizedBox(height: FeSpace.sm),
      Text(g.name, style: t.titleLarge, key: const Key('grp.lesson.groupName')),
      const SizedBox(height: FeSpace.xxs),
      Text(
        a.topicTitle,
        style: t.titleSmall,
        key: const Key('grp.lesson.startedTopic'),
      ),
      const SizedBox(height: FeSpace.xxs),
      Text(
        groupAssignmentLine(context, l, a),
        style: t.bodySmall?.copyWith(color: c.textSecondary),
      ),
      const SizedBox(height: FeSpace.md),
      FeCard(
        key: const Key('grp.lesson.qr'),
        child: Column(
          children: [
            ClassQr(data: link, size: 200),
            const SizedBox(height: FeSpace.sm),
            Text(l.grpLessonJoinLink, style: t.labelMedium),
            const SizedBox(height: FeSpace.xxs),
            GroupCodeText(code: code, fontSize: 30),
            const SizedBox(height: FeSpace.xs),
            Text(
              l.grpLessonStartedHint,
              textAlign: TextAlign.center,
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
      const SizedBox(height: FeSpace.md),
      FilledButton.icon(
        key: const Key('grp.lesson.live'),
        onPressed: () => context.push(Routes.groupBoard(g.id, a.id)),
        icon: const Icon(Icons.leaderboard_outlined),
        label: Text(l.grpLessonLiveResults),
      ),
      const SizedBox(height: FeSpace.xs),
      OutlinedButton.icon(
        key: const Key('grp.lesson.panel'),
        onPressed: () => context.go(Routes.groupAssignment(g.id, a.id)),
        icon: const Icon(Icons.dashboard_outlined),
        label: Text(l.grpLessonTeacherPanel),
      ),
    ];
  }
}
