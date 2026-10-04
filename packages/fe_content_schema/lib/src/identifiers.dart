import 'package:meta/meta.dart';

/// Tashqi identifikator sxemalari.
///
/// CAS ham shu ro‘yxatda — lekin **ilova uni ishlatish-ishlatmasligini
/// [IdentifierPolicy] belgilaydi**, sxema emas. Shu tufayli CAS bo‘yicha
/// qaror o‘zgarsa, kod va sxema o‘zgarmaydi — faqat siyosat konfiguratsiyasi.
enum IdentifierScheme {
  pubchemCid('pubchem_cid'),
  inchiKey('inchikey'),
  chebi('chebi'),
  drugbankOpen('drugbank_open'),
  cas('cas_rn');

  const IdentifierScheme(this.code);

  final String code;
}

/// Bitta yozuvga tegishli tashqi identifikator.
@immutable
class ExternalIdentifier {
  const ExternalIdentifier({
    required this.scheme,
    required this.value,
    required this.sourceId,
  });

  final IdentifierScheme scheme;
  final String value;

  /// Identifikator qaysi manbadan olingani (provenance).
  final String sourceId;
}

/// Identifikatordan qanday foydalanish mumkinligi.
@immutable
class IdentifierUsage {
  const IdentifierUsage({
    required this.store,
    required this.display,
    required this.search,
  });

  /// Hech qanday foydalanish yo‘q.
  static const none = IdentifierUsage(
    store: false,
    display: false,
    search: false,
  );

  /// To‘liq foydalanish.
  static const full = IdentifierUsage(store: true, display: true, search: true);

  final bool store;
  final bool display;
  final bool search;
}

/// Identifikatorlar siyosati — **konfiguratsiya**, qotirilgan qoida emas.
///
/// Default holat ehtiyotkor: CAS bo‘yicha yakuniy huquqiy xulosa
/// chiqmaguncha (egasining qarori bilan) CAS saqlanmaydi, ko‘rsatilmaydi
/// va qidiruvga qo‘shilmaydi. Qaror o‘zgarsa, siyosat kontent paketi yoki
/// remote config orqali yangilanadi.
@immutable
class IdentifierPolicy {
  const IdentifierPolicy(this._usage);

  /// PHASE 1 default siyosati.
  factory IdentifierPolicy.conservativeDefault() => const IdentifierPolicy({
    IdentifierScheme.pubchemCid: IdentifierUsage.full,
    IdentifierScheme.inchiKey: IdentifierUsage.full,
    IdentifierScheme.chebi: IdentifierUsage.full,
    IdentifierScheme.drugbankOpen: IdentifierUsage.full,
    IdentifierScheme.cas: IdentifierUsage.none,
  });

  /// JSON konfiguratsiyadan (masalan, kontent paketidagi `policy.json`).
  factory IdentifierPolicy.fromJson(Map<String, Object?> json) {
    final base = IdentifierPolicy.conservativeDefault()._usage;
    final result = Map<IdentifierScheme, IdentifierUsage>.of(base);
    for (final scheme in IdentifierScheme.values) {
      final raw = json[scheme.code];
      if (raw is Map<String, Object?>) {
        result[scheme] = IdentifierUsage(
          store: raw['store'] == true,
          display: raw['display'] == true,
          search: raw['search'] == true,
        );
      }
    }
    return IdentifierPolicy(result);
  }

  final Map<IdentifierScheme, IdentifierUsage> _usage;

  IdentifierUsage usageOf(IdentifierScheme scheme) =>
      _usage[scheme] ?? IdentifierUsage.none;
}
