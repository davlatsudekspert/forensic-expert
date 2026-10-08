/// Yopiq «amaliyot kodlari» katalogi — cheklangan manba (masalan,
/// nashr etilmagan idoraviy yo‘riqnoma) bo‘limlarining **faqat
/// metadata’si**: kod, sarlavha, sahifa, fanlar, teglar va holatlar.
///
/// Xavfsizlik qoidalari:
/// * Katalog ilova paketiga, repo’ga, CI artefaktiga yoki serverga
///   kirmaydi. Admin uni o‘z qurilmasida fayldan import qiladi va u
///   faqat ilovaning shaxsiy papkasida saqlanadi.
/// * Ekranda faqat `identity_admin` roliga ko‘rinadi.
/// * Asl kodlar o‘zgartirilmaydi: normallashtirilgan kod alohida maydon.
/// * Har bir yozuv ekspert ko‘rigigacha `NEEDS_REVIEW`; AI’ga berilmaydi.
library;

import 'package:flutter/foundation.dart';

import 'guideline_models.dart';

@immutable
class PracticeRecord {
  const PracticeRecord({
    required this.code,
    required this.codeOriginal,
    required this.section,
    required this.title,
    this.pageStart,
    this.pageEnd,
    this.pageNote,
    this.disciplines = const [],
    this.methodTags = const [],
    this.analytes = const [],
    this.relatedNormative = const [],
    this.independentCards = const [],
    this.titleTranslationStatus = GuidelineTranslationStatus.draft,
  });

  factory PracticeRecord.fromJson(Map<String, Object?> j) {
    List<String> list(String k) => [
      for (final v in (j[k] as List? ?? const [])) '$v',
    ];
    final title = <String, String>{
      if (j['title_uz'] is String) 'uz': j['title_uz']! as String,
      if (j['title_ru'] is String) 'ru': j['title_ru']! as String,
      if (j['title_en'] is String) 'en': j['title_en']! as String,
    };
    final code = '${j['code_normalized'] ?? j['code'] ?? ''}';
    return PracticeRecord(
      code: code,
      codeOriginal: '${j['code_original'] ?? j['code'] ?? code}',
      section: '${j['section'] ?? ''}',
      title: Tri(title),
      pageStart: (j['page_start'] as num?)?.toInt(),
      pageEnd: (j['page_end'] as num?)?.toInt(),
      pageNote: j['page_note'] as String?,
      disciplines: list('disciplines'),
      methodTags: list('method_tags'),
      analytes: list('analytes'),
      relatedNormative: list('related_normative'),
      independentCards: list('independent_cards'),
      titleTranslationStatus: GuidelineTranslationStatus.parse(
        j['title_translation_status'],
      ),
    );
  }

  final String code;
  final String codeOriginal;
  final String section;
  final Tri title;
  final int? pageStart;
  final int? pageEnd;
  final String? pageNote;
  final List<String> disciplines;
  final List<String> methodTags;
  final List<String> analytes;
  final List<String> relatedNormative;
  final List<String> independentCards;
  final GuidelineTranslationStatus titleTranslationStatus;

  bool get codeWasNormalized => codeOriginal != code;
}

@immutable
class PracticeSource {
  const PracticeSource({
    required this.sourceId,
    required this.title,
    this.organization,
    this.year,
    this.rightsStatus,
  });

  factory PracticeSource.fromJson(Map<String, Object?> j) => PracticeSource(
    sourceId: '${j['source_id'] ?? ''}',
    title: '${j['title_uz'] ?? j['title'] ?? ''}',
    organization: j['organization'] as String?,
    year: (j['year'] as num?)?.toInt(),
    rightsStatus: j['rights_status'] as String?,
  );

  final String sourceId;
  final String title;
  final String? organization;
  final int? year;
  final String? rightsStatus;
}

@immutable
class PracticeCatalog {
  const PracticeCatalog({
    required this.source,
    required this.records,
    this.normative = const [],
    this.tagTerms = const {},
  });

  /// `aby_catalog.json` kabi fayl. Noto‘g‘ri tuzilma — [FormatException].
  factory PracticeCatalog.fromJson(Map<String, Object?> j) {
    final src = j['source'];
    final recs = j['records'];
    if (src is! Map<String, Object?> || recs is! List || recs.isEmpty) {
      throw const FormatException('restricted catalog: source/records');
    }
    final tags = <String, List<String>>{};
    for (final key in ['tags', 'analytes']) {
      if (j[key] case final Map<Object?, Object?> m) {
        for (final e in m.entries) {
          tags['${e.key}'] = [
            '${e.key}'.replaceAll('_', ' '),
            for (final v in (e.value as List? ?? const [])) '$v',
          ];
        }
      }
    }
    return PracticeCatalog(
      source: PracticeSource.fromJson(src),
      records: [
        for (final r in recs)
          if (r is Map<String, Object?>) PracticeRecord.fromJson(r),
      ],
      normative: [
        for (final n in (j['normative'] as List? ?? const []))
          if (n is Map<String, Object?>) PracticeSource.fromJson(n),
      ],
      tagTerms: tags,
    );
  }

  final PracticeSource source;
  final List<PracticeRecord> records;
  final List<PracticeSource> normative;

  /// Teg → uz/ru/en sinonimlar (uch tilli qidiruv uchun).
  final Map<String, List<String>> tagTerms;

  List<String> searchTermsOf(PracticeRecord r) => [
    r.code,
    r.codeOriginal,
    ...r.title.all,
    for (final t in [...r.methodTags, ...r.analytes]) ...?tagTerms[t],
  ];

  List<String> get sections {
    final s = <String>{for (final r in records) r.section}.toList()..sort();
    return s;
  }
}

/// Qurilmadagi saqlash (ilova shaxsiy papkasi). Testlarda xotiradagi
/// variant bilan almashtiriladi.
abstract interface class PracticeCatalogStore {
  Future<String?> read();
  Future<void> write(String json);
  Future<void> clear();
}

class MemoryPracticeCatalogStore implements PracticeCatalogStore {
  MemoryPracticeCatalogStore([this._value]);

  String? _value;

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String json) async => _value = json;

  @override
  Future<void> clear() async => _value = null;
}
