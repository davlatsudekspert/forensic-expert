import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;

import '../../../app/class_groups.dart' show groupHardestDetailProvider;
import '../../../app/class_quiz.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../domain/class_quiz/class_quiz_models.dart';
import '../../../domain/plan/plan_models.dart';
import '../../pro/presentation/pro_gate.dart';
import 'class_quiz_widgets.dart';

/// Muhokama ma’lumot manbai: «Sinfda test» (sessiya) yoki «Guruh testi»
/// (topshiriq) — ikkalasi ham bir xil [ClassHardDetail] ro‘yxatini beradi.
typedef ClassHardestSource =
    ProviderListenable<AsyncValue<ClassResult<List<ClassHardDetail>>>>;

/// «Qiyin savol» muhokama sahifasini ochadi (proyektor uchun to‘q mavzu).
/// [questionIndex] — dashboarddagi `hardest[i].index`.
Future<void> openClassHardestDiscussion(
  BuildContext context, {
  required String sessionId,
  required List<ClassHardQuestion> hardest,
  required int questionIndex,
}) => Navigator.of(context).push<void>(
  MaterialPageRoute<void>(
    fullscreenDialog: true,
    // Qiyin savollar muhokamasi — Ustoz Pro (ochilishi qulfli, ko‘rinadi).
    builder: (ctx) => ProGated(
      feature: ProFeature.hardestDiscussion,
      title: AppLocalizations.of(ctx).classHardestTitle,
      child: ClassHardestDiscussionScreen(
        sessionId: sessionId,
        hardest: hardest,
        initialQuestionIndex: questionIndex,
      ),
    ),
  ),
);

/// Guruh testi: yopilgan topshiriqning qiyin savollari muhokamasi
/// (`group_assignment_hardest_detail`). Ismlar ko‘rsatilmaydi.
Future<void> openGroupHardestDiscussion(
  BuildContext context, {
  required String assignmentId,
}) => Navigator.of(context).push<void>(
  MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (ctx) => ProGated(
      feature: ProFeature.hardestDiscussion,
      title: AppLocalizations.of(ctx).classHardestTitle,
      child: ClassHardestDiscussionScreen(
        sessionId: assignmentId,
        hardest: const [],
        initialQuestionIndex: 0,
        source: groupHardestDetailProvider(assignmentId),
      ),
    ),
  ),
);

/// Muhokama varaqasi: savol matni, 4 variant (to‘g‘risi belgilangan), xato
/// foizi, tushuntirish, manba (muallif, sarlavha, bet). Talaba ismlari
/// ko‘rsatilmaydi — faqat savol bo‘yicha jami. Katta ekranda yirik shrift.
class ClassHardestDiscussionScreen extends ConsumerStatefulWidget {
  const ClassHardestDiscussionScreen({
    super.key,
    required this.sessionId,
    required this.hardest,
    required this.initialQuestionIndex,
    this.source,
  });

  /// Sessiya (yoki guruh topshirig‘i) id si.
  final String sessionId;

  /// Ma’lumot manbai; berilmasa — «Sinfda test» sessiyasi.
  final ClassHardestSource? source;
  final List<ClassHardQuestion> hardest;
  final int initialQuestionIndex;

  @override
  ConsumerState<ClassHardestDiscussionScreen> createState() =>
      _ClassHardestDiscussionState();
}

class _ClassHardestDiscussionState
    extends ConsumerState<ClassHardestDiscussionScreen> {
  /// Hozirgi savolning `index`i (ro‘yxat o‘zgarsa ham joy saqlanadi).
  late int _current = widget.initialQuestionIndex;
  bool? _big;

  /// Tafsilot kelmasa — dashboard `hardest` ma’lumotlari (variantlarsiz).
  List<ClassHardDetail> _items(ClassResult<List<ClassHardDetail>>? r) {
    final d = r?.value;
    if (d != null && d.isNotEmpty) return d;
    return [
      for (final h in widget.hardest)
        ClassHardDetail(
          index: h.index,
          text: h.text,
          options: const [],
          correctIndex: -1,
          explanation: '',
          source: const ClassSource(),
          answered: h.answered,
          correctPct: h.correctPct,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final detail = ref.watch(
      widget.source ?? classHardestDetailProvider(widget.sessionId),
    );
    final result = detail.value;
    final items = _items(result);
    final hasDetail = result?.value?.isNotEmpty ?? false;
    var pos = items.indexWhere((x) => x.index == _current);
    if (pos < 0) pos = 0;
    final width = MediaQuery.sizeOf(context).width;
    final big = _big ?? width >= 900;
    final scale = !big
        ? 1.0
        : (width >= 1500 ? 1.6 : (width >= 900 ? 1.3 : 1.15));
    return Theme(
      data: FeThemeBuilder.dark(),
      child: Builder(
        builder: (context) {
          final t = Theme.of(context).textTheme;
          final c = FeTheme.of(context);
          TextStyle? sized(TextStyle? s, {FontWeight? w, Color? color}) =>
              s?.copyWith(
                fontSize: (s.fontSize ?? 14) * scale,
                fontWeight: w,
                color: color,
                height: 1.35,
              );
          Widget body;
          if (detail.isLoading && result == null) {
            body = const Center(child: CircularProgressIndicator());
          } else if (items.isEmpty) {
            body = Center(
              child: Padding(
                padding: const EdgeInsets.all(FeSpace.md),
                child: Text(l.classNoAnswersYet, style: sized(t.titleMedium)),
              ),
            );
          } else {
            final q = items[pos];
            body = ListView(
              key: const Key('class.discuss.scroll'),
              padding: const EdgeInsets.all(FeSpace.md),
              children: [
                FeContentFrame(
                  maxWidth: 1200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l.classDiscussPosition(pos + 1, items.length),
                              key: const Key('class.discuss.position'),
                              style: sized(
                                t.labelLarge,
                                color: c.textSecondary,
                              ),
                            ),
                          ),
                          _WrongChip(pct: q.wrongPct, scale: scale),
                        ],
                      ),
                      const SizedBox(height: FeSpace.xs),
                      Text(
                        l.classDiscussAnswered(q.answered),
                        key: const Key('class.discuss.answered'),
                        style: sized(t.bodyMedium, color: c.textSecondary),
                      ),
                      const SizedBox(height: FeSpace.sm),
                      Text(
                        q.text,
                        key: const Key('class.discuss.question'),
                        style: sized(t.headlineSmall, w: FontWeight.w700),
                      ),
                      const SizedBox(height: FeSpace.md),
                      if (!hasDetail || q.options.isEmpty)
                        Text(
                          l.classDiscussUnavailable,
                          key: const Key('class.discuss.unavailable'),
                          style: sized(t.bodyMedium, color: c.textSecondary),
                        )
                      else ...[
                        for (var i = 0; i < q.options.length; i++)
                          _OptionRow(
                            index: i,
                            text: q.options[i],
                            correct: i == q.correctIndex,
                            count: i < q.optionCounts.length
                                ? q.optionCounts[i]
                                : null,
                            scale: scale,
                          ),
                        const SizedBox(height: FeSpace.sm),
                        _Section(
                          title: l.classDiscussExplanation,
                          scale: scale,
                          child: Text(
                            q.explanation.isEmpty
                                ? l.classDiscussNoExplanation
                                : q.explanation,
                            key: const Key('class.discuss.explanation'),
                            style: sized(t.titleMedium),
                          ),
                        ),
                        if (!q.source.isEmpty) ...[
                          const SizedBox(height: FeSpace.sm),
                          // Satr o‘zi «Manba: …» bilan boshlanadi — alohida sarlavha yo‘q.
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                classSourceCitation(l, q.source),
                                key: const Key('class.discuss.source'),
                                style: sized(t.bodyLarge),
                              ),
                              if (q.source.isTranslationPending)
                                _Note(
                                  key: const Key('class.discuss.pending'),
                                  icon: Icons.hourglass_empty,
                                  text: l.classTranslationPending,
                                  scale: scale,
                                ),
                              if (q.source.isMachineTranslation)
                                _Note(
                                  icon: Icons.translate,
                                  text: l.trStatusMachineDraft,
                                  scale: scale,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            );
          }
          return Scaffold(
            key: const Key('class.discuss'),
            appBar: AppBar(
              title: Text(l.classDiscussTitle),
              leading: IconButton(
                key: const Key('class.discuss.close'),
                tooltip: l.classDiscussClose,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              actions: [
                Tooltip(
                  message: l.classDiscussBigFont,
                  child: const Icon(Icons.text_fields),
                ),
                Switch(
                  key: const Key('class.discuss.big'),
                  value: big,
                  onChanged: (v) => setState(() => _big = v),
                ),
                const SizedBox(width: FeSpace.xs),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(child: body),
                  if (items.length > 1)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        FeSpace.md,
                        FeSpace.xs,
                        FeSpace.md,
                        FeSpace.sm,
                      ),
                      child: FeContentFrame(
                        maxWidth: 1200,
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                key: const Key('class.discuss.prev'),
                                onPressed: pos > 0
                                    ? () => setState(
                                        () => _current = items[pos - 1].index,
                                      )
                                    : null,
                                icon: const Icon(Icons.chevron_left),
                                label: Text(
                                  l.classDiscussPrev,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                ),
                              ),
                            ),
                            const SizedBox(width: FeSpace.sm),
                            Expanded(
                              child: FilledButton.icon(
                                key: const Key('class.discuss.next'),
                                onPressed: pos < items.length - 1
                                    ? () => setState(
                                        () => _current = items[pos + 1].index,
                                      )
                                    : null,
                                icon: const Icon(Icons.chevron_right),
                                iconAlignment: IconAlignment.end,
                                label: Text(
                                  l.classDiscussNext,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WrongChip extends StatelessWidget {
  const _WrongChip({required this.pct, required this.scale});

  final int pct;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Container(
      key: const Key('class.discuss.wrongPct'),
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 4 * scale,
      ),
      decoration: BoxDecoration(
        color: c.danger.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.danger),
      ),
      child: Text(
        l.classDiscussWrongPct(pct),
        style: t.titleMedium?.copyWith(
          fontSize: (t.titleMedium?.fontSize ?? 16) * scale,
          color: c.danger,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.index,
    required this.text,
    required this.correct,
    required this.scale,
    this.count,
  });

  final int index;
  final String text;
  final bool correct;
  final int? count;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final base = t.titleLarge;
    final style = base?.copyWith(
      fontSize: (base.fontSize ?? 20) * scale,
      height: 1.3,
      fontWeight: correct ? FontWeight.w700 : null,
    );
    final color = correct ? c.verified : c.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: Semantics(
        label: correct
            ? '${classOptionLetter(index)}. $text. ${l.classDiscussCorrectMark}'
            : '${classOptionLetter(index)}. $text',
        excludeSemantics: true,
        child: Container(
          key: Key('class.discuss.option.$index'),
          padding: EdgeInsets.all(12 * scale),
          decoration: BoxDecoration(
            color: correct ? c.verified.withValues(alpha: 0.18) : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: correct ? 2 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                classOptionLetter(index),
                style: style?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text, style: style),
                    if (correct)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          key: Key('class.discuss.correct.$index'),
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 18 * scale,
                              color: c.verified,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                l.classDiscussCorrectMark,
                                style: t.labelLarge?.copyWith(
                                  fontSize:
                                      (t.labelLarge?.fontSize ?? 14) * scale,
                                  color: c.verified,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (count != null) ...[
                SizedBox(width: 12 * scale),
                Text(
                  count.toString(),
                  key: Key('class.discuss.count.$index'),
                  semanticsLabel: l.classDiscussPicked(count!),
                  style: style?.copyWith(color: c.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    required this.scale,
  });

  final String title;
  final Widget child;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: t.labelLarge?.copyWith(
            fontSize: (t.labelLarge?.fontSize ?? 14) * scale,
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({
    super.key,
    required this.icon,
    required this.text,
    required this.scale,
  });

  final IconData icon;
  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16 * scale, color: c.textSecondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: t.bodyMedium?.copyWith(
                fontSize: (t.bodyMedium?.fontSize ?? 14) * scale,
                color: c.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
