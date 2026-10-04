import 'package:meta/meta.dart';

import 'bundle.dart';
import 'claim.dart';
import 'concentration.dart';
import 'enums.dart';
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

    return ValidationReport(List.unmodifiable(issues));
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
