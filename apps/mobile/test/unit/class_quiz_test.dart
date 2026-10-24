import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_expert/data/class_quiz/class_quiz_demo_bank.dart';
import 'package:forensic_expert/domain/class_quiz/class_quiz_models.dart';

void main() {
  group('ClassCode', () {
    test('normalize: 6 raqam, bo‘shliq/defis olib tashlanadi', () {
      expect(ClassCode.normalize('123456'), '123456');
      expect(ClassCode.normalize('123 456'), '123456');
      expect(ClassCode.normalize(' 123-456 '), '123456');
      expect(ClassCode.normalize('12345'), isNull);
      expect(ClassCode.normalize('1234567'), isNull);
      expect(ClassCode.normalize('12a456'), isNull);
      expect(ClassCode.normalize(null), isNull);
    });

    test('generate: har doim 6 raqam, bosh nollar saqlanadi', () {
      final rng = Random(7);
      for (var i = 0; i < 2000; i++) {
        final c = ClassCode.generate(rng);
        expect(c, matches(RegExp(r'^[0-9]{6}$')));
      }
      // 000042 kabi kod yo‘qolib qolmasin
      expect(ClassCode.normalize('000042'), '000042');
    });

    test('display va yo‘l', () {
      expect(ClassCode.display('123456'), '123 456');
      expect(ClassCode.routeFor('123456'), '/join/123456');
    });

    test('havoladan kod: https, ilova sxemasi, yo‘l, query', () {
      expect(
        ClassCode.extract(Uri.parse('https://example.org/join/123456')),
        '123456',
      );
      expect(
        ClassCode.extract(Uri.parse('forensicexpert://app/join/654321')),
        '654321',
      );
      expect(ClassCode.extract(Uri.parse('/join/111222')), '111222');
      expect(ClassCode.extract(Uri.parse('/x?code=222333')), '222333');
      expect(ClassCode.extract(Uri.parse('/join/abc')), isNull);
      expect(ClassCode.extract(Uri.parse('/join/12345')), isNull);
    });

    test('QR matni: havola yoki oddiy raqam', () {
      expect(ClassCode.fromScanned('https://x.org/join/123456'), '123456');
      expect(ClassCode.fromScanned('123456'), '123456');
      expect(ClassCode.fromScanned('hello'), isNull);
      expect(ClassCode.fromScanned(null), isNull);
    });

    test('joinLink: domen bo‘lsa https, bo‘lmasa ilova sxemasi', () {
      expect(
        ClassCode.joinLink(
          '123456',
          publicBase: Uri.parse('https://forensic.example'),
        ).toString(),
        'https://forensic.example/join/123456',
      );
      expect(
        ClassCode.joinLink(
          '123456',
          publicBase: Uri.parse('https://forensic.example/app/'),
        ).toString(),
        'https://forensic.example/app/join/123456',
      );
      expect(
        ClassCode.joinLink('123456').toString(),
        'forensicexpert://app/join/123456',
      );
      // Havoladan kod qaytadan chiqadi.
      expect(ClassCode.extract(ClassCode.joinLink('123456')), '123456');
    });
  });

  group('ClassNickname', () {
    test('uzunlik 2–20', () {
      expect(ClassNickname.check('A'), NicknameCheck.length);
      expect(ClassNickname.check('  '), NicknameCheck.length);
      expect(ClassNickname.check('Ali'), NicknameCheck.ok);
      expect(ClassNickname.check('x' * 20), NicknameCheck.ok);
      expect(ClassNickname.check('x' * 21), NicknameCheck.length);
    });

    test('belgilar: markup va faqat ajratgichlar rad', () {
      expect(ClassNickname.check('a<b>'), NicknameCheck.chars);
      expect(ClassNickname.check('a"b'), NicknameCheck.chars);
      expect(ClassNickname.check('___'), NicknameCheck.chars);
      expect(ClassNickname.check('Gul_nora'), NicknameCheck.ok);
      expect(ClassNickname.check('O‘tkir'), NicknameCheck.ok);
      expect(ClassNickname.check('Дилнозa'), NicknameCheck.ok);
    });

    test('nomaqbul so‘zlar: yashirinishlar ham ushlanadi', () {
      expect(ClassNickname.check('f.u.c.k'), NicknameCheck.blocked);
      expect(ClassNickname.check('Sh1t'), NicknameCheck.blocked);
      expect(ClassNickname.check('PIDOR'), NicknameCheck.blocked);
      expect(ClassNickname.check('xuy'), NicknameCheck.blocked);
      expect(ClassNickname.check('Мудак'), NicknameCheck.blocked);
    });

    test('oddiy so‘zlarda yolg‘on ishga tushmaydi', () {
      for (final ok in ['Passenger', 'Klassik', 'Sikl', 'Husniya', 'Sexta']) {
        // “Sexta” — to‘liq so‘z “sex” emas; “Sikl” — “sik” emas.
        expect(ClassNickname.check(ok), NicknameCheck.ok, reason: ok);
      }
    });

    test('takror laqab: 2, 3, … qo‘shiladi; 20 belgidan oshmaydi', () {
      expect(ClassNickname.dedupe('Ali', ['Gulnora']), 'Ali');
      expect(ClassNickname.dedupe('Ali', ['ali']), 'Ali2');
      expect(ClassNickname.dedupe('Ali', ['Ali', 'ali2', 'ALI3']), 'Ali4');
      final long = 'x' * 20;
      final d = ClassNickname.dedupe(long, [long]);
      expect(d.length, 20);
      expect(d.endsWith('2'), isTrue);
    });

    test('clean: ortiqcha bo‘shliq', () {
      expect(ClassNickname.clean('  Ali   Vali '), 'Ali Vali');
    });
  });

  group('ClassScoring', () {
    test('ball: tez javob ko‘proq, kech javob 500, noto‘g‘ri 0', () {
      int p(bool ok, int e) =>
          ClassScoring.points(correct: ok, elapsedMs: e, limitMs: 30000);
      expect(p(true, 0), 1000);
      expect(p(true, 15000), 750);
      expect(p(true, 30000), 500);
      expect(p(true, 99999), 500, reason: 'limitdan oshgani limit deb olinadi');
      expect(p(true, -5), 1000);
      expect(p(false, 0), 0);
      expect(ClassScoring.points(correct: true, elapsedMs: 1, limitMs: 0), 0);
    });

    test('ball tezlik bo‘yicha kamaymaydigan emas (monoton)', () {
      var prev = 1 << 30;
      for (var e = 0; e <= 30000; e += 500) {
        final v = ClassScoring.points(
          correct: true,
          elapsedMs: e,
          limitMs: 30000,
        );
        expect(v <= prev, isTrue);
        prev = v;
      }
    });

    test('SQL bilan bir xil butun son bo‘linishi', () {
      // 500 + floor(500 * (limit - e) / limit)
      expect(
        ClassScoring.points(correct: true, elapsedMs: 1000, limitMs: 15000),
        500 + (500 * 14000) ~/ 15000,
      );
    });
  });

  group('ClassResultsCsv', () {
    const rows = [
      ClassExportRow(
        nickname: 'Ali',
        score: 1800,
        correct: 2,
        answered: 2,
        avgMs: 4250,
        rank: 1,
      ),
      ClassExportRow(
        nickname: '=HYPERLINK("x")',
        score: 0,
        correct: 0,
        answered: 0,
        avgMs: 0,
        rank: 2,
      ),
      ClassExportRow(
        nickname: 'A,B',
        score: 500,
        correct: 1,
        answered: 1,
        avgMs: 30000,
        rank: 3,
      ),
    ];

    test('ustunlar: laqab, ball, to‘g‘ri soni, javob vaqti', () {
      final csv = ClassResultsCsv.build(rows);
      final lines = csv.trim().split('\r\n');
      expect(lines.first, 'laqab,ball,togri_soni,javob_vaqti_s');
      expect(lines[1], 'Ali,1800,2,4.3');
    });

    test('formula in’yeksiyasi va vergul', () {
      final csv = ClassResultsCsv.build(rows);
      expect(csv, contains('\'=HYPERLINK'));
      expect(csv, contains('"A,B",500,1,30.0'));
    });

    test('fayl nomi ASCII va sanaga ega', () {
      final n = ClassResultsCsv.fileName('123456', DateTime(2026, 10, 17));
      expect(n, 'guruh_test_123456_2026-10-17.csv');
      expect(n.codeUnits.every((c) => c < 128), isTrue);
      expect(
        ClassResultsCsv.fileName('Ў-ҚҲ', DateTime(2026, 1, 2)),
        'guruh_test_sessiya_2026-01-02.csv',
      );
    });
  });

  group('JSON', () {
    test('ClassFailure.fromServer xaritasi', () {
      expect(ClassFailure.fromServer('rate_limited'), ClassFailure.rateLimited);
      expect(ClassFailure.fromServer('nick_blocked'), ClassFailure.nickBlocked);
      expect(ClassFailure.fromServer('time_over'), ClassFailure.timeOver);
      expect(ClassFailure.fromServer('???'), ClassFailure.server);
      expect(ClassFailure.fromServer(null), ClassFailure.server);
    });

    test('talaba holati: ochiq savolda to‘g‘ri javob yo‘q', () {
      final st = ClassStudentState.fromJson({
        'ok': true,
        'id': 's1',
        'code': '123456',
        'status': 'running',
        'phase': 'open',
        'remaining_ms': 12000,
        'joined': 3,
        'nickname': 'Ali',
        'score': 0,
        'correct': 0,
        'current_index': 0,
        'total': 5,
        'seconds': 30,
        'question': {
          'index': 0,
          'text': 'Savol?',
          'options': [
            {'id': 'o0', 'text': 'A'},
            {'id': 'o1', 'text': 'B'},
          ],
        },
      });
      expect(st.status, ClassSessionStatus.running);
      expect(st.phase, ClassPhase.open);
      expect(st.reveal, isNull);
      expect(st.question!.options.length, 2);
      expect(st.remainingMs, 12000);
    });

    test('dashboard JSON: joriy savol va eng qiyin', () {
      final d = ClassDashboard.fromJson({
        'id': 's1',
        'code': '123456',
        'status': 'running',
        'phase': 'closed',
        'joined': 4,
        'remaining_ms': 0,
        'reports': 1,
        'participants': [
          {'id': 'p1', 'nickname': 'Ali'},
        ],
        'leaderboard': [
          {
            'participant_id': 'p1',
            'nickname': 'Ali',
            'score': 900,
            'correct': 1,
            'rank': 1,
          },
        ],
        'hardest': [
          {'index': 2, 'text': 'Q3', 'answered': 4, 'correct_pct': 25},
        ],
        'current': {
          'index': 0,
          'text': 'Savol?',
          'correct_option': 'o1',
          'explanation': 'izoh',
          'answered': 4,
          'correct_count': 3,
          'options': [
            {'id': 'o0', 'text': 'A', 'count': 1},
            {'id': 'o1', 'text': 'B', 'count': 3},
          ],
        },
      });
      expect(d.current!.correctPct, 75);
      expect(d.hardest.single.correctPct, 25);
      expect(d.reports, 1);
      expect(d.leaderboard.single.nickname, 'Ali');
    });
  });

  group('savol banki formati', () {
    test('tools/slides mcq elementi tryParse bilan o‘qiladi', () {
      final q = ClassBankQuestion.tryParse({
        'question': 'Savol matni?',
        'options': ['a', 'b', 'c', 'd'],
        'correct_index': 2,
        'explanation': 'izoh',
        'source': {'author': 'Muallif', 'title': 'Kitob', 'page': '12'},
      });
      expect(q, isNotNull);
      expect(q!.correctIndex, 2);
      expect(q.source.page, '12');
    });

    test('noto‘g‘ri shakl to‘qilmaydi: null qaytadi', () {
      Map<String, Object?> base() => {
        'question': 'Savol matni?',
        'options': ['a', 'b', 'c', 'd'],
        'correct_index': 0,
        'source': {'author': 'M', 'title': 'K', 'page': '1'},
      };
      expect(ClassBankQuestion.tryParse(base()), isNotNull);
      expect(
        ClassBankQuestion.tryParse(base()..['options'] = ['a', 'b', 'c']),
        isNull,
      );
      expect(ClassBankQuestion.tryParse(base()..['correct_index'] = 4), isNull);
      expect(ClassBankQuestion.tryParse(base()..remove('source')), isNull);
      expect(
        ClassBankQuestion.tryParse(
          base()..['source'] = {'author': '', 'title': '', 'page': ''},
        ),
        isNull,
        reason: 'manbasiz savol bankka kirmaydi',
      );
      expect(ClassBankQuestion.tryParse('x'), isNull);
    });

    test(
      'DEMO mavzu: 10 ta savol, hammasi DEMO belgili va to‘g‘ri shaklda',
      () {
        expect(classQuizDemoTopic.isDemo, isTrue);
        expect(classQuizDemoTopic.questions.length, 10);
        for (final q in classQuizDemoTopic.questions) {
          expect(q.options.length, 4);
          expect(q.options.toSet().length, 4, reason: q.question);
          expect(q.correctIndex, inInclusiveRange(0, 3));
          expect(q.source.author, 'DEMO');
          expect(q.explanation, isNotEmpty);
        }
        expect(classQuizDemoTopic.title, startsWith('DEMO'));
      },
    );
  });

  test('ClassQuizSettings.valid chegaralari', () {
    expect(const ClassQuizSettings().valid, isTrue);
    expect(const ClassQuizSettings(questionCount: 4).valid, isFalse);
    expect(const ClassQuizSettings(questionCount: 21).valid, isFalse);
    expect(const ClassQuizSettings(studentLimit: 4).valid, isFalse);
    expect(const ClassQuizSettings(studentLimit: 201).valid, isFalse);
    expect(const ClassQuizSettings(seconds: 20).valid, isFalse);
    for (final s in [15, 30, 45, 60]) {
      expect(ClassQuizSettings(seconds: s).valid, isTrue);
    }
  });
}
