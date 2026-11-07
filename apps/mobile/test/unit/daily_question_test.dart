import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/app/class_quiz.dart' show ClassQuizBank;
import 'package:forensic_expert/domain/learn/study_models.dart';
import 'package:forensic_expert/domain/professional/professional_models.dart';
import 'package:forensic_expert/features/home/daily_question.dart';
import 'package:forensic_expert/features/home/workbench.dart';

import '../helpers/home_desk_world.dart' show deskCatalog, deskQuestionItem;

/// «Bugungi savol» manbasi (egasi qarori, 2026-11-07): asosan sud tibbiyoti
/// (sinf testlari banki), 10 kundan 1 kun toksikologiya; farmatsiya /
/// toksikologik kimyo yo‘nalishida — aksincha.
void main() {
  const fm = DailyQuestionDirection.forensicMedicine;
  const tox = DailyQuestionDirection.toxicology;

  Map<String, Object?> q(
    String id, {
    Set<String> langs = const {'uz', 'ru', 'en'},
    bool checked = true,
    String page = '57',
  }) => {
    'id': id,
    'question_i18n': {for (final l in langs) l: 'Savol $id ($l)?'},
    'options_i18n': {
      for (final l in langs) l: [for (var i = 0; i < 4; i++) 'V$i $id $l'],
    },
    'correct_index': 1,
    'explanation_i18n': {for (final l in langs) l: 'Izoh $id $l'},
    'source': {
      'author': 'G‘iyosov Z.A.',
      'title': 'Sud tibbiyoti: darslik',
      'page': page,
      if (checked)
        'checked': {'method': 'source_compare', 'date': '2026-10-18'},
    },
  };

  Map<String, Object?> topic(
    String id,
    String group,
    List<Map<String, Object?>> qs, {
    Map<String, String>? status,
  }) => {
    'id': id,
    'group': group,
    'number': 1,
    'title_i18n': {
      'uz': 'Mexanik jarohatlar $id',
      'ru': 'Механические повреждения $id',
      'en': 'Mechanical injuries $id',
    },
    'translation_status':
        status ??
        {'uz': 'source', 'ru': 'auto_unreviewed', 'en': 'auto_unreviewed'},
    'questions': qs,
  };

  final bank = ClassQuizBank.parse(
    jsonEncode({
      'groups': [
        {
          'id': 'sud-tibbiyoti-ktp-2026',
          'order': 5,
          'title_i18n': <String, String>{},
        },
        {'id': 'bioetika-2', 'order': 0, 'title_i18n': <String, String>{}},
      ],
      'topics': [
        topic('t1', 'sud-tibbiyoti-ktp-2026', [
          q('t1-q01'),
          q('t1-q02', langs: {'uz'}),
          q('t1-q03', checked: false),
        ]),
        topic('t2', 'sud-tibbiyoti-ktp-2026', [q('t2-q01')]),
        // Sud tibbiyoti emas — kirmaydi.
        topic('b1', 'bioetika-2', [q('b1-q01')]),
      ],
    }),
  );
  final catalog = deskCatalog([
    for (var i = 1; i <= 4; i++) deskQuestionItem(i),
  ]);

  /// 2026-11-01 dan boshlab kun raqami [p] ga mos [n] ta kun.
  List<DateTime> daysWith(bool Function(int day) p, int n) {
    final out = <DateTime>[];
    for (
      var d = DateTime(2026, 11, 1);
      out.length < n;
      d = d.add(const Duration(days: 1))
    ) {
      if (p(dayNumberOf(d))) out.add(d);
    }
    return out;
  }

  bool isBank(StudyQuestion question) =>
      question.item.deckId.startsWith(dailyBankDeckPrefix);

  group('9:1 aylanish', () {
    test('standart (sud tibbiyoti): 100 kunda 90 FM, 10 toks', () {
      final days = [
        for (var i = 0; i < 100; i++)
          DateTime(2026, 11, 1).add(Duration(days: i)),
      ];
      final picks = [
        for (final d in days)
          pickDailyQuestion(
            catalog: catalog,
            bank: bank,
            lang: 'uz',
            today: d,
          )!,
      ];
      expect(picks.where(isBank).length, 90);
      expect(picks.where((x) => !isBank(x)).length, 10);
      for (final (i, d) in days.indexed) {
        expect(
          isBank(picks[i]),
          dailyQuestionSourceFor(dayNumberOf(d), fm) == fm,
        );
      }
    });

    test('farmatsiya yo‘nalishi: 100 kunda 90 toks, 10 FM', () {
      final picks = [
        for (var i = 0; i < 100; i++)
          pickDailyQuestion(
            catalog: catalog,
            bank: bank,
            lang: 'uz',
            direction: tox,
            today: DateTime(2026, 11, 1).add(Duration(days: i)),
          )!,
      ];
      expect(picks.where((x) => !isBank(x)).length, 90);
      expect(picks.where(isBank).length, 10);
    });

    test('manba funksiyasi: 10 kundan aynan bittasi ozchilik', () {
      for (final primary in [fm, tox]) {
        final minor = [
          for (var d = 0; d < 1000; d++)
            if (dailyQuestionSourceFor(d, primary) != primary) d,
        ];
        expect(minor.length, 100);
        expect(minor.every((d) => d % 10 == dailyQuestionMinorityDay), isTrue);
      }
    });

    test('ozchilik kunlari ketma-ket har xil savol', () {
      final days = daysWith((d) => d % 10 == dailyQuestionMinorityDay, 2);
      final ids = [
        for (final d in days)
          pickDailyQuestion(
            catalog: catalog,
            bank: bank,
            lang: 'uz',
            today: d,
          )!.item.id,
      ];
      expect(ids.toSet().length, 2);
    });

    test('bir manba bo‘sh — ikkinchisi; ikkalasi bo‘sh — null', () {
      final d = daysWith((d) => d % 10 == dailyQuestionMinorityDay, 1).single;
      // Ozchilik kuni toks kerak, lekin katalog bo‘sh — bank savoli.
      final a = pickDailyQuestion(
        catalog: deskCatalog(const []),
        bank: bank,
        lang: 'uz',
        today: d,
      )!;
      expect(isBank(a), isTrue);
      // Bank bo‘sh — katalog savoli (avvalgi xatti-harakat).
      final b = pickDailyQuestion(
        catalog: catalog,
        lang: 'uz',
        today: DateTime(2026, 11, 1),
      )!;
      expect(isBank(b), isFalse);
      expect(
        pickDailyQuestion(catalog: deskCatalog(const []), lang: 'uz', today: d),
        isNull,
      );
    });
  });

  group('til va yaroqlilik', () {
    List<String> ids(String lang) => [
      for (final b in dailyForensicPool(bank, lang)) b(1).item.id,
    ];

    test('faqat shu tilda savol+variant bor, checked, sud tibbiyoti', () {
      expect(ids('uz'), [
        'classbank.t1-q01',
        'classbank.t1-q02',
        'classbank.t2-q01',
      ]);
      // Tarjimasi yo‘q savol ru/en’da yo‘q; ~ru/~en nusxa takrorlanmaydi.
      expect(ids('ru'), ['classbank.t1-q01~ru', 'classbank.t2-q01~ru']);
      expect(ids('en'), ['classbank.t1-q01~en', 'classbank.t2-q01~en']);
    });

    test('matn UI tilida, manba — mavzu nomi, avtomatik tarjima belgisi', () {
      final uz = dailyForensicPool(bank, 'uz').first(3);
      expect(uz.stem.resolve('uz'), 'Savol t1-q01 (uz)?');
      expect(uz.item.citations.single.title, 'Mexanik jarohatlar t1');
      expect(uz.item.draftLanguages, isEmpty);
      final ru = dailyForensicPool(bank, 'ru').first(3);
      expect(ru.stem.resolve('ru'), 'Savol t1-q01 (ru)?');
      expect(ru.item.citations.single.title, 'Механические повреждения t1');
      expect(ru.item.draftLanguages, {'ru'});
      expect(ru.correctText.resolve('ru'), 'V1 t1-q01 ru');
      for (var i = 0; i < 4; i++) {
        expect(ru.optionText(i).resolve('ru'), endsWith(' ru'));
      }
      expect(dailyQuestionRoute(ru), '/home/learn/groups/practice/t1~ru');
    });

    test('tarjimasi kutilayotgan mavzu boshqa tilda kirmaydi', () {
      final pending = ClassQuizBank.parse(
        jsonEncode({
          'groups': const <Object>[],
          'topics': [
            topic(
              'p1',
              'sud-tibbiyoti-ktp-2026',
              [q('p1-q01')],
              status: {'uz': 'source', 'ru': 'pending', 'en': 'pending'},
            ),
          ],
        }),
      );
      expect(dailyForensicPool(pending, 'uz'), hasLength(1));
      expect(dailyForensicPool(pending, 'ru'), isEmpty);
      expect(dailyForensicPool(pending, 'en'), isEmpty);
    });

    test('ilova banki: uch tilda ham sud tibbiyoti savollari bor', () {
      final real = ClassQuizBank.parse(
        File('assets/content/class_quiz/class_quiz_bank.json')
            .readAsStringSync(),
      );
      for (final lang in ['uz', 'ru', 'en']) {
        final pool = dailyForensicPool(real, lang);
        expect(pool.length, greaterThan(100), reason: lang);
        final s = pool.first(0);
        // Mavzu nomi, kod emas (`4-kurs-davolash-10` kabi).
        expect(
          s.item.citations.single.title,
          isNot(matches(RegExp(r'^[a-z0-9~-]+$'))),
          reason: lang,
        );
        expect(s.stem.values[lang], isNotEmpty);
      }
    });
  });

  group('aniqlik (determinism)', () {
    test('bir kunda bir xil savol va variantlar tartibi, ertasi — boshqa', () {
      final d = daysWith((d) => d % 10 == 0, 1).single;
      final a = pickDailyQuestion(
        catalog: catalog,
        bank: bank,
        lang: 'uz',
        today: d,
      )!;
      final a2 = pickDailyQuestion(
        catalog: catalog,
        bank: bank,
        lang: 'uz',
        today: d.add(const Duration(hours: 14)),
      )!;
      expect(isBank(a), isTrue);
      expect(a2.item.id, a.item.id);
      expect(a2.correctIndex, a.correctIndex);
      expect(
        [for (var i = 0; i < 4; i++) a2.optionText(i).resolve('uz')],
        [for (var i = 0; i < 4; i++) a.optionText(i).resolve('uz')],
      );
      final next = pickDailyQuestion(
        catalog: catalog,
        bank: bank,
        lang: 'uz',
        today: d.add(const Duration(days: 1)),
      )!;
      expect(next.item.id, isNot(a.item.id));
      expect(
        a.optionText(a.correctIndex).resolve('uz'),
        'V1 ${a.item.id.substring(10)} uz',
      );
    });
  });

  group('yo‘nalish', () {
    StudentProfile student({
      String? faculty,
      List<Specialty> interests = const [],
    }) => StudentProfile(
      fullName: 'Talaba',
      country: 'UZ',
      faculty: faculty,
      interests: interests,
    );
    ProfessionalProfile pro(Specialty s) => ProfessionalProfile(
      fullName: 'Ekspert',
      country: 'UZ',
      organization: 'Lab',
      position: 'Ekspert',
      primarySpecialty: s,
      education: 'MSc',
    );

    test('noma’lum — sud tibbiyoti', () {
      expect(dailyQuestionDirectionOf(), fm);
      expect(
        dailyQuestionDirectionOf(
          profile: LocalUserProfile(student: student(faculty: 'Davolash ishi')),
        ),
        fm,
      );
      expect(
        dailyQuestionDirectionOf(
          profile: LocalUserProfile(professional: pro(Specialty.other)),
        ),
        fm,
      );
    });

    test('farmatsiya / toksikologik kimyo / sud-kimyo — toksikologiya', () {
      for (final f in [
        'Farmatsiya',
        'Sanoat farmatsiyasi',
        'Toksikologik kimyo',
        'Фармацевтический',
        'Faculty of Pharmacy',
        'Sud-kimyo',
      ]) {
        expect(
          dailyQuestionDirectionOf(
            profile: LocalUserProfile(student: student(faculty: f)),
          ),
          tox,
          reason: f,
        );
      }
      expect(
        dailyQuestionDirectionOf(
          profile: LocalUserProfile(
            student: student(interests: [Specialty.forensicToxicology]),
          ),
        ),
        tox,
      );
      for (final s in [
        Specialty.forensicChemistry,
        Specialty.forensicToxicology,
      ]) {
        expect(
          dailyQuestionDirectionOf(
            profile: LocalUserProfile(professional: pro(s)),
          ),
          tox,
        );
      }
      expect(
        dailyQuestionDirectionOf(
          profile: LocalUserProfile(
            professional: pro(Specialty.forensicMedicine),
          ),
        ),
        fm,
      );
    });

    test('«Ish stolim»da tanlangan ko‘rinish ustun', () {
      final chem = LocalUserProfile(
        professional: pro(Specialty.forensicChemistry),
      );
      expect(
        dailyQuestionDirectionOf(
          view: WorkbenchSpecialty.medicine,
          profile: chem,
        ),
        fm,
      );
      expect(dailyQuestionDirectionOf(view: WorkbenchSpecialty.chemistry), tox);
    });
  });
}
