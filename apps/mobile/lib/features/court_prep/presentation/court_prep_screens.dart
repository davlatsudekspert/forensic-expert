import 'dart:math' as math;

import 'package:fe_search_core/fe_search_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/court_prep.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/court_prep/court_prep_models.dart';
import '../../../domain/guidelines/guideline_models.dart';
import '../../learn/presentation/study_screens.dart' show StudyFlipCard;
import '../../support/presentation/support_widgets.dart' show ReportErrorMenu;
import 'court_prep_widgets.dart';

export 'court_prep_widgets.dart';
export 'court_simulator_screens.dart';

/// Bo‘lim ekranlari uchun umumiy ramka.
class _CourtScaffold extends StatelessWidget {
  const _CourtScaffold({
    required this.title,
    required this.listKey,
    required this.children,
    this.actions = const [],
  });

  final String title;
  final Key listKey;
  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: actions),
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

/// Bosh sahifadagi kirish kartasi (ikonka, sarlavha, tavsif).
class _EntryCard extends StatelessWidget {
  const _EntryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
    this.pro = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  /// Mutaxassis Pro’dagi imkoniyat (kichik belgi bilan).
  final bool pro;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        onTap: onTap,
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: c.accentContainer,
                borderRadius: BorderRadius.circular(FeRadius.md),
              ),
              child: SizedBox.square(
                dimension: 40,
                child: Icon(icon, color: c.onAccentContainer, size: 21),
              ),
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
                      Text(title, style: t.titleSmall),
                      if (pro)
                        StatusChip(
                          icon: Icons.workspace_premium_outlined,
                          label: AppLocalizations.of(context).courtProBadge,
                          color: c.accent,
                        ),
                    ],
                  ),
                  const SizedBox(height: FeSpace.xxs),
                  Text(
                    body,
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
      ),
    );
  }
}

/// «Sudda so‘roq: tayyorgarlik» — tamoyillar, mashq, simulyator, mavzular.
class CourtPrepScreen extends ConsumerStatefulWidget {
  const CourtPrepScreen({super.key});

  @override
  ConsumerState<CourtPrepScreen> createState() => _CourtPrepScreenState();
}

class _CourtPrepScreenState extends ConsumerState<CourtPrepScreen> {
  static const _normalizer = SearchNormalizer();
  String _query = '';

  bool _matches(CourtPrepQuestion q) {
    final key = _normalizer.searchKey(_query);
    if (key.isEmpty) return true;
    return q.searchTerms.any((s) => _normalizer.searchKey(s).contains(key));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final async = ref.watch(courtPrepProvider);
    final bundle = async.value ?? CourtPrepBundle.empty;
    final unlocked = ref.watch(courtPrepUnlockedProvider);
    final uz = ref.watch(courtUzbekistanProvider);
    final results = _query.trim().isEmpty
        ? const <CourtPrepQuestion>[]
        : bundle.visible(uzbekistan: uz).where(_matches).toList();

    return _CourtScaffold(
      title: l.courtTitle,
      listKey: const Key('court.hub'),
      children: [
        const CourtDisclaimer(),
        const SizedBox(height: FeSpace.sm),
        if (async.isLoading)
          FeListSkeleton(semanticLabel: l.courtTitle)
        else if (bundle.isEmpty)
          FeEmptyState(
            key: const Key('court.empty'),
            icon: Icons.gavel_outlined,
            body: l.courtEmpty,
          )
        else ...[
          TextField(
            key: const Key('court.search'),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: l.courtSearchHint,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          if (_query.trim().isNotEmpty) ...[
            const SizedBox(height: FeSpace.sm),
            if (results.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: FeSpace.lg),
                child: Text(
                  l.courtNoResults,
                  key: const Key('court.noResults'),
                  textAlign: TextAlign.center,
                  style: t.bodyMedium?.copyWith(color: c.textSecondary),
                ),
              ),
            for (final q in results)
              _QuestionRow(
                question: q,
                lang: lang,
                subtitle: bundle.topic(q.topicId)?.title.of(lang),
              ),
          ] else ...[
            const SizedBox(height: FeSpace.sm),
            _JurisdictionNote(uzbekistan: uz),
            const SizedBox(height: FeSpace.sm),
            _EntryCard(
              key: const Key('court.principles'),
              icon: Icons.verified_user_outlined,
              title: l.courtPrinciples,
              body: l.courtPrinciplesBody,
              onTap: () => context.push(Routes.courtPrepPrinciples),
            ),
            _EntryCard(
              key: const Key('court.practice'),
              icon: Icons.style_outlined,
              title: l.courtPractice,
              body: l.courtPracticeBody,
              onTap: () => context.push(Routes.courtPrepPractice),
            ),
            _EntryCard(
              key: const Key('court.simulator'),
              icon: Icons.record_voice_over_outlined,
              title: l.courtSimulator,
              body: unlocked ? l.courtSimulatorBody : l.courtSimFreeNote,
              onTap: () => context.push(Routes.courtPrepSimulator),
            ),
            _EntryCard(
              key: const Key('court.drill'),
              icon: Icons.groups_outlined,
              title: l.courtDrill,
              body: l.courtDrillBody,
              pro: true,
              onTap: () => context.push(
                unlocked ? Routes.courtPrepDrill : Routes.purchase,
              ),
            ),
            _EntryCard(
              key: const Key('court.stats'),
              icon: Icons.insights_outlined,
              title: l.courtStats,
              body: l.courtStatsBody,
              pro: true,
              onTap: () => context.push(
                unlocked ? Routes.courtPrepStats : Routes.purchase,
              ),
            ),
            if (!unlocked) ...[
              const SizedBox(height: FeSpace.xs),
              const CourtProCard(),
            ],
            FeSectionHeader(l.courtTopics),
            for (final topic in bundle.topics)
              _TopicCard(topic: topic, bundle: bundle, uzbekistan: uz),
          ],
        ],
      ],
    );
  }
}

class _JurisdictionNote extends StatelessWidget {
  const _JurisdictionNote({required this.uzbekistan});

  final bool uzbekistan;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: Key('court.jurisdiction.${uzbekistan ? 'uz' : 'intl'}'),
      color: c.surface,
      padding: const EdgeInsets.all(FeSpace.sm),
      onTap: () => context.push(Routes.jurisdictionSelect),
      semanticLabel: l.courtJurisdictionChange,
      child: Row(
        children: [
          Icon(Icons.account_balance_outlined, color: c.accent, size: 20),
          const SizedBox(width: FeSpace.xs),
          Expanded(
            child: Text(
              uzbekistan ? l.courtJurisdictionUz : l.courtJurisdictionIntl,
              style: t.bodySmall,
            ),
          ),
          Icon(Icons.tune, color: c.textSecondary, size: 18),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.bundle,
    required this.uzbekistan,
  });

  final CourtPrepTopic topic;
  final CourtPrepBundle bundle;
  final bool uzbekistan;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final n = bundle.questionsOf(topic.id, uzbekistan: uzbekistan).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: Key('court.topic.${topic.id}'),
        onTap: () => context.push(Routes.courtPrepTopic(topic.id)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              courtTopicIcon(topic.icon),
              color: topic.pending ? c.textSecondary : c.accent,
            ),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topic.title.of(lang), style: t.titleSmall),
                  const SizedBox(height: FeSpace.xxs),
                  Text(
                    topic.summary.of(lang),
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: FeSpace.xxs),
                  if (topic.pending)
                    StatusChip(
                      key: Key('court.pending.${topic.id}'),
                      icon: Icons.hourglass_empty,
                      label: l.courtPendingTopic,
                      color: c.warning,
                    )
                  else
                    Text(
                      l.courtQuestionCount(n),
                      style: t.labelSmall?.copyWith(color: c.textSecondary),
                    ),
                ],
              ),
            ),
            ExcludeSemantics(
              child: Icon(Icons.chevron_right, color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Savol qatori: ochiq bo‘lsa — batafsil sahifa; yopiq bo‘lsa — tariflar.
class _QuestionRow extends StatelessWidget {
  const _QuestionRow({
    required this.question,
    required this.lang,
    this.subtitle,
  });

  final CourtPrepQuestion question;
  final String lang;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        key: Key('court.q.${question.id}'),
        onTap: () => context.push(Routes.courtPrepQuestion(question.id)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.help_outline, color: c.accent, size: 20),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question.of(lang),
                    style: t.bodyMedium?.copyWith(height: 1.35),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: FeSpace.xxs),
                      child: Text(
                        subtitle!,
                        style: t.labelSmall?.copyWith(color: c.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
            ExcludeSemantics(
              child: Icon(Icons.chevron_right, color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bitta mavzu: savollar ro‘yxati (yurisdiksiyaga qarab).
class CourtTopicScreen extends ConsumerWidget {
  const CourtTopicScreen({super.key, required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final bundle = ref.watch(courtPrepProvider).value ?? CourtPrepBundle.empty;
    final uz = ref.watch(courtUzbekistanProvider);
    final topic = bundle.topic(topicId);
    if (topic == null) {
      return Scaffold(appBar: AppBar(title: Text(l.courtTitle)));
    }
    final questions = bundle.questionsOf(topic.id, uzbekistan: uz);
    return _CourtScaffold(
      title: l.courtTitle,
      listKey: const Key('court.topicList'),
      children: [
        Semantics(
          header: true,
          child: Text(
            topic.title.of(lang),
            style: t.headlineSmall,
            textScaler: MediaQuery.textScalerOf(context)
                .clamp(maxScaleFactor: 1.3),
          ),
        ),
        const SizedBox(height: FeSpace.xs),
        Text(
          topic.summary.of(lang),
          style: t.bodyMedium?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: FeSpace.sm),
        const CourtDisclaimer(),
        if (topic.pending) ...[
          const SizedBox(height: FeSpace.md),
          FeEmptyState(
            key: const Key('court.topicPending'),
            icon: Icons.hourglass_empty,
            body: l.courtPendingTopic,
          ),
        ] else ...[
          FeSectionHeader(l.courtQuestionCount(questions.length)),
          for (final q in questions) _QuestionRow(question: q, lang: lang),
        ],
      ],
    );
  }
}

/// Savol kartasi: A savol, holat (I), sud nimani tekshiradi, B–H bloklar.
class CourtQuestionScreen extends ConsumerWidget {
  const CourtQuestionScreen({super.key, required this.questionId});

  final String questionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final bundle = ref.watch(courtPrepProvider).value ?? CourtPrepBundle.empty;
    final uz = ref.watch(courtUzbekistanProvider);
    final q = bundle.question(questionId);
    if (q == null) {
      return Scaffold(appBar: AppBar(title: Text(l.courtTitle)));
    }
    final topic = bundle.topic(q.topicId);
    final siblings = bundle.questionsOf(q.topicId, uzbekistan: uz);
    final title = q.question.pick(lang);

    return _CourtScaffold(
      title: l.courtTitle,
      listKey: const Key('court.detail'),
      actions: [ReportErrorMenu(entityId: 'court:${q.id}', title: title.text)],
      children: [
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xxs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ReviewStatusBadge(
              key: const Key('court.status'),
              status: q.status,
              compact: true,
            ),
            if (topic != null)
              Text(
                topic.title.of(lang),
                style: t.labelMedium?.copyWith(color: c.textSecondary),
              ),
            if (siblings.contains(q))
              Text(
                l.courtQuestionOf(siblings.indexOf(q) + 1, siblings.length),
                style: t.labelMedium?.copyWith(color: c.textSecondary),
              ),
          ],
        ),
        const SizedBox(height: FeSpace.xs),
        Semantics(
          header: true,
          child: Text(
            title.text,
            key: const Key('court.detail.question'),
            style: t.headlineSmall,
            textScaler: MediaQuery.textScalerOf(context)
                .clamp(maxScaleFactor: 1.3),
          ),
        ),
        const SizedBox(height: FeSpace.sm),
        const CourtDisclaimer(),
        if (q.translationFor(lang) == GuidelineTranslationStatus.draft) ...[
          const SizedBox(height: FeSpace.xs),
          FeBanner(
            key: const Key('court.draftTranslation'),
            icon: Icons.translate,
            tone: FeBannerTone.warning,
            text: l.guidelineTranslationDraft,
          ),
        ],
        CourtQuestionBody(question: q, bundle: bundle),
      ],
    );
  }
}

/// Halollik tamoyillari — hamma uchun ochiq (pullik devor ortida emas).
class CourtPrinciplesScreen extends ConsumerWidget {
  const CourtPrinciplesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final bundle = ref.watch(courtPrepProvider).value ?? CourtPrepBundle.empty;
    return _CourtScaffold(
      title: l.courtPrinciples,
      listKey: const Key('court.principlesView'),
      children: [
        FeBanner(
          key: const Key('court.principles.intro'),
          icon: Icons.verified_user_outlined,
          tone: FeBannerTone.review,
          text: l.courtPrinciplesIntro,
        ),
        const SizedBox(height: FeSpace.sm),
        for (final (i, p) in bundle.principles.indexed) ...[
          FeCard(
            key: Key('court.principle.${p.id}'),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: c.accentContainer,
                  child: Text(
                    '${i + 1}',
                    style: t.labelLarge?.copyWith(color: c.onAccentContainer),
                  ),
                ),
                const SizedBox(width: FeSpace.sm),
                Expanded(
                  child: SelectableText(
                    courtCite(p.text, lang, courtRefIndex(bundle, p)),
                    style: t.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          CourtSourcesSection(item: p, bundle: bundle, showExport: false),
        ],
        const SizedBox(height: FeSpace.sm),
        const CourtDisclaimer(),
      ],
    );
  }
}

/// «Mashq rejimi»: tasodifiy savol → o‘ylash → kartani ochish.
class CourtPracticeScreen extends ConsumerStatefulWidget {
  const CourtPracticeScreen({super.key, this.random});

  /// Testlar uchun barqaror tartib.
  final math.Random? random;

  @override
  ConsumerState<CourtPracticeScreen> createState() =>
      _CourtPracticeScreenState();
}

class _CourtPracticeScreenState extends ConsumerState<CourtPracticeScreen> {
  late final math.Random _random = widget.random ?? math.Random();
  final _order = <String>[];
  var _position = 0;
  var _practised = 0;
  var _revealed = false;

  void _ensureOrder(List<String> ids) {
    final same = _order.length == ids.length && _order.toSet().containsAll(ids);
    if (same) return;
    _order
      ..clear()
      ..addAll(ids)
      ..shuffle(_random);
    _position = 0;
  }

  void _next() => setState(() {
    _revealed = false;
    _practised++;
    _position = (_position + 1) % _order.length;
    if (_position == 0) _order.shuffle(_random);
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final bundle = ref.watch(courtPrepProvider).value ?? CourtPrepBundle.empty;
    final uz = ref.watch(courtUzbekistanProvider);
    _ensureOrder([for (final q in bundle.visible(uzbekistan: uz)) q.id]);
    final q = _order.isEmpty ? null : bundle.question(_order[_position]);

    return _CourtScaffold(
      title: l.courtPractice,
      listKey: const Key('court.practiceView'),
      children: [
        const CourtDisclaimer(),
        if (q == null)
          FeEmptyState(icon: Icons.gavel_outlined, body: l.courtEmpty)
        else ...[
          const SizedBox(height: FeSpace.sm),
          Text(
            l.courtPracticeProgress(_practised),
            key: const Key('court.practice.progress'),
            style: t.labelMedium?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: FeSpace.xs),
          StudyFlipCard(
            key: const Key('court.practice.card'),
            revealed: _revealed,
            hint: l.courtPracticeHint,
            onTap: () => setState(() => _revealed = !_revealed),
            front: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  bundle.topic(q.topicId)?.title.of(lang) ?? '',
                  textAlign: TextAlign.center,
                  style: t.labelMedium?.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: FeSpace.sm),
                Text(
                  q.question.of(lang),
                  key: const Key('court.practice.question'),
                  textAlign: TextAlign.center,
                  style: t.titleLarge,
                ),
              ],
            ),
            back: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.courtShortAnswer, style: t.titleSmall),
                const SizedBox(height: FeSpace.xs),
                Text(
                  courtCite(q.shortAnswer, lang, courtRefIndex(bundle, q)),
                  textAlign: TextAlign.center,
                  style: t.bodyMedium?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: FeSpace.sm),
          if (!_revealed) ...[
            Text(
              l.courtPracticeThink,
              key: const Key('court.practice.think'),
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: FeSpace.sm),
            FilledButton.icon(
              key: const Key('court.practice.reveal'),
              onPressed: () => setState(() => _revealed = true),
              icon: const Icon(Icons.checklist),
              label: Text(l.courtPracticeReveal),
            ),
          ] else
            CourtQuestionBody(
              key: Key('court.practice.body.${q.id}'),
              question: q,
              bundle: bundle,
            ),
          const SizedBox(height: FeSpace.sm),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: FeSpace.xs,
            runSpacing: FeSpace.xs,
            children: [
              OutlinedButton.icon(
                key: const Key('court.practice.open'),
                onPressed: () => context.push(Routes.courtPrepQuestion(q.id)),
                icon: const Icon(Icons.open_in_full, size: 18),
                label: Text(l.courtPracticeOpen),
              ),
              OutlinedButton.icon(
                key: const Key('court.practice.next'),
                onPressed: _next,
                icon: const Icon(Icons.shuffle, size: 18),
                label: Text(l.courtPracticeNext),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
