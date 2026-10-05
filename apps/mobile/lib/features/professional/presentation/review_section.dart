import 'package:fe_content_schema/fe_content_schema.dart' show KnowledgeArea;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/professional.dart';
import '../../../app/providers.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/knowledge/knowledge_models.dart';
import '../../../domain/library/library_models.dart';
import '../../../domain/ports/professional_ports.dart';
import '../../../domain/professional/professional_models.dart';
import '../../../domain/professional/review_models.dart';
import '../professional_strings.dart';
import 'professional_widgets.dart';

/// «MUTAXASSIS TAQRIZI» — ijtimoiy izoh emas. Faqat malakali, soha
/// vakolati berilgan mutaxassis taqrizi ko‘rsatiladi; taqriz yo‘q bo‘lsa —
/// ochiq aytiladi (soxta taqriz yo‘q).
///
/// Bitta taqriz ilmiy tasdiq emas: tekshiruv qatlamlari alohida
/// ko‘rsatiladi (manba · identifikator · mutaxassis taqrizi · inson
/// ilmiy tasdig‘i).
class ProfessionalReviewSection extends ConsumerWidget {
  const ProfessionalReviewSection({
    super.key,
    required this.recordId,
    required this.kind,
    this.scopes,
    this.claimId,
    this.risk = RiskLevel.standard,
    this.sourceCount = 0,
    this.identifiersVerified,
  });

  final String recordId;
  final ReviewSubjectKind kind;

  /// `null` — tur bo‘yicha standart sohalar.
  final Set<ReviewerScope>? scopes;
  final String? claimId;
  final RiskLevel risk;
  final int sourceCount;

  /// `null` — identifikatorli manba yo‘q (qo‘llanilmaydi).
  final bool? identifiersVerified;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final version = ref.watch(contentStatusProvider).value?.packVersion ?? '—';
    final subject = ReviewSubject(
      recordId: recordId,
      kind: kind,
      claimId: claimId,
      contentVersion: version,
      scopes: scopes ?? ReviewScopes.forKind(kind),
      risk: risk,
    );
    final identity = ref.watch(professionalIdentityProvider);
    final studentUi =
        ref.watch(settingsControllerProvider.select((s) => s.userMode)) ==
        UserMode.student;
    final permission = ReviewAuthority.canReview(
      identity,
      subject,
      studentModeUi: studentUi,
    );
    final result = ref.watch(reviewsForProvider(recordId));
    final reviews = result.value?.value ?? const <ProfessionalReview>[];
    // Server tekshirgan (yozilgan paytda tasdiqlangan mutaxassis) va
    // joriy versiyaga tegishli mustaqil ma’qullashlar soni.
    final approvals = reviews
        .where(
          (r) =>
              !r.withdrawn &&
              r.contentVersion == version &&
              r.action == ReviewAction.approve &&
              r.reviewerVerificationStatus ==
                  VerificationStatus.verifiedProfessional,
        )
        .map((r) => r.reviewerUserId)
        .toSet()
        .length;
    final required = const ReviewPolicy().requiredFor(risk);

    return Column(
      key: Key('review.section.$recordId'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.reviewSectionTitle),
        _Layers(
          sourceCount: sourceCount,
          identifiersVerified: identifiersVerified,
          professionalReviews: reviews
              .where((r) => !r.withdrawn && r.contentVersion == version)
              .length,
          humanApprovals: approvals,
          required: required,
        ),
        const SizedBox(height: FeSpace.sm),
        if (result.isLoading)
          const Padding(
            padding: EdgeInsets.all(FeSpace.sm),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: FeSpace.xs),
            child: FeNote(
              key: Key('review.empty.$recordId'),
              icon: Icons.rate_review_outlined,
              text: l.reviewEmpty,
            ),
          )
        else
          for (final r in reviews)
            ProfessionalReviewCard(
              review: r,
              stale: r.contentVersion != version,
            ),
        const SizedBox(height: FeSpace.xs),
        if (permission == ReviewPermission.allowed)
          OutlinedButton.icon(
            key: Key('review.write.$recordId'),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => ReviewComposer(subject: subject),
            ),
            icon: const Icon(Icons.rate_review_outlined),
            label: Text(l.reviewWrite),
          )
        else
          Text(
            subject.scopes.isEmpty
                ? l.reviewScopeNotAssigned
                : permission == ReviewPermission.notSignedIn
                ? l.reviewWhoCanReview
                : l.reviewPermissionLabel(permission),
            key: Key('review.permission.$recordId'),
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
      ],
    );
  }
}

class _Layers extends StatelessWidget {
  const _Layers({
    required this.sourceCount,
    required this.identifiersVerified,
    required this.professionalReviews,
    required this.humanApprovals,
    required this.required,
  });

  final int sourceCount;
  final bool? identifiersVerified;
  final int professionalReviews;
  final int humanApprovals;
  final int required;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    Widget row(String key, bool? done, String title, String value) {
      final (icon, color) = switch (done) {
        true => (Icons.check_circle_outline, c.verified),
        false => (Icons.radio_button_unchecked, c.textSecondary),
        null => (Icons.remove, c.textSecondary),
      };
      return Semantics(
        label: [title, value].join(': '),
        excludeSemantics: true,
        child: Padding(
          key: Key('review.layer.$key'),
          padding: const EdgeInsets.symmetric(vertical: FeSpace.xxs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: FeSpace.xs),
              Expanded(flex: 3, child: Text(title, style: t.bodyMedium)),
              const SizedBox(width: FeSpace.xs),
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        borderRadius: BorderRadius.circular(FeRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FeSpace.sm,
          vertical: FeSpace.xs,
        ),
        child: Column(
          children: [
            row(
              'source',
              sourceCount > 0,
              l.layerSource,
              sourceCount > 0
                  ? l.layerSourceCount(sourceCount)
                  : l.noReliableSource,
            ),
            row(
              'identifier',
              identifiersVerified,
              l.layerIdentifier,
              switch (identifiersVerified) {
                true => l.layerIdentifierOk,
                false => l.layerIdentifierPending,
                null => l.layerNotApplicable,
              },
            ),
            row(
              'professional',
              professionalReviews > 0,
              l.layerProfessional,
              '$professionalReviews',
            ),
            row(
              'human',
              humanApprovals >= required,
              l.layerHuman,
              l.layerHumanCount(humanApprovals, required),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bitta mutaxassis taqrizi kartasi.
class ProfessionalReviewCard extends StatelessWidget {
  const ProfessionalReviewCard({
    super.key,
    required this.review,
    this.stale = false,
  });

  final ProfessionalReview review;
  final bool stale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final loc = MaterialLocalizations.of(context);
    final decisionColor = switch (review.action) {
      ReviewAction.approve => c.verified,
      ReviewAction.requestChange || ReviewAction.flagOutdated => c.warning,
      ReviewAction.flagConflict || ReviewAction.reject => c.danger,
    };
    return Card(
      key: Key('review.card.${review.reviewId}'),
      child: Padding(
        padding: const EdgeInsets.all(FeSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VerifiedProfessionalBadge(
              status: review.reviewerVerificationStatus,
            ),
            const SizedBox(height: FeSpace.xxs),
            Text(review.reviewerDisplayName, style: t.titleSmall),
            Text(
              l.scopeLabel(review.reviewerScope),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
            if (review.reviewerOrganization case final o?)
              Text(o, style: t.bodySmall?.copyWith(color: c.textSecondary)),
            const SizedBox(height: FeSpace.sm),
            Text(
              '${l.reviewDecision}: ${l.reviewDecisionLabel(review.action)}',
              key: Key('review.decision.${review.reviewId}'),
              style: t.labelLarge?.copyWith(color: decisionColor),
            ),
            const SizedBox(height: FeSpace.xs),
            Text(review.text, style: t.bodyMedium),
            if (review.sourceReference case final s?) ...[
              const SizedBox(height: FeSpace.xs),
              Text(
                '${l.reviewSourceRef}: $s',
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ],
            const SizedBox(height: FeSpace.sm),
            Text(
              l.reviewMeta(
                loc.formatShortDate(review.createdAt),
                review.contentVersion,
              ),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
            if (stale) ...[
              const SizedBox(height: FeSpace.xs),
              FeNote(
                key: Key('review.stale.${review.reviewId}'),
                icon: Icons.history,
                text: l.reviewStale,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Taqriz yozish (faqat vakolatli mutaxassis uchun ochiladi; server
/// vakolatni baribir qayta tekshiradi).
class ReviewComposer extends ConsumerStatefulWidget {
  const ReviewComposer({super.key, required this.subject});

  final ReviewSubject subject;

  @override
  ConsumerState<ReviewComposer> createState() => _ReviewComposerState();
}

class _ReviewComposerState extends ConsumerState<ReviewComposer> {
  ReviewAction _action = ReviewAction.requestChange;
  final _note = TextEditingController();
  final _source = TextEditingController();
  Set<ReviewDraftError> _errors = const {};
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    _source.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final errors = ReviewDraftValidation.validate(
      note: _note.text,
      sourceReference: _source.text,
    );
    setState(() => _errors = errors);
    if (errors.isNotEmpty) return;
    setState(() => _busy = true);
    final r = await ref
        .read(professionalReviewServiceProvider)
        .submit(
          subject: widget.subject,
          action: _action,
          note: _note.text.trim(),
          sourceReference: _source.text.trim().isEmpty
              ? null
              : _source.text.trim(),
        );
    if (!mounted) return;
    setState(() => _busy = false);
    final messenger = ScaffoldMessenger.of(context);
    if (r.ok) {
      ref.invalidate(reviewsForProvider(widget.subject.recordId));
      Navigator.pop(context);
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          r.ok ? l.reviewSubmitted : l.professionalFailureLabel(r.failure!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ListView(
        key: const Key('review.composer'),
        shrinkWrap: true,
        padding: const EdgeInsets.all(FeSpace.md),
        children: [
          Text(l.reviewWrite, style: t.titleLarge),
          const SizedBox(height: FeSpace.xs),
          FeNote(icon: Icons.info_outline, text: l.reviewNotVerification),
          const SizedBox(height: FeSpace.md),
          Text(l.reviewDecision, style: t.titleSmall),
          RadioGroup<ReviewAction>(
            groupValue: _action,
            onChanged: (v) => setState(() => _action = v!),
            child: Column(
              children: [
                for (final a in ReviewAction.values)
                  RadioListTile<ReviewAction>(
                    key: Key('review.action.${a.name}'),
                    contentPadding: EdgeInsets.zero,
                    value: a,
                    title: Text(l.reviewActionLabel(a)),
                  ),
              ],
            ),
          ),
          TextField(
            key: const Key('review.note'),
            controller: _note,
            minLines: 4,
            maxLines: 10,
            maxLength: ReviewDraftValidation.maxNote,
            decoration: InputDecoration(
              labelText: requiredLabel(l.reviewNote),
              helperText: l.reviewNoteHelper,
              errorText: _errors.contains(ReviewDraftError.noteTooShort)
                  ? l.reviewNoteTooShort
                  : _errors.contains(ReviewDraftError.noteTooLong)
                  ? l.formTooLong
                  : null,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: FeSpace.sm),
          TextField(
            key: const Key('review.source'),
            controller: _source,
            decoration: InputDecoration(
              labelText: l.reviewSourceRef,
              helperText: l.reviewSourceHelper,
              errorText:
                  _errors.contains(ReviewDraftError.invalidSourceReference)
                  ? l.reviewSourceInvalid
                  : null,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: FeSpace.md),
          FilledButton(
            key: const Key('review.submit'),
            onPressed: _busy ? null : _submit,
            child: Text(l.reviewSubmit),
          ),
          const SizedBox(height: FeSpace.xs),
          Text(
            l.reviewVersionNote(widget.subject.contentVersion),
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Taqrizchi ish joyi (faqat tasdiqlangan, soha vakolati bor
/// mutaxassis uchun).
class ReviewDashboardScreen extends ConsumerStatefulWidget {
  const ReviewDashboardScreen({super.key});

  @override
  ConsumerState<ReviewDashboardScreen> createState() =>
      _ReviewDashboardScreenState();
}

class _ReviewDashboardScreenState extends ConsumerState<ReviewDashboardScreen> {
  ReviewQueue _queue = ReviewQueue.needsReview;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final identity = ref.watch(professionalIdentityProvider);
    final allowed =
        identity != null &&
        identity.isVerifiedProfessional &&
        identity.scopes.isNotEmpty;
    final result = allowed ? ref.watch(reviewQueueProvider(_queue)) : null;
    return Scaffold(
      appBar: AppBar(title: Text(l.dashboardTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('dashboard.list'),
          padding: const EdgeInsets.symmetric(
            vertical: FeSpace.md,
            horizontal: FeSpace.md,
          ),
          children: [
            if (!allowed)
              FeEmptyState(
                key: const Key('dashboard.forbidden'),
                icon: Icons.lock_outline,
                title: l.dashboardTitle,
                body: l.dashboardOnlyVerified,
              )
            else ...[
              Wrap(
                spacing: FeSpace.xs,
                runSpacing: FeSpace.xs,
                children: [
                  for (final s in identity.scopes)
                    StatusChip(
                      icon: Icons.rate_review_outlined,
                      label: l.scopeLabel(s),
                      color: c.accent,
                    ),
                ],
              ),
              const SizedBox(height: FeSpace.sm),
              Wrap(
                spacing: FeSpace.xs,
                runSpacing: FeSpace.xs,
                children: [
                  for (final q in ReviewQueue.values)
                    ChoiceChip(
                      key: Key('dashboard.queue.${q.name}'),
                      label: Text(l.reviewQueueLabel(q)),
                      selected: _queue == q,
                      onSelected: (_) => setState(() => _queue = q),
                    ),
                ],
              ),
              const SizedBox(height: FeSpace.md),
              switch (result) {
                null || AsyncLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                AsyncData(:final value) when !value.ok => FeBanner(
                  key: const Key('dashboard.unavailable'),
                  icon: Icons.cloud_off_outlined,
                  text: l.professionalFailureLabel(value.failure!),
                ),
                AsyncData(:final value) when value.value!.isEmpty =>
                  FeEmptyState(
                    icon: Icons.inbox_outlined,
                    body: l.dashboardQueueEmpty,
                  ),
                AsyncData(:final value) => Column(
                  children: [
                    for (final item in value.value!)
                      Card(
                        key: Key('dashboard.item.${item.subject.recordId}'),
                        child: Padding(
                          padding: const EdgeInsets.all(FeSpace.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: t.titleSmall),
                              Text(
                                item.discipline,
                                style: t.bodySmall?.copyWith(
                                  color: c.textSecondary,
                                ),
                              ),
                              const SizedBox(height: FeSpace.xs),
                              Text(
                                l.dashboardItemMeta(
                                  item.claimCount,
                                  item.sourceCount,
                                  item.evidenceLevel ?? '—',
                                  item.subject.contentVersion,
                                ),
                                style: t.bodySmall?.copyWith(
                                  color: c.textSecondary,
                                ),
                              ),
                              const SizedBox(height: FeSpace.xs),
                              StatusChip(
                                icon: Icons.flag_outlined,
                                label: l.reviewStateLabel(item.state),
                                color: c.reviewed,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                AsyncError() => FeBanner(
                  icon: Icons.error_outline,
                  text: l.proServerError,
                ),
              },
            ],
          ],
        ),
      ),
    );
  }
}

/// Manbalardagi DOI/PMID API orqali tekshirilganmi. Identifikatorli
/// manba bo‘lmasa — `null` (qo‘llanilmaydi).
bool? identifiersVerified(List<SourceView> sources) {
  final withId = [
    for (final s in sources)
      if (s.doi != null || s.pmid != null) s,
  ];
  if (withId.isEmpty) return null;
  return withId.every((s) => s.identifierVerified);
}

/// Bilim yozuvi turi/sohasidan taqriz obyekti turi.
ReviewSubjectKind reviewKindForKnowledge(
  KnowledgeKind kind,
  KnowledgeArea area,
) => switch (kind) {
  KnowledgeKind.reagent => ReviewSubjectKind.reagent,
  KnowledgeKind.screeningTest => ReviewSubjectKind.screeningTest,
  KnowledgeKind.method => ReviewSubjectKind.method,
  KnowledgeKind.emergingIssue => ReviewSubjectKind.claim,
  KnowledgeKind.topic => switch (area) {
    KnowledgeArea.forensicMedicine => ReviewSubjectKind.forensicMedicine,
    KnowledgeArea.biochemistry => ReviewSubjectKind.biochemistry,
    KnowledgeArea.histology => ReviewSubjectKind.histology,
    KnowledgeArea.toxicology ||
    KnowledgeArea.emergingIssues => ReviewSubjectKind.claim,
    KnowledgeArea.laboratory ||
    KnowledgeArea.methods => ReviewSubjectKind.method,
    KnowledgeArea.reagents => ReviewSubjectKind.reagent,
    KnowledgeArea.screening => ReviewSubjectKind.screeningTest,
    KnowledgeArea.jurisdiction => ReviewSubjectKind.legal,
    KnowledgeArea.education => ReviewSubjectKind.reference,
  },
};
