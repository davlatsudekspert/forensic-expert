import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../common/entry_tile.dart';
import '../../disciplines/discipline_strings.dart';
import '../../disciplines/presentation/disciplines_screens.dart'
    show disciplineHasMaterials;
import '../../home/presentation/home_screen.dart' show HomeModule;

/// Mutaxassis: «Ekspertiza yo‘nalishlari» — bitta kirish. Har yo‘nalish
/// MAVJUD sahifaga olib boradi; materiali yo‘q yo‘nalish «Tayyorlanmoqda».
/// Sud-kimyoviy ekspertiza → «Kasbiy tayyorgarlik» → «Toksikologik kimyo»
/// kursi (modul sahifasida).
class ExpertiseAreasScreen extends ConsumerWidget {
  const ExpertiseAreasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final library = ref.watch(libraryRepositoryProvider);

    Widget badge(bool has) => StateChip(
      label: has ? l.areaHasMaterials : l.progStatusPreparing,
      tone: has ? 0 : 2,
    );
    // (tayyor?, kartа) — tayyorlar yuqorida, mazmuni yo‘qlari «Tez orada»
    // guruhida (egasi, 2026-11-06: bo‘sh bo‘limlar va’da qilinmaydi).
    (bool, Widget) byModule(
      HomeModule m,
      IconData icon, {
      required String key,
    }) => (
      true,
      Padding(
        padding: const EdgeInsets.only(bottom: FeSpace.xs),
        child: EntryTile(
          key: Key(key),
          icon: icon,
          title: m.label(l),
          badge: badge(true),
          onTap: () => context.push(m.route),
        ),
      ),
    );
    (bool, Widget) byDiscipline(ForensicDiscipline d, IconData icon) {
      final has = disciplineHasMaterials(d, knowledge, library);
      return (
        has,
        Padding(
          padding: const EdgeInsets.only(bottom: FeSpace.xs),
          child: EntryTile(
            key: Key('areas.${d.code}'),
            icon: icon,
            title: l.disciplineName(d),
            badge: badge(has),
            onTap: () => context.push(Routes.discipline(d.code)),
          ),
        ),
      );
    }

    // Tartib: sud-kimyo (asosiy), sud tibbiyoti, patologiya, genetika/DNK,
    // biologiya, gistologiya, kriminalistika, radiologiya.
    final entries = <(bool, Widget)>[
      byModule(
        HomeModule.toxicology,
        Icons.science_outlined,
        key: 'areas.chemistry',
      ),
      byModule(
        HomeModule.forensicMedicine,
        Icons.monitor_heart_outlined,
        key: 'areas.medicine',
      ),
      byDiscipline(
        ForensicDiscipline.forensicPathology,
        Icons.biotech_outlined,
      ),
      (
        true,
        Padding(
          padding: const EdgeInsets.only(bottom: FeSpace.xs),
          child: EntryTile(
            key: const Key('areas.genetics'),
            icon: Icons.hub_outlined,
            title: l.areaBiologyDna,
            badge: badge(true),
            onTap: () => context.push(Routes.dna),
          ),
        ),
      ),
      byModule(
        HomeModule.histology,
        Icons.blur_on_outlined,
        key: 'areas.histology',
      ),
      byDiscipline(ForensicDiscipline.medicalCriminalistics, Icons.fingerprint),
      byDiscipline(
        ForensicDiscipline.forensicRadiology,
        Icons.view_in_ar_outlined,
      ),
    ];
    final ready = [
      for (final e in entries)
        if (e.$1) e.$2,
    ];
    final soon = [
      for (final e in entries)
        if (!e.$1) e.$2,
    ];

    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.areasTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('areas.list'),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  FeBanner(
                    icon: Icons.account_tree_outlined,
                    text: l.areasIntro,
                  ),
                  const SizedBox(height: FeSpace.sm),
                  ...ready,
                  if (soon.isNotEmpty) ...[
                    FeSectionHeader(
                      l.areasSoonTitle,
                      padding: const EdgeInsets.only(
                        top: FeSpace.md,
                        bottom: FeSpace.xs,
                      ),
                    ),
                    ...soon,
                  ],
                  const SizedBox(height: FeSpace.xs),
                  EntryTile(
                    key: const Key('areas.all'),
                    icon: Icons.apps_rounded,
                    title: l.homeAllDisciplines,
                    body: l.homeAllDisciplinesCount(
                      ForensicDiscipline.values.length,
                    ),
                    onTap: () => context.push(Routes.disciplines),
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

/// Mutaxassis: «Usullar va apparatlar» — mavjud sahifalarga havolalar
/// (yangi kontent yo‘q): usullar, reagentlar, skrining, laboratoriya
/// vositalari, asbob-uskunalar va virtual autopsiya.
class MethodsDevicesScreen extends StatelessWidget {
  const MethodsDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget tile(String key, IconData icon, String title, String route) =>
        Padding(
          padding: const EdgeInsets.only(bottom: FeSpace.xs),
          child: EntryTile(
            key: Key(key),
            icon: icon,
            title: title,
            onTap: () => context.push(route),
          ),
        );
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.mdTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('methodsDevices.list'),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  FeBanner(icon: Icons.build_outlined, text: l.mdIntro),
                  const SizedBox(height: FeSpace.sm),
                  tile(
                    'md.methods',
                    Icons.science_outlined,
                    l.moduleMethods,
                    Routes.knowledge('method'),
                  ),
                  tile(
                    'md.reagents',
                    Icons.colorize_outlined,
                    l.moduleReagents,
                    Routes.knowledge('reagent'),
                  ),
                  tile(
                    'md.screening',
                    Icons.rule_outlined,
                    l.moduleScreening,
                    Routes.knowledge('screeningTest'),
                  ),
                  tile(
                    'md.spectro',
                    Icons.show_chart,
                    l.workbenchLabSpectro,
                    Routes.labHub('spectro'),
                  ),
                  tile(
                    'md.ms',
                    Icons.stacked_line_chart,
                    l.workbenchLabMs,
                    Routes.labHub('chromatography'),
                  ),
                  tile(
                    'md.equipment',
                    Icons.precision_manufacturing_outlined,
                    l.equipTitle,
                    Routes.equipment,
                  ),
                  tile(
                    'md.virtopsy',
                    Icons.view_in_ar_outlined,
                    l.homeNewVirtopsy,
                    Routes.equipmentItem('virtopsy'),
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
