import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';
import 'generated/app_localizations_uz_new.dart';
import 'uz_alphabet.dart';

/// Kontent matnlari uchun joriy holat: o‘zbekcha matn yangi alifboda
/// ko‘rsatiladimi. [FeLocalizationsDelegate] yuklanganda yangilanadi —
/// sozlama o‘zgarsa delegate qayta yuklanadi va barcha matnli vidjetlar
/// qayta quriladi.
abstract final class UzAlphabetMode {
  static bool newAlphabet = false;
}

/// AppLocalizations delegate’i: `uz` + yangi alifbo yoqilgan bo‘lsa
/// [AppLocalizationsUzNew] qaytaradi.
class FeLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const FeLocalizationsDelegate({required this.newUzAlphabet});

  final bool newUzAlphabet;

  static List<LocalizationsDelegate<dynamic>> all({required bool newUz}) => [
    FeLocalizationsDelegate(newUzAlphabet: newUz),
    ...AppLocalizations.localizationsDelegates.where(
      (d) => d.type != AppLocalizations,
    ),
  ];

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.delegate.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) {
    final useNew = newUzAlphabet && locale.languageCode == 'uz';
    UzAlphabetMode.newAlphabet = useNew;
    LocalizedTextHook.display = uzDisplay;
    return SynchronousFuture<AppLocalizations>(
      useNew ? AppLocalizationsUzNew() : lookupAppLocalizations(locale),
    );
  }

  @override
  bool shouldReload(FeLocalizationsDelegate old) =>
      old.newUzAlphabet != newUzAlphabet;
}

/// Kontent matni: [lang] o‘zbekcha va yangi alifbo yoqilgan bo‘lsa — yangi
/// alifboda; aks holda o‘zgarmaydi. Manba iqtibosi («Asl matn»),
/// bibliografiya va DOI bu funksiyadan o‘tkazilmaydi.
String uzDisplay(String lang, String text) =>
    lang == 'uz' && UzAlphabetMode.newAlphabet ? toUzNewAlphabet(text) : text;
