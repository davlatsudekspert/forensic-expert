import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../domain/library/library_models.dart';
import '../../library/presentation/source_detail_screen.dart';
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

  /// Fan rangi — vazmin, bitta tizim ichida farqlanadigan.
  FeHue get hue => switch (this) {
    HomeModule.forensicMedicine || HomeModule.standardsLaws => FeHues.indigo,
    HomeModule.toxicology || HomeModule.screening => FeHues.plum,
    HomeModule.biochemistry || HomeModule.histology => FeHues.sage,
    HomeModule.laboratory || HomeModule.methods => FeHues.slate,
    HomeModule.emerging ||
    HomeModule.research ||
    HomeModule.learn => FeHues.ochre,
    HomeModule.reagents ||
    HomeModule.substances ||
    HomeModule.ai => FeHues.teal,
  };

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

  /// Pastki tab (AI) — almashtiriladi; qolganlari ustiga ochiladi (Back).
  bool get isTab => this == HomeModule.ai;

  /// Modul kartochkasi qayerga olib boradi.
  String get route => switch (this) {
    HomeModule.ai => Routes.ai,
    HomeModule.learn => Routes.learn,
    HomeModule.substances => Routes.librarySection('substances'),
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
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: FeSpace.xs),
          children: [
            const _HomeHero(),
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  if (FeFlags.showTestFixtures) ...[
                    const SizedBox(height: FeSpace.xs),
                    FeBanner(
                      icon: Icons.info_outline,
                      text: l.homePrototypeNotice,
                    ),
                  ] else if (FeFlags.contentChannel != 'production') ...[
                    const SizedBox(height: FeSpace.xs),
                    _ReviewNotice(
                      key: const Key('home.pilotNotice'),
                      text: l.homePilotNotice,
                    ),
                  ],
                  if (isStudent) ...[
                    const SizedBox(height: FeSpace.md),
                    const _ContinueLearningCard(),
                  ],
                  const SizedBox(height: FeSpace.sm),
                  const _DatabaseCard(),
                  FeSectionHeader(l.homeAreasHeading),
                  _ModuleGrid(modules: modules),
                  const SizedBox(height: FeSpace.sm),
                  const _AllDisciplinesTile(),
                  const _QuickAccess(),
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
    // Haqiqiy sonlar (oflayn bazadan); HUMAN VERIFIED — faqat inson
    // ko‘rib chiqqan claim’lar (fixture/AI/avtomatik tekshiruv emas).
    final review = ref.watch(provenanceIndexProvider).review;
    final substances = ref
        .watch(libraryRepositoryProvider)
        .entries(LibrarySection.substances)
        .length;
    final sources = ref.watch(sourceIndexProvider).length;
    final lines = status.when(
      data: (s) => s.isInstalled
          ? [
              Text(
                l.homeDbPack(s.packVersion!),
                key: const Key('home.db.pack'),
                style: FeThemeBuilder.numeric(t.bodySmall!)
                    .copyWith(color: c.textPrimary),
              ),
              if (versions['scientific'] case final v?)
                Text(l.homeDbScientific(v), style: secondary),
              if (versions['jurisdiction'] case final v?)
                Text(l.homeDbJurisdiction(v), style: secondary),
              if (review.total > 0) ...[
                const SizedBox(height: FeSpace.sm),
                _StatGrid(
                  key: const Key('home.db.counts'),
                  stats: [
                    (substances, l.homeStatSubstances, false),
                    (sources, l.homeStatSources, false),
                    (review.total, l.homeStatClaims, false),
                    (review.humanVerified, l.homeStatHumanVerified, true),
                  ],
                ),
                const SizedBox(height: FeSpace.xs),
                Text(
                  l.homeStatPolicy,
                  key: const Key('home.db.humanVerified'),
                  style: secondary,
                ),
              ],
            ]
          : [Text(l.homeDbNotInstalled, style: secondary)],
      loading: () => [FeSkeleton(lines: 2, semanticLabel: l.homeDbLoading)],
      error: (_, _) => [Text(l.homeDbNotInstalled, style: secondary)],
    );
    return FeCard(
      key: const Key('home.database'),
      padding: const EdgeInsets.all(FeSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dataset_outlined, color: c.accent, size: 22),
              const SizedBox(width: FeSpace.xs),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(l.homeDbTitle, style: t.titleSmall),
                ),
              ),
              Icon(Icons.offline_pin_outlined, size: 18, color: c.verified),
            ],
          ),
          const SizedBox(height: FeSpace.xs),
          ...lines,
          const SizedBox(height: FeSpace.xs),
          Text(l.homeDbOffline, style: secondary),
        ],
      ),
    );
  }
}

/// Ilmiy baza raqamlari — katta tabular raqam + kichik yorliq.
class _StatGrid extends StatelessWidget {
  const _StatGrid({super.key, required this.stats});

  /// (qiymat, yorliq, alohida ta’kid — «inson tasdiqlagan»).
  final List<(int, String, bool)> stats;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, box) {
        final cols =
            box.maxWidth >= 340 &&
                MediaQuery.textScalerOf(context).scale(1) < 1.6
            ? 4
            : 2;
        final w = (box.maxWidth - FeSpace.xs * (cols - 1)) / cols;
        return Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            for (final (value, label, emphasis) in stats)
              SizedBox(
                width: w,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: emphasis ? c.accentContainer : c.surface,
                    borderRadius: BorderRadius.circular(FeRadius.md),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: FeSpace.xs,
                      vertical: FeSpace.sm,
                    ),
                    child: Semantics(
                      label: [label, '$value'].join(': '),
                      excludeSemantics: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$value',
                            style: FeThemeBuilder.numeric(t.titleLarge!)
                                .copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: emphasis
                                      ? c.onAccentContainer
                                      : c.textPrimary,
                                ),
                          ),
                          Text(
                            label,
                            maxLines: 2,
                            style: t.labelSmall?.copyWith(
                              color: emphasis
                                  ? c.onAccentContainer
                                  : c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
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
      onTap: () => context.push(Routes.learn),
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
        context.push(Routes.tool(id));
      } else if (knowledge.byId(id) != null) {
        context.push(Routes.knowledgeEntry(id));
      } else if (evidence.researchById(id) != null) {
        context.push(Routes.researchEntry(id));
      } else {
        context.push(Routes.libraryEntry(id));
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
              (q, () => context.push(Routes.searchWith(q))),
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
  const _JurisdictionContext({this.onDark = false});

  /// Navy hero ustida — oq matn.
  final bool onDark;

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
        onTap: () => context.push(Routes.jurisdictions),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Icon(
                Icons.public,
                size: 18,
                color: onDark ? const Color(0xFFB8C2D6) : c.textSecondary,
              ),
              const SizedBox(width: FeSpace.xs),
              // Bitta o‘raladigan matn — 320 dp va ×2 shriftda ham sig‘adi.
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${l.homeJurisdictionChip(name)} · ',
                        style: t.bodySmall?.copyWith(
                          color: onDark
                              ? const Color(0xFFD5DCE8)
                              : c.textSecondary,
                        ),
                      ),
                      TextSpan(
                        text: l.homeChange,
                        style: t.labelMedium?.copyWith(
                          color: onDark ? const Color(0xFF7FDDE6) : c.accent,
                        ),
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
      onTap: () => context.push(Routes.disciplines),
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
        // Har qatordagi kartalar bir xil balandlikda (tartibli to‘r).
        return Column(
          children: [
            for (var i = 0; i < modules.length; i += columns)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i + columns < modules.length ? gap : 0,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var j = 0; j < columns; j++) ...[
                        if (j > 0) const SizedBox(width: gap),
                        Expanded(
                          child: i + j < modules.length
                              ? _ModuleCard(module: modules[i + j])
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Yengil (ramkasiz) tekshiruv eslatmasi — banner shovqinisiz.
class _ReviewNotice extends StatelessWidget {
  const _ReviewNotice({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(Icons.fact_check_outlined, size: 16, color: c.reviewed),
        ),
        const SizedBox(width: FeSpace.xs),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});

  final HomeModule module;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final b = Theme.of(context).brightness;
    final hue = module.hue;
    return FeCard(
      key: Key('home.module.${module.name}'),
      padding: const EdgeInsets.fromLTRB(
        FeSpace.sm,
        FeSpace.sm,
        FeSpace.sm,
        FeSpace.sm,
      ),
      onTap: () =>
          module.isTab ? context.go(module.route) : context.push(module.route),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 84),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: hue.bg(b),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox.square(
                    dimension: 38,
                    child: Icon(module.icon, color: hue.fg(b), size: 21),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 16,
                  color: FeTheme.of(context).textSecondary,
                ),
              ],
            ),
            const SizedBox(height: FeSpace.sm),
            Text(
              module.label(l),
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600, height: 1.25),
            ),
          ],
        ),
      ),
    );
  }
}

/// Brend «hero»: navy panel, emblema, nom va shior, qidiruv, yurisdiksiya.
/// Fon naqshi — juda xira xromatogramma va o‘lchov halqalari (bezak emas,
/// ilmiy kontekst). Ikkala mavzuda ham navy — brend langari.
class _HomeHero extends StatelessWidget {
  const _HomeHero();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [Color(0xFF0C1830), Color(0xFF13233F)]
                : const [Color(0xFF0F1E3D), Color(0xFF17305A)],
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(FeRadius.hero),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(FeRadius.hero),
          ),
          child: CustomPaint(
            painter: const _HeroPatternPainter(),
            child: Padding(
              padding: EdgeInsets.only(top: top),
              child: FeContentFrame(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: FeSpace.md,
                    bottom: FeSpace.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        key: const Key('home.header'),
                        children: [
                          const BrandMark(
                            size: 52,
                            onDark: true,
                            tier: BrandTier.icon,
                          ),
                          const SizedBox(width: FeSpace.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    l.appTitle,
                                    maxLines: 1,
                                    style: t.titleLarge?.copyWith(
                                      color: Colors.white,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    l.appTagline,
                                    maxLines: 1,
                                    style: t.labelMedium?.copyWith(
                                      color: const Color(0xFFC9A75E),
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FeSpace.md),
                      FeSearchEntry(
                        key: const Key('home.search'),
                        hint: l.searchHint,
                        onDark: true,
                        onTap: () => context.push(Routes.search),
                      ),
                      const SizedBox(height: FeSpace.xxs),
                      const _JurisdictionContext(onDark: true),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPatternPainter extends CustomPainter {
  const _HeroPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x14FFFFFF);
    final center = Offset(size.width - 24, 40);
    for (final r in [56.0, 88.0, 120.0, 152.0]) {
      canvas.drawCircle(center, r, ring);
    }
    // Shartli xromatogramma chizig‘i (real ma’lumot emas — bezak).
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0x1F4CC9D6);
    final y = size.height - 18;
    final w = size.width;
    final path = Path()..moveTo(0, y);
    const peaks = [0.18, 0.31, 0.47, 0.62, 0.78, 0.9];
    const heights = [10.0, 26.0, 14.0, 34.0, 12.0, 20.0];
    for (var i = 0; i < peaks.length; i++) {
      final x = w * peaks[i];
      path
        ..lineTo(x - 6, y)
        ..lineTo(x, y - heights[i])
        ..lineTo(x + 6, y);
    }
    path.lineTo(w, y);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
