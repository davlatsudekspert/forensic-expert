import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/class_quiz.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_quiz/class_quiz_models.dart';
import 'class_quiz_widgets.dart';

/// Talaba ekrani: kutish zali → savollar → natija. Holat serverdan har ~2 s
/// polling bilan keladi; to‘g‘ri javob vaqt tugagach ochiladi.
///
/// Bitta so‘rov xato bo‘lsa (tarmoq/server), oxirgi yaxshi holat ekranda
/// qoladi va kichik «Aloqa tiklanmoqda» belgisi chiqadi; to‘liq xato ekrani
/// faqat hali birorta holat kelmagan bo‘lsa (yoki kirish huquqi yo‘q bo‘lsa).
class ClassPlayScreen extends ConsumerStatefulWidget {
  const ClassPlayScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<ClassPlayScreen> createState() => _ClassPlayScreenState();
}

class _ClassPlayScreenState extends ConsumerState<ClassPlayScreen> {
  ClassStudentState? _last;

  String get sessionId => widget.sessionId;

  void _exit(BuildContext context, WidgetRef ref) {
    ref.read(classActiveJoinProvider.notifier).set(null);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.classQuiz);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(classStudentStateProvider(sessionId));
    final result = async.value;
    final failure = result?.failure;
    final fresh = result?.value;
    if (fresh != null) _last = fresh;
    // Huquq yo‘q (sessiya o‘chirilgan / hisob chiqqan) — eski holat ko‘rsatilmaydi.
    final fatal =
        failure == ClassFailure.forbidden ||
        failure == ClassFailure.notSignedIn;
    final last = _last?.session.id == sessionId ? _last : null;
    final st = fresh ?? (fatal ? null : last);
    final reconnecting = fresh == null && st != null && failure != null;

    Widget body;
    if (st != null) {
      body = st.kicked
          ? _Message(
              key: const Key('class.kicked'),
              icon: Icons.person_off_outlined,
              text: l.classErrKicked,
              action: l.classExit,
              onAction: () => _exit(context, ref),
            )
          : switch (st.status) {
              ClassSessionStatus.lobby => _StudentLobby(st: st),
              ClassSessionStatus.running => _StudentQuestion(
                sessionId: sessionId,
                st: st,
              ),
              ClassSessionStatus.finished => _StudentFinished(
                sessionId: sessionId,
                st: st,
                onExit: () => _exit(context, ref),
              ),
            };
    } else if (failure != null) {
      body = _Message(
        key: const Key('class.playError'),
        icon: failure == ClassFailure.offline
            ? Icons.wifi_off
            : Icons.error_outline,
        text: classFailureText(l, failure),
        action: fatal ? l.classExit : l.classRetry,
        onAction: fatal
            ? () => _exit(context, ref)
            : () => ref.invalidate(classStudentStateProvider(sessionId)),
      );
    } else {
      body = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: FeAppBarTitle(st?.session.topicTitle ?? l.classQuizTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Aloqa uzildi, oxirgi holat bor — ekran saqlanadi, kichik belgi.
            if (reconnecting) const ClassReconnectingBar(),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    super.key,
    required this.icon,
    required this.text,
    required this.action,
    required this.onAction,
  });

  final IconData icon;
  final String text;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(FeSpace.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: FeTheme.of(context).textSecondary),
          const SizedBox(height: FeSpace.sm),
          Text(text, textAlign: TextAlign.center),
          const SizedBox(height: FeSpace.sm),
          OutlinedButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    ),
  );
}

class _StudentLobby extends StatelessWidget {
  const _StudentLobby({required this.st});

  final ClassStudentState st;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        FeContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: FeSpace.sm),
              const ClassDemoBanner(),
              FeCard(
                key: const Key('class.lobby'),
                child: Column(
                  children: [
                    const Icon(Icons.hourglass_top, size: 36),
                    const SizedBox(height: FeSpace.sm),
                    Text(
                      l.classLobbyWelcome(st.nickname),
                      key: const Key('class.lobbyNick'),
                      textAlign: TextAlign.center,
                      style: t.titleLarge,
                    ),
                    const SizedBox(height: FeSpace.xs),
                    Text(
                      l.classLobbyWait,
                      textAlign: TextAlign.center,
                      style: t.bodyMedium,
                    ),
                    const SizedBox(height: FeSpace.xs),
                    Text(
                      l.classJoinedCount(st.joined, st.session.studentLimit),
                      style: t.titleSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudentQuestion extends ConsumerStatefulWidget {
  const _StudentQuestion({required this.sessionId, required this.st});

  final String sessionId;
  final ClassStudentState st;

  @override
  ConsumerState<_StudentQuestion> createState() => _StudentQuestionState();
}

class _StudentQuestionState extends ConsumerState<_StudentQuestion> {
  String? _local;
  int? _localIndex;
  bool _busy = false;
  String? _pending;
  int? _pendingIndex;

  Future<void> _answer(ClassQuestionView q, String optionId) async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _local = optionId;
      _localIndex = q.index;
    });
    final r = await ref
        .read(classQuizServiceProvider)
        .submitAnswer(
          sessionId: widget.sessionId,
          questionIndex: q.index,
          optionId: optionId,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    if (!r.ok && r.failure != ClassFailure.alreadyAnswered) {
      setState(() {
        _local = null;
        _localIndex = null;
      });
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(classFailureText(l, r.failure!))),
        );
    }
    ref.invalidate(classStudentStateProvider(widget.sessionId));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final st = widget.st;
    final q = st.question;
    if (q == null) return const Center(child: CircularProgressIndicator());
    final submitted = st.myOption ?? (_localIndex == q.index ? _local : null);
    final selected = submitted ?? (_pendingIndex == q.index ? _pending : null);
    final open = st.phase == ClassPhase.open;
    final reveal = st.reveal;
    // Proyektor bilan bir xil (server) tartib: «B» ikkala ekranda bir variant.
    final order = q.options;

    ClassOptionState stateOf(String id) {
      if (reveal != null) {
        if (id == reveal.correctOption) return ClassOptionState.correct;
        if (id == selected) return ClassOptionState.wrong;
        return ClassOptionState.neutral;
      }
      return id == selected
          ? ClassOptionState.chosen
          : ClassOptionState.neutral;
    }

    final String status;
    if (reveal != null) {
      status = selected == null
          ? l.classResultNoAnswer
          : reveal.myCorrect
          ? l.classResultCorrect(reveal.myPoints)
          : l.classResultWrong;
    } else if (!open) {
      status = l.classTimeUpWaiting;
    } else if (submitted != null) {
      status = l.classAnswerAccepted;
    } else {
      status = l.classChooseAnswer;
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        FeContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: FeSpace.sm),
              const ClassDemoBanner(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.classQuestionOf(q.index + 1, st.session.total),
                      style: t.titleMedium?.copyWith(color: c.textSecondary),
                    ),
                  ),
                  ClassCountdown(
                    key: ValueKey('q${q.index}'),
                    remainingMs: st.remainingMs,
                    totalMs: st.session.seconds * 1000,
                    size: 56,
                  ),
                ],
              ),
              const SizedBox(height: FeSpace.xs),
              Text(
                q.text,
                key: const Key('class.question'),
                style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: FeSpace.md),
              for (var i = 0; i < order.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: FeSpace.xs),
                  child: ClassOptionTile(
                    key: Key('class.option.${order[i].id}'),
                    letter: classOptionLetter(i),
                    text: order[i].text,
                    state: stateOf(order[i].id),
                    onTap: open && submitted == null && !_busy
                        ? () => setState(() {
                            _pending = order[i].id;
                            _pendingIndex = q.index;
                          })
                        : null,
                  ),
                ),
              const SizedBox(height: FeSpace.xs),
              if (open && submitted == null)
                FilledButton(
                  key: const Key('class.confirm'),
                  onPressed: selected == null || _busy
                      ? null
                      : () => _answer(q, selected),
                  child: Text(l.verifySubmit),
                ),
              Semantics(
                liveRegion: true,
                child: Text(
                  status,
                  key: const Key('class.status'),
                  style: t.titleSmall?.copyWith(
                    color: reveal == null
                        ? c.textSecondary
                        : (reveal.myCorrect ? c.verified : c.danger),
                  ),
                ),
              ),
              if (reveal != null && reveal.explanation.isNotEmpty) ...[
                const SizedBox(height: FeSpace.xs),
                FeBanner(
                  key: const Key('class.explanation'),
                  icon: Icons.lightbulb_outline,
                  text: reveal.explanation,
                  tone: FeBannerTone.review,
                ),
              ],
              if (reveal != null) ...[
                const SizedBox(height: FeSpace.xs),
                Text(l.classWaitNext, style: t.bodySmall),
              ],
              const SizedBox(height: FeSpace.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      st.nickname,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodyMedium,
                    ),
                  ),
                  // Ball faqat natija ochilgach (savol ochiq turganda ko‘rsatilmaydi).
                  if (reveal != null)
                    Text(
                      l.classScoreLine(st.score),
                      key: const Key('class.score'),
                      style: t.titleSmall,
                    ),
                ],
              ),
              const SizedBox(height: FeSpace.lg),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudentFinished extends ConsumerWidget {
  const _StudentFinished({
    required this.sessionId,
    required this.st,
    required this.onExit,
  });

  final String sessionId;
  final ClassStudentState st;
  final VoidCallback onExit;

  Future<void> _report(
    BuildContext context,
    WidgetRef ref,
    ClassLeaderRow row,
  ) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.classReportTitle),
        content: Text(l.classReportBody(row.nickname)),
        actions: [
          TextButton(onPressed: () => c.pop(false), child: Text(l.classCancel)),
          FilledButton(
            key: const Key('class.reportConfirm'),
            onPressed: () => c.pop(true),
            child: Text(l.classReportAction),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final r = await ref
        .read(classQuizServiceProvider)
        .reportNickname(
          sessionId: sessionId,
          participantId: row.participantId,
          reason: l.classReportReason,
        );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            r.ok ? l.classReportSent : classFailureText(l, r.failure!),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final results = ref.watch(classMyResultsProvider(sessionId)).value?.value;
    final mistakes = results?.mistakes ?? const <ClassResultItem>[];
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        FeContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: FeSpace.sm),
              const ClassDemoBanner(),
              FeCard(
                key: const Key('class.summary'),
                child: Column(
                  children: [
                    Text(l.classFinishedTitle, style: t.titleLarge),
                    const SizedBox(height: FeSpace.xs),
                    Text(
                      l.classScoreLine(st.score),
                      key: const Key('class.finalScore'),
                      style: t.headlineMedium?.copyWith(
                        color: c.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (st.rank != null)
                      Text(
                        l.classRankLine(st.rank!, st.joined),
                        key: const Key('class.finalRank'),
                        style: t.titleSmall,
                      ),
                    if (results != null)
                      Text(
                        l.classCorrectOfTotal(results.correct, results.total),
                        key: const Key('class.finalCorrect'),
                        style: t.bodyMedium,
                      ),
                  ],
                ),
              ),
              FeSectionHeader(l.classTopFive),
              FeCard(
                key: const Key('class.topBoard'),
                child: Column(
                  children: [
                    for (final r in st.leaderboard)
                      Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(r.rank.toString(), style: t.titleSmall),
                          ),
                          Expanded(
                            child: Text(
                              r.nickname,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(r.score.toString(), style: t.titleSmall),
                          if (r.nickname != st.nickname)
                            IconButton(
                              tooltip: l.classReportAction,
                              icon: const Icon(Icons.flag_outlined, size: 20),
                              onPressed: () => _report(context, ref, r),
                            )
                          else
                            const SizedBox(width: FeTouch.minTarget),
                        ],
                      ),
                  ],
                ),
              ),
              FeSectionHeader(l.classMistakesTitle),
              if (results == null)
                const Center(child: CircularProgressIndicator())
              else if (mistakes.isEmpty)
                FeBanner(
                  key: const Key('class.noMistakes'),
                  icon: Icons.verified_outlined,
                  text: l.classNoMistakes,
                  tone: FeBannerTone.review,
                )
              else
                for (final m in mistakes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: FeSpace.sm),
                    child: ClassMistakeCard(item: m),
                  ),
              const SizedBox(height: FeSpace.md),
              FilledButton(
                key: const Key('class.exitButton'),
                onPressed: onExit,
                child: Text(l.classExit),
              ),
              const SizedBox(height: FeSpace.xl),
            ],
          ),
        ),
      ],
    );
  }
}

class ClassMistakeCard extends StatelessWidget {
  const ClassMistakeCard({super.key, required this.item});

  final ClassResultItem item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    String textOf(String? id) =>
        item.options.where((o) => o.id == id).firstOrNull?.text ?? '';
    final src = item.source;
    // Bet bo‘sh («-», «--») bo‘lsa — betsiz; «I bob, 1.4» kabi joy — «-bet»
    // qo‘shilmaydi.
    final page = src.cleanPage;
    final cite = src.isEmpty
        ? null
        : page == null
        ? l.classSourceLineNoPage(src.author, src.title)
        : src.pageIsNumeric
        ? l.classSourceLine(src.author, src.title, page)
        : l.classSourceLineLocator(src.author, src.title, page);
    return FeCard(
      key: Key('class.mistake.${item.index}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.classQuestionNumber(item.index + 1),
            style: t.labelMedium?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: FeSpace.xxs),
          Text(item.text, style: t.titleSmall),
          const SizedBox(height: FeSpace.xs),
          Text(
            item.unanswered
                ? l.classResultNoAnswer
                : l.classYourAnswer(textOf(item.myOption)),
            style: t.bodyMedium?.copyWith(color: c.danger),
          ),
          Text(
            l.classCorrectAnswer(textOf(item.correctOption)),
            style: t.bodyMedium?.copyWith(
              color: c.verified,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (item.explanation.isNotEmpty) ...[
            const SizedBox(height: FeSpace.xs),
            Text(item.explanation, style: t.bodyMedium),
          ],
          if (cite != null) ...[
            const SizedBox(height: FeSpace.xs),
            Text(
              cite,
              key: Key('class.source.${item.index}'),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ],
          if (src.checked) ...[
            const SizedBox(height: 2),
            Row(
              key: Key('class.sourceChecked.${item.index}'),
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 14,
                  color: c.textSecondary,
                ),
                const SizedBox(width: FeSpace.xxs),
                Flexible(
                  child: Text(
                    l.classSourceChecked,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
          ],
          if (src.isTranslationPending) ...[
            const SizedBox(height: 2),
            Row(
              key: Key('class.translationPending.${item.index}'),
              children: [
                Icon(Icons.hourglass_empty, size: 14, color: c.textSecondary),
                const SizedBox(width: FeSpace.xxs),
                Flexible(
                  child: Text(
                    l.classTranslationPending,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
          ],
          if (src.isMachineTranslation) ...[
            const SizedBox(height: 2),
            Row(
              key: Key('class.machineTranslation.${item.index}'),
              children: [
                Icon(Icons.translate, size: 14, color: c.textSecondary),
                const SizedBox(width: FeSpace.xxs),
                Flexible(
                  child: Text(
                    l.trStatusMachineDraft,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
