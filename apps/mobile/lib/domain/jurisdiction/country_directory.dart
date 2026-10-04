/// Global yurisdiksiya katalogi: ISO 3166-1 davlatlari (249 ta) va ularning
/// EN / RU / UZ nomlari (Unicode CLDR).
///
/// Katalog **faqat tanlash uchun**. Davlat ro‘yxatda bo‘lishi — u uchun
/// huquqiy kontent tekshirilgan degani EMAS. Kontent bo‘lmasa UI «bu
/// yurisdiksiya uchun kontent hali tekshirilmagan» deydi va hech qachon
/// boshqa davlat qonunini fallback sifatida ko‘rsatmaydi.
library;

import 'package:flutter/foundation.dart';

part 'country_directory.g.dart';

@immutable
class CountryName {
  const CountryName(this.code, this.en, this.ru, this.uz);

  /// ISO 3166-1 alpha-2.
  final String code;
  final String en;
  final String ru;
  final String uz;

  String name(String lang) => switch (lang) {
    'ru' => ru,
    'uz' => uz,
    _ => en,
  };
}

abstract final class CountryDirectory {
  static const all = _countries;

  static CountryName? byCode(String code) {
    for (final c in _countries) {
      if (c.code == code) return c;
    }
    return null;
  }
}
