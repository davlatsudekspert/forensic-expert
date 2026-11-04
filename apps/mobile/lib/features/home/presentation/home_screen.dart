import 'package:fe_content_schema/fe_content_schema.dart'
    show ForensicDiscipline;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/dna.dart';
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
import '../../../domain/knowledge/knowledge_models.dart';
import '../../../domain/plan/plan_models.dart' show ProFeature;
import '../../../domain/plan/pro_split.dart';
import '../../pro/presentation/pro_first_offer.dart';
import '../../pro/presentation/pro_gate.dart'
    show ProLockBadge, proSectionLocked;
import '../../referral/presentation/invite_card.dart';
import 'first_steps_card.dart';
import 'home_desks.dart';
import 'saved_items.dart';

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
  /// Asosiy uch fan — Mutaxassis/Talaba bosh sahifasining tepasida.
  static const core = [forensicMedicine, toxicology];

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

  /// Bo‘lim o‘qishini Pro’da yopadigan funksiya (faqat `FE_PRO_STRICT`
  /// yoqilganda amal qiladi); `null` — bepul (Bepul/Pro bo‘linishi).
  ProFeature? get proFeature => ProSplit.featureForModule(name);

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

  String get keyName => module == null ? 'home.$id' : 'home.module.$id';

  Key get key => Key(keyName);

  /// Karta o‘qishini Pro’da yopadigan funksiya (qat’iy bo‘linishda).
  ProFeature? get proFeature => switch (id) {
    'guidelines' => ProFeature.proModules,
    'tools' => ProFeature.proTools,
    _ => module?.proFeature,
  };

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
    final lean = mode == UserMode.professional || mode == UserMode.student;
    // Takrorlar yo‘q (egasi talabi, 2026-11-01): Kalkulyatorlar — «Vositalar»
    // tabida va Ish stolida, AI — markaziy tugmada, O‘qish — talaba
    // stolida.
    final actions = [
      for (final a in HomeAction.forMode(mode))
        if (!lean ||
            (a != HomeAction.tools &&
                a.module != HomeModule.ai &&
                a.module != HomeModule.learn))
          a,
    ];
    final featured = {for (final a in actions) ?a.module};
    // Asosiy fanlar (Sud tibbiyoti, Toksikologiya, Biokimyo) — Mutaxassis va
    // Talaba bosh sahifasining eng yuqorisida (egasi talabi, 2026-10-31).
    final coreTop = mode != null;
    // Tezkor amallardagi bo‘limlar to‘rda takrorlanmaydi.
    final modules = [
      for (final m in HomeModule.orderFor(mode))
        if (!featured.contains(m) &&
            m != HomeModule.ai &&
            !(coreTop && HomeModule.core.contains(m)))
          m,
    ];
    final guidelinesFeatured = actions.contains(HomeAction.guidelines);
    // Ustoz paneli FAQAT «Ustoz» rejimida (egasi qarori, 2026-10-24): Talaba va
    // Mutaxassis rejimida karta ham, havola ham yo‘q — server roli (masalan
    // admin) bo‘lsa ham. Talaba guruhga «O‘qish» bo‘limidan qo‘shiladi.
    // Ustoz rejimida server roli bo‘lmasa — ichida rolni olish tartibi yozilgan.

    // Ierarxiya: sarlavha (salom, rejim, qidiruv) → rejimga mos 4 ta tezkor
    // amal → birinchi qadamlar → bo‘limlar → davom ettirish → taklif →
    // bitta sokin ishonch izohi.
    return Scaffold(
      body: SafeArea(
        top: false,
        // Suzuvchi menyu: pastki padding (menyu balandligi) ListView’ga
        // beriladi — kontent menyu ostida ko‘rinadi, oxirida to‘silmaydi.
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(
            bottom: FeSpace.xs + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            const _HomeHero(),
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.lg),
                  // Ekspert: «Ish stolim»; talaba: «O‘qish stolim» (+ kunlik
                  // ma’lumot/savol). Ustoz bosh sahifasi o‘zgarmaydi.
                  // Talaba: o‘z paneli birinchi (egasi so‘rovi, 2026-11-02).
                  if (mode == UserMode.student) ...[
                    const StudentDesk(),
                    const SizedBox(height: FeSpace.lg),
                  ],
                  // «Bilim va malakani baholash» — faqat Mutaxassisda, eng
                  // tepada (egasi, 2026-11-02).
                  if (mode == UserMode.professional) ...[
                    _ResourceTile(
                      key: const Key('home.assessment'),
                      icon: Icons.fact_check_outlined,
                      title: l.assessmentTitle,
                      body: l.assessmentSubtitle,
                      lock: ProFeature.proModules,
                      onTap: () => context.push(Routes.assessment),
                    ),
                    const SizedBox(height: FeSpace.lg),
                  ],
                  if (coreTop) ...[
                    FeSectionHeader(
                      l.homeCoreTitle,
                      padding: const EdgeInsets.only(bottom: FeSpace.xs),
                    ),
                    const _CoreDisciplinesCard(),
                    // «Barcha fanlar» (gistologiya, kriminalistika …) —
                    // bo‘limlar to‘ri Kutubxonada bo‘lgani uchun shu yerda.
                    if (lean) ...[
                      const SizedBox(height: FeSpace.sm),
                      const _AllDisciplinesCard(),
                    ],
                    const SizedBox(height: FeSpace.lg),
                  ],
                  if (mode == UserMode.professional) ...[
                    const ExpertWorkbench(),
                    const SizedBox(height: FeSpace.sm),
                  ] else if (mode == UserMode.teacher) ...[
                    const TeacherDesk(),
                    const SizedBox(height: FeSpace.sm),
                  ],
                  _ActionGrid(actions: actions),
                  if (FeFlags.showTestFixtures) ...[
                    const SizedBox(height: FeSpace.md),
                    FeBanner(
                      icon: Icons.info_outline,
                      text: l.homePrototypeNotice,
                    ),
                  ],
                  const FirstStepsCard(),
                  const ProFirstOfferCard(),
                  // Egasi qarori (2026-11-01): Mutaxassis va Talaba bosh
                  // sahifasida faqat asosiylar; bo‘limlar to‘ri, yo‘riqnomalar,
                  // apparatlar kursi va tezkor kirish — Kutubxonada, taklif —
                  // Profilda. Ustoz bosh sahifasi o‘zgarmaydi.
                  if (!lean) ...[
                    FeSectionHeader(l.homeAreasTitle),
                    _ModuleGrid(modules: modules),
                  ],
                  if (!lean && !guidelinesFeatured) ...[
                    const SizedBox(height: FeSpace.sm),
                    _ResourceTile(
                      key: const Key('home.guidelines'),
                      icon: Icons.assignment_outlined,
                      title: l.guidelinesTitle,
                      body: l.guidelinesSubtitle,
                      lock: ProFeature.proModules,
                      onTap: () => context.push(Routes.guidelines),
                    ),
                  ],
                  // Mutaxassis rejimi: sudda so‘roqqa tayyorgarlik.
                  // Talabada — Kutubxonada.
                  // Mutaxassis: apparatlar bilan ishlash kursi
                  // (hammaga ochiq darslar) — egasi qarori, 2026-10-24.
                  if (!lean && mode == UserMode.professional) ...[
                    const SizedBox(height: FeSpace.sm),
                    _ResourceTile(
                      key: const Key('home.instruments'),
                      icon: Icons.biotech_outlined,
                      title: l.homeInstrumentsTitle,
                      body: l.homeInstrumentsBody,
                      lock: ProFeature.instrumentsCourseFull,
                      onTap: () => context.push(Routes.lessons),
                    ),
                  ],
                  if (mode != UserMode.student &&
                      mode != UserMode.professional) ...[
                    const SizedBox(height: FeSpace.sm),
                    _ResourceTile(
                      key: const Key('home.courtPrep'),
                      icon: Icons.gavel_outlined,
                      title: l.courtTitle,
                      body: l.courtSubtitle,
                      lock: ProFeature.courtPrep,
                      onTap: () => context.push(Routes.courtPrep),
                    ),
                  ],
                  // Kutubxona va Vositalar — pastki tablarda; baza holati —
                  // Profil → Ilova haqida.
                  const _QuickAccess(),
                  if (!lean) ...[
                    const SizedBox(height: FeSpace.lg),
                    const InviteColleagueCard(
                      key: Key('home.invite'),
                      compact: true,
                    ),
                  ],
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

class _ActionCard extends ConsumerWidget {
  const _ActionCard({required this.action});

  final HomeAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locked = proSectionLocked(ref, action.proFeature);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final b = Theme.of(context).brightness;
    final gold = action.highlight;
    return FeCard(
      key: action.key,
      color: gold ? c.accentContainer : null,
      padding: const EdgeInsets.fromLTRB(
        FeSpace.md,
        FeSpace.md,
        FeSpace.sm,
        FeSpace.md,
      ),
      onTap: () =>
          action.isTab ? context.go(action.route) : context.push(action.route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: gold ? c.surfaceRaised : action.hue.bg(b),
                  borderRadius: BorderRadius.circular(FeRadius.md),
                  border: gold ? Border.all(color: c.accentBorder) : null,
                ),
                child: SizedBox.square(
                  dimension: 44,
                  child: Icon(
                    action.icon,
                    color: gold ? c.accent : action.hue.fg(b),
                    size: 24,
                  ),
                ),
              ),
              if (locked) ...[
                const Spacer(),
                ProLockBadge(key: Key('${action.keyName}.lock')),
              ],
            ],
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
class _ResourceTile extends ConsumerWidget {
  const _ResourceTile({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
    this.lock,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  /// Bo‘lim Pro’da yopilsa qulf belgisi (faqat `FE_PRO_STRICT` yoqilganda).
  final ProFeature? lock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final locked = proSectionLocked(ref, lock);
    final k = key;
    final lockKey = k is ValueKey<String> ? '${k.value}.lock' : 'home.lock';
    return FeCard(
      onTap: onTap,
      child: _EntryLayout(
        leading: DecoratedBox(
          decoration: BoxDecoration(
            color: c.accentContainer,
            borderRadius: BorderRadius.circular(FeRadius.md),
          ),
          child: SizedBox.square(
            dimension: 44,
            child: Icon(icon, color: c.accent, size: 22),
          ),
        ),
        title: Text(title, style: t.titleSmall),
        body: body,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (locked) ...[
              ProLockBadge(key: Key(lockKey)),
              const SizedBox(width: FeSpace.xxs),
            ],
            Icon(Icons.chevron_right, color: c.textSecondary),
          ],
        ),
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
    final data = ref.watch(userDataProvider);
    List<(String, VoidCallback)> items(List<String> ids) =>
        resolveSavedItems(context, ref, ids);
    // Mutaxassisda «Tanlanganlar» — «Ish stolim» ichida (takrorlanmaydi).
    final favInDesk =
        ref.watch(settingsControllerProvider.select((s) => s.userMode)) ==
        UserMode.professional;

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
      if (!favInDesk)
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
      padding: const EdgeInsets.fromLTRB(
        FeSpace.md,
        FeSpace.md,
        FeSpace.sm,
        FeSpace.md,
      ),
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

/// «Asosiy fanlar»: Sud tibbiyoti, Toksikologiya, Biokimyo — bitta kartada,
/// har biri alohida qator (nom bo‘linmaydi, tor ekranda ham). Mutaxassis va
/// Talaba bosh sahifasining tepasida.
class _CoreDisciplinesCard extends ConsumerWidget {
  const _CoreDisciplinesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final b = Theme.of(context).brightness;
    String body(HomeModule m) => switch (m) {
      HomeModule.forensicMedicine => l.homeCoreMedicineBody,
      HomeModule.toxicology => l.homeCoreToxBody,
      _ => l.homeCoreBiochemBody,
    };
    // Tor ekran + katta shrift: ikonka yashiriladi, sarlavha kichrayadi —
    // fan nomi so‘z o‘rtasidan bo‘linmasin.
    final width = MediaQuery.sizeOf(context).width;
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final compact = width < 380 && scale > 1.3;
    return FeCard(
      key: const Key('home.core'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, m) in HomeModule.core.indexed) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: compact ? FeSpace.md : FeSpace.md + 44 + FeSpace.sm,
                color: c.border.withValues(alpha: 0.6),
              ),
            Semantics(
              button: true,
              child: InkWell(
                key: Key('home.module.${m.name}'),
                borderRadius: BorderRadius.vertical(
                  top: i == 0
                      ? const Radius.circular(FeRadius.lg)
                      : Radius.zero,
                  bottom: i == HomeModule.core.length - 1
                      ? const Radius.circular(FeRadius.lg)
                      : Radius.zero,
                ),
                onTap: () =>
                    m.isTab ? context.go(m.route) : context.push(m.route),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FeSpace.md,
                    vertical: FeSpace.sm + 2,
                  ),
                  child: Row(
                    children: [
                      if (!compact) ...[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: m.hue.bg(b),
                            borderRadius: BorderRadius.circular(FeRadius.md),
                          ),
                          child: SizedBox.square(
                            dimension: 44,
                            child: Icon(m.icon, color: m.hue.fg(b), size: 22),
                          ),
                        ),
                        const SizedBox(width: FeSpace.sm),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.label(l),
                              style: (compact ? t.titleSmall : t.titleMedium)
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    height: 1.25,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              body(m),
                              style: t.bodySmall?.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (proSectionLocked(ref, m.proFeature)) ...[
                        ProLockBadge(key: Key('home.module.${m.name}.lock')),
                        const SizedBox(width: FeSpace.xs),
                      ],
                      Icon(Icons.chevron_right, color: c.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModuleCard extends ConsumerWidget {
  const _ModuleCard({required this.module});

  final HomeModule module;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final b = Theme.of(context).brightness;
    final hue = module.hue;
    final locked = proSectionLocked(ref, module.proFeature);
    return FeCard(
      key: Key('home.module.${module.name}'),
      padding: const EdgeInsets.fromLTRB(
        FeSpace.md,
        FeSpace.md,
        FeSpace.sm,
        FeSpace.md,
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
                if (locked) ...[
                  ProLockBadge(key: Key('home.module.${module.name}.lock')),
                  const SizedBox(width: FeSpace.xs),
                ],
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
    final modeLabel = switch (mode) {
      UserMode.student => l.modeStudent,
      UserMode.teacher => l.modeTeacher,
      _ => l.modeProfessional,
    };
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
                            : Icons.badge_outlined,
                        label: l.homeRoleChip(modeLabel),
                      ),
                      const SizedBox(height: FeSpace.sm),
                      FeSearchEntry(
                        key: const Key('home.search'),
                        hint: l.searchHint,
                        prominent: true,
                        onTap: () => context.push(Routes.search),
                      ),
                      // Egasi qarori (2026-11-01): Kutubxona — pastki
                      // menyuda, Yurisdiksiya — Profilda; tepada yangi
                      // bo‘limlar ko‘rinadi.
                      const SizedBox(height: FeSpace.sm),
                      const _NewSections(),
                      const SizedBox(height: FeSpace.sm),
                      const _CatalogBanner(),
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

/// «Yangi bo‘limlar»: DNK, virtual autopsiya (KT/MRT), asbob-uskunalar —
/// rasmli kichik kartalar, birinchi ekranda.
class _NewSections extends ConsumerWidget {
  const _NewSections();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final hasDna = !(ref.watch(dnaProvider).value?.isEmpty ?? true);
    final items = [
      if (hasDna) ('home.new.dna', 'dna_banner', l.dnaTitle, Routes.dna),
      (
        'home.new.virtopsy',
        'virtopsy',
        l.homeNewVirtopsy,
        Routes.equipmentItem('virtopsy'),
      ),
      ('home.new.equipment', 'gc_ms', l.equipTitle, Routes.equipment),
    ];
    return Column(
      key: const Key('home.new'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.homeNewTitle,
          style: t.labelLarge?.copyWith(color: c.accent, letterSpacing: 0.6),
        ),
        const SizedBox(height: FeSpace.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, (key, img, title, route)) in items.indexed) ...[
              if (i > 0) const SizedBox(width: FeSpace.xs),
              Expanded(
                child: FeCard(
                  key: Key(key),
                  padding: EdgeInsets.zero,
                  onTap: () => context.push(route),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(FeRadius.lg),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1.25,
                          child: ColoredBox(
                            color: const Color(0xFFF4EFE6),
                            child: Image.asset(
                              'assets/images/instruments/$img.webp',
                              fit: BoxFit.cover,
                              alignment: img == 'dna_banner'
                                  ? Alignment.centerRight
                                  : Alignment.center,
                              excludeFromSemantics: true,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(FeSpace.xs),
                        child: _NoSplitLabel(
                          title,
                          style: t.labelLarge?.copyWith(height: 1.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// «Ustozlar va mutaxassislar ⭐» — katalog kartasi (egasi so‘rovi,
/// 2026-11-02).
class _CatalogBanner extends StatelessWidget {
  const _CatalogBanner();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: const Key('home.catalog'),
      onTap: () => context.push(Routes.catalog),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [c.brand, Color.lerp(c.brand, c.accent, 0.7)!],
              ),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Color(0xFFFFC83D),
              size: 28,
            ),
          ),
          const SizedBox(width: FeSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.catTitle, style: t.titleSmall),
                Text(
                  l.catHomeHint,
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: c.textSecondary),
        ],
      ),
    );
  }
}

/// Tor kartadagi sarlavha: so‘z o‘rtasidan bo‘linmaydi («DNK eksp|ertizasi»).
/// Chiziqchadan keyin satr ko‘chishi mumkin. Eng uzun so‘z sig‘masa, shrift shu so‘z sig‘adigan darajada kichrayadi.
class _NoSplitLabel extends StatelessWidget {
  const _NoSplitLabel(this.text, {this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final scaler = MediaQuery.textScalerOf(context);
        var factor = 1.0;
        for (final w in text.split(RegExp(r'(?<=-)|\s+'))) {
          final tp = TextPainter(
            text: TextSpan(text: w, style: style),
            textDirection: Directionality.of(context),
            textScaler: scaler,
            maxLines: 1,
          )..layout();
          if (tp.width > box.maxWidth && tp.width > 0) {
            factor = (box.maxWidth / tp.width).clamp(0.6, factor);
          }
          tp.dispose();
        }
        final base = style?.fontSize ?? 14;
        return Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: style?.copyWith(fontSize: base * factor * 0.98),
        );
      },
    );
  }
}
