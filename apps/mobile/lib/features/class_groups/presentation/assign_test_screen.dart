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
import '../../../domain/class_quiz/class_quiz_models.dart' show ClassTopic;
import '../../class_quiz/presentation/class_quiz_widgets.dart'
    show classFailureText;
import '../../professional/presentation/professional_widgets.dart' show FeNote;
import 'group_widgets.dart';
import 'test_settings.dart';

/// Ilova tilidagi mavzu varianti (`<id>`, `<id>~ru`, `<id>~en`).
String? pickTopicVariant(List<ClassTopic> all, String id, String lang) {
  final base = ClassQuizBank.baseId(id);
  final variants = {
    for (final x in all)
      if (ClassQuizBank.baseId(x.id) == base)
        ClassQuizBank.variantLang(x.id): x,
  };
  return (variants[lang] ?? variants['uz'] ?? variants.values.firstOrNull)?.id;
}

/// «Mavzu testi berish»: mavzu va topshirish sozlamalari.
class AssignTestScreen extends ConsumerStatefulWidget {
  const AssignTestScreen({
    super.key,
    required this.groupId,
    this.initialTopicId,
  });

  final String groupId;
  final String? initialTopicId;

  @override
  ConsumerState<AssignTestScreen> createState() => _AssignTestState();
}

class _AssignTestState extends ConsumerState<AssignTestScreen> {
  String? _topicId;
  bool _initialApplied = false;
  String _query = '';
  var _s = const TestSettings();
  bool _busy = false;
  String? _error;

  Future<void> _submit(ClassTopic topic) async {
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
    final init = widget.initialTopicId;
    if (!_initialApplied && init != null && all.isNotEmpty) {
      _initialApplied = true;
      _topicId = pickTopicVariant(all, init, lang);
    }
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
    if (selected != null && _s.count > selected.count) {
      _s = _s.copyWith(count: max(1, selected.count));
    }

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
          for (final x in list.take(60))
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
                    const SizedBox(width: FeSpace.xs),
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
                    TestSettingsSection(
                      value: _s,
                      poolSize: selected.count,
                      countPresets: const [5, 10, 15, 20, 30],
                      now: ref.read(groupNowProvider),
                      onChanged: (v) => setState(() => _s = v),
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
