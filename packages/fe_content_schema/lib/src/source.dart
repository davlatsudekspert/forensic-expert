import 'package:meta/meta.dart';

import 'enums.dart';

/// Manba turi.
enum SourceType {
  journalArticle,
  book,
  bookChapter,
  guideline,
  standard,
  database,
  legislation,
  report,
  website,
}

/// Manba ierarxiyasi (PHASE 4). Blog, AI matni yoki tasodifiy veb-sahifa
/// [other] — hech qachon ilmiy dalil sifatida qabul qilinmaydi (FE017).
enum SourceClass {
  /// Rasmiy birlamchi manba: qonun, rasmiy ro‘yxat, davlat/xalqaro organ.
  primaryOfficial,

  /// Peer-reviewed ilmiy nashr.
  peerReviewed,

  /// Standart yoki rasmiy qo‘llanma (ASB, OSAC, ISO, WHO guideline…).
  standardGuideline,

  /// Kitob / qo‘llanma (handbook).
  bookHandbook,

  /// Ikkilamchi: ma’lumotlar bazasi yig‘masi, sharh sayt.
  secondary,

  /// Boshqa (blog, forum, AI matni) — dalil emas.
  other;

  /// [SourceType] dan standart sinf.
  static SourceClass fromType(SourceType t) => switch (t) {
    SourceType.journalArticle => peerReviewed,
    SourceType.legislation => primaryOfficial,
    SourceType.guideline || SourceType.standard => standardGuideline,
    SourceType.book || SourceType.bookChapter => bookHandbook,
    SourceType.database || SourceType.report => secondary,
    SourceType.website => other,
  };

  /// Ilmiy claim’ni yolg‘iz asoslay oladimi.
  bool get canBackClaim => this != other;
}

/// Bibliografik manba (6.2-bo‘lim).
@immutable
class Source {
  const Source({
    required this.sourceId,
    required this.sourceType,
    required this.title,
    required this.tier,
    required this.evidenceLevel,
    required this.licenseMode,
    this.authors = const [],
    this.organization,
    this.journal,
    this.publicationYear,
    this.edition,
    this.doi,
    this.pmid,
    this.officialUrl,
    this.accessedDate,
    this.identifierVerified = false,
    this.licenseAgreementId,
    this.isTestData = false,
    this.version = 1,
    this._sourceClass,
  });

  final SourceClass? _sourceClass;

  /// Aniq berilmagan bo‘lsa — [SourceType] dan.
  SourceClass get sourceClass =>
      _sourceClass ?? SourceClass.fromType(sourceType);

  final String sourceId;
  final SourceType sourceType;
  final String title;
  final List<String> authors;
  final String? organization;
  final String? journal;
  final int? publicationYear;
  final String? edition;
  final String? doi;
  final String? pmid;
  final String? officialUrl;
  final DateTime? accessedDate;
  final SourceTier tier;
  final EvidenceLevel evidenceLevel;
  final SourceLicenseMode licenseMode;

  /// DOI/PMID Crossref yoki PubMed API orqali avtomatik tekshirilganmi.
  /// To‘qilgan identifikatorning bazaga tushishiga qarshi texnik himoya.
  final bool identifierVerified;

  /// Litsenziya shartnomasi ID’si (LICENSE REQUIRED manbalar uchun).
  final String? licenseAgreementId;

  /// TEST DATA — production paketga hech qachon tushmaydi.
  final bool isTestData;
  final int version;

  bool get hasPersistentIdentifier => doi != null || pmid != null;

  /// Strukturaviy qiymat uchun asos bo‘la oladimi.
  bool get canBackStructuredValue =>
      licenseMode.allowsStructuredReuse || licenseAgreementId != null;
}
