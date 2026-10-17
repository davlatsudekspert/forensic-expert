import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../domain/moderation/moderation_models.dart';

/// Shikoyat/bloklash/admin kengaytmasi domen qiymatlari → tarjima.
extension ModerationStrings on AppLocalizations {
  String repKindLabel(ReportKind k) => switch (k) {
    ReportKind.complaint => repKindComplaint,
    ReportKind.inappropriate => repKindInappropriate,
    ReportKind.bug => repKindBug,
    ReportKind.advertising => repKindAdvertising,
    ReportKind.other => repKindOther,
  };

  String repResultText(ReportResult r) => switch (r) {
    ReportResult.created => repSent,
    ReportResult.invalid => repInvalid,
    ReportResult.rateLimited => repRateLimited(ReportLimits.perHour),
    ReportResult.suspended => repSuspended,
    ReportResult.failed => repFailed,
  };

  String? roleResultText(RoleChangeResult r) => switch (r) {
    RoleChangeResult.granted => admxRoleGranted,
    RoleChangeResult.revoked => admxRoleRevoked,
    RoleChangeResult.unchanged => admxNoChange,
    RoleChangeResult.notFound => admxUserNotFound,
    RoleChangeResult.invalid => admxReasonShort,
    RoleChangeResult.forbiddenRole => admxRoleForbidden,
    RoleChangeResult.emailUnconfirmed => admxEmailUnconfirmed,
    RoleChangeResult.selfAdminChange => admxSelfAdmin,
    RoleChangeResult.lastAdmin => admxLastAdmin,
    RoleChangeResult.failed => admxActionFailed,
  };

  String? suspensionResultText(SuspensionResult r) => switch (r) {
    SuspensionResult.suspended => admxSuspended,
    SuspensionResult.restored => admxRestored,
    SuspensionResult.unchanged => admxNoChange,
    SuspensionResult.notFound => admxUserNotFound,
    SuspensionResult.invalid => admxReasonShort,
    SuspensionResult.cannotSuspendAdmin => admxCannotSuspendAdmin,
    SuspensionResult.cannotSuspendSelf => admxCannotSuspendSelf,
    SuspensionResult.failed => admxActionFailed,
  };
}

extension ReportKindUi on ReportKind {
  IconData get icon => switch (this) {
    ReportKind.complaint => Icons.report_gmailerrorred_outlined,
    ReportKind.inappropriate => Icons.visibility_off_outlined,
    ReportKind.bug => Icons.bug_report_outlined,
    ReportKind.advertising => Icons.campaign_outlined,
    ReportKind.other => Icons.chat_bubble_outline,
  };
}
