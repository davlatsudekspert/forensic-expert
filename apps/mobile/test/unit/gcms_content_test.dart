import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/instruments/gcms_content.dart';

const _dir = 'assets/content/instruments/gc_ms';

GcMsContent _load() => GcMsContent.fromJson(
  (jsonDecode(File('$_dir/gc_ms_parts_3lang.json').readAsStringSync()) as Map)
      .cast<String, Object?>(),
  (jsonDecode(
    File('$_dir/gc_ms_catalog_card_and_sources.json').readAsStringSync(),
  ) as Map).cast<String, Object?>(),
);

void main() {
  const langs = ['uz', 'ru', 'en'];

  test('har bir qism 1..10: uz/ru/en nom va vazifa bor', () {
    final g = _load();
    expect(g.parts.map((p) => p.number), [for (var i = 1; i <= 10; i++) i]);
    for (final p in g.parts) {
      expect(p.name.hasAll(langs), isTrue, reason: 'nom ${p.number}');
      expect(p.function.hasAll(langs), isTrue, reason: 'vazifa ${p.number}');
    }
    for (final t in [
      g.title,
      g.alt,
      g.caption,
      g.note,
      g.principle,
      g.result,
    ]) {
      expect(t.hasAll(langs), isTrue);
    }
    expect(g.tasks, isNotEmpty);
    expect(g.source.url, startsWith('https://'));
  });

  test('rasm fayllarining SHA-256 qiymati paket yozuviga mos (original)', () {
    String sha(String f) =>
        sha256.convert(File('$_dir/$f').readAsBytesSync()).toString();
    expect(
      sha('mass_spec_gc_1200.png'),
      'd03a2586aac8dad6527e1522400e39f01370a6e2ba799750dd4bac996882880f',
    );
    expect(
      sha('mass_spec_gc_480.png'),
      '461c2aec24053f3c3cc24b954696124c2e802006d6af737e231c29ef63d39102',
    );
  });
}
