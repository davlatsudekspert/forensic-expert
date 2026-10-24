import 'dart:convert';

import 'class_quiz_demo_bank.dart';

/// Ilova asseti: `tools/class_quiz/import_quiz_bank.py` yaratadi
/// (`slides-out` branchidagi `quiz/*.json` dan; uz asl + ru/en avtomatik
/// tarjima, tekshirilmagan).
const classQuizBankAsset = 'assets/content/class_quiz/class_quiz_bank.json';

/// Bank tillari. Har mavzu uchta til varianti sifatida beriladi: `<id>` (uz),
/// `<id>~ru`, `<id>~en` — server `class_quiz_questions` bilan bir xil
/// (sessiya savollari bitta tilda nusxalanadi, proyektor va talabalar bir xil
/// matnni ko‘radi).
const classQuizBankLangs = ['uz', 'ru', 'en'];

/// Kurs/fan guruhi (masalan «Sud tibbiyoti · 4-kurs, davolash ishi»).
class ClassQuizBankGroup {
  const ClassQuizBankGroup({
    required this.id,
    required this.order,
    required this.titles,
  });

  final String id;
  final int order;
  final Map<String, String> titles;

  String title(String lang) => titles[lang] ?? titles['uz'] ?? id;
}

/// Mavzu metama’lumoti (guruh, tartib, uch tildagi nom, tarjima holati).
class ClassQuizBankTopicMeta {
  const ClassQuizBankTopicMeta({
    required this.id,
    required this.groupId,
    required this.number,
    required this.titles,
    required this.translationStatus,
    required this.questionCount,
  });

  final String id;
  final String groupId;
  final int number;
  final Map<String, String> titles;
  final Map<String, String> translationStatus;
  final int questionCount;

  String title(String lang) => titles[lang] ?? titles['uz'] ?? id;

  bool isMachineTranslation(String lang) =>
      translationStatus[lang] == 'auto_unreviewed';

  /// Faqat o‘zbekcha yozuv: boshqa tilda asl matn + «tarjima kutilmoqda».
  bool isTranslationPending(String lang) =>
      lang != 'uz' && translationStatus[lang] == 'pending';
}

class ClassQuizBank {
  const ClassQuizBank({
    this.groups = const [],
    this.topics = const [],
    this.variants = const [],
    this.index = const {},
  });

  static const empty = ClassQuizBank();

  final List<ClassQuizBankGroup> groups;
  final List<ClassQuizBankTopicMeta> topics;

  /// Xizmat (fake backend / server seed) uchun til variantlari.
  final List<ClassBankTopic> variants;

  /// YAGONA savollar indeksi (id → savol): ustoz sahifasi, «Talaba
  /// ko‘rinishida sinash», talaba testi, katta ekran va natijalar savolni
  /// shu yerdan id bo‘yicha topadi. Bankdagi HAMMA savol kiradi — jumladan
  /// mashq ro‘yxatiga kiritilmaganlari (masalan beti ko‘rsatilmagan, slayd
  /// matnidan tuzilgan savollar). LabGuide’da shular indeksga tushmay,
  /// iPhone’da «savol to‘plamda yo‘q» xatosi chiqqan.
  final Map<String, ClassBankQuestion> index;

  /// Id bo‘yicha savol (yo‘q — `null`).
  ClassBankQuestion? question(String id) => index[id];

  /// `4-kurs-davolash-10~ru` → `4-kurs-davolash-10`.
  static String baseId(String topicId) => topicId.split('~').first;

  /// Variant tili: `~ru` → `ru`; qo‘shimchasiz — `uz` (asl til).
  static String variantLang(String topicId) {
    final i = topicId.indexOf('~');
    return i < 0 ? 'uz' : topicId.substring(i + 1);
  }

  static String variantId(String baseId, String lang) =>
      lang == 'uz' ? baseId : '$baseId~$lang';

  ClassQuizBankTopicMeta? meta(String topicId) {
    final b = baseId(topicId);
    for (final t in topics) {
      if (t.id == b) return t;
    }
    return null;
  }

  ClassQuizBankGroup? group(String id) {
    for (final g in groups) {
      if (g.id == id) return g;
    }
    return null;
  }

  /// JSON’ni o‘qiydi. Shakli noto‘g‘ri savol o‘tkaziladi (to‘qilmaydi,
  /// to‘ldirilmaydi); manbasi yoki beti yo‘q savol bankka kirmaydi.
  static ClassQuizBank parse(String text) {
    final root = jsonDecode(text);
    if (root is! Map) return empty;
    Map<String, String> strMap(Object? v) => {
      if (v is Map)
        for (final e in v.entries)
          if (e.value is String) '${e.key}': e.value as String,
    };
    final groups = <ClassQuizBankGroup>[
      for (final g in (root['groups'] as List? ?? const []))
        if (g is Map && g['id'] is String)
          ClassQuizBankGroup(
            id: g['id'] as String,
            order: (g['order'] as num?)?.toInt() ?? 0,
            titles: strMap(g['title_i18n']),
          ),
    ]..sort((a, b) => a.order.compareTo(b.order));
    final metas = <ClassQuizBankTopicMeta>[];
    final variants = <ClassBankTopic>[];
    final index = <String, ClassBankQuestion>{};
    for (final t in (root['topics'] as List? ?? const [])) {
      if (t is! Map || t['id'] is! String) continue;
      final id = t['id'] as String;
      final titles = strMap(t['title_i18n']);
      final status = strMap(t['translation_status']);
      final byLang = {
        for (final l in classQuizBankLangs) l: <ClassBankQuestion>[],
      };
      for (final q in (t['questions'] as List? ?? const [])) {
        if (q is! Map) continue;
        final qi = strMap(q['question_i18n']);
        final ex = strMap(q['explanation_i18n']);
        final opts = q['options_i18n'];
        final src = q['source'];
        final qs = strMap(q['translation_status']);
        if (src is! Map || opts is! Map) continue;
        for (final l in classQuizBankLangs) {
          final o = opts[l];
          final parsed = ClassBankQuestion.tryParse({
            if (q['id'] is String) 'id': variantId(q['id'] as String, l),
            'question': qi[l],
            'options': o,
            'correct_index': q['correct_index'],
            'explanation': ex[l] ?? '',
            'source': {
              'author': src['author'],
              'title': src['title'],
              'page': src['page'],
              if (src['checked'] is Map) 'checked': src['checked'],
              if ((qs[l] ?? status[l]) case final st?
                  when st == 'auto_unreviewed' ||
                      (st == 'pending' && l != 'uz'))
                'translation': st,
            },
          });
          if (parsed == null) continue;
          // Indeksga hammasi; mashq ro‘yxatiga — faqat beti ko‘rsatilgani.
          if (parsed.id.isNotEmpty) index[parsed.id] = parsed;
          if (parsed.source.cleanPage == null) continue;
          byLang[l]!.add(parsed);
        }
      }
      final uzCount = byLang['uz']!.length;
      if (uzCount == 0) continue;
      metas.add(
        ClassQuizBankTopicMeta(
          id: id,
          groupId: t['group'] is String ? t['group'] as String : '',
          number: (t['number'] as num?)?.toInt() ?? 0,
          titles: titles,
          translationStatus: status,
          questionCount: uzCount,
        ),
      );
      for (final l in classQuizBankLangs) {
        final list = byLang[l]!;
        if (list.isEmpty) continue;
        variants.add(
          ClassBankTopic(
            id: variantId(id, l),
            title: titles[l] ?? titles['uz'] ?? id,
            questions: list,
          ),
        );
      }
    }
    return ClassQuizBank(
      groups: groups,
      topics: metas,
      variants: variants,
      index: index,
    );
  }
}

/// Fake (qurilmadagi) sinf serveri mavzulari: bank variantlari; DEMO
/// to‘plam faqat [includeDemo] bo‘lsa (debug/test — release’da emas).
List<ClassBankTopic> classQuizLocalTopics(
  ClassQuizBank bank, {
  required bool includeDemo,
}) => [if (includeDemo) classQuizDemoTopic, ...bank.variants];
