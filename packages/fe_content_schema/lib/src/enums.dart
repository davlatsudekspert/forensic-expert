/// Ilmiy ishonchlilik statusi (`docs/00_ARXITEKTURA_REJASI.md`, 6.4).
///
/// Bu status hech qachon qo‘lda belgilanmaydi — [StatusResolver] uni
/// review yozuvlaridan hisoblaydi.
enum ScientificStatus {
  verified('VERIFIED'),
  reviewed('REVIEWED'),
  needsReview('NEEDS_REVIEW'),
  outdated('OUTDATED'),
  rejected('REJECTED');

  const ScientificStatus(this.code);

  final String code;

  static ScientificStatus fromCode(String code) => values.firstWhere(
    (s) => s.code == code,
    orElse: () => throw FormatException('Unknown status: $code'),
  );

  /// Production kontent paketiga tushishi mumkin bo‘lgan statuslar.
  bool get isPublishable => this == verified || this == reviewed;
}

/// CMS ish jarayoni statusi (ilmiy statusdan alohida).
enum WorkflowStatus {
  draft('DRAFT'),
  needsReview('NEEDS_REVIEW'),
  reviewed('REVIEWED'),
  published('PUBLISHED');

  const WorkflowStatus(this.code);

  final String code;
}

/// Tarjima statusi — ilmiy statusdan mustaqil.
enum TranslationStatus {
  machineDraft('machine_draft'),
  translated('translated'),
  reviewed('reviewed');

  const TranslationStatus(this.code);

  final String code;
}

/// Soddalashtirilgan dalil darajasi (6.5-bo‘lim).
enum EvidenceLevel {
  /// Xalqaro standart, rasmiy qo‘llanma, tizimli review.
  a('A'),

  /// Peer-reviewed birlamchi tadqiqot.
  b('B'),

  /// Darslik, monografiya, ekspert konsensusi.
  c('C'),

  /// Alohida case report.
  d('D'),

  /// Ichki ekspert fikri — manba bilan tasdiqlanmagan.
  e('E');

  const EvidenceLevel(this.code);

  final String code;
}

/// Manba darajasi (2-bo‘lim).
enum SourceTier { tier1, tier2, tier3 }

/// Manbadan foydalanish rejimi (`docs/03_SOURCE_MATRIX.md`, 0-bo‘lim).
enum SourceLicenseMode {
  /// Tijoriy qayta foydalanishga ruxsat (public domain, CC0, CC BY).
  openReuse,

  /// Faqat havola va mustaqil qisqa mazmun.
  citeOnly,

  /// CC BY-NC va shunga o‘xshash — tijoriy ilovaga ruxsatsiz kirmaydi.
  nonCommercial,

  /// Pullik / litsenziya kerak.
  licenseRequired,

  /// Faqat tashqi qidiruv, bazaga tushmaydi.
  lookupOnly,

  /// Hali aniqlanmagan — xavfsiz tomonga: strukturaviy qiymat uchun ishlatilmaydi.
  unknown;

  /// Bu manba **strukturaviy qiymat** (raqam, jadval qatori) uchun
  /// litsenziya shartnomasisiz asos bo‘la oladimi.
  bool get allowsStructuredReuse => this == openReuse;
}

/// Review domenlari (22-bo‘lim).
enum ContentDomain {
  tox('tox'),
  fm('fm'),
  lab('lab'),
  legal('legal'),
  edu('edu');

  const ContentDomain(this.code);

  final String code;
}

/// Kontent to‘plamining turi. Test ma’lumot production’ga o‘tmasligi
/// uchun har bir to‘plam o‘z turini e’lon qiladi.
enum BundleChannel { production, development, test }
