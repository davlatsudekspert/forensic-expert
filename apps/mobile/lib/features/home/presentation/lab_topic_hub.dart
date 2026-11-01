import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/equipment.dart';
import '../../../app/guidelines.dart' show guidelinesProvider;
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/catalog/tools_catalog.dart';
import '../../../domain/equipment/equipment.dart';
import '../../../domain/guidelines/guideline_models.dart';
import '../../tools/tool_strings.dart';

/// «Laboratoriya usullari» ichidagi mavzu sahifasi (egasi talabi, 2026-11-01):
/// Spektrofotometriya va GC-MS/LC-MS uchun ilovadagi BARCHA manbali material
/// bir joyda — apparat bilan ishlash darsi (rasmlar, ish tartibi), aniqlash
/// yo‘riqnomalari (kitob boblari), usul tavsiflari va hisob-kitob.
/// Yangi ma’lumot to‘qilmaydi: faqat mavjud yozuvlarga havola.
enum LabTopic { spectro, chromatography, causeOfDeath }

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

  /// Sud-tibbiy ekspert: qiyin holatlarda o‘lim sababini aniqlashga yordam
  /// beruvchi mavjud manbali yozuvlar, savol bo‘yicha guruhlangan.
  /// Har guruh: (sarlavha kaliti, bilim yozuvlari, yo‘riqnomalar, vositalar).
  static const _deathGroups =
      <(String, List<String>, List<String>, List<String>)>[
        (
          'pmi',
          [
            'fm-postmortem-interval',
            'fm-postmortem-changes',
            'fm-algor-mortis',
            'fm-livor-mortis',
            'fm-rigor-mortis',
            'fm-decomposition',
            'bio-vitreous-potassium',
            'ent-pmi-insects',
            'mic-thanatomicrobiome',
          ],
          [],
          ['tool.fm.pmi_henssge'],
        ),
        (
          'trauma',
          [
            'fm-blunt-trauma',
            'fm-firearm',
            'fm-asphyxia',
            'fm-drowning',
            'his-wound-vitality',
            'his-fat-embolism',
          ],
          ['guideline.path.diatom_test'],
          [],
        ),
        (
          'physical',
          ['fm-burns', 'fm-hypothermia', 'bio-temperature-effect'],
          [],
          [],
        ),
        (
          'sudden',
          [
            'bio-cardiac-markers',
            'his-mi-early',
            'bio-tryptase',
            'bio-crp-procalcitonin',
            'bio-bhb-ketoacidosis',
            'bio-vitreous-glucose',
            'bio-hba1c',
            'bio-insulin-cpeptide',
            'bio-vitreous-sodium-chloride',
            'bio-vitreous-urea-creatinine',
            'bio-csf',
          ],
          [],
          [],
        ),
        (
          'poison',
          [
            'tox-postmortem-redistribution',
            'bio-sampling-site',
            'bio-ethanol-neoformation',
            'bio-preanalytical-hemolysis',
          ],
          [
            'guideline.tox.postmortem_interpretation',
            'guideline.tox.specimen_preanalytics',
          ],
          ['tool.tox.widmark', 'tool.tox.back_calculation'],
        ),
        (
          'identification',
          [
            'rad-pmct',
            'fm-age-estimation',
            'fm-stature-estimation',
            'fm-odontology',
            'fm-anthropology',
            'fm-dvi',
          ],
          ['guideline.anthro.stature_long_bones'],
          [],
        ),
        (
          'histology',
          ['his-putrefaction-artifact', 'his-ihc', 'his-fixation'],
          [],
          [],
        ),
      ];

  String _groupTitle(AppLocalizations l, String key) => switch (key) {
    'pmi' => l.deathHubPmi,
    'trauma' => l.deathHubTrauma,
    'physical' => l.deathHubPhysical,
    'sudden' => l.deathHubSudden,
    'poison' => l.deathHubPoison,
    'identification' => l.deathHubIdentification,
    _ => l.deathHubHistology,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final bundle = ref.watch(guidelinesProvider).value ?? GuidelineBundle.empty;
    final spectro = topic == LabTopic.spectro;
    final death = topic == LabTopic.causeOfDeath;
    final equipment =
        ref.watch(equipmentProvider).value ?? EquipmentBundle.empty;

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

    List<_HubTile> devices(List<String> ids) => [
      for (final id in ids)
        if (equipment.byId(id) case final d?)
          _HubTile(
            Icons.precision_manufacturing_outlined,
            d.name,
            l.equipOpenDevice,
            Routes.equipmentItem(id),
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
              Icons.stacked_line_chart,
              l.labHubReading,
              l.labHubReadingBody,
              Routes.gcmsReading,
            ),
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
    List<_HubTile> tools(List<String> ids) => [
      for (final id in ids)
        if (ToolsCatalog.byId(id) case final t?)
          _HubTile(
            Icons.calculate_outlined,
            l.toolName(t),
            null,
            Routes.homeTool(t.id),
          ),
    ];
    List<_HubTile> topics(List<String> ids) => [
      for (final id in ids)
        if (knowledge.byId(id) case final e? when e.claims.isNotEmpty)
          _HubTile(
            Icons.menu_book_outlined,
            e.name.resolve(lang),
            null,
            Routes.knowledgeEntry(id),
          ),
    ];
    final sections = death
        ? <(String, List<_HubTile>)>[
            for (final (key, k, g, t) in _deathGroups)
              (_groupTitle(l, key), [...topics(k), ...guides(g), ...tools(t)]),
          ]
        : <(String, List<_HubTile>)>[
            (l.labHubPractice, lessons),
            (
              l.equipTitle,
              devices(
                spectro
                    ? const ['uv_vis']
                    : const ['gc_ms', 'lc_msms', 'hplc', 'tlc'],
              ),
            ),
            (l.labHubGuides, guides(spectro ? _spectroGuides : _chromGuides)),
            (
              l.labHubMethods,
              methods(spectro ? _spectroMethods : _chromMethods),
            ),
            (l.labHubCalc, calc),
          ];

    return Scaffold(
      appBar: AppBar(
        title: FeAppBarTitle(
          death
              ? l.deathHubTitle
              : spectro
              ? l.workbenchLabSpectro
              : l.workbenchLabMs,
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
                  death
                      ? l.deathHubIntro
                      : spectro
                      ? l.labHubSpectroIntro
                      : l.labHubChromIntro,
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
