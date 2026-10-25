import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/assessment/assessment_models.dart';

/// Og‘zaki javoblar paketining yaxlitligi: har bir band manbali, iqtibosli va
/// mavjud savolga bog‘langan; «to‘qilgan» javob yo‘q.
void main() {
  final base = jsonDecode(
    File('assets/content/assessment/assessment_v1.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final questionIds = <String, Set<String>>{
    for (final s in (base['specialties']! as List).cast<Map<String, Object?>>())
      s['id']! as String: {
        for (final c in (s['categories']! as List).cast<Map<String, Object?>>())
          for (final q
              in (c['questions']! as List).cast<Map<String, Object?>>())
            q['id']! as String,
      },
  };

  for (final spec in ['sud_tib', 'pat_anat', 'sud_kimyo']) {
    group('oral_$spec.json', () {
      final raw = File('assets/content/assessment/oral_$spec.json')
          .readAsStringSync();
      final data = OralAnswers.fromJson(
        (jsonDecode(raw) as Map).cast<String, Object?>(),
      );

      test('javoblar mavjud savollarga bog‘langan', () {
        expect(data.answers, isNotEmpty);
        for (final id in data.answers.keys) {
          expect(questionIds[spec], contains(id), reason: id);
        }
      });

      test('har bir javobda kamida 3 band; har bandda manba va iqtibos', () {
        for (final e in data.answers.entries) {
          expect(e.value.points.length, greaterThanOrEqualTo(3), reason: e.key);
          for (final p in e.value.points) {
            expect(p.text.trim(), isNotEmpty, reason: e.key);
            expect(p.source, isNotNull, reason: e.key);
            expect(
              p.quote.trim().length,
              inInclusiveRange(12, 320),
              reason: e.key,
            );
            if (p.source!.kind == 'book') {
              expect(p.page, greaterThan(0), reason: e.key);
            } else {
              expect(p.source!.kind, 'web', reason: e.key);
              expect(
                p.url.isNotEmpty || p.source!.url.isNotEmpty,
                isTrue,
                reason: e.key,
              );
            }
          }
          if (!e.value.full) {
            // Qisman javobda aniq yoritilmagan jihatlar bo‘lishi shart emas,
            // lekin to‘liq javobda "gaps" bo‘lmaydi.
          } else {
            expect(e.value.gaps, isEmpty, reason: e.key);
          }
        }
      });

      test('ichki belgilar va tuzatilgan xato atamalar yo‘q', () {
        for (final e in data.answers.entries) {
          for (final p in e.value.points) {
            expect(p.text, isNot(contains('TODO')), reason: e.key);
            expect(
              p.text,
              isNot(matches(RegExp('obkladochn|Surinkali'))),
              reason: e.key,
            );
          }
        }
      });
    });
  }
}
