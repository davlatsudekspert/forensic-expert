import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_groups/class_groups_models.dart';
import '../../../domain/class_groups/variant_draw.dart';

/// Topshirish sozlamalari (mavzu testi va «Umumiy test» uchun bitta shakl).
///
/// «Vaqt chegarasi» (talaba boshlagandan hisoblanadi) va «Test qancha vaqt
/// ochiq turadi» (boshlash mumkin bo‘lgan davr) — ATAYLAB alohida bo‘limlar.
@immutable
class TestSettings {
  const TestSettings({
    this.count = 10,
    this.timeLimit = GroupRules.defaultTimeLimit,
    this.openDays = GroupRules.defaultOpenDays,
    this.openUntil,
    this.variant = true,
    this.reveal = RevealPolicy.afterDue,
  });

  final int count;

  /// Daqiqa; `null` — vaqtsiz.
  final int? timeLimit;

  /// 1/3/7 kun; [openUntil] berilsa — e’tiborsiz.
  final int openDays;
  final DateTime? openUntil;
  final bool variant;
  final RevealPolicy reveal;

  DateTime dueAt(DateTime now) =>
      openUntil ?? now.add(Duration(days: openDays));

  TestSettings copyWith({
    int? count,
    int? Function()? timeLimit,
    int? openDays,
    DateTime? Function()? openUntil,
    bool? variant,
    RevealPolicy? reveal,
  }) => TestSettings(
    count: count ?? this.count,
    timeLimit: timeLimit == null ? this.timeLimit : timeLimit(),
    openDays: openDays ?? this.openDays,
    openUntil: openUntil == null ? this.openUntil : openUntil(),
    variant: variant ?? this.variant,
    reveal: reveal ?? this.reveal,
  );

  AssignmentDraft draft({
    required String topicId,
    required int poolSize,
    required DateTime now,
    List<String>? topics,
    String? title,
  }) => AssignmentDraft(
    topicId: topicId,
    topics: topics,
    title: title,
    questionCount: count,
    timeLimitMin: timeLimit,
    dueAt: dueAt(now),
    variantMode: variant && variantAllowed(poolSize, count),
    reveal: reveal,
  );
}

/// Butun son so‘rash oynasi («Boshqa…»).
Future<int?> askNumber(
  BuildContext context, {
  required String title,
  required String hint,
  required int min,
  required int max,
}) => showDialog<int>(
  context: context,
  builder: (ctx) => _NumberDialog(title: title, hint: hint, min: min, max: max),
);

/// Controller oynaning o‘zida — yopilish animatsiyasi tugaguncha yashaydi.
class _NumberDialog extends StatefulWidget {
  const _NumberDialog({
    required this.title,
    required this.hint,
    required this.min,
    required this.max,
  });

  final String title;
  final String hint;
  final int min;
  final int max;

  @override
  State<_NumberDialog> createState() => _NumberDialogState();
}

class _NumberDialogState extends State<_NumberDialog> {
  final _c = TextEditingController();
  bool _bad = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _done() {
    final n = int.tryParse(_c.text.trim());
    if (n != null && n >= widget.min && n <= widget.max) {
      context.pop(n);
    } else {
      setState(() => _bad = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const Key('grp.customField'),
        controller: _c,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        onSubmitted: (_) => _done(),
        decoration: InputDecoration(
          helperText: widget.hint,
          helperMaxLines: 3,
          errorText: _bad ? widget.hint : null,
          errorMaxLines: 3,
        ),
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: Text(l.grpCancel)),
        FilledButton(
          key: const Key('grp.customOk'),
          onPressed: _done,
          child: Text(l.grpOk),
        ),
      ],
    );
  }
}

/// Sozlamalar bo‘limlari: savollar soni, vaqt chegarasi, ochiq turish
/// muddati, variant, javoblar qachon ochilishi.
class TestSettingsSection extends StatelessWidget {
  const TestSettingsSection({
    super.key,
    required this.value,
    required this.poolSize,
    required this.countPresets,
    required this.onChanged,
    required this.now,
    this.simple = false,
  });

  /// Dars oxiridagi guruh testi: faqat savol soni (tez tanlov), vaqt chegarasi
  /// va ochiq turish muddati; «Boshqa…» son, variant va javoblarni ochish
  /// bo‘limlari yo‘q (standartlar [TestSettings] da).
  final bool simple;

  final TestSettings value;
  final int poolSize;
  final List<int> countPresets;
  final ValueChanged<TestSettings> onChanged;
  final DateTime Function() now;

  Widget _hint(BuildContext context, String text, {Key? key}) => Padding(
    padding: const EdgeInsets.only(top: FeSpace.xxs),
    child: Text(
      text,
      key: key,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: FeTheme.of(context).textSecondary),
    ),
  );

  Future<void> _pickDate(BuildContext context) async {
    final n = now();
    final base = value.openUntil ?? n.add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: n,
      lastDate: n.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null) return;
    onChanged(
      value.copyWith(
        openUntil: () =>
            DateTime(date.year, date.month, date.day, time.hour, time.minute),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final maxCount = min(poolSize, GroupRules.maxQuestions);
    final presets = [
      for (final p in countPresets)
        if (p <= poolSize && p <= GroupRules.presetMaxQuestions) p,
    ];
    final canVariant = variantAllowed(poolSize, value.count);
    final customCount =
        !simple && !presets.contains(value.count) && value.count != maxCount;
    // Soddalashtirilgan: «Hammasi · N» faqat mavzu eng katta tez tanlovdan
    // kichik bo‘lsa (masalan 7 ta savol: «Hammasi · 7»).
    final showAll =
        maxCount > 0 &&
        (!simple ||
            (!presets.contains(maxCount) &&
                (countPresets.isEmpty || maxCount < countPresets.last)));
    final customTime =
        value.timeLimit != null &&
        !GroupRules.timeLimitPresets.contains(value.timeLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(l.grpCountSection),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            for (final p in presets)
              ChoiceChip(
                key: Key('grp.count.$p'),
                label: Text(p.toString()),
                selected: value.count == p,
                onSelected: (_) => onChanged(value.copyWith(count: p)),
              ),
            if (showAll)
              ChoiceChip(
                key: const Key('grp.count.all'),
                label: Text(
                  simple
                      ? l.classQuestionCountAll(maxCount)
                      : poolSize > maxCount
                      ? l.grpCountMax(maxCount)
                      : l.grpCountAll(maxCount),
                ),
                selected:
                    value.count == maxCount && !presets.contains(maxCount),
                onSelected: (_) => onChanged(value.copyWith(count: maxCount)),
              ),
            if (!simple)
              ChoiceChip(
                key: const Key('grp.count.custom'),
                label: Text(
                  customCount ? l.grpCustomValue(value.count) : l.grpCustom,
                ),
                selected: customCount,
                onSelected: (_) async {
                  final n = await askNumber(
                    context,
                    title: l.grpCountSection,
                    hint: l.grpCountCustomHint(maxCount),
                    min: 1,
                    max: max(1, maxCount),
                  );
                  if (n != null) onChanged(value.copyWith(count: n));
                },
              ),
          ],
        ),
        _hint(
          context,
          l.grpCountHint(value.count, poolSize),
          key: const Key('grp.countHint'),
        ),
        FeSectionHeader(l.grpTimeLimitLabel),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            for (final m in GroupRules.timeLimitPresets)
              ChoiceChip(
                key: Key('grp.time.$m'),
                label: Text(l.grpMinutesN(m)),
                selected: value.timeLimit == m,
                onSelected: (_) =>
                    onChanged(value.copyWith(timeLimit: () => m)),
              ),
            ChoiceChip(
              key: const Key('grp.time.none'),
              label: Text(l.grpNoTimeLimitShort),
              selected: value.timeLimit == null,
              onSelected: (_) =>
                  onChanged(value.copyWith(timeLimit: () => null)),
            ),
            ChoiceChip(
              key: const Key('grp.time.custom'),
              label: Text(
                customTime ? l.grpMinutesN(value.timeLimit!) : l.grpCustom,
              ),
              selected: customTime,
              onSelected: (_) async {
                final n = await askNumber(
                  context,
                  title: l.grpTimeLimitLabel,
                  hint: l.grpTimeCustomHint,
                  min: GroupRules.minTimeLimit,
                  max: GroupRules.maxTimeLimit,
                );
                if (n != null) onChanged(value.copyWith(timeLimit: () => n));
              },
            ),
          ],
        ),
        _hint(context, l.grpTimeLimitHint, key: const Key('grp.timeHint')),
        FeSectionHeader(l.grpOpenSection),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            for (final d in GroupRules.openDaysPresets)
              ChoiceChip(
                key: Key('grp.open.$d'),
                label: Text(l.grpDaysN(d)),
                selected: value.openUntil == null && value.openDays == d,
                onSelected: (_) => onChanged(
                  value.copyWith(openDays: d, openUntil: () => null),
                ),
              ),
            ChoiceChip(
              key: const Key('grp.open.date'),
              label: Text(
                value.openUntil == null
                    ? l.grpPickDate
                    : feDueShort(context, value.openUntil!),
              ),
              selected: value.openUntil != null,
              onSelected: (_) => _pickDate(context),
            ),
          ],
        ),
        _hint(
          context,
          l.grpOpenHint(feDueShort(context, value.dueAt(now()))),
          key: const Key('grp.openHint'),
        ),
        if (!simple) ..._advanced(context, l, t, canVariant),
      ],
    );
  }

  /// Variant almashtirgichi va javoblarni ochish qoidasi.
  List<Widget> _advanced(
    BuildContext context,
    AppLocalizations l,
    TextTheme t,
    bool canVariant,
  ) {
    return [
      const SizedBox(height: FeSpace.sm),
      SwitchListTile(
        key: const Key('grp.variantSwitch'),
        contentPadding: EdgeInsets.zero,
        title: Text(l.grpVariantLabel),
        subtitle: Text(
          canVariant
              ? l.grpVariantHelp
              : l.grpVariantTooFew(poolSize, value.count * 2),
          key: const Key('grp.variantNote'),
        ),
        value: canVariant && value.variant,
        onChanged: canVariant
            ? (v) => onChanged(value.copyWith(variant: v))
            : null,
      ),
      FeSectionHeader(l.grpRevealSection),
      RadioGroup<RevealPolicy>(
        groupValue: value.reveal,
        onChanged: (v) => onChanged(value.copyWith(reveal: v)),
        child: Column(
          children: [
            RadioListTile<RevealPolicy>(
              key: const Key('grp.revealDue'),
              contentPadding: EdgeInsets.zero,
              value: RevealPolicy.afterDue,
              title: Text(l.grpRevealAfterDue, style: t.bodyLarge),
            ),
            RadioListTile<RevealPolicy>(
              key: const Key('grp.revealClose'),
              contentPadding: EdgeInsets.zero,
              value: RevealPolicy.afterClose,
              title: Text(l.grpRevealAfterClose, style: t.bodyLarge),
            ),
          ],
        ),
      ),
    ];
  }
}
