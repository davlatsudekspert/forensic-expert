import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';

/// Bitta yurisdiksion qoida — rasmiy hujjat, bo‘lim, organ, kuchga kirish
/// sanasi, status va (ochiq litsenziyada) rasmiy matn iqtibosi bilan.
///
/// Qiymatlar faqat qoida yozuvidan; hech narsa hisoblanmaydi yoki
/// xulosa qilinmaydi.
class LegalRuleCard extends ConsumerWidget {
  const LegalRuleCard({
    super.key,
    required this.rule,
    required this.instrument,
    this.overrides,
  });

  final JurisdictionalRule rule;
  final JurisdictionalInstrument instrument;

  /// Shu qoida o‘rnini bosgan kamroq aniq yurisdiksiya (masalan, GB).
  final Jurisdiction? overrides;

  static String specimenLabel(AppLocalizations l, String key) => switch (key) {
    'breath' => l.specimenBreath,
    'blood' => l.specimenBlood,
    'urine' => l.specimenUrine,
    _ => key,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final resolver = ref.watch(jurisdictionResolverProvider);
    final catalog = ref.watch(legalCatalogProvider);
    final jurisdiction = resolver.byId(instrument.jurisdictionId);
    final layer = jurisdiction == null
        ? null
        : legalLayerOf(instrument, jurisdiction.level);
    String date(DateTime d) => feDate(context, d);
    final v = rule.value;
    final limits = (v['limits'] as Map?)?.cast<String, Object?>();
    final excerpt = v['excerpt'] as String?;
    final schedules = [
      for (final s in (v['schedules'] as List? ?? const [])) '$s',
    ];
    final authority = instrument.authorityId == null
        ? null
        : catalog.authorities[instrument.authorityId]?.resolve(lang);
    final secondary = t.bodySmall?.copyWith(color: c.textSecondary);

    return FeCard(
      key: Key('legal.${rule.id}'),
      padding: const EdgeInsets.all(FeSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: FeSpace.xs,
            runSpacing: FeSpace.xxs,
            children: [
              ReviewStatusBadge(status: rule.status),
              if (layer != null)
                StatusChip(
                  icon: layer == LegalLayerKind.internationalControl
                      ? Icons.public
                      : Icons.account_balance_outlined,
                  label: layer == LegalLayerKind.internationalControl
                      ? l.legalInternationalLayer
                      : l.legalLayerNational,
                  color: c.textSecondary,
                ),
              StatusChip(
                icon: Icons.gavel_outlined,
                label: switch (instrument.legalStatus) {
                  InstrumentLegalStatus.inForce => l.legalStatusInForce,
                  InstrumentLegalStatus.amended => l.legalStatusAmended,
                  InstrumentLegalStatus.superseded => l.legalStatusSuperseded,
                  InstrumentLegalStatus.repealed => l.legalStatusRepealed,
                },
                color: c.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: FeSpace.xs),
          if (rule.ruleType == JurisdictionalRuleType.controlStatus)
            Text(
              l.legalSchedule(
                (v['convention'] as String?) ?? instrument.titles['en'] ?? '',
                schedules.join(', '),
              ),
              style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            )
          else ...[
            Text(
              l.legalThresholdTitle,
              style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (limits != null)
              for (final e in limits.entries)
                Padding(
                  key: Key('legal.${rule.id}.${e.key}'),
                  padding: const EdgeInsets.only(top: 2),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${specimenLabel(l, e.key)}: ',
                          style: secondary,
                        ),
                        TextSpan(
                          text:
                              '${(e.value! as Map)['value']} '
                              '${(e.value! as Map)['unit']}',
                          style: FeThemeBuilder.numeric(t.bodyMedium!),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
          const SizedBox(height: FeSpace.xxs),
          Text(
            instrument.titles['en'] ?? instrument.id,
            locale: const Locale('en'),
            style: t.bodySmall,
          ),
          if (rule.articleSection != null)
            Text(l.compareArticle(rule.articleSection!), style: secondary),
          if (authority != null)
            Text(l.compareAuthority(authority), style: secondary),
          if (v['extent'] case final String extent)
            Text(l.legalExtent(extent), style: secondary),
          if (rule.appliesTo case final applies?)
            Text(
              l.legalAppliesTo(
                [
                  for (final id in applies.toList()..sort())
                    resolver.byId(id)?.name(lang) ?? id,
                ].join(', '),
              ),
              style: secondary,
            ),
          if (overrides != null)
            Text(
              l.compareOverrides(overrides!.name(lang)),
              key: Key('legal.${rule.id}.overrides'),
              style: secondary,
            ),
          Text(
            '${l.legalEffective(date(rule.effectiveFrom))}'
            '${catalog.instrumentDatePrecision[instrument.id] == 'year' ? ' ${l.legalDateYearOnly}' : ''}',
            style: secondary,
          ),
          if (instrument.lastVerifiedAt != null)
            Text(
              l.legalLastVerified(date(instrument.lastVerifiedAt!)),
              style: secondary,
            ),
          if (excerpt != null) ...[
            const SizedBox(height: FeSpace.xs),
            DecoratedBox(
              key: Key('legal.${rule.id}.excerpt'),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: c.accent, width: 3)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: FeSpace.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.compareOfficialExcerpt,
                      style: t.labelSmall?.copyWith(color: c.textSecondary),
                    ),
                    Text(
                      excerpt,
                      locale: Locale(instrument.language ?? 'en'),
                      style: t.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
