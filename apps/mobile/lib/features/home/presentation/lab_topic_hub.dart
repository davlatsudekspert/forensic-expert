import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/guidelines.dart' show guidelinesProvider;
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/catalog/tools_catalog.dart';
import '../../../domain/guidelines/guideline_models.dart';
import '../../tools/tool_strings.dart';

/// «Laboratoriya usullari» ichidagi mavzu sahifasi (egasi talabi, 2026-11-01):
/// Spektrofotometriya va GC-MS/LC-MS uchun ilovadagi BARCHA manbali material
/// bir joyda — apparat bilan ishlash darsi (rasmlar, ish tartibi), aniqlash
/// yo‘riqnomalari (kitob boblari), usul tavsiflari va hisob-kitob.
/// Yangi ma’lumot to‘qilmaydi: faqat mavjud yozuvlarga havola.
enum LabTopic { spectro, chromatography }

class _HubTile {
  const _HubTile(this.icon, this.title, this.body, this.route);
  final IconData icon;
  final String title;
  final String? body;
  final String route;
}

class LabTopicHubScreen extends ConsumerWidget {
  const LabTopicHubScreen({super.key, required this.topic});

  final LabTopic topic;

  static const _spectroGuides = [
    'guideline.chem.co_cohb_determination',
    'guideline.chem.uvvis_drug_analysis',
  ];
  static const _spectroMethods = ['method-uvvis', 'method-spectroscopy'];
  static const _chromGuides = [
    'guideline.chem.ethanol_gc',
    'guideline.chem.gmt_analysis_scheme',
    'guideline.chem.method_comparison',
  ];
  static const _chromMethods = [
    'method-gcms',
    'method-gc-fid',
    'method-headspace-gc',
    'method-derivatization',
    'method-lcmsms',
    'method-hplc',
    'method-hrms',
    'method-identification-criteria',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final bundle = ref.watch(guidelinesProvider).value ?? GuidelineBundle.empty;
    final spectro = topic == LabTopic.spectro;

    List<_HubTile> guides(List<String> ids) => [
      for (final id in ids)
        if (bundle.cards.where((c) => c.id == id).firstOrNull case final g?)
          _HubTile(
            Icons.assignment_outlined,
            g.title.of(lang),
            null,
            Routes.guideline(id),
          ),
    ];
    List<_HubTile> methods(List<String> ids) => [
      for (final id in ids)
        if (knowledge.byId(id) case final e?)
          _HubTile(
            Icons.rule_folder_outlined,
            e.name.resolve(lang),
            null,
            Routes.knowledgeEntry(id),
          ),
    ];

    final lessons = spectro
        ? [
            _HubTile(
              Icons.slideshow_rounded,
              l.labHubLessonCohb,
              l.labHubLessonBody,
              Routes.lesson('instr-02-uv1900-cohb'),
            ),
          ]
        : [
            _HubTile(
              Icons.biotech_outlined,
              l.labHubGcmsScheme,
              l.labHubGcmsSchemeBody,
              Routes.gcms,
            ),
            _HubTile(
              Icons.slideshow_rounded,
              l.labHubLessonGcms,
              l.labHubLessonBody,
              Routes.lesson('instr-03-gcms-asoslar'),
            ),
            _HubTile(
              Icons.slideshow_rounded,
              l.labHubLessonEthanol,
              l.labHubLessonBody,
              Routes.lesson('instr-01-kristallyuks-etanol'),
            ),
          ];
    final calc = <_HubTile>[
      if (spectro)
        if (ToolsCatalog.byId('tool.lab.beer_lambert') case final t?)
          _HubTile(
            Icons.calculate_outlined,
            l.toolName(t),
            null,
            Routes.homeTool(t.id),
          ),
    ];
    final sections = <(String, List<_HubTile>)>[
      (l.labHubPractice, lessons),
      (l.labHubGuides, guides(spectro ? _spectroGuides : _chromGuides)),
      (l.labHubMethods, methods(spectro ? _spectroMethods : _chromMethods)),
      (l.labHubCalc, calc),
    ];

    return Scaffold(
      appBar: AppBar(
        title: FeAppBarTitle(
          spectro ? l.workbenchLabSpectro : l.workbenchLabMs,
        ),
      ),
      body: ListView(
        key: Key('labHub.${topic.name}'),
        padding: EdgeInsets.only(
          bottom: FeSpace.xl + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          FeContentFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: FeSpace.sm),
                Text(
                  spectro ? l.labHubSpectroIntro : l.labHubChromIntro,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: FeTheme.of(context).textSecondary),
                ),
                for (final (title, tiles) in sections)
                  if (tiles.isNotEmpty) ...[
                    FeSectionHeader(title),
                    _TileGroup(tiles: tiles),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TileGroup extends StatelessWidget {
  const _TileGroup({required this.tiles});

  final List<_HubTile> tiles;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (i, x) in tiles.indexed) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: FeSpace.md + 24 + FeSpace.sm,
                color: c.border.withValues(alpha: 0.6),
              ),
            InkWell(
              key: Key('labHub.tile.$i.${x.route}'),
              onTap: () => context.push(x.route),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FeSpace.md,
                  vertical: FeSpace.sm,
                ),
                child: Row(
                  children: [
                    Icon(x.icon, color: c.accent),
                    const SizedBox(width: FeSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            x.title,
                            style: t.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (x.body != null)
                            Text(
                              x.body!,
                              style: t.bodySmall?.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: c.textSecondary),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
