import 'package:meta/meta.dart';

import 'enums.dart';
import 'review.dart';
import 'source.dart';
import 'taxonomy.dart';

/// PHASE 7: tasdiqlanadigan ilmiy kontent pipeline’i.
///
/// Bu faylda faqat **qoidalar va modellar**: manba hayot sikli, claim hayot
/// sikli, dalil ziddiyatlari, review harakatlari va rollari, metabolit
/// munosabatlari, namunalar, standartlar katalogi va termin tarjimalari.
/// Hech bir model statusni VERIFIED ga o‘zi o‘tkaza olmaydi: VERIFIED faqat
/// [StatusResolver] orqali, haqiqiy reviewer yozuvlaridan hisoblanadi.

// ---------------------------------------------------------------------------
// Manba ierarxiyasi va hayot sikli
// ---------------------------------------------------------------------------

/// Manba ierarxiyasi (PHASE 7, 3-bo‘lim).
///
/// * **A** — rasmiy birlamchi manba (qonun, rasmiy ro‘yxat), xalqaro
///   standart yoki rasmiy qo‘llanma.
/// * **B** — peer-reviewed ilmiy nashr.
/// * **C** — kitob/qo‘llanma, ma’lumotlar bazasi yig‘masi, ikkilamchi manba.
///
/// Blog, forum, AI matni — ierarxiyada yo‘q (dalil emas, FE017).
enum SourceHierarchy {
  a('A'),
  b('B'),
  c('C');

  const SourceHierarchy(this.code);

  final String code;

  static SourceHierarchy? of(SourceClass cls) => switch (cls) {
    SourceClass.primaryOfficial || SourceClass.standardGuideline => a,
    SourceClass.peerReviewed => b,
    SourceClass.bookHandbook || SourceClass.secondary => c,
    SourceClass.other => null,
  };
}

/// Qayta foydalanish holati — ilovada ko‘rsatiladigan yorliq.
enum ReuseStatus {
  openReuse('OPEN_REUSE'),
  citeOnly('CITE_ONLY'),
  nonCommercial('NON_COMMERCIAL'),
  licenseRequired('LICENSE_REQUIRED'),
  lookupOnly('LOOKUP_ONLY'),
  unknown('UNKNOWN');

  const ReuseStatus(this.code);

  final String code;

  static ReuseStatus of(SourceLicenseMode m) => switch (m) {
    SourceLicenseMode.openReuse => openReuse,
    SourceLicenseMode.citeOnly => citeOnly,
    SourceLicenseMode.nonCommercial => nonCommercial,
    SourceLicenseMode.licenseRequired => licenseRequired,
    SourceLicenseMode.lookupOnly => lookupOnly,
    SourceLicenseMode.unknown => unknown,
  };

  static ReuseStatus fromCode(String c) => values.firstWhere(
    (v) => v.code == c,
    orElse: () => throw FormatException('unknown reuse status "$c"'),
  );

  /// Asl matndan iqtibos (excerpt) ilovaga kira oladimi.
  bool get allowsExcerpt => this == openReuse;
}

/// Manbaning nashr holati.
enum SourceLifecycle {
  current('current'),
  superseded('superseded'),
  retracted('retracted'),
  withdrawn('withdrawn');

  const SourceLifecycle(this.code);

  final String code;

  static SourceLifecycle fromCode(String c) => values.firstWhere(
    (v) => v.code == c,
    orElse: () => throw FormatException('unknown source lifecycle "$c"'),
  );
}

/// Manbaning PHASE 7 provenance metama’lumoti ([Source] ga qo‘shimcha).
@immutable
class SourceProvenance {
  const SourceProvenance({
    required this.sourceId,
    this.language,
    this.sha256,
    this.sourceVersion,
    this.lifecycle = SourceLifecycle.current,
    this.supersededBy,
    this.lifecycleCheckedAt,
    this.lifecycleBasis,
    this.forensicRelevance = ForensicRelevance.unassessed,
  });

  final String sourceId;

  /// Nashr tili (ISO 639-1).
  final String? language;

  /// Arxivlangan nusxa (PDF/HTML/XML) SHA-256 — faqat haqiqatan yuklangan
  /// fayl uchun.
  final String? sha256;

  /// Nashr versiyasi/tahriri (masalan `R2`, `65th edition`, eCFR sanasi).
  final String? sourceVersion;
  final SourceLifecycle lifecycle;

  /// [SourceLifecycle.superseded] bo‘lsa — yangi manba ID’si.
  final String? supersededBy;

  /// Retraksiya/yangilanish oxirgi marta qachon tekshirilgan.
  final DateTime? lifecycleCheckedAt;

  /// Holat qanday aniqlangan (masalan, PubMed `Retracted Publication[pt]`).
  final String? lifecycleBasis;
  final ForensicRelevance forensicRelevance;
}

// ---------------------------------------------------------------------------
// Claim hayot sikli
// ---------------------------------------------------------------------------

/// Claim hayot sikli (PHASE 7, 20-bo‘lim). **Hisoblanadi**, qo‘lda
/// belgilanmaydi: review statusi, manba holati va reviewer belgilaridan.
enum ClaimLifecycle {
  current('CURRENT'),
  needsReview('NEEDS_REVIEW'),
  outdated('OUTDATED'),
  superseded('SUPERSEDED'),
  retracted('RETRACTED'),
  rejected('REJECTED');

  const ClaimLifecycle(this.code);

  final String code;

  static ClaimLifecycle fromCode(String c) => values.firstWhere(
    (v) => v.code == c,
    orElse: () => throw FormatException('unknown claim lifecycle "$c"'),
  );

  /// Ilovada joriy fakt sifatida (ogohlantirishsiz) ko‘rsatish mumkinmi.
  bool get isCurrent => this == current;
}

@immutable
class LifecycleVerdict {
  const LifecycleVerdict(
    this.lifecycle,
    this.reason, {
    this.sourceIds = const [],
  });

  final ClaimLifecycle lifecycle;

  /// Mashina o‘qiy oladigan sabab (`source_retracted`, `status_rejected`…).
  final String reason;

  /// Holatga sabab bo‘lgan manbalar.
  final List<String> sourceIds;
}

/// Claim hayot siklini deterministik hisoblaydi.
///
/// Ustuvorlik: REJECTED > RETRACTED > SUPERSEDED > OUTDATED > CURRENT >
/// NEEDS_REVIEW. Eski fakt jimgina «joriy» bo‘lib qolmaydi: bitta manba
/// retraksiya qilinsa — claim RETRACTED; barcha manbalari almashtirilgan
/// bo‘lsa — SUPERSEDED.
abstract final class ClaimLifecycleResolver {
  static LifecycleVerdict resolve({
    required ScientificStatus status,
    required List<SourceProvenance> sources,
    bool flaggedOutdated = false,
  }) {
    if (status == ScientificStatus.rejected) {
      return const LifecycleVerdict(ClaimLifecycle.rejected, 'status_rejected');
    }
    final retracted = [
      for (final s in sources)
        if (s.lifecycle == SourceLifecycle.retracted ||
            s.lifecycle == SourceLifecycle.withdrawn)
          s.sourceId,
    ];
    if (retracted.isNotEmpty) {
      return LifecycleVerdict(
        ClaimLifecycle.retracted,
        'source_retracted',
        sourceIds: retracted,
      );
    }
    if (sources.isNotEmpty &&
        sources.every((s) => s.lifecycle == SourceLifecycle.superseded)) {
      return LifecycleVerdict(
        ClaimLifecycle.superseded,
        'all_sources_superseded',
        sourceIds: [for (final s in sources) s.sourceId],
      );
    }
    if (status == ScientificStatus.outdated || flaggedOutdated) {
      return const LifecycleVerdict(
        ClaimLifecycle.outdated,
        'flagged_outdated',
      );
    }
    if (status.isPublishable) {
      return const LifecycleVerdict(ClaimLifecycle.current, 'reviewed');
    }
    return const LifecycleVerdict(ClaimLifecycle.needsReview, 'not_reviewed');
  }

  /// Manba holati o‘zgarganda ta’sirlangan claim’lar (bog‘liqlik tahlili).
  static List<String> dependentClaims(
    String sourceId,
    Iterable<({String claimId, String sourceId})> citations,
  ) => [
    for (final c in citations)
      if (c.sourceId == sourceId) c.claimId,
  ]..sort();
}

// ---------------------------------------------------------------------------
// Dalil ziddiyatlari
// ---------------------------------------------------------------------------

/// Ziddiyat turi. Har biri ochiq ko‘rsatiladi — tanlov reviewer’niki.
enum ConflictKind {
  /// Ikki manba bir savolga qarama-qarshi javob beradi.
  directContradiction('direct_contradiction'),

  /// Manbalar turli sharoitda turlicha xulosa beradi (harorat, populyatsiya…).
  contextDependent('context_dependent'),

  /// Turli kontekstdagi qiymatlar bir-birini qoplaydi (masalan, o‘lim va
  /// tirik bemorlar konsentratsiyasi) — yolg‘iz qiymat talqin qilinmaydi.
  valueOverlap('value_overlap'),

  /// Manbalar bir xil narsani turlicha tavsiflaydi (masalan, metabolitni biri
  /// «faol», ikkinchisi rolsiz «metabolit» deydi) — to‘g‘ridan-to‘g‘ri
  /// inkor emas.
  inconsistentCharacterisation('inconsistent_characterisation');

  const ConflictKind(this.code);

  final String code;

  static ConflictKind fromCode(String c) => values.firstWhere(
    (v) => v.code == c,
    orElse: () => throw FormatException('unknown conflict kind "$c"'),
  );

  /// Kamida nechta claim kerak.
  int get minClaims => this == valueOverlap ? 1 : 2;
}

enum EvidenceConflictState {
  open('open'),
  resolvedByReviewer('resolved_by_reviewer');

  const EvidenceConflictState(this.code);

  final String code;

  static EvidenceConflictState fromCode(String c) => values.firstWhere(
    (v) => v.code == c,
    orElse: () => throw FormatException('unknown conflict state "$c"'),
  );
}

/// «EVIDENCE CONFLICT» yozuvi. Pipeline ziddiyatni yashirmaydi va
/// o‘zi hal qilmaydi: holat faqat reviewer qarori bilan o‘zgaradi.
@immutable
class EvidenceConflict {
  const EvidenceConflict({
    required this.id,
    required this.entityId,
    required this.question,
    required this.kind,
    required this.claimIds,
    required this.note,
    this.state = EvidenceConflictState.open,
    this.detectedAt,
  });

  final String id;
  final String entityId;

  /// Qaysi savolga tegishli (masalan, «vitreous K⁺ PMI uchun»).
  final String question;
  final ConflictKind kind;
  final List<String> claimIds;

  /// Neytral tavsif — faqat iqtiboslarda aytilgan narsa.
  final String note;
  final EvidenceConflictState state;
  final DateTime? detectedAt;
}

// ---------------------------------------------------------------------------
// Reviewer rollari va harakatlari
// ---------------------------------------------------------------------------

/// Reviewer roli (PHASE 7, 18-bo‘lim) va uning ixtisoslik doirasi.
enum ReviewerRole {
  forensicToxicology('forensic_toxicology', {ContentDomain.tox}),
  forensicMedicine('forensic_medicine', {ContentDomain.fm}),
  laboratoryAnalytical('laboratory_analytical', {ContentDomain.lab}),
  forensicBiochemistry('forensic_biochemistry', {
    ContentDomain.fm,
    ContentDomain.lab,
  }),
  legalJurisdiction('legal_jurisdiction', {ContentDomain.legal}),
  translation('translation', {ContentDomain.i18n}),

  /// Ilmiy muharrir / admin: navbatni boshqaradi, ziddiyat va eskirganlikni
  /// belgilaydi, o‘zgartirish so‘raydi — lekin ilmiy, huquqiy yoki tarjima
  /// mazmunini **tasdiqlay olmaydi**.
  scientificEditor('scientific_editor', {});

  const ReviewerRole(this.code, this.approvableDomains);

  final String code;

  /// Shu rol APPROVE/REJECT qila oladigan domenlar.
  final Set<ContentDomain> approvableDomains;

  static ReviewerRole fromCode(String c) => values.firstWhere(
    (v) => v.code == c,
    orElse: () => throw FormatException('unknown reviewer role "$c"'),
  );
}

enum ReviewActionType {
  approve('APPROVE'),
  reject('REJECT'),
  requestChange('REQUEST_CHANGE'),
  flagConflict('FLAG_CONFLICT'),
  flagOutdated('FLAG_OUTDATED');

  const ReviewActionType(this.code);

  final String code;

  static ReviewActionType fromCode(String c) => values.firstWhere(
    (v) => v.code == c,
    orElse: () => throw FormatException('unknown review action "$c"'),
  );

  /// Ilmiy qaror (faqat ixtisoslik egasi).
  bool get isDecision => this == approve || this == reject;
}

/// Ruxsat matritsasi: qaysi rol qaysi domenda qaysi harakatni qila oladi.
abstract final class ReviewPermissions {
  static bool allows(
    ReviewerRole role,
    ContentDomain domain,
    ReviewActionType action,
  ) {
    if (action.isDecision) return role.approvableDomains.contains(domain);
    // Belgilar: muharrir har qanday domenda; mutaxassis — o‘z domenida.
    if (role == ReviewerRole.scientificEditor) return true;
    return role.approvableDomains.contains(domain);
  }

  /// Izoh majburiy harakatlar.
  static bool requiresNote(ReviewActionType a) => a != ReviewActionType.approve;
}

/// Bitta reviewer harakati — muayyan obyekt **versiyasiga** bog‘langan.
@immutable
class ReviewAction {
  const ReviewAction({
    required this.id,
    required this.subjectId,
    required this.subjectVersion,
    required this.contentVersion,
    required this.domain,
    required this.reviewerId,
    required this.role,
    required this.action,
    required this.at,
    this.note = '',
  });

  final String id;
  final String subjectId;
  final int subjectVersion;

  /// Qaysi kontent paketi versiyasida ko‘rilgan (`2026.10.5`).
  final String contentVersion;
  final ContentDomain domain;
  final String reviewerId;
  final ReviewerRole role;
  final ReviewActionType action;
  final DateTime at;
  final String note;
}

/// Review navbatidagi obyekt holati (UI va CMS uchun).
enum ReviewWorkflowState {
  awaitingReview,
  changesRequested,
  conflictFlagged,
  outdatedFlagged,
  partiallyApproved,
  approved,
  rejected,
}

@immutable
class ActionCheck {
  const ActionCheck(this.ok, this.reason);

  final bool ok;
  final String reason;
}

/// Reviewer workflow davlat mashinasi.
///
/// Qoidalar:
/// * Rol domenga ega bo‘lmasa — rad (tarjimon ilmiy claim’ni tasdiqlay
///   olmaydi; muharrir hech narsani tasdiqlay olmaydi).
/// * Eski versiyaga harakat — rad (claim o‘zgargan).
/// * Muallif o‘z claim’ini tasdiqlay olmaydi.
/// * REJECT / REQUEST CHANGE / FLAG — izohsiz qabul qilinmaydi.
/// * Reviewer ro‘yxatda bo‘lishi va faol bo‘lishi shart — soxta reviewer yo‘q.
abstract final class ReviewWorkflow {
  static ActionCheck check({
    required ReviewAction action,
    required int currentVersion,
    required ContentDomain subjectDomain,
    required Map<String, Reviewer> reviewers,
    String? authorId,
  }) {
    final r = reviewers[action.reviewerId];
    if (r == null || !r.active) {
      return const ActionCheck(false, 'unknown_or_inactive_reviewer');
    }
    if (action.domain != subjectDomain) {
      return const ActionCheck(false, 'domain_mismatch');
    }
    if (!ReviewPermissions.allows(action.role, subjectDomain, action.action)) {
      return const ActionCheck(false, 'role_not_permitted');
    }
    if (action.action.isDecision && r.grantFor(subjectDomain) == null) {
      return const ActionCheck(false, 'reviewer_has_no_domain_grant');
    }
    if (action.subjectVersion != currentVersion) {
      return const ActionCheck(false, 'stale_version');
    }
    if (authorId != null &&
        authorId == action.reviewerId &&
        action.action.isDecision) {
      return const ActionCheck(false, 'author_cannot_review_own_claim');
    }
    if (ReviewPermissions.requiresNote(action.action) &&
        action.note.trim().isEmpty) {
      return const ActionCheck(false, 'note_required');
    }
    return const ActionCheck(true, 'ok');
  }

  /// Joriy versiyadagi haqiqiy harakatlardan holat.
  static ReviewWorkflowState state(Iterable<ReviewAction> validActions) {
    final list = validActions.toList()..sort((a, b) => a.at.compareTo(b.at));
    if (list.any((a) => a.action == ReviewActionType.reject)) {
      return ReviewWorkflowState.rejected;
    }
    if (list.isEmpty) return ReviewWorkflowState.awaitingReview;
    final last = list.last.action;
    if (last == ReviewActionType.requestChange) {
      return ReviewWorkflowState.changesRequested;
    }
    if (list.any((a) => a.action == ReviewActionType.flagConflict)) {
      return ReviewWorkflowState.conflictFlagged;
    }
    if (list.any((a) => a.action == ReviewActionType.flagOutdated)) {
      return ReviewWorkflowState.outdatedFlagged;
    }
    final approvers = {
      for (final a in list)
        if (a.action == ReviewActionType.approve) a.reviewerId,
    };
    if (approvers.length >= 2) return ReviewWorkflowState.approved;
    if (approvers.length == 1) return ReviewWorkflowState.partiallyApproved;
    return ReviewWorkflowState.awaitingReview;
  }

  /// Tasdiqlash/rad harakatlarini [StatusResolver] uchun [Review] ga
  /// aylantiradi. Status baribir faqat resolver orqali hisoblanadi.
  static List<Review> toReviews(Iterable<ReviewAction> validActions) => [
    for (final a in validActions)
      if (a.action.isDecision)
        Review(
          reviewId: a.id,
          claimId: a.subjectId,
          claimVersion: a.subjectVersion,
          reviewerId: a.reviewerId,
          domain: a.domain,
          decision: a.action == ReviewActionType.approve
              ? ReviewDecision.approve
              : ReviewDecision.reject,
          createdAt: a.at,
        ),
  ];
}

// ---------------------------------------------------------------------------
// Metabolitlar, namunalar, standartlar, terminlar
// ---------------------------------------------------------------------------

/// Ota modda → metabolit munosabati turi. Faqat manba aytgan tur:
/// faollik yoki marker roli iqtibosda bo‘lmasa — [metabolite] (rol
/// ko‘rsatilmagan).
enum MetaboliteRelationKind {
  metabolite('metabolite'),
  activeMetabolite('active_metabolite'),
  inactiveMetabolite('inactive_metabolite'),
  marker('marker'),
  artifact('artifact');

  const MetaboliteRelationKind(this.code);

  final String code;

  static MetaboliteRelationKind fromCode(String c) => values.firstWhere(
    (v) => v.code == c,
    orElse: () => throw FormatException('unknown metabolite relation "$c"'),
  );
}

@immutable
class MetaboliteRelation {
  const MetaboliteRelation({
    required this.id,
    required this.parentId,
    required this.metaboliteName,
    required this.kind,
    required this.basisClaimId,
    this.metaboliteId,
    this.specimens = const [],
  });

  final String id;
  final String parentId;

  /// Kutubxonada alohida yozuv bo‘lsa — uning ID’si.
  final String? metaboliteId;
  final String metaboliteName;
  final MetaboliteRelationKind kind;

  /// Manbada tilga olingan namunalar (bo‘lmasa — bo‘sh).
  final List<String> specimens;
  final String basisClaimId;
}

/// Namuna turi (PHASE 7, 8-bo‘lim).
@immutable
class SpecimenRecord {
  const SpecimenRecord({
    required this.id,
    required this.names,
    required this.category,
    this.aliases = const [],
  });

  /// `blood`, `serum-plasma`, `urine`, `vitreous`, `oral-fluid`, `hair`,
  /// `gastric`, `liver`, `bile`.
  final String id;
  final Map<String, String> names;

  /// `fluid` | `tissue` | `keratinous` | `content`.
  final String category;

  /// Iqtiboslardagi variantlar (`vitreous humour`, `cardiac blood`…) —
  /// konsentratsiya claim’larini namunaga bog‘lash uchun.
  final List<String> aliases;
}

enum StandardStatus {
  current('current'),

  /// OSAC Proposed Standard / loyiha — hali SDO tomonidan nashr etilmagan.
  proposed('proposed'),
  superseded('superseded'),
  withdrawn('withdrawn'),
  unknown('unknown');

  const StandardStatus(this.code);

  final String code;

  static StandardStatus fromCode(String c) => values.firstWhere(
    (v) => v.code == c,
    orElse: () => throw FormatException('unknown standard status "$c"'),
  );
}

/// Standartlar katalogi yozuvi — **faqat metadata va havola**. Matn
/// ko‘chirilmaydi; himoyalangan standart LICENSE REQUIRED.
@immutable
class StandardRecord {
  const StandardRecord({
    required this.id,
    required this.designation,
    required this.title,
    required this.publisher,
    required this.documentKind,
    required this.status,
    required this.reuse,
    required this.verifiedFrom,
    required this.verifiedAt,
    this.year,
    this.edition,
    this.supersededBy,
    this.url,
    this.sha256,
    this.disciplines = const [],
    this.note,
  });

  final String id;
  final String designation;
  final String title;
  final String publisher;
  final DocumentKind documentKind;
  final StandardStatus status;
  final ReuseStatus reuse;

  /// Metadata qayerdan tekshirilgan (rasmiy registr sahifasi).
  final String verifiedFrom;
  final DateTime verifiedAt;
  final String? year;
  final String? edition;
  final String? supersededBy;
  final String? url;

  /// Faqat ochiq yuklangan rasmiy PDF uchun.
  final String? sha256;
  final List<ForensicDiscipline> disciplines;
  final String? note;
}

/// Termin turi: identifikator, formula va qisqartma tarjima qilinmaydi.
enum ScientificTermKind {
  term('term'),
  abbreviation('abbreviation'),
  identifier('identifier'),
  formula('formula');

  const ScientificTermKind(this.code);

  final String code;

  static ScientificTermKind fromCode(String c) => values.firstWhere(
    (v) => v.code == c,
    orElse: () => throw FormatException('unknown term kind "$c"'),
  );

  bool get translatable => this == term;
}

/// Ilmiy termin tarjimasi: asl termin → kanonik → lokal.
@immutable
class TermTranslation {
  const TermTranslation({
    required this.id,
    required this.kind,
    required this.original,
    required this.originalLang,
    required this.canonical,
    required this.localized,
    required this.status,
  });

  final String id;
  final ScientificTermKind kind;

  /// Manbadagi asl ko‘rinish.
  final String original;
  final String originalLang;

  /// Kanonik (ingliz) termin.
  final String canonical;
  final Map<String, String> localized;
  final Map<String, TranslationStatus> status;
}

/// Konsentratsiya claim’ining **qat’iy** konteksti (PHASE 7, 6-bo‘lim).
///
/// Har bir kalit majburiy. Iqtibosda aytilmagan bo‘lsa — [notStated]
/// (to‘qilmaydi).
abstract final class StrictConcentrationContext {
  static const key = 'context_strict';
  static const notStated = 'not_stated';

  static const requiredKeys = <String>[
    'specimen',
    'sampling', // postmortem | antemortem | mixed | not_stated
    'subject_state', // deceased | living | mixed | not_stated
    'population',
    'study_size',
    'case_type',
    'co_intoxicants',
    'analytical_method',
    'timing',
    'statistic',
    'reporting', // primary | secondary_citation | not_assessed
    'limitations',
  ];

  static const samplingValues = {
    'postmortem',
    'antemortem',
    'mixed',
    notStated,
  };
  static const subjectValues = {'deceased', 'living', 'mixed', notStated};

  /// `not_assessed` — pilotdan tashqari claim’lar: hali qo‘lda ko‘rilmagan.
  static const reportingValues = {
    'primary',
    'secondary_citation',
    'not_assessed',
  };
}
