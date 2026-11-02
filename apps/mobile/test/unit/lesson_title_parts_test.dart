import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/lessons/lesson_models.dart';

void main() {
  test('nom va bandlar ajraladi', () {
    final p = LessonGrouping.titleParts(
      'Mexanik jarohatlar xaqidagi ma’lumot.1. Mexanik shikastlanishlarning '
      'asosiy turlari2. Mexanik shikastlanish sabablari',
    );
    expect(p.main, 'Mexanik jarohatlar xaqidagi ma’lumot');
    expect(
      p.points,
      '1. Mexanik shikastlanishlarning asosiy turlari 2. Mexanik '
      'shikastlanish sabablari',
    );
  });

  test('bandsiz sarlavha o‘zgarmaydi', () {
    final p = LessonGrouping.titleParts(
      'Yangi tug‘ilgan go‘daklar murdasining sud-tibbiy ekspertizasi',
    );
    expect(
      p.main,
      'Yangi tug‘ilgan go‘daklar murdasining sud-tibbiy ekspertizasi',
    );
    expect(p.points, '');
  });

  test('raqam bilan boshlansa — butun matn nom', () {
    final p = LessonGrouping.titleParts('1. Kirish');
    expect(p.main, '1. Kirish');
  });

  test('«Amaliy mashg‘ulot:» va «№1.Ma’ruza:» — tur belgisiga', () {
    final a = LessonGrouping.titleParts(
      'Amaliy mashg’ulot: Tibbiy yordam ko‘rsatish nuqsonlari.',
    );
    expect(a.kind, LessonKind.practice);
    expect(a.main, 'Tibbiy yordam ko‘rsatish nuqsonlari');
    final b = LessonGrouping.titleParts(
      '№2.Ma’ruza: Tibbiyot hodimlarining kasb huquqbuzarliklari.',
    );
    expect(b.kind, LessonKind.lecture);
    expect(b.main, 'Tibbiyot hodimlarining kasb huquqbuzarliklari');
  });

  test('haqiqiy ro‘yxat namunasi (ixtiyoriy fayl)', () {
    final f = File('/dev/shm/tmp/lesson_list.json');
    if (!f.existsSync()) return;
    final rows = (jsonDecode(f.readAsStringSync()) as List).cast<Map<String, Object?>>();
    final out = StringBuffer();
    for (final r in rows.take(400)) {
      final p = LessonGrouping.titleParts(r['n'] as String);
      out.writeln(
        '${r['c']} | ${p.kind?.name ?? '-'} | ${p.main} || ${p.points}',
      );
    }
    File('/dev/shm/tmp/tp/out.txt').writeAsStringSync(out.toString());
  });
}
