import 'dart:convert';
import 'dart:io';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/domain/catalog/tools_catalog.dart';
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

  test('UB-ko‘rinadigan spektrofotometriya kartasi: manbalar va vositalar', () {
    final card = bundle.cards.singleWhere(
      (c) => c.id == 'guideline.chem.uvvis_drug_analysis',
    );
    expect(card.disciplineCodes, contains('forensic_chemistry'));
    expect(card.sections.map((s) => s.key), [
      'basis',
      'scope',
      'methods',
      'advantages',
      'limitations',
      'factors',
      'cautions',
      'alternatives',
    ]);
    // Bog‘langan vositalar katalogda mavjud (Ber–Lambert, kalibrlash, LOD/LOQ).
    expect(card.relatedToolIds, [
      'tool.lab.beer_lambert',
      'tool.lab.calibration',
      'tool.lab.lod_loq',
    ]);
    for (final id in card.relatedToolIds) {
      expect(ToolsCatalog.byId(id)?.isAvailable, isTrue, reason: id);
    }
    final keys = bundle.referencesOf(card).map((r) => r.key).toSet();
    // Tekshirilgan asosiy manbalar: Ber–Lambert (IUPAC), ICH Q2(R2), SWGDRUG,
    // HPLC-DAD kutubxonasi selektivligi.
    expect(
      keys,
      containsAll([
        'iupac_beer_lambert',
        'ich_q2r2_2023',
        'swgdrug2024',
        'herzler2003',
      ]),
    );
    final herzler = bundle.references['herzler2003']!;
    expect(herzler.doi, '10.1093/jat/27.4.233');
    expect(herzler.pmid, '12820746');
    expect(
      bundle.references['iupac_beer_lambert']!.doi,
      '10.1351/goldbook.B00626',
    );
    // Past o‘ziga xoslik va tasdiqlash talabi uch tilda ham aytilgan.
    final cautions = card.sections.singleWhere((s) => s.key == 'cautions');
    expect(cautions.body.of('en'), contains('UV spectrum alone'));
    expect(cautions.body.of('uz'), contains('faqat UB spektri'));
  });

  test('ichki maydonlar ilova paketida yo‘q; yopiq manbaga havola yo‘q', () {
    expect(raw.contains('omitted_unverified'), isFalse);
    expect(raw.contains('ABY'), isFalse);
  });

  group('«Toksikologik kimyo» majmuasi kartalari (Yuldashev Z.A.)', () {
    const ids = [
      'guideline.chem.toks_isolation',
      'guideline.chem.toks_mineralization',
      'guideline.chem.toks_metal_poisons',
      'guideline.chem.toks_volatile_poisons',
      'guideline.chem.toks_pesticides',
    ];
    final cards = [for (final id in ids) bundle.byId(id)];

    test('beshta karta bor, sud-kimyo bo‘limida, NEEDS_REVIEW', () {
      for (final (i, c) in cards.indexed) {
        expect(c, isNotNull, reason: ids[i]);
        expect(c!.area, GuidelineArea.forensicChemistry);
        expect(c.status, ScientificStatus.needsReview);
        expect(c.sections, hasLength(8), reason: c.id);
      }
    });

    test('egasi qarori: barcha uchun bepul, manba qatori ko‘rsatiladi', () {
      for (final c in cards.nonNulls) {
        expect(c.access, GuidelineAccess.free, reason: c.id);
        expect(c.isFree, isTrue, reason: c.id);
        expect(bundle.citesYuldashevMaterial(c), isTrue, reason: c.id);
      }
      // Yuldashev materialiga tayangan har qanday karta bepul bo‘lishi shart.
      for (final c in bundle.cards) {
        if (bundle.citesYuldashevMaterial(c)) {
          expect(c.isFree, isTrue, reason: c.id);
        }
      }
      // Boshqa kartalarda bu qator chiqmaydi.
      expect(
        bundle.citesYuldashevMaterial(
          bundle.byId('guideline.chem.ethanol_gc')!,
        ),
        isFalse,
      );
    });

    test('majmua manbasi: teaching_material, iqtiboslar sahifa bilan', () {
      final ref = bundle.references['toks_majmua2025'];
      expect(ref, isNotNull);
      expect(ref!.type, 'teaching_material');
      expect(ref.isYuldashevMaterial, isTrue);
      expect(ref.citation, contains('Yuldashev'));
      expect(
        ref.citation,
        contains('Toshkent: Toshkent farmatsevtika instituti'),
      );
      expect(ref.citation, contains('(2025)'));
      expect(ref.doi, isNull);
      for (final c in cards.nonNulls) {
        for (final s in c.sections) {
          for (final lang in ['uz', 'ru', 'en']) {
            final body = s.body.of(lang);
            for (final m in RegExp(
              r'\[toks_majmua2025\](?! \()',
            ).allMatches(body)) {
              fail('${c.id}/${s.key}/$lang: page missing at ${m.start}');
            }
          }
        }
      }
    });

    // Manba auditi (docs/qa/TOKS_SOURCE_AUDIT.md): har bir majmua iqtibosi
    // aniq sahifa raqami bilan va kitob chegarasida; savollarda ham shunday.
    // Bosma sahifa raqami = PDF sahifa indeksi (toks 355 b., dvssm 350 b.).
    test('manba auditi: har bir iqtibos sahifasi kitob chegarasida', () {
      const maxPage = {'toks_majmua2025': 355, 'dvssm_majmua2025': 350};
      final cite = RegExp(
        r'\[(toks_majmua2025|dvssm_majmua2025)\]'
        r'( \((?:с\. |pp?\. )?([0-9][0-9–, ]*)(?:-b\.)?\))?',
      );
      List<int> pagesOf(String spec) => [
        for (final m in RegExp(r'\d+').allMatches(spec)) int.parse(m.group(0)!),
      ];
      var checked = 0;
      for (final c in cards.nonNulls) {
        for (final s in c.sections) {
          for (final lang in ['uz', 'ru', 'en']) {
            for (final m in cite.allMatches(s.body.of(lang))) {
              final where = '${c.id}/${s.key}/$lang@${m.start}';
              expect(m.group(2), isNotNull, reason: 'page missing: $where');
              final pages = pagesOf(m.group(3)!);
              expect(pages, isNotEmpty, reason: where);
              for (final p in pages) {
                expect(
                  p,
                  inInclusiveRange(1, maxPage[m.group(1)]!),
                  reason: where,
                );
              }
              checked++;
            }
          }
        }
        for (final q in c.quiz) {
          final pages = pagesOf(q.pages ?? '');
          expect(pages, isNotEmpty, reason: q.id);
          for (final p in pages) {
            expect(p, inInclusiveRange(1, 355), reason: q.id);
          }
        }
      }
      expect(checked, greaterThan(400));
    });

    test('manba auditi: hech bir karta HUMAN_VERIFIED emas', () {
      expect(raw.contains('HUMAN_VERIFIED'), isFalse);
      for (final c in bundle.cards) {
        expect(c.status, ScientificStatus.needsReview, reason: c.id);
      }
      for (final f in Directory(
        '../../content/guidelines/src',
      ).listSync().whereType<File>().where((f) => f.path.contains('toks'))) {
        final src = f.readAsStringSync();
        expect(src.contains('HUMAN_VERIFIED'), isFalse, reason: f.path);
        expect(
          src.contains('"status": "NEEDS_REVIEW"'),
          isTrue,
          reason: f.path,
        );
      }
    });

    test('o‘ldiruvchi yoki «mastlik» chegaralari qoida sifatida yo‘q', () {
      for (final c in cards.nonNulls) {
        for (final s in c.sections) {
          for (final lang in ['uz', 'ru', 'en']) {
            final body = s.body.of(lang);
            expect(body.contains('‰'), isFalse, reason: '${c.id}/${s.key}');
            expect(
              RegExp(r'\bmg/kg\b').hasMatch(body),
              isFalse,
              reason: '${c.id}/${s.key}/$lang',
            );
          }
        }
      }
    });

    test('savollar: ≥30, uch tilda, har birida 3 ta distraktor va sahifa', () {
      final quiz = [for (final c in cards.nonNulls) ...c.quiz];
      expect(quiz.length, greaterThanOrEqualTo(30));
      expect({for (final q in quiz) q.id}.length, quiz.length);
      for (final q in quiz) {
        expect(q.pages, isNotNull, reason: q.id);
        expect(q.distractors, hasLength(3), reason: q.id);
        for (final lang in ['uz', 'ru', 'en']) {
          expect(q.question.pick(lang).isFallback, isFalse, reason: q.id);
          expect(q.answer.pick(lang).isFallback, isFalse, reason: q.id);
          final a = q.answer.of(lang).trim().toLowerCase();
          for (final d in q.distractors) {
            expect(d.pick(lang).isFallback, isFalse, reason: q.id);
            expect(d.of(lang).trim().toLowerCase(), isNot(a), reason: q.id);
          }
        }
      }
    });
  });

  group('COHb (uglerod (II) oksidi) kartasi', () {
    final card = bundle.byId('guideline.chem.co_cohb_determination');

    test('tuzilma, vositalar va bepul kirish', () {
      expect(card, isNotNull);
      expect(card!.area, GuidelineArea.forensicChemistry);
      expect(card.status, ScientificStatus.needsReview);
      expect(card.sections, hasLength(8));
      expect(card.access, GuidelineAccess.free);
      expect(bundle.citesYuldashevMaterial(card), isFalse);
      for (final id in card.relatedToolIds) {
        expect(ToolsCatalog.byId(id)?.isAvailable, isTrue, reason: id);
      }
      final keys = bundle.referencesOf(card).map((r) => r.key).toSet();
      expect(
        keys,
        containsAll([
          'widdop2002',
          'kristoffersen2023',
          'lewis2004',
          'siek1984',
          'oritani2000',
        ]),
      );
      expect(bundle.references['kristoffersen2023']!.pmid, '36495201');
      expect(bundle.references['widdop2002']!.doi,
          '10.1258/000456302760042146');
    });

    test('talqin bo‘limi bor; o‘ldiruvchi chegaralar yo‘q', () {
      final cautions =
          card!.sections.singleWhere((s) => s.key == 'cautions');
      expect(cautions.body.of('uz'), contains('qat’iy belgilamaydi'));
      expect(cautions.body.of('en'), contains('cause of death'));
      for (final s in card.sections) {
        for (final lang in ['uz', 'ru', 'en']) {
          final body = s.body.of(lang);
          expect(RegExp(r'\bmg/kg\b').hasMatch(body), isFalse,
              reason: '${s.key}/$lang');
          expect(body.contains('‰'), isFalse, reason: '${s.key}/$lang');
        }
      }
    });
  });
}
