import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../app/user_data.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/flags.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../core/widgets/fe_data_components.dart';
import '../../../domain/catalog/tools_catalog.dart';
import '../../../domain/knowledge/knowledge_models.dart';
import '../../tools/tool_strings.dart';

/// Home modullari (professional bo‘limlar). ID’lar marshrut parametri.
enum HomeModule {
  forensicMedicine(Icons.monitor_heart_outlined),
  toxicology(Icons.science_outlined),
  biochemistry(Icons.bubble_chart_outlined),
  laboratory(Icons.biotech_outlined),
  reagents(Icons.colorize_outlined),
  screening(Icons.fact_check_outlined),
  methods(Icons.rule_folder_outlined),
  substances(Icons.hub_outlined),
  standardsLaws(Icons.gavel_outlined),
  emerging(Icons.new_releases_outlined),
  histology(Icons.grid_view_outlined),
  research(Icons.library_books_outlined),
  learn(Icons.school_outlined),
  ai(Icons.auto_awesome_outlined);

  const HomeModule(this.icon);

  final IconData icon;

  String label(AppLocalizations l) => switch (this) {
    HomeModule.forensicMedicine => l.moduleForensicMedicine,
    HomeModule.toxicology => l.moduleToxicology,
    HomeModule.biochemistry => l.moduleBiochemistry,
    HomeModule.laboratory => l.moduleLaboratory,
    HomeModule.reagents => l.moduleReagents,
    HomeModule.screening => l.moduleScreening,
    HomeModule.methods => l.moduleMethods,
    HomeModule.substances => l.moduleSubstances,
    HomeModule.standardsLaws => l.moduleStandardsLaws,
    HomeModule.emerging => l.moduleEmerging,
    HomeModule.histology => l.moduleHistology,
    HomeModule.research => l.moduleResearch,
    HomeModule.learn => l.moduleLearn,
    HomeModule.ai => l.moduleAi,
  };

  /// Home’dagi asosiy 12 bo‘lim (rejimga mos tartib). Qolgan sohalar
  /// (gistologiya, yangi muammolar va 20 fan) — «Barcha fanlar» ichida.
  static List<HomeModule> orderFor(UserMode? mode) => switch (mode) {
    UserMode.student => const [
      learn,
      forensicMedicine,
      toxicology,
      substances,
      laboratory,
      methods,
      biochemistry,
      screening,
      reagents,
      research,
      standardsLaws,
      ai,
    ],
    UserMode.research => const [
      research,
      substances,
      methods,
      toxicology,
      laboratory,
      screening,
      reagents,
      biochemistry,
      forensicMedicine,
      standardsLaws,
      learn,
      ai,
    ],
    _ => const [
      forensicMedicine,
      toxicology,
      laboratory,
      substances,
      methods,
      reagents,
      screening,
      biochemistry,
      standardsLaws,
      research,
      learn,
      ai,
    ],
  };

  /// Modul kartochkasi qayerga olib boradi.
  String get route => switch (this) {
    HomeModule.ai => Routes.ai,
    HomeModule.learn => Routes.learn,
    HomeModule.substances => Routes.library,
    HomeModule.forensicMedicine => Routes.forensicMedicine,
    HomeModule.biochemistry => Routes.biochemistry,
    HomeModule.reagents => Routes.knowledge(KnowledgeKind.reagent.name),
    HomeModule.screening => Routes.knowledge(KnowledgeKind.screeningTest.name),
    HomeModule.methods => Routes.knowledge(KnowledgeKind.method.name),
    HomeModule.emerging => Routes.knowledge(KnowledgeKind.emergingIssue.name),
    HomeModule.standardsLaws => Routes.jurisdictions,
    HomeModule.histology => Routes.histology,
    HomeModule.research => Routes.research,
    _ => Routes.module(name),
  };
}

/// Professional dashboard. Ochilishi AI yoki backend javobini kutmaydi —
/// faqat lokal holat (sozlamalar, saralanganlar) dan quriladi.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final mode = ref.watch(
      settingsControllerProvider.select((s) => s.userMode),
    );
    final modules = HomeModule.orderFor(mode);
    final isStudent = mode == UserMode.student;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: FeBreakpoints.gutter(context),
        title: Row(
          children: [
            const BrandMark(size: 28),
            const SizedBox(width: FeSpace.xs),
            Flexible(
              child: Text(
                l.appTitle,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(letterSpacing: 1.6, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: FeSpace.xs),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FeSearchEntry(
                    key: const Key('home.search'),
                    hint: l.searchHint,
                    onTap: () => context.go(Routes.search),
                  ),
                  const SizedBox(height: FeSpace.xs),
                  const _JurisdictionContext(),
                  if (FeFlags.showTestFixtures) ...[
                    const SizedBox(height: FeSpace.xs),
                    FeBanner(
                      icon: Icons.info_outline,
                      text: l.homePrototypeNotice,
                    ),
                  ] else if (FeFlags.contentChannel != 'production') ...[
                    const SizedBox(height: FeSpace.xs),
                    FeBanner(
                      key: const Key('home.pilotNotice'),
                      icon: Icons.science_outlined,
                      text: l.homePilotNotice,
                      tone: FeBannerTone.review,
                    ),
                  ],
                  if (isStudent) ...[
                    const SizedBox(height: FeSpace.md),
                    const _ContinueLearningCard(),
                  ],
                  FeSectionHeader(l.homeAreasHeading),
                  _ModuleGrid(modules: modules),
                  const SizedBox(height: FeSpace.sm),
                  const _AllDisciplinesTile(),
                  const _QuickAccess(),
                  const SizedBox(height: FeSpace.md),
                  const _DatabaseCard(),
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

/// Oflayn baza holati: paket versiyasi, ilmiy va yurisdiksiya komponent
/// versiyalari, maxfiylik eslatmasi. Sun’iy statistika yo‘q.
class _DatabaseCard extends ConsumerWidget {
  const _DatabaseCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final status = ref.watch(contentStatusProvider);
    final versions = ref.watch(legalCatalogProvider).componentVersions;
    final secondary = t.bodySmall?.copyWith(color: c.textSecondary);
    final lines = status.when(
      data: (s) => s.isInstalled
          ? [
              Text(
                l.homeDbPack(s.packVersion!),
                key: const Key('home.db.pack'),
                style: FeThemeBuilder.numeric(t.bodyMedium!),
              ),
              if (versions['scientific'] case final v?)
                Text(l.homeDbScientific(v), style: secondary),
              if (versions['jurisdiction'] case final v?)
                Text(l.homeDbJurisdiction(v), style: secondary),
            ]
          : [Text(l.homeDbNotInstalled, style: secondary)],
      loading: () => [FeSkeleton(lines: 2, semanticLabel: l.homeDbLoading)],
      error: (_, _) => [Text(l.homeDbNotInstalled, style: secondary)],
    );
    return FeCard(
      key: const Key('home.database'),
      padding: const EdgeInsets.all(FeSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.offline_pin_outlined, color: c.accent),
          const SizedBox(width: FeSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(l.homeDbTitle, style: t.titleSmall),
                ),
                const SizedBox(height: 2),
                ...lines,
                const SizedBox(height: FeSpace.xxs),
                Text(l.homeDbOffline, style: secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: const Key('home.continueLearning'),
      onTap: () => context.go(Routes.learn),
      child: Row(
        children: [
          Icon(Icons.school_outlined, color: c.accent, size: 32),
          const SizedBox(width: FeSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.homeContinueLearning, style: t.titleMedium),
                const SizedBox(height: 2),
                Text(
                  l.homeStudyHubBody,
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          ExcludeSemantics(
            child: Icon(Icons.chevron_right, color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Tezkor kirish: yaqinda ko‘rilganlar, so‘nggi vositalar, saralanganlar,
/// so‘nggi qidiruvlar — faqat to‘lgan bloklar ko‘rsatiladi (shovqin kam).
/// Hammasi bo‘sh bo‘lsa — bitta tushuntiruvchi qator. Sun’iy statistika yo‘q.
class _QuickAccess extends ConsumerWidget {
  const _QuickAccess();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final data = ref.watch(userDataProvider);
    final library = ref.watch(libraryRepositoryProvider);
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final evidence = ref.watch(evidenceDataProvider);

    String? nameOf(String id) {
      final tool = ToolsCatalog.byId(id);
      if (tool != null) return l.toolName(tool);
      final k = knowledge.byId(id);
      if (k != null) return k.name.resolve(lang);
      final entry = library.byId(id);
      if (entry != null) return entry.name.resolve(lang);
      final r = evidence.researchById(id);
      if (r != null) {
        return r.title.length > 60 ? '${r.title.substring(0, 57)}…' : r.title;
      }
      return null; // O‘chirilgan yoki paketda yo‘q yozuv — ko‘rsatilmaydi.
    }

    void openId(String id) {
      if (ToolsCatalog.byId(id) != null) {
        context.go(Routes.tool(id));
      } else if (knowledge.byId(id) != null) {
        context.go(Routes.knowledgeEntry(id));
      } else if (evidence.researchById(id) != null) {
        context.go(Routes.researchEntry(id));
      } else {
        context.go(Routes.libraryEntry(id));
      }
    }

    List<(String, VoidCallback)> items(List<String> ids) => [
      for (final id in ids)
        if (nameOf(id) case final n?) (n, () => openId(id)),
    ];

    final blocks = <Widget>[
      if (items(data.recentlyViewed) case final xs when xs.isNotEmpty)
        _QuickBlock(
          key: const Key('home.recentlyViewed'),
          icon: Icons.visibility_outlined,
          title: l.homeRecentlyViewed,
          items: xs,
        ),
      if (items(data.recentTools) case final xs when xs.isNotEmpty)
        _QuickBlock(
          key: const Key('home.recentTools'),
          icon: Icons.history,
          title: l.homeRecentTools,
          items: xs,
        ),
      if (items(data.favorites) case final xs when xs.isNotEmpty)
        _QuickBlock(
          key: const Key('home.favorites'),
          icon: Icons.star_border,
          title: l.homeFavorites,
          items: xs,
        ),
      if (data.recentSearches.isNotEmpty)
        _QuickBlock(
          key: const Key('home.recentSearches'),
          icon: Icons.manage_search,
          title: l.homeRecentSearches,
          items: [
            for (final q in data.recentSearches)
              (q, () => context.go(Routes.searchWith(q))),
          ],
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.homeQuickAccess),
        if (blocks.isEmpty)
          Text(
            l.homeQuickEmpty,
            key: const Key('home.quickEmpty'),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: c.textSecondary),
          )
        else
          ...blocks,
      ],
    );
  }
}

/// Joriy yurisdiksiya — ilmiy kontent yurisdiksiyasiz ishlaydi; bu faqat
/// huquqiy/protsessual qatlam uchun. Bayroq ishlatilmaydi (ISO kod + nom).
class _JurisdictionContext extends ConsumerWidget {
  const _JurisdictionContext();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final id = ref.watch(
      settingsControllerProvider.select((s) => s.jurisdictionId),
    );
    final j = ref.watch(jurisdictionResolverProvider).byId(id);
    final name = j?.name(lang) ?? id;
    return Semantics(
      button: true,
      label: l.homeJurisdictionChip(name),
      excludeSemantics: true,
      child: InkWell(
        key: const Key('home.jurisdiction'),
        borderRadius: BorderRadius.circular(FeRadius.sm),
        onTap: () => context.go(Routes.jurisdictions),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Icon(Icons.public, size: 18, color: c.textSecondary),
              const SizedBox(width: FeSpace.xs),
              // Bitta o‘raladigan matn — 320 dp va ×2 shriftda ham sig‘adi.
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${l.homeJurisdictionChip(name)} · ',
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                      TextSpan(
                        text: l.homeChange,
                        style: t.labelMedium?.copyWith(color: c.accent),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllDisciplinesTile extends StatelessWidget {
  const _AllDisciplinesTile();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: const Key('home.allDisciplines'),
      padding: const EdgeInsets.symmetric(
        horizontal: FeSpace.md,
        vertical: FeSpace.sm,
      ),
      onTap: () => context.go(Routes.disciplines),
      child: Row(
        children: [
          Icon(Icons.apps_outlined, color: c.accent),
          const SizedBox(width: FeSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.homeAllDisciplines, style: t.titleSmall),
                Text(
                  l.homeAllDisciplinesBody,
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          ExcludeSemantics(
            child: Icon(Icons.chevron_right, color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _QuickBlock extends StatelessWidget {
  const _QuickBlock({
    super.key,
    required this.icon,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final String title;
  final List<(String, VoidCallback)> items;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(FeRadius.md),
          border: Border.all(color: c.border),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            FeSpace.md,
            FeSpace.sm,
            FeSpace.md,
            FeSpace.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: c.textSecondary),
                  const SizedBox(width: FeSpace.xs),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(title, style: t.titleSmall),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: FeSpace.xxs),
                child: Wrap(
                  spacing: FeSpace.xs,
                  children: [
                    for (final (label, onTap) in items)
                      ActionChip(label: Text(label), onPressed: onTap),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({required this.modules});

  final List<HomeModule> modules;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        // Katta matnda ustunlar kamayadi — overflow o‘rniga qayta joylashuv.
        final columns = w >= 560 ? 3 : (w >= 300 && textScale < 1.6 ? 2 : 1);
        const gap = FeSpace.sm;
        final itemWidth = (w - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final m in modules)
              SizedBox(
                width: itemWidth,
                child: _ModuleCard(module: m),
              ),
          ],
        );
      },
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});

  final HomeModule module;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    return Semantics(
      button: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: InkWell(
          key: Key('home.module.${module.name}'),
          onTap: () => context.go(module.route),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FeSpace.sm,
                vertical: FeSpace.sm,
              ),
              child: Row(
                children: [
                  Icon(module.icon, color: c.accent, size: 22),
                  const SizedBox(width: FeSpace.sm),
                  Expanded(
                    child: Text(
                      module.label(l),
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
