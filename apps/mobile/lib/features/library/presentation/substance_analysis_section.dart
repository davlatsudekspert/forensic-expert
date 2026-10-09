import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/evidence/substance_analysis.dart';
import '../../../domain/library/library_models.dart';
import '../../evidence/presentation/provenance_widgets.dart';
import 'content_entry_sections.dart';

/// «Tahlil» — modda biologik ob’ektlarda (qon, siydik, jigar…) qanday tahlil
/// qilinadi: namunalar, skrining → tasdiqlash, manbalardagi tahlil metodlari
/// va izlanadigan metabolitlar.
///
/// Faqat paketdagi manbali bog‘lanishlar ([SubstanceAnalysis]); har bir qator
/// asos claim’ining holati va dalil darajasi bilan, manbaga va metod / namuna
/// sahifasiga olib boradi. Ma’lumot bo‘lmasa — halol bo‘sh holat.
class SubstanceAnalysisSection extends ConsumerWidget {
  const SubstanceAnalysisSection({super.key, required this.entityId});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final a = ref.watch(substanceAnalysisProvider(entityId));
    final library = ref.watch(libraryRepositoryProvider);
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final index = ref.watch(provenanceIndexProvider);

    String kName(String id) => knowledge.byId(id)?.name.resolve(lang) ?? id;
    String sName(String id) => index.specimen(id)?.names.resolve(lang) ?? id;
    String names(Iterable<String> ids, String Function(String) f) =>
        ids.map(f).join(FeGlyphs.listSeparator);

    Widget subheader(String text) => Padding(
      padding: const EdgeInsets.only(top: FeSpace.sm, bottom: FeSpace.xs),
      child: Semantics(header: true, child: Text(text, style: t.titleSmall)),
    );
    Widget note(String text) => Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: Text(text, style: t.bodySmall?.copyWith(color: c.textSecondary)),
    );

    if (a.isEmpty) {
      return FeEmptyState(
        key: Key('analysis.empty.$entityId'),
        icon: Icons.biotech_outlined,
        body: l.analysisEmpty,
        compact: true,
      );
    }

    return Column(
      key: Key('analysis.$entityId'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeBanner(
          icon: Icons.science_outlined,
          text: l.analysisIntro,
          tone: FeBannerTone.review,
        ),
        // 1. Namunalar (biologik ob’ektlar).
        subheader(l.analysisSpecimensTitle),
        if (a.specimens.isEmpty)
          FeEmptyState(
            key: Key('analysis.noSpecimens.$entityId'),
            icon: Icons.water_drop_outlined,
            body: l.analysisNoSpecimens,
            compact: true,
          )
        else ...[
          note(l.analysisSpecimensNote),
          for (final s in a.specimens)
            AnalysisRow(
              // Eski kalit saqlanadi (testlar va chuqur havolalar).
              key: Key('measured.$entityId.${s.specimenId}'),
              icon: Icons.water_drop_outlined,
              title: sName(s.specimenId),
              details: [
                if (s.methodIds.isNotEmpty)
                  l.analysisSpecimenMethods(names(s.methodIds, kName)),
                if (s.basisIds.length > 1)
                  l.analysisSourcedRecords(s.basisIds.length),
              ],
              claim: s.basisClaims.firstOrNull,
              onTap: () => context.push(Routes.specimen(s.specimenId)),
            ),
        ],
        // 2. Skrining (taxminiy) — tasdiqlash shart.
        if (a.screenings.isNotEmpty) ...[
          subheader(l.analysisScreeningTitle),
          FeBanner(
            icon: Icons.warning_amber_rounded,
            text: l.analysisScreeningNote,
            tone: FeBannerTone.critical,
          ),
          const SizedBox(height: FeSpace.xs),
          for (final s in a.screenings)
            AnalysisRow(
              key: Key('screened.$entityId.${s.screeningId}'),
              icon: Icons.filter_alt_outlined,
              title: kName(s.screeningId),
              details: [
                if (s.confirmationMethodIds.isNotEmpty)
                  l.analysisConfirmedBy(names(s.confirmationMethodIds, kName)),
              ],
              claim: s.basisClaims.firstOrNull,
              onTap: () => context.push(Routes.knowledgeEntry(s.screeningId)),
            ),
        ],
        // 3. Tasdiqlovchi metodlar (skrining → tasdiqlash).
        if (a.confirmationMethods.isNotEmpty) ...[
          subheader(l.analysisConfirmationTitle),
          for (final m in a.confirmationMethods)
            AnalysisRow(
              key: Key('analysis.confirm.$entityId.${m.methodId}'),
              icon: Icons.science_outlined,
              title: kName(m.methodId),
              details: [
                l.analysisAfterScreening(names(m.afterScreeningIds, kName)),
              ],
              claim: m.basisClaims.firstOrNull,
              onTap: () => context.push(Routes.knowledgeEntry(m.methodId)),
            ),
        ],
        // 4. Manbalardagi tahlil metodlari (modda darajasida).
        if (a.analyticalMethods.isNotEmpty) ...[
          subheader(l.analysisMethodsTitle),
          // Bitta izoh: «namunaga bog‘lanmagan» + «tasdiqlangan protsedura
          // emas» — ikki alohida banner/izoh o‘rniga.
          if (!a.methodsLinkedToSpecimens) ...[
            FeBanner(
              key: Key('analysis.notPaired.$entityId'),
              icon: Icons.info_outline,
              text:
                  '${l.analysisMethodsNotPaired} '
                  '${l.analysisMethodsRoleNote}',
            ),
            const SizedBox(height: FeSpace.xs),
          ] else
            note(l.analysisMethodsRoleNote),
          for (final m in a.analyticalMethods)
            AnalysisRow(
              key: Key('analysis.method.$entityId.${m.methodId}'),
              icon: Icons.biotech_outlined,
              title: kName(m.methodId),
              details: [
                if (m.basisIds.length > 1)
                  l.analysisSourcedRecords(m.basisIds.length),
              ],
              claim: m.basisClaims.firstOrNull,
              onTap: () => context.push(Routes.knowledgeEntry(m.methodId)),
            ),
        ],
        // 5. Izlanadigan metabolitlar.
        if (a.metabolites.isNotEmpty) ...[
          subheader(l.analysisMetabolitesTitle),
          for (final m in a.metabolites)
            Builder(
              builder: (context) {
                final r = m.relation;
                final entry = r.metaboliteId == null
                    ? null
                    : library.byId(r.metaboliteId!);
                return AnalysisRow(
                  key: Key('analysis.metabolite.$entityId.${r.id}'),
                  icon: Icons.subdirectory_arrow_right,
                  title: entry?.name.resolve(lang) ?? r.metaboliteName,
                  titleLocale: entry == null ? const Locale('en') : null,
                  details: [
                    l.metaboliteKindLabel(r.kind),
                    if (m.specimenIds.isNotEmpty)
                      l.analysisMetaboliteSpecimens(
                        names(m.specimenIds, sName),
                      ),
                  ],
                  claim: m.basisClaim,
                  // Kutubxonada yozuvi bo‘lmasa — faqat manba tugmasi.
                  onTap: entry == null
                      ? null
                      : () => context.push(Routes.libraryEntry(entry.id)),
                );
              },
            ),
        ],
      ],
    );
  }
}

/// Tahlil qatori: ikonka, nom, izoh qatorlari, asos claim holati + dalil
/// darajasi, manba tugmasi va (bo‘lsa) sahifaga o‘tish.
class AnalysisRow extends StatelessWidget {
  const AnalysisRow({
    super.key,
    required this.icon,
    required this.title,
    this.details = const [],
    this.claim,
    this.onTap,
    this.titleLocale,
  });

  final IconData icon;
  final String title;
  final Locale? titleLocale;
  final List<String> details;

  /// Bog‘lanish asosi (manbali claim). Holat va dalil darajasi shundan.
  final ClaimView? claim;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: FeSpace.xs),
      child: FeCard(
        padding: const EdgeInsets.fromLTRB(
          FeSpace.sm,
          FeSpace.xs,
          FeSpace.xxs,
          FeSpace.xs,
        ),
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 20, color: c.accent),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    locale: titleLocale,
                    style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  for (final d in details)
                    Text(
                      d,
                      style: t.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  if (claim case final cl?) ...[
                    const SizedBox(height: 2),
                    ClaimMeta(status: cl.status, level: cl.evidenceLevel),
                  ],
                ],
              ),
            ),
            if (claim case final cl?)
              IconButton(
                key: Key('analysis.source.${cl.claimId}'),
                tooltip: l.analysisShowSource,
                icon: const Icon(Icons.format_quote_outlined, size: 20),
                onPressed: () => showProvenanceSheet(context, cl),
              ),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 20, color: c.textSecondary),
          ],
        ),
      ),
    );
  }
}
