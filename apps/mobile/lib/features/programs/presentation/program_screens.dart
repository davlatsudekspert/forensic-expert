import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/programs.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/settings/app_settings.dart' show UserMode;
import '../../../core/settings/settings_controller.dart'
    show settingsControllerProvider;
import '../../../core/widgets/fe_components.dart';
import '../../../domain/programs/program_models.dart';
import '../../common/entry_tile.dart';
import '../../evidence/evidence_strings.dart' show EvidenceStrings;

/// «O‘quv dasturlari»: ixtisoslashtirish kurslari ro‘yxati (Ustoz, Talaba).
/// Hozir bitta kurs — «Toksikologik kimyo». Davomiylik hech qayerda yo‘q.
class ProgramsListScreen extends ConsumerWidget {
  const ProgramsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final program = ref.watch(toxChemProgramProvider).value;
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.progListTitle)),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          key: const Key('programs.list'),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  FeBanner(icon: Icons.school_outlined, text: l.progListIntro),
                  const SizedBox(height: FeSpace.sm),
                  EntryTile(
                    key: const Key('programs.toxChem'),
                    icon: Icons.science_outlined,
                    title: l.progTkTitle,
                    body: l.progTkSubtitle,
                    badge: program == null || program.topics.isEmpty
                        ? null
                        : StateChip(
                            label: l.progTopicsCount(program.topics.length),
                            tone: 1,
                          ),
                    onTap: () => context.push(Routes.program(toxChemProgramId)),
                  ),
                  const SizedBox(height: FeSpace.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _norm(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[‘’ʻʼ\'`]'), '')
    .replaceAll(RegExp(r'\s+'), ' ');

/// Kurs sahifasi: tavsif, qidiruv, tematik guruhlar yoki asl dastur tartibi.
class ProgramScreen extends ConsumerStatefulWidget {
  const ProgramScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends ConsumerState<ProgramScreen> {
  final _query = TextEditingController();
  bool _byGroups = true;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  String _groupTitle(AppLocalizations l, String id) => switch (id) {
    'g1' => l.progGroup1,
    'g2' => l.progGroup2,
    'g3' => l.progGroup3,
    'g4' => l.progGroup4,
    'g5' => l.progGroup5,
    'g6' => l.progGroup6,
    _ => l.progGroup7,
  };

  String _linkLabel(AppLocalizations l, ProgramLink k, String lang) {
    final v = k.value;
    switch (k.kind) {
      case 'method':
        final e = ref.read(knowledgeRepositoryProvider).byId(v!);
        return e?.name.resolve(lang) ?? v;
      case 'substances':
        return v == null
            ? l.moduleSubstances
            : '${l.moduleSubstances}: ${l.substanceGroupName(v)}';
      case 'lab':
        return v == 'spectro' ? l.workbenchLabSpectro : l.workbenchLabMs;
      case 'tool':
        return v == 'tool.lab.solution'
            ? l.workbenchSolutionTitle
            : l.workbenchLodTitle;
      case 'equipment':
        return l.equipTitle;
      case 'jurisdictions':
        return l.jurisdictionsTitle;
      case 'knowledge':
        return switch (v) {
          'reagent' => l.moduleReagents,
          'screeningTest' => l.moduleScreening,
          _ => l.moduleMethods,
        };
    }
    return v ?? '';
  }

  void _open(ProgramTopic t, AppLocalizations l, String lang) {
    if (t.links.isEmpty) return;
    if (t.links.length == 1 && t.status == ProgramTopicStatus.available) {
      context.push(programLinkRoute(t.links.first));
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            FeSpace.md,
            0,
            FeSpace.md,
            FeSpace.md,
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            key: const Key('program.sheet'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${t.number}. ${t.title}',
                  style: Theme.of(sheet).textTheme.titleSmall,
                ),
                const SizedBox(height: FeSpace.xs),
                if (t.status == ProgramTopicStatus.partial)
                  Text(
                    l.progPartialNote,
                    style: Theme.of(sheet).textTheme.bodySmall
                        ?.copyWith(color: FeTheme.of(sheet).textSecondary),
                  ),
                const SizedBox(height: FeSpace.sm),
                FeSectionHeader(
                  l.progMaterials,
                  padding: const EdgeInsets.only(bottom: FeSpace.xs),
                ),
                for (final k in t.links)
                  Padding(
                    padding: const EdgeInsets.only(bottom: FeSpace.xs),
                    child: EntryTile(
                      icon: Icons.open_in_new_rounded,
                      title: _linkLabel(l, k, lang),
                      onTap: () {
                        Navigator.of(sheet).pop();
                        context.push(programLinkRoute(k));
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(ProgramTopic t, AppLocalizations l, String lang) {
    final c = FeTheme.of(context);
    final tt = Theme.of(context).textTheme;
    final (label, tone) = switch (t.status) {
      ProgramTopicStatus.available => (l.progStatusAvailable, 0),
      ProgramTopicStatus.partial => (l.progStatusPartial, 1),
      ProgramTopicStatus.preparing => (l.progStatusPreparing, 2),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: Key('program.topic.${t.id}'),
        onTap: t.links.isEmpty ? null : () => _open(t, l, lang),
        padding: const EdgeInsets.symmetric(
          horizontal: FeSpace.md,
          vertical: FeSpace.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${t.number}',
                style: tt.titleSmall?.copyWith(color: c.accent),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title, style: tt.bodyMedium),
                  const SizedBox(height: FeSpace.xxs),
                  StateChip(label: label, tone: tone),
                ],
              ),
            ),
            if (t.links.isNotEmpty)
              Icon(Icons.chevron_right, color: c.textSecondary),
          ],
        ),
      ),
    );
  }

  /// Mavzular ro‘yxati: bo‘sh natija, guruhlar yoki asl dastur tartibi.
  List<Widget> _topicWidgets(
    Program? program,
    List<ProgramTopic> topics,
    AppLocalizations l,
    String lang,
  ) {
    final c = FeTheme.of(context);
    if (topics.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(FeSpace.lg),
          child: Text(
            l.progNoResults,
            key: const Key('program.empty'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: c.textSecondary),
          ),
        ),
      ];
    }
    if (!_byGroups) {
      return [for (final x in topics) _tile(x, l, lang)];
    }
    return [
      for (final g in program?.groupIds ?? const <String>[])
        if (topics.any((x) => x.groupId == g)) ...[
          FeSectionHeader(_groupTitle(l, g)),
          for (final x in topics)
            if (x.groupId == g) _tile(x, l, lang),
        ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final professional =
        ref.watch(settingsControllerProvider.select((s) => s.userMode)) ==
        UserMode.professional;
    final program = ref.watch(toxChemProgramProvider).value;
    final q = _norm(_query.text.trim());
    final topics = [
      for (final x in program?.topics ?? const <ProgramTopic>[])
        if (q.isEmpty || _norm(x.title).contains(q)) x,
    ];
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.progTkTitle)),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          key: const Key('program.list'),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  Text(l.progTkTitle, style: t.headlineSmall),
                  const SizedBox(height: FeSpace.xxs),
                  Text(
                    l.progTkSubtitle,
                    style: t.bodyMedium?.copyWith(color: c.textSecondary),
                  ),
                  if (program != null && program.topics.isNotEmpty) ...[
                    const SizedBox(height: FeSpace.xs),
                    Text(
                      l.progTopicsCount(program.topics.length),
                      key: const Key('program.count'),
                      style: t.labelLarge?.copyWith(color: c.accent),
                    ),
                    const SizedBox(height: FeSpace.xxs),
                    Text(
                      l.progSummary(
                        program.count(ProgramTopicStatus.available),
                        program.count(ProgramTopicStatus.partial),
                        program.count(ProgramTopicStatus.preparing),
                      ),
                      key: const Key('program.summary'),
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ],
                  if (lang != 'uz') ...[
                    const SizedBox(height: FeSpace.sm),
                    FeBanner(
                      key: const Key('program.uzOnly'),
                      icon: Icons.translate_outlined,
                      text: l.progTitlesUzOnly,
                    ),
                  ],
                  if (professional) ...[
                    const SizedBox(height: FeSpace.sm),
                    EntryTile(
                      key: const Key('program.tests'),
                      icon: Icons.fact_check_outlined,
                      title: l.progTests,
                      onTap: () => context.push(Routes.assessment),
                    ),
                  ],
                  const SizedBox(height: FeSpace.sm),
                  TextField(
                    key: const Key('program.search'),
                    controller: _query,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: l.progSearchHint,
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: FeSpace.sm),
                  SegmentedButton<bool>(
                    key: const Key('program.view'),
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: true,
                        label: Text(
                          l.progViewGroups,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text(
                          l.progViewOrder,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    selected: {_byGroups},
                    onSelectionChanged: (s) =>
                        setState(() => _byGroups = s.first),
                  ),
                  const SizedBox(height: FeSpace.xs),
                  ..._topicWidgets(program, topics, l, lang),
                  const SizedBox(height: FeSpace.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
