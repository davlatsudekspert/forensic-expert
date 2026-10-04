import 'package:meta/meta.dart';

import 'enums.dart';
import 'taxonomy.dart';

/// PHASE 5: Research / Evidence Library, bilim grafigi va ilmiy rasmlar.
///
/// Faqat **metadata**: to‘liq matn yoki annotatsiya ko‘chirilmaydi.
/// Dissertatsiya, tezis va konferensiya tezisi peer-reviewed to‘liq maqola
/// bilan bir xil dalil darajasida ko‘rsatilmaydi (FE028).

enum ResearchKind {
  journalArticle('journal_article'),
  review('review'),
  systematicReview('systematic_review'),
  metaAnalysis('meta_analysis'),
  caseReport('case_report'),
  conferenceAbstract('conference_abstract'),
  conferencePaper('conference_paper'),
  dissertation('dissertation'),
  thesis('thesis'),
  officialReport('official_report'),
  standard('standard'),
  guideline('guideline'),
  validationStudy('validation_study'),
  caseSeries('case_series');

  const ResearchKind(this.code);

  final String code;

  static ResearchKind fromCode(String c) => values.firstWhere(
    (k) => k.code == c,
    orElse: () => throw FormatException('unknown research kind "$c"'),
  );

  /// Peer-reviewed to‘liq nashr turimi.
  bool get isPeerReviewedFullArticle => switch (this) {
    journalArticle ||
    review ||
    systematicReview ||
    metaAnalysis ||
    caseReport ||
    validationStudy ||
    caseSeries => true,
    _ => false,
  };

  /// Tur uchun yuqori dalil darajasi (bundan kuchli belgilanmaydi).
  EvidenceLevel get maxEvidence => switch (this) {
    systematicReview ||
    metaAnalysis ||
    standard ||
    guideline => EvidenceLevel.a,
    journalArticle || officialReport || validationStudy => EvidenceLevel.b,
    review => EvidenceLevel.c,
    caseReport || caseSeries => EvidenceLevel.d,
    conferenceAbstract ||
    conferencePaper ||
    dissertation ||
    thesis => EvidenceLevel.e,
  };
}

@immutable
class ResearchRecord {
  const ResearchRecord({
    required this.id,
    required this.kind,
    required this.title,
    required this.evidenceLevel,
    required this.status,
    this.authors = const [],
    this.organization,
    this.container,
    this.year,
    this.doi,
    this.pmid,
    this.pmcid,
    this.handle,
    this.url,
    this.degree,
    this.openAccess,
    this.sourceApi,
    this.accessedDate,
    this.isTestData = false,
    this.forensicRelevance = ForensicRelevance.unassessed,
    this.language,
  });

  final String id;
  final ResearchKind kind;

  /// Dalil sifatidan alohida: reviewer baholamaguncha `unassessed`.
  final ForensicRelevance forensicRelevance;

  /// Nashr tili (ISO 639-1), ma’lum bo‘lsa.
  final String? language;
  final String title;
  final List<String> authors;

  /// Universitet / tashkilot (dissertatsiya, hisobot).
  final String? organization;

  /// Jurnal yoki konferensiya.
  final String? container;
  final String? year;
  final String? doi;
  final String? pmid;
  final String? pmcid;
  final String? handle;
  final String? url;
  final String? degree;
  final String? openAccess;
  final String? sourceApi;
  final DateTime? accessedDate;
  final EvidenceLevel evidenceLevel;
  final ScientificStatus status;
  final bool isTestData;

  /// Dublikat aniqlash kaliti: DOI → PMID → Handle → sarlavha + 1-muallif.
  String get dedupKey {
    if (doi != null && doi!.isNotEmpty) return 'doi:${doi!.toLowerCase()}';
    if (pmid != null && pmid!.isNotEmpty) return 'pmid:$pmid';
    if (handle != null && handle!.isNotEmpty) {
      return 'handle:${handle!.toLowerCase()}';
    }
    final first = authors.isEmpty
        ? ''
        : authors.first.toLowerCase().split(RegExp(r'[\s,]+')).first;
    return 'title:${normalizeTitle(title)}|$first';
  }

  bool get hasIdentifier =>
      [doi, pmid, handle, url].any((x) => x != null && x.isNotEmpty);
}

String normalizeTitle(String t) => t
    .toLowerCase()
    .replaceAll(RegExp(r'<[^>]+>|&[a-z]+;'), ' ')
    .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
    .trim();

/// Bilim grafigidagi bog‘lanish. Har bir bog‘lanish tekshiriladigan asosga
/// ega: manba (claim/research) yoki aniq tahririy qoida (`basis`).
enum LinkRelation {
  /// Modda ↔ metod: manbadagi jumlada ikkalasi tilga olingan.
  analysedBy('analysed_by'),

  /// Modda ↔ boshqa modda: metabolizm iqtibosida birga tilga olingan
  /// (reviewer munosabatni tasdiqlaydi).
  metabolismCoMention('metabolism_co_mention'),

  /// Skrining ↔ tasdiqlovchi metod.
  confirmedBy('confirmed_by'),

  /// Reagent ↔ metod / skrining.
  usedIn('used_in'),

  /// Yozuv ↔ tadqiqot.
  research('research'),

  /// Mavzu ↔ mavzu (sud tibbiyoti ↔ gistologiya / biokimyo).
  relatedTopic('related_topic'),

  // PHASE 7: provenance bilan bilim zanjirlari. Asos (basis) — claim, qoida
  // yoki standart ID’si; `editorial:` asosi bu munosabatlarda taqiqlangan.

  /// Ota modda → metabolit (MetaboliteRelation asosida).
  hasMetabolite('has_metabolite'),

  /// Modda/metabolit/mavzu → namuna: manbada shu namunada o‘lchangan.
  measuredIn('measured_in'),

  /// Modda → skrining testi (manbali claim).
  screenedBy('screened_by'),

  /// Standart → metod/kalkulyator (standart nomi va sohasi asosida).
  standardFor('standard_for'),

  /// Modda → yurisdiksion qoida (rasmiy ro‘yxat yozuvi).
  legalStatus('legal_status');

  const LinkRelation(this.code);

  final String code;

  /// Asosi tekshiriladigan (editorial bo‘lmagan) PHASE 7 munosabatlari.
  bool get requiresTraceableBasis => index >= hasMetabolite.index;

  static LinkRelation fromCode(String c) => values.firstWhere(
    (k) => k.code == c,
    orElse: () => throw FormatException('unknown link relation "$c"'),
  );
}

@immutable
class EntityLink {
  const EntityLink({
    required this.fromId,
    required this.toId,
    required this.relation,
    required this.basis,
  });

  final String fromId;
  final String toId;
  final LinkRelation relation;

  /// Asos: claim ID, research ID yoki `editorial:<qoida>`.
  final String basis;
}

/// Ilmiy rasm. Litsenziyasi noaniq rasm kiritilmaydi (FE031).
enum ImageKind {
  chemicalStructure('chemical_structure'),
  schematic('schematic'),
  chromatogram('chromatogram'),
  massSpectrum('mass_spectrum'),
  micrograph('micrograph'),
  tlcPlate('tlc_plate'),
  colourTest('colour_test'),
  photo('photo');

  const ImageKind(this.code);

  final String code;

  static ImageKind fromCode(String c) => values.firstWhere(
    (k) => k.code == c,
    orElse: () => throw FormatException('unknown image kind "$c"'),
  );
}

/// Ruxsat etilgan litsenziyalar (ilovaga asset sifatida).
const allowedImageLicenses = {
  'CC BY',
  'CC BY 4.0',
  'CC0',
  'public_domain',
  'original_work',
  'original_depiction_of_factual_data',
};

@immutable
class ScientificImage {
  const ScientificImage({
    required this.id,
    required this.kind,
    required this.entityId,
    required this.title,
    required this.alt,
    required this.license,
    required this.attribution,
    required this.isOriginalDiagram,
    required this.representsRealData,
    this.creator,
    this.sourceName,
    this.sourceUrl,
    this.doi,
    this.captionOriginal,
    this.graphic = false,
    this.accessedDate,
    this.sha256,
    this.file,
  });

  final String id;
  final ImageKind kind;
  final String entityId;
  final Map<String, String> title;

  /// Ekran o‘quvchisi uchun matn (majburiy).
  final Map<String, String> alt;
  final String license;
  final String attribution;

  /// Original sxema/depiksiya — real eksperimental natija EMAS.
  final bool isOriginalDiagram;

  /// Real eksperimental ma’lumotmi (xromatogramma, mikrofoto).
  final bool representsRealData;
  final String? creator;
  final String? sourceName;
  final String? sourceUrl;
  final String? doi;
  final String? captionOriginal;

  /// Graphic (tana, jarohat, autopsiya) — default UI’da taqiqlangan.
  final bool graphic;
  final DateTime? accessedDate;
  final String? sha256;

  /// Pipeline uchun: diskdagi fayl yo‘li.
  final String? file;
}
