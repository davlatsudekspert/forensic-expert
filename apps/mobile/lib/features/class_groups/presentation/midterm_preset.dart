import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/class_groups/class_groups_models.dart';
import '../../../domain/class_groups/variant_draw.dart';
import 'mixed_test_screen.dart' show MixedSource;
import 'test_settings.dart';

/// «Oraliq nazorat» standartlari (egasi qarori, 2026-10-31): 30 savol,
/// 40 daqiqa vaqt chegarasi, muddat — 1 kun. Server chegaralari (savol
/// 1–200, vaqt 1–180 daqiqa) [GroupRules] orqali qisiladi.
abstract final class MidtermDefaults {
  static const int questions = 30;
  static const int minutes = 40;
  static const int days = 1;
}

/// Kursdagi savollar soni [pool] bo‘yicha boshlang‘ich sozlamalar:
/// savollar soni — `min(30, pool)`, variantlar — faqat hovuz ≥ 2 × savollar.
TestSettings midtermSettings(int pool) {
  final count = max(
    GroupRules.minQuestions,
    min(MidtermDefaults.questions, min(pool, GroupRules.maxQuestions)),
  );
  return TestSettings(
    count: count,
    timeLimit: MidtermDefaults.minutes.clamp(
      GroupRules.minTimeLimit,
      GroupRules.maxTimeLimit,
    ),
    openDays: MidtermDefaults.days,
    variant: variantAllowed(pool, count),
  );
}

/// Test nomi: «Oraliq nazorat: kurs nomi» (server chegarasi — 120).
String midtermTitle(String prefix, String course) {
  final s = '$prefix: ${course.trim()}';
  return s.length <= 120 ? s : '${s.substring(0, 119).trimRight()}…';
}

/// Kursdagi savollar soni (barcha mavzular).
int midtermPool(MixedSource src) => src.topics.fold(0, (a, t) => a + t.count);

/// Kurslar: savoli bor manbalar («Boshqa mavzular» — kurs emas).
List<MixedSource> midtermCourses(List<MixedSource> sources) => [
  for (final s in sources)
    if (s.id != 'other' && midtermPool(s) > 0) s,
];

/// «Oraliq nazorat» kartasi: kursni bir bosishda tanlash.
class MidtermPresetCard extends StatelessWidget {
  const MidtermPresetCard({
    super.key,
    required this.courses,
    required this.onPick,
    this.pickedId,
  });

  final List<MixedSource> courses;
  final ValueChanged<MixedSource> onPick;
  final String? pickedId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = FeTheme.of(context);
    return FeCard(
      key: const Key('grp.midtermCard'),
      color: c.accentContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check_outlined, color: c.accent),
              const SizedBox(width: FeSpace.xs),
              Expanded(
                child: Text(l.scoringMidtermTitle, style: t.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: FeSpace.xxs),
          Text(
            l.scoringMidtermIntro(
              MidtermDefaults.questions,
              MidtermDefaults.minutes,
              MidtermDefaults.days,
            ),
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: FeSpace.xs),
          for (final src in courses)
            Padding(
              padding: const EdgeInsets.only(bottom: FeSpace.xxs),
              child: FilledButton.tonal(
                key: Key('grp.midterm.${src.id}'),
                onPressed: () => onPick(src),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  alignment: AlignmentDirectional.centerStart,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            src.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: t.titleSmall,
                          ),
                          Text(
                            l.scoringMidtermCourseLine(
                              src.topics.length,
                              midtermPool(src),
                            ),
                            style: t.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      pickedId == src.id
                          ? Icons.check_circle
                          : Icons.chevron_right,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Kurs tanlangach sozlamalar ostida chiqadigan izohlar (hovuz kichik / variant
/// o‘chiq). Hech narsa kerak bo‘lmasa — bo‘sh.
class MidtermNotes extends StatelessWidget {
  const MidtermNotes({
    super.key,
    required this.course,
    required this.pool,
    required this.settings,
  });

  final String course;
  final int pool;
  final TestSettings settings;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final style = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: c.textSecondary);
    final variantOk = variantAllowed(pool, settings.count);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NoteLine(
          key: const Key('grp.midtermApplied'),
          text: l.scoringMidtermApplied(course),
          style: style,
        ),
        if (pool < MidtermDefaults.questions)
          _NoteLine(
            key: const Key('grp.midtermPoolShort'),
            text: l.scoringMidtermPoolShort(pool),
            style: style,
          ),
        if (!variantOk)
          _NoteLine(
            key: const Key('grp.midtermVariantOff'),
            text: l.scoringMidtermVariantOff(pool, max(1, pool ~/ 2)),
            style: style,
          )
        else if (settings.variant)
          _NoteLine(
            key: const Key('grp.midtermVariantOn'),
            text: l.scoringMidtermVariantOn,
            style: style,
          ),
      ],
    );
  }
}

/// Kichik izoh qatori.
class _NoteLine extends StatelessWidget {
  const _NoteLine({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: FeSpace.xxs),
    child: Text(text, style: style),
  );
}
