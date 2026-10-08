import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// O‘zbek (lotin) va rus UI to‘liqligi.
///
/// (a) app_en.arb’dagi har bir kalit app_uz.arb va app_ru.arb’da bor va
///     qiymati bo‘sh emas;
/// (b) o‘zbekcha qiymatlarda inglizcha UI so‘zlari (Search, Retry, Settings…)
///     alohida so‘z sifatida uchramaydi;
/// (c) ruscha qiymatlarda ham xuddi shunday.
///
/// Istisno faqat quyidagi kichik allowlist’lar orqali va har biri izoh bilan.
/// Xalqaro atamalar (DNK/DNA, GC-MS, HPLC, ISO, DOI, PMID, API, URL, email,
/// PubMed, PubChem, Crossref, FORENSIC EXPERT, App Store, Google Play,
/// Gemini) ro‘yxatdagi so‘zlarga kirmaydi, shuning uchun allowlist kerak emas.
/// Tuzatishlar: tool/l10n_uz_complete.py.
void main() {
  const dir = 'lib/core/l10n/arb';
  Map<String, Object?> load(String code) =>
      jsonDecode(File('$dir/app_$code.arb').readAsStringSync())
          as Map<String, Object?>;

  final en = load('en');
  final messageKeys = en.keys.where((k) => !k.startsWith('@')).toSet();

  /// Inglizcha UI so‘zlari (katta-kichik harf farqsiz, butun so‘z).
  const englishUiWords = [
    'search',
    'results',
    'retry',
    'settings',
    'source',
    'sources',
    'loading',
    'research',
    'restore',
    'purchases',
    'evidence',
    'status',
    'error',
    'cancel',
    'save',
    'delete',
    'sign in',
    'sign out',
    'login',
    'continue',
    'back',
    'next',
    'done',
    'open',
    'close',
    'share',
    'filter',
    'sort',
    'language',
    'profile',
    'home',
    'library',
    'tools',
    'subscription',
    'upgrade',
    'free trial',
  ];

  // Harf (har qanday yozuv) yoki o‘zbek apostroflari bilan yopishmagan so‘z.
  final wordPattern = RegExp(
    r"(?<![\p{L}‘’'])(" +
        englishUiWords.map((w) => w.replaceAll(' ', r'\s+')).join('|') +
        r")(?![\p{L}‘’'])",
    caseSensitive: false,
    unicode: true,
  );

  /// ICU sintaksisini olib tashlaydi: `{name}`, `{count, plural,` va
  /// `one{` / `=0{` kabi selektorlar foydalanuvchiga ko‘rinmaydi.
  String visibleText(String v) => v
      .replaceAll(RegExp(r'\{\s*\w+\s*(,\s*\w+\s*,)?\s*\}?'), ' ')
      .replaceAll(RegExp(r'(=\d+|zero|one|two|few|many|other)\s*\{'), ' ')
      .replaceAll(RegExp(r'[{}]'), ' ');

  /// O‘zbekcha uchun ruxsat etilgan istisnolar (kalit → sabab).
  /// Hozircha bo‘sh: barcha UI matni o‘zbekcha.
  const uzAllowlist = <String, String>{};

  /// Ruscha uchun ruxsat etilgan istisnolar (kalit → sabab).
  /// Hozircha bo‘sh: barcha UI matni ruscha.
  const ruAllowlist = <String, String>{};

  for (final code in ['uz', 'ru']) {
    final arb = load(code);
    final allowlist = code == 'uz' ? uzAllowlist : ruAllowlist;

    group('app_$code.arb', () {
      test('(a) EN’dagi har bir kalit bor va qiymati bo‘sh emas', () {
        final missing = <String>[];
        final empty = <String>[];
        for (final k in messageKeys) {
          final v = arb[k];
          if (v == null) {
            missing.add(k);
          } else if (v is! String || v.trim().isEmpty) {
            empty.add(k);
          }
        }
        expect(missing, isEmpty, reason: 'yetishmaydi: $missing');
        expect(empty, isEmpty, reason: 'bo‘sh: $empty');
      });

      test('(${code == 'uz' ? 'b' : 'c'}) inglizcha UI so‘zlari yo‘q', () {
        final offenders = <String>[];
        for (final k in messageKeys) {
          if (allowlist.containsKey(k)) continue;
          final v = arb[k];
          if (v is! String) continue;
          final hits = wordPattern
              .allMatches(visibleText(v))
              .map((m) => m[0]!)
              .toSet();
          if (hits.isNotEmpty) offenders.add('$k: $hits — «$v»');
        }
        expect(offenders, isEmpty, reason: offenders.join('\n'));
      });

      test('allowlist eskirmagan (kalitlar mavjud va sababi yozilgan)', () {
        for (final e in allowlist.entries) {
          expect(messageKeys, contains(e.key), reason: e.key);
          expect(e.value.trim(), isNotEmpty, reason: e.key);
        }
      });
    });
  }

  test('o‘zbekcha (lotin) qiymatlarda kirill harflari yo‘q', () {
    final uz = load('uz');
    final cyrillic = RegExp('[А-Яа-яЁёЎўҚқҒғҲҳ]');
    final offenders = [
      for (final k in messageKeys)
        if (cyrillic.hasMatch(uz[k]! as String)) k,
    ];
    expect(offenders, isEmpty, reason: offenders.join(', '));
  });

  test('so‘z filtri o‘zi ishlaydi (sanity)', () {
    expect(wordPattern.hasMatch(visibleText('Retry')), isTrue);
    expect(wordPattern.hasMatch(visibleText('Sign  in now')), isTrue);
    expect(wordPattern.hasMatch(visibleText('Manba: {source}')), isFalse);
    expect(
      wordPattern.hasMatch(
        visibleText('{count, plural, =1{1 source} other{{count} manba}}'),
      ),
      isTrue,
    );
    expect(wordPattern.hasMatch(visibleText('Qidiruv natijalari')), isFalse);
  });
}
