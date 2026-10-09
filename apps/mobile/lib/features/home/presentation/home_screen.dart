import 'package:fe_content_schema/fe_content_schema.dart'
    show ForensicDiscipline;
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
import '../../../domain/catalog/tools_catalog.dart';
import '../../../domain/knowledge/knowledge_models.dart';
import '../../referral/presentation/invite_card.dart';
import '../../tools/tool_strings.dart';
import 'first_steps_card.dart';

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

/// Rejimga mos tezkor amal (Home’ning birinchi bloki).
class HomeAction {
  const HomeAction({
    required this.id,
    required this.icon,
    required this.hue,
    required this.route,
    this.module,
    this.isTab = false,
    this.highlight = false,
  });

  /// Kalit: `home.module.<modul>` (modulga bog‘liq bo‘lsa) yoki `home.<id>`.
  final String id;
  final IconData icon;
  final FeHue hue;
  final String route;
  final HomeModule? module;

  /// Pastki tab — almashtiriladi (`go`); qolganlari ustiga ochiladi.
  final bool isTab;

  /// AI — oltin aksentli karta.
  final bool highlight;

  Key get key => Key(module == null ? 'home.$id' : 'home.module.$id');

  String title(AppLocalizations l) => switch (id) {
    'learn' => l.homeActLearnTitle,
    'guidelines' => l.guidelinesTitle,
    'tools' => l.homeActToolsTitle,
    _ => module!.label(l),
  };

  String body(AppLocalizations l) => switch (id) {
    'learn' => l.homeActLearnBody,
    'guidelines' => l.homeActGuidelinesBody,
    'substances' => l.homeActSubstancesBody,
    'methods' => l.homeActMethodsBody,
    'tools' => l.homeActToolsBody,
    _ => l.homeActAiBody,
  };

  static HomeAction _module(HomeModule m) => HomeAction(
    id: m.name,
    icon: m.icon,
    hue: m.hue,
    route: m.route,
    module: m,
    isTab: m.isTab,
    highlight: m == HomeModule.ai,
  );

  static const guidelines = HomeAction(
    id: 'guidelines',
    icon: Icons.assignment_outlined,
    hue: FeHues.slate,
    route: Routes.guidelines,
  );

  static const tools = HomeAction(
    id: 'tools',
    icon: Icons.calculate_outlined,
    hue: FeHues.ochre,
    route: Routes.tools,
    isTab: true,
  );

  /// Talaba: o‘qish, yo‘riqnomalar, moddalar, AI. Mutaxassis: moddalar,
  /// tahlil usullari, kalkulyatorlar, AI. Qidiruv — sarlavhada.
  static List<HomeAction> forMode(UserMode? mode) => switch (mode) {
    UserMode.student => [
      _module(HomeModule.learn),
      guidelines,
      _module(HomeModule.substances),
      _module(HomeModule.ai),
    ],
    _ => [
      _module(HomeModule.substances),
      _module(HomeModule.methods),
      tools,
      _module(HomeModule.ai),
    ],
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
    final actions = HomeAction.forMode(mode);
    final featured = {for (final a in actions) ?a.module};
    // Tezkor amallardagi bo‘limlar to‘rda takrorlanmaydi.
    final modules = [
      for (final m in HomeModule.orderFor(mode))
        if (!featured.contains(m) && m != HomeModule.ai) m,
    ];
    final guidelinesFeatured = actions.contains(HomeAction.guidelines);

    // Ierarxiya: sarlavha (salom, rejim, qidiruv) → rejimga mos 4 ta tezkor
    // amal → birinchi qadamlar → bo‘limlar → davom ettirish → taklif →
    // bitta sokin ishonch izohi.
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
                  const SizedBox(height: FeSpace.md),
                  _ActionGrid(actions: actions),
                  if (FeFlags.showTestFixtures) ...[
                    const SizedBox(height: FeSpace.md),
                    FeBanner(
                      icon: Icons.info_outline,
                      text: l.homePrototypeNotice,
                    ),
                  ],
                  const FirstStepsCard(),
                  FeSectionHeader(l.homeAreasTitle),
                  _ModuleGrid(modules: modules),
                  if (!guidelinesFeatured) ...[
                    const SizedBox(height: FeSpace.sm),
                    _ResourceTile(
                      key: const Key('home.guidelines'),
                      icon: Icons.assignment_outlined,
                      title: l.guidelinesTitle,
                      body: l.guidelinesSubtitle,
                      onTap: () => context.push(Routes.guidelines),
                    ),
                  ],
                  // Kutubxona va Vositalar — pastki tablarda; baza holati —
                  // Profil → Ilova haqida.
                  const _QuickAccess(),
                  const SizedBox(height: FeSpace.lg),
                  const InviteColleagueCard(
                    key: Key('home.invite'),
                    compact: true,
                  ),
                  if (!FeFlags.showTestFixtures &&
                      FeFlags.contentChannel != 'production') ...[
                    const SizedBox(height: FeSpace.lg),
                    _ReviewNotice(
                      key: const Key('home.pilotNotice'),
                      text: l.homeTrustNote,
                    ),
                  ],
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

/// 2×2 tezkor amallar (tor ekran yoki katta shriftda — bitta ustun).
class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.actions});

  final List<HomeAction> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final columns = w >= 560 ? 4 : (w >= 300 && textScale < 1.6 ? 2 : 1);
        const gap = FeSpace.sm;
        return Column(
          children: [
            for (var i = 0; i < actions.length; i += columns)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i + columns < actions.length ? gap : 0,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var j = 0; j < columns; j++) ...[
                        if (j > 0) const SizedBox(width: gap),
                        Expanded(
                          child: i + j < actions.length
                              ? _ActionCard(action: actions[i + j])
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

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});

  final HomeAction action;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final b = Theme.of(context).brightness;
    final gold = action.highlight;
    return FeCard(
      key: action.key,
      color: gold ? c.accentContainer : null,
      padding: const EdgeInsets.all(FeSpace.sm),
      onTap: () =>
          action.isTab ? context.go(action.route) : context.push(action.route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: gold ? c.surfaceRaised : action.hue.bg(b),
              borderRadius: BorderRadius.circular(FeRadius.md),
              border: gold ? Border.all(color: c.accentBorder) : null,
            ),
            child: SizedBox.square(
              dimension: 40,
              child: Icon(
                action.icon,
                color: gold ? c.accent : action.hue.fg(b),
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: FeSpace.sm),
          Text(
            action.title(l),
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: gold ? c.onAccentContainer : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            action.body(l),
            style: t.bodySmall?.copyWith(
              color: gold ? c.onAccentContainer : c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kutubxona / vositalar kirishi — ikonka, sarlavha, qisqa tavsif.
class _ResourceTile extends StatelessWidget {
  const _ResourceTile({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      onTap: onTap,
      child: _EntryLayout(
        leading: DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(FeRadius.md),
          ),
          child: SizedBox.square(
            dimension: 40,
            child: Icon(icon, color: c.textPrimary, size: 21),
          ),
        ),
        title: Text(title, style: t.titleSmall),
        body: body,
        trailing: Icon(Icons.chevron_right, color: c.textSecondary),
      ),
    );
  }
}

/// Kirish kartasi tarkibi: odatda ikonka | matn | strelka bir qatorda.
/// Tor ekran yoki katta shriftda (×1.6+) ikonka va strelka yuqori qatorga
/// chiqadi, matn butun kenglikni oladi — so‘z o‘rtasidan bo‘linmaydi.
class _EntryLayout extends StatelessWidget {
  const _EntryLayout({
    required this.leading,
    required this.title,
    required this.body,
    required this.trailing,
  });

  final Widget leading;
  final Widget title;
  final String body;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        const SizedBox(height: 2),
        Text(body, style: t.bodySmall?.copyWith(color: c.textSecondary)),
      ],
    );
    final stacked = MediaQuery.textScalerOf(context).scale(1) >= 1.6;
    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              leading,
              const Spacer(),
              ExcludeSemantics(child: trailing),
            ],
          ),
          const SizedBox(height: FeSpace.sm),
          text,
        ],
      );
    }
    return Row(
      children: [
        leading,
        const SizedBox(width: FeSpace.md),
        Expanded(child: text),
        const SizedBox(width: FeSpace.xs),
        ExcludeSemantics(child: trailing),
      ],
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
        context.push(Routes.homeTool(id));
      } else if (knowledge.byId(id) != null) {
        context.push(Routes.knowledgeEntry(id));
      } else if (evidence.researchById(id) != null) {
        context.push(Routes.researchEntry(id));
      } else {
        context.push(Routes.homeSubstance(id));
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
    // Yangi foydalanuvchida bo‘sh bo‘lim ko‘rsatilmaydi (tugallanmagan
    // ko‘rinish bermaslik uchun) — bloklar ishlatilgach paydo bo‘ladi.
    if (blocks.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [FeSectionHeader(l.homeContinueSaved), ...blocks],
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
        onTap: () => context.push(Routes.jurisdictions),
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

/// «Barcha sud-ekspert fanlari» — to‘rdagi oxirgi karta (oltin aksent).
class _AllDisciplinesCard extends StatelessWidget {
  const _AllDisciplinesCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: const Key('home.allDisciplines'),
      padding: const EdgeInsets.all(FeSpace.sm),
      onTap: () => context.push(Routes.disciplines),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 84),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.accentContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox.square(
                    dimension: 38,
                    child: Icon(Icons.apps_outlined, color: c.accent, size: 21),
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_outward_rounded, size: 16, color: c.accent),
              ],
            ),
            const SizedBox(height: FeSpace.sm),
            Text(
              l.homeAllDisciplines,
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
            Text(
              l.homeAllDisciplinesCount(ForensicDiscipline.values.length),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ],
        ),
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
        // Oxirgi karta — «Barcha fanlar» (to‘r yarim bo‘sh qolmaydi).
        final cards = <Widget>[
          for (final m in modules) _ModuleCard(module: m),
          const _AllDisciplinesCard(),
        ];
        // Har qatordagi kartalar bir xil balandlikda (tartibli to‘r).
        return Column(
          children: [
            for (var i = 0; i < cards.length; i += columns)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i + columns < cards.length ? gap : 0,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var j = 0; j < columns; j++) ...[
                        if (j > 0) const SizedBox(width: gap),
                        Expanded(
                          child: i + j < cards.length
                              ? cards[i + j]
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

/// Premium sarlavha: ikkilamchi fon paneli, emblema, serif nom, oltin
/// shior; salomlashish va rol; markaziy ilmiy qidiruv; yurisdiksiya.
/// Fon naqshi — juda xira o‘lchov halqalari va shartli xromatogramma
/// (bezak, real ma’lumot emas). Ranglar faqat mavzu tokenlaridan.
class _HomeHero extends ConsumerWidget {
  const _HomeHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final top = MediaQuery.paddingOf(context).top;
    final mode = ref.watch(
      settingsControllerProvider.select((s) => s.userMode),
    );
    final student = mode == UserMode.student;
    final modeLabel = student ? l.modeStudent : l.modeProfessional;
    const radius = BorderRadius.vertical(
      bottom: Radius.circular(FeRadius.hero),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: DecoratedBox(
        decoration: BoxDecoration(color: c.surface, borderRadius: radius),
        child: ClipRRect(
          borderRadius: radius,
          child: CustomPaint(
            painter: _HeroPatternPainter(c.accent),
            child: Padding(
              padding: EdgeInsets.only(top: top),
              child: FeContentFrame(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: FeSpace.md,
                    bottom: FeSpace.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        key: const Key('home.header'),
                        children: [
                          const BrandMark(size: 44),
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
                                    style: t.titleMedium?.copyWith(
                                      color: c.textPrimary,
                                      letterSpacing: 1.6,
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
                                      color: c.accent,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FeSpace.lg),
                      // Katta sarlavha ×2 shriftda ekranni egallamasligi
                      // uchun masshtab 1.4 bilan cheklanadi (baribir yirik).
                      Semantics(
                        header: true,
                        child: Text(
                          student
                              ? l.homeGreetingStudent
                              : l.homeGreetingExpert,
                          textScaler: MediaQuery.textScalerOf(context)
                              .clamp(maxScaleFactor: 1.4),
                          key: const Key('home.greeting'),
                          style: t.headlineSmall?.copyWith(
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                      _RoleChip(
                        icon: student
                            ? Icons.school_outlined
                            : Icons.workspace_premium_outlined,
                        label: l.homeRoleChip(modeLabel),
                      ),
                      const SizedBox(height: FeSpace.sm),
                      FeSearchEntry(
                        key: const Key('home.search'),
                        hint: l.searchHint,
                        prominent: true,
                        onTap: () => context.push(Routes.search),
                      ),
                      const SizedBox(height: FeSpace.xxs),
                      const _JurisdictionContext(),
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

/// Joriy foydalanish rejimi — bosilsa rejim sozlamasi ochiladi.
class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          key: const Key('home.role'),
          borderRadius: BorderRadius.circular(FeRadius.sm),
          onTap: () => context.push(Routes.profileMode),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: FeTouch.minTarget),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: c.accent),
                const SizedBox(width: FeSpace.xs),
                Flexible(
                  child: Text(
                    label,
                    style: t.labelLarge?.copyWith(
                      color: c.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPatternPainter extends CustomPainter {
  const _HeroPatternPainter(this.accent);

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = accent.withValues(alpha: 0.10);
    final center = Offset(size.width - 24, 40);
    for (final r in [56.0, 88.0, 120.0, 152.0]) {
      canvas.drawCircle(center, r, ring);
    }
    // Shartli xromatogramma chizig‘i (real ma’lumot emas — bezak).
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = accent.withValues(alpha: 0.16);
    final y = size.height - 10;
    final w = size.width;
    final path = Path()..moveTo(0, y);
    const peaks = [0.18, 0.31, 0.47, 0.62, 0.78, 0.9];
    const heights = [6.0, 16.0, 9.0, 22.0, 8.0, 13.0];
    for (var i = 0; i < peaks.length; i++) {
      final x = w * peaks[i];
      path
        ..lineTo(x - 5, y)
        ..lineTo(x, y - heights[i])
        ..lineTo(x + 5, y);
    }
    path.lineTo(w, y);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _HeroPatternPainter oldDelegate) =>
      oldDelegate.accent != accent;
}
