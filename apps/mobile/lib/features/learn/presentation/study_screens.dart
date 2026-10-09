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
import '../../evidence/presentation/localized_content.dart';
import '../../glossary/presentation/glossary_linked_text.dart';
import '../../guidelines/presentation/guidelines_screens.dart';

/// To‘plam nomi (fan, modda guruhi yoki yo‘riqnoma yo‘nalishi).
String studyDeckTitle(AppLocalizations l, StudyDeck d) {
  if (d.isMixed) {
    return switch (d.kind) {
      StudyDeckKind.discipline => l.studyDeckMixedTopics,
      StudyDeckKind.substanceGroup => l.studyDeckMixedSubstances,
      StudyDeckKind.guidelineArea ||
      StudyDeckKind.teachingMaterial => l.studyDeckMixedGuidelines,
    };
  }
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
      return switch (d.key) {
        StudyCatalogBuilder.toksDeckKey => l.studyDeckToks,
        StudyCatalogBuilder.gmtDeckKey => l.studyDeckGmt,
        _ => d.key,
      };
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

/// Kartochka manbasi sahifasi: paketdagi manba bo‘lsa — manba, aks holda
/// asl yozuv (yo‘riqnoma kartasi adabiyoti bilan).
String _sourceRoute(StudyItem i) {
  for (final c in i.citations) {
    if (c.sourceId != null) return Routes.source(c.sourceId!);
  }
  return _originRoute(i);
}

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
    final lang = Localizations.localeOf(context).languageCode;
    final progress = ref.watch(studyProgressProvider);
    final now = ref.watch(studyClockProvider)();
    final due = LeitnerScheduler.dueCount(deck.items, progress, now);
    final canQuiz = StudyQuizBuilder.canQuiz(deck, catalog);
    final examCount = StudyQuizBuilder.examCount(deck, catalog, lang);
    final canExam = StudyQuizBuilder.canExam(deck, catalog, lang);
    // Imtihon savollari bor, lekin tanlangan tildagi tarjimasi qoralama.
    final draftOnly =
        !canExam &&
        StudyQuizBuilder.canExam(deck, catalog, 'uz') &&
        deck.items.any((i) => i.draftLanguages.contains(lang));
    final note = t.bodySmall?.copyWith(color: c.textSecondary);
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
              Text(l.studyDeckCount(deck.items.length), style: note),
              StatusChip(
                key: Key('study.due.${deck.id}'),
                icon: Icons.schedule,
                label: l.studyDueCount(due),
                color: due > 0 ? c.accent : c.textSecondary,
              ),
              StatusChip(
                key: Key('study.examCount.${deck.id}'),
                icon: canExam ? Icons.verified_outlined : Icons.edit_note,
                label: canExam
                    ? l.studyExamCount(examCount)
                    : l.studyPracticeOnly,
                color: canExam ? c.verified : c.textSecondary,
              ),
              ReviewStatusBadge(status: deck.status, compact: true),
              if (deck.isTestData) const TestDataBadge(),
            ],
          ),
          if (deck.kind == StudyDeckKind.teachingMaterial) ...[
            const SizedBox(height: FeSpace.xs),
            Text(
              deck.key == StudyCatalogBuilder.gmtDeckKey
                  ? l.guidelineGmtAttribution
                  : l.guidelineToksAttribution,
              key: Key('study.attribution.${deck.id}'),
              style: note,
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
                icon: const Icon(Icons.fitness_center_outlined),
                label: Text(l.studyModePractice),
                onPressed: canQuiz
                    ? () => context.push(Routes.studyQuiz(deck.id))
                    : null,
              ),
              OutlinedButton.icon(
                key: Key('study.exam.${deck.id}'),
                icon: const Icon(Icons.fact_check_outlined),
                label: Text(l.studyModeExam),
                onPressed: canExam
                    ? () => context.push(Routes.studyQuiz(deck.id, exam: true))
                    : null,
              ),
            ],
          ),
          if (!canQuiz) ...[
            const SizedBox(height: FeSpace.xxs),
            Text(
              l.studyQuizFlashcardsOnly,
              key: Key('study.flashcardsOnly.${deck.id}'),
              style: note,
            ),
          ],
          if (!canExam && canQuiz) ...[
            const SizedBox(height: FeSpace.xxs),
            Text(
              draftOnly ? l.studyExamDraftLanguage : l.studyExamUnavailable,
              key: Key('study.examUnavailable.${deck.id}'),
              style: note,
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

/// Javob matni: manbadagi iqtibos (UI tilidagi tarjima birinchi, asl —
/// alohida ochiladi), formula yoki mazmun (tarjima holati bilan).
class StudyAnswerText extends ConsumerWidget {
  const StudyAnswerText({super.key, required this.item, this.maxLines});

  final StudyItem item;
  final int? maxLines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        return StudyQuoteText(
          claimId: item.claimId,
          quote: text,
          maxLines: maxLines,
          keyPrefix: item.id,
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

/// Manbadagi iqtibos: UI tilidagi avtomatik tarjima (holat belgisi bilan)
/// birinchi; asl matn «Asl manbadagi iqtibosni ko‘rish» orqali. Tarjima
/// bo‘lmasa — asl iqtibos (asl tilda deb belgilanadi).
class StudyQuoteText extends ConsumerWidget {
  const StudyQuoteText({
    super.key,
    required this.claimId,
    required this.quote,
    required this.keyPrefix,
    this.maxLines,
  });

  final String? claimId;
  final String quote;
  final String keyPrefix;
  final int? maxLines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    // Asl iqtibos — manba tilida (inglizcha); tarjima — claim ID bo‘yicha
    // (`ContentTranslations.resolve`, docs/L10N_DATA_CONTRACT.md).
    const kind = ContentTextKind.claimExcerpt;
    final id = claimId ?? keyPrefix;
    final r = resolveContent(
      ref,
      context,
      kind,
      id,
      source: quote,
      originalLang: 'en',
    );
    final overflow = maxLines == null ? null : TextOverflow.ellipsis;
    return Column(
      key: Key(
        r.isTranslation
            ? 'study.quote.translated.$keyPrefix'
            : 'study.quote.$keyPrefix',
      ),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          r.isTranslation ? l.trQuoteTranslatedLabel : l.studyQuoteLabel,
          style: t.labelSmall?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: FeSpace.xxs),
        if (r.missingTranslation) ...[
          NoTranslationNotice(
            key: Key('l10n.missing.$kind.$id'),
            originalLang: r.originalLang,
          ),
          const SizedBox(height: FeSpace.xxs),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(color: c.accent, width: 3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: FeSpace.sm),
            child: Text(
              r.text,
              key: Key('l10n.text.$kind.$id'),
              locale: Locale(r.textLang),
              maxLines: maxLines,
              overflow: overflow,
              style: t.bodyLarge?.copyWith(
                // Aynan iqtibos — kursiv; tarjima — oddiy matn.
                fontStyle: r.isTranslation ? null : FontStyle.italic,
                height: 1.45,
              ),
            ),
          ),
        ),
        if (r.isTranslation) ...[
          const SizedBox(height: FeSpace.xxs),
          TranslationStatusBadge(
            key: Key('l10n.status.$kind.$id'),
            status: r.status!,
          ),
          if (maxLines == null)
            OriginalTextToggle(
              key: Key('study.quote.original.$keyPrefix'),
              original: r.original,
              originalLang: r.originalLang,
              showLabel: l.trOriginalQuoteShow,
              toggleKey: Key('l10n.originalToggle.$kind.$id'),
              originalKey: Key('l10n.original.$kind.$id'),
              style: t.bodyMedium,
            ),
        ],
      ],
    );
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
    final lang = Localizations.localeOf(context).languageCode;
    final shown = item.citations.take(max).toList();
    final more = item.citations.length - shown.length;
    final small = t.bodySmall?.copyWith(color: c.textSecondary);
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
                        // Bibliografiya — asl sarlavha (tarjima bo‘lsa —
                        // u birinchi, asl nomi ostida).
                        TranslatedTitle(
                          kind: ContentTextKind.sourceTitle,
                          id: s.sourceId ?? s.title,
                          title: s.title,
                          originalLang: s.language,
                          maxLines: 4,
                          showMissingNotice: false,
                          style: t.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                        if (s.detail != null)
                          Text(
                            s.detail!,
                            style: small?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        if (s.pages != null)
                          Text(
                            l.studySourcePages(s.pages!),
                            key: Key('study.source.pages.${item.id}.$i'),
                            style: small,
                          ),
                        if (s.section case final sec?)
                          Text(
                            l.studySourceSection(sec.resolve(lang)),
                            key: Key('study.source.section.${item.id}.$i'),
                            style: small,
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20, color: c.textSecondary),
                ],
              ),
            ),
          ),
        if (more > 0) Text(l.studyMoreSources(more), style: small),
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

/// Javobdan keyingi izoh: «To‘g‘ri / Noto‘g‘ri», nega to‘g‘ri (muallif izohi
/// yoki manbali claim matni), to‘g‘ri javob va «Manbani ochish».
class StudyAnswerExplanation extends StatelessWidget {
  const StudyAnswerExplanation({
    super.key,
    required this.question,
    required this.correct,
    this.showVerdict = true,
  });

  final StudyQuestion question;
  final bool correct;
  final bool showVerdict;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final item = question.item;
    final body = t.bodyMedium?.copyWith(height: 1.45);
    final Widget why = switch (item.explanationKind) {
      StudyExplanationKind.authored => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlossaryLinkedText(
            item.explanation?.resolve(lang) ?? '',
            key: Key('study.explanation.text.${item.id}'),
            style: body,
          ),
          if (item.draftLanguages.contains(lang)) ...[
            const SizedBox(height: FeSpace.xxs),
            Text(
              l.guidelineTranslationDraft,
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ],
        ],
      ),
      StudyExplanationKind.sourcedClaim => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlossaryLinkedText(
            l.studyExplainTopic(item.prompt.resolve(lang)),
            key: Key('study.explanation.text.${item.id}'),
            style: body,
          ),
          const SizedBox(height: FeSpace.xs),
          Text(
            l.studyExplainSourceSays,
            style: t.labelMedium?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: FeSpace.xxs),
          StudyQuoteText(
            claimId: item.claimId,
            quote: item.answer.resolve('en'),
            keyPrefix: 'explain.${item.id}',
          ),
        ],
      ),
      StudyExplanationKind.substanceIdentity => Text(
        l.studyExplainSubstance(
          item.prompt.resolve(lang),
          item.answer.resolve(lang),
        ),
        key: Key('study.explanation.text.${item.id}'),
        style: body,
      ),
      StudyExplanationKind.guidelineSummary => GlossaryLinkedText(
        l.studyExplainGuideline(item.prompt.resolve(lang)),
        key: Key('study.explanation.text.${item.id}'),
        style: body,
      ),
    };
    return Column(
      key: Key('study.explanation.${item.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showVerdict)
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
        const SizedBox(height: FeSpace.xs),
        FeCard(
          padding: const EdgeInsets.all(FeSpace.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.quizExplanation,
                style: t.labelLarge?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: FeSpace.xxs),
              if (!correct || question.isTrueFalse) ...[
                Text(
                  l.studyQuizCorrectAnswer(question.correctText.resolve(lang)),
                  key: Key('study.explanation.answer.${item.id}'),
                  style: t.bodyMedium?.copyWith(
                    color: c.verified,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: FeSpace.xs),
              ],
              why,
              const SizedBox(height: FeSpace.xs),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilledButton.tonalIcon(
                  key: Key('study.quiz.openSource.${item.id}'),
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(l.studyOpenSource),
                  onPressed: () => context.push(_sourceRoute(item)),
                ),
              ),
            ],
          ),
        ),
        StudySources(item: item, max: 2),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Test: mashq va imtihon
// ---------------------------------------------------------------------------

/// O‘z-o‘zini tekshirish: [StudyQuizMode.practice] — darhol izoh bilan,
/// [StudyQuizMode.exam] — faqat imtihonga mos savollar, natija oxirida.
class StudyQuizScreen extends ConsumerStatefulWidget {
  const StudyQuizScreen({
    super.key,
    required this.deckId,
    this.mode = StudyQuizMode.practice,
  });

  final String deckId;
  final StudyQuizMode mode;

  @override
  ConsumerState<StudyQuizScreen> createState() => _StudyQuizScreenState();
}

class _StudyQuizScreenState extends ConsumerState<StudyQuizScreen> {
  List<StudyQuestion>? _questions;
  String? _lang;
  final _answers = <int>[];
  int? _selected;
  bool _checked = false;

  bool get _exam => widget.mode == StudyQuizMode.exam;

  void _restart(StudyDeck deck, String lang) => setState(() {
    _questions = _build(deck, lang);
    _answers.clear();
    _selected = null;
    _checked = false;
  });

  List<StudyQuestion> _build(StudyDeck deck, String lang) =>
      StudyQuizBuilder.build(
        deck,
        ref.read(studyCatalogProvider),
        seed: ref.read(studySeedProvider)(),
        mode: widget.mode,
        lang: lang,
      );

  void _next() => setState(() {
    _answers.add(_selected!);
    _selected = null;
    _checked = false;
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final deck = ref.watch(studyCatalogProvider).deck(widget.deckId);
    final Widget body;
    if (deck == null) {
      body = FeEmptyState(
        key: const Key('study.deckNotFound'),
        icon: Icons.inbox_outlined,
        body: l.studyDeckNotFound,
      );
    } else {
      // Til o‘zgarsa — imtihon to‘plami ham o‘zgaradi (qayta tuziladi).
      if (_lang != lang) {
        _lang = lang;
        _questions = _build(deck, lang);
        _answers.clear();
        _selected = null;
        _checked = false;
      }
      final questions = _questions!;
      if (questions.isEmpty) {
        body = FeEmptyState(
          key: const Key('study.quiz.unavailable'),
          icon: Icons.quiz_outlined,
          body: !_exam
              ? l.studyQuizUnavailable
              // Savollar bor, lekin shu tildagi tarjimasi qoralama.
              : StudyQuizBuilder.canExam(
                  deck,
                  ref.read(studyCatalogProvider),
                  'uz',
                )
              ? l.studyExamDraftLanguage
              : l.studyExamUnavailable,
        );
      } else if (_answers.length >= questions.length) {
        body = _results(context, l, deck, questions, lang);
      } else {
        body = _question(context, l, questions, lang);
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          deck == null
              ? (_exam ? l.studyModeExam : l.studyModePractice)
              : studyDeckTitle(l, deck),
        ),
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

  Widget _modeChip(AppLocalizations l, FeColorTokens c) => StatusChip(
    key: Key('study.mode.${_exam ? 'exam' : 'practice'}'),
    icon: _exam ? Icons.fact_check_outlined : Icons.fitness_center_outlined,
    label: _exam ? l.studyModeExam : l.studyModePractice,
    color: _exam ? c.accent : c.textSecondary,
  );

  Widget _stem(BuildContext context, AppLocalizations l, StudyQuestion q) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
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
        if (q.isTrueFalse) ...[
          const SizedBox(height: FeSpace.md),
          Text(
            l.studyTfProposed,
            style: t.labelMedium?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: FeSpace.xxs),
          FeCard(
            key: const Key('study.quiz.proposed'),
            padding: const EdgeInsets.all(FeSpace.sm),
            child: Text(
              q.proposed.resolve(lang),
              style: q.item.kind == StudyItemKind.substanceFormula
                  ? FeThemeBuilder.numeric(t.titleMedium!)
                  : t.titleSmall,
            ),
          ),
          const SizedBox(height: FeSpace.sm),
          Text(l.studyTfQuestion, style: t.titleSmall),
        ],
      ],
    );
  }

  String _choiceText(AppLocalizations l, StudyQuestion q, int i, String lang) =>
      q.isTrueFalse
      ? (i == 0 ? l.studyTrue : l.studyFalse)
      : q.optionText(i).resolve(lang);

  Widget _question(
    BuildContext context,
    AppLocalizations l,
    List<StudyQuestion> questions,
    String lang,
  ) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final n = _answers.length;
    final q = questions[n];
    final last = n == questions.length - 1;
    final mono =
        q.item.kind == StudyItemKind.substanceFormula && !q.isTrueFalse;
    final eligible = StudyEligibility.examEligible(q.item, lang);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l.studyQuizQuestionOf(n + 1, questions.length),
                key: const Key('study.quiz.progress'),
                style: t.labelLarge?.copyWith(color: c.textSecondary),
              ),
            ),
            _modeChip(l, c),
          ],
        ),
        const SizedBox(height: FeSpace.xxs),
        LinearProgressIndicator(
          value: n / questions.length,
          semanticsLabel: l.studyQuizQuestionOf(n + 1, questions.length),
        ),
        if (n == 0) ...[
          const SizedBox(height: FeSpace.sm),
          FeBanner(
            key: Key('study.mode.banner.${_exam ? 'exam' : 'practice'}'),
            icon: _exam ? Icons.fact_check_outlined : Icons.info_outline,
            tone: _exam ? FeBannerTone.review : FeBannerTone.info,
            text: _exam ? l.studyModeExamBanner : l.studyModePracticeBanner,
          ),
          if (!_exam) ...[
            const SizedBox(height: FeSpace.xs),
            FeBanner(
              icon: Icons.rule,
              text: q.item.distractors.isNotEmpty
                  ? l.studyQuizNoteAuthored
                  : questions.any((x) => x.isTrueFalse)
                  ? '${l.studyQuizNote} ${l.studyTfNote}'
                  : l.studyQuizNote,
            ),
          ],
        ],
        const SizedBox(height: FeSpace.sm),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xxs,
          children: [
            ReviewStatusBadge(status: q.item.status, compact: true),
            if (!_exam && !eligible)
              StatusChip(
                key: const Key('study.quiz.practiceOnly'),
                icon: Icons.edit_note,
                label: l.studyPracticeOnly,
                color: c.textSecondary,
              ),
            if (q.item.isTestData) const TestDataBadge(),
          ],
        ),
        const SizedBox(height: FeSpace.sm),
        _stem(context, l, q),
        const SizedBox(height: FeSpace.md),
        for (var i = 0; i < q.choiceCount; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            child: _OptionTile(
              key: Key('study.quiz.option.$i'),
              text: _choiceText(l, q, i, lang),
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
        if (_exam)
          FilledButton(
            key: const Key('study.quiz.next'),
            onPressed: _selected == null ? null : _next,
            child: Text(last ? l.studyQuizFinish : l.studyQuizNext),
          )
        else if (!_checked)
          FilledButton(
            key: const Key('study.quiz.check'),
            onPressed: _selected == null
                ? null
                : () => setState(() => _checked = true),
            child: Text(l.quizCheck),
          )
        else ...[
          StudyAnswerExplanation(question: q, correct: q.isCorrect(_selected!)),
          const SizedBox(height: FeSpace.sm),
          FilledButton(
            key: const Key('study.quiz.next'),
            onPressed: _next,
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
    String lang,
  ) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final mistakes = [
      for (final (i, q) in questions.indexed)
        if (!q.isCorrect(_answers[i])) (i, q),
    ];
    final score = questions.length - mistakes.length;
    // Imtihonda — barcha javoblar izoh bilan; mashqda — faqat xatolar.
    final review = _exam ? [...questions.indexed] : mistakes;
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
              if (_exam) ...[
                const SizedBox(height: FeSpace.xxs),
                Text(l.studyExamResultTitle, style: t.titleMedium),
              ],
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
              if (_exam)
                Text(
                  l.studyExamPercent((score * 100 / questions.length).round()),
                  key: const Key('study.exam.percent'),
                  style: t.bodyMedium?.copyWith(color: c.textSecondary),
                ),
              const SizedBox(height: FeSpace.xs),
              LinearProgressIndicator(
                value: score / questions.length,
                semanticsLabel: l.studyQuizScore(score, questions.length),
              ),
            ],
          ),
        ),
        FeSectionHeader(_exam ? l.studyExamReview : l.studyQuizMistakes),
        if (review.isEmpty)
          FeEmptyState(
            key: const Key('study.quiz.noMistakes'),
            icon: Icons.check_circle_outline,
            body: l.studyQuizNoMistakes,
            compact: true,
          )
        else
          for (final (i, q) in review)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.sm),
              child: FeCard(
                key: Key('study.quiz.${_exam ? 'review' : 'mistake'}.$i'),
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
                    if (q.isTrueFalse) ...[
                      const SizedBox(height: FeSpace.xxs),
                      Text(
                        '${l.studyTfProposed}: ${q.proposed.resolve(lang)}',
                        style: t.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: FeSpace.xs),
                    Text(
                      l.studyQuizYourAnswer(
                        _choiceText(l, q, _answers[i], lang),
                      ),
                      style: t.bodyMedium?.copyWith(
                        color: q.isCorrect(_answers[i]) ? c.verified : c.danger,
                      ),
                    ),
                    const SizedBox(height: FeSpace.xs),
                    StudyAnswerExplanation(
                      question: q,
                      correct: q.isCorrect(_answers[i]),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: FeSpace.md),
        FilledButton(
          key: const Key('study.quiz.retry'),
          onPressed: () => _restart(deck, lang),
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
