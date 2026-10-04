import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/widgets/fe_components.dart';
import '../../knowledge/knowledge_strings.dart';
import 'legal_rule_card.dart';

/// Solishtiriladigan mavzu: bir xil `topicKey` li qoidalar.
typedef _RuleRow = (JurisdictionalRule, JurisdictionalInstrument);

typedef _Topic = ({String subjectType, String subjectId, String topicKey});

/// Yurisdiksiyalarni yonma-yon solishtirish.
///
/// * Har bir katak — faqat shu yurisdiksiyada amal qiladigan qoida
///   (hududiy qamrov va «aniqroq yurisdiksiya ustun» qoidasi bilan).
/// * Ma’lumot yo‘q bo‘lsa — «ma’lumot yo‘q, xulosa chiqarilmaydi».
///   «Topilmadi = ruxsat / nazoratda emas / taqiqlangan» hech qachon emas.
class CompareJurisdictionsScreen extends ConsumerStatefulWidget {
  const CompareJurisdictionsScreen({super.key});

  @override
  ConsumerState<CompareJurisdictionsScreen> createState() =>
      _CompareJurisdictionsScreenState();
}

class _CompareJurisdictionsScreenState
    extends ConsumerState<CompareJurisdictionsScreen> {
  _Topic? _topic;
  Set<String>? _selected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final resolver = ref.watch(jurisdictionResolverProvider);
    final includeUnreviewed = ref.watch(showUnreviewedLegalProvider);
    final userJurisdiction = ref.watch(
      settingsControllerProvider.select((s) => s.jurisdictionId),
    );

    final topics =
        <_Topic>{
            for (final r in resolver.rules)
              if (r.topicKey != null)
                (
                  subjectType: r.subjectType,
                  subjectId: r.subjectId,
                  topicKey: r.topicKey!,
                ),
          }.toList()
          // Avval umumiy mavzular (alkogol chegarasi), so‘ng moddalar bo‘yicha.
          ..sort((a, b) {
            final ac = a.topicKey.startsWith('controlled_substance') ? 1 : 0;
            final bc = b.topicKey.startsWith('controlled_substance') ? 1 : 0;
            return ac != bc ? ac - bc : a.subjectId.compareTo(b.subjectId);
          });
    final topic = _topic ?? topics.firstOrNull;
    final library = ref.watch(libraryRepositoryProvider);
    String topicLabel(_Topic tp) {
      final name = library.byId(tp.subjectId)?.name.resolve(lang);
      return tp.topicKey.startsWith('controlled_substance') && name != null
          ? '${l.legalTopicName(tp.topicKey)}: $name'
          : l.legalTopicName(tp.topicKey);
    }

    // Standart tanlov: qoidasi bor davlatlarning hududlari + foydalanuvchi
    // yurisdiksiyasi.
    final withData = {
      for (final r in resolver.rules)
        if (topic != null && r.topicKey == topic.topicKey)
          for (final i in resolver.instruments)
            if (i.id == r.instrumentId) i.jurisdictionId,
    };
    final defaults = <String>{
      for (final j in resolver.jurisdictions)
        if (j.level == JurisdictionLevel.subdivision &&
            (withData.contains(j.parentId) || withData.contains(j.id)))
          j.id,
      userJurisdiction,
    };
    final selected = _selected ?? defaults;
    final ordered = [
      for (final j in resolver.jurisdictions)
        if (selected.contains(j.id)) j,
    ]..sort((a, b) => a.id.compareTo(b.id));

    return Scaffold(
      appBar: AppBar(title: Text(l.compareTitle)),
      body: SafeArea(
        child: ListView(
          key: const Key('compare.list'),
          padding: const EdgeInsets.symmetric(vertical: FeSpace.sm),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FeBanner(
                    key: const Key('compare.notAdvice'),
                    icon: Icons.gavel_outlined,
                    text: l.compareNotAdvice,
                  ),
                  const SizedBox(height: FeSpace.xs),
                  FeBanner(
                    icon: Icons.info_outline,
                    text: l.compareNoInference,
                  ),
                  if (topic == null)
                    FeEmptyState(
                      key: const Key('compare.noTopics'),
                      icon: Icons.inbox_outlined,
                      body: l.compareNoTopics,
                    )
                  else ...[
                    FeSectionHeader(topicLabel(topic)),
                    Wrap(
                      spacing: FeSpace.xs,
                      runSpacing: FeSpace.xxs,
                      children: [
                        for (final tp in topics)
                          if (topics.length > 1)
                            ChoiceChip(
                              key: Key(
                                'compare.topic.${tp.subjectId}.${tp.topicKey}',
                              ),
                              label: Text(topicLabel(tp)),
                              selected: tp == topic,
                              onSelected: (_) => setState(() => _topic = tp),
                            ),
                      ],
                    ),
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        key: const Key('compare.picker'),
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: const EdgeInsets.only(
                          bottom: FeSpace.xs,
                        ),
                        leading: const Icon(Icons.tune),
                        title: Text(
                          '${l.methodJurisdiction} · ${ordered.length}',
                          style: t.labelLarge,
                        ),
                        subtitle: Text(
                          ordered.map((j) => j.name(lang)).join(', '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodySmall?.copyWith(color: c.textSecondary),
                        ),
                        children: [
                          Wrap(
                            spacing: FeSpace.xs,
                            runSpacing: FeSpace.xxs,
                            children: [
                              for (final j
                                  in resolver.jurisdictions.toList()
                                    ..sort((a, b) => a.id.compareTo(b.id)))
                                FilterChip(
                                  key: Key('compare.pick.${j.id}'),
                                  label: Text(j.name(lang)),
                                  selected: selected.contains(j.id),
                                  onSelected: (on) => setState(() {
                                    _selected = {...selected};
                                    on
                                        ? _selected!.add(j.id)
                                        : _selected!.remove(j.id);
                                  }),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: FeSpace.sm),
                    for (final j in ordered)
                      _Cell(
                        jurisdiction: j,
                        view: resolver.view(
                          jurisdictionId: j.id,
                          subjectType: topic.subjectType,
                          subjectId: topic.subjectId,
                          at: DateTime.now(),
                          includeUnreviewed: includeUnreviewed,
                        ),
                        topicKey: topic.topicKey,
                        lang: lang,
                        noData: l.compareNoData,
                        secondary: c.textSecondary,
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

class _Cell extends ConsumerWidget {
  const _Cell({
    required this.jurisdiction,
    required this.view,
    required this.topicKey,
    required this.lang,
    required this.noData,
    required this.secondary,
  });

  final Jurisdiction jurisdiction;
  final JurisdictionView? view;
  final String topicKey;
  final String lang;
  final String noData;
  final Color secondary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final resolver = ref.watch(jurisdictionResolverProvider);
    final rules = <_RuleRow>[
      for (final (r, i) in view?.rules ?? const <_RuleRow>[])
        if (r.topicKey == topicKey) (r, i),
    ];
    final overridden = [
      for (final (r, i) in view?.overridden ?? const <_RuleRow>[])
        if (r.topicKey == topicKey) i.jurisdictionId,
    ];
    return Padding(
      key: Key('compare.cell.${jurisdiction.id}'),
      padding: const EdgeInsets.only(bottom: FeSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(jurisdiction.name(lang), style: t.titleSmall),
          ),
          const SizedBox(height: FeSpace.xxs),
          if (rules.isEmpty)
            FeEmptyState(
              key: Key('compare.noData.${jurisdiction.id}'),
              icon: Icons.help_outline,
              body: noData,
              compact: true,
            )
          else
            for (final (r, i) in rules)
              LegalRuleCard(
                rule: r,
                instrument: i,
                overrides: overridden.isEmpty
                    ? null
                    : resolver.byId(overridden.first),
              ),
        ],
      ),
    );
  }
}
