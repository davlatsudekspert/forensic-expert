import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/moderation.dart';
import '../../../app/qa.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/moderation/moderation_models.dart';
import '../../../domain/qa/qa_models.dart';
import '../../moderation/presentation/moderation_widgets.dart';
import '../qa_strings.dart';
import 'qa_widgets.dart';

/// Bitta savol: matn, javoblar, ovoz berish, eng yaxshi javob, shikoyat.
class QaQuestionScreen extends ConsumerStatefulWidget {
  const QaQuestionScreen({super.key, required this.questionId});

  final String questionId;

  @override
  ConsumerState<QaQuestionScreen> createState() => _QaQuestionScreenState();
}

class _QaQuestionScreenState extends ConsumerState<QaQuestionScreen> {
  final _answer = TextEditingController();
  bool _sending = false;
  QaPostResult? _answerResult;
  String? _message;

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  void _say(String text) => setState(() => _message = text);

  Future<void> _sendAnswer() async {
    final l = AppLocalizations.of(context);
    // Birinchi yozishdan oldin hamjamiyat qoidalari qabul qilinadi.
    if (!await ensureCommunityTerms(context, ref)) return;
    if (!mounted) return;
    setState(() {
      _sending = true;
      _message = null;
      _answerResult = null;
    });
    final out = await ref
        .read(qaServiceProvider)
        .answer(
          questionId: widget.questionId,
          lang: QaLang.fromLocale(Localizations.localeOf(context).languageCode),
          body: _answer.text.trim(),
        );
    if (!mounted) return;
    setState(() {
      _sending = false;
      _answerResult = out;
      _message = out == null ? l.qaSendFailed : null;
      if (out != null) _answer.clear();
    });
    ref.invalidate(qaQuestionProvider(widget.questionId));
  }

  Future<void> _vote(QaAnswer answer, int value) async {
    final l = AppLocalizations.of(context);
    final next = answer.myVote == value ? 0 : value;
    final out = await ref.read(qaServiceProvider).vote(answer.id, next);
    if (!mounted) return;
    if (out == null) {
      _say(l.qaOnlyVerifiedMayVote);
      return;
    }
    ref.invalidate(qaQuestionProvider(widget.questionId));
  }

  Future<void> _accept(QaQuestion q, QaAnswer answer) async {
    final ok = await ref
        .read(qaServiceProvider)
        .accept(q.id, q.acceptedAnswerId == answer.id ? null : answer.id);
    if (!mounted) return;
    if (!ok) _say(AppLocalizations.of(context).qaSendFailed);
    ref.invalidate(qaQuestionProvider(widget.questionId));
  }

  Future<void> _report(QaTargetType target, String id) async {
    final l = AppLocalizations.of(context);
    final reason = await showDialog<String>(
      context: context,
      builder: (c) => _ReportDialog(hint: l.qaReportReasonHint, send: l.qaSend),
    );
    if (reason == null || reason.trim().isEmpty) return;
    final out = await ref
        .read(qaServiceProvider)
        .report(target: target, id: id, reason: reason.trim());
    if (!mounted) return;
    _say(
      out == null
          ? l.qaSendFailed
          : (out.hidden ? l.qaReportHidden : l.qaReportSent),
    );
    ref.invalidate(qaQuestionProvider(widget.questionId));
  }

  /// Post muallifini bloklash: kimligi mijozga hech qachon kelmaydi; bloklangan
  /// muallifning savol/javoblari ko‘rinmaydi (server filtri).
  Future<void> _block(QaTargetType target, String id) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.blkConfirmTitle),
        content: Text(l.blkConfirmBody),
        actions: [
          TextButton(
            key: const Key('qa.block.cancel'),
            onPressed: () => Navigator.pop(c, false),
            child: Text(l.admxCancel),
          ),
          FilledButton(
            key: const Key('qa.block.confirm'),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l.blkAction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final out = await ref
        .read(moderationServiceProvider)
        .blockAuthor(
          target == QaTargetType.question
              ? ReportTarget.qaQuestion
              : ReportTarget.qaAnswer,
          id,
        );
    if (!mounted) return;
    _say(switch (out) {
      BlockResult.blocked => l.blkDone,
      BlockResult.already => l.blkAlready,
      BlockResult.self => l.blkSelf,
      _ => l.blkFailed,
    });
    if (out.ok) {
      ref.invalidate(qaFeedProvider);
      ref.invalidate(myBlocksProvider);
      if (target == QaTargetType.question) {
        if (!mounted) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(Routes.qa);
        }
      } else {
        ref.invalidate(qaQuestionProvider(widget.questionId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final me = ref.watch(qaMeProvider).value;
    final async = ref.watch(qaQuestionProvider(widget.questionId));
    return QaGate(
      title: l.qaTitle,
      child: Scaffold(
        appBar: AppBar(title: Text(l.qaTitle)),
        body: SafeArea(
          child: switch (async) {
            AsyncData(value: final q?) => _body(context, l, q, me),
            AsyncData() || AsyncError() => FeEmptyState(
              key: const Key('qa.question.notFound'),
              icon: Icons.cloud_off_outlined,
              body: l.qaLoadFailed,
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l,
    QaQuestion q,
    QaMe? me,
  ) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      key: const Key('qa.question'),
      children: [
        FeContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: FeSpace.sm),
              const QaNotice(),
              const SizedBox(height: FeSpace.sm),
              FeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: FeSpace.xxs,
                      runSpacing: FeSpace.xxs,
                      children: [
                        if (q.pinned)
                          StatusChip(
                            icon: Icons.push_pin_outlined,
                            label: l.qaPinned,
                            color: c.accent,
                          ),
                        if (q.status != QaPostStatus.published)
                          QaPostStatusChip(q.status),
                      ],
                    ),
                    const SizedBox(height: FeSpace.xxs),
                    QaTranslatableText(
                      target: QaTargetType.question,
                      id: q.id,
                      postLang: q.lang,
                      title: q.title,
                      body: q.body,
                    ),
                    const SizedBox(height: FeSpace.xs),
                    Wrap(
                      spacing: FeSpace.xs,
                      runSpacing: FeSpace.xxs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        QaAuthorBadge(q.authorRole),
                        if (q.createdAt case final date?)
                          Text(
                            feDate(context, date),
                            style: t.labelSmall?.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                        for (final tag in q.tags)
                          Text(
                            '#${l.qaTag(tag)}',
                            style: t.labelSmall?.copyWith(color: c.accent),
                          ),
                        if (!q.isMine)
                          TextButton.icon(
                            key: const Key('qa.question.report'),
                            onPressed: () =>
                                _report(QaTargetType.question, q.id),
                            icon: const Icon(Icons.flag_outlined, size: 18),
                            label: Text(l.qaReport),
                          ),
                        if (!q.isMine && ref.watch(reportAvailableProvider))
                          TextButton.icon(
                            key: const Key('qa.question.block'),
                            onPressed: () =>
                                _block(QaTargetType.question, q.id),
                            icon: const Icon(Icons.block, size: 18),
                            label: Text(l.blkAction),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FeSpace.md),
              FeSectionHeader(l.qaAnswersCount(q.answers.length)),
              if (q.answers.isEmpty)
                FeEmptyState(
                  key: const Key('qa.noAnswers'),
                  icon: Icons.question_answer_outlined,
                  body: l.qaNoAnswers,
                ),
              for (final a in q.answers) ...[
                _AnswerCard(
                  answer: a,
                  question: q,
                  canVote: me?.canAnswer ?? false,
                  onVote: (value) => _vote(a, value),
                  onAccept: () => _accept(q, a),
                  onReport: () => _report(QaTargetType.answer, a.id),
                  onBlock: ref.watch(reportAvailableProvider)
                      ? () => _block(QaTargetType.answer, a.id)
                      : null,
                ),
                const SizedBox(height: FeSpace.xs),
              ],
              const SizedBox(height: FeSpace.md),
              if (me?.canAnswer ?? false) ...[
                const QaPrivacyWarning(),
                const SizedBox(height: FeSpace.xs),
                TextField(
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  key: const Key('qa.answer.body'),
                  controller: _answer,
                  minLines: 3,
                  maxLines: 8,
                  maxLength: 4000,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: l.qaAnswerHint,
                    alignLabelWithHint: true,
                  ),
                ),
                FilledButton(
                  key: const Key('qa.answer.send'),
                  onPressed: _answer.text.trim().length >= 30 && !_sending
                      ? _sendAnswer
                      : null,
                  child: Text(l.qaSend),
                ),
              ] else
                FeBanner(
                  key: const Key('qa.answer.locked'),
                  icon: Icons.lock_outline,
                  tone: FeBannerTone.info,
                  text: l.qaOnlyVerifiedMayAnswer,
                ),
              if (_answerResult?.held ?? false) ...[
                const SizedBox(height: FeSpace.sm),
                QaFlagsNotice(_answerResult!.flags),
              ],
              if (_message != null) ...[
                const SizedBox(height: FeSpace.sm),
                Text(_message!, key: const Key('qa.question.message')),
              ],
              const SizedBox(height: FeSpace.xxl),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.answer,
    required this.question,
    required this.canVote,
    required this.onVote,
    required this.onAccept,
    required this.onReport,
    this.onBlock,
  });

  final QaAnswer answer;
  final QaQuestion question;
  final bool canVote;
  final ValueChanged<int> onVote;
  final VoidCallback onAccept;
  final VoidCallback onReport;
  final VoidCallback? onBlock;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: Key('qa.answer.${answer.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (answer.accepted)
            StatusChip(
              icon: Icons.verified_outlined,
              label: l.qaAcceptedAnswer,
              color: c.verified,
            ),
          if (answer.accepted) const SizedBox(height: FeSpace.xxs),
          QaTranslatableText(
            target: QaTargetType.answer,
            id: answer.id,
            postLang: answer.lang,
            title: null,
            body: answer.body,
          ),
          const SizedBox(height: FeSpace.xs),
          Wrap(
            spacing: FeSpace.xs,
            runSpacing: FeSpace.xxs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              QaAuthorBadge(answer.authorRole),
              Text(
                l.qaScore(answer.score),
                style: t.labelSmall?.copyWith(color: c.textSecondary),
              ),
              if (canVote && !answer.isMine) ...[
                IconButton(
                  key: Key('qa.upvote.${answer.id}'),
                  tooltip: l.qaUpvote,
                  isSelected: answer.myVote == 1,
                  icon: const Icon(Icons.thumb_up_outlined),
                  onPressed: () => onVote(1),
                ),
                IconButton(
                  key: Key('qa.downvote.${answer.id}'),
                  tooltip: l.qaDownvote,
                  isSelected: answer.myVote == -1,
                  icon: const Icon(Icons.thumb_down_outlined),
                  onPressed: () => onVote(-1),
                ),
              ],
              if (question.isMine)
                TextButton(
                  key: Key('qa.accept.${answer.id}'),
                  onPressed: onAccept,
                  child: Text(answer.accepted ? l.qaUnmarkBest : l.qaMarkBest),
                ),
              if (!answer.isMine)
                TextButton.icon(
                  key: Key('qa.report.${answer.id}'),
                  onPressed: onReport,
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: Text(l.qaReport),
                ),
              if (!answer.isMine && onBlock != null)
                TextButton.icon(
                  key: Key('qa.block.${answer.id}'),
                  onPressed: onBlock,
                  icon: const Icon(Icons.block, size: 18),
                  label: Text(l.blkAction),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog({required this.hint, required this.send});

  final String hint;
  final String send;

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    content: TextField(
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      key: const Key('qa.report.reason'),
      controller: _reason,
      autofocus: true,
      maxLength: 400,
      decoration: InputDecoration(labelText: widget.hint),
    ),
    actions: [
      TextButton(
        key: const Key('qa.report.cancel'),
        onPressed: () => Navigator.of(context).pop(),
        child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
      ),
      FilledButton(
        key: const Key('qa.report.send'),
        onPressed: () => Navigator.of(context).pop(_reason.text),
        child: Text(widget.send),
      ),
    ],
  );
}
