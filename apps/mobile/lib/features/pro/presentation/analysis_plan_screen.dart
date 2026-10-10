import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/pro_tools.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/evidence/content_translations.dart';
import '../../../domain/pro/analysis_plan.dart';
import '../analysis_plan_text.dart';
import '../pro_strings.dart';
import 'pro_widgets.dart';

/// «Modda bo‘yicha tahlil rejasi» (Pro). Bepul foydalanuvchi: qisqa ko‘rinish
/// (sonlar va namunalar) + tariflar taklifi. Pro: to‘liq reja, har blokda
/// manba va aniq joyi, holat belgisi, hamda iqtiboslar bilan nusxalash.
class AnalysisPlanScreen extends ConsumerWidget {
  const AnalysisPlanScreen({super.key, required this.entityId});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final unlocked = ref.watch(proToolsUnlockedProvider);
    final plan = ref.watch(analysisPlanProvider(entityId));
    final nameOf = proNameResolver(ref, lang);
    final title = nameOf(entityId);
    final translations = ref.watch(contentTranslationsProvider);
    String principleOf(PlanScreening s) => translations
        .resolve(
          ContentTextKind.screeningField,
          '${s.screeningId}#principle',
          source: s.principle,
          lang: lang,
        )
        .text;

    Widget emptyLine(String text, {String? k}) => Padding(
      padding: const EdgeInsets.only(top: FeSpace.xxs),
      child: Text(
        text,
        key: k == null ? null : Key(k),
        style: t.bodySmall?.copyWith(color: c.textSecondary),
      ),
    );

    Widget block(
      int n,
      String key,
      String heading,
      IconData icon,
      List<Widget> children,
      String empty,
    ) => Column(
      key: Key('plan.block.$key'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: FeSpace.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: c.accent),
            const SizedBox(width: FeSpace.xs),
            Expanded(
              child: Semantics(
                header: true,
                child: Text('$n. $heading', style: t.titleSmall),
              ),
            ),
          ],
        ),
        if (children.isEmpty) emptyLine(empty, k: 'plan.empty.$key'),
        ...children,
      ],
    );

    Widget card(Key key, List<Widget> children, {VoidCallback? onTap}) =>
        Padding(
          padding: const EdgeInsets.only(top: FeSpace.xs),
          child: FeCard(
            key: key,
            onTap: onTap,
            padding: const EdgeInsets.all(FeSpace.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        );

    Widget cardTitle(String text, {bool chevron = false}) => Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (chevron)
          Icon(Icons.chevron_right, size: 20, color: c.textSecondary),
      ],
    );

    Widget methodCard(String key, PlanMethod m, {bool required = false}) =>
        card(Key('plan.$key.${m.methodId}'), [
          cardTitle(nameOf(m.methodId), chevron: true),
          if (required || m.families.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: FeSpace.xxs),
              child: Wrap(
                spacing: FeSpace.xs,
                runSpacing: FeSpace.xxs,
                children: [
                  if (required)
                    StatusChip(
                      icon: Icons.rule,
                      label: l.planConfirmRequired,
                      color: c.danger,
                    ),
                  for (final f in m.families)
                    StatusChip(
                      icon: Icons.biotech_outlined,
                      label: l.familyName(f),
                      color: c.textSecondary,
                    ),
                ],
              ),
            ),
          if (m.afterScreeningIds.isNotEmpty)
            emptyLine(
              l.analysisAfterScreening(
                m.afterScreeningIds.map(nameOf).join(FeGlyphs.listSeparator),
              ),
            ),
          for (final q in m.quotes) PlanQuoteTile(quote: q),
        ], onTap: () => context.push(Routes.knowledgeEntry(m.methodId)));

    final body = <Widget>[
      FeBanner(
        icon: Icons.science_outlined,
        text: l.planIntro,
        tone: FeBannerTone.review,
      ),
      const SizedBox(height: FeSpace.sm),
    ];

    if (!unlocked) {
      body
        ..add(
          FeCard(
            key: const Key('plan.preview'),
            padding: const EdgeInsets.all(FeSpace.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.planSummary(
                    plan.specimens.length,
                    plan.presumptive.length,
                    plan.confirmation.length,
                    plan.limits.length,
                  ),
                  key: const Key('plan.summary'),
                  style: t.bodyMedium,
                ),
                if (plan.specimens.isNotEmpty) ...[
                  const SizedBox(height: FeSpace.xs),
                  Text(
                    l.planSecSpecimens,
                    style: t.labelMedium?.copyWith(color: c.textSecondary),
                  ),
                  Text(
                    plan.specimens
                        .map((s) => nameOf(s.specimenId))
                        .join(FeGlyphs.listSeparator),
                    key: const Key('plan.preview.specimens'),
                    style: t.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        )
        ..add(const SizedBox(height: FeSpace.sm))
        ..add(
          ProLockedCard(
            title: l.planLockedTitle(l.tierProfessionalPro),
            body: l.planLockedBody,
            buttonKey: const Key('plan.unlock'),
          ),
        );
    } else if (plan.isEmpty && plan.presumptive.isEmpty) {
      body.add(
        FeEmptyState(
          key: const Key('plan.noData'),
          icon: Icons.biotech_outlined,
          body: l.planRemNoData,
        ),
      );
    } else {
      // 1. Namunalar va namuna olish izohlari.
      final sampling = [
        for (final s in plan.specimens)
          for (final q in s.notes)
            if (q.role == PlanRole.use) q,
      ];
      body
        ..add(
          block(1, 'specimens', l.planSecSpecimens, Icons.water_drop_outlined, [
            for (final s in plan.specimens)
              card(Key('plan.specimen.${s.specimenId}'), [
                cardTitle(nameOf(s.specimenId), chevron: true),
                for (final q in s.basis.take(1)) PlanQuoteTile(quote: q),
                for (final q in s.notes)
                  if (q.role == PlanRole.use) PlanQuoteTile(quote: q),
              ], onTap: () => context.push(Routes.homeSpecimen(s.specimenId))),
            if (plan.specimens.isNotEmpty && sampling.isEmpty)
              emptyLine(l.planNoSamplingNotes, k: 'plan.noSamplingNotes'),
          ], l.planNoSpecimens),
        )
        // 2. Taxminiy testlar.
        ..add(
          block(
            2,
            'presumptive',
            l.planSecPresumptive,
            Icons.filter_alt_outlined,
            [
              if (plan.presumptive.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: FeSpace.xs),
                  child: FeBanner(
                    icon: Icons.warning_amber_rounded,
                    text: l.analysisScreeningNote,
                    tone: FeBannerTone.critical,
                  ),
                ),
              for (final s in plan.presumptive)
                card(
                  Key('plan.screening.${s.screeningId}'),
                  [
                    cardTitle(nameOf(s.screeningId), chevron: true),
                    if (s.principle.isNotEmpty)
                      emptyLine(l.planPrinciple(principleOf(s))),
                    if (!s.supportsDefinitive) emptyLine(l.planNotDefinitive),
                    for (final q in s.quotes) PlanQuoteTile(quote: q),
                    const SizedBox(height: FeSpace.xs),
                    if (s.reagents.isEmpty)
                      emptyLine(l.planNoReagents, k: 'plan.noReagents')
                    else ...[
                      Text(
                        l.planReagentsLabel,
                        style: t.labelMedium?.copyWith(color: c.textSecondary),
                      ),
                      for (final r in s.reagents)
                        Padding(
                          padding: const EdgeInsets.only(top: FeSpace.xxs),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      nameOf(r.reagentId),
                                      style: t.bodyMedium,
                                    ),
                                  ),
                                  if (r.hasRecipe)
                                    TextButton(
                                      key: Key('plan.recipe.${r.reagentId}'),
                                      onPressed: () => context.push(
                                        Routes.knowledgeEntry(r.reagentId),
                                      ),
                                      child: Text(l.planReagentRecipe),
                                    ),
                                ],
                              ),
                              if (!r.quotes.any(
                                (q) => q.role == PlanRole.observation,
                              ))
                                emptyLine(l.planNoReagents),
                              for (final q in r.quotes) PlanQuoteTile(quote: q),
                            ],
                          ),
                        ),
                    ],
                  ],
                  onTap: () =>
                      context.push(Routes.knowledgeEntry(s.screeningId)),
                ),
            ],
            l.planNoPresumptive,
          ),
        )
        // 3. TLC / mikrokristall / UV-Vis.
        ..add(
          block(3, 'bench', l.planSecBench, Icons.grid_on_outlined, [
            for (final m in plan.bench) methodCard('bench', m),
          ], l.planNoBench),
        )
        // 4. Tasdiqlash.
        ..add(
          block(
            4,
            'confirmation',
            l.planSecConfirmation,
            Icons.verified_outlined,
            [
              for (final m in plan.confirmation)
                methodCard('confirm', m, required: true),
            ],
            l.planNoConfirmation,
          ),
        )
        ..add(
          block(
            5,
            'instrumental',
            l.planSecInstrumental,
            Icons.biotech_outlined,
            [
              if (plan.instrumental.isNotEmpty &&
                  plan.specimens.isNotEmpty &&
                  !plan.specimens.any((s) => s.methodIds.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.only(top: FeSpace.xs),
                  child: FeBanner(
                    key: const Key('plan.notPaired'),
                    icon: Icons.info_outline,
                    text:
                        '${l.analysisMethodsNotPaired} '
                        '${l.analysisMethodsRoleNote}',
                  ),
                ),
              for (final m in plan.instrumental) methodCard('instr', m),
            ],
            l.planNoInstrumental,
          ),
        )
        ..add(
          block(6, 'interferences', l.planSecInterferences, Icons.call_split, [
            if (plan.interferences.isNotEmpty)
              card(const Key('plan.interferences'), [
                for (final q in plan.interferences) PlanQuoteTile(quote: q),
              ]),
          ], l.planNoInterferences),
        )
        ..add(
          block(7, 'limits', l.planSecLimits, Icons.straighten, [
            if (plan.limits.isNotEmpty)
              card(const Key('plan.limits'), [
                for (final q in plan.limits) PlanQuoteTile(quote: q),
              ]),
          ], l.planNoLimits),
        );

      // 8. Xulosa uchun eslatma.
      final may = [
        for (final r in plan.reminders)
          if (r.allowed) r,
      ];
      final mayNot = [
        for (final r in plan.reminders)
          if (!r.allowed) r,
      ];
      Widget reminderCard(PlanReminder r) =>
          card(Key('plan.reminder.${r.kind.name}'), [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  r.allowed ? Icons.check_circle_outline : Icons.block,
                  size: 18,
                  color: r.allowed ? c.verified : c.danger,
                ),
                const SizedBox(width: FeSpace.xs),
                Expanded(
                  child: Text(
                    planReminderText(l, r, nameOf),
                    style: t.bodyMedium,
                  ),
                ),
              ],
            ),
            for (final q in r.quotes) PlanQuoteTile(quote: q),
          ]);
      body.add(
        block(8, 'reminder', l.planSecReminder, Icons.fact_check_outlined, [
          if (may.isNotEmpty) ...[
            emptyLine(l.planMayHeading),
            for (final r in may) reminderCard(r),
          ],
          if (mayNot.isNotEmpty) ...[
            emptyLine(l.planMayNotHeading),
            for (final r in mayNot) reminderCard(r),
          ],
          emptyLine(l.planReminderFootnote, k: 'plan.footnote'),
        ], l.planRemNoData),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.planTitle),
        actions: [
          if (unlocked && !plan.isEmpty)
            IconButton(
              key: const Key('plan.copy'),
              tooltip: l.planCopy,
              icon: const Icon(Icons.copy_all_outlined),
              onPressed: () async {
                final text = buildAnalysisPlanText(
                  l: l,
                  plan: plan,
                  title: title,
                  lang: lang,
                  nameOf: nameOf,
                  translations: ref.read(contentTranslationsProvider),
                );
                final messenger = ScaffoldMessenger.of(context);
                await Clipboard.setData(ClipboardData(text: text));
                messenger.showSnackBar(SnackBar(content: Text(l.planCopied)));
              },
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          key: Key('plan.$entityId'),
          padding: const EdgeInsets.symmetric(vertical: FeSpace.sm),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(title, style: t.headlineSmall),
                  ),
                  const SizedBox(height: FeSpace.sm),
                  ...body,
                  const SizedBox(height: FeSpace.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
