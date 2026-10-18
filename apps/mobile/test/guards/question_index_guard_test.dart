import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart' show ClassQuizBank;
import 'package:forensic_expert/data/class_groups/fake_class_groups_service.dart';
import 'package:forensic_expert/data/class_quiz/class_quiz_bank.dart'
    show classQuizBankAsset, classQuizBankLangs;
import 'package:forensic_expert/domain/class_groups/class_groups_models.dart';

/// «Qorovul»: YAGONA savollar indeksi — ilovadagi HAQIQIY savollar banki
/// (`assets/content/class_quiz/class_quiz_bank.json`) bilan, soxta test
/// ma’lumotisiz. LabGuide’da mashq ro‘yxatidan chiqarilgan savollar indeksga
/// tushmay, iPhone’da «savol to‘plamda yo‘q» xatosi chiqqan.
void main() {
  final raw = File(classQuizBankAsset).readAsStringSync();
  final json = jsonDecode(raw) as Map<String, Object?>;
  final bank = ClassQuizBank.parse(raw);

  test('haqiqiy bank: har mavzuning har savoli (har tilda) indeksda, kalit 0–3', () {
    var checked = 0;
    final topics = json['topics']! as List;
    expect(topics, isNotEmpty);
    for (final t in topics.cast<Map<String, Object?>>()) {
      for (final q in (t['questions']! as List).cast<Map<String, Object?>>()) {
        for (final l in classQuizBankLangs) {
          final opts = (q['options_i18n']! as Map)[l];
          if (opts == null) continue;
          final id = ClassQuizBank.variantId(q['id']! as String, l);
          final found = bank.question(id);
          expect(found, isNotNull, reason: '$id indeksda yo‘q');
          expect(found!.correctIndex, inInclusiveRange(0, found.options.length - 1));
          expect(found.options, hasLength(4));
          checked++;
        }
      }
    }
    expect(checked, greaterThanOrEqualTo(540 * 3));
  });

  test('har tanlanadigan mavzu (mashq ro‘yxati) savoli indeksda', () {
    for (final v in bank.variants) {
      for (final q in v.questions) {
        expect(q.id, isNotEmpty, reason: v.id);
        expect(identical(bank.question(q.id), q) || bank.question(q.id) != null, isTrue);
      }
    }
  });

  test('mashq ro‘yxatidan chiqarilgan savol ham indeksda', () {
    final b = ClassQuizBank.parse(
      jsonEncode({
        'groups': const [],
        'topics': [
          {
            'id': 'm1',
            'title_i18n': {'uz': 'M'},
            'questions': [
              for (final page in ['12', '-'])
                {
                  'id': 'm1-p$page',
                  'question_i18n': {'uz': 'Savol beti $page'},
                  'options_i18n': {
                    'uz': ['a', 'b', 'c', 'd'],
                  },
                  'correct_index': 1,
                  'source': {'author': 'A', 'title': 'T', 'page': page},
                },
            ],
          },
        ],
      }),
    );
    expect(b.variants.single.questions, hasLength(1));
    expect(b.question('m1-p-'), isNotNull, reason: 'slayd/betsiz savol');
    expect(b.question('m1-p12'), isNotNull);
  });

  test('topshiriq hovuzi (ustoz, sinov, talaba, natija) id lari indeksda', () async {
    final uz = bank.variants.where((v) => !v.id.contains('~')).toList();
    final b = FakeClassGroupsBackend(
      topics: () async => bank.variants,
      teachers: {'t'},
    );
    final g = b.create('t', 'Indeks guruhi').value!;
    b.join('s', code: g.code!, nickname: 'Talaba');
    for (final v in uz) {
      final a = (await b.createAssignment(
        't',
        g.id,
        AssignmentDraft(topicId: v.id, questionCount: 5),
      )).value!;
      for (final q in b.preview('t', a.id).value!.pool) {
        expect(bank.question(q.id), isNotNull, reason: '${v.id}: ${q.id}');
      }
      for (final q in b.open('s', a.id).value!.questions) {
        expect(bank.question(q.id), isNotNull, reason: '${v.id}: ${q.id}');
      }
    }
  });
}
