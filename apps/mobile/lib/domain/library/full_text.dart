/// Ochiq kirishdagi (open access) maqolaning to‘liq matni — faqat
/// PubMed Central’dagi maqolalar uchun, Europe PMC’ning rasmiy PDF manzili.
/// Pullik jurnal maqolalari uchun havola qaytarilmaydi (mualliflik huquqi);
/// PDF ilovaga joylanmaydi — foydalanuvchi qurilmasida ochiladi.
library;

import 'library_models.dart';

final _pmcid = RegExp(r'PMC(\d{4,10})', caseSensitive: false);

/// `PMC8400298` yoki `null`.
String? pmcidOf(SourceView s) {
  for (final text in [s.sourceId, s.url ?? '']) {
    final m = _pmcid.firstMatch(text);
    if (m != null) return 'PMC${m.group(1)}';
  }
  return null;
}

/// `https://europepmc.org/articles/PMCxxxx?pdf=render` yoki `null`.
Uri? openAccessPdfUrl(SourceView s) {
  final id = pmcidOf(s);
  return id == null
      ? null
      : Uri.https('europepmc.org', '/articles/$id', {'pdf': 'render'});
}
