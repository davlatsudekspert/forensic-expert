import '../../core/l10n/generated/app_localizations.dart';
import '../../domain/evidence/citation_format.dart';
import '../../domain/evidence/content_translations.dart';
import '../../domain/pro/analysis_plan.dart';
import '../evidence/presentation/localized_content.dart'
    show translationStatusLabel;
import '../evidence/presentation/source_quote.dart' show localizedSectionRef;
import 'pro_strings.dart';

/// Rejani to‘liq iqtiboslar bilan oddiy matnga aylantiradi (xulosaga qo‘yish
/// yoki nusxalash uchun). Hech narsa qo‘shilmaydi: har satr — paketdagi
/// iqtibos, raqamli manba havolasi va aniq joyi, holati va dalil darajasi.
/// Manbalar ro‘yxati mavjud iqtibos formatlovchisi bilan
/// ([formatReferenceList]).
String buildAnalysisPlanText({
  required AppLocalizations l,
  required AnalysisPlan plan,
  required String title,
  required String lang,
  required String Function(String id) nameOf,
  required ContentTranslations translations,
  CitationStyle? style,
}) {
  final sources = plan.allSources;
  final number = {for (final (i, s) in sources.indexed) s.sourceId: i + 1};
  final out = StringBuffer()
    ..writeln(l.planExportHeader(title))
    ..writeln(l.planExportDisclaimer)
    ..writeln();

  String quoteLines(PlanQuote q) {
    final b = StringBuffer();
    final role = l.planRole(q.role);
    final shown = q.texts.isNotEmpty
        ? (q.texts[lang] ?? q.texts['en'] ?? q.text)
        : null;
    final content = shown == null
        ? translations.resolve(q.kind, q.id, source: q.text, lang: lang)
        : null;
    final text = shown ?? content!.text;
    final ref = StringBuffer();
    if (q.source case final s?) {
      ref.write('[${number[s.sourceId]}');
      if (q.locator != null) {
        ref.write(', ${localizedSectionRef(l, q.locator!)}');
      }
      ref.write(']');
    } else {
      ref.write('[${l.planNoSource}]');
    }
    final about = q.aboutId == null
        ? ''
        : ' (${l.planAbout(nameOf(q.aboutId!))})';
    b.write('  • $role$about: «$text» $ref');
    if (content != null && content.isTranslation) {
      b.write(' (${translationStatusLabel(l, content.status!)})');
    }
    b
      ..write(' (${l.planExportStatus(l.reviewStatusName(q.status), q.level)})')
      ..writeln();
    if (content != null && content.isTranslation) {
      b.writeln('    ${l.planExportOriginal}: «${content.original}»');
    }
    return b.toString();
  }

  void section(int n, String heading, Iterable<String> lines, String empty) {
    out.writeln('$n. ${heading.toUpperCase()}');
    final list = lines.toList();
    if (list.isEmpty) {
      out.writeln('  – $empty');
    } else {
      list.forEach(out.write);
    }
    out.writeln();
  }

  section(1, l.planSecSpecimens, [
    for (final s in plan.specimens) ...[
      '  ${nameOf(s.specimenId)}\n',
      for (final q in s.basis.take(1)) quoteLines(q),
      for (final q in s.notes)
        if (q.role == PlanRole.use) quoteLines(q),
    ],
  ], l.planNoSpecimens);
  section(2, l.planSecPresumptive, [
    for (final s in plan.presumptive) ...[
      '  ${nameOf(s.screeningId)}'
          '${s.principle.isEmpty ? '' : ' — ${l.planPrinciple(translations.resolve(ContentTextKind.screeningField, '${s.screeningId}#principle', source: s.principle, lang: lang).text)}'}\n',
      if (!s.supportsDefinitive) '  ${l.planNotDefinitive}\n',
      for (final q in s.quotes) quoteLines(q),
      if (s.reagents.isEmpty)
        '  – ${l.planNoReagents}\n'
      else
        for (final r in s.reagents) ...[
          '  ${l.planReagentsLabel}: ${nameOf(r.reagentId)}\n',
          for (final q in r.quotes) quoteLines(q),
        ],
    ],
  ], l.planNoPresumptive);
  String methodLines(Iterable<PlanMethod> ms) => [
    for (final m in ms)
      '  ${nameOf(m.methodId)}'
          '${m.afterScreeningIds.isEmpty ? '' : ' — ${l.analysisAfterScreening(m.afterScreeningIds.map(nameOf).join(', '))}'}\n'
          '${m.quotes.map(quoteLines).join()}',
  ].join();
  section(
    3,
    l.planSecBench,
    [methodLines(plan.bench)].where((s) => s.isNotEmpty),
    l.planNoBench,
  );
  section(
    4,
    '${l.planSecConfirmation} (${l.planConfirmRequired})',
    [methodLines(plan.confirmation)].where((s) => s.isNotEmpty),
    l.planNoConfirmation,
  );
  section(
    5,
    l.planSecInstrumental,
    [methodLines(plan.instrumental)].where((s) => s.isNotEmpty),
    l.planNoInstrumental,
  );
  section(
    6,
    l.planSecInterferences,
    plan.interferences.map(quoteLines),
    l.planNoInterferences,
  );
  section(7, l.planSecLimits, plan.limits.map(quoteLines), l.planNoLimits);
  section(8, l.planSecReminder, [
    for (final r in plan.reminders) ...[
      '  ${r.allowed ? '✓' : '✗'} ${planReminderText(l, r, nameOf)}\n',
      for (final q in r.quotes) quoteLines(q),
    ],
  ], l.planRemNoData);
  out.writeln(l.planReminderFootnote);
  if (sources.isNotEmpty) {
    out
      ..writeln()
      ..writeln(l.planExportSources)
      ..writeln(
        formatReferenceList(
          [for (final s in sources) CitationData.fromSource(s)],
          style ?? defaultCitationStyle(lang),
          lang: citationLangOf(lang),
        ),
      );
  }
  return out.toString().trimRight();
}
