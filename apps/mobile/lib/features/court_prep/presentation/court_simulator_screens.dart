import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/court_prep.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/court_prep/court_prep_models.dart';
import 'court_prep_widgets.dart';

extension CourtRoleL10n on CourtRole {
  String label(AppLocalizations l) => switch (this) {
    CourtRole.judge => l.courtRoleJudge,
    CourtRole.prosecutor => l.courtRoleProsecutor,
    CourtRole.defense => l.courtRoleDefense,
    CourtRole.expert => l.courtRoleExpert,
  };

  IconData get icon => switch (this) {
    CourtRole.judge => Icons.gavel_outlined,
    CourtRole.prosecutor => Icons.policy_outlined,
    CourtRole.defense => Icons.shield_outlined,
    CourtRole.expert => Icons.science_outlined,
  };
}

extension CourtCriterionL10n on CourtCriterion {
  String label(AppLocalizations l) => switch (this) {
    CourtCriterion.accuracy => l.courtCritAccuracy,
    CourtCriterion.sources => l.courtCritSources,
    CourtCriterion.limitations => l.courtCritLimitations,
    CourtCriterion.impartiality => l.courtCritImpartiality,
  };
}

/// Asosiy (bepul) ssenariylar hamma uchun; qolganlari — Mutaxassis Pro.
bool courtScenarioOpen(CourtScenario s, {required bool unlocked}) =>
    unlocked || s.isSample;

/// Rol mashqi: har roldan bitta ssenariy, sudya → prokuror → advokat →
/// boshqa ekspert tartibida.
List<CourtScenario> courtDrillScenarios(CourtPrepBundle bundle) => [
  for (final role in CourtRole.values)
    ?bundle.scenarios.where((s) => s.role == role).firstOrNull,
];

class _Frame extends StatelessWidget {
  const _Frame({
    required this.title,
    required this.listKey,
    required this.children,
  });

  final String title;
  final Key listKey;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SafeArea(
      child: ListView(
        key: listKey,
        children: [
          FeContentFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: FeSpace.sm),
                ...children,
                const SizedBox(height: FeSpace.xl),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// «Sud so‘rog‘i simulyatori» — ssenariylar ro‘yxati.
class CourtSimulatorScreen extends ConsumerWidget {
  const CourtSimulatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final bundle = ref.watch(courtPrepProvider).value ?? CourtPrepBundle.empty;
    final unlocked = ref.watch(courtPrepUnlockedProvider);
    return _Frame(
      title: l.courtSimulator,
      listKey: const Key('court.simulatorView'),
      children: [
        FeBanner(
          key: const Key('court.sim.note'),
          icon: Icons.verified_user_outlined,
          tone: FeBannerTone.review,
          text: l.courtSimulatorNote,
        ),
        const SizedBox(height: FeSpace.xs),
        const CourtDisclaimer(),
        if (!unlocked) ...[
          const SizedBox(height: FeSpace.xs),
          FeBanner(icon: Icons.lock_open_outlined, text: l.courtSimFreeNote),
        ],
        FeSectionHeader(l.courtScenarioCount(bundle.scenarios.length)),
        for (final s in bundle.scenarios)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: FeCard(
              key: Key('court.scenario.${s.id}'),
              onTap: courtScenarioOpen(s, unlocked: unlocked)
                  ? () => context.push(Routes.courtPrepScenario(s.id))
                  : () => context.push(Routes.purchase),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    courtScenarioOpen(s, unlocked: unlocked)
                        ? s.role.icon
                        : Icons.lock_outline,
                    color: c.accent,
                  ),
                  const SizedBox(width: FeSpace.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: FeSpace.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              s.role.label(l),
                              style: t.labelMedium?.copyWith(
                                color: c.textSecondary,
                              ),
                            ),
                            if (!s.isSample)
                              StatusChip(
                                icon: Icons.workspace_premium_outlined,
                                label: l.courtProBadge,
                                color: c.accent,
                              ),
                          ],
                        ),
                        Text(s.prompt.of(lang), style: t.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (!unlocked) ...[
          const SizedBox(height: FeSpace.sm),
          const CourtProCard(),
        ],
      ],
    );
  }
}

/// Bitta ssenariy sahifasi.
class CourtScenarioScreen extends ConsumerWidget {
  const CourtScenarioScreen({super.key, required this.scenarioId});

  final String scenarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final bundle = ref.watch(courtPrepProvider).value ?? CourtPrepBundle.empty;
    final unlocked = ref.watch(courtPrepUnlockedProvider);
    final s = bundle.scenario(scenarioId);
    if (s == null) {
      return Scaffold(appBar: AppBar(title: Text(l.courtSimulator)));
    }
    final openList = [
      for (final x in bundle.scenarios)
        if (courtScenarioOpen(x, unlocked: unlocked)) x,
    ];
    final next = openList.length < 2 || !openList.contains(s)
        ? null
        : openList[(openList.indexOf(s) + 1) % openList.length];
    return _Frame(
      title: l.courtSimulator,
      listKey: const Key('court.scenarioView'),
      children: [
        if (!courtScenarioOpen(s, unlocked: unlocked))
          const CourtProCard()
        else
          CourtScenarioView(
            key: ValueKey(s.id),
            scenario: s,
            bundle: bundle,
            pro: unlocked,
            nextLabel: next == null ? null : l.courtSimNext,
            onNext: next == null
                ? null
                : () => context.pushReplacement(
                    Routes.courtPrepScenario(next.id),
                  ),
          ),
        const SizedBox(height: FeSpace.md),
        const CourtDisclaimer(),
      ],
    );
  }
}

/// Ssenariy tanasi: vaziyat, savol, erkin javob (qoidaga asoslangan baho),
/// AI tahlili (Pro; ulanmagan — halol «tez orada»), variantlar, 4 mezon
/// bo‘yicha baho, eng kuchli variant va manbalar.
class CourtScenarioView extends ConsumerStatefulWidget {
  const CourtScenarioView({
    super.key,
    required this.scenario,
    required this.bundle,
    required this.pro,
    this.drill = false,
    this.onNext,
    this.nextLabel,
  });

  final CourtScenario scenario;
  final CourtPrepBundle bundle;

  /// Pro: urinish shaxsiy tarixga yoziladi, AI tugmasi ishlaydi.
  final bool pro;
  final bool drill;
  final VoidCallback? onNext;
  final String? nextLabel;

  @override
  ConsumerState<CourtScenarioView> createState() => _CourtScenarioViewState();
}

class _CourtScenarioViewState extends ConsumerState<CourtScenarioView> {
  final _text = TextEditingController();
  int? _chosen;
  var _checked = false;
  var _aiShown = false;
  CourtFreeTextResult? _free;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _check(CourtScenario s) async {
    setState(() => _checked = true);
    if (!widget.pro || _chosen == null) return;
    await ref
        .read(courtHistoryProvider.notifier)
        .record(
          CourtAttempt(
            scenarioId: s.id,
            score: s.effectiveScore(s.options[_chosen!]),
            at: DateTime.now(),
            drill: widget.drill,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final s = widget.scenario;
    final bundle = widget.bundle;
    final index = courtRefIndex(bundle, s);
    final chosen = _chosen == null ? null : s.options[_chosen!];
    final best = s.best;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeCard(
          color: c.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.courtSimContext,
                style: t.labelMedium?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: FeSpace.xxs),
              Text(s.context.of(lang), style: t.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: FeSpace.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: c.accentContainer,
              child: Icon(s.role.icon, color: c.onAccentContainer),
            ),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.role.label(l),
                    style: t.labelLarge?.copyWith(color: c.accent),
                  ),
                  Text(
                    s.prompt.of(lang),
                    key: const Key('court.sim.prompt'),
                    style: t.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        FeSectionHeader(l.courtSimYourAnswer),
        TextField(
          key: const Key('court.sim.text'),
          controller: _text,
          minLines: 2,
          maxLines: 6,
          decoration: InputDecoration(hintText: l.courtSimYourAnswerHint),
        ),
        const SizedBox(height: FeSpace.xs),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            OutlinedButton.icon(
              key: const Key('court.sim.evaluateText'),
              onPressed: () =>
                  setState(() => _free = bundle.rubric.evaluate(_text.text)),
              icon: const Icon(Icons.rule, size: 18),
              label: Text(l.courtSimEvaluateText),
            ),
            OutlinedButton.icon(
              key: const Key('court.sim.ai'),
              onPressed: widget.pro
                  ? () => setState(() => _aiShown = true)
                  : () => context.push(Routes.purchase),
              icon: const Icon(Icons.auto_awesome_outlined, size: 18),
              label: Text(widget.pro ? l.courtAi : l.courtAiPro),
            ),
          ],
        ),
        if (_aiShown) ...[
          const SizedBox(height: FeSpace.xs),
          FeBanner(
            key: const Key('court.sim.aiUnavailable'),
            icon: Icons.schedule_outlined,
            text: l.courtAiUnavailable,
          ),
        ],
        if (_free case final f?) ...[
          const SizedBox(height: FeSpace.xs),
          _ScoreCard(
            key: const Key('court.sim.freeResult'),
            score: f.score,
            notes: [
              if (f.tooShort) l.courtSimTooShort,
              if (f.overstatement) l.courtSimFlagOverstatement,
              if (f.evasion) l.courtSimFlagEvasion,
              l.courtSimFreeTextNote,
            ],
          ),
        ],
        FeSectionHeader(l.courtSimChoose),
        RadioGroup<int>(
          groupValue: _chosen,
          onChanged: (v) => setState(() {
            _chosen = v;
            _checked = false;
          }),
          child: Column(
            children: [
              for (final (i, o) in s.options.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: FeSpace.xs),
                  child: FeCard(
                    padding: EdgeInsets.zero,
                    child: RadioListTile<int>(
                      key: Key('court.sim.option.$i'),
                      value: i,
                      title: Text(o.text.of(lang), style: t.bodyMedium),
                    ),
                  ),
                ),
            ],
          ),
        ),
        FilledButton(
          key: const Key('court.sim.check'),
          onPressed: _chosen == null ? null : () => _check(s),
          child: Text(l.courtSimCheck),
        ),
        if (_checked && chosen != null) ...[
          FeSectionHeader(l.courtSimResult),
          _ScoreCard(
            key: const Key('court.sim.result'),
            score: s.effectiveScore(chosen),
            notes: [
              courtCite(chosen.feedback, lang, index),
              if (s.reliesOnUnverified(chosen)) l.courtSimPartialUnverified,
              l.courtSimReviewNote,
            ],
          ),
          if (best != null && !identical(best, chosen)) ...[
            FeSectionHeader(l.courtSimBest),
            FeCard(
              key: const Key('court.sim.best'),
              color: c.accentContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    best.text.of(lang),
                    style: t.bodyMedium?.copyWith(color: c.onAccentContainer),
                  ),
                  const SizedBox(height: FeSpace.xs),
                  Text(
                    courtCite(best.feedback, lang, index),
                    style: t.bodySmall?.copyWith(color: c.onAccentContainer),
                  ),
                ],
              ),
            ),
          ],
          CourtSourcesSection(item: s, bundle: bundle),
        ],
        const SizedBox(height: FeSpace.md),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            if (s.questionId != null)
              OutlinedButton.icon(
                key: const Key('court.sim.openQuestion'),
                onPressed: () =>
                    context.push(Routes.courtPrepQuestion(s.questionId!)),
                icon: const Icon(Icons.article_outlined, size: 18),
                label: Text(l.courtSimOpenQuestion),
              ),
            if (widget.onNext != null)
              OutlinedButton.icon(
                key: const Key('court.sim.next'),
                onPressed: widget.onNext,
                icon: const Icon(Icons.skip_next, size: 18),
                label: Text(widget.nextLabel ?? l.courtSimNext),
              ),
          ],
        ),
      ],
    );
  }
}

/// Rol mashqi (Pro): sudya → prokuror → advokat → boshqa ekspert.
class CourtDrillScreen extends ConsumerStatefulWidget {
  const CourtDrillScreen({super.key});

  @override
  ConsumerState<CourtDrillScreen> createState() => _CourtDrillScreenState();
}

class _CourtDrillScreenState extends ConsumerState<CourtDrillScreen> {
  var _step = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final bundle = ref.watch(courtPrepProvider).value ?? CourtPrepBundle.empty;
    final unlocked = ref.watch(courtPrepUnlockedProvider);
    final steps = courtDrillScenarios(bundle);
    final done = _step >= steps.length;
    return _Frame(
      title: l.courtDrill,
      listKey: const Key('court.drillView'),
      children: [
        if (!unlocked)
          const CourtProCard()
        else if (steps.isEmpty)
          FeEmptyState(icon: Icons.groups_outlined, body: l.courtEmpty)
        else if (done) ...[
          FeEmptyState(
            key: const Key('court.drill.done'),
            icon: Icons.emoji_events_outlined,
            body: l.courtDrillDone,
          ),
          FilledButton(
            key: const Key('court.drill.stats'),
            onPressed: () => context.push(Routes.courtPrepStats),
            child: Text(l.courtStats),
          ),
        ] else ...[
          Text(
            l.courtDrillStep(_step + 1, steps.length),
            key: const Key('court.drill.step'),
            style: t.labelLarge,
          ),
          const SizedBox(height: FeSpace.xs),
          LinearProgressIndicator(value: (_step + 1) / steps.length),
          const SizedBox(height: FeSpace.sm),
          CourtScenarioView(
            key: ValueKey('drill.${steps[_step].id}'),
            scenario: steps[_step],
            bundle: bundle,
            pro: true,
            drill: true,
            nextLabel: l.courtDrillNext,
            onNext: () => setState(() => _step++),
          ),
        ],
        const SizedBox(height: FeSpace.md),
        const CourtDisclaimer(),
      ],
    );
  }
}

/// Shaxsiy statistika va urinishlar tarixi (Pro, faqat qurilmada).
class CourtStatsScreen extends ConsumerWidget {
  const CourtStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final bundle = ref.watch(courtPrepProvider).value ?? CourtPrepBundle.empty;
    final unlocked = ref.watch(courtPrepUnlockedProvider);
    final history = ref.watch(courtHistoryProvider);
    final stats = CourtStats(history);
    return _Frame(
      title: l.courtStats,
      listKey: const Key('court.statsView'),
      children: [
        if (!unlocked)
          const CourtProCard()
        else ...[
          FeBanner(icon: Icons.phone_android, text: l.courtStatsBody),
          const SizedBox(height: FeSpace.sm),
          Text(
            l.courtStatsAttempts(stats.count),
            key: const Key('court.stats.count'),
            style: t.titleSmall,
          ),
          if (stats.count == 0)
            FeEmptyState(
              key: const Key('court.stats.empty'),
              icon: Icons.insights_outlined,
              body: l.courtStatsEmpty,
              compact: true,
            )
          else ...[
            FeSectionHeader(l.courtStatsAverage),
            _ScoreCard(
              key: const Key('court.stats.average'),
              score: CourtScore({
                for (final cr in CourtCriterion.values)
                  cr: stats.average(cr).round(),
              }),
              notes: [
                for (final cr in CourtCriterion.values)
                  '${cr.label(l)}: ${stats.average(cr).toStringAsFixed(1)}/2',
              ],
            ),
            FeSectionHeader(l.courtStatsHistory),
            for (final a in history.reversed.take(30))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  bundle.scenario(a.scenarioId)?.role.icon ?? Icons.history,
                  color: c.accent,
                ),
                title: Text(
                  bundle.scenario(a.scenarioId)?.prompt.of(lang) ??
                      a.scenarioId,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodySmall,
                ),
                subtitle: Text(
                  '${feDate(context, a.at)} · '
                  '${l.courtSimTotal(a.score.total, CourtScore.max)}'
                  '${a.drill ? ' · ${l.courtDrill}' : ''}',
                  style: t.labelSmall?.copyWith(color: c.textSecondary),
                ),
              ),
            const SizedBox(height: FeSpace.sm),
            OutlinedButton.icon(
              key: const Key('court.stats.clear'),
              onPressed: () => ref.read(courtHistoryProvider.notifier).clear(),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(l.courtStatsClear),
            ),
          ],
        ],
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({super.key, required this.score, required this.notes});

  final CourtScore score;
  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.courtSimTotal(score.total, CourtScore.max),
            style: t.titleSmall,
          ),
          const SizedBox(height: FeSpace.xs),
          for (final cr in CourtCriterion.values)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(cr.label(l), style: t.bodySmall)),
                      Text(
                        '${score.of(cr)}/2',
                        key: Key('court.sim.score.${cr.name}'),
                        style: t.labelLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  LinearProgressIndicator(
                    value: score.of(cr) / 2,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                    color: score.of(cr) == 2
                        ? c.verified
                        : score.of(cr) == 1
                        ? c.accent
                        : c.danger,
                    backgroundColor: c.surface,
                    semanticsLabel: l.courtScoreSemantics(
                      cr.label(l),
                      score.of(cr),
                    ),
                  ),
                ],
              ),
            ),
          for (final n in notes)
            Padding(
              padding: const EdgeInsets.only(top: FeSpace.xxs),
              child: Text(
                n,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
