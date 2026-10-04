import 'package:meta/meta.dart';

import 'bundle.dart';
import 'claim.dart';
import 'concentration.dart';
import 'enums.dart';
import 'jurisdiction.dart';
import 'knowledge.dart';
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
          ])
            n.sourceId,
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
}
