import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Arxitektura qoidalari (statik tekshiruv).
void main() {
  List<File> dartFiles(String dir) =>
      Directory(dir)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => !f.path.contains('/generated/'))
          .toList();

  test('feature’lar lib/data ni to‘g‘ridan-to‘g‘ri import qilmaydi', () {
    final offenders = <String>[];
    for (final f in dartFiles('lib/features')) {
      for (final line in f.readAsLinesSync()) {
        if (line.startsWith('import') && line.contains('/data/')) {
          offenders.add('${f.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test(
    'vendor SDK’lar (Supabase, RevenueCat, HTTP) faqat lib/data/remote ichida',
    () {
      const vendorPackages = [
        'package:supabase',
        'package:supabase_flutter',
        'package:purchases_flutter',
        'package:http/',
        'package:dio/',
        'package:firebase_',
      ];
      final offenders = <String>[];
      for (final f in dartFiles('lib')) {
        if (f.path.contains('lib/data/remote/')) continue;
        for (final line in f.readAsLinesSync()) {
          if (line.startsWith('import') &&
              vendorPackages.any((p) => line.contains(p))) {
            offenders.add('${f.path}: $line');
          }
        }
      }
      expect(offenders, isEmpty, reason: offenders.join('\n'));
    },
  );

  test('domain qatlami Flutter UI va data’ga bog‘liq emas', () {
    final offenders = <String>[];
    for (final f in dartFiles('lib/domain')) {
      for (final line in f.readAsLinesSync()) {
        if (line.startsWith('import') &&
            (line.contains('package:flutter/material') ||
                line.contains('/data/') ||
                line.contains('/features/'))) {
          offenders.add('${f.path}: $line');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('UI’da hardcoded foydalanuvchi matni yo‘q', () {
    // Matn ko‘rsatadigan parametrlar ichidagi string literal’lar.
    final patterns = [
      RegExp(r'''Text\(\s*['"]'''),
      RegExp(
        r'''(label|tooltip|hintText|labelText|helperText|semanticsLabel|title|message)\s*:\s*['"][^'"]*[A-Za-zА-Яа-яЎўҚқҒғҲҳ]''',
      ),
    ];
    final offenders = <String>[];
    for (final dir in ['lib/features', 'lib/core/widgets', 'lib/app']) {
      for (final f in dartFiles(dir)) {
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.trimLeft().startsWith('//')) continue;
          if (patterns.any((p) => p.hasMatch(line))) {
            offenders.add('${f.path}:${i + 1}: ${line.trim()}');
          }
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('ilova kodida maxfiy kalitga o‘xshash satr yo‘q', () {
    final suspicious = RegExp(
      r'(sk-[A-Za-z0-9]{20,}|service_role|-----BEGIN [A-Z ]*PRIVATE KEY-----|'
      r'AIza[0-9A-Za-z\-_]{35}|appl_[A-Za-z0-9]{20,}|goog_[A-Za-z0-9]{20,})',
    );
    final offenders = <String>[];
    for (final f in dartFiles('lib')) {
      if (suspicious.hasMatch(f.readAsStringSync())) offenders.add(f.path);
    }
    expect(offenders, isEmpty);
  });
}
