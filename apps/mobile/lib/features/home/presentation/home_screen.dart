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
import '../../../domain/catalog/tools_catalog.dart';
import '../../tools/tool_strings.dart';

/// Home modullari. ID’lar marshrut parametri sifatida ishlatiladi.
enum HomeModule {
  forensicMedicine(Icons.monitor_heart_outlined),
  toxicology(Icons.science_outlined),
  laboratory(Icons.biotech_outlined),
  substances(Icons.hub_outlined),
  learn(Icons.school_outlined),
  ai(Icons.auto_awesome_outlined);

  const HomeModule(this.icon);

  final IconData icon;

  String label(AppLocalizations l) => switch (this) {
    HomeModule.forensicMedicine => l.moduleForensicMedicine,
    HomeModule.toxicology => l.moduleToxicology,
    HomeModule.laboratory => l.moduleLaboratory,
    HomeModule.substances => l.moduleSubstances,
    HomeModule.learn => l.moduleLearn,
    HomeModule.ai => l.moduleAi,
  };

  /// Rejimga mos tartib: talaba kontenti professional ish oqimiga xalal bermaydi.
  static List<HomeModule> orderFor(UserMode? mode) => switch (mode) {
    UserMode.student => const [
      learn,
      forensicMedicine,
      toxicology,
      substances,
      laboratory,
      ai,
    ],
    UserMode.research => const [
      substances,
      toxicology,
      forensicMedicine,
      laboratory,
      learn,
      ai,
    ],
    _ => const [
      toxicology,
      substances,
      laboratory,
      forensicMedicine,
      ai,
      learn,
    ],
  };

  /// Modul kartochkasi qayerga olib boradi.
  String get route => switch (this) {
    HomeModule.ai => Routes.ai,
    HomeModule.learn => Routes.learn,
    HomeModule.substances => Routes.library,
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
                  if (FeFlags.showTestFixtures) ...[
                    const SizedBox(height: FeSpace.sm),
                    FeBanner(
                      icon: Icons.info_outline,
                      text: l.homePrototypeNotice,
                    ),
                  ] else if (FeFlags.contentChannel != 'production') ...[
                    const SizedBox(height: FeSpace.sm),
                    FeBanner(
                      key: const Key('home.pilotNotice'),
                      icon: Icons.science_outlined,
                      text: l.homePilotNotice,
                    ),
                  ],
                  if (isStudent) ...[
                    const SizedBox(height: FeSpace.md),
                    const _ContinueLearningCard(),
                  ],
                  if (!isStudent) const _QuickAccess(),
                  FeSectionHeader(l.homeModulesHeading),
                  _ModuleGrid(modules: modules),
                  if (isStudent) const _RecentSearches(),
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

/// Tezkor kirish: so‘nggi vositalar, saralanganlar, so‘nggi qidiruvlar.
/// Bo‘sh bo‘lsa — sun’iy statistika emas, tushuntiruvchi bo‘sh holat.
class _QuickAccess extends ConsumerWidget {
  const _QuickAccess();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(userDataProvider);
    final library = ref.watch(libraryRepositoryProvider);

    String nameOf(String id) {
      final tool = ToolsCatalog.byId(id);
      if (tool != null) return l.toolName(tool);
      final entry = library.byId(id);
      if (entry != null) {
        return entry.name.resolve(Localizations.localeOf(context).languageCode);
      }
      return id;
    }

    void openId(String id) {
      if (ToolsCatalog.byId(id) != null) {
        context.go(Routes.tool(id));
      } else {
        context.go(Routes.libraryEntry(id));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.homeQuickAccess),
        _QuickBlock(
          key: const Key('home.recentTools'),
          icon: Icons.history,
          title: l.homeRecentTools,
          empty: l.homeEmptyRecentTools,
          items: [
            for (final id in data.recentTools) (nameOf(id), () => openId(id)),
          ],
        ),
        _QuickBlock(
          key: const Key('home.favorites'),
          icon: Icons.star_border,
          title: l.homeFavorites,
          empty: l.homeEmptyFavorites,
          items: [
            for (final id in data.favorites) (nameOf(id), () => openId(id)),
          ],
        ),
        const _RecentSearches(),
      ],
    );
  }
}

class _RecentSearches extends ConsumerWidget {
  const _RecentSearches();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final recent = ref.watch(userDataProvider.select((d) => d.recentSearches));
    return _QuickBlock(
      key: const Key('home.recentSearches'),
      icon: Icons.manage_search,
      title: l.homeRecentSearches,
      empty: l.homeEmptyRecentSearches,
      items: [
        for (final q in recent) (q, () => context.go(Routes.searchWith(q))),
      ],
    );
  }
}

class _QuickBlock extends StatelessWidget {
  const _QuickBlock({
    super.key,
    required this.icon,
    required this.title,
    required this.empty,
    required this.items,
  });

  final IconData icon;
  final String title;
  final String empty;
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
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    top: FeSpace.xxs,
                    bottom: FeSpace.xs,
                  ),
                  child: Text(
                    empty,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                )
              else
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
        child: InkWell(
          key: Key('home.module.${module.name}'),
          onTap: () => context.go(module.route),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 96),
            child: Padding(
              padding: const EdgeInsets.all(FeSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(module.icon, color: c.accent),
                  const SizedBox(height: FeSpace.sm),
                  Text(
                    module.label(l),
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
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
