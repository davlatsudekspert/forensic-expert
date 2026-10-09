import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Lokalizatsiya to‘liqligi: barcha tillarda bir xil kalitlar, bir xil
/// placeholder’lar, bo‘sh qiymat yo‘q, tarjima qilinmay qolgan matn yo‘q.
void main() {
  const dir = 'lib/core/l10n/arb';
  Map<String, Object?> load(String code) =>
      jsonDecode(File('$dir/app_$code.arb').readAsStringSync())
          as Map<String, Object?>;

  final en = load('en');
  final messageKeys = en.keys.where((k) => !k.startsWith('@')).toSet();

  // Brend va texnik qisqartmalar — barcha tillarda bir xil bo‘lishi mumkin.
  const sameInAllLanguages = {
    'appTitle',
    'appTagline',
    // Manba bo‘limi havolasi: faqat «§» belgisi + lokal bo‘lim nomi.
    'sourceSectionRef',
    // Yakuniy: xalqaro identifikator (PubMed ID).
    'sourcePmid',
    // SI birligi (g/mol) — barcha tillarda bir xil yoziladi.
    'rdGlanceMolarMass',
    // Reaktiv retsepti: SI birligi «g» o‘zbekchada ham aynan shunday.
    'reagentUnitG',
    'languageOptionSemantics',
    'moduleAi',
    'navAi',
    // PHASE 2: brend/texnik nomlar va xalqaro atamalar.
    'testDataBadge',
    'toolLodName',
    // O‘zbek tilida ham aynan «Formula» — tarjima to‘g‘ri.
    'calcFormula',
    // PHASE 3: o‘zbekcha ham «Biomarker»; brend nomi «Lifetime».
    'detailBiomarker',
    'lockedBadge',
    // PHASE 5: xalqaro analitik qisqartmalar (o‘zbekchada ham aynan shunday).
    'tech_gc',
    'tech_gcFid',
    'tech_gcMs',
    'tech_hplc',
    'tech_lcMsMs',
    'tech_headspaceGc',
    // Admin panel: platforma nomlari va o‘zbekchada ham «Admin» belgisi.
    'adminAndroid',
    'adminIos',
    'adminAdminBadge',
    // PHASE 6: statistik belgilar va xalqaro qisqartmalar; ICH hujjat nomi
    // rasmiy inglizcha sarlavha (tarjima qilinmaydi).
    'calcStatsN',
    'calcRegR2',
    'calcStatsMin',
    'calcLodReference',
    'tech_gcMsMs',
    'tech_lcMs',
    'docKindSop',
    // Yil oralig‘i — raqamlar barcha tillarda bir xil; uz: SOP, Marker.
    'researchPeriod2010',
    'tpl_marker',
    // Iqtibos uslublari nomlari (GOST, Vancouver, APA 7) — xos nomlar.
    'citeStyleGost',
    'citeStyleVancouver',
    'citeStyleApa',
    'metKindMarker',
    'reagentPh',
    // Tarif nomlari — mahsulot brendi, har tilda bir xil.
    'tierStudentPro',
    'tierProfessionalPro',
    // Faqat o‘rin belgilari (narx va davr store/lokalizatsiyadan).
    'offerPriceLine',
    // Fayl hajmi: «KB» — o‘zbekchada ham xalqaro birlik belgisi (ru: «КБ»).
    'fileSizeKb',
  };

  Set<String> placeholders(String s) =>
      RegExp(r'\{(\w+)\}').allMatches(s).map((m) => m[1]!).toSet();

  test('template’dagi har bir kalitda tavsif bor', () {
    for (final k in messageKeys) {
      final meta = en['@$k'];
      expect(meta, isA<Map<String, Object?>>(), reason: k);
      expect((meta! as Map)['description'], isNotEmpty, reason: k);
    }
  });

  for (final code in ['ru', 'uz']) {
    group('app_$code.arb', () {
      final arb = load(code);
      final keys = arb.keys.where((k) => !k.startsWith('@')).toSet();

      test('kalitlar EN bilan aynan mos', () {
        expect(keys.difference(messageKeys), isEmpty, reason: 'ortiqcha');
        expect(messageKeys.difference(keys), isEmpty, reason: 'yetishmaydi');
      });

      test('bo‘sh qiymat yo‘q va placeholder’lar mos', () {
        for (final k in messageKeys) {
          final v = arb[k]! as String;
          expect(v.trim(), isNotEmpty, reason: k);
          expect(placeholders(v), placeholders(en[k]! as String), reason: k);
        }
      });

      test('tarjima qilinmay qolgan (EN bilan bir xil) matn yo‘q', () {
        for (final k in messageKeys.difference(sameInAllLanguages)) {
          expect(arb[k], isNot(equals(en[k])), reason: k);
        }
      });
    });
  }

  test(
    'o‘zbek matnida apostrof bir xil (‘ yoki ’), ASCII \' ishlatilmaydi',
    () {
      final uz = load('uz');
      for (final k in messageKeys) {
        final v = uz[k]! as String;
        expect(RegExp(r"[a-zA-Z]'[a-zA-Z]").hasMatch(v), isFalse, reason: k);
      }
    },
  );
}
