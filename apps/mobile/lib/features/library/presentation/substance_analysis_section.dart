import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/pro_tools.dart';
import '../../../app/providers.dart';
import '../../../app/routes.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/evidence/substance_analysis.dart';
import '../../../domain/library/library_models.dart';
import '../../evidence/presentation/localized_content.dart';
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

    // «Tahlil» — egasi belgilagan 3 bo‘lim (2026-10-17): 1) test (ekspress /
    // skrining), 2) sifat reaksiyalari (rangli reaktivlar), 3) miqdoriy
    // aniqlash (GC-MS, LC-MS/MS, spektrofotometriya). Har bir bo‘lim faqat
    // paketdagi manbali yozuvlardan yig‘iladi; yozuv bo‘lmasa — halol bo‘sh
    // holat («manba kerak»), hech narsa to‘qilmaydi. Tasdiqlangan manba
    // (ustoz kitoblari) yozuvlari har bo‘limda birinchi, keyin adabiyot
    // (xalqaro maqola, UNODC, SWGDRUG) — har biri o‘z holati va dalil
    // darajasi bilan (ClaimCard).
    final own = visibleClaims(
      library.byId(entityId)?.details?.claims ?? const <ClaimView>[],
      lang,
    );
    // Graf qatori allaqachon asos qilib ko‘rsatgan `analytical_method` yozuvi
    // ikkinchi marta karta bo‘lib chiqmaydi.
    final graphBasis = <String>{
      for (final m in a.analyticalMethods) ...m.basisIds,
      for (final m in a.confirmationMethods) ...m.basisIds,
      for (final s in a.screenings) ...s.basisIds,
    };
    final sectionClaims = [
      for (final s in [1, 2, 3])
        analysisSectionClaims(
          own,
          s,
          skipIds: s == 3 ? graphBasis : const <String>{},
        ),
    ];

    // Graf qatorlari ham egasi tartibida bo‘linadi: rangli / mikrokristall
    // sinamalar va TLC — «Sifat reaksiyalari»; qolgan skrining testlari —
    // «Test»; instrumental / spektrofotometrik metodlar — «Miqdoriy aniqlash».
    final screeningsTest = [
      for (final s in a.screenings)
        if (!analysisQualitativeScreeningIds.contains(s.screeningId)) s,
    ];
    final screeningsQual = [
      for (final s in a.screenings)
        if (analysisQualitativeScreeningIds.contains(s.screeningId)) s,
    ];
    final methodsQual = [
      for (final m in a.analyticalMethods)
        if (analysisQualitativeMethodIds.contains(m.methodId)) m,
    ];
    final methodsQuant = [
      for (final m in a.analyticalMethods)
        if (!analysisQualitativeMethodIds.contains(m.methodId)) m,
    ];

    Widget claimList(List<ClaimView> claims) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final cl in claims)
          Padding(
            padding: const EdgeInsets.only(bottom: FeSpace.xs),
            // Namuna tayyorlash kabi «usul rejimi» yozuvlari yorlig‘i bilan
            // (ular bu sahifada faqat shu yerda, «Usul rejimi»da takrorlanmaydi).
            child: methodRecordFields.contains(cl.field)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: FeSpace.xxs),
                        child: Text(
                          methodRecordLabel(l, cl.field),
                          key: Key('methodRecord.label.${cl.claimId}'),
                          style: t.labelLarge,
                        ),
                      ),
                      ClaimCard(claim: cl),
                    ],
                  )
                : ClaimCard(claim: cl),
          ),
      ],
    );
    Widget section(
      int n,
      String title,
      String intro, {
      required bool empty,
      required List<Widget> children,
    }) => Column(
      key: Key('analysis.s$n.$entityId'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        subheader(title),
        note(intro),
        if (empty)
          FeEmptyState(
            key: Key('analysis.s$n.empty.$entityId'),
            icon: Icons.menu_book_outlined,
            body: l.analysisSectionEmpty,
            compact: true,
          )
        else
          ...children,
      ],
    );

    return Column(
      key: Key('analysis.$entityId'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeBanner(
          icon: Icons.science_outlined,
          text: l.analysisIntro,
          tone: FeBannerTone.review,
        ),
        // Pro: shu moddaning to‘liq tahlil rejasi (bepulda qisqa ko‘rinish).
        if (!a.isEmpty) AnalysisPlanEntry(entityId: entityId),
        // 1. Test (ekspress / skrining).
        section(
          1,
          l.analysisS1Title,
          l.analysisS1Note,
          empty: sectionClaims[0].isEmpty && screeningsTest.isEmpty,
          children: [
            if (screeningsTest.isNotEmpty) ...[
              FeBanner(
                icon: Icons.warning_amber_rounded,
                text: l.analysisScreeningNote,
                tone: FeBannerTone.critical,
              ),
              const SizedBox(height: FeSpace.xs),
              for (final s in screeningsTest)
                AnalysisRow(
                  key: Key('screened.$entityId.${s.screeningId}'),
                  icon: Icons.filter_alt_outlined,
                  title: kName(s.screeningId),
                  details: [
                    if (s.confirmationMethodIds.isNotEmpty)
                      l.analysisConfirmedBy(
                        names(s.confirmationMethodIds, kName),
                      ),
                  ],
                  claim: s.basisClaims.firstOrNull,
                  onTap: () =>
                      context.push(Routes.knowledgeEntry(s.screeningId)),
                ),
            ],
            claimList(sectionClaims[0]),
          ],
        ),
        // 2. Sifat reaksiyalari (rangli reaktivlar va boshqa taxminiy sinamalar).
        section(
          2,
          l.analysisS2Title,
          l.analysisS2Note,
          empty:
              sectionClaims[1].isEmpty &&
              screeningsQual.isEmpty &&
              methodsQual.isEmpty,
          children: [
            claimList(sectionClaims[1]),
            for (final s in screeningsQual)
              AnalysisRow(
                key: Key('screened.$entityId.${s.screeningId}'),
                icon: Icons.filter_alt_outlined,
                title: kName(s.screeningId),
                details: [
                  if (s.confirmationMethodIds.isNotEmpty)
                    l.analysisConfirmedBy(
                      names(s.confirmationMethodIds, kName),
                    ),
                ],
                claim: s.basisClaims.firstOrNull,
                onTap: () => context.push(Routes.knowledgeEntry(s.screeningId)),
              ),
            for (final m in methodsQual)
              AnalysisRow(
                key: Key('analysis.method.$entityId.${m.methodId}'),
                icon: Icons.biotech_outlined,
                title: kName(m.methodId),
                claim: m.basisClaims.firstOrNull,
                onTap: () => context.push(Routes.knowledgeEntry(m.methodId)),
              ),
          ],
        ),
        // 3. Miqdoriy aniqlash (GC-MS, LC-MS/MS, spektrofotometriya …).
        section(
          3,
          l.analysisS3Title,
          l.analysisS3Note,
          empty:
              sectionClaims[2].isEmpty &&
              a.confirmationMethods.isEmpty &&
              methodsQuant.isEmpty,
          children: [
            claimList(sectionClaims[2]),
            // Skriningdan keyingi tasdiqlovchi metodlar.
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
            // Manbalardagi tahlil metodlari (modda darajasida).
            if (methodsQuant.isNotEmpty) ...[
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
              for (final m in methodsQuant)
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
          ],
        ),
        // Namunalar (biologik ob’ektlar) va metabolitlar — 3 bo‘limdan keyin.
        if (!a.isEmpty) ...[
          // Namunalar (biologik ob’ektlar) — adabiyotdan.
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
                  // Kutubxonada yozuvi yo‘q metabolit — manbadagi nom
                  // (`metabolite_name` tarjimasi bo‘lsa — u, aks holda asl).
                  final name = entry == null
                      ? ref
                            .watch(contentTranslationsProvider)
                            .resolve(
                              ContentTextKind.metaboliteName,
                              r.id,
                              source: r.metaboliteName,
                              sameTextKinds: const {ContentTextKind.listItem},
                              lang: lang,
                            )
                      : null;
                  return AnalysisRow(
                    key: Key('analysis.metabolite.$entityId.${r.id}'),
                    icon: Icons.subdirectory_arrow_right,
                    title: entry?.name.resolve(lang) ?? name!.text,
                    titleLocale: name == null ? null : Locale(name.textLang),
                    details: [
                      if (name != null && name.missingTranslation)
                        l.trInOriginalLanguage(
                          contentLanguageName(l, name.originalLang),
                        ),
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
      ],
    );
  }
}

/// «Tahlil» bo‘limlari bo‘yicha claim maydonlari (egasi tartibi, 2026-10-17):
/// 1 — test (ekspress / skrining); 2 — sifat reaksiyalari (rangli reaktivlar
/// va boshqa taxminiy sinamalar); 3 — miqdoriy / instrumental aniqlash.
/// Maydon ro‘yxatda bo‘lmasa, claim «Tahlil»ga kirmaydi (boshqa bo‘limda
/// ko‘rsatiladi). Ro‘yxat tartibi — ko‘rsatish tartibi.
const analysisSectionFields = <int, List<String>>{
  1: ['express_test', 'immunoassay_screen', 'odour_test'],
  2: [
    'colour_test',
    'chemical_test',
    'microcrystal_test',
    'tlc_system',
    'melting_point',
    'method_caveat',
  ],
  3: [
    'confirmatory_method',
    'analytical_method',
    'sample_preparation',
    'uv_spectrum',
    'photometric_assay',
    'spectroscopy',
  ],
};

/// [section] (1–3) uchun [claims] dan tanlanadi: maydon tartibida; har
/// maydon ichida tasdiqlangan manba (ustoz kitoblari, to‘liq matni bilan)
/// birinchi, keyin adabiyot yozuvlari. [skipIds] — boshqa qatorda allaqachon
/// asos sifatida ko‘rsatilgan `analytical_method` claim’lari (ikki marta
/// chiqmasligi uchun; boshqa maydonlarda to‘liq matn kartasi saqlanadi).
List<ClaimView> analysisSectionClaims(
  List<ClaimView> claims,
  int section, {
  Set<String> skipIds = const {},
}) {
  final result = <ClaimView>[];
  for (final f in analysisSectionFields[section] ?? const <String>[]) {
    final ofField = [
      for (final cl in claims)
        if (cl.field == f &&
            !(f == 'analytical_method' && skipIds.contains(cl.claimId)))
          cl,
    ];
    result.addAll(
      ofField.where((c) => c.fromConfirmedSource && c.hasStatement),
    );
    result.addAll(ofField.where((c) => !c.fromConfirmedSource));
  }
  return result;
}

/// Graf: «Sifat reaksiyalari» ga tegishli skrining testlari va metodlar
/// (qolgan skrining testlari «Test», qolgan metodlar «Miqdoriy aniqlash»da).
const analysisQualitativeScreeningIds = {
  'scr-colour-tests',
  'scr-microcrystal-tests',
};
const analysisQualitativeMethodIds = {'method-tlc'};

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
                    ClaimMeta(
                      status: cl.status,
                      level: cl.evidenceLevel,
                      confirmedSource: cl.fromConfirmedSource,
                    ),
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

/// «Tahlil rejasi» kirish kartasi. Bepul foydalanuvchi ham ko‘radi (Pro
/// belgisi bilan) — sahifada qisqa ko‘rinish va tariflar taklifi.
class AnalysisPlanEntry extends ConsumerWidget {
  const AnalysisPlanEntry({super.key, required this.entityId});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final unlocked = ref.watch(proToolsUnlockedProvider);
    return Padding(
      padding: const EdgeInsets.only(top: FeSpace.sm),
      child: FeCard(
        key: Key('analysis.plan.entry.$entityId'),
        onTap: () => context.push(Routes.homePlan(entityId)),
        padding: const EdgeInsets.all(FeSpace.sm),
        child: Row(
          children: [
            Icon(Icons.route_outlined, color: c.accent),
            const SizedBox(width: FeSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.planEntryTitle,
                    style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    l.planEntryBody,
                    style: t.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            if (!unlocked) ...[
              Icon(Icons.lock_outline, size: 14, color: c.textSecondary),
              const SizedBox(width: 3),
              Text(
                l.lockedBadge,
                style: t.labelSmall?.copyWith(color: c.textSecondary),
              ),
            ],
            Icon(Icons.chevron_right, size: 20, color: c.textSecondary),
          ],
        ),
      ),
    );
  }
}
