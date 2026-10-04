import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/widgets/brand_mark.dart';

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
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final mode = ref.watch(
      settingsControllerProvider.select((s) => s.userMode),
    );
    final modules = HomeModule.orderFor(mode);

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
              maxWidth: FeBreakpoints.maxContentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Global Search kirish nuqtasi (PHASE 3 da ulanadi).
                  Semantics(
                    button: true,
                    label: l.searchHint,
                    excludeSemantics: true,
                    child: Material(
                      color: c.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(FeRadius.md),
                        side: BorderSide(color: c.border),
                      ),
                      child: InkWell(
                        key: const Key('home.search'),
                        borderRadius: BorderRadius.circular(FeRadius.md),
                        onTap: () => context.go(Routes.search),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 52),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: FeSpace.md,
                              vertical: FeSpace.sm,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: c.textSecondary),
                                const SizedBox(width: FeSpace.sm),
                                Expanded(
                                  child: Text(
                                    l.searchHint,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: c.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Semantics(
                    header: true,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: FeSpace.lg,
                        bottom: FeSpace.sm,
                      ),
                      child: Text(
                        l.homeModulesHeading,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  _ModuleGrid(modules: modules),
                ],
              ),
            ),
          ],
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
          onTap: () => module == HomeModule.ai
              ? context.go(Routes.ai)
              : context.go(Routes.module(module.name)),
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
