import '../../domain/class_quiz/class_quiz_models.dart';

/// Savol banki yozuvi — server `class_quiz_questions` va `tools/slides`
/// `mcq` elementi bilan bir xil shakl:
/// `{question, options[4], correct_index, explanation, source{author,title,page}}`.
class ClassBankQuestion {
  const ClassBankQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.source,
    this.id = '',
  });

  /// `tools/slides/out/*.json` dagi `mcq[i]` (yoki import fayli) elementidan.
  /// Shakli noto‘g‘ri bo‘lsa `null` (to‘qilmaydi, qiymat to‘ldirilmaydi).
  static ClassBankQuestion? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final q = raw['question'];
    final opts = raw['options'];
    final ci = raw['correct_index'];
    final src = raw['source'];
    if (q is! String || q.trim().length < 5) return null;
    if (opts is! List || opts.length != 4 || opts.any((o) => o is! String)) {
      return null;
    }
    if (ci is! int || ci < 0 || ci > 3) return null;
    if (src is! Map) return null;
    final source = ClassSource.fromJson(src.cast<String, Object?>());
    if (source.author.isEmpty || source.title.isEmpty) return null;
    return ClassBankQuestion(
      id: raw['id'] is String ? raw['id']! as String : '',
      question: q,
      options: [for (final o in opts) o as String],
      correctIndex: ci,
      explanation: (raw['explanation'] as String?) ?? '',
      source: source,
    );
  }

  /// Bankdagi barqaror id (asset: `<mavzu>-qNN`, til varianti `~ru`/`~en`).
  /// Bo‘sh — demo to‘plam (id ni chaqiruvchi beradi).
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final ClassSource source;
}

class ClassBankTopic {
  const ClassBankTopic({
    required this.id,
    required this.title,
    required this.questions,
    this.isDemo = false,
  });

  final String id;
  final String title;
  final List<ClassBankQuestion> questions;
  final bool isDemo;
}

const _demoSource = ClassSource(
  author: 'DEMO',
  title: 'DEMO savol (ilmiy manba emas)',
  page: '-',
);

ClassBankQuestion _q(
  String question,
  List<String> options,
  int correct,
  String explanation,
) => ClassBankQuestion(
  question: question,
  options: options,
  correctIndex: correct,
  explanation: explanation,
  source: _demoSource,
);

/// Demo uchun 10 ta oddiy savol. **DEMO**: umumiy bilim, sud-ekspertiza
/// kontenti emas va ilmiy manbaga ega emas — faqat oqimni sinash uchun.
/// Haqiqiy savollar serverdagi `class_quiz_questions` bankidan keladi.
final ClassBankTopic classQuizDemoTopic = ClassBankTopic(
  id: 'demo-topic',
  title: 'DEMO: oddiy savollar',
  isDemo: true,
  questions: [
    _q(
      'Toshkent qaysi davlatning poytaxti?',
      ['Qozog‘iston', 'O‘zbekiston', 'Qirg‘iziston', 'Tojikiston'],
      1,
      'Toshkent — O‘zbekiston poytaxti.',
    ),
    _q('7 × 8 nechaga teng?', ['54', '56', '48', '64'], 1, '7 × 8 = 56.'),
    _q(
      'Bir haftada necha kun bor?',
      ['5', '6', '7', '10'],
      2,
      'Hafta 7 kundan iborat.',
    ),
    _q(
      'Suvning kimyoviy formulasi qaysi?',
      ['CO2', 'H2O', 'NaCl', 'O2'],
      1,
      'Suv molekulasi ikki vodorod va bir kislorod atomidan iborat: H2O.',
    ),
    _q(
      'Bir soatda necha daqiqa bor?',
      ['30', '45', '60', '100'],
      2,
      '1 soat = 60 daqiqa.',
    ),
    _q(
      'Yilda necha oy bor?',
      ['10', '11', '12', '13'],
      2,
      'Yil 12 oydan iborat.',
    ),
    _q(
      'Kvadratning nechta tomoni bor?',
      ['3', '4', '5', '6'],
      1,
      'Kvadratning to‘rtta teng tomoni bor.',
    ),
    _q(
      'Yer qaysi yulduz atrofida aylanadi?',
      ['Oy', 'Mars', 'Quyosh', 'Venera'],
      2,
      'Yer Quyosh atrofida aylanadi.',
    ),
    _q(
      'Eng katta okean qaysi?',
      [
        'Tinch okeani',
        'Atlantika okeani',
        'Hind okeani',
        'Shimoliy Muz okeani',
      ],
      0,
      'Tinch okeani Yerdagi eng katta okeandir.',
    ),
    _q(
      '100 ning yarmi nechaga teng?',
      ['25', '40', '50', '75'],
      2,
      '100 / 2 = 50.',
    ),
  ],
);
