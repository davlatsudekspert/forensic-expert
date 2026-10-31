import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../domain/class_quiz/class_quiz_models.dart';

/// Har savolga vaqt: tez tanlov chiplari (15/30/45/60) + istalgan butun son
/// 5..300 (server `class_create_session` bilan bir xil chegara) uchun maydon
/// va ±5 tugmalari. Yaroqsiz/bo‘sh qiymat uchun [onChanged] 0 ni qaytaradi
/// (`ClassQuizRules.validSeconds` rad etadi) va maydon ostida xato ko‘rinadi.
class ClassSecondsPicker extends StatefulWidget {
  const ClassSecondsPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<ClassSecondsPicker> createState() => _ClassSecondsPickerState();
}

class _ClassSecondsPickerState extends State<ClassSecondsPicker> {
  static const _step = 5;
  late final TextEditingController _c = TextEditingController(
    text: widget.value == 0 ? '' : '${widget.value}',
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ClassSecondsPicker old) {
    super.didUpdateWidget(old);
    // Chip/±5 qiymatni o‘zgartirsa — maydon ham yangilanadi (yozayotganda emas).
    if ((int.tryParse(_c.text) ?? 0) != widget.value) {
      _c.text = widget.value == 0 ? '' : '${widget.value}';
    }
  }

  void _set(int v) {
    final n = v.clamp(ClassQuizRules.minSeconds, ClassQuizRules.maxSeconds);
    _c.text = '$n';
    widget.onChanged(n);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    final v = widget.value;
    final valid = ClassQuizRules.validSeconds(v);
    return Column(
      key: const Key('class.seconds'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xs,
          children: [
            for (final s in ClassQuizRules.secondsChoices)
              ChoiceChip(
                key: Key('class.seconds.$s'),
                label: Text(l.classSecondsShort(s)),
                selected: v == s,
                onSelected: (_) => _set(s),
              ),
          ],
        ),
        const SizedBox(height: FeSpace.xs),
        Row(
          children: [
            IconButton.outlined(
              key: const Key('class.secondsMinus'),
              tooltip: l.acSecondsMinus,
              onPressed: valid && v > ClassQuizRules.minSeconds
                  ? () => _set(v - _step)
                  : null,
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: FeSpace.xs),
            SizedBox(
              width: 112,
              child: TextField(
                key: const Key('class.secondsField'),
                controller: _c,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                onChanged: (s) => widget.onChanged(int.tryParse(s) ?? 0),
                decoration: InputDecoration(
                  isDense: true,
                  labelText: l.acSecondsLabel,
                  errorText: valid ? null : l.acSecondsError,
                  errorMaxLines: 2,
                ),
              ),
            ),
            const SizedBox(width: FeSpace.xs),
            IconButton.outlined(
              key: const Key('class.secondsPlus'),
              tooltip: l.acSecondsPlus,
              onPressed: valid && v < ClassQuizRules.maxSeconds
                  ? () => _set(v + _step)
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        if (valid)
          Padding(
            padding: const EdgeInsets.only(top: FeSpace.xxs),
            child: Text(
              l.acSecondsHint,
              key: const Key('class.secondsHint'),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
      ],
    );
  }
}
