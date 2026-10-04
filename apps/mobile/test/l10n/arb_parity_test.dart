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
    'languageOptionSemantics',
    'moduleAi',
    'navAi',
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
