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
import '../../../domain/class_groups/variant_draw.dart';
import '../../../domain/class_quiz/class_quiz_models.dart' show ClassTopic;
import 'group_widgets.dart';
import 'test_settings.dart';

/// Manba (kurs/fan guruhi) va undagi tanlanadigan mavzular.
class MixedSource {
  const MixedSource(this.id, this.title, this.topics);

  final String id;
  final String title;
  final List<ClassTopic> topics;
}

/// Manbalar: savollar banki guruhlari (Darslar bilan bir xil: Davolash ishi,
/// Pediatriya, Tibbiy profilaktika, Bioetika, …) — ilova tilidagi
/// variantlar; guruhga kirmaganlari — «Boshqa mavzular».
List<MixedSource> mixedSources(
  ClassQuizBank bank,
  List<ClassTopic> server,
  String lang,
  String otherTitle,
) {
  final inLang = [
    for (final t in server)
      if (ClassQuizBank.variantLang(t.id) == lang) t,
  ];
  final pool = inLang.isEmpty ? server : inLang;
  final used = <String>{};
  final out = <MixedSource>[];
  for (final g in bank.groups) {
    final ts = [
      for (final m in bank.topics.where((m) => m.groupId == g.id))
        ?pool.where((t) => ClassQuizBank.baseId(t.id) == m.id).firstOrNull,
    ];
    if (ts.isEmpty) continue;
    used.addAll(ts.map((t) => t.id));
    out.add(MixedSource(g.id, g.title(lang), ts));
  }
  final rest = [
    for (final t in pool)
      if (!used.contains(t.id)) t,
  ];
  if (rest.isNotEmpty) out.add(MixedSource('other', otherTitle, rest));
  return out;
}

/// Avtomatik nom: «Umumiy test: A · B…».
String mixedAutoTitle(String prefix, List<String> titles) {
  String short(String s) =>
      s.length <= 28 ? s : '${s.substring(0, 27).trimRight()}…';
  final head = titles.take(2).map(short).join(' · ');
  return titles.length > 2 ? '$prefix: $head…' : '$prefix: $head';
}

/// «Umumiy test berish»: bir nechta manbadan mavzular, navbatma-navbat
/// taqsimot, mavzu testidagi kabi sozlamalar, tahrirlanadigan nom.
class MixedTestScreen extends ConsumerStatefulWidget {
  const MixedTestScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<MixedTestScreen> createState() => _MixedTestState();
}

class _MixedTestState extends ConsumerState<MixedTestScreen> {
  final _selected = <String>[];
  final _queries = <String, String>{};
  final _title = TextEditingController();
  bool _titleEdited = false;
  var _s = const TestSettings(count: 20);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _toggle(String id, bool on) => setState(() {
    _selected.remove(id);
    if (on) _selected.add(id);
  });

  void _syncTitle(List<ClassTopic> all, AppLocalizations l) {
    if (_titleEdited) return;
    final titles = [
      for (final id in _selected) ?all.where((t) => t.id == id).firstOrNull,
    ].map((t) => t.title).toList();
    final auto = titles.isEmpty ? '' : mixedAutoTitle(l.grpMixedPrefix, titles);
    if (_title.text != auto) _title.text = auto;
  }

  Future<void> _preview(List<ClassTopic> chosen, ClassQuizBank bank) async {
    final l = AppLocalizations.of(context);
    final take = _s.variant && variantAllowed(_total(chosen), _s.count)
        ? _s.count * 2
        : _s.count;
    final counts = roundRobinCounts([for (final t in chosen) t.count], take);
    final sample = roundRobinPick([
      for (final t in chosen)
        [
          for (final q
              in bank.variants
                      .where((v) => v.id == t.id)
                      .firstOrNull
                      ?.questions ??
                  const <ClassBankQuestion>[])
            q.id,
        ],
    ], take);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (ctx, sc) => ListView(
          key: const Key('grp.mixedPreview'),
          controller: sc,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(FeSpace.md),
          children: [
            Text(
              l.grpMixedPreviewTitle(take),
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            const SizedBox(height: FeSpace.xs),
            for (final (i, t) in chosen.indexed)
              Text([FeGlyphs.bullet, t.title, ': ', counts[i]].join()),
            const SizedBox(height: FeSpace.sm),
            Text(
              l.grpMixedPreviewNote,
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            const Divider(),
            for (final (i, id) in sample.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: FeSpace.xxs),
                child: Text(
                  [i + 1, '. ', bank.question(id)?.question ?? id].join(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _total(List<ClassTopic> chosen) => chosen.fold(0, (a, t) => a + t.count);

  Future<void> _submit(List<ClassTopic> chosen) async {
    final l = AppLocalizations.of(context);
    final now = ref.read(groupNowProvider)();
    final total = _total(chosen);
    final draft = _s.draft(
      topicId: chosen.first.id,
      topics: [for (final t in chosen) t.id],
      title: _title.text.trim(),
      poolSize: total,
      now: now,
    );
    final err = draft.validate(poolSize: total, now: now);
    if (err != null) {
      setState(
        () => _error = groupFailureText(l, err, {
          'available': total,
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
    final bank = ref.watch(classQuizBankProvider).value ?? ClassQuizBank.empty;
    final sources = mixedSources(bank, all, lang, l.grpMixedOtherSource);
    final chosen = [
      for (final id in _selected) ?all.where((x) => x.id == id).firstOrNull,
    ];
    final total = _total(chosen);
    if (total > 0 && _s.count > total) _s = _s.copyWith(count: total);
    _syncTitle(all, l);

    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.grpMixedTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('grp.mixedList'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: FeSpace.xl),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.xs),
                  const GroupDemoBanner(),
                  Text(
                    l.grpMixedIntro,
                    style: t.bodyMedium?.copyWith(color: c.textSecondary),
                  ),
                  FeSectionHeader(l.grpMixedSources),
                  if (topics.isLoading)
                    FeListSkeleton(semanticLabel: l.grpMixedSources)
                  else if (sources.isEmpty)
                    FeEmptyState(
                      icon: Icons.quiz_outlined,
                      body: l.classNoTopics,
                    ),
                  for (final src in sources) _source(context, src),
                  if (chosen.isNotEmpty) ...[
                    FeSectionHeader(l.grpMixedSelected(chosen.length, total)),
                    TextField(
                      key: const Key('grp.mixedTitle'),
                      controller: _title,
                      maxLength: 120,
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      onChanged: (_) => _titleEdited = true,
                      decoration: InputDecoration(
                        labelText: l.grpMixedTitleLabel,
                        helperText: l.grpMixedTitleHint,
                      ),
                    ),
                    TestSettingsSection(
                      value: _s,
                      poolSize: total,
                      countPresets: const [10, 20, 30, 50],
                      now: ref.read(groupNowProvider),
                      onChanged: (v) => setState(() => _s = v),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    OutlinedButton.icon(
                      key: const Key('grp.mixedPreviewButton'),
                      onPressed: () => _preview(chosen, bank),
                      icon: const Icon(Icons.list_alt),
                      label: Text(l.grpMixedPreviewAction),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: FeSpace.xs),
                      Text(
                        _error!,
                        key: const Key('grp.assignError'),
                        style: t.bodyMedium?.copyWith(color: c.danger),
                      ),
                    ],
                    const SizedBox(height: FeSpace.xs),
                    FilledButton.icon(
                      key: const Key('grp.mixedSubmit'),
                      onPressed: _busy ? null : () => _submit(chosen),
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

  Widget _source(BuildContext context, MixedSource src) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final q = (_queries[src.id] ?? '').toLowerCase();
    final shown = [
      for (final x in src.topics)
        if (q.isEmpty || x.title.toLowerCase().contains(q)) x,
    ];
    final picked = src.topics.where((x) => _selected.contains(x.id)).length;
    final allOn = picked == src.topics.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: Key('grp.source.${src.id}'),
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          shape: const Border(),
          title: Text(src.title, style: t.titleSmall),
          subtitle: Text(l.grpMixedSourceLine(src.topics.length, picked)),
          childrenPadding: const EdgeInsets.fromLTRB(
            FeSpace.sm,
            0,
            FeSpace.sm,
            FeSpace.sm,
          ),
          children: [
            CheckboxListTile(
              key: Key('grp.sourceAll.${src.id}'),
              contentPadding: EdgeInsets.zero,
              value: allOn ? true : (picked == 0 ? false : null),
              tristate: true,
              title: Text(l.grpSelectAll),
              onChanged: (_) => setState(() {
                for (final x in src.topics) {
                  _selected.remove(x.id);
                  if (!allOn) _selected.add(x.id);
                }
              }),
            ),
            TextField(
              key: Key('grp.sourceSearch.${src.id}'),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              onChanged: (v) => setState(() => _queries[src.id] = v),
              decoration: InputDecoration(
                hintText: l.classTopicSearchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
            ),
            for (final x in shown)
              CheckboxListTile(
                key: Key('grp.mixedTopic.${x.id}'),
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: _selected.contains(x.id),
                title: Text(
                  x.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(l.classQuestionsAvailable(x.count)),
                onChanged: (v) => _toggle(x.id, v ?? false),
              ),
          ],
        ),
      ),
    );
  }
}
