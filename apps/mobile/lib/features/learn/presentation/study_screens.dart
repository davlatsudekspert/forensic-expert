import 'dart:async';
import 'dart:math' as math;

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/study.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/guidelines/guideline_models.dart';
import '../../../domain/learn/study_models.dart';
import '../../disciplines/discipline_strings.dart';
import '../../evidence/evidence_strings.dart';
import '../../guidelines/presentation/guidelines_screens.dart';

/// To‘plam nomi (fan, modda guruhi yoki yo‘riqnoma yo‘nalishi).
String studyDeckTitle(AppLocalizations l, StudyDeck d) {
  switch (d.kind) {
    case StudyDeckKind.discipline:
      final x = ForensicDiscipline.values.asNameMap()[d.key];
      return x == null ? d.key : l.disciplineName(x);
    case StudyDeckKind.substanceGroup:
      return l.substanceGroupName(d.key);
    case StudyDeckKind.guidelineArea:
      final x = GuidelineArea.values.asNameMap()[d.key];
      return x == null ? d.key : x.label(l);
    case StudyDeckKind.teachingMaterial:
      return d.key == StudyCatalogBuilder.toksDeckKey ? l.studyDeckToks : d.key;
  }
}

String _sectionTitle(AppLocalizations l, StudyDeckKind k) => switch (k) {
  StudyDeckKind.discipline => l.studySectionTopics,
  StudyDeckKind.substanceGroup => l.studySectionSubstances,
  StudyDeckKind.guidelineArea => l.studySectionGuidelines,
  StudyDeckKind.teachingMaterial => l.studySectionTeaching,
};

String _originRoute(StudyItem i) => switch (i.origin) {
  StudyOrigin.knowledgeEntry => Routes.knowledgeEntry(i.originId),
  StudyOrigin.libraryEntry => Routes.libraryEntry(i.originId),
  StudyOrigin.guideline => Routes.guideline(i.originId),
};

/// O‘quv rejimi: fan / mavzu bo‘yicha to‘plamlar.
class StudyHubScreen extends ConsumerWidget {
  const StudyHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final catalog = ref.watch(studyCatalogProvider);
    final loading = ref.watch(studyCatalogLoadingProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.studyTitle)),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  FeBanner(
                    icon: Icons.menu_book_outlined,
                    text: l.studyIntro,
                    tone: FeBannerTone.review,
                  ),
                  if (catalog.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: FeSpace.lg),
                      child: loading
                          ? FeListSkeleton(semanticLabel: l.studyLoading)
                          : FeEmptyState(
                              key: const Key('study.empty'),
                              icon: Icons.school_outlined,
                              body: l.studyEmpty,
                            ),
                    )
                  else
                    for (final kind in StudyDeckKind.values)
                      if (catalog.decks.where((d) => d.kind == kind).toList()
                          case final decks when decks.isNotEmpty) ...[
                        FeSectionHeader(_sectionTitle(l, kind)),
                        for (final d in decks)
                          Padding(
                            padding: const EdgeInsets.only(bottom: FeSpace.xs),
                            child: _DeckCard(deck: d, catalog: catalog),
                          ),
                      ],
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

class _DeckCard extends ConsumerWidget {
  const _DeckCard({required this.deck, required this.catalog});

  final StudyDeck deck;
  final StudyCatalog catalog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final progress = ref.watch(studyProgressProvider);
    final now = ref.watch(studyClockProvider)();
    final due = LeitnerScheduler.dueCount(deck.items, progress, now);
    final canQuiz = StudyQuizBuilder.canQuiz(deck, catalog);
    return FeCard(
      key: Key('study.deck.${deck.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(studyDeckTitle(l, deck), style: t.titleSmall),
          const SizedBox(height: FeSpace.xxs),
          Wrap(
            spacing: FeSpace.xs,
            runSpacing: FeSpace.xxs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l.studyDeckCount(deck.items.length),
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
              StatusChip(
                key: Key('study.due.${deck.id}'),
                icon: Icons.schedule,
                label: l.studyDueCount(due),
                color: due > 0 ? c.accent : c.textSecondary,
              ),
              ReviewStatusBadge(status: deck.status, compact: true),
              if (deck.isTestData) const TestDataBadge(),
            ],
          ),
          if (deck.kind == StudyDeckKind.teachingMaterial) ...[
            const SizedBox(height: FeSpace.xs),
            Text(
              l.guidelineToksAttribution,
              key: Key('study.attribution.${deck.id}'),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ],
          const SizedBox(height: FeSpace.sm),
          Wrap(
            spacing: FeSpace.xs,
            runSpacing: FeSpace.xs,
            children: [
              FilledButton.tonalIcon(
                key: Key('study.cards.${deck.id}'),
                icon: const Icon(Icons.style_outlined),
                label: Text(l.learnFlashcards),
                onPressed: () => context.push(Routes.studyCards(deck.id)),
              ),
              OutlinedButton.icon(
                key: Key('study.quiz.${deck.id}'),
                icon: const Icon(Icons.quiz_outlined),
                label: Text(l.learnQuiz),
                onPressed: canQuiz
                    ? () => context.push(Routes.studyQuiz(deck.id))
                    : null,
              ),
            ],
          ),
          if (!canQuiz) ...[
            const SizedBox(height: FeSpace.xxs),
            Text(
              l.studyQuizUnavailable,
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartochkalar
// ---------------------------------------------------------------------------

/// Leitner qutilari bilan kartochkalar sessiyasi.
class StudyFlashcardsScreen extends ConsumerStatefulWidget {
  const StudyFlashcardsScreen({super.key, required this.deckId});

  final String deckId;

  @override
  ConsumerState<StudyFlashcardsScreen> createState() =>
      _StudyFlashcardsScreenState();
}

class _StudyFlashcardsScreenState extends ConsumerState<StudyFlashcardsScreen> {
  List<StudyItem>? _queue;
  int _index = 0;
  bool _revealed = false;
  int _known = 0;
  int _reviewed = 0;

  void _start(List<StudyItem> queue) => setState(() {
    _queue = queue;
    _index = 0;
    _revealed = false;
    _known = 0;
    _reviewed = 0;
  });

  void _grade(StudyItem item, {required bool knew}) {
    unawaited(
      ref.read(studyProgressProvider.notifier).record(item.id, knew: knew),
    );
    setState(() {
      _index++;
      _reviewed++;
      if (knew) _known++;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final deck = ref.watch(studyCatalogProvider).deck(widget.deckId);
    final progress = ref.watch(studyProgressProvider);
    final Widget body;
    if (deck == null) {
      body = FeEmptyState(
        key: const Key('study.deckNotFound'),
        icon: Icons.inbox_outlined,
        body: l.studyDeckNotFound,
      );
    } else {
      final queue = _queue ??= LeitnerScheduler.dueQueue(
        deck.items,
        progress,
        ref.read(studyClockProvider)(),
      );
      if (queue.isEmpty) {
        body = _caughtUp(context, l, deck, progress);
      } else if (_index >= queue.length) {
        body = _done(context, l, deck, progress);
      } else {
        body = _card(context, l, queue, progress);
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(deck == null ? l.learnFlashcards : studyDeckTitle(l, deck)),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: FeSpace.sm,
                  bottom: FeSpace.xl,
                ),
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _caughtUp(
    BuildContext context,
    AppLocalizations l,
    StudyDeck deck,
    Map<String, LeitnerCard> progress,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FeEmptyState(
        key: const Key('study.caughtUp'),
        icon: Icons.event_available_outlined,
        body: l.studyAllCaughtUp,
      ),
      const SizedBox(height: FeSpace.md),
      FilledButton(
        key: const Key('study.reviewAll'),
        onPressed: () =>
            _start(LeitnerScheduler.allByBox(deck.items, progress)),
        child: Text(l.studyReviewAll),
      ),
    ],
  );

  Widget _done(
    BuildContext context,
    AppLocalizations l,
    StudyDeck deck,
    Map<String, LeitnerCard> progress,
  ) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeCard(
          key: const Key('study.sessionDone'),
          child: Column(
            children: [
              Icon(Icons.task_alt, color: c.accent, size: 36),
              const SizedBox(height: FeSpace.xs),
              Semantics(
                header: true,
                child: Text(l.studySessionDone, style: t.titleMedium),
              ),
              const SizedBox(height: FeSpace.xxs),
              Semantics(
                liveRegion: true,
                child: Text(
                  l.studySessionSummary(_known, _reviewed),
                  key: const Key('study.sessionSummary'),
                  style: t.bodyLarge,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: FeSpace.md),
        FilledButton(
          key: const Key('study.reviewAll'),
          onPressed: () =>
              _start(LeitnerScheduler.allByBox(deck.items, progress)),
          child: Text(l.studyReviewAll),
        ),
        const SizedBox(height: FeSpace.xs),
        OutlinedButton(
          key: const Key('study.backToDecks'),
          onPressed: () => context.pop(),
          child: Text(l.studyBackToDecks),
        ),
        const SizedBox(height: FeSpace.xs),
        TextButton(
          key: const Key('study.reset'),
          onPressed: () {
            unawaited(
              ref.read(studyProgressProvider.notifier).reset([
                for (final i in deck.items) i.id,
              ]),
            );
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(l.studyResetDone)));
          },
          child: Text(l.studyResetProgress),
        ),
      ],
    );
  }

  Widget _card(
    BuildContext context,
    AppLocalizations l,
    List<StudyItem> queue,
    Map<String, LeitnerCard> progress,
  ) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final item = queue[_index];
    final box = progress[item.id]?.box;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.studyCardProgress(_index + 1, queue.length),
          key: const Key('study.cardProgress'),
          style: t.labelLarge?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: FeSpace.xxs),
        LinearProgressIndicator(
          value: _index / queue.length,
          semanticsLabel: l.studyCardProgress(_index + 1, queue.length),
        ),
        const SizedBox(height: FeSpace.sm),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xxs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ReviewStatusBadge(status: item.status, compact: true),
            StatusChip(
              icon: Icons.inventory_2_outlined,
              label: box == null
                  ? l.studyBoxNew
                  : l.studyBox(box, LeitnerScheduler.maxBox),
              color: c.textSecondary,
            ),
            if (item.isTestData) const TestDataBadge(),
          ],
        ),
        const SizedBox(height: FeSpace.sm),
        StudyFlipCard(
          key: const Key('study.card'),
          revealed: _revealed,
          hint: l.studyTapToFlip,
          onTap: () => setState(() => _revealed = !_revealed),
          front: _CardFront(item: item),
          back: _CardBack(item: item),
        ),
        const SizedBox(height: FeSpace.md),
        if (!_revealed)
          FilledButton(
            key: const Key('study.reveal'),
            onPressed: () => setState(() => _revealed = true),
            child: Text(l.flashcardShowAnswer),
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const Key('study.didntKnow'),
                  onPressed: () => _grade(item, knew: false),
                  child: Text(l.studyDidntKnow, textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(width: FeSpace.sm),
              Expanded(
                child: FilledButton(
                  key: const Key('study.knew'),
                  onPressed: () => _grade(item, knew: true),
                  child: Text(l.flashcardKnew, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
          StudySources(item: item),
        ],
      ],
    );
  }
}

/// Aylanuvchi kartochka (reduced motion’da animatsiyasiz).
class StudyFlipCard extends StatelessWidget {
  const StudyFlipCard({
    super.key,
    required this.revealed,
    required this.front,
    required this.back,
    required this.onTap,
    required this.hint,
  });

  final bool revealed;
  final Widget front;
  final Widget back;
  final VoidCallback onTap;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final radius = BorderRadius.circular(FeRadius.lg);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: revealed ? 1 : 0),
      duration: FeMotion.of(context, const Duration(milliseconds: 360)),
      curve: Curves.easeInOut,
      builder: (context, v, _) {
        final showBack = v >= 0.5;
        final face = showBack
            ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: back,
              )
            : front;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(v * math.pi),
          child: Semantics(
            button: true,
            hint: hint,
            child: Material(
              color: c.surfaceRaised,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: BorderSide(
                  color: showBack ? c.accentBorder : c.borderStrong,
                  width: showBack ? 1.5 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 220),
                  child: Padding(
                    padding: const EdgeInsets.all(FeSpace.lg),
                    child: Center(child: face),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({required this.item});

  final StudyItem item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final hint = switch (item.kind) {
      StudyItemKind.topicExcerpt => l.studyFrontTopic,
      StudyItemKind.substanceFormula => l.studyFrontSubstance,
      StudyItemKind.guidelineSummary => l.studyFrontGuideline,
      StudyItemKind.guidelineQuestion => l.studyFrontQuestion,
    };
    final prompt = item.prompt.resolve(lang);
    // Uzun sarlavha yoki katta shrift (2×) — so‘z o‘rtasidan uzilmasin.
    final largeText = MediaQuery.textScalerOf(context).scale(10) > 13;
    final compact =
        largeText ||
        prompt.length > 32 ||
        MediaQuery.sizeOf(context).width < 360;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          prompt,
          key: const Key('study.front'),
          style:
              (largeText
                      ? t.titleMedium
                      : compact
                      ? t.titleLarge
                      : t.headlineSmall)
                  ?.copyWith(color: c.textPrimary),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: compact ? FeSpace.xs : FeSpace.sm),
        Text(
          hint,
          style: t.bodyMedium?.copyWith(color: c.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.item});

  final StudyItem item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          item.prompt.resolve(lang),
          style: t.labelLarge?.copyWith(color: c.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: FeSpace.sm),
        StudyAnswerText(item: item, key: const Key('study.back')),
        if (item.group case final g?) ...[
          const SizedBox(height: FeSpace.sm),
          Text(
            l.studyGroupLabel(l.substanceGroupName(g)),
            style: t.bodySmall?.copyWith(color: c.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Javob matni: asl iqtibos, formula yoki mazmun (tarjima holati bilan).
class StudyAnswerText extends StatelessWidget {
  const StudyAnswerText({super.key, required this.item, this.maxLines});

  final StudyItem item;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final text = item.answer.resolve(lang);
    final overflow = maxLines == null ? null : TextOverflow.ellipsis;
    switch (item.kind) {
      case StudyItemKind.substanceFormula:
        return Text(
          text,
          style: FeThemeBuilder.numeric(t.headlineSmall!)
              .copyWith(color: c.textPrimary),
          textAlign: TextAlign.center,
        );
      case StudyItemKind.topicExcerpt:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.studyQuoteLabel,
              style: t.labelSmall?.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: FeSpace.xxs),
            DecoratedBox(
              decoration: BoxDecoration(
                border: BorderDirectional(
                  start: BorderSide(color: c.accent, width: 3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: FeSpace.sm),
                child: Text(
                  text,
                  locale: const Locale('en'),
                  maxLines: maxLines,
                  overflow: overflow,
                  style: t.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                  ),
                ),
              ),
            ),
          ],
        );
      case StudyItemKind.guidelineSummary:
      case StudyItemKind.guidelineQuestion:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              maxLines: maxLines,
              overflow: overflow,
              style: t.bodyLarge?.copyWith(height: 1.45),
            ),
            if (item.draftLanguages.contains(lang)) ...[
              const SizedBox(height: FeSpace.xs),
              Text(
                l.guidelineTranslationDraft,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
          ],
        );
    }
  }
}

/// Kartochka manbalari va asl yozuvga havola.
class StudySources extends StatelessWidget {
  const StudySources({super.key, required this.item, this.max = 3});

  final StudyItem item;
  final int max;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final shown = item.citations.take(max).toList();
    final more = item.citations.length - shown.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.studySourcesHeader),
        for (final (i, s) in shown.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: FeCard(
              key: Key('study.source.${item.id}.$i'),
              padding: const EdgeInsets.all(FeSpace.sm),
              semanticLabel: l.studyOpenSourceDetails,
              onTap: () => context.push(
                s.sourceId != null
                    ? Routes.source(s.sourceId!)
                    : _originRoute(item),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote_outlined, size: 20, color: c.accent),
                  const SizedBox(width: FeSpace.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.title,
                          locale: const Locale('en'),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        if (s.detail != null)
                          Text(
                            s.detail!,
                            style: t.bodySmall?.copyWith(
                              color: c.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        if (s.pages != null)
                          Text(
                            l.studySourcePages(s.pages!),
                            key: Key('study.source.pages.${item.id}.$i'),
                            style: t.bodySmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20, color: c.textSecondary),
                ],
              ),
            ),
          ),
        if (more > 0)
          Text(
            l.studyMoreSources(more),
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            key: Key('study.openEntry.${item.id}'),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(l.studyOpenEntry),
            onPressed: () => context.push(_originRoute(item)),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Test
// ---------------------------------------------------------------------------

/// O‘z-o‘zini tekshirish testi: variantlar — shu turdagi boshqa yozuvlar.
class StudyQuizScreen extends ConsumerStatefulWidget {
  const StudyQuizScreen({super.key, required this.deckId});

  final String deckId;

  @override
  ConsumerState<StudyQuizScreen> createState() => _StudyQuizScreenState();
}

class _StudyQuizScreenState extends ConsumerState<StudyQuizScreen> {
  List<StudyQuestion>? _questions;
  final _answers = <int>[];
  int? _selected;
  bool _checked = false;

  void _restart(StudyDeck deck) => setState(() {
    _questions = _build(deck);
    _answers.clear();
    _selected = null;
    _checked = false;
  });

  List<StudyQuestion> _build(StudyDeck deck) => StudyQuizBuilder.build(
    deck,
    ref.read(studyCatalogProvider),
    seed: ref.read(studySeedProvider)(),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final deck = ref.watch(studyCatalogProvider).deck(widget.deckId);
    final Widget body;
    if (deck == null) {
      body = FeEmptyState(
        key: const Key('study.deckNotFound'),
        icon: Icons.inbox_outlined,
        body: l.studyDeckNotFound,
      );
    } else {
      final questions = _questions ??= _build(deck);
      if (questions.isEmpty) {
        body = FeEmptyState(
          key: const Key('study.quiz.unavailable'),
          icon: Icons.quiz_outlined,
          body: l.studyQuizUnavailable,
        );
      } else if (_answers.length >= questions.length) {
        body = _results(context, l, deck, questions);
      } else {
        body = _question(context, l, questions);
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(deck == null ? l.learnQuiz : studyDeckTitle(l, deck)),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            FeContentFrame(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: FeSpace.sm,
                  bottom: FeSpace.xl,
                ),
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stem(BuildContext context, AppLocalizations l, StudyQuestion q) {
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final title = switch (q.item.kind) {
      StudyItemKind.topicExcerpt => l.studyQuizStemTopic,
      StudyItemKind.substanceFormula => l.studyQuizStemSubstance(
        q.item.prompt.resolve(lang),
      ),
      StudyItemKind.guidelineSummary => l.studyQuizStemGuideline,
      StudyItemKind.guidelineQuestion => q.item.prompt.resolve(lang),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            key: const Key('study.quiz.stem'),
            style: t.titleMedium,
          ),
        ),
        if (q.asksForPrompt) ...[
          const SizedBox(height: FeSpace.sm),
          StudyAnswerText(item: q.item),
        ],
      ],
    );
  }

  Widget _question(
    BuildContext context,
    AppLocalizations l,
    List<StudyQuestion> questions,
  ) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final n = _answers.length;
    final q = questions[n];
    final correct = _selected == q.correctIndex;
    final last = n == questions.length - 1;
    final mono = q.item.kind == StudyItemKind.substanceFormula;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.studyQuizQuestionOf(n + 1, questions.length),
          key: const Key('study.quiz.progress'),
          style: t.labelLarge?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: FeSpace.xxs),
        LinearProgressIndicator(
          value: n / questions.length,
          semanticsLabel: l.studyQuizQuestionOf(n + 1, questions.length),
        ),
        if (n == 0) ...[
          const SizedBox(height: FeSpace.sm),
          FeBanner(
            icon: Icons.info_outline,
            text: q.item.distractors.isNotEmpty
                ? l.studyQuizNoteAuthored
                : l.studyQuizNote,
          ),
        ],
        const SizedBox(height: FeSpace.sm),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xxs,
          children: [
            ReviewStatusBadge(status: q.item.status, compact: true),
            if (q.item.isTestData) const TestDataBadge(),
          ],
        ),
        const SizedBox(height: FeSpace.sm),
        _stem(context, l, q),
        const SizedBox(height: FeSpace.md),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: _OptionTile(
              key: Key('study.quiz.option.$i'),
              text: q.optionText(i).resolve(lang),
              mono: mono,
              selected: _selected == i,
              state: !_checked
                  ? null
                  : i == q.correctIndex
                  ? true
                  : _selected == i
                  ? false
                  : null,
              onTap: _checked ? null : () => setState(() => _selected = i),
            ),
          ),
        const SizedBox(height: FeSpace.sm),
        if (!_checked)
          FilledButton(
            key: const Key('study.quiz.check'),
            onPressed: _selected == null
                ? null
                : () => setState(() => _checked = true),
            child: Text(l.quizCheck),
          )
        else ...[
          Semantics(
            liveRegion: true,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: StatusChip(
                key: Key('study.quiz.feedback.${correct ? 'ok' : 'wrong'}'),
                icon: correct
                    ? Icons.check_circle_outline
                    : Icons.highlight_off,
                label: correct ? l.quizCorrect : l.quizIncorrect,
                color: correct ? c.verified : c.danger,
              ),
            ),
          ),
          StudySources(item: q.item, max: 2),
          const SizedBox(height: FeSpace.sm),
          FilledButton(
            key: const Key('study.quiz.next'),
            onPressed: () => setState(() {
              _answers.add(_selected!);
              _selected = null;
              _checked = false;
            }),
            child: Text(last ? l.studyQuizFinish : l.studyQuizNext),
          ),
        ],
      ],
    );
  }

  Widget _results(
    BuildContext context,
    AppLocalizations l,
    StudyDeck deck,
    List<StudyQuestion> questions,
  ) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final mistakes = [
      for (final (i, q) in questions.indexed)
        if (_answers[i] != q.correctIndex) (i, q),
    ];
    final score = questions.length - mistakes.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeCard(
          child: Column(
            children: [
              Icon(
                mistakes.isEmpty ? Icons.emoji_events_outlined : Icons.insights,
                color: c.accent,
                size: 36,
              ),
              const SizedBox(height: FeSpace.xs),
              Semantics(
                liveRegion: true,
                child: Text(
                  l.studyQuizScore(score, questions.length),
                  key: const Key('study.quiz.score'),
                  style: t.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: FeSpace.xs),
              LinearProgressIndicator(
                value: score / questions.length,
                semanticsLabel: l.studyQuizScore(score, questions.length),
              ),
            ],
          ),
        ),
        FeSectionHeader(l.studyQuizMistakes),
        if (mistakes.isEmpty)
          FeEmptyState(
            key: const Key('study.quiz.noMistakes'),
            icon: Icons.check_circle_outline,
            body: l.studyQuizNoMistakes,
            compact: true,
          )
        else
          for (final (i, q) in mistakes)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.sm),
              child: FeCard(
                key: Key('study.quiz.mistake.$i'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: FeSpace.xs,
                      runSpacing: FeSpace.xxs,
                      children: [
                        ReviewStatusBadge(status: q.item.status, compact: true),
                        if (q.item.isTestData) const TestDataBadge(),
                      ],
                    ),
                    const SizedBox(height: FeSpace.xs),
                    if (q.asksForPrompt)
                      StudyAnswerText(item: q.item, maxLines: 4)
                    else
                      Text(
                        q.item.kind == StudyItemKind.guidelineQuestion
                            ? q.item.prompt.resolve(lang)
                            : l.studyQuizStemSubstance(
                                q.item.prompt.resolve(lang),
                              ),
                        style: t.titleSmall,
                      ),
                    const SizedBox(height: FeSpace.xs),
                    Text(
                      l.studyQuizYourAnswer(
                        q.optionText(_answers[i]).resolve(lang),
                      ),
                      style: t.bodyMedium?.copyWith(color: c.danger),
                    ),
                    const SizedBox(height: FeSpace.xxs),
                    Text(
                      l.studyQuizCorrectAnswer(
                        q.optionText(q.correctIndex).resolve(lang),
                      ),
                      style: t.bodyMedium?.copyWith(
                        color: c.verified,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    StudySources(item: q.item, max: 2),
                  ],
                ),
              ),
            ),
        const SizedBox(height: FeSpace.md),
        FilledButton(
          key: const Key('study.quiz.retry'),
          onPressed: () => _restart(deck),
          child: Text(l.studyQuizRetry),
        ),
        const SizedBox(height: FeSpace.xs),
        OutlinedButton(
          key: const Key('study.quiz.back'),
          onPressed: () => context.pop(),
          child: Text(l.studyBackToDecks),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    super.key,
    required this.text,
    required this.mono,
    required this.selected,
    required this.state,
    required this.onTap,
  });

  final String text;
  final bool mono;
  final bool selected;

  /// `true` — to‘g‘ri javob, `false` — tanlangan xato javob (tekshiruvdan
  /// keyin), `null` — belgisiz.
  final bool? state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final accent = switch (state) {
      true => c.verified,
      false => c.danger,
      null => selected ? c.accent : c.borderStrong,
    };
    final icon = switch (state) {
      true => Icons.check_circle_outline,
      false => Icons.highlight_off,
      null =>
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
    };
    final style = mono ? FeThemeBuilder.numeric(t.bodyLarge!) : t.bodyLarge;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      button: true,
      child: Material(
        color: c.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FeRadius.md),
          side: BorderSide(
            color: accent,
            width: selected || state != null ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(FeSpace.md),
            child: Row(
              children: [
                Icon(icon, color: accent),
                const SizedBox(width: FeSpace.sm),
                Expanded(child: Text(text, style: style)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
