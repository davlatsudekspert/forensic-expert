import 'package:fe_content_schema/fe_content_schema.dart' show ScientificStatus;

import '../../core/l10n/generated/app_localizations.dart';
import '../../domain/pro/analysis_plan.dart';
import '../../domain/pro/pro_search.dart';

/// Pro vositalar matnlari (ARB: `l10n_pro_tools.py`).
extension ProStrings on AppLocalizations {
  String familyName(MethodFamily f) => proFamilyName(f.name);

  String planRole(PlanRole r) => planRoleName(r.name);

  String entityTypeName(ProEntityType t) => switch (t) {
    ProEntityType.substance => librarySubstances,
    ProEntityType.method => libraryMethods,
    ProEntityType.screening => searchGroupScreening,
    ProEntityType.reagent => searchGroupReagents,
  };

  String reviewStatusName(ScientificStatus s) => switch (s) {
    ScientificStatus.verified => statusVerified,
    ScientificStatus.reviewed => statusReviewed,
    ScientificStatus.outdated => statusOutdated,
    _ => statusNeedsReview,
  };

  /// Teskari qidiruv: bog‘lanish roli.
  String reverseRole(String role) => switch (role) {
    'analysed' => proRoleAnalysed,
    'confirmation' => proRoleConfirmation,
    'screened' => proRoleScreened,
    'measured' => proRoleMeasured,
    _ => role,
  };
}

/// «Xulosa uchun eslatma» matni (ekran va nusxa uchun bir xil).
String planReminderText(
  AppLocalizations l,
  PlanReminder r,
  String Function(String id) nameOf,
) {
  String names() => r.ids.map(nameOf).join(', ');
  return switch (r.kind) {
    PlanReminderKind.presumptiveOnly => l.planRemPresumptiveOnly(names()),
    PlanReminderKind.confirmationDocumented => l.planRemConfirmDocumented(
      names(),
    ),
    PlanReminderKind.confirmationNotDocumented => l.planRemConfirmMissing,
    PlanReminderKind.concentrationNotThreshold => l.planRemNotThreshold(
      r.count,
    ),
    PlanReminderKind.methodsNotPaired => l.planRemNotPaired,
    PlanReminderKind.nothingVerified => l.planRemNothingVerified,
    PlanReminderKind.openConflict => l.planRemConflict(r.count),
    PlanReminderKind.noData => l.planRemNoData,
  };
}
