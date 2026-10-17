import 'package:flutter/material.dart';

import '../../core/design/theme.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../domain/support/support_models.dart';

extension SupportStrings on AppLocalizations {
  String supCategoryLabel(SupportCategory c) => switch (c) {
    SupportCategory.suggestion => supCatSuggestion,
    SupportCategory.bug => supCatBug,
    SupportCategory.scientificError => supCatScientificError,
    SupportCategory.featureRequest => supCatFeatureRequest,
    SupportCategory.techSupport => supCatTechSupport,
    SupportCategory.general => supCatGeneral,
  };

  String supStatus(SupportStatus s) => switch (s) {
    SupportStatus.newRequest => supStatusNew,
    SupportStatus.inReview => supStatusInReview,
    SupportStatus.answered => supStatusAnswered,
    SupportStatus.closed => supStatusClosed,
  };

  String admAction(String action) => switch (action) {
    'SUPPORT_REPLY' => admActSupportReply,
    'SUPPORT_STATUS' => admActSupportStatus,
    'SUPPORT_THREAD_VIEW' => admActSupportView,
    'USERS_VIEW' => admActUsersView,
    'VERIFICATIONS_VIEW' => admActVerificationsView,
    'ACCESS_SET' => admActAccessSet,
    'ROLE_GRANTED' => admActRoleGranted,
    'ROLE_REVOKED' => admActRoleRevoked,
    'ROLE_CHANGED' => admActRoleChanged,
    'ADMIN_ROLE_SET' => admActAdminRoleSet,
    'USER_SUSPENDED' => admActUserSuspended,
    'USER_RESTORED' => admActUserRestored,
    'REPORTS_VIEW' => admActReportsView,
    'REPORT_NOTE' => admActReportNote,
    'REPORT_RESOLVED' => admActReportResolved,
    'REPORT_REOPENED' => admActReportReopened,
    'ADMIN_BOOTSTRAP' => admActAdminBootstrap,
    _ => admActOther,
  };

  /// `android` / `ios` → «Android» / «iOS»; boshqasi o‘zgarmaydi.
  String admPlatformLabel(String p) => switch (p.toLowerCase()) {
    'android' => adminAndroid,
    'ios' => adminIos,
    _ => p,
  };

  /// Server rol kodi → nomi (`publication_moderator` admin EMAS).
  String admRoleLabel(String role) => switch (role) {
    'identity_admin' => adminAdminBadge,
    'publication_moderator' => admRolePublicationModerator,
    _ => role,
  };

  /// Jurnal tafsiloti (holat yoki rol kodi) → o‘qiladigan nom.
  String admAuditValue(String v) {
    for (final s in SupportStatus.values) {
      if (s.wire == v) return supStatus(s);
    }
    return admRoleLabel(v);
  }
}

extension SupportCategoryUi on SupportCategory {
  IconData get icon => switch (this) {
    SupportCategory.suggestion => Icons.lightbulb_outline,
    SupportCategory.bug => Icons.bug_report_outlined,
    SupportCategory.scientificError => Icons.science_outlined,
    SupportCategory.featureRequest => Icons.add_task_outlined,
    SupportCategory.techSupport => Icons.support_agent_outlined,
    SupportCategory.general => Icons.chat_bubble_outline,
  };
}

extension SupportStatusUi on SupportStatus {
  IconData get icon => switch (this) {
    SupportStatus.newRequest => Icons.mark_email_unread_outlined,
    SupportStatus.inReview => Icons.manage_search,
    SupportStatus.answered => Icons.mark_chat_read_outlined,
    SupportStatus.closed => Icons.lock_outline,
  };

  Color color(BuildContext context) {
    final c = FeTheme.of(context);
    return switch (this) {
      SupportStatus.newRequest => c.accent,
      SupportStatus.inReview => c.reviewed,
      SupportStatus.answered => c.verified,
      SupportStatus.closed => c.textSecondary,
    };
  }
}
