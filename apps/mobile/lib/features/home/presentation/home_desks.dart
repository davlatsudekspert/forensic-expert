import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/dna.dart';
import '../../../app/routes.dart';
import '../../../app/user_data.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/equipment/equipment.dart';
import '../../../domain/learn/study_models.dart';
import '../../class_quiz/presentation/teacher_panel_screen.dart'
    show watchIsTeacher;
import '../../learn/presentation/learn_screens.dart' show ClassQuizEntryCard;
import '../daily_fact.dart';
import '../daily_question.dart';
import '../workbench.dart';
import 'saved_items.dart';

/// Ekspert Home: «Ish stolim» (mutaxassislikka mos kirishlar) va
/// «Bugungi ma’lumot». Faqat mavjud ekranlarga olib boradi.
class ExpertWorkbench extends ConsumerWidget {
  const ExpertWorkbench({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final specialty = ref.watch(workbenchEffectiveProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final fact = ref.watch(dailyFactProvider(lang));
    final chemistry = specialty == WorkbenchSpecialty.chemistry;
    return Column(
      key: Key('workbench.${specialty.name}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(
          l.workbenchTitle,
          padding: const EdgeInsets.only(bottom: FeSpace.xs),
        ),
        SegmentedButton<WorkbenchSpecialty>(
          key: const Key('workbench.view'),
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: WorkbenchSpecialty.medicine,
              icon: const Icon(Icons.monitor_heart_outlined, size: 18),
              label: Text(
                l.workbenchViewMedicine,
                key: const Key('workbench.view.medicine'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ButtonSegment(
              value: WorkbenchSpecialty.chemistry,
              icon: const Icon(Icons.science_outlined, size: 18),
              label: Text(
                l.workbenchViewChemistry,
                key: const Key('workbench.view.chemistry'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          selected: {specialty},
          onSelectionChanged: (s) =>
              ref.read(workbenchViewProvider.notifier).select(s.first),
        ),
        const SizedBox(height: FeSpace.sm),
        if (chemistry) ...[
          const _LabMethodsCard(),
          const SizedBox(height: FeSpace.sm),
        ] else ...[
          const _DeathCauseCard(),
          const SizedBox(height: FeSpace.sm),
        ],
        EquipmentCard(
          group: chemistry ? EquipmentGroup.lab : EquipmentGroup.morgue,
        ),
        const DnaCard(),
        const SizedBox(height: FeSpace.sm),
        _DeskGrid(items: Workbench.cardsFor(specialty)),
        const SizedBox(height: FeSpace.sm),
        // ★ Tanlanganlar — ikkala stolda ham: foydalanuvchi o‘zi belgilagan
        // mavzu, modda va kalkulyatorlar shu yerda turadi.
        const _DeskFavorites(),
        if (fact != null) ...[
          const SizedBox(height: FeSpace.sm),
          DailyFactCard(fact: fact),
        ],
        const _DeskDailyQuestion(),
        const SizedBox(height: FeSpace.xs),
      ],
    );
  }
}

/// Talaba Home: «O‘qish stolim» va «Bugungi savol».
class StudentDesk extends ConsumerWidget {
  const StudentDesk({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final question = ref.watch(dailyQuestionProvider(lang));
    return Column(
      key: const Key('desk.student'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(
          l.studentDeskTitle,
          padding: const EdgeInsets.only(bottom: FeSpace.xs),
        ),
        const ClassQuizEntryCard(),
        const SizedBox(height: FeSpace.sm),
        _DeskGrid(items: Workbench.studentCards),
        const SizedBox(height: FeSpace.sm),
        const EquipmentCard(group: EquipmentGroup.lab),
        const DnaCard(),
        if (question != null) ...[
          const SizedBox(height: FeSpace.sm),
          // Kun o‘zgarganda (kalit) javob holati yangidan boshlanadi.
          DailyQuestionCard(
            key: ValueKey('daily.q.${question.item.id}'),
            question: question,
          ),
        ],
        const SizedBox(height: FeSpace.xs),
      ],
    );
  }
}

/// Ustoz Home: «Ustoz stolim» — darslar (prezentatsiyalar), jonli guruh
/// testi, guruhlar va mavzu testlari, Ustoz paneli (natijalar, CSV).
class TeacherDesk extends ConsumerWidget {
  const TeacherDesk({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Column(
      key: const Key('desk.teacher'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeSectionHeader(
          l.teacherDeskTitle,
          padding: const EdgeInsets.only(bottom: FeSpace.xs),
        ),
        _DeskGrid(
          items: Workbench.teacherCards(isTeacher: watchIsTeacher(ref)),
        ),
        const _DeskDailyQuestion(),
        const SizedBox(height: FeSpace.xs),
      ],
    );
  }
}

void _open(BuildContext context, WorkbenchItem item) =>
    item.isTab ? context.go(item.route) : context.push(item.route);

/// 2 ustunli to‘r (tor ekran yoki katta shriftda — bitta ustun; Home’ning
/// tezkor amallar to‘ri bilan bir xil qoida).
class _DeskGrid extends StatelessWidget {
  const _DeskGrid({required this.items});

  final List<WorkbenchItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final columns = w >= 560 ? 4 : (w >= 300 && textScale < 1.6 ? 2 : 1);
        const gap = FeSpace.sm;
        return Column(
          children: [
            for (var i = 0; i < items.length; i += columns)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i + columns < items.length ? gap : 0,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var j = 0; j < columns; j++) ...[
                        if (j > 0) const SizedBox(width: gap),
                        Expanded(
                          child: i + j < items.length
                              ? _DeskCard(item: items[i + j])
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DeskCard extends StatelessWidget {
  const _DeskCard({required this.item});

  final WorkbenchItem item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final b = Theme.of(context).brightness;
    return gateWorkbenchItem(
      context,
      item.id,
      FeCard(
        key: item.key,
        padding: const EdgeInsets.fromLTRB(
          FeSpace.md,
          FeSpace.md,
          FeSpace.sm,
          FeSpace.md,
        ),
        onTap: () => _open(context, item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: item.hue.bg(b),
                borderRadius: BorderRadius.circular(FeRadius.md),
              ),
              child: SizedBox.square(
                dimension: 44,
                child: Icon(item.icon, color: item.hue.fg(b), size: 24),
              ),
            ),
            const SizedBox(height: FeSpace.sm),
            Text(
              item.title(l),
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.body(l),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kimyo/toksikologiya ekspertining keng kartasi: «Laboratoriya usullari» —
/// 4 ta bosiladigan band (reaktivlar, ekspress, spektrofotometriya,
/// GC-MS / LC-MS). Karta o‘zi hammaga ochiq; bandlar Pro darvozasi orqali.
class _LabMethodsCard extends StatelessWidget {
  const _LabMethodsCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: const Key('workbench.labMethods'),
      color: c.accentContainer,
      padding: const EdgeInsets.all(FeSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: c.surfaceRaised,
                  borderRadius: BorderRadius.circular(FeRadius.md),
                  border: Border.all(color: c.accentBorder),
                ),
                child: SizedBox.square(
                  dimension: 44,
                  child: Icon(Icons.biotech_outlined, color: c.accent),
                ),
              ),
              const SizedBox(width: FeSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.workbenchLabTitle,
                      style: t.titleMedium?.copyWith(
                        fontSize: 18,
                        height: 1.25,
                        color: c.onAccentContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.workbenchLabBody,
                      style: t.bodySmall?.copyWith(color: c.onAccentContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FeSpace.sm),
          for (final (i, item) in Workbench.labItems.indexed) ...[
            if (i > 0) const SizedBox(height: FeSpace.xs),
            gateWorkbenchItem(context, item.id, _LabRow(item: item)),
          ],
        ],
      ),
    );
  }
}

class _LabRow extends StatelessWidget {
  const _LabRow({required this.item});

  final WorkbenchItem item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final b = Theme.of(context).brightness;
    return Semantics(
      button: true,
      child: Material(
        key: item.key,
        color: c.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FeRadius.md),
          side: BorderSide(color: c.accentBorder.withValues(alpha: 0.6)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _open(context, item),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FeSpace.sm,
              vertical: FeSpace.xs + 2,
            ),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: item.hue.bg(b),
                    borderRadius: BorderRadius.circular(FeRadius.sm),
                  ),
                  child: SizedBox.square(
                    dimension: 36,
                    child: Icon(item.icon, color: item.hue.fg(b), size: 20),
                  ),
                ),
                const SizedBox(width: FeSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title(l),
                        style: t.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                      Text(
                        item.body(l),
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: c.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// «Bugungi ma’lumot»: manbali bitta ma’lumot; bosilsa — to‘liq yozuv.
class DailyFactCard extends StatelessWidget {
  const DailyFactCard({super.key, required this.fact});

  final DailyFact fact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final sourceLine = '${l.workbenchFactSource}: ${fact.source}';
    return FeCard(
      key: const Key('workbench.dailyFact'),
      semanticLabel: '${l.workbenchFactTitle}. ${l.workbenchFactSemantics}',
      onTap: () => context.push(fact.route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 18, color: c.accent),
              const SizedBox(width: FeSpace.xs),
              Expanded(
                child: Text(
                  l.workbenchFactTitle,
                  style: t.labelLarge?.copyWith(
                    color: c.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: c.textSecondary),
            ],
          ),
          const SizedBox(height: FeSpace.xs),
          Text(
            fact.title,
            key: const Key('workbench.dailyFact.title'),
            style: t.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            fact.excerpt,
            key: const Key('workbench.dailyFact.excerpt'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.bodyMedium,
          ),
          if (fact.translationPending)
            Padding(
              padding: const EdgeInsets.only(top: FeSpace.xxs),
              child: Text(
                l.trPendingTranslation,
                key: const Key('workbench.dailyFact.pending'),
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            ),
          const SizedBox(height: FeSpace.xs),
          Text(
            sourceLine,
            key: const Key('workbench.dailyFact.source'),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// «Bugungi savol»: mavjud savollar bankidan, manba va betlari bilan. Karta
/// ustida javob beriladi (to‘g‘ri javob ko‘rsatiladi); to‘liq izoh va mashq
/// — odatiy test ekranida.
class DailyQuestionCard extends StatefulWidget {
  const DailyQuestionCard({super.key, required this.question});

  final StudyQuestion question;

  @override
  State<DailyQuestionCard> createState() => _DailyQuestionCardState();
}

class _DailyQuestionCardState extends State<DailyQuestionCard> {
  int? _picked;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final q = widget.question;
    final item = q.item;
    final answered = _picked != null;
    final source = [
      // Kartada faqat birinchi manba (to‘liq ro‘yxat test ekranida).
      for (final s in item.citations.take(1))
        [
          s.title,
          ?s.detail,
          if (s.pages != null) l.studySourcePages(s.pages!),
          if (s.pages == null && s.locator != null) s.locator!,
          if (s.pages == null && s.locator == null && s.section != null)
            s.section!.resolve(lang),
        ].join(' · '),
    ].join('\n');
    final sourceLine = '${l.workbenchFactSource}: $source';
    return FeCard(
      key: const Key('desk.dailyQuestion'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.quiz_outlined, size: 18, color: c.accent),
              const SizedBox(width: FeSpace.xs),
              Expanded(
                child: Text(
                  l.dailyQuestionTitle,
                  style: t.labelLarge?.copyWith(
                    color: c.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FeSpace.xs),
          Text(
            q.stem.resolve(lang),
            key: const Key('desk.dailyQuestion.stem'),
            style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: FeSpace.xs),
          for (var i = 0; i < q.choiceCount; i++) ...[
            if (i > 0) const SizedBox(height: FeSpace.xs),
            _AnswerRow(
              key: Key('desk.dailyQuestion.option.$i'),
              text: q.optionText(i).resolve(lang),
              state: !answered
                  ? null
                  : q.isCorrect(i)
                  ? true
                  : (_picked == i ? false : null),
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
          ],
          if (answered)
            Padding(
              padding: const EdgeInsets.only(top: FeSpace.xs),
              child: Text(
                q.isCorrect(_picked!)
                    ? l.dailyQuestionCorrect
                    : l.dailyQuestionWrong,
                key: const Key('desk.dailyQuestion.feedback'),
                style: t.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: q.isCorrect(_picked!) ? c.verified : c.danger,
                ),
              ),
            ),
          const SizedBox(height: FeSpace.xs),
          Text(
            sourceLine,
            key: const Key('desk.dailyQuestion.source'),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: t.bodySmall?.copyWith(color: c.textSecondary),
          ),
          if (answered)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: gateWorkbenchItem(
                context,
                WorkbenchItemId.deskTests,
                TextButton.icon(
                  key: const Key('desk.dailyQuestion.explain'),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(l.dailyQuestionExplain),
                  onPressed: () => context.push(Routes.studyQuiz(item.deckId)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    super.key,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String text;

  /// `true` — to‘g‘ri javob, `false` — tanlangan xato, `null` — belgisiz.
  final bool? state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final accent = switch (state) {
      true => c.verified,
      false => c.danger,
      null => c.borderStrong,
    };
    final icon = switch (state) {
      true => Icons.check_circle_outline,
      false => Icons.highlight_off,
      null => Icons.radio_button_unchecked,
    };
    return Semantics(
      button: true,
      child: Material(
        color: c.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FeRadius.md),
          side: BorderSide(color: accent, width: state != null ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FeSpace.sm,
              vertical: FeSpace.xs + 2,
            ),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 20),
                const SizedBox(width: FeSpace.xs),
                Expanded(child: Text(text, style: t.bodyMedium)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// «Tanlanganlar» (★): bo‘sh bo‘lsa — qanday qo‘shishni aytuvchi bitta qator.
class _DeskFavorites extends ConsumerWidget {
  const _DeskFavorites();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final b = Theme.of(context).brightness;
    final ids = ref.watch(userDataProvider.select((d) => d.favorites));
    final items = resolveSavedItems(context, ref, ids).take(8).toList();
    return FeCard(
      key: const Key('workbench.favorites'),
      padding: const EdgeInsets.all(FeSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: FeHues.ochre.bg(b),
                  borderRadius: BorderRadius.circular(FeRadius.sm),
                ),
                child: SizedBox.square(
                  dimension: 36,
                  child: Icon(Icons.star_rounded, color: FeHues.ochre.fg(b)),
                ),
              ),
              const SizedBox(width: FeSpace.sm),
              Expanded(
                child: Text(
                  l.workbenchFavTitle,
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: FeSpace.xs),
          if (items.isEmpty)
            Text(
              l.workbenchFavEmpty,
              key: const Key('workbench.favorites.empty'),
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            )
          else
            for (final (name, open) in items)
              InkWell(
                borderRadius: BorderRadius.circular(FeRadius.sm),
                onTap: open,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: FeSpace.xs),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, size: 16, color: c.accent),
                      const SizedBox(width: FeSpace.xs),
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodyMedium,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: c.textSecondary),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

/// «Bugungi savol» — mutaxassis va ustoz stolida ham (egasi talabi,
/// 2026-11-01); talabaniki «O‘qish stolim» ichida.
class _DeskDailyQuestion extends ConsumerWidget {
  const _DeskDailyQuestion();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final question = ref.watch(dailyQuestionProvider(lang));
    if (question == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: FeSpace.sm),
      child: DailyQuestionCard(
        key: ValueKey('daily.q.${question.item.id}'),
        question: question,
      ),
    );
  }
}

/// Sud-tibbiy ekspertning keng kartasi: «O‘lim sababini aniqlash» — qiyin
/// holatlar uchun manbali yozuvlar savol bo‘yicha (o‘lim vaqti, jarohatlar,
/// to‘satdan o‘lim, zaharlanish gumoni …). «Laboratoriya usullari» juftligi.
class _DeathCauseCard extends StatelessWidget {
  const _DeathCauseCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return FeCard(
      key: const Key('workbench.deathCause'),
      color: c.accentContainer,
      padding: const EdgeInsets.all(FeSpace.md),
      onTap: () => context.push(Routes.labHub('causeOfDeath')),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: c.surfaceRaised,
              borderRadius: BorderRadius.circular(FeRadius.md),
              border: Border.all(color: c.accentBorder),
            ),
            child: SizedBox.square(
              dimension: 44,
              child: Icon(Icons.manage_search_rounded, color: c.accent),
            ),
          ),
          const SizedBox(width: FeSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.deathHubTitle,
                  style: t.titleMedium?.copyWith(
                    fontSize: 18,
                    height: 1.25,
                    color: c.onAccentContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.deathHubCardBody,
                  style: t.bodySmall?.copyWith(color: c.onAccentContainer),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: c.onAccentContainer),
        ],
      ),
    );
  }
}

/// «Asbob-uskunalar» kartasi: 3 ta kichik illyustratsiya + sarlavha.
/// Ekspert stolida ko‘rinishga mos bo‘lim ochiladi (Sud-kimyo → Laboratoriya,
/// Sud-tibbiy → Morg).
class EquipmentCard extends StatelessWidget {
  const EquipmentCard({super.key, required this.group});

  final EquipmentGroup group;

  static const _lab = ['gc_ms', 'uv_vis', 'microscope'];
  static const _morgue = ['autopsy_set', 'brain_knife', 'organ_scale'];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final ids = group == EquipmentGroup.lab ? _lab : _morgue;
    return FeCard(
      key: const Key('desk.equipment'),
      padding: const EdgeInsets.all(FeSpace.md),
      onTap: () => context.push(Routes.equipmentGroup(group.name)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.equipTitle,
                      style: t.titleMedium?.copyWith(
                        fontSize: 18,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.equipCardBody,
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: c.textSecondary),
            ],
          ),
          const SizedBox(height: FeSpace.sm),
          Row(
            children: [
              for (final (i, id) in ids.indexed) ...[
                if (i > 0) const SizedBox(width: FeSpace.xs),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(FeRadius.md),
                      child: ColoredBox(
                        color: const Color(0xFFF4EFE6),
                        child: Image.asset(
                          'assets/images/instruments/$id.webp',
                          fit: BoxFit.cover,
                          excludeFromSemantics: true,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// «DNK ekspertizasi» kartasi — bo‘lim paketi bo‘lsagina ko‘rinadi
/// (manbali kontent yo‘q bo‘lsa karta ham yo‘q).
class DnaCard extends ConsumerWidget {
  const DnaCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(dnaProvider).value;
    if (b == null || b.isEmpty) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: FeSpace.sm),
      child: FeCard(
        key: const Key('desk.dna'),
        padding: EdgeInsets.zero,
        onTap: () => context.push(Routes.dna),
        // Rasm o‘ng tomonda, matn chap bo‘sh joyda (egasi talabi,
        // 2026-11-01): karta ixcham, bo‘sh maydon qolmaydi.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(FeRadius.lg),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/instruments/dna_banner.webp',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  excludeFromSemantics: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  FeSpace.md,
                  FeSpace.lg,
                  FeSpace.md,
                  FeSpace.lg,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 11,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.dnaTitle,
                            style: t.titleMedium?.copyWith(
                              fontSize: 18,
                              height: 1.25,
                              color: const Color(0xFF0B1B2B),
                            ),
                          ),
                          const SizedBox(height: FeSpace.xs),
                          Text(
                            l.dnaSubtitle,
                            style: t.bodySmall?.copyWith(
                              color: const Color(0xFF4A5563),
                            ),
                          ),
                          const SizedBox(height: FeSpace.sm),
                          const Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: Color(0xFF0B1B2B),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 9),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
