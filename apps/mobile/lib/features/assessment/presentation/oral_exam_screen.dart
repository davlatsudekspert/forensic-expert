import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/assessment.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/assessment/assessment_models.dart';
import '../../../domain/assessment/oral_exam.dart';
import 'assessment_screens.dart';
import 'oral_ticket_card.dart';

/// Og‘zaki imtihon: 5 savollik bilet, har savolga 0–20 ball, jami 100.
/// Ball qo‘yuvchi (ustoz yoki mutaxassis) telefonni ushlab turadi; natijalar
/// faqat qurilmada saqlanadi.
class AssessmentOralExamScreen extends ConsumerStatefulWidget {
  const AssessmentOralExamScreen({
    super.key,
    required this.specialtyId,
    required this.categoryId,
  });

  final String specialtyId;
  final String categoryId;

  @override
  ConsumerState<AssessmentOralExamScreen> createState() =>
      _AssessmentOralExamScreenState();
}

class _AssessmentOralExamScreenState
    extends ConsumerState<AssessmentOralExamScreen> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  AssessmentCategory? _category(AssessmentSpecialty? spec) {
    if (spec == null) return null;
    return spec.category(widget.categoryId) ??
        (spec.categories.isEmpty ? null : spec.categories.first);
  }

  Future<void> _draw(AssessmentCategory cat) async {
    _name.clear();
    await ref.read(oralExamProvider.notifier).draw(widget.specialtyId, cat.id, [
      for (final q in cat.questions) q.id,
    ]);
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final total = await ref.read(oralExamProvider.notifier).finish();
    if (!mounted || total == null) return;
    _name.clear();
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.oralExamSaved(total))));
  }

  Future<void> _clearHistory() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.oralExamHistoryClear),
        content: Text(l.oralExamHistoryClearBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l.oralExamCancel),
          ),
          FilledButton(
            key: const Key('oral.clearConfirm'),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l.oralExamHistoryClear),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(oralExamProvider.notifier).clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final spec = ref
        .watch(assessmentProvider)
        .value
        ?.specialty(widget.specialtyId);
    final cat = _category(spec);
    final title = assessmentSpecTitle(l, widget.specialtyId);
    final st = ref.watch(oralExamProvider);
    final answers = ref.watch(oralAnswersProvider(widget.specialtyId)).value;
    if (spec == null || cat == null || cat.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: FeAppBarTitle(l.oralExamTitle)),
        body: SafeArea(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              FeContentFrame(
                child: FeEmptyState(
                  icon: Icons.quiz_outlined,
                  body: l.assessmentEmpty,
                ),
              ),
            ],
          ),
        ),
      );
    }
    final here = st.spec == spec.id && st.cat == cat.id;
    final ticket = here && st.hasTicket;
    final byId = {for (final q in cat.questions) q.id: q};
    final poolIds = [for (final q in cat.questions) q.id];
    // Nusxa: saqlangan to‘plamga tegilmaydi.
    final used = {
      for (final x in st.data.usedFor(spec.id, cat.id))
        if (byId.containsKey(x)) x,
    };
    final history = [
      for (final r in st.data.history)
        if (r.spec == spec.id && r.cat == cat.id) r,
    ];
    final number = history.length + 1;
    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.oralExamTitle)),
      body: SafeArea(
        child: ListView(
          key: Key('oral.list.${spec.id}.${cat.id}'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  Text(
                    '$title · ${assessmentCatTitle(l, cat.id)}',
                    style: t.labelLarge?.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: FeSpace.xs),
                  Text(
                    l.oralExamPool(used.length, poolIds.length),
                    key: const Key('oral.pool'),
                    style: t.labelMedium?.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: FeSpace.sm),
                  if (!ticket)
                    FilledButton.icon(
                      key: const Key('oral.draw'),
                      onPressed: () => _draw(cat),
                      icon: const Icon(Icons.confirmation_number_outlined),
                      label: Text(l.oralExamNext),
                    )
                  else ...[
                    Text(l.oralExamTicketNo(number), style: t.titleLarge),
                    if (st.poolReset)
                      Padding(
                        padding: const EdgeInsets.only(top: FeSpace.xxs),
                        child: Text(
                          l.oralExamPoolReset,
                          key: const Key('oral.poolReset'),
                          style: t.bodySmall?.copyWith(color: c.textSecondary),
                        ),
                      ),
                    const SizedBox(height: FeSpace.xs),
                    TextField(
                      key: const Key('oral.name'),
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        hintText: l.oralExamName,
                      ),
                      onChanged: ref.read(oralExamProvider.notifier).setName,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    for (var i = 0; i < st.questionIds.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: FeSpace.sm),
                        child: _TicketQuestion(
                          index: i,
                          question: byId[st.questionIds[i]],
                          score: st.scores[i],
                          answer: answers?.answers[st.questionIds[i]],
                        ),
                      ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.oralExamTotal(st.total),
                            key: const Key('oral.total'),
                            style: t.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: FeSpace.xs),
                    FilledButton.icon(
                      key: const Key('oral.save'),
                      onPressed: st.allScored ? _save : null,
                      icon: const Icon(Icons.check),
                      label: Text(l.oralExamSave),
                    ),
                    if (!st.allScored)
                      Padding(
                        padding: const EdgeInsets.only(top: FeSpace.xxs),
                        child: Text(
                          l.oralExamSaveHint,
                          style: t.bodySmall?.copyWith(color: c.textSecondary),
                        ),
                      ),
                  ],
                  FeSectionHeader(l.oralExamHistory),
                  if (history.isEmpty)
                    Text(
                      l.oralExamHistoryEmpty,
                      key: const Key('oral.historyEmpty'),
                      style: t.bodyMedium?.copyWith(color: c.textSecondary),
                    ),
                  for (final r in history.take(20))
                    ListTile(
                      key: Key('oral.history.${r.atMs}'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(r.name.isEmpty ? l.oralExamNoName : r.name),
                      subtitle: Text(_date(r.atMs)),
                      trailing: Text(
                        '${r.total} / $oralExamMaxTotal',
                        style: t.titleMedium,
                      ),
                    ),
                  const SizedBox(height: FeSpace.sm),
                  Wrap(
                    spacing: FeSpace.xs,
                    runSpacing: FeSpace.xs,
                    children: [
                      OutlinedButton(
                        key: const Key('oral.resetPool'),
                        onPressed: used.isEmpty
                            ? null
                            : () => ref
                                  .read(oralExamProvider.notifier)
                                  .resetPool(spec.id, cat.id),
                        child: Text(l.oralExamResetPool),
                      ),
                      if (history.isNotEmpty)
                        OutlinedButton(
                          key: const Key('oral.clearHistory'),
                          onPressed: _clearHistory,
                          child: Text(l.oralExamHistoryClear),
                        ),
                    ],
                  ),
                  const SizedBox(height: FeSpace.sm),
                  Text(
                    l.oralExamDeviceNote,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                  const SizedBox(height: FeSpace.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _date(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}

class _TicketQuestion extends ConsumerWidget {
  const _TicketQuestion({
    required this.index,
    required this.question,
    required this.score,
    required this.answer,
  });

  final int index;
  final AssessmentQuestion? question;
  final int? score;
  final OralAnswer? answer;

  @override
  Widget build(BuildContext context, WidgetRef ref) => OralTicketQuestionCard(
    index: index,
    text: question?.text ?? '',
    sourceNote: switch (question?.textSource) {
      AssessmentTextSource.official => AppLocalizations.of(
        context,
      ).trStatusOfficial,
      AssessmentTextSource.machine => AppLocalizations.of(
        context,
      ).trStatusMachineDraft,
      _ => null,
    },
    score: score,
    onScore: (v) => ref.read(oralExamProvider.notifier).setScore(index, v),
    answerKey: OralAnswerView(answer: answer),
  );
}
