import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/design/theme.dart';

/// Ilovaga qo‘shilgan shriftlar o‘zbek (lotin va kirill), rus va lotin
/// kengaytirilgan belgilarini o‘zi chizishini tekshiradi (zaxira shriftga
/// tushmasligi).
///
/// 1. Har bir TTF faylning `cmap` jadvali (format 12) o‘qiladi va har bir
///    belgi uchun glif borligi aniq tekshiriladi.
/// 2. Namuna matn haqiqiy shriftlar bilan chiziladi (golden) — tofu/kvadrat
///    yo‘qligini ko‘z bilan tekshirish uchun. Shriftlar
///    `flutter_test_config.dart` da yuklanadi.
const _sample = 'oʻ gʻ o‘ g‘ Ўў Ққ Ғғ Ҳҳ ё Ж ж';

/// Matn/raqam belgilari — tirnoq, tire, ilmiy belgilar.
const _extra = '’ ʼ « » № – — ≥ ≤ ± µ × ° ‰ 0123456789';

/// TrueType `cmap` (platform 3, encoding 10, format 12) dan kod nuqtalari.
bool Function(int) _cmap(String path) {
  final bytes = File(path).readAsBytesSync();
  final d = ByteData.sublistView(bytes);
  final numTables = d.getUint16(4);
  var cmap = -1;
  for (var i = 0; i < numTables; i++) {
    final rec = 12 + i * 16;
    final tag = String.fromCharCodes(bytes.sublist(rec, rec + 4));
    if (tag == 'cmap') cmap = d.getUint32(rec + 8);
  }
  if (cmap < 0) throw StateError('cmap yo‘q: $path');
  final n = d.getUint16(cmap + 2);
  for (var i = 0; i < n; i++) {
    final rec = cmap + 4 + i * 8;
    final platform = d.getUint16(rec);
    final encoding = d.getUint16(rec + 2);
    final sub = cmap + d.getUint32(rec + 4);
    if (platform != 3 || encoding != 10 || d.getUint16(sub) != 12) continue;
    final groups = d.getUint32(sub + 12);
    final ranges = [
      for (var g = 0; g < groups; g++)
        (d.getUint32(sub + 16 + g * 12), d.getUint32(sub + 20 + g * 12)),
    ];
    return (cp) => ranges.any((r) => cp >= r.$1 && cp <= r.$2);
  }
  throw StateError('cmap format 12 yo‘q: $path');
}

void main() {
  final codePoints = {
    for (final r in (_sample + _extra).runes)
      if (r != 0x20) r,
  };

  for (final path in [
    'assets/fonts/source_serif_4/SourceSerif4-Regular.ttf',
    'assets/fonts/source_serif_4/SourceSerif4-SemiBold.ttf',
    'assets/fonts/source_serif_4/SourceSerif4-Bold.ttf',
    'assets/fonts/inter/Inter-Regular.ttf',
    'assets/fonts/inter/Inter-Medium.ttf',
    'assets/fonts/inter/Inter-SemiBold.ttf',
    'assets/fonts/inter/Inter-Bold.ttf',
  ]) {
    test('${path.split('/').last}: barcha belgilar shriftning o‘zida', () {
      final has = _cmap(path);
      final missing = [
        for (final cp in codePoints)
          if (!has(cp)) String.fromCharCode(cp),
      ];
      expect(missing, isEmpty, reason: 'glif yo‘q: $missing');
    });
  }

  test(
    'cmap tekshiruvi ishlaydi: JetBrains Mono’da «Ҳ» yo‘q (Inter zaxira)',
    () {
      final has = _cmap(
        'assets/fonts/jetbrains_mono/JetBrainsMono-Regular.ttf',
      );
      expect(has('0'.runes.first), isTrue);
      expect(has('Ҳ'.runes.first), isFalse);
      expect(FeFonts.monoFallback, contains(FeFonts.sans));
    },
  );

  testWidgets('tipografiya namunasi (golden)', (tester) async {
    tester.view.physicalSize = const Size(760, 900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final theme = FeThemeBuilder.light();
    final t = theme.textTheme;
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_sample, style: t.headlineMedium),
                Text(_sample, style: t.titleLarge),
                Text(_sample, style: t.bodyLarge),
                Text(_sample, style: FeThemeBuilder.numeric(t.bodyLarge!)),
                const SizedBox(height: 8),
                Text(_extra, style: t.titleMedium),
                Text(_extra, style: t.bodyMedium),
                Text(
                  '0.125 mg/L · 1 234,56 ‰',
                  style: FeThemeBuilder.figures(t.titleLarge!),
                ),
                Text(
                  '0.125 mg/L · 1 234,56 ‰',
                  style: FeThemeBuilder.numeric(t.titleMedium!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/typography_coverage.png'),
    );
  });
}
