import 'package:meta/meta.dart';

import 'bundle.dart';
import 'claim.dart';
import 'concentration.dart';
import 'enums.dart';
import 'jurisdiction.dart';
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
      if (claim.declaredStatus != ScientificStatus.outdated &&
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
}
