import 'package:fe_content_schema/fe_content_schema.dart' show KnowledgeArea;

/// Imzolangan kontent paketidagi joylashuv xatolari uchun ilova tomonidagi
/// tuzatishlar (ilmiy audit, 2026-11-01). Paket qayta yig‘ilganda manbada
/// tuzatiladi va bu ro‘yxat bo‘shatiladi.
///
/// * Mavzu boshqa fanga tegishli bo‘lsa — to‘g‘ri soha.
/// * Iqtibos mavzuga tegishli bo‘lmasa (boshqa tadqiqotdan noto‘g‘ri
///   biriktirilgan parcha) — ko‘rsatilmaydi; ma’lumot to‘qilmaydi.
abstract final class ContentCorrections {
  static const areaOverrides = <String, KnowledgeArea>{
    // Kokainning namunada parchalanishi va NaF konservanti —
    // toksikologik namuna bilan ishlash, biokimyo emas.
    'bio-cocaine-stability': KnowledgeArea.toxicology,
  };

  /// Modda guruhi (Kutubxona → Moddalar va test to‘plamlari).
  static const substanceGroupOverrides = <String, String>{
    // GHB — MNS depressanti (sedativ-gipnotik), gallyutsinogen emas.
    'ghb': 'sedatives_hypnotics',
  };

  /// [hiddenClaims] tegishli yozuvlar (testlar va hisobot uchun).
  static const correctedEntries = <String>{
    'fm-death-investigation',
    'method-validation',
    'method-lcmsms',
  };

  static const hiddenClaims = <String>{
    // «O‘lim holatini tekshirish» ta’rifi o‘rnida Finlyandiyadagi
    // buprenorfin o‘limlari tadqiqotidan parcha.
    'C-FM-DEATH-INVESTIGATION-DEFINITION-P5',
    // «Validatsiya» cheklovi o‘rnida suyak iligi va PMR sharhi.
    'C-METHOD-VALIDATION-LIMITATION-P5',
    // «LC-MS/MS tamoyili» o‘rnida parakvat autopsiya tadqiqotining maqsadi.
    'C-METHOD-LCMSMS-PRINCIPLE-P5',
  };
}
