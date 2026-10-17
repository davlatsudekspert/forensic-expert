import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/design/theme.dart';
import '../../../core/design/tokens.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/fe_components.dart';
import '../../../domain/knowledge/method_short_name.dart';
import '../../../domain/library/library_models.dart';
import '../../evidence/presentation/localized_content.dart';

/// «Qisqacha» — modda sahifasi tepasidagi ixcham xulosa.
///
/// Yangi ma’lumot YO‘Q: faqat sahifadagi manbali bo‘limlardan (identifikatsiya
/// claim’i, «Tahlil» graf bog‘lanishlari, konsentratsiya claim’lari, manbalar)
/// nomlar va sonlar yig‘iladi. Har qator o‘sha bo‘limga olib boradi — iqtibos,
/// holat va manba bo‘lim ichida.
class SubstanceGlanceCard extends ConsumerWidget {
  const SubstanceGlanceCard({
    super.key,
    required this.entry,
    required this.onJump,
  });

  final LibraryEntry entry;

  /// Sahifa ichidagi bo‘limga o‘tish (`analysis`, `identity`,
  /// `reported_concentration`, `sources`).
  final ValueChanged<String> onJump;

  static const _maxNames = 3;
  static const _maxChips = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final d = entry.details!;
    final a = ref.watch(substanceAnalysisProvider(entry.id));
    final knowledge = ref.watch(knowledgeRepositoryProvider);
    final library = ref.watch(libraryRepositoryProvider);
    final index = ref.watch(provenanceIndexProvider);

    String names(List<String> all) {
      if (all.length <= _maxNames) return all.join(FeGlyphs.listSeparator);
      return '${all.take(_maxNames).join(FeGlyphs.listSeparator)}'
          '${FeGlyphs.middleDot}${l.rdGlanceMore(all.length - _maxNames)}';
    }

    final identity = d.claims.where((x) => x.field == 'identity').firstOrNull;
    final formula = identity?.value['molecular_formula'];
    final weight = identity?.value['molecular_weight'];
    final specimens = [
      for (final s in a.specimens)
        index.specimen(s.specimenId)?.names.resolve(lang) ?? s.specimenId,
    ];
    final methods = [
      for (final id in a.allMethodIds)
        knowledge.byId(id)?.name.resolve(lang) ?? id,
    ];
    // Usullar — qisqa nom chiplari (GC-MS, LC-MS/MS…); to‘liq nom «Tahlil»
    // bo‘limida va semantik yorliqda.
    final methodChips = <String>{for (final m in methods) methodShortName(m)}
        .toList();
    // Kutubxonada yozuvi yo‘q metabolit — manbadagi nom (`metabolite_name`
    // tarjimasi bo‘lsa — u); UI tilida bo‘lmasa, qator oxirida ochiq belgi.
    final translations = ref.watch(contentTranslationsProvider);
    var metaboliteOriginal = <String>{};
    final metabolites = [
      for (final m in a.metabolites)
        (m.relation.metaboliteId == null
                ? null
                : library.byId(m.relation.metaboliteId!)?.name.resolve(lang)) ??
            () {
              final r = translations.resolve(
                ContentTextKind.metaboliteName,
                m.relation.id,
                source: m.relation.metaboliteName,
                sameTextKinds: const {ContentTextKind.listItem},
                lang: lang,
              );
              if (r.missingTranslation) {
                metaboliteOriginal = {...metaboliteOriginal, r.originalLang};
              }
              return r.text;
            }(),
    ];
    final concentrations = d.claims
        .where((x) => x.field == 'reported_concentration')
        .length;
    final sources = d.allSources.length;

    // (kalit, ikonka, sarlavha, qiymat, bo‘lim)
    final rows = <(String, IconData, String, String, String)>[
      if (formula != null)
        (
          'formula',
          Icons.science_outlined,
          l.rdGlanceFormula,
          [
            '$formula',
            if (weight != null) l.rdGlanceMolarMass('$weight'),
          ].join(FeGlyphs.middleDot),
          'identity',
        ),
      if (specimens.isNotEmpty)
        (
          'specimens',
          Icons.water_drop_outlined,
          l.rdGlanceSpecimens,
          names(specimens),
          'analysis',
        ),
      if (methods.isNotEmpty)
        (
          'methods',
          Icons.biotech_outlined,
          l.rdGlanceMethods,
          methods.join(FeGlyphs.listSeparator),
          'analysis',
        ),
      if (metabolites.isNotEmpty)
        (
          'metabolites',
          Icons.subdirectory_arrow_right,
          l.rdGlanceMetabolites,
          [
            names(metabolites),
            for (final o in metaboliteOriginal)
              '(${l.trInOriginalLanguage(contentLanguageName(l, o))})',
          ].join(' '),
          'analysis',
        ),
      if (concentrations > 0)
        (
          'concentrations',
          Icons.show_chart,
          l.rdGlanceConcentrations,
          l.rdGlanceRecords(concentrations),
          'reported_concentration',
        ),
      (
        'sources',
        Icons.format_quote_outlined,
        l.rdGlanceSources,
        l.rdSourcesCount(sources),
        'sources',
      ),
    ];

    return FeCard(
      key: Key('entry.glance.${entry.id}'),
      padding: const EdgeInsets.fromLTRB(
        FeSpace.sm,
        FeSpace.sm,
        FeSpace.xxs,
        FeSpace.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: FeSpace.xs),
            child: Semantics(
              header: true,
              child: Text(l.rdGlanceTitle, style: t.titleSmall),
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(right: FeSpace.xs),
            child: Text(
              l.rdGlanceNote,
              style: t.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
          const SizedBox(height: FeSpace.xxs),
          for (final (key, icon, label, value, target) in rows)
            _GlanceRow(
              key: Key('entry.glance.row.$key'),
              icon: icon,
              label: label,
              value: value,
              chips: key == 'methods'
                  ? [
                      ...methodChips.take(_maxChips),
                      if (methodChips.length > _maxChips)
                        l.rdGlanceMore(methodChips.length - _maxChips),
                    ]
                  : null,
              hint: l.rdJumpTo,
              onTap: () => onJump(target),
            ),
        ],
      ),
    );
  }
}

class _GlanceRow extends StatelessWidget {
  const _GlanceRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
    this.chips,
  });

  final IconData icon;
  final String label;

  /// To‘liq qiymat (ekran o‘quvchisi uchun ham).
  final String value;

  /// Berilsa — qiymat o‘rniga ixcham chiplar (to‘liq [value] semantikada).
  final List<String>? chips;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    final t = Theme.of(context).textTheme;
    final chips = this.chips;
    return Semantics(
      button: true,
      hint: hint,
      label: chips == null ? null : '$label: $value',
      excludeSemantics: chips != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FeRadius.sm),
        child: ConstrainedBox(
          // Kamida 48 dp bosish maydoni.
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: FeSpace.xxs),
            child: Row(
              children: [
                Icon(icon, size: 18, color: c.accent),
                const SizedBox(width: FeSpace.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: t.labelMedium?.copyWith(color: c.textSecondary),
                      ),
                      if (chips == null)
                        Text(
                          value,
                          style: t.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.only(top: FeSpace.xxs),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final chip in chips) _MiniChip(label: chip),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: c.textSecondary),
                const SizedBox(width: FeSpace.xxs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bosilmaydigan ixcham belgi (qator o‘zi bosiladi).
class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = FeTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(FeRadius.sm),
        border: Border.all(color: c.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w600, height: 1.2),
        ),
      ),
    );
  }
}
