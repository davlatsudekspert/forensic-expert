import 'dart:convert';
import 'dart:io';

import 'package:fe_content_schema/fe_content_schema.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/core/l10n/generated/app_localizations.dart';
import 'package:forensic_expert/domain/catalog/tools_catalog.dart';
import 'package:forensic_expert/domain/court_prep/court_prep_models.dart';
import 'package:forensic_expert/domain/guidelines/guideline_models.dart';
import 'package:forensic_expert/domain/ports/billing_ports.dart';
import 'package:forensic_expert/features/court_prep/presentation/court_prep_screens.dart';

/// Ilovaga qo‘shilgan haqiqiy «Sudda so‘roq» paketi: karta tuzilmasi
/// (A–I), manba joylari, yurisdiksiya, simulyator baholashi.
void main() {
  final raw = File('assets/content/court_prep/court_prep_v1.json')
      .readAsStringSync();
  final bundle = CourtPrepBundle.fromJson(
    (jsonDecode(raw) as Map).cast<String, Object?>(),
  );
  final guidelines = GuidelineBundle.fromJson(
    (jsonDecode(
      File('assets/content/guidelines/guidelines_v1.json').readAsStringSync(),
    ) as Map).cast<String, Object?>(),
  );
  const langs = ['uz', 'ru', 'en'];

  test('mavzular: tayyorlanayotgan mavzu savolsiz, qolganlarida savol bor', () {
    expect(bundle.topics.length, greaterThanOrEqualTo(14));
    expect(bundle.questions.length, inInclusiveRange(30, 60));
    for (final t in bundle.topics) {
      final n = bundle.questions.where((q) => q.topicId == t.id).length;
      expect(n == 0, t.pending, reason: t.id);
      expect(courtTopicIcon(t.icon), isNot(courtTopicIcon('?')), reason: t.id);
    }
  });

  test('karta tuzilmasi: A savol, B qisqa javob, C asos, E/F 2–5 qo‘shimcha '
      'savol, G cheklov, tayyorgarlik; uch til', () {
    for (final q in bundle.questions) {
      for (final lang in langs) {
        expect(q.question.pick(lang).isFallback, isFalse, reason: q.id);
        expect(q.tests.pick(lang).isFallback, isFalse, reason: q.id);
        expect(q.shortAnswer.pick(lang).isFallback, isFalse, reason: q.id);
        for (final b in CourtPrepBlock.values) {
          expect(q.block(b), isNotEmpty, reason: '${q.id}/${b.name}');
          for (final it in q.block(b)) {
            expect(it.pick(lang).isFallback, isFalse, reason: q.id);
          }
        }
        for (final f in q.followups) {
          expect(f.question.pick(lang).isFallback, isFalse, reason: q.id);
          expect(f.answer.pick(lang).isFallback, isFalse, reason: q.id);
        }
      }
      expect(q.followups.length, inInclusiveRange(2, 5), reason: q.id);
      expect(q.limitations, isNotEmpty, reason: q.id);
    }
  });

  test('I. holat: hech qachon tasdiqlangan emas (HUMAN_VERIFIED yo‘q)', () {
    expect(raw.contains('HUMAN_VERIFIED'), isFalse);
    for (final q in bundle.questions) {
      expect(q.status, ScientificStatus.needsReview, reason: q.id);
    }
    // Fayl «VERIFIED» yoki «HUMAN_VERIFIED» desa ham — NEEDS_REVIEW.
    for (final status in ['VERIFIED', 'HUMAN_VERIFIED', 'REVIEWED']) {
      final q = CourtPrepQuestion.fromJson({
        'id': 'x',
        'topic': 't',
        'status': status,
      });
      expect(q.status, ScientificStatus.needsReview, reason: status);
    }
  });

  test('D. manba joylari: har iqtibosda joy yoki aniq «tekshirilmagan»', () {
    final l = lookupAppLocalizations(const Locale('uz'));
    final items = <CourtSourced>[
      ...bundle.questions,
      ...bundle.principles,
      ...bundle.scenarios,
    ];
    for (final item in items) {
      final refs = bundle.referencesOf(item);
      expect(refs.length, item.citations.length);
      expect(refs, isNotEmpty);
      for (final r in refs) {
        expect(r.verifiedVia, isNotNull, reason: r.key);
        expect(item.locators.containsKey(r.key), isTrue, reason: r.key);
        final locs = item.locatorsOf(r.key);
        if (locs == null) {
          // Matni o‘qilmagan standart — UI «Manba tekshirilmagan» deydi.
          expect(r.key, 'court_iso17025_2017');
          expect(
            courtSourceLine(l, 1, r, locs),
            contains(l.courtSourceUnverified),
          );
        } else {
          for (final loc in locs) {
            final label = courtLocatorLabel(l, loc);
            expect(label, isNot(contains(':')), reason: '${r.key} $label');
          }
        }
      }
    }
  });

  test('matndagi [kalit] iqtiboslar raqamga aylanadi', () {
    for (final q in bundle.questions) {
      final index = courtRefIndex(bundle, q);
      final texts = [
        q.tests,
        q.shortAnswer,
        for (final b in CourtPrepBlock.values) ...q.block(b),
        for (final f in q.followups) f.answer,
        ...q.limitations,
      ];
      for (final tri in texts) {
        for (final lang in langs) {
          final out = courtCite(tri, lang, index);
          expect(
            RegExp(r'\[[a-z][a-z0-9_]*\]').hasMatch(out),
            isFalse,
            reason: '${q.id}/$lang: $out',
          );
        }
      }
    }
  });

  test('yurisdiksiya: O‘zbekiston — JPK savollari, boshqa — xalqaro', () {
    final uz = bundle.visible(uzbekistan: true).map((q) => q.id).toSet();
    final intl = bundle.visible(uzbekistan: false).map((q) => q.id).toSet();
    expect(uz, containsAll(['court.q.rights_uz', 'court.q.duties_uz']));
    expect(uz.contains('court.q.rights_intl'), isFalse);
    expect(intl, containsAll(['court.q.rights_intl', 'court.q.duties_intl']));
    expect(intl.contains('court.q.rights_uz'), isFalse);
    final law = bundle.references['court_uz_expertise_law']!;
    expect(law.isLaw, isTrue);
    expect(law.url, 'https://lex.uz/docs/1633100');
  });

  test('bepul/Pro: kartalar hamma uchun; Pro — faqat kengaytirilgan mashq', () {
    expect(bundle.samples, isEmpty, reason: 'karta paywall belgisi yo‘q');
    expect(
      FeatureGate.minimumTier(ProductFeature.courtTestimonyPrep),
      PlanTier.professionalPro,
    );
    // Asosiy (bepul) ssenariylar bor, qolganlari Pro.
    final free = bundle.scenarios.where(
      (s) => courtScenarioOpen(s, unlocked: false),
    );
    expect(free.length, inInclusiveRange(1, 3));
    expect(free.length, lessThan(bundle.scenarios.length));
    expect(
      bundle.scenarios.every((s) => courtScenarioOpen(s, unlocked: true)),
      isTrue,
    );
    // Rol mashqi — har roldan bittadan, belgilangan tartibda.
    expect(
      courtDrillScenarios(bundle).map((s) => s.role).toList(),
      CourtRole.values,
    );
  });

  test('simulyator tekshirilmagan manbaga tayangan javobni to‘g‘ri deb '
      'baholamaydi', () {
    for (final s in bundle.scenarios) {
      final best = s.best!;
      expect(s.reliesOnUnverified(best), isFalse, reason: s.id);
      for (final lang in langs) {
        expect(
          RegExp('^(To‘g‘ri|Correct|Верно)').hasMatch(best.feedback.of(lang)),
          isFalse,
          reason: '${s.id}/$lang',
        );
      }
    }
    // Sintetik: eng yaxshi variant joyi tasdiqlanmagan manbaga tayansa —
    // har mezon ko‘pi bilan 1 («qisman»).
    final s = CourtScenario.fromJson({
      'id': 'x',
      'role': 'judge',
      'options': [
        {
          'text': {'uz': 'a'},
          'scores': {
            'accuracy': 2,
            'sources': 2,
            'limitations': 2,
            'impartiality': 2,
          },
          'feedback': {'uz': 'Izoh [court_iso17025_2017].'},
        },
      ],
      'citations': ['court_iso17025_2017'],
      'locators': {'court_iso17025_2017': null},
    });
    final o = s.options.single;
    expect(s.reliesOnUnverified(o), isTrue);
    expect(s.effectiveScore(o).isBest, isFalse);
    for (final cr in CourtCriterion.values) {
      expect(s.effectiveScore(o).of(cr), 1);
    }
  });

  test('shaxsiy tarix: kodlash/ochish, chegara, statistika', () {
    final at = DateTime.utc(2026, 10, 9, 12);
    final a = CourtAttempt(
      scenarioId: 'court.sim.certainty',
      score: const CourtScore({
        CourtCriterion.accuracy: 2,
        CourtCriterion.sources: 1,
        CourtCriterion.limitations: 2,
        CourtCriterion.impartiality: 0,
      }),
      at: at,
      drill: true,
    );
    final back = CourtHistoryCodec.decode(CourtHistoryCodec.encode([a, a]));
    expect(back, hasLength(2));
    expect(back.first.score.total, 5);
    expect(back.first.drill, isTrue);
    expect(back.first.at, at);
    final many = List.filled(CourtHistoryCodec.limit + 5, a);
    expect(
      CourtHistoryCodec.decode(CourtHistoryCodec.encode(many)),
      hasLength(CourtHistoryCodec.limit),
    );
    final stats = CourtStats(back);
    expect(stats.count, 2);
    expect(stats.average(CourtCriterion.sources), 1);
    expect(stats.bestTotal('court.sim.certainty'), 5);
    expect(CourtHistoryCodec.decode('not json'), isEmpty);
  });

  test('ilova ichidagi havolalar mavjud kontentga olib boradi', () {
    for (final q in bundle.questions) {
      for (final link in q.links) {
        switch (link.kind) {
          case 'guideline':
            expect(guidelines.byId(link.id), isNotNull, reason: link.id);
          case 'tool':
            expect(ToolsCatalog.byId(link.id), isNotNull, reason: link.id);
          case 'page':
            expect({
              'sources',
              'specimens',
              'standards',
              'conflicts',
            }, contains(link.id));
          default:
            fail('unknown link kind ${link.kind}');
        }
      }
    }
  });

  test('H. bibliografik eksport: BibTeX va matn qatori', () {
    final l = lookupAppLocalizations(const Locale('en'));
    final dror = bundle.references['court_dror2020']!;
    final bib = dror.toBibtex();
    expect(bib, startsWith('@article{court_dror2020,'));
    expect(bib, contains('doi = {10.1021/acs.analchem.0c00704}'));
    final line = courtSourceLine(l, 2, dror, const [CourtLocator('abstract')]);
    expect(line, contains('https://doi.org/10.1021/acs.analchem.0c00704'));
    expect(line, endsWith('— Abstract'));
    final book = bundle.references['court_yuldashev_toks2025']!;
    expect(book.isTeacherBook, isTrue);
    expect(book.toBibtex(), startsWith('@book{'));
  });

  test('simulyator: 4 rol, har ssenariyda bitta namunaviy javob', () {
    expect(
      bundle.scenarios.map((s) => s.role).toSet(),
      CourtRole.values.toSet(),
    );
    for (final s in bundle.scenarios) {
      expect(
        s.options.where((o) => o.score.isBest),
        hasLength(1),
        reason: s.id,
      );
      expect(bundle.question(s.questionId!), isNotNull, reason: s.id);
      // Eng yaxshi javob — barcha 4 mezon bo‘yicha 2 ball.
      for (final cr in CourtCriterion.values) {
        expect(s.best!.score.of(cr), 2, reason: '${s.id}/${cr.name}');
      }
    }
  });

  test('simulyator: erkin matnni qoidaga asoslangan baholash', () {
    final r = bundle.rubric;
    final over = r.evaluate('Natija 100% to‘g‘ri, albatta modda bor edi.');
    expect(over.overstatement, isTrue);
    expect(over.score.of(CourtCriterion.accuracy), 0);
    final evade = r.evaluate('Bu haqda javob bermayman, kechirasiz.');
    expect(evade.evasion, isTrue);
    final good = r.evaluate(
      'Bu taxminiy natija; validatsiya hujjati va nazorat namunalari bor, '
      'noaniqlik va cheklov bor, muqobil izohni ham ko‘rib chiqaman.',
    );
    expect(good.overstatement, isFalse);
    expect(good.score.of(CourtCriterion.sources), 2);
    expect(good.score.of(CourtCriterion.limitations), 2);
    expect(good.score.of(CourtCriterion.impartiality), greaterThan(0));
    // Ilmiy aniqlik avtomatik 2 bo‘lmaydi — namunaviy javob bilan solishtirish.
    expect(good.score.of(CourtCriterion.accuracy), 1);
    expect(r.evaluate('ha').tooShort, isTrue);
  });
}
