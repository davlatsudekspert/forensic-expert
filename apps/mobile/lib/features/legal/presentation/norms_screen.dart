import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/date_format.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/fe_components.dart';
import 'instrument_title.dart';

/// Rule type used for forensic-expertise procedural / criminal-law norms.
const String kExpertNormSubject = 'expert_norm';

/// Hujjatning bugungi kuch holati — sanalardan **aniq** (taxmin yo‘q).
enum NormTiming { inForce, notYet, endsOn }

NormTiming normTimingOf(JurisdictionalInstrument i, DateTime now) {
  if (i.effectiveFrom.isAfter(now)) return NormTiming.notYet;
  if (i.effectiveTo != null && i.effectiveTo!.isAfter(now)) {
    return NormTiming.endsOn;
  }
  return NormTiming.inForce;
}

/// Yurisdiksiya uchun sud-ekspertiza normalari: hujjat bo‘yicha guruhlangan
/// moddalar. Qisqa mazmun — NEEDS_REVIEW; rasmiy matn o‘rnini bosmaydi.
class JurisdictionNormsScreen extends ConsumerWidget {
  const JurisdictionNormsScreen({super.key, required this.id, this.now});

  final String id;

  /// Testlar uchun; odatda `DateTime.now()`.
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final resolver = ref.watch(jurisdictionResolverProvider);
    final catalog = ref.watch(legalCatalogProvider);
    final at = now ?? DateTime.now();
    final chain = {for (final j in resolver.chainOf(id)) j.id};
    final groups = <(JurisdictionalInstrument, List<JurisdictionalRule>)>[];
    for (final i in resolver.instruments) {
      if (!chain.contains(i.jurisdictionId)) continue;
      final rules = [
        for (final r in resolver.rules)
          if (r.instrumentId == i.id &&
              r.ruleType == JurisdictionalRuleType.procedureRequirement &&
              r.subjectType == kExpertNormSubject)
            r,
      ];
      if (rules.isNotEmpty) groups.add((i, rules));
    }
    // Kuchdagi hujjatlar avval, so‘ng kuchga kirmagan, oxirida tugaydigan.
    groups.sort((a, b) {
      int rank(JurisdictionalInstrument i) => switch (normTimingOf(i, at)) {
        NormTiming.inForce => 0,
        NormTiming.notYet => 1,
        NormTiming.endsOn => 2,
      };
      final d = rank(a.$1) - rank(b.$1);
      return d != 0 ? d : a.$1.id.compareTo(b.$1.id);
    });

    return Scaffold(
      appBar: AppBar(title: FeAppBarTitle(l.legalNormsTitle)),
      body: SafeArea(
        child: ListView(
          key: Key('norms.$id'),
          children: [
            FeContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FeSpace.sm),
                  FeBanner(
                    key: const Key('norms.review'),
                    icon: Icons.rule_outlined,
                    tone: FeBannerTone.warning,
                    text: l.legalNormsReview,
                  ),
                  if (lang != 'uz')
                    Padding(
                      padding: const EdgeInsets.only(top: FeSpace.xs),
                      child: Text(
                        l.legalNormsLangNote,
                        style: t.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ),
                  if (groups.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: FeSpace.md),
                      child: Text(
                        l.legalNormsNone,
                        key: const Key('norms.none'),
                      ),
                    ),
                  for (final (inst, rules) in groups) ...[
                    const SizedBox(height: FeSpace.md),
                    _InstrumentHeader(
                      instrument: inst,
                      timing: normTimingOf(inst, at),
                      url: catalog.instrumentSources[inst.id]?.url,
                    ),
                    for (final r in rules) _NormTile(rule: r, inst: inst),
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

class _InstrumentHeader extends StatelessWidget {
  const _InstrumentHeader({
    required this.instrument,
    required this.timing,
    required this.url,
  });

  final JurisdictionalInstrument instrument;
  final NormTiming timing;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final i = instrument;
    return Column(
      key: Key('norms.instrument.${i.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InstrumentTitle(instrument: i, style: t.titleSmall),
        const SizedBox(height: FeSpace.xxs),
        Wrap(
          spacing: FeSpace.xs,
          runSpacing: FeSpace.xxs,
          children: [
            if (i.officialReference != null)
              Text(
                i.officialReference!,
                style: t.bodySmall?.copyWith(color: c.textSecondary),
              ),
            switch (timing) {
              NormTiming.inForce => StatusChip(
                icon: Icons.gavel_outlined,
                label: l.legalStatusInForce,
                color: c.textSecondary,
              ),
              NormTiming.notYet => StatusChip(
                key: Key('norms.timing.${i.id}'),
                icon: Icons.schedule,
                label:
                    '${l.legalStatusNotYet} · '
                    '${l.legalInForceFrom(feDate(context, i.effectiveFrom))}',
                color: c.accent,
              ),
              NormTiming.endsOn => StatusChip(
                key: Key('norms.timing.${i.id}'),
                icon: Icons.history_toggle_off,
                label: l.legalInForceUntil(feDate(context, i.effectiveTo!)),
                color: c.accent,
              ),
            },
          ],
        ),
        if (url != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              icon: const Icon(Icons.link),
              label: Text(l.researchCopyLink),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: url!));
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l.researchLinkCopied)));
                }
              },
            ),
          ),
      ],
    );
  }
}

class _NormTile extends StatelessWidget {
  const _NormTile({required this.rule, required this.inst});

  final JurisdictionalRule rule;
  final JurisdictionalInstrument inst;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final v = rule.value;
    final article = '${v['article'] ?? rule.articleSection ?? ''}';
    final title = '${v['title_uz'] ?? ''}';
    final summary = v['summary_uz'] as String?;
    return Padding(
      padding: const EdgeInsets.only(top: FeSpace.xs),
      child: FeCard(
        key: Key('norm.${rule.id}'),
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: FeSpace.sm,
              vertical: 2,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(
              FeSpace.sm,
              0,
              FeSpace.sm,
              FeSpace.sm,
            ),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            title: Text(
              '${l.legalNormArticle(article)} · $title',
              style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            children: [
              ReviewStatusBadge(status: rule.status),
              if (summary != null)
                Padding(
                  padding: const EdgeInsets.only(top: FeSpace.xs),
                  child: Text(
                    summary,
                    key: Key('norm.${rule.id}.summary'),
                    locale: const Locale('uz'),
                    style: t.bodyMedium,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: FeSpace.xs),
                child: Text(
                  '${v['summary_basis'] ?? ''}',
                  style: t.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
