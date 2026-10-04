import 'package:meta/meta.dart';

import 'bundle.dart';
import 'claim.dart';
import 'concentration.dart';
import 'enums.dart';
import 'evidence_graph.dart';
import 'jurisdiction.dart';
import 'knowledge.dart';
import 'provenance.dart';
import 'source.dart';
import 'status_resolver.dart';

enum IssueSeverity { error, warning }

/// Validatsiya qoidalari kodlari. Kodlar barqaror — CI hisobotlari va
/// CMS shu kodlarga tayanadi.
abstract final class RuleCodes {
  static const testDataInProduction = 'FE001_TEST_DATA_IN_PRODUCTION';
  static const statusMismatch = 'FE002_DECLARED_STATUS_NOT_BACKED_BY_REVIEWS';
  static const missingCitation = 'FE003_CLAIM_WITHOUT_SOURCE';
  static const unknownSource = 'FE004_CITATION_TO_UNKNOWN_SOURCE';
  static const licenseViolation =
      'FE005_STRUCTURED_VALUE_FROM_RESTRICTED_SOURCE';
  static const concentrationContext = 'FE006_CONCENTRATION_CONTEXT_MISSING';
  static const forbiddenCategory = 'FE007_FORBIDDEN_CONCENTRATION_CATEGORY';
  static const unpublishableStatus = 'FE008_UNPUBLISHABLE_STATUS_IN_PRODUCTION';
  static const testDataIdPrefix = 'FE009_TEST_DATA_ID_PREFIX';
  static const preferenceWithoutReason = 'FE010_PREFERRED_WITHOUT_REASON';
  static const unresolvedConflict = 'FE011_UNRESOLVED_CONFLICT';

  // --- Global Scientific Core + Jurisdiction Layer ---
  static const jurisdictionalClaimUnanchored =
      'FE012_JURISDICTIONAL_CLAIM_WITHOUT_JURISDICTION_OR_INSTRUMENT';
  static const layerMixing = 'FE013_LAYER_MIXING';
  static const instrumentWithoutOfficialSource =
      'FE014_INSTRUMENT_WITHOUT_OFFICIAL_SOURCE';
  static const invalidEffectivePeriod = 'FE015_INVALID_EFFECTIVE_PERIOD';
  static const unknownJurisdictionReference =
      'FE016_UNKNOWN_JURISDICTION_REFERENCE';

  // --- PHASE 4: global bilim sohalari ---
  static const sourceNotEvidence = 'FE017_SOURCE_CLASS_NOT_EVIDENCE';
  static const recipeWithoutSource = 'FE018_RECIPE_WITHOUT_SOURCE';
  static const unsourcedStepOrder = 'FE019_UNSOURCED_STEP_ORDER';
  static const subjectStatusNotBacked = 'FE020_STATUS_NOT_BACKED_BY_REVIEWS';
  static const screeningWithoutConfirmation =
      'FE021_SCREENING_WITHOUT_CONFIRMATION_OR_LIMITATIONS';
  static const unsourcedValue = 'FE022_UNSOURCED_VALUE';
  static const definitiveIdWithoutAuthority =
      'FE023_DEFINITIVE_IDENTIFICATION_WITHOUT_AUTHORITY';
  static const methodKindMixing = 'FE024_METHOD_KIND_MIXING';
  static const textLicense = 'FE025_TEXT_NOT_PERMITTED_BY_LICENSE';
  static const emergingWithoutProvenance =
      'FE026_EMERGING_ISSUE_WITHOUT_SOURCE_OR_DATE';

  /// Ko‘rib chiqilgan ma’lumot yangi paketda jimgina yo‘qolgan, pasaygan
  /// yoki versiyasi oshirilmay o‘zgargan (ReviewRegressionGuard).
  static const silentReviewRegression = 'FE027_SILENT_REVIEW_REGRESSION';

  /// Research yozuvi: identifikatorsiz, yoki dissertatsiya/tezis/tezis
  /// peer-reviewed maqola darajasida ko‘rsatilgan.
  static const researchRecordInvalid = 'FE028_RESEARCH_RECORD_INVALID';
  static const researchDuplicate = 'FE029_RESEARCH_DUPLICATE';
  static const brokenLink = 'FE030_LINK_TO_UNKNOWN_ENTITY';
  static const imageLicense = 'FE031_IMAGE_LICENSE_OR_METADATA';

  /// Xabar qilingan konsentratsiya: namuna, kontekst va «chegara emas»
  /// belgisi majburiy.
  static const reportedConcentrationContext =
      'FE032_CONCENTRATION_WITHOUT_CONTEXT';

  // --- PHASE 7: tasdiqlanadigan kontent pipeline’i ---
  /// Konsentratsiya claim’ida qat’iy kontekst kalitlaridan biri yo‘q yoki
  /// noto‘g‘ri qiymat.
  static const strictConcentrationContext =
      'FE033_STRICT_CONCENTRATION_CONTEXT';

  /// Retraksiya/almashtirilgan manbaga tayangan claim joriy (publishable)
  /// deb e’lon qilingan yoki manba holati izchil emas.
  static const sourceLifecycle = 'FE034_SOURCE_LIFECYCLE';
  static const conflictInvalid = 'FE035_EVIDENCE_CONFLICT_INVALID';
  static const metaboliteRelationInvalid = 'FE036_METABOLITE_RELATION_INVALID';

  /// PHASE 7 graf qirrasi kuzatiladigan asossiz (claim/qoida/standart).
  static const untraceableEdge = 'FE037_GRAPH_EDGE_WITHOUT_PROVENANCE';
  static const standardInvalid = 'FE038_STANDARD_RECORD_INVALID';

  /// Reviewer harakati: ruxsat yo‘q, soxta reviewer, eski versiya, izohsiz.
  static const reviewActionInvalid = 'FE039_REVIEW_ACTION_INVALID';

  /// DOI/PMID/formula/qisqartma tarjima qilingan yoki tarjima holati yo‘q.
  static const termTranslationInvalid = 'FE040_TERM_TRANSLATION_INVALID';
  static const specimenInvalid = 'FE041_SPECIMEN_RECORD_INVALID';

  // --- PHASE 8 ---
  static const methodEvidenceType = 'FE042_METHOD_EVIDENCE_TYPE_UNSUPPORTED';
}

/// Test ma’lumot ID’lari shu prefiks bilan boshlanadi — ko‘zga tashlanishi
/// va production’ga adashib o‘tmasligi uchun.
const testDataIdPrefix = 'TEST-';

@immutable
class ValidationIssue {
  const ValidationIssue(this.code, this.severity, this.subjectId, this.message);

  final String code;
  final IssueSeverity severity;
  final String subjectId;
  final String message;

  @override
  String toString() => '[$code] $subjectId: $message';
}

@immutable
class ValidationReport {
  const ValidationReport(this.issues);

  final List<ValidationIssue> issues;

  bool get isValid => issues.every((i) => i.severity != IssueSeverity.error);

  Iterable<ValidationIssue> get errors =>
      issues.where((i) => i.severity == IssueSeverity.error);

  bool hasCode(String code) => issues.any((i) => i.code == code);
}

/// Content pipeline validatori (`docs/00_ARXITEKTURA_REJASI.md`, 22.4).
///
/// Validator xatoga yo‘l qo‘ymaydi: build to‘xtaydi. Statusni qo‘lda
/// «VERIFIED» deb yozib qo‘yishning iloji yo‘q — e’lon qilingan status
/// review yozuvlaridan hisoblangan statusga teng bo‘lishi shart.
class ContentValidator {
  const ContentValidator();

  ValidationReport validate(ContentBundle bundle) {
    final issues = <ValidationIssue>[];
    final sourcesById = {for (final s in bundle.sources) s.sourceId: s};
    final citationsByClaim = <String, List<String>>{};
    for (final c in bundle.citations) {
      citationsByClaim.putIfAbsent(c.claimId, () => []).add(c.sourceId);
    }
    final resolver = StatusResolver(
      reviewers: bundle.reviewers,
      reviews: bundle.reviews,
      authorships: bundle.authorships,
    );
    final isProduction = bundle.channel == BundleChannel.production;
    final jurisdictionIds = {for (final j in bundle.jurisdictions) j.id};
    final instrumentsById = {for (final i in bundle.instruments) i.id: i};

    for (final s in bundle.sources) {
      _checkTestData(issues, s.sourceId, s.isTestData, isProduction);
    }

    for (final claim in bundle.claims) {
      _checkTestData(issues, claim.claimId, claim.isTestData, isProduction);

      final sourceIds = citationsByClaim[claim.claimId] ?? const <String>[];
      if (sourceIds.isEmpty) {
        issues.add(
          ValidationIssue(
            RuleCodes.missingCitation,
            IssueSeverity.error,
            claim.claimId,
            'Claim has no citation.',
          ),
        );
      }
      final sources = <Source>[];
      for (final id in sourceIds) {
        final source = sourcesById[id];
        if (source == null) {
          issues.add(
            ValidationIssue(
              RuleCodes.unknownSource,
              IssueSeverity.error,
              claim.claimId,
              'Unknown source $id.',
            ),
          );
        } else {
          sources.add(source);
        }
      }

      if (sources.isNotEmpty &&
          sources.every((src) => !src.sourceClass.canBackClaim)) {
        issues.add(
          ValidationIssue(
            RuleCodes.sourceNotEvidence,
            IssueSeverity.error,
            claim.claimId,
            'Claim is backed only by non-evidence sources (blog/AI/web).',
          ),
        );
      }

      if (claim.isStructuredValue) {
        for (final s in sources) {
          if (!s.canBackStructuredValue) {
            issues.add(
              ValidationIssue(
                RuleCodes.licenseViolation,
                IssueSeverity.error,
                claim.claimId,
                'Source ${s.sourceId} (${s.licenseMode.name}) cannot back a '
                'structured value without a license agreement.',
              ),
            );
          }
        }
      }

      final computed = resolver.resolve(claim, sources);
      final draftOk =
          claim.declaredStatus == ScientificStatus.draft &&
          computed == ScientificStatus.needsReview;
      if (claim.declaredStatus != ScientificStatus.outdated &&
          !draftOk &&
          claim.declaredStatus != computed) {
        issues.add(
          ValidationIssue(
            RuleCodes.statusMismatch,
            IssueSeverity.error,
            claim.claimId,
            'Declared ${claim.declaredStatus.code} but reviews support '
            '${computed.code}.',
          ),
        );
      }

      if (isProduction && !claim.declaredStatus.isPublishable) {
        issues.add(
          ValidationIssue(
            RuleCodes.unpublishableStatus,
            IssueSeverity.error,
            claim.claimId,
            '${claim.declaredStatus.code} content cannot enter a production '
            'bundle.',
          ),
        );
      }

      if (claim.field == ConcentrationContract.field) {
        _checkConcentration(issues, claim);
      }

      _checkClaimLayer(issues, claim, jurisdictionIds, instrumentsById);

      if (claim.preferred &&
          (claim.preferenceReason == null || claim.preferenceReason!.isEmpty)) {
        issues.add(
          ValidationIssue(
            RuleCodes.preferenceWithoutReason,
            IssueSeverity.error,
            claim.claimId,
            'Preferred without reason.',
          ),
        );
      }
    }

    for (final g in bundle.groups) {
      if (g.conflictState == ConflictState.conflict &&
          (g.editorialNote == null || g.editorialNote!.isEmpty)) {
        issues.add(
          ValidationIssue(
            RuleCodes.unresolvedConflict,
            isProduction ? IssueSeverity.error : IssueSeverity.warning,
            g.groupId,
            'Conflicting group has no editorial note.',
          ),
        );
      }
    }

    _checkJurisdictionLayer(
      issues,
      bundle,
      sourcesById,
      jurisdictionIds,
      instrumentsById,
      isProduction,
    );
    _checkKnowledge(issues, bundle, sourcesById, resolver, isProduction);
    _checkEvidenceGraph(issues, bundle, isProduction);
    _checkProvenance(issues, bundle, citationsByClaim);

    return ValidationReport(List.unmodifiable(issues));
  }

  /// Qatlamlar aralashmasligi: ilmiy/standart claim davlatga bog‘lanmaydi,
  /// yurisdiksion claim esa yurisdiksiya va rasmiy hujjatga bog‘lanadi.
  void _checkClaimLayer(
    List<ValidationIssue> issues,
    Claim claim,
    Set<String> jurisdictionIds,
    Map<String, JurisdictionalInstrument> instrumentsById,
  ) {
    void add(String code, String message) => issues.add(
      ValidationIssue(code, IssueSeverity.error, claim.claimId, message),
    );

    if (claim.layer == KnowledgeLayer.jurisdictional) {
      if (claim.jurisdictionId == null || claim.instrumentId == null) {
        add(
          RuleCodes.jurisdictionalClaimUnanchored,
          'Jurisdictional claim needs jurisdictionId and instrumentId.',
        );
        return;
      }
      if (!jurisdictionIds.contains(claim.jurisdictionId)) {
        add(
          RuleCodes.unknownJurisdictionReference,
          'Unknown jurisdiction ${claim.jurisdictionId}.',
        );
      }
      final inst = instrumentsById[claim.instrumentId];
      if (inst == null) {
        add(
          RuleCodes.unknownJurisdictionReference,
          'Unknown instrument ${claim.instrumentId}.',
        );
      } else if (inst.jurisdictionId != claim.jurisdictionId) {
        add(
          RuleCodes.layerMixing,
          'Instrument ${inst.id} belongs to ${inst.jurisdictionId}, '
          'not ${claim.jurisdictionId}.',
        );
      }
      return;
    }

    if (claim.jurisdictionId != null || claim.instrumentId != null) {
      add(
        RuleCodes.layerMixing,
        '${claim.layer.code} claim must not reference a jurisdiction or '
        'legal instrument.',
      );
    }
    if (claim.layer == KnowledgeLayer.internationalScientific &&
        claim.domain == ContentDomain.legal) {
      add(
        RuleCodes.layerMixing,
        'Legal-domain content cannot live in the international scientific '
        'layer.',
      );
    }
  }

  void _checkJurisdictionLayer(
    List<ValidationIssue> issues,
    ContentBundle bundle,
    Map<String, Source> sourcesById,
    Set<String> jurisdictionIds,
    Map<String, JurisdictionalInstrument> instrumentsById,
    bool isProduction,
  ) {
    void add(String code, String id, String message) =>
        issues.add(ValidationIssue(code, IssueSeverity.error, id, message));

    final byId = {for (final j in bundle.jurisdictions) j.id: j};
    for (final j in bundle.jurisdictions) {
      if (j.parentId != null && !byId.containsKey(j.parentId)) {
        add(
          RuleCodes.unknownJurisdictionReference,
          j.id,
          'Unknown parent jurisdiction ${j.parentId}.',
        );
      }
      // Aylanma bog‘lanish (A → B → A).
      final seen = <String>{j.id};
      var parent = j.parentId;
      while (parent != null) {
        if (!seen.add(parent)) {
          add(
            RuleCodes.unknownJurisdictionReference,
            j.id,
            'Jurisdiction hierarchy contains a cycle.',
          );
          break;
        }
        parent = byId[parent]?.parentId;
      }
    }

    for (final inst in bundle.instruments) {
      _checkTestData(issues, inst.id, inst.isTestData, isProduction);
      if (!jurisdictionIds.contains(inst.jurisdictionId)) {
        add(
          RuleCodes.unknownJurisdictionReference,
          inst.id,
          'Unknown jurisdiction ${inst.jurisdictionId}.',
        );
      }
      if (inst.officialSourceId.isEmpty ||
          !sourcesById.containsKey(inst.officialSourceId)) {
        add(
          RuleCodes.instrumentWithoutOfficialSource,
          inst.id,
          'Instrument must cite an official source present in the bundle.',
        );
      }
      if (inst.version.isEmpty) {
        add(
          RuleCodes.instrumentWithoutOfficialSource,
          inst.id,
          'Instrument version is empty.',
        );
      }
      if (inst.effectiveTo != null &&
          !inst.effectiveTo!.isAfter(inst.effectiveFrom)) {
        add(
          RuleCodes.invalidEffectivePeriod,
          inst.id,
          'effectiveTo must be after effectiveFrom.',
        );
      }
      if (isProduction && !inst.status.isPublishable) {
        add(
          RuleCodes.unpublishableStatus,
          inst.id,
          '${inst.status.code} instrument cannot enter a production bundle.',
        );
      }
    }

    for (final r in bundle.jurisdictionalRules) {
      _checkTestData(issues, r.id, r.isTestData, isProduction);
      final inst = instrumentsById[r.instrumentId];
      if (inst == null) {
        add(
          RuleCodes.unknownJurisdictionReference,
          r.id,
          'Unknown instrument ${r.instrumentId}.',
        );
      } else if (r.effectiveFrom.isBefore(inst.effectiveFrom) ||
          (inst.effectiveTo != null &&
              (r.effectiveTo == null ||
                  r.effectiveTo!.isAfter(inst.effectiveTo!)))) {
        add(
          RuleCodes.invalidEffectivePeriod,
          r.id,
          'Rule period lies outside its instrument period.',
        );
      }
      if (r.effectiveTo != null && !r.effectiveTo!.isAfter(r.effectiveFrom)) {
        add(
          RuleCodes.invalidEffectivePeriod,
          r.id,
          'effectiveTo must be after effectiveFrom.',
        );
      }
      if (isProduction && !r.status.isPublishable) {
        add(
          RuleCodes.unpublishableStatus,
          r.id,
          '${r.status.code} rule cannot enter a production bundle.',
        );
      }
    }
  }

  void _checkTestData(
    List<ValidationIssue> issues,
    String id,
    bool isTestData,
    bool isProduction,
  ) {
    if (isTestData && isProduction) {
      issues.add(
        ValidationIssue(
          RuleCodes.testDataInProduction,
          IssueSeverity.error,
          id,
          'TEST DATA in production bundle.',
        ),
      );
    }
    if (isTestData && !id.startsWith(testDataIdPrefix)) {
      issues.add(
        ValidationIssue(
          RuleCodes.testDataIdPrefix,
          IssueSeverity.error,
          id,
          'Test data id must start with "$testDataIdPrefix".',
        ),
      );
    }
    if (!isTestData && id.startsWith(testDataIdPrefix)) {
      issues.add(
        ValidationIssue(
          RuleCodes.testDataIdPrefix,
          IssueSeverity.error,
          id,
          'Id has TEST- prefix but is not flagged as test data.',
        ),
      );
    }
  }

  void _checkConcentration(List<ValidationIssue> issues, Claim claim) {
    for (final key in ConcentrationContract.requiredKeys) {
      final v = claim.value[key];
      if (v == null || (v is String && v.isEmpty)) {
        issues.add(
          ValidationIssue(
            RuleCodes.concentrationContext,
            IssueSeverity.error,
            claim.claimId,
            'Missing "$key".',
          ),
        );
      }
    }
    final category = claim.value['category'];
    if (category is String &&
        (ConcentrationContract.forbiddenCategories.contains(category) ||
            ConcentrationCategory.tryParse(category) == null)) {
      issues.add(
        ValidationIssue(
          RuleCodes.forbiddenCategory,
          IssueSeverity.error,
          claim.claimId,
          'Category "$category" is not allowed.',
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // PHASE 4: Reagents, Screening, Methods, Emerging, yurisdiksiya statuslari
  // ---------------------------------------------------------------------------

  void _checkKnowledge(
    List<ValidationIssue> issues,
    ContentBundle b,
    Map<String, Source> sources,
    StatusResolver resolver,
    bool isProduction,
  ) {
    void err(String code, String id, String msg) =>
        issues.add(ValidationIssue(code, IssueSeverity.error, id, msg));

    void checkSourceRefs(String id, Iterable<String?> refs) {
      for (final r in refs) {
        if (r == null || r.isEmpty || !sources.containsKey(r)) {
          err(
            RuleCodes.unsourcedValue,
            id,
            'Value without a known source ($r).',
          );
        }
      }
    }

    void checkStatus(
      String id,
      int version,
      ScientificStatus declared,
      ContentDomain domain,
      List<String> sourceIds,
      bool isTestData, {
      bool checkTestData = true,
    }) {
      // Yurisdiksion yozuvlar TEST tekshiruvi _checkJurisdictionLayer’da.
      if (checkTestData) _checkTestData(issues, id, isTestData, isProduction);
      final srcs = [for (final s in sourceIds) ?sources[s]];
      final computed = resolver.resolveSubject(
        subjectId: id,
        version: version,
        domain: domain,
        sources: srcs,
      );
      final ok =
          declared == computed ||
          declared == ScientificStatus.outdated ||
          (declared == ScientificStatus.draft &&
              computed == ScientificStatus.needsReview);
      if (!ok) {
        err(
          RuleCodes.subjectStatusNotBacked,
          id,
          'Declared ${declared.code} but ${domain.code} reviews support '
          '${computed.code}.',
        );
      }
      if (checkTestData && isProduction && !declared.isPublishable) {
        err(
          RuleCodes.unpublishableStatus,
          id,
          '${declared.code} cannot enter a production bundle.',
        );
      }
      if (srcs.isNotEmpty && srcs.every((x) => !x.sourceClass.canBackClaim)) {
        err(RuleCodes.sourceNotEvidence, id, 'Only non-evidence sources.');
      }
    }

    // Yurisdiksion hujjat va qoidalar — faqat legal reviewer.
    for (final i in b.instruments) {
      checkStatus(
        i.id,
        1,
        i.status,
        ContentDomain.legal,
        [i.officialSourceId],
        i.isTestData,
        checkTestData: false,
      );
    }
    for (final r in b.jurisdictionalRules) {
      final inst = b.instruments.where((i) => i.id == r.instrumentId);
      checkStatus(
        r.id,
        r.version,
        r.status,
        ContentDomain.legal,
        [for (final i in inst) i.officialSourceId],
        r.isTestData,
        checkTestData: false,
      );
    }

    for (final r in b.recipes) {
      checkStatus(
        r.id,
        r.version,
        r.status,
        r.domain,
        r.sourceIds,
        r.isTestData,
      );
      if (r.hasPreparationData && r.sourceIds.isEmpty) {
        err(
          RuleCodes.recipeWithoutSource,
          r.id,
          'Preparation data without a source.',
        );
      }
      checkSourceRefs(r.id, r.sourceIds);
      checkSourceRefs(
        r.id,
        [
          r.finalVolume?.sourceId,
          r.storage?.sourceId,
          r.temperature?.sourceId,
          r.stability?.sourceId,
          r.disposalReference?.sourceId,
          r.qcRequirement?.sourceId,
          for (final h in r.hazards) h.sourceId,
          r.concentration?.sourceId,
          r.solvent?.sourceId,
          r.ph?.sourceId,
          r.expiry?.sourceId,
          for (final n in r.ppe) n.sourceId,
        ].where((x) => x != null),
      );
      if (!r.orderExplicitInSource && r.steps.any((st) => st.order != null)) {
        err(
          RuleCodes.unsourcedStepOrder,
          r.id,
          'Order of addition is set but the source does not state it.',
        );
      }
    }

    for (final t in b.screeningTests) {
      checkStatus(
        t.id,
        t.version,
        t.status,
        ContentDomain.tox,
        t.sourceIds,
        t.isTestData,
      );
      if (t.confirmatoryMethodIds.isEmpty || t.limitations.isEmpty) {
        err(
          RuleCodes.screeningWithoutConfirmation,
          t.id,
          'Screening test needs a confirmatory method and limitations.',
        );
      }
      checkSourceRefs(
        t.id,
        [
          t.cutoff?.sourceId,
          t.sensitivity?.sourceId,
          t.specificity?.sourceId,
          t.storage?.sourceId,
          for (final n in [
            ...t.crossReactivity,
            ...t.falsePositive,
            ...t.falseNegative,
            ...t.limitations,
            ...t.interferences,
          ])
            n.sourceId,
          t.resultType?.sourceId,
          t.detectionWindow?.sourceId,
        ].where((x) => x != null),
      );
      if (t.supportsDefinitiveIdentification) {
        final src = sources[t.definitiveIdentificationSourceId];
        final authoritative =
            src != null &&
            (src.sourceClass == SourceClass.primaryOfficial ||
                src.sourceClass == SourceClass.standardGuideline);
        if (!authoritative) {
          err(
            RuleCodes.definitiveIdWithoutAuthority,
            t.id,
            'Definitive identification requires an authoritative method.',
          );
        }
      }
    }

    for (final m in b.methods) {
      checkStatus(
        m.id,
        m.version,
        m.status,
        ContentDomain.lab,
        m.sourceIds,
        m.isTestData,
      );
      final org = m.organization != null && m.organization!.isNotEmpty;
      final juris = m.jurisdictionId;
      final mixing = switch (m.kind) {
        MethodKind.scientificMethod => juris != null,
        MethodKind.internationalStandard =>
          !org || (juris != null && juris != 'INT'),
        MethodKind.nationalMethod => !org || juris == null || juris == 'INT',
        MethodKind.institutionalSop => !org,
      };
      if (mixing) {
        err(
          RuleCodes.methodKindMixing,
          m.id,
          '${m.kind.name}: organization/jurisdiction do not match kind.',
        );
      }
      if (m.sections.isNotEmpty && m.sourceIds.isEmpty) {
        err(RuleCodes.unsourcedValue, m.id, 'Method text without a source.');
      }
      // FE042: «standart / qo‘llanma / validatsiya qilingan metod» deb
      // belgilash uchun rasmiy yoki nashr manbasi majburiy; ta’limiy
      // umumlashma hech qachon «validatsiya qilingan» deb ko‘rsatilmaydi.
      final ev = m.effectiveEvidenceType;
      if (ev != MethodEvidenceType.educationalSummary && m.sourceIds.isEmpty) {
        err(
          RuleCodes.methodEvidenceType,
          m.id,
          '${ev.name} requires a source.',
        );
      }
      if (ev == MethodEvidenceType.internationalStandard &&
          !m.sourceIds.any(
            (s) =>
                sources[s]?.sourceClass == SourceClass.standardGuideline ||
                sources[s]?.sourceClass == SourceClass.primaryOfficial,
          )) {
        err(
          RuleCodes.methodEvidenceType,
          m.id,
          'internationalStandard needs a standard/official source.',
        );
      }
      if (m.textOrigin == TextOrigin.openLicenseExcerpt &&
          m.sourceIds.any(
            (s) => sources[s]?.licenseMode != SourceLicenseMode.openReuse,
          )) {
        err(
          RuleCodes.textLicense,
          m.id,
          'Excerpted text from a source that does not permit reuse.',
        );
      }
      checkSourceRefs(m.id, m.sourceIds);
    }

    for (final e in b.emergingIssues) {
      checkStatus(
        e.id,
        1,
        e.status,
        ContentDomain.tox,
        e.sourceIds,
        e.isTestData,
      );
      if (e.sourceIds.isEmpty || e.date == null) {
        err(
          RuleCodes.emergingWithoutProvenance,
          e.id,
          'Emerging issue needs a source and a date.',
        );
      }
      checkSourceRefs(e.id, e.sourceIds);
    }

    for (final t in b.topics) {
      _checkTestData(issues, t.id, t.isTestData, isProduction);
    }
  }

  void _checkEvidenceGraph(
    List<ValidationIssue> issues,
    ContentBundle b,
    bool isProduction,
  ) {
    void err(String code, String id, String msg) =>
        issues.add(ValidationIssue(code, IssueSeverity.error, id, msg));

    final keys = <String, String>{};
    for (final r in b.research) {
      _checkTestData(issues, r.id, r.isTestData, isProduction);
      if (!r.hasIdentifier || r.title.trim().isEmpty) {
        err(
          RuleCodes.researchRecordInvalid,
          r.id,
          'Needs a title and an identifier/URL.',
        );
      }
      // Dalil darajasi turdan kuchli bo‘lmasligi kerak (A eng kuchli).
      if (r.evidenceLevel.index < r.kind.maxEvidence.index) {
        err(
          RuleCodes.researchRecordInvalid,
          r.id,
          '${r.kind.code} cannot carry evidence level ${r.evidenceLevel.code}.',
        );
      }
      if (r.status == ScientificStatus.verified ||
          r.status == ScientificStatus.reviewed) {
        err(
          RuleCodes.statusMismatch,
          r.id,
          'Research records are not reviewed in this bundle.',
        );
      }
      final k = r.dedupKey;
      final prev = keys[k];
      if (prev != null) {
        err(RuleCodes.researchDuplicate, r.id, 'Duplicate of $prev ($k).');
      } else {
        keys[k] = r.id;
      }
    }

    final known = <String>{
      ...b.knownEntityIds,
      for (final x in b.topics) x.id,
      for (final x in b.recipes) x.reagentId,
      for (final x in b.screeningTests) x.id,
      for (final x in b.methods) x.id,
      for (final x in b.emergingIssues) x.id,
      for (final x in b.research) x.id,
      for (final x in b.images) x.id,
      // PHASE 7 tugunlari.
      for (final x in b.specimens) x.id,
      for (final x in b.standards) x.id,
      for (final x in b.jurisdictionalRules) x.id,
    };
    for (final l in b.links) {
      for (final id in [l.fromId, l.toId]) {
        if (!known.contains(id)) {
          err(
            RuleCodes.brokenLink,
            '${l.fromId}->${l.toId}',
            'Unknown entity $id.',
          );
        }
      }
      if (l.basis.isEmpty) {
        err(
          RuleCodes.brokenLink,
          '${l.fromId}->${l.toId}',
          'Link needs a basis.',
        );
      }
    }

    for (final im in b.images) {
      final ok =
          allowedImageLicenses.contains(im.license) &&
          im.attribution.isNotEmpty &&
          (im.alt['en'] ?? '').isNotEmpty &&
          !im.graphic &&
          known.contains(im.entityId) &&
          // Original sxema real natija sifatida ko‘rsatilmaydi.
          !(im.isOriginalDiagram && im.representsRealData) &&
          // Tashqi rasm — manba havolasi majburiy.
          (im.isOriginalDiagram || (im.sourceUrl ?? '').isNotEmpty);
      if (!ok) {
        err(
          RuleCodes.imageLicense,
          im.id,
          'License/attribution/alt/entity invalid.',
        );
      }
    }

    for (final c in b.claims) {
      if (c.field != 'reported_concentration') continue;
      final specimen = c.value['specimen'];
      if (specimen is! List ||
          specimen.isEmpty ||
          c.value['context'] == null ||
          c.value['not_a_threshold'] != true) {
        err(
          RuleCodes.reportedConcentrationContext,
          c.claimId,
          'Reported concentration needs specimen, context and not_a_threshold.',
        );
      }
    }
  }

  /// PHASE 7 qoidalari (FE033–FE041).
  void _checkProvenance(
    List<ValidationIssue> issues,
    ContentBundle b,
    Map<String, List<String>> citationsByClaim,
  ) {
    void err(String code, String id, String msg) =>
        issues.add(ValidationIssue(code, IssueSeverity.error, id, msg));

    final claimsById = {for (final c in b.claims) c.claimId: c};
    final sourceIds = {for (final s in b.sources) s.sourceId};
    final prov = {for (final p in b.sourceProvenance) p.sourceId: p};
    final specimenIds = {for (final s in b.specimens) s.id};

    // FE033 — qat’iy konsentratsiya konteksti.
    for (final c in b.claims) {
      if (c.field != 'reported_concentration') continue;
      final ctx = c.value[StrictConcentrationContext.key];
      if (ctx is! Map) {
        err(
          RuleCodes.strictConcentrationContext,
          c.claimId,
          'Missing ${StrictConcentrationContext.key}.',
        );
        continue;
      }
      final missing = [
        for (final k in StrictConcentrationContext.requiredKeys)
          if (!ctx.containsKey(k) || ctx[k] == null) k,
      ];
      if (missing.isNotEmpty) {
        err(
          RuleCodes.strictConcentrationContext,
          c.claimId,
          'Missing keys: ${missing.join(', ')}.',
        );
      }
      if (!StrictConcentrationContext.samplingValues.contains(
            ctx['sampling'],
          ) ||
          !StrictConcentrationContext.subjectValues.contains(
            ctx['subject_state'],
          ) ||
          !StrictConcentrationContext.reportingValues.contains(
            ctx['reporting'],
          )) {
        err(
          RuleCodes.strictConcentrationContext,
          c.claimId,
          'sampling/subject_state/reporting has an unknown value.',
        );
      }
      final specimens = ctx['specimen'];
      if (specimens is! List ||
          specimens.isEmpty ||
          (specimenIds.isNotEmpty && !specimens.every(specimenIds.contains))) {
        err(
          RuleCodes.strictConcentrationContext,
          c.claimId,
          'specimen must list known specimen IDs.',
        );
      }
    }

    // FE034 — manba hayot sikli.
    for (final p in b.sourceProvenance) {
      if (!sourceIds.contains(p.sourceId)) {
        err(RuleCodes.sourceLifecycle, p.sourceId, 'Unknown source.');
      }
      if (p.lifecycle == SourceLifecycle.superseded &&
          (p.supersededBy == null || !sourceIds.contains(p.supersededBy))) {
        err(
          RuleCodes.sourceLifecycle,
          p.sourceId,
          'Superseded source must name an existing successor.',
        );
      }
      if (p.lifecycle != SourceLifecycle.current &&
          (p.lifecycleBasis ?? '').isEmpty) {
        err(
          RuleCodes.sourceLifecycle,
          p.sourceId,
          'Non-current lifecycle needs a recorded basis.',
        );
      }
    }
    for (final c in b.claims) {
      final verdict = ClaimLifecycleResolver.resolve(
        status: c.declaredStatus,
        sources: [
          for (final id in citationsByClaim[c.claimId] ?? const <String>[])
            prov[id] ?? SourceProvenance(sourceId: id),
        ],
      );
      if (c.declaredStatus.isPublishable &&
          (verdict.lifecycle == ClaimLifecycle.retracted ||
              verdict.lifecycle == ClaimLifecycle.superseded)) {
        err(
          RuleCodes.sourceLifecycle,
          c.claimId,
          'Claim relies on ${verdict.reason}: cannot be shown as current.',
        );
      }
    }

    // FE035 — ziddiyatlar.
    final conflictIds = <String>{};
    for (final k in b.conflicts) {
      if (!conflictIds.add(k.id)) {
        err(RuleCodes.conflictInvalid, k.id, 'Duplicate conflict id.');
      }
      final unknown = k.claimIds.where((id) => !claimsById.containsKey(id));
      if (unknown.isNotEmpty) {
        err(RuleCodes.conflictInvalid, k.id, 'Unknown claims: $unknown.');
      }
      if (k.claimIds.toSet().length < k.kind.minClaims) {
        err(
          RuleCodes.conflictInvalid,
          k.id,
          '${k.kind.code} needs ${k.kind.minClaims} distinct claims.',
        );
      }
      if (k.note.trim().isEmpty || k.question.trim().isEmpty) {
        err(RuleCodes.conflictInvalid, k.id, 'Question and note required.');
      }
      if (k.state != EvidenceConflictState.open &&
          !b.reviewActions.any((a) => a.subjectId == k.id)) {
        err(
          RuleCodes.conflictInvalid,
          k.id,
          'Only a reviewer action can resolve a conflict.',
        );
      }
    }

    // FE036 — metabolit munosabatlari.
    for (final r in b.metaboliteRelations) {
      final basis = claimsById[r.basisClaimId];
      final entityOk =
          basis != null &&
          (basis.entityId == r.parentId || basis.entityId == r.metaboliteId);
      final idsOk =
          b.knownEntityIds.isEmpty ||
          (b.knownEntityIds.contains(r.parentId) &&
              (r.metaboliteId == null ||
                  b.knownEntityIds.contains(r.metaboliteId)));
      final specimensOk =
          specimenIds.isEmpty || r.specimens.every(specimenIds.contains);
      if (!entityOk || !idsOk || !specimensOk) {
        err(
          RuleCodes.metaboliteRelationInvalid,
          r.id,
          'Basis claim must belong to parent or metabolite; ids and '
          'specimens must be known.',
        );
      }
      if (basis != null && r.kind != MetaboliteRelationKind.metabolite) {
        final text = '${basis.value['excerpt'] ?? ''}'.toLowerCase();
        final word = switch (r.kind) {
          MetaboliteRelationKind.activeMetabolite => 'active',
          MetaboliteRelationKind.inactiveMetabolite => 'inactive',
          MetaboliteRelationKind.marker => 'marker',
          MetaboliteRelationKind.artifact => 'artifact',
          MetaboliteRelationKind.metabolite => '',
        };
        if (!text.contains(word)) {
          err(
            RuleCodes.metaboliteRelationInvalid,
            r.id,
            'Role "${r.kind.code}" is not stated in the basis excerpt.',
          );
        }
      }
    }

    // FE037 — PHASE 7 graf qirralari kuzatiladigan asosga ega.
    final ruleIds = {for (final r in b.jurisdictionalRules) r.id};
    final standardIds = {for (final s in b.standards) s.id};
    final relationIds = {for (final r in b.metaboliteRelations) r.id};
    final known = <String>{
      ...b.knownEntityIds,
      ...specimenIds,
      ...standardIds,
      ...ruleIds,
      for (final x in b.topics) x.id,
      for (final x in b.recipes) x.reagentId,
      for (final x in b.screeningTests) x.id,
      for (final x in b.methods) x.id,
      for (final x in b.research) x.id,
    };
    for (final l in b.links) {
      if (!l.relation.requiresTraceableBasis) continue;
      final id = '${l.fromId}->${l.toId}';
      final traceable =
          claimsById.containsKey(l.basis) ||
          ruleIds.contains(l.basis) ||
          standardIds.contains(l.basis) ||
          relationIds.contains(l.basis);
      if (!traceable) {
        err(RuleCodes.untraceableEdge, id, 'Basis ${l.basis} not traceable.');
      }
      if (!known.contains(l.fromId) || !known.contains(l.toId)) {
        err(RuleCodes.untraceableEdge, id, 'Unknown endpoint.');
      }
    }

    // FE038 — standartlar: faqat metadata; litsenziyali matn yo‘q.
    for (final s in b.standards) {
      if (s.status == StandardStatus.superseded &&
          (s.supersededBy == null || !standardIds.contains(s.supersededBy))) {
        err(
          RuleCodes.standardInvalid,
          s.id,
          'Superseded standard must name an existing successor.',
        );
      }
      if (s.verifiedFrom.isEmpty || !s.verifiedFrom.startsWith('https://')) {
        err(RuleCodes.standardInvalid, s.id, 'verified_from must be https.');
      }
      if (s.sha256 != null && s.reuse == ReuseStatus.licenseRequired) {
        err(
          RuleCodes.standardInvalid,
          s.id,
          'Licensed standards are not archived in the app.',
        );
      }
    }

    // FE039 — reviewer harakatlari.
    final reviewers = {for (final r in b.reviewers) r.reviewerId: r};
    final authors = {for (final a in b.authorships) a.claimId: a.authorId};
    for (final a in b.reviewActions) {
      final claim = claimsById[a.subjectId];
      final isConflict = conflictIds.contains(a.subjectId);
      if (claim == null && !isConflict) {
        err(RuleCodes.reviewActionInvalid, a.id, 'Unknown subject.');
        continue;
      }
      final check = ReviewWorkflow.check(
        action: a,
        currentVersion: claim?.version ?? a.subjectVersion,
        subjectDomain: claim?.domain ?? a.domain,
        reviewers: reviewers,
        authorId: authors[a.subjectId],
      );
      if (!check.ok) {
        err(RuleCodes.reviewActionInvalid, a.id, check.reason);
      }
    }

    // FE040 — termin tarjimalari.
    for (final t in b.termTranslations) {
      final changed = t.localized.values.any((v) => v != t.original);
      if (!t.kind.translatable && changed) {
        err(
          RuleCodes.termTranslationInvalid,
          t.id,
          '${t.kind.code} must not be translated.',
        );
      }
      if (!t.localized.keys.every(t.status.containsKey)) {
        err(
          RuleCodes.termTranslationInvalid,
          t.id,
          'Every localized value needs a translation status.',
        );
      }
    }

    // FE041 — namunalar.
    final seen = <String>{};
    for (final s in b.specimens) {
      if (!seen.add(s.id) ||
          (s.names['en'] ?? '').isEmpty ||
          !const {
            'fluid',
            'tissue',
            'keratinous',
            'content',
          }.contains(s.category)) {
        err(RuleCodes.specimenInvalid, s.id, 'Invalid specimen record.');
      }
    }
  }
}
