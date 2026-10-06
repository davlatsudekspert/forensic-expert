/// Ilmiy yozuv / manbani ulashish matni. Faqat ommaviy bibliografik
/// ma’lumot (sarlavha, jurnal, yil, DOI/PMID/URL) — profil, ish (case),
/// eslatma yoki hujjat ma’lumoti hech qachon qo‘shilmaydi.
library;

import '../library/library_models.dart';

/// Manbaning ommaviy havolasi (faqat HTTPS): DOI → PubMed → URL.
String? publicSourceUrl(SourceView s) {
  final doi = s.doi?.trim();
  if (doi != null && doi.isNotEmpty) return 'https://doi.org/$doi';
  final pmid = s.pmid?.trim();
  if (pmid != null && RegExp(r'^\d+$').hasMatch(pmid)) {
    return 'https://pubmed.ncbi.nlm.nih.gov/$pmid/';
  }
  final url = Uri.tryParse(s.url ?? '');
  if (url != null && url.scheme == 'https' && url.host.isNotEmpty) {
    return url.toString();
  }
  return null;
}

String _citation(SourceView s) {
  final meta = [
    if (s.journal != null && s.journal!.trim().isNotEmpty) s.journal!.trim(),
    if (s.organization != null && s.journal == null) s.organization!.trim(),
    if (s.year != null) '${s.year}',
  ].join(', ');
  return meta.isEmpty ? s.title : '${s.title} ($meta)';
}

String _bullet(SourceView s) {
  final url = publicSourceUrl(s);
  return url == null ? '• ${_citation(s)}' : '• ${_citation(s)} — $url';
}

String sourceShareText(SourceView s, {required String footer, Uri? appLink}) {
  final url = publicSourceUrl(s);
  return [
    _citation(s),
    ?url,
    if (appLink != null) appLink.toString(),
    '',
    footer,
  ].join('\n');
}

String recordShareText({
  required String title,
  required List<SourceView> sources,
  required String sourcesLabel,
  required String footer,
  Uri? appLink,
  int maxSources = 3,
}) {
  final seen = <String>{};
  final picked = [
    for (final s in sources)
      if (seen.add(s.sourceId)) s,
  ].take(maxSources);
  return [
    title,
    if (appLink != null) appLink.toString(),
    if (picked.isNotEmpty) ...[
      '',
      '$sourcesLabel:',
      for (final s in picked) _bullet(s),
    ],
    '',
    footer,
  ].join('\n');
}
