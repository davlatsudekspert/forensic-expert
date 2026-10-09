import 'dart:convert';
import 'dart:io';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/guidelines/guideline_models.dart';
import 'package:forensic_expert/features/guidelines/presentation/guidelines_screens.dart';

/// Ilovaga qo‘shilgan haqiqiy yo‘riqnoma paketi: tuzilma, til to‘liqligi,
/// iqtiboslar va ichki maydonlar sizib chiqmasligi.
void main() {
  final raw = File('assets/content/guidelines/guidelines_v1.json')
      .readAsStringSync();
  final json = (jsonDecode(raw) as Map).cast<String, Object?>();
  final bundle = GuidelineBundle.fromJson(json);

  test('kartalar: NEEDS_REVIEW, uch til, manbalar tekshirilgan', () {
    expect(bundle.cards, isNotEmpty);
    for (final c in bundle.cards) {
      expect(c.status, ScientificStatus.needsReview, reason: c.id);
      for (final lang in ['uz', 'ru', 'en']) {
        expect(c.title.pick(lang).isFallback, isFalse, reason: c.id);
        for (final s in c.sections) {
          expect(s.body.pick(lang).isFallback, isFalse, reason: s.key);
        }
      }
      final refs = bundle.referencesOf(c);
      expect(refs, isNotEmpty, reason: c.id);
      expect(refs.every((r) => r.verifiedVia != null), isTrue);
    }
  });

  test('matndagi barcha [kalit] iqtiboslar raqamga aylanadi', () {
    for (final c in bundle.cards) {
      final refs = bundle.referencesOf(c);
      final index = {for (var i = 0; i < refs.length; i++) refs[i].key: i + 1};
      for (final s in c.sections) {
        for (final lang in ['uz', 'ru', 'en']) {
          final out = numberCitations(s.body.of(lang), s.citations, index);
          expect(
            RegExp(r'\[[a-z][a-z0-9_]*[0-9]{4}[a-z]?').hasMatch(out),
            isFalse,
            reason: '${c.id}/${s.key}/$lang',
          );
        }
      }
    }
  });

  test('ichki maydonlar ilova paketida yo‘q; yopiq manbaga havola yo‘q', () {
    expect(raw.contains('omitted_unverified'), isFalse);
    expect(raw.contains('ABY'), isFalse);
  });

  group('«Giyohvand moddalar tahlili» (GMT) kartalari', () {
    const book = 'gmt_yuldashev2024';
    const ids = {
      'guideline.chem.gmt_analysis_scheme',
      'guideline.chem.gmt_opioids',
      'guideline.chem.gmt_cocaine',
      'guideline.chem.gmt_cannabis',
      'guideline.chem.gmt_phenylalkylamines',
      'guideline.chem.gmt_barbiturates',
      'guideline.chem.gmt_benzodiazepines',
      'guideline.chem.gmt_precursors',
      'guideline.chem.gmt_uz_control_lists',
    };
    final gmt = [
      for (final c in bundle.cards)
        if (c.id.startsWith('guideline.chem.gmt_')) c,
    ];
    final inline = RegExp(r'\[[a-z0-9_]+(?:,\s*[a-z0-9_]+)*\]');

    test('9 ta karta: har bir guruh + sxema + huquqiy eslatma', () {
      expect({for (final c in gmt) c.id}, ids);
      for (final c in gmt) {
        expect(c.area, GuidelineArea.forensicChemistry, reason: c.id);
      }
    });

    test('NEEDS_REVIEW, uz/ru/en, darslik kitob turida manbada', () {
      final ref = bundle.references[book];
      expect(ref, isNotNull);
      expect(ref!.citation, contains('Giyohvand moddalar tahlili'));
      expect(ref.citation, contains('2024'));
      expect(ref.firstAuthor, 'Yuldashev Z.A.');
      final rawRef = ((json['references']! as List).cast<Map>()).firstWhere(
        (r) => r['key'] == book,
      );
      expect(rawRef['type'], 'book');
      expect(rawRef['publisher'], 'Toshkent farmatsevtika instituti');
      expect(rawRef['place'], 'Toshkent');
      expect(rawRef['year'], 2024);
      expect(rawRef['pages_total'], 173);
      expect(
        ref.citation,
        contains('Toshkent farmatsevtika instituti, Toshkent'),
      );
      expect(ref.citation, startsWith('Yuldashev ZA, Zulfikariyeva DA'));
      expect(
        '${rawRef['rights']}',
        contains('muallif ruxsati bilan, 2026-10-09'),
      );
      for (final c in gmt) {
        expect(c.status, ScientificStatus.needsReview, reason: c.id);
        expect(
          bundle.referencesOf(c).map((r) => r.key),
          contains(book),
          reason: c.id,
        );
        for (final lang in ['uz', 'ru', 'en']) {
          expect(c.summary.pick(lang).isFallback, isFalse, reason: c.id);
        }
      }
    });

    test('har bir bayonot (qator) iqtibosli; darslik sahifasi bilan', () {
      final locator = {
        'uz': RegExp(r'\[gmt_yuldashev2024\] \([0-9–, -]+-b\.\)'),
        'ru': RegExp(r'\[gmt_yuldashev2024\] \(с\. [0-9–, ]+\)'),
        'en': RegExp(r'\[gmt_yuldashev2024\] \(pp?\. [0-9–, ]+\)'),
      };
      for (final c in gmt) {
        for (final s in c.sections) {
          expect(s.citations, isNotEmpty, reason: '${c.id}/${s.key}');
          for (final lang in ['uz', 'ru', 'en']) {
            final body = s.body.of(lang);
            for (final line in body.split('\n')) {
              if (line.trim().isEmpty) continue;
              expect(
                inline.hasMatch(line),
                isTrue,
                reason: '${c.id}/${s.key}/$lang: $line',
              );
            }
            final bookCites = RegExp(r'\[gmt_yuldashev2024\]').allMatches(body);
            expect(
              locator[lang]!.allMatches(body).length,
              bookCites.length,
              reason: '${c.id}/${s.key}/$lang: kitob sahifasiz keltirilgan',
            );
          }
        }
      }
    });

    test('muallif ruxsati bilan — barcha uchun bepul (Pro emas)', () {
      for (final c in gmt) {
        final a = c.sourceAccess;
        expect(a, isNotNull, reason: c.id);
        expect(a!.sourceKey, book);
        expect(a.isFree, isTrue, reason: c.id);
        expect(a.byAuthorPermission, isTrue, reason: c.id);
      }
      // Darslikka tayangan har qanday karta bepul deb belgilangan.
      for (final c in bundle.cards) {
        if (bundle.referencesOf(c).any((r) => r.key == book)) {
          expect(c.sourceAccess?.isFree, isTrue, reason: c.id);
        }
      }
    });

    test('test savollari: ≥30, manbali, 3 tadan noto‘g‘ri variant', () {
      final quiz = [for (final c in gmt) ...c.quiz];
      expect(quiz.length, greaterThanOrEqualTo(30));
      expect({for (final q in quiz) q.id}.length, quiz.length);
      for (final c in gmt) {
        final keys = {for (final r in bundle.referencesOf(c)) r.key};
        for (final q in c.quiz) {
          expect(q.distractors, hasLength(3), reason: q.id);
          expect(q.citations, isNotEmpty, reason: q.id);
          for (final cit in q.citations) {
            expect(keys, contains(cit.key), reason: q.id);
          }
          for (final lang in ['uz', 'ru', 'en']) {
            expect(q.question.pick(lang).isFallback, isFalse, reason: q.id);
            expect(q.answer.pick(lang).isFallback, isFalse, reason: q.id);
            for (final d in q.distractors) {
              expect(d.of(lang), isNot(q.answer.of(lang)), reason: q.id);
            }
          }
        }
      }
    });

    test('tuzatilgan xatolar faqat «tuzatishlar» bo‘limida eslatiladi', () {
      final opioids = bundle.byId('guideline.chem.gmt_opioids')!;
      final basis = opioids.sections.firstWhere((s) => s.key == 'basis');
      for (final lang in ['uz', 'ru', 'en']) {
        expect(basis.body.of(lang), contains('C15H21NO2'));
      }
      final wrong = RegExp(r'etinil|этинил|ethynyl|Rf\s*=\s*8[.,]6|13–15%');
      for (final c in gmt) {
        for (final s in c.sections) {
          if (s.key == 'cautions') continue;
          for (final b in s.body.all) {
            expect(wrong.hasMatch(b), isFalse, reason: '${c.id}/${s.key}');
          }
        }
      }
    });
  });
}
