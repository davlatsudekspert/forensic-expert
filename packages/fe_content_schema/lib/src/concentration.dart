/// Konsentratsiya yozuvlari toifasi.
///
/// **Ataylab** «fatal threshold» degan toifa yo‘q: konsentratsiyaning o‘zi
/// o‘lim sababini isbotlamaydi (`docs/00_ARXITEKTURA_REJASI.md`, 9-bo‘lim).
enum ConcentrationCategory {
  therapeuticReference('therapeutic_reference'),
  toxicReference('toxic_reference'),
  reportedPostmortem('reported_postmortem'),
  reportedImpairment('reported_impairment');

  const ConcentrationCategory(this.code);

  final String code;

  static ConcentrationCategory? tryParse(String code) {
    for (final c in values) {
      if (c.code == code) return c;
    }
    return null;
  }
}

/// Konsentratsiya claim’ida majburiy kontekst maydonlari (6.6-bo‘lim).
abstract final class ConcentrationContract {
  static const String field = 'concentration';

  static const requiredKeys = <String>[
    'category',
    'matrix',
    'population',
    'value_type',
    'unit',
  ];

  /// Ruxsat etilmagan toifa kalitlari.
  static const forbiddenCategories = <String>{
    'fatal',
    'fatal_threshold',
    'lethal',
    'lethal_threshold',
  };
}
