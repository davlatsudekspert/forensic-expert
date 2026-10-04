import 'package:fe_content_schema/fe_content_schema.dart';

import 'country_directory.dart';

/// Yurisdiksiyalar ro‘yxati (**Global Scientific Core + Jurisdiction Layer**).
///
/// Bu yerda faqat yurisdiksiya **identifikatorlari va nomlari** bor
/// (ISO 3166 kodlari). Hech qanday qonun, ro‘yxat, chegara qiymati yoki
/// protsedura YO‘Q — ular kelajakda imzolangan kontent paketidan
/// (`jurisdictional_instruments`, `jurisdictional_rules`) rasmiy manba,
/// kuchga kirish sanasi, versiya va review bilan keladi.
///
/// Ro‘yxat boshlang‘ich; kontent paketi o‘z `jurisdictions` jadvali bilan
/// uni kengaytiradi (yuzlab davlat va hududlar uchun ilova kodi o‘zgarmaydi).
abstract final class JurisdictionCatalog {
  /// «Xalqaro» — tanlov bo‘lmasa standart: faqat Global Scientific Core va
  /// xalqaro standartlar ko‘rsatiladi.
  static const internationalId = 'INT';

  /// Yevropa Ittifoqi a’zolari (ISO 3166-1) — faqat ierarxiya (EU → davlat).
  static const euMembers = {
    'AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'DE', 'GR', //
    'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', 'NL', 'PL', 'PT', 'RO', 'SK',
    'SI', 'ES', 'SE',
  };

  static final seed = List<Jurisdiction>.unmodifiable([
    ..._curated,
    // Qolgan ISO 3166-1 davlatlari — nomlar Unicode CLDR’dan. Bu faqat
    // tanlash ro‘yxati: kontent bo‘lmasa UI «tekshirilmagan» deydi.
    for (final c in CountryDirectory.all)
      if (!_curatedIds.contains(c.code))
        _country(
          c.code,
          c.en,
          c.ru,
          c.uz,
          parentId: euMembers.contains(c.code)
              ? 'EU'
              : JurisdictionCatalog.internationalId,
        ),
  ]);

  static final _curatedIds = {for (final j in _curated) j.id};

  static final _curated = List<Jurisdiction>.unmodifiable([
    const Jurisdiction(
      id: internationalId,
      level: JurisdictionLevel.international,
      names: {'en': 'International', 'ru': 'Международный', 'uz': 'Xalqaro'},
    ),
    const Jurisdiction(
      id: 'EU',
      level: JurisdictionLevel.supranational,
      parentId: internationalId,
      names: {
        'en': 'European Union',
        'ru': 'Европейский союз',
        'uz': 'Yevropa Ittifoqi',
      },
    ),
    _country('UZ', 'Uzbekistan', 'Узбекистан', 'O‘zbekiston'),
    _country('KZ', 'Kazakhstan', 'Казахстан', 'Qozog‘iston'),
    _country('KG', 'Kyrgyzstan', 'Кыргызстан', 'Qirg‘iziston'),
    _country('TJ', 'Tajikistan', 'Таджикистан', 'Tojikiston'),
    _country('TM', 'Turkmenistan', 'Туркменистан', 'Turkmaniston'),
    _country('RU', 'Russia', 'Россия', 'Rossiya'),
    _country('TR', 'Türkiye', 'Турция', 'Turkiya'),
    _country('US', 'United States', 'США', 'AQSH'),
    _country('GB', 'United Kingdom', 'Великобритания', 'Buyuk Britaniya'),
    _country('DE', 'Germany', 'Германия', 'Germaniya', parentId: 'EU'),
  ]);

  static Jurisdiction byId(String id) =>
      seed.firstWhere((j) => j.id == id, orElse: () => seed.first);
}

Jurisdiction _country(
  String iso,
  String en,
  String ru,
  String uz, {
  String parentId = JurisdictionCatalog.internationalId,
}) => Jurisdiction(
  id: iso,
  level: JurisdictionLevel.country,
  parentId: parentId,
  iso3166: iso,
  names: {'en': en, 'ru': ru, 'uz': uz},
);
